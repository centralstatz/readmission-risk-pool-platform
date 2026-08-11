rrp_history_contract_identities <- function() {
  list(
    operational_run_status = rrp_identity(
      "persistence_record", "platform.operational-run-status", "0.1.0"
    ),
    invalidation = rrp_identity(
      "persistence_record", "platform.history-invalidation", "0.1.0"
    ),
    persistence_adapter = rrp_identity(
      "persistence_contract", "platform.persistence-adapter", "0.1.0"
    )
  )
}

#' Validate injected operational-history contracts
#' @export
validate_history_contracts <- function(contracts) {
  expected <- rrp_history_contract_identities()
  issues <- list()
  if (!is.list(contracts) || is.null(names(contracts))) {
    return(rrp_runtime_result(
      rrp_identity("persistence_contract_set", "platform.history-contract-set", "0.1.0"),
      list(rrp_runtime_issue(
        "history.contracts.structure", "invalid_history_contract_set",
        "History contracts must be a named collection.", "$"
      ))
    ))
  }
  for (name in names(expected)) {
    if (!name %in% names(contracts)) {
      issues[[length(issues) + 1L]] <- rrp_runtime_issue(
        "history.contracts.required", "missing_history_contract",
        paste0("Required history contract is missing: ", name, "."),
        paste0("$.", name)
      )
    } else if (!rrp_specification_matches(contracts[[name]], expected[[name]])) {
      issues[[length(issues) + 1L]] <- rrp_runtime_issue(
        "history.contracts.support", "unsupported_history_contract",
        paste0("History contract identity or version is unsupported: ", name, "."),
        paste0("$.", name)
      )
    }
  }
  rrp_runtime_result(
    rrp_identity("persistence_contract_set", "platform.history-contract-set", "0.1.0"),
    issues
  )
}

