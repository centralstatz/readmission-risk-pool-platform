# Implementation-owned translation into the exact Phase 2 clinical profile.

rrp_synthetic_mapping_specification_identity <- function() {
  list(
    specification_kind = "source_mapping",
    specification_id = "reference.synthetic-to-readmission-canonical",
    specification_version = "0.1.0"
  )
}

rrp_synthetic_episode_id <- function(discharge_key) {
  sub("^synthetic_discharge_", "episode_", discharge_key)
}

rrp_synthetic_mapping_issue <- function(code, message, path, location) {
  rrp_synthetic_issue(
    "synthetic.mapping.translation",
    code,
    message,
    path,
    location,
    rrp_synthetic_mapping_specification_identity()
  )
}

rrp_map_synthetic_discharge_episodes <- function(source, config) {
  discharges <- source$discharges
  encounters <- source$encounters
  encounter_index <- match(discharges$encounter_key, encounters$encounter_key)
  as_of <- rrp_timestamp_number(config$canonical_as_of_time)
  discharge_time <- rrp_timestamp_number(encounters$discharged_at[encounter_index])
  keep <- discharge_time <= as_of
  discharges <- discharges[keep, , drop = FALSE]
  encounter_index <- encounter_index[keep]
  discharge_time <- discharge_time[keep]

  available_outcomes <- source$outcomes[
    rrp_timestamp_number(source$outcomes$received_at) <= as_of,
    , drop = FALSE
  ]
  readmissions <- available_outcomes[available_outcomes$outcome_code == "readmission", , drop = FALSE]
  deaths <- available_outcomes[available_outcomes$outcome_code == "death", , drop = FALSE]
  readmission_index <- match(discharges$discharge_key, readmissions$discharge_key)
  death_index <- match(discharges$discharge_key, deaths$discharge_key)

  records <- vector("list", nrow(discharges))
  for (index in seq_len(nrow(discharges))) {
    encounter <- encounters[encounter_index[[index]], , drop = FALSE]
    record <- list(
      episode_id = rrp_synthetic_episode_id(discharges$discharge_key[[index]]),
      patient_id = encounter$patient_key[[1L]],
      index_encounter_id = encounter$encounter_key[[1L]],
      admission_time = encounter$admitted_at[[1L]],
      discharge_time = encounter$discharged_at[[1L]],
      followup_window_end = rrp_synthetic_format_time(
        discharge_time[[index]] + discharges$followup_days[[index]] * 86400
      )
    )
    if (!is.na(readmission_index[[index]])) {
      record$readmission_time <- readmissions$occurred_at[[readmission_index[[index]]]]
    }
    if (!is.na(death_index[[index]])) {
      record$death_time <- deaths$occurred_at[[death_index[[index]]]]
    }
    records[[index]] <- record
  }
  records
}

rrp_map_synthetic_baseline_risk <- function(source, config) {
  as_of <- rrp_timestamp_number(config$canonical_as_of_time)
  scores <- source$risk_scores[
    rrp_timestamp_number(source$risk_scores$received_at) <= as_of,
    , drop = FALSE
  ]
  lapply(seq_len(nrow(scores)), function(index) {
    list(
      episode_id = rrp_synthetic_episode_id(scores$discharge_key[[index]]),
      source_model_id = "reference.synthetic-local-readmit-probability",
      source_model_version = scores$score_version[[index]],
      score_time = scores$assessed_at[[index]],
      available_at = scores$received_at[[index]],
      value_type = "probability",
      probability = scores$score_probability[[index]],
      source_reference_id = scores$score_key[[index]]
    )
  })
}

rrp_map_synthetic_episode_events <- function(source, config, location) {
  issues <- list()
  event_translation <- c(
    transition_call_complete = "care_transition_contact",
    ambulatory_followup = "followup_visit",
    emergency_visit = "emergency_department_visit",
    medication_barrier = "medication_issue"
  )
  outcome_translation <- c(
    readmission = "hospital_readmission",
    death = "death_notification"
  )
  as_of <- rrp_timestamp_number(config$canonical_as_of_time)
  activities <- source$activity_events[
    rrp_timestamp_number(source$activity_events$received_at) <= as_of,
    , drop = FALSE
  ]
  outcomes <- source$outcomes[
    rrp_timestamp_number(source$outcomes$received_at) <= as_of,
    , drop = FALSE
  ]

  unmapped_activities <- setdiff(unique(activities$event_code), names(event_translation))
  for (code in unmapped_activities) {
    issues[[length(issues) + 1L]] <- rrp_synthetic_mapping_issue(
      "unmapped_source_event_code",
      paste0("Source event code has no approved canonical translation: ", code, "."),
      "$.activity_events.event_code", location
    )
  }
  unmapped_outcomes <- setdiff(unique(outcomes$outcome_code), names(outcome_translation))
  for (code in unmapped_outcomes) {
    issues[[length(issues) + 1L]] <- rrp_synthetic_mapping_issue(
      "unmapped_source_outcome_code",
      paste0("Source outcome code has no approved canonical translation: ", code, "."),
      "$.outcomes.outcome_code", location
    )
  }
  if (length(issues) > 0L) {
    return(list(records = list(), issues = issues))
  }

  activity_records <- lapply(seq_len(nrow(activities)), function(index) {
    list(
      event_id = activities$event_key[[index]],
      episode_id = rrp_synthetic_episode_id(activities$discharge_key[[index]]),
      event_type = unname(event_translation[[activities$event_code[[index]]]]),
      event_time = activities$occurred_at[[index]],
      available_at = activities$received_at[[index]],
      source_reference_id = activities$event_key[[index]]
    )
  })
  outcome_records <- lapply(seq_len(nrow(outcomes)), function(index) {
    list(
      event_id = outcomes$outcome_key[[index]],
      episode_id = rrp_synthetic_episode_id(outcomes$discharge_key[[index]]),
      event_type = unname(outcome_translation[[outcomes$outcome_code[[index]]]]),
      event_time = outcomes$occurred_at[[index]],
      available_at = outcomes$received_at[[index]],
      source_reference_id = outcomes$outcome_key[[index]]
    )
  })
  list(records = c(activity_records, outcome_records), issues = issues)
}

rrp_synthetic_bundle_suffix <- function(config) {
  time <- gsub("[^0-9]", "", config$canonical_as_of_time)
  paste(config$scale_id, as.integer(config$seed), time, sep = "_")
}

rrp_build_synthetic_canonical_bundle <- function(
  domain_records,
  config,
  implementation
) {
  suffix <- rrp_synthetic_bundle_suffix(config)
  identities <- rrp_synthetic_expected_identities()
  list(
    bundle_instance_id = paste0("reference_synthetic_bundle_", suffix),
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
      run_id = paste0("run_synthetic_reference_", suffix),
      operation_id = "generate_reference_implementation",
      as_of_time = config$canonical_as_of_time
    ),
    implementation_identity = identities$implementation_identity,
    mapping_identity = identities$mapping_identity,
    domains = list(
      list(
        domain_id = "discharge_episode",
        domain_specification = list(
          specification_kind = "canonical_domain",
          specification_id = "platform.canonical-discharge-episode",
          specification_version = "0.1.0"
        ),
        requirement_class = "required",
        status = "available",
        domain_instance_id = paste0("domain_discharge_episode_", suffix),
        capability_ids = list("platform.discharge-episode")
      ),
      list(
        domain_id = "baseline_risk",
        domain_specification = list(
          specification_kind = "canonical_domain",
          specification_id = "platform.canonical-baseline-risk",
          specification_version = "0.1.0"
        ),
        requirement_class = "optional",
        status = "available",
        domain_instance_id = paste0("domain_baseline_risk_", suffix),
        capability_ids = list("platform.baseline-risk-input"),
        temporal_declaration = list(
          occurrence_field = "score_time",
          availability_field = "available_at",
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
        requirement_class = "optional",
        status = "available",
        domain_instance_id = paste0("domain_episode_event_", suffix),
        capability_ids = list("platform.episode-event-history"),
        temporal_declaration = list(
          occurrence_field = "event_time",
          availability_field = "available_at",
          availability_order = "not_before_occurrence"
        )
      )
    ),
    capabilities = list(
      list(
        capability_id = "platform.discharge-episode",
        requirement_class = "required",
        status = "available",
        domain_ids = list("discharge_episode")
      ),
      list(
        capability_id = "platform.baseline-risk-input",
        requirement_class = "optional",
        status = "available",
        domain_ids = list("baseline_risk")
      ),
      list(
        capability_id = "platform.episode-event-history",
        requirement_class = "optional",
        status = "available",
        domain_ids = list("episode_event")
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
        provenance_type = "generator_identity",
        provenance_id = identities$generator_identity$generator_id,
        relationship = "generated_source",
        version_or_revision = identities$generator_identity$generator_version
      ),
      list(
        provenance_type = "source_schema_identity",
        provenance_id = identities$source_schema_identity$source_schema_id,
        relationship = "validated_source_against",
        version_or_revision = identities$source_schema_identity$source_schema_version
      ),
      list(
        provenance_type = "mapping_identity",
        provenance_id = identities$mapping_identity$mapping_id,
        relationship = "mapped_by",
        version_or_revision = identities$mapping_identity$mapping_version
      )
    ),
    conformance_result_references = list(
      list(
        provenance_type = "conformance_result",
        provenance_id = paste0("source_conformance_", suffix),
        relationship = "producer_reported"
      )
    ),
    reference_test_realization = list(
      realization_kind = "embedded_records",
      domain_payloads = list(
        list(
          domain_instance_id = paste0("domain_discharge_episode_", suffix),
          records = domain_records$discharge_episode
        ),
        list(
          domain_instance_id = paste0("domain_baseline_risk_", suffix),
          records = domain_records$baseline_risk
        ),
        list(
          domain_instance_id = paste0("domain_episode_event_", suffix),
          records = domain_records$episode_event
        )
      )
    )
  )
}

rrp_map_synthetic_source_to_canonical <- function(
  source,
  config,
  implementation,
  location = NA_character_
) {
  event_mapping <- rrp_map_synthetic_episode_events(source, config, location)
  issues <- event_mapping$issues
  domain_records <- list(
    discharge_episode = rrp_map_synthetic_discharge_episodes(source, config),
    baseline_risk = rrp_map_synthetic_baseline_risk(source, config),
    episode_event = event_mapping$records
  )
  result <- rrp_synthetic_result(
    list(), issues, rrp_synthetic_mapping_specification_identity()
  )
  if (!rrp_conforms(result)) {
    return(list(
      candidate_bundle = NULL,
      domain_records = domain_records,
      conformance = result
    ))
  }
  bundle <- rrp_build_synthetic_canonical_bundle(
    domain_records, config, implementation
  )
  list(
    candidate_bundle = bundle,
    domain_records = domain_records,
    conformance = rrp_synthetic_result(
      bundle, list(), rrp_synthetic_mapping_specification_identity()
    )
  )
}
