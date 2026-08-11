# Test-only semantic realization of the persistence ports. It deliberately has
# no files, connections, serialization format, or durability promise.

phase5_copy <- function(value) unserialize(serialize(value, NULL))

phase5_time_number <- function(value) {
  normalized <- sub("Z$", "+0000", value)
  normalized <- sub("([+-][0-9]{2}):([0-9]{2})$", "\\1\\2", normalized)
  as.numeric(as.POSIXct(
    normalized, format = "%Y-%m-%dT%H:%M:%OS%z", tz = "UTC"
  ))
}

phase5_in_memory_adapter <- function() {
  store <- new.env(parent = emptyenv())
  store$records <- list(
    operational_run = list(), episode_state = list(), estimand_request = list(),
    provider_execution_result = list(), estimate = list(), invalidation = list()
  )

  identity_field <- function(family) switch(family,
    operational_run = "run_status_record_id", episode_state = "state_id",
    estimand_request = "request_id",
    provider_execution_result = "execution_result_id", estimate = "estimate_id",
    invalidation = "invalidation_id"
  )
  append_to <- function(records, family, values) {
    output <- records
    field <- identity_field(family)
    for (value in values) {
      id <- value[[field]]
      existing <- output[[family]][[id]]
      if (!is.null(existing) && !identical(existing, value)) stop(
        "History identity conflict for ", family, ": ", id, call. = FALSE
      )
      if (is.null(existing)) output[[family]][[id]] <- phase5_copy(value)
    }
    output
  }
  run_statuses <- function(records, run_id) Filter(function(value) {
    identical(value$runtime_run_id, run_id)
  }, records$operational_run)
  preflight_status <- function(records, status) {
    existing <- run_statuses(records, status$runtime_run_id)
    same_id <- Filter(function(value) identical(
      value$run_status_record_id, status$run_status_record_id
    ), existing)
    if (length(same_id) == 1L && identical(same_id[[1L]], status)) return(invisible(TRUE))
    if (length(same_id) == 1L) stop("Run status identity conflict.", call. = FALSE)
    started <- Filter(function(value) identical(value$run_status, "started"), existing)
    terminal <- Filter(function(value) !identical(value$run_status, "started"), existing)
    if (identical(status$run_status, "started")) {
      if (length(started) > 0L) stop("Run already has a different started status.", call. = FALSE)
    } else {
      if (length(started) != 1L || length(terminal) > 0L) stop(
        "Terminal status requires exactly one started status and no prior terminal status.",
        call. = FALSE
      )
      context <- c(
        "runtime_run_id", "as_of_time", "bundle_instance_id", "canonical_run_id",
        "implementation_reference", "mapping_reference"
      )
      if (!all(vapply(context, function(field) identical(
        started[[1L]][[field]], status[[field]]
      ), logical(1)))) stop("Run lifecycle context changed.", call. = FALSE)
      if (!identical(
        status$previous_run_status_record_id,
        started[[1L]]$run_status_record_id
      )) stop("Terminal status does not reference its started status.", call. = FALSE)
    }
    invisible(TRUE)
  }
  append_status <- function(status) {
    candidate <- phase5_copy(store$records)
    preflight_status(candidate, status)
    candidate <- append_to(candidate, "operational_run", list(status))
    store$records <- candidate
    invisible(list(appended = TRUE, runtime_run_id = status$runtime_run_id))
  }
  append_completed <- function(batch) {
    candidate <- phase5_copy(store$records)
    preflight_status(candidate, batch$run_status)
    candidate <- append_to(candidate, "operational_run", list(batch$run_status))
    candidate <- append_to(candidate, "episode_state", batch$episode_states)
    candidate <- append_to(candidate, "estimand_request", batch$estimand_requests)
    candidate <- append_to(
      candidate, "provider_execution_result", batch$provider_execution_results
    )
    candidate <- append_to(candidate, "estimate", batch$estimates)
    store$records <- candidate
    invisible(list(appended = TRUE, runtime_run_id = batch$run_status$runtime_run_id))
  }
  append_invalidations <- function(invalidations) {
    candidate <- phase5_copy(store$records)
    for (invalidation in invalidations) {
      family <- invalidation$target_record_family
      target_exists <- if (identical(family, "operational_run")) {
        length(run_statuses(candidate, invalidation$target_runtime_run_id)) > 0L &&
          identical(invalidation$target_record_id, invalidation$target_runtime_run_id)
      } else !is.null(candidate[[family]][[invalidation$target_record_id]])
      if (!target_exists) stop("Invalidation target does not exist.", call. = FALSE)
    }
    candidate <- append_to(candidate, "invalidation", invalidations)
    store$records <- candidate
    invisible(list(appended = TRUE, count = length(invalidations)))
  }
  invalid_identity_sets <- function(records) {
    invalid <- list(
      runs = character(), states = character(), requests = character(),
      executions = character(), estimates = character()
    )
    for (value in records$invalidation) {
      family <- value$target_record_family
      if (identical(family, "operational_run")) invalid$runs <- union(
        invalid$runs, value$target_runtime_run_id
      )
      if (identical(family, "episode_state")) invalid$states <- union(
        invalid$states, value$target_record_id
      )
      if (identical(family, "estimand_request")) invalid$requests <- union(
        invalid$requests, value$target_record_id
      )
      if (identical(family, "provider_execution_result")) invalid$executions <- union(
        invalid$executions, value$target_record_id
      )
      if (identical(family, "estimate")) invalid$estimates <- union(
        invalid$estimates, value$target_record_id
      )
    }
    invalid$states <- union(invalid$states, vapply(Filter(function(value) {
      value$runtime_run_id %in% invalid$runs
    }, records$episode_state), `[[`, character(1), "state_id"))
    invalid$requests <- union(invalid$requests, vapply(Filter(function(value) {
      value$runtime_run_id %in% invalid$runs || value$state_reference$state_id %in% invalid$states
    }, records$estimand_request), `[[`, character(1), "request_id"))
    invalid$executions <- union(invalid$executions, vapply(Filter(function(value) {
      value$runtime_run_id %in% invalid$runs || value$state_id %in% invalid$states ||
        value$request_id %in% invalid$requests
    }, records$provider_execution_result), `[[`, character(1), "execution_result_id"))
    invalid$estimates <- union(invalid$estimates, vapply(Filter(function(value) {
      value$runtime_run_id %in% invalid$runs ||
        value$state_reference$state_id %in% invalid$states ||
        value$request_id %in% invalid$requests ||
        any(vapply(records$provider_execution_result[invalid$executions], function(execution) {
          identical(execution$estimate_record$estimate_id, value$estimate_id)
        }, logical(1)))
    }, records$estimate), `[[`, character(1), "estimate_id"))
    invalid
  }
  valid_records <- function(records) {
    invalid <- invalid_identity_sets(records)
    list(
      operational_run = Filter(function(value) !value$runtime_run_id %in% invalid$runs, records$operational_run),
      episode_state = records$episode_state[setdiff(names(records$episode_state), invalid$states)],
      estimand_request = records$estimand_request[setdiff(names(records$estimand_request), invalid$requests)],
      provider_execution_result = records$provider_execution_result[setdiff(names(records$provider_execution_result), invalid$executions)],
      estimate = records$estimate[setdiff(names(records$estimate), invalid$estimates)],
      invalidation = records$invalidation
    )
  }
  selected <- function(view) if (identical(view, "raw")) {
    phase5_copy(store$records)
  } else valid_records(phase5_copy(store$records))
  read_record <- function(family, id, view) {
    records <- selected(view)
    value <- records[[family]][[id]]
    if (is.null(value)) NULL else phase5_copy(value)
  }
  read_run <- function(run_id, view) {
    records <- selected(view)
    output <- lapply(records, function(family) Filter(function(value) {
      identical(value$runtime_run_id, run_id) ||
        identical(value$target_runtime_run_id, run_id)
    }, family))
    phase5_copy(output)
  }
  episode_estimates <- function(episode_id, estimand_id, view) {
    values <- Filter(function(value) {
      identical(value$episode_id, episode_id) &&
        (is.null(estimand_id) || identical(
          value$estimand_specification$specification_id, estimand_id
        ))
    }, selected(view)$estimate)
    if (length(values) > 1L) values <- values[order(
      vapply(values, function(value) phase5_time_number(value$as_of_time), numeric(1)),
      vapply(values, `[[`, character(1), "runtime_run_id"),
      vapply(values, `[[`, character(1), "estimate_id")
    )]
    phase5_copy(values)
  }
  current_estimate <- function(episode_id, estimand_id, cutoff) {
    records <- selected("valid")
    values <- episode_estimates(episode_id, estimand_id, "valid")
    terminal <- Filter(function(value) value$run_status %in% c(
      "completed", "completed_with_failures"
    ), records$operational_run)
    terminal_by_run <- stats::setNames(terminal, vapply(
      terminal, `[[`, character(1), "runtime_run_id"
    ))
    values <- Filter(function(value) {
      value$runtime_run_id %in% names(terminal_by_run) &&
        phase5_time_number(value$as_of_time) <= phase5_time_number(cutoff)
    }, values)
    if (length(values) == 0L) return(NULL)
    as_of_values <- vapply(values, function(value) {
      phase5_time_number(value$as_of_time)
    }, numeric(1))
    candidates <- values[as_of_values == max(as_of_values)]
    terminal_values <- vapply(candidates, function(value) {
      phase5_time_number(terminal_by_run[[value$runtime_run_id]]$status_time)
    }, numeric(1))
    candidates <- candidates[terminal_values == max(terminal_values)]
    if (length(candidates) != 1L) stop(
      "Current estimate is ambiguous at the requested cutoff.", call. = FALSE
    )
    phase5_copy(candidates[[1L]])
  }

  list(
    adapter_id = "test.in-memory-operational-history",
    adapter_version = "0.1.0",
    contract_reference = list(
      specification_kind = "persistence_contract",
      specification_id = "platform.persistence-adapter",
      specification_version = "0.1.0"
    ),
    capabilities = list(
      atomic_completed_run_append = TRUE,
      idempotent_identical_append = TRUE,
      conflicting_identity_rejected = TRUE,
      append_only_invalidation = TRUE,
      raw_history_reads = TRUE,
      validity_resolved_reads = TRUE
    ),
    methods = list(
      append_run_status = append_status,
      append_completed_run = append_completed,
      append_invalidations = append_invalidations,
      read_record = read_record,
      read_run_history = read_run,
      read_episode_estimate_history = episode_estimates,
      read_current_estimate = current_estimate
    )
  )
}
