phase5_runtime_helpers <- new.env(parent = environment())
sys.source(file.path(
  repository_root, "tests", "phase4", "test-provider-foundation.R"
), envir = phase5_runtime_helpers)

phase5_history_contracts <- function(repository_root) {
  paths <- c(
    operational_run_status = "operational-run-status.yml",
    invalidation = "history-invalidation.yml",
    persistence_adapter = "persistence-adapter.yml"
  )
  documents <- lapply(paths, function(path) {
    parsed <- rrp_parse_yaml_specification(file.path(
      repository_root, "contracts", "persistence", path
    ))
    if (!is.null(parsed$error)) stop(parsed$error, call. = FALSE)
    parsed$document
  })
  names(documents) <- names(paths)
  documents
}

phase5_fixture <- function(
  repository_root,
  run_id = "fictional_history_run_001",
  as_of_time = "2026-01-10T12:00:00Z",
  provider_execution_run_id = paste0(run_id, "_provider_001"),
  attempt_number = 1L,
  retry_of = NULL,
  registered = NULL,
  run_provenance = list()
) {
  helpers <- phase5_runtime_helpers
  input <- helpers$phase42_input()
  input$bundle_as_of_time <- as_of_time
  runtime_contracts <- rrp_read_runtime_contracts(repository_root)
  context <- list(run_id = run_id, as_of_time = as_of_time)
  eligibility <- rrpruntime::evaluate_episode_eligibility(input, context, runtime_contracts)
  states <- rrpruntime::build_episode_states(input, eligibility, context, runtime_contracts)
  requests <- rrpruntime::build_estimand_requests(states, eligibility, context, runtime_contracts)
  if (is.null(registered)) registered <- helpers$phase42_registry(repository_root)
  execution <- rrpruntime::execute_provider(
    registered$registry, registered$specification$provider_id,
    registered$specification$provider_version, requests$records[[1L]],
    states$records[[1L]], provider_execution_run_id, runtime_contracts,
    registered$contracts$provider, attempt_number, retry_of
  )
  history_contracts <- phase5_history_contracts(repository_root)
  implementation <- list(
    implementation_id = "reference.synthetic", implementation_version = "0.1.0"
  )
  mapping <- list(mapping_id = "reference.synthetic-to-canonical", mapping_version = "0.1.0")
  started <- rrpruntime::new_operational_run_status(
    run_id, "started", as_of_time, as_of_time, input$bundle_instance_id,
    input$canonical_run_id, implementation, mapping,
    history_contracts$operational_run_status,
    provenance_references = run_provenance
  )
  failed_count <- as.integer(!identical(execution$execution_status, "successful_estimate"))
  estimates <- if (failed_count == 0L) list(execution$estimate_record) else list()
  summary <- list(
    episode_state_count = length(states$records),
    estimand_request_count = length(requests$records),
    provider_execution_result_count = 1L,
    successful_estimate_count = length(estimates),
    failed_execution_count = failed_count
  )
  terminal <- rrpruntime::new_operational_run_status(
    run_id, if (failed_count == 0L) "completed" else "completed_with_failures",
    as_of_time, as_of_time, input$bundle_instance_id, input$canonical_run_id,
    implementation, mapping, history_contracts$operational_run_status,
    previous_run_status_record_id = started$run_status_record_id,
    status_summary = summary,
    provenance_references = run_provenance
  )
  list(
    contracts = history_contracts, started = started, terminal = terminal,
    states = states$records, requests = requests$records,
    executions = list(execution), estimates = estimates,
    registered = registered
  )
}

phase5_port <- function(repository_root) rrpruntime::new_persistence_port(
  phase5_in_memory_adapter(), phase5_history_contracts(repository_root)
)

phase5_append_fixture <- function(port, fixture) {
  rrpruntime::append_run_status(port, fixture$started)
  rrpruntime::append_completed_run(
    port, fixture$terminal, fixture$states, fixture$requests,
    fixture$executions, fixture$estimates
  )
}

phase5_test_cases <- function(repository_root) list(
  "history contracts and test adapter conform without a backend dependency" = function() {
    contracts <- phase5_history_contracts(repository_root)
    phase0_assert_true(rrpruntime::runtime_conforms(
      rrpruntime::validate_history_contracts(contracts)
    ))
    phase0_assert_true(rrpruntime::runtime_conforms(
      rrpruntime::validate_persistence_adapter(
        phase5_in_memory_adapter(), contracts$persistence_adapter
      )
    ))
    description <- read.dcf(file.path(repository_root, "runtime", "DESCRIPTION"))
    phase0_assert_true(identical(description[[1L, "Version"]], "0.3.0"))
    phase0_assert_false("Imports" %in% colnames(description))
  },

  "completed run appends and reads as one coherent history" = function() {
    port <- phase5_port(repository_root)
    fixture <- phase5_fixture(repository_root)
    phase5_append_fixture(port, fixture)
    run <- rrpruntime::read_run_history(port, fixture$terminal$runtime_run_id)
    phase0_assert_true(length(run$operational_run) == 2L)
    phase0_assert_true(length(run$episode_state) == 1L)
    phase0_assert_true(length(run$estimand_request) == 1L)
    phase0_assert_true(length(run$provider_execution_result) == 1L)
    phase0_assert_true(length(run$estimate) == 1L)
    current <- rrpruntime::read_current_estimate(
      port, fixture$estimates[[1L]]$episode_id,
      fixture$estimates[[1L]]$estimand_specification$specification_id,
      "2026-01-11T12:00:00Z"
    )
    phase0_assert_true(identical(current$estimate_id, fixture$estimates[[1L]]$estimate_id))
  },

  "identical retry is idempotent and same identity conflict is loud" = function() {
    port <- phase5_port(repository_root)
    fixture <- phase5_fixture(repository_root)
    phase5_append_fixture(port, fixture)
    phase5_append_fixture(port, fixture)
    phase0_assert_true(length(rrpruntime::read_run_history(
      port, fixture$terminal$runtime_run_id, "raw"
    )$estimate) == 1L)
    conflicting_estimate <- phase5_copy(fixture$estimates[[1L]])
    conflicting_estimate$estimate_value <- conflicting_estimate$estimate_value + 0.01
    conflicting_execution <- phase5_copy(fixture$executions[[1L]])
    conflicting_execution$estimate_record <- conflicting_estimate
    phase0_assert_error(rrpruntime::append_completed_run(
      port, fixture$terminal, fixture$states, fixture$requests,
      list(conflicting_execution), list(conflicting_estimate)
    ), "identity conflict")
  },

  "provider failure retry preserves attempt lineage and accepts one estimate" = function() {
    helpers <- phase5_runtime_helpers
    failing <- helpers$phase42_registry(
      repository_root, adapter = function(...) stop("fictional failure")
    )
    first <- phase5_fixture(repository_root, registered = failing)
    successful_registry <- helpers$phase42_registry(repository_root)
    second <- phase5_fixture(
      repository_root,
      provider_execution_run_id = "fictional_history_run_001_provider_002",
      attempt_number = 2L,
      retry_of = first$executions[[1L]]$execution_result_id,
      registered = successful_registry
    )
    second$executions <- c(first$executions, second$executions)
    second$terminal$status_summary$provider_execution_result_count <- 2L
    second$terminal$status_summary$failed_execution_count <- 1L
    second$terminal <- rrpruntime::new_operational_run_status(
      second$terminal$runtime_run_id, "completed_with_failures",
      second$terminal$status_time, second$terminal$as_of_time,
      second$terminal$bundle_instance_id, second$terminal$canonical_run_id,
      second$terminal$implementation_reference, second$terminal$mapping_reference,
      second$contracts$operational_run_status,
      previous_run_status_record_id = second$started$run_status_record_id,
      status_summary = second$terminal$status_summary
    )
    port <- phase5_port(repository_root)
    rrpruntime::append_run_status(port, second$started)
    rrpruntime::append_completed_run(
      port, second$terminal, second$states, second$requests,
      second$executions, second$estimates
    )
    phase0_assert_true(length(rrpruntime::read_run_history(
      port, second$terminal$runtime_run_id
    )$provider_execution_result) == 2L)
  },

  "provider transition changes future runs without rewriting prior history" = function() {
    helpers <- phase5_runtime_helpers
    port <- phase5_port(repository_root)
    first <- phase5_fixture(repository_root)
    phase5_append_fixture(port, first)
    alternate_spec <- helpers$phase42_constant_specification(
      rrp_read_reference_provider_specification(repository_root), "0.1.0"
    )
    alternate <- helpers$phase42_registry(
      repository_root, alternate_spec, helpers$phase42_constant_adapter(0.21)
    )
    second <- phase5_fixture(
      repository_root, run_id = "fictional_history_run_002",
      as_of_time = "2026-01-11T12:00:00Z", registered = alternate
    )
    phase5_append_fixture(port, second)
    old <- rrpruntime::read_history_record(
      port, "estimate", first$estimates[[1L]]$estimate_id, "valid"
    )
    phase0_assert_true(identical(
      old$provider_reference$provider_id,
      first$estimates[[1L]]$provider_reference$provider_id
    ))
    phase0_assert_true(length(rrpruntime::read_episode_estimate_history(
      port, old$episode_id, NULL, "valid"
    )) == 2L)
  },

  "invalidation retains raw facts and restatement becomes current" = function() {
    port <- phase5_port(repository_root)
    first <- phase5_fixture(repository_root)
    phase5_append_fixture(port, first)
    invalidation <- rrpruntime::new_history_invalidation(
      "operational_run", first$terminal$runtime_run_id,
      first$terminal$runtime_run_id, "2026-01-11T13:00:00Z",
      "fictional_input_correction", "Fictional fixture restatement.",
      first$contracts$invalidation,
      replacement_runtime_run_id = "fictional_history_run_restatement"
    )
    rrpruntime::append_history_invalidations(port, list(invalidation))
    phase0_assert_true(length(rrpruntime::read_episode_estimate_history(
      port, first$estimates[[1L]]$episode_id, NULL, "raw"
    )) == 1L)
    phase0_assert_true(length(rrpruntime::read_episode_estimate_history(
      port, first$estimates[[1L]]$episode_id, NULL, "valid"
    )) == 0L)
    restated <- phase5_fixture(
      repository_root, run_id = "fictional_history_run_restatement",
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
    phase5_append_fixture(port, restated)
    current <- rrpruntime::read_current_estimate(
      port, restated$estimates[[1L]]$episode_id,
      restated$estimates[[1L]]$estimand_specification$specification_id,
      "2026-01-12T12:00:00Z"
    )
    phase0_assert_true(identical(current$runtime_run_id, "fictional_history_run_restatement"))
    phase0_assert_true(length(restated$started$provenance_references) == 2L)
  },

  "started and failed runs cannot masquerade as complete" = function() {
    port <- phase5_port(repository_root)
    fixture <- phase5_fixture(repository_root)
    rrpruntime::append_run_status(port, fixture$started)
    phase0_assert_true(is.null(rrpruntime::read_current_estimate(
      port, fixture$states[[1L]]$episode_id,
      fixture$requests[[1L]]$estimand_specification$specification_id,
      "2026-01-11T12:00:00Z"
    )))
    phase0_assert_error(rrpruntime::append_completed_run(
      port, fixture$terminal, fixture$states, fixture$requests,
      fixture$executions, list()
    ), "estimate_execution_mismatch")
    phase0_assert_true(length(rrpruntime::read_run_history(
      port, fixture$started$runtime_run_id, "raw"
    )$operational_run) == 1L)
  }
)
