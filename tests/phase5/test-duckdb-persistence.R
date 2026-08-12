phase52_helpers <- new.env(parent = environment())
sys.source(file.path(
  repository_root, "tests", "phase5", "test-operational-history.R"
), envir = phase52_helpers)
for (file in c(
  "identity-configuration.R", "generate-source.R", "source-validation.R",
  "map-to-canonical.R", "producer.R"
)) sys.source(file.path(
  repository_root, "implementations", "synthetic-reference", "R", file
), envir = environment())
sys.source(file.path(
  repository_root, "operations", "lib", "reference-history-operation.R"
), envir = environment())

phase52_database <- function() tempfile("rrp-history-", fileext = ".duckdb")

phase52_open <- function(repository_root, path, read_only = FALSE) {
  contracts <- phase52_helpers$phase5_history_contracts(repository_root)
  rrp_initialize_duckdb_history(path)
  rrp_open_duckdb_persistence(path, contracts, read_only)
}

phase52_append <- function(session, fixture) {
  phase52_helpers$phase5_append_fixture(
    rrp_duckdb_persistence_port(session), fixture
  )
}

phase52_invalidation <- function(fixture, family, id, suffix = family) {
  rrpruntime::new_history_invalidation(
    family, id, fixture$terminal$runtime_run_id,
    "2026-01-11T13:00:00Z", paste0("fictional_", suffix),
    "Fictional adapter conformance correction.", fixture$contracts$invalidation
  )
}

phase5_test_cases <- function(repository_root) list(
  "DuckDB declaration, physical schema, and non-destructive initialization are explicit" = function() {
    path <- phase52_database()
    on.exit(unlink(c(path, paste0(path, ".wal")), force = TRUE), add = TRUE)
    first <- rrp_initialize_duckdb_history(path)
    size <- file.info(path)$size
    second <- rrp_initialize_duckdb_history(path)
    phase0_assert_true(isTRUE(first$created))
    phase0_assert_false(second$created)
    phase0_assert_true(identical(file.info(path)$size, size))
    connection <- rrp_duckdb_connect(path, read_only = TRUE)
    on.exit(rrp_duckdb_disconnect(connection), add = TRUE)
    expected <- c(
      "adapter_metadata", "operational_run_statuses", "episode_states",
      "estimand_requests", "provider_execution_results", "estimates",
      "history_invalidations"
    )
    phase0_assert_true(all(expected %in% DBI::dbListTables(connection)))
    declaration <- yaml::read_yaml(file.path(
      repository_root, "implementations", "persistence", "duckdb", "adapter.yml"
    ))
    configuration <- yaml::read_yaml(file.path(
      repository_root, "implementations", "persistence", "duckdb", "config",
      "reference.yml"
    ))
    phase0_assert_true(rrp_conforms(rrp_validate_specification_envelope(
      declaration, "implementations/persistence/duckdb/adapter.yml"
    )))
    phase0_assert_true(rrp_conforms(rrp_validate_specification_envelope(
      configuration,
      "implementations/persistence/duckdb/config/reference.yml"
    )))
    phase0_assert_true(identical(
      declaration$specification_id, "reference.duckdb-persistence"
    ))
    unknown <- tempfile("rrp-not-database-")
    on.exit(unlink(unknown, force = TRUE), add = TRUE)
    writeLines("do not overwrite", unknown)
    phase0_assert_error(
      rrp_initialize_duckdb_history(unknown), "Existing path"
    )
    phase0_assert_true(identical(readLines(unknown), "do not overwrite"))
  },

  "DuckDB round-trips every logical family exactly after close and reopen" = function() {
    path <- phase52_database()
    on.exit(unlink(c(path, paste0(path, ".wal")), force = TRUE), add = TRUE)
    fixture <- phase52_helpers$phase5_fixture(repository_root)
    session <- phase52_open(repository_root, path)
    phase52_append(session, fixture)
    invalidation <- phase52_invalidation(
      fixture, "estimate", fixture$estimates[[1L]]$estimate_id
    )
    rrpruntime::append_history_invalidations(
      rrp_duckdb_persistence_port(session), list(invalidation)
    )
    rrp_close_duckdb_persistence(session)
    reopened <- phase52_open(repository_root, path, read_only = TRUE)
    on.exit(rrp_close_duckdb_persistence(reopened), add = TRUE)
    port <- rrp_duckdb_persistence_port(reopened)
    expected <- list(
      operational_run = fixture$started,
      episode_state = fixture$states[[1L]],
      estimand_request = fixture$requests[[1L]],
      provider_execution_result = fixture$executions[[1L]],
      estimate = fixture$estimates[[1L]],
      invalidation = invalidation
    )
    ids <- c(
      fixture$started$run_status_record_id, fixture$states[[1L]]$state_id,
      fixture$requests[[1L]]$request_id,
      fixture$executions[[1L]]$execution_result_id,
      fixture$estimates[[1L]]$estimate_id, invalidation$invalidation_id
    )
    for (index in seq_along(expected)) phase0_assert_true(identical(
      rrpruntime::read_history_record(
        port, names(expected)[[index]], ids[[index]], "raw"
      ), expected[[index]]
    ))
  },

  "DuckDB identical rerun is a no-op and conflict survives restart" = function() {
    path <- phase52_database()
    on.exit(unlink(c(path, paste0(path, ".wal")), force = TRUE), add = TRUE)
    fixture <- phase52_helpers$phase5_fixture(repository_root)
    session <- phase52_open(repository_root, path)
    phase52_append(session, fixture)
    rrp_close_duckdb_persistence(session)
    reopened <- phase52_open(repository_root, path)
    phase52_append(reopened, fixture)
    port <- rrp_duckdb_persistence_port(reopened)
    phase0_assert_true(length(rrpruntime::read_run_history(
      port, fixture$terminal$runtime_run_id, "raw"
    )$estimate) == 1L)
    conflict <- unserialize(serialize(fixture$estimates[[1L]], NULL))
    conflict$estimate_value <- conflict$estimate_value + 0.01
    execution <- unserialize(serialize(fixture$executions[[1L]], NULL))
    execution$estimate_record <- conflict
    phase0_assert_error(rrpruntime::append_completed_run(
      port, fixture$terminal, fixture$states, fixture$requests,
      list(execution), list(conflict)
    ), "identity conflict")
    rrp_close_duckdb_persistence(reopened)
    final <- phase52_open(repository_root, path, read_only = TRUE)
    on.exit(rrp_close_duckdb_persistence(final), add = TRUE)
    stored <- rrpruntime::read_history_record(
      rrp_duckdb_persistence_port(final), "estimate",
      fixture$estimates[[1L]]$estimate_id, "raw"
    )
    phase0_assert_true(identical(stored, fixture$estimates[[1L]]))
  },

  "DuckDB terminal batch rolls back after every injected write stage" = function() {
    stages <- c(
      "run_status", "episode_states", "estimand_requests",
      "provider_execution_results", "estimates"
    )
    for (stage in stages) {
      path <- phase52_database()
      fixture <- phase52_helpers$phase5_fixture(
        repository_root, run_id = paste0("fictional_rollback_", stage)
      )
      normal <- phase52_open(repository_root, path)
      rrpruntime::append_run_status(
        rrp_duckdb_persistence_port(normal), fixture$started
      )
      rrp_close_duckdb_persistence(normal)
      injected <- rrp_duckdb_test_session(path, fixture$contracts, stage)
      phase0_assert_error(rrpruntime::append_completed_run(
        rrp_duckdb_persistence_port(injected), fixture$terminal,
        fixture$states, fixture$requests, fixture$executions, fixture$estimates
      ), "Injected DuckDB")
      rrp_close_duckdb_persistence(injected)
      reopened <- phase52_open(repository_root, path, read_only = TRUE)
      history <- rrpruntime::read_run_history(
        rrp_duckdb_persistence_port(reopened), fixture$terminal$runtime_run_id, "raw"
      )
      rrp_close_duckdb_persistence(reopened)
      phase0_assert_true(length(history$operational_run) == 1L)
      phase0_assert_true(all(lengths(history[c(
        "episode_state", "estimand_request", "provider_execution_result", "estimate"
      )]) == 0L))
      unlink(c(path, paste0(path, ".wal")), force = TRUE)
    }
  },

  "DuckDB preserves retry attempts and provider transition history" = function() {
    helpers <- phase52_helpers$phase5_runtime_helpers
    path <- phase52_database()
    on.exit(unlink(c(path, paste0(path, ".wal")), force = TRUE), add = TRUE)
    session <- phase52_open(repository_root, path)
    port <- rrp_duckdb_persistence_port(session)
    first <- phase52_helpers$phase5_fixture(repository_root)
    phase52_helpers$phase5_append_fixture(port, first)
    alternate_spec <- helpers$phase42_constant_specification(
      rrp_read_reference_provider_specification(repository_root), "0.1.0"
    )
    alternate <- helpers$phase42_registry(
      repository_root, alternate_spec, helpers$phase42_constant_adapter(0.21)
    )
    second <- phase52_helpers$phase5_fixture(
      repository_root, run_id = "fictional_duckdb_transition_002",
      as_of_time = "2026-01-11T12:00:00Z", registered = alternate
    )
    phase52_helpers$phase5_append_fixture(port, second)
    history <- rrpruntime::read_episode_estimate_history(
      port, first$estimates[[1L]]$episode_id, NULL, "valid"
    )
    phase0_assert_true(length(history) == 2L)
    current <- rrpruntime::read_current_estimate(
      port, second$estimates[[1L]]$episode_id,
      second$estimates[[1L]]$estimand_specification$specification_id,
      "2026-01-12T12:00:00Z"
    )
    phase0_assert_true(identical(current$runtime_run_id, second$terminal$runtime_run_id))

    failing <- helpers$phase42_registry(
      repository_root, adapter = function(...) stop("fictional failure")
    )
    failed <- phase52_helpers$phase5_fixture(
      repository_root, run_id = "fictional_duckdb_retry", registered = failing
    )
    successful <- phase52_helpers$phase5_fixture(
      repository_root, run_id = "fictional_duckdb_retry",
      provider_execution_run_id = "fictional_duckdb_retry_provider_002",
      attempt_number = 2L,
      retry_of = failed$executions[[1L]]$execution_result_id
    )
    successful$executions <- c(failed$executions, successful$executions)
    successful$terminal$status_summary$provider_execution_result_count <- 2L
    successful$terminal$status_summary$failed_execution_count <- 1L
    successful$terminal <- rrpruntime::new_operational_run_status(
      successful$terminal$runtime_run_id, "completed_with_failures",
      successful$terminal$status_time, successful$terminal$as_of_time,
      successful$terminal$bundle_instance_id, successful$terminal$canonical_run_id,
      successful$terminal$implementation_reference,
      successful$terminal$mapping_reference,
      successful$contracts$operational_run_status,
      previous_run_status_record_id = successful$started$run_status_record_id,
      status_summary = successful$terminal$status_summary
    )
    rrpruntime::append_run_status(port, successful$started)
    rrpruntime::append_completed_run(
      port, successful$terminal, successful$states, successful$requests,
      successful$executions, successful$estimates
    )
    phase0_assert_true(length(rrpruntime::read_run_history(
      port, "fictional_duckdb_retry", "raw"
    )$provider_execution_result) == 2L)
    rrp_close_duckdb_persistence(session)
  },

  "DuckDB resolves every invalidation target family and keeps raw facts" = function() {
    targets <- c(
      operational_run = "runtime_run_id", episode_state = "state_id",
      estimand_request = "request_id",
      provider_execution_result = "execution_result_id", estimate = "estimate_id"
    )
    for (family in names(targets)) {
      path <- phase52_database()
      fixture <- phase52_helpers$phase5_fixture(
        repository_root, run_id = paste0("fictional_invalidation_", family)
      )
      session <- phase52_open(repository_root, path)
      phase52_append(session, fixture)
      target <- switch(family,
        operational_run = fixture$terminal$runtime_run_id,
        episode_state = fixture$states[[1L]]$state_id,
        estimand_request = fixture$requests[[1L]]$request_id,
        provider_execution_result = fixture$executions[[1L]]$execution_result_id,
        estimate = fixture$estimates[[1L]]$estimate_id
      )
      invalidation <- phase52_invalidation(fixture, family, target)
      port <- rrp_duckdb_persistence_port(session)
      rrpruntime::append_history_invalidations(port, list(invalidation))
      phase0_assert_true(!is.null(rrpruntime::read_history_record(
        port, family, if (identical(family, "operational_run")) {
          fixture$started$run_status_record_id
        } else target, "raw"
      )))
      phase0_assert_true(length(rrpruntime::read_episode_estimate_history(
        port, fixture$estimates[[1L]]$episode_id, NULL, "valid"
      )) == 0L)
      rrp_close_duckdb_persistence(session)
      unlink(c(path, paste0(path, ".wal")), force = TRUE)
    }
  },

  "DuckDB preserves failed lifecycle and durable restatement lineage" = function() {
    path <- phase52_database()
    on.exit(unlink(c(path, paste0(path, ".wal")), force = TRUE), add = TRUE)
    session <- phase52_open(repository_root, path)
    port <- rrp_duckdb_persistence_port(session)
    original <- phase52_helpers$phase5_fixture(repository_root)
    phase52_helpers$phase5_append_fixture(port, original)
    invalidation <- rrpruntime::new_history_invalidation(
      "operational_run", original$terminal$runtime_run_id,
      original$terminal$runtime_run_id, "2026-01-11T13:00:00Z",
      "fictional_restatement", "Fictional durable restatement.",
      original$contracts$invalidation,
      replacement_runtime_run_id = "fictional_duckdb_restatement"
    )
    rrpruntime::append_history_invalidations(port, list(invalidation))
    restated <- phase52_helpers$phase5_fixture(
      repository_root, run_id = "fictional_duckdb_restatement",
      as_of_time = "2026-01-11T12:00:00Z",
      run_provenance = list(list(
        provenance_type = "history_invalidation",
        provenance_id = invalidation$invalidation_id,
        relationship = "restates"
      ))
    )
    phase52_helpers$phase5_append_fixture(port, restated)

    failed_fixture <- phase52_helpers$phase5_fixture(
      repository_root, run_id = "fictional_duckdb_failed"
    )
    failed <- rrpruntime::new_operational_run_status(
      failed_fixture$started$runtime_run_id, "failed",
      failed_fixture$started$status_time, failed_fixture$started$as_of_time,
      failed_fixture$started$bundle_instance_id,
      failed_fixture$started$canonical_run_id,
      failed_fixture$started$implementation_reference,
      failed_fixture$started$mapping_reference,
      failed_fixture$contracts$operational_run_status,
      previous_run_status_record_id = failed_fixture$started$run_status_record_id,
      status_summary = list(failure_stage = "fictional_test")
    )
    rrpruntime::append_run_status(port, failed_fixture$started)
    rrpruntime::append_run_status(port, failed)
    rrp_close_duckdb_persistence(session)

    reopened <- phase52_open(repository_root, path, read_only = TRUE)
    on.exit(rrp_close_duckdb_persistence(reopened), add = TRUE)
    reopened_port <- rrp_duckdb_persistence_port(reopened)
    phase0_assert_true(length(rrpruntime::read_episode_estimate_history(
      reopened_port, original$estimates[[1L]]$episode_id, NULL, "raw"
    )) == 2L, "Raw history did not retain original plus restatement.")
    current <- rrpruntime::read_current_estimate(
      reopened_port, restated$estimates[[1L]]$episode_id,
      restated$estimates[[1L]]$estimand_specification$specification_id,
      "2026-01-12T12:00:00Z"
    )
    phase0_assert_true(identical(
      current$runtime_run_id, "fictional_duckdb_restatement"
    ), "Restatement did not become current.")
    failed_history <- rrpruntime::read_run_history(
      reopened_port, "fictional_duckdb_failed", "raw"
    )
    phase0_assert_true(identical(
      unname(vapply(
        failed_history$operational_run, `[[`, character(1), "run_status"
      )),
      c("started", "failed")
    ), "Failed run lifecycle was not retained in sequence.")
    phase0_assert_true(sum(lengths(failed_history[c(
      "episode_state", "estimand_request", "provider_execution_result", "estimate"
    )])) == 0L, "Failed run unexpectedly retained terminal batch members.")
  },

  "DuckDB deterministic history ordering does not hide semantic current ties" = function() {
    path <- phase52_database()
    on.exit(unlink(c(path, paste0(path, ".wal")), force = TRUE), add = TRUE)
    session <- phase52_open(repository_root, path)
    port <- rrp_duckdb_persistence_port(session)
    first <- phase52_helpers$phase5_fixture(
      repository_root, run_id = "fictional_tie_a"
    )
    second <- phase52_helpers$phase5_fixture(
      repository_root, run_id = "fictional_tie_b"
    )
    phase52_helpers$phase5_append_fixture(port, second)
    phase52_helpers$phase5_append_fixture(port, first)
    history <- rrpruntime::read_episode_estimate_history(
      port, first$estimates[[1L]]$episode_id, NULL, "raw"
    )
    phase0_assert_true(identical(
      vapply(history, `[[`, character(1), "estimate_id"),
      sort(vapply(history, `[[`, character(1), "estimate_id"))
    ))
    phase0_assert_error(rrpruntime::read_current_estimate(
      port, first$estimates[[1L]]$episode_id,
      first$estimates[[1L]]$estimand_specification$specification_id,
      "2026-01-11T12:00:00Z"
    ), "ambiguous")
    rrp_close_duckdb_persistence(session)
  },

  "DuckDB incompatible schema version fails and backup reopens cleanly" = function() {
    path <- phase52_database()
    backup <- tempfile("rrp-history-backup-", fileext = ".duckdb")
    on.exit(unlink(c(
      path, paste0(path, ".wal"), backup, paste0(backup, ".wal")
    ), force = TRUE), add = TRUE)
    fixture <- phase52_helpers$phase5_fixture(repository_root)
    session <- phase52_open(repository_root, path)
    phase52_append(session, fixture)
    rrp_close_duckdb_persistence(session)
    rrp_backup_duckdb_history(path, backup)
    restored <- phase52_open(repository_root, backup, read_only = TRUE)
    phase0_assert_true(length(rrpruntime::read_run_history(
      rrp_duckdb_persistence_port(restored), fixture$terminal$runtime_run_id, "raw"
    )$estimate) == 1L)
    rrp_close_duckdb_persistence(restored)
    connection <- rrp_duckdb_connect(path)
    DBI::dbExecute(
      connection,
      "UPDATE adapter_metadata SET schema_version = ? WHERE metadata_key = ?",
      params = list("99.0.0", "platform_operational_history")
    )
    rrp_duckdb_disconnect(connection)
    phase0_assert_error(
      phase52_open(repository_root, path), "incompatible"
    )
    phase0_assert_error(
      rrp_backup_duckdb_history(backup, backup), "new file"
    )
  },

  "DuckDB durable reference operation is end-to-end and repeatable" = function() {
    path <- phase52_database()
    on.exit(unlink(c(path, paste0(path, ".wal")), force = TRUE), add = TRUE)
    first <- rrp_run_reference_history(repository_root, "test", path)
    second <- rrp_run_reference_history(repository_root, "test", path)
    expected <- list(
      run_statuses = 2L, episode_states = 6L, estimand_requests = 6L,
      provider_execution_results = 6L, estimates = 6L, invalidations = 0L
    )
    phase0_assert_true(identical(first$counts, expected))
    phase0_assert_true(identical(second$counts, expected))
    phase0_assert_true(identical(first$runtime_run_id, second$runtime_run_id))
    phase0_assert_true(identical(first$run_status, "completed"))
  },

  "DuckDB remains absent from runtime and language-neutral contracts" = function() {
    runtime_files <- list.files(
      file.path(repository_root, "runtime"), recursive = TRUE,
      full.names = TRUE, pattern = "[.](R|Rd|DESCRIPTION)$"
    )
    contract_files <- list.files(
      file.path(repository_root, "contracts"), recursive = TRUE,
      full.names = TRUE, pattern = "[.]yml$"
    )
    runtime_text <- paste(unlist(lapply(runtime_files, readLines, warn = FALSE)), collapse = "\n")
    contract_text <- paste(unlist(lapply(contract_files, readLines, warn = FALSE)), collapse = "\n")
    backend_pattern <- "duckdb|DBI::|database_path|\\b(SELECT|INSERT)\\s"
    phase0_assert_false(grepl(backend_pattern, runtime_text))
    phase0_assert_false(grepl(backend_pattern, contract_text))
  }
)
