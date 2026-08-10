# Focused pre-runtime validation for the initial readmission clinical profile.

rrp_clinical_profile_identity <- function() {
  list(
    specification_kind = "canonical_profile",
    specification_id = "platform.readmission-initial-profile",
    specification_version = "0.1.0"
  )
}

rrp_clinical_domain_identities <- function() {
  list(
    discharge_episode = list(
      specification_kind = "canonical_domain",
      specification_id = "platform.canonical-discharge-episode",
      specification_version = "0.1.0"
    ),
    baseline_risk = list(
      specification_kind = "canonical_domain",
      specification_id = "platform.canonical-baseline-risk",
      specification_version = "0.1.0"
    ),
    episode_event = list(
      specification_kind = "canonical_domain",
      specification_id = "platform.canonical-episode-event",
      specification_version = "0.1.0"
    )
  )
}

rrp_clinical_vocabulary_identities <- function() {
  list(
    baseline_value_types = list(
      specification_kind = "canonical_vocabulary",
      specification_id = "platform.baseline-value-types",
      specification_version = "0.1.0"
    ),
    episode_event_types = list(
      specification_kind = "canonical_vocabulary",
      specification_id = "platform.episode-event-types",
      specification_version = "0.1.0"
    )
  )
}

rrp_baseline_value_types <- function() {
  c("probability", "numeric_score", "category")
}

rrp_episode_event_types <- function() {
  c(
    "care_transition_contact",
    "followup_visit",
    "emergency_department_visit",
    "medication_issue",
    "hospital_readmission",
    "death_notification"
  )
}

rrp_clinical_issue <- function(
  rule_id,
  issue_code,
  message,
  object_path = NA_character_,
  location = NA_character_,
  specification = rrp_clinical_profile_identity()
) {
  rrp_conformance_issue(
    rule_id, "error", issue_code, message, object_path, location, specification
  )
}

rrp_clinical_result <- function(candidate, issues, specification = NULL) {
  rrp_conformance_result(
    candidate,
    specification %||% rrp_clinical_profile_identity(),
    rrp_bind_rows(issues, rrp_empty_conformance_issues)
  )
}

rrp_clinical_domain_definitions <- function() {
  list(
    discharge_episode = list(
      primary_key = "episode_id",
      fields = list(
        episode_id = c(type = "string", required = "true", nullable = "false"),
        patient_id = c(type = "string", required = "true", nullable = "false"),
        index_encounter_id = c(type = "string", required = "true", nullable = "false"),
        admission_time = c(type = "timestamp", required = "true", nullable = "false"),
        discharge_time = c(type = "timestamp", required = "true", nullable = "false"),
        followup_window_end = c(type = "timestamp", required = "true", nullable = "false"),
        readmission_time = c(type = "timestamp", required = "false", nullable = "true"),
        death_time = c(type = "timestamp", required = "false", nullable = "true")
      )
    ),
    baseline_risk = list(
      primary_key = c(
        "episode_id", "source_model_id", "source_model_version", "score_time"
      ),
      fields = list(
        episode_id = c(type = "string", required = "true", nullable = "false"),
        source_model_id = c(type = "identifier", required = "true", nullable = "false"),
        source_model_version = c(type = "version", required = "true", nullable = "false"),
        score_time = c(type = "timestamp", required = "true", nullable = "false"),
        available_at = c(type = "timestamp", required = "true", nullable = "false"),
        value_type = c(type = "string", required = "true", nullable = "false"),
        probability = c(type = "number", required = "false", nullable = "true"),
        numeric_score = c(type = "number", required = "false", nullable = "true"),
        category = c(type = "string", required = "false", nullable = "true"),
        source_reference_id = c(type = "string", required = "false", nullable = "true")
      )
    ),
    episode_event = list(
      primary_key = "event_id",
      fields = list(
        event_id = c(type = "identifier", required = "true", nullable = "false"),
        episode_id = c(type = "string", required = "true", nullable = "false"),
        event_type = c(type = "string", required = "true", nullable = "false"),
        event_time = c(type = "timestamp", required = "true", nullable = "false"),
        available_at = c(type = "timestamp", required = "true", nullable = "false"),
        source_reference_id = c(type = "string", required = "false", nullable = "true")
      )
    )
  )
}

rrp_validate_clinical_domain_specification <- function(document, location) {
  issues <- list()
  domain_id <- document$domain_id %||% ""
  definitions <- rrp_clinical_domain_definitions()
  identities <- rrp_clinical_domain_identities()
  definition <- definitions[[domain_id]]
  identity <- identities[[domain_id]] %||% rrp_clinical_profile_identity()

  if (is.null(definition)) {
    issues[[1L]] <- rrp_clinical_issue(
      "clinical.domain.identity", "unsupported_clinical_domain",
      "The initial clinical profile does not support this domain ID.",
      "$.domain_id", location, identity
    )
    return(rrp_clinical_result(document, issues, identity))
  }
  reference <- rrp_validate_canonical_specification_reference(
    document,
    "$",
    location,
    expected_kind = identity$specification_kind,
    expected_id = identity$specification_id,
    supported_version = identity$specification_version
  )
  issues[[length(issues) + 1L]] <- reference$issues

  if (!identical(document$additional_fields_policy, "reject")) {
    issues[[length(issues) + 1L]] <- rrp_clinical_issue(
      "clinical.domain.additional_fields", "invalid_additional_fields_policy",
      "Initial clinical domain specifications must reject undeclared fields.",
      "$.additional_fields_policy", location, identity
    )
  }
  primary_key <- as.character(unlist(document$primary_key, use.names = FALSE))
  if (!identical(primary_key, definition$primary_key)) {
    issues[[length(issues) + 1L]] <- rrp_clinical_issue(
      "clinical.domain.primary_key", "invalid_domain_primary_key",
      "Domain primary key does not match the supported clinical contract.",
      "$.primary_key", location, identity
    )
  }

  observed_fields <- document$fields
  if (!rrp_is_named_mapping(observed_fields) ||
      !identical(names(observed_fields), names(definition$fields))) {
    issues[[length(issues) + 1L]] <- rrp_clinical_issue(
      "clinical.domain.fields", "invalid_domain_fields",
      "Declared fields and their order must match the supported clinical contract.",
      "$.fields", location, identity
    )
  } else {
    for (field_name in names(definition$fields)) {
      observed <- observed_fields[[field_name]]
      expected <- definition$fields[[field_name]]
      normalized <- c(
        type = as.character(observed$type %||% ""),
        required = tolower(as.character(observed$required %||% "")),
        nullable = tolower(as.character(observed$nullable %||% ""))
      )
      if (!identical(normalized, expected)) {
        issues[[length(issues) + 1L]] <- rrp_clinical_issue(
          "clinical.domain.fields", "invalid_domain_field_definition",
          paste0("Field definition is unsupported: ", field_name, "."),
          paste0("$.fields.", field_name), location, identity
        )
      }
    }
  }

  required_sections <- switch(
    domain_id,
    discharge_episode = c("temporal_rules", "ownership"),
    baseline_risk = c("relationships", "conditional_rules", "temporal_rules", "identity_note"),
    episode_event = c("relationships", "temporal_roles", "temporal_rules")
  )
  for (section in required_sections) {
    if (is.null(document[[section]])) {
      issues[[length(issues) + 1L]] <- rrp_clinical_issue(
        "clinical.domain.semantics", "missing_domain_semantic_section",
        paste0("Domain specification requires semantic section `", section, "`."),
        paste0("$.", section), location, identity
      )
    }
  }

  expected_rule_ids <- switch(
    domain_id,
    discharge_episode = c(
      "admission_precedes_discharge", "discharge_precedes_followup_end",
      "readmission_within_observation_window", "death_within_observation_window",
      "readmission_not_after_death"
    ),
    baseline_risk = c(
      "score_during_index_encounter", "availability_not_before_score",
      "availability_not_after_bundle_as_of"
    ),
    episode_event = c(
      "occurrence_within_episode_window", "availability_not_before_occurrence",
      "availability_not_after_bundle_as_of"
    )
  )
  observed_rule_ids <- vapply(document$temporal_rules %||% list(), function(rule) {
    if (rrp_is_named_mapping(rule)) rule$rule_id %||% NA_character_ else NA_character_
  }, character(1))
  if (!identical(observed_rule_ids, expected_rule_ids)) {
    issues[[length(issues) + 1L]] <- rrp_clinical_issue(
      "clinical.domain.temporal_rules", "invalid_domain_temporal_rules",
      "Domain temporal rules do not match the supported specification line.",
      "$.temporal_rules", location, identity
    )
  }

  if (domain_id %in% c("baseline_risk", "episode_event")) {
    relationship <- document$relationships[[1L]] %||% NULL
    valid_relationship <- rrp_is_named_mapping(relationship) &&
      identical(as.character(unlist(relationship$fields, use.names = FALSE)), "episode_id") &&
      identical(relationship$references_domain, "discharge_episode") &&
      identical(
        as.character(unlist(relationship$references_fields, use.names = FALSE)),
        "episode_id"
      )
    if (!valid_relationship) {
      issues[[length(issues) + 1L]] <- rrp_clinical_issue(
        "clinical.domain.relationship", "invalid_episode_relationship",
        "Child domain must declare episode_id to discharge_episode.episode_id.",
        "$.relationships", location, identity
      )
    }
  }
  if (identical(domain_id, "baseline_risk")) {
    expected_vocabulary <- rrp_clinical_vocabulary_identities()$baseline_value_types
    vocabulary <- document$fields$value_type$vocabulary_specification
    value_rule <- document$conditional_rules[[1L]] %||% NULL
    representations <- if (rrp_is_named_mapping(value_rule$representations)) {
      unlist(value_rule$representations, use.names = TRUE)
    } else {
      character()
    }
    expected_representations <- c(
      probability = "probability", numeric_score = "numeric_score", category = "category"
    )
    if (!rrp_is_named_mapping(vocabulary) ||
        !identical(vocabulary$specification_id, expected_vocabulary$specification_id) ||
        !identical(vocabulary$specification_version, expected_vocabulary$specification_version) ||
        !identical(representations, expected_representations) ||
        !isTRUE(all.equal(as.numeric(document$fields$probability$minimum), 0)) ||
        !isTRUE(all.equal(as.numeric(document$fields$probability$maximum), 1))) {
      issues[[length(issues) + 1L]] <- rrp_clinical_issue(
        "clinical.baseline.value_contract", "invalid_baseline_value_contract",
        "Baseline vocabulary, exact-one representations, and probability bounds must match.",
        "$.fields.value_type", location, identity
      )
    }
  }
  if (identical(domain_id, "episode_event")) {
    expected_vocabulary <- rrp_clinical_vocabulary_identities()$episode_event_types
    vocabulary <- document$fields$event_type$vocabulary_specification
    roles <- document$temporal_roles
    if (!rrp_is_named_mapping(vocabulary) ||
        !identical(vocabulary$specification_id, expected_vocabulary$specification_id) ||
        !identical(vocabulary$specification_version, expected_vocabulary$specification_version) ||
        !rrp_is_named_mapping(roles) ||
        !identical(roles$occurrence_field, "event_time") ||
        !identical(roles$availability_field, "available_at") ||
        !identical(roles$availability_order, "not_before_occurrence")) {
      issues[[length(issues) + 1L]] <- rrp_clinical_issue(
        "clinical.event.temporal_vocabulary", "invalid_event_temporal_vocabulary_contract",
        "Event vocabulary and occurrence/availability roles must match.",
        "$.temporal_roles", location, identity
      )
    }
  }

  rrp_clinical_result(document, issues, identity)
}

rrp_validate_clinical_vocabulary_specification <- function(document, location) {
  identities <- rrp_clinical_vocabulary_identities()
  expected <- if (identical(document$specification_id, identities$baseline_value_types$specification_id)) {
    list(identity = identities$baseline_value_types, values = rrp_baseline_value_types())
  } else if (identical(document$specification_id, identities$episode_event_types$specification_id)) {
    list(identity = identities$episode_event_types, values = rrp_episode_event_types())
  } else {
    NULL
  }
  if (is.null(expected)) {
    issue <- rrp_clinical_issue(
      "clinical.vocabulary.identity", "unsupported_clinical_vocabulary",
      "The initial clinical profile does not support this vocabulary.",
      "$.specification_id", location
    )
    return(rrp_clinical_result(document, list(issue)))
  }

  reference <- rrp_validate_canonical_specification_reference(
    document, "$", location,
    expected_kind = expected$identity$specification_kind,
    expected_id = expected$identity$specification_id,
    supported_version = expected$identity$specification_version
  )
  issues <- list(reference$issues)
  values <- document$values
  if (!rrp_is_named_mapping(values) || !identical(names(values), expected$values) ||
      any(!vapply(values, rrp_is_scalar_character, logical(1)))) {
    issues[[length(issues) + 1L]] <- rrp_clinical_issue(
      "clinical.vocabulary.values", "invalid_clinical_vocabulary_values",
      "Vocabulary values must exactly match the supported version.",
      "$.values", location, expected$identity
    )
  }
  if (!rrp_is_scalar_character(document$extension_policy)) {
    issues[[length(issues) + 1L]] <- rrp_clinical_issue(
      "clinical.vocabulary.extension", "missing_vocabulary_extension_policy",
      "Clinical vocabularies require an explicit extension policy.",
      "$.extension_policy", location, expected$identity
    )
  }
  rrp_clinical_result(document, issues, expected$identity)
}

rrp_clinical_profile_definitions <- function() {
  list(
    domains = list(
      discharge_episode = list(
        requirement_class = "required", capability_id = "platform.discharge-episode",
        row_cardinality = "one_or_more"
      ),
      baseline_risk = list(
        requirement_class = "optional", capability_id = "platform.baseline-risk-input",
        row_cardinality = "zero_or_more"
      ),
      episode_event = list(
        requirement_class = "optional", capability_id = "platform.episode-event-history",
        row_cardinality = "zero_or_more"
      )
    ),
    deferred_domains = c(
      "workflow_task", "intervention", "measure_membership", "feature_value"
    ),
    dependency_ids = c(
      "baseline-risk-requires-discharge-episode",
      "episode-event-requires-discharge-episode",
      "baseline-risk-capability-requires-episode-capability",
      "event-capability-requires-episode-capability"
    )
  )
}

rrp_validate_clinical_profile_specification <- function(document, location) {
  identity <- rrp_clinical_profile_identity()
  reference <- rrp_validate_canonical_specification_reference(
    document, "$", location,
    expected_kind = identity$specification_kind,
    expected_id = identity$specification_id,
    supported_version = identity$specification_version
  )
  issues <- list(reference$issues)
  bundle_reference <- rrp_validate_canonical_specification_reference(
    document$bundle_specification, "$.bundle_specification", location,
    expected_kind = "canonical_bundle",
    expected_id = "platform.canonical-bundle",
    supported_version = "0.1.0"
  )
  issues[[length(issues) + 1L]] <- bundle_reference$issues
  definitions <- rrp_clinical_profile_definitions()

  if (!rrp_is_sequence(document$domains)) {
    issues[[length(issues) + 1L]] <- rrp_clinical_issue(
      "clinical.profile.domains", "invalid_profile_domains",
      "Clinical profile domains must be a sequence.", "$.domains", location
    )
  } else {
    observed_ids <- rrp_registration_ids(document$domains, "domain_id")
    if (!setequal(observed_ids, names(definitions$domains))) {
      issues[[length(issues) + 1L]] <- rrp_clinical_issue(
        "clinical.profile.domains", "invalid_profile_domain_set",
        "Clinical profile must declare exactly the three initial domains.",
        "$.domains", location
      )
    }
    identities <- rrp_clinical_domain_identities()
    for (domain in document$domains) {
      if (!rrp_is_named_mapping(domain) || is.null(definitions$domains[[domain$domain_id]])) next
      expected <- definitions$domains[[domain$domain_id]]
      if (!identical(domain$requirement_class, expected$requirement_class) ||
          !identical(domain$capability_id, expected$capability_id) ||
          !identical(domain$row_cardinality, expected$row_cardinality)) {
        issues[[length(issues) + 1L]] <- rrp_clinical_issue(
          "clinical.profile.domain_semantics", "invalid_profile_domain_semantics",
          paste0("Profile semantics do not match domain `", domain$domain_id, "`."),
          "$.domains", location
        )
      }
      result <- rrp_validate_canonical_specification_reference(
        domain$domain_specification, "$.domains.domain_specification", location,
        expected_kind = "canonical_domain",
        expected_id = identities[[domain$domain_id]]$specification_id,
        supported_version = identities[[domain$domain_id]]$specification_version
      )
      issues[[length(issues) + 1L]] <- result$issues
    }
  }

  if (!rrp_is_sequence(document$capabilities)) {
    issues[[length(issues) + 1L]] <- rrp_clinical_issue(
      "clinical.profile.capabilities", "invalid_profile_capabilities",
      "Clinical profile capabilities must be a sequence.",
      "$.capabilities", location
    )
  } else {
    observed_capability_ids <- rrp_registration_ids(
      document$capabilities, "capability_id"
    )
    expected_capability_ids <- vapply(
      definitions$domains, `[[`, character(1), "capability_id"
    )
    if (!setequal(observed_capability_ids, expected_capability_ids)) {
      issues[[length(issues) + 1L]] <- rrp_clinical_issue(
        "clinical.profile.capabilities", "invalid_profile_capability_set",
        "Clinical profile must declare exactly one capability for each domain.",
        "$.capabilities", location
      )
    }
    for (capability in document$capabilities) {
      if (!rrp_is_named_mapping(capability)) next
      matching_domain <- names(definitions$domains)[vapply(
        definitions$domains,
        function(definition) identical(definition$capability_id, capability$capability_id),
        logical(1)
      )][1L]
      if (is.na(matching_domain)) next
      expected <- definitions$domains[[matching_domain]]
      if (!identical(capability$requirement_class, expected$requirement_class) ||
          !identical(capability$domain_id, matching_domain)) {
        issues[[length(issues) + 1L]] <- rrp_clinical_issue(
          "clinical.profile.capabilities", "invalid_profile_capability_semantics",
          paste0("Capability does not match its profile domain: ", capability$capability_id, "."),
          "$.capabilities", location
        )
      }
    }
  }

  observed_dependencies <- vapply(document$dependencies %||% list(), function(item) {
    if (rrp_is_named_mapping(item)) item$dependency_id %||% NA_character_ else NA_character_
  }, character(1))
  if (!setequal(observed_dependencies, definitions$dependency_ids)) {
    issues[[length(issues) + 1L]] <- rrp_clinical_issue(
      "clinical.profile.dependencies", "invalid_profile_dependencies",
      "Profile dependencies must match the supported child-to-root relationships.",
      "$.dependencies", location
    )
  }
  deferred <- as.character(unlist(document$deferred_domains, use.names = FALSE))
  if (!identical(deferred, definitions$deferred_domains)) {
    issues[[length(issues) + 1L]] <- rrp_clinical_issue(
      "clinical.profile.deferred_domains", "invalid_deferred_domain_set",
      "The initial profile must explicitly defer the four later canonical domains.",
      "$.deferred_domains", location
    )
  }
  if (!rrp_is_named_mapping(document$capability_and_cardinality_semantics)) {
    issues[[length(issues) + 1L]] <- rrp_clinical_issue(
      "clinical.profile.cardinality", "missing_capability_cardinality_semantics",
      "Profile must distinguish availability from row cardinality.",
      "$.capability_and_cardinality_semantics", location
    )
  }
  rrp_clinical_result(document, issues, identity)
}

rrp_clinical_value_conforms_to_type <- function(value, type) {
  switch(
    type,
    string = rrp_is_scalar_character(value),
    identifier = rrp_is_identifier(value),
    version = rrp_is_semver(value),
    timestamp = rrp_is_rfc3339_timestamp(value),
    number = is.numeric(value) && length(value) == 1L && !is.na(value) && is.finite(value),
    FALSE
  )
}

rrp_validate_clinical_records <- function(records, specification, path, location) {
  issues <- list()
  if (!rrp_is_sequence(records)) {
    issue <- rrp_clinical_issue(
      "clinical.domain.records", "invalid_domain_records",
      "Domain records must be a sequence.", path, location, specification
    )
    return(rrp_clinical_result(records, list(issue), specification))
  }
  definitions <- rrp_clinical_domain_definitions()
  domain_id <- names(rrp_clinical_domain_identities())[vapply(
    rrp_clinical_domain_identities(),
    function(identity) identical(identity$specification_id, specification$specification_id),
    logical(1)
  )][1L]
  definition <- definitions[[domain_id]]
  keys <- character()

  for (index in seq_along(records)) {
    record <- records[[index]]
    record_path <- paste0(path, "[", index, "]")
    if (!rrp_is_named_mapping(record)) {
      issues[[length(issues) + 1L]] <- rrp_clinical_issue(
        "clinical.domain.record", "invalid_domain_record",
        "Each domain record must be a named mapping.", record_path, location, specification
      )
      next
    }
    unknown <- setdiff(names(record), names(definition$fields))
    for (field in unknown) {
      issues[[length(issues) + 1L]] <- rrp_clinical_issue(
        "clinical.domain.additional_fields", "unknown_domain_field",
        paste0("Undeclared canonical field is not permitted: ", field, "."),
        paste0(record_path, ".", field), location, specification
      )
    }
    for (field in names(definition$fields)) {
      descriptor <- definition$fields[[field]]
      required <- identical(descriptor[["required"]], "true")
      nullable <- identical(descriptor[["nullable"]], "true")
      present <- field %in% names(record)
      value <- if (present) record[[field]] else NULL
      if (required && !present) {
        issues[[length(issues) + 1L]] <- rrp_clinical_issue(
          "clinical.domain.required", "missing_required_field",
          paste0("Required field is missing: ", field, "."),
          paste0(record_path, ".", field), location, specification
        )
      } else if (present && is.null(value) && !nullable) {
        issues[[length(issues) + 1L]] <- rrp_clinical_issue(
          "clinical.domain.nullability", "null_required_field",
          paste0("Required field may not be null: ", field, "."),
          paste0(record_path, ".", field), location, specification
        )
      } else if (present && !is.null(value) &&
                 !rrp_clinical_value_conforms_to_type(value, descriptor[["type"]])) {
        issues[[length(issues) + 1L]] <- rrp_clinical_issue(
          "clinical.domain.type", "invalid_field_type",
          paste0("Field `", field, "` does not match type `", descriptor[["type"]], "`."),
          paste0(record_path, ".", field), location, specification
        )
      }
    }
    if (all(definition$primary_key %in% names(record)) &&
        all(vapply(record[definition$primary_key], Negate(is.null), logical(1)))) {
      keys <- c(keys, paste(unlist(record[definition$primary_key]), collapse = "\u001f"))
    } else {
      keys <- c(keys, NA_character_)
    }
  }
  duplicate_keys <- unique(keys[!is.na(keys) & duplicated(keys)])
  for (key in duplicate_keys) {
    issues[[length(issues) + 1L]] <- rrp_clinical_issue(
      "clinical.domain.primary_key", "duplicate_primary_key",
      paste0("Domain primary key is duplicated: ", key, "."),
      path, location, specification
    )
  }
  rrp_clinical_result(records, issues, specification)
}

rrp_clinical_registration <- function(bundle, type, id) {
  items <- bundle[[type]] %||% list()
  field <- if (identical(type, "domains")) "domain_id" else "capability_id"
  ids <- rrp_registration_ids(items, field)
  index <- match(id, ids)
  if (is.na(index)) NULL else items[[index]]
}

rrp_clinical_payload <- function(bundle, domain_id) {
  domain <- rrp_clinical_registration(bundle, "domains", domain_id)
  if (is.null(domain) || is.null(domain$domain_instance_id)) return(NULL)
  payloads <- bundle$reference_test_realization$domain_payloads %||% list()
  matches <- Filter(function(payload) {
    rrp_is_named_mapping(payload) &&
      identical(payload$domain_instance_id, domain$domain_instance_id)
  }, payloads)
  if (length(matches) == 1L) matches[[1L]] else NULL
}

rrp_validate_clinical_profile_registration <- function(bundle, location) {
  issues <- list()
  profile_reference <- rrp_validate_canonical_specification_reference(
    bundle$profile_specification,
    "$.bundle_instance.profile_specification",
    location,
    expected_kind = "canonical_profile",
    expected_id = "platform.readmission-initial-profile",
    supported_version = "0.1.0"
  )
  issues[[length(issues) + 1L]] <- profile_reference$issues
  definitions <- rrp_clinical_profile_definitions()
  identities <- rrp_clinical_domain_identities()

  domain_ids <- rrp_registration_ids(bundle$domains %||% list(), "domain_id")
  if (!"discharge_episode" %in% domain_ids) {
    issues[[length(issues) + 1L]] <- rrp_clinical_issue(
      "clinical.profile.required_root", "missing_required_root_domain",
      "Initial clinical profile requires the discharge episode root domain.",
      "$.bundle_instance.domains", location
    )
  }
  for (id in setdiff(domain_ids[!is.na(domain_ids)], names(definitions$domains))) {
    issues[[length(issues) + 1L]] <- rrp_clinical_issue(
      "clinical.profile.domain_set", "unexpected_profile_domain",
      paste0("Domain is outside the initial clinical profile: ", id, "."),
      "$.bundle_instance.domains", location
    )
  }
  for (id in names(definitions$domains)) {
    domain <- rrp_clinical_registration(bundle, "domains", id)
    if (is.null(domain)) {
      issues[[length(issues) + 1L]] <- rrp_clinical_issue(
        "clinical.profile.domain_declaration", "missing_profile_domain_declaration",
        paste0("Profile bundle must explicitly declare domain status: ", id, "."),
        "$.bundle_instance.domains", location
      )
      next
    }
    expected <- definitions$domains[[id]]
    if (!identical(domain$requirement_class, expected$requirement_class)) {
      issues[[length(issues) + 1L]] <- rrp_clinical_issue(
        "clinical.profile.requirement", "profile_requirement_mismatch",
        paste0("Domain requirement class does not match profile: ", id, "."),
        "$.bundle_instance.domains", location
      )
    }
    reference <- rrp_validate_canonical_specification_reference(
      domain$domain_specification, "$.bundle_instance.domains.domain_specification", location,
      expected_kind = "canonical_domain",
      expected_id = identities[[id]]$specification_id,
      supported_version = identities[[id]]$specification_version
    )
    issues[[length(issues) + 1L]] <- reference$issues

    capability <- rrp_clinical_registration(bundle, "capabilities", expected$capability_id)
    if (is.null(capability)) {
      issues[[length(issues) + 1L]] <- rrp_clinical_issue(
        "clinical.profile.capability", "missing_profile_capability_declaration",
        paste0("Profile bundle must declare capability: ", expected$capability_id, "."),
        "$.bundle_instance.capabilities", location
      )
    } else {
      if (!identical(capability$requirement_class, expected$requirement_class)) {
        issues[[length(issues) + 1L]] <- rrp_clinical_issue(
          "clinical.profile.requirement", "profile_requirement_mismatch",
          paste0("Capability requirement class does not match profile: ", expected$capability_id, "."),
          "$.bundle_instance.capabilities", location
        )
      }
      if (!identical(capability$status, domain$status)) {
        issues[[length(issues) + 1L]] <- rrp_clinical_issue(
          "clinical.profile.capability_status", "capability_domain_status_mismatch",
          paste0("One-to-one domain and capability statuses disagree for: ", id, "."),
          "$.bundle_instance.capabilities", location
        )
      }
    }

    payload <- rrp_clinical_payload(bundle, id)
    if (identical(domain$status, "available") && is.null(payload)) {
      issues[[length(issues) + 1L]] <- rrp_clinical_issue(
        "clinical.profile.instance_presence", "available_domain_missing_payload",
        paste0("Available domain requires a supplied payload, including when it has zero rows: ", id, "."),
        "$.bundle_instance.reference_test_realization", location
      )
    }
    if (identical(id, "discharge_episode") && !is.null(payload) &&
        rrp_is_sequence(payload$records) && length(payload$records) == 0L) {
      issues[[length(issues) + 1L]] <- rrp_clinical_issue(
        "clinical.profile.root_cardinality", "empty_required_root_domain",
        "Discharge episode domain must contain at least one root record.",
        "$.bundle_instance.reference_test_realization", location
      )
    }
  }

  declared_dependencies <- vapply(bundle$dependencies %||% list(), function(item) {
    if (rrp_is_named_mapping(item)) item$dependency_id %||% NA_character_ else NA_character_
  }, character(1))
  for (id in setdiff(definitions$dependency_ids, declared_dependencies)) {
    issues[[length(issues) + 1L]] <- rrp_clinical_issue(
      "clinical.profile.dependencies", "missing_profile_dependency",
      paste0("Profile dependency is missing: ", id, "."),
      "$.bundle_instance.dependencies", location
    )
  }
  rrp_clinical_result(bundle, issues)
}

rrp_validate_discharge_episode_semantics <- function(records, path, location) {
  issues <- list()
  identity <- rrp_clinical_domain_identities()$discharge_episode
  for (index in seq_along(records)) {
    record <- records[[index]]
    if (!rrp_is_named_mapping(record)) next
    record_path <- paste0(path, "[", index, "]")
    timestamp <- function(field) {
      value <- record[[field]]
      if (rrp_is_rfc3339_timestamp(value)) rrp_timestamp_number(value) else NA_real_
    }
    admission <- timestamp("admission_time")
    discharge <- timestamp("discharge_time")
    window_end <- timestamp("followup_window_end")
    if (!is.na(admission) && !is.na(discharge) && admission >= discharge) {
      issues[[length(issues) + 1L]] <- rrp_clinical_issue(
        "clinical.episode.admission_discharge", "admission_not_before_discharge",
        "Admission time must be strictly before discharge time.",
        paste0(record_path, ".admission_time"), location, identity
      )
    }
    if (!is.na(discharge) && !is.na(window_end) && discharge >= window_end) {
      issues[[length(issues) + 1L]] <- rrp_clinical_issue(
        "clinical.episode.observation_window", "followup_not_after_discharge",
        "Follow-up window end must be strictly after discharge time.",
        paste0(record_path, ".followup_window_end"), location, identity
      )
    }
    terminal_values <- c(readmission_time = timestamp("readmission_time"), death_time = timestamp("death_time"))
    for (field in names(terminal_values)) {
      value <- terminal_values[[field]]
      if (!is.na(value) && !is.na(discharge) && !is.na(window_end) &&
          (value <= discharge || value > window_end)) {
        issues[[length(issues) + 1L]] <- rrp_clinical_issue(
          "clinical.episode.terminal_window", "terminal_outside_observation_window",
          paste0("Terminal field `", field, "` must be after discharge and within the follow-up window."),
          paste0(record_path, ".", field), location, identity
        )
      }
    }
    readmission <- terminal_values[["readmission_time"]]
    death <- terminal_values[["death_time"]]
    if (!is.na(readmission) && !is.na(death) && readmission > death) {
      issues[[length(issues) + 1L]] <- rrp_clinical_issue(
        "clinical.episode.terminal_order", "readmission_after_death",
        "A readmission terminal time may not occur after death.",
        paste0(record_path, ".readmission_time"), location, identity
      )
    }
  }
  rrp_clinical_result(records, issues, identity)
}

rrp_validate_baseline_risk_semantics <- function(records, episodes, path, location) {
  issues <- list()
  identity <- rrp_clinical_domain_identities()$baseline_risk
  episode_ids <- vapply(episodes, function(record) {
    if (rrp_is_named_mapping(record)) record$episode_id %||% NA_character_ else NA_character_
  }, character(1))
  for (index in seq_along(records)) {
    record <- records[[index]]
    if (!rrp_is_named_mapping(record)) next
    record_path <- paste0(path, "[", index, "]")
    if (!rrp_is_identifier(record$source_model_id) || !rrp_is_semver(record$source_model_version)) {
      issues[[length(issues) + 1L]] <- rrp_clinical_issue(
        "clinical.baseline.source_identity", "invalid_source_model_identity",
        "Baseline source model requires a logical identifier and semantic version.",
        record_path, location, identity
      )
    }
    value_type <- record$value_type %||% ""
    representations <- c(probability = "probability", numeric_score = "numeric_score", category = "category")
    populated <- names(representations)[vapply(representations, function(field) {
      field %in% names(record) && !is.null(record[[field]])
    }, logical(1))]
    if (!value_type %in% rrp_baseline_value_types() ||
        length(populated) != 1L || !identical(populated, value_type)) {
      issues[[length(issues) + 1L]] <- rrp_clinical_issue(
        "clinical.baseline.value_representation", "missing_or_conflicting_baseline_value",
        "Exactly one value representation must be populated and match value_type.",
        record_path, location, identity
      )
    }
    probability <- record$probability
    if (!is.null(probability) && is.numeric(probability) && length(probability) == 1L &&
        !is.na(probability) && (probability < 0 || probability > 1)) {
      issues[[length(issues) + 1L]] <- rrp_clinical_issue(
        "clinical.baseline.probability", "invalid_probability_bound",
        "Baseline probability must be between zero and one inclusive.",
        paste0(record_path, ".probability"), location, identity
      )
    }
    episode_index <- match(record$episode_id %||% NA_character_, episode_ids)
    if (is.na(episode_index)) {
      issues[[length(issues) + 1L]] <- rrp_clinical_issue(
        "clinical.baseline.episode_foreign_key", "unresolved_baseline_episode_id",
        "Baseline risk episode_id must resolve to a discharge episode.",
        paste0(record_path, ".episode_id"), location, identity
      )
    } else {
      episode <- episodes[[episode_index]]
      score <- if (rrp_is_rfc3339_timestamp(record$score_time)) rrp_timestamp_number(record$score_time) else NA_real_
      admission <- if (rrp_is_rfc3339_timestamp(episode$admission_time)) rrp_timestamp_number(episode$admission_time) else NA_real_
      discharge <- if (rrp_is_rfc3339_timestamp(episode$discharge_time)) rrp_timestamp_number(episode$discharge_time) else NA_real_
      if (!anyNA(c(score, admission, discharge)) && (score < admission || score > discharge)) {
        issues[[length(issues) + 1L]] <- rrp_clinical_issue(
          "clinical.baseline.score_time", "score_outside_index_encounter",
          "Baseline score_time must fall within the index encounter through discharge.",
          paste0(record_path, ".score_time"), location, identity
        )
      }
    }
  }
  rrp_clinical_result(records, issues, identity)
}

rrp_validate_episode_event_semantics <- function(records, episodes, path, location) {
  issues <- list()
  identity <- rrp_clinical_domain_identities()$episode_event
  episode_ids <- vapply(episodes, function(record) {
    if (rrp_is_named_mapping(record)) record$episode_id %||% NA_character_ else NA_character_
  }, character(1))
  for (index in seq_along(records)) {
    record <- records[[index]]
    if (!rrp_is_named_mapping(record)) next
    record_path <- paste0(path, "[", index, "]")
    if (rrp_is_scalar_character(record$event_type) &&
        !record$event_type %in% rrp_episode_event_types()) {
      issues[[length(issues) + 1L]] <- rrp_clinical_issue(
        "clinical.event.type", "unknown_event_type",
        "Episode event type is not in the supported vocabulary.",
        paste0(record_path, ".event_type"), location, identity
      )
    }
    episode_index <- match(record$episode_id %||% NA_character_, episode_ids)
    if (is.na(episode_index)) {
      issues[[length(issues) + 1L]] <- rrp_clinical_issue(
        "clinical.event.episode_foreign_key", "unresolved_event_episode_id",
        "Episode event episode_id must resolve to a discharge episode.",
        paste0(record_path, ".episode_id"), location, identity
      )
    } else {
      episode <- episodes[[episode_index]]
      event <- if (rrp_is_rfc3339_timestamp(record$event_time)) rrp_timestamp_number(record$event_time) else NA_real_
      discharge <- if (rrp_is_rfc3339_timestamp(episode$discharge_time)) rrp_timestamp_number(episode$discharge_time) else NA_real_
      window_end <- if (rrp_is_rfc3339_timestamp(episode$followup_window_end)) rrp_timestamp_number(episode$followup_window_end) else NA_real_
      if (!anyNA(c(event, discharge, window_end)) && (event < discharge || event > window_end)) {
        issues[[length(issues) + 1L]] <- rrp_clinical_issue(
          "clinical.event.episode_window", "event_outside_episode_window",
          "Episode event occurrence must be within discharge through follow-up end.",
          paste0(record_path, ".event_time"), location, identity
        )
      }
    }
  }
  rrp_clinical_result(records, issues, identity)
}

rrp_validate_clinical_bundle_instance <- function(bundle, repository_root, location = NA_character_) {
  issues <- list()
  generic <- rrp_validate_canonical_bundle_instance(bundle, location)
  issues[[length(issues) + 1L]] <- generic$issues
  profile <- rrp_validate_clinical_profile_registration(bundle, location)
  issues[[length(issues) + 1L]] <- profile$issues
  domain_identities <- rrp_clinical_domain_identities()
  payloads <- lapply(names(domain_identities), function(id) rrp_clinical_payload(bundle, id))
  names(payloads) <- names(domain_identities)

  for (id in names(payloads)) {
    payload <- payloads[[id]]
    if (is.null(payload)) next
    path <- paste0("$.bundle_instance.reference_test_realization.", id, ".records")
    structural <- rrp_validate_clinical_records(
      payload$records, domain_identities[[id]], path, location
    )
    issues[[length(issues) + 1L]] <- structural$issues
  }

  episodes <- payloads$discharge_episode$records %||% list()
  if (rrp_is_sequence(episodes)) {
    semantic <- rrp_validate_discharge_episode_semantics(
      episodes,
      "$.bundle_instance.reference_test_realization.discharge_episode.records",
      location
    )
    issues[[length(issues) + 1L]] <- semantic$issues
  }
  baselines <- payloads$baseline_risk$records %||% list()
  if (rrp_is_sequence(baselines) && rrp_is_sequence(episodes)) {
    semantic <- rrp_validate_baseline_risk_semantics(
      baselines, episodes,
      "$.bundle_instance.reference_test_realization.baseline_risk.records",
      location
    )
    issues[[length(issues) + 1L]] <- semantic$issues
  }
  events <- payloads$episode_event$records %||% list()
  if (rrp_is_sequence(events) && rrp_is_sequence(episodes)) {
    semantic <- rrp_validate_episode_event_semantics(
      events, episodes,
      "$.bundle_instance.reference_test_realization.episode_event.records",
      location
    )
    issues[[length(issues) + 1L]] <- semantic$issues
  }
  rrp_clinical_result(bundle, issues)
}

rrp_validate_clinical_fixture_document <- function(document, repository_root, location) {
  issues <- list()
  expectation <- document$expected_conformance
  if (!rrp_is_named_mapping(expectation) ||
      !rrp_is_scalar_character(document$data_classification) ||
      !grepl("fictional|nonclinical|synthetic", document$data_classification)) {
    issues[[1L]] <- rrp_clinical_issue(
      "clinical.fixture.metadata", "invalid_clinical_fixture_metadata",
      "Clinical fixture requires expected conformance and visible fictional classification.",
      "$", location
    )
    return(rrp_clinical_result(document, issues))
  }
  bundle_result <- rrp_validate_clinical_bundle_instance(
    document$bundle_instance, repository_root, location
  )
  expected_codes <- sort(unique(as.character(unlist(expectation$issue_codes, use.names = FALSE))))
  observed_codes <- sort(unique(as.character(bundle_result$issues$issue_code)))
  if (!identical(bundle_result$overall_status, expectation$overall_status)) {
    issues[[length(issues) + 1L]] <- rrp_clinical_issue(
      "clinical.fixture.expectation", "unexpected_clinical_fixture_status",
      "Clinical fixture status does not match its expected conformance.",
      "$.expected_conformance.overall_status", location
    )
  }
  if (!identical(expected_codes, observed_codes)) {
    issues[[length(issues) + 1L]] <- rrp_clinical_issue(
      "clinical.fixture.expectation", "unexpected_clinical_fixture_issue_codes",
      paste0("Expected [", paste(expected_codes, collapse = ", "), "]; observed [",
             paste(observed_codes, collapse = ", "), "]."),
      "$.expected_conformance.issue_codes", location
    )
  }
  result <- rrp_clinical_result(document, issues)
  attr(result, "bundle_result") <- bundle_result
  result
}
