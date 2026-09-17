rrp_producer_failure_messages <- function() {
  c(
    invalid_as_of_time = "Producer as-of time is invalid.",
    producer_unavailable = "Selected producer reported a controlled failure.",
    producer_source_failed = "Selected producer reported a controlled failure.",
    producer_mapping_failed = "Selected producer reported a controlled failure.",
    producer_execution_failed = "Selected producer execution failed.",
    invalid_producer_result = "Producer result validation failed."
  )
}

rrp_producer_abort <- function(code) {
  messages <- rrp_producer_failure_messages()
  if (!is.character(code) || length(code) != 1L || is.na(code) ||
      !code %in% names(messages)) {
    stop("Invalid internal producer-error definition.", call. = FALSE)
  }
  stop(structure(
    list(message = unname(messages[[code]]), call = NULL, code = code),
    class = c("rrp_producer_error", "error", "condition")
  ))
}

rrp_producer_scalar_string <- function(value) {
  is.character(value) && length(value) == 1L && !is.na(value) &&
    nzchar(value) && identical(value, trimws(value)) && is.null(attributes(value))
}

rrp_producer_timestamp_number <- function(value) {
  if (!rrp_producer_scalar_string(value) || !grepl(
    paste0(
      "^[0-9]{4}-[0-9]{2}-[0-9]{2}T",
      "(?:[01][0-9]|2[0-3]):[0-5][0-9]:[0-5][0-9]",
      "(?:[.][0-9]+)?(?:Z|[+-](?:[01][0-9]|2[0-3]):[0-5][0-9])$"
    ),
    value, perl = TRUE
  )) return(NA_real_)
  normalized <- sub("Z$", "+0000", value)
  normalized <- sub(
    "([+-][0-9]{2}):([0-9]{2})$", "\\1\\2", normalized, perl = TRUE
  )
  parsed <- suppressWarnings(strptime(
    normalized, format = "%Y-%m-%dT%H:%M:%OS%z", tz = "UTC"
  ))
  if (length(parsed) != 1L || is.na(parsed)) return(NA_real_)
  as.numeric(as.POSIXct(parsed, tz = "UTC"))
}

rrp_producer_split_fields <- function(value) {
  strsplit(value, ",", fixed = TRUE)[[1L]]
}

rrp_producer_plain_named_list <- function(value, fields) {
  is.list(value) && !is.object(value) &&
    identical(names(attributes(value)), "names") &&
    identical(names(value), fields)
}

rrp_producer_has_unsafe_value <- function(value) {
  if (is.function(value) || is.environment(value) ||
      typeof(value) %in% c(
        "externalptr", "weakref", "closure", "builtin", "special",
        "language", "symbol", "promise"
      ) || inherits(value, "connection")) return(TRUE)
  if (!is.list(value)) return(FALSE)
  any(vapply(value, rrp_producer_has_unsafe_value, logical(1L)))
}

rrp_producer_request <- function(context, producer_contract, as_of_time) {
  fields <- rrp_producer_split_fields(producer_contract[["Request-Fields"]])
  request <- list(
    producer_api_id = producer_contract[["Producer-API-ID"]],
    producer_api_version = producer_contract[["Producer-API-Version"]],
    project_id = context$manifest[["Project-ID"]],
    project_version = context$manifest[["Project-Version"]],
    producer_id = context$producer$component_id,
    producer_version = context$producer$component_version,
    canonical_bundle_id = producer_contract[["Canonical-Bundle-ID"]],
    canonical_bundle_version = producer_contract[["Canonical-Bundle-Version"]],
    canonical_profile_id = context$canonical_profile$profile_id,
    canonical_profile_version = context$canonical_profile$profile_version,
    as_of_time = as_of_time
  )
  if (!rrp_producer_plain_named_list(request, fields)) {
    stop("Invalid internal producer-request construction.", call. = FALSE)
  }
  request
}

rrp_producer_invoke <- function(context, request) {
  previous_directory <- getwd()
  on.exit({
    current_directory <- getwd()
    if (!identical(current_directory, previous_directory)) {
      setwd(previous_directory)
    }
  }, add = TRUE)

  outcome <- rrp_project_with_libraries(
    context$extension_library_path,
    function() tryCatch(
      list(returned = TRUE, value = context$producer$callable(request)),
      error = function(condition) list(returned = FALSE, value = NULL)
    )
  )
  if (!identical(outcome$returned, TRUE)) {
    rrp_producer_abort("producer_execution_failed")
  }
  outcome$value
}

rrp_producer_validate_result <- function(
  result,
  context,
  producer_contract,
  request
) {
  fields <- rrp_producer_split_fields(producer_contract[["Result-Fields"]])
  if (!rrp_producer_plain_named_list(result, fields) ||
      rrp_producer_has_unsafe_value(result)) {
    rrp_producer_abort("invalid_producer_result")
  }

  statuses <- rrp_producer_split_fields(
    producer_contract[["Result-Status-Values"]]
  )
  if (!rrp_producer_scalar_string(result$status) ||
      !result$status %in% statuses) {
    rrp_producer_abort("invalid_producer_result")
  }

  expected <- list(
    producer_contract_id = producer_contract[["Specification-ID"]],
    producer_contract_version = producer_contract[["Specification-Version"]],
    producer_id = context$producer$component_id,
    producer_version = context$producer$component_version,
    implementation_id = context$producer$implementation_id,
    implementation_version = context$producer$implementation_version,
    mapping_id = context$producer$mapping_id,
    mapping_version = context$producer$mapping_version,
    canonical_profile_id = context$producer$canonical_profile_id,
    canonical_profile_version = context$producer$canonical_profile_version,
    canonical_as_of_time = request$as_of_time,
    capabilities = context$producer$capabilities
  )
  if (any(!vapply(names(expected), function(field) {
    identical(result[[field]], expected[[field]])
  }, logical(1L)))) {
    rrp_producer_abort("invalid_producer_result")
  }

  if (identical(result$status, "succeeded")) {
    if (is.null(result$candidate_bundle) || !is.null(result$failure_code)) {
      rrp_producer_abort("invalid_producer_result")
    }
    return(result$candidate_bundle)
  }

  supported_failures <- rrp_producer_split_fields(
    producer_contract[["Failure-Codes"]]
  )
  if (!is.null(result$candidate_bundle) ||
      !rrp_producer_scalar_string(result$failure_code) ||
      !result$failure_code %in% supported_failures) {
    rrp_producer_abort("invalid_producer_result")
  }
  rrp_producer_abort(result$failure_code)
}

rrp_producer_expected_context <- function(
  context,
  canonical_contracts,
  request
) {
  rrp_canonical_admission_context(
    canonical_contracts = canonical_contracts,
    project_id = request$project_id,
    project_version = request$project_version,
    producer_id = request$producer_id,
    producer_version = request$producer_version,
    implementation_id = context$producer$implementation_id,
    implementation_version = context$producer$implementation_version,
    mapping_id = context$producer$mapping_id,
    mapping_version = context$producer$mapping_version,
    as_of_time = request$as_of_time
  )
}

rrp_producer_operation_failure <- function(condition) {
  message <- if (inherits(condition, "rrp_project_error")) {
    "RRP project loading failed."
  } else if (inherits(condition, "rrp_canonical_error")) {
    "Canonical admission failed."
  } else {
    condition$message
  }
  diagnostic <- rrp_new_diagnostic(
    code = condition$code,
    severity = "error",
    message = message
  )
  rrp_new_operation_result(
    operation_id = "rrp.execute-producer",
    status = "failure",
    value = NULL,
    diagnostics = list(diagnostic)
  )
}

rrp_producer_execute <- function(software_catalog, project_root, as_of_time) {
  if (is.na(rrp_producer_timestamp_number(as_of_time))) {
    rrp_producer_abort("invalid_as_of_time")
  }

  context <- rrp_load_project(software_catalog, project_root)
  canonical_contracts <- rrp_canonical_contracts(context$software_catalog)
  producer_contract <- canonical_contracts$canonical_producer
  request <- rrp_producer_request(context, producer_contract, as_of_time)
  producer_result <- rrp_producer_invoke(context, request)
  candidate <- rrp_producer_validate_result(
    producer_result, context, producer_contract, request
  )
  expected_context <- rrp_producer_expected_context(
    context, canonical_contracts, request
  )
  admitted <- rrpruntime::rrp_admit_canonical_bundle(
    candidate, expected_context
  )
  rrp_new_operation_result(
    operation_id = "rrp.execute-producer",
    status = "success",
    value = admitted,
    diagnostics = list()
  )
}

#' Execute the producer selected by an explicit RRP project
#'
#' Load one explicit project through the authoritative loader, construct the
#' closed RRP producer request, invoke the exact selected producer once, and
#' admit its successful candidate through `rrpruntime`. The trusted producer
#' may use project-owned source behavior captured during registration; this
#' operation passes it no project path or source configuration.
#'
#' @param software_catalog A validated `rrp_resource_catalog` returned by
#'   [rrp_open_resource_catalog()].
#' @param project_root One explicit existing independent project directory.
#' @param as_of_time One RFC 3339 timestamp with an explicit offset.
#' @return One validated `rrp_operation_result`. On success, `value` is an
#'   `rrp_admitted_canonical_bundle`; expected project, producer, and canonical
#'   failures return one bounded error diagnostic.
#' @export
rrp_execute_producer <- function(software_catalog, project_root, as_of_time) {
  tryCatch(
    rrp_producer_execute(software_catalog, project_root, as_of_time),
    rrp_project_error = rrp_producer_operation_failure,
    rrp_producer_error = rrp_producer_operation_failure,
    rrp_canonical_error = rrp_producer_operation_failure
  )
}
