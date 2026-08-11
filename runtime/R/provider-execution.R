rrp_raw_provider_output_issues <- function(output, request, state) {
  issues <- list()
  if (!is.list(output) || !identical(output$status, "success") ||
      !is.list(output$outputs)) {
    return(list(rrp_runtime_issue(
      "provider.output.structure", "malformed_provider_output",
      "Provider success output must contain an outputs collection.", "$"
    )))
  }
  if (length(output$outputs) != 1L) {
    issues[[length(issues) + 1L]] <- rrp_runtime_issue(
      "provider.output.cardinality", "invalid_provider_output_cardinality",
      "Successful provider output must contain exactly one result.",
      "$.outputs"
    )
    return(issues)
  }
  value <- output$outputs[[1L]]
  required <- c(
    "request_id", "state_id", "episode_id", "estimand_specification",
    "target_interval_start", "target_interval_end", "interval_boundary",
    "output_type", "estimate_value", "provenance_references"
  )
  missing <- required[!required %in% names(value)]
  if (length(missing) > 0L) {
    issues[[length(issues) + 1L]] <- rrp_runtime_issue(
      "provider.output.required", "missing_provider_output_field",
      paste0("Provider output fields are missing: ", paste(missing, collapse = ", "), "."),
      "$.outputs[1]"
    )
    return(issues)
  }
  identity_ok <- identical(value$request_id, request$request_id) &&
    identical(value$state_id, state$state_id) &&
    identical(value$episode_id, request$episode_id) &&
    identical(value$estimand_specification, request$estimand_specification)
  if (!identity_ok) {
    issues[[length(issues) + 1L]] <- rrp_runtime_issue(
      "provider.output.identity", "provider_output_identity_mismatch",
      "Provider output request/state/episode/estimand identities do not match.",
      "$.outputs[1]"
    )
  }
  interval_ok <- identical(value$target_interval_start, request$target_interval_start) &&
    identical(value$target_interval_end, request$target_interval_end) &&
    identical(value$interval_boundary, request$interval_boundary)
  if (!interval_ok) {
    issues[[length(issues) + 1L]] <- rrp_runtime_issue(
      "provider.output.interval", "provider_output_interval_mismatch",
      "Provider output interval does not match the estimand request.",
      "$.outputs[1]"
    )
  }
  value_ok <- identical(value$output_type, "probability") &&
    is.numeric(value$estimate_value) && length(value$estimate_value) == 1L &&
    is.finite(value$estimate_value) && value$estimate_value >= 0 &&
    value$estimate_value <= 1
  if (!value_ok) {
    issues[[length(issues) + 1L]] <- rrp_runtime_issue(
      "provider.output.value", "invalid_provider_probability",
      "Provider output must be one finite probability in [0,1].",
      "$.outputs[1].estimate_value"
    )
  }
  issues
}

rrp_execution_result_id <- function(
  provider_execution_run_id,
  request,
  provider
) {
  rrp_deterministic_id(
    "provider_execution",
    provider_execution_run_id,
    request$request_id,
    request$state_reference$state_id,
    request$estimand_specification$specification_id,
    request$estimand_specification$specification_version,
    provider$provider_id,
    provider$provider_version,
    provider$implementation$implementation_version,
    request$target_interval_start,
    request$target_interval_end
  )
}

rrp_provider_execution_result <- function(
  status,
  execution_result_id,
  provider_execution_run_id,
  request,
  provider,
  execution_result_contract,
  failure_code = NULL,
  message = "",
  estimate = NULL,
  issues = rrp_runtime_empty_issues()
) {
  structure(list(
    execution_result_id = execution_result_id,
    execution_result_specification = rrp_identity(
      execution_result_contract$specification_kind,
      execution_result_contract$specification_id,
      execution_result_contract$specification_version
    ),
    provider_execution_run_id = provider_execution_run_id,
    request_id = request$request_id,
    state_id = request$state_reference$state_id,
    episode_id = request$episode_id,
    estimand_specification = request$estimand_specification,
    provider_reference = rrp_provider_reference(provider),
    execution_status = status,
    failure_code = failure_code,
    message = message,
    estimate_record = estimate,
    issues = issues
  ), class = "rrp_provider_execution_result")
}

#' Execute one request through an exact registered provider
#' @export
execute_provider <- function(
  registry,
  provider_id,
  provider_version,
  request,
  state,
  provider_execution_run_id,
  runtime_contracts,
  provider_contracts
) {
  rrp_assert_runtime_conforms(
    validate_provider_contracts(provider_contracts), "Provider contracts"
  )
  if (!rrp_is_scalar_string(provider_execution_run_id)) {
    stop("Provider execution requires one non-empty run ID.", call. = FALSE)
  }
  entry <- resolve_provider(registry, provider_id, provider_version)
  provider <- entry$specification
  result_id <- rrp_execution_result_id(
    provider_execution_run_id, request, provider
  )
  compatibility <- validate_provider_compatibility(
    provider, request, state, runtime_contracts
  )
  if (!runtime_conforms(compatibility)) {
    issues <- compatibility$issues
    return(rrp_provider_execution_result(
      compatibility$compatibility_status,
      result_id,
      provider_execution_run_id,
      request,
      provider,
      provider_contracts$execution_result,
      failure_code = issues$issue_code[[1L]],
      message = paste(unique(issues$message), collapse = " "),
      issues = issues
    ))
  }
  state_before <- unserialize(serialize(state, NULL))
  attempted <- tryCatch(
    entry$adapter(
      request = unserialize(serialize(request, NULL)),
      state = unserialize(serialize(state, NULL)),
      provider_specification = unserialize(serialize(provider, NULL))
    ),
    error = function(condition) condition
  )
  if (inherits(attempted, "condition")) {
    issues <- rrp_runtime_issue(
      "provider.execution.adapter", "provider_execution_error",
      conditionMessage(attempted), "$.provider_adapter"
    )
    return(rrp_provider_execution_result(
      "execution_failure", result_id, provider_execution_run_id,
      request, provider, provider_contracts$execution_result,
      failure_code = "provider_execution_error",
      message = "Provider adapter failed during execution.", issues = issues
    ))
  }
  if (!identical(state, state_before)) {
    issues <- rrp_runtime_issue(
      "provider.execution.state", "provider_mutated_state",
      "Provider execution altered runtime-owned state.", "$.state"
    )
    return(rrp_provider_execution_result(
      "invalid_output", result_id, provider_execution_run_id,
      request, provider, provider_contracts$execution_result,
      failure_code = "provider_mutated_state",
      message = "Provider violated state immutability.", issues = issues
    ))
  }
  output_issues <- rrp_runtime_bind_issues(
    rrp_raw_provider_output_issues(attempted, request, state)
  )
  if (nrow(output_issues) > 0L) {
    return(rrp_provider_execution_result(
      "invalid_output", result_id, provider_execution_run_id,
      request, provider, provider_contracts$execution_result,
      failure_code = output_issues$issue_code[[1L]],
      message = "Provider returned nonconforming output.", issues = output_issues
    ))
  }
  estimate <- rrp_build_estimate_record(
    attempted$outputs[[1L]], request, state, provider,
    provider_execution_run_id, result_id, provider_contracts$estimate
  )
  estimate_conformance <- validate_estimate_record(
    estimate, request, state, provider, provider_contracts$estimate
  )
  if (!runtime_conforms(estimate_conformance)) {
    return(rrp_provider_execution_result(
      "invalid_output", result_id, provider_execution_run_id,
      request, provider, provider_contracts$execution_result,
      failure_code = estimate_conformance$issues$issue_code[[1L]],
      message = "Standardized estimate failed conformance.",
      issues = estimate_conformance$issues
    ))
  }
  rrp_provider_execution_result(
    "successful_estimate", result_id, provider_execution_run_id,
    request, provider, provider_contracts$execution_result,
    message = "One conforming estimate was produced.", estimate = estimate
  )
}

