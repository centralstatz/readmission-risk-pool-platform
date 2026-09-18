rrp_operation_contract_abort <- function(message) {
  stop(message, call. = FALSE)
}

rrp_diagnostic_code_is_valid <- function(code) {
  is.character(code) && length(code) == 1L && !is.na(code) &&
    nchar(code, type = "bytes") <= 64L &&
    grepl("^[a-z][a-z0-9_]*$", code)
}

rrp_diagnostic_message_is_safe <- function(message) {
  if (!is.character(message) || length(message) != 1L || is.na(message) ||
      !nzchar(message) || !identical(message, trimws(message)) ||
      nchar(message, type = "bytes") > 240L ||
      grepl("[[:cntrl:]]", message)) {
    return(FALSE)
  }

  sensitive <- paste0(
    "patient[ _-]?(?:id|identifier|name)|medical[ _-]?record|mrn|",
    "credential|password|passwd|secret|authorization|bearer|",
    "access[ _-]?(?:token|key)|api[ _-]?key|private[ _-]?key|",
    "connection[ _-]?string|jdbc|raw[ _-]?(?:input|content|record|payload)|",
    "(?:server|host|database|uid|user[ _-]?id)[[:space:]]*="
  )
  if (grepl(sensitive, message, ignore.case = TRUE, perl = TRUE)) {
    return(FALSE)
  }

  path_like <- paste0(
    "[/\\\\]|[A-Za-z]:[/\\\\]|",
    "(^|[[:space:]])~(?:[/\\\\]|$)|",
    "(^|[[:space:]])[.]{1,2}[/\\\\]"
  )
  !grepl(path_like, message, perl = TRUE)
}

rrp_validate_diagnostic <- function(diagnostic) {
  fields <- c("code", "severity", "message")
  valid_shape <- is.list(diagnostic) &&
    identical(class(diagnostic), c("rrp_diagnostic", "list")) &&
    identical(names(diagnostic), fields)
  if (!valid_shape ||
      !rrp_diagnostic_code_is_valid(diagnostic$code) ||
      !is.character(diagnostic$severity) ||
      length(diagnostic$severity) != 1L || is.na(diagnostic$severity) ||
      !diagnostic$severity %in% c("info", "warning", "error") ||
      !rrp_diagnostic_message_is_safe(diagnostic$message)) {
    rrp_operation_contract_abort("Invalid RRP diagnostic.")
  }
  invisible(diagnostic)
}

rrp_new_diagnostic <- function(code, severity, message) {
  diagnostic <- structure(
    list(code = code, severity = severity, message = message),
    class = c("rrp_diagnostic", "list")
  )
  rrp_validate_diagnostic(diagnostic)
  diagnostic
}

rrp_operation_id_is_valid <- function(operation_id) {
  is.character(operation_id) && length(operation_id) == 1L &&
    !is.na(operation_id) && nchar(operation_id, type = "bytes") <= 96L &&
    grepl("^rrp[.][a-z0-9]+(?:[.-][a-z0-9]+)*$", operation_id, perl = TRUE)
}

rrp_validate_operation_result <- function(result) {
  fields <- c("operation_id", "status", "value", "diagnostics")
  valid_shape <- is.list(result) &&
    identical(class(result), c("rrp_operation_result", "list")) &&
    identical(names(result), fields)
  if (!valid_shape || !rrp_operation_id_is_valid(result$operation_id) ||
      !is.character(result$status) || length(result$status) != 1L ||
      is.na(result$status) || !result$status %in% c("success", "failure") ||
      !is.list(result$diagnostics) || !is.null(names(result$diagnostics))) {
    rrp_operation_contract_abort("Invalid RRP operation result.")
  }

  for (diagnostic in result$diagnostics) {
    tryCatch(
      rrp_validate_diagnostic(diagnostic),
      error = function(condition) {
        rrp_operation_contract_abort("Invalid RRP operation result.")
      }
    )
  }
  severities <- vapply(
    result$diagnostics, `[[`, character(1L), "severity"
  )
  has_error <- any(severities == "error")
  if (identical(result$status, "success") && has_error) {
    rrp_operation_contract_abort("Invalid RRP operation result.")
  }
  if (identical(result$status, "failure") &&
      (!has_error || !is.null(result$value))) {
    rrp_operation_contract_abort("Invalid RRP operation result.")
  }
  invisible(result)
}

rrp_new_operation_result <- function(
  operation_id,
  status,
  value = NULL,
  diagnostics = list()
) {
  result <- structure(
    list(
      operation_id = operation_id,
      status = status,
      value = value,
      diagnostics = diagnostics
    ),
    class = c("rrp_operation_result", "list")
  )
  rrp_validate_operation_result(result)
  result
}

#' Test whether an RRP operation succeeded
#'
#' Validate one common RRP operation result and return its machine-readable
#' success state. Malformed result-like objects are rejected.
#'
#' @param result One valid `rrp_operation_result`.
#' @return One non-missing logical value.
#' @export
rrp_operation_succeeded <- function(result) {
  rrp_validate_operation_result(result)
  identical(result$status, "success")
}

rrp_resource_failure_result <- function(condition) {
  diagnostic <- rrp_new_diagnostic(
    code = condition$code,
    severity = "error",
    message = "Software resource validation failed."
  )
  rrp_new_operation_result(
    operation_id = "rrp.validate-software-resources",
    status = "failure",
    value = NULL,
    diagnostics = list(diagnostic)
  )
}

#' Validate installed RRP software resources
#'
#' Validate the existing installed resource boundary beneath one explicit
#' caller-supplied software root and return a common structured result.
#'
#' @param software_root One explicit distribution-shaped software root.
#' @return One validated `rrp_operation_result`.
#' @export
rrp_validate_software_resources <- function(software_root) {
  tryCatch({
    catalog <- rrp_open_resource_catalog(software_root)
    canonical_contracts <- rrp_canonical_contracts(catalog)
    rrp_runtime_contracts(catalog, canonical_contracts)
    rrp_project_manifest_contract(catalog)
    rrp_project_registration_contract(catalog)
    header <- catalog$catalog$header
    value <- list(
      catalog_id = header[["Catalog-ID"]],
      catalog_version = header[["Catalog-Version"]],
      resource_count = as.integer(length(catalog$catalog$entries))
    )
    rrp_new_operation_result(
      operation_id = "rrp.validate-software-resources",
      status = "success",
      value = value,
      diagnostics = list()
    )
  }, rrp_resource_error = rrp_resource_failure_result)
}
