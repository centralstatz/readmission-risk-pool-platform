phase6_history_helpers <- new.env(parent = environment())
sys.source(file.path(
  repository_root, "tests", "phase5", "test-operational-history.R"
), envir = phase6_history_helpers)

phase6_contracts <- function(repository_root) {
  rrp_read_product_contracts(repository_root)
}

phase6_assert_identical <- function(actual, expected) {
  phase0_assert_true(
    identical(actual, expected),
    paste0(
      "Expected identical values; actual: ", paste(actual, collapse = ", "),
      "; expected: ", paste(expected, collapse = ", ")
    )
  )
}

phase6_assert_setequal <- function(actual, expected) {
  phase0_assert_true(
    setequal(actual, expected),
    paste0(
      "Expected equal sets; actual: ", paste(actual, collapse = ", "),
      "; expected: ", paste(expected, collapse = ", ")
    )
  )
}

phase6_build <- function(
  port,
  run_ids,
  repository_root,
  cutoff = "2026-01-12T12:00:00Z",
  generated_at = "2026-01-13T12:00:00Z"
) {
  rrp_build_logical_product_set(
    port,
    run_ids,
    cutoff,
    generated_at,
    phase6_contracts(repository_root)
  )
}

phase6_provider_transition <- function(repository_root, port) {
  helpers <- phase6_history_helpers
  first <- helpers$phase5_fixture(repository_root)
  helpers$phase5_append_fixture(port, first)
  provider_helpers <- helpers$phase5_runtime_helpers
  alternate_spec <- provider_helpers$phase42_constant_specification(
    rrp_read_reference_provider_specification(repository_root),
    "0.1.0"
  )
  alternate <- provider_helpers$phase42_registry(
    repository_root,
    alternate_spec,
    provider_helpers$phase42_constant_adapter(0.21)
  )
  second <- helpers$phase5_fixture(
    repository_root,
    run_id = "fictional_history_run_002",
    as_of_time = "2026-01-11T12:00:00Z",
    registered = alternate
  )
  helpers$phase5_append_fixture(port, second)
  list(first = first, second = second)
}

phase6_retry_fixture <- function(repository_root) {
  helpers <- phase6_history_helpers
  provider_helpers <- helpers$phase5_runtime_helpers
  failing <- provider_helpers$phase42_registry(
    repository_root,
    adapter = function(...) stop("fictional failure")
  )
  first <- helpers$phase5_fixture(repository_root, registered = failing)
  successful <- provider_helpers$phase42_registry(repository_root)
  second <- helpers$phase5_fixture(
    repository_root,
    provider_execution_run_id = "fictional_history_run_001_provider_002",
    attempt_number = 2L,
    retry_of = first$executions[[1L]]$execution_result_id,
    registered = successful
  )
  second$executions <- c(first$executions, second$executions)
  summary <- second$terminal$status_summary
  summary$provider_execution_result_count <- 2L
  summary$failed_execution_count <- 1L
  second$terminal <- rrpruntime::new_operational_run_status(
    second$terminal$runtime_run_id,
    "completed_with_failures",
    second$terminal$status_time,
    second$terminal$as_of_time,
    second$terminal$bundle_instance_id,
    second$terminal$canonical_run_id,
    second$terminal$implementation_reference,
    second$terminal$mapping_reference,
    second$contracts$operational_run_status,
    previous_run_status_record_id = second$started$run_status_record_id,
    status_summary = summary
  )
  second
}

phase6_test_cases <- function(repository_root) list(
  "product contracts define a complete backend-neutral core suite" = function() {
    contracts <- phase6_contracts(repository_root)
    phase0_assert_true(rrp_product_conforms(
      rrp_product_contracts_conformance(contracts)
    ))
    phase6_assert_setequal(names(contracts$product_set$required_products), c(
      "current_episode_risk", "episode_risk_history", "operational_run_summary"
    ))
    product_files <- list.files(
      file.path(repository_root, "products", "R"),
      pattern = "[.]R$",
      recursive = TRUE,
      full.names = TRUE
    )
    product_text <- paste(unlist(lapply(product_files, readLines, warn = FALSE)),
      collapse = "\n"
    )
    for (forbidden in c("DBI", "duckdb", "dbGetQuery", "Shiny", "synthetic-reference")) {
      phase0_assert_false(grepl(forbidden, product_text, fixed = TRUE))
    }
  },

  "current risk uses persistence current selection and deterministic freshness identity" = function() {
    port <- phase6_history_helpers$phase5_port(repository_root)
    fixtures <- phase6_provider_transition(repository_root, port)
    first <- phase6_build(
      port,
      c(fixtures$first$terminal$runtime_run_id, fixtures$second$terminal$runtime_run_id),
      repository_root
    )
    phase6_assert_identical(first$overall_status, "succeeded")
    product <- first$products$current_episode_risk
    phase6_assert_identical(product$row_count, 1L)
    phase6_assert_identical(
      product$rows[[1L]]$estimate_id,
      fixtures$second$estimates[[1L]]$estimate_id
    )
    phase0_assert_false(any(c(
      "priority", "risk_category", "recommended_action"
    ) %in% names(product$rows[[1L]])))
    later_build <- phase6_build(
      port,
      c(fixtures$first$terminal$runtime_run_id, fixtures$second$terminal$runtime_run_id),
      repository_root,
      generated_at = "2026-01-14T12:00:00Z"
    )
    phase6_assert_identical(
      first$product_set$product_set_id,
      later_build$product_set$product_set_id
    )
    phase6_assert_identical(
      first$products$current_episode_risk$product_instance_id,
      later_build$products$current_episode_risk$product_instance_id
    )
    phase0_assert_false(identical(
      first$product_set$product_generated_at,
      later_build$product_set$product_generated_at
    ))
  },

  "history preserves provider transition without trajectory recomputation" = function() {
    port <- phase6_history_helpers$phase5_port(repository_root)
    fixtures <- phase6_provider_transition(repository_root, port)
    built <- phase6_build(
      port,
      c(fixtures$first$terminal$runtime_run_id, fixtures$second$terminal$runtime_run_id),
      repository_root
    )
    history <- built$products$episode_risk_history
    phase6_assert_identical(history$row_count, 2L)
    phase6_assert_setequal(
      vapply(history$rows, `[[`, character(1), "provider_id"),
      c(
        fixtures$first$estimates[[1L]]$provider_reference$provider_id,
        fixtures$second$estimates[[1L]]$provider_reference$provider_id
      )
    )
    phase0_assert_true(all(vapply(
      history$rows,
      function(row) identical(row$validity_status, "valid"),
      logical(1)
    )))
  },

  "invalidation is excluded and restatement provenance remains visible" = function() {
    helpers <- phase6_history_helpers
    port <- helpers$phase5_port(repository_root)
    first <- helpers$phase5_fixture(repository_root)
    helpers$phase5_append_fixture(port, first)
    invalidation <- rrpruntime::new_history_invalidation(
      "operational_run",
      first$terminal$runtime_run_id,
      first$terminal$runtime_run_id,
      "2026-01-11T13:00:00Z",
      "fictional_input_correction",
      "Fictional product restatement fixture.",
      first$contracts$invalidation,
      replacement_runtime_run_id = "fictional_product_restatement"
    )
    rrpruntime::append_history_invalidations(port, list(invalidation))
    restated <- helpers$phase5_fixture(
      repository_root,
      run_id = "fictional_product_restatement",
      as_of_time = "2026-01-11T12:00:00Z",
      run_provenance = list(
        list(
          provenance_type = "history_invalidation",
          provenance_id = invalidation$invalidation_id,
          relationship = "restates"
        ),
        list(
          provenance_type = "operational_run",
          provenance_id = first$terminal$runtime_run_id,
          relationship = "supersedes"
        )
      )
    )
    helpers$phase5_append_fixture(port, restated)
    built <- phase6_build(
      port,
      restated$terminal$runtime_run_id,
      repository_root
    )
    rows <- built$products$episode_risk_history$rows
    phase6_assert_identical(length(rows), 1L)
    phase6_assert_identical(rows[[1L]]$estimate_id, restated$estimates[[1L]]$estimate_id)
    phase0_assert_false(identical(rows[[1L]]$estimate_id, first$estimates[[1L]]$estimate_id))
    phase6_assert_setequal(
      vapply(
        rows[[1L]]$source_run_provenance_references,
        `[[`,
        character(1),
        "relationship"
      ),
      c("restates", "supersedes")
    )
  },

  "run summary retains completed-with-failures and exact persisted counts" = function() {
    helpers <- phase6_history_helpers
    port <- helpers$phase5_port(repository_root)
    fixture <- phase6_retry_fixture(repository_root)
    helpers$phase5_append_fixture(port, fixture)
    built <- phase6_build(port, fixture$terminal$runtime_run_id, repository_root)
    row <- built$products$operational_run_summary$rows[[1L]]
    phase6_assert_identical(row$terminal_status, "completed_with_failures")
    phase6_assert_identical(row$provider_execution_result_count, 2L)
    phase6_assert_identical(row$successful_estimate_count, 1L)
    phase6_assert_identical(row$failed_execution_count, 1L)
  },

  "supported zero-row risk products remain available rather than failed" = function() {
    helpers <- phase6_history_helpers
    failing <- helpers$phase5_runtime_helpers$phase42_registry(
      repository_root,
      adapter = function(...) stop("fictional failure")
    )
    fixture <- helpers$phase5_fixture(repository_root, registered = failing)
    port <- helpers$phase5_port(repository_root)
    helpers$phase5_append_fixture(port, fixture)
    built <- phase6_build(port, fixture$terminal$runtime_run_id, repository_root)
    phase6_assert_identical(built$overall_status, "succeeded")
    phase6_assert_identical(built$products$current_episode_risk$row_count, 0L)
    phase6_assert_identical(built$products$episode_risk_history$row_count, 0L)
    phase6_assert_identical(
      built$products$current_episode_risk$availability_status,
      "available"
    )
    phase6_assert_identical(
      built$products$operational_run_summary$rows[[1L]]$terminal_status,
      "completed_with_failures"
    )
  },

  "product conformance reports duplicate freshness version and reference issues" = function() {
    helpers <- phase6_history_helpers
    port <- helpers$phase5_port(repository_root)
    fixture <- helpers$phase5_fixture(repository_root)
    helpers$phase5_append_fixture(port, fixture)
    built <- phase6_build(port, fixture$terminal$runtime_run_id, repository_root)
    contracts <- phase6_contracts(repository_root)
    history <- rrpruntime::read_run_history(
      port,
      fixture$terminal$runtime_run_id,
      "valid"
    )
    source <- rrp_product_source_index(
      stats::setNames(list(history), fixture$terminal$runtime_run_id),
      fixture$terminal$runtime_run_id,
      built$product_set$source_cutoff_time
    )
    duplicate <- rrp_product_copy(built$products$episode_risk_history)
    duplicate$rows <- c(duplicate$rows, duplicate$rows)
    duplicate$row_count <- 2L
    malformed <- rrp_product_copy(duplicate)
    malformed$source_as_of_time <- "not-a-time"
    malformed$rows[[1L]]$state_id <- "unknown_state"
    result <- rrp_validate_logical_product(
      malformed,
      contracts$episode_risk_history,
      source
    )
    phase0_assert_false(rrp_product_conforms(result))
    phase0_assert_true(all(c(
      "duplicate_product_row_key", "invalid_product_freshness",
      "unknown_upstream_reference"
    ) %in% result$issues$issue_code))
    incompatible <- rrp_product_copy(history)
    incompatible$estimate[[1L]]$estimate_specification$specification_version <- "0.9.0"
    compatibility <- rrp_validate_product_source_histories(
      stats::setNames(list(incompatible), fixture$terminal$runtime_run_id),
      fixture$terminal$runtime_run_id,
      contracts
    )
    phase0_assert_false(rrp_product_conforms(compatibility))
    phase0_assert_true("unsupported_upstream_specification" %in%
      compatibility$issues$issue_code)
  },

  "logical access exposes only a coherent successful product set" = function() {
    helpers <- phase6_history_helpers
    port <- helpers$phase5_port(repository_root)
    fixture <- helpers$phase5_fixture(repository_root)
    helpers$phase5_append_fixture(port, fixture)
    built <- phase6_build(port, fixture$terminal$runtime_run_id, repository_root)
    access <- new_logical_product_access(built)
    listed <- access$list_products()
    phase6_assert_identical(length(listed), 3L)
    product <- access$read_product(
      "platform.current-episode-risk",
      "0.1.0",
      built$product_set$product_set_id
    )
    phase6_assert_identical(product$row_count, 1L)
    metadata <- access$read_product_metadata(
      "platform.current-episode-risk",
      "0.1.0",
      built$product_set$product_set_id
    )
    phase0_assert_true(is.null(metadata$rows))
    phase0_assert_error(access$read_product(
      "platform.current-episode-risk",
      "0.1.0",
      "different_set"
    ), "not available")
  },

  "in-memory and DuckDB ports produce identical logical products" = function() {
    helpers <- phase6_history_helpers
    in_memory <- helpers$phase5_port(repository_root)
    fixtures <- phase6_provider_transition(repository_root, in_memory)
    run_ids <- c(
      fixtures$first$terminal$runtime_run_id,
      fixtures$second$terminal$runtime_run_id
    )
    expected <- phase6_build(in_memory, run_ids, repository_root)

    database_path <- tempfile("phase6-products-", fileext = ".duckdb")
    on.exit(unlink(database_path, force = TRUE), add = TRUE)
    rrp_initialize_duckdb_history(database_path)
    session <- rrp_open_duckdb_persistence(
      database_path,
      fixtures$first$contracts
    )
    on.exit(rrp_close_duckdb_persistence(session), add = TRUE)
    durable <- rrp_duckdb_persistence_port(session)
    helpers$phase5_append_fixture(durable, fixtures$first)
    helpers$phase5_append_fixture(durable, fixtures$second)
    actual <- phase6_build(durable, run_ids, repository_root)
    phase6_assert_identical(actual$product_set, expected$product_set)
    phase6_assert_identical(actual$products, expected$products)
  },

  "source read failures are structured and never masquerade as empty products" = function() {
    port <- phase6_history_helpers$phase5_port(repository_root)
    port$adapter$methods$read_run_history <- function(...) stop("fictional read failure")
    result <- phase6_build(port, "fictional_missing_run", repository_root)
    phase6_assert_identical(result$overall_status, "failed")
    phase6_assert_identical(result$failure_stage, "source_history_read")
    phase6_assert_identical(length(result$products), 0L)
  }
)
