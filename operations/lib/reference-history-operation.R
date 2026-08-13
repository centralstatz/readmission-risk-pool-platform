# Human-callable composition of the existing synthetic, runtime, provider, and
# persistence interfaces. No history semantics are implemented here.

rrp_reference_history_identities <- function(scale, runtime_run_id = NULL) {
  default_identity <- is.null(runtime_run_id)
  runtime_run_id <- runtime_run_id %||% paste0("runtime_synthetic_history_", scale, "_001")
  list(
    runtime_run_id = runtime_run_id,
    provider_execution_run_id = if (default_identity) {
      paste0("provider_synthetic_history_", scale, "_001")
    } else {
      paste0("provider_execution_", runtime_run_id)
    }
  )
}

rrp_reference_history_configuration <- function(
  repository_root,
  scale,
  as_of_time = NULL
) {
  configuration <- rrp_read_synthetic_configuration(repository_root, scale)
  if (is.null(as_of_time)) return(configuration)
  if (!rrp_is_rfc3339_timestamp(as_of_time)) stop(
    "Reference run as-of time must be an explicit-offset RFC 3339 timestamp.",
    call. = FALSE
  )
  configuration$simulation_as_of_time <- as_of_time
  configuration$canonical_as_of_time <- as_of_time
  configuration
}

rrp_reference_history_status <- function(
  run_id, status, status_time, bundle, produced, history_contracts,
  previous = NULL, summary = NULL
) {
  rrpruntime::new_operational_run_status(
    runtime_run_id = run_id,
    run_status = status,
    status_time = status_time,
    as_of_time = bundle$run_context$as_of_time,
    bundle_instance_id = bundle$bundle_instance_id,
    canonical_run_id = bundle$run_context$run_id,
    implementation_reference = produced$implementation_identity,
    mapping_reference = produced$mapping_identity,
    contract = history_contracts$operational_run_status,
    previous_run_status_record_id = previous,
    status_summary = summary,
    provenance_references = produced$provenance_references
  )
}

rrp_run_reference_history <- function(
  repository_root,
  scale,
  database_path,
  runtime_run_id = NULL,
  as_of_time = NULL
) {
  identities <- rrp_reference_history_identities(scale, runtime_run_id)
  configuration <- rrp_reference_history_configuration(
    repository_root, scale, as_of_time
  )
  produced <- rrp_run_synthetic_reference(
    repository_root, scale, configuration
  )
  if (!identical(produced$overall_status, "succeeded")) stop(
    "Synthetic canonical production failed; history run was not started.",
    call. = FALSE
  )
  bundle <- produced$candidate_bundle
  runtime_result <- rrp_run_runtime_from_bundle(
    bundle, repository_root, identities$runtime_run_id
  )
  history_contracts <- rrp_read_history_contracts(repository_root)
  rrp_initialize_duckdb_history(database_path)
  session <- rrp_open_duckdb_persistence(database_path, history_contracts)
  on.exit(rrp_close_duckdb_persistence(session), add = TRUE)
  port <- rrp_duckdb_persistence_port(session)
  status_time <- bundle$run_context$as_of_time
  started <- rrp_reference_history_status(
    identities$runtime_run_id, "started", status_time, bundle, produced,
    history_contracts
  )
  rrpruntime::append_run_status(port, started)

  estimation <- tryCatch(
    rrp_execute_reference_estimation(
      runtime_result, repository_root, identities$provider_execution_run_id
    ),
    error = function(condition) {
      failed <- rrp_reference_history_status(
        identities$runtime_run_id, "failed", status_time, bundle, produced,
        history_contracts, previous = started$run_status_record_id,
        summary = list(failure_stage = "reference_provider_execution")
      )
      try(rrpruntime::append_run_status(port, failed), silent = TRUE)
      stop("Reference estimation failed: ", conditionMessage(condition), call. = FALSE)
    }
  )
  failed_count <- sum(vapply(estimation$execution_results, function(value) {
    !identical(value$execution_status, "successful_estimate")
  }, logical(1)))
  terminal_status <- if (failed_count == 0L) "completed" else {
    "completed_with_failures"
  }
  terminal_summary <- list(
    episode_state_count = length(runtime_result$states$records),
    estimand_request_count = length(runtime_result$estimand_requests$records),
    provider_execution_result_count = length(estimation$execution_results),
    successful_estimate_count = length(estimation$estimates),
    failed_execution_count = as.integer(failed_count)
  )
  terminal <- rrp_reference_history_status(
    identities$runtime_run_id, terminal_status, status_time, bundle, produced,
    history_contracts, previous = started$run_status_record_id,
    summary = terminal_summary
  )
  rrpruntime::append_completed_run(
    port, terminal, runtime_result$states$records,
    runtime_result$estimand_requests$records, estimation$execution_results,
    estimation$estimates
  )
  rrp_close_duckdb_persistence(session)

  reopened <- rrp_open_duckdb_persistence(
    database_path, history_contracts, read_only = TRUE
  )
  on.exit(rrp_close_duckdb_persistence(reopened), add = TRUE)
  reopened_port <- rrp_duckdb_persistence_port(reopened)
  durable <- rrpruntime::read_run_history(
    reopened_port, identities$runtime_run_id, "valid"
  )
  list(
    database_path = normalizePath(database_path, winslash = "/", mustWork = TRUE),
    runtime_run_id = identities$runtime_run_id,
    provider_execution_run_id = identities$provider_execution_run_id,
    adapter = rrp_duckdb_identity(),
    run_status = terminal_status,
    counts = list(
      run_statuses = length(durable$operational_run),
      episode_states = length(durable$episode_state),
      estimand_requests = length(durable$estimand_request),
      provider_execution_results = length(durable$provider_execution_result),
      estimates = length(durable$estimate),
      invalidations = length(durable$invalidation)
    )
  )
}
