library(rrpplatform)

arguments <- commandArgs(trailingOnly = TRUE)
software_root <- if (length(arguments) >= 1L) arguments[[1L]] else
  Sys.getenv("RRP_TEST_SOFTWARE_ROOT", unset = "")
stopifnot(nzchar(software_root), dir.exists(software_root))
software_root <- normalizePath(software_root, winslash = "/", mustWork = TRUE)
catalog <- rrp_open_resource_catalog(software_root)

definitions <- getFromNamespace(
  "rrp_lifecycle_contract_definitions", "rrpplatform"
)()
contracts <- getFromNamespace("rrp_lifecycle_contracts", "rrpplatform")(catalog)
stopifnot(
  identical(names(contracts), names(definitions)),
  all(vapply(names(definitions), function(name) {
    identical(unlist(contracts[[name]], use.names = TRUE),
      definitions[[name]]$expected)
  }, logical(1L)))
)

suite <- tempfile("rrp-lifecycle-contracts-")
dir.create(suite)
on.exit(unlink(suite, recursive = TRUE, force = TRUE), add = TRUE)

copy_software <- function(name) {
  parent <- file.path(suite, name)
  dir.create(parent)
  stopifnot(file.copy(
    software_root, parent, recursive = TRUE, copy.mode = FALSE,
    copy.date = FALSE
  ))
  file.path(parent, basename(software_root))
}

expect_resource_failure <- function(root, code) {
  result <- rrp_validate_software_resources(root)
  stopifnot(
    !rrp_operation_succeeded(result), identical(result$status, "failure"),
    is.null(result$value), length(result$diagnostics) == 1L,
    identical(result$diagnostics[[1L]]$code, code),
    identical(
      result$diagnostics[[1L]]$message,
      "Software resource validation failed."
    )
  )
}

drift <- copy_software("drift")
drift_path <- file.path(
  drift, "resources", "contracts", "lifecycle", "activation-record.dcf"
)
drift_lines <- readLines(drift_path, warn = FALSE, encoding = "UTF-8")
drift_lines <- sub(
  "^Project-Association: prohibited$",
  "Project-Association: allowed", drift_lines
)
writeLines(drift_lines, drift_path, useBytes = TRUE)
expect_resource_failure(drift, "unsupported_lifecycle_contract")

extra <- copy_software("extra-field")
extra_path <- file.path(
  extra, "resources", "contracts", "lifecycle", "cli-result-json.dcf"
)
write("Unexpected-Field: prohibited", extra_path, append = TRUE)
expect_resource_failure(extra, "invalid_lifecycle_contract_fields")

missing <- copy_software("missing")
unlink(file.path(
  missing, "resources", "contracts", "lifecycle", "installation-record.dcf"
))
expect_resource_failure(missing, "missing_resource")
