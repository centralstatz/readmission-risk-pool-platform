phase4_copy <- function(value) unserialize(serialize(value, NULL))

phase4_independent_bundle <- function(repository_root) {
  yaml::read_yaml(file.path(
    repository_root, "contracts", "canonical", "examples",
    "readmission-initial-profile-valid.yml"
  ))$bundle_instance
}

phase4_contracts <- function(repository_root) {
  rrp_read_runtime_contracts(repository_root)
}

phase4_input <- function(
  as_of = "2026-01-10T12:00:00Z",
  episodes = NULL,
  baselines = list(),
  events = list(),
  optional_status = "available"
) {
  if (is.null(episodes)) {
    episodes <- list(list(
      episode_id = "fictional_episode_001",
      patient_id = "fictional_patient_001",
      index_encounter_id = "fictional_encounter_001",
      admission_time = "2026-01-01T12:00:00Z",
      discharge_time = "2026-01-03T12:00:00Z",
      followup_window_end = "2026-02-02T12:00:00Z"
    ))
  }
  rrpruntime::new_admitted_canonical_input(
    bundle_instance_id = paste0("fictional_bundle_", gsub("[^0-9]", "", as_of)),
    bundle_as_of_time = as_of,
    canonical_run_id = "fictional_canonical_run",
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
    discharge_episodes = episodes,
    baseline_risk = baselines,
    episode_events = events,
    provenance_references = list(list(
      provenance_type = "fixture_definition",
      provenance_id = "fictional_runtime_input",
      relationship = "constructed_for_test"
    )),
    admission_reference = list(overall_status = "pass")
  )
}

phase4_context <- function(input, run_id = "runtime_test_001") {
  list(run_id = run_id, as_of_time = input$bundle_as_of_time)
}

phase4_run <- function(input, contracts) {
  context <- phase4_context(input)
  eligibility <- rrpruntime::evaluate_episode_eligibility(input, context, contracts)
  states <- rrpruntime::build_episode_states(input, eligibility, context, contracts)
  requests <- rrpruntime::build_estimand_requests(
    states, eligibility, context, contracts
  )
  list(context = context, eligibility = eligibility, states = states, requests = requests)
}

phase4_test_cases <- function(repository_root) {
  list(
    "runtime package installs and loads with no external package imports" = function() {
      phase0_assert_true("rrpruntime" %in% loadedNamespaces())
      description <- read.dcf(file.path(repository_root, "runtime", "DESCRIPTION"))
      phase0_assert_true(identical(description[[1L, "Package"]], "rrpruntime"))
      phase0_assert_false("Imports" %in% colnames(description))
    },

    "runtime contracts use supported distinct identities" = function() {
      contracts <- phase4_contracts(repository_root)
      phase0_assert_true(rrpruntime::runtime_conforms(
        rrpruntime::validate_runtime_contracts(contracts)
      ))
      ids <- vapply(contracts, `[[`, character(1), "specification_id")
      phase0_assert_true(length(unique(ids)) == 4L)
    },

    "unsupported estimand version fails closed" = function() {
      contracts <- phase4_contracts(repository_root)
      contracts$estimand$specification_version <- "0.2.0"
      result <- rrpruntime::validate_runtime_contracts(contracts)
      phase0_assert_false(rrpruntime::runtime_conforms(result))
      phase0_assert_true("unsupported_runtime_contract" %in% result$issues$issue_code)
    },

    "independent Phase 2 fixture is admitted and accepted by runtime" = function() {
      bundle <- phase4_independent_bundle(repository_root)
      admission <- rrp_validate_clinical_bundle_instance(bundle, repository_root)
      phase0_assert_true(rrp_conforms(admission))
      input <- rrp_runtime_input_from_admitted_bundle(bundle, admission)
      phase0_assert_true(rrpruntime::runtime_conforms(
        rrpruntime::validate_runtime_input(input)
      ))
      result <- rrp_run_runtime_from_bundle(
        bundle, repository_root, "runtime_independent_test"
      )
      phase0_assert_true(length(result$eligibility$records) == 2L)
      phase0_assert_true(length(result$states$records) == 1L)
      phase0_assert_true(length(result$estimand_requests$records) == 1L)
      reasons <- vapply(
        result$eligibility$records, `[[`, character(1), "eligibility_reason"
      )
      phase0_assert_true(setequal(reasons, c("already_readmitted", "eligible")))
    },

    "synthetic Phase 3 bundle uses the same runtime APIs" = function() {
      produced <- rrp_run_synthetic_reference(repository_root, "test")
      phase0_assert_true(identical(produced$overall_status, "succeeded"))
      result <- rrp_run_runtime_from_bundle(
        produced$candidate_bundle, repository_root, "runtime_synthetic_test"
      )
      phase0_assert_true(length(result$eligibility$records) == 6L)
      phase0_assert_true(length(result$states$records) == 6L)
      phase0_assert_true(length(result$estimand_requests$records) == 6L)
    },

    "runtime rejects input without canonical admission" = function() {
      input <- phase4_input()
      input$admission_reference$overall_status <- "fail"
      result <- rrpruntime::validate_runtime_input(input)
      phase0_assert_false(rrpruntime::runtime_conforms(result))
      phase0_assert_true("canonical_input_not_admitted" %in% result$issues$issue_code)
    },

    "runtime as-of must equal admitted bundle cutoff" = function() {
      input <- phase4_input()
      context <- list(run_id = "runtime_test", as_of_time = "2026-01-09T12:00:00Z")
      phase0_assert_error(
        rrpruntime::evaluate_episode_eligibility(
          input, context, phase4_contracts(repository_root)
        ),
        "runtime_bundle_as_of_mismatch"
      )
    },

    "eligibility includes exact discharge and excludes exact follow-up end" = function() {
      episode <- phase4_input()$discharge_episodes[[1L]]
      at_discharge <- phase4_input(as_of = episode$discharge_time, episodes = list(episode))
      at_end <- phase4_input(as_of = episode$followup_window_end, episodes = list(episode))
      contracts <- phase4_contracts(repository_root)
      first <- phase4_run(at_discharge, contracts)$eligibility$records[[1L]]
      second <- phase4_run(at_end, contracts)$eligibility$records[[1L]]
      phase0_assert_true(identical(first$eligibility_reason, "eligible"))
      phase0_assert_true(identical(second$eligibility_reason, "followup_complete"))
    },

    "eligibility reports before-discharge explicitly" = function() {
      input <- phase4_input(as_of = "2026-01-02T12:00:00Z")
      result <- phase4_run(input, phase4_contracts(repository_root))
      phase0_assert_true(identical(
        result$eligibility$records[[1L]]$eligibility_reason,
        "before_discharge"
      ))
      phase0_assert_true(length(result$requests$records) == 0L)
    },

    "readmission at or before interval start is ineligible" = function() {
      for (time in c("2026-01-09T12:00:00Z", "2026-01-10T12:00:00Z")) {
        episode <- phase4_input()$discharge_episodes[[1L]]
        episode$readmission_time <- time
        result <- phase4_run(
          phase4_input(episodes = list(episode)), phase4_contracts(repository_root)
        )
        phase0_assert_true(identical(
          result$eligibility$records[[1L]]$eligibility_reason,
          "already_readmitted"
        ))
      }
    },

    "death at interval start is ineligible" = function() {
      episode <- phase4_input()$discharge_episodes[[1L]]
      episode$death_time <- "2026-01-10T12:00:00Z"
      result <- phase4_run(
        phase4_input(episodes = list(episode)), phase4_contracts(repository_root)
      )
      phase0_assert_true(identical(
        result$eligibility$records[[1L]]$eligibility_reason, "died"
      ))
      phase0_assert_true(length(result$states$records) == 0L)
    },

    "future terminal occurrence does not affect current eligibility" = function() {
      episode <- phase4_input()$discharge_episodes[[1L]]
      episode$readmission_time <- "2026-01-11T12:00:00Z"
      result <- phase4_run(
        phase4_input(episodes = list(episode)), phase4_contracts(repository_root)
      )
      phase0_assert_true(identical(
        result$eligibility$records[[1L]]$eligibility_reason, "eligible"
      ))
    },

    "optional baseline and events are not estimand eligibility requirements" = function() {
      input <- phase4_input(optional_status = "unsupported")
      result <- phase4_run(input, phase4_contracts(repository_root))
      phase0_assert_true(length(result$states$records) == 1L)
      phase0_assert_true(length(result$requests$records) == 1L)
      phase0_assert_true(length(
        result$states$records[[1L]]$available_baseline_risk
      ) == 0L)
      phase0_assert_true(length(
        result$states$records[[1L]]$available_episode_events
      ) == 0L)
    },

    "state identity is deterministic and explicitly versioned" = function() {
      input <- phase4_input()
      contracts <- phase4_contracts(repository_root)
      first <- phase4_run(input, contracts)$states$records[[1L]]
      second <- phase4_run(input, contracts)$states$records[[1L]]
      phase0_assert_true(identical(first$state_id, second$state_id))
      phase0_assert_true(identical(
        first$state_specification$specification_id,
        "platform.readmission-episode-state"
      ))
      phase0_assert_true(identical(first$state_specification$specification_version, "0.1.0"))
    },

    "state retains all available baselines without latest-row selection" = function() {
      baselines <- list(
        list(
          episode_id = "fictional_episode_001", source_model_id = "fictional.model-b",
          source_model_version = "1.0.0", score_time = "2026-01-03T11:00:00Z",
          available_at = "2026-01-03T13:00:00Z", value_type = "numeric_score",
          numeric_score = 8, source_reference_id = "fictional_baseline_b"
        ),
        list(
          episode_id = "fictional_episode_001", source_model_id = "fictional.model-a",
          source_model_version = "2.0.0", score_time = "2026-01-03T10:00:00Z",
          available_at = "2026-01-03T14:00:00Z", value_type = "probability",
          probability = 0.3, source_reference_id = "fictional_baseline_a"
        )
      )
      state <- phase4_run(
        phase4_input(baselines = baselines), phase4_contracts(repository_root)
      )$states$records[[1L]]
      phase0_assert_true(length(state$available_baseline_risk) == 2L)
      phase0_assert_true(identical(
        vapply(state$available_baseline_risk, `[[`, character(1), "source_model_id"),
        c("fictional.model-a", "fictional.model-b")
      ))
    },

    "state excludes unavailable baseline and future events" = function() {
      baselines <- list(
        list(
          episode_id = "fictional_episode_001", source_model_id = "fictional.model",
          source_model_version = "1.0.0", score_time = "2026-01-03T10:00:00Z",
          available_at = "2026-01-11T12:00:00Z", value_type = "probability",
          probability = 0.4
        ),
        list(
          episode_id = "fictional_episode_001", source_model_id = "fictional.future",
          source_model_version = "1.0.0", score_time = "2026-01-11T10:00:00Z",
          available_at = "2026-01-09T12:00:00Z", value_type = "probability",
          probability = 0.5
        )
      )
      events <- list(
        list(
          event_id = "fictional_event_future_available",
          episode_id = "fictional_episode_001", event_type = "followup_visit",
          event_time = "2026-01-09T12:00:00Z",
          available_at = "2026-01-11T12:00:00Z"
        ),
        list(
          event_id = "fictional_event_future_occurrence",
          episode_id = "fictional_episode_001", event_type = "followup_visit",
          event_time = "2026-01-11T12:00:00Z",
          available_at = "2026-01-09T12:00:00Z"
        )
      )
      state <- phase4_run(
        phase4_input(baselines = baselines, events = events),
        phase4_contracts(repository_root)
      )$states$records[[1L]]
      phase0_assert_true(length(state$available_baseline_risk) == 0L)
      phase0_assert_true(length(state$available_episode_events) == 0L)
    },

    "available events are ordered by occurrence availability and ID" = function() {
      event <- function(id, time, available) list(
        event_id = id, episode_id = "fictional_episode_001",
        event_type = "followup_visit", event_time = time, available_at = available
      )
      events <- list(
        event("fictional_event_c", "2026-01-08T12:00:00Z", "2026-01-08T13:00:00Z"),
        event("fictional_event_b", "2026-01-07T09:00:00Z", "2026-01-07T11:00:00Z"),
        event("fictional_event_a", "2026-01-07T09:00:00Z", "2026-01-07T10:00:00Z"),
        event(
          "fictional_event_offset", "2026-01-07T10:00:00+02:00",
          "2026-01-07T10:30:00+02:00"
        )
      )
      state <- phase4_run(
        phase4_input(events = events), phase4_contracts(repository_root)
      )$states$records[[1L]]
      phase0_assert_true(identical(
        vapply(state$available_episode_events, `[[`, character(1), "event_id"),
        c(
          "fictional_event_offset", "fictional_event_a",
          "fictional_event_b", "fictional_event_c"
        )
      ))
    },

    "state provenance retains canonical and eligibility references" = function() {
      state <- phase4_run(
        phase4_input(), phase4_contracts(repository_root)
      )$states$records[[1L]]
      types <- vapply(state$input_references, `[[`, character(1), "reference_type")
      phase0_assert_true(identical(
        types, c("canonical_bundle", "canonical_run", "eligibility_result")
      ))
    },

    "state changes only with separately admitted as-of information" = function() {
      event <- list(
        event_id = "fictional_event_later", episode_id = "fictional_episode_001",
        event_type = "followup_visit", event_time = "2026-01-09T12:00:00Z",
        available_at = "2026-01-09T13:00:00Z"
      )
      early <- phase4_input(as_of = "2026-01-08T12:00:00Z", events = list(event))
      later <- phase4_input(as_of = "2026-01-10T12:00:00Z", events = list(event))
      contracts <- phase4_contracts(repository_root)
      early_state <- phase4_run(early, contracts)$states$records[[1L]]
      later_state <- phase4_run(later, contracts)$states$records[[1L]]
      phase0_assert_true(length(early_state$available_episode_events) == 0L)
      phase0_assert_true(length(later_state$available_episode_events) == 1L)
      phase0_assert_true(later_state$days_since_discharge > early_state$days_since_discharge)
    },

    "eligible state produces exactly one correctly linked request" = function() {
      result <- phase4_run(phase4_input(), phase4_contracts(repository_root))
      phase0_assert_true(length(result$requests$records) == 1L)
      request <- result$requests$records[[1L]]
      phase0_assert_true(identical(
        request$state_reference$state_id, result$states$records[[1L]]$state_id
      ))
      phase0_assert_true(identical(
        request$estimand_specification$specification_id,
        "platform.readmission-next-day-conditional-hazard"
      ))
      phase0_assert_true(identical(request$interval_boundary, "(start, end]"))
    },

    "final request interval is clipped to effective follow-up end" = function() {
      episode <- phase4_input()$discharge_episodes[[1L]]
      episode$followup_window_end <- "2026-01-10T18:00:00Z"
      input <- phase4_input(episodes = list(episode))
      request <- phase4_run(
        input, phase4_contracts(repository_root)
      )$requests$records[[1L]]
      phase0_assert_true(identical(
        request$target_interval_end, "2026-01-10T18:00:00Z"
      ))
    },

    "estimand request contains no provider or model identity" = function() {
      request <- phase4_run(
        phase4_input(), phase4_contracts(repository_root)
      )$requests$records[[1L]]
      phase0_assert_true(!any(c(
        "provider_id", "provider_version", "model_id", "model_version",
        "risk_probability"
      ) %in% names(request)))
    },

    "estimand explicitly bounds probability without hazard monotonicity" = function() {
      estimand <- phase4_contracts(repository_root)$estimand
      phase0_assert_true(identical(
        estimand$event$event_type, "first_canonical_readmission"
      ))
      phase0_assert_true(identical(
        estimand$event$plannedness,
        "not_distinguished_by_initial_canonical_profile"
      ))
      phase0_assert_true(identical(as.numeric(estimand$output$minimum), 0))
      phase0_assert_true(identical(as.numeric(estimand$output$maximum), 1))
      phase0_assert_true(identical(
        estimand$coherence$monotonic_across_intervals_required, FALSE
      ))
      phase0_assert_true(grepl("P(T_readmission", estimand$mathematical_definition, fixed = TRUE))
    },

    "runtime package has no synthetic source or repository-path dependency" = function() {
      files <- list.files(
        file.path(repository_root, "runtime"), recursive = TRUE,
        full.names = TRUE
      )
      text <- unlist(lapply(files[grepl("[.](R|md|DESCRIPTION|NAMESPACE)$", files)],
                           readLines, warn = FALSE))
      forbidden <- c(
        "synthetic", "reference.synthetic", "activity_events", "source-schema",
        "getwd(", "../contracts", "canonical-pipeline", "provider"
      )
      # Responsibility prose may say provider, so executable R carries the strict check.
      r_files <- files[grepl("[.]R$", files)]
      r_text <- unlist(lapply(r_files, readLines, warn = FALSE))
      phase0_assert_true(!any(vapply(forbidden[-length(forbidden)], function(value) {
        any(grepl(value, r_text, fixed = TRUE))
      }, logical(1))))
      phase0_assert_true(!any(grepl("provider_id", r_text, fixed = TRUE)))
    }
  )
}
