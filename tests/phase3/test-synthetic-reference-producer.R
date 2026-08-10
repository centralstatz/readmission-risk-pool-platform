phase3_copy <- function(value) unserialize(serialize(value, NULL))

phase3_cached_producer <- local({
  cache <- list()
  function(repository_root, scale = "test") {
    if (is.null(cache[[scale]])) {
      cache[[scale]] <<- rrp_run_synthetic_reference(repository_root, scale)
    }
    phase3_copy(cache[[scale]])
  }
})

phase3_payload_records <- function(bundle, domain_id) {
  payload <- rrp_clinical_payload(bundle, domain_id)
  payload$records
}

phase3_issue_codes <- function(result) unique(result$issues$issue_code)

phase3_test_cases <- function(repository_root) {
  list(
    "synthetic identities and configurations are distinct and conforming" = function() {
      implementation <- rrp_read_synthetic_implementation_specification(repository_root)
      schema <- rrp_read_synthetic_source_schema(repository_root)
      config <- rrp_read_synthetic_configuration(repository_root, "test")
      phase0_assert_true(rrp_conforms(
        rrp_validate_synthetic_implementation_specification(implementation)
      ))
      phase0_assert_true(rrp_conforms(
        rrp_validate_synthetic_source_schema_specification(schema)
      ))
      phase0_assert_true(rrp_conforms(
        rrp_validate_synthetic_configuration(config, implementation)
      ))
      identity_values <- c(
        implementation$implementation_identity$implementation_id,
        implementation$mapping_identity$mapping_id,
        implementation$generator_identity$generator_id,
        implementation$source_schema_identity$source_schema_id
      )
      phase0_assert_true(length(unique(identity_values)) == 4L)
    },

    "same version configuration and seed reproduce source and bundle" = function() {
      first <- rrp_run_synthetic_reference(repository_root, "test")
      second <- rrp_run_synthetic_reference(repository_root, "test")
      phase0_assert_true(identical(serialize(first$source, NULL), serialize(second$source, NULL)))
      phase0_assert_true(identical(
        serialize(first$candidate_bundle, NULL), serialize(second$candidate_bundle, NULL)
      ))
    },

    "changing seed changes data while preserving conformance" = function() {
      implementation <- rrp_read_synthetic_implementation_specification(repository_root)
      schema <- rrp_read_synthetic_source_schema(repository_root)
      original <- rrp_read_synthetic_configuration(repository_root, "test")
      changed <- phase3_copy(original)
      changed$seed <- original$seed + 1L
      source_original <- rrp_generate_synthetic_source(original)
      source_changed <- rrp_generate_synthetic_source(changed)
      phase0_assert_false(identical(source_original$risk_scores, source_changed$risk_scores))
      produced <- rrp_produce_synthetic_from_source(
        source_changed, changed, implementation, schema, repository_root
      )
      phase0_assert_true(identical(produced$overall_status, "succeeded"))
    },

    "source domains are relational and meaningfully noncanonical" = function() {
      result <- phase3_cached_producer(repository_root)
      source <- result$source
      phase0_assert_true(setequal(names(source), c(
        "patients", "encounters", "discharges", "risk_scores",
        "activity_events", "outcomes"
      )))
      phase0_assert_true(any(duplicated(source$encounters$patient_key)))
      phase0_assert_true(all(source$encounters$patient_key %in% source$patients$patient_key))
      phase0_assert_true(all(source$discharges$encounter_key %in% source$encounters$encounter_key))
      phase0_assert_true(!"episode_id" %in% names(source$discharges))
    },

    "source-local validation rejects duplicate IDs" = function() {
      result <- phase3_cached_producer(repository_root)
      source <- result$source
      source$patients$patient_key[[2L]] <- source$patients$patient_key[[1L]]
      validation <- rrp_validate_synthetic_source(
        source, rrp_read_synthetic_source_schema(repository_root)
      )
      phase0_assert_true(
        "duplicate_or_missing_source_id" %in% phase3_issue_codes(validation)
      )
    },

    "source-local validation rejects broken relationships" = function() {
      result <- phase3_cached_producer(repository_root)
      source <- result$source
      source$discharges$encounter_key[[1L]] <- "synthetic_encounter_missing"
      validation <- rrp_validate_synthetic_source(
        source, rrp_read_synthetic_source_schema(repository_root)
      )
      phase0_assert_true(
        "unresolved_source_foreign_key" %in% phase3_issue_codes(validation)
      )
    },

    "source-local validation reports missing fields without crashing" = function() {
      result <- phase3_cached_producer(repository_root)
      source <- result$source
      source$risk_scores$received_at <- NULL
      validation <- rrp_validate_synthetic_source(
        source, rrp_read_synthetic_source_schema(repository_root)
      )
      phase0_assert_false(rrp_conforms(validation))
      phase0_assert_true(
        "missing_source_field" %in% phase3_issue_codes(validation)
      )
    },

    "source-local validation rejects impossible timestamps" = function() {
      result <- phase3_cached_producer(repository_root)
      source <- result$source
      source$encounters$admitted_at[[1L]] <- source$encounters$discharged_at[[1L]]
      source$risk_scores$received_at[[1L]] <- "2020-01-01T00:00:00Z"
      validation <- rrp_validate_synthetic_source(
        source, rrp_read_synthetic_source_schema(repository_root)
      )
      codes <- phase3_issue_codes(validation)
      phase0_assert_true("invalid_source_encounter_time" %in% codes)
      phase0_assert_true("source_risk_received_before_assessed" %in% codes)
    },

    "source-local validation rejects invalid event and risk codes" = function() {
      result <- phase3_cached_producer(repository_root)
      source <- result$source
      source$activity_events$event_code[[1L]] <- "unknown_local_event"
      source$risk_scores$score_code[[1L]] <- "unknown_local_score"
      validation <- rrp_validate_synthetic_source(
        source, rrp_read_synthetic_source_schema(repository_root)
      )
      phase0_assert_true("invalid_source_code" %in% phase3_issue_codes(validation))
      phase0_assert_true(nrow(validation$issues) >= 2L)
    },

    "producer stops after source-local failure" = function() {
      normal <- phase3_cached_producer(repository_root)
      source <- normal$source
      source$activity_events$discharge_key[[1L]] <- "synthetic_discharge_missing"
      produced <- rrp_produce_synthetic_from_source(
        source,
        rrp_read_synthetic_configuration(repository_root, "test"),
        rrp_read_synthetic_implementation_specification(repository_root),
        rrp_read_synthetic_source_schema(repository_root),
        repository_root
      )
      phase0_assert_true(identical(produced$overall_status, "failed"))
      phase0_assert_true(identical(
        produced$stage_statuses[["source_local_validation"]], "failed"
      ))
      phase0_assert_true(identical(produced$stage_statuses[["mapping"]], "not_run"))
      phase0_assert_true(is.null(produced$candidate_bundle))
    },

    "source-valid but unmapped code is a distinct mapping failure" = function() {
      normal <- phase3_cached_producer(repository_root)
      source <- normal$source
      as_of <- rrp_timestamp_number(
        rrp_read_synthetic_configuration(repository_root, "test")$canonical_as_of_time
      )
      available <- which(rrp_timestamp_number(source$activity_events$received_at) <= as_of)
      source$activity_events$event_code[[available[[1L]]]] <- "other_observed"
      schema <- rrp_read_synthetic_source_schema(repository_root)
      phase0_assert_true(rrp_conforms(rrp_validate_synthetic_source(source, schema)))
      produced <- rrp_produce_synthetic_from_source(
        source,
        rrp_read_synthetic_configuration(repository_root, "test"),
        rrp_read_synthetic_implementation_specification(repository_root),
        schema,
        repository_root
      )
      phase0_assert_true(identical(produced$stage_statuses[["mapping"]], "failed"))
      phase0_assert_true(
        "unmapped_source_event_code" %in% phase3_issue_codes(produced$mapping_conformance)
      )
      phase0_assert_true(is.null(produced$canonical_conformance))
    },

    "mapping creates deterministic root identity and exact root fields" = function() {
      result <- phase3_cached_producer(repository_root)
      episodes <- phase3_payload_records(result$candidate_bundle, "discharge_episode")
      phase0_assert_true(identical(episodes[[1L]]$episode_id, "episode_000001"))
      phase0_assert_true(identical(
        episodes[[1L]]$patient_id, result$source$patients$patient_key[[1L]]
      ))
      phase0_assert_true(setequal(
        names(episodes[[1L]]),
        c(
          "episode_id", "patient_id", "index_encounter_id", "admission_time",
          "discharge_time", "followup_window_end"
        )
      ))
    },

    "baseline mapping preserves source identity value and dual time" = function() {
      result <- phase3_cached_producer(repository_root)
      baselines <- phase3_payload_records(result$candidate_bundle, "baseline_risk")
      phase0_assert_true(length(baselines) > 0L)
      phase0_assert_true(all(vapply(baselines, function(record) {
        identical(record$source_model_id, "reference.synthetic-local-readmit-probability") &&
          identical(record$value_type, "probability") &&
          rrp_timestamp_number(record$available_at) >= rrp_timestamp_number(record$score_time)
      }, logical(1))))
      phase0_assert_true(any(vapply(baselines, function(record) {
        episode <- phase3_payload_records(
          result$candidate_bundle, "discharge_episode"
        )[[match(
          record$episode_id,
          vapply(phase3_payload_records(
            result$candidate_bundle, "discharge_episode"
          ), `[[`, character(1), "episode_id")
        )]]
        rrp_timestamp_number(record$available_at) > rrp_timestamp_number(episode$discharge_time)
      }, logical(1))))
    },

    "event translation preserves delayed occurrence and availability" = function() {
      result <- phase3_cached_producer(repository_root, "reference")
      events <- phase3_payload_records(result$candidate_bundle, "episode_event")
      phase0_assert_true(all(vapply(events, function(record) {
        record$event_type %in% rrp_episode_event_types()
      }, logical(1))))
      phase0_assert_true(any(vapply(events, function(record) {
        rrp_timestamp_number(record$available_at) > rrp_timestamp_number(record$event_time)
      }, logical(1))))
    },

    "mapping excludes source information unavailable after as-of" = function() {
      result <- phase3_cached_producer(repository_root)
      as_of <- rrp_timestamp_number(result$candidate_bundle$run_context$as_of_time)
      future_activity_ids <- result$source$activity_events$event_key[
        rrp_timestamp_number(result$source$activity_events$received_at) > as_of
      ]
      mapped_events <- phase3_payload_records(result$candidate_bundle, "episode_event")
      mapped_references <- vapply(
        mapped_events, `[[`, character(1), "source_reference_id"
      )
      phase0_assert_true(length(future_activity_ids) > 0L)
      phase0_assert_true(!any(future_activity_ids %in% mapped_references))
      phase0_assert_true(result$summary$future_source_records_excluded > 0L)
    },

    "generated bundle conforms to exact Phase 2 profile" = function() {
      result <- phase3_cached_producer(repository_root)
      phase0_assert_true(identical(result$overall_status, "succeeded"))
      phase0_assert_true(rrp_conforms(result$source_local_conformance))
      phase0_assert_true(rrp_conforms(result$mapping_conformance))
      phase0_assert_true(rrp_conforms(result$canonical_conformance))
      phase0_assert_true(identical(
        result$candidate_bundle$profile_specification$specification_id,
        "platform.readmission-initial-profile"
      ))
    },

    "capability availability is independent of per-episode rows" = function() {
      result <- phase3_cached_producer(repository_root)
      bundle <- result$candidate_bundle
      phase0_assert_true(all(vapply(bundle$capabilities, function(capability) {
        identical(capability$status, "available")
      }, logical(1))))
      episodes <- phase3_payload_records(bundle, "discharge_episode")
      baselines <- phase3_payload_records(bundle, "baseline_risk")
      events <- phase3_payload_records(bundle, "episode_event")
      episode_ids <- vapply(episodes, `[[`, character(1), "episode_id")
      baseline_ids <- vapply(baselines, `[[`, character(1), "episode_id")
      event_ids <- vapply(events, `[[`, character(1), "episode_id")
      phase0_assert_true(length(setdiff(episode_ids, baseline_ids)) > 0L)
      phase0_assert_true(length(setdiff(episode_ids, event_ids)) > 0L)
    },

    "reference scale includes terminal and active episodes" = function() {
      result <- phase3_cached_producer(repository_root, "reference")
      phase0_assert_true(result$summary$readmissions > 0L)
      phase0_assert_true(result$summary$deaths > 0L)
      phase0_assert_true(result$summary$active_episodes > 0L)
      phase0_assert_true(rrp_conforms(result$canonical_conformance))
    },

    "source-only fields do not leak into canonical records" = function() {
      result <- phase3_cached_producer(repository_root)
      record_fields <- unique(unlist(lapply(
        c("discharge_episode", "baseline_risk", "episode_event"),
        function(domain) unlist(lapply(
          phase3_payload_records(result$candidate_bundle, domain), names
        ), use.names = FALSE)
      ), use.names = FALSE))
      phase0_assert_true(!any(c(
        "fictional_region_code", "source_episode_label", "source_queue_label",
        "source_note_class", "score_code", "event_code"
      ) %in% record_fields))
    },

    "canonical failure remains distinct from conforming source" = function() {
      result <- phase3_cached_producer(repository_root)
      bundle <- result$candidate_bundle
      payload <- rrp_clinical_payload(bundle, "episode_event")
      payload$records[[1L]]$event_type <- "invalid_canonical_event"
      payload_index <- match(
        payload$domain_instance_id,
        vapply(
          bundle$reference_test_realization$domain_payloads,
          `[[`, character(1), "domain_instance_id"
        )
      )
      bundle$reference_test_realization$domain_payloads[[payload_index]] <- payload
      canonical <- rrp_validate_clinical_bundle_instance(bundle, repository_root)
      phase0_assert_true(rrp_conforms(result$source_local_conformance))
      phase0_assert_false(rrp_conforms(canonical))
      phase0_assert_true("unknown_event_type" %in% phase3_issue_codes(canonical))
    },

    "generic canonical validation has no synthetic dependency or identity branch" = function() {
      files <- c(
        "operations/lib/canonical-bundle-validation.R",
        "operations/lib/canonical-clinical-validation.R",
        "operations/lib/canonical-specification-validation.R"
      )
      text <- unlist(lapply(file.path(repository_root, files), readLines, warn = FALSE))
      forbidden <- c(
        "synthetic-reference", "synthetic-health-system", "activity_events",
        "source_queue_label", "other_observed"
      )
      phase0_assert_true(!any(vapply(forbidden, function(value) {
        any(grepl(value, text, fixed = TRUE))
      }, logical(1))))
    },

    "reference-scale high-level regression remains understandable" = function() {
      summary <- phase3_cached_producer(repository_root, "reference")$summary
      expected <- list(
        patients = 24L,
        encounters = 42L,
        discharge_episodes = 36L,
        baseline_records = 27L,
        event_records = 38L,
        readmissions = 6L,
        deaths = 4L,
        active_episodes = 11L,
        future_source_records_excluded = 9L
      )
      phase0_assert_true(identical(summary, expected))
    },

    "producer provenance carries distinct generator mapping and schema identity" = function() {
      result <- phase3_cached_producer(repository_root)
      types <- vapply(
        result$provenance_references, `[[`, character(1), "provenance_type"
      )
      phase0_assert_true(setequal(
        types, c("generator_identity", "source_schema_identity", "mapping_identity")
      ))
      phase0_assert_true(!is.null(result$source_local_conformance))
      phase0_assert_true(!is.null(result$canonical_conformance))
    },

    "all generated identifiers and classifications are visibly fictional" = function() {
      result <- phase3_cached_producer(repository_root)
      source_ids <- unlist(lapply(result$source, function(table) table[[1L]]))
      phase0_assert_true(all(startsWith(source_ids, "synthetic_")))
      implementation <- rrp_read_synthetic_implementation_specification(repository_root)
      phase0_assert_true(identical(
        implementation$data_classification, "fictional_nonclinical"
      ))
      phase0_assert_true(identical(implementation$clinical_validity, "none"))
    }
  )
}
