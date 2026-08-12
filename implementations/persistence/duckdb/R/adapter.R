# Complete platform.persistence-adapter@0.1.0 realization over one connection.

rrp_duckdb_assert_open <- function(state) {
  if (!isTRUE(state$open) || !DBI::dbIsValid(state$connection)) stop(
    "DuckDB persistence session is closed.", call. = FALSE
  )
  invisible(TRUE)
}

rrp_duckdb_record_id <- function(record, family) {
  definition <- rrp_duckdb_family_definitions()[[family]]
  record[[definition$id]]
}

rrp_duckdb_existing_record <- function(connection, family, id) {
  definition <- rrp_duckdb_family_definitions()[[family]]
  query <- paste0(
    "SELECT payload_hex FROM ", definition$table,
    " WHERE ", definition$id, " = ?"
  )
  row <- DBI::dbGetQuery(connection, query, params = list(id))
  if (nrow(row) == 0L) return(NULL)
  if (nrow(row) != 1L) stop("DuckDB history identity is not unique.", call. = FALSE)
  rrp_duckdb_decode_record(row$payload_hex[[1L]])
}

rrp_duckdb_preflight_records <- function(connection, family, records) {
  Filter(function(record) {
    id <- rrp_duckdb_record_id(record, family)
    existing <- rrp_duckdb_existing_record(connection, family, id)
    if (!is.null(existing) && !identical(existing, record)) stop(
      "History identity conflict for ", family, ": ", id, call. = FALSE
    )
    is.null(existing)
  }, records)
}

rrp_duckdb_insert_records <- function(connection, family, records) {
  if (length(records) == 0L) return(invisible(0L))
  definition <- rrp_duckdb_family_definitions()[[family]]
  fields <- c(definition$id, definition$columns, "payload_hex")
  statement <- paste0(
    "INSERT INTO ", definition$table, " (", paste(fields, collapse = ", "),
    ") VALUES (", paste(rep("?", length(fields)), collapse = ", "), ")"
  )
  for (record in records) {
    values <- c(
      list(rrp_duckdb_record_id(record, family)),
      rrp_duckdb_record_columns(record, family),
      list(rrp_duckdb_encode_record(record))
    )
    DBI::dbExecute(connection, statement, params = unname(values))
  }
  invisible(length(records))
}

rrp_duckdb_run_statuses <- function(connection, runtime_run_id) {
  rows <- DBI::dbGetQuery(
    connection,
    "SELECT payload_hex FROM operational_run_statuses WHERE runtime_run_id = ?",
    params = list(runtime_run_id)
  )
  lapply(rows$payload_hex, rrp_duckdb_decode_record)
}

rrp_duckdb_preflight_status <- function(connection, status) {
  existing <- rrp_duckdb_run_statuses(connection, status$runtime_run_id)
  same_id <- Filter(function(value) identical(
    value$run_status_record_id, status$run_status_record_id
  ), existing)
  if (length(same_id) == 1L && identical(same_id[[1L]], status)) return(FALSE)
  if (length(same_id) == 1L) stop("Run status identity conflict.", call. = FALSE)
  started <- Filter(function(value) identical(value$run_status, "started"), existing)
  terminal <- Filter(function(value) !identical(value$run_status, "started"), existing)
  if (identical(status$run_status, "started")) {
    if (length(started) > 0L) stop(
      "Run already has a different started status.", call. = FALSE
    )
  } else {
    if (length(started) != 1L || length(terminal) > 0L) stop(
      "Terminal status requires exactly one started status and no prior terminal status.",
      call. = FALSE
    )
    context_fields <- c(
      "runtime_run_id", "as_of_time", "bundle_instance_id", "canonical_run_id",
      "implementation_reference", "mapping_reference"
    )
    context_ok <- all(vapply(context_fields, function(field) identical(
      started[[1L]][[field]], status[[field]]
    ), logical(1)))
    if (!context_ok) stop("Run lifecycle context changed.", call. = FALSE)
    if (!identical(
      status$previous_run_status_record_id,
      started[[1L]]$run_status_record_id
    )) stop("Terminal status does not reference its started status.", call. = FALSE)
  }
  TRUE
}

rrp_duckdb_transaction <- function(connection, action) {
  DBI::dbBegin(connection)
  committed <- FALSE
  on.exit(if (!committed && DBI::dbIsValid(connection)) {
    try(DBI::dbRollback(connection), silent = TRUE)
  }, add = TRUE)
  value <- action()
  DBI::dbCommit(connection)
  committed <- TRUE
  value
}

rrp_duckdb_inject_failure <- function(test_failure_stage, stage) {
  if (!is.null(test_failure_stage) && identical(test_failure_stage, stage)) stop(
    "Injected DuckDB completed-batch failure after ", stage, ".", call. = FALSE
  )
  invisible(NULL)
}

rrp_duckdb_all_records <- function(connection) {
  definitions <- rrp_duckdb_family_definitions()
  output <- lapply(names(definitions), function(family) {
    definition <- definitions[[family]]
    rows <- DBI::dbGetQuery(
      connection, paste0("SELECT payload_hex FROM ", definition$table)
    )
    records <- lapply(rows$payload_hex, rrp_duckdb_decode_record)
    if (length(records) > 0L) names(records) <- vapply(
      records, rrp_duckdb_record_id, character(1), family = family
    )
    records
  })
  names(output) <- names(definitions)
  output
}

rrp_duckdb_invalid_identity_sets <- function(records) {
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
    value$runtime_run_id %in% invalid$runs ||
      value$state_reference$state_id %in% invalid$states
  }, records$estimand_request), `[[`, character(1), "request_id"))
  invalid$executions <- union(invalid$executions, vapply(Filter(function(value) {
    value$runtime_run_id %in% invalid$runs || value$state_id %in% invalid$states ||
      value$request_id %in% invalid$requests
  }, records$provider_execution_result), `[[`, character(1), "execution_result_id"))
  invalid_execution_estimates <- vapply(
    records$provider_execution_result[invalid$executions],
    function(execution) if (is.null(execution$estimate_record)) "" else {
      execution$estimate_record$estimate_id
    },
    character(1)
  )
  invalid$estimates <- union(invalid$estimates, vapply(Filter(function(value) {
    value$runtime_run_id %in% invalid$runs ||
      value$state_reference$state_id %in% invalid$states ||
      value$request_id %in% invalid$requests ||
      value$estimate_id %in% invalid_execution_estimates
  }, records$estimate), `[[`, character(1), "estimate_id"))
  invalid
}

rrp_duckdb_valid_records <- function(records) {
  invalid <- rrp_duckdb_invalid_identity_sets(records)
  list(
    operational_run = Filter(function(value) {
      !value$runtime_run_id %in% invalid$runs
    }, records$operational_run),
    episode_state = records$episode_state[setdiff(names(records$episode_state), invalid$states)],
    estimand_request = records$estimand_request[setdiff(names(records$estimand_request), invalid$requests)],
    provider_execution_result = records$provider_execution_result[setdiff(
      names(records$provider_execution_result), invalid$executions
    )],
    estimate = records$estimate[setdiff(names(records$estimate), invalid$estimates)],
    invalidation = records$invalidation
  )
}

rrp_duckdb_sort_records <- function(records) {
  order_records <- function(values, keys) {
    if (length(values) < 2L) return(values)
    vectors <- lapply(keys, function(key) vapply(values, key, FUN.VALUE = key(values[[1L]])))
    values[do.call(order, vectors)]
  }
  terminal_times <- list()
  for (status in records$operational_run) if (status$run_status %in% c(
    "completed", "completed_with_failures", "failed"
  )) terminal_times[[status$runtime_run_id]] <- status$status_time
  records$operational_run <- order_records(records$operational_run, list(
    function(value) as.integer(value$status_sequence),
    function(value) rrp_duckdb_time_number(value$status_time),
    function(value) value$run_status_record_id
  ))
  records$episode_state <- order_records(records$episode_state, list(
    function(value) rrp_duckdb_time_number(value$as_of_time),
    function(value) value$episode_id,
    function(value) value$state_id
  ))
  records$estimand_request <- order_records(records$estimand_request, list(
    function(value) rrp_duckdb_time_number(value$as_of_time),
    function(value) value$episode_id,
    function(value) value$request_id
  ))
  records$provider_execution_result <- order_records(
    records$provider_execution_result, list(
      function(value) value$request_id,
      function(value) as.integer(value$attempt_number),
      function(value) value$execution_result_id
    )
  )
  records$estimate <- order_records(records$estimate, list(
    function(value) rrp_duckdb_time_number(value$as_of_time),
    function(value) {
      time <- terminal_times[[value$runtime_run_id]]
      if (is.null(time)) -Inf else rrp_duckdb_time_number(time)
    },
    function(value) value$estimate_id
  ))
  records$invalidation <- order_records(records$invalidation, list(
    function(value) rrp_duckdb_time_number(value$invalidated_at),
    function(value) value$invalidation_id
  ))
  records
}

rrp_duckdb_new_adapter <- function(state, test_failure_stage = NULL) {
  selected <- function(view) {
    rrp_duckdb_assert_open(state)
    records <- rrp_duckdb_all_records(state$connection)
    rrp_duckdb_sort_records(if (identical(view, "raw")) records else {
      rrp_duckdb_valid_records(records)
    })
  }
  append_status <- function(status) {
    rrp_duckdb_assert_open(state)
    appended <- rrp_duckdb_transaction(state$connection, function() {
      needs_insert <- rrp_duckdb_preflight_status(state$connection, status)
      if (needs_insert) rrp_duckdb_insert_records(
        state$connection, "operational_run", list(status)
      )
      needs_insert
    })
    invisible(list(appended = appended, runtime_run_id = status$runtime_run_id))
  }
  append_completed <- function(batch) {
    rrp_duckdb_assert_open(state)
    appended <- rrp_duckdb_transaction(state$connection, function() {
      pending <- list(
        operational_run = if (rrp_duckdb_preflight_status(
          state$connection, batch$run_status
        )) list(batch$run_status) else list(),
        episode_state = rrp_duckdb_preflight_records(
          state$connection, "episode_state", batch$episode_states
        ),
        estimand_request = rrp_duckdb_preflight_records(
          state$connection, "estimand_request", batch$estimand_requests
        ),
        provider_execution_result = rrp_duckdb_preflight_records(
          state$connection, "provider_execution_result",
          batch$provider_execution_results
        ),
        estimate = rrp_duckdb_preflight_records(
          state$connection, "estimate", batch$estimates
        )
      )
      stages <- c(
        operational_run = "run_status", episode_state = "episode_states",
        estimand_request = "estimand_requests",
        provider_execution_result = "provider_execution_results",
        estimate = "estimates"
      )
      for (family in names(stages)) {
        rrp_duckdb_insert_records(state$connection, family, pending[[family]])
        rrp_duckdb_inject_failure(test_failure_stage, stages[[family]])
      }
      any(lengths(pending) > 0L)
    })
    invisible(list(
      appended = appended, runtime_run_id = batch$run_status$runtime_run_id
    ))
  }
  append_invalidations <- function(invalidations) {
    rrp_duckdb_assert_open(state)
    appended <- rrp_duckdb_transaction(state$connection, function() {
      for (record in invalidations) {
        family <- record$target_record_family
        target_exists <- if (identical(family, "operational_run")) {
          length(rrp_duckdb_run_statuses(
            state$connection, record$target_runtime_run_id
          )) > 0L && identical(
            record$target_record_id, record$target_runtime_run_id
          )
        } else !is.null(rrp_duckdb_existing_record(
          state$connection, family, record$target_record_id
        ))
        if (!target_exists) stop("Invalidation target does not exist.", call. = FALSE)
      }
      pending <- rrp_duckdb_preflight_records(
        state$connection, "invalidation", invalidations
      )
      rrp_duckdb_insert_records(state$connection, "invalidation", pending)
      length(pending)
    })
    invisible(list(appended = appended > 0L, count = appended))
  }
  read_record <- function(family, id, view) {
    records <- selected(view)
    value <- records[[family]][[id]]
    if (is.null(value)) NULL else unserialize(serialize(value, NULL))
  }
  read_run <- function(run_id, view) {
    records <- selected(view)
    output <- lapply(records, function(family) Filter(function(value) {
      identical(value$runtime_run_id, run_id) ||
        identical(value$target_runtime_run_id, run_id)
    }, family))
    rrp_duckdb_sort_records(output)
  }
  episode_estimates <- function(episode_id, estimand_id, view) {
    records <- selected(view)
    values <- Filter(function(value) {
      identical(value$episode_id, episode_id) &&
        (is.null(estimand_id) || identical(
          value$estimand_specification$specification_id, estimand_id
        ))
    }, records$estimate)
    records$estimate <- values
    rrp_duckdb_sort_records(records)$estimate
  }
  current_estimate <- function(episode_id, estimand_id, cutoff) {
    records <- selected("valid")
    values <- Filter(function(value) {
      identical(value$episode_id, episode_id) && identical(
        value$estimand_specification$specification_id, estimand_id
      ) && rrp_duckdb_time_number(value$as_of_time) <= rrp_duckdb_time_number(cutoff)
    }, records$estimate)
    terminal <- Filter(function(value) value$run_status %in% c(
      "completed", "completed_with_failures"
    ), records$operational_run)
    terminal_by_run <- stats::setNames(
      terminal, vapply(terminal, `[[`, character(1), "runtime_run_id")
    )
    values <- Filter(function(value) value$runtime_run_id %in% names(terminal_by_run), values)
    if (length(values) == 0L) return(NULL)
    as_of <- vapply(values, function(value) {
      rrp_duckdb_time_number(value$as_of_time)
    }, numeric(1))
    candidates <- values[as_of == max(as_of)]
    terminal_time <- vapply(candidates, function(value) {
      rrp_duckdb_time_number(terminal_by_run[[value$runtime_run_id]]$status_time)
    }, numeric(1))
    candidates <- candidates[terminal_time == max(terminal_time)]
    if (length(candidates) != 1L) stop(
      "Current estimate is ambiguous at the requested cutoff.", call. = FALSE
    )
    unserialize(serialize(candidates[[1L]], NULL))
  }

  list(
    adapter_id = rrp_duckdb_identity()$adapter_id,
    adapter_version = rrp_duckdb_identity()$adapter_version,
    contract_reference = rrp_duckdb_contract_reference(),
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

