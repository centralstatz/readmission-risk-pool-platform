rrp_project_initialization_abort <- function(code, message) {
  if (!is.character(code) || length(code) != 1L || is.na(code) ||
      !grepl("^[a-z][a-z0-9_]*$", code) ||
      !is.character(message) || length(message) != 1L || is.na(message) ||
      !nzchar(message) || nchar(message, type = "bytes") > 160L ||
      grepl("[\r\n]", message)) {
    stop("Invalid internal initialization-error definition.", call. = FALSE)
  }
  stop(structure(
    list(message = message, call = NULL, code = code),
    class = c("rrp_project_initialization_error", "error", "condition")
  ))
}

rrp_project_initialization_path_exists <- function(path) {
  target <- Sys.readlink(path)
  file.exists(path) || dir.exists(path) || (!is.na(target) && nzchar(target))
}

rrp_project_initialization_inputs <- function(
  project_id,
  project_version,
  manifest_contract,
  registration_contract
) {
  identity_max <- as.integer(manifest_contract[["Identity-Max-Bytes"]])
  version_max <- as.integer(manifest_contract[["Version-Max-Bytes"]])
  valid_project_id <- rrp_project_valid_identity(
    project_id, manifest_contract[["Project-ID-Pattern"]], identity_max
  ) && !startsWith(
    project_id, manifest_contract[["Protected-Project-ID-Prefix"]]
  )
  if (!valid_project_id) {
    rrp_project_initialization_abort(
      "invalid_project_id", "Project identity is invalid."
    )
  }
  if (!rrp_project_valid_version(
    project_version, manifest_contract[["Version-Pattern"]], version_max
  )) {
    rrp_project_initialization_abort(
      "invalid_project_version", "Project version is invalid."
    )
  }

  producer_id <- paste0(project_id, ".producer")
  provider_id <- paste0(project_id, ".provider")
  component_max <- as.integer(registration_contract[["Identity-Max-Bytes"]])
  valid_component <- vapply(c(producer_id, provider_id), function(value) {
    rrp_project_valid_identity(
      value, registration_contract[["Component-ID-Pattern"]], component_max
    ) && !startsWith(
      value, registration_contract[["Protected-ID-Prefix"]]
    )
  }, logical(1L))
  if (!all(valid_component)) {
    rrp_project_initialization_abort(
      "invalid_project_id", "Project identity cannot form valid components."
    )
  }

  list(
    project_id = project_id,
    project_version = project_version,
    producer_id = producer_id,
    provider_id = provider_id
  )
}

rrp_project_initialization_destination <- function(project_root) {
  if (!rrp_project_scalar_string(project_root) ||
      grepl("[[:cntrl:]]", project_root) || startsWith(project_root, "~")) {
    rrp_project_initialization_abort(
      "invalid_project_destination", "Project destination is invalid."
    )
  }
  leaf <- basename(project_root)
  if (!nzchar(leaf) || leaf %in% c(".", "..") ||
      !identical(leaf, trimws(leaf))) {
    rrp_project_initialization_abort(
      "invalid_project_destination", "Project destination is invalid."
    )
  }
  parent <- dirname(project_root)
  parent_link <- Sys.readlink(parent)
  if (!file.exists(parent) || !dir.exists(parent) ||
      (!is.na(parent_link) && nzchar(parent_link))) {
    rrp_project_initialization_abort(
      "invalid_project_parent", "Project destination parent is invalid."
    )
  }
  parent <- normalizePath(parent, winslash = "/", mustWork = TRUE)
  destination <- gsub("\\\\", "/", file.path(parent, leaf))
  if (rrp_project_initialization_path_exists(destination)) {
    rrp_project_initialization_abort(
      "project_destination_exists", "Project destination already exists."
    )
  }
  siblings <- list.files(parent, all.files = TRUE, no.. = TRUE)
  if (any(tolower(siblings) == tolower(leaf))) {
    rrp_project_initialization_abort(
      "project_destination_exists", "Project destination already exists."
    )
  }
  list(parent = parent, destination = destination, leaf = leaf)
}

rrp_project_initialization_stage <- function(destination) {
  for (attempt in seq_len(16L)) {
    staging <- tempfile(
      paste0(".", destination$leaf, ".rrp-staging-"),
      tmpdir = destination$parent
    )
    if (rrp_project_initialization_path_exists(staging)) next
    created <- dir.create(staging, showWarnings = FALSE)
    target <- Sys.readlink(staging)
    if (isTRUE(created) && dir.exists(staging) &&
        (is.na(target) || !nzchar(target))) return(staging)
  }
  rrp_project_initialization_abort(
    "project_staging_failed", "Project staging could not be created."
  )
}

rrp_project_render_template <- function(lines, values) {
  if (!is.character(lines) || length(lines) == 0L || anyNA(lines)) {
    rrp_project_initialization_abort(
      "project_template_invalid", "Installed project template is invalid."
    )
  }
  tokens <- paste0("@@RRP_", names(values), "@@")
  present <- vapply(tokens, function(token) {
    any(grepl(token, lines, fixed = TRUE))
  }, logical(1L))
  discovered <- unique(unlist(regmatches(
    lines, gregexpr("@@RRP_[A-Z_]+@@", lines, perl = TRUE)
  ), use.names = FALSE))
  if (!all(present) || !setequal(discovered, tokens)) {
    rrp_project_initialization_abort(
      "project_template_invalid", "Installed project template is invalid."
    )
  }
  rendered <- lines
  for (index in seq_along(tokens)) {
    rendered <- gsub(tokens[[index]], values[[index]], rendered, fixed = TRUE)
  }
  if (any(grepl("@@RRP_[A-Z_]+@@", rendered, perl = TRUE))) {
    rrp_project_initialization_abort(
      "project_render_failed", "Project template rendering failed."
    )
  }
  rendered
}

rrp_project_initialization_inventory <- function(root) {
  files <- sort(list.files(
    root, recursive = TRUE, all.files = TRUE, no.. = TRUE,
    full.names = FALSE, include.dirs = FALSE
  ), method = "radix")
  directories <- sort(list.dirs(
    root, recursive = TRUE, full.names = FALSE
  ), method = "radix")
  identical(files, c("R/register.R", "rrp-project.dcf")) &&
    identical(directories[nzchar(directories)], "R")
}

rrp_project_initialization_assert_context <- function(context, inputs, root) {
  expected_root <- normalizePath(root, winslash = "/", mustWork = TRUE)
  valid <- identical(context$project_root, expected_root) &&
    identical(context$manifest[["Project-ID"]], inputs$project_id) &&
    identical(context$manifest[["Project-Version"]], inputs$project_version) &&
    identical(context$producer$component_id, inputs$producer_id) &&
    identical(context$producer$component_version, inputs$project_version) &&
    identical(context$producer$origin, "project") &&
    identical(context$provider$component_id, inputs$provider_id) &&
    identical(context$provider$component_version, inputs$project_version) &&
    identical(context$provider$origin, "project")
  if (!valid) {
    rrp_project_initialization_abort(
      "project_render_failed", "Initialized project identity is invalid."
    )
  }
  invisible(context)
}

rrp_project_initialization_failure <- function(condition) {
  diagnostic <- rrp_new_diagnostic(
    code = condition$code,
    severity = "error",
    message = "Project initialization failed."
  )
  rrp_new_operation_result(
    operation_id = "rrp.initialize-project",
    status = "failure",
    value = NULL,
    diagnostics = list(diagnostic)
  )
}

rrp_project_initialize <- function(
  software_catalog,
  project_root,
  project_id,
  project_version
) {
  manifest_contract <- rrp_project_manifest_contract(software_catalog)
  registration_contract <- rrp_project_registration_contract(software_catalog)
  manifest_template <- rrp_resource_path(
    software_catalog, "rrp.template.project-manifest"
  )
  registration_template <- rrp_resource_path(
    software_catalog, "rrp.template.project-registration"
  )
  inputs <- rrp_project_initialization_inputs(
    project_id, project_version, manifest_contract, registration_contract
  )
  destination <- rrp_project_initialization_destination(project_root)

  values <- c(
    PROJECT_ID = inputs$project_id,
    PROJECT_VERSION = inputs$project_version,
    PRODUCER_ID = inputs$producer_id,
    PROVIDER_ID = inputs$provider_id
  )
  manifest <- rrp_project_render_template(
    readLines(manifest_template, warn = FALSE, encoding = "UTF-8"), values
  )
  registration <- rrp_project_render_template(
    readLines(registration_template, warn = FALSE, encoding = "UTF-8"), values
  )

  staging <- rrp_project_initialization_stage(destination)
  staging_owned <- TRUE
  final_owned <- FALSE
  completed <- FALSE
  on.exit({
    if (!completed && final_owned &&
        rrp_project_initialization_path_exists(destination$destination)) {
      unlink(destination$destination, recursive = TRUE, force = TRUE)
    }
    if (staging_owned && rrp_project_initialization_path_exists(staging)) {
      unlink(staging, recursive = TRUE, force = TRUE)
    }
  }, add = TRUE)

  if (!dir.create(file.path(staging, "R"), showWarnings = FALSE)) {
    rrp_project_initialization_abort(
      "project_render_failed", "Project template rendering failed."
    )
  }
  tryCatch({
    writeLines(manifest, file.path(staging, "rrp-project.dcf"), useBytes = TRUE)
    writeLines(registration, file.path(staging, "R", "register.R"), useBytes = TRUE)
  }, error = function(condition) rrp_project_initialization_abort(
    "project_render_failed", "Project template rendering failed."
  ))
  if (!rrp_project_initialization_inventory(staging)) {
    rrp_project_initialization_abort(
      "project_render_failed", "Project template rendering failed."
    )
  }
  staged_context <- rrp_load_project(software_catalog, staging)
  rrp_project_initialization_assert_context(staged_context, inputs, staging)

  if (rrp_project_initialization_path_exists(destination$destination) ||
      any(tolower(list.files(
        destination$parent, all.files = TRUE, no.. = TRUE
      )) == tolower(destination$leaf))) {
    rrp_project_initialization_abort(
      "project_destination_exists", "Project destination already exists."
    )
  }
  if (!file.rename(staging, destination$destination)) {
    rrp_project_initialization_abort(
      "project_promotion_failed", "Project promotion failed."
    )
  }
  staging_owned <- FALSE
  final_owned <- TRUE
  final_context <- rrp_load_project(software_catalog, destination$destination)
  rrp_project_initialization_assert_context(
    final_context, inputs, destination$destination
  )

  value <- list(
    project_id = inputs$project_id,
    project_version = inputs$project_version,
    producer_id = inputs$producer_id,
    producer_version = inputs$project_version,
    provider_id = inputs$provider_id,
    provider_version = inputs$project_version,
    created_paths = c("rrp-project.dcf", "R/register.R")
  )
  result <- rrp_new_operation_result(
    operation_id = "rrp.initialize-project",
    status = "success",
    value = value,
    diagnostics = list()
  )
  completed <- TRUE
  result
}

#' Initialize a minimal independent RRP project
#'
#' Transactionally render the two installed project templates into one absent
#' explicit destination, prove the staged output through [rrp_load_project()],
#' atomically promote it, and load it again at its final physical location.
#'
#' @param software_catalog A validated `rrp_resource_catalog` returned by
#'   [rrp_open_resource_catalog()].
#' @param project_root One explicit absent project destination.
#' @param project_id One project identity accepted by the project contracts.
#' @param project_version One project version accepted by the project contracts.
#' @return One validated `rrp_operation_result`.
#' @export
rrp_initialize_project <- function(
  software_catalog,
  project_root,
  project_id,
  project_version
) {
  tryCatch(
    rrp_project_initialize(
      software_catalog, project_root, project_id, project_version
    ),
    rrp_resource_error = rrp_project_initialization_failure,
    rrp_project_error = rrp_project_initialization_failure,
    rrp_project_initialization_error = rrp_project_initialization_failure
  )
}
