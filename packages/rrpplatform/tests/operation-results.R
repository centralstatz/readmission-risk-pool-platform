library(rrpplatform)

rrp_test_internal <- function(name) {
  get(name, envir = asNamespace("rrpplatform"), inherits = FALSE)
}

rrp_test_new_diagnostic <- rrp_test_internal("rrp_new_diagnostic")
rrp_test_validate_diagnostic <- rrp_test_internal("rrp_validate_diagnostic")
rrp_test_new_result <- rrp_test_internal("rrp_new_operation_result")
rrp_test_validate_result <- rrp_test_internal("rrp_validate_operation_result")

rrp_test_expect_contract_error <- function(callback) {
  condition <- tryCatch({
    callback()
    NULL
  }, error = identity)
  stopifnot(
    !is.null(condition),
    identical(condition$call, NULL),
    conditionMessage(condition) %in% c(
      "Invalid RRP diagnostic.", "Invalid RRP operation result."
    )
  )
  invisible(condition)
}

rrp_test_write_records <- function(records, path) {
  lines <- unlist(lapply(seq_along(records), function(index) {
    record <- records[[index]]
    fields <- paste0(names(record), ": ", unlist(record, use.names = FALSE))
    if (index < length(records)) c(fields, "") else fields
  }), use.names = FALSE)
  writeLines(lines, path, useBytes = TRUE)
}

rrp_test_operation_fixture <- function() {
  root <- tempfile("rrp-operation-result-")
  dir.create(file.path(root, "resources", "contracts"), recursive = TRUE)
  schema <- rrp_test_internal("rrp_resource_schema_contract")()
  writeLines(
    paste0(names(schema), ": ", unname(schema)),
    file.path(root, "resources", "resource-catalog-schema.dcf"),
    useBytes = TRUE
  )
  entries <- list(
    list(
      "Record-Type" = "resource",
      "Resource-ID" = "rrp.contract.resource-catalog",
      "Resource-Class" = "contract",
      "Owner-Package" = "rrpplatform",
      "Installed-Path" = "resources/resource-catalog-schema.dcf",
      "Format" = "dcf"
    ),
    list(
      "Record-Type" = "resource",
      "Resource-ID" = "rrp.contract.diagnostic",
      "Resource-Class" = "contract",
      "Owner-Package" = "rrpplatform",
      "Installed-Path" = "resources/contracts/diagnostic.dcf",
      "Format" = "dcf"
    ),
    list(
      "Record-Type" = "resource",
      "Resource-ID" = "rrp.contract.operation-result",
      "Resource-Class" = "contract",
      "Owner-Package" = "rrpplatform",
      "Installed-Path" = "resources/contracts/operation-result.dcf",
      "Format" = "dcf"
    )
  )
  header <- list(
    "Record-Type" = "catalog",
    "Catalog-ID" = "rrp.software-resources",
    "Catalog-Version" = "0.1.0",
    "Format-Version" = "1.0.0",
    "Product-ID" = "readmission-risk-pool-platform",
    "Development-Version" = "1.0.0-dev",
    "Status" = "development_unpublished"
  )
  rrp_test_write_records(
    c(list(header), entries),
    file.path(root, "resources", "resource-catalog.dcf")
  )
  writeLines(
    "Record-Type: contract",
    file.path(root, "resources", "contracts", "diagnostic.dcf"),
    useBytes = TRUE
  )
  writeLines(
    "Record-Type: contract",
    file.path(root, "resources", "contracts", "operation-result.dcf"),
    useBytes = TRUE
  )
  root
}

rrp_test_with_operation_fixture <- function(callback) {
  root <- rrp_test_operation_fixture()
  on.exit(unlink(root, recursive = TRUE, force = TRUE), add = TRUE)
  callback(root)
}

rrp_test_expect_failed_validation <- function(root, expected_code, forbidden) {
  result <- rrp_validate_software_resources(root)
  stopifnot(
    identical(class(result), c("rrp_operation_result", "list")),
    identical(names(result), c(
      "operation_id", "status", "value", "diagnostics"
    )),
    identical(result$operation_id, "rrp.validate-software-resources"),
    identical(result$status, "failure"),
    is.null(result$value),
    length(result$diagnostics) == 1L,
    identical(result$diagnostics[[1L]]$code, expected_code),
    identical(result$diagnostics[[1L]]$severity, "error"),
    identical(
      result$diagnostics[[1L]]$message,
      "Software resource validation failed."
    ),
    identical(rrp_operation_succeeded(result), FALSE)
  )
  rrp_test_validate_diagnostic(result$diagnostics[[1L]])
  rrp_test_validate_result(result)
  for (text in forbidden[nzchar(forbidden)]) {
    stopifnot(!grepl(text, result$diagnostics[[1L]]$message, fixed = TRUE))
  }
  invisible(result)
}

rrp_test_cases <- list(
  "diagnostic exact shape and accepted values" = function() {
    diagnostic <- rrp_test_new_diagnostic(
      "catalog_valid", "info", "Software resources are valid."
    )
    stopifnot(
      identical(class(diagnostic), c("rrp_diagnostic", "list")),
      identical(names(diagnostic), c("code", "severity", "message")),
      identical(diagnostic$code, "catalog_valid"),
      identical(diagnostic$severity, "info"),
      identical(diagnostic$message, "Software resources are valid.")
    )
    rrp_test_validate_diagnostic(diagnostic)
    for (severity in c("info", "warning", "error")) {
      rrp_test_validate_diagnostic(rrp_test_new_diagnostic(
        "accepted_code", severity, "Maintainer-authored diagnostic."
      ))
    }
  },
  "diagnostic code severity and message bounds" = function() {
    for (code in list("", "Uppercase", "hyphen-code", "1code", NA_character_)) {
      rrp_test_expect_contract_error(function() {
        rrp_test_new_diagnostic(code, "info", "Bounded message.")
      })
    }
    rrp_test_expect_contract_error(function() {
      rrp_test_new_diagnostic(paste(rep("a", 65L), collapse = ""), "info", "Bounded message.")
    })
    for (severity in list("debug", "fatal", "", NA_character_)) {
      rrp_test_expect_contract_error(function() {
        rrp_test_new_diagnostic("valid_code", severity, "Bounded message.")
      })
    }
    for (message in list(
      "", " leading text", "trailing text ", "multiple\nlines", "tab\ttext",
      paste(rep("m", 241L), collapse = ""), NA_character_
    )) {
      rrp_test_expect_contract_error(function() {
        rrp_test_new_diagnostic("valid_code", "info", message)
      })
    }
  },
  "diagnostic sensitive and path-like text rejection" = function() {
    unsafe <- c(
      "patient_id=fictional-1", "MRN: fictional", "password=fictional",
      "Bearer fictional", "access token fictional", "api key fictional",
      "connection string supplied", "server=fictional", "raw input copied",
      "private key supplied", "/tmp/rrp", "C:\\private\\rrp", "~/rrp"
    )
    for (message in unsafe) {
      rrp_test_expect_contract_error(function() {
        rrp_test_new_diagnostic("unsafe_message", "error", message)
      })
    }
  },
  "diagnostic malformed and extra fields" = function() {
    diagnostic <- rrp_test_new_diagnostic("valid_code", "warning", "Safe warning.")
    malformed <- unclass(diagnostic)
    rrp_test_expect_contract_error(function() rrp_test_validate_diagnostic(malformed))
    malformed <- diagnostic
    malformed$context <- list(arbitrary = "detail")
    rrp_test_expect_contract_error(function() rrp_test_validate_diagnostic(malformed))
    malformed <- diagnostic[c("severity", "code", "message")]
    class(malformed) <- c("rrp_diagnostic", "list")
    rrp_test_expect_contract_error(function() rrp_test_validate_diagnostic(malformed))
  },
  "operation result exact shape status and ordered diagnostics" = function() {
    info <- rrp_test_new_diagnostic("first", "info", "First diagnostic.")
    warning <- rrp_test_new_diagnostic("second", "warning", "Second diagnostic.")
    result <- rrp_test_new_result(
      "rrp.example-operation", "success", list(answer = 1L),
      list(info, warning)
    )
    stopifnot(
      identical(class(result), c("rrp_operation_result", "list")),
      identical(names(result), c(
        "operation_id", "status", "value", "diagnostics"
      )),
      identical(result$operation_id, "rrp.example-operation"),
      identical(result$status, "success"),
      identical(vapply(result$diagnostics, `[[`, character(1L), "code"), c(
        "first", "second"
      )),
      identical(rrp_operation_succeeded(result), TRUE),
      is.logical(rrp_operation_succeeded(result)),
      length(rrp_operation_succeeded(result)) == 1L
    )
  },
  "operation success and failure invariants" = function() {
    success <- rrp_test_new_result("rrp.example", "success")
    warning <- rrp_test_new_diagnostic("warning_code", "warning", "Safe warning.")
    with_warning <- rrp_test_new_result(
      "rrp.example", "success", value = 2L, diagnostics = list(warning)
    )
    error <- rrp_test_new_diagnostic("error_code", "error", "Safe failure.")
    failure <- rrp_test_new_result(
      "rrp.example", "failure", value = NULL, diagnostics = list(error)
    )
    stopifnot(
      length(success$diagnostics) == 0L,
      identical(with_warning$value, 2L),
      identical(rrp_operation_succeeded(success), TRUE),
      identical(rrp_operation_succeeded(failure), FALSE)
    )
    rrp_test_expect_contract_error(function() {
      rrp_test_new_result("rrp.example", "success", diagnostics = list(error))
    })
    rrp_test_expect_contract_error(function() {
      rrp_test_new_result("rrp.example", "failure", diagnostics = list(warning))
    })
    rrp_test_expect_contract_error(function() {
      rrp_test_new_result("rrp.example", "failure", value = 1L, diagnostics = list(error))
    })
  },
  "operation result rejects malformed objects" = function() {
    error <- rrp_test_new_diagnostic("error_code", "error", "Safe failure.")
    valid <- rrp_test_new_result("rrp.example", "failure", diagnostics = list(error))
    malformed <- unclass(valid)
    rrp_test_expect_contract_error(function() rrp_operation_succeeded(malformed))
    malformed <- valid
    malformed$extra <- "not allowed"
    rrp_test_expect_contract_error(function() rrp_operation_succeeded(malformed))
    malformed <- valid
    malformed$diagnostics <- list(named = error)
    rrp_test_expect_contract_error(function() rrp_operation_succeeded(malformed))
    malformed <- valid
    malformed$operation_id <- "analytical-run::123"
    rrp_test_expect_contract_error(function() rrp_operation_succeeded(malformed))
    malformed <- valid
    malformed$status <- "succeeded"
    rrp_test_expect_contract_error(function() rrp_operation_succeeded(malformed))
  },
  "valid copied root returns successful result" = function() {
    rrp_test_with_operation_fixture(function(root) {
      unrelated <- tempfile("rrp-unrelated-")
      dir.create(unrelated)
      on.exit(unlink(unrelated, recursive = TRUE, force = TRUE), add = TRUE)
      old <- setwd(unrelated)
      on.exit(setwd(old), add = TRUE)
      result <- rrp_validate_software_resources(root)
      stopifnot(
        identical(result$operation_id, "rrp.validate-software-resources"),
        identical(result$status, "success"),
        identical(result$value, list(
          catalog_id = "rrp.software-resources",
          catalog_version = "0.1.0",
          resource_count = 3L
        )),
        identical(result$diagnostics, list()),
        identical(rrp_operation_succeeded(result), TRUE)
      )
      rrp_test_validate_result(result)
    })
  },
  "resource failures translate safely without throwing" = function() {
    missing <- tempfile("rrp-missing-root-")
    rrp_test_expect_failed_validation(
      missing, "missing_software_root", c(missing, "patient_id", "password")
    )
    rrp_test_with_operation_fixture(function(root) {
      schema <- file.path(root, "resources", "resource-catalog-schema.dcf")
      unlink(schema)
      rrp_test_expect_failed_validation(
        root, "missing_schema", c(root, schema, "patient_id", "password")
      )
    })
    rrp_test_with_operation_fixture(function(root) {
      catalog <- file.path(root, "resources", "resource-catalog.dcf")
      lines <- readLines(catalog, warn = FALSE, encoding = "UTF-8")
      lines <- append(
        lines, c("Patient-ID: fictional", "Path: /private/value"), after = 7L
      )
      writeLines(lines, catalog, useBytes = TRUE)
      rrp_test_expect_failed_validation(
        root, "invalid_catalog_fields",
        c(root, catalog, "fictional", "Patient-ID", "/private/value")
      )
    })
  }
)

for (case_name in names(rrp_test_cases)) {
  rrp_test_cases[[case_name]]()
  cat("PASS ", case_name, "\n", sep = "")
}
