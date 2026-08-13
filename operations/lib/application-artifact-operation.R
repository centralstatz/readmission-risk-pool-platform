# Target-neutral reduced application artifact construction and invocation.

rrp_load_application_artifact_contract_runtime <- function(repository_root) {
  sys.source(
    file.path(
      repository_root, "deploy", "application-artifact", "R", "artifact-runtime.R"
    ),
    envir = parent.frame()
  )
  invisible(TRUE)
}

rrp_read_application_artifact_documents <- function(repository_root) {
  paths <- list(
    contract = file.path(
      repository_root, "contracts", "deployment", "application-artifact.yml"
    ),
    application = file.path(repository_root, "app", "application.yml"),
    dependencies = file.path(
      repository_root, "deploy", "application-artifact", "runtime-dependencies.yml"
    )
  )
  documents <- lapply(paths, function(path) {
    parsed <- rrp_parse_yaml_specification(path)
    if (!is.null(parsed$error)) stop(
      "Could not read application artifact document: ", parsed$error,
      call. = FALSE
    )
    parsed$document
  })
  names(documents) <- names(paths)
  documents
}

rrp_application_artifact_source_map <- function(repository_root) c(
  "app.R" = file.path(repository_root, "deploy", "application-artifact", "app.R"),
  "validate-artifact.R" = file.path(
    repository_root, "deploy", "application-artifact", "validate-artifact.R"
  ),
  "R/artifact-runtime.R" = file.path(
    repository_root, "deploy", "application-artifact", "R", "artifact-runtime.R"
  ),
  "R/product-foundation.R" = file.path(
    repository_root, "products", "R", "foundation.R"
  ),
  "R/product-conformance.R" = file.path(
    repository_root, "products", "R", "conformance.R"
  ),
  "R/yaml-product-foundation.R" = file.path(
    repository_root, "implementations", "products", "yaml", "R", "foundation.R"
  ),
  "R/yaml-product-validation.R" = file.path(
    repository_root, "implementations", "products", "yaml", "R", "validation.R"
  ),
  "R/yaml-product-access.R" = file.path(
    repository_root, "implementations", "products", "yaml", "R", "access.R"
  ),
  "R/app-init.R" = file.path(repository_root, "app", "R", "app-init.R"),
  "R/view-models.R" = file.path(repository_root, "app", "R", "view-models.R"),
  "R/application.R" = file.path(repository_root, "app", "R", "app.R"),
  "contracts/application-artifact.yml" = file.path(
    repository_root, "contracts", "deployment", "application-artifact.yml"
  ),
  "contracts/application.yml" = file.path(repository_root, "app", "application.yml"),
  "contracts/product-materialization-adapter.yml" = file.path(
    repository_root, "contracts", "products", "product-materialization-adapter.yml"
  ),
  "contracts/initial-risk-product-set.yml" = file.path(
    repository_root, "contracts", "products", "initial-risk-product-set.yml"
  ),
  "contracts/current-episode-risk.yml" = file.path(
    repository_root, "contracts", "products", "current-episode-risk.yml"
  ),
  "contracts/episode-risk-history.yml" = file.path(
    repository_root, "contracts", "products", "episode-risk-history.yml"
  ),
  "contracts/operational-run-summary.yml" = file.path(
    repository_root, "contracts", "products", "operational-run-summary.yml"
  ),
  "config/yaml-product-adapter.yml" = file.path(
    repository_root, "implementations", "products", "yaml", "adapter.yml"
  ),
  "config/runtime-dependencies.yml" = file.path(
    repository_root, "deploy", "application-artifact", "runtime-dependencies.yml"
  )
)

rrp_application_artifact_copy_file <- function(source, root, relative) {
  destination <- file.path(root, relative)
  dir.create(dirname(destination), recursive = TRUE, showWarnings = FALSE)
  if (!file.exists(source) || dir.exists(source) || nzchar(Sys.readlink(source)) ||
      !isTRUE(file.copy(source, destination, overwrite = FALSE, copy.mode = TRUE))) stop(
    "Could not copy required regular artifact input: ", relative, call. = FALSE
  )
  invisible(destination)
}

rrp_application_artifact_inventory <- function(root, paths) {
  paths <- sort(paths, method = "radix")
  lapply(paths, function(path) list(
    path = path,
    role = if (startsWith(path, "products/")) {
      "materialized_product"
    } else if (startsWith(path, "contracts/")) {
      "runtime_contract"
    } else if (startsWith(path, "config/")) {
      "runtime_declaration"
    } else if (startsWith(path, "R/")) {
      "application_runtime"
    } else {
      "artifact_entry_point"
    },
    checksum = list(
      algorithm = "md5",
      value = rrp_artifact_checksum(file.path(root, path))
    )
  ))
}

rrp_application_artifact_now <- function() {
  format(Sys.time(), "%Y-%m-%dT%H:%M:%SZ", tz = "UTC")
}

rrp_application_artifact_timestamp <- function(value) {
  is.character(value) && length(value) == 1L && !is.na(value) &&
    grepl(
      "^[0-9]{4}-[0-9]{2}-[0-9]{2}T[0-9]{2}:[0-9]{2}:[0-9]{2}(Z|[+-][0-9]{2}:[0-9]{2})$",
      value
    ) && !is.na(as.POSIXct(value, format = "%Y-%m-%dT%H:%M:%S", tz = "UTC"))
}

rrp_application_artifact_yaml_write <- function(value, path) {
  if (!requireNamespace("yaml", quietly = TRUE)) stop(
    "Package `yaml` is required to build an application artifact.", call. = FALSE
  )
  yaml::write_yaml(value, path, handlers = list(
    integer = function(value) as.integer(value)
  ))
  invisible(path)
}

rrp_application_artifact_trees_identical <- function(left, right) {
  left_tree <- rrp_artifact_scan_tree(left)
  right_tree <- rrp_artifact_scan_tree(right)
  identical(left_tree$files, right_tree$files) &&
    length(left_tree$symlinks) == 0L && length(right_tree$symlinks) == 0L &&
    all(vapply(left_tree$files, function(path) identical(
      rrp_artifact_checksum(file.path(left, path)),
      rrp_artifact_checksum(file.path(right, path))
    ), logical(1)))
}

rrp_resolve_application_artifact <- function(store_or_artifact_path) {
  candidate <- normalizePath(store_or_artifact_path, mustWork = FALSE)
  if (!dir.exists(candidate) || nzchar(Sys.readlink(candidate))) stop(
    "Application artifact path does not exist or is a symbolic link.", call. = FALSE
  )
  if (file.exists(file.path(candidate, "ARTIFACT.yml"))) return(candidate)
  pointer_path <- file.path(candidate, "CURRENT.yml")
  if (!file.exists(pointer_path) || nzchar(Sys.readlink(pointer_path))) stop(
    "Artifact store has no regular CURRENT.yml pointer.", call. = FALSE
  )
  pointer <- rrp_artifact_read_yaml(pointer_path)
  required <- c(
    "pointer_kind", "pointer_version", "artifact_specification",
    "artifact_instance_id", "artifact_build_id", "artifact_directory",
    "manifest_checksum", "exposed_at"
  )
  safe <- is.list(pointer) && all(required %in% names(pointer)) &&
    identical(pointer$pointer_kind, "current_application_artifact_pointer") &&
    identical(pointer$pointer_version, "0.1.0") &&
    identical(pointer$artifact_specification, rrp_artifact_specification()) &&
    is.character(pointer$artifact_directory) &&
    length(pointer$artifact_directory) == 1L &&
    grepl("^artifacts/artifact-[a-f0-9]{32}$", pointer$artifact_directory)
  if (!safe) stop("Artifact store CURRENT.yml is invalid or unsafe.", call. = FALSE)
  root <- file.path(candidate, pointer$artifact_directory)
  if (!dir.exists(root) || nzchar(Sys.readlink(root))) stop(
    "Current application artifact directory is unavailable.", call. = FALSE
  )
  manifest_path <- file.path(root, "ARTIFACT.yml")
  checksum <- pointer$manifest_checksum
  if (!file.exists(manifest_path) || !is.list(checksum) ||
      !identical(checksum$algorithm, "md5") ||
      !identical(checksum$value, rrp_artifact_checksum(manifest_path))) stop(
    "Current application artifact manifest checksum is invalid.", call. = FALSE
  )
  root
}

rrp_build_reference_application_artifact <- function(
  repository_root,
  product_store,
  artifact_store,
  built_at = rrp_application_artifact_now()
) {
  repository_root <- normalizePath(repository_root, mustWork = TRUE)
  product_store <- normalizePath(product_store, mustWork = FALSE)
  artifact_store <- normalizePath(artifact_store, mustWork = FALSE)
  if (!rrp_application_artifact_timestamp(built_at)) stop(
    "Artifact build time must be an RFC 3339 timestamp.", call. = FALSE
  )
  documents <- rrp_read_application_artifact_documents(repository_root)
  if (!identical(list(
    specification_kind = documents$contract$specification_kind,
    specification_id = documents$contract$specification_id,
    specification_version = documents$contract$specification_version
  ), rrp_artifact_specification())) stop(
    "Application artifact contract identity/version is unsupported.", call. = FALSE
  )
  source_map <- rrp_application_artifact_source_map(repository_root)
  missing <- names(source_map)[!file.exists(unname(source_map))]
  if (length(missing) > 0L) stop(
    "Required artifact source is missing: ", paste(missing, collapse = ", "),
    call. = FALSE
  )
  dependency_issues <- rrp_artifact_validate_dependencies(
    documents$dependencies, check_installed = TRUE
  )
  if (length(dependency_issues) > 0L) stop(
    "Application artifact runtime dependency validation failed: ",
    paste(vapply(dependency_issues, `[[`, character(1), "message"), collapse = "; "),
    call. = FALSE
  )
  opened <- rrp_open_reference_product_access(repository_root, product_store)
  if (!identical(opened$overall_status, "succeeded")) stop(
    "Application artifact build requires a valid current product bundle: ",
    opened$message, call. = FALSE
  )
  initialized <- rrp_initialize_reference_app(opened$access)
  if (!identical(initialized$overall_status, "succeeded")) stop(
    "Application artifact build requires compatible application products: ",
    initialized$message, call. = FALSE
  )
  application <- rrp_create_reference_app(opened$access)
  if (!inherits(application, "shiny.appobj")) stop(
    "Source application did not construct successfully.", call. = FALSE
  )
  published_at <- opened$validation$pointer$published_at
  if (as.numeric(as.POSIXct(built_at, tz = "UTC")) <
      as.numeric(as.POSIXct(published_at, tz = "UTC"))) stop(
    "Artifact build time must not precede product publication.", call. = FALSE
  )

  if (file.exists(artifact_store) && !dir.exists(artifact_store)) stop(
    "Artifact store path exists and is not a directory.", call. = FALSE
  )
  dir.create(file.path(artifact_store, "artifacts"), recursive = TRUE, showWarnings = FALSE)
  if (!dir.exists(artifact_store) || nzchar(Sys.readlink(artifact_store)) ||
      nzchar(Sys.readlink(file.path(artifact_store, "artifacts")))) stop(
    "Artifact store and its artifacts directory must be regular directories.",
    call. = FALSE
  )
  staging <- tempfile(".staging-", tmpdir = file.path(artifact_store, "artifacts"))
  dir.create(staging)
  if (!dir.exists(staging)) stop("Could not create artifact staging directory.", call. = FALSE)
  on.exit(if (dir.exists(staging)) unlink(staging, recursive = TRUE, force = TRUE), add = TRUE)

  for (relative in names(source_map)) rrp_application_artifact_copy_file(
    unname(source_map[[relative]]), staging, relative
  )
  pointer <- opened$validation$pointer
  source_bundle <- file.path(product_store, pointer$bundle_directory)
  product_paths <- rrp_artifact_product_paths(pointer)
  product_sources <- c(
    file.path(product_store, "CURRENT.yml"),
    file.path(source_bundle, c(
      "PRODUCT_SET.yml", "current-episode-risk.yml",
      "episode-risk-history.yml", "operational-run-summary.yml"
    ))
  )
  if (!identical(length(product_paths), length(product_sources))) stop(
    "Current product pointer cannot be reduced safely.", call. = FALSE
  )
  for (index in seq_along(product_paths)) rrp_application_artifact_copy_file(
    product_sources[[index]], staging, product_paths[[index]]
  )

  inventory <- rrp_application_artifact_inventory(
    staging, c(names(source_map), product_paths)
  )
  product_set <- opened$validation$manifest$product_set
  application_reference <- list(
    application_id = documents$application$specification_id,
    application_version = documents$application$specification_version
  )
  instance_id <- rrp_artifact_instance_id(
    application_reference, product_set$product_set_id, inventory
  )
  build_id <- rrp_artifact_build_id(instance_id, built_at)
  manifest <- list(
    manifest_kind = "reduced_application_artifact_manifest",
    manifest_version = "0.1.0",
    artifact_specification = rrp_artifact_specification(),
    artifact_instance_id = instance_id,
    artifact_build_id = build_id,
    application_reference = application_reference,
    source_product_set = list(
      specification = product_set$product_set_specification,
      product_set_id = product_set$product_set_id
    ),
    freshness = list(
      source_cutoff_time = product_set$source_cutoff_time,
      source_as_of_time = product_set$source_as_of_time,
      latest_source_runtime_run_id = product_set$latest_source_runtime_run_id,
      product_generated_at = product_set$product_generated_at,
      product_published_at = pointer$published_at
    ),
    runtime_requirements = list(
      declaration_file = "config/runtime-dependencies.yml",
      declaration_version = documents$dependencies$declaration_version
    ),
    required_runtime_files = as.list(rrp_artifact_runtime_files()),
    required_product_members = as.list(product_paths),
    inventory = inventory,
    integrity = list(
      algorithm = "md5",
      purpose = "accidental_corruption_detection_not_authenticity",
      manifest_checksum_file = "ARTIFACT.md5"
    ),
    build_provenance = list(
      builder_id = "platform.application-artifact-builder",
      builder_version = "0.1.0",
      operation_id = "platform.build-application-artifact",
      built_at = built_at,
      source_materialization_id = pointer$materialization_id,
      source_product_build_id = product_set$product_build_id,
      source_runtime_run_ids = product_set$source_runtime_run_ids
    ),
    compatibility = list(
      product_set = documents$application$required_product_set,
      materialization_adapter = list(
        adapter_id = opened$validation$manifest$adapter_reference$adapter_id,
        adapter_version = opened$validation$manifest$adapter_reference$adapter_version
      ),
      application = application_reference
    ),
    validation_evidence = c(
      rrp_artifact_validator_reference(), list(status = "passed")
    ),
    data_classification = "fictional_nonclinical_reference_only"
  )
  rrp_application_artifact_yaml_write(manifest, file.path(staging, "ARTIFACT.yml"))
  writeLines(
    rrp_artifact_checksum(file.path(staging, "ARTIFACT.yml")),
    file.path(staging, "ARTIFACT.md5"),
    useBytes = TRUE
  )
  validation_environment <- new.env(parent = baseenv())
  sys.source(
    file.path(staging, "R", "artifact-runtime.R"),
    envir = validation_environment
  )
  validation_environment$rrp_load_application_artifact_runtime(
    staging, validation_environment
  )
  validation <- validation_environment$rrp_validate_application_artifact(
    staging, construct_app = TRUE, check_dependencies = TRUE
  )
  if (!identical(validation$overall_status, "pass")) stop(
    "Staged application artifact failed validation: ",
    paste(paste0(
      validation$issues$issue_code, " (", validation$issues$message, ")"
    ), collapse = "; "), call. = FALSE
  )

  final_name <- paste0("artifact-", sub("^.*::", "", build_id))
  final_path <- file.path(artifact_store, "artifacts", final_name)
  idempotent <- FALSE
  if (dir.exists(final_path)) {
    if (!rrp_application_artifact_trees_identical(staging, final_path)) stop(
      "Existing immutable artifact build conflicts with staged content.", call. = FALSE
    )
    unlink(staging, recursive = TRUE, force = TRUE)
    idempotent <- TRUE
  } else if (!file.rename(staging, final_path)) stop(
    "Could not atomically promote the staged application artifact.", call. = FALSE
  )
  final_validation <- validation_environment$rrp_validate_application_artifact(
    final_path, construct_app = TRUE, check_dependencies = TRUE
  )
  if (!identical(final_validation$overall_status, "pass")) stop(
    "Promoted application artifact failed validation.", call. = FALSE
  )
  current <- list(
    pointer_kind = "current_application_artifact_pointer",
    pointer_version = "0.1.0",
    artifact_specification = rrp_artifact_specification(),
    artifact_instance_id = instance_id,
    artifact_build_id = build_id,
    artifact_directory = paste0("artifacts/", final_name),
    manifest_checksum = list(
      algorithm = "md5",
      value = rrp_artifact_checksum(file.path(final_path, "ARTIFACT.yml"))
    ),
    exposed_at = built_at
  )
  pointer_staging <- tempfile(".CURRENT-", tmpdir = artifact_store, fileext = ".yml")
  on.exit(if (file.exists(pointer_staging)) unlink(pointer_staging, force = TRUE), add = TRUE)
  rrp_application_artifact_yaml_write(current, pointer_staging)
  if (!file.rename(pointer_staging, file.path(artifact_store, "CURRENT.yml"))) stop(
    "Could not atomically expose the completed application artifact.", call. = FALSE
  )
  structure(list(
    overall_status = "succeeded",
    artifact_store = artifact_store,
    artifact_path = final_path,
    artifact_instance_id = instance_id,
    artifact_build_id = build_id,
    product_set_id = product_set$product_set_id,
    source_as_of_time = product_set$source_as_of_time,
    idempotent = idempotent,
    validation = final_validation
  ), class = "rrp_application_artifact_build_result")
}

rrp_validate_completed_application_artifact <- function(store_or_artifact_path) {
  root <- rrp_resolve_application_artifact(store_or_artifact_path)
  rscript <- file.path(R.home("bin"), "Rscript")
  output <- tempfile("rrp-artifact-validation-", fileext = ".log")
  on.exit(unlink(output, force = TRUE), add = TRUE)
  previous_directory <- setwd(root)
  on.exit(setwd(previous_directory), add = TRUE)
  library_path <- paste(.libPaths(), collapse = .Platform$path.sep)
  status <- system2(
    rscript,
    c("--vanilla", shQuote(file.path(root, "validate-artifact.R"))),
    stdout = output,
    stderr = output,
    env = paste0("R_LIBS=", shQuote(library_path))
  )
  lines <- if (file.exists(output)) readLines(output, warn = FALSE) else character()
  structure(list(
    overall_status = if (identical(status, 0L)) "pass" else "fail",
    artifact_path = root,
    output = lines,
    process_status = status
  ), class = "rrp_application_artifact_process_validation_result")
}
