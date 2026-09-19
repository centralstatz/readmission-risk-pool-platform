rrp_transparent_provider_callable <- function(request) {
  list(
    request_id = request$request_id,
    status = "success",
    estimate_value = as.numeric(
      0.20 * request$remaining_seconds_through_w30 / 2592000
    ),
    failure_code = NULL
  )
}

rrp_transparent_provider_declaration <- function() {
  list(
    component_id = "rrp.provider.transparent",
    component_version = "0.1.0",
    provider_api_id = "rrp.provider-api",
    provider_api_version = "0.1.0",
    target_id = "rrp.risk-target.readmission-remaining-30-day",
    target_version = "0.1.0",
    state_contract_id = "rrp.episode-state",
    state_contract_version = "0.1.0",
    request_contract_id = "rrp.risk-request",
    request_contract_version = "0.1.0",
    estimate_contract_id = "rrp.risk-estimate",
    estimate_contract_version = "0.1.0",
    implementation_id = "rrp.provider-implementation.transparent",
    implementation_version = "0.1.0",
    model_id = NULL,
    model_version = NULL,
    callable = rrp_transparent_provider_callable
  )
}

rrp_risk_failure_messages <- function() {
  c(
    invalid_analytical_as_of = "Analytical as-of time is invalid.",
    unknown_episode = "Selected episode is invalid.",
    project_identity_mismatch = paste0(
      "Admitted bundle project does not match the selected project."
    ),
    profile_identity_mismatch = paste0(
      "Admitted bundle profile does not match the selected project."
    )
  )
}

rrp_risk_abort <- function(code) {
  messages <- rrp_risk_failure_messages()
  if (!is.character(code) || length(code) != 1L || is.na(code) ||
      !code %in% names(messages)) {
    stop("Invalid internal risk-operation error definition.", call. = FALSE)
  }
  stop(structure(
    list(message = unname(messages[[code]]), call = NULL, code = code),
    class = c("rrp_risk_operation_error", "error", "condition")
  ))
}

rrp_risk_validate_inputs <- function(episode_id, as_of_time) {
  valid_episode <- rrp_producer_scalar_string(episode_id) &&
    nchar(episode_id, type = "bytes") <= 96L &&
    grepl("^[a-z][a-z0-9]*(?:[.-][a-z0-9]+)*$", episode_id, perl = TRUE)
  if (!valid_episode) rrp_risk_abort("unknown_episode")
  if (is.na(rrp_producer_timestamp_number(as_of_time))) {
    rrp_risk_abort("invalid_analytical_as_of")
  }
  invisible(NULL)
}

rrp_risk_validate_project_agreement <- function(state, context) {
  manifest <- context$manifest
  if (!identical(state$project_id, manifest[["Project-ID"]]) ||
      !identical(state$project_version, manifest[["Project-Version"]])) {
    rrp_risk_abort("project_identity_mismatch")
  }
  if (!identical(
    state$canonical_profile_id, context$canonical_profile$profile_id
  ) || !identical(
    state$canonical_profile_version, context$canonical_profile$profile_version
  )) {
    rrp_risk_abort("profile_identity_mismatch")
  }
  invisible(state)
}

rrp_risk_runtime_provider <- function(provider) {
  fields <- rrp_project_split_fields(
    rrp_project_registration_contract_expected()[["Provider-Fields"]]
  )
  provider[fields]
}

rrp_risk_invoke_provider <- function(
  context,
  episode_state,
  provider_context
) {
  previous_directory <- getwd()
  on.exit({
    current_directory <- getwd()
    if (!identical(current_directory, previous_directory)) {
      setwd(previous_directory)
    }
  }, add = TRUE)

  rrp_project_with_libraries(
    context$extension_library_path,
    function() rrpruntime::rrp_execute_risk_provider(
      episode_state,
      rrp_risk_runtime_provider(context$provider),
      provider_context
    )
  )
}

rrp_risk_operation_failure <- function(condition) {
  message <- if (inherits(condition, "rrp_project_error")) {
    "RRP project loading failed."
  } else {
    "Risk execution failed."
  }
  diagnostic <- rrp_new_diagnostic(
    code = condition$code,
    severity = "error",
    message = message
  )
  rrp_new_operation_result(
    operation_id = "rrp.execute-risk",
    status = "failure",
    value = NULL,
    diagnostics = list(diagnostic)
  )
}

rrp_risk_execute <- function(
  software_catalog,
  project_root,
  admitted_bundle,
  episode_id,
  as_of_time
) {
  rrp_risk_validate_inputs(episode_id, as_of_time)
  context <- rrp_load_project(software_catalog, project_root)
  canonical_contracts <- rrp_canonical_contracts(context$software_catalog)
  runtime_contracts <- rrp_runtime_contracts(
    context$software_catalog, canonical_contracts
  )
  episode_state <- rrpruntime::rrp_prepare_episode_state(
    admitted_bundle,
    episode_id,
    as_of_time,
    rrp_episode_state_expected_context(runtime_contracts, canonical_contracts)
  )
  rrp_risk_validate_project_agreement(episode_state, context)
  estimate <- rrp_risk_invoke_provider(
    context,
    episode_state,
    rrp_provider_expected_context(runtime_contracts, canonical_contracts)
  )
  rrp_new_operation_result(
    operation_id = "rrp.execute-risk",
    status = "success",
    value = estimate,
    diagnostics = list()
  )
}

#' Execute the risk provider selected by an explicit RRP project
#'
#' Load one explicit project through the authoritative loader, construct one
#' eligible detached episode state from an already admitted bundle, and invoke
#' exactly the provider selected by that project through the standard runtime
#' request/result boundary. The installed transparent provider is available
#' only through explicit project selection and is a deterministic nonclinical
#' conformance example, not a default or clinically validated model.
#'
#' @param software_catalog A validated `rrp_resource_catalog` returned by
#'   [rrp_open_resource_catalog()].
#' @param project_root One explicit existing independent project directory.
#' @param admitted_bundle One already admitted `rrp_admitted_canonical_bundle`.
#' @param episode_id One exact admitted episode identity.
#' @param as_of_time One RFC 3339 timestamp with an explicit offset, denoting
#'   the same instant as the admitted bundle's authoritative cutoff.
#' @return One validated `rrp_operation_result`. On success, `value` is the
#'   accepted detached `rrp_risk_estimate`; expected project, target, provider,
#'   and estimate failures return one bounded error diagnostic.
#' @export
rrp_execute_risk <- function(
  software_catalog,
  project_root,
  admitted_bundle,
  episode_id,
  as_of_time
) {
  tryCatch(
    rrp_risk_execute(
      software_catalog, project_root, admitted_bundle, episode_id, as_of_time
    ),
    rrp_project_error = rrp_risk_operation_failure,
    rrp_risk_operation_error = rrp_risk_operation_failure,
    rrp_runtime_error = rrp_risk_operation_failure
  )
}
