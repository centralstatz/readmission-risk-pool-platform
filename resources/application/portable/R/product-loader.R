# Portable loading for one frozen, already-governed application product set.
# The caller resolves the active managed set. This file performs no discovery,
# analytical execution, history access, or mutation.

rrp_application_safe_relative_path <- function(path) {
  if (!rrp_application_scalar(path, 240L) ||
      grepl("[\\\\]", path) || startsWith(path, "/") ||
      startsWith(path, "~") || startsWith(path, "//") ||
      grepl("^[A-Za-z]:", path) || endsWith(path, "/")) return(FALSE)
  segments <- strsplit(path, "/", fixed = TRUE)[[1L]]
  length(segments) > 0L && all(nzchar(segments)) &&
    !any(segments %in% c(".", ".."))
}

rrp_application_path_has_link <- function(root, relative) {
  current <- root
  for (segment in strsplit(relative, "/", fixed = TRUE)[[1L]]) {
    current <- file.path(current, segment)
    target <- Sys.readlink(current)
    if (!is.na(target) && nzchar(target)) return(TRUE)
  }
  FALSE
}

rrp_application_regular_file <- function(root, relative) {
  if (!rrp_application_safe_relative_path(relative) ||
      rrp_application_path_has_link(root, relative)) return(FALSE)
  path <- file.path(root, relative)
  state <- file.info(path, extra_cols = FALSE)
  file.exists(path) && nrow(state) == 1L && !is.na(state$isdir[[1L]]) &&
    !isTRUE(state$isdir[[1L]])
}

rrp_application_read_dcf <- function(path, fields = NULL, records = 1L) {
  raw <- tryCatch(
    suppressWarnings(read.dcf(path, all = TRUE)),
    error = function(condition) NULL
  )
  if (is.null(raw) || nrow(raw) != records || anyNA(raw) ||
      any(!nzchar(raw)) || anyDuplicated(colnames(raw)) ||
      !is.null(fields) && !identical(colnames(raw), fields)) {
    rrp_application_abort("application_product_integrity_failed")
  }
  lapply(seq_len(nrow(raw)), function(index) {
    value <- as.list(unname(raw[index, , drop = TRUE]))
    names(value) <- colnames(raw)
    value
  })
}

rrp_application_sha256 <- function(path) {
  utility <- Sys.which("sha256sum")
  arguments <- path
  if (!nzchar(utility)) {
    utility <- Sys.which("shasum")
    arguments <- c("-a", "256", path)
  }
  if (!nzchar(utility)) {
    rrp_application_abort("application_product_integrity_failed")
  }
  output <- suppressWarnings(system2(
    utility, shQuote(arguments), stdout = TRUE, stderr = TRUE
  ))
  status <- attr(output, "status")
  digest <- if (length(output)) sub("[[:space:]].*$", "", output[[1L]]) else ""
  if (!is.null(status) || !grepl("^[0-9a-f]{64}$", digest)) {
    rrp_application_abort("application_product_integrity_failed")
  }
  digest
}

rrp_application_managed_paths <- function() c(
  "current-remaining-risk.csv",
  "operational-scope-summary.csv",
  "products.dcf",
  "remaining-risk-trajectory.csv"
)

rrp_application_inventory_fields <- function() c(
  "Record-Type", "Path", "Role", "Byte-Size", "SHA256"
)

rrp_application_product_fields <- function() {
  set <- c(
    "Record-Type", "Portable-Application-Contract-ID",
    "Portable-Application-Contract-Version", "Product-Set-Contract-ID",
    "Product-Set-Contract-Version", "Product-Set-ID", "Materialization-ID",
    "Source-Operation-Run-ID", "Source-Analytical-Time",
    "Source-History-Cutoff", "Source-History-Fingerprint"
  )
  member <- c(
    "Product-Contract-ID", "Product-Contract-Version",
    "Product-Instance-ID", "Row-Count", "File"
  )
  prefixes <- c(
    "Current-Remaining-Risk", "Remaining-Risk-Trajectory",
    "Operational-Scope-Summary"
  )
  c(set, unlist(lapply(prefixes, function(prefix) {
    paste(prefix, member, sep = "-")
  }), use.names = FALSE))
}

rrp_application_csv_schemas <- function() {
  common <- c(
    "product_row_id", "episode_id", "target_id", "target_version",
    "analytical_time", "estimate_value", "estimate_record_id",
    "analytical_run_id", "source_operation_run_id", "state_id", "request_id",
    "provider_id", "provider_version", "implementation_id",
    "implementation_version", "model_id", "model_version",
    "target_interval_start", "target_interval_end",
    "target_interval_boundary"
  )
  list(
    current_remaining_risk = list(
      fields = common, integer = character(), double = "estimate_value",
      logical = character(), nullable = c("model_id", "model_version")
    ),
    remaining_risk_trajectory = list(
      fields = c(common, "analytical_kind", "related_analytical_run_id"),
      integer = character(), double = "estimate_value", logical = character(),
      nullable = c("model_id", "model_version", "related_analytical_run_id")
    ),
    operational_scope_summary = list(
      fields = c(
        "product_row_id", "operation_run_id", "scope_record_id", "state_id",
        "project_id", "project_version", "bundle_instance_id",
        "canonical_profile_id", "canonical_profile_version", "producer_id",
        "producer_version", "producer_implementation_id",
        "producer_implementation_version", "mapping_id", "mapping_version",
        "target_id", "target_version", "analytical_time", "scope_created_at",
        "expected_episode_count", "initial_disposition_count",
        "effective_disposition_count", "eligible_count",
        "accepted_estimate_count", "provider_incompatible_count",
        "provider_declared_failure_count", "detected_failure_count",
        "ineligible_count", "episode_before_discharge_count",
        "target_horizon_exhausted_count", "episode_already_readmitted_count",
        "episode_already_dead_count", "membership_fingerprint", "complete"
      ),
      integer = c(
        "expected_episode_count", "initial_disposition_count",
        "effective_disposition_count", "eligible_count",
        "accepted_estimate_count", "provider_incompatible_count",
        "provider_declared_failure_count", "detected_failure_count",
        "ineligible_count", "episode_before_discharge_count",
        "target_horizon_exhausted_count", "episode_already_readmitted_count",
        "episode_already_dead_count"
      ),
      double = character(), logical = "complete", nullable = character()
    )
  )
}

rrp_application_read_csv <- function(root, relative, schema) {
  if (!rrp_application_regular_file(root, relative)) {
    rrp_application_abort("application_product_integrity_failed")
  }
  raw <- tryCatch(utils::read.csv(
    file.path(root, relative), header = TRUE, colClasses = "character",
    na.strings = "", check.names = FALSE, stringsAsFactors = FALSE,
    strip.white = FALSE, fileEncoding = "UTF-8"
  ), error = function(condition) NULL)
  if (is.null(raw) || !identical(names(raw), schema$fields)) {
    rrp_application_abort("application_product_integrity_failed")
  }
  required <- setdiff(schema$fields, schema$nullable)
  if (any(vapply(raw[required], anyNA, logical(1L)))) {
    rrp_application_abort("application_product_integrity_failed")
  }
  data <- raw
  for (field in schema$integer) {
    value <- raw[[field]]
    if (anyNA(value) || any(!grepl("^(0|[1-9][0-9]*)$", value))) {
      rrp_application_abort("application_product_integrity_failed")
    }
    converted <- suppressWarnings(as.integer(value))
    if (anyNA(converted)) rrp_application_abort("application_product_integrity_failed")
    data[[field]] <- converted
  }
  for (field in schema$double) {
    converted <- suppressWarnings(as.double(raw[[field]]))
    if (anyNA(converted) || any(!is.finite(converted))) {
      rrp_application_abort("application_product_integrity_failed")
    }
    data[[field]] <- converted
  }
  for (field in schema$logical) {
    if (any(!raw[[field]] %in% c("TRUE", "FALSE"))) {
      rrp_application_abort("application_product_integrity_failed")
    }
    data[[field]] <- raw[[field]] == "TRUE"
  }
  data
}

rrp_application_validate_loaded_products <- function(products) {
  current <- products$current_remaining_risk$data
  trajectory <- products$remaining_risk_trajectory$data
  summary <- products$operational_scope_summary$data
  timestamp <- function(value) grepl(
    "^[0-9]{4}-[0-9]{2}-[0-9]{2}T[0-9]{2}:[0-9]{2}:[0-9]{2}Z$", value
  )
  valid <- nrow(summary) == 1L && isTRUE(summary$complete[[1L]]) &&
    all(current$estimate_value >= 0 & current$estimate_value <= 1) &&
    all(trajectory$estimate_value >= 0 & trajectory$estimate_value <= 1) &&
    all(timestamp(c(
      current$analytical_time, current$target_interval_start,
      current$target_interval_end, trajectory$analytical_time,
      trajectory$target_interval_start, trajectory$target_interval_end,
      summary$analytical_time, summary$scope_created_at
    ))) &&
    all(current$target_interval_boundary == "(start,end]") &&
    all(trajectory$target_interval_boundary == "(start,end]") &&
    identical(
      summary$effective_disposition_count[[1L]],
      summary$accepted_estimate_count[[1L]] +
        summary$provider_incompatible_count[[1L]] +
        summary$provider_declared_failure_count[[1L]] +
        summary$detected_failure_count[[1L]] +
        summary$ineligible_count[[1L]]
    )
  if (!valid) rrp_application_abort("application_product_incompatible")
  invisible(products)
}

rrp_application_load_product_set <- function(set_root) {
  if (!rrp_application_scalar(set_root, 4096L) || !dir.exists(set_root) ||
      nzchar(Sys.readlink(set_root))) {
    rrp_application_abort("application_product_integrity_failed")
  }
  root <- normalizePath(set_root, winslash = "/", mustWork = TRUE)
  actual <- sort(list.files(
    root, all.files = TRUE, no.. = TRUE, recursive = FALSE
  ), method = "radix")
  expected <- sort(c("inventory.dcf", rrp_application_managed_paths()),
    method = "radix")
  if (!identical(actual, expected)) {
    rrp_application_abort("application_product_integrity_failed")
  }
  inventory <- rrp_application_read_dcf(
    file.path(root, "inventory.dcf"), rrp_application_inventory_fields(),
    length(rrp_application_managed_paths())
  )
  paths <- vapply(inventory, `[[`, character(1L), "Path")
  expected_paths <- rrp_application_managed_paths()
  valid_inventory <- identical(paths, expected_paths) &&
    !anyDuplicated(tolower(paths)) &&
    identical(
      vapply(inventory, `[[`, character(1L), "Record-Type"),
      rep("managed-file", length(paths))
    ) &&
    identical(
      vapply(inventory, `[[`, character(1L), "Role"),
      c("product_member", "product_member", "product_declaration",
        "product_member")
    )
  if (!valid_inventory) {
    rrp_application_abort("application_product_integrity_failed")
  }
  for (item in inventory) {
    if (!rrp_application_regular_file(root, item$Path)) {
      rrp_application_abort("application_product_integrity_failed")
    }
    size <- file.info(file.path(root, item$Path), extra_cols = FALSE)$size[[1L]]
    if (!grepl("^(0|[1-9][0-9]*)$", item[["Byte-Size"]]) ||
        !identical(as.character(size), item[["Byte-Size"]]) ||
        !grepl("^[0-9a-f]{64}$", item$SHA256) ||
        !identical(rrp_application_sha256(file.path(root, item$Path)),
          item$SHA256)) {
      rrp_application_abort("application_product_integrity_failed")
    }
  }
  declaration <- rrp_application_read_dcf(
    file.path(root, "products.dcf"), rrp_application_product_fields(), 1L
  )[[1L]]
  fixed <- c(
    "Record-Type" = "rrp-application-product-set",
    "Portable-Application-Contract-ID" = "rrp.application.portable",
    "Portable-Application-Contract-Version" = "0.1.0",
    "Product-Set-Contract-ID" = "rrp.product-set.initial-readmission-risk",
    "Product-Set-Contract-Version" = "0.1.0"
  )
  if (!all(vapply(names(fixed), function(field) {
      identical(declaration[[field]], unname(fixed[[field]]))
    }, logical(1L)))) {
    rrp_application_abort("application_product_incompatible")
  }
  definitions <- list(
    current_remaining_risk = c(
      prefix = "Current-Remaining-Risk",
      id = "rrp.product.current-remaining-risk",
      file = "current-remaining-risk.csv"
    ),
    remaining_risk_trajectory = c(
      prefix = "Remaining-Risk-Trajectory",
      id = "rrp.product.remaining-risk-trajectory",
      file = "remaining-risk-trajectory.csv"
    ),
    operational_scope_summary = c(
      prefix = "Operational-Scope-Summary",
      id = "rrp.product.operational-scope-summary",
      file = "operational-scope-summary.csv"
    )
  )
  schemas <- rrp_application_csv_schemas()
  products <- lapply(names(definitions), function(name) {
    definition <- definitions[[name]]
    get <- function(field) declaration[[paste(definition[["prefix"]], field,
      sep = "-")]]
    if (!identical(get("Product-Contract-ID"), definition[["id"]]) ||
        !identical(get("Product-Contract-Version"), "0.1.0") ||
        !identical(get("File"), definition[["file"]]) ||
        !grepl("^(0|[1-9][0-9]*)$", get("Row-Count"))) {
      rrp_application_abort("application_product_incompatible")
    }
    data <- rrp_application_read_csv(root, definition[["file"]], schemas[[name]])
    if (!identical(as.integer(nrow(data)), as.integer(get("Row-Count")))) {
      rrp_application_abort("application_product_integrity_failed")
    }
    list(
      product_contract_id = definition[["id"]],
      product_contract_version = "0.1.0",
      product_instance_id = get("Product-Instance-ID"),
      product_set_id = declaration[["Product-Set-ID"]],
      row_count = as.integer(nrow(data)),
      data = data
    )
  })
  names(products) <- names(definitions)
  rrp_application_validate_loaded_products(products)
  snapshot <- structure(list(
    product_set_id = declaration[["Product-Set-ID"]],
    source_operation_run_id = declaration[["Source-Operation-Run-ID"]],
    source_analytical_time = declaration[["Source-Analytical-Time"]],
    source_history_cutoff = declaration[["Source-History-Cutoff"]],
    source_history_fingerprint = declaration[["Source-History-Fingerprint"]],
    freshness = list(
      status = "not-evaluated", expected_operation_run_id = NULL,
      expected_history_cutoff = NULL,
      expected_source_history_fingerprint = NULL
    ),
    products = products
  ), class = c("rrp_application_product_snapshot", "list"))
  rrp_application_validate_snapshot(snapshot)
  snapshot
}

rrp_application_presentation_fields <- function() c(
  "Record-Type", "Presentation-Contract-ID", "Presentation-Contract-Version",
  "Brand-Contract-ID", "Brand-Contract-Version", "Source", "Display-Name",
  "Primary-Color", "Logo-File", "Logo-Media-Type", "Logo-Alt"
)

rrp_application_load_presentation <- function(root, css_file, declaration_file) {
  if (!rrp_application_scalar(root, 4096L) || !dir.exists(root) ||
      nzchar(Sys.readlink(root)) ||
      !rrp_application_safe_relative_path(css_file) ||
      !rrp_application_safe_relative_path(declaration_file) ||
      !rrp_application_regular_file(root, css_file) ||
      !rrp_application_regular_file(root, declaration_file)) {
    rrp_application_abort("application_input_invalid")
  }
  declaration <- rrp_application_read_dcf(
    file.path(root, declaration_file), rrp_application_presentation_fields(), 1L
  )[[1L]]
  fixed <- c(
    "Record-Type" = "rrp-application-presentation",
    "Presentation-Contract-ID" = "rrp.application-presentation",
    "Presentation-Contract-Version" = "0.1.0",
    "Brand-Contract-ID" = "rrp.project-brand",
    "Brand-Contract-Version" = "0.1.0"
  )
  if (!all(vapply(names(fixed), function(field) {
      identical(declaration[[field]], unname(fixed[[field]]))
    }, logical(1L))) ||
      !declaration$Source %in% c("rrp-defaults", "project-brand") ||
      !rrp_application_scalar(declaration[["Display-Name"]]) ||
      !grepl("^#[0-9A-F]{6}$", declaration[["Primary-Color"]])) {
    rrp_application_abort("application_input_invalid")
  }
  logo <- NULL
  if (!identical(declaration[["Logo-File"]], "none")) {
    relative <- declaration[["Logo-File"]]
    media <- declaration[["Logo-Media-Type"]]
    if (!rrp_application_regular_file(root, relative) ||
        !media %in% c("image/png", "image/jpeg") ||
        !rrp_application_scalar(declaration[["Logo-Alt"]], 200L)) {
      rrp_application_abort("application_input_invalid")
    }
    path <- file.path(root, relative)
    bytes <- readBin(path, "raw", n = file.info(path, extra_cols = FALSE)$size[[1L]])
    png <- length(bytes) >= 8L && identical(bytes[1:8], as.raw(c(
      0x89, 0x50, 0x4e, 0x47, 0x0d, 0x0a, 0x1a, 0x0a
    )))
    jpeg <- length(bytes) >= 3L &&
      identical(bytes[1:3], as.raw(c(0xff, 0xd8, 0xff)))
    if (xor(png, jpeg) &&
        identical(media, if (png) "image/png" else "image/jpeg")) {
      logo <- list(
        media_type = media, bytes = bytes, alt = declaration[["Logo-Alt"]]
      )
    } else {
      rrp_application_abort("application_input_invalid")
    }
  } else if (!identical(declaration[["Logo-Media-Type"]], "none") ||
      !identical(declaration[["Logo-Alt"]], "none")) {
    rrp_application_abort("application_input_invalid")
  }
  model <- structure(list(
    brand_contract_id = "rrp.project-brand",
    brand_contract_version = "0.1.0",
    source = declaration$Source,
    display_name = declaration[["Display-Name"]],
    primary_color = declaration[["Primary-Color"]],
    logo = logo,
    rrp_css = paste(readLines(
      file.path(root, css_file), warn = FALSE, encoding = "UTF-8"
    ), collapse = "\n")
  ), class = c("rrp_presentation_model", "list"))
  rrp_application_validate_presentation(model)
  model
}
