rrp_canonical_envelope_expected <- function() {
  c(
    "Record-Type" = "specification",
    "Specification-Kind" = "specification-envelope",
    "Specification-ID" = "rrp.specification-envelope",
    "Specification-Version" = "0.1.0",
    "Specification-Format-Version" = "1.0.0",
    "Identity-Scope" = "platform",
    "Status" = "development_unpublished",
    "Product-ID" = "readmission-risk-pool-platform",
    "Development-Version" = "1.0.0-dev",
    "Owner-Package" = "rrpplatform",
    "Required-Envelope-Fields" = paste(c(
      "Record-Type", "Specification-Kind", "Specification-ID",
      "Specification-Version", "Specification-Format-Version",
      "Identity-Scope", "Status", "Product-ID", "Development-Version",
      "Owner-Package"
    ), collapse = ","),
    "Allowed-Specification-Kinds" = paste(c(
      "specification-envelope", "canonical-producer-contract",
      "canonical-bundle-contract", "canonical-profile", "canonical-domain"
    ), collapse = ","),
    "Specification-ID-Pattern" = "^rrp[.][a-z0-9]+(?:[.-][a-z0-9]+)+$",
    "Specification-Version-Pattern" = paste0(
      "^[0-9]+[.][0-9]+[.][0-9]+",
      "(?:-[0-9A-Za-z]+(?:[.-][0-9A-Za-z]+)*)?$"
    ),
    "Compatibility-Rule" = "exact_version",
    "Unknown-Fields" = "prohibited",
    "Additional-Records" = "prohibited",
    "Executable-Content" = "prohibited"
  )
}

rrp_canonical_producer_contract_expected <- function() {
  c(
    "Record-Type" = "specification",
    "Specification-Kind" = "canonical-producer-contract",
    "Specification-ID" = "rrp.canonical-producer",
    "Specification-Version" = "0.1.0",
    "Specification-Format-Version" = "1.0.0",
    "Identity-Scope" = "platform",
    "Status" = "development_unpublished",
    "Product-ID" = "readmission-risk-pool-platform",
    "Development-Version" = "1.0.0-dev",
    "Owner-Package" = "rrpplatform",
    "Producer-API-ID" = "rrp.producer-api",
    "Producer-API-Version" = "0.1.0",
    "Canonical-Bundle-ID" = "rrp.canonical-bundle",
    "Canonical-Bundle-Version" = "0.1.0",
    "Canonical-Profile-ID" = "rrp.canonical-profile.readmission",
    "Canonical-Profile-Version" = "0.1.0",
    "Producer-Declaration-Fields" = paste(c(
      "component_id", "component_version", "producer_api_id",
      "producer_api_version", "canonical_bundle_id",
      "canonical_bundle_version", "canonical_profile_id",
      "canonical_profile_version", "implementation_id",
      "implementation_version", "mapping_id", "mapping_version",
      "capabilities", "callable"
    ), collapse = ","),
    "Capability-Record-Fields" = "capability_id,status",
    "Required-Capability-IDs" = paste(c(
      "rrp.capability.discharge-episode", "rrp.capability.terminal-event"
    ), collapse = ","),
    "Capability-Status-Values" = "available",
    "Callable-Semantics" = "trusted_not_invoked_during_validation",
    "Request-Fields" = paste(c(
      "producer_api_id", "producer_api_version", "project_id",
      "project_version", "producer_id", "producer_version",
      "canonical_bundle_id", "canonical_bundle_version",
      "canonical_profile_id", "canonical_profile_version", "as_of_time"
    ), collapse = ","),
    "Result-Fields" = paste(c(
      "producer_contract_id", "producer_contract_version", "status",
      "producer_id", "producer_version", "implementation_id",
      "implementation_version", "mapping_id", "mapping_version",
      "canonical_profile_id", "canonical_profile_version",
      "canonical_as_of_time", "capabilities", "candidate_bundle",
      "failure_code"
    ), collapse = ","),
    "Result-Status-Values" = "succeeded,failed",
    "Failure-Codes" = paste(c(
      "producer_unavailable", "producer_source_failed",
      "producer_mapping_failed"
    ), collapse = ","),
    "Unknown-Fields" = "prohibited",
    "Additional-Records" = "prohibited",
    "Executable-Configuration" = "prohibited"
  )
}

rrp_canonical_bundle_contract_expected <- function() {
  c(
    "Record-Type" = "specification",
    "Specification-Kind" = "canonical-bundle-contract",
    "Specification-ID" = "rrp.canonical-bundle",
    "Specification-Version" = "0.1.0",
    "Specification-Format-Version" = "1.0.0",
    "Identity-Scope" = "platform",
    "Status" = "development_unpublished",
    "Product-ID" = "readmission-risk-pool-platform",
    "Development-Version" = "1.0.0-dev",
    "Owner-Package" = "rrpruntime",
    "Bundle-Fields" = paste(c(
      "bundle_contract_id", "bundle_contract_version", "bundle_instance_id",
      "project_id", "project_version", "producer_id", "producer_version",
      "implementation_id", "implementation_version", "mapping_id",
      "mapping_version", "canonical_profile_id",
      "canonical_profile_version", "as_of_time", "capabilities", "domains"
    ), collapse = ","),
    "Canonical-Profile-ID" = "rrp.canonical-profile.readmission",
    "Canonical-Profile-Version" = "0.1.0",
    "Domain-IDs" = "discharge_episode,terminal_event",
    "Capability-IDs" = paste(c(
      "rrp.capability.discharge-episode", "rrp.capability.terminal-event"
    ), collapse = ","),
    "Capability-Record-Fields" = "capability_id,status",
    "Capability-Status-Values" = "available",
    "As-Of-Representation" = "rfc3339_explicit_offset",
    "Identity-Agreement" = paste(c(
      "project", "producer", "implementation", "mapping", "profile",
      "capabilities", "as_of"
    ), collapse = ","),
    "Initial-Adapter" = "closed_named_record_with_tabular_domains",
    "Unknown-Fields" = "prohibited",
    "Additional-Records" = "prohibited",
    "Executable-Content" = "prohibited"
  )
}

rrp_canonical_profile_expected <- function() {
  c(
    "Record-Type" = "specification",
    "Specification-Kind" = "canonical-profile",
    "Specification-ID" = "rrp.canonical-profile.readmission",
    "Specification-Version" = "0.1.0",
    "Specification-Format-Version" = "1.0.0",
    "Identity-Scope" = "platform",
    "Status" = "development_unpublished",
    "Product-ID" = "readmission-risk-pool-platform",
    "Development-Version" = "1.0.0-dev",
    "Owner-Package" = "rrpruntime",
    "Canonical-Bundle-ID" = "rrp.canonical-bundle",
    "Canonical-Bundle-Version" = "0.1.0",
    "Domain-IDs" = "discharge_episode,terminal_event",
    "Domain-Specifications" = paste(c(
      "rrp.canonical-domain.discharge-episode@0.1.0",
      "rrp.canonical-domain.terminal-event@0.1.0"
    ), collapse = ","),
    "Domain-Requirement" = "required",
    "Available-Row-Cardinality" = "zero_or_more",
    "Capability-IDs" = paste(c(
      "rrp.capability.discharge-episode", "rrp.capability.terminal-event"
    ), collapse = ","),
    "Capability-Status" = "available",
    "Unknown-Domains" = "prohibited",
    "Unknown-Capabilities" = "prohibited",
    "Additional-Records" = "prohibited"
  )
}

rrp_canonical_discharge_episode_expected <- function() {
  c(
    "Record-Type" = "specification",
    "Specification-Kind" = "canonical-domain",
    "Specification-ID" = "rrp.canonical-domain.discharge-episode",
    "Specification-Version" = "0.1.0",
    "Specification-Format-Version" = "1.0.0",
    "Identity-Scope" = "platform",
    "Status" = "development_unpublished",
    "Product-ID" = "readmission-risk-pool-platform",
    "Development-Version" = "1.0.0-dev",
    "Owner-Package" = "rrpruntime",
    "Domain-ID" = "discharge_episode",
    "Capability-ID" = "rrp.capability.discharge-episode",
    "Fields" = paste(c(
      "episode_id", "patient_id", "index_encounter_id", "admission_time",
      "discharge_time", "followup_window_end"
    ), collapse = ","),
    "Primary-Key" = "episode_id",
    "Identifier-Fields" = "episode_id,patient_id,index_encounter_id",
    "Timestamp-Fields" = "admission_time,discharge_time,followup_window_end",
    "Timestamp-Representation" = "rfc3339_explicit_offset",
    "Admission-Before-Discharge" = "required",
    "Discharge-Not-After-Bundle-As-Of" = "required",
    "Followup-Elapsed-Seconds" = "2592000",
    "Multiple-Episodes-Per-Patient" = "allowed",
    "Available-Row-Cardinality" = "zero_or_more",
    "Null-Fields" = "none",
    "Unknown-Fields" = "prohibited",
    "Additional-Records" = "prohibited"
  )
}

rrp_canonical_terminal_event_expected <- function() {
  c(
    "Record-Type" = "specification",
    "Specification-Kind" = "canonical-domain",
    "Specification-ID" = "rrp.canonical-domain.terminal-event",
    "Specification-Version" = "0.1.0",
    "Specification-Format-Version" = "1.0.0",
    "Identity-Scope" = "platform",
    "Status" = "development_unpublished",
    "Product-ID" = "readmission-risk-pool-platform",
    "Development-Version" = "1.0.0-dev",
    "Owner-Package" = "rrpruntime",
    "Domain-ID" = "terminal_event",
    "Capability-ID" = "rrp.capability.terminal-event",
    "Fields" = "terminal_event_id,episode_id,event_type,occurred_at,available_at",
    "Primary-Key" = "terminal_event_id",
    "Episode-Reference-Field" = "episode_id",
    "Episode-Reference-Domain" = "discharge_episode",
    "Event-Type-Field" = "event_type",
    "Event-Type-Values" = "readmission,death",
    "Occurrence-Field" = "occurred_at",
    "Availability-Field" = "available_at",
    "Timestamp-Representation" = "rfc3339_explicit_offset",
    "Occurrence-After-Discharge" = "required",
    "Occurrence-Through-Followup-End" = "required",
    "Availability-Not-Before-Occurrence" = "required",
    "Availability-Not-After-Bundle-As-Of" = "required",
    "Maximum-Per-Episode-And-Type" = "1",
    "Equal-Readmission-Death-Time" = "allowed",
    "Death-Before-Later-Readmission" = "prohibited",
    "Available-Row-Cardinality" = "zero_or_more",
    "Null-Fields" = "none",
    "Unknown-Fields" = "prohibited",
    "Additional-Records" = "prohibited"
  )
}

rrp_canonical_contract_definitions <- function() {
  list(
    specification_envelope = list(
      resource_id = "rrp.contract.specification-envelope",
      path = "resources/contracts/canonical/specification-envelope.dcf",
      owner = "rrpplatform",
      expected = rrp_canonical_envelope_expected()
    ),
    canonical_producer = list(
      resource_id = "rrp.contract.canonical-producer",
      path = "resources/contracts/canonical/canonical-producer.dcf",
      owner = "rrpplatform",
      expected = rrp_canonical_producer_contract_expected()
    ),
    canonical_bundle = list(
      resource_id = "rrp.contract.canonical-bundle",
      path = "resources/contracts/canonical/canonical-bundle.dcf",
      owner = "rrpruntime",
      expected = rrp_canonical_bundle_contract_expected()
    ),
    readmission_profile = list(
      resource_id = "rrp.profile.readmission",
      path = "resources/contracts/canonical/profiles/readmission.dcf",
      owner = "rrpruntime",
      expected = rrp_canonical_profile_expected()
    ),
    discharge_episode = list(
      resource_id = "rrp.domain.discharge-episode",
      path = "resources/contracts/canonical/domains/discharge-episode.dcf",
      owner = "rrpruntime",
      expected = rrp_canonical_discharge_episode_expected()
    ),
    terminal_event = list(
      resource_id = "rrp.domain.terminal-event",
      path = "resources/contracts/canonical/domains/terminal-event.dcf",
      owner = "rrpruntime",
      expected = rrp_canonical_terminal_event_expected()
    )
  )
}

rrp_canonical_contract_record <- function(catalog, definition) {
  path <- rrp_resource_path(catalog, definition$resource_id)
  records <- rrp_resource_read_dcf(
    path, "malformed_canonical_contract", "Installed canonical contract"
  )
  if (length(records) != 1L) {
    rrp_resource_abort(
      "malformed_canonical_contract",
      "Installed canonical contract is malformed."
    )
  }
  record <- records[[1L]]
  expected <- definition$expected
  rrp_resource_require_fields(
    record, names(expected), "invalid_canonical_contract_fields",
    "Installed canonical contract"
  )
  for (field in names(expected)) {
    if (!identical(record[[field]], unname(expected[[field]]))) {
      rrp_resource_abort(
        "unsupported_canonical_contract",
        "Installed canonical contract is unsupported."
      )
    }
  }
  record
}

rrp_canonical_validate_relationships <- function(contracts) {
  producer <- contracts$canonical_producer
  bundle <- contracts$canonical_bundle
  profile <- contracts$readmission_profile
  discharge <- contracts$discharge_episode
  terminal <- contracts$terminal_event
  capabilities <- paste(c(
    discharge[["Capability-ID"]], terminal[["Capability-ID"]]
  ), collapse = ",")
  domains <- paste(c(
    discharge[["Domain-ID"]], terminal[["Domain-ID"]]
  ), collapse = ",")
  domain_specifications <- paste(c(
    paste0(discharge[["Specification-ID"]], "@", discharge[["Specification-Version"]]),
    paste0(terminal[["Specification-ID"]], "@", terminal[["Specification-Version"]])
  ), collapse = ",")
  valid <- identical(
    producer[["Canonical-Bundle-ID"]], bundle[["Specification-ID"]]
  ) && identical(
    producer[["Canonical-Bundle-Version"]], bundle[["Specification-Version"]]
  ) && identical(
    producer[["Canonical-Profile-ID"]], profile[["Specification-ID"]]
  ) && identical(
    producer[["Canonical-Profile-Version"]], profile[["Specification-Version"]]
  ) && identical(
    bundle[["Canonical-Profile-ID"]], profile[["Specification-ID"]]
  ) && identical(
    bundle[["Canonical-Profile-Version"]], profile[["Specification-Version"]]
  ) && identical(
    profile[["Canonical-Bundle-ID"]], bundle[["Specification-ID"]]
  ) && identical(
    profile[["Canonical-Bundle-Version"]], bundle[["Specification-Version"]]
  ) && identical(producer[["Required-Capability-IDs"]], capabilities) &&
    identical(bundle[["Capability-IDs"]], capabilities) &&
    identical(profile[["Capability-IDs"]], capabilities) &&
    identical(bundle[["Domain-IDs"]], domains) &&
    identical(profile[["Domain-IDs"]], domains) &&
    identical(profile[["Domain-Specifications"]], domain_specifications) &&
    identical(terminal[["Episode-Reference-Domain"]], discharge[["Domain-ID"]])
  if (!valid) {
    rrp_resource_abort(
      "incompatible_canonical_contracts",
      "Installed canonical contracts are incompatible."
    )
  }
  invisible(contracts)
}

rrp_canonical_contracts <- function(catalog) {
  definitions <- rrp_canonical_contract_definitions()
  contracts <- lapply(definitions, function(definition) {
    rrp_canonical_contract_record(catalog, definition)
  })
  rrp_canonical_validate_relationships(contracts)
  contracts
}

rrp_canonical_required_capabilities <- function(canonical_contracts) {
  ids <- strsplit(
    canonical_contracts$canonical_producer[["Required-Capability-IDs"]],
    ",", fixed = TRUE
  )[[1L]]
  lapply(ids, function(id) list(capability_id = id, status = "available"))
}
