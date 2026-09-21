rrp_backup_manifest_fields <- function(contract) {
  strsplit(contract[["Fields"]], ",", fixed = TRUE)[[1L]]
}

rrp_backup_new_identity <- function() {
  sub("^rrp[.]state[.]", "rrp.backup.", rrp_state_new_identity())
}

rrp_backup_new_manifest <- function(metadata, evidence, contract) {
  values <- c(
    "Record-Type" = contract[["Manifest-Record-Type"]],
    "Backup-Contract-ID" = contract[["Contract-ID"]],
    "Backup-Contract-Version" = contract[["Contract-Version"]],
    "Format-Version" = contract[["Format-Version"]],
    "Product-ID" = contract[["Product-ID"]],
    "Development-Version" = contract[["Development-Version"]],
    "Backup-ID" = rrp_backup_new_identity(),
    "Source-State-ID" = metadata[["State-ID"]],
    "Project-ID" = metadata[["Project-ID"]],
    "Project-API-ID" = metadata[["Project-API-ID"]],
    "Project-API-Version" = metadata[["Project-API-Version"]],
    "State-Contract-ID" = metadata[["State-Contract-ID"]],
    "State-Contract-Version" = metadata[["State-Contract-Version"]],
    "Logical-History-Format-Version" =
      metadata[["Logical-History-Format-Version"]],
    "Target-ID" = metadata[["Target-ID"]],
    "Target-Version" = metadata[["Target-Version"]],
    "History-Scope-Contract-ID" = metadata[["History-Scope-Contract-ID"]],
    "History-Scope-Contract-Version" =
      metadata[["History-Scope-Contract-Version"]],
    "History-Disposition-Contract-ID" =
      metadata[["History-Disposition-Contract-ID"]],
    "History-Disposition-Contract-Version" =
      metadata[["History-Disposition-Contract-Version"]],
    "History-Action-Contract-ID" = metadata[["History-Action-Contract-ID"]],
    "History-Action-Contract-Version" =
      metadata[["History-Action-Contract-Version"]],
    "History-Port-Contract-ID" = metadata[["History-Port-Contract-ID"]],
    "History-Port-Contract-Version" = metadata[["History-Port-Contract-Version"]],
    "Adapter-ID" = metadata[["Adapter-ID"]],
    "Adapter-Version" = metadata[["Adapter-Version"]],
    "Physical-Schema-Version" = metadata[["Physical-Schema-Version"]],
    "Payload-Encoding-Version" = metadata[["Payload-Encoding-Version"]],
    "Created-At" = format(Sys.time(), "%Y-%m-%dT%H:%M:%SZ", tz = "UTC"),
    "High-Water-Commit-ID" = evidence$high_water_commit_id,
    "Scope-Count" = as.character(evidence$scope_count),
    "Disposition-Count" = as.character(evidence$disposition_count),
    "Action-Count" = as.character(evidence$action_count),
    "Payload-File" = contract[["Payload-File"]],
    "Payload-Size" = evidence$payload_size,
    "Artifact-Inventory" = contract[["Artifact-Inventory"]]
  )
  stopifnot(identical(names(values), rrp_backup_manifest_fields(contract)))
  values
}

rrp_backup_read_manifest <- function(path) {
  tryCatch(
    rrp_state_read_metadata(path),
    rrp_state_error = function(condition) rrp_state_abort(
      "backup_invalid", "Project state backup is invalid."
    )
  )
}

rrp_backup_validate_manifest <- function(
  manifest, metadata, evidence, context, contract
) {
  fixed <- c(
    "Record-Type" = contract[["Manifest-Record-Type"]],
    "Backup-Contract-ID" = contract[["Contract-ID"]],
    "Backup-Contract-Version" = contract[["Contract-Version"]],
    "Format-Version" = contract[["Format-Version"]],
    "Product-ID" = contract[["Product-ID"]],
    "Development-Version" = contract[["Development-Version"]],
    "Project-API-ID" = metadata[["Project-API-ID"]],
    "Project-API-Version" = metadata[["Project-API-Version"]],
    "State-Contract-ID" = metadata[["State-Contract-ID"]],
    "State-Contract-Version" = metadata[["State-Contract-Version"]],
    "Logical-History-Format-Version" =
      metadata[["Logical-History-Format-Version"]],
    "Target-ID" = metadata[["Target-ID"]],
    "Target-Version" = metadata[["Target-Version"]],
    "History-Scope-Contract-ID" = metadata[["History-Scope-Contract-ID"]],
    "History-Scope-Contract-Version" =
      metadata[["History-Scope-Contract-Version"]],
    "History-Disposition-Contract-ID" =
      metadata[["History-Disposition-Contract-ID"]],
    "History-Disposition-Contract-Version" =
      metadata[["History-Disposition-Contract-Version"]],
    "History-Action-Contract-ID" = metadata[["History-Action-Contract-ID"]],
    "History-Action-Contract-Version" =
      metadata[["History-Action-Contract-Version"]],
    "History-Port-Contract-ID" = metadata[["History-Port-Contract-ID"]],
    "History-Port-Contract-Version" = metadata[["History-Port-Contract-Version"]],
    "Adapter-ID" = metadata[["Adapter-ID"]],
    "Adapter-Version" = metadata[["Adapter-Version"]],
    "Physical-Schema-Version" = metadata[["Physical-Schema-Version"]],
    "Payload-Encoding-Version" = metadata[["Payload-Encoding-Version"]],
    "High-Water-Commit-ID" = evidence$high_water_commit_id,
    "Scope-Count" = as.character(evidence$scope_count),
    "Disposition-Count" = as.character(evidence$disposition_count),
    "Action-Count" = as.character(evidence$action_count),
    "Payload-File" = contract[["Payload-File"]],
    "Payload-Size" = evidence$payload_size,
    "Artifact-Inventory" = contract[["Artifact-Inventory"]]
  )
  valid <- is.character(manifest) &&
    identical(names(manifest), rrp_backup_manifest_fields(contract)) &&
    all(vapply(names(fixed), function(field) {
      identical(manifest[[field]], fixed[[field]])
    }, logical(1L))) &&
    grepl(contract[["Backup-ID-Pattern"]], manifest[["Backup-ID"]]) &&
    grepl(contract[["High-Water-Commit-ID-Pattern"]],
      manifest[["High-Water-Commit-ID"]]) &&
    identical(manifest[["Source-State-ID"]], metadata[["State-ID"]]) &&
    identical(manifest[["Project-ID"]], metadata[["Project-ID"]]) &&
    identical(manifest[["Project-ID"]], context$manifest[["Project-ID"]]) &&
    !is.na(rrp_state_timestamp_number(manifest[["Created-At"]]))
  if (!valid) rrp_state_abort(
    "backup_incompatible", "Project state backup is incompatible."
  )
  manifest
}

rrp_backup_inventory <- function(root, contract) {
  root_link <- Sys.readlink(root)
  if (!dir.exists(root) || (!is.na(root_link) && nzchar(root_link))) {
    rrp_state_abort("backup_invalid", "Project state backup is invalid.")
  }
  files <- sort(list.files(
    root, recursive = TRUE, all.files = TRUE, no.. = TRUE,
    full.names = FALSE, include.dirs = FALSE
  ), method = "radix")
  expected <- sort(
    strsplit(contract[["Artifact-Inventory"]], ",", fixed = TRUE)[[1L]],
    method = "radix"
  )
  directories <- sort(list.dirs(root, recursive = TRUE, full.names = FALSE),
    method = "radix")
  directories <- directories[nzchar(directories)]
  if (!identical(files, expected) || length(directories)) {
    rrp_state_abort("backup_invalid", "Project state backup is invalid.")
  }
  for (relative in expected) {
    path <- file.path(root, relative)
    link <- Sys.readlink(path)
    info <- file.info(path, extra_cols = FALSE)
    if ((!is.na(link) && nzchar(link)) || nrow(info) != 1L ||
        is.na(info$isdir[[1L]]) || isTRUE(info$isdir[[1L]])) {
      rrp_state_abort("backup_invalid", "Project state backup is invalid.")
    }
  }
  invisible(expected)
}

rrp_backup_inspect_root <- function(root, context, contracts, backup_contract) {
  rrp_backup_inventory(root, backup_contract)
  database <- file.path(root, backup_contract[["Payload-File"]])
  metadata <- tryCatch(
    {
      value <- rrp_duckdb_read_metadata(database)
      value <- rrp_state_validate_metadata(value, context, contracts)
      rrp_duckdb_validate_file(database, value, contracts)
      value
    },
    rrp_state_error = function(condition) {
      if (identical(condition$code, "state_incompatible")) rrp_state_abort(
        "backup_incompatible", "Project state backup is incompatible."
      )
      rrp_state_abort("backup_invalid", "Project state backup is invalid.")
    }
  )
  manifest <- rrp_backup_read_manifest(file.path(
    root, backup_contract[["Manifest-File"]]
  ))
  evidence <- rrp_duckdb_high_water_file(database, metadata, contracts)
  evidence$payload_size <- as.character(file.info(
    database, extra_cols = FALSE
  )$size[[1L]])
  manifest <- rrp_backup_validate_manifest(
    manifest, metadata, evidence, context, backup_contract
  )
  list(manifest = manifest, metadata = metadata, database = database)
}

rrp_backup_destination <- function(path) {
  valid <- is.character(path) && length(path) == 1L && !is.na(path) &&
    nzchar(path) && !grepl("[[:cntrl:]]", path) &&
    !basename(path) %in% c(".", "..")
  if (!valid) rrp_state_abort(
    "backup_destination_invalid", "Backup destination is invalid."
  )
  expanded <- path.expand(path)
  if (rrp_state_path_exists(expanded)) rrp_state_abort(
    "backup_destination_exists", "Backup destination already exists."
  )
  parent <- tryCatch(
    normalizePath(dirname(expanded), winslash = "/", mustWork = TRUE),
    error = function(condition) NA_character_
  )
  if (is.na(parent) || !dir.exists(parent) || nzchar(Sys.readlink(parent))) {
    rrp_state_abort("backup_destination_invalid", "Backup destination is invalid.")
  }
  file.path(parent, basename(expanded))
}

rrp_backup_staging_directory <- function(parent) {
  for (attempt in seq_len(16L)) {
    path <- tempfile(".rrp-backup-staging-", tmpdir = parent)
    if (!rrp_state_path_exists(path) && dir.create(path, showWarnings = FALSE) &&
        dir.exists(path) && !nzchar(Sys.readlink(path))) return(path)
  }
  rrp_state_abort("backup_failed", "Project state backup failed.")
}

rrp_backup_value <- function(manifest, status) list(
  backup_status = status,
  backup_id = unname(manifest[["Backup-ID"]]),
  source_state_id = unname(manifest[["Source-State-ID"]]),
  project_id = unname(manifest[["Project-ID"]]),
  backup_contract_id = unname(manifest[["Backup-Contract-ID"]]),
  backup_contract_version = unname(manifest[["Backup-Contract-Version"]])
)

rrp_state_backup <- function(
  software_catalog, project_root, backup_path, failure_stage = NULL
) {
  allowed <- c("after_checkpoint", "after_manifest", "before_promotion",
    "after_promotion")
  if (!is.null(failure_stage) && !failure_stage %in% allowed) {
    stop("Invalid internal backup interruption stage.", call. = FALSE)
  }
  inject <- function(stage) if (identical(failure_stage, stage)) {
    rrp_state_abort("injected_interruption", "Injected backup interruption.")
  }
  context <- rrp_load_project(software_catalog, project_root)
  contracts <- rrp_state_contracts(software_catalog)
  backup_contract <- rrp_state_backup_contract(software_catalog)
  if (!rrp_state_path_exists(context$state_path)) rrp_state_abort(
    "state_uninitialized", "Project state has not been initialized."
  )
  metadata <- rrp_state_inspect_root(context$state_path, context, contracts)
  destination <- rrp_backup_destination(backup_path)
  state_root <- normalizePath(context$state_path, winslash = "/", mustWork = TRUE)
  if (startsWith(destination, paste0(state_root, "/"))) rrp_state_abort(
    "backup_destination_invalid", "Backup destination is invalid."
  )
  staging <- rrp_backup_staging_directory(dirname(destination))
  staging_owned <- TRUE
  final_owned <- FALSE
  completed <- FALSE
  on.exit({
    if (!completed && final_owned && rrp_state_path_exists(destination)) {
      unlink(destination, recursive = TRUE, force = TRUE)
    }
    if (staging_owned && rrp_state_path_exists(staging)) {
      unlink(staging, recursive = TRUE, force = TRUE)
    }
  }, add = TRUE)
  evidence <- rrp_duckdb_checkpoint_copy(
    file.path(context$state_path, "history.duckdb"),
    file.path(staging, backup_contract[["Payload-File"]]), metadata, contracts
  )
  inject("after_checkpoint")
  manifest <- rrp_backup_new_manifest(metadata, evidence, backup_contract)
  tryCatch(
    writeLines(
      paste0(names(manifest), ": ", unname(manifest)),
      file.path(staging, backup_contract[["Manifest-File"]]), useBytes = TRUE
    ),
    error = function(condition) rrp_state_abort(
      "backup_failed", "Project state backup failed."
    )
  )
  inject("after_manifest")
  rrp_backup_inspect_root(staging, context, contracts, backup_contract)
  inject("before_promotion")
  if (rrp_state_path_exists(destination) || !file.rename(staging, destination)) {
    rrp_state_abort("backup_failed", "Project state backup failed.")
  }
  staging_owned <- FALSE
  final_owned <- TRUE
  inject("after_promotion")
  inspected <- rrp_backup_inspect_root(
    destination, context, contracts, backup_contract
  )
  completed <- TRUE
  rrp_new_operation_result(
    "rrp.backup-project-state", "success",
    rrp_backup_value(inspected$manifest, "created"), list()
  )
}

rrp_state_restore <- function(
  software_catalog, project_root, backup_path, failure_stage = NULL
) {
  allowed <- c("after_copy", "before_promotion", "after_promotion")
  if (!is.null(failure_stage) && !failure_stage %in% allowed) {
    stop("Invalid internal restore interruption stage.", call. = FALSE)
  }
  inject <- function(stage) if (identical(failure_stage, stage)) {
    rrp_state_abort("injected_interruption", "Injected restore interruption.")
  }
  context <- rrp_load_project(software_catalog, project_root)
  contracts <- rrp_state_contracts(software_catalog)
  backup_contract <- rrp_state_backup_contract(software_catalog)
  if (rrp_state_path_exists(context$state_path)) rrp_state_abort(
    "restore_destination_exists", "Project state already exists."
  )
  valid_backup_path <- is.character(backup_path) && length(backup_path) == 1L &&
    !is.na(backup_path) && nzchar(backup_path) &&
    !grepl("[[:cntrl:]]", backup_path)
  expanded_backup <- if (valid_backup_path) path.expand(backup_path) else NA_character_
  linked_backup <- if (valid_backup_path) Sys.readlink(expanded_backup) else NA_character_
  backup_root <- if (valid_backup_path &&
      (is.na(linked_backup) || !nzchar(linked_backup))) tryCatch(
    normalizePath(expanded_backup, winslash = "/", mustWork = TRUE),
    error = function(condition) NA_character_
  ) else NA_character_
  if (is.na(backup_root)) rrp_state_abort(
    "backup_invalid", "Project state backup is invalid."
  )
  inspected <- rrp_backup_inspect_root(
    backup_root, context, contracts, backup_contract
  )
  staging <- rrp_state_staging_directory(context)
  staging_owned <- TRUE
  final_owned <- FALSE
  created_parents <- character()
  completed <- FALSE
  on.exit({
    if (!completed && final_owned && rrp_state_path_exists(context$state_path)) {
      unlink(context$state_path, recursive = TRUE, force = TRUE)
    }
    if (staging_owned && rrp_state_path_exists(staging)) {
      unlink(staging, recursive = TRUE, force = TRUE)
    }
    if (!completed && length(created_parents)) {
      for (path in rev(created_parents)) {
        if (dir.exists(path) && !length(list.files(
          path, all.files = TRUE, no.. = TRUE
        ))) unlink(path, recursive = FALSE, force = TRUE)
      }
    }
  }, add = TRUE)
  for (file in c("state.dcf", "history.duckdb")) {
    if (identical(file, "state.dcf")) {
      tryCatch(
        writeLines(
          paste0(names(inspected$metadata), ": ", unname(inspected$metadata)),
          file.path(staging, file), useBytes = TRUE
        ),
        error = function(condition) rrp_state_abort(
          "restore_failed", "Project state restore failed."
        )
      )
    } else if (!isTRUE(file.copy(
      inspected$database, file.path(staging, file), overwrite = FALSE,
      copy.mode = FALSE, copy.date = FALSE
    ))) rrp_state_abort("restore_failed", "Project state restore failed.")
  }
  inject("after_copy")
  rrp_state_inspect_root(staging, context, contracts)
  created_parents <- rrp_state_create_parent(context)
  inject("before_promotion")
  if (rrp_state_path_exists(context$state_path) ||
      !file.rename(staging, context$state_path)) {
    rrp_state_abort("restore_failed", "Project state restore failed.")
  }
  staging_owned <- FALSE
  final_owned <- TRUE
  inject("after_promotion")
  metadata <- rrp_state_inspect_root(context$state_path, context, contracts)
  completed <- TRUE
  value <- rrp_state_value(metadata, "compatible")
  value$restored <- TRUE
  value$backup_id <- unname(inspected$manifest[["Backup-ID"]])
  rrp_new_operation_result("rrp.restore-project-state", "success", value, list())
}

#' Back up explicit project-owned RRP state
#'
#' @param software_catalog A validated RRP software resource catalog.
#' @param project_root One explicit independent project directory.
#' @param backup_path One explicit absent backup-artifact destination.
#' @return A common operation result containing bounded backup evidence.
#' @export
rrp_backup_project_state <- function(software_catalog, project_root, backup_path) {
  tryCatch(
    rrp_state_backup(software_catalog, project_root, backup_path),
    rrp_resource_error = function(condition) rrp_state_operation_failure(
      condition, "rrp.backup-project-state", "Project state backup failed."
    ),
    rrp_project_error = function(condition) rrp_state_operation_failure(
      condition, "rrp.backup-project-state", "Project state backup failed."
    ),
    rrp_state_error = function(condition) rrp_state_operation_failure(
      condition, "rrp.backup-project-state", "Project state backup failed."
    )
  )
}

#' Restore explicit project-owned RRP state
#'
#' @inheritParams rrp_backup_project_state
#' @return A common operation result containing compatible restored-state evidence.
#' @export
rrp_restore_project_state <- function(software_catalog, project_root, backup_path) {
  tryCatch(
    rrp_state_restore(software_catalog, project_root, backup_path),
    rrp_resource_error = function(condition) rrp_state_operation_failure(
      condition, "rrp.restore-project-state", "Project state restore failed."
    ),
    rrp_project_error = function(condition) rrp_state_operation_failure(
      condition, "rrp.restore-project-state", "Project state restore failed."
    ),
    rrp_state_error = function(condition) rrp_state_operation_failure(
      condition, "rrp.restore-project-state", "Project state restore failed."
    )
  )
}
