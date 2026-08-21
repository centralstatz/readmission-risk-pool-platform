# Callable source-to-history composition for one explicitly trusted producer.
# Human scripts and generated adopter wrappers supply executable registration
# in code; configuration contributes only the exact selected identity/version.

rrp_validate_selected_canonical_producer <- function(
  repository_root,
  registry,
  selection,
  producer_invocation
) {
  if (!is.list(selection) ||
      !identical(sort(names(selection)), c("producer_id", "producer_version"))) {
    stop("Producer selection must contain one exact producer ID and version.", call. = FALSE)
  }
  rrp_conform_registered_canonical_producer(
    registry,
    selection$producer_id,
    selection$producer_version,
    producer_invocation,
    repository_root
  )
}

rrp_run_selected_platform_cycle <- function(
  repository_root,
  registry,
  selection,
  producer_invocation,
  database_path,
  runtime_run_id,
  run_label = "configured",
  event_emitter = NULL
) {
  if (!is.list(selection) ||
      !identical(sort(names(selection)), c("producer_id", "producer_version"))) {
    stop("Producer selection must contain one exact producer ID and version.", call. = FALSE)
  }
  if (!is.character(runtime_run_id) || length(runtime_run_id) != 1L ||
      is.na(runtime_run_id) || !nzchar(runtime_run_id)) {
    stop("Runtime run ID must be one non-empty non-patient identifier.", call. = FALSE)
  }
  produced <- rrp_execute_canonical_producer(
    registry,
    selection$producer_id,
    selection$producer_version,
    producer_invocation,
    repository_root,
    event_emitter
  )
  if (!identical(produced$overall_status, "succeeded")) stop(
    "Configured canonical producer failed before Platform runtime execution: ",
    produced$failure_code %||% "producer_execution_failed", ".",
    call. = FALSE
  )
  rrp_run_reference_history(
    repository_root = repository_root,
    scale = run_label,
    database_path = database_path,
    runtime_run_id = runtime_run_id,
    as_of_time = produced$canonical_as_of_time,
    event_emitter = event_emitter,
    producer_result = produced
  )
}
