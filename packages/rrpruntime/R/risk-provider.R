rrp_provider_context_fields <- function() {
  c(
    "product_id", "development_version", "target_id", "target_version",
    "state_contract_id", "state_contract_version", "request_contract_id",
    "request_contract_version", "provider_api_id", "provider_api_version",
    "estimate_contract_id", "estimate_contract_version", "request_class",
    "estimate_class", "target_interval_boundary", "output_type",
    "output_minimum", "output_maximum"
  )
}

rrp_provider_fields <- function() {
  c(
    "component_id", "component_version", "provider_api_id",
    "provider_api_version", "target_id", "target_version",
    "state_contract_id", "state_contract_version", "request_contract_id",
    "request_contract_version", "estimate_contract_id",
    "estimate_contract_version", "implementation_id",
    "implementation_version", "model_id", "model_version", "callable"
  )
}

rrp_risk_request_fields <- function() {
  c(
    "request_contract_id", "request_contract_version", "request_id",
    "target_id", "target_version", "state_contract_id",
    "state_contract_version", "state_id", "bundle_instance_id",
    "project_id", "project_version", "episode_id", "as_of_time",
    "discharge_time", "target_interval_start", "target_interval_end",
    "target_interval_boundary", "elapsed_seconds_since_discharge",
    "remaining_seconds_through_w30"
  )
}

rrp_risk_estimate_fields <- function() {
  c(
    "estimate_contract_id", "estimate_contract_version",
    "request_contract_id", "request_contract_version", "request_id",
    "state_contract_id", "state_contract_version", "state_id", "target_id",
    "target_version", "product_id", "development_version",
    "bundle_instance_id", "project_id", "project_version", "episode_id",
    "as_of_time", "target_interval_start", "target_interval_end",
    "target_interval_boundary", "provider_id", "provider_version",
    "implementation_id", "implementation_version", "model_id",
    "model_version", "output_type", "estimate_value"
  )
}

rrp_runtime_validate_provider_context <- function(expected_context) {
  expected <- list(
    product_id = "readmission-risk-pool-platform",
    development_version = "1.0.0-dev",
    target_id = "rrp.risk-target.readmission-remaining-30-day",
    target_version = "0.1.0",
    state_contract_id = "rrp.episode-state",
    state_contract_version = "0.1.0",
    request_contract_id = "rrp.risk-request",
    request_contract_version = "0.1.0",
    provider_api_id = "rrp.provider-api",
    provider_api_version = "0.1.0",
    estimate_contract_id = "rrp.risk-estimate",
    estimate_contract_version = "0.1.0",
    request_class = "rrp_risk_request,list",
    estimate_class = "rrp_risk_estimate,list",
    target_interval_boundary = "(start,end]",
    output_type = "probability",
    output_minimum = 0,
    output_maximum = 1
  )
  valid <- rrp_canonical_plain_named_list(expected_context) &&
    identical(names(expected_context), rrp_provider_context_fields()) &&
    !rrp_canonical_has_unsafe_value(expected_context) &&
    identical(expected_context, expected)
  if (!valid) rrp_runtime_abort("invalid_expected_context")
  invisible(expected_context)
}

rrp_runtime_validate_provider <- function(provider, expected_context) {
  valid_shape <- rrp_canonical_plain_named_list(provider) &&
    identical(names(provider), rrp_provider_fields()) &&
    is.function(provider$callable)
  if (!valid_shape) rrp_runtime_abort("provider_incompatible")

  identities <- c(
    "component_id", "provider_api_id", "target_id", "state_contract_id",
    "request_contract_id", "estimate_contract_id", "implementation_id"
  )
  versions <- c(
    "component_version", "provider_api_version", "target_version",
    "state_contract_version", "request_contract_version",
    "estimate_contract_version", "implementation_version"
  )
  if (any(!vapply(provider[identities], rrp_canonical_valid_identity, logical(1L))) ||
      any(!vapply(provider[versions], rrp_canonical_valid_version, logical(1L)))) {
    rrp_runtime_abort("provider_incompatible")
  }
  fixed <- c(
    provider_api_id = "provider_api_id",
    provider_api_version = "provider_api_version",
    target_id = "target_id", target_version = "target_version",
    state_contract_id = "state_contract_id",
    state_contract_version = "state_contract_version",
    request_contract_id = "request_contract_id",
    request_contract_version = "request_contract_version",
    estimate_contract_id = "estimate_contract_id",
    estimate_contract_version = "estimate_contract_version"
  )
  if (any(!vapply(names(fixed), function(field) {
    identical(provider[[field]], expected_context[[fixed[[field]]]])
  }, logical(1L)))) rrp_runtime_abort("provider_incompatible")

  model_null <- is.null(provider$model_id) && is.null(provider$model_version)
  model_set <- rrp_canonical_valid_identity(provider$model_id) &&
    rrp_canonical_valid_version(provider$model_version)
  if (!model_null && !model_set) rrp_runtime_abort("provider_incompatible")
  arguments <- formals(provider$callable)
  if (!identical(names(arguments), "request")) {
    rrp_runtime_abort("provider_incompatible")
  }
  invisible(provider)
}

rrp_runtime_validate_provider_state <- function(episode_state, expected_context) {
  valid <- tryCatch({
    rrp_runtime_validate_episode_state(episode_state)
    TRUE
  }, error = function(condition) FALSE)
  if (!valid || !identical(episode_state$target_id, expected_context$target_id) ||
      !identical(episode_state$target_version, expected_context$target_version) ||
      !identical(
        episode_state$state_contract_id, expected_context$state_contract_id
      ) || !identical(
        episode_state$state_contract_version,
        expected_context$state_contract_version
      ) || !identical(
        episode_state$remaining_seconds_through_w30,
        as.numeric(
          rrp_canonical_timestamp_number(episode_state$target_window_end) -
            rrp_canonical_timestamp_number(episode_state$as_of_time)
        )
      ) || !identical(
        episode_state$elapsed_seconds_since_discharge,
        as.numeric(
          rrp_canonical_timestamp_number(episode_state$as_of_time) -
            rrp_canonical_timestamp_number(episode_state$discharge_time)
        )
      ) || episode_state$remaining_seconds_through_w30 <= 0 ||
      episode_state$elapsed_seconds_since_discharge < 0) {
    rrp_runtime_abort("provider_incompatible")
  }
  identity_values <- list(
    episode_state$bundle_contract_id, episode_state$bundle_contract_version,
    episode_state$bundle_instance_id, episode_state$project_id,
    episode_state$project_version, episode_state$canonical_profile_id,
    episode_state$canonical_profile_version, episode_state$episode_id,
    episode_state$as_of_time, episode_state$discharge_time,
    episode_state$target_window_end, episode_state$target_id,
    episode_state$target_version, episode_state$state_contract_id,
    episode_state$state_contract_version
  )
  if (!identical(
    episode_state$state_id, rrp_runtime_state_identity(identity_values)
  )) rrp_runtime_abort("provider_incompatible")
  invisible(episode_state)
}

rrp_runtime_identity <- function(prefix, values) {
  serialized <- paste(vapply(values, function(value) {
    value <- enc2utf8(as.character(value))
    paste0(nchar(value, type = "bytes"), ":", value)
  }, character(1L)), collapse = "|")
  first <- rrp_runtime_hash(serialized, 257, 2147483629)
  second <- rrp_runtime_hash(serialized, 263, 2147483587)
  paste0(prefix, sprintf("%08x%08x", first, second))
}

rrp_runtime_risk_request <- function(episode_state, expected_context) {
  values <- list(
    request_contract_id = expected_context$request_contract_id,
    request_contract_version = expected_context$request_contract_version,
    target_id = episode_state$target_id,
    target_version = episode_state$target_version,
    state_contract_id = episode_state$state_contract_id,
    state_contract_version = episode_state$state_contract_version,
    state_id = episode_state$state_id,
    bundle_instance_id = episode_state$bundle_instance_id,
    project_id = episode_state$project_id,
    project_version = episode_state$project_version,
    episode_id = episode_state$episode_id,
    as_of_time = episode_state$as_of_time,
    discharge_time = episode_state$discharge_time,
    target_interval_start = episode_state$as_of_time,
    target_interval_end = episode_state$target_window_end,
    target_interval_boundary = expected_context$target_interval_boundary,
    elapsed_seconds_since_discharge = episode_state$elapsed_seconds_since_discharge,
    remaining_seconds_through_w30 = episode_state$remaining_seconds_through_w30
  )
  request <- c(
    values[1:2],
    list(request_id = rrp_runtime_identity("rrp.request.", values)),
    values[-(1:2)]
  )
  request <- structure(request, class = c("rrp_risk_request", "list"))
  if (!identical(names(request), rrp_risk_request_fields()) ||
      rrp_canonical_has_unsafe_value(request)) {
    stop("Invalid internal risk-request construction.", call. = FALSE)
  }
  request
}

rrp_runtime_invoke_provider <- function(provider, request) {
  outcome <- tryCatch(
    list(returned = TRUE, value = provider$callable(
      unserialize(serialize(request, NULL))
    )),
    error = function(condition) list(returned = FALSE, value = NULL)
  )
  if (!identical(outcome$returned, TRUE)) {
    rrp_runtime_abort("provider_execution_failed")
  }
  outcome$value
}

rrp_runtime_provider_result <- function(result, request, expected_context) {
  fields <- c("request_id", "status", "estimate_value", "failure_code")
  if (!rrp_canonical_plain_named_list(result) ||
      !identical(names(result), fields) ||
      rrp_canonical_has_unsafe_value(result) ||
      !rrp_canonical_scalar_string(result$request_id) ||
      !rrp_canonical_scalar_string(result$status) ||
      !result$status %in% c("success", "failure")) {
    rrp_runtime_abort("invalid_provider_result")
  }
  if (!identical(result$request_id, request$request_id)) {
    rrp_runtime_abort("provider_result_identity_mismatch")
  }
  if (identical(result$status, "failure")) {
    failures <- c(
      "provider_unavailable", "provider_input_unavailable",
      "provider_calculation_failed"
    )
    if (!is.null(result$estimate_value) ||
        !rrp_canonical_scalar_string(result$failure_code) ||
        !result$failure_code %in% failures) {
      rrp_runtime_abort("invalid_provider_result")
    }
    rrp_runtime_abort(result$failure_code)
  }
  if (!is.null(result$failure_code)) {
    rrp_runtime_abort("invalid_provider_result")
  }
  value <- result$estimate_value
  if (!is.double(value) || length(value) != 1L || !is.finite(value) ||
      !is.null(attributes(value)) || value < expected_context$output_minimum ||
      value > expected_context$output_maximum) {
    rrp_runtime_abort("invalid_estimate")
  }
  value
}

rrp_runtime_risk_estimate <- function(
  request,
  provider,
  estimate_value,
  expected_context
) {
  estimate <- structure(list(
    estimate_contract_id = expected_context$estimate_contract_id,
    estimate_contract_version = expected_context$estimate_contract_version,
    request_contract_id = request$request_contract_id,
    request_contract_version = request$request_contract_version,
    request_id = request$request_id,
    state_contract_id = request$state_contract_id,
    state_contract_version = request$state_contract_version,
    state_id = request$state_id,
    target_id = request$target_id,
    target_version = request$target_version,
    product_id = expected_context$product_id,
    development_version = expected_context$development_version,
    bundle_instance_id = request$bundle_instance_id,
    project_id = request$project_id,
    project_version = request$project_version,
    episode_id = request$episode_id,
    as_of_time = request$as_of_time,
    target_interval_start = request$target_interval_start,
    target_interval_end = request$target_interval_end,
    target_interval_boundary = request$target_interval_boundary,
    provider_id = provider$component_id,
    provider_version = provider$component_version,
    implementation_id = provider$implementation_id,
    implementation_version = provider$implementation_version,
    model_id = provider$model_id,
    model_version = provider$model_version,
    output_type = expected_context$output_type,
    estimate_value = estimate_value
  ), class = c("rrp_risk_estimate", "list"))
  if (!identical(names(estimate), rrp_risk_estimate_fields()) ||
      rrp_canonical_has_unsafe_value(estimate)) {
    stop("Invalid internal risk-estimate construction.", call. = FALSE)
  }
  estimate
}

rrp_runtime_risk_evidence <- function(
  episode_state,
  provider,
  expected_context
) {
  rrp_runtime_validate_provider_context(expected_context)
  rrp_runtime_validate_provider_state(episode_state, expected_context)

  compatibility <- tryCatch({
    rrp_runtime_validate_provider(provider, expected_context)
    NULL
  }, rrp_runtime_error = identity)
  if (!is.null(compatibility)) return(list(
    outcome = "provider_incompatible",
    outcome_code = compatibility$code,
    provider_status = "not_invoked",
    request = NULL,
    estimate = NULL
  ))

  request <- rrp_runtime_risk_request(episode_state, expected_context)
  execution <- tryCatch({
    value <- rrp_runtime_provider_result(
      rrp_runtime_invoke_provider(provider, request), request, expected_context
    )
    list(
      outcome = "accepted_estimate",
      outcome_code = "estimate_accepted",
      provider_status = "succeeded",
      request = request,
      estimate = rrp_runtime_risk_estimate(
        request, provider, value, expected_context
      )
    )
  }, rrp_runtime_error = function(condition) {
    declared <- condition$code %in% c(
      "provider_unavailable", "provider_input_unavailable",
      "provider_calculation_failed"
    )
    list(
      outcome = if (declared) {
        "provider_declared_failure"
      } else {
        "detected_failure"
      },
      outcome_code = condition$code,
      provider_status = if (declared) "declared_failure" else "detected_failure",
      request = request,
      estimate = NULL
    )
  })
  unserialize(serialize(execution, NULL))
}

#' Execute one compatible risk provider
#'
#' Revalidate an immutable episode state and one explicit semantic provider,
#' construct the provider-neutral request, invoke the provider exactly once,
#' and return one detached accepted probability estimate. Expected failures
#' are bounded `rrp_runtime_error` conditions.
#'
#' @param episode_state One eligible `rrp_episode_state`.
#' @param provider One closed semantic provider declaration and trusted callable.
#' @param expected_context The exact software and runtime contract context.
#' @return One detached object with class `c("rrp_risk_estimate", "list")`.
#' @export
rrp_execute_risk_provider <- function(
  episode_state,
  provider,
  expected_context
) {
  evidence <- rrp_runtime_risk_evidence(
    episode_state, provider, expected_context
  )
  if (!identical(evidence$outcome, "accepted_estimate")) {
    rrp_runtime_abort(evidence$outcome_code)
  }
  evidence$estimate
}
