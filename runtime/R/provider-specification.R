rrp_provider_contract_identities <- function() {
  list(
    provider_specification = rrp_identity(
      "provider_contract", "platform.provider-specification", "0.1.0"
    ),
    execution_adapter = rrp_identity(
      "provider_contract", "platform.provider-execution-adapter", "0.1.0"
    ),
    execution_result = rrp_identity(
      "runtime_result", "platform.provider-execution-result", "0.1.0"
    ),
    estimate = rrp_identity(
      "runtime_record", "platform.readmission-risk-estimate", "0.1.0"
    )
  )
}

rrp_semver_parts <- function(value) {
  if (!rrp_is_scalar_string(value) || !grepl(
    "^[0-9]+[.][0-9]+[.][0-9]+$", value
  )) return(NULL)
  as.integer(strsplit(value, ".", fixed = TRUE)[[1L]])
}

rrp_version_in_range <- function(value, minimum, maximum) {
  candidate <- rrp_semver_parts(value)
  lower <- rrp_semver_parts(minimum)
  upper <- rrp_semver_parts(maximum)
  if (is.null(candidate) || is.null(lower) || is.null(upper)) return(FALSE)
  compare <- function(left, right) {
    for (index in seq_along(left)) {
      if (left[[index]] < right[[index]]) return(-1L)
      if (left[[index]] > right[[index]]) return(1L)
    }
    0L
  }
  compare(candidate, lower) >= 0L && compare(candidate, upper) <= 0L
}

#' Validate injected provider and estimate contracts
#' @export
validate_provider_contracts <- function(contracts) {
  expected <- rrp_provider_contract_identities()
  issues <- list()
  if (!is.list(contracts) || is.null(names(contracts))) {
    return(rrp_runtime_result(
      rrp_identity("provider_contract_set", "platform.provider-contract-set", "0.1.0"),
      list(rrp_runtime_issue(
        "provider.contracts.structure", "invalid_provider_contract_set",
        "Provider contracts must be a named collection.", "$"
      ))
    ))
  }
  for (name in names(expected)) {
    if (!name %in% names(contracts)) {
      issues[[length(issues) + 1L]] <- rrp_runtime_issue(
        "provider.contracts.required", "missing_provider_contract",
        paste0("Required provider contract is missing: ", name, "."),
        paste0("$.", name)
      )
    } else if (!rrp_specification_matches(contracts[[name]], expected[[name]])) {
      issues[[length(issues) + 1L]] <- rrp_runtime_issue(
        "provider.contracts.support", "unsupported_provider_contract",
        paste0("Provider contract identity or version is unsupported: ", name, "."),
        paste0("$.", name)
      )
    }
  }
  estimate <- contracts$estimate
  if (is.list(estimate)) {
    output_ok <- identical(estimate$output$output_type, "probability") &&
      identical(as.numeric(estimate$output$minimum), 0) &&
      identical(as.numeric(estimate$output$maximum), 1) &&
      identical(estimate$output$finite_required, TRUE)
    if (!output_ok) {
      issues[[length(issues) + 1L]] <- rrp_runtime_issue(
        "provider.contracts.estimate", "unsupported_estimate_semantics",
        "Estimate contract must require one finite probability in [0,1].",
        "$.estimate.output"
      )
    }
  }
  rrp_runtime_result(
    rrp_identity("provider_contract_set", "platform.provider-contract-set", "0.1.0"),
    issues
  )
}

rrp_provider_allowed_fields <- function() {
  c(
    "specification_kind", "specification_id", "specification_version",
    "specification_format_version", "identity_scope", "title", "status",
    "description", "provider_id", "provider_version", "implementation",
    "model_identity", "supported_estimands", "supported_state",
    "supported_outputs", "required_capabilities", "input_requirements",
    "reproducibility", "uncertainty_capability", "explanation_capability",
    "execution_limitations", "failure_behavior", "conformance_scenarios",
    "method", "clinical_use"
  )
}

#' Validate one language-neutral provider declaration
#' @export
validate_provider_specification <- function(specification, provider_contract) {
  target <- rrp_identity(
    "provider_contract", "platform.provider-specification", "0.1.0"
  )
  issues <- list()
  if (!rrp_specification_matches(provider_contract, target)) {
    return(rrp_runtime_result(target, list(rrp_runtime_issue(
      "provider.specification.contract", "unsupported_provider_specification_contract",
      "Provider specification contract identity or version is unsupported.",
      "$.provider_contract"
    ))))
  }
  if (!is.list(specification)) {
    return(rrp_runtime_result(target, list(rrp_runtime_issue(
      "provider.specification.structure", "invalid_provider_specification",
      "Provider specification must be a language-neutral record.", "$"
    ))))
  }
  required <- unlist(
    provider_contract$provider_declaration$required_fields, use.names = FALSE
  )
  common <- c(
    "specification_kind", "specification_id", "specification_version",
    "specification_format_version", "identity_scope", "title", "status"
  )
  missing <- c(common, required)[!c(common, required) %in% names(specification)]
  if (length(missing) > 0L) {
    issues[[length(issues) + 1L]] <- rrp_runtime_issue(
      "provider.specification.required", "missing_provider_specification_field",
      paste0("Provider specification fields are missing: ", paste(missing, collapse = ", "), "."),
      "$"
    )
  }
  unknown <- setdiff(names(specification), rrp_provider_allowed_fields())
  if (length(unknown) > 0L) {
    issues[[length(issues) + 1L]] <- rrp_runtime_issue(
      "provider.specification.closed", "unknown_provider_specification_field",
      paste0("Unknown provider specification fields: ", paste(unknown, collapse = ", "), "."),
      "$"
    )
  }
  identity_ok <- identical(specification$specification_kind, "provider") &&
    rrp_is_scalar_string(specification$provider_id) &&
    rrp_is_scalar_string(specification$provider_version) &&
    identical(specification$provider_id, specification$specification_id) &&
    identical(specification$provider_version, specification$specification_version) &&
    !is.null(rrp_semver_parts(specification$provider_version)) &&
    identical(specification$specification_format_version, "1.0.0")
  if (!identity_ok) {
    issues[[length(issues) + 1L]] <- rrp_runtime_issue(
      "provider.specification.identity", "invalid_provider_identity",
      "Provider identity/version must match the provider specification envelope.",
      "$.provider_id"
    )
  }
  selectable <- unlist(
    provider_contract$provider_declaration$selectable_statuses, use.names = FALSE
  )
  if (!rrp_is_scalar_string(specification$status) ||
      !specification$status %in% c(selectable, "experimental", "deprecated", "retired")) {
    issues[[length(issues) + 1L]] <- rrp_runtime_issue(
      "provider.specification.lifecycle", "invalid_provider_lifecycle",
      "Provider lifecycle status is not recognized.", "$.status"
    )
  }
  implementation <- specification$implementation
  if (!is.list(implementation) ||
      !rrp_is_scalar_string(implementation$implementation_version) ||
      is.null(rrp_semver_parts(implementation$implementation_version)) ||
      !identical(
        implementation$adapter_contract,
        "platform.provider-execution-adapter@0.1.0"
      )) {
    issues[[length(issues) + 1L]] <- rrp_runtime_issue(
      "provider.specification.implementation", "invalid_provider_implementation",
      "Provider implementation needs a semantic version and adapter contract.",
      "$.implementation"
    )
  }
  estimands <- specification$supported_estimands
  estimands_ok <- rrp_named_records(estimands) && length(estimands) > 0L &&
    all(vapply(estimands, function(item) {
      rrp_is_scalar_string(item$specification_id) &&
        !is.null(rrp_semver_parts(item$minimum_version)) &&
        !is.null(rrp_semver_parts(item$maximum_version)) &&
        rrp_version_in_range(
          item$minimum_version, item$minimum_version, item$maximum_version
        ) &&
        is.numeric(item$maximum_followup_days) &&
        length(item$maximum_followup_days) == 1L &&
        is.finite(item$maximum_followup_days) &&
        item$maximum_followup_days > 0 &&
        is.numeric(item$maximum_interval_days) &&
        length(item$maximum_interval_days) == 1L &&
        is.finite(item$maximum_interval_days) &&
        item$maximum_interval_days > 0
    }, logical(1)))
  if (!estimands_ok) {
    issues[[length(issues) + 1L]] <- rrp_runtime_issue(
      "provider.specification.estimands", "invalid_supported_estimands",
      "Provider must declare bounded estimand versions, follow-up, and intervals.",
      "$.supported_estimands"
    )
  }
  state <- specification$supported_state
  state_ok <- is.list(state) && rrp_is_scalar_string(state$specification_id) &&
    !is.null(rrp_semver_parts(state$minimum_version)) &&
    !is.null(rrp_semver_parts(state$maximum_version)) &&
    rrp_version_in_range(state$minimum_version, state$minimum_version, state$maximum_version) &&
    is.character(unlist(state$required_fields, use.names = FALSE)) &&
    length(state$required_fields) > 0L
  if (!state_ok) {
    issues[[length(issues) + 1L]] <- rrp_runtime_issue(
      "provider.specification.state", "invalid_supported_state",
      "Provider must declare a bounded state version range and required fields.",
      "$.supported_state"
    )
  }
  statuses <- c("required", "optional", "unused")
  inputs <- specification$input_requirements
  input_ok <- is.list(inputs) &&
    identical(length(inputs$available_baseline_risk), 1L) &&
    inputs$available_baseline_risk %in% statuses &&
    identical(length(inputs$available_episode_events), 1L) &&
    inputs$available_episode_events %in% statuses
  if (!input_ok) {
    issues[[length(issues) + 1L]] <- rrp_runtime_issue(
      "provider.specification.inputs", "invalid_provider_input_requirements",
      "Provider input requirements must be required, optional, or unused.",
      "$.input_requirements"
    )
  }
  deterministic <- specification$reproducibility$deterministic
  if (!is.logical(deterministic) || length(deterministic) != 1L || is.na(deterministic)) {
    issues[[length(issues) + 1L]] <- rrp_runtime_issue(
      "provider.specification.reproducibility", "invalid_reproducibility_declaration",
      "Provider must explicitly declare deterministic behavior.",
      "$.reproducibility.deterministic"
    )
  }
  outputs <- specification$supported_outputs
  outputs_ok <- rrp_named_records(outputs) && length(outputs) > 0L &&
    all(vapply(outputs, function(output) {
      identical(output$output_type, "probability") &&
        is.numeric(output$minimum) && length(output$minimum) == 1L &&
        is.numeric(output$maximum) && length(output$maximum) == 1L &&
        output$minimum == 0 && output$maximum == 1 &&
        identical(output$cardinality_per_request, "one")
    }, logical(1)))
  if (!outputs_ok) {
    issues[[length(issues) + 1L]] <- rrp_runtime_issue(
      "provider.specification.outputs", "invalid_supported_outputs",
      "Provider must declare one bounded probability per successful request.",
      "$.supported_outputs"
    )
  }
  capabilities <- unlist(specification$required_capabilities, use.names = FALSE)
  if (!is.character(capabilities) || any(!nzchar(capabilities)) || anyDuplicated(capabilities)) {
    issues[[length(issues) + 1L]] <- rrp_runtime_issue(
      "provider.specification.capabilities", "invalid_required_capabilities",
      "Provider required capabilities must be unique non-empty IDs.",
      "$.required_capabilities"
    )
  }
  model <- specification$model_identity
  if (!is.list(model) || !is.logical(model$separate_model_artifact) ||
      length(model$separate_model_artifact) != 1L ||
      is.na(model$separate_model_artifact)) {
    issues[[length(issues) + 1L]] <- rrp_runtime_issue(
      "provider.specification.model", "invalid_model_identity_declaration",
      "Provider must explicitly declare whether a separate model artifact exists.",
      "$.model_identity"
    )
  }
  if (!rrp_named_records(lapply(specification$conformance_scenarios, function(value) {
    list(value = value)
  })) || length(specification$conformance_scenarios) == 0L) {
    issues[[length(issues) + 1L]] <- rrp_runtime_issue(
      "provider.specification.scenarios", "missing_provider_conformance_scenarios",
      "Provider must declare one or more conformance scenario IDs.",
      "$.conformance_scenarios"
    )
  }
  rrp_runtime_result(target, issues)
}

rrp_provider_reference <- function(specification) {
  list(
    provider_id = specification$provider_id,
    provider_version = specification$provider_version,
    implementation_version = specification$implementation$implementation_version
  )
}
