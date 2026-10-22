rrp_app_lifecycle_abort <- function(
  code, message = "Standalone application managed-content operation failed."
) {
  stop(structure(
    list(message = message, call = NULL, code = code),
    class = c("rrp_application_lifecycle_error", "error", "condition")
  ))
}

rrp_app_link_exists <- function(path) {
  target <- Sys.readlink(path)
  !is.na(target) && nzchar(target)
}

rrp_app_managed_portable <- function(catalog) {
  environment <- new.env(parent = baseenv())
  ids <- c(
    "rrp.application.portable-core", "rrp.application.portable-products",
    "rrp.application.standalone-managed-loader"
  )
  for (id in ids) {
    path <- tryCatch(
      rrp_resource_path(catalog, id),
      error = function(condition) rrp_app_lifecycle_abort(
        "application_software_identity_invalid"
      )
    )
    tryCatch(
      sys.source(path, envir = environment, chdir = FALSE, keep.source = TRUE),
      error = function(condition) rrp_app_lifecycle_abort(
        "application_software_identity_invalid"
      )
    )
  }
  required <- c(
    "rrp_application_safe_relative_path", "rrp_application_regular_file",
    "rrp_application_read_dcf", "rrp_application_sha256",
    "rrp_application_load_product_set", "rrp_standalone_load_managed_set"
  )
  if (!all(vapply(required, exists, logical(1L), envir = environment,
      inherits = FALSE))) {
    rrp_app_lifecycle_abort("application_software_identity_invalid")
  }
  environment
}

rrp_app_existing_root <- function(path) {
  if (!rrp_application_scalar(path, 4096L) || !dir.exists(path) ||
      rrp_app_link_exists(path)) {
    rrp_app_lifecycle_abort("application_path_invalid")
  }
  root <- tryCatch(
    normalizePath(path, winslash = "/", mustWork = TRUE),
    error = function(condition) NULL
  )
  if (is.null(root) || !dir.exists(root)) {
    rrp_app_lifecycle_abort("application_path_invalid")
  }
  root
}

rrp_app_managed_regular_directory <- function(root, relative) {
  if (!rrp_project_safe_relative_path(relative)) return(FALSE)
  current <- root
  for (segment in strsplit(relative, "/", fixed = TRUE)[[1L]]) {
    current <- file.path(current, segment)
    if (rrp_app_link_exists(current)) return(FALSE)
  }
  state <- file.info(current, extra_cols = FALSE)
  dir.exists(current) && nrow(state) == 1L && !is.na(state$isdir[[1L]]) &&
    isTRUE(state$isdir[[1L]])
}

rrp_app_validate_presentation_managed <- function(root, portable) {
  relative <- "rrp-data/presentation.dcf"
  fields <- portable$rrp_application_presentation_fields()
  if (!portable$rrp_application_regular_file(root, relative)) {
    rrp_app_lifecycle_abort("application_managed_content_invalid")
  }
  declaration <- tryCatch(
    portable$rrp_application_read_dcf(file.path(root, relative), fields, 1L)[[1L]],
    error = function(condition) rrp_app_lifecycle_abort(
      "application_managed_content_invalid"
    )
  )
  fixed <- c(
    "Record-Type" = "rrp-application-presentation",
    "Presentation-Contract-ID" = "rrp.application-presentation",
    "Presentation-Contract-Version" = "0.1.0",
    "Brand-Contract-ID" = "rrp.project-brand",
    "Brand-Contract-Version" = "0.1.0"
  )
  valid <- all(vapply(names(fixed), function(field) identical(
    declaration[[field]], unname(fixed[[field]])
  ), logical(1L))) &&
    declaration[["Source"]] %in% c("rrp-defaults", "project-brand") &&
    rrp_application_scalar(declaration[["Display-Name"]]) &&
    grepl("^#[0-9A-F]{6}$", declaration[["Primary-Color"]])
  logo <- declaration[["Logo-File"]]
  if (identical(logo, "none")) {
    valid <- valid && identical(declaration[["Logo-Media-Type"]], "none") &&
      identical(declaration[["Logo-Alt"]], "none")
  } else {
    valid <- valid && logo %in% c(
      "rrp-data/brand-logo.png", "rrp-data/brand-logo.jpg"
    ) && declaration[["Logo-Media-Type"]] %in% c("image/png", "image/jpeg") &&
      rrp_application_scalar(declaration[["Logo-Alt"]], 200L) &&
      portable$rrp_application_regular_file(root, logo)
    if (valid) {
      path <- file.path(root, logo)
      bytes <- readBin(path, "raw", n = file.info(path, extra_cols = FALSE)$size[[1L]])
      png <- length(bytes) >= 8L && identical(bytes[1:8], as.raw(c(
        0x89, 0x50, 0x4e, 0x47, 0x0d, 0x0a, 0x1a, 0x0a
      )))
      jpeg <- length(bytes) >= 3L && identical(
        bytes[1:3], as.raw(c(0xff, 0xd8, 0xff))
      )
      valid <- xor(png, jpeg) && identical(
        declaration[["Logo-Media-Type"]], if (png) "image/png" else "image/jpeg"
      )
    }
  }
  if (!valid) rrp_app_lifecycle_abort("application_managed_content_invalid")
  invisible(declaration)
}

rrp_app_managed_inventory <- function(root, portable) {
  data_root <- file.path(root, "rrp-data")
  sets_root <- file.path(data_root, "sets")
  if (!rrp_app_managed_regular_directory(root, "rrp-data") ||
      !rrp_app_managed_regular_directory(root, "rrp-data/sets")) {
    rrp_app_lifecycle_abort("application_managed_content_invalid")
  }
  entries <- list.files(data_root, all.files = TRUE, no.. = TRUE)
  fixed <- c("current.dcf", "presentation.dcf", "sets")
  logos <- c("brand-logo.png", "brand-logo.jpg")
  pointer_staging <- grepl("^[.]rrp-current-staging-[A-Za-z0-9._-]+[.]dcf$", entries)
  if (any(!entries %in% c(fixed, logos) & !pointer_staging) ||
      all(logos %in% entries)) {
    rrp_app_lifecycle_abort("application_managed_content_invalid")
  }
  for (entry in entries) {
    relative <- paste0("rrp-data/", entry)
    directory <- identical(entry, "sets")
    valid <- if (directory) {
      rrp_app_managed_regular_directory(root, relative)
    } else {
      portable$rrp_application_regular_file(root, relative)
    }
    if (!valid) rrp_app_lifecycle_abort("application_managed_content_invalid")
  }
  set_entries <- list.files(sets_root, all.files = TRUE, no.. = TRUE)
  complete <- grepl("^set-[0-9a-f]{24}$", set_entries)
  staging <- grepl("^[.]rrp-set-staging-[A-Za-z0-9._-]+$", set_entries)
  if (any(!complete & !staging)) {
    rrp_app_lifecycle_abort("application_managed_content_invalid")
  }
  invalid_inactive <- 0L
  for (index in seq_along(set_entries)) {
    entry <- set_entries[[index]]
    relative <- paste0("rrp-data/sets/", entry)
    if (!rrp_app_managed_regular_directory(root, relative)) {
      rrp_app_lifecycle_abort("application_managed_content_invalid")
    }
    children <- list.files(file.path(sets_root, entry), all.files = TRUE, no.. = TRUE)
    if (any(!vapply(children, function(child) {
      portable$rrp_application_regular_file(
        root, paste0(relative, "/", child)
      )
    }, logical(1L)))) {
      rrp_app_lifecycle_abort("application_managed_content_invalid")
    }
    if (complete[[index]]) {
      valid <- tryCatch({
        portable$rrp_application_load_product_set(file.path(sets_root, entry))
        TRUE
      }, error = function(condition) FALSE)
      if (!valid) invalid_inactive <- invalid_inactive + 1L
    } else if (any(!children %in% c(
      "current-remaining-risk.csv", "remaining-risk-trajectory.csv",
      "operational-scope-summary.csv", "products.dcf", "inventory.dcf"
    ))) {
      rrp_app_lifecycle_abort("application_managed_content_invalid")
    }
  }
  list(
    set_entries = set_entries, complete = set_entries[complete],
    staging = set_entries[staging], pointer_staging = entries[pointer_staging],
    invalid_complete_count = as.integer(invalid_inactive)
  )
}

rrp_app_read_initial_evidence <- function(root, portable) {
  provenance_path <- file.path(root, "rrp-initialization.dcf")
  inventory_path <- file.path(root, "rrp-source-inventory.dcf")
  if (!file.exists(provenance_path) && !rrp_app_link_exists(provenance_path)) {
    return(list(initial_provenance_status = "missing",
      source_baseline_status = "unavailable"))
  }
  fields <- c(
    "Record-Type", "Contract-ID", "Contract-Version", "Software-Product-ID",
    "Software-Version", "Distribution-ID", "Package-Version",
    "Resource-Catalog-ID", "Resource-Catalog-Version",
    "Portable-Application-Contract-ID", "Portable-Application-Contract-Version",
    "Application-Baseline-ID", "Dependency-Identity", "Initial-Product-Set-ID",
    "Initial-Materialization-ID", "Source-Operation-Run-ID",
    "Source-Analytical-Time", "Source-History-Cutoff",
    "Source-History-Fingerprint", "Presentation-SHA256",
    "Source-Inventory-SHA256", "Managed-Inventory-SHA256"
  )
  provenance <- tryCatch({
    if (!portable$rrp_application_regular_file(root, "rrp-initialization.dcf")) {
      stop("invalid")
    }
    portable$rrp_application_read_dcf(provenance_path, fields, 1L)[[1L]]
  }, error = function(condition) NULL)
  fixed <- c(
    "Record-Type" = "rrp-application-initialization",
    "Contract-ID" = "rrp.application-initialization",
    "Contract-Version" = "0.1.0",
    "Portable-Application-Contract-ID" = "rrp.application.portable",
    "Portable-Application-Contract-Version" = "0.1.0"
  )
  hash_fields <- c(
    "Application-Baseline-ID", "Presentation-SHA256",
    "Source-Inventory-SHA256", "Managed-Inventory-SHA256"
  )
  baseline_values <- if (is.null(provenance)) character() else c(
    "rrp.application.portable@0.1.0", provenance[["Dependency-Identity"]],
    provenance[["Initial-Product-Set-ID"]],
    provenance[["Initial-Materialization-ID"]],
    provenance[["Source-Operation-Run-ID"]],
    provenance[["Source-Analytical-Time"]],
    provenance[["Source-History-Cutoff"]],
    provenance[["Source-History-Fingerprint"]],
    provenance[["Presentation-SHA256"]],
    provenance[["Source-Inventory-SHA256"]],
    provenance[["Managed-Inventory-SHA256"]]
  )
  baseline_valid <- tryCatch({
    path <- tempfile("rrp-initial-baseline-")
    on.exit(unlink(path, force = TRUE), add = TRUE)
    writeLines(paste0(nchar(baseline_values, type = "bytes"), ":",
      baseline_values), path, useBytes = TRUE)
    identical(rrp_app_sha256(path), provenance[["Application-Baseline-ID"]])
  }, error = function(condition) FALSE)
  if (is.null(provenance) || !all(vapply(names(fixed), function(field) {
      identical(provenance[[field]], unname(fixed[[field]]))
    }, logical(1L))) || !all(vapply(provenance, rrp_application_scalar,
      logical(1L))) || !all(vapply(provenance[hash_fields], function(value) {
        grepl("^[0-9a-f]{64}$", value)
      }, logical(1L))) || !baseline_valid) {
    return(list(initial_provenance_status = "invalid",
      source_baseline_status = "unavailable"))
  }
  inventory <- tryCatch({
    if (!portable$rrp_application_regular_file(root, "rrp-source-inventory.dcf") ||
        !identical(portable$rrp_application_sha256(inventory_path),
          provenance[["Source-Inventory-SHA256"]])) stop("invalid")
    records <- suppressWarnings(read.dcf(inventory_path, all = TRUE))
    expected_fields <- c("Record-Type", "Path", "Byte-Size", "SHA256")
    expected_paths <- sort(c(
      "app.R", paste0("R/", c(
        "application-core.R", "product-loader.R", "application-ui.R",
        "application-server.R", "managed-loader.R"
      )), "www/rrp.css", "README.md", "renv.lock", "LICENSE", "NOTICE"
    ), method = "radix")
    if (!nrow(records) || !identical(colnames(records), expected_fields) ||
        anyNA(records) || anyDuplicated(records[, "Path"]) ||
        any(records[, "Record-Type"] != "source-file") ||
        !identical(as.character(records[, "Path"]), expected_paths) ||
        any(!vapply(records[, "Path"], portable$rrp_application_safe_relative_path,
          logical(1L))) || any(!grepl("^(0|[1-9][0-9]*)$", records[, "Byte-Size"])) ||
        any(!grepl("^[0-9a-f]{64}$", records[, "SHA256"]))) stop("invalid")
    records
  }, error = function(condition) NULL)
  if (is.null(inventory)) return(list(
    initial_provenance_status = "available", source_baseline_status = "unavailable"
  ))
  matches <- vapply(seq_len(nrow(inventory)), function(index) {
    relative <- inventory[index, "Path"]
    if (!portable$rrp_application_regular_file(root, relative)) return(FALSE)
    path <- file.path(root, relative)
    identical(as.character(file.info(path, extra_cols = FALSE)$size[[1L]]),
      inventory[index, "Byte-Size"]) && identical(
        portable$rrp_application_sha256(path), inventory[index, "SHA256"]
      )
  }, logical(1L))
  list(
    initial_provenance_status = "available",
    source_baseline_status = if (all(matches)) "matches" else "drifted"
  )
}

rrp_app_open_managed <- function(catalog, app_path, include_initial = TRUE) {
  root <- rrp_app_existing_root(app_path)
  portable <- rrp_app_managed_portable(catalog)
  inventory <- rrp_app_managed_inventory(root, portable)
  active <- tryCatch(
    portable$rrp_standalone_load_managed_set(root),
    error = function(condition) rrp_app_lifecycle_abort(
      "application_managed_content_invalid"
    )
  )
  rrp_app_validate_presentation_managed(root, portable)
  active_name <- basename(active$set_root)
  inactive <- setdiff(inventory$complete, active_name)
  invalid_inactive <- 0L
  for (entry in inactive) {
    valid <- tryCatch({
      portable$rrp_application_load_product_set(file.path(root, "rrp-data", "sets", entry))
      TRUE
    }, error = function(condition) FALSE)
    if (!valid) invalid_inactive <- invalid_inactive + 1L
  }
  initial <- if (include_initial) rrp_app_read_initial_evidence(root, portable) else NULL
  list(
    root = root, portable = portable, pointer = active$pointer,
    snapshot = active$set, set_root = active$set_root,
    complete_sets = inventory$complete,
    inactive_set_count = as.integer(length(inactive)),
    invalid_inactive_set_count = as.integer(invalid_inactive),
    stale_work_count = as.integer(length(inventory$staging) +
      length(inventory$pointer_staging)), initial = initial
  )
}

rrp_app_cleanup_obsolete_sets <- function(opened, retain) {
  removable <- setdiff(opened$complete_sets, retain)
  for (entry in removable) {
    relative <- paste0("rrp-data/sets/", entry)
    path <- file.path(opened$root, relative)
    if (!grepl("^set-[0-9a-f]{24}$", entry) ||
        !rrp_app_managed_regular_directory(opened$root, relative)) next
    valid <- tryCatch({
      opened$portable$rrp_application_load_product_set(path)
      TRUE
    }, error = function(condition) FALSE)
    if (!valid) next
    unlink(path, recursive = TRUE, force = TRUE)
    if (file.exists(path) || dir.exists(path) || rrp_app_link_exists(path)) {
      rrp_app_lifecycle_abort("application_refresh_committed")
    }
  }
  invisible(length(removable))
}

rrp_app_validation_value <- function(opened) list(
  application_id = "rrp.application.supplied",
  application_version = "0.1.0",
  application_path = opened$root,
  managed_content_status = "valid",
  product_set_id = opened$snapshot$product_set_id,
  materialization_id = opened$pointer[["Materialization-ID"]],
  source_operation_run_id = opened$snapshot$source_operation_run_id,
  source_history_cutoff = opened$snapshot$source_history_cutoff,
  managed_inventory_status = "valid",
  initial_provenance_status = opened$initial$initial_provenance_status,
  source_baseline_status = opened$initial$source_baseline_status,
  inactive_set_count = opened$inactive_set_count,
  invalid_inactive_set_count = opened$invalid_inactive_set_count,
  stale_work_count = opened$stale_work_count
)

rrp_app_lifecycle_failure <- function(condition, operation_id) {
  code <- if (inherits(condition, "rrp_application_lifecycle_error")) {
    condition$code
  } else if (inherits(condition, "rrp_application_initialization_error")) {
    condition$code
  } else {
    if (identical(operation_id, "rrp.refresh-app")) {
      "application_refresh_failed"
    } else "application_validation_failed"
  }
  message <- if (identical(operation_id, "rrp.refresh-app")) {
    "Standalone application refresh failed."
  } else "Standalone application validation failed."
  rrp_new_operation_result(operation_id, "failure", NULL,
    list(rrp_new_diagnostic(code, "error", message)))
}

# Private failure injection and promotion hooks exist only for package-native
# transaction tests. The exported operation does not expose either argument.
rrp_app_refresh <- function(software_catalog, project_root, scope_id,
    history_cutoff, app_path = NULL, failure_stage = NULL,
    promotion_hook = NULL) tryCatch({
  stages <- c(
    "before_staging", "during_staged_construction",
    "during_staged_validation", "before_pointer_replacement",
    "after_pointer_replacement", "during_cleanup"
  )
  if (!is.null(failure_stage) && !failure_stage %in% stages) {
    rrp_app_lifecycle_abort("application_failure_stage_invalid")
  }
  inject <- function(stage, committed = FALSE) if (identical(failure_stage, stage)) {
    rrp_app_lifecycle_abort(
      if (committed) "application_refresh_committed" else "application_injected_failure"
    )
  }
  rrp_resource_validate_catalog_object(software_catalog)
  if (!rrp_operation_succeeded(rrp_validate_software_resources(
      software_catalog$software_root))) {
    rrp_app_lifecycle_abort("application_software_identity_invalid")
  }
  resolved <- rrp_app_structural_access(
    software_catalog, project_root, scope_id, history_cutoff
  )
  target <- if (is.null(app_path)) {
    file.path(resolved$context$project_root, "app")
  } else app_path
  opened <- rrp_app_open_managed(software_catalog, target, FALSE)
  pointer_path <- file.path(opened$root, "rrp-data", "current.dcf")
  pointer_raw <- readBin(pointer_path, "raw", n = file.info(pointer_path)$size[[1L]])
  previous_id <- opened$snapshot$product_set_id
  inject("before_staging")

  sets_root <- file.path(opened$root, "rrp-data", "sets")
  staging <- tempfile(".rrp-set-staging-", tmpdir = sets_root)
  if (!dir.create(staging, showWarnings = FALSE)) {
    rrp_app_lifecycle_abort("application_refresh_failed")
  }
  stage_owned <- TRUE
  on.exit(if (stage_owned && dir.exists(staging)) {
    unlink(staging, recursive = TRUE, force = TRUE)
  }, add = TRUE)
  inject("during_staged_construction")
  snapshot <- rrp_app_write_frozen_set(resolved$access, staging)
  inject("during_staged_validation")
  validated <- tryCatch(
    opened$portable$rrp_application_load_product_set(staging),
    error = function(condition) rrp_app_lifecycle_abort(
      "application_product_incompatible"
    )
  )
  if (!identical(validated$product_set_id, resolved$access$product_set_id)) {
    rrp_app_lifecycle_abort("application_product_incompatible")
  }
  inventory_sha <- rrp_app_sha256(file.path(staging, "inventory.dcf"))
  set_id <- paste0("set-", substr(inventory_sha, 1L, 24L))
  final <- file.path(sets_root, set_id)
  if (file.exists(final) || dir.exists(final) || rrp_app_link_exists(final)) {
    if (!rrp_app_managed_regular_directory(opened$root,
        paste0("rrp-data/sets/", set_id))) {
      rrp_app_lifecycle_abort("application_managed_content_invalid")
    }
    existing <- tryCatch(
      opened$portable$rrp_application_load_product_set(final),
      error = function(condition) rrp_app_lifecycle_abort(
        "application_managed_content_invalid"
      )
    )
    expected_files <- c("inventory.dcf", opened$portable$rrp_application_managed_paths())
    identical_files <- all(vapply(expected_files, function(name) {
      identical(rrp_app_sha256(file.path(staging, name)),
        rrp_app_sha256(file.path(final, name)))
    }, logical(1L)))
    if (!identical(existing$product_set_id, snapshot$product_set_id) ||
        !identical_files) {
      rrp_app_lifecycle_abort("application_managed_content_invalid")
    }
    unlink(staging, recursive = TRUE, force = TRUE)
    stage_owned <- FALSE
  } else {
    if (!file.rename(staging, final)) {
      rrp_app_lifecycle_abort("application_refresh_failed")
    }
    stage_owned <- FALSE
  }

  pointer <- c(
    "Record-Type" = "rrp-application-current",
    "Managed-Content-Contract-ID" = "rrp.application-managed-content",
    "Managed-Content-Contract-Version" = "0.1.0",
    "Set-Directory" = paste0("sets/", set_id),
    "Product-Set-ID" = resolved$access$product_set_id,
    "Materialization-ID" = resolved$access$materialization_id,
    "Source-Operation-Run-ID" = resolved$access$source_operation_run_id,
    "Source-History-Cutoff" = resolved$access$source_history_cutoff,
    "Source-History-Fingerprint" = resolved$access$source_history_fingerprint,
    "Managed-Inventory-SHA256" = inventory_sha
  )
  pointer_staging <- tempfile(
    ".rrp-current-staging-", tmpdir = file.path(opened$root, "rrp-data"),
    fileext = ".dcf"
  )
  on.exit(if (file.exists(pointer_staging)) unlink(pointer_staging, force = TRUE),
    add = TRUE)
  rrp_app_write_dcf(list(pointer), pointer_staging)
  staged_name <- basename(pointer_staging)
  tryCatch(
    opened$portable$rrp_standalone_load_managed_set(
      opened$root, pointer_file = staged_name
    ),
    error = function(condition) rrp_app_lifecycle_abort(
      "application_staged_pointer_invalid"
    )
  )
  inject("before_pointer_replacement")
  if (!is.null(promotion_hook)) {
    if (!is.function(promotion_hook)) {
      rrp_app_lifecycle_abort("application_refresh_failed")
    }
    promotion_hook(pointer_path)
  }
  current_raw <- if (rrp_product_regular_file(pointer_path)) {
    readBin(pointer_path, "raw", n = file.info(pointer_path)$size[[1L]])
  } else raw()
  if (!identical(current_raw, pointer_raw)) {
    rrp_app_lifecycle_abort("application_current_changed")
  }
  changed <- !identical(previous_id, snapshot$product_set_id)
  if (changed) {
    if (!file.rename(pointer_staging, pointer_path)) {
      rrp_app_lifecycle_abort("application_refresh_failed")
    }
  } else {
    unlink(pointer_staging, force = TRUE)
  }
  inject("after_pointer_replacement", committed = changed)
  final_opened <- tryCatch(
    rrp_app_open_managed(software_catalog, opened$root, FALSE),
    rrp_application_lifecycle_error = function(condition) {
      rrp_app_lifecycle_abort("application_postcommit_invalid")
    }
  )
  inject("during_cleanup", committed = changed)
  if (changed) rrp_app_cleanup_obsolete_sets(final_opened, c(
    basename(final_opened$set_root), basename(opened$set_root)
  ))
  final_opened <- tryCatch(
    rrp_app_open_managed(software_catalog, opened$root, FALSE),
    rrp_application_lifecycle_error = function(condition) {
      rrp_app_lifecycle_abort("application_postcommit_invalid")
    }
  )
  rrp_new_operation_result("rrp.refresh-app", "success", list(
    application_id = "rrp.application.supplied",
    application_version = "0.1.0",
    application_path = opened$root,
    previous_product_set_id = previous_id,
    product_set_id = final_opened$snapshot$product_set_id,
    materialization_id = final_opened$pointer[["Materialization-ID"]],
    source_operation_run_id = final_opened$snapshot$source_operation_run_id,
    source_history_cutoff = final_opened$snapshot$source_history_cutoff,
    changed = changed,
    managed_content_status = "valid",
    inactive_set_count = final_opened$inactive_set_count,
    stale_work_count = final_opened$stale_work_count
  ), list())
}, rrp_application_lifecycle_error = function(condition) {
  rrp_app_lifecycle_failure(condition, "rrp.refresh-app")
}, rrp_application_initialization_error = function(condition) {
  rrp_app_lifecycle_failure(condition, "rrp.refresh-app")
}, error = function(condition) {
  rrp_app_lifecycle_failure(condition, "rrp.refresh-app")
})

#' Refresh one standalone application's managed analytical products
#' @param software_catalog A validated explicit-root software resource catalog.
#' @param project_root One explicit initialized independent-project root.
#' @param scope_id Exact source operation-run identity.
#' @param history_cutoff Exact RFC 3339 UTC history cutoff.
#' @param app_path Optional existing application path; defaults to `app` in the project.
#' @return A common RRP operation result.
#' @export
rrp_refresh_app <- function(software_catalog, project_root, scope_id,
    history_cutoff, app_path = NULL) rrp_app_refresh(
  software_catalog, project_root, scope_id, history_cutoff, app_path
)

#' Validate a standalone application's managed content
#' @param software_catalog A validated explicit-root software resource catalog.
#' @param app_path One explicit existing standalone application path.
#' @return A common RRP operation result.
#' @export
rrp_validate_app <- function(software_catalog, app_path) tryCatch({
  rrp_resource_validate_catalog_object(software_catalog)
  opened <- rrp_app_open_managed(software_catalog, app_path, TRUE)
  rrp_new_operation_result(
    "rrp.validate-app", "success", rrp_app_validation_value(opened), list()
  )
}, rrp_application_lifecycle_error = function(condition) {
  rrp_app_lifecycle_failure(condition, "rrp.validate-app")
}, error = function(condition) {
  rrp_app_lifecycle_failure(condition, "rrp.validate-app")
})
