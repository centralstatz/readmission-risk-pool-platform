# Credential-safe GitHub REST client for the maintainer publication operation.
# Credentials remain in process memory and are passed to curl on standard input;
# they are never written to release evidence, command arguments, or diagnostics.

rrp_publication_json_escape <- function(value) {
  encoded <- encodeString(value, quote = '"', na.encode = FALSE)
  substring(encoded, 2L, nchar(encoded) - 1L)
}

rrp_publication_json <- function(value) {
  if (is.null(value)) return("null")
  if (is.logical(value) && length(value) == 1L) {
    return(if (isTRUE(value)) "true" else "false")
  }
  if (is.numeric(value) && length(value) == 1L && is.finite(value)) {
    return(as.character(value))
  }
  if (is.character(value) && length(value) == 1L) {
    return(paste0('"', rrp_publication_json_escape(value), '"'))
  }
  if (is.list(value) && !is.null(names(value)) && all(nzchar(names(value)))) {
    members <- vapply(seq_along(value), function(index) paste0(
      rrp_publication_json(names(value)[[index]]), ":",
      rrp_publication_json(value[[index]])
    ), character(1))
    return(paste0("{", paste(members, collapse = ","), "}"))
  }
  if (is.list(value) || length(value) > 1L) {
    members <- vapply(as.list(value), rrp_publication_json, character(1))
    return(paste0("[", paste(members, collapse = ","), "]"))
  }
  stop("Unsupported value in GitHub JSON request.", call. = FALSE)
}

rrp_publication_git_credential <- function(remote_url) {
  if (!grepl("^https://github[.]com/", remote_url)) stop(
    "GitHub publication requires the expected HTTPS GitHub remote.", call. = FALSE
  )
  output <- suppressWarnings(system2(
    Sys.which("git"), c("credential", "fill"),
    input = c(paste0("url=", remote_url), ""), stdout = TRUE, stderr = TRUE
  ))
  status <- attr(output, "status")
  if (!is.null(status) && !identical(as.integer(status), 0L)) stop(
    "GitHub authentication is unavailable from the configured Git credential helper.",
    call. = FALSE
  )
  records <- strsplit(output[grepl("=", output, fixed = TRUE)], "=", fixed = TRUE)
  names <- vapply(records, `[[`, character(1), 1L)
  values <- vapply(records, function(record) {
    paste(record[-1L], collapse = "=")
  }, character(1))
  credential <- setNames(values, names)
  if (!all(c("username", "password") %in% names(credential)) ||
      !nzchar(credential[["username"]]) || !nzchar(credential[["password"]])) stop(
    "GitHub authentication did not provide a usable username and token.", call. = FALSE
  )
  list(username = credential[["username"]], token = credential[["password"]])
}

rrp_publication_http_request <- function(
  credential,
  method,
  url,
  body = NULL,
  download_path = NULL,
  content_type = "application/vnd.github+json"
) {
  curl <- Sys.which("curl")
  if (!nzchar(curl)) stop("curl is required for GitHub publication.", call. = FALSE)
  response_path <- download_path %||% tempfile("rrp-github-response-")
  remove_response <- is.null(download_path)
  if (remove_response) on.exit(unlink(response_path, force = TRUE), add = TRUE)
  request_path <- NULL
  if (!is.null(body)) {
    request_path <- tempfile("rrp-github-request-")
    on.exit(unlink(request_path, force = TRUE), add = TRUE)
    writeLines(body, request_path, useBytes = TRUE)
  }
  arguments <- c(
    "-sS", "--location", "--request", method, "--output", shQuote(response_path),
    "--write-out", shQuote("%{http_code}"), "--header", "@-"
  )
  if (!is.null(request_path)) arguments <- c(
    arguments, "--data-binary", shQuote(paste0("@", request_path))
  )
  arguments <- c(arguments, shQuote(url))
  headers <- c(
    paste0("Authorization: Bearer ", credential$token),
    paste0("Accept: ", content_type),
    "X-GitHub-Api-Version: 2022-11-28",
    "User-Agent: readmission-risk-pool-release-publisher",
    if (!is.null(body)) "Content-Type: application/json" else character(),
    ""
  )
  output <- suppressWarnings(system2(
    curl, arguments, input = headers, stdout = TRUE, stderr = TRUE
  ))
  process_status <- attr(output, "status")
  if (!is.null(process_status) && !identical(as.integer(process_status), 0L)) stop(
    "GitHub API transport failed without changing publication evidence.", call. = FALSE
  )
  http_status <- suppressWarnings(as.integer(tail(output, 1L)))
  if (is.na(http_status)) stop(
    "GitHub API did not return an HTTP status.", call. = FALSE
  )
  data <- NULL
  if (remove_response && file.exists(response_path) && file.info(response_path)$size > 0) {
    data <- tryCatch(suppressWarnings(yaml::read_yaml(response_path)),
                     error = function(condition) NULL)
  }
  list(status = http_status, data = data, path = response_path)
}

rrp_publication_public_download <- function(url, path) {
  curl <- Sys.which("curl")
  if (!nzchar(curl)) stop("curl is required for release acquisition.", call. = FALSE)
  output <- suppressWarnings(system2(curl, c(
    "-sS", "--location", "--output", shQuote(path),
    "--write-out", shQuote("%{http_code}"), shQuote(url)
  ), stdout = TRUE, stderr = TRUE))
  process_status <- attr(output, "status")
  if (!is.null(process_status) && !identical(as.integer(process_status), 0L)) stop(
    "Public release acquisition failed.", call. = FALSE
  )
  list(status = suppressWarnings(as.integer(tail(output, 1L))), path = path)
}

rrp_github_publication_client <- function(remote_url) {
  credential <- rrp_publication_git_credential(remote_url)
  api <- "https://api.github.com"
  request <- function(method, path, body = NULL, download_path = NULL,
                      content_type = "application/vnd.github+json") {
    rrp_publication_http_request(
      credential, method, paste0(api, path), body, download_path, content_type
    )
  }
  structure(list(
    authenticated_user = function() request("GET", "/user"),
    repository = function(repository) request("GET", paste0("/repos/", repository)),
    organization = function(owner) request("GET", paste0("/orgs/", owner)),
    membership = function(owner, login) request(
      "GET", paste0("/orgs/", owner, "/memberships/", login)
    ),
    branch_rules = function(repository, branch) request(
      "GET", paste0("/repos/", repository, "/rules/branches/", branch)
    ),
    branch_protection = function(repository, branch) request(
      "GET", paste0("/repos/", repository, "/branches/", branch, "/protection")
    ),
    tag = function(repository, tag) request(
      "GET", paste0("/repos/", repository, "/git/ref/tags/", tag)
    ),
    annotated_tag = function(repository, object_sha) request(
      "GET", paste0("/repos/", repository, "/git/tags/", object_sha)
    ),
    branch = function(repository, branch) request(
      "GET", paste0("/repos/", repository, "/git/ref/heads/", branch)
    ),
    release = function(repository, tag) request(
      "GET", paste0("/repos/", repository, "/releases/tags/", tag)
    ),
    private_vulnerability_reporting = function(repository) request(
      "GET", paste0("/repos/", repository, "/private-vulnerability-reporting")
    ),
    enable_private_vulnerability_reporting = function(repository) request(
      "PUT", paste0("/repos/", repository, "/private-vulnerability-reporting")
    ),
    create_repository = function(owner, name, description) request(
      "POST", paste0("/orgs/", owner, "/repos"), rrp_publication_json(list(
        name = name, description = description, private = FALSE,
        has_issues = TRUE, has_projects = FALSE, has_wiki = FALSE,
        auto_init = FALSE
      ))
    ),
    create_release = function(repository, tag, name, notes, target_commitish) request(
      "POST", paste0("/repos/", repository, "/releases"),
      rrp_publication_json(list(
        tag_name = tag, target_commitish = target_commitish, name = name,
        body = notes, draft = FALSE, prerelease = FALSE,
        generate_release_notes = FALSE
      ))
    ),
    upload_binary_asset = function(repository, release_id, name, path,
                                   media_type = "application/octet-stream") {
      response <- tempfile("rrp-upload-response-")
      on.exit(unlink(response, force = TRUE), add = TRUE)
      curl <- Sys.which("curl")
      url <- paste0(
        "https://uploads.github.com/repos/", repository, "/releases/",
        release_id, "/assets?name=", utils::URLencode(name, reserved = TRUE)
      )
      headers <- c(
        paste0("Authorization: Bearer ", credential$token),
        "Accept: application/vnd.github+json",
        "X-GitHub-Api-Version: 2022-11-28",
        "User-Agent: readmission-risk-pool-release-publisher", ""
      )
      output <- suppressWarnings(system2(curl, c(
        "-sS", "--location", "--request", "POST", "--output", shQuote(response),
        "--write-out", shQuote("%{http_code}"), "--header", "@-",
        "--header", shQuote(paste0("Content-Type: ", media_type)),
        "--data-binary", shQuote(paste0("@", path)), shQuote(url)
      ), input = headers, stdout = TRUE, stderr = TRUE))
      status <- suppressWarnings(as.integer(tail(output, 1L)))
      data <- if (file.exists(response) && file.info(response)$size > 0) {
        tryCatch(suppressWarnings(yaml::read_yaml(response)),
                 error = function(condition) NULL)
      } else NULL
      list(status = status, data = data)
    },
    download = function(url, path) rrp_publication_public_download(url, path)
  ), class = "rrp_github_publication_client")
}
