rrp_readmission_risk_target_expected <- function() {
  c(
    "Record-Type" = "specification",
    "Specification-Kind" = "risk-target",
    "Specification-ID" = "rrp.risk-target.readmission-remaining-30-day",
    "Specification-Version" = "0.1.0",
    "Specification-Format-Version" = "1.0.0",
    "Identity-Scope" = "platform",
    "Status" = "development_unpublished",
    "Product-ID" = "readmission-risk-pool-platform",
    "Development-Version" = "1.0.0-dev",
    "Owner-Package" = "rrpruntime",
    "Canonical-Profile-ID" = "rrp.canonical-profile.readmission",
    "Canonical-Profile-Version" = "0.1.0",
    "Population" = "all_admitted_profile_episodes",
    "Event" = "first_canonical_readmission",
    "Readmission-Plannedness" = "not_distinguished",
    "Origin" = "discharge_time",
    "Endpoint-Definition" = "discharge_plus_elapsed_seconds",
    "Endpoint-Elapsed-Seconds" = "2592000",
    "Endpoint-Inclusion" = "included",
    "Eligible-As-Of-Interval" = "[D,W30)",
    "Target-Interval" = "(t,W30]",
    "Conditioning" = "alive_and_readmission_free_through_t",
    "Information-Cutoff" = "occurred_and_available_through_t",
    "Competing-Event" = "death",
    "Equal-Time-Precedence" = "readmission",
    "Output-Quantity" = "probability",
    "Output-Cardinality" = "one",
    "Output-Minimum" = "0",
    "Output-Maximum" = "1",
    "Target-Selection" = "prohibited",
    "Eligibility-Failure-Codes" = paste(c(
      "invalid_analytical_as_of", "analytical_as_of_mismatch",
      "unknown_episode", "episode_before_discharge",
      "target_horizon_exhausted", "episode_already_readmitted",
      "episode_already_dead"
    ), collapse = ","),
    "Unknown-Fields" = "prohibited",
    "Additional-Records" = "prohibited",
    "Executable-Content" = "prohibited"
  )
}

rrp_episode_state_contract_expected <- function() {
  c(
    "Record-Type" = "specification",
    "Specification-Kind" = "episode-state-contract",
    "Specification-ID" = "rrp.episode-state",
    "Specification-Version" = "0.1.0",
    "Specification-Format-Version" = "1.0.0",
    "Identity-Scope" = "platform",
    "Status" = "development_unpublished",
    "Product-ID" = "readmission-risk-pool-platform",
    "Development-Version" = "1.0.0-dev",
    "Owner-Package" = "rrpruntime",
    "Target-ID" = "rrp.risk-target.readmission-remaining-30-day",
    "Target-Version" = "0.1.0",
    "Canonical-Bundle-ID" = "rrp.canonical-bundle",
    "Canonical-Bundle-Version" = "0.1.0",
    "Canonical-Profile-ID" = "rrp.canonical-profile.readmission",
    "Canonical-Profile-Version" = "0.1.0",
    "Object-Class" = "rrp_episode_state,list",
    "State-Fields" = paste(c(
      "state_contract_id", "state_contract_version", "state_id",
      "target_id", "target_version", "bundle_contract_id",
      "bundle_contract_version", "bundle_instance_id", "project_id",
      "project_version", "canonical_profile_id",
      "canonical_profile_version", "episode_id", "as_of_time",
      "discharge_time", "target_window_end",
      "elapsed_seconds_since_discharge",
      "remaining_seconds_through_w30", "terminal_status"
    ), collapse = ","),
    "Timestamp-Fields" = "as_of_time,discharge_time,target_window_end",
    "Timestamp-Representation" = "rfc3339_utc",
    "Elapsed-Fields" = paste(c(
      "elapsed_seconds_since_discharge", "remaining_seconds_through_w30"
    ), collapse = ","),
    "Elapsed-Unit" = "seconds",
    "Terminal-Status-Value" = "none_available_through_as_of",
    "State-ID-Prefix" = "rrp.state.",
    "State-ID-Algorithm" = "dual_modular_hash_v1",
    "State-ID-Inputs" = paste(c(
      "bundle_contract_id", "bundle_contract_version", "bundle_instance_id",
      "project_id", "project_version", "canonical_profile_id",
      "canonical_profile_version", "episode_id", "as_of_time",
      "discharge_time", "target_window_end", "target_id", "target_version",
      "state_contract_id", "state_contract_version"
    ), collapse = ","),
    "Expected-Context-Fields" = paste(c(
      "product_id", "development_version", "target_id", "target_version",
      "state_contract_id", "state_contract_version", "bundle_contract_id",
      "bundle_contract_version", "canonical_profile_id",
      "canonical_profile_version", "target_event", "conditioning",
      "endpoint_elapsed_seconds", "eligible_as_of_start",
      "eligible_as_of_end", "target_interval", "information_cutoff",
      "competing_event", "equal_time_precedence", "target_selection",
      "terminal_status"
    ), collapse = ","),
    "Construction" = "eligible_only",
    "Detached-Plain-Value" = "required",
    "Reference-Bearing-Values" = "prohibited",
    "Unknown-Fields" = "prohibited",
    "Additional-Records" = "prohibited",
    "Executable-Content" = "prohibited"
  )
}

rrp_risk_request_contract_expected <- function() {
  c(
    "Record-Type" = "specification",
    "Specification-Kind" = "risk-request-contract",
    "Specification-ID" = "rrp.risk-request",
    "Specification-Version" = "0.1.0",
    "Specification-Format-Version" = "1.0.0",
    "Identity-Scope" = "platform",
    "Status" = "development_unpublished",
    "Product-ID" = "readmission-risk-pool-platform",
    "Development-Version" = "1.0.0-dev",
    "Owner-Package" = "rrpruntime",
    "Target-ID" = "rrp.risk-target.readmission-remaining-30-day",
    "Target-Version" = "0.1.0",
    "State-Contract-ID" = "rrp.episode-state",
    "State-Contract-Version" = "0.1.0",
    "Object-Class" = "rrp_risk_request,list",
    "Request-Fields" = paste(c(
      "request_contract_id", "request_contract_version", "request_id",
      "target_id", "target_version", "state_contract_id",
      "state_contract_version", "state_id", "bundle_instance_id",
      "project_id", "project_version", "episode_id", "as_of_time",
      "discharge_time", "target_interval_start", "target_interval_end",
      "target_interval_boundary", "elapsed_seconds_since_discharge",
      "remaining_seconds_through_w30"
    ), collapse = ","),
    "Timestamp-Fields" = paste(c(
      "as_of_time", "discharge_time", "target_interval_start",
      "target_interval_end"
    ), collapse = ","),
    "Timestamp-Representation" = "rfc3339_utc",
    "Elapsed-Fields" = paste(c(
      "elapsed_seconds_since_discharge", "remaining_seconds_through_w30"
    ), collapse = ","),
    "Elapsed-Unit" = "seconds",
    "Target-Interval-Boundary" = "(start,end]",
    "Request-ID-Prefix" = "rrp.request.",
    "Request-ID-Algorithm" = "dual_modular_hash_v1",
    "Request-ID-Inputs" = paste(c(
      "request_contract_id", "request_contract_version", "target_id",
      "target_version", "state_contract_id", "state_contract_version",
      "state_id", "bundle_instance_id", "project_id", "project_version",
      "episode_id", "as_of_time", "discharge_time", "target_interval_start",
      "target_interval_end", "target_interval_boundary",
      "elapsed_seconds_since_discharge", "remaining_seconds_through_w30"
    ), collapse = ","),
    "Provider-Identity" = "prohibited",
    "Detached-Plain-Value" = "required",
    "Reference-Bearing-Values" = "prohibited",
    "Unknown-Fields" = "prohibited",
    "Additional-Records" = "prohibited",
    "Executable-Content" = "prohibited"
  )
}

rrp_risk_provider_contract_expected <- function() {
  c(
    "Record-Type" = "specification",
    "Specification-Kind" = "risk-provider-contract",
    "Specification-ID" = "rrp.provider-api",
    "Specification-Version" = "0.1.0",
    "Specification-Format-Version" = "1.0.0",
    "Identity-Scope" = "platform",
    "Status" = "development_unpublished",
    "Product-ID" = "readmission-risk-pool-platform",
    "Development-Version" = "1.0.0-dev",
    "Owner-Package" = "rrpruntime",
    "Target-ID" = "rrp.risk-target.readmission-remaining-30-day",
    "Target-Version" = "0.1.0",
    "State-Contract-ID" = "rrp.episode-state",
    "State-Contract-Version" = "0.1.0",
    "Request-Contract-ID" = "rrp.risk-request",
    "Request-Contract-Version" = "0.1.0",
    "Estimate-Contract-ID" = "rrp.risk-estimate",
    "Estimate-Contract-Version" = "0.1.0",
    "Provider-Declaration-Fields" = paste(c(
      "component_id", "component_version", "provider_api_id",
      "provider_api_version", "target_id", "target_version",
      "state_contract_id", "state_contract_version", "request_contract_id",
      "request_contract_version", "estimate_contract_id",
      "estimate_contract_version", "implementation_id",
      "implementation_version", "model_id", "model_version", "callable"
    ), collapse = ","),
    "Model-Identity-Rule" = "both_null_or_both_bounded",
    "Callable-Arguments" = "request",
    "Callable-Invocation" = "exactly_once_after_compatibility",
    "Result-Fields" = "request_id,status,estimate_value,failure_code",
    "Result-Status-Values" = "success,failure",
    "Failure-Codes" = paste(c(
      "provider_unavailable", "provider_input_unavailable",
      "provider_calculation_failed"
    ), collapse = ","),
    "Runtime-Failure-Codes" = paste(c(
      "provider_incompatible", "provider_execution_failed",
      "invalid_provider_result", "provider_result_identity_mismatch",
      "invalid_estimate"
    ), collapse = ","),
    "Unknown-Fields" = "prohibited",
    "Additional-Records" = "prohibited",
    "Executable-Configuration" = "prohibited"
  )
}

rrp_risk_estimate_contract_expected <- function() {
  c(
    "Record-Type" = "specification",
    "Specification-Kind" = "risk-estimate-contract",
    "Specification-ID" = "rrp.risk-estimate",
    "Specification-Version" = "0.1.0",
    "Specification-Format-Version" = "1.0.0",
    "Identity-Scope" = "platform",
    "Status" = "development_unpublished",
    "Product-ID" = "readmission-risk-pool-platform",
    "Development-Version" = "1.0.0-dev",
    "Owner-Package" = "rrpruntime",
    "Target-ID" = "rrp.risk-target.readmission-remaining-30-day",
    "Target-Version" = "0.1.0",
    "State-Contract-ID" = "rrp.episode-state",
    "State-Contract-Version" = "0.1.0",
    "Request-Contract-ID" = "rrp.risk-request",
    "Request-Contract-Version" = "0.1.0",
    "Provider-API-ID" = "rrp.provider-api",
    "Provider-API-Version" = "0.1.0",
    "Object-Class" = "rrp_risk_estimate,list",
    "Estimate-Fields" = paste(c(
      "estimate_contract_id", "estimate_contract_version",
      "request_contract_id", "request_contract_version", "request_id",
      "state_contract_id", "state_contract_version", "state_id",
      "target_id", "target_version", "product_id", "development_version",
      "bundle_instance_id", "project_id", "project_version", "episode_id",
      "as_of_time", "target_interval_start", "target_interval_end",
      "target_interval_boundary", "provider_id", "provider_version",
      "implementation_id", "implementation_version", "model_id",
      "model_version", "output_type", "estimate_value"
    ), collapse = ","),
    "Nullable-Fields" = "model_id,model_version",
    "Model-Identity-Rule" = "both_null_or_both_bounded",
    "Timestamp-Fields" = "as_of_time,target_interval_start,target_interval_end",
    "Timestamp-Representation" = "rfc3339_utc",
    "Target-Interval-Boundary" = "(start,end]",
    "Output-Type" = "probability",
    "Output-Cardinality" = "one",
    "Output-Minimum" = "0",
    "Output-Maximum" = "1",
    "Output-Value-Type" = "unclassed_base_double",
    "Detached-Plain-Value" = "required",
    "Reference-Bearing-Values" = "prohibited",
    "Unknown-Fields" = "prohibited",
    "Additional-Records" = "prohibited",
    "Executable-Content" = "prohibited"
  )
}

rrp_runtime_contract_definitions <- function() {
  list(
    readmission_risk_target = list(
      resource_id = "rrp.target.readmission-risk",
      path = "resources/contracts/runtime/readmission-risk-target.dcf",
      owner = "rrpruntime",
      expected = rrp_readmission_risk_target_expected()
    ),
    episode_state = list(
      resource_id = "rrp.contract.episode-state",
      path = "resources/contracts/runtime/episode-state.dcf",
      owner = "rrpruntime",
      expected = rrp_episode_state_contract_expected()
    ),
    risk_request = list(
      resource_id = "rrp.contract.risk-request",
      path = "resources/contracts/runtime/risk-request.dcf",
      owner = "rrpruntime",
      expected = rrp_risk_request_contract_expected()
    ),
    risk_provider = list(
      resource_id = "rrp.contract.risk-provider",
      path = "resources/contracts/runtime/risk-provider.dcf",
      owner = "rrpruntime",
      expected = rrp_risk_provider_contract_expected()
    ),
    risk_estimate = list(
      resource_id = "rrp.contract.risk-estimate",
      path = "resources/contracts/runtime/risk-estimate.dcf",
      owner = "rrpruntime",
      expected = rrp_risk_estimate_contract_expected()
    )
  )
}

rrp_runtime_contract_record <- function(catalog, definition) {
  path <- rrp_resource_path(catalog, definition$resource_id)
  records <- rrp_resource_read_dcf(
    path, "malformed_runtime_contract", "Installed runtime contract"
  )
  if (length(records) != 1L) {
    rrp_resource_abort(
      "malformed_runtime_contract",
      "Installed runtime contract is malformed."
    )
  }
  record <- records[[1L]]
  expected <- definition$expected
  rrp_resource_require_fields(
    record, names(expected), "invalid_runtime_contract_fields",
    "Installed runtime contract"
  )
  for (field in names(expected)) {
    if (!identical(record[[field]], unname(expected[[field]]))) {
      rrp_resource_abort(
        "unsupported_runtime_contract",
        "Installed runtime contract is unsupported."
      )
    }
  }
  record
}

rrp_runtime_validate_relationships <- function(
  runtime_contracts,
  canonical_contracts
) {
  target <- runtime_contracts$readmission_risk_target
  state <- runtime_contracts$episode_state
  request <- runtime_contracts$risk_request
  provider <- runtime_contracts$risk_provider
  estimate <- runtime_contracts$risk_estimate
  bundle <- canonical_contracts$canonical_bundle
  profile <- canonical_contracts$readmission_profile
  discharge <- canonical_contracts$discharge_episode
  terminal <- canonical_contracts$terminal_event
  terminal_values <- strsplit(
    terminal[["Event-Type-Values"]], ",", fixed = TRUE
  )[[1L]]
  valid <- identical(
    target[["Canonical-Profile-ID"]], profile[["Specification-ID"]]
  ) && identical(
    target[["Canonical-Profile-Version"]], profile[["Specification-Version"]]
  ) && identical(
    target[["Endpoint-Elapsed-Seconds"]],
    discharge[["Followup-Elapsed-Seconds"]]
  ) && target[["Competing-Event"]] %in% terminal_values &&
    target[["Equal-Time-Precedence"]] %in% terminal_values &&
    identical(terminal[["Equal-Readmission-Death-Time"]], "allowed") &&
    identical(state[["Target-ID"]], target[["Specification-ID"]]) &&
    identical(state[["Target-Version"]], target[["Specification-Version"]]) &&
    identical(state[["Canonical-Bundle-ID"]], bundle[["Specification-ID"]]) &&
    identical(
      state[["Canonical-Bundle-Version"]], bundle[["Specification-Version"]]
    ) && identical(
      state[["Canonical-Profile-ID"]], profile[["Specification-ID"]]
    ) && identical(
      state[["Canonical-Profile-Version"]], profile[["Specification-Version"]]
    ) && identical(request[["Target-ID"]], target[["Specification-ID"]]) &&
    identical(request[["Target-Version"]], target[["Specification-Version"]]) &&
    identical(request[["State-Contract-ID"]], state[["Specification-ID"]]) &&
    identical(request[["State-Contract-Version"]], state[["Specification-Version"]]) &&
    identical(provider[["Target-ID"]], target[["Specification-ID"]]) &&
    identical(provider[["Target-Version"]], target[["Specification-Version"]]) &&
    identical(provider[["State-Contract-ID"]], state[["Specification-ID"]]) &&
    identical(provider[["State-Contract-Version"]], state[["Specification-Version"]]) &&
    identical(provider[["Request-Contract-ID"]], request[["Specification-ID"]]) &&
    identical(provider[["Request-Contract-Version"]], request[["Specification-Version"]]) &&
    identical(provider[["Estimate-Contract-ID"]], estimate[["Specification-ID"]]) &&
    identical(provider[["Estimate-Contract-Version"]], estimate[["Specification-Version"]]) &&
    identical(estimate[["Target-ID"]], target[["Specification-ID"]]) &&
    identical(estimate[["Target-Version"]], target[["Specification-Version"]]) &&
    identical(estimate[["State-Contract-ID"]], state[["Specification-ID"]]) &&
    identical(estimate[["State-Contract-Version"]], state[["Specification-Version"]]) &&
    identical(estimate[["Request-Contract-ID"]], request[["Specification-ID"]]) &&
    identical(estimate[["Request-Contract-Version"]], request[["Specification-Version"]]) &&
    identical(estimate[["Provider-API-ID"]], provider[["Specification-ID"]]) &&
    identical(estimate[["Provider-API-Version"]], provider[["Specification-Version"]]) &&
    identical(target[["Target-Interval"]], "(t,W30]") &&
    identical(request[["Target-Interval-Boundary"]], "(start,end]") &&
    identical(estimate[["Target-Interval-Boundary"]], "(start,end]") &&
    identical(target[["Output-Quantity"]], estimate[["Output-Type"]]) &&
    identical(target[["Output-Minimum"]], estimate[["Output-Minimum"]]) &&
    identical(target[["Output-Maximum"]], estimate[["Output-Maximum"]])
  if (!valid) {
    rrp_resource_abort(
      "incompatible_runtime_contracts",
      "Installed runtime contracts are incompatible."
    )
  }
  invisible(runtime_contracts)
}

rrp_provider_expected_context <- function(runtime_contracts, canonical_contracts) {
  rrp_runtime_validate_relationships(runtime_contracts, canonical_contracts)
  target <- runtime_contracts$readmission_risk_target
  state <- runtime_contracts$episode_state
  request <- runtime_contracts$risk_request
  provider <- runtime_contracts$risk_provider
  estimate <- runtime_contracts$risk_estimate
  list(
    product_id = target[["Product-ID"]],
    development_version = target[["Development-Version"]],
    target_id = target[["Specification-ID"]],
    target_version = target[["Specification-Version"]],
    state_contract_id = state[["Specification-ID"]],
    state_contract_version = state[["Specification-Version"]],
    request_contract_id = request[["Specification-ID"]],
    request_contract_version = request[["Specification-Version"]],
    provider_api_id = provider[["Specification-ID"]],
    provider_api_version = provider[["Specification-Version"]],
    estimate_contract_id = estimate[["Specification-ID"]],
    estimate_contract_version = estimate[["Specification-Version"]],
    request_class = request[["Object-Class"]],
    estimate_class = estimate[["Object-Class"]],
    target_interval_boundary = request[["Target-Interval-Boundary"]],
    output_type = estimate[["Output-Type"]],
    output_minimum = as.numeric(estimate[["Output-Minimum"]]),
    output_maximum = as.numeric(estimate[["Output-Maximum"]])
  )
}

rrp_runtime_contracts <- function(catalog, canonical_contracts = NULL) {
  if (is.null(canonical_contracts)) {
    canonical_contracts <- rrp_canonical_contracts(catalog)
  }
  definitions <- rrp_runtime_contract_definitions()
  contracts <- lapply(definitions, function(definition) {
    rrp_runtime_contract_record(catalog, definition)
  })
  rrp_runtime_validate_relationships(contracts, canonical_contracts)
  contracts
}

rrp_episode_state_expected_context <- function(
  runtime_contracts,
  canonical_contracts
) {
  definitions <- rrp_runtime_contract_definitions()
  valid_runtime <- is.list(runtime_contracts) &&
    identical(names(runtime_contracts), names(definitions)) &&
    all(vapply(names(definitions), function(name) {
      identical(
        runtime_contracts[[name]], as.list(definitions[[name]]$expected)
      )
    }, logical(1L)))
  canonical_definitions <- rrp_canonical_contract_definitions()
  valid_canonical <- is.list(canonical_contracts) &&
    identical(names(canonical_contracts), names(canonical_definitions)) &&
    all(vapply(names(canonical_definitions), function(name) {
      identical(
        canonical_contracts[[name]],
        as.list(canonical_definitions[[name]]$expected)
      )
    }, logical(1L)))
  if (!valid_runtime || !valid_canonical) {
    rrp_resource_abort(
      "incompatible_runtime_contracts",
      "Installed runtime contracts are incompatible."
    )
  }
  rrp_runtime_validate_relationships(runtime_contracts, canonical_contracts)
  target <- runtime_contracts$readmission_risk_target
  state <- runtime_contracts$episode_state
  list(
    product_id = target[["Product-ID"]],
    development_version = target[["Development-Version"]],
    target_id = target[["Specification-ID"]],
    target_version = target[["Specification-Version"]],
    state_contract_id = state[["Specification-ID"]],
    state_contract_version = state[["Specification-Version"]],
    bundle_contract_id = state[["Canonical-Bundle-ID"]],
    bundle_contract_version = state[["Canonical-Bundle-Version"]],
    canonical_profile_id = state[["Canonical-Profile-ID"]],
    canonical_profile_version = state[["Canonical-Profile-Version"]],
    target_event = target[["Event"]],
    conditioning = target[["Conditioning"]],
    endpoint_elapsed_seconds = as.numeric(target[["Endpoint-Elapsed-Seconds"]]),
    eligible_as_of_start = "inclusive",
    eligible_as_of_end = "exclusive",
    target_interval = target[["Target-Interval"]],
    information_cutoff = target[["Information-Cutoff"]],
    competing_event = target[["Competing-Event"]],
    equal_time_precedence = target[["Equal-Time-Precedence"]],
    target_selection = target[["Target-Selection"]],
    terminal_status = state[["Terminal-Status-Value"]]
  )
}
