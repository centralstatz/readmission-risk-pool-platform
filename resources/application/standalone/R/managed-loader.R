rrp_standalone_load_managed_set <- function(root, pointer_file = "current.dcf") {
  fields <- c(
    "Record-Type", "Managed-Content-Contract-ID",
    "Managed-Content-Contract-Version", "Set-Directory", "Product-Set-ID",
    "Materialization-ID", "Source-Operation-Run-ID", "Source-History-Cutoff",
    "Source-History-Fingerprint", "Managed-Inventory-SHA256"
  )
  pointer_relative <- paste0("rrp-data/", pointer_file)
  pointer_path <- file.path(root, pointer_relative)
  if (!rrp_application_safe_relative_path(pointer_relative) ||
      !rrp_application_regular_file(root, pointer_relative)) {
    rrp_application_abort("application_product_integrity_failed")
  }
  pointer <- rrp_application_read_dcf(pointer_path, fields, 1L)[[1L]]
  fixed <- c(
    "Record-Type" = "rrp-application-current",
    "Managed-Content-Contract-ID" = "rrp.application-managed-content",
    "Managed-Content-Contract-Version" = "0.1.0"
  )
  if (!all(vapply(names(fixed), function(field) identical(
      pointer[[field]], unname(fixed[[field]])), logical(1L))) ||
      !rrp_application_safe_relative_path(pointer[["Set-Directory"]]) ||
      !grepl("^sets/set-[0-9a-f]{24}$", pointer[["Set-Directory"]])) {
    rrp_application_abort("application_product_integrity_failed")
  }
  set_root <- file.path(root, "rrp-data", pointer[["Set-Directory"]])
  set <- rrp_application_load_product_set(set_root)
  declaration <- rrp_application_read_dcf(
    file.path(set_root, "products.dcf"), rrp_application_product_fields(), 1L
  )[[1L]]
  valid <- identical(set$product_set_id, pointer[["Product-Set-ID"]]) &&
    identical(declaration[["Materialization-ID"]],
      pointer[["Materialization-ID"]]) &&
    identical(set$source_operation_run_id,
      pointer[["Source-Operation-Run-ID"]]) &&
    identical(set$source_history_cutoff,
      pointer[["Source-History-Cutoff"]]) &&
    identical(set$source_history_fingerprint,
      pointer[["Source-History-Fingerprint"]]) &&
    identical(rrp_application_sha256(file.path(set_root, "inventory.dcf")),
      pointer[["Managed-Inventory-SHA256"]])
  if (!valid) rrp_application_abort("application_product_integrity_failed")
  list(pointer = pointer, set = set, set_root = set_root,
    declaration = declaration)
}

rrp_standalone_application_model <- function(root) {
  managed <- rrp_standalone_load_managed_set(root)
  presentation <- rrp_application_load_presentation(
    root, "www/rrp.css", "rrp-data/presentation.dcf"
  )
  rrp_application_model(managed$set, presentation)
}
