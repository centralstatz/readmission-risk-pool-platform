#!/usr/bin/env Rscript

# Prove the local package/resource/project and canonical-handoff foundation,
# including explicit-root installed-resource access, pure canonical admission,
# trusted project loading, and selected producer execution. This is not an
# installed RRP operation or a general validator.

script_argument <- grep(
  "^--file=", commandArgs(trailingOnly = FALSE), value = TRUE
)
if (length(script_argument) != 1L) {
  stop("Cannot determine the package-validation script path.", call. = FALSE)
}
script_path <- normalizePath(
  sub("^--file=", "", script_argument), mustWork = TRUE
)
repository_root <- normalizePath(
  file.path(dirname(script_path), ".."), mustWork = TRUE
)

package_specs <- list(
  rrpruntime = list(
    version = "0.4.0.9000",
    imports = character()
  ),
  rrpplatform = list(
    version = "0.1.0.9000",
    imports = "rrpruntime"
  )
)

fail <- function(...) {
  stop(paste0(...), call. = FALSE)
}

require_true <- function(condition, message) {
  if (!isTRUE(condition)) fail(message)
}

resource_fail <- function(code, message) {
  fail("[", code, "] ", message)
}

resource_require <- function(condition, code, message) {
  if (!isTRUE(condition)) resource_fail(code, message)
}

split_controlled_values <- function(value) {
  strsplit(value, ",", fixed = TRUE)[[1L]]
}

read_dcf_records <- function(path) {
  resource_require(file.exists(path), "dcf_missing", "DCF file is missing.")
  lines <- readLines(path, warn = FALSE, encoding = "UTF-8")
  resource_require(length(lines) > 0L, "dcf_layout", "DCF file is empty.")
  resource_require(
    !any(grepl("^[[:space:]]*$", lines) & nzchar(lines)),
    "dcf_layout", "DCF separators must be empty lines."
  )
  blank <- !nzchar(lines)
  resource_require(
    !blank[[1L]] && !blank[[length(blank)]] &&
      !any(blank[-length(blank)] & blank[-1L]),
    "dcf_layout", "DCF records require exactly one empty separator line."
  )

  separators <- which(blank)
  starts <- c(1L, separators + 1L)
  ends <- c(separators - 1L, length(lines))
  lapply(seq_along(starts), function(index) {
    block <- lines[starts[[index]]:ends[[index]]]
    resource_require(
      all(grepl("^[A-Za-z][A-Za-z0-9-]*:[[:space:]]+[^[:space:]].*$", block)),
      "dcf_layout", "Every DCF field must be one non-empty single line."
    )
    field_names <- sub(":.*$", "", block)
    resource_require(
      !anyDuplicated(field_names), "dcf_fields",
      "A DCF record contains a duplicate field."
    )
    connection <- textConnection(block)
    parsed <- tryCatch(
      read.dcf(connection, all = TRUE),
      error = function(condition) resource_fail(
        "dcf_parse", paste0("DCF parsing failed: ", conditionMessage(condition))
      ),
      finally = close(connection)
    )
    resource_require(
      nrow(parsed) == 1L, "dcf_layout",
      "Each parsed DCF block must contain exactly one record."
    )
    setNames(as.list(as.character(parsed[1L, ])), colnames(parsed))
  })
}

write_dcf_records <- function(records, path) {
  parent <- dirname(path)
  if (!dir.exists(parent)) dir.create(parent, recursive = TRUE)
  lines <- unlist(lapply(seq_along(records), function(index) {
    record <- records[[index]]
    record_lines <- paste0(names(record), ": ", unlist(record, use.names = FALSE))
    if (index < length(records)) c(record_lines, "") else record_lines
  }), use.names = FALSE)
  writeLines(lines, path, useBytes = TRUE)
}

resource_schema_expected <- function() {
  c(
    "Record-Type" = "resource-catalog-schema",
    "Schema-ID" = "rrp.resource-catalog-schema",
    "Schema-Version" = "0.1.0",
    "Format-Version" = "1.0.0",
    "Catalog-Record-Type" = "catalog",
    "Resource-Record-Type" = "resource",
    "Catalog-ID" = "rrp.software-resources",
    "Catalog-Version" = "0.1.0",
    "Source-Catalog-Path" = "resources/source-catalog.dcf",
    "Installed-Catalog-Path" = "resources/resource-catalog.dcf",
    "Catalog-Fields" = paste(c(
      "Record-Type", "Catalog-ID", "Catalog-Version", "Format-Version",
      "Product-ID", "Development-Version", "Status"
    ), collapse = ","),
    "Source-Resource-Fields" = paste(c(
      "Record-Type", "Resource-ID", "Resource-Class", "Owner-Package",
      "Source-Path", "Installed-Path", "Format"
    ), collapse = ","),
    "Installed-Resource-Fields" = paste(c(
      "Record-Type", "Resource-ID", "Resource-Class", "Owner-Package",
      "Installed-Path", "Format"
    ), collapse = ","),
    "Resource-ID-Pattern" = "^rrp[.][a-z0-9]+(?:[.][a-z0-9-]+)+$",
    "Resource-Classes" = paste(c(
      "contract", "default", "template", "documentation",
      "static_application_asset"
    ), collapse = ","),
    "Owner-Packages" = "rrpplatform,rrpruntime",
    "Resource-Formats" = "dcf,r",
    "Status-Values" = "development_unpublished",
    "Unique-Fields" = "Resource-ID,Source-Path,Installed-Path",
    "Case-Folded-Path-Fields" = "Source-Path,Installed-Path",
    "Safe-Relative-Paths" = "true",
    "File-Directory-Conflicts-Prohibited" = "true",
    "Linked-Sources-Prohibited" = "true",
    "Regular-Sources-Required" = "true",
    "Closed-Source-Inventory" = "true",
    "Projection-Omitted-Fields" = "Source-Path"
  )
}

validate_exact_fields <- function(record, expected_fields, code, label) {
  missing_fields <- setdiff(expected_fields, names(record))
  unknown_fields <- setdiff(names(record), expected_fields)
  resource_require(
    length(missing_fields) == 0L && length(unknown_fields) == 0L,
    code,
    paste0(
      label, " fields must be exact; missing: ",
      if (length(missing_fields)) paste(missing_fields, collapse = ", ") else "none",
      "; unknown: ",
      if (length(unknown_fields)) paste(unknown_fields, collapse = ", ") else "none",
      "."
    )
  )
}

canonical_contract_resources <- function() {
  envelope <- c(
    "Record-Type" = "specification",
    "Specification-Kind" = "specification-envelope",
    "Specification-ID" = "rrp.specification-envelope",
    "Specification-Version" = "0.1.0",
    "Specification-Format-Version" = "1.0.0",
    "Identity-Scope" = "platform", "Status" = "development_unpublished",
    "Product-ID" = "readmission-risk-pool-platform",
    "Development-Version" = "1.0.0-dev", "Owner-Package" = "rrpplatform",
    "Required-Envelope-Fields" = paste(c(
      "Record-Type", "Specification-Kind", "Specification-ID",
      "Specification-Version", "Specification-Format-Version",
      "Identity-Scope", "Status", "Product-ID", "Development-Version",
      "Owner-Package"
    ), collapse = ","),
    "Allowed-Specification-Kinds" = paste(c(
      "specification-envelope", "canonical-producer-contract",
      "canonical-bundle-contract", "canonical-profile", "canonical-domain",
      "risk-target", "episode-state-contract", "risk-request-contract",
      "risk-provider-contract", "risk-estimate-contract"
    ), collapse = ","),
    "Specification-ID-Pattern" = "^rrp[.][a-z0-9]+(?:[.-][a-z0-9]+)+$",
    "Specification-Version-Pattern" = paste0(
      "^[0-9]+[.][0-9]+[.][0-9]+",
      "(?:-[0-9A-Za-z]+(?:[.-][0-9A-Za-z]+)*)?$"
    ),
    "Compatibility-Rule" = "exact_version", "Unknown-Fields" = "prohibited",
    "Additional-Records" = "prohibited", "Executable-Content" = "prohibited"
  )
  producer <- c(
    envelope[c(
      "Record-Type", "Specification-Kind", "Specification-ID",
      "Specification-Version", "Specification-Format-Version",
      "Identity-Scope", "Status", "Product-ID", "Development-Version",
      "Owner-Package"
    )],
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
      "producer_unavailable", "producer_source_failed", "producer_mapping_failed"
    ), collapse = ","),
    "Unknown-Fields" = "prohibited", "Additional-Records" = "prohibited",
    "Executable-Configuration" = "prohibited"
  )
  producer[["Specification-Kind"]] <- "canonical-producer-contract"
  producer[["Specification-ID"]] <- "rrp.canonical-producer"
  bundle <- c(
    producer[c(
      "Record-Type", "Specification-Kind", "Specification-ID",
      "Specification-Version", "Specification-Format-Version",
      "Identity-Scope", "Status", "Product-ID", "Development-Version",
      "Owner-Package"
    )],
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
    "Identity-Agreement" = "project,producer,implementation,mapping,profile,capabilities,as_of",
    "Initial-Adapter" = "closed_named_record_with_tabular_domains",
    "Unknown-Fields" = "prohibited", "Additional-Records" = "prohibited",
    "Executable-Content" = "prohibited"
  )
  bundle[["Specification-Kind"]] <- "canonical-bundle-contract"
  bundle[["Specification-ID"]] <- "rrp.canonical-bundle"
  bundle[["Owner-Package"]] <- "rrpruntime"
  profile <- c(
    bundle[c(
      "Record-Type", "Specification-Kind", "Specification-ID",
      "Specification-Version", "Specification-Format-Version",
      "Identity-Scope", "Status", "Product-ID", "Development-Version",
      "Owner-Package", "Canonical-Profile-ID", "Canonical-Profile-Version"
    )],
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
    "Capability-Status" = "available", "Unknown-Domains" = "prohibited",
    "Unknown-Capabilities" = "prohibited", "Additional-Records" = "prohibited"
  )
  profile[["Specification-Kind"]] <- "canonical-profile"
  profile[["Specification-ID"]] <- "rrp.canonical-profile.readmission"
  names(profile)[names(profile) == "Canonical-Profile-ID"] <- "Canonical-Bundle-ID"
  names(profile)[names(profile) == "Canonical-Profile-Version"] <- "Canonical-Bundle-Version"
  profile[["Canonical-Bundle-ID"]] <- "rrp.canonical-bundle"
  domain_prefix <- bundle[c(
    "Record-Type", "Specification-Kind", "Specification-ID",
    "Specification-Version", "Specification-Format-Version", "Identity-Scope",
    "Status", "Product-ID", "Development-Version", "Owner-Package"
  )]
  domain_prefix[["Specification-Kind"]] <- "canonical-domain"
  discharge <- c(
    domain_prefix,
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
    "Available-Row-Cardinality" = "zero_or_more", "Null-Fields" = "none",
    "Unknown-Fields" = "prohibited", "Additional-Records" = "prohibited"
  )
  discharge[["Specification-ID"]] <- "rrp.canonical-domain.discharge-episode"
  terminal <- c(
    domain_prefix,
    "Domain-ID" = "terminal_event",
    "Capability-ID" = "rrp.capability.terminal-event",
    "Fields" = "terminal_event_id,episode_id,event_type,occurred_at,available_at",
    "Primary-Key" = "terminal_event_id",
    "Episode-Reference-Field" = "episode_id",
    "Episode-Reference-Domain" = "discharge_episode",
    "Event-Type-Field" = "event_type", "Event-Type-Values" = "readmission,death",
    "Occurrence-Field" = "occurred_at", "Availability-Field" = "available_at",
    "Timestamp-Representation" = "rfc3339_explicit_offset",
    "Occurrence-After-Discharge" = "required",
    "Occurrence-Through-Followup-End" = "required",
    "Availability-Not-Before-Occurrence" = "required",
    "Availability-Not-After-Bundle-As-Of" = "required",
    "Maximum-Per-Episode-And-Type" = "1",
    "Equal-Readmission-Death-Time" = "allowed",
    "Death-Before-Later-Readmission" = "prohibited",
    "Available-Row-Cardinality" = "zero_or_more", "Null-Fields" = "none",
    "Unknown-Fields" = "prohibited", "Additional-Records" = "prohibited"
  )
  terminal[["Specification-ID"]] <- "rrp.canonical-domain.terminal-event"
  specifications <- list(
    canonical_envelope = list(
      id = "rrp.contract.specification-envelope", owner = "rrpplatform",
      path = "resources/contracts/canonical/specification-envelope.dcf",
      document = envelope
    ),
    canonical_producer = list(
      id = "rrp.contract.canonical-producer", owner = "rrpplatform",
      path = "resources/contracts/canonical/canonical-producer.dcf",
      document = producer
    ),
    canonical_bundle = list(
      id = "rrp.contract.canonical-bundle", owner = "rrpruntime",
      path = "resources/contracts/canonical/canonical-bundle.dcf",
      document = bundle
    ),
    readmission_profile = list(
      id = "rrp.profile.readmission", owner = "rrpruntime",
      path = "resources/contracts/canonical/profiles/readmission.dcf",
      document = profile
    ),
    discharge_episode = list(
      id = "rrp.domain.discharge-episode", owner = "rrpruntime",
      path = "resources/contracts/canonical/domains/discharge-episode.dcf",
      document = discharge
    ),
    terminal_event = list(
      id = "rrp.domain.terminal-event", owner = "rrpruntime",
      path = "resources/contracts/canonical/domains/terminal-event.dcf",
      document = terminal
    )
  )
  lapply(specifications, function(specification) {
    specification$source_path <- specification$path
    specification$installed_path <- specification$path
    specification$path <- NULL
    specification
  })
}

runtime_contract_resources <- function() {
  target <- c(
    "Record-Type" = "specification", "Specification-Kind" = "risk-target",
    "Specification-ID" = "rrp.risk-target.readmission-remaining-30-day",
    "Specification-Version" = "0.1.0",
    "Specification-Format-Version" = "1.0.0",
    "Identity-Scope" = "platform", "Status" = "development_unpublished",
    "Product-ID" = "readmission-risk-pool-platform",
    "Development-Version" = "1.0.0-dev", "Owner-Package" = "rrpruntime",
    "Canonical-Profile-ID" = "rrp.canonical-profile.readmission",
    "Canonical-Profile-Version" = "0.1.0",
    "Population" = "all_admitted_profile_episodes",
    "Event" = "first_canonical_readmission",
    "Readmission-Plannedness" = "not_distinguished",
    "Origin" = "discharge_time",
    "Endpoint-Definition" = "discharge_plus_elapsed_seconds",
    "Endpoint-Elapsed-Seconds" = "2592000",
    "Endpoint-Inclusion" = "included",
    "Eligible-As-Of-Interval" = "[D,W30)",
    "Target-Interval" = "(t,W30]",
    "Conditioning" = "alive_and_readmission_free_through_t",
    "Information-Cutoff" = "occurred_and_available_through_t",
    "Competing-Event" = "death",
    "Equal-Time-Precedence" = "readmission",
    "Output-Quantity" = "probability", "Output-Cardinality" = "one",
    "Output-Minimum" = "0", "Output-Maximum" = "1",
    "Target-Selection" = "prohibited",
    "Eligibility-Failure-Codes" = paste(c(
      "invalid_analytical_as_of", "analytical_as_of_mismatch",
      "unknown_episode", "episode_before_discharge",
      "target_horizon_exhausted", "episode_already_readmitted",
      "episode_already_dead"
    ), collapse = ","),
    "Unknown-Fields" = "prohibited", "Additional-Records" = "prohibited",
    "Executable-Content" = "prohibited"
  )
  state <- c(
    "Record-Type" = "specification",
    "Specification-Kind" = "episode-state-contract",
    "Specification-ID" = "rrp.episode-state",
    "Specification-Version" = "0.1.0",
    "Specification-Format-Version" = "1.0.0",
    "Identity-Scope" = "platform", "Status" = "development_unpublished",
    "Product-ID" = "readmission-risk-pool-platform",
    "Development-Version" = "1.0.0-dev", "Owner-Package" = "rrpruntime",
    "Target-ID" = target[["Specification-ID"]],
    "Target-Version" = target[["Specification-Version"]],
    "Canonical-Bundle-ID" = "rrp.canonical-bundle",
    "Canonical-Bundle-Version" = "0.1.0",
    "Canonical-Profile-ID" = "rrp.canonical-profile.readmission",
    "Canonical-Profile-Version" = "0.1.0",
    "Object-Class" = "rrp_episode_state,list",
    "State-Fields" = paste(c(
      "state_contract_id", "state_contract_version", "state_id", "target_id",
      "target_version", "bundle_contract_id", "bundle_contract_version",
      "bundle_instance_id", "project_id", "project_version",
      "canonical_profile_id", "canonical_profile_version", "episode_id",
      "as_of_time", "discharge_time", "target_window_end",
      "elapsed_seconds_since_discharge", "remaining_seconds_through_w30",
      "terminal_status"
    ), collapse = ","),
    "Timestamp-Fields" = "as_of_time,discharge_time,target_window_end",
    "Timestamp-Representation" = "rfc3339_utc",
    "Elapsed-Fields" = paste(c(
      "elapsed_seconds_since_discharge", "remaining_seconds_through_w30"
    ), collapse = ","),
    "Elapsed-Unit" = "seconds",
    "Terminal-Status-Value" = "none_available_through_as_of",
    "State-ID-Prefix" = "rrp.state.",
    "State-ID-Algorithm" = "dual_modular_hash_v1",
    "State-ID-Inputs" = paste(c(
      "bundle_contract_id", "bundle_contract_version", "bundle_instance_id",
      "project_id", "project_version", "canonical_profile_id",
      "canonical_profile_version", "episode_id", "as_of_time",
      "discharge_time", "target_window_end", "target_id", "target_version",
      "state_contract_id", "state_contract_version"
    ), collapse = ","),
    "Expected-Context-Fields" = paste(c(
      "product_id", "development_version", "target_id", "target_version",
      "state_contract_id", "state_contract_version", "bundle_contract_id",
      "bundle_contract_version", "canonical_profile_id",
      "canonical_profile_version", "target_event", "conditioning",
      "endpoint_elapsed_seconds", "eligible_as_of_start",
      "eligible_as_of_end", "target_interval", "information_cutoff",
      "competing_event", "equal_time_precedence", "target_selection",
      "terminal_status"
    ), collapse = ","),
    "Construction" = "eligible_only", "Detached-Plain-Value" = "required",
    "Reference-Bearing-Values" = "prohibited",
    "Unknown-Fields" = "prohibited", "Additional-Records" = "prohibited",
    "Executable-Content" = "prohibited"
  )
  request <- c(
    "Record-Type" = "specification",
    "Specification-Kind" = "risk-request-contract",
    "Specification-ID" = "rrp.risk-request",
    "Specification-Version" = "0.1.0",
    "Specification-Format-Version" = "1.0.0",
    "Identity-Scope" = "platform", "Status" = "development_unpublished",
    "Product-ID" = "readmission-risk-pool-platform",
    "Development-Version" = "1.0.0-dev", "Owner-Package" = "rrpruntime",
    "Target-ID" = target[["Specification-ID"]],
    "Target-Version" = target[["Specification-Version"]],
    "State-Contract-ID" = state[["Specification-ID"]],
    "State-Contract-Version" = state[["Specification-Version"]],
    "Object-Class" = "rrp_risk_request,list",
    "Request-Fields" = paste(c(
      "request_contract_id", "request_contract_version", "request_id",
      "target_id", "target_version", "state_contract_id",
      "state_contract_version", "state_id", "bundle_instance_id",
      "project_id", "project_version", "episode_id", "as_of_time",
      "discharge_time", "target_interval_start", "target_interval_end",
      "target_interval_boundary", "elapsed_seconds_since_discharge",
      "remaining_seconds_through_w30"
    ), collapse = ","),
    "Timestamp-Fields" = paste(c(
      "as_of_time", "discharge_time", "target_interval_start",
      "target_interval_end"
    ), collapse = ","),
    "Timestamp-Representation" = "rfc3339_utc",
    "Elapsed-Fields" = paste(c(
      "elapsed_seconds_since_discharge", "remaining_seconds_through_w30"
    ), collapse = ","),
    "Elapsed-Unit" = "seconds",
    "Target-Interval-Boundary" = "(start,end]",
    "Request-ID-Prefix" = "rrp.request.",
    "Request-ID-Algorithm" = "dual_modular_hash_v1",
    "Request-ID-Inputs" = paste(c(
      "request_contract_id", "request_contract_version", "target_id",
      "target_version", "state_contract_id", "state_contract_version",
      "state_id", "bundle_instance_id", "project_id", "project_version",
      "episode_id", "as_of_time", "discharge_time", "target_interval_start",
      "target_interval_end", "target_interval_boundary",
      "elapsed_seconds_since_discharge", "remaining_seconds_through_w30"
    ), collapse = ","),
    "Provider-Identity" = "prohibited",
    "Detached-Plain-Value" = "required",
    "Reference-Bearing-Values" = "prohibited",
    "Unknown-Fields" = "prohibited", "Additional-Records" = "prohibited",
    "Executable-Content" = "prohibited"
  )
  provider <- c(
    "Record-Type" = "specification",
    "Specification-Kind" = "risk-provider-contract",
    "Specification-ID" = "rrp.provider-api",
    "Specification-Version" = "0.1.0",
    "Specification-Format-Version" = "1.0.0",
    "Identity-Scope" = "platform", "Status" = "development_unpublished",
    "Product-ID" = "readmission-risk-pool-platform",
    "Development-Version" = "1.0.0-dev", "Owner-Package" = "rrpruntime",
    "Target-ID" = target[["Specification-ID"]],
    "Target-Version" = target[["Specification-Version"]],
    "State-Contract-ID" = state[["Specification-ID"]],
    "State-Contract-Version" = state[["Specification-Version"]],
    "Request-Contract-ID" = request[["Specification-ID"]],
    "Request-Contract-Version" = request[["Specification-Version"]],
    "Estimate-Contract-ID" = "rrp.risk-estimate",
    "Estimate-Contract-Version" = "0.1.0",
    "Provider-Declaration-Fields" = paste(c(
      "component_id", "component_version", "provider_api_id",
      "provider_api_version", "target_id", "target_version",
      "state_contract_id", "state_contract_version", "request_contract_id",
      "request_contract_version", "estimate_contract_id",
      "estimate_contract_version", "implementation_id",
      "implementation_version", "model_id", "model_version", "callable"
    ), collapse = ","),
    "Model-Identity-Rule" = "both_null_or_both_bounded",
    "Callable-Arguments" = "request",
    "Callable-Invocation" = "exactly_once_after_compatibility",
    "Result-Fields" = "request_id,status,estimate_value,failure_code",
    "Result-Status-Values" = "success,failure",
    "Failure-Codes" = paste(c(
      "provider_unavailable", "provider_input_unavailable",
      "provider_calculation_failed"
    ), collapse = ","),
    "Runtime-Failure-Codes" = paste(c(
      "provider_incompatible", "provider_execution_failed",
      "invalid_provider_result", "provider_result_identity_mismatch",
      "invalid_estimate"
    ), collapse = ","),
    "Unknown-Fields" = "prohibited", "Additional-Records" = "prohibited",
    "Executable-Configuration" = "prohibited"
  )
  estimate <- c(
    "Record-Type" = "specification",
    "Specification-Kind" = "risk-estimate-contract",
    "Specification-ID" = "rrp.risk-estimate",
    "Specification-Version" = "0.1.0",
    "Specification-Format-Version" = "1.0.0",
    "Identity-Scope" = "platform", "Status" = "development_unpublished",
    "Product-ID" = "readmission-risk-pool-platform",
    "Development-Version" = "1.0.0-dev", "Owner-Package" = "rrpruntime",
    "Target-ID" = target[["Specification-ID"]],
    "Target-Version" = target[["Specification-Version"]],
    "State-Contract-ID" = state[["Specification-ID"]],
    "State-Contract-Version" = state[["Specification-Version"]],
    "Request-Contract-ID" = request[["Specification-ID"]],
    "Request-Contract-Version" = request[["Specification-Version"]],
    "Provider-API-ID" = provider[["Specification-ID"]],
    "Provider-API-Version" = provider[["Specification-Version"]],
    "Object-Class" = "rrp_risk_estimate,list",
    "Estimate-Fields" = paste(c(
      "estimate_contract_id", "estimate_contract_version",
      "request_contract_id", "request_contract_version", "request_id",
      "state_contract_id", "state_contract_version", "state_id",
      "target_id", "target_version", "product_id", "development_version",
      "bundle_instance_id", "project_id", "project_version", "episode_id",
      "as_of_time", "target_interval_start", "target_interval_end",
      "target_interval_boundary", "provider_id", "provider_version",
      "implementation_id", "implementation_version", "model_id",
      "model_version", "output_type", "estimate_value"
    ), collapse = ","),
    "Nullable-Fields" = "model_id,model_version",
    "Model-Identity-Rule" = "both_null_or_both_bounded",
    "Timestamp-Fields" = "as_of_time,target_interval_start,target_interval_end",
    "Timestamp-Representation" = "rfc3339_utc",
    "Target-Interval-Boundary" = "(start,end]",
    "Output-Type" = "probability", "Output-Cardinality" = "one",
    "Output-Minimum" = "0", "Output-Maximum" = "1",
    "Output-Value-Type" = "unclassed_base_double",
    "Detached-Plain-Value" = "required",
    "Reference-Bearing-Values" = "prohibited",
    "Unknown-Fields" = "prohibited", "Additional-Records" = "prohibited",
    "Executable-Content" = "prohibited"
  )
  list(
    readmission_risk_target = list(
      id = "rrp.target.readmission-risk", owner = "rrpruntime",
      source_path = "resources/contracts/runtime/readmission-risk-target.dcf",
      installed_path = "resources/contracts/runtime/readmission-risk-target.dcf",
      document = target
    ),
    episode_state = list(
      id = "rrp.contract.episode-state", owner = "rrpruntime",
      source_path = "resources/contracts/runtime/episode-state.dcf",
      installed_path = "resources/contracts/runtime/episode-state.dcf",
      document = state
    ),
    risk_request = list(
      id = "rrp.contract.risk-request", owner = "rrpruntime",
      source_path = "resources/contracts/runtime/risk-request.dcf",
      installed_path = "resources/contracts/runtime/risk-request.dcf",
      document = request
    ),
    risk_provider = list(
      id = "rrp.contract.risk-provider", owner = "rrpruntime",
      source_path = "resources/contracts/runtime/risk-provider.dcf",
      installed_path = "resources/contracts/runtime/risk-provider.dcf",
      document = provider
    ),
    risk_estimate = list(
      id = "rrp.contract.risk-estimate", owner = "rrpruntime",
      source_path = "resources/contracts/runtime/risk-estimate.dcf",
      installed_path = "resources/contracts/runtime/risk-estimate.dcf",
      document = estimate
    )
  )
}

history_contract_resources <- function() {
  common <- c(
    "Record-Type" = "history-contract",
    "Contract-Version" = "0.1.0",
    "Format-Version" = "1.0.0",
    "Product-ID" = "readmission-risk-pool-platform",
    "Development-Version" = "1.0.0-dev",
    "Status" = "development_unpublished",
    "Owner-Package" = "rrpruntime"
  )
  scope <- c(
    common["Record-Type"],
    "Contract-ID" = "rrp.history.operational-scope",
    common[names(common) != "Record-Type"],
    "Object-Class" = "rrp_operational_scope,list",
    "Fields" = paste(c(
      "scope_contract_id", "scope_contract_version", "scope_record_id",
      "named_operation_id", "operation_run_id", "operation_key", "state_id",
      "product_id", "development_version", "rrp_api_version", "project_api_id",
      "project_api_version", "project_id", "project_version", "bundle_contract_id",
      "bundle_contract_version", "bundle_instance_id", "canonical_profile_id",
      "canonical_profile_version", "producer_id", "producer_version",
      "producer_implementation_id", "producer_implementation_version",
      "mapping_id", "mapping_version", "target_id", "target_version",
      "analytical_time", "expected_episode_count", "membership_encoding",
      "membership_fingerprint_algorithm", "membership_fingerprint", "created_at"
    ), collapse = ","),
    "Named-Operation-ID" = "rrp.operation.evaluate-admitted-bundle",
    "Operation-Run-ID-Prefix" = "rrp.operation-run.",
    "Operation-Run-ID-Algorithm" = "dual_modular_hash_v1",
    "Operation-Run-ID-Inputs" = "state_id,named_operation_id,operation_key",
    "Scope-Record-ID-Prefix" = "rrp.scope.",
    "Scope-Record-ID-Algorithm" = "dual_modular_hash_v1",
    "Scope-Record-ID-Inputs" = paste(c(
      "scope_contract_id", "scope_contract_version", "operation_run_id"
    ), collapse = ","),
    "Membership-Encoding" = "utf8_length_prefixed_sorted_unique_v1",
    "Membership-Fingerprint-Algorithm" = "dual_modular_hash_v1",
    "Membership-Fingerprint-Prefix" = "rrp.membership.",
    "Membership-Inputs" = "sorted_unique_episode_ids",
    "Expected-Episode-Count-Type" = "nonnegative_integer",
    "Completion-Rule" = "initial_disposition_count_and_membership_fingerprint_match",
    "Mutable-Completion-Flag" = "prohibited",
    "Full-Canonical-Bundle" = "prohibited",
    "Second-Episode-Manifest" = "prohibited",
    "Timestamp-Fields" = "analytical_time,created_at",
    "Timestamp-Representation" = "rfc3339_utc",
    "Timestamp-Order" = "analytical_time<=created_at",
    "Unknown-Fields" = "prohibited",
    "Reference-Bearing-Values" = "prohibited"
  )
  disposition <- c(
    common["Record-Type"],
    "Contract-ID" = "rrp.history.episode-disposition",
    common[names(common) != "Record-Type"],
    "Object-Class" = "rrp_episode_disposition,list",
    "Fields" = paste(c(
      "disposition_contract_id", "disposition_contract_version",
      "disposition_record_id", "operation_run_id", "analytical_run_id",
      "analytical_kind", "related_analytical_run_id", "analytical_key",
      "episode_id", "patient_id", "target_id", "target_version",
      "analytical_time", "outcome", "outcome_code", "eligibility_status",
      "state", "request", "provider_id", "provider_version", "implementation_id",
      "implementation_version", "model_id", "model_version",
      "provider_execution_id", "provider_status", "estimate_record_id",
      "estimate", "terminal_time"
    ), collapse = ","),
    "Analytical-Kinds" = "initial,retry,restatement",
    "Initial-Analytical-ID-Prefix" = "rrp.analysis.",
    "Initial-Analytical-ID-Algorithm" = "dual_modular_hash_v1",
    "Initial-Analytical-ID-Inputs" = paste(c(
      "operation_run_id", "episode_id", "target_id", "target_version",
      "analytical_time", "initial"
    ), collapse = ","),
    "Later-Analytical-ID-Inputs" = paste(c(
      "operation_run_id", "episode_id", "target_id", "target_version",
      "analytical_time", "analytical_kind", "related_analytical_run_id",
      "analytical_key"
    ), collapse = ","),
    "Nullable-ID-Encoding" = "literal_null_token_v1",
    "Disposition-Record-ID-Prefix" = "rrp.disposition.",
    "Disposition-Record-ID-Algorithm" = "dual_modular_hash_v1",
    "Disposition-Record-ID-Inputs" = paste(c(
      "disposition_contract_id", "disposition_contract_version",
      "analytical_run_id"
    ), collapse = ","),
    "Provider-Execution-ID-Prefix" = "rrp.provider-execution.",
    "Provider-Execution-ID-Algorithm" = "dual_modular_hash_v1",
    "Provider-Execution-ID-Inputs" = paste(c(
      "analytical_run_id", "request_id", "provider_id", "provider_version",
      "implementation_id", "implementation_version", "model_id", "model_version"
    ), collapse = ","),
    "Estimate-Record-ID-Prefix" = "rrp.estimate-record.",
    "Estimate-Record-ID-Algorithm" = "dual_modular_hash_v1",
    "Estimate-Record-ID-Inputs" = paste(c(
      "provider_execution_id", "estimate_contract_id", "estimate_contract_version",
      "request_id", "estimate_value"
    ), collapse = ","),
    "Outcome-Values" = paste(c(
      "ineligible", "accepted_estimate", "provider_incompatible",
      "provider_declared_failure", "detected_failure"
    ), collapse = ","),
    "Eligibility-Values" = "eligible,ineligible",
    "Provider-Status-Values" = "not_invoked,succeeded,declared_failure,detected_failure",
    "Ineligible-Codes" = paste(c(
      "episode_before_discharge", "target_horizon_exhausted",
      "episode_already_readmitted", "episode_already_dead"
    ), collapse = ","),
    "Declared-Failure-Codes" = paste(c(
      "provider_unavailable", "provider_input_unavailable",
      "provider_calculation_failed"
    ), collapse = ","),
    "Detected-Failure-Codes" = paste(c(
      "provider_execution_failed", "invalid_provider_result",
      "provider_result_identity_mismatch", "invalid_estimate"
    ), collapse = ","),
    "Accepted-Outcome-Code" = "estimate_accepted",
    "Timestamp-Fields" = "analytical_time,terminal_time",
    "Timestamp-Representation" = "rfc3339_utc",
    "Timestamp-Order" = "analytical_time<=terminal_time",
    "Unknown-Fields" = "prohibited",
    "Reference-Bearing-Values" = "prohibited"
  )
  action <- c(
    common["Record-Type"],
    "Contract-ID" = "rrp.history.action",
    common[names(common) != "Record-Type"],
    "Object-Class" = "rrp_history_action,list",
    "Fields" = paste(c(
      "action_contract_id", "action_contract_version", "action_id", "target_kind",
      "target_id", "target_operation_run_id", "action_type", "effective_time",
      "reason_code", "replacement_operation_run_id",
      "replacement_analytical_run_id", "actor_category"
    ), collapse = ","),
    "Target-Kinds" = "analytical_run,operational_scope",
    "Action-Types" = "invalidate,restate",
    "Reason-Codes" = paste(c(
      "incorrect_input", "incorrect_scope", "incorrect_provenance",
      "superseded_result"
    ), collapse = ","),
    "Actor-Categories" = "maintainer,operator",
    "Action-ID-Prefix" = "rrp.history-action.",
    "Action-ID-Algorithm" = "dual_modular_hash_v1",
    "Action-ID-Inputs" = paste(c(
      "action_contract_id", "action_contract_version", "target_kind", "target_id",
      "target_operation_run_id", "action_type", "effective_time", "reason_code",
      "replacement_operation_run_id", "replacement_analytical_run_id",
      "actor_category"
    ), collapse = ","),
    "Nullable-ID-Encoding" = "literal_null_token_v1",
    "Episode-Correction" = "normal",
    "Scope-Correction" = "shared_admission_or_provenance_only",
    "Mutation-Or-Deletion" = "prohibited",
    "Free-Text-Reason" = "prohibited",
    "Timestamp-Fields" = "effective_time",
    "Timestamp-Representation" = "rfc3339_utc",
    "Unknown-Fields" = "prohibited",
    "Reference-Bearing-Values" = "prohibited"
  )
  port <- c(
    common["Record-Type"],
    "Contract-ID" = "rrp.history.port",
    common[names(common) != "Record-Type"],
    "Object-Class" = "rrp_history_port,list",
    "Adapter-Fields" = paste(c(
      "adapter_id", "adapter_version", "contract_id", "contract_version",
      "capabilities", "methods"
    ), collapse = ","),
    "Required-Methods" = paste(c(
      "append_scope", "append_disposition", "append_action",
      "append_restatement", "read_scope_history", "read_episode_history"
    ), collapse = ","),
    "Required-Capabilities" = paste(c(
      "atomic_scope_append", "atomic_episode_append",
      "atomic_restatement_append", "identical_append_idempotency",
      "conflicting_identity_rejection", "immutable_raw_retention",
      "bounded_raw_reads", "detached_reads"
    ), collapse = ","),
    "Logical-Operations" = paste(c(
      "append_or_match_scope", "append_episode_disposition",
      "append_invalidation", "append_restatement", "read_scope_progress",
      "read_raw_episode_history", "resolve_current_episode_history"
    ), collapse = ","),
    "Validate-Before-Delegate" = "required",
    "Validate-After-Read" = "required",
    "Detached-Records" = "required",
    "Physical-Storage-Vocabulary" = "prohibited",
    "Close-Reopen-Durability" = "deferred_to_physical_adapter",
    "Current-History-Owner" = "rrpruntime",
    "Unknown-Fields" = "prohibited",
    "Reference-Bearing-Values" = "adapter_methods_only"
  )
  list(
    history_operational_scope = list(
      id = "rrp.contract.history-operational-scope", owner = "rrpruntime",
      source_path = "resources/contracts/history/operational-scope.dcf",
      installed_path = "resources/contracts/history/operational-scope.dcf",
      document = scope
    ),
    history_episode_disposition = list(
      id = "rrp.contract.history-episode-disposition", owner = "rrpruntime",
      source_path = "resources/contracts/history/episode-disposition.dcf",
      installed_path = "resources/contracts/history/episode-disposition.dcf",
      document = disposition
    ),
    history_action = list(
      id = "rrp.contract.history-action", owner = "rrpruntime",
      source_path = "resources/contracts/history/history-action.dcf",
      installed_path = "resources/contracts/history/history-action.dcf",
      document = action
    ),
    history_port = list(
      id = "rrp.contract.history-port", owner = "rrpruntime",
      source_path = "resources/contracts/history/history-port.dcf",
      installed_path = "resources/contracts/history/history-port.dcf",
      document = port
    )
  )
}

software_contract_resources <- function() {
  resources <- list(
    diagnostic = list(
      id = "rrp.contract.diagnostic",
      source_path = "resources/contracts/diagnostic.dcf",
      installed_path = "resources/contracts/diagnostic.dcf",
      document = c(
        "Record-Type" = "contract",
        "Contract-ID" = "rrp.contract.diagnostic",
        "Contract-Version" = "0.1.0",
        "Format-Version" = "1.0.0",
        "Product-ID" = "readmission-risk-pool-platform",
        "Development-Version" = "1.0.0-dev",
        "Status" = "development_unpublished",
        "Owner-Package" = "rrpplatform",
        "Object-Class" = "rrp_diagnostic,list",
        "Fields" = "code,severity,message",
        "Code-Pattern" = "^[a-z][a-z0-9_]*$",
        "Code-Max-Bytes" = "64",
        "Severity-Values" = "info,warning,error",
        "Message-Max-Bytes" = "240",
        "Message-Empty" = "prohibited",
        "Message-Control-Characters" = "prohibited",
        "Message-Sensitive-Text" = "prohibited",
        "Message-Path-Like-Text" = "prohibited",
        "Additional-Fields" = "prohibited"
      )
    ),
    operation_result = list(
      id = "rrp.contract.operation-result",
      source_path = "resources/contracts/operation-result.dcf",
      installed_path = "resources/contracts/operation-result.dcf",
      document = c(
        "Record-Type" = "contract",
        "Contract-ID" = "rrp.contract.operation-result",
        "Contract-Version" = "0.1.0",
        "Format-Version" = "1.0.0",
        "Product-ID" = "readmission-risk-pool-platform",
        "Development-Version" = "1.0.0-dev",
        "Status" = "development_unpublished",
        "Owner-Package" = "rrpplatform",
        "Object-Class" = "rrp_operation_result,list",
        "Fields" = "operation_id,status,value,diagnostics",
        "Operation-ID-Pattern" = "^rrp[.][a-z0-9]+(?:[.-][a-z0-9]+)*$",
        "Operation-ID-Max-Bytes" = "96",
        "Status-Values" = "success,failure",
        "Diagnostic-Contract" = "rrp.contract.diagnostic@0.1.0",
        "Diagnostics-Ordering" = "preserved",
        "Success-Error-Diagnostics" = "prohibited",
        "Failure-Error-Diagnostics" = "one_or_more",
        "Failure-Value" = "null",
        "Additional-Fields" = "prohibited"
      )
    ),
    project_manifest = list(
      id = "rrp.contract.project-manifest",
      source_path = "resources/contracts/project-manifest.dcf",
      installed_path = "resources/contracts/project-manifest.dcf",
      document = c(
        "Record-Type" = "project-manifest-contract",
        "Contract-ID" = "rrp.project",
        "Contract-Version" = "0.3.0",
        "Format-Version" = "1.0.0",
        "Product-ID" = "readmission-risk-pool-platform",
        "Development-Version" = "1.0.0-dev",
        "Status" = "development_unpublished",
        "Owner-Package" = "rrpplatform",
        "Manifest-Path" = "rrp-project.dcf",
        "Registration-Path" = "R/register.R",
        "Manifest-Record-Type" = "rrp-project",
        "Project-API-ID" = "rrp.project-api",
        "Project-API-Version" = "0.3.0",
        "Fields" = paste(c(
          "Record-Type", "Project-Contract-ID", "Project-Contract-Version",
          "Project-ID", "Project-Version", "Project-Scope",
          "Supported-RRP-API-Version", "Canonical-Profile-ID",
          "Canonical-Profile-Version", "Producer-ID", "Producer-Version",
          "Provider-ID", "Provider-Version", "Extension-Library-Path", "State-Path"
        ), collapse = ","),
        "Optional-Fields" = "none",
        "Identity-Fields" = "Project-ID,Producer-ID,Provider-ID",
        "Project-ID-Pattern" = "^[a-z][a-z0-9]*(?:[.-][a-z0-9]+)*$",
        "Identity-Max-Bytes" = "96",
        "Protected-Project-ID-Prefix" = "rrp.",
        "Version-Fields" = paste(c(
          "Project-Version", "Canonical-Profile-Version", "Producer-Version",
          "Provider-Version"
        ), collapse = ","),
        "Version-Pattern" = paste0(
          "^[0-9]+[.][0-9]+[.][0-9]+",
          "(?:-[0-9A-Za-z]+(?:[.-][0-9A-Za-z]+)*)?$"
        ),
        "Version-Max-Bytes" = "64",
        "Project-Scope-Value" = "one_health_system",
        "Canonical-Profile-ID-Value" = "rrp.canonical-profile.readmission",
        "Canonical-Profile-Version-Value" = "0.1.0",
        "Path-Fields" = "Extension-Library-Path,State-Path",
        "Path-Syntax" = "safe_relative_forward_segments",
        "Path-Case-Folded-Conflicts" = "prohibited",
        "Path-Overlap" = "prohibited",
        "Fixed-Path-Conflicts" = "rrp-project.dcf,R/register.R",
        "Unknown-Fields" = "prohibited",
        "Additional-Records" = "prohibited",
        "Multiline-Values" = "prohibited",
        "Secret-Or-Arbitrary-Content" = "prohibited"
      )
    ),
    project_registration = list(
      id = "rrp.contract.project-registration",
      source_path = "resources/contracts/project-registration.dcf",
      installed_path = "resources/contracts/project-registration.dcf",
      document = c(
        "Record-Type" = "project-registration-contract",
        "Contract-ID" = "rrp.project-registration",
        "Contract-Version" = "0.3.0",
        "Format-Version" = "1.0.0",
        "Product-ID" = "readmission-risk-pool-platform",
        "Development-Version" = "1.0.0-dev",
        "Status" = "development_unpublished",
        "Owner-Package" = "rrpplatform",
        "Registration-Path" = "R/register.R",
        "Registration-Function" = "rrp_register_project",
        "Result-Fields" = paste(c(
          "registration_contract_id", "registration_contract_version",
          "project_id", "producers", "providers"
        ), collapse = ","),
        "Collection-Fields" = "producers,providers",
        "Collection-Representation" = "ordered_unnamed_list",
        "Empty-Collections" = "allowed",
        "Producer-Fields" = paste(c(
          "component_id", "component_version", "producer_api_id",
          "producer_api_version", "canonical_bundle_id",
          "canonical_bundle_version", "canonical_profile_id",
          "canonical_profile_version", "implementation_id",
          "implementation_version", "mapping_id", "mapping_version",
          "capabilities", "callable"
        ), collapse = ","),
        "Provider-Fields" = paste(c(
          "component_id", "component_version", "provider_api_id",
          "provider_api_version", "target_id", "target_version",
          "state_contract_id", "state_contract_version",
          "request_contract_id", "request_contract_version",
          "estimate_contract_id", "estimate_contract_version",
          "implementation_id", "implementation_version", "model_id",
          "model_version", "callable"
        ), collapse = ","),
        "Capability-Fields" = "capability_id,status",
        "Producer-API-ID" = "rrp.producer-api",
        "Producer-API-Version" = "0.1.0",
        "Canonical-Bundle-ID" = "rrp.canonical-bundle",
        "Canonical-Bundle-Version" = "0.1.0",
        "Canonical-Profile-ID" = "rrp.canonical-profile.readmission",
        "Canonical-Profile-Version" = "0.1.0",
        "Provider-API-ID" = "rrp.provider-api",
        "Provider-API-Version" = "0.1.0",
        "Target-ID" = "rrp.risk-target.readmission-remaining-30-day",
        "Target-Version" = "0.1.0",
        "State-Contract-ID" = "rrp.episode-state",
        "State-Contract-Version" = "0.1.0",
        "Request-Contract-ID" = "rrp.risk-request",
        "Request-Contract-Version" = "0.1.0",
        "Estimate-Contract-ID" = "rrp.risk-estimate",
        "Estimate-Contract-Version" = "0.1.0",
        "Model-Identity-Rule" = "both_null_or_both_bounded",
        "Required-Capability-IDs" = paste(c(
          "rrp.capability.discharge-episode", "rrp.capability.terminal-event"
        ), collapse = ","),
        "Capability-Status-Value" = "available",
        "Project-ID-Pattern" = "^[a-z][a-z0-9]*(?:[.-][a-z0-9]+)*$",
        "Component-ID-Pattern" = "^[a-z][a-z0-9]*(?:[.-][a-z0-9]+)*$",
        "Identity-Max-Bytes" = "96",
        "Protected-ID-Prefix" = "rrp.",
        "Component-Version-Pattern" = paste0(
          "^[0-9]+[.][0-9]+[.][0-9]+",
          "(?:-[0-9A-Za-z]+(?:[.-][0-9A-Za-z]+)*)?$"
        ),
        "Component-Version-Max-Bytes" = "64",
        "Callable-Type" = "function",
        "Duplicate-Kind-ID-Version" = "prohibited",
        "Unknown-Component-Kinds" = "prohibited",
        "Additional-Result-Fields" = "prohibited",
        "Additional-Producer-Fields" = "prohibited",
        "Additional-Provider-Fields" = "prohibited",
        "Callable-Invocation-During-Validation" = "prohibited"
      )
    )
  )
  c(
    resources, canonical_contract_resources(), runtime_contract_resources(),
    history_contract_resources()
  )
}

validate_software_contract_resources <- function(authority, root, projection) {
  ids <- vapply(
    authority$entries, `[[`, character(1L), "Resource-ID"
  )
  for (name in names(software_contract_resources())) {
    specification <- software_contract_resources()[[name]]
    matched <- which(ids == specification$id)
    resource_require(
      length(matched) == 1L, paste0(name, "_contract_catalog"),
      paste0(specification$id, " must be cataloged exactly once.")
    )
    entry <- authority$entries[[matched]]
    owner <- if (is.null(specification$owner)) {
      "rrpplatform"
    } else {
      specification$owner
    }
    expected_entry <- c(
      "Resource-ID" = specification$id,
      "Resource-Class" = "contract",
      "Owner-Package" = owner,
      "Installed-Path" = specification$installed_path,
      "Format" = "dcf"
    )
    if (!projection) {
      expected_entry <- append(
        expected_entry,
        c("Source-Path" = specification$source_path),
        after = 3L
      )
    }
    for (field in names(expected_entry)) {
      resource_require(
        identical(entry[[field]], unname(expected_entry[[field]])),
        paste0(name, "_contract_catalog"),
        paste0(specification$id, " has an unsupported catalog mapping.")
      )
    }

    relative_path <- if (projection) {
      specification$installed_path
    } else {
      specification$source_path
    }
    records <- read_dcf_records(file.path(root, relative_path))
    resource_require(
      length(records) == 1L, paste0(name, "_contract_records"),
      paste0(specification$id, " must contain exactly one DCF record.")
    )
    record <- records[[1L]]
    expected <- specification$document
    validate_exact_fields(
      record, names(expected), paste0(name, "_contract_fields"),
      specification$id
    )
    for (field in names(expected)) {
      resource_require(
        identical(record[[field]], unname(expected[[field]])),
        paste0(name, "_contract_identity"),
        paste0(specification$id, " field ", field, " is unsupported.")
      )
    }
  }
  invisible(authority)
}

validate_software_template_resources <- function(authority, root, projection) {
  templates <- list(
    project_manifest = c(
      id = "rrp.template.project-manifest",
      path = "resources/templates/project/rrp-project.dcf", format = "dcf"
    ),
    project_registration = c(
      id = "rrp.template.project-registration",
      path = "resources/templates/project/R/register.R", format = "r"
    )
  )
  ids <- vapply(authority$entries, `[[`, character(1L), "Resource-ID")
  manifest_tokens <- c(
    "@@RRP_PROJECT_ID@@", "@@RRP_PROJECT_VERSION@@",
    "@@RRP_PRODUCER_ID@@", "@@RRP_PROVIDER_ID@@"
  )
  for (name in names(templates)) {
    specification <- templates[[name]]
    matched <- which(ids == specification[["id"]])
    resource_require(
      length(matched) == 1L, paste0(name, "_template_catalog"),
      paste0(specification[["id"]], " must be cataloged exactly once.")
    )
    entry <- authority$entries[[matched]]
    expected <- c(
      "Resource-ID" = specification[["id"]],
      "Resource-Class" = "template", "Owner-Package" = "rrpplatform",
      "Installed-Path" = specification[["path"]],
      "Format" = specification[["format"]]
    )
    if (!projection) expected <- append(
      expected, c("Source-Path" = specification[["path"]]), after = 3L
    )
    for (field in names(expected)) resource_require(
      identical(entry[[field]], unname(expected[[field]])),
      paste0(name, "_template_catalog"),
      paste0(specification[["id"]], " has an unsupported catalog mapping.")
    )
    lines <- readLines(
      file.path(root, specification[["path"]]), warn = FALSE, encoding = "UTF-8"
    )
    discovered <- unique(unlist(regmatches(
      lines, gregexpr("@@RRP_[A-Z_]+@@", lines, perl = TRUE)
    ), use.names = FALSE))
    required_tokens <- if (identical(name, "project_registration")) {
      c(manifest_tokens, "@@RRP_IMPLEMENTATION_ID@@", "@@RRP_MAPPING_ID@@")
    } else {
      manifest_tokens
    }
    resource_require(
      setequal(discovered, required_tokens), paste0(name, "_template_tokens"),
      paste0(specification[["id"]], " has invalid template tokens.")
    )
    if (identical(specification[["format"]], "dcf")) {
      resource_require(
        length(read_dcf_records(file.path(root, specification[["path"]]))) == 1L,
        "project_manifest_template", "Project manifest template is malformed."
      )
    } else {
      tryCatch(
        parse(text = lines),
        error = function(condition) resource_fail(
          "project_registration_template",
          "Project registration template is malformed."
        )
      )
    }
  }
}

validate_resource_schema <- function(record) {
  expected <- resource_schema_expected()
  validate_exact_fields(record, names(expected), "schema_fields", "Schema")
  for (field in names(expected)) {
    resource_require(
      identical(record[[field]], unname(expected[[field]])),
      "schema_identity",
      paste0("Schema field ", field, " does not match the accepted contract.")
    )
  }
  pattern <- record[["Resource-ID-Pattern"]]
  valid_pattern <- tryCatch({
    grepl(pattern, "rrp.contract.resource-catalog", perl = TRUE)
  }, error = function(condition) FALSE)
  resource_require(
    isTRUE(valid_pattern), "schema_identity",
    "The resource-ID pattern must be valid and accept the initial resource ID."
  )
  invisible(record)
}

safe_resource_path <- function(path) {
  if (length(path) != 1L || is.na(path) || !nzchar(path) ||
      !identical(path, trimws(path))) return(FALSE)
  if (grepl("[[:cntrl:]\\\\]", path) || startsWith(path, "/") ||
      grepl("^[A-Za-z]:", path) || startsWith(path, "~") ||
      startsWith(path, "//") || endsWith(path, "/")) return(FALSE)
  segments <- strsplit(path, "/", fixed = TRUE)[[1L]]
  length(segments) > 0L && all(nzchar(segments)) &&
    !any(segments %in% c(".", ".."))
}

path_has_link <- function(root, relative_path) {
  current <- root
  for (segment in strsplit(relative_path, "/", fixed = TRUE)[[1L]]) {
    current <- file.path(current, segment)
    target <- Sys.readlink(current)
    if (!is.na(target) && nzchar(target)) return(TRUE)
  }
  FALSE
}

path_is_contained <- function(root, relative_path) {
  normalized_root <- normalizePath(root, winslash = "/", mustWork = TRUE)
  candidate <- normalizePath(
    file.path(root, relative_path), winslash = "/", mustWork = TRUE
  )
  startsWith(candidate, paste0(normalized_root, "/"))
}

file_directory_conflict <- function(paths) {
  folded <- tolower(paths)
  if (length(folded) < 2L) return(NULL)
  for (left in seq_len(length(folded) - 1L)) {
    for (right in (left + 1L):length(folded)) {
      if (startsWith(folded[[right]], paste0(folded[[left]], "/")) ||
          startsWith(folded[[left]], paste0(folded[[right]], "/"))) {
        return(c(paths[[left]], paths[[right]]))
      }
    }
  }
  NULL
}

resource_tree_files <- function(root) {
  resource_root <- file.path(root, "resources")
  if (!dir.exists(resource_root)) return(character())
  files <- list.files(
    resource_root, recursive = TRUE, all.files = TRUE, no.. = TRUE,
    full.names = FALSE, include.dirs = FALSE
  )
  sort(paste0("resources/", gsub("\\\\", "/", files)), method = "radix")
}

validate_closed_files <- function(actual, expected, code, label) {
  missing <- setdiff(expected, actual)
  undeclared <- setdiff(actual, expected)
  resource_require(
    length(missing) == 0L && length(undeclared) == 0L,
    code,
    paste0(
      label, " is not closed; missing: ",
      if (length(missing)) paste(missing, collapse = ", ") else "none",
      "; undeclared: ",
      if (length(undeclared)) paste(undeclared, collapse = ", ") else "none",
      "."
    )
  )
}

validate_fixed_file <- function(root, relative_path, label) {
  resource_require(
    safe_resource_path(relative_path), "fixed_path",
    paste0(label, " path is unsafe.")
  )
  resource_require(
    !path_has_link(root, relative_path), "linked_file",
    paste0(label, " must not be linked.")
  )
  path <- file.path(root, relative_path)
  resource_require(file.exists(path), "missing_file", paste0(label, " is missing."))
  resource_require(
    isTRUE(file_test("-f", path)), "nonregular_file",
    paste0(label, " must be a regular file.")
  )
  resource_require(
    path_is_contained(root, relative_path), "containment",
    paste0(label, " must remain beneath its explicit root.")
  )
}

read_product_identity <- function(root) {
  path <- file.path(root, "RRP.yml")
  resource_require(file.exists(path), "product_identity", "RRP.yml is missing.")
  lines <- trimws(readLines(path, warn = FALSE, encoding = "UTF-8"))
  lines <- lines[nzchar(lines) & !startsWith(lines, "#")]
  pattern <- "^([a-z][a-z0-9_]*):[[:space:]]+([^#[:space:]][^#]*)$"
  resource_require(
    all(grepl(pattern, lines, perl = TRUE)), "product_identity",
    "RRP.yml is not parseable by the current metadata contract."
  )
  keys <- sub(pattern, "\\1", lines, perl = TRUE)
  values <- trimws(sub(pattern, "\\2", lines, perl = TRUE))
  setNames(values, keys)
}

validate_catalog_records <- function(records, schema, root, projection) {
  resource_require(
    length(records) >= 2L, "catalog_records",
    "The catalog must contain a header and at least one resource."
  )
  catalog_fields <- split_controlled_values(schema[["Catalog-Fields"]])
  validate_exact_fields(
    records[[1L]], catalog_fields, "catalog_header_fields", "Catalog header"
  )
  expected_header <- c(
    "Record-Type" = schema[["Catalog-Record-Type"]],
    "Catalog-ID" = schema[["Catalog-ID"]],
    "Catalog-Version" = schema[["Catalog-Version"]],
    "Format-Version" = schema[["Format-Version"]],
    "Product-ID" = "readmission-risk-pool-platform",
    "Development-Version" = "1.0.0-dev",
    "Status" = "development_unpublished"
  )
  for (field in names(expected_header)) {
    resource_require(
      identical(records[[1L]][[field]], unname(expected_header[[field]])),
      "catalog_identity",
      paste0("Catalog header field ", field, " is unsupported.")
    )
  }
  if (!projection) {
    identity <- read_product_identity(root)
    resource_require(
      identical(identity[["product_id"]], records[[1L]][["Product-ID"]]) &&
        identical(
          identity[["development_version"]],
          records[[1L]][["Development-Version"]]
        ),
      "product_identity",
      "The source catalog and RRP.yml product-development identities differ."
    )
  }

  entries <- records[-1L]
  resource_fields <- split_controlled_values(schema[[if (projection) {
    "Installed-Resource-Fields"
  } else {
    "Source-Resource-Fields"
  }]])
  classes <- split_controlled_values(schema[["Resource-Classes"]])
  owners <- split_controlled_values(schema[["Owner-Packages"]])
  formats <- split_controlled_values(schema[["Resource-Formats"]])
  id_pattern <- schema[["Resource-ID-Pattern"]]
  for (entry in entries) {
    validate_exact_fields(entry, resource_fields, "resource_fields", "Resource")
    resource_require(
      identical(entry[["Record-Type"]], schema[["Resource-Record-Type"]]),
      "resource_record_type", "Resource record type is unsupported."
    )
    resource_require(
      grepl(id_pattern, entry[["Resource-ID"]], perl = TRUE),
      "resource_id", "Resource ID is malformed."
    )
    resource_require(
      entry[["Resource-Class"]] %in% classes,
      "resource_class", "Resource class is unsupported."
    )
    resource_require(
      entry[["Owner-Package"]] %in% owners,
      "resource_owner", "Resource owner package is unsupported."
    )
    resource_require(
      entry[["Format"]] %in% formats,
      "resource_format", "Resource format is unsupported."
    )
  }

  values <- function(field) vapply(entries, `[[`, character(1L), field)
  ids <- values("Resource-ID")
  resource_require(!anyDuplicated(ids), "duplicate_resource_id", "Resource IDs must be unique.")
  installed_paths <- values("Installed-Path")
  for (path in installed_paths) {
    resource_require(
      safe_resource_path(path), "unsafe_installed_path",
      "Installed paths must be safe relative paths."
    )
  }
  resource_require(
    !anyDuplicated(installed_paths), "duplicate_installed_path",
    "Installed paths must be unique."
  )
  resource_require(
    !anyDuplicated(tolower(installed_paths)), "case_installed_path",
    "Installed paths must be unique after case folding."
  )
  installed_with_catalog <- c(
    schema[["Installed-Catalog-Path"]], installed_paths
  )
  resource_require(
    !anyDuplicated(tolower(installed_with_catalog)), "case_installed_path",
    "Installed paths must not collide with the fixed installed catalog."
  )
  conflict <- file_directory_conflict(installed_with_catalog)
  resource_require(
    is.null(conflict), "installed_path_conflict",
    "Installed paths contain a file/directory conflict."
  )

  if (!projection) {
    source_paths <- values("Source-Path")
    for (path in source_paths) {
      resource_require(
        safe_resource_path(path), "unsafe_source_path",
        "Source paths must be safe relative paths."
      )
      resource_require(
        startsWith(path, "resources/"), "source_root",
        "Source resources must be beneath resources/."
      )
    }
    source_with_catalog <- c(schema[["Source-Catalog-Path"]], source_paths)
    resource_require(
      !anyDuplicated(source_paths), "duplicate_source_path",
      "Source paths must be unique."
    )
    resource_require(
      !anyDuplicated(tolower(source_with_catalog)), "case_source_path",
      "Source paths must be unique after case folding."
    )
    conflict <- file_directory_conflict(source_with_catalog)
    resource_require(
      is.null(conflict), "source_path_conflict",
      "Source paths contain a file/directory conflict."
    )
    for (path in source_paths) {
      resource_require(
        !path_has_link(root, path), "linked_source",
        "Cataloged source resources must not be linked."
      )
      absolute <- file.path(root, path)
      resource_require(
        file.exists(absolute), "missing_source",
        "A cataloged source resource is missing."
      )
      resource_require(
        isTRUE(file_test("-f", absolute)), "nonregular_source",
        "Cataloged source resources must be regular files."
      )
      resource_require(
        path_is_contained(root, path), "source_containment",
        "Cataloged source resources must remain beneath the source root."
      )
    }
    validate_closed_files(
      resource_tree_files(root), sort(source_with_catalog, method = "radix"),
      "source_closure", "Source resource inventory"
    )
  } else {
    for (path in installed_paths) {
      resource_require(
        !path_has_link(root, path), "linked_installed_resource",
        "Projected resources must not be linked."
      )
      absolute <- file.path(root, path)
      resource_require(
        file.exists(absolute), "missing_installed_resource",
        "A projected resource is missing."
      )
      resource_require(
        isTRUE(file_test("-f", absolute)), "nonregular_installed_resource",
        "Projected resources must be regular files."
      )
      resource_require(
        path_is_contained(root, path), "installed_containment",
        "Projected resources must remain beneath the explicit root."
      )
    }
    validate_closed_files(
      resource_tree_files(root), sort(installed_with_catalog, method = "radix"),
      "installed_closure", "Installed resource inventory"
    )
  }

  initial_index <- which(ids == "rrp.contract.resource-catalog")
  resource_require(
    length(initial_index) == 1L, "initial_resource",
    "The catalog-schema resource must be declared exactly once."
  )
  first <- entries[[initial_index]]
  expected_first <- c(
    "Resource-ID" = "rrp.contract.resource-catalog",
    "Resource-Class" = "contract",
    "Owner-Package" = "rrpplatform",
    "Installed-Path" = "resources/resource-catalog-schema.dcf",
    "Format" = "dcf"
  )
  if (!projection) {
    expected_first <- append(
      expected_first,
      c("Source-Path" = "resources/resource-catalog-schema.dcf"),
      after = 3L
    )
  }
  for (field in names(expected_first)) {
    resource_require(
      identical(first[[field]], unname(expected_first[[field]])),
      "initial_resource",
      paste0("Initial resource field ", field, " is unsupported.")
    )
  }
  list(header = records[[1L]], entries = entries, schema = schema)
}

validate_resource_authority <- function(root, projection = FALSE) {
  resource_require(
    dir.exists(root), "resource_root", "The explicit resource root is missing."
  )
  root_link <- Sys.readlink(root)
  resource_require(
    is.na(root_link) || !nzchar(root_link), "resource_root",
    "The explicit resource root must not be linked."
  )
  root <- normalizePath(root, winslash = "/", mustWork = TRUE)
  schema_relative <- "resources/resource-catalog-schema.dcf"
  catalog_relative <- if (projection) {
    "resources/resource-catalog.dcf"
  } else {
    "resources/source-catalog.dcf"
  }
  validate_fixed_file(root, catalog_relative, "Catalog")
  validate_fixed_file(root, schema_relative, "Catalog schema")
  schema_records <- read_dcf_records(file.path(root, schema_relative))
  resource_require(
    length(schema_records) == 1L, "schema_records",
    "The resource-catalog schema must contain exactly one record."
  )
  schema <- validate_resource_schema(schema_records[[1L]])
  expected_catalog_path <- schema[[if (projection) {
    "Installed-Catalog-Path"
  } else {
    "Source-Catalog-Path"
  }]]
  resource_require(
    identical(catalog_relative, expected_catalog_path),
    "catalog_path", "The fixed catalog path differs from the schema."
  )
  records <- read_dcf_records(file.path(root, catalog_relative))
  authority <- validate_catalog_records(records, schema, root, projection)
  actual_ids <- vapply(
    authority$entries, `[[`, character(1L), "Resource-ID"
  )
  expected_ids <- c(
    "rrp.contract.resource-catalog",
    unname(vapply(
      software_contract_resources(), `[[`, character(1L), "id"
    )),
    "rrp.template.project-manifest", "rrp.template.project-registration"
  )
  resource_require(
    length(actual_ids) == 22L && identical(
      sort(actual_ids, method = "radix"),
      sort(expected_ids, method = "radix")
    ),
    "resource_inventory",
    "The software resource inventory must contain exactly 22 known entries."
  )
  validate_software_contract_resources(authority, root, projection)
  validate_software_template_resources(authority, root, projection)
  authority
}

raw_file <- function(path) {
  readBin(path, what = "raw", n = file.info(path)$size)
}

project_resource_authority <- function(source_root, projection_root) {
  source <- validate_resource_authority(source_root, projection = FALSE)
  resource_require(
    !file.exists(projection_root) && !dir.exists(projection_root),
    "projection_root", "Projection destination must not already exist."
  )
  dir.create(projection_root, recursive = TRUE)
  projected_records <- c(
    list(source$header),
    lapply(source$entries, function(entry) {
      entry[["Source-Path"]] <- NULL
      entry
    })
  )
  write_dcf_records(
    projected_records,
    file.path(projection_root, source$schema[["Installed-Catalog-Path"]])
  )
  for (entry in source$entries) {
    destination <- file.path(projection_root, entry[["Installed-Path"]])
    if (!dir.exists(dirname(destination))) dir.create(dirname(destination), recursive = TRUE)
    copied <- file.copy(
      file.path(source_root, entry[["Source-Path"]]), destination,
      overwrite = FALSE, copy.mode = FALSE, copy.date = FALSE
    )
    resource_require(copied, "projection_copy", "A resource could not be projected.")
  }
  validate_projection(source_root, projection_root)
  invisible(projection_root)
}

validate_projection <- function(source_root, projection_root) {
  source <- validate_resource_authority(source_root, projection = FALSE)
  for (entry in source$entries) {
    resource_require(
      identical(
        raw_file(file.path(source_root, entry[["Source-Path"]])),
        raw_file(file.path(projection_root, entry[["Installed-Path"]]))
      ),
      "projection_byte_drift",
      "Projected resource bytes differ from their source bytes."
    )
  }
  installed <- validate_resource_authority(projection_root, projection = TRUE)
  projected_source_entries <- lapply(source$entries, function(entry) {
    entry[["Source-Path"]] <- NULL
    entry
  })
  resource_require(
    identical(projected_source_entries, installed$entries),
    "projection_mapping_drift",
    "Projected catalog mappings differ from the source catalog."
  )
  invisible(installed)
}

trees_identical <- function(left_root, right_root) {
  left_files <- resource_tree_files(left_root)
  right_files <- resource_tree_files(right_root)
  identical(left_files, right_files) && all(vapply(left_files, function(path) {
    identical(raw_file(file.path(left_root, path)), raw_file(file.path(right_root, path)))
  }, logical(1L)))
}

copy_resource_fixture <- function(parent, label) {
  root <- file.path(parent, label)
  dir.create(root, recursive = TRUE)
  for (relative_path in c("RRP.yml", resource_tree_files(repository_root))) {
    destination <- file.path(root, relative_path)
    if (!dir.exists(dirname(destination))) dir.create(dirname(destination), recursive = TRUE)
    copied <- file.copy(
      file.path(repository_root, relative_path), destination,
      copy.mode = FALSE, copy.date = FALSE
    )
    require_true(copied, paste0("Could not create fixture ", label, "."))
  }
  root
}

mutate_fixture_catalog <- function(root, callback) {
  path <- file.path(root, "resources", "source-catalog.dcf")
  write_dcf_records(callback(read_dcf_records(path)), path)
}

mutate_fixture_schema <- function(root, callback) {
  path <- file.path(root, "resources", "resource-catalog-schema.dcf")
  records <- read_dcf_records(path)
  write_dcf_records(callback(records), path)
}

expect_resource_failure <- function(label, callback, code) {
  condition <- tryCatch({
    callback()
    NULL
  }, error = identity)
  require_true(!is.null(condition), paste0(label, " unexpectedly passed."))
  marker <- paste0("[", code, "]")
  require_true(
    grepl(marker, conditionMessage(condition), fixed = TRUE),
    paste0(
      label, " failed for the wrong reason; expected ", marker,
      ", got: ", conditionMessage(condition)
    )
  )
  cat("PASS ", label, " rejected (", code, ")\n", sep = "")
}

run_resource_contract_validation <- function() {
  validate_resource_authority(repository_root, projection = FALSE)
  cat(
    paste0(
      "PASS source catalog/schema/contracts identity, fields, closure, ",
      "and safety\n"
    )
  )

  work_root <- tempfile("rrp-resource-validation-")
  dir.create(work_root)
  on.exit(unlink(work_root, recursive = TRUE, force = TRUE), add = TRUE)
  first_projection <- file.path(work_root, "projection-one")
  second_projection <- file.path(work_root, "projection-two")
  project_resource_authority(repository_root, first_projection)
  project_resource_authority(repository_root, second_projection)
  require_true(
    trees_identical(first_projection, second_projection),
    "Repeated installed-resource projections must be byte-identical."
  )
  cat("PASS deterministic byte-preserving installed projection\n")

  fixture_number <- 0L
  fixture <- function(label) {
    fixture_number <<- fixture_number + 1L
    copy_resource_fixture(work_root, paste0(sprintf("%02d", fixture_number), "-", label))
  }
  catalog_failure <- function(label, code, mutate) {
    root <- fixture(label)
    mutate_fixture_catalog(root, mutate)
    expect_resource_failure(label, function() {
      validate_resource_authority(root, projection = FALSE)
    }, code)
  }

  catalog_failure("missing resource field", "resource_fields", function(records) {
    records[[2L]][["Format"]] <- NULL
    records
  })
  catalog_failure("unknown resource field", "resource_fields", function(records) {
    records[[2L]][["Unknown-Field"]] <- "not-allowed"
    records
  })
  catalog_failure("unsupported catalog identity", "catalog_identity", function(records) {
    records[[1L]][["Catalog-Version"]] <- "9.9.9"
    records
  })
  root <- fixture("unsupported-schema-identity")
  mutate_fixture_schema(root, function(records) {
    records[[1L]][["Schema-ID"]] <- "rrp.unsupported-schema"
    records
  })
  expect_resource_failure("unsupported schema identity", function() {
    validate_resource_authority(root, projection = FALSE)
  }, "schema_identity")
  root <- fixture("missing-schema-field")
  mutate_fixture_schema(root, function(records) {
    records[[1L]][["Resource-Formats"]] <- NULL
    records
  })
  expect_resource_failure("missing schema field", function() {
    validate_resource_authority(root, projection = FALSE)
  }, "schema_fields")
  root <- fixture("unknown-schema-field")
  mutate_fixture_schema(root, function(records) {
    records[[1L]][["Unknown-Field"]] <- "not-allowed"
    records
  })
  expect_resource_failure("unknown schema field", function() {
    validate_resource_authority(root, projection = FALSE)
  }, "schema_fields")
  catalog_failure("mismatched product identity", "catalog_identity", function(records) {
    records[[1L]][["Product-ID"]] <- "different-product"
    records
  })

  add_entry <- function(records, changes) {
    duplicate <- records[[2L]]
    for (field in names(changes)) duplicate[[field]] <- changes[[field]]
    c(records, list(duplicate))
  }
  catalog_failure("duplicate resource ID", "duplicate_resource_id", function(records) {
    add_entry(records, c(
      "Source-Path" = "resources/duplicate-id.dcf",
      "Installed-Path" = "resources/duplicate-id.dcf"
    ))
  })
  catalog_failure("duplicate source path", "duplicate_source_path", function(records) {
    add_entry(records, c(
      "Resource-ID" = "rrp.contract.duplicate-source",
      "Installed-Path" = "resources/duplicate-source.dcf"
    ))
  })
  catalog_failure("duplicate installed path", "duplicate_installed_path", function(records) {
    add_entry(records, c(
      "Resource-ID" = "rrp.contract.duplicate-installed",
      "Source-Path" = "resources/duplicate-installed.dcf"
    ))
  })

  unsafe_paths <- c(
    absolute = "/tmp/resource.dcf",
    drive = "C:/resource.dcf",
    home = "~/resource.dcf",
    empty_segment = "resources//resource.dcf",
    dot_segment = "resources/./resource.dcf",
    parent_segment = "resources/../resource.dcf",
    backslash = "resources\\resource.dcf",
    control = paste0("resources/", "\t", "resource.dcf")
  )
  for (label in names(unsafe_paths)) {
    catalog_failure(
      paste0("unsafe source path (", label, ")"), "unsafe_source_path",
      function(records) {
        records[[2L]][["Source-Path"]] <- unsafe_paths[[label]]
        records
      }
    )
  }
  catalog_failure("unsafe installed traversal", "unsafe_installed_path", function(records) {
    records[[2L]][["Installed-Path"]] <- "resources/../resource.dcf"
    records
  })

  catalog_failure("case-folded source collision", "case_source_path", function(records) {
    add_entry(records, c(
      "Resource-ID" = "rrp.contract.case-source",
      "Source-Path" = "resources/RESOURCE-CATALOG-SCHEMA.dcf",
      "Installed-Path" = "resources/case-source.dcf"
    ))
  })
  catalog_failure("case-folded installed collision", "case_installed_path", function(records) {
    add_entry(records, c(
      "Resource-ID" = "rrp.contract.case-installed",
      "Source-Path" = "resources/case-installed.dcf",
      "Installed-Path" = "resources/RESOURCE-CATALOG-SCHEMA.dcf"
    ))
  })
  catalog_failure("installed file-directory conflict", "installed_path_conflict", function(records) {
    add_entry(records, c(
      "Resource-ID" = "rrp.contract.path-conflict",
      "Source-Path" = "resources/path-conflict.dcf",
      "Installed-Path" = "resources/resource-catalog-schema.dcf/child"
    ))
  })
  catalog_failure("source file-directory conflict", "source_path_conflict", function(records) {
    add_entry(records, c(
      "Resource-ID" = "rrp.contract.source-path-conflict",
      "Source-Path" = "resources/resource-catalog-schema.dcf/child",
      "Installed-Path" = "resources/source-path-conflict.dcf"
    ))
  })

  catalog_failure("missing source", "missing_source", function(records) {
    records[[2L]][["Source-Path"]] <- "resources/missing-source.dcf"
    records
  })
  root <- fixture("linked-source")
  copied <- file.copy(
    file.path(root, "resources", "resource-catalog-schema.dcf"),
    file.path(root, "linked-target.dcf"), copy.mode = FALSE, copy.date = FALSE
  )
  require_true(copied, "Could not create the linked-source target fixture.")
  unlink(file.path(root, "resources", "resource-catalog-schema.dcf"))
  linked <- file.symlink(
    "../linked-target.dcf",
    file.path(root, "resources", "resource-catalog-schema.dcf")
  )
  require_true(linked, "Could not create the linked-source fixture.")
  expect_resource_failure("linked source", function() {
    validate_resource_authority(root, projection = FALSE)
  }, "linked_file")

  root <- fixture("nonregular-source")
  unlink(file.path(root, "resources", "resource-catalog-schema.dcf"))
  dir.create(file.path(root, "resources", "resource-catalog-schema.dcf"))
  expect_resource_failure("nonregular source", function() {
    validate_resource_authority(root, projection = FALSE)
  }, "nonregular_file")

  root <- fixture("undeclared-source")
  writeLines(
    "Record-Type: undeclared",
    file.path(root, "resources", "undeclared.dcf"), useBytes = TRUE
  )
  expect_resource_failure("undeclared source", function() {
    validate_resource_authority(root, projection = FALSE)
  }, "source_closure")

  root <- fixture("invalid-diagnostic-contract")
  diagnostic_path <- file.path(root, "resources", "contracts", "diagnostic.dcf")
  records <- read_dcf_records(diagnostic_path)
  records[[1L]][["Severity-Values"]] <- "debug,info,error"
  write_dcf_records(records, diagnostic_path)
  expect_resource_failure("invalid diagnostic contract", function() {
    validate_resource_authority(root, projection = FALSE)
  }, "diagnostic_contract_identity")

  root <- fixture("invalid-operation-result-contract")
  result_path <- file.path(
    root, "resources", "contracts", "operation-result.dcf"
  )
  records <- read_dcf_records(result_path)
  records[[1L]][["Failure-Value"]] <- NULL
  write_dcf_records(records, result_path)
  expect_resource_failure("invalid operation-result contract", function() {
    validate_resource_authority(root, projection = FALSE)
  }, "operation_result_contract_fields")

  root <- fixture("invalid-project-manifest-contract")
  manifest_path <- file.path(
    root, "resources", "contracts", "project-manifest.dcf"
  )
  records <- read_dcf_records(manifest_path)
  records[[1L]][["Project-API-Version"]] <- "9.9.9"
  write_dcf_records(records, manifest_path)
  expect_resource_failure("invalid project-manifest contract", function() {
    validate_resource_authority(root, projection = FALSE)
  }, "project_manifest_contract_identity")

  root <- fixture("invalid-project-registration-contract")
  registration_path <- file.path(
    root, "resources", "contracts", "project-registration.dcf"
  )
  records <- read_dcf_records(registration_path)
  records[[1L]][["Callable-Type"]] <- NULL
  write_dcf_records(records, registration_path)
  expect_resource_failure("invalid project-registration contract", function() {
    validate_resource_authority(root, projection = FALSE)
  }, "project_registration_contract_fields")

  root <- fixture("unsupported-canonical-bundle-version")
  bundle_path <- file.path(
    root, "resources", "contracts", "canonical", "canonical-bundle.dcf"
  )
  records <- read_dcf_records(bundle_path)
  records[[1L]][["Specification-Version"]] <- "9.9.9"
  write_dcf_records(records, bundle_path)
  expect_resource_failure("unsupported canonical bundle version", function() {
    validate_resource_authority(root, projection = FALSE)
  }, "canonical_bundle_contract_identity")

  root <- fixture("unknown-canonical-domain-field")
  domain_path <- file.path(
    root, "resources", "contracts", "canonical", "domains",
    "terminal-event.dcf"
  )
  records <- read_dcf_records(domain_path)
  records[[1L]][["Unknown-Field"]] <- "not-allowed"
  write_dcf_records(records, domain_path)
  expect_resource_failure("unknown canonical domain field", function() {
    validate_resource_authority(root, projection = FALSE)
  }, "terminal_event_contract_fields")

  root <- fixture("unsupported-readmission-risk-target")
  target_path <- file.path(
    root, "resources", "contracts", "runtime",
    "readmission-risk-target.dcf"
  )
  records <- read_dcf_records(target_path)
  records[[1L]][["Target-Interval"]] <- "(t,t+1day]"
  write_dcf_records(records, target_path)
  expect_resource_failure("unsupported readmission risk target", function() {
    validate_resource_authority(root, projection = FALSE)
  }, "readmission_risk_target_contract_identity")

  root <- fixture("unknown-episode-state-field")
  state_path <- file.path(
    root, "resources", "contracts", "runtime", "episode-state.dcf"
  )
  records <- read_dcf_records(state_path)
  records[[1L]][["Unknown-Field"]] <- "not-allowed"
  write_dcf_records(records, state_path)
  expect_resource_failure("unknown episode-state field", function() {
    validate_resource_authority(root, projection = FALSE)
  }, "episode_state_contract_fields")

  drift_projection <- file.path(work_root, "projection-byte-drift")
  project_resource_authority(repository_root, drift_projection)
  schema_path <- file.path(
    drift_projection, "resources", "resource-catalog-schema.dcf"
  )
  writeBin(c(raw_file(schema_path), charToRaw("drift")), schema_path)
  expect_resource_failure("projected resource byte drift", function() {
    validate_projection(repository_root, drift_projection)
  }, "projection_byte_drift")

  catalog_drift_projection <- file.path(work_root, "projection-catalog-drift")
  project_resource_authority(repository_root, catalog_drift_projection)
  installed_catalog <- file.path(
    catalog_drift_projection, "resources", "resource-catalog.dcf"
  )
  records <- read_dcf_records(installed_catalog)
  records[[1L]][["Status"]] <- "unsupported"
  write_dcf_records(records, installed_catalog)
  expect_resource_failure("projected catalog drift", function() {
    validate_projection(repository_root, catalog_drift_projection)
  }, "catalog_identity")
}

package_expected_files <- function(package_name) {
  files <- c(
    "DESCRIPTION", "NAMESPACE",
    file.path("R", paste0(package_name, "-package.R")),
    "README.md",
    file.path("man", paste0(package_name, "-package.Rd")),
    file.path("tests", "package-foundation.R")
  )
  if (identical(package_name, "rrpplatform")) {
    files <- c(
      files,
      file.path("R", "canonical-contracts.R"),
      file.path("R", "operation-result.R"),
      file.path("R", "producer-execution.R"),
      file.path("R", "risk-execution.R"),
      file.path("R", "project-contracts.R"),
      file.path("R", "project-doctor.R"),
      file.path("R", "project-initializer.R"),
      file.path("R", "project-loader.R"),
      file.path("R", "resource-catalog.R"),
      file.path("R", "runtime-contracts.R"),
      file.path("man", "rrp_initialize_project.Rd"),
      file.path("man", "rrp_load_project.Rd"),
      file.path("man", "rrp_open_resource_catalog.Rd"),
      file.path("man", "rrp_operation_succeeded.Rd"),
      file.path("man", "rrp_execute_producer.Rd"),
      file.path("man", "rrp_execute_risk.Rd"),
      file.path("man", "rrp_resource_path.Rd"),
      file.path("man", "rrp_validate_project.Rd"),
      file.path("man", "rrp_validate_software_resources.Rd"),
      file.path("tests", "operation-results.R"),
      file.path("tests", "canonical-contracts.R"),
      file.path("tests", "project-contracts.R"),
      file.path("tests", "project-doctor.R"),
      file.path("tests", "project-initializer.R"),
      file.path("tests", "project-loader.R"),
      file.path("tests", "producer-execution.R"),
      file.path("tests", "risk-execution.R"),
      file.path("tests", "resource-access.R"),
      file.path("tests", "runtime-contracts.R")
    )
  } else {
    files <- c(
      files,
      file.path("R", "canonical-admission.R"),
      file.path("R", "episode-state.R"),
      file.path("R", "history.R"),
      file.path("R", "risk-provider.R"),
      file.path("man", "rrp_admit_canonical_bundle.Rd"),
      file.path("man", "rrp_prepare_episode_state.Rd"),
      file.path("man", "rrp_execute_risk_provider.Rd"),
      file.path("man", "rrp_history_port.Rd"),
      file.path("man", "rrp_history_reads.Rd"),
      file.path("man", "rrp_history_records.Rd"),
      file.path("tests", "canonical-admission.R"),
      file.path("tests", "episode-state.R"),
      file.path("tests", "history.R"),
      file.path("tests", "risk-provider.R")
    )
  }
  files
}

package_dependency_names <- function(description, field) {
  if (!field %in% colnames(description)) return(character())
  values <- trimws(strsplit(description[[1L, field]], ",", fixed = TRUE)[[1L]])
  sub("[[:space:]]*[(].*$", "", values)
}

read_package_description <- function(package_root, package_name) {
  description_path <- file.path(package_root, "DESCRIPTION")
  description <- tryCatch(
    read.dcf(description_path),
    error = function(condition) fail(
      package_name, " DESCRIPTION is not valid DCF: ", conditionMessage(condition)
    )
  )
  require_true(
    nrow(description) == 1L,
    paste0(package_name, " DESCRIPTION must contain exactly one record.")
  )
  description
}

validate_package_layout <- function(package_root, package_name) {
  actual_files <- sort(list.files(
    package_root, recursive = TRUE, all.files = TRUE,
    full.names = FALSE, include.dirs = FALSE, no.. = TRUE
  ), method = "radix")
  expected_files <- sort(package_expected_files(package_name), method = "radix")
  missing_files <- setdiff(expected_files, actual_files)
  unexpected_files <- setdiff(actual_files, expected_files)
  if (length(missing_files) > 0L) fail(
    package_name, " is missing required package file(s): ",
    paste(missing_files, collapse = ", ")
  )
  if (length(unexpected_files) > 0L) fail(
    package_name, " contains unexpected package file(s): ",
    paste(unexpected_files, collapse = ", ")
  )

  actual_directories <- list.dirs(
    package_root, recursive = TRUE, full.names = FALSE
  )
  actual_directories <- sort(
    actual_directories[nzchar(actual_directories)], method = "radix"
  )
  expected_directories <- sort(c("R", "man", "tests"), method = "radix")
  require_true(
    identical(actual_directories, expected_directories),
    paste0(
      package_name,
      " must contain exactly the conventional R, man, and tests directories."
    )
  )
}

validate_package_metadata <- function(package_root, package_name, spec) {
  description <- read_package_description(package_root, package_name)
  expected_fields <- c(
    Package = package_name,
    Type = "Package",
    Title = if (identical(package_name, "rrpruntime")) {
      "Dependency-Light Readmission Runtime Foundation"
    } else {
      "Internal Readmission Risk Pool Implementation"
    },
    Version = spec$version,
    License = "Apache License (>= 2)",
    URL = "https://github.com/centralstatz/readmission-risk-pool-platform",
    BugReports = paste0(
      "https://github.com/centralstatz/readmission-risk-pool-platform/issues"
    ),
    Encoding = "UTF-8",
    Depends = "R (>= 4.4.0)"
  )
  for (field in names(expected_fields)) {
    actual <- if (field %in% colnames(description)) {
      unname(description[[1L, field]])
    } else {
      NA_character_
    }
    require_true(
      identical(actual, expected_fields[[field]]),
      paste0(
        package_name, " DESCRIPTION field ", field, " must be `",
        expected_fields[[field]], "`."
      )
    )
  }
  for (field in c("Authors@R", "Description")) {
    require_true(
      field %in% colnames(description) && nzchar(description[[1L, field]]),
      paste0(package_name, " DESCRIPTION must define ", field, ".")
    )
  }

  imports <- package_dependency_names(description, "Imports")
  suggest_dependencies <- package_dependency_names(description, "Suggests")
  linking_dependencies <- package_dependency_names(description, "LinkingTo")
  require_true(
    identical(imports, spec$imports),
    paste0(
      package_name, " Imports must be exactly: ",
      if (length(spec$imports) == 0L) "none" else paste(spec$imports, collapse = ", "),
      "."
    )
  )
  require_true(
    length(suggest_dependencies) == 0L && length(linking_dependencies) == 0L,
    paste0(package_name, " must not declare Suggests or LinkingTo dependencies.")
  )

  r_files <- list.files(
    package_root, pattern = "[.]R$", recursive = TRUE, full.names = TRUE
  )
  for (r_file in r_files) {
    tryCatch(
      parse(r_file),
      error = function(condition) fail(
        package_name, " R file does not parse: ",
        sub(paste0("^", package_root, .Platform$file.sep), "", r_file),
        ": ", conditionMessage(condition)
      )
    )
  }
  documentation_files <- list.files(
    file.path(package_root, "man"), pattern = "[.]Rd$", full.names = TRUE
  )
  for (documentation_file in documentation_files) {
    tryCatch(
      invisible(tools::parse_Rd(documentation_file)),
      error = function(condition) fail(
        package_name, " package documentation does not parse: ",
        basename(documentation_file), ": ", conditionMessage(condition)
      )
    )
  }

  namespace <- tryCatch(
    base::parseNamespaceFile(package_name, dirname(package_root)),
    error = function(condition) fail(
      package_name, " NAMESPACE does not parse: ", conditionMessage(condition)
    )
  )
  expected_exports <- if (identical(package_name, "rrpplatform")) {
    c(
      "rrp_execute_producer", "rrp_execute_risk", "rrp_initialize_project",
      "rrp_load_project",
      "rrp_open_resource_catalog",
      "rrp_operation_succeeded",
      "rrp_resource_path", "rrp_validate_project",
      "rrp_validate_software_resources"
    )
  } else c(
    "rrp_admit_canonical_bundle", "rrp_execute_risk_provider",
    "rrp_history_append_disposition", "rrp_history_append_invalidation",
    "rrp_history_append_restatement", "rrp_history_append_scope",
    "rrp_history_membership_fingerprint", "rrp_history_read_current",
    "rrp_history_read_episode", "rrp_history_read_scope",
    "rrp_new_episode_disposition", "rrp_new_history_action",
    "rrp_new_history_port", "rrp_new_operational_scope",
    "rrp_prepare_episode_state"
  )
  require_true(
    identical(sort(namespace$exports, method = "radix"), expected_exports),
    paste0(
      package_name, " exports must be exactly: ",
      if (length(expected_exports)) paste(expected_exports, collapse = ", ") else "none",
      "."
    )
  )
  namespace_lines <- trimws(readLines(
    file.path(package_root, "NAMESPACE"), warn = FALSE, encoding = "UTF-8"
  ))
  namespace_directives <- namespace_lines[
    nzchar(namespace_lines) & !startsWith(namespace_lines, "#")
  ]
  expected_directives <- if (identical(package_name, "rrpplatform")) {
    c(
      "export(rrp_initialize_project)",
      "export(rrp_execute_producer)",
      "export(rrp_execute_risk)",
      "export(rrp_load_project)",
      "export(rrp_open_resource_catalog)",
      "export(rrp_operation_succeeded)",
      "export(rrp_resource_path)",
      "export(rrp_validate_project)",
      "export(rrp_validate_software_resources)",
      "import(rrpruntime)"
    )
  } else c(
    "export(rrp_admit_canonical_bundle)",
    "export(rrp_execute_risk_provider)",
    "export(rrp_history_append_disposition)",
    "export(rrp_history_append_invalidation)",
    "export(rrp_history_append_restatement)",
    "export(rrp_history_append_scope)",
    "export(rrp_history_membership_fingerprint)",
    "export(rrp_history_read_current)",
    "export(rrp_history_read_episode)",
    "export(rrp_history_read_scope)",
    "export(rrp_new_episode_disposition)",
    "export(rrp_new_history_action)",
    "export(rrp_new_history_port)",
    "export(rrp_new_operational_scope)",
    "export(rrp_prepare_episode_state)"
  )
  require_true(
    identical(namespace_directives, expected_directives),
    paste0(
      package_name, " NAMESPACE must contain exactly ",
      if (length(expected_directives) == 0L) {
        "no directives."
      } else {
        paste0("`", expected_directives, "`.")
      }
    )
  )

  invisible(description)
}

validate_source_boundaries <- function(package_roots) {
  runtime_files <- list.files(
    package_roots[["rrpruntime"]], recursive = TRUE, full.names = TRUE
  )
  runtime_text <- paste(unlist(lapply(
    runtime_files, readLines, warn = FALSE, encoding = "UTF-8"
  ), use.names = FALSE), collapse = "\n")
  require_true(
    !grepl("rrpplatform", runtime_text, fixed = TRUE),
    "rrpruntime must not refer to rrpplatform."
  )

  forbidden_source_patterns <- c(
    "\\.GlobalEnv", "Sys\\.getenv\\s*\\(",
    "repository_root", "[.]git(?:/|\\\\|\"|')",
    "readmission-risk-pool(?:/|\\\\)"
  )
  for (package_name in names(package_roots)) {
    source_files <- list.files(
      file.path(package_roots[[package_name]], "R"),
      pattern = "[.]R$", full.names = TRUE
    )
    source_text <- paste(unlist(lapply(
      source_files, readLines, warn = FALSE, encoding = "UTF-8"
    ), use.names = FALSE), collapse = "\n")
    matched <- forbidden_source_patterns[vapply(
      forbidden_source_patterns, grepl, logical(1L), x = source_text,
      perl = TRUE, ignore.case = TRUE
    )]
    if (length(matched) > 0L) fail(
      package_name, " source contains prohibited repository coupling: ",
      paste(matched, collapse = ", ")
    )
  }

  platform_source_files <- list.files(
    file.path(package_roots[["rrpplatform"]], "R"),
    pattern = "[.]R$", full.names = TRUE
  )
  getwd_calls <- lapply(platform_source_files, function(path) {
    lines <- readLines(path, warn = FALSE, encoding = "UTF-8")
    grep("getwd[[:space:]]*[(]", lines, value = TRUE, perl = TRUE)
  })
  names(getwd_calls) <- basename(platform_source_files)
  files_with_getwd <- sort(
    names(getwd_calls)[lengths(getwd_calls) > 0L], method = "radix"
  )
  require_true(
    identical(
      files_with_getwd, c("producer-execution.R", "risk-execution.R")
    ) && length(getwd_calls[["producer-execution.R"]]) == 2L &&
      length(getwd_calls[["risk-execution.R"]]) == 2L,
    paste0(
      "rrpplatform may inspect the working directory only to save and restore ",
      "it around selected producer or provider execution."
    )
  )

  risk_source <- paste(readLines(
    file.path(package_roots[["rrpplatform"]], "R", "risk-execution.R"),
    warn = FALSE, encoding = "UTF-8"
  ), collapse = "\n")
  generic_risk <- sub(
    "(?s).*?rrp_risk_execute <- function\\(",
    "rrp_risk_execute <- function(", risk_source, perl = TRUE
  )
  generic_risk <- sub(
    "(?s)\\n#' Execute the risk provider.*$", "", generic_risk, perl = TRUE
  )
  provider_branch_tokens <- c(
    "rrp.provider.transparent", "provider_id", "implementation_id",
    "model_id", "project_id"
  )
  require_true(
    !any(vapply(
      provider_branch_tokens, grepl, logical(1L), x = generic_risk,
      fixed = TRUE
    )),
    "Generic risk orchestration must not branch on provider or project identity."
  )

  generic_text <- paste(unlist(lapply(c(
    platform_source_files,
    list.files(
      file.path(package_roots[["rrpplatform"]], "man"),
      pattern = "[.]Rd$", full.names = TRUE
    ),
    list.files(
      file.path(repository_root, "resources"),
      recursive = TRUE, full.names = TRUE, include.dirs = FALSE
    )
  ), readLines, warn = FALSE, encoding = "UTF-8"), use.names = FALSE),
  collapse = "\n")
  hospital_vocabulary <- c(
    "visit_key", "person_key", "unit_case", "member_token",
    "encounters.csv", "stays.csv", "returns.csv", "deaths.csv"
  )
  require_true(
    !any(vapply(
      hospital_vocabulary, grepl, logical(1L), x = generic_text, fixed = TRUE
    )),
    "Generic package source and documentation must not embed hospital mappings."
  )

  source_pattern <- "(?:^|[^[:alnum:]_.])(?:sys[.])?source[[:space:]]*[(]"
  source_calls <- lapply(platform_source_files, function(path) {
    lines <- readLines(path, warn = FALSE, encoding = "UTF-8")
    grep(source_pattern, lines, value = TRUE, perl = TRUE, ignore.case = TRUE)
  })
  names(source_calls) <- basename(platform_source_files)
  files_with_source <- names(source_calls)[lengths(source_calls) > 0L]
  require_true(
    identical(files_with_source, "project-loader.R") &&
      length(source_calls[["project-loader.R"]]) == 1L &&
      grepl(
        "sys[.]source[[:space:]]*[(]", source_calls[["project-loader.R"]],
        perl = TRUE
      ),
    paste0(
      "rrpplatform may evaluate source only once through the fixed trusted ",
      "project-loader registration boundary."
    )
  )
}

run_command <- function(command, arguments, environment = character()) {
  output <- suppressWarnings(system2(
    command, arguments, stdout = TRUE, stderr = TRUE, env = environment
  ))
  status <- attr(output, "status")
  if (is.null(status)) status <- 0L
  list(status = as.integer(status), output = output)
}

require_command_success <- function(label, command, arguments, environment = character()) {
  result <- run_command(command, arguments, environment)
  if (!identical(result$status, 0L)) {
    details <- paste(tail(result$output, 80L), collapse = "\n")
    fail(label, " failed with exit status ", result$status, ".\n", details)
  }
  invisible(result$output)
}

write_validation_profile <- function(path, library_root, repository_url = NULL) {
  lines <- paste0(
    ".libPaths(c(",
    encodeString(normalizePath(library_root, mustWork = TRUE), quote = "\""),
    ", .Library))"
  )
  if (!is.null(repository_url)) {
    lines <- c(lines, paste0(
      "options(repos = c(CRAN = ",
      encodeString(repository_url, quote = "\""), "))"
    ))
  }
  writeLines(lines, path, useBytes = TRUE)
}

validation_environment <- function(profile_path, library_root) {
  c(
    paste0("R_LIBS=", library_root),
    paste0("R_LIBS_USER=", library_root),
    paste0("R_PROFILE_USER=", profile_path),
    "R_ENVIRON_USER=/dev/null"
  )
}

build_package <- function(package_name, package_root, work_root) {
  spec <- package_specs[[package_name]]
  require_command_success(
    paste0(package_name, " build"),
    file.path(R.home("bin"), "R"),
    c("CMD", "build", "--no-manual", shQuote(package_root))
  )
  archive <- file.path(
    work_root, paste0(package_name, "_", spec$version, ".tar.gz")
  )
  require_true(
    file.exists(archive),
    paste0(package_name, " build did not create ", basename(archive), ".")
  )
  archive
}

install_package <- function(package_name, archive, library_root, environment) {
  require_command_success(
    paste0(package_name, " isolated installation"),
    file.path(R.home("bin"), "R"),
    c(
      "CMD", "INSTALL", paste0("--library=", shQuote(library_root)),
      shQuote(archive)
    ),
    environment
  )
}

load_package_fresh <- function(package_name, library_root) {
  spec <- package_specs[[package_name]]
  expected_exports <- if (identical(package_name, "rrpplatform")) {
    paste0(
      "c(\"rrp_execute_producer\", \"rrp_execute_risk\", ",
      "\"rrp_initialize_project\", ",
      "\"rrp_load_project\", ",
      "\"rrp_open_resource_catalog\", ",
      "\"rrp_operation_succeeded\", ",
      "\"rrp_resource_path\", \"rrp_validate_project\", ",
      "\"rrp_validate_software_resources\")"
    )
  } else paste0(
    "c(\"rrp_admit_canonical_bundle\", ",
    "\"rrp_execute_risk_provider\", ",
    "\"rrp_history_append_disposition\", ",
    "\"rrp_history_append_invalidation\", ",
    "\"rrp_history_append_restatement\", ",
    "\"rrp_history_append_scope\", ",
    "\"rrp_history_membership_fingerprint\", ",
    "\"rrp_history_read_current\", ",
    "\"rrp_history_read_episode\", ",
    "\"rrp_history_read_scope\", ",
    "\"rrp_new_episode_disposition\", ",
    "\"rrp_new_history_action\", ",
    "\"rrp_new_history_port\", ",
    "\"rrp_new_operational_scope\", ",
    "\"rrp_prepare_episode_state\")"
  )
  expression <- paste0(
    "library_root <- ",
    encodeString(normalizePath(library_root, mustWork = TRUE), quote = "\""),
    "; .libPaths(c(library_root, .Library)); package_name <- ",
    encodeString(package_name, quote = "\""),
    "; library(package_name, character.only = TRUE); ",
    "stopifnot(startsWith(normalizePath(find.package(package_name)), ",
    "paste0(library_root, .Platform$file.sep)), ",
    "identical(as.character(packageVersion(package_name)), ",
    encodeString(spec$version, quote = "\""),
    "), identical(sort(getNamespaceExports(package_name)), ",
    expected_exports, "))",
    if (identical(package_name, "rrpplatform")) {
      "; stopifnot(\"rrpruntime\" %in% loadedNamespaces())"
    } else {
      ""
    }
  )
  require_command_success(
    paste0(package_name, " fresh-process load"),
    file.path(R.home("bin"), "Rscript"),
    c("--vanilla", "-e", shQuote(expression))
  )
}

check_package <- function(
  package_name, archive, work_root, library_root, environment
) {
  require_command_success(
    paste0(package_name, " R CMD check --no-manual"),
    file.path(R.home("bin"), "R"),
    c(
      "CMD", "check", "--no-manual",
      paste0("--library=", shQuote(library_root)), shQuote(archive)
    ),
    environment
  )
  check_log <- file.path(work_root, paste0(package_name, ".Rcheck"), "00check.log")
  require_true(
    file.exists(check_log),
    paste0(package_name, " check log is missing.")
  )
  status <- grep(
    "^Status:", readLines(check_log, warn = FALSE, encoding = "UTF-8"),
    value = TRUE
  )
  require_true(
    identical(status, "Status: OK"),
    paste0(
      package_name, " check must end with exact `Status: OK`; found: ",
      if (length(status) == 0L) "no status" else paste(status, collapse = " | ")
    )
  )
}

validate_installed_resource_access <- function(library_root, work_root) {
  projection_root <- file.path(work_root, "projected-software-root")
  project_resource_authority(repository_root, projection_root)
  failed_projection_root <- file.path(work_root, "invalid-projected-software-root")
  project_resource_authority(repository_root, failed_projection_root)
  unlink(file.path(
    failed_projection_root, "resources", "resource-catalog-schema.dcf"
  ))
  expected_resources <- c(
    resource_catalog = "resources/resource-catalog-schema.dcf",
    diagnostic = "resources/contracts/diagnostic.dcf",
    operation_result = "resources/contracts/operation-result.dcf",
    project_manifest = "resources/contracts/project-manifest.dcf",
    project_registration = "resources/contracts/project-registration.dcf",
    canonical_envelope = "resources/contracts/canonical/specification-envelope.dcf",
    canonical_producer = "resources/contracts/canonical/canonical-producer.dcf",
    canonical_bundle = "resources/contracts/canonical/canonical-bundle.dcf",
    readmission_profile = "resources/contracts/canonical/profiles/readmission.dcf",
    discharge_episode = "resources/contracts/canonical/domains/discharge-episode.dcf",
    terminal_event = "resources/contracts/canonical/domains/terminal-event.dcf",
    readmission_risk_target = "resources/contracts/runtime/readmission-risk-target.dcf",
    episode_state = "resources/contracts/runtime/episode-state.dcf",
    risk_request = "resources/contracts/runtime/risk-request.dcf",
    risk_provider = "resources/contracts/runtime/risk-provider.dcf",
    risk_estimate = "resources/contracts/runtime/risk-estimate.dcf",
    history_operational_scope = "resources/contracts/history/operational-scope.dcf",
    history_episode_disposition = "resources/contracts/history/episode-disposition.dcf",
    history_action = "resources/contracts/history/history-action.dcf",
    history_port = "resources/contracts/history/history-port.dcf",
    project_manifest_template = "resources/templates/project/rrp-project.dcf",
    project_registration_template = "resources/templates/project/R/register.R"
  )
  expected_copies <- vapply(names(expected_resources), function(name) {
    destination <- file.path(work_root, paste0("expected-", name, ".dcf"))
    copied <- file.copy(
      file.path(repository_root, expected_resources[[name]]),
      destination, copy.mode = FALSE, copy.date = FALSE
    )
    require_true(copied, paste0("Could not create expected ", name, " evidence."))
    normalizePath(destination, winslash = "/", mustWork = TRUE)
  }, character(1L))
  expected_resource_count <- length(
    validate_resource_authority(repository_root, projection = FALSE)$entries
  )
  unrelated_root <- file.path(work_root, "unrelated-working-directory")
  dir.create(unrelated_root)

  expression <- paste0(
    "library_root <- ",
    encodeString(normalizePath(library_root, mustWork = TRUE), quote = "\""),
    "; .libPaths(c(library_root, .Library)); old <- setwd(",
    encodeString(normalizePath(unrelated_root, mustWork = TRUE), quote = "\""),
    "); on.exit(setwd(old), add = TRUE); library(rrpplatform); root <- ",
    encodeString(normalizePath(projection_root, mustWork = TRUE), quote = "\""),
    "; invalid_root <- ",
    encodeString(
      normalizePath(failed_projection_root, mustWork = TRUE), quote = "\""
    ),
    "; expected <- c(resource_catalog = ",
    encodeString(expected_copies[["resource_catalog"]], quote = "\""),
    ", diagnostic = ",
    encodeString(expected_copies[["diagnostic"]], quote = "\""),
    ", operation_result = ",
    encodeString(expected_copies[["operation_result"]], quote = "\""),
    ", project_manifest = ",
    encodeString(expected_copies[["project_manifest"]], quote = "\""),
    ", project_registration = ",
    encodeString(expected_copies[["project_registration"]], quote = "\""),
    ", canonical_envelope = ",
    encodeString(expected_copies[["canonical_envelope"]], quote = "\""),
    ", canonical_producer = ",
    encodeString(expected_copies[["canonical_producer"]], quote = "\""),
    ", canonical_bundle = ",
    encodeString(expected_copies[["canonical_bundle"]], quote = "\""),
    ", readmission_profile = ",
    encodeString(expected_copies[["readmission_profile"]], quote = "\""),
    ", discharge_episode = ",
    encodeString(expected_copies[["discharge_episode"]], quote = "\""),
    ", terminal_event = ",
    encodeString(expected_copies[["terminal_event"]], quote = "\""),
    ", readmission_risk_target = ",
    encodeString(expected_copies[["readmission_risk_target"]], quote = "\""),
    ", episode_state = ",
    encodeString(expected_copies[["episode_state"]], quote = "\""),
    ", risk_request = ",
    encodeString(expected_copies[["risk_request"]], quote = "\""),
    ", risk_provider = ",
    encodeString(expected_copies[["risk_provider"]], quote = "\""),
    ", risk_estimate = ",
    encodeString(expected_copies[["risk_estimate"]], quote = "\""),
    ", project_manifest_template = ",
    encodeString(expected_copies[["project_manifest_template"]], quote = "\""),
    ", project_registration_template = ",
    encodeString(expected_copies[["project_registration_template"]], quote = "\""),
    "); expected_count <- ", expected_resource_count,
    "L; stopifnot(!dir.exists('.git'), !dir.exists(file.path(root, '.git')), ",
    "startsWith(normalizePath(find.package('rrpplatform')), ",
    "paste0(library_root, .Platform$file.sep)), ",
    "identical(sort(getNamespaceExports('rrpplatform')), ",
    "c('rrp_execute_producer', 'rrp_execute_risk', ",
    "'rrp_initialize_project', 'rrp_load_project', ",
    "'rrp_open_resource_catalog', ",
    "'rrp_operation_succeeded', ",
    "'rrp_resource_path', 'rrp_validate_project', ",
    "'rrp_validate_software_resources'))); ",
    "catalog <- rrp_open_resource_catalog(root); ",
    "stopifnot(identical(class(catalog), c('rrp_resource_catalog', 'list')), ",
    "identical(names(catalog), c('software_root', 'catalog_path', ",
    "'schema_path', 'catalog')), ",
    "!'Source-Path' %in% names(catalog$catalog$entries[[1L]])); ",
    "read_raw <- function(path) readBin(path, 'raw', n = file.info(path)$size); ",
    "ids <- c(resource_catalog = 'rrp.contract.resource-catalog', ",
    "diagnostic = 'rrp.contract.diagnostic', ",
    "operation_result = 'rrp.contract.operation-result', ",
    "project_manifest = 'rrp.contract.project-manifest', ",
    "project_registration = 'rrp.contract.project-registration', ",
    "canonical_envelope = 'rrp.contract.specification-envelope', ",
    "canonical_producer = 'rrp.contract.canonical-producer', ",
    "canonical_bundle = 'rrp.contract.canonical-bundle', ",
    "readmission_profile = 'rrp.profile.readmission', ",
    "discharge_episode = 'rrp.domain.discharge-episode', ",
    "terminal_event = 'rrp.domain.terminal-event'); ",
    "ids <- c(ids, readmission_risk_target = 'rrp.target.readmission-risk', ",
    "episode_state = 'rrp.contract.episode-state', ",
    "risk_request = 'rrp.contract.risk-request', ",
    "risk_provider = 'rrp.contract.risk-provider', ",
    "risk_estimate = 'rrp.contract.risk-estimate'); ",
    "ids <- c(ids, project_manifest_template = 'rrp.template.project-manifest', ",
    "project_registration_template = 'rrp.template.project-registration'); ",
    "resolved <- vapply(ids, function(id) rrp_resource_path(catalog, id), ",
    "character(1L)); stopifnot(all(vapply(names(ids), function(name) ",
    "identical(read_raw(resolved[[name]]), read_raw(expected[[name]])), ",
    "logical(1L)))); ",
    "manifest_contract <- getFromNamespace('rrp_project_manifest_contract', ",
    "'rrpplatform')(catalog); registration_contract <- getFromNamespace(",
    "'rrp_project_registration_contract', 'rrpplatform')(catalog); ",
    "stopifnot(identical(manifest_contract[['Contract-ID']], 'rrp.project'), ",
    "identical(manifest_contract[['Project-API-Version']], '0.3.0'), ",
    "identical(registration_contract[['Contract-ID']], ",
    "'rrp.project-registration'), identical(registration_contract[[",
    "'Callable-Invocation-During-Validation']], 'prohibited')); ",
    "canonical_contracts <- getFromNamespace('rrp_canonical_contracts', ",
    "'rrpplatform')(catalog); stopifnot(identical(names(canonical_contracts), ",
    "c('specification_envelope', 'canonical_producer', 'canonical_bundle', ",
    "'readmission_profile', 'discharge_episode', 'terminal_event')), ",
    "identical(canonical_contracts$canonical_producer[['Canonical-Profile-ID']], ",
    "'rrp.canonical-profile.readmission')); ",
    "runtime_contracts <- getFromNamespace('rrp_runtime_contracts', ",
    "'rrpplatform')(catalog, canonical_contracts); context <- getFromNamespace(",
    "'rrp_episode_state_expected_context', 'rrpplatform')(",
    "runtime_contracts, canonical_contracts); stopifnot(",
    "identical(names(runtime_contracts), c('readmission_risk_target', ",
    "'episode_state', 'risk_request', 'risk_provider', 'risk_estimate')), ",
    "identical(context$target_id, ",
    "'rrp.risk-target.readmission-remaining-30-day'), ",
    "identical(context$endpoint_elapsed_seconds, 2592000)); ",
    "success <- rrp_validate_software_resources(root); ",
    "stopifnot(identical(class(success), c('rrp_operation_result', 'list')), ",
    "identical(names(success), c('operation_id', 'status', 'value', ",
    "'diagnostics')), identical(success$operation_id, ",
    "'rrp.validate-software-resources'), identical(success$status, 'success'), ",
    "identical(success$value, list(catalog_id = 'rrp.software-resources', ",
    "catalog_version = '0.1.0', resource_count = expected_count)), ",
    "identical(success$diagnostics, list()), ",
    "identical(rrp_operation_succeeded(success), TRUE)); ",
    "failure <- rrp_validate_software_resources(invalid_root); ",
    "diagnostic <- failure$diagnostics[[1L]]; stopifnot(",
    "identical(class(failure), c('rrp_operation_result', 'list')), ",
    "identical(failure$operation_id, 'rrp.validate-software-resources'), ",
    "identical(failure$status, 'failure'), is.null(failure$value), ",
    "length(failure$diagnostics) == 1L, ",
    "identical(class(diagnostic), c('rrp_diagnostic', 'list')), ",
    "identical(names(diagnostic), c('code', 'severity', 'message')), ",
    "identical(diagnostic$code, 'missing_schema'), ",
    "identical(diagnostic$severity, 'error'), ",
    "identical(diagnostic$message, 'Software resource validation failed.'), ",
    "!grepl(invalid_root, diagnostic$message, fixed = TRUE), ",
    "!grepl('/', diagnostic$message, fixed = TRUE), ",
    "!grepl(intToUtf8(92L), diagnostic$message, fixed = TRUE), ",
    "identical(rrp_operation_succeeded(failure), FALSE)); ",
    "unlink(resolved[['resource_catalog']]); condition <- tryCatch({rrp_resource_path(catalog, ",
    "'rrp.contract.resource-catalog'); NULL}, error = identity); ",
    "stopifnot(inherits(condition, 'rrp_resource_error'), ",
    "identical(condition$code, 'missing_schema'), ",
    "!grepl(root, condition$message, fixed = TRUE))"
  )
  require_command_success(
    "installed rrpplatform copied-root resource access",
    file.path(R.home("bin"), "Rscript"),
    c("--vanilla", "-e", shQuote(expression))
  )
  cat(
    paste0(
      "PASS installed rrpplatform explicit-root resolution, contract loading, ",
      "byte equality, structured success/failure, safe diagnostics, and ",
      "post-open mutation rejection\n"
    )
  )
}

write_hand_authored_project <- function(project_root) {
  dir.create(file.path(project_root, "R"), recursive = TRUE)
  manifest <- c(
    "Record-Type" = "rrp-project",
    "Project-Contract-ID" = "rrp.project",
    "Project-Contract-Version" = "0.3.0",
    "Project-ID" = "maintainer-fixture",
    "Project-Version" = "1.0.0",
    "Project-Scope" = "one_health_system",
    "Supported-RRP-API-Version" = "0.3.0",
    "Canonical-Profile-ID" = "rrp.canonical-profile.readmission",
    "Canonical-Profile-Version" = "0.1.0",
    "Producer-ID" = "maintainer.producer",
    "Producer-Version" = "1.0.0",
    "Provider-ID" = "maintainer.provider",
    "Provider-Version" = "1.0.0",
    "Extension-Library-Path" = "extensions/library",
    "State-Path" = "state"
  )
  writeLines(
    paste0(names(manifest), ": ", unname(manifest)),
    file.path(project_root, "rrp-project.dcf"), useBytes = TRUE
  )
  writeLines(c(
    "rrp_register_project <- local({",
    "  calls <- 0L",
    "  function(project_root) {",
    "    calls <<- calls + 1L",
    "    component <- function(id, kind = 'producer') {",
    "      callable <- function(request) stop('selected callable executed', call. = FALSE)",
    "      attr(callable, 'registration_calls') <- calls",
    "      if (identical(kind, 'provider')) return(list(component_id = id, component_version = '1.0.0', provider_api_id = 'rrp.provider-api', provider_api_version = '0.1.0', target_id = 'rrp.risk-target.readmission-remaining-30-day', target_version = '0.1.0', state_contract_id = 'rrp.episode-state', state_contract_version = '0.1.0', request_contract_id = 'rrp.risk-request', request_contract_version = '0.1.0', estimate_contract_id = 'rrp.risk-estimate', estimate_contract_version = '0.1.0', implementation_id = paste0(sub('[.]provider$', '', id), '.implementation'), implementation_version = '1.0.0', model_id = NULL, model_version = NULL, callable = callable))",
    "      prefix <- sub('[.]producer$', '', id)",
    "      list(component_id = id, component_version = '1.0.0', producer_api_id = 'rrp.producer-api', producer_api_version = '0.1.0', canonical_bundle_id = 'rrp.canonical-bundle', canonical_bundle_version = '0.1.0', canonical_profile_id = 'rrp.canonical-profile.readmission', canonical_profile_version = '0.1.0', implementation_id = paste0(prefix, '.implementation'), implementation_version = '1.0.0', mapping_id = paste0(prefix, '.mapping'), mapping_version = '1.0.0', capabilities = list(list(capability_id = 'rrp.capability.discharge-episode', status = 'available'), list(capability_id = 'rrp.capability.terminal-event', status = 'available')), callable = callable)",
    "    }",
    "    list(registration_contract_id = 'rrp.project-registration',",
    "         registration_contract_version = '0.3.0',",
    "         project_id = 'maintainer-fixture',",
    "         producers = list(component('zeta.producer'), component('maintainer.producer')),",
    "         providers = list(component('zeta.provider', 'provider'), component('maintainer.provider', 'provider'))) ",
    "  }",
    "})"
  ), file.path(project_root, "R", "register.R"), useBytes = TRUE)
}

validate_installed_project_loading <- function(library_root, work_root) {
  software_root <- file.path(work_root, "project-loader-software-root")
  project_resource_authority(repository_root, software_root)
  project_root <- file.path(work_root, "hand-authored-project")
  write_hand_authored_project(project_root)
  copy_parent <- file.path(work_root, "copied-project-parent")
  dir.create(copy_parent)
  require_true(
    file.copy(project_root, copy_parent, recursive = TRUE, copy.mode = FALSE),
    "Could not copy the hand-authored project fixture."
  )
  copied_root <- file.path(copy_parent, basename(project_root))
  invalid_parent <- file.path(work_root, "invalid-selection-parent")
  dir.create(invalid_parent)
  require_true(
    file.copy(project_root, invalid_parent, recursive = TRUE, copy.mode = FALSE),
    "Could not copy the invalid project fixture."
  )
  invalid_root <- file.path(invalid_parent, basename(project_root))
  invalid_manifest <- readLines(
    file.path(invalid_root, "rrp-project.dcf"), warn = FALSE
  )
  invalid_manifest <- sub(
    "^Provider-ID:.*$", "Provider-ID: missing.provider", invalid_manifest
  )
  writeLines(
    invalid_manifest, file.path(invalid_root, "rrp-project.dcf"),
    useBytes = TRUE
  )
  unrelated_root <- file.path(work_root, "project-loader-unrelated-directory")
  dir.create(unrelated_root)
  script_path <- file.path(work_root, "validate-installed-project-loader.R")
  writeLines(c(
    "local({",
    "  arguments <- commandArgs(trailingOnly = TRUE)",
    "  library_root <- normalizePath(arguments[[1L]], winslash = '/', mustWork = TRUE)",
    "  software_root <- normalizePath(arguments[[2L]], winslash = '/', mustWork = TRUE)",
    "  project_root <- normalizePath(arguments[[3L]], winslash = '/', mustWork = TRUE)",
    "  copied_root <- normalizePath(arguments[[4L]], winslash = '/', mustWork = TRUE)",
    "  invalid_root <- normalizePath(arguments[[5L]], winslash = '/', mustWork = TRUE)",
    "  unrelated_root <- normalizePath(arguments[[6L]], winslash = '/', mustWork = TRUE)",
    "  .libPaths(c(library_root, .Library), include.site = FALSE)",
    "  library(rrpplatform)",
    "  before_globals <- ls(.GlobalEnv, all.names = TRUE)",
    "  before_libraries <- .libPaths()",
    "  previous_directory <- setwd(unrelated_root)",
    "  on.exit(setwd(previous_directory), add = TRUE)",
    "  catalog <- rrp_open_resource_catalog(software_root)",
    "  context <- rrp_load_project(catalog, project_root)",
    "  copied <- rrp_load_project(catalog, copied_root)",
    "  stopifnot(",
    "    identical(class(context), c('rrp_project_context', 'list')),",
    "    identical(names(context), c('software_catalog', 'project_root', 'manifest', 'registration', 'canonical_profile', 'producer', 'provider', 'extension_library_path', 'state_path')),",
    "    identical(context$manifest[['Project-ID']], 'maintainer-fixture'),",
    "    identical(context$canonical_profile, list(profile_id = 'rrp.canonical-profile.readmission', profile_version = '0.1.0')),",
    "    identical(context$producer$component_id, 'maintainer.producer'),",
    "    identical(context$provider$component_id, 'maintainer.provider'),",
    "    identical(context$producer$origin, 'project'),",
    "    identical(context$provider$origin, 'project'),",
    "    identical(attr(context$producer$callable, 'registration_calls'), 1L),",
    "    identical(attr(context$provider$callable, 'registration_calls'), 1L),",
    "    identical(vapply(context$registration$producers, function(entry) entry$component_id, character(1L)), c('maintainer.producer', 'zeta.producer')),",
    "    identical(vapply(context$registration$providers, function(entry) entry$component_id, character(1L)), c('maintainer.provider', 'zeta.provider')),",
    "    !dir.exists(context$extension_library_path), !dir.exists(context$state_path),",
    "    identical(copied$manifest, context$manifest),",
    "    identical(copied$producer$component_id, context$producer$component_id),",
    "    identical(copied$provider$component_id, context$provider$component_id),",
    "    !identical(copied$project_root, context$project_root),",
    "    !identical(copied$extension_library_path, context$extension_library_path),",
    "    !identical(copied$state_path, context$state_path),",
    "    !startsWith(project_root, paste0(software_root, '/')),",
    "    !startsWith(software_root, paste0(project_root, '/')),",
    "    identical(.libPaths(), before_libraries),",
    "    identical(getwd(), unrelated_root),",
    "    identical(ls(.GlobalEnv, all.names = TRUE), before_globals),",
    "    !dir.exists(file.path(project_root, '.git')), !dir.exists(file.path(unrelated_root, '.git'))",
    "  )",
    "  condition <- tryCatch({ rrp_load_project(catalog, invalid_root); NULL }, error = identity)",
    "  stopifnot(inherits(condition, 'rrp_project_error'), identical(condition$code, 'unknown_provider_selection'), !grepl(invalid_root, condition$message, fixed = TRUE), !grepl('[/\\\\]', condition$message), identical(.libPaths(), before_libraries))",
    "})"
  ), script_path, useBytes = TRUE)
  require_command_success(
    "installed rrpplatform explicit project loading",
    file.path(R.home("bin"), "Rscript"),
    c(
      "--vanilla", shQuote(script_path), shQuote(library_root),
      shQuote(software_root), shQuote(project_root), shQuote(copied_root),
      shQuote(invalid_root), shQuote(unrelated_root)
    )
  )
  cat(
    paste0(
      "PASS installed rrpplatform explicit/copy project loading, exact ",
      "selection, origin, call-count, non-invocation, context separation, ",
      "global/working-directory stability, and safe typed failure\n"
    )
  )
}

validate_installed_project_initialization <- function(library_root, work_root) {
  software_root <- file.path(work_root, "project-initializer-software-root")
  project_resource_authority(repository_root, software_root)
  destination_parent <- file.path(work_root, "initializer-destination-parent")
  copy_parent <- file.path(work_root, "initializer-copy-parent")
  unrelated_root <- file.path(work_root, "initializer-unrelated-directory")
  dir.create(destination_parent)
  dir.create(copy_parent)
  dir.create(unrelated_root)
  destination <- file.path(destination_parent, "initialized-project")
  script_path <- file.path(work_root, "validate-installed-project-initializer.R")
  writeLines(c(
    "local({",
    "  arguments <- commandArgs(trailingOnly = TRUE)",
    "  library_root <- normalizePath(arguments[[1L]], winslash = '/', mustWork = TRUE)",
    "  software_root <- normalizePath(arguments[[2L]], winslash = '/', mustWork = TRUE)",
    "  destination <- arguments[[3L]]",
    "  copy_parent <- normalizePath(arguments[[4L]], winslash = '/', mustWork = TRUE)",
    "  unrelated_root <- normalizePath(arguments[[5L]], winslash = '/', mustWork = TRUE)",
    "  .libPaths(c(library_root, .Library), include.site = FALSE)",
    "  old <- setwd(unrelated_root); on.exit(setwd(old), add = TRUE)",
    "  library(rrpplatform)",
    "  before_globals <- ls(.GlobalEnv, all.names = TRUE)",
    "  before_libraries <- .libPaths()",
    "  catalog <- rrp_open_resource_catalog(software_root)",
    "  stopifnot(!file.exists(destination), !dir.exists(destination))",
    "  result <- rrp_initialize_project(catalog, destination, 'maintainer-initialized', '1.2.3')",
    "  expected_value <- list(project_id = 'maintainer-initialized', project_version = '1.2.3', producer_id = 'maintainer-initialized.producer', producer_version = '1.2.3', implementation_id = 'maintainer-initialized.implementation', implementation_version = '1.2.3', mapping_id = 'maintainer-initialized.mapping', mapping_version = '1.2.3', canonical_profile_id = 'rrp.canonical-profile.readmission', canonical_profile_version = '0.1.0', provider_id = 'maintainer-initialized.provider', provider_version = '1.2.3', created_paths = c('rrp-project.dcf', 'R/register.R'))",
    "  context <- rrp_load_project(catalog, destination)",
    "  doctor <- rrp_validate_project(catalog, destination)",
    "  expected_doctor <- list(project_id = 'maintainer-initialized', project_version = '1.2.3', project_contract_id = 'rrp.project', project_contract_version = '0.3.0', supported_rrp_api_version = '0.3.0', canonical_profile = list(profile_id = 'rrp.canonical-profile.readmission', profile_version = '0.1.0'), producer = list(component_id = 'maintainer-initialized.producer', component_version = '1.2.3', implementation_id = 'maintainer-initialized.implementation', implementation_version = '1.2.3', mapping_id = 'maintainer-initialized.mapping', mapping_version = '1.2.3', origin = 'project'), provider = list(component_id = 'maintainer-initialized.provider', component_version = '1.2.3', implementation_id = 'maintainer-initialized.implementation', implementation_version = '1.2.3', model_id = NULL, model_version = NULL, origin = 'project'), extension_library_status = 'not_initialized', state_status = 'not_initialized')",
    "  stopifnot(identical(class(result), c('rrp_operation_result', 'list')), identical(result$operation_id, 'rrp.initialize-project'), identical(result$status, 'success'), identical(result$value, expected_value), identical(result$diagnostics, list()), identical(sort(list.files(destination, recursive = TRUE, all.files = TRUE, no.. = TRUE, include.dirs = FALSE)), c('R/register.R', 'rrp-project.dcf')), !dir.exists(file.path(destination, 'extensions')), !dir.exists(file.path(destination, 'state')), !dir.exists(file.path(destination, '.git')), identical(context$producer$origin, 'project'), identical(context$provider$origin, 'project'), identical(doctor$operation_id, 'rrp.validate-project'), identical(doctor$status, 'success'), identical(doctor$value, expected_doctor), length(doctor$diagnostics) == 1L, identical(doctor$diagnostics[[1L]]$code, 'project_state_not_initialized'), identical(doctor$diagnostics[[1L]]$severity, 'warning'), identical(doctor$diagnostics[[1L]]$message, 'Project state has not been initialized.'), identical(rrp_operation_succeeded(doctor), TRUE), !grepl(destination, paste(capture.output(str(doctor)), collapse = ' '), fixed = TRUE), !grepl('function', paste(capture.output(str(doctor)), collapse = ' '), fixed = TRUE))",
    "  stopifnot(file.copy(destination, copy_parent, recursive = TRUE, copy.mode = FALSE))",
    "  copied_root <- file.path(copy_parent, basename(destination)); copied <- rrp_load_project(catalog, copied_root); copied_doctor <- rrp_validate_project(catalog, copied_root)",
    "  text <- paste(unlist(lapply(c(file.path(destination, 'rrp-project.dcf'), file.path(destination, 'R', 'register.R')), readLines, warn = FALSE)), collapse = '\\n')",
    "  stopifnot(identical(copied$manifest, context$manifest), identical(copied$producer$component_id, context$producer$component_id), identical(copied$provider$component_id, context$provider$component_id), !identical(copied$project_root, context$project_root), identical(copied_doctor, doctor), !grepl(destination, paste(capture.output(str(copied_doctor)), collapse = ' '), fixed = TRUE), !grepl(destination, text, fixed = TRUE), !grepl('rrp-staging', text, fixed = TRUE))",
    "  dir.create(file.path(copied_root, 'extensions', 'library'), recursive = TRUE); dir.create(file.path(copied_root, 'state')); writeLines('opaque', file.path(copied_root, 'state', 'sentinel')); available <- rrp_validate_project(catalog, copied_root)",
    "  stopifnot(identical(available$status, 'success'), identical(available$value$extension_library_status, 'available'), identical(available$value$state_status, 'available'), identical(available$diagnostics, list()), identical(readLines(file.path(copied_root, 'state', 'sentinel')), 'opaque'))",
    "  invalid_parent <- file.path(dirname(copy_parent), 'doctor-invalid-parent'); dir.create(invalid_parent); stopifnot(file.copy(destination, invalid_parent, recursive = TRUE, copy.mode = FALSE)); invalid_root <- file.path(invalid_parent, basename(destination)); invalid_manifest <- readLines(file.path(invalid_root, 'rrp-project.dcf')); invalid_manifest <- sub('^Provider-ID:.*$', 'Provider-ID: missing.provider', invalid_manifest); writeLines(invalid_manifest, file.path(invalid_root, 'rrp-project.dcf')); invalid_doctor <- rrp_validate_project(catalog, invalid_root)",
    "  stopifnot(identical(invalid_doctor$operation_id, 'rrp.validate-project'), identical(invalid_doctor$status, 'failure'), is.null(invalid_doctor$value), length(invalid_doctor$diagnostics) == 1L, identical(invalid_doctor$diagnostics[[1L]]$code, 'unknown_provider_selection'), identical(invalid_doctor$diagnostics[[1L]]$severity, 'error'), identical(invalid_doctor$diagnostics[[1L]]$message, 'RRP project validation failed.'), !grepl(invalid_root, paste(capture.output(str(invalid_doctor)), collapse = ' '), fixed = TRUE))",
    "  existing <- rrp_initialize_project(catalog, destination, 'maintainer-initialized', '1.2.3')",
    "  invalid_destination <- file.path(dirname(destination), 'invalid-project'); invalid <- rrp_initialize_project(catalog, invalid_destination, 'rrp.protected', 'bad-version')",
    "  stopifnot(identical(existing$status, 'failure'), identical(existing$diagnostics[[1L]]$code, 'project_destination_exists'), identical(invalid$status, 'failure'), identical(invalid$diagnostics[[1L]]$code, 'invalid_project_id'), !file.exists(invalid_destination), !dir.exists(invalid_destination), !any(grepl('rrp-staging', list.files(dirname(destination)))), identical(.libPaths(), before_libraries), identical(getwd(), unrelated_root), identical(ls(.GlobalEnv, all.names = TRUE), before_globals))",
    "})"
  ), script_path, useBytes = TRUE)
  require_command_success(
    "installed rrpplatform transactional project initialization",
    file.path(R.home("bin"), "Rscript"),
    c(
      "--vanilla", shQuote(script_path), shQuote(library_root),
      shQuote(software_root), shQuote(destination), shQuote(copy_parent),
      shQuote(unrelated_root)
    )
  )
  cat(
    paste0(
      "PASS installed rrpplatform transactional initialization, exact ",
      "inventory, final-location load/doctor, copied portability, state and ",
      "extension status, bounded adversarial failure, create-only failure, ",
      "state isolation, and staging cleanup\n"
    )
  )
}

validate_installed_producer_execution <- function(
  library_root,
  work_root,
  environment
) {
  software_root <- file.path(work_root, "producer-execution-software-root")
  project_resource_authority(repository_root, software_root)
  script_path <- file.path(work_root, "validate-installed-producer-execution.R")
  copied <- file.copy(
    file.path(
      repository_root, "packages", "rrpplatform", "tests",
      "producer-execution.R"
    ),
    script_path,
    overwrite = FALSE,
    copy.mode = FALSE,
    copy.date = FALSE
  )
  require_true(copied, "Could not copy installed producer-execution proof.")
  require_command_success(
    "installed rrpplatform selected producer execution",
    file.path(R.home("bin"), "Rscript"),
    c("--vanilla", shQuote(script_path), shQuote(software_root)),
    environment
  )
  cat(
    paste0(
      "PASS installed selected producer execution for two fictional hospital ",
      "mappings, copied-project portability, exact one-call/zero-provider ",
      "behavior, bounded failures, admission delegation, process restoration, ",
      "and no project/state mutation\n"
    )
  )
}

validate_installed_risk_execution <- function(
  library_root,
  work_root,
  environment
) {
  software_root <- file.path(work_root, "risk-execution-software-root")
  project_resource_authority(repository_root, software_root)
  script_path <- file.path(work_root, "validate-installed-risk-execution.R")
  copied <- file.copy(
    file.path(
      repository_root, "packages", "rrpplatform", "tests",
      "risk-execution.R"
    ),
    script_path,
    overwrite = FALSE,
    copy.mode = FALSE,
    copy.date = FALSE
  )
  require_true(copied, "Could not copy installed risk-execution proof.")
  require_command_success(
    "installed rrpplatform selected provider execution",
    file.path(R.home("bin"), "Rscript"),
    c("--vanilla", shQuote(script_path), shQuote(software_root)),
    environment
  )
  cat(
    paste0(
      "PASS installed producer-to-estimate execution with explicit ",
      "transparent/project provider selection, copied-project substitution, ",
      "one-call/no-call behavior, bounded failures, process restoration, ",
      "estimate detachment, and zero project-state output\n"
    )
  )
}

validate_packages <- function() {
  cat("RRP local package, project, canonical, and state validation\n")
  cat("=============================================================\n")

  run_resource_contract_validation()

  package_root <- file.path(repository_root, "packages")
  require_true(dir.exists(package_root), "The packages directory is missing.")
  actual_package_roots <- sort(list.dirs(
    package_root, recursive = FALSE, full.names = FALSE
  ), method = "radix")
  expected_package_roots <- sort(names(package_specs), method = "radix")
  require_true(
    identical(actual_package_roots, expected_package_roots),
    paste0(
      "Package roots must be exactly: ",
      paste(expected_package_roots, collapse = ", "), "."
    )
  )

  package_roots <- setNames(
    file.path(package_root, names(package_specs)), names(package_specs)
  )
  for (package_name in names(package_specs)) {
    validate_package_layout(package_roots[[package_name]], package_name)
    validate_package_metadata(
      package_roots[[package_name]], package_name, package_specs[[package_name]]
    )
    cat(sprintf("PASS %-11s static package boundary\n", package_name))
  }
  validate_source_boundaries(package_roots)
  cat("PASS one-way dependency and repository-independence boundary\n")

  work_root <- tempfile("rrp-package-validation-")
  dir.create(work_root)
  old_directory <- setwd(work_root)
  on.exit({
    setwd(old_directory)
    unlink(work_root, recursive = TRUE, force = TRUE)
  }, add = TRUE)

  library_root <- file.path(work_root, "library")
  missing_dependency_library <- file.path(work_root, "missing-dependency-library")
  local_contrib <- file.path(work_root, "repository", "src", "contrib")
  dir.create(library_root)
  dir.create(missing_dependency_library)
  dir.create(local_contrib, recursive = TRUE)
  writeLines(character(), file.path(local_contrib, "PACKAGES"))

  profile_path <- file.path(work_root, "check-profile.R")
  repository_url <- paste0(
    "file://", normalizePath(file.path(work_root, "repository"),
                              winslash = "/", mustWork = TRUE)
  )
  write_validation_profile(profile_path, library_root, repository_url)
  environment <- validation_environment(profile_path, library_root)

  archives <- lapply(names(package_specs), function(package_name) {
    archive <- build_package(
      package_name, package_roots[[package_name]], work_root
    )
    cat(sprintf("PASS %-11s source build\n", package_name))
    archive
  })
  names(archives) <- names(package_specs)

  missing_profile <- file.path(work_root, "missing-dependency-profile.R")
  write_validation_profile(
    missing_profile, missing_dependency_library, repository_url
  )
  missing_environment <- validation_environment(
    missing_profile, missing_dependency_library
  )
  missing_result <- run_command(
    file.path(R.home("bin"), "R"),
    c(
      "CMD", "INSTALL",
      paste0("--library=", shQuote(missing_dependency_library)),
      shQuote(archives[["rrpplatform"]])
    ),
    missing_environment
  )
  require_true(
    !identical(missing_result$status, 0L),
    paste0(
      "rrpplatform unexpectedly installed without rrpruntime in its isolated ",
      "library."
    )
  )
  cat("PASS rrpplatform rejects installation without rrpruntime\n")

  for (package_name in names(package_specs)) {
    install_package(
      package_name, archives[[package_name]], library_root, environment
    )
    load_package_fresh(package_name, library_root)
    check_package(
      package_name, archives[[package_name]], work_root, library_root,
      environment
    )
    cat(sprintf(
      paste0(
        "PASS %-11s isolated install/load and R CMD check ",
        "--no-manual (Status: OK)\n"
      ),
      package_name
    ))
  }

  validate_installed_resource_access(library_root, work_root)
  validate_installed_project_loading(library_root, work_root)
  validate_installed_project_initialization(library_root, work_root)
  validate_installed_producer_execution(library_root, work_root, environment)
  validate_installed_risk_execution(library_root, work_root, environment)

  cat("\nResult: PASS (package, project, canonical, runtime, and history foundation)\n")
  cat(
    "Scope: closed source-resource authority, temporary deterministic installed ",
    "projection, explicit-root installed-package access, common result/diagnostic ",
    "canonical, five-resource runtime, and four-resource logical-history ",
    "contract relationships, dependency-light logical history records/port, ",
    "in-memory conformance, raw/current interpretation, dependency-light ",
    "canonical admission, exact eligibility and immutable episode-state ",
    "construction, provider-neutral request, direct compatible-provider ",
    "execution, accepted estimate, exact project-selected provider risk ",
    "execution, installed transparent/project provider substitution, ",
    "and kind-specific project contracts, ",
    "explicit trusted project loading, exact semantic producer and provider ",
    "selection, transactional minimal-project initialization, ",
    "selected producer execution, closed request/result validation, exact ",
    "one-call and zero-provider behavior, admission delegation, two distinct ",
    "hospital mapping fixtures, ",
    "loader-backed project diagnosis, copied-project portability, bounded ",
    "adversarial translation, resource-validation operation, package topology, metadata, ",
    "dependency direction, exact exports, build, isolated install/load, and ",
    "package-native check only.\n",
    sep = ""
  )
}

passed <- tryCatch(
  {
    validate_packages()
    TRUE
  },
  error = function(condition) {
    cat("\nResult: FAIL\n", file = stderr())
    cat("  ", conditionMessage(condition), "\n", sep = "", file = stderr())
    FALSE
  }
)

if (!passed) quit(save = "no", status = 1L, runLast = FALSE)
