# Test-only implementation-owned identities, configuration, and fictional data.

rrp_adopter_fixture_root <- function(repository_root) file.path(
  repository_root, "tests", "phase10", "fixtures", "adopter-producer"
)

rrp_adopter_fixture_read_yaml <- function(repository_root, name) {
  yaml::read_yaml(file.path(rrp_adopter_fixture_root(repository_root), name))
}

rrp_adopter_fixture_identities <- function() list(
  producer = list(
    producer_id = "conformance.adopter-extract-canonical-producer",
    producer_version = "0.1.0"
  ),
  implementation = list(
    implementation_id = "conformance.fictional-export-source",
    implementation_version = "0.1.0"
  ),
  source_schema = list(
    source_schema_id = "conformance.fictional-export-source-schema",
    source_schema_version = "0.1.0"
  ),
  mapping = list(
    mapping_id = "conformance.fictional-export-to-readmission-canonical",
    mapping_version = "0.1.0"
  )
)

rrp_adopter_source_schema_specification <- function() list(
  specification_kind = "source_schema",
  specification_id = "conformance.fictional-export-source-schema",
  specification_version = "0.1.0"
)

rrp_adopter_mapping_specification <- function() list(
  specification_kind = "source_mapping",
  specification_id = "conformance.fictional-export-to-readmission-canonical",
  specification_version = "0.1.0"
)

rrp_adopter_issue <- function(
  rule_id, issue_code, message, object_path = "$", specification = NULL
) rrp_conformance_issue(
  rule_id, "error", issue_code, message, object_path,
  specification = specification %||% rrp_adopter_source_schema_specification()
)

rrp_adopter_result <- function(candidate, issues, specification = NULL) {
  rrp_conformance_result(
    candidate,
    specification %||% rrp_adopter_source_schema_specification(),
    rrp_bind_rows(issues, rrp_empty_conformance_issues)
  )
}

rrp_adopter_local_time_number <- function(value) {
  parsed <- as.POSIXct(
    value, format = "%Y-%m-%d %H:%M:%S %z", tz = "UTC"
  )
  as.numeric(parsed)
}

rrp_adopter_local_time_valid <- function(value) {
  is.character(value) && all(is.na(value) | !is.na(rrp_adopter_local_time_number(value)))
}

rrp_adopter_canonical_time <- function(value) {
  if (length(value) != 1L || is.na(value)) return(NULL)
  number <- rrp_adopter_local_time_number(value)
  if (is.na(number)) stop("Adopter source time could not be normalized.", call. = FALSE)
  format(as.POSIXct(number, origin = "1970-01-01", tz = "UTC"),
         "%Y-%m-%dT%H:%M:%SZ", tz = "UTC")
}

rrp_adopter_normalize_identifier <- function(prefix, value) {
  normalized <- tolower(gsub("[^A-Za-z0-9]+", "_", value))
  normalized <- gsub("^_+|_+$", "", normalized)
  paste(prefix, normalized, sep = "_")
}

rrp_adopter_fixture_source <- function() list(
  case_extract = data.frame(
    case_ref = c("ZONE-A|CASE-701", "ZONE-B|CASE-918", "ZONE-A|CASE-744"),
    subject_token = c("SUBJECT/ALPHA", "SUBJECT/BRAVO", "SUBJECT/CHARLIE"),
    stay_ref = c("STAY:5001", "STAY:5108", "STAY:5220"),
    arrived_local = c(
      "2026-07-28 08:00:00 -0500", "2026-07-30 09:30:00 -0500",
      "2026-08-01 11:00:00 -0500"
    ),
    departed_local = c(
      "2026-07-30 14:00:00 -0500", "2026-08-01 12:00:00 -0500",
      "2026-08-03 16:30:00 -0500"
    ),
    watch_through_local = c(
      "2026-08-29 14:00:00 -0500", "2026-08-31 12:00:00 -0500",
      "2026-09-02 16:30:00 -0500"
    ),
    extract_loaded_local = c(
      "2026-07-30 14:20:00 -0500", "2026-08-01 12:20:00 -0500",
      "2026-08-03 16:50:00 -0500"
    ),
    closure_code = c("OPEN", "RETURNED", "OPEN"),
    terminal_local = c(NA_character_, "2026-08-05 09:15:00 -0500", NA_character_),
    terminal_loaded_local = c(NA_character_, "2026-08-05 10:05:00 -0500", NA_character_),
    stringsAsFactors = FALSE
  ),
  activity_feed = data.frame(
    fact_ref = c("FEED-201", "FEED-202", "FEED-203", "FEED-204", "FEED-205"),
    case_ref = c(
      "ZONE-A|CASE-701", "ZONE-A|CASE-701", "ZONE-B|CASE-918",
      "ZONE-A|CASE-744", "ZONE-A|CASE-744"
    ),
    fact_code = c(
      "CALL_OK", "MED_ACCESS_FLAG", "RETURN_NOTICE", "CLINIC_SEEN", "ED_SEEN"
    ),
    happened_local = c(
      "2026-07-31 10:00:00 -0500", "2026-08-02 08:30:00 -0500",
      "2026-08-05 09:15:00 -0500", "2026-08-08 13:00:00 -0500",
      "2026-08-09 20:00:00 -0500"
    ),
    loaded_local = c(
      "2026-07-31 10:40:00 -0500", "2026-08-02 09:10:00 -0500",
      "2026-08-05 10:05:00 -0500", "2026-08-08 14:00:00 -0500",
      "2026-08-11 07:30:00 -0500"
    ),
    feed_state = rep("FINAL", 5L),
    stringsAsFactors = FALSE
  )
)

rrp_validate_adopter_configuration <- function(configuration) {
  issues <- list()
  envelope <- rrp_validate_specification_envelope(configuration)
  issues[[length(issues) + 1L]] <- envelope$issues
  expected_schema <- list(
    specification_kind = "source_schema",
    specification_id = "conformance.fictional-export-source-schema",
    specification_version = "0.1.0"
  )
  if (!identical(configuration$specification_kind, "adopter_conformance_source_configuration") ||
      !identical(configuration$specification_id, "conformance.adopter-extract-scenario") ||
      !identical(configuration$specification_version, "0.1.0")) {
    issues[[length(issues) + 1L]] <- rrp_adopter_issue(
      "adopter.configuration.identity", "invalid_adopter_configuration_identity",
      "Adopter conformance configuration identity is unsupported.", "$"
    )
  }
  if (!identical(configuration$scenario_id, "fictional_export_case_v1") ||
      !identical(configuration$data_classification, "fictional_nonclinical") ||
      !identical(configuration$clinical_validity, "none")) {
    issues[[length(issues) + 1L]] <- rrp_adopter_issue(
      "adopter.configuration.classification", "invalid_adopter_scenario",
      "The adopter fixture must remain the declared fictional nonclinical scenario.", "$"
    )
  }
  if (!rrp_is_rfc3339_timestamp(configuration$canonical_as_of_time)) {
    issues[[length(issues) + 1L]] <- rrp_adopter_issue(
      "adopter.configuration.time", "invalid_adopter_as_of_time",
      "Adopter canonical as-of time must be explicit-offset RFC 3339.",
      "$.canonical_as_of_time"
    )
  }
  if (!identical(configuration$source_schema_reference, expected_schema)) {
    issues[[length(issues) + 1L]] <- rrp_adopter_issue(
      "adopter.configuration.schema", "invalid_adopter_source_schema_reference",
      "Adopter configuration must reference the exact fixture source schema.",
      "$.source_schema_reference"
    )
  }
  rrp_adopter_result(configuration, issues)
}
