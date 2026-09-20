rrp_history_abort <- function(code) {
  messages <- c(
    invalid_scope = "Operational scope validation failed.",
    invalid_disposition = "Episode disposition validation failed.",
    invalid_action = "History action validation failed.",
    invalid_adapter = "History adapter validation failed.",
    identity_conflict = "History identity conflicts with existing content.",
    relationship_conflict = "History relationship validation failed.",
    ambiguous_current = "Current episode history is ambiguous.",
    invalid_read = "History read request or result is invalid."
  )
  stop(structure(
    list(message = unname(messages[[code]]), call = NULL, code = code),
    class = c("rrp_history_error", "error", "condition")
  ))
}

rrp_history_copy <- function(value) unserialize(serialize(value, NULL))
rrp_history_time <- function(value) rrp_canonical_timestamp_number(value)
rrp_history_string <- function(value) {
  rrp_canonical_scalar_string(value) && nchar(value, type = "bytes") <= 160L &&
    !grepl("[[:cntrl:]]", value)
}
rrp_history_nullable_string <- function(value) is.null(value) || rrp_history_string(value)
rrp_history_identity_values <- function(values) {
  lapply(values, function(value) if (is.null(value)) "<NULL>" else value)
}
rrp_history_id <- function(prefix, values) {
  rrp_runtime_identity(prefix, rrp_history_identity_values(values))
}

#' Compute governed admitted-episode membership evidence
#' @param episode_ids Unique opaque admitted episode identities.
#' @return One deterministic membership fingerprint.
#' @export
rrp_history_membership_fingerprint <- function(episode_ids) {
  valid <- is.character(episode_ids) && !anyNA(episode_ids) &&
    !anyDuplicated(episode_ids) &&
    all(vapply(episode_ids, rrp_canonical_valid_identity, logical(1L)))
  if (!valid) rrp_history_abort("invalid_scope")
  ids <- sort(enc2utf8(episode_ids), method = "radix")
  encoded <- paste0(length(ids), "|", paste(vapply(ids, function(value) {
    paste0(nchar(value, type = "bytes"), ":", value)
  }, character(1L)), collapse = "|"))
  rrp_history_id("rrp.membership.", list(encoded))
}

rrp_history_scope_fields <- function() c(
  "scope_contract_id", "scope_contract_version", "scope_record_id",
  "named_operation_id", "operation_run_id", "operation_key", "state_id",
  "product_id", "development_version", "rrp_api_version", "project_api_id",
  "project_api_version", "project_id", "project_version", "bundle_contract_id",
  "bundle_contract_version", "bundle_instance_id", "canonical_profile_id",
  "canonical_profile_version", "producer_id", "producer_version",
  "producer_implementation_id", "producer_implementation_version", "mapping_id",
  "mapping_version", "target_id", "target_version", "analytical_time",
  "expected_episode_count", "membership_encoding",
  "membership_fingerprint_algorithm", "membership_fingerprint", "created_at"
)

rrp_history_scope_input_fields <- function() c(
  "operation_key", "state_id", "product_id", "development_version",
  "rrp_api_version", "project_api_id", "project_api_version", "project_id",
  "project_version", "bundle_contract_id", "bundle_contract_version",
  "bundle_instance_id", "canonical_profile_id", "canonical_profile_version",
  "producer_id", "producer_version", "producer_implementation_id",
  "producer_implementation_version", "mapping_id", "mapping_version",
  "target_id", "target_version", "analytical_time", "created_at"
)

rrp_history_validate_scope <- function(scope) {
  versions <- c(
    "scope_contract_version", "development_version", "rrp_api_version",
    "project_api_version", "project_version", "bundle_contract_version",
    "canonical_profile_version", "producer_version",
    "producer_implementation_version", "mapping_version", "target_version"
  )
  identities <- c(
    "scope_contract_id", "scope_record_id", "named_operation_id",
    "operation_run_id", "state_id", "product_id", "project_api_id", "project_id",
    "bundle_contract_id", "bundle_instance_id", "canonical_profile_id",
    "producer_id", "producer_implementation_id", "mapping_id", "target_id",
    "membership_fingerprint"
  )
  valid <- is.list(scope) &&
    identical(class(scope), c("rrp_operational_scope", "list")) &&
    identical(names(scope), rrp_history_scope_fields()) &&
    all(vapply(scope[identities], rrp_canonical_valid_identity, logical(1L))) &&
    all(vapply(scope[versions], rrp_canonical_valid_version, logical(1L))) &&
    rrp_history_string(scope$operation_key) &&
    identical(scope$scope_contract_id, "rrp.history.operational-scope") &&
    identical(scope$scope_contract_version, "0.1.0") &&
    identical(scope$named_operation_id, "rrp.operation.evaluate-admitted-bundle") &&
    identical(scope$product_id, "readmission-risk-pool-platform") &&
    identical(scope$development_version, "1.0.0-dev") &&
    is.integer(scope$expected_episode_count) &&
    length(scope$expected_episode_count) == 1L &&
    !is.na(scope$expected_episode_count) && scope$expected_episode_count >= 0L &&
    identical(scope$membership_encoding, "utf8_length_prefixed_sorted_unique_v1") &&
    identical(scope$membership_fingerprint_algorithm, "dual_modular_hash_v1") &&
    !is.na(rrp_history_time(scope$analytical_time)) &&
    !is.na(rrp_history_time(scope$created_at)) &&
    rrp_history_time(scope$created_at) >= rrp_history_time(scope$analytical_time) &&
    identical(scope$operation_run_id, rrp_history_id(
      "rrp.operation-run.",
      list(scope$state_id, scope$named_operation_id, scope$operation_key)
    )) &&
    identical(scope$scope_record_id, rrp_history_id(
      "rrp.scope.",
      list(scope$scope_contract_id, scope$scope_contract_version, scope$operation_run_id)
    ))
  if (!valid) rrp_history_abort("invalid_scope")
  invisible(scope)
}

#' Construct one immutable bundle-scoped operational record
#' @param values Exact governed scope values in contract order.
#' @param episode_ids Unique admitted episode identities.
#' @return A detached `rrp_operational_scope`.
#' @export
rrp_new_operational_scope <- function(values, episode_ids) {
  if (!rrp_canonical_plain_named_list(values) ||
      !identical(names(values), rrp_history_scope_input_fields())) {
    rrp_history_abort("invalid_scope")
  }
  operation_run_id <- rrp_history_id(
    "rrp.operation-run.",
    list(values$state_id, "rrp.operation.evaluate-admitted-bundle", values$operation_key)
  )
  scope <- structure(list(
    scope_contract_id = "rrp.history.operational-scope",
    scope_contract_version = "0.1.0",
    scope_record_id = rrp_history_id(
      "rrp.scope.",
      list("rrp.history.operational-scope", "0.1.0", operation_run_id)
    ),
    named_operation_id = "rrp.operation.evaluate-admitted-bundle",
    operation_run_id = operation_run_id,
    operation_key = values$operation_key,
    state_id = values$state_id,
    product_id = values$product_id,
    development_version = values$development_version,
    rrp_api_version = values$rrp_api_version,
    project_api_id = values$project_api_id,
    project_api_version = values$project_api_version,
    project_id = values$project_id,
    project_version = values$project_version,
    bundle_contract_id = values$bundle_contract_id,
    bundle_contract_version = values$bundle_contract_version,
    bundle_instance_id = values$bundle_instance_id,
    canonical_profile_id = values$canonical_profile_id,
    canonical_profile_version = values$canonical_profile_version,
    producer_id = values$producer_id,
    producer_version = values$producer_version,
    producer_implementation_id = values$producer_implementation_id,
    producer_implementation_version = values$producer_implementation_version,
    mapping_id = values$mapping_id,
    mapping_version = values$mapping_version,
    target_id = values$target_id,
    target_version = values$target_version,
    analytical_time = values$analytical_time,
    expected_episode_count = as.integer(length(episode_ids)),
    membership_encoding = "utf8_length_prefixed_sorted_unique_v1",
    membership_fingerprint_algorithm = "dual_modular_hash_v1",
    membership_fingerprint = rrp_history_membership_fingerprint(episode_ids),
    created_at = values$created_at
  ), class = c("rrp_operational_scope", "list"))
  rrp_history_validate_scope(scope)
  rrp_history_copy(scope)
}

rrp_history_disposition_fields <- function() c(
  "disposition_contract_id", "disposition_contract_version",
  "disposition_record_id", "operation_run_id", "analytical_run_id",
  "analytical_kind", "related_analytical_run_id", "analytical_key",
  "episode_id", "patient_id", "target_id", "target_version", "analytical_time",
  "outcome", "outcome_code", "eligibility_status", "state", "request",
  "provider_id", "provider_version", "implementation_id",
  "implementation_version", "model_id", "model_version",
  "provider_execution_id", "provider_status", "estimate_record_id", "estimate",
  "terminal_time"
)

rrp_history_disposition_input_fields <- function() c(
  "analytical_kind", "related_analytical_run_id", "analytical_key",
  "episode_id", "patient_id", "target_id", "target_version", "analytical_time",
  "outcome", "outcome_code", "eligibility_status", "state", "request",
  "provider_id", "provider_version", "implementation_id",
  "implementation_version", "model_id", "model_version", "provider_status",
  "estimate", "terminal_time"
)

rrp_history_validate_request <- function(request, state) {
  valid <- is.list(request) &&
    identical(class(request), c("rrp_risk_request", "list")) &&
    identical(names(request), rrp_risk_request_fields()) &&
    !rrp_canonical_has_unsafe_value(request) &&
    identical(request$request_contract_id, "rrp.risk-request") &&
    identical(request$request_contract_version, "0.1.0") &&
    identical(request$request_id, rrp_history_id("rrp.request.", unname(request[-3L]))) &&
    identical(request$state_contract_id, state$state_contract_id) &&
    identical(request$state_contract_version, state$state_contract_version) &&
    identical(request$state_id, state$state_id) &&
    identical(request$bundle_instance_id, state$bundle_instance_id) &&
    identical(request$project_id, state$project_id) &&
    identical(request$project_version, state$project_version) &&
    identical(request$episode_id, state$episode_id) &&
    identical(request$as_of_time, state$as_of_time) &&
    identical(request$target_id, state$target_id) &&
    identical(request$target_version, state$target_version) &&
    identical(request$target_interval_start, state$as_of_time) &&
    identical(request$target_interval_end, state$target_window_end) &&
    identical(request$target_interval_boundary, "(start,end]") &&
    identical(request$elapsed_seconds_since_discharge,
      state$elapsed_seconds_since_discharge) &&
    identical(request$remaining_seconds_through_w30,
      state$remaining_seconds_through_w30)
  if (!valid) rrp_history_abort("invalid_disposition")
  invisible(request)
}

rrp_history_validate_estimate <- function(estimate, request, provider) {
  valid <- is.list(estimate) &&
    identical(class(estimate), c("rrp_risk_estimate", "list")) &&
    identical(names(estimate), rrp_risk_estimate_fields()) &&
    !rrp_canonical_has_unsafe_value(estimate) &&
    identical(estimate$estimate_contract_id, "rrp.risk-estimate") &&
    identical(estimate$estimate_contract_version, "0.1.0") &&
    identical(estimate$request_id, request$request_id) &&
    identical(estimate$state_id, request$state_id) &&
    identical(estimate$episode_id, request$episode_id) &&
    identical(estimate$as_of_time, request$as_of_time) &&
    identical(estimate$product_id, "readmission-risk-pool-platform") &&
    identical(estimate$development_version, "1.0.0-dev") &&
    identical(estimate$output_type, "probability") &&
    is.double(estimate$estimate_value) && length(estimate$estimate_value) == 1L &&
    is.finite(estimate$estimate_value) && is.null(attributes(estimate$estimate_value)) &&
    estimate$estimate_value >= 0 && estimate$estimate_value <= 1 &&
    identical(estimate$provider_id, provider$provider_id) &&
    identical(estimate$provider_version, provider$provider_version) &&
    identical(estimate$implementation_id, provider$implementation_id) &&
    identical(estimate$implementation_version, provider$implementation_version) &&
    identical(estimate$model_id, provider$model_id) &&
    identical(estimate$model_version, provider$model_version)
  if (!valid) rrp_history_abort("invalid_disposition")
  invisible(estimate)
}

rrp_history_validate_disposition <- function(disposition) {
  strings <- c(
    "disposition_contract_id", "disposition_contract_version",
    "disposition_record_id", "operation_run_id", "analytical_run_id",
    "analytical_kind", "episode_id", "patient_id", "target_id", "target_version",
    "analytical_time", "outcome", "outcome_code", "eligibility_status",
    "provider_status", "terminal_time"
  )
  nullable <- c(
    "related_analytical_run_id", "analytical_key", "provider_id",
    "provider_version", "implementation_id", "implementation_version", "model_id",
    "model_version", "provider_execution_id", "estimate_record_id"
  )
  valid <- is.list(disposition) &&
    identical(class(disposition), c("rrp_episode_disposition", "list")) &&
    identical(names(disposition), rrp_history_disposition_fields()) &&
    all(vapply(disposition[strings], rrp_history_string, logical(1L))) &&
    all(vapply(disposition[nullable], rrp_history_nullable_string, logical(1L))) &&
    identical(disposition$disposition_contract_id, "rrp.history.episode-disposition") &&
    identical(disposition$disposition_contract_version, "0.1.0") &&
    disposition$analytical_kind %in% c("initial", "retry", "restatement") &&
    disposition$outcome %in% c(
      "ineligible", "accepted_estimate", "provider_incompatible",
      "provider_declared_failure", "detected_failure"
    ) &&
    disposition$eligibility_status %in% c("eligible", "ineligible") &&
    disposition$provider_status %in% c(
      "not_invoked", "succeeded", "declared_failure", "detected_failure"
    ) &&
    !is.na(rrp_history_time(disposition$analytical_time)) &&
    !is.na(rrp_history_time(disposition$terminal_time)) &&
    rrp_history_time(disposition$terminal_time) >=
      rrp_history_time(disposition$analytical_time)
  if (!valid) rrp_history_abort("invalid_disposition")

  initial <- identical(disposition$analytical_kind, "initial")
  if (initial) {
    if (!is.null(disposition$related_analytical_run_id) ||
        !is.null(disposition$analytical_key)) rrp_history_abort("invalid_disposition")
  } else if (!rrp_history_string(disposition$related_analytical_run_id) ||
             !rrp_history_string(disposition$analytical_key)) {
    rrp_history_abort("invalid_disposition")
  }
  identity_values <- list(
    disposition$operation_run_id, disposition$episode_id, disposition$target_id,
    disposition$target_version, disposition$analytical_time,
    disposition$analytical_kind
  )
  if (!initial) identity_values <- c(identity_values, list(
    disposition$related_analytical_run_id, disposition$analytical_key
  ))
  if (!identical(disposition$analytical_run_id,
      rrp_history_id("rrp.analysis.", identity_values)) ||
      !identical(disposition$disposition_record_id, rrp_history_id(
        "rrp.disposition.", list(
          disposition$disposition_contract_id,
          disposition$disposition_contract_version,
          disposition$analytical_run_id
        )
      ))) rrp_history_abort("invalid_disposition")

  provider <- disposition[c(
    "provider_id", "provider_version", "implementation_id",
    "implementation_version", "model_id", "model_version"
  )]
  selected <- provider[1:4]
  selected_valid <- all(vapply(selected[c(1L, 3L)],
    rrp_canonical_valid_identity, logical(1L))) &&
    all(vapply(selected[c(2L, 4L)], rrp_canonical_valid_version, logical(1L)))
  model_valid <- (is.null(provider$model_id) && is.null(provider$model_version)) ||
    (rrp_canonical_valid_identity(provider$model_id) &&
      rrp_canonical_valid_version(provider$model_version))
  none <- function(values) all(vapply(values, is.null, logical(1L)))

  if (identical(disposition$outcome, "ineligible")) {
    valid_ineligible <- identical(disposition$eligibility_status, "ineligible") &&
      identical(disposition$provider_status, "not_invoked") &&
      disposition$outcome_code %in% c(
        "episode_before_discharge", "target_horizon_exhausted",
        "episode_already_readmitted", "episode_already_dead"
      ) && none(disposition[c(
        "state", "request", names(provider), "provider_execution_id",
        "estimate_record_id", "estimate"
      )])
    if (!valid_ineligible) rrp_history_abort("invalid_disposition")
    return(invisible(disposition))
  }

  state_valid <- !is.null(disposition$state) && tryCatch({
    rrp_runtime_validate_episode_state(disposition$state)
    state <- disposition$state
    identical(state$state_id, rrp_runtime_state_identity(list(
      state$bundle_contract_id, state$bundle_contract_version,
      state$bundle_instance_id, state$project_id, state$project_version,
      state$canonical_profile_id, state$canonical_profile_version,
      state$episode_id, state$as_of_time, state$discharge_time,
      state$target_window_end, state$target_id, state$target_version,
      state$state_contract_id, state$state_contract_version
    )))
  }, error = function(condition) FALSE)
  if (!state_valid || !selected_valid || !model_valid ||
      !identical(disposition$eligibility_status, "eligible") ||
      !identical(disposition$state$episode_id, disposition$episode_id) ||
      !identical(disposition$state$target_id, disposition$target_id) ||
      !identical(disposition$state$target_version, disposition$target_version) ||
      !identical(disposition$state$as_of_time, disposition$analytical_time)) {
    rrp_history_abort("invalid_disposition")
  }

  if (identical(disposition$outcome, "provider_incompatible")) {
    if (!is.null(disposition$request)) {
      rrp_history_validate_request(disposition$request, disposition$state)
    }
    if (!identical(disposition$provider_status, "not_invoked") ||
        !identical(disposition$outcome_code, "provider_incompatible") ||
        !none(disposition[c(
          "provider_execution_id", "estimate_record_id", "estimate"
        )])) rrp_history_abort("invalid_disposition")
    return(invisible(disposition))
  }

  if (is.null(disposition$request)) rrp_history_abort("invalid_disposition")
  rrp_history_validate_request(disposition$request, disposition$state)
  expected_execution <- rrp_history_id(
    "rrp.provider-execution.",
    c(list(disposition$analytical_run_id, disposition$request$request_id),
      unname(provider))
  )
  if (!identical(disposition$provider_execution_id, expected_execution)) {
    rrp_history_abort("invalid_disposition")
  }
  if (identical(disposition$outcome, "accepted_estimate")) {
    if (!identical(disposition$provider_status, "succeeded") ||
        !identical(disposition$outcome_code, "estimate_accepted") ||
        is.null(disposition$estimate)) rrp_history_abort("invalid_disposition")
    rrp_history_validate_estimate(disposition$estimate, disposition$request, provider)
    expected_estimate <- rrp_history_id("rrp.estimate-record.", list(
      disposition$provider_execution_id,
      disposition$estimate$estimate_contract_id,
      disposition$estimate$estimate_contract_version,
      disposition$estimate$request_id,
      disposition$estimate$estimate_value
    ))
    if (!identical(disposition$estimate_record_id, expected_estimate)) {
      rrp_history_abort("invalid_disposition")
    }
  } else {
    declared <- identical(disposition$outcome, "provider_declared_failure")
    expected_status <- if (declared) "declared_failure" else "detected_failure"
    allowed_codes <- if (declared) c(
      "provider_unavailable", "provider_input_unavailable",
      "provider_calculation_failed"
    ) else c(
      "provider_execution_failed", "invalid_provider_result",
      "provider_result_identity_mismatch", "invalid_estimate"
    )
    if (!identical(disposition$provider_status, expected_status) ||
        !disposition$outcome_code %in% allowed_codes ||
        !none(disposition[c("estimate_record_id", "estimate")])) {
      rrp_history_abort("invalid_disposition")
    }
  }
  invisible(disposition)
}

#' Construct one terminal episode disposition
#' @param scope A validated operational scope.
#' @param values Exact governed disposition values in contract order.
#' @return A detached `rrp_episode_disposition`.
#' @export
rrp_new_episode_disposition <- function(scope, values) {
  rrp_history_validate_scope(scope)
  if (!rrp_canonical_plain_named_list(values) ||
      !identical(names(values), rrp_history_disposition_input_fields()) ||
      !identical(values$target_id, scope$target_id) ||
      !identical(values$target_version, scope$target_version) ||
      !identical(values$analytical_time, scope$analytical_time)) {
    rrp_history_abort("invalid_disposition")
  }
  analytical_values <- list(
    scope$operation_run_id, values$episode_id, values$target_id,
    values$target_version, values$analytical_time, values$analytical_kind
  )
  if (!identical(values$analytical_kind, "initial")) analytical_values <- c(
    analytical_values,
    list(values$related_analytical_run_id, values$analytical_key)
  )
  analytical_run_id <- rrp_history_id("rrp.analysis.", analytical_values)
  provider_values <- values[c(
    "provider_id", "provider_version", "implementation_id",
    "implementation_version", "model_id", "model_version"
  )]
  provider_execution_id <- if (identical(values$provider_status, "not_invoked")) {
    NULL
  } else {
    request_id <- if (is.list(values$request)) values$request$request_id else NULL
    rrp_history_id("rrp.provider-execution.", c(
      list(analytical_run_id, request_id), unname(provider_values)
    ))
  }
  estimate_record_id <- if (is.null(values$estimate)) NULL else rrp_history_id(
    "rrp.estimate-record.", list(
      provider_execution_id, values$estimate$estimate_contract_id,
      values$estimate$estimate_contract_version, values$estimate$request_id,
      values$estimate$estimate_value
    )
  )
  disposition <- structure(list(
    disposition_contract_id = "rrp.history.episode-disposition",
    disposition_contract_version = "0.1.0",
    disposition_record_id = rrp_history_id("rrp.disposition.", list(
      "rrp.history.episode-disposition", "0.1.0", analytical_run_id
    )),
    operation_run_id = scope$operation_run_id,
    analytical_run_id = analytical_run_id,
    analytical_kind = values$analytical_kind,
    related_analytical_run_id = values$related_analytical_run_id,
    analytical_key = values$analytical_key,
    episode_id = values$episode_id,
    patient_id = values$patient_id,
    target_id = values$target_id,
    target_version = values$target_version,
    analytical_time = values$analytical_time,
    outcome = values$outcome,
    outcome_code = values$outcome_code,
    eligibility_status = values$eligibility_status,
    state = values$state,
    request = values$request,
    provider_id = values$provider_id,
    provider_version = values$provider_version,
    implementation_id = values$implementation_id,
    implementation_version = values$implementation_version,
    model_id = values$model_id,
    model_version = values$model_version,
    provider_execution_id = provider_execution_id,
    provider_status = values$provider_status,
    estimate_record_id = estimate_record_id,
    estimate = values$estimate,
    terminal_time = values$terminal_time
  ), class = c("rrp_episode_disposition", "list"))
  rrp_history_validate_disposition(disposition)
  rrp_history_copy(disposition)
}

rrp_history_action_fields <- function() c(
  "action_contract_id", "action_contract_version", "action_id", "target_kind",
  "target_id", "target_operation_run_id", "action_type", "effective_time",
  "reason_code", "replacement_operation_run_id",
  "replacement_analytical_run_id", "actor_category"
)

rrp_history_validate_action <- function(action) {
  valid <- is.list(action) &&
    identical(class(action), c("rrp_history_action", "list")) &&
    identical(names(action), rrp_history_action_fields()) &&
    all(vapply(action[c(1L, 2L, 4:9, 12L)], rrp_history_string, logical(1L))) &&
    all(vapply(action[10:11], rrp_history_nullable_string, logical(1L))) &&
    identical(action$action_contract_id, "rrp.history.action") &&
    identical(action$action_contract_version, "0.1.0") &&
    action$target_kind %in% c("analytical_run", "operational_scope") &&
    action$action_type %in% c("invalidate", "restate") &&
    action$reason_code %in% c(
      "incorrect_input", "incorrect_scope", "incorrect_provenance",
      "superseded_result"
    ) &&
    action$actor_category %in% c("maintainer", "operator") &&
    !is.na(rrp_history_time(action$effective_time)) &&
    identical(action$action_id, rrp_history_id(
      "rrp.history-action.", unname(action[-3L])
    ))
  if (!valid) rrp_history_abort("invalid_action")
  if (identical(action$target_kind, "operational_scope") &&
      !action$reason_code %in% c("incorrect_scope", "incorrect_provenance")) {
    rrp_history_abort("invalid_action")
  }
  if (identical(action$action_type, "invalidate")) {
    if (!is.null(action$replacement_operation_run_id) ||
        !is.null(action$replacement_analytical_run_id)) {
      rrp_history_abort("invalid_action")
    }
  } else if (identical(action$target_kind, "analytical_run")) {
    if (is.null(action$replacement_operation_run_id) ||
        is.null(action$replacement_analytical_run_id)) {
      rrp_history_abort("invalid_action")
    }
  } else if (is.null(action$replacement_operation_run_id) ||
             !is.null(action$replacement_analytical_run_id)) {
    rrp_history_abort("invalid_action")
  }
  invisible(action)
}

#' Construct one append-only history action
#' @param values Exact governed action values in contract order.
#' @return A detached `rrp_history_action`.
#' @export
rrp_new_history_action <- function(values) {
  fields <- setdiff(
    rrp_history_action_fields(),
    c("action_contract_id", "action_contract_version", "action_id")
  )
  if (!rrp_canonical_plain_named_list(values) || !identical(names(values), fields)) {
    rrp_history_abort("invalid_action")
  }
  action <- structure(list(
    action_contract_id = "rrp.history.action",
    action_contract_version = "0.1.0",
    action_id = rrp_history_id(
      "rrp.history-action.",
      c(list("rrp.history.action", "0.1.0"), unname(values))
    ),
    target_kind = values$target_kind,
    target_id = values$target_id,
    target_operation_run_id = values$target_operation_run_id,
    action_type = values$action_type,
    effective_time = values$effective_time,
    reason_code = values$reason_code,
    replacement_operation_run_id = values$replacement_operation_run_id,
    replacement_analytical_run_id = values$replacement_analytical_run_id,
    actor_category = values$actor_category
  ), class = c("rrp_history_action", "list"))
  rrp_history_validate_action(action)
  rrp_history_copy(action)
}

rrp_history_adapter_methods <- function() c(
  "append_scope", "append_disposition", "append_action",
  "append_restatement", "read_scope_history", "read_episode_history"
)
rrp_history_adapter_capabilities <- function() c(
  "atomic_scope_append", "atomic_episode_append", "atomic_restatement_append",
  "identical_append_idempotency", "conflicting_identity_rejection",
  "immutable_raw_retention", "bounded_raw_reads", "detached_reads"
)

#' Create a storage-neutral operational-history port
#' @param adapter A closed adapter declaration implementing the logical port.
#' @return A validated `rrp_history_port`.
#' @export
rrp_new_history_port <- function(adapter) {
  valid <- rrp_canonical_plain_named_list(adapter) &&
    identical(names(adapter), c(
      "adapter_id", "adapter_version", "contract_id", "contract_version",
      "capabilities", "methods"
    )) &&
    rrp_canonical_valid_identity(adapter$adapter_id) &&
    rrp_canonical_valid_version(adapter$adapter_version) &&
    identical(adapter$contract_id, "rrp.history.port") &&
    identical(adapter$contract_version, "0.1.0") &&
    is.list(adapter$capabilities) &&
    identical(names(adapter$capabilities), rrp_history_adapter_capabilities()) &&
    all(vapply(adapter$capabilities, identical, logical(1L), TRUE)) &&
    is.list(adapter$methods) &&
    identical(names(adapter$methods), rrp_history_adapter_methods()) &&
    all(vapply(adapter$methods, is.function, logical(1L)))
  if (!valid) rrp_history_abort("invalid_adapter")
  structure(
    list(adapter = rrp_history_copy(adapter)),
    class = c("rrp_history_port", "list")
  )
}

rrp_history_assert_port <- function(port) {
  if (!is.list(port) ||
      !identical(class(port), c("rrp_history_port", "list")) ||
      !identical(names(port), "adapter")) rrp_history_abort("invalid_adapter")
  invisible(port)
}

rrp_history_validate_raw_shape <- function(raw) {
  valid <- rrp_canonical_plain_named_list(raw) &&
    identical(names(raw), c("scopes", "dispositions", "actions")) &&
    is.list(raw$scopes) && is.list(raw$dispositions) && is.list(raw$actions)
  if (!valid) rrp_history_abort("invalid_read")
  lapply(raw$scopes, rrp_history_validate_scope)
  lapply(raw$dispositions, rrp_history_validate_disposition)
  lapply(raw$actions, rrp_history_validate_action)
  ids <- list(
    vapply(raw$scopes, `[[`, character(1L), "operation_run_id"),
    vapply(raw$dispositions, `[[`, character(1L), "analytical_run_id"),
    vapply(raw$actions, `[[`, character(1L), "action_id")
  )
  if (any(vapply(ids, anyDuplicated, integer(1L)) > 0L)) {
    rrp_history_abort("invalid_read")
  }
  rrp_history_copy(raw)
}

rrp_history_find_one <- function(records, field, value) {
  selected <- Filter(function(record) identical(record[[field]], value), records)
  if (length(selected) != 1L) rrp_history_abort("relationship_conflict")
  selected[[1L]]
}

rrp_history_validate_graph <- function(raw) {
  raw <- rrp_history_validate_raw_shape(raw)
  for (disposition in raw$dispositions) {
    scope <- rrp_history_find_one(
      raw$scopes, "operation_run_id", disposition$operation_run_id
    )
    if (!identical(disposition$target_id, scope$target_id) ||
        !identical(disposition$target_version, scope$target_version) ||
        !identical(disposition$analytical_time, scope$analytical_time)) {
      rrp_history_abort("relationship_conflict")
    }
    if (!identical(disposition$analytical_kind, "initial")) {
      parent <- rrp_history_find_one(
        raw$dispositions, "analytical_run_id",
        disposition$related_analytical_run_id
      )
      if (!identical(parent$episode_id, disposition$episode_id) ||
          !identical(parent$target_id, disposition$target_id) ||
          !identical(parent$target_version, disposition$target_version) ||
          !identical(parent$analytical_time, disposition$analytical_time)) {
        rrp_history_abort("relationship_conflict")
      }
      if (identical(disposition$analytical_kind, "retry") &&
          !parent$outcome %in% c("provider_declared_failure", "detected_failure")) {
        rrp_history_abort("relationship_conflict")
      }
    }
  }
  initial <- Filter(function(value) identical(value$analytical_kind, "initial"),
    raw$dispositions)
  initial_keys <- vapply(initial, function(value) {
    paste(value$operation_run_id, value$episode_id, sep = "\r")
  }, character(1L))
  if (anyDuplicated(initial_keys)) rrp_history_abort("relationship_conflict")
  children <- Filter(function(value) !is.null(value$related_analytical_run_id),
    raw$dispositions)
  child_parents <- vapply(
    children, `[[`, character(1L), "related_analytical_run_id"
  )
  if (anyDuplicated(child_parents)) rrp_history_abort("relationship_conflict")

  restatement_targets <- character()
  for (action in raw$actions) {
    if (identical(action$target_kind, "operational_scope")) {
      target <- rrp_history_find_one(raw$scopes, "operation_run_id", action$target_id)
      target_time <- target$created_at
      if (!identical(action$target_operation_run_id, target$operation_run_id)) {
        rrp_history_abort("relationship_conflict")
      }
      if (identical(action$action_type, "restate")) {
        replacement <- rrp_history_find_one(
          raw$scopes, "operation_run_id", action$replacement_operation_run_id
        )
        if (identical(replacement$operation_run_id, target$operation_run_id)) {
          rrp_history_abort("relationship_conflict")
        }
        replacement_time <- replacement$created_at
        restatement_targets <- c(
          restatement_targets, paste(action$target_kind, action$target_id, sep = "\r")
        )
      } else replacement_time <- NULL
    } else {
      target <- rrp_history_find_one(
        raw$dispositions, "analytical_run_id", action$target_id
      )
      target_time <- target$terminal_time
      if (!identical(action$target_operation_run_id, target$operation_run_id)) {
        rrp_history_abort("relationship_conflict")
      }
      if (identical(action$action_type, "restate")) {
        replacement <- rrp_history_find_one(
          raw$dispositions, "analytical_run_id",
          action$replacement_analytical_run_id
        )
        if (!identical(replacement$operation_run_id,
            action$replacement_operation_run_id) ||
            !identical(replacement$analytical_kind, "restatement") ||
            !identical(replacement$related_analytical_run_id,
              target$analytical_run_id)) {
          rrp_history_abort("relationship_conflict")
        }
        replacement_time <- replacement$terminal_time
        restatement_targets <- c(
          restatement_targets, paste(action$target_kind, action$target_id, sep = "\r")
        )
      } else replacement_time <- NULL
    }
    effective <- rrp_history_time(action$effective_time)
    if (effective < rrp_history_time(target_time) ||
        (!is.null(replacement_time) &&
          effective < rrp_history_time(replacement_time))) {
      rrp_history_abort("relationship_conflict")
    }
  }
  if (anyDuplicated(restatement_targets)) rrp_history_abort("relationship_conflict")
  restatements <- Filter(function(value) {
    identical(value$analytical_kind, "restatement")
  }, raw$dispositions)
  replacements <- vapply(Filter(function(action) {
    identical(action$action_type, "restate") &&
      identical(action$target_kind, "analytical_run")
  }, raw$actions), `[[`, character(1L), "replacement_analytical_run_id")
  if (length(restatements) && !all(vapply(
    restatements, `[[`, character(1L), "analytical_run_id"
  ) %in% replacements)) rrp_history_abort("relationship_conflict")
  raw
}

rrp_history_merge_records <- function(first, second, id_field) {
  output <- first
  for (candidate in second) {
    ids <- vapply(output, `[[`, character(1L), id_field)
    at <- which(ids == candidate[[id_field]])
    if (!length(at)) {
      output[[length(output) + 1L]] <- candidate
    } else if (!identical(output[[at[[1L]]]], candidate)) {
      rrp_history_abort("identity_conflict")
    }
  }
  output
}

rrp_history_merge_raw <- function(first, second) {
  first <- rrp_history_validate_raw_shape(first)
  second <- rrp_history_validate_raw_shape(second)
  list(
    scopes = rrp_history_merge_records(
      first$scopes, second$scopes, "operation_run_id"
    ),
    dispositions = rrp_history_merge_records(
      first$dispositions, second$dispositions, "analytical_run_id"
    ),
    actions = rrp_history_merge_records(first$actions, second$actions, "action_id")
  )
}

rrp_history_adapter_scope_raw <- function(port, operation_run_id) {
  rrp_history_validate_graph(
    port$adapter$methods$read_scope_history(operation_run_id)
  )
}

#' Append or match an immutable operational scope
#' @param port A validated history port.
#' @param scope A validated operational scope.
#' @return A detached copy of `scope`.
#' @export
rrp_history_append_scope <- function(port, scope) {
  rrp_history_assert_port(port)
  rrp_history_validate_scope(scope)
  raw <- rrp_history_adapter_scope_raw(port, scope$operation_run_id)
  existing <- Filter(function(value) {
    identical(value$operation_run_id, scope$operation_run_id)
  }, raw$scopes)
  if (length(existing) && !identical(existing[[1L]], scope)) {
    rrp_history_abort("identity_conflict")
  }
  port$adapter$methods$append_scope(rrp_history_copy(scope))
  invisible(rrp_history_copy(scope))
}

#' Append one terminal episode disposition
#' @param port A validated history port.
#' @param disposition A validated terminal disposition.
#' @return A detached copy of `disposition`.
#' @export
rrp_history_append_disposition <- function(port, disposition) {
  rrp_history_assert_port(port)
  rrp_history_validate_disposition(disposition)
  raw <- rrp_history_adapter_scope_raw(port, disposition$operation_run_id)
  existing <- Filter(function(value) {
    identical(value$analytical_run_id, disposition$analytical_run_id)
  }, raw$dispositions)
  if (length(existing) && !identical(existing[[1L]], disposition)) {
    rrp_history_abort("identity_conflict")
  }
  candidate <- raw
  if (!length(existing)) {
    candidate$dispositions[[length(candidate$dispositions) + 1L]] <- disposition
  }
  rrp_history_validate_graph(candidate)
  port$adapter$methods$append_disposition(rrp_history_copy(disposition))
  invisible(rrp_history_copy(disposition))
}

#' Append one immutable invalidation
#' @param port A validated history port.
#' @param action A validated invalidation action.
#' @return A detached copy of `action`.
#' @export
rrp_history_append_invalidation <- function(port, action) {
  rrp_history_assert_port(port)
  rrp_history_validate_action(action)
  if (!identical(action$action_type, "invalidate")) {
    rrp_history_abort("invalid_action")
  }
  raw <- rrp_history_adapter_scope_raw(port, action$target_operation_run_id)
  existing <- Filter(function(value) identical(value$action_id, action$action_id),
    raw$actions)
  if (length(existing) && !identical(existing[[1L]], action)) {
    rrp_history_abort("identity_conflict")
  }
  if (!length(existing)) raw$actions[[length(raw$actions) + 1L]] <- action
  rrp_history_validate_graph(raw)
  port$adapter$methods$append_action(rrp_history_copy(action))
  invisible(rrp_history_copy(action))
}

#' Atomically append replacement history and its restatement action
#' @param port A validated history port.
#' @param replacement A replacement disposition or operational scope.
#' @param action The matching restatement action.
#' @return A detached list containing `replacement` and `action`.
#' @export
rrp_history_append_restatement <- function(port, replacement, action) {
  rrp_history_assert_port(port)
  rrp_history_validate_action(action)
  if (!identical(action$action_type, "restate")) {
    rrp_history_abort("invalid_action")
  }
  target_raw <- rrp_history_adapter_scope_raw(port, action$target_operation_run_id)
  if (inherits(replacement, "rrp_episode_disposition")) {
    rrp_history_validate_disposition(replacement)
    valid_link <- identical(action$target_kind, "analytical_run") &&
      identical(action$replacement_operation_run_id,
        replacement$operation_run_id) &&
      identical(action$replacement_analytical_run_id,
        replacement$analytical_run_id)
    replacement_operation <- replacement$operation_run_id
    collection <- "dispositions"
    identity_field <- "analytical_run_id"
  } else if (inherits(replacement, "rrp_operational_scope")) {
    rrp_history_validate_scope(replacement)
    valid_link <- identical(action$target_kind, "operational_scope") &&
      identical(action$replacement_operation_run_id,
        replacement$operation_run_id) &&
      is.null(action$replacement_analytical_run_id)
    replacement_operation <- replacement$operation_run_id
    collection <- "scopes"
    identity_field <- "operation_run_id"
  } else {
    rrp_history_abort("relationship_conflict")
  }
  if (!valid_link) rrp_history_abort("relationship_conflict")
  raw <- target_raw
  if (!identical(replacement_operation, action$target_operation_run_id)) {
    raw <- rrp_history_merge_raw(
      raw, rrp_history_adapter_scope_raw(port, replacement_operation)
    )
  }
  existing <- Filter(function(value) {
    identical(value[[identity_field]], replacement[[identity_field]])
  }, raw[[collection]])
  if (length(existing) && !identical(existing[[1L]], replacement)) {
    rrp_history_abort("identity_conflict")
  }
  if (!length(existing)) {
    raw[[collection]][[length(raw[[collection]]) + 1L]] <- replacement
  }
  existing_action <- Filter(function(value) identical(value$action_id, action$action_id),
    raw$actions)
  if (length(existing_action) && !identical(existing_action[[1L]], action)) {
    rrp_history_abort("identity_conflict")
  }
  if (!length(existing_action)) raw$actions[[length(raw$actions) + 1L]] <- action
  rrp_history_validate_graph(raw)
  port$adapter$methods$append_restatement(
    rrp_history_copy(replacement), rrp_history_copy(action)
  )
  invisible(rrp_history_copy(list(replacement = replacement, action = action)))
}

rrp_history_progress <- function(scope, dispositions) {
  initial <- Filter(function(value) {
    identical(value$operation_run_id, scope$operation_run_id) &&
      identical(value$analytical_kind, "initial")
  }, dispositions)
  ids <- vapply(initial, `[[`, character(1L), "episode_id")
  unique_ids <- !anyDuplicated(ids)
  fingerprint <- if (unique_ids) {
    tryCatch(
      rrp_history_membership_fingerprint(ids),
      error = function(condition) NA_character_
    )
  } else NA_character_
  list(
    expected_episode_count = scope$expected_episode_count,
    dispositioned_episode_count = as.integer(length(ids)),
    complete = unique_ids && length(ids) == scope$expected_episode_count &&
      identical(fingerprint, scope$membership_fingerprint)
  )
}

#' Read one raw operational scope and its derived progress
#' @param port A validated history port.
#' @param operation_run_id One exact operation-run identity.
#' @return Scope, progress, dispositions, and actions as detached records.
#' @export
rrp_history_read_scope <- function(port, operation_run_id) {
  rrp_history_assert_port(port)
  if (!rrp_canonical_valid_identity(operation_run_id)) {
    rrp_history_abort("invalid_read")
  }
  raw <- rrp_history_adapter_scope_raw(port, operation_run_id)
  scopes <- Filter(function(value) {
    identical(value$operation_run_id, operation_run_id)
  }, raw$scopes)
  if (length(scopes) != 1L) rrp_history_abort("invalid_read")
  scope <- scopes[[1L]]
  rrp_history_copy(list(
    scope = scope,
    progress = rrp_history_progress(scope, raw$dispositions),
    dispositions = Filter(function(value) {
      identical(value$operation_run_id, operation_run_id)
    }, raw$dispositions),
    actions = Filter(function(value) {
      identical(value$target_operation_run_id, operation_run_id) ||
        identical(value$replacement_operation_run_id, operation_run_id)
    }, raw$actions)
  ))
}

rrp_history_episode_candidates <- function(
  port, episode_id, target_id, history_cutoff
) {
  rrp_history_assert_port(port)
  if (!rrp_canonical_valid_identity(episode_id) ||
      !rrp_canonical_valid_identity(target_id) ||
      is.na(rrp_history_time(history_cutoff))) rrp_history_abort("invalid_read")
  raw <- rrp_history_validate_graph(port$adapter$methods$read_episode_history(
    episode_id, target_id, history_cutoff
  ))
  cutoff <- rrp_history_time(history_cutoff)
  raw$scopes <- Filter(function(value) {
    rrp_history_time(value$created_at) <= cutoff
  }, raw$scopes)
  scope_ids <- vapply(raw$scopes, `[[`, character(1L), "operation_run_id")
  raw$dispositions <- Filter(function(value) {
    value$operation_run_id %in% scope_ids &&
      rrp_history_time(value$terminal_time) <= cutoff
  }, raw$dispositions)
  raw$actions <- Filter(function(value) {
    rrp_history_time(value$effective_time) <= cutoff
  }, raw$actions)
  raw
}

#' Read bounded immutable episode history
#' @param port A validated history port.
#' @param episode_id One opaque episode identity.
#' @param target_id One exact target identity.
#' @param history_cutoff Explicit history-time cutoff.
#' @return Detached raw scopes, episode dispositions, and actions.
#' @export
rrp_history_read_episode <- function(port, episode_id, target_id, history_cutoff) {
  raw <- rrp_history_episode_candidates(port, episode_id, target_id, history_cutoff)
  selected <- Filter(function(value) {
    identical(value$episode_id, episode_id) && identical(value$target_id, target_id)
  }, raw$dispositions)
  analytical_ids <- vapply(selected, `[[`, character(1L), "analytical_run_id")
  operation_ids <- vapply(selected, `[[`, character(1L), "operation_run_id")
  rrp_history_copy(list(
    scopes = Filter(function(value) {
      value$operation_run_id %in% operation_ids
    }, raw$scopes),
    dispositions = selected,
    actions = Filter(function(value) {
      (identical(value$target_kind, "analytical_run") &&
        value$target_id %in% analytical_ids) ||
        (identical(value$target_kind, "operational_scope") &&
          value$target_id %in% operation_ids)
    }, raw$actions)
  ))
}

#' Resolve effective current terminal history for one episode
#' @param port A validated history port.
#' @param episode_id One opaque episode identity.
#' @param target_id One exact target identity.
#' @param analytical_cutoff Explicit analytical-time cutoff.
#' @param history_cutoff Explicit history-time cutoff.
#' @return One detached current disposition, or `NULL`.
#' @export
rrp_history_read_current <- function(
  port, episode_id, target_id, analytical_cutoff, history_cutoff
) {
  if (is.na(rrp_history_time(analytical_cutoff))) {
    rrp_history_abort("invalid_read")
  }
  raw <- rrp_history_episode_candidates(port, episode_id, target_id, history_cutoff)
  complete <- vapply(raw$scopes, function(scope) {
    rrp_history_progress(scope, raw$dispositions)$complete
  }, logical(1L))
  complete_scope_ids <- vapply(
    raw$scopes[complete], `[[`, character(1L), "operation_run_id"
  )
  excluded_scopes <- vapply(Filter(function(action) {
    identical(action$target_kind, "operational_scope")
  }, raw$actions), `[[`, character(1L), "target_id")
  excluded_analyses <- vapply(Filter(function(action) {
    identical(action$target_kind, "analytical_run")
  }, raw$actions), `[[`, character(1L), "target_id")
  cutoff <- rrp_history_time(analytical_cutoff)
  values <- Filter(function(value) {
    identical(value$episode_id, episode_id) &&
      identical(value$target_id, target_id) &&
      value$operation_run_id %in% setdiff(complete_scope_ids, excluded_scopes) &&
      !value$analytical_run_id %in% excluded_analyses &&
      rrp_history_time(value$analytical_time) <= cutoff
  }, raw$dispositions)
  if (!length(values)) return(NULL)
  parents <- vapply(Filter(function(value) {
    !is.null(value$related_analytical_run_id)
  }, values), `[[`, character(1L), "related_analytical_run_id")
  leaves <- Filter(function(value) !value$analytical_run_id %in% parents, values)
  if (!length(leaves)) rrp_history_abort("ambiguous_current")
  times <- vapply(leaves, function(value) {
    rrp_history_time(value$analytical_time)
  }, numeric(1L))
  candidates <- leaves[times == max(times)]
  if (length(candidates) != 1L) rrp_history_abort("ambiguous_current")
  rrp_history_copy(candidates[[1L]])
}
