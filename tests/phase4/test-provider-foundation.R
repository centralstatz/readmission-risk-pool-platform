phase42_copy <- function(value) unserialize(serialize(value, NULL))

phase42_contracts <- function(repository_root) {
  list(
    runtime = rrp_read_runtime_contracts(repository_root),
    provider = rrp_read_provider_contracts(repository_root),
    reference = rrp_read_reference_provider_specification(repository_root)
  )
}

phase42_input <- function(
  baselines = list(),
  events = list(),
  optional_status = "available"
) {
  rrpruntime::new_admitted_canonical_input(
    bundle_instance_id = "fictional_provider_bundle_001",
    bundle_as_of_time = "2026-01-10T12:00:00Z",
    canonical_run_id = "fictional_provider_canonical_run",
    profile_specification = list(
      specification_kind = "canonical_profile",
      specification_id = "platform.readmission-initial-profile",
      specification_version = "0.1.0"
    ),
    capabilities = list(
      list(capability_id = "platform.discharge-episode", status = "available"),
      list(capability_id = "platform.baseline-risk-input", status = optional_status),
      list(capability_id = "platform.episode-event-history", status = optional_status)
    ),
    discharge_episodes = list(list(
      episode_id = "fictional_provider_episode_001",
      patient_id = "fictional_provider_patient_001",
      index_encounter_id = "fictional_provider_encounter_001",
      admission_time = "2026-01-01T12:00:00Z",
      discharge_time = "2026-01-03T12:00:00Z",
      followup_window_end = "2026-02-02T12:00:00Z"
    )),
    baseline_risk = baselines,
    episode_events = events,
    provenance_references = list(list(
      provenance_type = "fixture_definition",
      provenance_id = "fictional_provider_fixture",
      relationship = "constructed_for_test"
    )),
    admission_reference = list(overall_status = "pass")
  )
}

phase42_runtime <- function(repository_root, input = phase42_input()) {
  contracts <- rrp_read_runtime_contracts(repository_root)
  context <- list(
    run_id = "fictional_runtime_provider_test_001",
    as_of_time = input$bundle_as_of_time
  )
  eligibility <- rrpruntime::evaluate_episode_eligibility(input, context, contracts)
  states <- rrpruntime::build_episode_states(input, eligibility, context, contracts)
  requests <- rrpruntime::build_estimand_requests(
    states, eligibility, context, contracts
  )
  list(
    state = states$records[[1L]], request = requests$records[[1L]],
    states = states, requests = requests
  )
}

phase42_registry <- function(repository_root, specification = NULL, adapter = NULL) {
  contracts <- phase42_contracts(repository_root)
  if (is.null(specification)) specification <- contracts$reference
  if (is.null(adapter)) adapter <- rrpruntime::reference_provider_adapter
  registry <- rrpruntime::new_provider_registry()
  rrpruntime::register_provider(
    registry, specification, adapter, contracts$provider$provider_specification
  )
  list(registry = registry, specification = specification, contracts = contracts)
}

phase42_execute <- function(repository_root, runtime = NULL, registered = NULL) {
  if (is.null(runtime)) runtime <- phase42_runtime(repository_root)
  if (is.null(registered)) registered <- phase42_registry(repository_root)
  rrpruntime::execute_provider(
    registered$registry,
    registered$specification$provider_id,
    registered$specification$provider_version,
    runtime$request,
    runtime$state,
    "fictional_provider_execution_run_001",
    registered$contracts$runtime,
    registered$contracts$provider
  )
}

phase42_constant_specification <- function(reference, version = "0.1.0") {
  specification <- phase42_copy(reference)
  specification$specification_id <- "reference.test-constant-hazard"
  specification$specification_version <- version
  specification$provider_id <- specification$specification_id
  specification$provider_version <- version
  specification$title <- "Test-only constant hazard provider"
  specification$description <- "Deterministic fictional test provider."
  specification$clinical_use <- "Test-only; no clinical validity."
  specification$method <- list(constant_probability = 0.21)
  specification
}

phase42_constant_adapter <- function(probability = 0.21) {
  force(probability)
  function(request, state, provider_specification) {
    list(status = "success", outputs = list(list(
      request_id = request$request_id,
      state_id = state$state_id,
      episode_id = state$episode_id,
      estimand_specification = request$estimand_specification,
      target_interval_start = request$target_interval_start,
      target_interval_end = request$target_interval_end,
      interval_boundary = request$interval_boundary,
      output_type = "probability",
      estimate_value = probability,
      provenance_references = list(list(
        provenance_type = "test_provider",
        provenance_id = provider_specification$provider_id,
        relationship = "computed_by"
      ))
    )))
  }
}

phase42_mutating_adapter <- function(mutate) {
  force(mutate)
  function(request, state, provider_specification) {
    output <- rrpruntime::reference_provider_adapter(
      request, state, provider_specification
    )
    mutate(output)
  }
}

phase42_provider_test_cases <- function(repository_root) {
  list(
    "provider and estimate contracts have distinct supported identities" = function() {
      contracts <- phase42_contracts(repository_root)
      phase0_assert_true(rrpruntime::runtime_conforms(
        rrpruntime::validate_provider_contracts(contracts$provider)
      ))
      phase0_assert_true(rrpruntime::runtime_conforms(
        rrpruntime::validate_provider_specification(
          contracts$reference, contracts$provider$provider_specification
        )
      ))
      ids <- c(
        vapply(contracts$provider, `[[`, character(1), "specification_id"),
        contracts$reference$specification_id
      )
      phase0_assert_true(length(unique(ids)) == 5L)
    },

    "valid provider registers and lists deterministically" = function() {
      registered <- phase42_registry(repository_root)
      listed <- rrpruntime::list_registered_providers(registered$registry)
      phase0_assert_true(nrow(listed) == 1L)
      phase0_assert_true(identical(
        listed$provider_id[[1L]], registered$specification$provider_id
      ))
      phase0_assert_true(identical(
        listed$implementation_version[[1L]], "0.1.0"
      ))
    },

    "duplicate provider identity and version is rejected" = function() {
      registered <- phase42_registry(repository_root)
      phase0_assert_error(
        rrpruntime::register_provider(
          registered$registry,
          registered$specification,
          rrpruntime::reference_provider_adapter,
          registered$contracts$provider$provider_specification
        ),
        "duplicate_registered_provider"
      )
    },

    "unknown provider selection fails explicitly" = function() {
      registered <- phase42_registry(repository_root)
      phase0_assert_error(
        rrpruntime::resolve_provider(
          registered$registry, "reference.unknown-provider", "0.1.0"
        ),
        "unknown_registered_provider"
      )
    },

    "exact provider resolution is deterministic" = function() {
      registered <- phase42_registry(repository_root)
      first <- rrpruntime::resolve_provider(
        registered$registry,
        registered$specification$provider_id,
        registered$specification$provider_version
      )
      second <- rrpruntime::resolve_provider(
        registered$registry,
        registered$specification$provider_id,
        registered$specification$provider_version
      )
      phase0_assert_true(identical(
        first$specification, second$specification
      ))
    },

    "arbitrary provider paths are neither declarations nor adapters" = function() {
      contracts <- phase42_contracts(repository_root)
      invalid <- phase42_copy(contracts$reference)
      invalid$provider_path <- "some/file.R"
      conformance <- rrpruntime::validate_provider_specification(
        invalid, contracts$provider$provider_specification
      )
      phase0_assert_false(rrpruntime::runtime_conforms(conformance))
      phase0_assert_true(
        "unknown_provider_specification_field" %in% conformance$issues$issue_code
      )
      phase0_assert_error(
        rrpruntime::register_provider(
          rrpruntime::new_provider_registry(), contracts$reference,
          "some/file.R", contracts$provider$provider_specification
        ),
        "trusted callable"
      )
    },

    "reference provider is compatible with the accepted request" = function() {
      contracts <- phase42_contracts(repository_root)
      runtime <- phase42_runtime(repository_root)
      result <- rrpruntime::validate_provider_compatibility(
        contracts$reference, runtime$request, runtime$state, contracts$runtime
      )
      phase0_assert_true(rrpruntime::runtime_conforms(result))
      phase0_assert_true(identical(result$compatibility_status, "compatible"))
    },

    "unsupported estimand is distinct from missing input" = function() {
      contracts <- phase42_contracts(repository_root)
      runtime <- phase42_runtime(repository_root)
      request <- phase42_copy(runtime$request)
      request$estimand_specification$specification_version <- "0.2.0"
      result <- rrpruntime::validate_provider_compatibility(
        contracts$reference, request, runtime$state, contracts$runtime
      )
      phase0_assert_true(identical(result$compatibility_status, "unsupported"))
      phase0_assert_true("unsupported_estimand" %in% result$issues$issue_code)
    },

    "unsupported state version fails before provider invocation" = function() {
      contracts <- phase42_contracts(repository_root)
      runtime <- phase42_runtime(repository_root)
      state <- phase42_copy(runtime$state)
      state$state_specification$specification_version <- "0.2.0"
      result <- rrpruntime::validate_provider_compatibility(
        contracts$reference, runtime$request, state, contracts$runtime
      )
      phase0_assert_true(identical(result$compatibility_status, "unsupported"))
      phase0_assert_true("unsupported_state_version" %in% result$issues$issue_code)
    },

    "non-active provider lifecycle is not selectable" = function() {
      contracts <- phase42_contracts(repository_root)
      provider <- phase42_copy(contracts$reference)
      provider$status <- "deprecated"
      runtime <- phase42_runtime(repository_root)
      result <- rrpruntime::validate_provider_compatibility(
        provider, runtime$request, runtime$state, contracts$runtime
      )
      phase0_assert_true(identical(result$compatibility_status, "unsupported"))
      phase0_assert_true("provider_not_selectable" %in% result$issues$issue_code)
    },

    "missing required capability is a provider input failure" = function() {
      contracts <- phase42_contracts(repository_root)
      runtime <- phase42_runtime(repository_root)
      request <- phase42_copy(runtime$request)
      request$capability_statuses[[1L]]$status <- "unsupported"
      result <- rrpruntime::validate_provider_compatibility(
        contracts$reference, request, runtime$state, contracts$runtime
      )
      phase0_assert_true(identical(
        result$compatibility_status, "missing_required_input"
      ))
      phase0_assert_true("missing_required_capability" %in% result$issues$issue_code)
    },

    "provider-specific required baseline can be missing" = function() {
      contracts <- phase42_contracts(repository_root)
      required <- phase42_copy(contracts$reference)
      required$input_requirements$available_baseline_risk <- "required"
      runtime <- phase42_runtime(repository_root)
      result <- rrpruntime::validate_provider_compatibility(
        required, runtime$request, runtime$state, contracts$runtime
      )
      phase0_assert_true(identical(
        result$compatibility_status, "missing_required_input"
      ))
      phase0_assert_true(
        "missing_required_provider_input" %in% result$issues$issue_code
      )
    },

    "provider-required state fields are enforced" = function() {
      contracts <- phase42_contracts(repository_root)
      runtime <- phase42_runtime(repository_root)
      state <- phase42_copy(runtime$state)
      state$days_since_discharge <- NULL
      result <- rrpruntime::validate_provider_compatibility(
        contracts$reference, runtime$request, state, contracts$runtime
      )
      phase0_assert_true(identical(
        result$compatibility_status, "missing_required_input"
      ))
      phase0_assert_true("missing_required_state_field" %in% result$issues$issue_code)
    },

    "provider target interval limit is enforced" = function() {
      contracts <- phase42_contracts(repository_root)
      runtime <- phase42_runtime(repository_root)
      request <- phase42_copy(runtime$request)
      request$target_interval_end <- "2026-01-12T12:00:00Z"
      result <- rrpruntime::validate_provider_compatibility(
        contracts$reference, request, runtime$state, contracts$runtime
      )
      phase0_assert_true(identical(result$compatibility_status, "unsupported"))
      phase0_assert_true("unsupported_target_interval" %in% result$issues$issue_code)
    },

    "provider discharge-relative follow-up limit is enforced" = function() {
      contracts <- phase42_contracts(repository_root)
      limited <- phase42_copy(contracts$reference)
      limited$supported_estimands[[1L]]$maximum_followup_days <- 7
      runtime <- phase42_runtime(repository_root)
      result <- rrpruntime::validate_provider_compatibility(
        limited, runtime$request, runtime$state, contracts$runtime
      )
      phase0_assert_true(identical(result$compatibility_status, "unsupported"))
      phase0_assert_true(
        "unsupported_followup_horizon" %in% result$issues$issue_code
      )
    },

    "reference provider produces one conforming estimate" = function() {
      result <- phase42_execute(repository_root)
      phase0_assert_true(identical(result$execution_status, "successful_estimate"))
      phase0_assert_true(is.null(result$failure_code))
      estimate <- result$estimate_record
      phase0_assert_true(is.numeric(estimate$estimate_value))
      phase0_assert_true(estimate$estimate_value >= 0 && estimate$estimate_value <= 1)
      phase0_assert_true(identical(
        estimate$estimate_specification$specification_id,
        "platform.readmission-risk-estimate"
      ))
      phase0_assert_true(is.null(estimate$model_reference))
    },

    "reference provider and estimate identity are deterministic" = function() {
      first <- phase42_execute(repository_root)
      second <- phase42_execute(repository_root)
      phase0_assert_true(identical(first, second))
      phase0_assert_true(identical(
        first$estimate_record$estimate_id, second$estimate_record$estimate_id
      ))
    },

    "second test provider registers without generic runtime edits" = function() {
      contracts <- phase42_contracts(repository_root)
      runtime <- phase42_runtime(repository_root)
      registry <- rrpruntime::new_provider_registry()
      rrpruntime::register_provider(
        registry, contracts$reference, rrpruntime::reference_provider_adapter,
        contracts$provider$provider_specification
      )
      constant <- phase42_constant_specification(contracts$reference)
      rrpruntime::register_provider(
        registry, constant, phase42_constant_adapter(),
        contracts$provider$provider_specification
      )
      result <- rrpruntime::execute_provider(
        registry, constant$provider_id, constant$provider_version,
        runtime$request, runtime$state, "fictional_constant_execution",
        contracts$runtime, contracts$provider
      )
      phase0_assert_true(identical(result$execution_status, "successful_estimate"))
      phase0_assert_true(identical(result$estimate_record$estimate_value, 0.21))
      phase0_assert_true(nrow(rrpruntime::list_registered_providers(registry)) == 2L)
    },

    "provider execution error is a structured non-estimate result" = function() {
      contracts <- phase42_contracts(repository_root)
      failing <- phase42_constant_specification(contracts$reference)
      failing$specification_id <- "reference.test-failing-provider"
      failing$provider_id <- failing$specification_id
      registered <- phase42_registry(
        repository_root, failing,
        function(request, state, provider_specification) stop("fictional failure")
      )
      result <- phase42_execute(repository_root, registered = registered)
      phase0_assert_true(identical(result$execution_status, "execution_failure"))
      phase0_assert_true(identical(result$failure_code, "provider_execution_error"))
      phase0_assert_true(is.null(result$estimate_record))
    },

    "provider receives an isolated state copy" = function() {
      contracts <- phase42_contracts(repository_root)
      runtime <- phase42_runtime(repository_root)
      before <- phase42_copy(runtime$state)
      mutator <- function(request, state, provider_specification) {
        state$days_since_discharge <- 999
        phase42_constant_adapter(0.18)(request, state, provider_specification)
      }
      specification <- phase42_constant_specification(contracts$reference)
      registered <- phase42_registry(repository_root, specification, mutator)
      result <- phase42_execute(repository_root, runtime, registered)
      phase0_assert_true(identical(result$execution_status, "successful_estimate"))
      phase0_assert_true(identical(runtime$state, before))
    },

    "mismatched provider output identity is rejected" = function() {
      adapter <- phase42_mutating_adapter(function(output) {
        output$outputs[[1L]]$request_id <- "fictional_wrong_request"
        output
      })
      registered <- phase42_registry(repository_root, adapter = adapter)
      result <- phase42_execute(repository_root, registered = registered)
      phase0_assert_true(identical(result$execution_status, "invalid_output"))
      phase0_assert_true(identical(
        result$failure_code, "provider_output_identity_mismatch"
      ))
      phase0_assert_true(is.null(result$estimate_record))
    },

    "missing and extra provider outputs violate cardinality" = function() {
      for (count in c(0L, 2L)) {
        adapter <- phase42_mutating_adapter(function(output) {
          if (count == 0L) output$outputs <- list()
          if (count == 2L) output$outputs <- c(output$outputs, output$outputs)
          output
        })
        result <- phase42_execute(
          repository_root, registered = phase42_registry(repository_root, adapter = adapter)
        )
        phase0_assert_true(identical(result$execution_status, "invalid_output"))
        phase0_assert_true(identical(
          result$failure_code, "invalid_provider_output_cardinality"
        ))
      }
    },

    "out-of-range and non-finite provider values are rejected" = function() {
      for (value in c(-0.01, 1.01, Inf, NaN)) {
        adapter <- phase42_mutating_adapter(function(output) {
          output$outputs[[1L]]$estimate_value <- value
          output
        })
        result <- phase42_execute(
          repository_root, registered = phase42_registry(repository_root, adapter = adapter)
        )
        phase0_assert_true(identical(result$execution_status, "invalid_output"))
        phase0_assert_true(identical(result$failure_code, "invalid_provider_probability"))
      }
    },

    "mismatched provider interval is rejected" = function() {
      adapter <- phase42_mutating_adapter(function(output) {
        output$outputs[[1L]]$target_interval_end <- "2026-01-11T18:00:00Z"
        output
      })
      result <- phase42_execute(
        repository_root, registered = phase42_registry(repository_root, adapter = adapter)
      )
      phase0_assert_true(identical(result$execution_status, "invalid_output"))
      phase0_assert_true(identical(
        result$failure_code, "provider_output_interval_mismatch"
      ))
    },

    "accepted estimate conformance rejects semantic tampering" = function() {
      registered <- phase42_registry(repository_root)
      runtime <- phase42_runtime(repository_root)
      result <- phase42_execute(repository_root, runtime, registered)
      estimate <- phase42_copy(result$estimate_record)
      estimate$target_interval_end <- "2026-01-11T18:00:00Z"
      conformance <- rrpruntime::validate_estimate_record(
        estimate, runtime$request, runtime$state, registered$specification,
        registered$contracts$provider$estimate
      )
      phase0_assert_false(rrpruntime::runtime_conforms(conformance))
      phase0_assert_true("estimate_interval_mismatch" %in% conformance$issues$issue_code)
      phase0_assert_true(
        "nondeterministic_estimate_identity" %in% conformance$issues$issue_code
      )
    },

    "reference provider supports no baseline and no events" = function() {
      result <- phase42_execute(repository_root)
      phase0_assert_true(identical(result$execution_status, "successful_estimate"))
      phase0_assert_true(abs(result$estimate_record$estimate_value - 0.04) < 1e-12)
    },

    "documented baseline probability changes only the method contribution" = function() {
      baseline <- list(list(
        episode_id = "fictional_provider_episode_001",
        source_model_id = "fictional.source-score",
        source_model_version = "1.0.0",
        score_time = "2026-01-03T12:00:00Z",
        available_at = "2026-01-04T12:00:00Z",
        value_type = "probability",
        probability = 0.8
      ))
      base <- phase42_execute(repository_root)$estimate_record$estimate_value
      with_baseline <- phase42_execute(
        repository_root,
        runtime = phase42_runtime(repository_root, phase42_input(baselines = baseline))
      )$estimate_record$estimate_value
      phase0_assert_true(with_baseline > base)
    },

    "documented available event terms change the reference estimate" = function() {
      events <- list(list(
        event_id = "fictional_provider_event_001",
        episode_id = "fictional_provider_episode_001",
        event_type = "followup_visit",
        event_time = "2026-01-09T12:00:00Z",
        available_at = "2026-01-09T13:00:00Z"
      ))
      base <- phase42_execute(repository_root)$estimate_record$estimate_value
      with_event <- phase42_execute(
        repository_root,
        runtime = phase42_runtime(repository_root, phase42_input(events = events))
      )$estimate_record$estimate_value
      phase0_assert_true(with_event > base)
    },

    "combined optional inputs follow the exact transparent method" = function() {
      baseline <- list(list(
        episode_id = "fictional_provider_episode_001",
        source_model_id = "fictional.source-score",
        source_model_version = "1.0.0",
        score_time = "2026-01-03T12:00:00Z",
        available_at = "2026-01-04T12:00:00Z",
        value_type = "probability",
        probability = 0.8
      ))
      events <- list(list(
        event_id = "fictional_provider_event_001",
        episode_id = "fictional_provider_episode_001",
        event_type = "followup_visit",
        event_time = "2026-01-09T12:00:00Z",
        available_at = "2026-01-09T13:00:00Z"
      ))
      runtime <- phase42_runtime(
        repository_root,
        phase42_input(baselines = baseline, events = events)
      )
      actual <- phase42_execute(
        repository_root, runtime = runtime
      )$estimate_record$estimate_value
      expected <- stats::plogis(stats::qlogis(0.04) + 0.75 * 0.8 + 0.12 + 0.10)
      phase0_assert_true(abs(actual - expected) < 1e-12)
    },

    "independent canonical fixture reaches provider execution" = function() {
      bundle <- yaml::read_yaml(file.path(
        repository_root, "contracts", "canonical", "examples",
        "readmission-initial-profile-valid.yml"
      ))$bundle_instance
      runtime <- rrp_run_runtime_from_bundle(
        bundle, repository_root, "fictional_independent_provider_runtime"
      )
      result <- rrp_execute_reference_estimation(
        runtime, repository_root, "fictional_independent_provider_execution"
      )
      summary <- rrp_estimation_result_summary(result)
      phase0_assert_true(summary$eligible_episodes == 1L)
      phase0_assert_true(summary$successful_estimates == 1L)
    },

    "provider runtime remains independent of sources and later layers" = function() {
      files <- list.files(
        file.path(repository_root, "runtime", "R"), pattern = "[.]R$",
        full.names = TRUE
      )
      text <- unlist(lapply(files, readLines, warn = FALSE))
      forbidden <- c(
        "reference.synthetic", "activity_events", "source-schema",
        "read_yaml", "getwd(", "../contracts", "canonical-pipeline",
        "priority_rank", "recommended_action", "storage_backend"
      )
      phase0_assert_true(!any(vapply(forbidden, function(value) {
        any(grepl(value, text, fixed = TRUE))
      }, logical(1))))
    }
  )
}

phase4_test_cases <- phase42_provider_test_cases
