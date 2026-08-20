# Implementation-owned validation for the adopter fixture's raw export shape.

rrp_adopter_source_field_has_type <- function(value, type) switch(
  type,
  character = is.character(value),
  local_timestamp = rrp_adopter_local_time_valid(value),
  FALSE
)

rrp_validate_adopter_source_schema <- function(schema) {
  issues <- list()
  support <- rrp_validate_specification_support(
    schema, "source_schema", "conformance.fictional-export-source-schema", "0.1.0"
  )
  issues[[length(issues) + 1L]] <- support$issues
  if (!rrp_is_named_mapping(schema$objects) ||
      !identical(names(schema$objects), c("case_extract", "activity_feed"))) {
    issues[[length(issues) + 1L]] <- rrp_adopter_issue(
      "adopter.schema.objects", "invalid_adopter_source_objects",
      "Source schema must declare exactly the case extract and activity feed.",
      "$.objects"
    )
  }
  if (!identical(schema$data_classification, "fictional_nonclinical") ||
      !identical(schema$additional_fields_policy, "reject")) {
    issues[[length(issues) + 1L]] <- rrp_adopter_issue(
      "adopter.schema.policy", "invalid_adopter_source_policy",
      "Fixture source schema must be fictional and reject undeclared fields.", "$"
    )
  }
  expected_vocabularies <- c("closure_code", "fact_code", "feed_state")
  if (!rrp_is_named_mapping(schema$controlled_values) ||
      !identical(names(schema$controlled_values), expected_vocabularies)) {
    issues[[length(issues) + 1L]] <- rrp_adopter_issue(
      "adopter.schema.vocabulary", "invalid_adopter_source_vocabularies",
      "Fixture source vocabularies do not match the supported scenario.",
      "$.controlled_values"
    )
  }
  rrp_adopter_result(schema, issues)
}

rrp_validate_adopter_source_structure <- function(source, schema) {
  issues <- list()
  expected_objects <- names(schema$objects)
  if (!is.list(source) || is.null(names(source))) return(rrp_adopter_result(
    source, list(rrp_adopter_issue(
      "adopter.source.structure", "invalid_adopter_source",
      "Adopter source must be a named collection of source objects."
    ))
  ))
  for (object_name in setdiff(expected_objects, names(source))) {
    issues[[length(issues) + 1L]] <- rrp_adopter_issue(
      "adopter.source.required_objects", "missing_adopter_source_object",
      paste0("Required adopter source object is missing: ", object_name, "."),
      paste0("$.", object_name)
    )
  }
  for (object_name in setdiff(names(source), expected_objects)) {
    issues[[length(issues) + 1L]] <- rrp_adopter_issue(
      "adopter.source.closed", "unknown_adopter_source_object",
      paste0("Undeclared adopter source object is not permitted: ", object_name, "."),
      paste0("$.", object_name)
    )
  }
  for (object_name in intersect(expected_objects, names(source))) {
    object <- source[[object_name]]
    definition <- schema$objects[[object_name]]
    object_path <- paste0("$.", object_name)
    if (!is.data.frame(object)) {
      issues[[length(issues) + 1L]] <- rrp_adopter_issue(
        "adopter.source.object_type", "adopter_source_object_not_data_frame",
        paste0("Adopter source object must be a data frame: ", object_name, "."),
        object_path
      )
      next
    }
    declared_fields <- names(definition$fields)
    for (field in setdiff(declared_fields, names(object))) {
      issues[[length(issues) + 1L]] <- rrp_adopter_issue(
        "adopter.source.required_fields", "missing_adopter_source_field",
        paste0("Required source field is missing: ", object_name, ".", field, "."),
        paste0(object_path, ".", field)
      )
    }
    for (field in setdiff(names(object), declared_fields)) {
      issues[[length(issues) + 1L]] <- rrp_adopter_issue(
        "adopter.source.closed", "unknown_adopter_source_field",
        paste0("Undeclared source field is not permitted: ", object_name, ".", field, "."),
        paste0(object_path, ".", field)
      )
    }
    for (field in intersect(declared_fields, names(object))) {
      descriptor <- definition$fields[[field]]
      value <- object[[field]]
      if (!rrp_adopter_source_field_has_type(value, descriptor$type)) {
        issues[[length(issues) + 1L]] <- rrp_adopter_issue(
          "adopter.source.field_type", "invalid_adopter_source_field_type",
          paste0("Source field has invalid type: ", object_name, ".", field, "."),
          paste0(object_path, ".", field)
        )
      }
      if (!isTRUE(descriptor$nullable) && anyNA(value)) {
        issues[[length(issues) + 1L]] <- rrp_adopter_issue(
          "adopter.source.nullability", "null_adopter_source_value",
          paste0("Source field may not contain missing values: ", object_name, ".", field, "."),
          paste0(object_path, ".", field)
        )
      }
    }
    primary_key <- definition$primary_key
    if (rrp_is_scalar_character(primary_key) && primary_key %in% names(object) &&
        any(is.na(object[[primary_key]]) | duplicated(object[[primary_key]]))) {
      issues[[length(issues) + 1L]] <- rrp_adopter_issue(
        "adopter.source.primary_key", "duplicate_or_missing_adopter_source_id",
        paste0("Source primary key must be populated and unique: ",
               object_name, ".", primary_key, "."),
        paste0(object_path, ".", primary_key)
      )
    }
  }
  rrp_adopter_result(source, issues)
}

rrp_validate_adopter_source_semantics <- function(source, schema) {
  issues <- list()
  required <- names(schema$objects)
  structurally_usable <- all(required %in% names(source)) &&
    all(vapply(source[required], is.data.frame, logical(1))) &&
    all(vapply(required, function(name) {
      all(names(schema$objects[[name]]$fields) %in% names(source[[name]]))
    }, logical(1)))
  if (!structurally_usable) return(rrp_adopter_result(source, issues))
  add_issue <- function(rule, code, message, path) {
    issues[[length(issues) + 1L]] <<- rrp_adopter_issue(
      rule, code, message, path
    )
  }

  cases <- source$case_extract
  activities <- source$activity_feed
  unresolved <- unique(activities$case_ref[!activities$case_ref %in% cases$case_ref])
  if (length(unresolved) > 0L) add_issue(
    "adopter.source.relationship", "unresolved_adopter_case_reference",
    "Activity feed contains case references absent from the case extract.",
    "$.activity_feed.case_ref"
  )
  vocabulary_fields <- list(
    list(object = "case_extract", field = "closure_code"),
    list(object = "activity_feed", field = "fact_code"),
    list(object = "activity_feed", field = "feed_state")
  )
  for (definition in vocabulary_fields) {
    values <- source[[definition$object]][[definition$field]]
    allowed <- unlist(schema$controlled_values[[definition$field]], use.names = FALSE)
    if (any(!is.na(values) & !values %in% allowed)) add_issue(
      "adopter.source.vocabulary", "invalid_adopter_source_code",
      paste0("Local source code is unsupported: ", definition$field, "."),
      paste0("$.", definition$object, ".", definition$field)
    )
  }

  arrived <- rrp_adopter_local_time_number(cases$arrived_local)
  departed <- rrp_adopter_local_time_number(cases$departed_local)
  watch_through <- rrp_adopter_local_time_number(cases$watch_through_local)
  extracted <- rrp_adopter_local_time_number(cases$extract_loaded_local)
  terminal <- rrp_adopter_local_time_number(cases$terminal_local)
  terminal_loaded <- rrp_adopter_local_time_number(cases$terminal_loaded_local)
  if (any(arrived >= departed, na.rm = TRUE) || any(departed >= watch_through, na.rm = TRUE)) {
    add_issue(
      "adopter.source.case_time", "invalid_adopter_case_window",
      "Local admission, discharge, and follow-up times are not strictly ordered.",
      "$.case_extract.arrived_local"
    )
  }
  if (any(extracted < departed, na.rm = TRUE)) add_issue(
    "adopter.source.extract_availability", "case_loaded_before_discharge",
    "A discharge extract row cannot load before the represented discharge.",
    "$.case_extract.extract_loaded_local"
  )
  terminal_state <- cases$closure_code %in% c("RETURNED", "DIED")
  incoherent_terminal <- terminal_state != (!is.na(terminal) & !is.na(terminal_loaded))
  if (any(incoherent_terminal)) add_issue(
    "adopter.source.terminal_status", "incoherent_adopter_terminal_fact",
    "Returned or died cases require both terminal times; open cases require neither.",
    "$.case_extract.closure_code"
  )
  if (any(terminal_state & (terminal <= departed | terminal > watch_through), na.rm = TRUE) ||
      any(terminal_loaded < terminal, na.rm = TRUE)) add_issue(
    "adopter.source.terminal_time", "invalid_adopter_terminal_time",
    "Terminal occurrence and load times violate the local episode window.",
    "$.case_extract.terminal_local"
  )

  case_index <- match(activities$case_ref, cases$case_ref)
  happened <- rrp_adopter_local_time_number(activities$happened_local)
  loaded <- rrp_adopter_local_time_number(activities$loaded_local)
  resolved <- !is.na(case_index)
  if (any(resolved & (happened < departed[case_index] |
                      happened > watch_through[case_index]), na.rm = TRUE)) add_issue(
    "adopter.source.activity_window", "activity_outside_adopter_case_window",
    "Activity occurrence must be inside its local post-discharge window.",
    "$.activity_feed.happened_local"
  )
  if (any(loaded < happened, na.rm = TRUE)) add_issue(
    "adopter.source.activity_availability", "activity_loaded_before_occurrence",
    "Activity load time cannot precede occurrence time.",
    "$.activity_feed.loaded_local"
  )
  rrp_adopter_result(source, issues)
}

rrp_validate_adopter_source <- function(source, schema) {
  schema_result <- rrp_validate_adopter_source_schema(schema)
  structure_result <- rrp_validate_adopter_source_structure(source, schema)
  semantics_result <- rrp_validate_adopter_source_semantics(source, schema)
  rrp_adopter_result(
    source,
    list(schema_result$issues, structure_result$issues, semantics_result$issues)
  )
}
