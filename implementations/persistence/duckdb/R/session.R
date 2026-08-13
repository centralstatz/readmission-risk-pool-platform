# Adapter-owned connection lifecycle. Normal callers receive a port, path, and
# close operation; the raw DBI connection remains captured in private state.

rrp_duckdb_open_session_internal <- function(
  database_path, history_contracts, read_only = FALSE, test_failure_stage = NULL
) {
  database_path <- normalizePath(database_path, winslash = "/", mustWork = TRUE)
  state <- new.env(parent = emptyenv())
  state$connection <- rrp_duckdb_connect(database_path, read_only = read_only)
  state$open <- TRUE
  valid <- FALSE
  on.exit(if (!valid) rrp_duckdb_disconnect(state$connection), add = TRUE)
  rrp_duckdb_validate_schema(state$connection)
  adapter <- rrp_duckdb_new_adapter(state, test_failure_stage)
  port <- rrpruntime::new_persistence_port(adapter, history_contracts)
  session <- new.env(parent = emptyenv())
  session$database_path <- database_path
  session$read_only <- read_only
  session$port <- port
  session$lifecycle <- function() {
    rrp_duckdb_assert_open(state)
    rows <- DBI::dbGetQuery(
      state$connection,
      "SELECT payload_hex FROM operational_run_statuses"
    )
    statuses <- lapply(rows$payload_hex, rrp_duckdb_decode_record)
    terminal <- Filter(function(value) value$run_status %in% c(
      "completed", "completed_with_failures"
    ), statuses)
    latest <- NULL
    if (length(terminal) > 0L) {
      order_index <- order(
        vapply(terminal, function(value) {
          rrp_duckdb_time_number(value$as_of_time)
        }, numeric(1)),
        vapply(terminal, function(value) {
          rrp_duckdb_time_number(value$status_time)
        }, numeric(1)),
        vapply(terminal, `[[`, character(1), "runtime_run_id"),
        method = "radix"
      )
      latest <- terminal[[tail(order_index, 1L)]]$runtime_run_id
    }
    list(
      initialized = TRUE,
      run_count = length(unique(vapply(
        statuses, `[[`, character(1), "runtime_run_id"
      ))),
      terminal_run_count = length(terminal),
      latest_runtime_run_id = latest
    )
  }
  session$close <- function() {
    if (isTRUE(state$open)) {
      rrp_duckdb_disconnect(state$connection)
      state$open <- FALSE
    }
    invisible(NULL)
  }
  class(session) <- "rrp_duckdb_persistence_session"
  reg.finalizer(session, function(value) value$close(), onexit = TRUE)
  valid <- TRUE
  session
}

rrp_open_duckdb_persistence <- function(
  database_path, history_contracts, read_only = FALSE
) {
  rrp_duckdb_open_session_internal(database_path, history_contracts, read_only)
}

rrp_close_duckdb_persistence <- function(session) {
  if (!inherits(session, "rrp_duckdb_persistence_session")) stop(
    "A DuckDB persistence session is required.", call. = FALSE
  )
  session$close()
}

rrp_duckdb_persistence_port <- function(session) {
  if (!inherits(session, "rrp_duckdb_persistence_session")) stop(
    "A DuckDB persistence session is required.", call. = FALSE
  )
  session$port
}

# Reference-operator lifecycle inspection. This is adapter-specific status
# evidence; it does not widen the backend-neutral persistence port.
rrp_duckdb_history_lifecycle <- function(session) {
  if (!inherits(session, "rrp_duckdb_persistence_session")) stop(
    "A DuckDB persistence session is required.", call. = FALSE
  )
  session$lifecycle()
}

# Test-only constructor keeps injected transaction failures out of the
# supported operation surface.
rrp_duckdb_test_session <- function(
  database_path, history_contracts, failure_stage
) {
  allowed <- c(
    "run_status", "episode_states", "estimand_requests",
    "provider_execution_results", "estimates"
  )
  if (!failure_stage %in% allowed) stop("Unknown DuckDB test failure stage.", call. = FALSE)
  rrp_duckdb_open_session_internal(
    database_path, history_contracts, test_failure_stage = failure_stage
  )
}

rrp_backup_duckdb_history <- function(database_path, backup_path) {
  database_path <- normalizePath(database_path, winslash = "/", mustWork = TRUE)
  backup_path <- normalizePath(backup_path, winslash = "/", mustWork = FALSE)
  if (identical(database_path, backup_path) || file.exists(backup_path) ||
      dir.exists(backup_path)) stop(
    "Backup destination must be a new file distinct from the source.", call. = FALSE
  )
  parent <- dirname(backup_path)
  if (!dir.exists(parent) && !dir.create(parent, recursive = TRUE)) stop(
    "Could not create backup parent directory.", call. = FALSE
  )
  connection <- rrp_duckdb_connect(database_path)
  on.exit(rrp_duckdb_disconnect(connection), add = TRUE)
  rrp_duckdb_validate_schema(connection)
  DBI::dbExecute(connection, "CHECKPOINT")
  rrp_duckdb_disconnect(connection)
  copied <- file.copy(database_path, backup_path, overwrite = FALSE, copy.mode = TRUE)
  if (!copied) stop("Could not copy the checkpointed DuckDB history file.", call. = FALSE)
  valid <- FALSE
  on.exit(if (!valid && file.exists(backup_path)) unlink(backup_path, force = TRUE), add = TRUE)
  check <- rrp_duckdb_connect(backup_path, read_only = TRUE)
  on.exit(rrp_duckdb_disconnect(check), add = TRUE)
  rrp_duckdb_validate_schema(check)
  valid <- TRUE
  invisible(list(source = database_path, backup = backup_path))
}
