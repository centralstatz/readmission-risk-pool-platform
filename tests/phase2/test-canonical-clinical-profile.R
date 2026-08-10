phase2_clinical_fixture <- function(repository_root) {
  yaml::read_yaml(file.path(
    repository_root,
    "contracts",
    "canonical",
    "examples",
    "readmission-initial-profile-valid.yml"
  ))
}

phase2_clinical_bundle <- function(repository_root) {
  phase2_clinical_fixture(repository_root)$bundle_instance
}

phase2_clinical_domain_index <- function(bundle, domain_id) {
  match(domain_id, vapply(bundle$domains, `[[`, character(1), "domain_id"))
}

phase2_clinical_capability_index <- function(bundle, capability_id) {
  match(capability_id, vapply(bundle$capabilities, `[[`, character(1), "capability_id"))
}

phase2_clinical_payload_index <- function(bundle, domain_id) {
  domain <- bundle$domains[[phase2_clinical_domain_index(bundle, domain_id)]]
  match(
    domain$domain_instance_id,
    vapply(
      bundle$reference_test_realization$domain_payloads,
      `[[`, character(1), "domain_instance_id"
    )
  )
}

phase2_clinical_records <- function(bundle, domain_id) {
  bundle$reference_test_realization$domain_payloads[[
    phase2_clinical_payload_index(bundle, domain_id)
  ]]$records
}

phase2_set_clinical_records <- function(bundle, domain_id, records) {
  payload_index <- phase2_clinical_payload_index(bundle, domain_id)
  bundle$reference_test_realization$domain_payloads[[payload_index]]$records <- records
  bundle
}

phase2_clinical_result <- function(bundle, repository_root) {
  rrp_validate_clinical_bundle_instance(bundle, repository_root, "memory:clinical")
}

phase2_clinical_codes <- function(result) unique(result$issues$issue_code)

phase2_test_cases <- function(repository_root) {
  list(
    "independent initial clinical profile fixture conforms" = function() {
      fixture <- phase2_clinical_fixture(repository_root)
      result <- phase2_clinical_result(fixture$bundle_instance, repository_root)
      phase0_assert_true(rrp_conforms(result))
      phase0_assert_true(identical(fixture$data_classification, "fictional_nonclinical"))
      phase0_assert_true(length(phase2_clinical_records(
        fixture$bundle_instance, "discharge_episode"
      )) == 2L)
    },

    "maintained clinical specification semantics fail closed on drift" = function() {
      baseline <- yaml::read_yaml(file.path(
        repository_root, "contracts", "canonical", "domains", "baseline-risk.yml"
      ))
      baseline$fields$probability$maximum <- 2
      baseline_result <- rrp_validate_clinical_domain_specification(
        baseline, "memory:baseline-specification"
      )
      phase0_assert_true(
        "invalid_baseline_value_contract" %in% phase2_clinical_codes(baseline_result)
      )

      profile <- yaml::read_yaml(file.path(
        repository_root, "contracts", "canonical", "profiles",
        "readmission-initial-profile.yml"
      ))
      profile$capabilities[[1L]]$requirement_class <- "optional"
      profile_result <- rrp_validate_clinical_profile_specification(
        profile, "memory:clinical-profile"
      )
      phase0_assert_true(
        "invalid_profile_capability_semantics" %in% phase2_clinical_codes(profile_result)
      )
    },

    "duplicate episode identity fails" = function() {
      bundle <- phase2_clinical_bundle(repository_root)
      episodes <- phase2_clinical_records(bundle, "discharge_episode")
      episodes[[2L]]$episode_id <- episodes[[1L]]$episode_id
      bundle <- phase2_set_clinical_records(bundle, "discharge_episode", episodes)
      result <- phase2_clinical_result(bundle, repository_root)
      phase0_assert_false(rrp_conforms(result))
      phase0_assert_true("duplicate_primary_key" %in% phase2_clinical_codes(result))
    },

    "episode admission and follow-up ordering fail independently" = function() {
      bundle <- phase2_clinical_bundle(repository_root)
      episodes <- phase2_clinical_records(bundle, "discharge_episode")
      episodes[[1L]]$admission_time <- "2026-01-03T13:00:00Z"
      episodes[[2L]]$followup_window_end <- episodes[[2L]]$discharge_time
      bundle <- phase2_set_clinical_records(bundle, "discharge_episode", episodes)
      result <- phase2_clinical_result(bundle, repository_root)
      codes <- phase2_clinical_codes(result)
      phase0_assert_true("admission_not_before_discharge" %in% codes)
      phase0_assert_true("followup_not_after_discharge" %in% codes)
    },

    "episode terminal window and ordering rules fail" = function() {
      bundle <- phase2_clinical_bundle(repository_root)
      episodes <- phase2_clinical_records(bundle, "discharge_episode")
      episodes[[1L]]$death_time <- "2026-01-10T12:00:00Z"
      episodes[[2L]]$death_time <- "2026-03-06T11:00:00Z"
      bundle <- phase2_set_clinical_records(bundle, "discharge_episode", episodes)
      result <- phase2_clinical_result(bundle, repository_root)
      codes <- phase2_clinical_codes(result)
      phase0_assert_true("readmission_after_death" %in% codes)
      phase0_assert_true("terminal_outside_observation_window" %in% codes)
    },

    "baseline foreign key and source model identity fail" = function() {
      bundle <- phase2_clinical_bundle(repository_root)
      baselines <- phase2_clinical_records(bundle, "baseline_risk")
      baselines[[1L]]$episode_id <- "fictional_missing_episode"
      baselines[[1L]]$source_model_id <- "Not A Logical ID"
      baselines[[1L]]$source_model_version <- "draft"
      bundle <- phase2_set_clinical_records(bundle, "baseline_risk", baselines)
      result <- phase2_clinical_result(bundle, repository_root)
      codes <- phase2_clinical_codes(result)
      phase0_assert_true("unresolved_baseline_episode_id" %in% codes)
      phase0_assert_true("invalid_source_model_identity" %in% codes)
    },

    "baseline requires exactly one matching value representation" = function() {
      bundle <- phase2_clinical_bundle(repository_root)
      baselines <- phase2_clinical_records(bundle, "baseline_risk")
      baselines[[1L]]$probability <- NULL
      bundle <- phase2_set_clinical_records(bundle, "baseline_risk", baselines)
      result <- phase2_clinical_result(bundle, repository_root)
      phase0_assert_true(
        "missing_or_conflicting_baseline_value" %in% phase2_clinical_codes(result)
      )

      bundle <- phase2_clinical_bundle(repository_root)
      baselines <- phase2_clinical_records(bundle, "baseline_risk")
      baselines[[1L]]$numeric_score <- 14.2
      bundle <- phase2_set_clinical_records(bundle, "baseline_risk", baselines)
      result <- phase2_clinical_result(bundle, repository_root)
      phase0_assert_true(
        "missing_or_conflicting_baseline_value" %in% phase2_clinical_codes(result)
      )
    },

    "baseline probability bounds and score timing fail" = function() {
      bundle <- phase2_clinical_bundle(repository_root)
      baselines <- phase2_clinical_records(bundle, "baseline_risk")
      baselines[[1L]]$probability <- 1.2
      baselines[[1L]]$score_time <- "2026-01-04T10:00:00Z"
      bundle <- phase2_set_clinical_records(bundle, "baseline_risk", baselines)
      result <- phase2_clinical_result(bundle, repository_root)
      codes <- phase2_clinical_codes(result)
      phase0_assert_true("invalid_probability_bound" %in% codes)
      phase0_assert_true("score_outside_index_encounter" %in% codes)
    },

    "baseline availability cannot precede score or exceed as-of" = function() {
      bundle <- phase2_clinical_bundle(repository_root)
      baselines <- phase2_clinical_records(bundle, "baseline_risk")
      baselines[[1L]]$available_at <- "2026-01-03T09:00:00Z"
      bundle <- phase2_set_clinical_records(bundle, "baseline_risk", baselines)
      result <- phase2_clinical_result(bundle, repository_root)
      phase0_assert_true("availability_before_occurrence" %in% phase2_clinical_codes(result))

      bundle <- phase2_clinical_bundle(repository_root)
      baselines <- phase2_clinical_records(bundle, "baseline_risk")
      baselines[[1L]]$available_at <- "2026-02-10T12:01:00Z"
      bundle <- phase2_set_clinical_records(bundle, "baseline_risk", baselines)
      result <- phase2_clinical_result(bundle, repository_root)
      phase0_assert_true("information_after_as_of" %in% phase2_clinical_codes(result))
    },

    "duplicate event identity and unresolved event episode fail" = function() {
      bundle <- phase2_clinical_bundle(repository_root)
      events <- phase2_clinical_records(bundle, "episode_event")
      events[[2L]]$event_id <- events[[1L]]$event_id
      events[[2L]]$episode_id <- "fictional_missing_episode"
      bundle <- phase2_set_clinical_records(bundle, "episode_event", events)
      result <- phase2_clinical_result(bundle, repository_root)
      codes <- phase2_clinical_codes(result)
      phase0_assert_true("duplicate_primary_key" %in% codes)
      phase0_assert_true("unresolved_event_episode_id" %in% codes)
    },

    "event vocabulary is closed" = function() {
      bundle <- phase2_clinical_bundle(repository_root)
      events <- phase2_clinical_records(bundle, "episode_event")
      events[[1L]]$event_type <- "arbitrary_source_event"
      bundle <- phase2_set_clinical_records(bundle, "episode_event", events)
      result <- phase2_clinical_result(bundle, repository_root)
      phase0_assert_true("unknown_event_type" %in% phase2_clinical_codes(result))
    },

    "event availability ordering and future information fail" = function() {
      bundle <- phase2_clinical_bundle(repository_root)
      events <- phase2_clinical_records(bundle, "episode_event")
      events[[1L]]$available_at <- "2026-01-05T09:59:00Z"
      events[[2L]]$available_at <- "2026-02-10T12:01:00Z"
      bundle <- phase2_set_clinical_records(bundle, "episode_event", events)
      result <- phase2_clinical_result(bundle, repository_root)
      codes <- phase2_clinical_codes(result)
      phase0_assert_true("availability_before_occurrence" %in% codes)
      phase0_assert_true("information_after_as_of" %in% codes)
    },

    "event occurrence must belong to episode observation window" = function() {
      bundle <- phase2_clinical_bundle(repository_root)
      events <- phase2_clinical_records(bundle, "episode_event")
      events[[1L]]$event_time <- "2025-12-31T10:00:00Z"
      events[[1L]]$available_at <- "2025-12-31T10:05:00Z"
      bundle <- phase2_set_clinical_records(bundle, "episode_event", events)
      result <- phase2_clinical_result(bundle, repository_root)
      phase0_assert_true(
        "event_outside_episode_window" %in% phase2_clinical_codes(result)
      )
    },

    "missing root and child records without roots fail relationships" = function() {
      bundle <- phase2_clinical_bundle(repository_root)
      root_index <- phase2_clinical_domain_index(bundle, "discharge_episode")
      root_instance <- bundle$domains[[root_index]]$domain_instance_id
      bundle$domains[[root_index]] <- NULL
      bundle$reference_test_realization$domain_payloads <- Filter(
        function(payload) !identical(payload$domain_instance_id, root_instance),
        bundle$reference_test_realization$domain_payloads
      )
      result <- phase2_clinical_result(bundle, repository_root)
      codes <- phase2_clinical_codes(result)
      phase0_assert_true("missing_required_root_domain" %in% codes)
      phase0_assert_true("unresolved_baseline_episode_id" %in% codes)
      phase0_assert_true("unresolved_event_episode_id" %in% codes)
    },

    "capability declaration cannot contradict domain status" = function() {
      bundle <- phase2_clinical_bundle(repository_root)
      capability_index <- phase2_clinical_capability_index(
        bundle, "platform.episode-event-history"
      )
      bundle$capabilities[[capability_index]]$status <- "unavailable"
      result <- phase2_clinical_result(bundle, repository_root)
      phase0_assert_true(
        "capability_domain_status_mismatch" %in% phase2_clinical_codes(result)
      )
    },

    "available optional domains permit zero records" = function() {
      bundle <- phase2_set_clinical_records(
        phase2_clinical_bundle(repository_root), "baseline_risk", list()
      )
      bundle <- phase2_set_clinical_records(bundle, "episode_event", list())
      result <- phase2_clinical_result(bundle, repository_root)
      phase0_assert_true(rrp_conforms(result))
    },

    "unavailable and unsupported optional domains have no fabricated instance" = function() {
      bundle <- phase2_clinical_bundle(repository_root)
      for (definition in list(
        list(domain = "baseline_risk", capability = "platform.baseline-risk-input", status = "unavailable"),
        list(domain = "episode_event", capability = "platform.episode-event-history", status = "unsupported")
      )) {
        domain_index <- phase2_clinical_domain_index(bundle, definition$domain)
        instance_id <- bundle$domains[[domain_index]]$domain_instance_id
        bundle$domains[[domain_index]]$status <- definition$status
        bundle$domains[[domain_index]]$domain_instance_id <- NULL
        capability_index <- phase2_clinical_capability_index(bundle, definition$capability)
        bundle$capabilities[[capability_index]]$status <- definition$status
        bundle$reference_test_realization$domain_payloads <- Filter(
          function(payload) !identical(payload$domain_instance_id, instance_id),
          bundle$reference_test_realization$domain_payloads
        )
      }
      result <- phase2_clinical_result(bundle, repository_root)
      phase0_assert_true(rrp_conforms(result))
    },

    "unavailable baseline with fabricated data fails" = function() {
      bundle <- phase2_clinical_bundle(repository_root)
      domain_index <- phase2_clinical_domain_index(bundle, "baseline_risk")
      capability_index <- phase2_clinical_capability_index(
        bundle, "platform.baseline-risk-input"
      )
      bundle$domains[[domain_index]]$status <- "unavailable"
      bundle$capabilities[[capability_index]]$status <- "unavailable"
      result <- phase2_clinical_result(bundle, repository_root)
      phase0_assert_true("absent_domain_has_instance" %in% phase2_clinical_codes(result))
    },

    "undeclared fields fail closed" = function() {
      bundle <- phase2_clinical_bundle(repository_root)
      events <- phase2_clinical_records(bundle, "episode_event")
      events[[1L]]$implementation_extra <- "not-canonical"
      bundle <- phase2_set_clinical_records(bundle, "episode_event", events)
      result <- phase2_clinical_result(bundle, repository_root)
      phase0_assert_true("unknown_domain_field" %in% phase2_clinical_codes(result))
    },

    "clinical conformance accumulates structured issues" = function() {
      bundle <- phase2_clinical_bundle(repository_root)
      episodes <- phase2_clinical_records(bundle, "discharge_episode")
      episodes[[1L]]$admission_time <- episodes[[1L]]$discharge_time
      bundle <- phase2_set_clinical_records(bundle, "discharge_episode", episodes)
      events <- phase2_clinical_records(bundle, "episode_event")
      events[[1L]]$event_type <- "unknown"
      bundle <- phase2_set_clinical_records(bundle, "episode_event", events)
      baselines <- phase2_clinical_records(bundle, "baseline_risk")
      baselines[[1L]]$probability <- NULL
      bundle <- phase2_set_clinical_records(bundle, "baseline_risk", baselines)
      result <- phase2_clinical_result(bundle, repository_root)
      phase0_assert_false(rrp_conforms(result))
      phase0_assert_true(nrow(result$issues) >= 3L)
      phase0_assert_true(all(nzchar(result$issues$rule_id)))
      phase0_assert_true(all(nzchar(result$issues$issue_code)))
      phase0_assert_true(all(nzchar(result$issues$message)))
    }
  )
}
