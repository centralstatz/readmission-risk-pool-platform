# Source-local conformance. Canonical validation is deliberately not used here.

rrp_validate_synthetic_source_schema_specification <- function(
  schema,
  location = NA_character_
) {
  identity <- rrp_synthetic_source_schema_identity()
  issues <- list()
  support <- rrp_validate_specification_support(
    schema,
    identity$specification_kind,
    identity$specification_id,
    identity$specification_version
  )
  issues[[length(issues) + 1L]] <- support$issues
  expected_tables <- c(
    "patients", "encounters", "discharges", "risk_scores",
    "activity_events", "outcomes"
  )
  if (!rrp_is_named_mapping(schema$tables) ||
      !identical(names(schema$tables), expected_tables)) {
    issues[[length(issues) + 1L]] <- rrp_synthetic_issue(
      "synthetic.source_schema.tables", "invalid_synthetic_source_tables",
      "Source schema must declare exactly the six implementation-owned tables.",
      "$.tables", location, identity
    )
  }
  if (!identical(schema$additional_fields_policy, "reject") ||
      !identical(schema$data_classification, "fictional_nonclinical")) {
    issues[[length(issues) + 1L]] <- rrp_synthetic_issue(
      "synthetic.source_schema.policy", "invalid_source_schema_policy",
      "Source schema must be visibly fictional and reject undeclared fields.",
      "$", location, identity
    )
  }
  required_vocabularies <- c(
    "encounter_class", "score_code", "event_code", "outcome_code"
  )
  if (!rrp_is_named_mapping(schema$controlled_values) ||
      !identical(names(schema$controlled_values), required_vocabularies)) {
    issues[[length(issues) + 1L]] <- rrp_synthetic_issue(
      "synthetic.source_schema.vocabulary", "invalid_source_vocabularies",
      "Source schema controlled vocabularies do not match the supported line.",
      "$.controlled_values", location, identity
    )
  }
  rrp_synthetic_result(schema, issues, identity)
}

rrp_synthetic_source_value_has_type <- function(value, type) {
  switch(
    type,
    character = is.character(value),
    integer = is.integer(value),
    numeric = is.numeric(value),
    timestamp = is.character(value) && all(vapply(
      value, rrp_is_rfc3339_timestamp, logical(1)
    )),
    FALSE
  )
}

rrp_synthetic_source_issue <- function(
  rule_id,
  issue_code,
  message,
  object_path,
  location
) {
  rrp_synthetic_issue(
    rule_id, issue_code, message, object_path, location,
    rrp_synthetic_source_schema_identity()
  )
}

rrp_validate_synthetic_source_tables <- function(source, schema, location) {
  issues <- list()
  expected_tables <- names(schema$tables)
  if (!is.list(source) || is.null(names(source))) {
    issue <- rrp_synthetic_source_issue(
      "synthetic.source.structure", "invalid_synthetic_source",
      "Synthetic source must be a named collection of source tables.", "$", location
    )
    return(rrp_synthetic_result(
      source, list(issue), rrp_synthetic_source_schema_identity()
    ))
  }
  missing_tables <- setdiff(expected_tables, names(source))
  unknown_tables <- setdiff(names(source), expected_tables)
  for (table in missing_tables) {
    issues[[length(issues) + 1L]] <- rrp_synthetic_source_issue(
      "synthetic.source.required_tables", "missing_source_table",
      paste0("Required source table is missing: ", table, "."),
      paste0("$.", table), location
    )
  }
  for (table in unknown_tables) {
    issues[[length(issues) + 1L]] <- rrp_synthetic_source_issue(
      "synthetic.source.additional_tables", "unknown_source_table",
      paste0("Undeclared source table is not permitted: ", table, "."),
      paste0("$.", table), location
    )
  }

  for (table in intersect(expected_tables, names(source))) {
    data <- source[[table]]
    table_schema <- schema$tables[[table]]
    table_path <- paste0("$.", table)
    if (!is.data.frame(data)) {
      issues[[length(issues) + 1L]] <- rrp_synthetic_source_issue(
        "synthetic.source.table_type", "source_table_not_data_frame",
        paste0("Source table must be a data frame: ", table, "."),
        table_path, location
      )
      next
    }
    declared_fields <- names(table_schema$fields)
    for (field in setdiff(declared_fields, names(data))) {
      issues[[length(issues) + 1L]] <- rrp_synthetic_source_issue(
        "synthetic.source.required_fields", "missing_source_field",
        paste0("Required source field is missing: ", table, ".", field, "."),
        paste0(table_path, ".", field), location
      )
    }
    for (field in setdiff(names(data), declared_fields)) {
      issues[[length(issues) + 1L]] <- rrp_synthetic_source_issue(
        "synthetic.source.additional_fields", "unknown_source_field",
        paste0("Undeclared source field is not permitted: ", table, ".", field, "."),
        paste0(table_path, ".", field), location
      )
    }
    for (field in intersect(declared_fields, names(data))) {
      descriptor <- table_schema$fields[[field]]
      value <- data[[field]]
      if (!rrp_synthetic_source_value_has_type(value, descriptor$type)) {
        issues[[length(issues) + 1L]] <- rrp_synthetic_source_issue(
          "synthetic.source.field_type", "invalid_source_field_type",
          paste0("Source field has invalid type: ", table, ".", field, "."),
          paste0(table_path, ".", field), location
        )
      }
      if (!isTRUE(descriptor$nullable) && anyNA(value)) {
        issues[[length(issues) + 1L]] <- rrp_synthetic_source_issue(
          "synthetic.source.nullability", "null_source_value",
          paste0("Source field may not contain missing values: ", table, ".", field, "."),
          paste0(table_path, ".", field), location
        )
      }
    }
    key <- table_schema$primary_key
    if (rrp_is_scalar_character(key) && key %in% names(data) &&
        any(duplicated(data[[key]]) | is.na(data[[key]]))) {
      issues[[length(issues) + 1L]] <- rrp_synthetic_source_issue(
        "synthetic.source.primary_key", "duplicate_or_missing_source_id",
        paste0("Source primary key must be populated and unique: ", table, ".", key, "."),
        paste0(table_path, ".", key), location
      )
    }
  }
  rrp_synthetic_result(source, issues, rrp_synthetic_source_schema_identity())
}

rrp_validate_synthetic_source_relationships <- function(source, schema, location) {
  issues <- list()
  if (!all(names(schema$tables) %in% names(source)) ||
      any(!vapply(source[names(schema$tables)], is.data.frame, logical(1)))) {
    return(rrp_synthetic_result(
      source, issues, rrp_synthetic_source_schema_identity()
    ))
  }
  for (relationship in schema$relationships) {
    fields_present <- relationship$child_field %in%
      names(source[[relationship$child_table]]) &&
      relationship$parent_field %in% names(source[[relationship$parent_table]])
    if (!fields_present) next
    child <- source[[relationship$child_table]][[relationship$child_field]]
    parent <- source[[relationship$parent_table]][[relationship$parent_field]]
    unresolved <- unique(child[!is.na(child) & !child %in% parent])
    if (length(unresolved) > 0L) {
      issues[[length(issues) + 1L]] <- rrp_synthetic_source_issue(
        "synthetic.source.foreign_key", "unresolved_source_foreign_key",
        paste0(
          relationship$child_table, ".", relationship$child_field,
          " contains ", length(unresolved), " unresolved value(s)."
        ),
        paste0("$.", relationship$child_table, ".", relationship$child_field),
        location
      )
    }
  }
  rrp_synthetic_result(source, issues, rrp_synthetic_source_schema_identity())
}

rrp_synthetic_source_times <- function(values) {
  if (!is.character(values) ||
      any(!vapply(values, rrp_is_rfc3339_timestamp, logical(1)))) {
    return(rep.int(NA_real_, length(values)))
  }
  rrp_timestamp_number(values)
}

rrp_validate_synthetic_source_semantics <- function(source, schema, location) {
  issues <- list()
  required <- names(schema$tables)
  if (!all(required %in% names(source)) ||
      any(!vapply(source[required], is.data.frame, logical(1)))) {
    return(rrp_synthetic_result(
      source, issues, rrp_synthetic_source_schema_identity()
    ))
  }
  fields_complete <- all(vapply(required, function(table) {
    all(names(schema$tables[[table]]$fields) %in% names(source[[table]]))
  }, logical(1)))
  if (!fields_complete) {
    return(rrp_synthetic_result(
      source, issues, rrp_synthetic_source_schema_identity()
    ))
  }
  add_issue <- function(rule_id, code, message, path) {
    issues[[length(issues) + 1L]] <<- rrp_synthetic_source_issue(
      rule_id, code, message, path, location
    )
  }

  for (definition in list(
    list(table = "encounters", field = "encounter_class"),
    list(table = "risk_scores", field = "score_code"),
    list(table = "activity_events", field = "event_code"),
    list(table = "outcomes", field = "outcome_code")
  )) {
    values <- source[[definition$table]][[definition$field]]
    allowed <- as.character(unlist(
      schema$controlled_values[[definition$field]], use.names = FALSE
    ))
    if (any(!is.na(values) & !values %in% allowed)) {
      add_issue(
        "synthetic.source.controlled_value", "invalid_source_code",
        paste0("Source code is outside the controlled vocabulary: ", definition$field, "."),
        paste0("$.", definition$table, ".", definition$field)
      )
    }
  }

  encounters <- source$encounters
  admitted <- rrp_synthetic_source_times(encounters$admitted_at)
  discharged <- rrp_synthetic_source_times(encounters$discharged_at)
  if (any(!is.na(admitted) & !is.na(discharged) & admitted >= discharged)) {
    add_issue(
      "synthetic.source.encounter_time", "invalid_source_encounter_time",
      "Source encounter admission must be strictly before discharge.",
      "$.encounters.admitted_at"
    )
  }

  discharges <- source$discharges
  discharge_encounter_index <- match(discharges$encounter_key, encounters$encounter_key)
  resolved_discharge <- !is.na(discharge_encounter_index)
  if (any(resolved_discharge &
          encounters$encounter_class[discharge_encounter_index] != "index_inpatient")) {
    add_issue(
      "synthetic.source.discharge_relationship", "discharge_not_index_encounter",
      "Every source discharge must resolve to an index inpatient encounter.",
      "$.discharges.encounter_key"
    )
  }
  index_admission <- admitted[discharge_encounter_index]
  index_discharge <- discharged[discharge_encounter_index]
  names(index_admission) <- discharges$discharge_key
  names(index_discharge) <- discharges$discharge_key
  window_end <- index_discharge + discharges$followup_days * 86400
  names(window_end) <- discharges$discharge_key

  scores <- source$risk_scores
  score_discharge <- match(scores$discharge_key, discharges$discharge_key)
  score_time <- rrp_synthetic_source_times(scores$assessed_at)
  score_received <- rrp_synthetic_source_times(scores$received_at)
  if (any(!is.na(score_time) & !is.na(score_received) & score_received < score_time)) {
    add_issue(
      "synthetic.source.risk_availability", "source_risk_received_before_assessed",
      "Source risk score cannot be received before it was assessed.",
      "$.risk_scores.received_at"
    )
  }
  valid_score_fk <- !is.na(score_discharge)
  if (any(valid_score_fk & (
      score_time < index_admission[score_discharge] |
      score_time > index_discharge[score_discharge]
  ), na.rm = TRUE)) {
    add_issue(
      "synthetic.source.risk_time", "source_risk_outside_encounter",
      "Source risk assessment must occur during its index encounter.",
      "$.risk_scores.assessed_at"
    )
  }
  if (any(!is.na(scores$score_probability) &
          (scores$score_probability < 0 | scores$score_probability > 1))) {
    add_issue(
      "synthetic.source.risk_probability", "invalid_source_probability",
      "Source probability must be between zero and one.",
      "$.risk_scores.score_probability"
    )
  }

  validate_feed_time <- function(table, occurrence_field, availability_field) {
    feed <- source[[table]]
    discharge_index <- match(feed$discharge_key, discharges$discharge_key)
    occurrence <- rrp_synthetic_source_times(feed[[occurrence_field]])
    availability <- rrp_synthetic_source_times(feed[[availability_field]])
    if (any(!is.na(occurrence) & !is.na(availability) & availability < occurrence)) {
      add_issue(
        paste0("synthetic.source.", table, "_availability"),
        "source_availability_before_occurrence",
        paste0("Source availability precedes occurrence in ", table, "."),
        paste0("$.", table, ".", availability_field)
      )
    }
    resolved <- !is.na(discharge_index)
    if (any(resolved & (
      occurrence < index_discharge[discharge_index] |
        occurrence > window_end[discharge_index]
    ), na.rm = TRUE)) {
      add_issue(
        paste0("synthetic.source.", table, "_window"),
        "source_record_outside_episode_window",
        paste0("Source occurrence is outside its discharge window in ", table, "."),
        paste0("$.", table, ".", occurrence_field)
      )
    }
  }
  validate_feed_time("activity_events", "occurred_at", "received_at")
  validate_feed_time("outcomes", "occurred_at", "received_at")

  outcomes <- source$outcomes
  readmissions <- outcomes$outcome_code == "readmission"
  deaths <- outcomes$outcome_code == "death"
  if (any(readmissions & (
      is.na(outcomes$related_encounter_key) |
      !outcomes$related_encounter_key %in% encounters$encounter_key
  ))) {
    add_issue(
      "synthetic.source.readmission_relationship", "invalid_readmission_encounter_reference",
      "Readmission outcomes require a resolving related encounter.",
      "$.outcomes.related_encounter_key"
    )
  }
  if (any(deaths & !is.na(outcomes$related_encounter_key))) {
    add_issue(
      "synthetic.source.death_relationship", "death_has_readmission_encounter",
      "Death outcomes must not claim a related readmission encounter.",
      "$.outcomes.related_encounter_key"
    )
  }
  if (any(readmissions)) {
    outcome_discharge_index <- match(outcomes$discharge_key, discharges$discharge_key)
    index_encounter_index <- match(
      discharges$encounter_key[outcome_discharge_index], encounters$encounter_key
    )
    related_index <- match(outcomes$related_encounter_key, encounters$encounter_key)
    if (any(readmissions & !is.na(related_index) & (
      encounters$encounter_class[related_index] != "readmission_inpatient" |
      encounters$patient_key[related_index] != encounters$patient_key[index_encounter_index]
    ))) {
      add_issue(
        "synthetic.source.readmission_integrity", "invalid_readmission_integrity",
        "Related readmission encounter must belong to the episode patient and class.",
        "$.outcomes.related_encounter_key"
      )
    }
  }

  all_ids <- unlist(lapply(source, function(table) {
    key <- names(table)[[1L]]
    table[[key]]
  }), use.names = FALSE)
  if (any(!startsWith(all_ids, "synthetic_"))) {
    add_issue(
      "synthetic.source.fictional_identity", "nonfictional_source_identifier",
      "Every generated primary identifier must use the visible synthetic prefix.",
      "$"
    )
  }
  rrp_synthetic_result(source, issues, rrp_synthetic_source_schema_identity())
}

rrp_validate_synthetic_source <- function(source, schema, location = NA_character_) {
  schema_result <- rrp_validate_synthetic_source_schema_specification(schema, location)
  structure_result <- rrp_validate_synthetic_source_tables(source, schema, location)
  relationship_result <- rrp_validate_synthetic_source_relationships(
    source, schema, location
  )
  semantic_result <- rrp_validate_synthetic_source_semantics(source, schema, location)
  rrp_combine_conformance_results(
    source,
    rrp_synthetic_source_schema_identity(),
    list(schema_result, structure_result, relationship_result, semantic_result)
  )
}
