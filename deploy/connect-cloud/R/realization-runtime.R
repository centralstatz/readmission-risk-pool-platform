# Standalone validation for one generated Connect Cloud Git realization.
# This file discovers only its injected realization root and embedded artifact.

rrp_connect_specification <- function() list(
  specification_kind = "deployment_realization",
  specification_id = "platform.connect-cloud-git-realization",
  specification_version = "0.1.0"
)

rrp_connect_validator_reference <- function() list(
  validator_id = "platform.connect-cloud-realization-validator",
  validator_version = "0.1.0"
)

rrp_connect_target_payload_files <- function() c(
  "app.R",
  "validate-connect-cloud.R",
  "R/connect-cloud-validation.R",
  "contracts/connect-cloud-realization.yml",
  "README.md"
)

rrp_connect_identity_files <- function() c(
  rrp_connect_target_payload_files(), "renv.lock"
)

rrp_connect_issue <- function(category, issue_code, message, path = "$") {
  data.frame(
    category = category,
    severity = "error",
    issue_code = issue_code,
    message = message,
    path = path,
    stringsAsFactors = FALSE
  )
}

rrp_connect_empty_issues <- function() data.frame(
  category = character(),
  severity = character(),
  issue_code = character(),
  message = character(),
  path = character(),
  stringsAsFactors = FALSE
)

rrp_connect_bind_issues <- function(issues) {
  issues <- Filter(function(value) !is.null(value) && nrow(value) > 0L, issues)
  if (length(issues) == 0L) return(rrp_connect_empty_issues())
  do.call(rbind, issues)
}

rrp_connect_result <- function(issues = list(), manifest = NULL, application = NULL) {
  bound <- rrp_connect_bind_issues(issues)
  structure(list(
    overall_status = if (nrow(bound) == 0L) "pass" else "fail",
    issues = bound,
    manifest = manifest,
    application = application
  ), class = "rrp_connect_cloud_validation_result")
}

rrp_connect_read_json <- function(path) {
  if (!requireNamespace("jsonlite", quietly = TRUE)) stop(
    "Package `jsonlite` is required to validate a Connect Cloud realization.",
    call. = FALSE
  )
  jsonlite::read_json(path, simplifyVector = FALSE)
}

rrp_connect_scan_tree <- function(root) {
  files <- character()
  symlinks <- character()
  queue <- ""
  while (length(queue) > 0L) {
    relative_directory <- queue[[1L]]
    queue <- queue[-1L]
    directory <- if (nzchar(relative_directory)) {
      file.path(root, relative_directory)
    } else root
    children <- list.files(
      directory, all.files = TRUE, no.. = TRUE, full.names = FALSE,
      recursive = FALSE
    )
    if (!nzchar(relative_directory)) children <- setdiff(children, ".git")
    for (child in children) {
      relative <- if (nzchar(relative_directory)) {
        paste(relative_directory, child, sep = "/")
      } else child
      path <- file.path(root, relative)
      if (nzchar(Sys.readlink(path))) {
        symlinks <- c(symlinks, relative)
      } else if (dir.exists(path)) {
        queue <- c(queue, relative)
      } else {
        files <- c(files, relative)
      }
    }
  }
  list(
    files = sort(files, method = "radix"),
    symlinks = sort(symlinks, method = "radix")
  )
}

rrp_connect_package_version <- function(package) {
  value <- package$description$Version
  if (is.null(value)) NA_character_ else as.character(value)
}

rrp_connect_dependency_fingerprint <- function(manifest) {
  packages <- manifest$packages
  if (!is.list(packages) || is.null(names(packages))) return(NA_character_)
  records <- vapply(sort(names(packages), method = "radix"), function(name) {
    package <- packages[[name]]
    paste(
      name,
      rrp_connect_package_version(package),
      if (is.null(package$Source)) "" else package$Source,
      if (is.null(package$Repository)) "" else package$Repository,
      sep = "="
    )
  }, character(1))
  rrp_artifact_string_digest(paste(c(manifest$platform, records), collapse = "\n"))
}

rrp_connect_realization_id <- function(root, artifact_manifest, connect_manifest) {
  target_records <- vapply(
    sort(rrp_connect_identity_files(), method = "radix"),
    function(path) paste0(path, "=", rrp_artifact_checksum(file.path(root, path))),
    character(1)
  )
  digest <- rrp_artifact_string_digest(paste(c(
    rrp_connect_specification()$specification_id,
    rrp_connect_specification()$specification_version,
    artifact_manifest$artifact_instance_id,
    artifact_manifest$artifact_build_id,
    rrp_connect_dependency_fingerprint(connect_manifest),
    target_records
  ), collapse = "\n"))
  paste0("connect_cloud_realization::", digest)
}

rrp_connect_git <- function(root, arguments) {
  git <- Sys.which("git")
  if (!nzchar(git)) return(list(status = 127L, output = "Git is unavailable."))
  output <- suppressWarnings(system2(
    git,
    c("-C", shQuote(root), arguments),
    stdout = TRUE,
    stderr = TRUE
  ))
  status <- attr(output, "status")
  if (is.null(status)) status <- 0L
  list(status = as.integer(status), output = as.character(output))
}

rrp_connect_validate_git <- function(root, expected_files) {
  issues <- list()
  git_directory <- file.path(root, ".git")
  if (!dir.exists(git_directory) || nzchar(Sys.readlink(git_directory))) return(list(
    rrp_connect_issue(
      "git", "missing_independent_git_repository",
      "Generated realization must contain a regular independent .git directory.",
      ".git"
    )
  ))
  inside <- rrp_connect_git(root, c("rev-parse", "--is-inside-work-tree"))
  if (!identical(inside$status, 0L) || !identical(inside$output, "true")) {
    issues[[length(issues) + 1L]] <- rrp_connect_issue(
      "git", "invalid_git_work_tree",
      "Destination is not an independent Git work tree.", ".git"
    )
  }
  remotes <- rrp_connect_git(root, "remote")
  if (!identical(remotes$status, 0L) || length(remotes$output) > 0L) {
    issues[[length(issues) + 1L]] <- rrp_connect_issue(
      "git", "configured_git_remote",
      "Generated realization must not configure or inherit a Git remote.", ".git/config"
    )
  }
  head <- rrp_connect_git(root, c("rev-parse", "--verify", "HEAD"))
  if (identical(head$status, 0L)) issues[[length(issues) + 1L]] <- rrp_connect_issue(
    "git", "generated_repository_has_commit",
    "Generation stops before a commit so the operator controls Git authorship.", ".git/HEAD"
  )
  branch <- rrp_connect_git(root, c("symbolic-ref", "--short", "HEAD"))
  if (!identical(branch$status, 0L) || !identical(branch$output, "main")) {
    issues[[length(issues) + 1L]] <- rrp_connect_issue(
      "git", "unexpected_initial_branch",
      "Generated repository must use the uncommitted main branch.", ".git/HEAD"
    )
  }
  tracked <- rrp_connect_git(root, "ls-files")
  tracked_files <- sort(tracked$output, method = "radix")
  if (!identical(tracked$status, 0L) || !identical(tracked_files, expected_files)) {
    issues[[length(issues) + 1L]] <- rrp_connect_issue(
      "git", "git_index_inventory_mismatch",
      "Every generated file, and only generated files, must be staged in Git.", ".git/index"
    )
  }
  unstaged <- rrp_connect_git(root, c("diff", "--quiet"))
  if (!identical(unstaged$status, 0L)) issues[[length(issues) + 1L]] <-
    rrp_connect_issue(
      "git", "unstaged_generated_repository_change",
      "Generated files differ from the staged Git index.", "$"
    )
  status <- rrp_connect_git(root, c("status", "--porcelain=v1", "--untracked-files=all"))
  expected_status <- paste0("A  ", expected_files)
  if (!identical(status$status, 0L) ||
      !identical(sort(status$output, method = "radix"), expected_status)) {
    issues[[length(issues) + 1L]] <- rrp_connect_issue(
      "git", "unexpected_generated_git_status",
      "Generated repository must contain only staged additions and no other changes.", "$"
    )
  }
  for (key in c("user.name", "user.email")) {
    configured <- rrp_connect_git(root, c("config", "--local", "--get", key))
    if (identical(configured$status, 0L) && length(configured$output) > 0L) {
      issues[[length(issues) + 1L]] <- rrp_connect_issue(
        "git", "invented_local_git_identity",
        "Generator must not set a local Git author identity.", ".git/config"
      )
    }
  }
  issues
}

rrp_validate_connect_cloud_realization <- function(
  root,
  construct_app = TRUE,
  check_dependencies = TRUE,
  check_git = TRUE
) {
  issues <- list()
  root_link <- nzchar(Sys.readlink(root))
  root <- normalizePath(root, mustWork = FALSE)
  if (!dir.exists(root) || root_link) return(rrp_connect_result(list(
    rrp_connect_issue(
      "integrity", "realization_root_unavailable",
      "Realization root must be an existing regular directory.", "$"
    )
  )))
  tree <- rrp_connect_scan_tree(root)
  for (path in tree$symlinks) issues[[length(issues) + 1L]] <- rrp_connect_issue(
    "integrity", "realization_symbolic_link",
    "Symbolic links are prohibited in the generated deployment repository.", path
  )
  required <- c(
    "app.R", "manifest.json", "manifest.md5", "renv.lock", "CONNECT-REALIZATION.yml",
    "CONNECT-REALIZATION.md5", "validate-connect-cloud.R", "README.md",
    "R/connect-cloud-validation.R", "contracts/connect-cloud-realization.yml",
    "artifact/ARTIFACT.yml", "artifact/ARTIFACT.md5"
  )
  for (path in setdiff(required, tree$files)) issues[[length(issues) + 1L]] <-
    rrp_connect_issue(
      "inventory", "missing_connect_realization_file",
      "Required generated deployment file is missing.", path
    )
  if (length(setdiff(required, tree$files)) > 0L) return(rrp_connect_result(issues))

  manifest_checksum <- trimws(readLines(file.path(root, "manifest.md5"), warn = FALSE))
  if (length(manifest_checksum) != 1L ||
      !identical(manifest_checksum, rrp_artifact_checksum(file.path(root, "manifest.json")))) {
    issues[[length(issues) + 1L]] <- rrp_connect_issue(
      "integrity", "connect_manifest_checksum_mismatch",
      "manifest.md5 does not match manifest.json.", "manifest.md5"
    )
  }
  realization_checksum <- trimws(readLines(
    file.path(root, "CONNECT-REALIZATION.md5"), warn = FALSE
  ))
  if (length(realization_checksum) != 1L || !identical(
    realization_checksum,
    rrp_artifact_checksum(file.path(root, "CONNECT-REALIZATION.yml"))
  )) issues[[length(issues) + 1L]] <- rrp_connect_issue(
    "integrity", "realization_manifest_checksum_mismatch",
    "CONNECT-REALIZATION.md5 does not match its manifest.",
    "CONNECT-REALIZATION.md5"
  )
  if (nrow(rrp_connect_bind_issues(issues)) > 0L) return(rrp_connect_result(issues))

  connect_manifest <- tryCatch(
    rrp_connect_read_json(file.path(root, "manifest.json")),
    error = function(value) value
  )
  realization <- tryCatch(
    rrp_artifact_read_yaml(file.path(root, "CONNECT-REALIZATION.yml")),
    error = function(value) value
  )
  contract <- tryCatch(
    rrp_artifact_read_yaml(file.path(root, "contracts", "connect-cloud-realization.yml")),
    error = function(value) value
  )
  if (inherits(connect_manifest, "condition") || !is.list(connect_manifest) ||
      inherits(realization, "condition") || !is.list(realization) ||
      inherits(contract, "condition") || !is.list(contract)) return(
    rrp_connect_result(c(issues, list(rrp_connect_issue(
      "contract", "unreadable_connect_realization_metadata",
      "Connect manifest, realization manifest, and contract must be readable.", "$"
    ))))
  )

  manifest_files <- sort(names(connect_manifest$files), method = "radix")
  safe_manifest <- length(manifest_files) > 0L && !anyDuplicated(manifest_files) &&
    all(vapply(manifest_files, rrp_artifact_safe_relative_path, logical(1)))
  if (!safe_manifest) issues[[length(issues) + 1L]] <- rrp_connect_issue(
    "inventory", "unsafe_connect_manifest_inventory",
    "Connect manifest file entries must be unique safe relative paths.",
    "manifest.json#files"
  ) else {
    expected_files <- sort(c(manifest_files, "manifest.json", "manifest.md5"),
      method = "radix"
    )
    if (!identical(tree$files, expected_files)) issues[[length(issues) + 1L]] <-
      rrp_connect_issue(
        "inventory", "connect_inventory_mismatch",
        paste0(
          "Generated repository differs from its closed manifest inventory. Unexpected: ",
          paste(setdiff(tree$files, expected_files), collapse = ", "),
          "; missing: ", paste(setdiff(expected_files, tree$files), collapse = ", "), "."
        ), "$"
      )
    for (path in manifest_files) {
      declared <- connect_manifest$files[[path]]$checksum
      if (!is.character(declared) || length(declared) != 1L ||
          !file.exists(file.path(root, path)) ||
          !identical(declared, rrp_artifact_checksum(file.path(root, path)))) {
        issues[[length(issues) + 1L]] <- rrp_connect_issue(
          "integrity", "connect_member_checksum_mismatch",
          "Generated repository member differs from manifest.json.", path
        )
      }
    }
  }

  specification <- realization$realization_specification
  contract_identity <- contract[c(
    "specification_kind", "specification_id", "specification_version"
  )]
  if (!identical(specification, rrp_connect_specification()) ||
      !identical(contract_identity, rrp_connect_specification()) ||
      !identical(realization$target, list(
        target_id = "posit.connect-cloud",
        delivery_model = "git_backed_repository",
        primary_file = "app.R",
        dependency_file = "manifest.json"
      ))) issues[[length(issues) + 1L]] <- rrp_connect_issue(
    "compatibility", "unsupported_connect_realization",
    "Connect realization identity or target declaration is unsupported.",
    "CONNECT-REALIZATION.yml"
  )
  metadata_ok <- identical(connect_manifest$version, 1L) &&
    identical(connect_manifest$metadata$appmode, "shiny") &&
    is.character(connect_manifest$platform) && length(connect_manifest$platform) == 1L
  if (!metadata_ok) issues[[length(issues) + 1L]] <- rrp_connect_issue(
    "dependencies", "invalid_connect_cloud_manifest",
    "manifest.json must identify version 1 Shiny content and one R platform.",
    "manifest.json"
  )

  artifact_root <- file.path(root, "artifact")
  artifact_validation <- rrp_validate_application_artifact(
    artifact_root, construct_app = FALSE, check_dependencies = check_dependencies
  )
  if (!identical(artifact_validation$overall_status, "pass")) {
    issues[[length(issues) + 1L]] <- rrp_connect_issue(
      "source_artifact", "invalid_embedded_application_artifact",
      paste(
        "Embedded reduced artifact failed independent validation:",
        paste(artifact_validation$issues$issue_code, collapse = ", ")
      ), "artifact"
    )
  } else {
    artifact_manifest <- artifact_validation$manifest
    source_reference <- list(
      artifact_specification = artifact_manifest$artifact_specification,
      artifact_instance_id = artifact_manifest$artifact_instance_id,
      artifact_build_id = artifact_manifest$artifact_build_id,
      product_set_id = artifact_manifest$source_product_set$product_set_id,
      artifact_manifest_checksum = list(
        algorithm = "md5",
        value = rrp_artifact_checksum(file.path(artifact_root, "ARTIFACT.yml"))
      )
    )
    if (!identical(realization$source_artifact, source_reference)) {
      issues[[length(issues) + 1L]] <- rrp_connect_issue(
        "provenance", "source_artifact_provenance_mismatch",
        "Realization provenance does not match the embedded artifact.",
        "CONNECT-REALIZATION.yml#source_artifact"
      )
    }
    expected_id <- rrp_connect_realization_id(root, artifact_manifest, connect_manifest)
    if (!identical(realization$realization_id, expected_id)) {
      issues[[length(issues) + 1L]] <- rrp_connect_issue(
        "identity", "connect_realization_identity_mismatch",
        "Realization identity does not match target, artifact, dependencies, and payload.",
        "CONNECT-REALIZATION.yml#realization_id"
      )
    }
  }

  packages <- connect_manifest$packages
  direct <- list(shiny = "1.10.0", yaml = "2.3.10")
  direct_ok <- is.list(packages) && all(vapply(names(direct), function(name) {
    name %in% names(packages) &&
      identical(rrp_connect_package_version(packages[[name]]), direct[[name]])
  }, logical(1)))
  forbidden_packages <- intersect(
    names(packages), c("DBI", "duckdb", "rrpruntime", "rsconnect", "renv")
  )
  platform_version <- tryCatch(package_version(connect_manifest$platform),
    error = function(value) NULL
  )
  platform_ok <- !is.null(platform_version) &&
    platform_version >= package_version("4.1.0") &&
    platform_version >= package_version("4.0.0") &&
    platform_version < package_version("4.7.0")
  runtime_lock <- tryCatch(
    rrp_connect_read_json(file.path(root, "renv.lock")),
    error = function(value) value
  )
  lock_packages <- if (inherits(runtime_lock, "condition") ||
      !is.list(runtime_lock$Packages)) character() else names(runtime_lock$Packages)
  lock_ok <- setequal(lock_packages, names(packages)) &&
    !any(c("DBI", "duckdb", "rrpruntime", "rsconnect", "renv") %in% lock_packages) &&
    all(vapply(names(direct), function(name) {
      name %in% lock_packages &&
        identical(runtime_lock$Packages[[name]]$Version, direct[[name]])
    }, logical(1)))
  if (!direct_ok || !lock_ok || length(forbidden_packages) > 0L || !platform_ok ||
      !identical(realization$dependency_realization, list(
        mechanism = "rsconnect_manifest_json",
        r_version = connect_manifest$platform,
        direct_runtime_roots = direct,
        dependency_fingerprint = rrp_connect_dependency_fingerprint(connect_manifest)
      ))) issues[[length(issues) + 1L]] <- rrp_connect_issue(
    "dependencies", "connect_dependency_realization_mismatch",
    "Connect dependencies must realize the exact artifact roots without platform-only packages.",
    "manifest.json#packages"
  )

  prohibited_prefixes <- c(
    "operations/", "runtime/", "implementations/", "products/", "tests/",
    "docs/", "renv/", ".github/", "source/", "provider/", "history/"
  )
  prohibited <- tree$files[vapply(tree$files, function(path) any(startsWith(
    path, prohibited_prefixes
  )), logical(1))]
  forbidden_names <- tree$files[grepl(
    "(^|/)([.]env($|[.])|credentials?|secrets?)|[.](pem|key|p12|pfx)$",
    tree$files, ignore.case = TRUE, perl = TRUE
  )]
  if (length(c(prohibited, forbidden_names)) > 0L) issues[[length(issues) + 1L]] <-
    rrp_connect_issue(
      "boundary", "prohibited_connect_repository_content",
      paste("Generated repository contains prohibited content:", paste(
        c(prohibited, forbidden_names), collapse = ", "
      )), "$"
    )
  text_files <- tree$files[grepl("[.](R|ya?ml|md|json)$", tree$files, ignore.case = TRUE)]
  text <- unlist(lapply(file.path(root, text_files), readLines, warn = FALSE),
    use.names = FALSE
  )
  machine_pattern <- paste(
    paste0("/", "(Users|home)", "/[^/]+/"),
    "(^|[[:space:]\"'])[A-Za-z]:[/\\\\]",
    sep = "|"
  )
  secret_pattern <- paste(
    paste("BEGIN", "(RSA |EC |OPENSSH )?PRIVATE KEY"),
    paste0("AK", "IA[0-9A-Z]{16}"),
    paste0("gh", "[pousr]_[A-Za-z0-9]{20,}"),
    sep = "|"
  )
  machine_path <- any(grepl(machine_pattern, text, perl = TRUE))
  secret <- any(grepl(secret_pattern, text, perl = TRUE))
  if (machine_path || secret) issues[[length(issues) + 1L]] <- rrp_connect_issue(
    "boundary", "nonportable_or_sensitive_connect_content",
    paste0(
      "Generated repository contains ",
      if (machine_path) "a developer path" else "possible secret material", "."
    ), "$"
  )

  expected_files <- sort(tree$files, method = "radix")
  if (check_git) issues <- c(issues, rrp_connect_validate_git(root, expected_files))
  if (nrow(rrp_connect_bind_issues(issues)) > 0L) return(
    rrp_connect_result(issues, realization)
  )

  application <- NULL
  if (construct_app) {
    previous_directory <- setwd(root)
    loaded <- tryCatch(source(
      "app.R", local = new.env(parent = globalenv()), chdir = FALSE
    )$value, error = function(value) value)
    setwd(previous_directory)
    if (inherits(loaded, "condition") || !inherits(loaded, "shiny.appobj")) {
      issues[[length(issues) + 1L]] <- rrp_connect_issue(
        "application", "connect_application_construction_failed",
        if (inherits(loaded, "condition")) conditionMessage(loaded) else {
          "Root app.R did not return a Shiny application."
        }, "app.R"
      )
    } else application <- loaded
  }
  rrp_connect_result(issues, realization, application)
}
