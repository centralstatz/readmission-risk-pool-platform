rrp_duckdb_payload_encode <- function(value) {
  bytes <- serialize(value, NULL, ascii = FALSE, xdr = TRUE, version = 3L)
  paste(sprintf("%02x", as.integer(bytes)), collapse = "")
}

rrp_duckdb_payload_decode <- function(value) {
  valid <- is.character(value) && length(value) == 1L && !is.na(value) &&
    nzchar(value) && nchar(value) %% 2L == 0L &&
    !grepl("[^0-9a-f]", value)
  if (!valid) rrp_state_abort(
    "state_corrupt", "Project state contains an invalid payload."
  )
  positions <- seq.int(1L, nchar(value), by = 2L)
  bytes <- as.raw(strtoi(substring(value, positions, positions + 1L), 16L))
  tryCatch(
    unserialize(bytes),
    error = function(condition) rrp_state_abort(
      "state_corrupt", "Project state contains an invalid payload."
    )
  )
}

rrp_duckdb_schema <- function() {
  list(
    rrp_state_metadata = c(
      metadata_key = "VARCHAR", state_id = "VARCHAR", project_id = "VARCHAR",
      payload_hex = "VARCHAR"
    ),
    operational_scopes = c(
      operation_run_id = "VARCHAR", operation_key = "VARCHAR",
      target_id = "VARCHAR", analytical_time = "VARCHAR",
      created_at = "VARCHAR", payload_hex = "VARCHAR"
    ),
    episode_dispositions = c(
      analytical_run_id = "VARCHAR", operation_run_id = "VARCHAR",
      episode_id = "VARCHAR", target_id = "VARCHAR",
      analytical_time = "VARCHAR", terminal_time = "VARCHAR",
      payload_hex = "VARCHAR"
    ),
    history_actions = c(
      action_id = "VARCHAR", target_kind = "VARCHAR", target_id = "VARCHAR",
      target_operation_run_id = "VARCHAR",
      replacement_operation_run_id = "VARCHAR", effective_time = "VARCHAR",
      payload_hex = "VARCHAR"
    )
  )
}

rrp_duckdb_schema_statements <- function() c(
  paste(
    "CREATE TABLE rrp_state_metadata (",
    "metadata_key VARCHAR PRIMARY KEY, state_id VARCHAR NOT NULL,",
    "project_id VARCHAR NOT NULL, payload_hex VARCHAR NOT NULL)"
  ),
  paste(
    "CREATE TABLE operational_scopes (",
    "operation_run_id VARCHAR PRIMARY KEY, operation_key VARCHAR NOT NULL,",
    "target_id VARCHAR NOT NULL, analytical_time VARCHAR NOT NULL,",
    "created_at VARCHAR NOT NULL, payload_hex VARCHAR NOT NULL)"
  ),
  paste(
    "CREATE TABLE episode_dispositions (",
    "analytical_run_id VARCHAR PRIMARY KEY, operation_run_id VARCHAR NOT NULL,",
    "episode_id VARCHAR NOT NULL, target_id VARCHAR NOT NULL,",
    "analytical_time VARCHAR NOT NULL, terminal_time VARCHAR NOT NULL,",
    "payload_hex VARCHAR NOT NULL)"
  ),
  paste(
    "CREATE TABLE history_actions (",
    "action_id VARCHAR PRIMARY KEY, target_kind VARCHAR NOT NULL,",
    "target_id VARCHAR NOT NULL, target_operation_run_id VARCHAR NOT NULL,",
    "replacement_operation_run_id VARCHAR, effective_time VARCHAR NOT NULL,",
    "payload_hex VARCHAR NOT NULL)"
  )
)

rrp_duckdb_connect <- function(path, read_only = FALSE) {
  driver <- NULL
  tryCatch(
    {
      driver <- duckdb::duckdb(dbdir = path, read_only = read_only)
      DBI::dbConnect(driver)
    },
    error = function(condition) {
      if (!is.null(driver)) try(duckdb::duckdb_shutdown(driver), silent = TRUE)
      detail <- conditionMessage(condition)
      unavailable <- grepl(
        "lock|already open|different configuration|permission|access denied|I/O",
        detail, ignore.case = TRUE, perl = TRUE
      )
      if (unavailable) {
        rrp_state_abort("state_unavailable", "Project state is unavailable.")
      }
      rrp_state_abort("state_corrupt", "Project state database is invalid.")
    }
  )
}

rrp_duckdb_disconnect <- function(connection) {
  if (inherits(connection, "DBIConnection") && DBI::dbIsValid(connection)) {
    try(DBI::dbDisconnect(connection, shutdown = TRUE), silent = TRUE)
  }
  invisible(NULL)
}

rrp_duckdb_with_connection <- function(path, metadata, contracts, read_only, callback) {
  connection <- NULL
  tryCatch({
    connection <- rrp_duckdb_connect(path, read_only = read_only)
    on.exit(rrp_duckdb_disconnect(connection), add = TRUE)
    rrp_duckdb_validate_connection(connection, metadata, contracts)
    callback(connection)
  }, error = function(condition) {
    if (inherits(condition, "rrp_state_error")) stop(condition)
    rrp_state_abort("state_access_failed", "Project state access failed.")
  })
}

rrp_duckdb_validate_connection <- function(connection, metadata, contracts) {
  expected <- rrp_duckdb_schema()
  tables <- sort(DBI::dbListTables(connection), method = "radix")
  if (!identical(tables, sort(names(expected), method = "radix"))) {
    rrp_state_abort("state_incompatible", "Project state schema is incompatible.")
  }
  for (table in names(expected)) {
    info <- DBI::dbGetQuery(
      connection, paste0("PRAGMA table_info('", table, "')")
    )
    if (!identical(as.character(info$name), names(expected[[table]])) ||
        !identical(as.character(info$type), unname(expected[[table]]))) {
      rrp_state_abort("state_incompatible", "Project state schema is incompatible.")
    }
  }
  rows <- DBI::dbGetQuery(
    connection,
    paste(
      "SELECT state_id, project_id, payload_hex FROM rrp_state_metadata",
      "WHERE metadata_key = ?"
    ),
    params = list("project_state")
  )
  if (nrow(rows) != 1L ||
      !identical(rows$state_id[[1L]], metadata[["State-ID"]]) ||
      !identical(rows$project_id[[1L]], metadata[["Project-ID"]]) ||
      !identical(rrp_duckdb_payload_decode(rows$payload_hex[[1L]]), metadata)) {
    rrp_state_abort("state_incompatible", "Project state metadata is incompatible.")
  }
  invisible(TRUE)
}

rrp_duckdb_validate_file <- function(path, metadata, contracts) {
  rrp_duckdb_with_connection(
    path, metadata, contracts, read_only = TRUE,
    callback = function(connection) invisible(TRUE)
  )
}

rrp_duckdb_initialize_file <- function(path, metadata, contracts) {
  if (rrp_state_path_exists(path)) rrp_state_abort(
    "state_initialization_failed", "Project state initialization failed."
  )
  connection <- NULL
  completed <- FALSE
  on.exit({
    if (!is.null(connection)) rrp_duckdb_disconnect(connection)
    if (!completed) unlink(c(path, paste0(path, ".wal")), force = TRUE)
  }, add = TRUE)
  connection <- rrp_duckdb_connect(path, read_only = FALSE)
  DBI::dbBegin(connection)
  committed <- FALSE
  on.exit(if (!committed && DBI::dbIsValid(connection)) {
    try(DBI::dbRollback(connection), silent = TRUE)
  }, add = TRUE)
  for (statement in rrp_duckdb_schema_statements()) {
    DBI::dbExecute(connection, statement)
  }
  DBI::dbExecute(
    connection,
    paste(
      "INSERT INTO rrp_state_metadata",
      "(metadata_key, state_id, project_id, payload_hex) VALUES (?, ?, ?, ?)"
    ),
    params = list(
      "project_state", metadata[["State-ID"]], metadata[["Project-ID"]],
      rrp_duckdb_payload_encode(metadata)
    )
  )
  DBI::dbCommit(connection)
  committed <- TRUE
  rrp_duckdb_validate_connection(connection, metadata, contracts)
  rrp_duckdb_disconnect(connection)
  connection <- NULL
  completed <- TRUE
  invisible(path)
}

rrp_duckdb_inject <- function(configured, stage) {
  if (!is.null(configured) && identical(configured, stage)) {
    rrp_state_abort("injected_interruption", "Injected project state interruption.")
  }
  invisible(NULL)
}

rrp_duckdb_transaction <- function(connection, failure_stage, callback) {
  rrp_duckdb_inject(failure_stage, "before_transaction")
  DBI::dbBegin(connection)
  committed <- FALSE
  on.exit(if (!committed && DBI::dbIsValid(connection)) {
    try(DBI::dbRollback(connection), silent = TRUE)
  }, add = TRUE)
  value <- callback()
  rrp_duckdb_inject(failure_stage, "before_commit")
  DBI::dbCommit(connection)
  committed <- TRUE
  rrp_duckdb_inject(failure_stage, "after_commit")
  value
}

rrp_duckdb_existing <- function(connection, table, identity_field, identity) {
  rows <- DBI::dbGetQuery(
    connection,
    paste0(
      "SELECT payload_hex FROM ", table, " WHERE ", identity_field, " = ?"
    ),
    params = list(identity)
  )
  if (!nrow(rows)) return(NULL)
  if (nrow(rows) != 1L) rrp_state_abort(
    "state_corrupt", "Project state identity is not unique."
  )
  rrp_duckdb_payload_decode(rows$payload_hex[[1L]])
}

rrp_duckdb_preflight <- function(
  connection, table, identity_field, identity, record
) {
  existing <- rrp_duckdb_existing(
    connection, table, identity_field, identity
  )
  if (!is.null(existing) && !identical(existing, record)) {
    rrp_state_abort(
      "history_identity_conflict", "History identity conflicts with stored content."
    )
  }
  is.null(existing)
}

rrp_duckdb_insert_scope <- function(connection, scope) {
  DBI::dbExecute(
    connection,
    paste(
      "INSERT INTO operational_scopes",
      "(operation_run_id, operation_key, target_id, analytical_time,",
      "created_at, payload_hex) VALUES (?, ?, ?, ?, ?, ?)"
    ),
    params = list(
      scope$operation_run_id, scope$operation_key, scope$target_id,
      scope$analytical_time, scope$created_at, rrp_duckdb_payload_encode(scope)
    )
  )
}

rrp_duckdb_insert_disposition <- function(connection, disposition) {
  DBI::dbExecute(
    connection,
    paste(
      "INSERT INTO episode_dispositions",
      "(analytical_run_id, operation_run_id, episode_id, target_id,",
      "analytical_time, terminal_time, payload_hex)",
      "VALUES (?, ?, ?, ?, ?, ?, ?)"
    ),
    params = list(
      disposition$analytical_run_id, disposition$operation_run_id,
      disposition$episode_id, disposition$target_id,
      disposition$analytical_time, disposition$terminal_time,
      rrp_duckdb_payload_encode(disposition)
    )
  )
}

rrp_duckdb_insert_action <- function(connection, action) {
  DBI::dbExecute(
    connection,
    paste(
      "INSERT INTO history_actions",
      "(action_id, target_kind, target_id, target_operation_run_id,",
      "replacement_operation_run_id, effective_time, payload_hex)",
      "VALUES (?, ?, ?, ?, ?, ?, ?)"
    ),
    params = list(
      action$action_id, action$target_kind, action$target_id,
      action$target_operation_run_id,
      if (is.null(action$replacement_operation_run_id)) NA_character_ else
        action$replacement_operation_run_id,
      action$effective_time, rrp_duckdb_payload_encode(action)
    )
  )
}

rrp_duckdb_decode_rows <- function(rows) {
  if (!nrow(rows)) return(list())
  lapply(rows$payload_hex, rrp_duckdb_payload_decode)
}

rrp_duckdb_placeholders <- function(values) {
  paste(rep("?", length(values)), collapse = ",")
}

rrp_duckdb_scope_raw_connection <- function(connection, operation_run_id) {
  operations <- operation_run_id
  repeat {
    placeholders <- rrp_duckdb_placeholders(operations)
    actions <- rrp_duckdb_decode_rows(DBI::dbGetQuery(
      connection,
      paste0(
        "SELECT payload_hex FROM history_actions WHERE ",
        "target_operation_run_id IN (", placeholders, ") OR ",
        "replacement_operation_run_id IN (", placeholders, ")"
      ),
      params = as.list(c(operations, operations))
    ))
    linked <- unique(c(
      operations,
      vapply(actions, `[[`, character(1L), "target_operation_run_id"),
      unlist(lapply(actions, `[[`, "replacement_operation_run_id"),
        use.names = FALSE)
    ))
    linked <- linked[!is.na(linked) & nzchar(linked)]
    if (setequal(linked, operations)) break
    operations <- linked
  }
  placeholders <- rrp_duckdb_placeholders(operations)
  scopes <- rrp_duckdb_decode_rows(DBI::dbGetQuery(
    connection,
    paste0(
      "SELECT payload_hex FROM operational_scopes WHERE operation_run_id IN (",
      placeholders, ") ORDER BY operation_run_id"
    ), params = as.list(operations)
  ))
  dispositions <- rrp_duckdb_decode_rows(DBI::dbGetQuery(
    connection,
    paste0(
      "SELECT payload_hex FROM episode_dispositions WHERE operation_run_id IN (",
      placeholders, ") ORDER BY analytical_time, operation_run_id, analytical_run_id"
    ), params = as.list(operations)
  ))
  actions <- rrp_duckdb_decode_rows(DBI::dbGetQuery(
    connection,
    paste0(
      "SELECT payload_hex FROM history_actions WHERE ",
      "target_operation_run_id IN (", placeholders, ") OR ",
      "replacement_operation_run_id IN (", placeholders, ") ",
      "ORDER BY effective_time, action_id"
    ), params = as.list(c(operations, operations))
  ))
  list(scopes = scopes, dispositions = dispositions, actions = actions)
}

rrp_duckdb_merge_raw <- function(parts) {
  output <- list(scopes = list(), dispositions = list(), actions = list())
  fields <- c(
    scopes = "operation_run_id", dispositions = "analytical_run_id",
    actions = "action_id"
  )
  for (part in parts) {
    for (collection in names(fields)) {
      for (record in part[[collection]]) {
        ids <- vapply(output[[collection]], `[[`, character(1L), fields[[collection]])
        if (!record[[fields[[collection]]]] %in% ids) {
          output[[collection]][[length(output[[collection]]) + 1L]] <- record
        }
      }
    }
  }
  output
}

rrp_duckdb_adapter <- function(database_path, metadata, contracts, failure_stage = NULL) {
  allowed_failures <- c(
    "before_transaction", "after_scope_insert", "after_disposition_insert",
    "after_action_insert", "after_replacement_insert", "before_commit",
    "after_commit"
  )
  if (!is.null(failure_stage) && !failure_stage %in% allowed_failures) {
    stop("Invalid internal interruption stage.", call. = FALSE)
  }
  with_connection <- function(read_only, callback) {
    rrp_duckdb_with_connection(
      database_path, metadata, contracts, read_only, callback
    )
  }
  append_scope <- function(scope) with_connection(FALSE, function(connection) {
    rrp_duckdb_transaction(connection, failure_stage, function() {
      insert <- rrp_duckdb_preflight(
        connection, "operational_scopes", "operation_run_id",
        scope$operation_run_id, scope
      )
      if (insert) rrp_duckdb_insert_scope(connection, scope)
      rrp_duckdb_inject(failure_stage, "after_scope_insert")
      invisible(scope)
    })
  })
  append_disposition <- function(disposition) {
    with_connection(FALSE, function(connection) {
      rrp_duckdb_transaction(connection, failure_stage, function() {
        insert <- rrp_duckdb_preflight(
          connection, "episode_dispositions", "analytical_run_id",
          disposition$analytical_run_id, disposition
        )
        if (insert) rrp_duckdb_insert_disposition(connection, disposition)
        rrp_duckdb_inject(failure_stage, "after_disposition_insert")
        invisible(disposition)
      })
    })
  }
  append_action <- function(action) with_connection(FALSE, function(connection) {
    rrp_duckdb_transaction(connection, failure_stage, function() {
      insert <- rrp_duckdb_preflight(
        connection, "history_actions", "action_id", action$action_id, action
      )
      if (insert) rrp_duckdb_insert_action(connection, action)
      rrp_duckdb_inject(failure_stage, "after_action_insert")
      invisible(action)
    })
  })
  append_restatement <- function(replacement, action) {
    with_connection(FALSE, function(connection) {
      rrp_duckdb_transaction(connection, failure_stage, function() {
        scope <- inherits(replacement, "rrp_operational_scope")
        table <- if (scope) "operational_scopes" else "episode_dispositions"
        field <- if (scope) "operation_run_id" else "analytical_run_id"
        replacement_id <- replacement[[field]]
        insert_replacement <- rrp_duckdb_preflight(
          connection, table, field, replacement_id, replacement
        )
        insert_action <- rrp_duckdb_preflight(
          connection, "history_actions", "action_id", action$action_id, action
        )
        if (!insert_action && insert_replacement) rrp_state_abort(
          "state_corrupt", "Project state contains an incomplete restatement."
        )
        if (insert_replacement) {
          if (scope) rrp_duckdb_insert_scope(connection, replacement) else
            rrp_duckdb_insert_disposition(connection, replacement)
        }
        rrp_duckdb_inject(failure_stage, "after_replacement_insert")
        if (insert_action) rrp_duckdb_insert_action(connection, action)
        rrp_duckdb_inject(failure_stage, "after_action_insert")
        invisible(list(replacement = replacement, action = action))
      })
    })
  }
  read_scope_history <- function(operation_run_id) {
    with_connection(TRUE, function(connection) {
      rrp_duckdb_scope_raw_connection(connection, operation_run_id)
    })
  }
  read_episode_history <- function(episode_id, target_id, history_cutoff) {
    with_connection(TRUE, function(connection) {
      rows <- DBI::dbGetQuery(
        connection,
        paste(
          "SELECT DISTINCT operation_run_id FROM episode_dispositions",
          "WHERE episode_id = ? AND target_id = ? ORDER BY operation_run_id"
        ),
        params = list(episode_id, target_id)
      )
      if (!nrow(rows)) return(list(
        scopes = list(), dispositions = list(), actions = list()
      ))
      rrp_duckdb_merge_raw(lapply(rows$operation_run_id, function(operation) {
        rrp_duckdb_scope_raw_connection(connection, operation)
      }))
    })
  }
  list(
    adapter_id = contracts$adapter[["Adapter-ID"]],
    adapter_version = contracts$adapter[["Adapter-Version"]],
    contract_id = contracts$adapter[["History-Port-Contract-ID"]],
    contract_version = contracts$adapter[["History-Port-Contract-Version"]],
    capabilities = structure(
      as.list(rep(TRUE, 8L)),
      names = c(
        "atomic_scope_append", "atomic_episode_append",
        "atomic_restatement_append", "identical_append_idempotency",
        "conflicting_identity_rejection", "immutable_raw_retention",
        "bounded_raw_reads", "detached_reads"
      )
    ),
    methods = list(
      append_scope = append_scope,
      append_disposition = append_disposition,
      append_action = append_action,
      append_restatement = append_restatement,
      read_scope_history = read_scope_history,
      read_episode_history = read_episode_history
    )
  )
}

rrp_state_history_port <- function(
  software_catalog, project_root, failure_stage = NULL
) {
  context <- rrp_load_project(software_catalog, project_root)
  contracts <- rrp_state_contracts(software_catalog)
  if (!rrp_state_path_exists(context$state_path)) rrp_state_abort(
    "state_uninitialized", "Project state has not been initialized."
  )
  metadata <- rrp_state_inspect_root(context$state_path, context, contracts)
  rrpruntime::rrp_new_history_port(rrp_duckdb_adapter(
    file.path(context$state_path, "history.duckdb"),
    metadata, contracts, failure_stage
  ))
}
