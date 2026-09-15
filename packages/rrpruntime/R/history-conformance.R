rrp_history_required_fields <- function(record_family) {
  switch(record_family,
    episode_state = c("state_id", "state_specification", "runtime_run_id", "episode_id", "as_of_time"),
    estimand_request = c("request_id", "request_specification", "runtime_run_id", "episode_id", "state_reference", "as_of_time"),
    provider_execution_result = c("execution_result_id", "execution_result_specification", "runtime_run_id", "provider_execution_run_id", "request_id", "state_id", "episode_id", "provider_reference", "attempt_number", "retry_of_execution_result_id", "execution_status", "estimate_record"),
    estimate = c("estimate_id", "estimate_specification", "runtime_run_id", "provider_execution_run_id", "request_id", "state_reference", "episode_id", "provider_reference", "as_of_time"),
    stop("Unknown history record family: ", record_family, call. = FALSE)
  )
}

rrp_history_record_id <- function(record, family) {
  record[[switch(family,
    episode_state = "state_id", estimand_request = "request_id",
    provider_execution_result = "execution_result_id", estimate = "estimate_id"
  )]]
}

rrp_history_record_shape_ok <- function(record, family) {
  expected <- switch(family,
    episode_state = rrp_runtime_supported_specifications()$episode_state,
    estimand_request = rrp_runtime_supported_specifications()$estimand_request,
    provider_execution_result = rrp_provider_contract_identities()$execution_result,
    estimate = rrp_provider_contract_identities()$estimate
  )
  specification_field <- switch(family,
    episode_state = "state_specification",
    estimand_request = "request_specification",
    provider_execution_result = "execution_result_specification",
    estimate = "estimate_specification"
  )
  identity_field <- switch(family,
    episode_state = "state_id", estimand_request = "request_id",
    provider_execution_result = "execution_result_id", estimate = "estimate_id"
  )
  common <- rrp_is_scalar_string(record[[identity_field]]) &&
    identical(record[[specification_field]], expected) &&
    rrp_is_scalar_string(record$runtime_run_id) &&
    rrp_is_scalar_string(record$episode_id)
  if (!common) return(FALSE)
  if (identical(family, "episode_state")) return(rrp_is_timestamp(record$as_of_time))
  if (identical(family, "estimand_request")) return(
    rrp_is_timestamp(record$as_of_time) && is.list(record$state_reference) &&
      rrp_is_scalar_string(record$state_reference$state_id)
  )
  if (identical(family, "provider_execution_result")) {
    statuses <- c(
      "successful_estimate", "unsupported", "missing_required_input",
      "execution_failure", "invalid_output"
    )
    attempt <- record$attempt_number
    attempt_ok <- is.numeric(attempt) && length(attempt) == 1L &&
      is.finite(attempt) && attempt == as.integer(attempt) && attempt >= 1L
    retry_ok <- attempt_ok && if (attempt == 1L) {
      is.null(record$retry_of_execution_result_id)
    } else rrp_is_scalar_string(record$retry_of_execution_result_id)
    success <- identical(record$execution_status, "successful_estimate")
    return(
      rrp_is_scalar_string(record$provider_execution_run_id) &&
        rrp_is_scalar_string(record$request_id) &&
        rrp_is_scalar_string(record$state_id) && is.list(record$provider_reference) &&
        rrp_is_scalar_string(record$execution_status) &&
        record$execution_status %in% statuses && attempt_ok && retry_ok &&
        if (success) is.list(record$estimate_record) else is.null(record$estimate_record)
    )
  }
  rrp_is_timestamp(record$as_of_time) &&
    rrp_is_scalar_string(record$provider_execution_run_id) &&
    rrp_is_scalar_string(record$request_id) && is.list(record$state_reference) &&
    rrp_is_scalar_string(record$state_reference$state_id) &&
    is.list(record$provider_reference) &&
    is.numeric(record$estimate_value) && length(record$estimate_value) == 1L &&
    is.finite(record$estimate_value) && record$estimate_value >= 0 &&
    record$estimate_value <= 1
}

rrp_history_record_issues <- function(records, family, runtime_run_id) {
  issues <- list()
  if (!rrp_named_records(records)) return(list(rrp_runtime_issue(
    "history.batch.structure", "invalid_history_record_collection",
    paste0("History family ", family, " must be a record collection."),
    paste0("$.", family)
  )))
  required <- rrp_history_required_fields(family)
  for (index in seq_along(records)) {
    record <- records[[index]]
    missing <- required[!required %in% names(record)]
    if (length(missing) > 0L) issues[[length(issues) + 1L]] <- rrp_runtime_issue(
      "history.batch.required", "missing_persisted_record_field",
      paste0(family, " record fields are missing: ", paste(missing, collapse = ", "), "."),
      paste0("$.", family, "[", index, "]")
    ) else if (!identical(record$runtime_run_id, runtime_run_id)) {
      issues[[length(issues) + 1L]] <- rrp_runtime_issue(
        "history.batch.run", "history_record_run_mismatch",
        paste0(family, " record belongs to a different runtime run."),
        paste0("$.", family, "[", index, "]")
      )
    } else if (!rrp_history_record_shape_ok(record, family)) {
      issues[[length(issues) + 1L]] <- rrp_runtime_issue(
        "history.batch.record", "invalid_persisted_record",
        paste0(family, " record identity, version, or value shape is invalid."),
        paste0("$.", family, "[", index, "]")
      )
    }
  }
  if (length(records) > 0L && all(vapply(records, function(record) {
    length(setdiff(required, names(record))) == 0L
  }, logical(1)))) {
    ids <- vapply(records, rrp_history_record_id, character(1), family = family)
    if (anyDuplicated(ids)) issues[[length(issues) + 1L]] <- rrp_runtime_issue(
      "history.batch.identity", "duplicate_history_record_identity",
      paste0("History family ", family, " contains duplicate identities."),
      paste0("$.", family)
    )
  }
  issues
}

rrp_estimate_semantic_key <- function(estimate) {
  model <- if (is.null(estimate$model_reference)) "no_separate_model" else paste(
    estimate$model_reference$model_id, estimate$model_reference$model_version, sep = "@"
  )
  paste(
    estimate$request_id, estimate$provider_reference$provider_id,
    estimate$provider_reference$provider_version, model,
    estimate$target_interval_start, estimate$target_interval_end,
    estimate$interval_boundary, sep = "|"
  )
}

#' Validate an atomic completed-run operational-history batch
#' @export
validate_completed_run_batch <- function(
  run_status,
  episode_states,
  estimand_requests,
  provider_execution_results,
  estimates,
  history_contracts
) {
  issues <- list()
  run_result <- validate_operational_run_status(
    run_status, history_contracts$operational_run_status
  )
  if (!runtime_conforms(run_result)) issues[[length(issues) + 1L]] <- run_result$issues
  if (!rrp_is_scalar_string(run_status$run_status) ||
      !run_status$run_status %in% c("completed", "completed_with_failures")) {
    issues[[length(issues) + 1L]] <- rrp_runtime_issue(
      "history.batch.terminal", "noncompleted_run_batch",
      "An atomic completed-run batch requires a completed terminal status.",
      "$.run_status"
    )
  }
  families <- list(
    episode_state = episode_states, estimand_request = estimand_requests,
    provider_execution_result = provider_execution_results, estimate = estimates
  )
  for (family in names(families)) issues <- c(
    issues, rrp_history_record_issues(families[[family]], family, run_status$runtime_run_id)
  )
  structurally_valid <- nrow(rrp_runtime_bind_issues(issues)) == 0L
  if (structurally_valid) {
    state_ids <- vapply(episode_states, `[[`, character(1), "state_id")
    request_ids <- vapply(estimand_requests, `[[`, character(1), "request_id")
    execution_ids <- vapply(provider_execution_results, `[[`, character(1), "execution_result_id")
    estimate_ids <- vapply(estimates, `[[`, character(1), "estimate_id")
    for (request in estimand_requests) if (!request$state_reference$state_id %in% state_ids) {
      issues[[length(issues) + 1L]] <- rrp_runtime_issue(
        "history.batch.relationship", "request_state_not_in_batch",
        "Every persisted request must reference a state in the same batch.", "$.estimand_requests"
      )
    }
    for (execution in provider_execution_results) {
      if (!execution$request_id %in% request_ids || !execution$state_id %in% state_ids) {
        issues[[length(issues) + 1L]] <- rrp_runtime_issue(
          "history.batch.relationship", "execution_input_not_in_batch",
          "Every execution must reference a request and state in the same batch.",
          "$.provider_execution_results"
        )
      }
      retry <- execution$retry_of_execution_result_id
      if (execution$attempt_number == 1L && !is.null(retry) ||
          execution$attempt_number > 1L && !rrp_is_scalar_string(retry)) {
        issues[[length(issues) + 1L]] <- rrp_runtime_issue(
          "history.batch.retry", "invalid_retry_lineage",
          "Attempt 1 has no retry reference; later attempts require one.",
          "$.provider_execution_results"
        )
      }
      if (execution$attempt_number > 1L) {
        prior_index <- match(retry, execution_ids)
        prior_ok <- !is.na(prior_index) &&
          provider_execution_results[[prior_index]]$attempt_number == execution$attempt_number - 1L &&
          identical(provider_execution_results[[prior_index]]$request_id, execution$request_id) &&
          identical(provider_execution_results[[prior_index]]$provider_reference, execution$provider_reference)
        if (!prior_ok) issues[[length(issues) + 1L]] <- rrp_runtime_issue(
          "history.batch.retry", "unresolved_retry_lineage",
          "A retry must reference the immediately preceding attempt for the same request/provider.",
          "$.provider_execution_results"
        )
      }
    }
    successful <- Filter(function(value) identical(value$execution_status, "successful_estimate"), provider_execution_results)
    successful_estimate_ids <- vapply(successful, function(value) value$estimate_record$estimate_id, character(1))
    if (!setequal(successful_estimate_ids, estimate_ids)) issues[[length(issues) + 1L]] <- rrp_runtime_issue(
      "history.batch.estimates", "estimate_execution_mismatch",
      "Accepted estimates must exactly match successful execution results.", "$.estimates"
    )
    if (length(successful) > 0L && any(!vapply(successful, function(execution) {
      index <- match(execution$estimate_record$estimate_id, estimate_ids)
      !is.na(index) && identical(execution$estimate_record, estimates[[index]])
    }, logical(1)))) issues[[length(issues) + 1L]] <- rrp_runtime_issue(
      "history.batch.estimates", "estimate_execution_content_mismatch",
      "Each estimate must equal the accepted record embedded in its successful execution.",
      "$.estimates"
    )
    if (anyDuplicated(vapply(estimates, rrp_estimate_semantic_key, character(1)))) {
      issues[[length(issues) + 1L]] <- rrp_runtime_issue(
        "history.batch.estimates", "duplicate_accepted_estimate",
        "A run cannot accept multiple estimates for one request/provider/model/interval.",
        "$.estimates"
      )
    }
    failed_count <- sum(vapply(provider_execution_results, function(value) {
      !identical(value$execution_status, "successful_estimate")
    }, logical(1)))
    status_ok <- if (failed_count == 0L) identical(run_status$run_status, "completed") else {
      identical(run_status$run_status, "completed_with_failures")
    }
    if (!status_ok) issues[[length(issues) + 1L]] <- rrp_runtime_issue(
      "history.batch.summary", "terminal_status_outcome_mismatch",
      "Terminal status must distinguish runs with failed provider executions.", "$.run_status"
    )
    expected_summary <- list(
      episode_state_count = length(episode_states),
      estimand_request_count = length(estimand_requests),
      provider_execution_result_count = length(provider_execution_results),
      successful_estimate_count = length(estimates),
      failed_execution_count = failed_count
    )
    if (!identical(run_status$status_summary, expected_summary)) issues[[length(issues) + 1L]] <- rrp_runtime_issue(
      "history.batch.summary", "run_summary_mismatch",
      "Run terminal summary must exactly describe the atomic batch.",
      "$.run_status.status_summary"
    )
  }
  rrp_runtime_result(
    rrp_identity("persistence_batch", "platform.completed-run-batch", "0.1.0"),
    issues
  )
}
