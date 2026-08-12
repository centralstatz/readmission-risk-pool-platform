# Explicit non-destructive schema initialization and compatibility checks.

rrp_duckdb_connect <- function(database_path, read_only = FALSE) {
  if (!requireNamespace("DBI", quietly = TRUE) ||
      !requireNamespace("duckdb", quietly = TRUE)) {
    stop("The DuckDB reference adapter requires locked packages `DBI` and `duckdb`.", call. = FALSE)
  }
  DBI::dbConnect(
    duckdb::duckdb(), dbdir = database_path, read_only = read_only
  )
}

rrp_duckdb_disconnect <- function(connection) {
  if (DBI::dbIsValid(connection)) {
    try(DBI::dbDisconnect(connection, shutdown = TRUE), silent = TRUE)
  }
  invisible(NULL)
}

rrp_duckdb_schema_statements <- function() c(
  paste(
    "CREATE TABLE adapter_metadata (",
    "metadata_key VARCHAR PRIMARY KEY, adapter_id VARCHAR NOT NULL,",
    "adapter_version VARCHAR NOT NULL, schema_version VARCHAR NOT NULL,",
    "payload_encoding VARCHAR NOT NULL, initialized BOOLEAN NOT NULL,",
    "initialized_at VARCHAR NOT NULL)"
  ),
  paste(
    "CREATE TABLE operational_run_statuses (",
    "run_status_record_id VARCHAR PRIMARY KEY, runtime_run_id VARCHAR NOT NULL,",
    "status_sequence INTEGER NOT NULL, run_status VARCHAR NOT NULL,",
    "status_time VARCHAR NOT NULL, as_of_time VARCHAR NOT NULL,",
    "payload_hex VARCHAR NOT NULL)"
  ),
  paste(
    "CREATE TABLE episode_states (state_id VARCHAR PRIMARY KEY,",
    "runtime_run_id VARCHAR NOT NULL, episode_id VARCHAR NOT NULL,",
    "as_of_time VARCHAR NOT NULL, payload_hex VARCHAR NOT NULL)"
  ),
  paste(
    "CREATE TABLE estimand_requests (request_id VARCHAR PRIMARY KEY,",
    "runtime_run_id VARCHAR NOT NULL, episode_id VARCHAR NOT NULL,",
    "state_id VARCHAR NOT NULL, estimand_id VARCHAR NOT NULL,",
    "as_of_time VARCHAR NOT NULL, payload_hex VARCHAR NOT NULL)"
  ),
  paste(
    "CREATE TABLE provider_execution_results (",
    "execution_result_id VARCHAR PRIMARY KEY, runtime_run_id VARCHAR NOT NULL,",
    "provider_execution_run_id VARCHAR NOT NULL, request_id VARCHAR NOT NULL,",
    "state_id VARCHAR NOT NULL, episode_id VARCHAR NOT NULL,",
    "provider_id VARCHAR NOT NULL, provider_version VARCHAR NOT NULL,",
    "attempt_number INTEGER NOT NULL, execution_status VARCHAR NOT NULL,",
    "payload_hex VARCHAR NOT NULL)"
  ),
  paste(
    "CREATE TABLE estimates (estimate_id VARCHAR PRIMARY KEY,",
    "runtime_run_id VARCHAR NOT NULL, provider_execution_run_id VARCHAR NOT NULL,",
    "request_id VARCHAR NOT NULL, state_id VARCHAR NOT NULL,",
    "episode_id VARCHAR NOT NULL, estimand_id VARCHAR NOT NULL,",
    "estimand_version VARCHAR NOT NULL, provider_id VARCHAR NOT NULL,",
    "provider_version VARCHAR NOT NULL, as_of_time VARCHAR NOT NULL,",
    "target_interval_start VARCHAR NOT NULL, target_interval_end VARCHAR NOT NULL,",
    "payload_hex VARCHAR NOT NULL)"
  ),
  paste(
    "CREATE TABLE history_invalidations (invalidation_id VARCHAR PRIMARY KEY,",
    "target_record_family VARCHAR NOT NULL, target_record_id VARCHAR NOT NULL,",
    "target_runtime_run_id VARCHAR NOT NULL, invalidated_at VARCHAR NOT NULL,",
    "replacement_runtime_run_id VARCHAR, payload_hex VARCHAR NOT NULL)"
  ),
  "CREATE INDEX operational_run_runtime_idx ON operational_run_statuses(runtime_run_id)",
  "CREATE INDEX episode_state_run_idx ON episode_states(runtime_run_id)",
  "CREATE INDEX request_run_idx ON estimand_requests(runtime_run_id)",
  "CREATE INDEX execution_run_idx ON provider_execution_results(runtime_run_id)",
  "CREATE INDEX estimate_episode_idx ON estimates(episode_id, estimand_id, as_of_time)",
  "CREATE INDEX invalidation_run_idx ON history_invalidations(target_runtime_run_id)"
)

rrp_duckdb_validate_schema <- function(connection) {
  identity <- rrp_duckdb_identity()
  required_tables <- c(
    "adapter_metadata",
    vapply(rrp_duckdb_family_definitions(), `[[`, character(1), "table")
  )
  present <- DBI::dbListTables(connection)
  missing <- setdiff(required_tables, present)
  if (length(missing) > 0L) stop(
    "DuckDB history schema is incomplete; missing: ",
    paste(missing, collapse = ", "), ". No automatic migration is available.",
    call. = FALSE
  )
  metadata <- DBI::dbGetQuery(
    connection,
    "SELECT adapter_id, adapter_version, schema_version, payload_encoding, initialized FROM adapter_metadata WHERE metadata_key = ?",
    params = list("platform_operational_history")
  )
  if (nrow(metadata) != 1L) stop(
    "DuckDB history metadata is missing or ambiguous; refusing to continue.",
    call. = FALSE
  )
  expected <- unname(unlist(identity[c(
    "adapter_id", "adapter_version", "schema_version", "payload_encoding"
  )]))
  actual <- unname(as.character(metadata[1L, names(identity)]))
  initialized <- isTRUE(metadata$initialized[[1L]])
  if (!identical(actual, expected) || !initialized) stop(
    "DuckDB history adapter/schema version is incompatible; no migration is available.",
    call. = FALSE
  )
  invisible(TRUE)
}

rrp_initialize_duckdb_history <- function(database_path) {
  if (!is.character(database_path) || length(database_path) != 1L ||
      !nzchar(database_path) || identical(database_path, ":memory:") ||
      dir.exists(database_path)) {
    stop("Initialization requires one persistent DuckDB file path.", call. = FALSE)
  }
  database_path <- normalizePath(database_path, winslash = "/", mustWork = FALSE)
  if (file.exists(database_path)) {
    connection <- tryCatch(
      rrp_duckdb_connect(database_path),
      error = function(condition) stop(
        "Existing path is not an initialized compatible DuckDB history database: ",
        conditionMessage(condition), call. = FALSE
      )
    )
    on.exit(rrp_duckdb_disconnect(connection), add = TRUE)
    rrp_duckdb_validate_schema(connection)
    return(invisible(list(database_path = database_path, created = FALSE)))
  }
  parent <- dirname(database_path)
  if (!dir.exists(parent) && !dir.create(parent, recursive = TRUE)) stop(
    "Could not create DuckDB history parent directory: ", parent, call. = FALSE
  )
  connection <- NULL
  completed <- FALSE
  on.exit({
    if (!is.null(connection)) rrp_duckdb_disconnect(connection)
    if (!completed) unlink(
      c(database_path, paste0(database_path, ".wal")), force = TRUE
    )
  }, add = TRUE)
  connection <- rrp_duckdb_connect(database_path)
  DBI::dbBegin(connection)
  committed <- FALSE
  on.exit(if (!committed && DBI::dbIsValid(connection)) {
    try(DBI::dbRollback(connection), silent = TRUE)
  }, add = TRUE)
  for (statement in rrp_duckdb_schema_statements()) DBI::dbExecute(connection, statement)
  identity <- rrp_duckdb_identity()
  initialized_at <- format(Sys.time(), "%Y-%m-%dT%H:%M:%SZ", tz = "UTC")
  DBI::dbExecute(
    connection,
    paste(
      "INSERT INTO adapter_metadata VALUES (?, ?, ?, ?, ?, ?, ?)"
    ),
    params = list(
      "platform_operational_history", identity$adapter_id,
      identity$adapter_version, identity$schema_version,
      identity$payload_encoding, TRUE, initialized_at
    )
  )
  DBI::dbCommit(connection)
  committed <- TRUE
  rrp_duckdb_validate_schema(connection)
  completed <- TRUE
  invisible(list(database_path = database_path, created = TRUE))
}
