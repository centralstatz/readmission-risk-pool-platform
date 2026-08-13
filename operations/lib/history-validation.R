# Repository validation for Phase 5 operational-history semantics, ports, and
# concrete DuckDB reference conformance.

rrp_history_contract_paths <- function(repository_root) c(
  operational_run_status = file.path(
    repository_root, "contracts", "persistence", "operational-run-status.yml"
  ),
  invalidation = file.path(
    repository_root, "contracts", "persistence", "history-invalidation.yml"
  ),
  persistence_adapter = file.path(
    repository_root, "contracts", "persistence", "persistence-adapter.yml"
  )
)

rrp_read_history_contracts <- function(repository_root) {
  paths <- rrp_history_contract_paths(repository_root)
  documents <- lapply(paths, function(path) {
    parsed <- rrp_parse_yaml_specification(path)
    if (!is.null(parsed$error)) stop(
      "Could not read history contract: ", parsed$error, call. = FALSE
    )
    parsed$document
  })
  names(documents) <- names(paths)
  documents
}

rrp_validate_history_repository <- function(repository_root) {
  repository_root <- normalizePath(repository_root, mustWork = TRUE)
  checks <- list()
  issues <- list()
  contracts <- tryCatch(
    rrp_read_history_contracts(repository_root),
    error = function(condition) condition
  )
  loaded <- !inherits(contracts, "condition")
  checks[[length(checks) + 1L]] <- rrp_check(
    "history_contract_documents", loaded,
    if (loaded) "three operational-history contracts loaded" else {
      "operational-history contracts could not be read"
    }
  )
  if (!loaded) issues[[length(issues) + 1L]] <- rrp_issue(
    "history_contract_documents", "history_contract_read_failed",
    conditionMessage(contracts), "contracts/persistence"
  ) else {
    paths <- rrp_history_contract_paths(repository_root)
    for (name in names(contracts)) {
      relative <- rrp_repository_relative_path(repository_root, paths[[name]])
      envelope <- rrp_validate_specification_envelope(contracts[[name]], relative)
      checks[[length(checks) + 1L]] <- rrp_check(
        paste0("history_specification:", name), rrp_conforms(envelope),
        paste0(contracts[[name]]$specification_id, "@", contracts[[name]]$specification_version)
      )
      for (index in seq_len(nrow(envelope$issues))) {
        issue <- envelope$issues[index, ]
        issues[[length(issues) + 1L]] <- rrp_issue(
          paste0("history_specification:", name), issue$issue_code,
          issue$message, relative
        )
      }
    }
  }
  description <- read.dcf(file.path(repository_root, "runtime", "DESCRIPTION"))
  dependency_fields <- intersect(c("Imports", "Suggests", "LinkingTo"), colnames(description))
  no_backend_dependencies <- length(dependency_fields) == 0L
  checks[[length(checks) + 1L]] <- rrp_check(
    "history_backend_independence", no_backend_dependencies,
    "rrpruntime has no storage package dependencies"
  )
  if (!no_backend_dependencies) issues[[length(issues) + 1L]] <- rrp_issue(
    "history_backend_independence", "storage_dependency_added",
    "Generic runtime must not select a concrete storage dependency.",
    "runtime/DESCRIPTION"
  )
  rrp_validation_result(
    "Operational-history contract and port validation",
    rrp_bind_rows(checks, rrp_empty_checks),
    rrp_bind_rows(issues, rrp_empty_issues)
  )
}

rrp_validate_phase5_checkpoint <- function(repository_root) {
  repository_root <- normalizePath(repository_root, mustWork = TRUE)
  checks <- list()
  issues <- list()
  required_files <- c(
    "contracts/persistence/operational-run-status.yml",
    "contracts/persistence/history-invalidation.yml",
    "contracts/persistence/persistence-adapter.yml",
    "runtime/R/history-specification.R", "runtime/R/history-records.R",
    "runtime/R/history-conformance.R", "runtime/R/persistence-port.R",
    "runtime/man/history-api.Rd",
    "tests/helpers/in-memory-history-adapter.R",
    "tests/phase5/test-operational-history.R", "tests/run-phase5-tests.R",
    "operations/lib/history-validation.R",
    "docs/architecture/operational-history-foundation.md",
    "implementations/persistence/duckdb/adapter.yml",
    "implementations/persistence/duckdb/config/reference.yml",
    "implementations/persistence/duckdb/R/foundation.R",
    "implementations/persistence/duckdb/R/schema.R",
    "implementations/persistence/duckdb/R/adapter.R",
    "implementations/persistence/duckdb/R/session.R",
    "operations/lib/duckdb-persistence-operation.R",
    "operations/lib/reference-history-operation.R",
    "operations/run-reference-history.R",
    "operations/inspect-reference-history.R",
    "operations/backup-reference-history.R",
    "tests/phase5/test-duckdb-persistence.R",
    "docs/architecture/duckdb-reference-persistence.md",
    "docs/operations/reference-history.md"
  )
  missing <- required_files[!file.exists(file.path(repository_root, required_files))]
  for (path in missing) issues[[length(issues) + 1L]] <- rrp_issue(
    "phase5_required_files", "missing_phase5_file",
    "Required completed Phase 5 file is missing.", path
  )
  checks[[length(checks) + 1L]] <- rrp_check(
    "phase5_required_files", length(missing) == 0L,
    paste(length(required_files), "required Phase 5 files")
  )
  prohibited_directories <- c("deploy", "config", "observability")
  premature <- prohibited_directories[dir.exists(file.path(
    repository_root, prohibited_directories
  ))]
  for (path in premature) issues[[length(issues) + 1L]] <- rrp_issue(
    "phase5_scope", "premature_phase5_content",
    "A still-unauthorized later layer is premature.", path
  )
  checks[[length(checks) + 1L]] <- rrp_check(
    "phase5_scope", length(premature) == 0L,
    "no deployment, root configuration, or observability implementation"
  )
  record_path <- file.path(
    repository_root, "docs", "architecture", "platform-implementation-record.md"
  )
  record_text <- if (file.exists(record_path)) paste(
    rrp_read_text(record_path), collapse = "\n"
  ) else ""
  headings <- c(
    "### Iteration 5.1 — Operational history semantics and persistence ports",
    "### Iteration 5.2 — DuckDB reference persistence adapter and durable vertical slice"
  )
  recorded <- all(vapply(headings, grepl, logical(1), x = record_text, fixed = TRUE))
  if (!recorded) issues[[length(issues) + 1L]] <- rrp_issue(
    "phase5_implementation_record", "missing_phase5_implementation_record",
    "Implementation record must contain the Iteration 5.1 and 5.2 entries.",
    "docs/architecture/platform-implementation-record.md"
  )
  checks[[length(checks) + 1L]] <- rrp_check(
    "phase5_implementation_record", recorded,
    "Iterations 5.1 and 5.2 implementation evidence is recorded"
  )
  lock_text <- paste(readLines(
    file.path(repository_root, "renv.lock"), warn = FALSE
  ), collapse = "\n")
  dependencies_ok <- all(vapply(c('"DBI"', '"duckdb"', '"yaml"'), function(value) {
    grepl(value, lock_text, fixed = TRUE)
  }, logical(1)))
  if (!dependencies_ok) issues[[length(issues) + 1L]] <- rrp_issue(
    "phase5_dependencies", "missing_reference_adapter_dependency",
    "renv.lock must record yaml, DBI, and duckdb.", "renv.lock"
  )
  checks[[length(checks) + 1L]] <- rrp_check(
    "phase5_dependencies", dependencies_ok,
    "adapter-only DBI and DuckDB dependencies are locked"
  )
  rrp_validation_result(
    "Completed Phase 5 strict checkpoint validation",
    rrp_bind_rows(checks, rrp_empty_checks),
    rrp_bind_rows(issues, rrp_empty_issues)
  )
}
