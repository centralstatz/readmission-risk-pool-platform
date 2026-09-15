rrp_persistence_methods <- function() c(
  "append_run_status", "append_completed_run", "append_invalidations",
  "read_record", "read_run_history", "read_episode_estimate_history",
  "read_current_estimate"
)

#' Validate a persistence adapter declaration and callable surface
#' @export
validate_persistence_adapter <- function(adapter, contract) {
  target <- rrp_history_contract_identities()$persistence_adapter
  issues <- list()
  if (!rrp_specification_matches(contract, target)) return(rrp_runtime_result(
    target, list(rrp_runtime_issue(
      "persistence.adapter.contract", "unsupported_persistence_adapter_contract",
      "Persistence adapter contract identity/version is unsupported.", "$.contract"
    ))
  ))
  required <- unlist(contract$required_adapter_fields, use.names = FALSE)
  if (!is.list(adapter)) return(rrp_runtime_result(target, list(rrp_runtime_issue(
    "persistence.adapter.structure", "invalid_persistence_adapter",
    "Persistence adapter must be a named record.", "$"
  ))))
  missing <- required[!required %in% names(adapter)]
  if (length(missing) > 0L) issues[[length(issues) + 1L]] <- rrp_runtime_issue(
    "persistence.adapter.required", "missing_persistence_adapter_field",
    paste0("Persistence adapter fields are missing: ", paste(missing, collapse = ", "), "."), "$"
  )
  method_names <- unlist(contract$required_methods, use.names = FALSE)
  methods_ok <- is.list(adapter$methods) && all(vapply(method_names, function(name) {
    is.function(adapter$methods[[name]])
  }, logical(1)))
  if (!methods_ok) issues[[length(issues) + 1L]] <- rrp_runtime_issue(
    "persistence.adapter.methods", "missing_persistence_adapter_method",
    "Persistence adapter does not implement every required logical method.", "$.methods"
  )
  required_capabilities <- contract$required_capabilities
  capabilities_ok <- is.list(adapter$capabilities) && all(vapply(
    names(required_capabilities), function(name) identical(adapter$capabilities[[name]], TRUE),
    logical(1)
  ))
  if (!capabilities_ok) issues[[length(issues) + 1L]] <- rrp_runtime_issue(
    "persistence.adapter.capabilities", "missing_persistence_adapter_capability",
    "Persistence adapter must affirm every required semantic capability.", "$.capabilities"
  )
  reference_ok <- identical(adapter$contract_reference, target) &&
    rrp_is_scalar_string(adapter$adapter_id) && !is.null(rrp_semver_parts(adapter$adapter_version))
  if (!reference_ok) issues[[length(issues) + 1L]] <- rrp_runtime_issue(
    "persistence.adapter.identity", "invalid_persistence_adapter_identity",
    "Persistence adapter needs an ID, semantic version, and exact contract reference.", "$"
  )
  rrp_runtime_result(target, issues)
}

#' Create a backend-independent operational-history port
#' @export
new_persistence_port <- function(adapter, history_contracts) {
  rrp_assert_runtime_conforms(
    validate_history_contracts(history_contracts), "History contracts"
  )
  rrp_assert_runtime_conforms(
    validate_persistence_adapter(adapter, history_contracts$persistence_adapter),
    "Persistence adapter"
  )
  structure(list(
    adapter = adapter,
    history_contracts = history_contracts
  ), class = "rrp_persistence_port")
}

rrp_assert_port <- function(port) {
  if (!inherits(port, "rrp_persistence_port")) {
    stop("A validated persistence port is required.", call. = FALSE)
  }
  invisible(TRUE)
}

#' Append one started or failed lifecycle status
#' @export
append_run_status <- function(port, run_status) {
  rrp_assert_port(port)
  rrp_assert_runtime_conforms(validate_operational_run_status(
    run_status, port$history_contracts$operational_run_status
  ), "Operational run status")
  if (!run_status$run_status %in% c("started", "failed")) stop(
    "Completed statuses must be appended with their atomic completed-run batch.",
    call. = FALSE
  )
  port$adapter$methods$append_run_status(run_status)
}

#' Atomically append one terminal run and all accepted member records
#' @export
append_completed_run <- function(
  port, run_status, episode_states, estimand_requests,
  provider_execution_results, estimates
) {
  rrp_assert_port(port)
  batch <- list(
    run_status = run_status, episode_states = episode_states,
    estimand_requests = estimand_requests,
    provider_execution_results = provider_execution_results,
    estimates = estimates
  )
  rrp_assert_runtime_conforms(do.call(
    validate_completed_run_batch,
    c(batch, list(history_contracts = port$history_contracts))
  ), "Completed-run history batch")
  port$adapter$methods$append_completed_run(batch)
}

#' Append governed invalidation overlays
#' @export
append_history_invalidations <- function(port, invalidations) {
  rrp_assert_port(port)
  if (!rrp_named_records(invalidations)) stop(
    "Invalidations must be a record collection.", call. = FALSE
  )
  for (record in invalidations) rrp_assert_runtime_conforms(
    validate_history_invalidation(record, port$history_contracts$invalidation),
    "History invalidation"
  )
  port$adapter$methods$append_invalidations(invalidations)
}

rrp_read_view <- function(view) match.arg(view, c("valid", "raw"))

#' Read one operational-history record by exact identity
#' @export
read_history_record <- function(port, record_family, record_id, view = c("valid", "raw")) {
  rrp_assert_port(port)
  families <- c(
    "operational_run", "episode_state", "estimand_request",
    "provider_execution_result", "estimate", "invalidation"
  )
  if (!rrp_is_scalar_string(record_family) || !record_family %in% families ||
      !rrp_is_scalar_string(record_id)) {
    stop("Exact history reads require one record family and ID.", call. = FALSE)
  }
  port$adapter$methods$read_record(record_family, record_id, rrp_read_view(view))
}

#' Read all retained or currently-valid records for one run
#' @export
read_run_history <- function(port, runtime_run_id, view = c("valid", "raw")) {
  rrp_assert_port(port)
  if (!rrp_is_scalar_string(runtime_run_id)) stop("Run history requires one run ID.", call. = FALSE)
  port$adapter$methods$read_run_history(runtime_run_id, rrp_read_view(view))
}

#' Read retained or currently-valid estimates for one episode
#' @export
read_episode_estimate_history <- function(
  port, episode_id, estimand_id = NULL, view = c("valid", "raw")
) {
  rrp_assert_port(port)
  if (!rrp_is_scalar_string(episode_id) ||
      (!is.null(estimand_id) && !rrp_is_scalar_string(estimand_id))) stop(
    "Episode estimate history requires an episode ID and optional estimand ID.",
    call. = FALSE
  )
  port$adapter$methods$read_episode_estimate_history(
    episode_id, estimand_id, rrp_read_view(view)
  )
}

#' Read the unambiguous current valid estimate at a cutoff
#' @export
read_current_estimate <- function(port, episode_id, estimand_id, as_of_time) {
  rrp_assert_port(port)
  if (!rrp_is_scalar_string(episode_id) || !rrp_is_scalar_string(estimand_id) ||
      !rrp_is_timestamp(as_of_time)) stop(
    "Current estimate reads require episode, estimand, and explicit-offset cutoff.",
    call. = FALSE
  )
  port$adapter$methods$read_current_estimate(episode_id, estimand_id, as_of_time)
}
