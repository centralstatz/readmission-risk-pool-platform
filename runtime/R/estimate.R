rrp_estimate_identity <- function(record) {
  model_identity <- if (is.null(record$model_reference)) {
    "no_separate_model"
  } else {
    paste(
      record$model_reference$model_id,
      record$model_reference$model_version,
      sep = "@"
    )
  }
  rrp_deterministic_id(
    "estimate",
    record$runtime_run_id,
    record$provider_execution_run_id,
    record$request_id,
    record$state_reference$state_id,
    record$estimand_specification$specification_id,
    record$estimand_specification$specification_version,
    record$provider_reference$provider_id,
    record$provider_reference$provider_version,
    model_identity,
    record$target_interval_start,
    record$target_interval_end,
    record$interval_boundary
  )
}

rrp_build_estimate_record <- function(
  raw_output,
  request,
  state,
  provider,
  provider_execution_run_id,
  execution_result_id,
  estimate_contract
) {
  record <- list(
    estimate_id = "pending",
    estimate_specification = rrp_identity(
      estimate_contract$specification_kind,
      estimate_contract$specification_id,
      estimate_contract$specification_version
    ),
    runtime_run_id = request$runtime_run_id,
    provider_execution_run_id = provider_execution_run_id,
    request_id = request$request_id,
    state_reference = list(
      state_id = state$state_id,
      state_specification = state$state_specification
    ),
    episode_id = request$episode_id,
    estimand_specification = request$estimand_specification,
    provider_reference = rrp_provider_reference(provider),
    model_reference = NULL,
    as_of_time = request$as_of_time,
    target_interval_start = request$target_interval_start,
    target_interval_end = request$target_interval_end,
    interval_boundary = request$interval_boundary,
    output_type = raw_output$output_type,
    estimate_value = as.numeric(raw_output$estimate_value),
    provenance_references = c(
      list(
        list(
          provenance_type = "estimand_request",
          provenance_id = request$request_id,
          relationship = "estimates"
        ),
        list(
          provenance_type = "episode_state",
          provenance_id = state$state_id,
          relationship = "used_state",
          version_or_revision = state$state_specification$specification_version
        ),
        list(
          provenance_type = "provider_execution_result",
          provenance_id = execution_result_id,
          relationship = "accepted_from"
        )
      ),
      raw_output$provenance_references
    )
  )
  record$estimate_id <- rrp_estimate_identity(record)
  record
}

#' Validate one standardized estimate record against its semantic inputs
#' @export
validate_estimate_record <- function(
  estimate,
  request,
  state,
  provider,
  estimate_contract
) {
  target <- rrp_provider_contract_identities()$estimate
  issues <- list()
  if (!rrp_specification_matches(estimate_contract, target)) {
    return(rrp_runtime_result(target, list(rrp_runtime_issue(
      "estimate.contract", "unsupported_estimate_contract",
      "Estimate contract identity/version is unsupported.", "$.estimate_contract"
    ))))
  }
  if (!is.list(estimate)) {
    return(rrp_runtime_result(target, list(rrp_runtime_issue(
      "estimate.structure", "invalid_estimate_record",
      "Estimate record must be a named record.", "$"
    ))))
  }
  required <- unlist(estimate_contract$required_fields, use.names = FALSE)
  missing <- required[!required %in% names(estimate)]
  if (length(missing) > 0L) {
    issues[[length(issues) + 1L]] <- rrp_runtime_issue(
      "estimate.required", "missing_estimate_field",
      paste0("Estimate fields are missing: ", paste(missing, collapse = ", "), "."),
      "$"
    )
  }
  prohibited <- intersect(
    names(estimate), unlist(estimate_contract$prohibited_fields, use.names = FALSE)
  )
  if (length(prohibited) > 0L) {
    issues[[length(issues) + 1L]] <- rrp_runtime_issue(
      "estimate.separation", "prohibited_estimate_field",
      paste0("Decision, product, or persistence fields are prohibited: ",
             paste(prohibited, collapse = ", "), "."), "$"
    )
  }
  identity_ok <- identical(estimate$request_id, request$request_id) &&
    identical(estimate$episode_id, request$episode_id) &&
    identical(estimate$state_reference$state_id, state$state_id) &&
    identical(estimate$estimand_specification, request$estimand_specification) &&
    identical(estimate$provider_reference, rrp_provider_reference(provider)) &&
    identical(estimate$runtime_run_id, request$runtime_run_id)
  if (!identity_ok) {
    issues[[length(issues) + 1L]] <- rrp_runtime_issue(
      "estimate.identity", "estimate_identity_mismatch",
      "Estimate request/state/episode/estimand/provider identities do not align.",
      "$"
    )
  }
  interval_ok <- identical(estimate$as_of_time, request$as_of_time) &&
    identical(estimate$target_interval_start, request$target_interval_start) &&
    identical(estimate$target_interval_end, request$target_interval_end) &&
    identical(estimate$interval_boundary, request$interval_boundary)
  if (!interval_ok) {
    issues[[length(issues) + 1L]] <- rrp_runtime_issue(
      "estimate.interval", "estimate_interval_mismatch",
      "Estimate interval/as-of values do not match the request.", "$"
    )
  }
  value_ok <- identical(estimate$output_type, "probability") &&
    is.numeric(estimate$estimate_value) && length(estimate$estimate_value) == 1L &&
    is.finite(estimate$estimate_value) && estimate$estimate_value >= 0 &&
    estimate$estimate_value <= 1
  if (!value_ok) {
    issues[[length(issues) + 1L]] <- rrp_runtime_issue(
      "estimate.output", "invalid_probability_estimate",
      "Estimate must contain one finite probability in [0,1].",
      "$.estimate_value"
    )
  }
  if (all(c(
    "runtime_run_id", "provider_execution_run_id", "request_id",
    "state_reference", "estimand_specification", "provider_reference",
    "model_reference", "target_interval_start", "target_interval_end",
    "interval_boundary", "estimate_id"
  ) %in% names(estimate)) && !identical(estimate$estimate_id, rrp_estimate_identity(estimate))) {
    issues[[length(issues) + 1L]] <- rrp_runtime_issue(
      "estimate.identity", "nondeterministic_estimate_identity",
      "Estimate ID does not match its declared semantic inputs.", "$.estimate_id"
    )
  }
  if (!rrp_named_records(estimate$provenance_references) ||
      length(estimate$provenance_references) == 0L) {
    issues[[length(issues) + 1L]] <- rrp_runtime_issue(
      "estimate.provenance", "missing_estimate_provenance",
      "Estimate requires request/state/provider-execution provenance references.",
      "$.provenance_references"
    )
  }
  rrp_runtime_result(target, issues)
}

