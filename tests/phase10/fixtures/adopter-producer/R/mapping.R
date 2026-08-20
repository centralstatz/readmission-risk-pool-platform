# Independent mapping from the fictional export shape to the existing profile.

rrp_adopter_bundle_suffix <- function(configuration) {
  time <- gsub("[^0-9]", "", configuration$canonical_as_of_time)
  paste(configuration$scenario_id, time, sep = "_")
}

rrp_adopter_map_discharge_episodes <- function(source, configuration) {
  as_of <- rrp_timestamp_number(configuration$canonical_as_of_time)
  cases <- source$case_extract[
    rrp_adopter_local_time_number(source$case_extract$extract_loaded_local) <= as_of,
    , drop = FALSE
  ]
  lapply(seq_len(nrow(cases)), function(index) {
    terminal_known <- !is.na(cases$terminal_loaded_local[[index]]) &&
      rrp_adopter_local_time_number(cases$terminal_loaded_local[[index]]) <= as_of
    record <- list(
      episode_id = rrp_adopter_normalize_identifier("adopter_episode", cases$case_ref[[index]]),
      patient_id = rrp_adopter_normalize_identifier("adopter_person", cases$subject_token[[index]]),
      index_encounter_id = rrp_adopter_normalize_identifier("adopter_encounter", cases$stay_ref[[index]]),
      admission_time = rrp_adopter_canonical_time(cases$arrived_local[[index]]),
      discharge_time = rrp_adopter_canonical_time(cases$departed_local[[index]]),
      followup_window_end = rrp_adopter_canonical_time(cases$watch_through_local[[index]])
    )
    if (terminal_known && identical(cases$closure_code[[index]], "RETURNED")) {
      record$readmission_time <- rrp_adopter_canonical_time(cases$terminal_local[[index]])
    }
    if (terminal_known && identical(cases$closure_code[[index]], "DIED")) {
      record$death_time <- rrp_adopter_canonical_time(cases$terminal_local[[index]])
    }
    record
  })
}

rrp_adopter_map_episode_events <- function(source, configuration) {
  translation <- c(
    CALL_OK = "care_transition_contact",
    CLINIC_SEEN = "followup_visit",
    ED_SEEN = "emergency_department_visit",
    MED_ACCESS_FLAG = "medication_issue",
    RETURN_NOTICE = "hospital_readmission",
    DEATH_ALERT = "death_notification"
  )
  as_of <- rrp_timestamp_number(configuration$canonical_as_of_time)
  available <- source$activity_feed[
    rrp_adopter_local_time_number(source$activity_feed$loaded_local) <= as_of,
    , drop = FALSE
  ]
  unmapped <- setdiff(unique(available$fact_code), names(translation))
  if (length(unmapped) > 0L) return(list(
    records = list(),
    issues = list(rrp_adopter_issue(
      "adopter.mapping.vocabulary", "unmapped_adopter_activity_code",
      "A local activity code has no approved canonical translation.",
      "$.activity_feed.fact_code", rrp_adopter_mapping_specification()
    ))
  ))
  records <- lapply(seq_len(nrow(available)), function(index) list(
    event_id = rrp_adopter_normalize_identifier("adopter_event", available$fact_ref[[index]]),
    episode_id = rrp_adopter_normalize_identifier("adopter_episode", available$case_ref[[index]]),
    event_type = unname(translation[[available$fact_code[[index]]]]),
    event_time = rrp_adopter_canonical_time(available$happened_local[[index]]),
    available_at = rrp_adopter_canonical_time(available$loaded_local[[index]]),
    source_reference_id = available$fact_ref[[index]]
  ))
  list(records = records, issues = list())
}

rrp_build_adopter_canonical_bundle <- function(
  discharge_episodes, episode_events, configuration
) {
  suffix <- rrp_adopter_bundle_suffix(configuration)
  identities <- rrp_adopter_fixture_identities()
  discharge_instance <- paste0("adopter_discharge_domain_", suffix)
  event_instance <- paste0("adopter_event_domain_", suffix)
  list(
    bundle_instance_id = paste0("adopter_conformance_bundle_", suffix),
    bundle_specification = list(
      specification_kind = "canonical_bundle",
      specification_id = "platform.canonical-bundle",
      specification_version = "0.1.0"
    ),
    profile_specification = list(
      specification_kind = "canonical_profile",
      specification_id = "platform.readmission-initial-profile",
      specification_version = "0.1.0"
    ),
    run_context = list(
      run_id = paste0("canonical_adopter_conformance_", suffix),
      operation_id = "adopter_conformance_production",
      as_of_time = configuration$canonical_as_of_time
    ),
    implementation_identity = identities$implementation,
    mapping_identity = identities$mapping,
    domains = list(
      list(
        domain_id = "discharge_episode",
        domain_specification = list(
          specification_kind = "canonical_domain",
          specification_id = "platform.canonical-discharge-episode",
          specification_version = "0.1.0"
        ),
        requirement_class = "required", status = "available",
        domain_instance_id = discharge_instance,
        capability_ids = list("platform.discharge-episode")
      ),
      list(
        domain_id = "baseline_risk",
        domain_specification = list(
          specification_kind = "canonical_domain",
          specification_id = "platform.canonical-baseline-risk",
          specification_version = "0.1.0"
        ),
        requirement_class = "optional", status = "unsupported",
        capability_ids = list("platform.baseline-risk-input"),
        temporal_declaration = list(
          occurrence_field = "score_time", availability_field = "available_at",
          availability_order = "not_before_occurrence"
        )
      ),
      list(
        domain_id = "episode_event",
        domain_specification = list(
          specification_kind = "canonical_domain",
          specification_id = "platform.canonical-episode-event",
          specification_version = "0.1.0"
        ),
        requirement_class = "optional", status = "available",
        domain_instance_id = event_instance,
        capability_ids = list("platform.episode-event-history"),
        temporal_declaration = list(
          occurrence_field = "event_time", availability_field = "available_at",
          availability_order = "not_before_occurrence"
        )
      )
    ),
    capabilities = list(
      list(
        capability_id = "platform.discharge-episode", requirement_class = "required",
        status = "available", domain_ids = list("discharge_episode")
      ),
      list(
        capability_id = "platform.baseline-risk-input", requirement_class = "optional",
        status = "unsupported", domain_ids = list("baseline_risk")
      ),
      list(
        capability_id = "platform.episode-event-history", requirement_class = "optional",
        status = "available", domain_ids = list("episode_event")
      )
    ),
    dependencies = list(
      list(
        dependency_id = "baseline-risk-requires-discharge-episode",
        subject_type = "domain", subject_id = "baseline_risk",
        prerequisite_type = "domain", prerequisite_id = "discharge_episode"
      ),
      list(
        dependency_id = "episode-event-requires-discharge-episode",
        subject_type = "domain", subject_id = "episode_event",
        prerequisite_type = "domain", prerequisite_id = "discharge_episode"
      ),
      list(
        dependency_id = "baseline-risk-capability-requires-episode-capability",
        subject_type = "capability", subject_id = "platform.baseline-risk-input",
        prerequisite_type = "capability", prerequisite_id = "platform.discharge-episode"
      ),
      list(
        dependency_id = "event-capability-requires-episode-capability",
        subject_type = "capability", subject_id = "platform.episode-event-history",
        prerequisite_type = "capability", prerequisite_id = "platform.discharge-episode"
      )
    ),
    provenance_references = list(
      list(
        provenance_type = "fixture_definition",
        provenance_id = "conformance.adopter-fictional-export-fixture",
        relationship = "constructed_fictional_source",
        version_or_revision = "0.1.0"
      ),
      list(
        provenance_type = "source_schema_identity",
        provenance_id = identities$source_schema$source_schema_id,
        relationship = "validated_source_against",
        version_or_revision = identities$source_schema$source_schema_version
      ),
      list(
        provenance_type = "mapping_identity",
        provenance_id = identities$mapping$mapping_id,
        relationship = "mapped_by",
        version_or_revision = identities$mapping$mapping_version
      )
    ),
    conformance_result_references = list(list(
      provenance_type = "conformance_result",
      provenance_id = paste0("adopter_source_conformance_", suffix),
      relationship = "producer_reported"
    )),
    reference_test_realization = list(
      realization_kind = "embedded_records",
      domain_payloads = list(
        list(domain_instance_id = discharge_instance, records = discharge_episodes),
        list(domain_instance_id = event_instance, records = episode_events)
      )
    )
  )
}

rrp_map_adopter_source_to_canonical <- function(source, configuration) {
  event_mapping <- rrp_adopter_map_episode_events(source, configuration)
  mapping_result <- rrp_adopter_result(
    list(), event_mapping$issues, rrp_adopter_mapping_specification()
  )
  if (!rrp_conforms(mapping_result)) return(list(
    candidate_bundle = NULL, conformance = mapping_result,
    discharge_episodes = list(), episode_events = list()
  ))
  episodes <- rrp_adopter_map_discharge_episodes(source, configuration)
  bundle <- rrp_build_adopter_canonical_bundle(
    episodes, event_mapping$records, configuration
  )
  list(
    candidate_bundle = bundle,
    conformance = rrp_adopter_result(
      bundle, list(), rrp_adopter_mapping_specification()
    ),
    discharge_episodes = episodes,
    episode_events = event_mapping$records
  )
}
