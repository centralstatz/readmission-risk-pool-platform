rrp_runtime_supported_specifications <- function() {
  list(
    eligibility_result = rrp_identity(
      "runtime_record", "platform.readmission-eligibility-result", "0.1.0"
    ),
    episode_state = rrp_identity(
      "runtime_record", "platform.readmission-episode-state", "0.1.0"
    ),
    estimand = rrp_identity(
      "estimand", "platform.readmission-next-day-conditional-hazard", "0.1.0"
    ),
    estimand_request = rrp_identity(
      "runtime_request", "platform.readmission-estimand-request", "0.1.0"
    )
  )
}

rrp_specification_matches <- function(document, expected) {
  is.list(document) &&
    identical(document$specification_kind, expected$specification_kind) &&
    identical(document$specification_id, expected$specification_id) &&
    identical(document$specification_version, expected$specification_version) &&
    identical(document$specification_format_version, "1.0.0")
}

#' Validate injected runtime specifications
#'
#' The package never discovers or reads repository contract files. Callers
#' explicitly load language-neutral documents and inject them here.
#' @export
validate_runtime_contracts <- function(contracts) {
  expected <- rrp_runtime_supported_specifications()
  issues <- list()
  if (!is.list(contracts) || is.null(names(contracts))) {
    return(rrp_runtime_result(
      rrp_identity("runtime_contract_set", "platform.runtime-contract-set", "0.1.0"),
      list(rrp_runtime_issue(
        "runtime.contracts.structure", "invalid_runtime_contract_set",
        "Runtime contracts must be a named collection.", "$"
      ))
    ))
  }
  for (name in names(expected)) {
    if (!name %in% names(contracts)) {
      issues[[length(issues) + 1L]] <- rrp_runtime_issue(
        "runtime.contracts.required", "missing_runtime_contract",
        paste0("Required runtime contract is missing: ", name, "."),
        paste0("$.", name)
      )
    } else if (!rrp_specification_matches(contracts[[name]], expected[[name]])) {
      issues[[length(issues) + 1L]] <- rrp_runtime_issue(
        "runtime.contracts.support", "unsupported_runtime_contract",
        paste0("Runtime contract identity or version is unsupported: ", name, "."),
        paste0("$.", name)
      )
    }
  }
  estimand <- contracts$estimand
  if (is.list(estimand)) {
    semantic_ok <- identical(estimand$quantity_type, "discrete_time_conditional_hazard") &&
      identical(estimand$event$event_type, "first_canonical_readmission") &&
      identical(
        estimand$event$plannedness,
        "not_distinguished_by_initial_canonical_profile"
      ) &&
      identical(as.numeric(estimand$interval$width_days), 1) &&
      identical(estimand$interval$start_boundary, "exclusive") &&
      identical(estimand$interval$end_boundary, "inclusive") &&
      identical(as.numeric(estimand$followup$maximum_horizon_days), 30) &&
      identical(estimand$output$value, "probability") &&
      identical(as.numeric(estimand$output$minimum), 0) &&
      identical(as.numeric(estimand$output$maximum), 1) &&
      identical(estimand$coherence$monotonic_across_intervals_required, FALSE) &&
      identical(
        unlist(estimand$requirements$required_capabilities, use.names = FALSE),
        "platform.discharge-episode"
      )
    if (!semantic_ok) {
      issues[[length(issues) + 1L]] <- rrp_runtime_issue(
        "runtime.estimand.semantics", "unsupported_estimand_semantics",
        "Injected estimand semantics do not match the supported quantity.",
        "$.estimand"
      )
    }
  }
  rrp_runtime_result(
    rrp_identity("runtime_contract_set", "platform.runtime-contract-set", "0.1.0"),
    issues
  )
}
