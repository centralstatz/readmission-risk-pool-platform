library(rrpplatform)

rrp_runtime_test_internal <- function(name) {
  get(name, envir = asNamespace("rrpplatform"), inherits = FALSE)
}

rrp_runtime_test_write <- function(record, path) {
  dir.create(dirname(path), recursive = TRUE, showWarnings = FALSE)
  writeLines(paste0(names(record), ": ", unname(record)), path, useBytes = TRUE)
}

rrp_runtime_test_records <- function(records, path) {
  lines <- unlist(lapply(seq_along(records), function(index) {
    value <- paste0(names(records[[index]]), ": ", unname(records[[index]]))
    if (index < length(records)) c(value, "") else value
  }), use.names = FALSE)
  writeLines(lines, path, useBytes = TRUE)
}

rrp_runtime_test_fixture <- function(mutate = NULL) {
  root <- tempfile("rrp-runtime-contracts-")
  dir.create(file.path(root, "resources"), recursive = TRUE)
  canonical <- rrp_runtime_test_internal(
    "rrp_canonical_contract_definitions"
  )()
  runtime <- rrp_runtime_test_internal("rrp_runtime_contract_definitions")()
  if (!is.null(mutate)) runtime <- mutate(runtime)
  schema <- rrp_runtime_test_internal("rrp_resource_schema_contract")()
  rrp_runtime_test_write(
    schema, file.path(root, "resources", "resource-catalog-schema.dcf")
  )
  definitions <- c(canonical, runtime)
  for (definition in definitions) {
    rrp_runtime_test_write(
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
  rrp_runtime_test_records(
    c(list(header), entries),
    file.path(root, "resources", "resource-catalog.dcf")
  )
  root
}

rrp_runtime_test_expect_error <- function(root, code) {
  on.exit(unlink(root, recursive = TRUE, force = TRUE), add = TRUE)
  catalog <- rrp_open_resource_catalog(root)
  canonical <- rrp_runtime_test_internal("rrp_canonical_contracts")(catalog)
  condition <- tryCatch({
    rrp_runtime_test_internal("rrp_runtime_contracts")(catalog, canonical)
    NULL
  }, error = identity)
  stopifnot(
    inherits(condition, "rrp_resource_error"),
    identical(condition$code, code),
    !grepl(root, condition$message, fixed = TRUE),
    !grepl("[/\\]", condition$message)
  )
}

root <- rrp_runtime_test_fixture()
on.exit(unlink(root, recursive = TRUE, force = TRUE), add = TRUE)
catalog <- rrp_open_resource_catalog(root)
canonical <- rrp_runtime_test_internal("rrp_canonical_contracts")(catalog)
contracts <- rrp_runtime_test_internal("rrp_runtime_contracts")(
  catalog, canonical
)
definitions <- rrp_runtime_test_internal("rrp_runtime_contract_definitions")()
context <- rrp_runtime_test_internal("rrp_episode_state_expected_context")(
  contracts, canonical
)
stopifnot(
  identical(names(contracts), names(definitions)),
  all(vapply(names(definitions), function(name) {
    identical(contracts[[name]], as.list(definitions[[name]]$expected))
  }, logical(1L))),
  identical(names(context), c(
    "product_id", "development_version", "target_id", "target_version",
    "state_contract_id", "state_contract_version", "bundle_contract_id",
    "bundle_contract_version", "canonical_profile_id",
    "canonical_profile_version", "target_event", "conditioning",
    "endpoint_elapsed_seconds", "eligible_as_of_start",
    "eligible_as_of_end", "target_interval", "information_cutoff",
    "competing_event", "equal_time_precedence", "target_selection",
    "terminal_status"
  )),
  identical(context$endpoint_elapsed_seconds, 2592000),
  identical(context$eligible_as_of_start, "inclusive"),
  identical(context$eligible_as_of_end, "exclusive")
)

admission_context <- rrp_runtime_test_internal(
  "rrp_canonical_admission_context"
)(
  canonical, "integration-health-system", "1.0.0",
  "integration.producer", "1.0.0", "integration.implementation", "1.0.0",
  "integration.mapping", "1.0.0", "2026-01-20T12:00:00Z"
)
candidate <- c(
  admission_context[c("bundle_contract_id", "bundle_contract_version")],
  list(bundle_instance_id = "integration.bundle-state"),
  admission_context[c(
    "project_id", "project_version", "producer_id", "producer_version",
    "implementation_id", "implementation_version", "mapping_id",
    "mapping_version", "canonical_profile_id", "canonical_profile_version"
  )],
  list(
    as_of_time = admission_context$as_of_time,
    capabilities = admission_context$capabilities,
    domains = list(
      discharge_episode = data.frame(
        episode_id = "episode-001", patient_id = "patient-001",
        index_encounter_id = "encounter-001",
        admission_time = "2026-01-09T12:00:00Z",
        discharge_time = "2026-01-10T12:00:00Z",
        followup_window_end = "2026-02-09T12:00:00Z",
        stringsAsFactors = FALSE
      ),
      terminal_event = data.frame(
        terminal_event_id = character(), episode_id = character(),
        event_type = character(), occurred_at = character(),
        available_at = character(), stringsAsFactors = FALSE
      )
    )
  )
)
admitted <- rrpruntime::rrp_admit_canonical_bundle(
  candidate, admission_context
)
state <- rrpruntime::rrp_prepare_episode_state(
  admitted, "episode-001", "2026-01-20T06:00:00-06:00", context
)
stopifnot(
  identical(class(state), c("rrp_episode_state", "list")),
  identical(state$target_id, context$target_id),
  identical(state$as_of_time, "2026-01-20T12:00:00Z"),
  identical(state$elapsed_seconds_since_discharge, 864000),
  identical(state$remaining_seconds_through_w30, 1728000)
)

rrp_runtime_test_expect_error(rrp_runtime_test_fixture(function(definitions) {
  definitions$episode_state$expected[["Unknown-Field"]] <- "not-allowed"
  definitions
}), "invalid_runtime_contract_fields")

rrp_runtime_test_expect_error(rrp_runtime_test_fixture(function(definitions) {
  definitions$readmission_risk_target$expected[["Specification-Version"]] <-
    "9.9.9"
  definitions
}), "unsupported_runtime_contract")

incompatible <- contracts
incompatible$episode_state[["Target-Version"]] <- "9.9.9"
condition <- tryCatch({
  rrp_runtime_test_internal("rrp_runtime_validate_relationships")(
    incompatible, canonical
  )
  NULL
}, error = identity)
stopifnot(
  inherits(condition, "rrp_resource_error"),
  identical(condition$code, "incompatible_runtime_contracts")
)

cat("rrpplatform runtime-contract tests passed\n")
