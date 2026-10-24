library(rrpplatform)

internal <- function(name) getFromNamespace(name, "rrpplatform")

valid_selector <- paste0(
  "1.0.0-dev/", paste(rep("a", 64L), collapse = "")
)
stopifnot(
  internal("rrp_software_selector_valid")(valid_selector),
  !internal("rrp_software_selector_valid")("1.0.0-dev"),
  !internal("rrp_software_selector_valid")("1.0.0-dev/latest"),
  !internal("rrp_software_selector_valid")(paste0(
    "1.0.0-dev/", paste(rep("A", 64L), collapse = "")
  ))
)

record <- c(
  "Product-ID" = "readmission-risk-pool-platform",
  "Product-Version" = "1.0.0-dev",
  "Installation-ID" = paste(rep("b", 64L), collapse = ""),
  "Distribution-ID" = paste(rep("a", 64L), collapse = ""),
  "Host-R-Version" = as.character(getRversion()),
  "Platform" = R.version$platform,
  "Architecture" = R.version$arch
)
verified <- list(
  record = record,
  artifact = c(
    "Artifact-State" = "development",
    "Target-Family" = "development-local",
    "Target-R-Version" = as.character(getRversion()),
    "Target-Platform" = R.version$platform,
    "Target-Architecture" = R.version$arch,
    "Qualification-Status" = "not_applicable"
  ),
  eligibility_status = "exact_build_target_unqualified",
  selector = valid_selector, activation_status = "inactive"
)
diagnosis <- internal("rrp_software_diagnosis_value")(verified)
stopifnot(
  identical(names(diagnosis), strsplit(
    internal("rrp_installed_diagnosis_contract_expected")()[["Value-Fields"]],
    ",", fixed = TRUE
  )[[1L]]),
  identical(diagnosis$software_status, "ready"),
  identical(diagnosis$artifact_state, "development"),
  identical(diagnosis$eligibility_status, "exact_build_target_unqualified"),
  identical(diagnosis$qualification_status, "not_applicable"),
  identical(diagnosis$activation_status, "inactive"),
  length(diagnosis$checks) == 7L
)

invalid <- diagnosis
invalid$unexpected <- "not allowed"
condition <- tryCatch({
  internal("rrp_software_diagnosis_validate_value")(invalid)
  NULL
}, error = identity)
stopifnot(inherits(condition, "error"))

empty <- tempfile("rrp-software-enumeration-")
dir.create(file.path(empty, "installations"), recursive = TRUE)
dir.create(file.path(empty, "staging"))
on.exit(unlink(empty, recursive = TRUE, force = TRUE), add = TRUE)
listed <- internal("rrp_list_installed_software")(empty)
current <- internal("rrp_current_installed_software")(empty)
doctor <- internal("rrp_software_doctor")(empty, NULL)
stopifnot(
  rrp_operation_succeeded(listed),
  identical(listed$value$installations, list()),
  rrp_operation_succeeded(current),
  identical(current$value$active, FALSE),
  identical(current$diagnostics[[1L]]$code, "active_software_not_selected"),
  rrp_operation_succeeded(doctor),
  identical(doctor$value$software_status, "blocked"),
  identical(doctor$diagnostics[[1L]]$code, "installed_software_absent")
)

shim <- file.path(empty, "rrp")
writeLines("#!/bin/sh", shim, useBytes = TRUE)
Sys.chmod(shim, mode = "0755", use_umask = FALSE)
dir.create(file.path(empty, "staging"))
missing <- internal("rrp_software_uninstall")(empty, valid_selector, shim)
stopifnot(
  !rrp_operation_succeeded(missing),
  identical(missing$operation_id, "rrp.software-uninstall"),
  identical(missing$diagnostics[[1L]]$code, "installed_software_not_found")
)

inventory_root <- tempfile("rrp-library-inventory-")
library_root <- file.path(inventory_root, "library")
dir.create(file.path(library_root, "Example", "assets"), recursive = TRUE)
writeLines("Package: Example\nVersion: 1.0.0",
  file.path(library_root, "Example", "DESCRIPTION"), useBytes = TRUE)
writeLines("asset", file.path(library_root, "Example", "assets", "app.js"),
  useBytes = TRUE)
writeLines("ordinary package filename", file.path(
  library_root, "Example", "assets", "credentials.js"
), useBytes = TRUE)
on.exit(unlink(inventory_root, recursive = TRUE, force = TRUE), add = TRUE)
paths <- internal("rrp_software_library_files")(library_root)
absolute <- file.path(library_root, paths)
digests <- internal("rrp_software_sha256_many")(absolute)
sizes <- sprintf("%.0f", file.info(absolute)$size)
installation_id <- paste(rep("c", 64L), collapse = "")
records <- c(list(c(
  "Record-Type" = "installed-library-inventory",
  "Inventory-Version" = "0.1.0",
  "Installation-ID" = installation_id,
  "File-Count" = as.character(length(paths))
)), lapply(seq_along(paths), function(index) c(
  "Record-Type" = "file", "Path" = paths[[index]],
  "Size" = sizes[[index]], "SHA256" = digests[[index]]
)))
inventory_path <- file.path(inventory_root, "library-inventory.dcf")
connection <- file(inventory_path, open = "wb")
for (index in seq_along(records)) {
  writeLines(paste0(names(records[[index]]), ": ", records[[index]]),
    connection, useBytes = TRUE)
  if (index < length(records)) writeLines("", connection, useBytes = TRUE)
}
close(connection)
inventory_record <- c(
  "Installation-ID" = installation_id,
  "Private-Library-Inventory-Path" = "library-inventory.dcf",
  "Private-Library-Inventory-Digest" =
    internal("rrp_software_sha256_many")(inventory_path)[[1L]]
)
stopifnot(identical(
  internal("rrp_software_verify_library_inventory")(
    inventory_root, inventory_record, TRUE
  ),
  invisible(length(paths))
))
write("tamper", absolute[[1L]], append = TRUE)
condition <- tryCatch({
  internal("rrp_software_verify_library_inventory")(
    inventory_root, inventory_record, TRUE
  )
  NULL
}, error = identity)
stopifnot(
  inherits(condition, "rrp_software_error"),
  identical(condition$code, "installed_library_integrity"),
  identical(
    internal("rrp_software_verify_library_inventory")(
      inventory_root, inventory_record, FALSE
    ),
    invisible(length(paths))
  )
)

legacy_root <- tempfile("rrp-legacy-installation-")
dir.create(legacy_root)
on.exit(unlink(legacy_root, recursive = TRUE, force = TRUE), add = TRUE)
legacy <- c(
  "Record-Type" = "rrp-installation",
  "Contract-ID" = "rrp.installation-record",
  "Contract-Version" = "0.1.0",
  "Installation-ID" = paste(rep("d", 64L), collapse = ""),
  "Product-ID" = "readmission-risk-pool-platform",
  "Product-Version" = "1.0.0-dev",
  "Development-Version" = "1.0.0-dev",
  "Distribution-ID" = paste(rep("e", 64L), collapse = ""),
  "Build-ID" = paste(rep("f", 64L), collapse = ""),
  "Dependency-Specification-ID" = paste(rep("1", 64L), collapse = ""),
  "Host-R-Executable" = file.path(R.home("bin"), "R"),
  "Host-R-Version" = as.character(getRversion()),
  "Platform" = R.version$platform,
  "Architecture" = R.version$arch,
  "Private-Library" = file.path(legacy_root, "library"),
  "Resource-Root" = legacy_root,
  "Distribution-Manifest-Digest" = paste(rep("2", 64L), collapse = ""),
  "Installed-At" = "2026-01-01T00:00:00Z"
)
write.dcf(matrix(unname(legacy), nrow = 1L,
  dimnames = list(NULL, names(legacy))),
file = file.path(legacy_root, "INSTALLATION.dcf"), width = 500L)
legacy_condition <- tryCatch({
  internal("rrp_software_record")(legacy_root)
  NULL
}, error = identity)
stopifnot(
  inherits(legacy_condition, "rrp_software_error"),
  identical(legacy_condition$code, "incomplete_library_integrity_evidence")
)
