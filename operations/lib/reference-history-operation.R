# Human-callable composition from an already resolved canonical producer result
# through the existing runtime, provider, and persistence interfaces. No source
# interpretation or history semantics are implemented here.

rrp_reference_history_emit <- function(event_emitter, ...) {
  if (is.null(event_emitter)) return(invisible(NULL))
  rrp_emit_operational_event(event_emitter, ...)
}

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
  as_of_time = NULL,
  event_emitter = NULL,
  producer_result = NULL
) {
  identities <- rrp_reference_history_identities(scale, runtime_run_id)
  produced <- producer_result %||% rrp_run_installed_canonical_producer(
    repository_root, scale, as_of_time,
    paste0("producer_execution_", identities$runtime_run_id), event_emitter
  )
  if (!identical(produced$overall_status, "succeeded")) stop(
    "Configured canonical production failed; history run was not started.",
    call. = FALSE
  )
  bundle <- produced$canonical_bundle
  rrp_reference_history_emit(
    event_emitter, "runtime", "runtime_preparation", "info", "stage_started",
    "run.runtime_started", "Runtime admission and estimand preparation started."
  )
  runtime_result <- rrp_run_runtime_from_bundle(
    bundle, repository_root, identities$runtime_run_id
  )
  rrp_reference_history_emit(
    event_emitter, "runtime", "runtime_preparation", "info", "stage_completed",
    "run.runtime_completed", "Runtime admission and estimand preparation completed.",
    related_identities = list(analytical_runtime_run_id = identities$runtime_run_id),
    details = list(
      episode_count = length(runtime_result$states$records),
      request_count = length(runtime_result$estimand_requests$records),
      status = "succeeded"
    )
  )
  history_contracts <- rrp_read_history_contracts(repository_root)
  rrp_reference_history_emit(
    event_emitter, "persistence", "persistence", "info", "stage_started",
    "run.persistence_started", "Operational history persistence started.",
    related_identities = list(analytical_runtime_run_id = identities$runtime_run_id)
  )
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

  rrp_reference_history_emit(
    event_emitter, "provider_execution", "provider_execution", "info",
    "stage_started", "run.provider_execution_started",
    "Provider execution started.",
    related_identities = list(analytical_runtime_run_id = identities$runtime_run_id),
    details = list(request_count = length(runtime_result$estimand_requests$records))
  )
  estimation <- tryCatch(
    rrp_execute_reference_estimation(
      runtime_result, repository_root, identities$provider_execution_run_id
    ),
    error = function(condition) {
      rrp_reference_history_emit(
        event_emitter, "provider_execution", "provider_execution", "error",
        "stage_completed", "run.provider_execution_failed",
        "Provider execution did not complete successfully.",
        related_identities = list(
          analytical_runtime_run_id = identities$runtime_run_id
        ), details = list(failure_category = "provider_execution_failure")
      )
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
  rrp_reference_history_emit(
    event_emitter, "provider_execution", "provider_execution",
    if (failed_count == 0L) "info" else "warning", "stage_completed",
    "run.provider_execution_completed", "Provider execution completed.",
    related_identities = list(
      analytical_runtime_run_id = identities$runtime_run_id,
      provider_id = "reference.transparent-readmission-hazard",
      provider_version = "0.1.0"
    ), details = list(
      request_count = length(runtime_result$estimand_requests$records),
      successful_count = length(estimation$estimates),
      failure_count = as.integer(failed_count),
      status = if (failed_count == 0L) "succeeded" else "completed_with_failures"
    )
  )
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
  rrp_reference_history_emit(
    event_emitter, "persistence", "persistence", "info", "stage_completed",
    "run.persistence_completed", "Operational history persistence completed.",
    related_identities = list(analytical_runtime_run_id = identities$runtime_run_id),
    details = list(
      run_status = terminal_status,
      persisted_count = sum(vapply(durable, length, integer(1)))
    )
  )
  list(
    database_path = normalizePath(database_path, winslash = "/", mustWork = TRUE),
    runtime_run_id = identities$runtime_run_id,
    provider_execution_run_id = identities$provider_execution_run_id,
    producer_reference = produced$producer_reference,
    producer_execution_id = produced$producer_execution_id,
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
