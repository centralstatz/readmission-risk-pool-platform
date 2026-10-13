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
  "Distribution-ID" = paste(rep("a", 64L), collapse = "")
)
verified <- list(
  record = record, selector = valid_selector, activation_status = "inactive"
)
diagnosis <- internal("rrp_software_diagnosis_value")(verified)
stopifnot(
  identical(names(diagnosis), strsplit(
    internal("rrp_installed_diagnosis_contract_expected")()[["Value-Fields"]],
    ",", fixed = TRUE
  )[[1L]]),
  identical(diagnosis$software_status, "ready"),
  identical(diagnosis$activation_status, "inactive"),
  length(diagnosis$checks) == 6L
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
