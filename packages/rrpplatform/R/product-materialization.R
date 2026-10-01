rrp_product_materialization_contract_expected <- function() {
  set_fields <- c(
    "Product-Set-Contract-ID", "Product-Set-Contract-Version", "Product-Set-ID",
    "Builder-ID", "Builder-Version", "Product-ID", "Development-Version",
    "RRP-API-Version", "Project-ID", "Project-Version", "State-ID",
    "Source-Scope-Contract-ID", "Source-Scope-Contract-Version",
    "Source-Disposition-Contract-ID", "Source-Disposition-Contract-Version",
    "Source-Action-Contract-ID", "Source-Action-Contract-Version",
    "Source-History-Port-Contract-ID", "Source-History-Port-Contract-Version",
    "Logical-History-Format-Version", "Source-Operation-Run-ID",
    "Source-Scope-Record-ID", "Bundle-Contract-ID", "Bundle-Contract-Version",
    "Bundle-Instance-ID", "Canonical-Profile-ID", "Canonical-Profile-Version",
    "Producer-ID", "Producer-Version", "Producer-Implementation-ID",
    "Producer-Implementation-Version", "Mapping-ID", "Mapping-Version",
    "Target-ID", "Target-Version", "Source-Analytical-Time",
    "Source-History-Cutoff", "Source-History-Fingerprint",
    "Source-History-Fingerprint-Algorithm"
  )
  member_fields <- c(
    "Product-Contract-ID", "Product-Contract-Version", "Product-Instance-ID",
    "Row-Count", "File", "Byte-Size", "MD5"
  )
  member_prefixes <- c(
    "Current-Remaining-Risk", "Remaining-Risk-Trajectory",
    "Operational-Scope-Summary"
  )
  manifest_fields <- c(
    "Record-Type", "Materialization-Contract-ID",
    "Materialization-Contract-Version", "Adapter-ID", "Adapter-Version",
    "Physical-Format-ID", "Physical-Format-Version", "Materialization-ID",
    set_fields,
    unlist(lapply(member_prefixes, function(prefix) {
      paste(prefix, member_fields, sep = "-")
    }), use.names = FALSE)
  )
  c(
    "Record-Type" = "contract",
    "Contract-ID" = "rrp.product-materialization",
    "Contract-Version" = "0.1.0",
    "Format-Version" = "1.0.0",
    "Product-ID" = "readmission-risk-pool-platform",
    "Development-Version" = "1.0.0-dev",
    "Status" = "development_unpublished",
    "Owner-Package" = "rrpplatform",
    "Adapter-ID" = "rrp.materializer.dcf-csv",
    "Adapter-Version" = "0.1.0",
    "Physical-Format-ID" = "rrp.product-format.dcf-csv",
    "Physical-Format-Version" = "0.1.0",
    "State-Contract-ID" = "rrp.project-state",
    "State-Contract-Version" = "0.2.0",
    "Product-Set-Contract-ID" = "rrp.product-set.initial-readmission-risk",
    "Product-Set-Contract-Version" = "0.1.0",
    "Store-Directory" = "products",
    "Pointer-File" = "current.dcf",
    "Sets-Directory" = "sets",
    "Manifest-File" = "product-set.dcf",
    "Member-Keys" = paste(c(
      "current_remaining_risk", "remaining_risk_trajectory",
      "operational_scope_summary"
    ), collapse = ","),
    "Member-Files" = paste(c(
      "current-remaining-risk.csv", "remaining-risk-trajectory.csv",
      "operational-scope-summary.csv"
    ), collapse = ","),
    "Set-Inventory" = paste(c(
      "current-remaining-risk.csv", "operational-scope-summary.csv",
      "product-set.dcf", "remaining-risk-trajectory.csv"
    ), collapse = ","),
    "Pointer-Fields" = paste(c(
      "Record-Type", "Materialization-Contract-ID",
      "Materialization-Contract-Version", "Adapter-ID", "Adapter-Version",
      "Physical-Format-ID", "Physical-Format-Version", "Materialization-ID",
      "Product-Set-ID", "Set-Directory", "Manifest-File", "Manifest-Size",
      "Manifest-MD5", "Published-At"
    ), collapse = ","),
    "Manifest-Set-Fields" = paste(set_fields, collapse = ","),
    "Manifest-Member-Fields" = paste(member_fields, collapse = ","),
    "Manifest-Fields" = paste(manifest_fields, collapse = ","),
    "Pointer-Record-Type" = "rrp-current-product-set",
    "Manifest-Record-Type" = "rrp-product-set-materialization",
    "Materialization-ID-Pattern" = "^rrp[.]materialization[.][0-9a-f]{16}$",
    "Materialization-ID-Inputs" =
      "adapter,physical_format,product_set_id,member_file_names_sizes_md5",
    "Materialization-ID-Algorithm" = "dual_modular_hash_v1",
    "Set-Directory-Pattern" =
      "^sets/rrp[.]materialization[.][0-9a-f]{16}$",
    "Staging-Directory-Prefix" = ".rrp-product-staging-",
    "CSV-Encoding" = "utf-8-rfc4180-like-base-r-v1",
    "Nullable-Character-Encoding" = "empty_string",
    "Digest-Algorithm" = "md5",
    "Digest-Purpose" = "accidental_corruption_only",
    "Publication" =
      "staged_whole_set_validate_promote_then_atomic_pointer_replace",
    "Published-Set-Mutation" = "prohibited",
    "Prior-Set-Retention" = "preserve",
    "Consumer-Physical-Path-Exposure" = "prohibited",
    "Backup-Inclusion" = "prohibited",
    "Unknown-Fields" = "prohibited",
    "Additional-Records" = "prohibited",
    "Linked-Or-Nonregular-Inventory" = "prohibited"
  )
}

rrp_product_materialization_contract <- function(catalog) {
  rrp_project_contract_record(
    catalog, "rrp.contract.product-materialization",
    rrp_product_materialization_contract_expected(),
    "product_materialization_contract"
  )
}

rrp_materialization_abort <- function(code) {
  messages <- c(
    product_materialization_failed = "Product materialization failed.",
    product_integrity_failed = "Product materialization integrity validation failed.",
    product_materialization_incompatible = "Product materialization is incompatible.",
    product_access_failed = "Product access failed."
  )
  stop(structure(
    list(message = unname(messages[[code]]), call = NULL, code = code),
    class = c("rrp_materialization_error", "error", "condition")
  ))
}

rrp_product_access_abort <- function() {
  stop(structure(
    list(
      message = "Product access operation failed.", call = NULL,
      code = "product_access_failed"
    ),
    class = c("rrp_product_access_error", "error", "condition")
  ))
}

rrp_product_regular_file <- function(path) {
  link <- Sys.readlink(path)
  info <- file.info(path, extra_cols = FALSE)
  file.exists(path) && (is.na(link) || !nzchar(link)) && nrow(info) == 1L &&
    !is.na(info$isdir[[1L]]) && !isTRUE(info$isdir[[1L]])
}

rrp_product_regular_directory <- function(path) {
  link <- Sys.readlink(path)
  info <- file.info(path, extra_cols = FALSE)
  dir.exists(path) && (is.na(link) || !nzchar(link)) && nrow(info) == 1L &&
    !is.na(info$isdir[[1L]]) && isTRUE(info$isdir[[1L]])
}

rrp_product_fields <- function(contract, name) {
  strsplit(contract[[name]], ",", fixed = TRUE)[[1L]]
}

rrp_product_member_maps <- function(contract) {
  keys <- rrp_product_fields(contract, "Member-Keys")
  files <- rrp_product_fields(contract, "Member-Files")
  prefixes <- c(
    current_remaining_risk = "Current-Remaining-Risk",
    remaining_risk_trajectory = "Remaining-Risk-Trajectory",
    operational_scope_summary = "Operational-Scope-Summary"
  )
  stopifnot(identical(names(prefixes), keys), length(files) == length(keys))
  list(files = stats::setNames(files, keys), prefixes = prefixes)
}

rrp_product_store_inventory <- function(
  root, allow_absent_pointer = TRUE, additional_pointer = NULL
) {
  if (!rrp_product_regular_directory(root)) {
    rrp_materialization_abort("product_integrity_failed")
  }
  entries <- list.files(root, all.files = TRUE, no.. = TRUE)
  files <- entries[vapply(file.path(root, entries), rrp_product_regular_file,
    logical(1L))]
  directories <- entries[vapply(file.path(root, entries),
    rrp_product_regular_directory, logical(1L))]
  if (!all(entries %in% c(files, directories)) ||
      !identical(sort(directories, method = "radix"), "sets") ||
      !all(files %in% c("current.dcf", additional_pointer)) ||
      (!allow_absent_pointer && !identical(files, "current.dcf"))) {
    rrp_materialization_abort("product_integrity_failed")
  }
  sets <- file.path(root, "sets")
  set_entries <- list.files(sets, all.files = TRUE, no.. = TRUE)
  if (length(set_entries)) for (entry in set_entries) {
    path <- file.path(sets, entry)
    published <- grepl("^rrp[.]materialization[.][0-9a-f]{16}$", entry)
    staging <- startsWith(entry, ".rrp-product-staging-") &&
      grepl("^[.A-Za-z0-9_-]+$", entry)
    if ((!published && !staging) || !rrp_product_regular_directory(path)) {
      rrp_materialization_abort("product_integrity_failed")
    }
    nested <- list.dirs(path, recursive = TRUE, full.names = FALSE)
    nested <- nested[nzchar(nested)]
    children <- list.files(path, all.files = TRUE, no.. = TRUE)
    if (length(nested) || any(!vapply(file.path(path, children),
      rrp_product_regular_file, logical(1L)))) {
      rrp_materialization_abort("product_integrity_failed")
    }
    if (published && !identical(
      sort(children, method = "radix"),
      c("current-remaining-risk.csv", "operational-scope-summary.csv",
        "product-set.dcf", "remaining-risk-trajectory.csv")
    )) rrp_materialization_abort("product_integrity_failed")
    if (staging && !all(children %in% c(
      "current-remaining-risk.csv", "operational-scope-summary.csv",
      "product-set.dcf", "remaining-risk-trajectory.csv"
    ))) rrp_materialization_abort("product_integrity_failed")
  }
  invisible(TRUE)
}

rrp_product_read_dcf <- function(path, code = "product_integrity_failed") {
  if (!rrp_product_regular_file(path)) rrp_materialization_abort(code)
  tryCatch(
    rrp_state_read_metadata(path),
    rrp_state_error = function(condition) rrp_materialization_abort(code),
    error = function(condition) rrp_materialization_abort(code)
  )
}

rrp_product_write_dcf <- function(values, path) {
  tryCatch(
    writeLines(paste0(names(values), ": ", unname(values)), path, useBytes = TRUE),
    error = function(condition) rrp_materialization_abort(
      "product_materialization_failed"
    )
  )
}

rrp_product_file_evidence <- function(path) {
  if (!rrp_product_regular_file(path)) {
    rrp_materialization_abort("product_integrity_failed")
  }
  list(
    size = as.character(file.info(path, extra_cols = FALSE)$size[[1L]]),
    md5 = unname(tools::md5sum(path)[[1L]])
  )
}

rrp_product_raw_equal <- function(first, second) {
  identical(readBin(first, "raw", n = file.info(first)$size),
    readBin(second, "raw", n = file.info(second)$size))
}

rrp_product_write_csv <- function(data, path) {
  tryCatch(
    utils::write.table(
      data, path, sep = ",", row.names = FALSE, col.names = TRUE,
      quote = TRUE, qmethod = "double", na = "", eol = "\n",
      fileEncoding = "UTF-8"
    ),
    error = function(condition) rrp_materialization_abort(
      "product_materialization_failed"
    )
  )
}

rrp_product_contract_selected <- function(contract, field) {
  if (identical(contract[[field]], "none")) character() else
    strsplit(contract[[field]], ",", fixed = TRUE)[[1L]]
}

rrp_product_read_csv <- function(path, member, contract) {
  if (!rrp_product_regular_file(path)) {
    rrp_materialization_abort("product_integrity_failed")
  }
  fields <- rrp_product_contract_selected(contract, "Row-Fields")
  raw <- tryCatch(
    utils::read.csv(
      path, header = TRUE, colClasses = "character", na.strings = "",
      check.names = FALSE, stringsAsFactors = FALSE,
      strip.white = FALSE, fileEncoding = "UTF-8"
    ),
    error = function(condition) rrp_materialization_abort(
      "product_integrity_failed"
    )
  )
  if (!identical(names(raw), fields)) {
    rrp_materialization_abort("product_integrity_failed")
  }
  data <- raw
  for (field in rrp_product_contract_selected(contract, "Integer-Fields")) {
    value <- raw[[field]]
    if (anyNA(value) || any(!grepl("^(0|[1-9][0-9]*)$", value))) {
      rrp_materialization_abort("product_integrity_failed")
    }
    converted <- suppressWarnings(as.integer(value))
    if (anyNA(converted)) rrp_materialization_abort("product_integrity_failed")
    data[[field]] <- converted
  }
  for (field in rrp_product_contract_selected(contract, "Double-Fields")) {
    value <- raw[[field]]
    converted <- suppressWarnings(as.double(value))
    if (anyNA(value) || anyNA(converted) || !all(is.finite(converted))) {
      rrp_materialization_abort("product_integrity_failed")
    }
    data[[field]] <- converted
  }
  for (field in rrp_product_contract_selected(contract, "Logical-Fields")) {
    value <- raw[[field]]
    if (anyNA(value) || any(!value %in% c("TRUE", "FALSE"))) {
      rrp_materialization_abort("product_integrity_failed")
    }
    data[[field]] <- value == "TRUE"
  }
  member$data <- data
  member$row_count <- as.integer(nrow(data))
  tryCatch(
    rrp_product_validate_member(member, contract),
    rrp_product_error = function(condition) rrp_materialization_abort(
      "product_integrity_failed"
    )
  )
  canonical <- tempfile("rrp-product-canonical-", fileext = ".csv")
  on.exit(unlink(canonical, force = TRUE), add = TRUE)
  rrp_product_write_csv(data, canonical)
  if (!rrp_product_raw_equal(path, canonical)) {
    rrp_materialization_abort("product_integrity_failed")
  }
  member
}

rrp_product_set_manifest_map <- function() c(
  product_set_contract_id = "Product-Set-Contract-ID",
  product_set_contract_version = "Product-Set-Contract-Version",
  product_set_id = "Product-Set-ID", builder_id = "Builder-ID",
  builder_version = "Builder-Version", product_id = "Product-ID",
  development_version = "Development-Version", rrp_api_version = "RRP-API-Version",
  project_id = "Project-ID", project_version = "Project-Version",
  state_id = "State-ID", source_scope_contract_id = "Source-Scope-Contract-ID",
  source_scope_contract_version = "Source-Scope-Contract-Version",
  source_disposition_contract_id = "Source-Disposition-Contract-ID",
  source_disposition_contract_version = "Source-Disposition-Contract-Version",
  source_action_contract_id = "Source-Action-Contract-ID",
  source_action_contract_version = "Source-Action-Contract-Version",
  source_history_port_contract_id = "Source-History-Port-Contract-ID",
  source_history_port_contract_version = "Source-History-Port-Contract-Version",
  logical_history_format_version = "Logical-History-Format-Version",
  source_operation_run_id = "Source-Operation-Run-ID",
  source_scope_record_id = "Source-Scope-Record-ID",
  bundle_contract_id = "Bundle-Contract-ID",
  bundle_contract_version = "Bundle-Contract-Version",
  bundle_instance_id = "Bundle-Instance-ID",
  canonical_profile_id = "Canonical-Profile-ID",
  canonical_profile_version = "Canonical-Profile-Version",
  producer_id = "Producer-ID", producer_version = "Producer-Version",
  producer_implementation_id = "Producer-Implementation-ID",
  producer_implementation_version = "Producer-Implementation-Version",
  mapping_id = "Mapping-ID", mapping_version = "Mapping-Version",
  target_id = "Target-ID", target_version = "Target-Version",
  source_analytical_time = "Source-Analytical-Time",
  source_history_cutoff = "Source-History-Cutoff",
  source_history_fingerprint = "Source-History-Fingerprint",
  source_history_fingerprint_algorithm = "Source-History-Fingerprint-Algorithm"
)

rrp_product_new_manifest <- function(
  product_set, member_evidence, materialization_id, contract
) {
  set_map <- rrp_product_set_manifest_map()
  values <- c(
    "Record-Type" = contract[["Manifest-Record-Type"]],
    "Materialization-Contract-ID" = contract[["Contract-ID"]],
    "Materialization-Contract-Version" = contract[["Contract-Version"]],
    "Adapter-ID" = contract[["Adapter-ID"]],
    "Adapter-Version" = contract[["Adapter-Version"]],
    "Physical-Format-ID" = contract[["Physical-Format-ID"]],
    "Physical-Format-Version" = contract[["Physical-Format-Version"]],
    "Materialization-ID" = materialization_id
  )
  values <- c(values, stats::setNames(
    vapply(names(set_map), function(name) product_set[[name]], character(1L)),
    unname(set_map)
  ))
  maps <- rrp_product_member_maps(contract)
  for (name in names(maps$files)) {
    prefix <- unname(maps$prefixes[[name]])
    member <- product_set$members[[name]]
    evidence <- member_evidence[[name]]
    values <- c(values, stats::setNames(c(
      member$product_contract_id, member$product_contract_version,
      member$product_instance_id, as.character(member$row_count),
      unname(maps$files[[name]]), evidence$size, evidence$md5
    ), paste(prefix, c(
      "Product-Contract-ID", "Product-Contract-Version", "Product-Instance-ID",
      "Row-Count", "File", "Byte-Size", "MD5"
    ), sep = "-")))
  }
  stopifnot(identical(names(values), rrp_product_fields(contract, "Manifest-Fields")))
  values
}

rrp_product_materialization_id <- function(product_set, evidence, contract) {
  maps <- rrp_product_member_maps(contract)
  facts <- unlist(lapply(names(maps$files), function(name) c(
    unname(maps$files[[name]]), evidence[[name]]$size, evidence[[name]]$md5
  )), use.names = FALSE)
  rrp_product_identity("rrp.materialization.", list(
    contract[["Adapter-ID"]], contract[["Adapter-Version"]],
    contract[["Physical-Format-ID"]], contract[["Physical-Format-Version"]],
    product_set$product_set_id, as.list(facts)
  ))
}

rrp_product_new_pointer <- function(manifest, manifest_evidence, contract) c(
  "Record-Type" = contract[["Pointer-Record-Type"]],
  "Materialization-Contract-ID" = contract[["Contract-ID"]],
  "Materialization-Contract-Version" = contract[["Contract-Version"]],
  "Adapter-ID" = contract[["Adapter-ID"]],
  "Adapter-Version" = contract[["Adapter-Version"]],
  "Physical-Format-ID" = contract[["Physical-Format-ID"]],
  "Physical-Format-Version" = contract[["Physical-Format-Version"]],
  "Materialization-ID" = manifest[["Materialization-ID"]],
  "Product-Set-ID" = manifest[["Product-Set-ID"]],
  "Set-Directory" = paste0("sets/", manifest[["Materialization-ID"]]),
  "Manifest-File" = contract[["Manifest-File"]],
  "Manifest-Size" = manifest_evidence$size,
  "Manifest-MD5" = manifest_evidence$md5,
  "Published-At" = format(Sys.time(), "%Y-%m-%dT%H:%M:%SZ", tz = "UTC")
)

rrp_product_validate_pointer <- function(pointer, contract) {
  fixed <- c(
    "Record-Type" = contract[["Pointer-Record-Type"]],
    "Materialization-Contract-ID" = contract[["Contract-ID"]],
    "Materialization-Contract-Version" = contract[["Contract-Version"]],
    "Adapter-ID" = contract[["Adapter-ID"]],
    "Adapter-Version" = contract[["Adapter-Version"]],
    "Physical-Format-ID" = contract[["Physical-Format-ID"]],
    "Physical-Format-Version" = contract[["Physical-Format-Version"]],
    "Manifest-File" = contract[["Manifest-File"]]
  )
  compatible <- is.character(pointer) &&
    identical(names(pointer), rrp_product_fields(contract, "Pointer-Fields")) &&
    all(vapply(names(fixed), function(name) identical(pointer[[name]], fixed[[name]]),
      logical(1L)))
  if (!compatible) rrp_materialization_abort(
    "product_materialization_incompatible"
  )
  valid <- grepl(contract[["Materialization-ID-Pattern"]],
      pointer[["Materialization-ID"]]) &&
    identical(pointer[["Set-Directory"]], paste0(
      "sets/", pointer[["Materialization-ID"]]
    )) && grepl(contract[["Set-Directory-Pattern"]], pointer[["Set-Directory"]]) &&
    grepl("^[0-9]+$", pointer[["Manifest-Size"]]) &&
    grepl("^[0-9a-f]{32}$", pointer[["Manifest-MD5"]]) &&
    !is.na(rrp_state_timestamp_number(pointer[["Published-At"]]))
  if (!valid) rrp_materialization_abort("product_integrity_failed")
  pointer
}

rrp_product_manifest_member <- function(manifest, name, contract) {
  maps <- rrp_product_member_maps(contract)
  prefix <- unname(maps$prefixes[[name]])
  get <- function(suffix) manifest[[paste(prefix, suffix, sep = "-")]]
  list(
    product_contract_id = get("Product-Contract-ID"),
    product_contract_version = get("Product-Contract-Version"),
    product_instance_id = get("Product-Instance-ID"),
    product_set_id = manifest[["Product-Set-ID"]],
    row_count = suppressWarnings(as.integer(get("Row-Count"))),
    data = NULL,
    file = get("File"), size = get("Byte-Size"), md5 = get("MD5")
  )
}

rrp_product_validate_set_directory <- function(
  set_path, expected_materialization_id, contract, product_contracts
) {
  if (!rrp_product_regular_directory(set_path)) {
    rrp_materialization_abort("product_integrity_failed")
  }
  entries <- sort(list.files(set_path, all.files = TRUE, no.. = TRUE),
    method = "radix")
  expected <- rrp_product_fields(contract, "Set-Inventory")
  if (!identical(entries, expected) || any(!vapply(
    file.path(set_path, entries), rrp_product_regular_file, logical(1L)
  ))) rrp_materialization_abort("product_integrity_failed")
  manifest_path <- file.path(set_path, contract[["Manifest-File"]])
  manifest <- rrp_product_read_dcf(manifest_path)
  if (!identical(names(manifest),
      rrp_product_fields(contract, "Manifest-Fields"))) {
    rrp_materialization_abort("product_integrity_failed")
  }
  fixed <- c(
    "Record-Type" = contract[["Manifest-Record-Type"]],
    "Materialization-Contract-ID" = contract[["Contract-ID"]],
    "Materialization-Contract-Version" = contract[["Contract-Version"]],
    "Adapter-ID" = contract[["Adapter-ID"]],
    "Adapter-Version" = contract[["Adapter-Version"]],
    "Physical-Format-ID" = contract[["Physical-Format-ID"]],
    "Physical-Format-Version" = contract[["Physical-Format-Version"]],
    "Product-Set-Contract-ID" = contract[["Product-Set-Contract-ID"]],
    "Product-Set-Contract-Version" = contract[["Product-Set-Contract-Version"]]
  )
  if (!identical(manifest[["Materialization-ID"]], expected_materialization_id) ||
      !all(vapply(names(fixed), function(name) identical(manifest[[name]], fixed[[name]]),
        logical(1L)))) rrp_materialization_abort(
          "product_materialization_incompatible"
        )
  maps <- rrp_product_member_maps(contract)
  set_map <- rrp_product_set_manifest_map()
  scalars <- stats::setNames(
    lapply(unname(set_map), function(field) unname(manifest[[field]])),
    names(set_map)
  )
  products <- list()
  member_contracts <- list(
    current_remaining_risk = product_contracts$current,
    remaining_risk_trajectory = product_contracts$trajectory,
    operational_scope_summary = product_contracts$summary
  )
  for (name in names(maps$files)) {
    descriptor <- rrp_product_manifest_member(manifest, name, contract)
    expected_contract <- member_contracts[[name]]
    if (!identical(descriptor$file, unname(maps$files[[name]])) ||
        !identical(descriptor$product_contract_id,
          expected_contract[["Contract-ID"]]) ||
        !identical(descriptor$product_contract_version,
          expected_contract[["Contract-Version"]]) ||
        is.na(descriptor$row_count) || descriptor$row_count < 0L ||
        !grepl("^[0-9]+$", descriptor$size) ||
        !grepl("^[0-9a-f]{32}$", descriptor$md5)) {
      rrp_materialization_abort("product_materialization_incompatible")
    }
    path <- file.path(set_path, descriptor$file)
    evidence <- rrp_product_file_evidence(path)
    if (!identical(evidence$size, descriptor$size) ||
        !identical(evidence$md5, descriptor$md5)) {
      rrp_materialization_abort("product_integrity_failed")
    }
    member <- structure(descriptor[c(
      "product_contract_id", "product_contract_version", "product_instance_id",
      "product_set_id", "row_count", "data"
    )], class = c("rrp_logical_product", "list"))
    member <- rrp_product_read_csv(path, member, expected_contract)
    if (!identical(member$row_count, descriptor$row_count)) {
      rrp_materialization_abort("product_integrity_failed")
    }
    products[[name]] <- member
  }
  references <- lapply(products, function(member) list(
    product_contract_id = member$product_contract_id,
    product_contract_version = member$product_contract_version,
    product_instance_id = member$product_instance_id
  ))
  product_set <- structure(c(scalars, list(
    member_references = references, members = products
  )), class = c("rrp_logical_product_set", "list"))
  tryCatch(
    rrp_validate_product_set(product_set, product_contracts),
    rrp_product_error = function(condition) rrp_materialization_abort(
      "product_integrity_failed"
    )
  )
  evidence <- rrp_product_file_evidence(manifest_path)
  list(manifest = manifest, manifest_evidence = evidence,
    product_set = product_set)
}

rrp_product_open_current <- function(
  store_path, pointer_file, contract, product_contracts
) {
  rrp_product_store_inventory(
    store_path, allow_absent_pointer = TRUE,
    additional_pointer = if (identical(pointer_file, "current.dcf")) NULL else
      pointer_file
  )
  pointer_path <- file.path(store_path, pointer_file)
  pointer <- rrp_product_validate_pointer(
    rrp_product_read_dcf(pointer_path, "product_access_failed"), contract
  )
  set_path <- file.path(store_path, pointer[["Set-Directory"]])
  validated <- rrp_product_validate_set_directory(
    set_path, pointer[["Materialization-ID"]], contract, product_contracts
  )
  if (!identical(pointer[["Product-Set-ID"]],
      validated$product_set$product_set_id) ||
      !identical(pointer[["Manifest-Size"]],
        validated$manifest_evidence$size) ||
      !identical(pointer[["Manifest-MD5"]],
        validated$manifest_evidence$md5)) {
    rrp_materialization_abort("product_integrity_failed")
  }
  list(pointer = pointer, product_set = validated$product_set)
}

rrp_product_staging_directory <- function(sets_path, contract) {
  for (attempt in seq_len(16L)) {
    path <- tempfile(contract[["Staging-Directory-Prefix"]], tmpdir = sets_path)
    if (!rrp_state_path_exists(path) && dir.create(path, showWarnings = FALSE) &&
        rrp_product_regular_directory(path)) return(path)
  }
  rrp_materialization_abort("product_materialization_failed")
}

rrp_product_remove_orphan_staging <- function(sets_path, contract) {
  entries <- list.files(sets_path, all.files = TRUE, no.. = TRUE)
  selected <- entries[startsWith(entries, contract[["Staging-Directory-Prefix"]])]
  for (entry in selected) {
    path <- file.path(sets_path, entry)
    if (!rrp_product_regular_directory(path)) {
      rrp_materialization_abort("product_integrity_failed")
    }
    unlink(path, recursive = TRUE, force = TRUE)
    if (rrp_state_path_exists(path)) {
      rrp_materialization_abort("product_materialization_failed")
    }
  }
}

rrp_product_restore_pointer <- function(pointer_path, previous_raw) {
  if (is.null(previous_raw)) {
    if (rrp_state_path_exists(pointer_path)) unlink(pointer_path, force = TRUE)
    return(invisible(NULL))
  }
  staged <- tempfile(".rrp-current-restore-", tmpdir = dirname(pointer_path))
  on.exit(if (rrp_state_path_exists(staged)) unlink(staged, force = TRUE), add = TRUE)
  writeBin(previous_raw, staged)
  if (!file.rename(staged, pointer_path)) {
    unlink(pointer_path, force = TRUE)
    if (!file.rename(staged, pointer_path)) {
      rrp_materialization_abort("product_materialization_failed")
    }
  }
  invisible(NULL)
}

rrp_product_replace_pointer <- function(staged, pointer_path) {
  if (file.rename(staged, pointer_path)) return(invisible(TRUE))
  previous <- tempfile(".rrp-current-previous-", tmpdir = dirname(pointer_path))
  moved <- rrp_state_path_exists(pointer_path) && file.rename(pointer_path, previous)
  if (rrp_state_path_exists(pointer_path) || !file.rename(staged, pointer_path)) {
    if (moved) file.rename(previous, pointer_path)
    rrp_materialization_abort("product_materialization_failed")
  }
  if (moved) unlink(previous, force = TRUE)
  invisible(TRUE)
}

rrp_product_materialization_value <- function(opened, reused) list(
  materialization_id = unname(opened$pointer[["Materialization-ID"]]),
  product_set_id = unname(opened$pointer[["Product-Set-ID"]]),
  adapter_id = unname(opened$pointer[["Adapter-ID"]]),
  adapter_version = unname(opened$pointer[["Adapter-Version"]]),
  physical_format_id = unname(opened$pointer[["Physical-Format-ID"]]),
  physical_format_version = unname(opened$pointer[["Physical-Format-Version"]]),
  reused = reused
)

rrp_product_materialize <- function(
  software_catalog, project_root, product_set, failure_stage = NULL,
  preserve_staging = FALSE
) {
  allowed <- c(
    "after_members", "after_manifest", "after_stage_validation",
    "after_set_promotion", "before_pointer_replace", "after_pointer_replace"
  )
  if (!is.null(failure_stage) && !failure_stage %in% allowed) {
    stop("Invalid internal product-materialization interruption stage.",
      call. = FALSE)
  }
  inject <- function(stage) if (identical(failure_stage, stage)) {
    rrp_materialization_abort("product_materialization_failed")
  }
  context <- rrp_load_project(software_catalog, project_root)
  state_contracts <- rrp_state_contracts(software_catalog)
  product_contracts <- rrp_product_contracts(software_catalog)
  contract <- rrp_product_materialization_contract(software_catalog)
  tryCatch(
    rrp_validate_product_set(product_set, product_contracts),
    rrp_product_error = function(condition) rrp_materialization_abort(
      "product_materialization_failed"
    )
  )
  metadata <- rrp_state_inspect_root(context$state_path, context, state_contracts)
  if (!identical(product_set$project_id, metadata[["Project-ID"]]) ||
      !identical(product_set$state_id, metadata[["State-ID"]])) {
    rrp_materialization_abort("product_materialization_incompatible")
  }
  store_path <- file.path(context$state_path, contract[["Store-Directory"]])
  sets_path <- file.path(store_path, contract[["Sets-Directory"]])
  completed <- FALSE
  store_owned <- FALSE
  on.exit({
    if (!completed && store_owned && rrp_state_path_exists(store_path)) {
      unlink(store_path, recursive = TRUE, force = TRUE)
    }
  }, add = TRUE)
  if (!rrp_state_path_exists(store_path)) {
    if (!dir.create(store_path, showWarnings = FALSE)) {
      rrp_materialization_abort("product_materialization_failed")
    }
    store_owned <- TRUE
    if (!dir.create(sets_path, showWarnings = FALSE)) {
      rrp_materialization_abort("product_materialization_failed")
    }
  }
  rrp_product_store_inventory(store_path, allow_absent_pointer = TRUE)
  rrp_product_remove_orphan_staging(sets_path, contract)
  staging <- rrp_product_staging_directory(sets_path, contract)
  staging_owned <- TRUE
  pointer_replaced <- FALSE
  pointer_path <- file.path(store_path, contract[["Pointer-File"]])
  previous_raw <- if (rrp_product_regular_file(pointer_path)) {
    readBin(pointer_path, "raw", n = file.info(pointer_path)$size)
  } else NULL
  on.exit({
    if (!completed && pointer_replaced) {
      rrp_product_restore_pointer(pointer_path, previous_raw)
    }
    if (staging_owned && rrp_state_path_exists(staging) &&
        !(preserve_staging && !completed)) {
      unlink(staging, recursive = TRUE, force = TRUE)
    }
  }, add = TRUE)
  maps <- rrp_product_member_maps(contract)
  evidence <- list()
  for (name in names(maps$files)) {
    path <- file.path(staging, unname(maps$files[[name]]))
    rrp_product_write_csv(product_set$members[[name]]$data, path)
    evidence[[name]] <- rrp_product_file_evidence(path)
  }
  inject("after_members")
  materialization_id <- rrp_product_materialization_id(
    product_set, evidence, contract
  )
  manifest <- rrp_product_new_manifest(
    product_set, evidence, materialization_id, contract
  )
  manifest_path <- file.path(staging, contract[["Manifest-File"]])
  rrp_product_write_dcf(manifest, manifest_path)
  inject("after_manifest")
  staged <- rrp_product_validate_set_directory(
    staging, materialization_id, contract, product_contracts
  )
  inject("after_stage_validation")
  final <- file.path(sets_path, materialization_id)
  reused <- FALSE
  if (rrp_state_path_exists(final)) {
    existing <- rrp_product_validate_set_directory(
      final, materialization_id, contract, product_contracts
    )
    staged_files <- rrp_product_fields(contract, "Set-Inventory")
    if (!all(vapply(staged_files, function(file) {
      rrp_product_raw_equal(file.path(staging, file), file.path(final, file))
    }, logical(1L)))) rrp_materialization_abort("product_materialization_failed")
    unlink(staging, recursive = TRUE, force = TRUE)
    staging_owned <- FALSE
    reused <- TRUE
    staged <- existing
  } else {
    if (!file.rename(staging, final)) {
      rrp_materialization_abort("product_materialization_failed")
    }
    staging_owned <- FALSE
  }
  inject("after_set_promotion")
  if (rrp_product_regular_file(pointer_path)) {
    current <- tryCatch(
      rrp_product_open_current(
        store_path, contract[["Pointer-File"]], contract, product_contracts
      ),
      rrp_materialization_error = function(condition) NULL
    )
    if (!is.null(current) && identical(
      current$pointer[["Materialization-ID"]], materialization_id
    )) {
      completed <- TRUE
      return(rrp_product_materialization_value(current, TRUE))
    }
  }
  pointer <- rrp_product_new_pointer(
    staged$manifest, staged$manifest_evidence, contract
  )
  pointer_staging <- tempfile(".rrp-current-", tmpdir = store_path,
    fileext = ".dcf")
  on.exit(if (rrp_state_path_exists(pointer_staging)) {
    unlink(pointer_staging, force = TRUE)
  }, add = TRUE)
  rrp_product_write_dcf(pointer, pointer_staging)
  rrp_product_open_current(
    store_path, basename(pointer_staging), contract, product_contracts
  )
  inject("before_pointer_replace")
  rrp_product_replace_pointer(pointer_staging, pointer_path)
  pointer_replaced <- TRUE
  inject("after_pointer_replace")
  opened <- rrp_product_open_current(
    store_path, contract[["Pointer-File"]], contract, product_contracts
  )
  completed <- TRUE
  rrp_product_materialization_value(opened, reused)
}

rrp_product_materialization_failure <- function(condition, operation_id) {
  code <- if (identical(operation_id, "rrp.open-product-access") &&
      !inherits(condition, "rrp_materialization_error")) {
    "product_access_failed"
  } else if (inherits(condition, "rrp_materialization_error")) {
    condition$code
  } else if (inherits(condition, "rrp_resource_error") ||
      inherits(condition, "rrp_project_error")) {
    "product_materialization_incompatible"
  } else "product_materialization_failed"
  rrp_new_operation_result(
    operation_id, "failure", NULL,
    list(rrp_new_diagnostic(code, "error", if (identical(
      operation_id, "rrp.open-product-access"
    )) "Product access failed." else "Product materialization failed."))
  )
}

#' Materialize one coherent logical product set
#'
#' @param software_catalog A validated explicit-root software resource catalog.
#' @param project_root One explicit initialized independent-project root.
#' @param product_set One conforming Stage 9 logical product set.
#' @return A common RRP operation result with bounded publication evidence.
#' @export
rrp_materialize_product_set <- function(
  software_catalog, project_root, product_set
) tryCatch({
  value <- rrp_product_materialize(
    software_catalog, project_root, rrp_product_copy(product_set)
  )
  rrp_new_operation_result("rrp.materialize-product-set", "success", value, list())
}, rrp_product_error = function(condition) rrp_product_materialization_failure(
  condition, "rrp.materialize-product-set"
), rrp_materialization_error = function(condition) {
  rrp_product_materialization_failure(condition, "rrp.materialize-product-set")
}, rrp_resource_error = function(condition) rrp_product_materialization_failure(
  condition, "rrp.materialize-product-set"
), rrp_project_error = function(condition) rrp_product_materialization_failure(
  condition, "rrp.materialize-product-set"
), rrp_state_error = function(condition) rrp_product_materialization_failure(
  condition, "rrp.materialize-product-set"
), error = function(condition) rrp_product_materialization_failure(
  condition, "rrp.materialize-product-set"
))

rrp_product_freshness <- function(
  product_set, expected_operation_run_id, history_cutoff, durable
) {
  if (is.null(expected_operation_run_id) && is.null(history_cutoff)) return(list(
    status = "not-evaluated", expected_operation_run_id = NULL,
    expected_history_cutoff = NULL, expected_source_history_fingerprint = NULL
  ))
  paired <- is.character(expected_operation_run_id) &&
    length(expected_operation_run_id) == 1L &&
    !is.na(expected_operation_run_id) && nzchar(expected_operation_run_id) &&
    is.character(history_cutoff) && length(history_cutoff) == 1L &&
    !is.na(history_cutoff) && nzchar(history_cutoff)
  if (!paired) rrp_materialization_abort("product_access_failed")
  cutoff <- tryCatch(
    rrp_product_canonical_time(history_cutoff),
    rrp_product_error = function(condition) rrp_materialization_abort(
      "product_access_failed"
    )
  )
  snapshot <- tryCatch(
    rrp_product_source_snapshot(durable$port, expected_operation_run_id, cutoff),
    error = function(condition) rrp_materialization_abort("product_access_failed")
  )
  fresh <- identical(expected_operation_run_id,
      product_set$source_operation_run_id) &&
    identical(snapshot$fingerprint, product_set$source_history_fingerprint)
  list(
    status = if (fresh) "fresh" else "stale",
    expected_operation_run_id = expected_operation_run_id,
    expected_history_cutoff = cutoff,
    expected_source_history_fingerprint = snapshot$fingerprint
  )
}

rrp_product_access_new <- function(product_set, pointer, freshness) structure(
  list(
    product_set_id = product_set$product_set_id,
    materialization_id = unname(pointer[["Materialization-ID"]]),
    source_operation_run_id = product_set$source_operation_run_id,
    source_analytical_time = product_set$source_analytical_time,
    source_history_cutoff = product_set$source_history_cutoff,
    source_history_fingerprint = product_set$source_history_fingerprint,
    freshness = freshness,
    members = rrp_product_copy(product_set$members)
  ),
  class = c("rrp_product_access", "list")
)

rrp_product_access_validate <- function(value) {
  valid <- is.list(value) &&
    identical(class(value), c("rrp_product_access", "list")) &&
    identical(names(value), c(
      "product_set_id", "materialization_id", "source_operation_run_id",
      "source_analytical_time", "source_history_cutoff",
      "source_history_fingerprint", "freshness", "members"
    )) && is.list(value$freshness) &&
    value$freshness$status %in% c("not-evaluated", "fresh", "stale") &&
    identical(names(value$members), c(
      "current_remaining_risk", "remaining_risk_trajectory",
      "operational_scope_summary"
    )) && all(vapply(value$members, function(member) {
      is.list(member) && identical(member$product_set_id, value$product_set_id)
    }, logical(1L)))
  if (!valid) rrp_product_access_abort()
  invisible(value)
}

#' Open validated logical product access
#'
#' @param software_catalog A validated explicit-root software resource catalog.
#' @param project_root One explicit initialized independent-project root.
#' @param expected_operation_run_id Optional explicit governed source operation.
#' @param history_cutoff Optional paired RFC 3339 UTC history cutoff.
#' @return A common RRP operation result containing detached product access.
#' @export
rrp_open_product_access <- function(
  software_catalog, project_root, expected_operation_run_id = NULL,
  history_cutoff = NULL
) tryCatch({
  context <- rrp_load_project(software_catalog, project_root)
  contracts <- rrp_state_contracts(software_catalog)
  metadata <- rrp_state_inspect_root(context$state_path, context, contracts)
  materialization <- rrp_product_materialization_contract(software_catalog)
  product_contracts <- rrp_product_contracts(software_catalog)
  store <- file.path(context$state_path, materialization[["Store-Directory"]])
  opened <- rrp_product_open_current(
    store, materialization[["Pointer-File"]], materialization, product_contracts
  )
  if (!identical(opened$product_set$state_id, metadata[["State-ID"]]) ||
      !identical(opened$product_set$project_id, metadata[["Project-ID"]])) {
    rrp_materialization_abort("product_access_failed")
  }
  needs_history <- !(is.null(expected_operation_run_id) && is.null(history_cutoff))
  durable <- if (needs_history) rrp_durable_port(software_catalog, project_root) else NULL
  freshness <- rrp_product_freshness(
    opened$product_set, expected_operation_run_id, history_cutoff, durable
  )
  value <- rrp_product_access_new(
    opened$product_set, opened$pointer, freshness
  )
  rrp_new_operation_result("rrp.open-product-access", "success", value, list())
}, rrp_materialization_error = function(condition) {
  rrp_product_materialization_failure(condition, "rrp.open-product-access")
}, rrp_resource_error = function(condition) rrp_product_materialization_failure(
  condition, "rrp.open-product-access"
), rrp_project_error = function(condition) rrp_product_materialization_failure(
  condition, "rrp.open-product-access"
), rrp_state_error = function(condition) rrp_product_materialization_failure(
  condition, "rrp.open-product-access"
), rrp_history_error = function(condition) rrp_product_materialization_failure(
  condition, "rrp.open-product-access"
), error = function(condition) rrp_product_materialization_failure(
  condition, "rrp.open-product-access"
))

rrp_product_access_metadata <- function(access, member) list(
  product_id = member$product_contract_id,
  product_version = member$product_contract_version,
  product_instance_id = member$product_instance_id,
  product_set_id = access$product_set_id,
  row_count = member$row_count,
  source_operation_run_id = access$source_operation_run_id,
  source_analytical_time = access$source_analytical_time,
  source_history_cutoff = access$source_history_cutoff,
  freshness = rrp_product_copy(access$freshness)
)

#' List products through validated detached access
#'
#' @param product_access One validated `rrp_product_access`.
#' @return The exact bounded logical product inventory.
#' @export
rrp_list_products <- function(product_access) {
  rrp_product_access_validate(product_access)
  unname(lapply(product_access$members, function(member) {
    rrp_product_access_metadata(product_access, member)
  }))
}

#' Read one product through validated detached access
#'
#' @inheritParams rrp_list_products
#' @param product_id One exact logical product identity.
#' @param product_version One exact logical product version.
#' @param metadata_only Return bounded metadata rather than product rows.
#' @return One detached logical product or bounded metadata.
#' @export
rrp_read_product <- function(
  product_access, product_id, product_version, metadata_only = FALSE
) {
  rrp_product_access_validate(product_access)
  valid_args <- is.character(product_id) && length(product_id) == 1L &&
    !is.na(product_id) && nzchar(product_id) &&
    is.character(product_version) && length(product_version) == 1L &&
    !is.na(product_version) && nzchar(product_version) &&
    is.logical(metadata_only) && length(metadata_only) == 1L &&
    !is.na(metadata_only)
  if (!valid_args) rrp_product_access_abort()
  matches <- Filter(function(member) {
    identical(member$product_contract_id, product_id) &&
      identical(member$product_contract_version, product_version)
  }, product_access$members)
  if (length(matches) != 1L) rrp_product_access_abort()
  if (metadata_only) {
    rrp_product_copy(rrp_product_access_metadata(product_access, matches[[1L]]))
  } else rrp_product_copy(matches[[1L]])
}
