# Repository-level validation for the bounded Phase 9 diagnostic foundation.

rrp_validate_observability_repository <- function(repository_root) {
  repository_root <- normalizePath(repository_root, mustWork = TRUE)
  checks <- list()
  issues <- list()
  required <- c(
    "contracts/observability/operation-run-context.yml",
    "contracts/observability/operational-event.yml",
    "operations/lib/observability-operation.R",
    "operations/lib/observability-validation.R",
    "tests/run-phase9-tests.R",
    "tests/phase9/test-observability-foundation.R",
    "docs/architecture/observability-foundation.md",
    "docs/operations/observability-and-diagnostics.md"
  )
  missing <- required[!file.exists(file.path(repository_root, required))]
  for (path in missing) issues[[length(issues) + 1L]] <- rrp_issue(
    "observability_required_files", "missing_observability_file",
    "Required Phase 9 observability file is missing.", path
  )
  checks[[length(checks) + 1L]] <- rrp_check(
    "observability_required_files", length(missing) == 0L,
    paste(length(required), "required Phase 9 files")
  )

  identities <- list(
    operation_run_context = list(
      path = "contracts/observability/operation-run-context.yml",
      id = "platform.operation-run-context"
    ),
    operational_event = list(
      path = "contracts/observability/operational-event.yml",
      id = "platform.operational-diagnostic-event"
    )
  )
  identity_ok <- all(vapply(identities, function(identity) {
    document <- tryCatch(yaml::read_yaml(file.path(repository_root, identity$path)),
      error = function(condition) condition
    )
    !inherits(document, "condition") && identical(
      document$specification_id, identity$id
    ) && identical(document$specification_version, "0.1.0")
  }, logical(1)))
  if (!identity_ok) issues[[length(issues) + 1L]] <- rrp_issue(
    "observability_contracts", "invalid_observability_contract",
    "Observability contract identity or version is invalid.",
    "contracts/observability"
  )
  checks[[length(checks) + 1L]] <- rrp_check(
    "observability_contracts", identity_ok,
    "operation context and diagnostic event contracts are versioned"
  )

  source <- paste(readLines(file.path(
    repository_root, "operations", "lib", "observability-operation.R"
  ), warn = FALSE), collapse = "\n")
  no_persistence <- !any(vapply(c(
    "DBI::", "duckdb::", "write.csv", "saveRDS", "writeLines(event"
  ), grepl, logical(1), x = source, fixed = TRUE))
  privacy_controls <- grepl("rrp_observability_unsafe_pattern", source, fixed = TRUE) &&
    grepl("rrp_validate_safe_diagnostic_mapping", source, fixed = TRUE) &&
    grepl("rrp_observability_related_identity_keys", source, fixed = TRUE)
  if (!no_persistence || !privacy_controls) issues[[length(issues) + 1L]] <- rrp_issue(
    "observability_boundary", "unsafe_observability_boundary",
    "Diagnostics must remain in-memory/console-only with explicit privacy controls.",
    "operations/lib/observability-operation.R"
  )
  checks[[length(checks) + 1L]] <- rrp_check(
    "observability_boundary", no_persistence && privacy_controls,
    "base-R callable sink with no retained log and explicit safe context"
  )

  scripts <- c(
    "operations/doctor.R", "operations/run-platform.R",
    "operations/build-reference-products.R",
    "operations/build-application-artifact.R",
    "operations/build-connect-cloud-deployment.R"
  )
  instrumented <- all(vapply(scripts, function(path) grepl(
    "rrp_start_operation_observability", paste(readLines(
      file.path(repository_root, path), warn = FALSE
    ), collapse = "\n"), fixed = TRUE
  ), logical(1)))
  if (!instrumented) issues[[length(issues) + 1L]] <- rrp_issue(
    "observability_integration", "missing_operation_instrumentation",
    "Selected stable operations must use the common diagnostic boundary.",
    "operations"
  )
  checks[[length(checks) + 1L]] <- rrp_check(
    "observability_integration", instrumented,
    paste(length(scripts), "stable operations use one event interface")
  )

  record <- paste(readLines(file.path(
    repository_root, "docs", "architecture", "platform-implementation-record.md"
  ), warn = FALSE), collapse = "\n")
  recorded <- grepl(
    paste(
      "### Iteration 9.1 — Structured run context, operational events,",
      "and privacy-conscious console diagnostics"
    ),
    record, fixed = TRUE
  )
  if (!recorded) issues[[length(issues) + 1L]] <- rrp_issue(
    "phase9_implementation_record", "missing_iteration_9_1_record",
    "Implementation record must contain the Iteration 9.1 entry.",
    "docs/architecture/platform-implementation-record.md"
  )
  checks[[length(checks) + 1L]] <- rrp_check(
    "phase9_implementation_record", recorded,
    "Iteration 9.1 implementation evidence is recorded"
  )

  rrp_validation_result(
    "Observability foundation validation",
    rrp_bind_rows(checks, rrp_empty_checks),
    rrp_bind_rows(issues, rrp_empty_issues)
  )
}

rrp_validate_phase9_checkpoint <- function(repository_root) {
  rrp_validate_observability_repository(repository_root)
}
