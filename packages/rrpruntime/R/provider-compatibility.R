rrp_provider_compatibility_result <- function(status, provider, issues = list()) {
  issues <- rrp_runtime_bind_issues(issues)
  structure(
    list(
      overall_status = if (identical(status, "compatible")) "pass" else "fail",
      compatibility_status = status,
      provider_reference = rrp_provider_reference(provider),
      issues = issues
    ),
    class = c("rrp_provider_compatibility_result", "rrp_runtime_conformance_result")
  )
}

rrp_supported_estimand_declaration <- function(provider, estimand) {
  matches <- Filter(function(item) {
    identical(item$specification_id, estimand$specification_id) &&
      rrp_version_in_range(
        estimand$specification_version,
        item$minimum_version,
        item$maximum_version
      )
  }, provider$supported_estimands)
  if (length(matches) == 1L) matches[[1L]] else NULL
}

rrp_capability_status <- function(capabilities, capability_id) {
  matches <- Filter(function(item) {
    identical(item$capability_id, capability_id)
  }, capabilities)
  if (length(matches) == 1L) matches[[1L]]$status else NA_character_
}

rrp_provider_missing_input_issues <- function(provider, state, request) {
  issues <- list()
  capabilities <- request$capability_statuses
  for (capability_id in unlist(provider$required_capabilities, use.names = FALSE)) {
    if (!identical(rrp_capability_status(capabilities, capability_id), "available")) {
      issues[[length(issues) + 1L]] <- rrp_runtime_issue(
        "provider.compatibility.capability", "missing_required_capability",
        paste0("Provider requires available capability: ", capability_id, "."),
        "$.request.capability_statuses"
      )
    }
  }
  required_fields <- unlist(
    provider$supported_state$required_fields, use.names = FALSE
  )
  missing_fields <- required_fields[!required_fields %in% names(state)]
  if (length(missing_fields) > 0L) {
    issues[[length(issues) + 1L]] <- rrp_runtime_issue(
      "provider.compatibility.state_fields", "missing_required_state_field",
      paste0("Provider-required state fields are missing: ", paste(missing_fields, collapse = ", "), "."),
      "$.state"
    )
  }
  requirements <- provider$input_requirements
  for (field in c("available_baseline_risk", "available_episode_events")) {
    if (identical(requirements[[field]], "required") &&
        (is.null(state[[field]]) || length(state[[field]]) == 0L)) {
      issues[[length(issues) + 1L]] <- rrp_runtime_issue(
        "provider.compatibility.provider_input", "missing_required_provider_input",
        paste0("Provider requires non-empty state input: ", field, "."),
        paste0("$.state.", field)
      )
    }
  }
  issues
}

#' Validate a provider against one state and estimand request
#' @export
validate_provider_compatibility <- function(
  provider,
  request,
  state,
  runtime_contracts
) {
  rrp_assert_runtime_conforms(
    validate_runtime_contracts(runtime_contracts), "Runtime contracts"
  )
  unsupported <- list()
  if (!identical(provider$status, "active")) {
    unsupported[[length(unsupported) + 1L]] <- rrp_runtime_issue(
      "provider.compatibility.lifecycle", "provider_not_selectable",
      "Only an active registered provider can be selected.", "$.provider.status"
    )
  }
  estimand <- request$estimand_specification
  declaration <- rrp_supported_estimand_declaration(provider, estimand)
  if (is.null(declaration)) {
    unsupported[[length(unsupported) + 1L]] <- rrp_runtime_issue(
      "provider.compatibility.estimand", "unsupported_estimand",
      "Provider does not support the request estimand identity/version.",
      "$.request.estimand_specification"
    )
  }
  state_specification <- state$state_specification
  supported_state <- provider$supported_state
  state_supported <- is.list(state_specification) &&
    identical(
      state_specification$specification_id, supported_state$specification_id
    ) &&
    rrp_version_in_range(
      state_specification$specification_version,
      supported_state$minimum_version,
      supported_state$maximum_version
    )
  if (!state_supported) {
    unsupported[[length(unsupported) + 1L]] <- rrp_runtime_issue(
      "provider.compatibility.state", "unsupported_state_version",
      "Provider does not support the state identity/version.",
      "$.state.state_specification"
    )
  }
  alignment_ok <- identical(request$state_reference$state_id, state$state_id) &&
    identical(request$episode_id, state$episode_id) &&
    identical(request$as_of_time, state$as_of_time)
  if (!alignment_ok) {
    unsupported[[length(unsupported) + 1L]] <- rrp_runtime_issue(
      "provider.compatibility.alignment", "request_state_mismatch",
      "Request and state identity/as-of references do not align.", "$"
    )
  }
  start <- rrp_time_number(request$target_interval_start)
  end <- rrp_time_number(request$target_interval_end)
  interval_days <- (end - start) / 86400
  if (!is.finite(interval_days) || interval_days <= 0 ||
      (!is.null(declaration) && interval_days > declaration$maximum_interval_days)) {
    unsupported[[length(unsupported) + 1L]] <- rrp_runtime_issue(
      "provider.compatibility.interval", "unsupported_target_interval",
      "Provider does not support the requested target interval.",
      "$.request.target_interval_end"
    )
  }
  has_followup <- "days_since_discharge" %in% names(state)
  valid_followup <- has_followup && is.numeric(state$days_since_discharge) &&
    length(state$days_since_discharge) == 1L &&
    is.finite(state$days_since_discharge) &&
    state$days_since_discharge >= 0 &&
    is.finite(interval_days)
  followup_days <- if (valid_followup) {
    state$days_since_discharge + interval_days
  } else NA_real_
  if (!is.null(declaration) && has_followup &&
      (!valid_followup ||
       followup_days > declaration$maximum_followup_days)) {
    unsupported[[length(unsupported) + 1L]] <- rrp_runtime_issue(
      "provider.compatibility.followup", "unsupported_followup_horizon",
      "Provider does not support the request's discharge-relative follow-up horizon.",
      "$.state.days_since_discharge"
    )
  }
  output_ok <- any(vapply(provider$supported_outputs, function(output) {
    identical(output$output_type, "probability") &&
      identical(as.numeric(output$minimum), 0) &&
      identical(as.numeric(output$maximum), 1) &&
      identical(output$cardinality_per_request, "one")
  }, logical(1)))
  if (!output_ok) {
    unsupported[[length(unsupported) + 1L]] <- rrp_runtime_issue(
      "provider.compatibility.output", "unsupported_output_semantics",
      "Provider does not declare one bounded probability per request.",
      "$.provider.supported_outputs"
    )
  }
  if (length(unsupported) > 0L) {
    return(rrp_provider_compatibility_result("unsupported", provider, unsupported))
  }
  missing <- rrp_provider_missing_input_issues(provider, state, request)
  if (length(missing) > 0L) {
    return(rrp_provider_compatibility_result(
      "missing_required_input", provider, missing
    ))
  }
  rrp_provider_compatibility_result("compatible", provider)
}
