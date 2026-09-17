library(rrpplatform)

rrp_canonical_test_internal <- function(name) {
  get(name, envir = asNamespace("rrpplatform"), inherits = FALSE)
}

rrp_canonical_test_write_record <- function(record, path) {
  dir.create(dirname(path), recursive = TRUE, showWarnings = FALSE)
  writeLines(paste0(names(record), ": ", unname(record)), path, useBytes = TRUE)
}

rrp_canonical_test_write_records <- function(records, path) {
  lines <- unlist(lapply(seq_along(records), function(index) {
    fields <- paste0(names(records[[index]]), ": ", unname(records[[index]]))
    if (index < length(records)) c(fields, "") else fields
  }), use.names = FALSE)
  writeLines(lines, path, useBytes = TRUE)
}

rrp_canonical_test_fixture <- function(mutate = NULL) {
  root <- tempfile("rrp-canonical-contracts-")
  dir.create(file.path(root, "resources"), recursive = TRUE)
  definitions <- rrp_canonical_test_internal(
    "rrp_canonical_contract_definitions"
  )()
  if (!is.null(mutate)) definitions <- mutate(definitions)
  schema <- rrp_canonical_test_internal("rrp_resource_schema_contract")()
  rrp_canonical_test_write_record(
    schema, file.path(root, "resources", "resource-catalog-schema.dcf")
  )
  for (definition in definitions) {
    rrp_canonical_test_write_record(
      definition$expected, file.path(root, definition$path)
    )
  }
  header <- c(
    "Record-Type" = "catalog", "Catalog-ID" = "rrp.software-resources",
    "Catalog-Version" = "0.1.0", "Format-Version" = "1.0.0",
    "Product-ID" = "readmission-risk-pool-platform",
    "Development-Version" = "1.0.0-dev",
    "Status" = "development_unpublished"
  )
  entries <- list(c(
    "Record-Type" = "resource",
    "Resource-ID" = "rrp.contract.resource-catalog",
    "Resource-Class" = "contract", "Owner-Package" = "rrpplatform",
    "Installed-Path" = "resources/resource-catalog-schema.dcf",
    "Format" = "dcf"
  ))
  entries <- c(entries, lapply(definitions, function(definition) c(
    "Record-Type" = "resource", "Resource-ID" = definition$resource_id,
    "Resource-Class" = "contract", "Owner-Package" = definition$owner,
    "Installed-Path" = definition$path, "Format" = "dcf"
  )))
  rrp_canonical_test_write_records(
    c(list(header), entries),
    file.path(root, "resources", "resource-catalog.dcf")
  )
  root
}

rrp_canonical_test_error <- function(root, code) {
  on.exit(unlink(root, recursive = TRUE, force = TRUE), add = TRUE)
  catalog <- rrp_open_resource_catalog(root)
  condition <- tryCatch({
    rrp_canonical_test_internal("rrp_canonical_contracts")(catalog)
    NULL
  }, error = identity)
  stopifnot(
    inherits(condition, "rrp_resource_error"),
    identical(condition$code, code),
    !grepl(root, condition$message, fixed = TRUE),
    !grepl("[/\\]", condition$message)
  )
}

root <- rrp_canonical_test_fixture()
on.exit(unlink(root, recursive = TRUE, force = TRUE), add = TRUE)
catalog <- rrp_open_resource_catalog(root)
contracts <- rrp_canonical_test_internal("rrp_canonical_contracts")(catalog)
definitions <- rrp_canonical_test_internal("rrp_canonical_contract_definitions")()
stopifnot(
  identical(names(contracts), names(definitions)),
  all(vapply(names(definitions), function(name) {
    identical(contracts[[name]], as.list(definitions[[name]]$expected))
  }, logical(1L))),
  identical(
    rrp_canonical_test_internal("rrp_canonical_required_capabilities")(
      contracts
    ),
    list(
      list(
        capability_id = "rrp.capability.discharge-episode",
        status = "available"
      ),
      list(
        capability_id = "rrp.capability.terminal-event",
        status = "available"
      )
    )
  )
)

admission_context <- rrp_canonical_test_internal(
  "rrp_canonical_admission_context"
)(
  contracts,
  project_id = "integration-health-system",
  project_version = "1.0.0",
  producer_id = "integration.producer",
  producer_version = "1.0.0",
  implementation_id = "integration.implementation",
  implementation_version = "1.0.0",
  mapping_id = "integration.mapping",
  mapping_version = "1.0.0",
  as_of_time = "2026-02-10T06:00:00-06:00"
)
integration_candidate <- c(
  admission_context[c("bundle_contract_id", "bundle_contract_version")],
  list(bundle_instance_id = "integration.bundle-001"),
  admission_context[c(
    "project_id", "project_version", "producer_id", "producer_version",
    "implementation_id", "implementation_version", "mapping_id",
    "mapping_version", "canonical_profile_id", "canonical_profile_version"
  )],
  list(
    as_of_time = "2026-02-10T12:00:00Z",
    capabilities = admission_context$capabilities,
    domains = list(
      discharge_episode = data.frame(
        episode_id = "integration-episode-001",
        patient_id = "integration-patient-001",
        index_encounter_id = "integration-encounter-001",
        admission_time = "2026-01-01T08:00:00-06:00",
        discharge_time = "2026-01-02T08:00:00-06:00",
        followup_window_end = "2026-02-01T14:00:00Z",
        stringsAsFactors = FALSE
      ),
      terminal_event = data.frame(
        terminal_event_id = "integration-event-001",
        episode_id = "integration-episode-001",
        event_type = "readmission",
        occurred_at = "2026-01-15T12:00:00-06:00",
        available_at = "2026-01-16T01:00:00+07:00",
        stringsAsFactors = FALSE
      )
    )
  )
)
admitted <- rrpruntime::rrp_admit_canonical_bundle(
  integration_candidate, admission_context
)
stopifnot(
  identical(class(admitted), c("rrp_admitted_canonical_bundle", "list")),
  identical(admitted$bundle_contract_id, contracts$canonical_bundle[[
    "Specification-ID"
  ]]),
  identical(admitted$canonical_profile_id, contracts$readmission_profile[[
    "Specification-ID"
  ]])
)

rrp_canonical_test_error(rrp_canonical_test_fixture(function(definitions) {
  definitions$canonical_bundle$expected[["Unknown-Field"]] <- "not-allowed"
  definitions
}), "invalid_canonical_contract_fields")

rrp_canonical_test_error(rrp_canonical_test_fixture(function(definitions) {
  definitions$canonical_bundle$expected[["Canonical-Profile-Version"]] <- "9.9.9"
  definitions
}), "unsupported_canonical_contract")

incompatible <- contracts
incompatible$terminal_event[["Episode-Reference-Domain"]] <- "other_domain"
condition <- tryCatch({
  rrp_canonical_test_internal("rrp_canonical_validate_relationships")(
    incompatible
  )
  NULL
}, error = identity)
stopifnot(
  inherits(condition, "rrp_resource_error"),
  identical(condition$code, "incompatible_canonical_contracts")
)

cat("rrpplatform canonical-contract tests passed\n")
