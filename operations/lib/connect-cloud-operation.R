# Posit Connect Cloud realization from a completed reduced application artifact.

rrp_load_connect_cloud_runtime <- function(repository_root) {
  sys.source(
    file.path(
      repository_root, "deploy", "connect-cloud", "R", "realization-runtime.R"
    ),
    envir = parent.frame()
  )
  invisible(TRUE)
}

rrp_connect_cloud_source_map <- function(repository_root) c(
  "app.R" = file.path(repository_root, "deploy", "connect-cloud", "app.R"),
  "validate-connect-cloud.R" = file.path(
    repository_root, "deploy", "connect-cloud", "validate-connect-cloud.R"
  ),
  "R/connect-cloud-validation.R" = file.path(
    repository_root, "deploy", "connect-cloud", "R", "realization-runtime.R"
  ),
  "contracts/connect-cloud-realization.yml" = file.path(
    repository_root, "contracts", "deployment", "connect-cloud-realization.yml"
  ),
  "README.md" = file.path(repository_root, "deploy", "connect-cloud", "README.md")
)

rrp_connect_cloud_copy_file <- function(source, root, relative) {
  if (!rrp_artifact_safe_relative_path(relative)) stop(
    "Connect realization contains an unsafe target path: ", relative,
    call. = FALSE
  )
  destination <- file.path(root, relative)
  dir.create(dirname(destination), recursive = TRUE, showWarnings = FALSE)
  if (!file.exists(source) || dir.exists(source) || nzchar(Sys.readlink(source)) ||
      !isTRUE(file.copy(source, destination, overwrite = FALSE, copy.mode = TRUE))) stop(
    "Could not copy required Connect realization input: ", relative,
    call. = FALSE
  )
  invisible(destination)
}

rrp_connect_cloud_copy_artifact <- function(artifact_root, realization_root) {
  tree <- rrp_artifact_scan_tree(artifact_root)
  if (length(tree$symlinks) > 0L) stop(
    "Reduced artifact contains prohibited symbolic links.", call. = FALSE
  )
  for (relative in tree$files) rrp_connect_cloud_copy_file(
    file.path(artifact_root, relative),
    realization_root,
    paste0("artifact/", relative)
  )
  invisible(file.path(realization_root, "artifact"))
}

rrp_connect_cloud_write_manifest <- function(root, files) {
  if (!requireNamespace("rsconnect", quietly = TRUE)) stop(
    "Package `rsconnect@1.3.1` is required to generate manifest.json.",
    call. = FALSE
  )
  if (!identical(as.character(utils::packageVersion("rsconnect")), "1.3.1")) stop(
    "Connect realization requires the tested builder dependency rsconnect@1.3.1.",
    call. = FALSE
  )
  files <- sort(files, method = "radix")
  if (length(files) == 0L || anyDuplicated(files) ||
      !all(vapply(files, rrp_artifact_safe_relative_path, logical(1))) ||
      !all(file.exists(file.path(root, files)))) stop(
    "Connect manifest inputs must be existing unique safe relative files.",
    call. = FALSE
  )
  suppressWarnings(rsconnect::writeManifest(
    appDir = root,
    appFiles = files,
    appMode = "shiny",
    quiet = TRUE
  ))
  if (!file.exists(file.path(root, "manifest.json"))) stop(
    "rsconnect did not produce manifest.json.", call. = FALSE
  )
  invisible(rrp_connect_read_json(file.path(root, "manifest.json")))
}

rrp_connect_cloud_write_runtime_lock <- function(repository_root, root) {
  if (!requireNamespace("jsonlite", quietly = TRUE)) stop(
    "Package `jsonlite` is required to construct Connect dependency metadata.",
    call. = FALSE
  )
  source_path <- file.path(repository_root, "renv.lock")
  lock <- jsonlite::read_json(source_path, simplifyVector = FALSE)
  required <- c("shiny", "yaml")
  selected <- character()
  queue <- required
  while (length(queue) > 0L) {
    package <- queue[[1L]]
    queue <- queue[-1L]
    if (package %in% selected) next
    if (!package %in% names(lock$Packages)) stop(
      "Platform dependency lock does not contain artifact runtime root: ", package,
      call. = FALSE
    )
    selected <- c(selected, package)
    dependencies <- unlist(lock$Packages[[package]]$Requirements, use.names = FALSE)
    queue <- c(queue, dependencies[dependencies %in% names(lock$Packages)])
  }
  selected <- sort(unique(selected), method = "radix")
  lock$Packages <- lock$Packages[selected]
  direct_versions <- vapply(required, function(package) {
    lock$Packages[[package]]$Version
  }, character(1))
  if (!identical(unname(direct_versions), c("1.10.0", "2.3.10")) ||
      any(c("DBI", "duckdb", "rrpruntime", "rsconnect", "renv") %in% selected)) stop(
    "Pruned deployment lock does not match the reduced artifact dependency roots.",
    call. = FALSE
  )
  jsonlite::write_json(
    lock, file.path(root, "renv.lock"),
    pretty = TRUE, auto_unbox = TRUE, null = "null"
  )
  invisible(selected)
}

rrp_connect_cloud_git_initialize <- function(root) {
  if (!nzchar(Sys.which("git"))) stop(
    "Git is required to initialize the generated deployment repository.",
    call. = FALSE
  )
  initialized <- rrp_connect_git(root, c("init", "--initial-branch=main"))
  if (!identical(initialized$status, 0L)) stop(
    "Could not initialize the Connect deployment Git repository: ",
    paste(initialized$output, collapse = " | "), call. = FALSE
  )
  staged <- rrp_connect_git(root, c("add", "--all"))
  if (!identical(staged$status, 0L)) stop(
    "Could not stage generated deployment files: ",
    paste(staged$output, collapse = " | "), call. = FALSE
  )
  invisible(TRUE)
}

rrp_connect_cloud_path_within <- function(path, root) {
  path <- normalizePath(path, mustWork = FALSE)
  root <- normalizePath(root, mustWork = FALSE)
  identical(path, root) || startsWith(path, paste0(root, .Platform$file.sep))
}

rrp_connect_cloud_promote <- function(staging, destination, existing_owned) {
  if (!existing_owned) {
    if (!file.rename(staging, destination)) stop(
      "Could not atomically expose the generated Connect deployment repository.",
      call. = FALSE
    )
    return(list(destination = destination, backup = NULL))
  }
  parent <- dirname(destination)
  backup <- tempfile(".rrp-connect-cloud-previous-", tmpdir = parent)
  if (!file.rename(destination, backup)) stop(
    "Could not move the owned prior deployment repository aside safely.",
    call. = FALSE
  )
  promoted <- file.rename(staging, destination)
  if (!promoted) {
    rollback <- file.rename(backup, destination)
    stop(
      "Could not expose the replacement deployment repository; prior state ",
      if (rollback) "was restored." else "could not be restored automatically.",
      call. = FALSE
    )
  }
  list(destination = destination, backup = backup)
}

rrp_connect_cloud_finish_promotion <- function(promotion, validation) {
  if (identical(validation$overall_status, "pass")) {
    if (!is.null(promotion$backup)) unlink(
      promotion$backup, recursive = TRUE, force = TRUE
    )
    return(invisible(TRUE))
  }

  unlink(promotion$destination, recursive = TRUE, force = TRUE)
  restored <- is.null(promotion$backup) || file.rename(
    promotion$backup, promotion$destination
  )
  stop(
    "Promoted Connect deployment repository failed validation; ",
    if (restored) {
      if (is.null(promotion$backup)) {
        "the failed new destination was removed."
      } else "the prior owned destination was restored."
    } else "the prior owned destination could not be restored automatically.",
    call. = FALSE
  )
}

rrp_build_connect_cloud_deployment <- function(
  repository_root,
  artifact_path,
  destination,
  generated_at = rrp_application_artifact_now()
) {
  repository_root <- normalizePath(repository_root, mustWork = TRUE)
  destination <- normalizePath(destination, mustWork = FALSE)
  if (!rrp_application_artifact_timestamp(generated_at)) stop(
    "Connect realization time must be an RFC 3339 timestamp.", call. = FALSE
  )
  if (rrp_connect_cloud_path_within(destination, repository_root)) stop(
    "Connect deployment destination must be outside the authoritative repository.",
    call. = FALSE
  )
  parent <- normalizePath(dirname(destination), mustWork = FALSE)
  if (!dir.exists(parent) || nzchar(Sys.readlink(parent))) stop(
    "Connect deployment destination parent must already exist as a regular directory.",
    call. = FALSE
  )
  if (file.exists(destination) && (!dir.exists(destination) ||
      nzchar(Sys.readlink(destination)))) stop(
    "Existing deployment destination is not a regular directory.", call. = FALSE
  )

  artifact_root <- rrp_resolve_application_artifact(artifact_path)
  if (rrp_connect_cloud_path_within(destination, artifact_root) ||
      rrp_connect_cloud_path_within(artifact_root, destination)) stop(
    "Deployment destination and source artifact must not contain one another.",
    call. = FALSE
  )
  source_process <- rrp_validate_completed_application_artifact(artifact_root)
  if (!identical(source_process$overall_status, "pass")) stop(
    "Connect realization requires a valid standalone reduced artifact: ",
      paste(source_process$output, collapse = " | "), call. = FALSE
  )
  rrp_load_application_artifact_runtime(artifact_root, parent.frame())
  source_validation <- rrp_validate_application_artifact(
    artifact_root, construct_app = FALSE, check_dependencies = TRUE
  )
  if (!identical(source_validation$overall_status, "pass")) stop(
    "Connect realization source artifact is invalid: ",
    paste(source_validation$issues$issue_code, collapse = ", "), call. = FALSE
  )

  source_map <- rrp_connect_cloud_source_map(repository_root)
  if (!identical(names(source_map), rrp_connect_target_payload_files()) ||
      anyDuplicated(names(source_map)) || !all(file.exists(unname(source_map)))) stop(
    "Maintained Connect target allowlist is incomplete or inconsistent.",
    call. = FALSE
  )
  staging <- tempfile(".rrp-connect-cloud-staging-", tmpdir = parent)
  dir.create(staging)
  if (!dir.exists(staging)) stop(
    "Could not create Connect deployment staging directory.", call. = FALSE
  )
  on.exit(if (dir.exists(staging)) unlink(staging, recursive = TRUE, force = TRUE),
    add = TRUE
  )
  rrp_connect_cloud_copy_artifact(artifact_root, staging)
  for (relative in names(source_map)) rrp_connect_cloud_copy_file(
    unname(source_map[[relative]]), staging, relative
  )
  rrp_connect_cloud_write_runtime_lock(repository_root, staging)

  provisional_files <- rrp_connect_scan_tree(staging)$files
  provisional_manifest <- rrp_connect_cloud_write_manifest(staging, provisional_files)
  unlink(file.path(staging, "manifest.json"), force = TRUE)
  artifact_manifest <- source_validation$manifest
  realization_id <- rrp_connect_realization_id(
    staging, artifact_manifest, provisional_manifest
  )
  realization <- list(
    manifest_kind = "connect_cloud_git_realization_manifest",
    manifest_version = "0.1.0",
    realization_specification = rrp_connect_specification(),
    realization_id = realization_id,
    target = list(
      target_id = "posit.connect-cloud",
      delivery_model = "git_backed_repository",
      primary_file = "app.R",
      dependency_file = "manifest.json"
    ),
    source_artifact = list(
      artifact_specification = artifact_manifest$artifact_specification,
      artifact_instance_id = artifact_manifest$artifact_instance_id,
      artifact_build_id = artifact_manifest$artifact_build_id,
      product_set_id = artifact_manifest$source_product_set$product_set_id,
      artifact_manifest_checksum = list(
        algorithm = "md5",
        value = rrp_artifact_checksum(file.path(artifact_root, "ARTIFACT.yml"))
      )
    ),
    application_reference = artifact_manifest$application_reference,
    dependency_realization = list(
      mechanism = "rsconnect_manifest_json",
      r_version = provisional_manifest$platform,
      direct_runtime_roots = list(shiny = "1.10.0", yaml = "2.3.10"),
      dependency_fingerprint = rrp_connect_dependency_fingerprint(provisional_manifest)
    ),
    repository_semantics = list(
      ownership = "fully_generated_disposable_output",
      initial_branch = "main",
      generated_files_staged = TRUE,
      generated_commit = FALSE,
      configured_remote = FALSE
    ),
    build_provenance = list(
      builder_id = "platform.connect-cloud-realization-builder",
      builder_version = "0.1.0",
      operation_id = "platform.build-connect-cloud-deployment",
      generated_at = generated_at,
      dependency_manifest_generator = list(
        package = "rsconnect",
        version = as.character(utils::packageVersion("rsconnect"))
      )
    ),
    validation_evidence = c(rrp_connect_validator_reference(), list(status = "passed")),
    data_classification = "fictional_nonclinical_reference_only",
    publication_status = "not_published"
  )
  rrp_application_artifact_yaml_write(
    realization, file.path(staging, "CONNECT-REALIZATION.yml")
  )
  writeLines(
    rrp_artifact_checksum(file.path(staging, "CONNECT-REALIZATION.yml")),
    file.path(staging, "CONNECT-REALIZATION.md5"),
    useBytes = TRUE
  )
  final_manifest_files <- rrp_connect_scan_tree(staging)$files
  connect_manifest <- rrp_connect_cloud_write_manifest(staging, final_manifest_files)
  if (!identical(
    rrp_connect_dependency_fingerprint(connect_manifest),
    rrp_connect_dependency_fingerprint(provisional_manifest)
  )) stop(
    "Connect dependency closure changed while realization metadata was finalized.",
    call. = FALSE
  )
  writeLines(
    rrp_artifact_checksum(file.path(staging, "manifest.json")),
    file.path(staging, "manifest.md5"),
    useBytes = TRUE
  )

  staged_validation <- rrp_validate_connect_cloud_realization(
    staging, construct_app = TRUE, check_dependencies = TRUE, check_git = FALSE
  )
  if (!identical(staged_validation$overall_status, "pass")) stop(
    "Staged Connect realization failed content validation: ",
    paste(paste0(
      staged_validation$issues$issue_code, " (", staged_validation$issues$message, ")"
    ), collapse = ", "), call. = FALSE
  )
  rrp_connect_cloud_git_initialize(staging)
  staged_git_validation <- rrp_validate_connect_cloud_realization(
    staging, construct_app = TRUE, check_dependencies = TRUE, check_git = TRUE
  )
  if (!identical(staged_git_validation$overall_status, "pass")) stop(
    "Staged Connect realization failed Git validation: ",
    paste(staged_git_validation$issues$issue_code, collapse = ", "), call. = FALSE
  )

  existing_owned <- dir.exists(destination)
  if (existing_owned) {
    existing <- rrp_validate_connect_cloud_realization(
      destination, construct_app = TRUE, check_dependencies = TRUE, check_git = TRUE
    )
    if (!identical(existing$overall_status, "pass")) stop(
      "Existing destination is unrelated, modified, published, or otherwise not ",
      "safe for generated replacement: ",
      paste(existing$issues$issue_code, collapse = ", "), call. = FALSE
    )
    if (identical(existing$manifest$realization_id, realization_id)) {
      unlink(staging, recursive = TRUE, force = TRUE)
      return(structure(list(
        overall_status = "succeeded",
        realization_id = realization_id,
        source_artifact_build_id = artifact_manifest$artifact_build_id,
        destination = destination,
        idempotent = TRUE,
        replaced = FALSE,
        validation = existing
      ), class = "rrp_connect_cloud_build_result"))
    }
  }

  promotion <- rrp_connect_cloud_promote(staging, destination, existing_owned)
  promoted <- rrp_validate_connect_cloud_realization(
    destination, construct_app = TRUE, check_dependencies = TRUE, check_git = TRUE
  )
  rrp_connect_cloud_finish_promotion(promotion, promoted)
  structure(list(
    overall_status = "succeeded",
    realization_id = realization_id,
    source_artifact_build_id = artifact_manifest$artifact_build_id,
    destination = destination,
    idempotent = FALSE,
    replaced = existing_owned,
    validation = promoted
  ), class = "rrp_connect_cloud_build_result")
}

rrp_validate_completed_connect_cloud_deployment <- function(realization_path) {
  root <- normalizePath(realization_path, mustWork = TRUE)
  script <- file.path(root, "validate-connect-cloud.R")
  if (!file.exists(script) || nzchar(Sys.readlink(script))) stop(
    "Generated repository has no regular standalone Connect validator.",
    call. = FALSE
  )
  output <- tempfile("rrp-connect-validation-", fileext = ".log")
  on.exit(unlink(output, force = TRUE), add = TRUE)
  previous_directory <- setwd(root)
  on.exit(setwd(previous_directory), add = TRUE)
  status <- system2(
    file.path(R.home("bin"), "Rscript"),
    c("--vanilla", shQuote(script)),
    stdout = output,
    stderr = output,
    env = paste0("R_LIBS=", shQuote(paste(.libPaths(), collapse = .Platform$path.sep)))
  )
  lines <- if (file.exists(output)) readLines(output, warn = FALSE) else character()
  structure(list(
    overall_status = if (identical(status, 0L)) "pass" else "fail",
    realization_path = root,
    process_status = status,
    output = lines
  ), class = "rrp_connect_cloud_process_validation_result")
}
