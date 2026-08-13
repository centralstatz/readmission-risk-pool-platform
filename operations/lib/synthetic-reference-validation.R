# Repository and checkpoint validation for the Phase 3 reference implementation.

rrp_validate_synthetic_reference_repository <- function(repository_root) {
  repository_root <- normalizePath(repository_root, mustWork = TRUE)
  checks <- list()
  issues <- list()
  implementation <- rrp_read_synthetic_implementation_specification(repository_root)
  schema <- rrp_read_synthetic_source_schema(repository_root)
  validations <- list(
    implementation = rrp_validate_synthetic_implementation_specification(
      implementation, "implementations/synthetic-reference/implementation.yml"
    ),
    source_schema = rrp_validate_synthetic_source_schema_specification(
      schema, "implementations/synthetic-reference/source-schema.yml"
    )
  )
  for (scale in c("test", "reference")) {
    config <- rrp_read_synthetic_configuration(repository_root, scale)
    validations[[paste0("configuration_", scale)]] <-
      rrp_validate_synthetic_configuration(
        config,
        implementation,
        paste0("implementations/synthetic-reference/config/", scale, ".yml")
      )
  }
  for (name in names(validations)) {
    result <- validations[[name]]
    checks[[length(checks) + 1L]] <- rrp_check(
      paste0("synthetic_specification:", name),
      rrp_conforms(result),
      if (rrp_conforms(result)) "supported identity and semantics" else {
        paste(nrow(result$issues), "conformance issue(s)")
      }
    )
    for (index in seq_len(nrow(result$issues))) {
      issue <- result$issues[index, ]
      issues[[length(issues) + 1L]] <- rrp_issue(
        paste0("synthetic_specification:", name),
        issue$issue_code,
        paste0("[", issue$rule_id, "] ", issue$message),
        issue$location
      )
    }
  }
  rrp_validation_result(
    "Synthetic reference specification validation",
    rrp_bind_rows(checks, rrp_empty_checks),
    rrp_bind_rows(issues, rrp_empty_issues)
  )
}

rrp_validate_phase3_checkpoint <- function(repository_root) {
  repository_root <- normalizePath(repository_root, mustWork = TRUE)
  checks <- list()
  issues <- list()
  required_files <- c(
    "implementations/synthetic-reference/implementation.yml",
    "implementations/synthetic-reference/source-schema.yml",
    "implementations/synthetic-reference/config/test.yml",
    "implementations/synthetic-reference/config/reference.yml",
    "implementations/synthetic-reference/R/identity-configuration.R",
    "implementations/synthetic-reference/R/generate-source.R",
    "implementations/synthetic-reference/R/source-validation.R",
    "implementations/synthetic-reference/R/map-to-canonical.R",
    "implementations/synthetic-reference/R/producer.R",
    "implementations/synthetic-reference/README.md",
    "docs/architecture/synthetic-reference-implementation.md",
    "docs/operations/generate-reference.md",
    "operations/generate-reference.R",
    "operations/lib/synthetic-reference-validation.R",
    "tests/phase3/test-synthetic-reference-producer.R",
    "tests/run-phase3-tests.R"
  )
  missing <- required_files[!file.exists(file.path(repository_root, required_files))]
  for (path in missing) {
    issues[[length(issues) + 1L]] <- rrp_issue(
      "phase3_required_files", "missing_phase3_file",
      "Required Phase 3 reference implementation file is missing.", path
    )
  }
  checks[[length(checks) + 1L]] <- rrp_check(
    "phase3_required_files", length(missing) == 0L,
    paste(length(required_files), "required Phase 3 files")
  )

  implementation_root <- file.path(
    repository_root, "implementations", "synthetic-reference"
  )
  actual_files <- if (dir.exists(implementation_root)) {
    sort(list.files(
      implementation_root, recursive = TRUE, full.names = FALSE,
      all.files = TRUE, include.dirs = FALSE, no.. = TRUE
    ))
  } else {
    character()
  }
  expected_files <- sub("^implementations/synthetic-reference/", "", required_files[
    startsWith(required_files, "implementations/")
  ])
  unexpected_files <- setdiff(actual_files, expected_files)
  for (path in unexpected_files) {
    issues[[length(issues) + 1L]] <- rrp_issue(
      "phase3_implementation_scope", "unexpected_implementation_file",
      "Only the approved synthetic reference implementation belongs in Phase 3.",
      file.path("implementations", "synthetic-reference", path)
    )
  }
  all_implementation_files <- sort(list.files(
    file.path(repository_root, "implementations"), recursive = TRUE,
    full.names = FALSE, all.files = TRUE, include.dirs = FALSE, no.. = TRUE
  ))
  generated_files <- all_implementation_files[grepl(
    "[.](csv|rds|rda|parquet|feather|duckdb|wal)$",
    all_implementation_files, ignore.case = TRUE
  )]
  for (path in generated_files) {
    issues[[length(issues) + 1L]] <- rrp_issue(
      "phase3_generated_data", "committed_generated_reference_data",
      "Generated source/canonical datasets are not committed in Phase 3.",
      file.path("implementations", path)
    )
  }
  checks[[length(checks) + 1L]] <- rrp_check(
    "phase3_implementation_scope",
    length(unexpected_files) + length(generated_files) == 0L,
    "only implementation source/specification/docs; no generated datasets"
  )

  prohibited_directories <- c(
    "providers", "persistence", "deploy",
    "config", "observability"
  )
  premature <- prohibited_directories[dir.exists(file.path(
    repository_root, prohibited_directories
  ))]
  for (path in premature) {
    issues[[length(issues) + 1L]] <- rrp_issue(
      "phase3_scope", "premature_phase3_content",
      "An unauthorized top-level runtime or later-phase directory is present.", path
    )
  }
  checks[[length(checks) + 1L]] <- rrp_check(
    "phase3_scope", length(premature) == 0L,
    "no unauthorized top-level runtime or later-layer directory"
  )

  reference <- tryCatch(
    rrp_run_synthetic_reference(repository_root, "reference"),
    error = function(condition) condition
  )
  reference_ok <- inherits(reference, "rrp_synthetic_producer_result") &&
    identical(reference$overall_status, "succeeded") &&
    rrp_conforms(reference$source_local_conformance) &&
    rrp_conforms(reference$canonical_conformance)
  if (!reference_ok) {
    issues[[length(issues) + 1L]] <- rrp_issue(
      "phase3_reference_flow", "reference_flow_failed",
      "Reference-scale source-to-canonical producer must conform.",
      "operations/generate-reference.R"
    )
  }
  checks[[length(checks) + 1L]] <- rrp_check(
    "phase3_reference_flow", reference_ok,
    if (reference_ok) {
      paste0(
        reference$summary$patients, " patients; ",
        reference$summary$discharge_episodes, " episodes; ",
        reference$summary$event_records, " admitted events"
      )
    } else {
      "reference flow did not conform"
    }
  )

  record_path <- file.path(
    repository_root, "docs", "architecture", "platform-implementation-record.md"
  )
  record_text <- if (file.exists(record_path)) {
    paste(rrp_read_text(record_path), collapse = "\n")
  } else {
    ""
  }
  heading <- "### Iteration 3.1 — Synthetic reference source and canonical producer"
  recorded <- grepl(heading, record_text, fixed = TRUE)
  if (!recorded) {
    issues[[length(issues) + 1L]] <- rrp_issue(
      "phase3_implementation_record", "missing_phase3_implementation_record",
      "Implementation record must contain the completed Iteration 3.1 entry.",
      "docs/architecture/platform-implementation-record.md"
    )
  }
  checks[[length(checks) + 1L]] <- rrp_check(
    "phase3_implementation_record", recorded,
    "Iteration 3.1 implementation evidence is recorded"
  )

  rrp_validation_result(
    "Phase 3 checkpoint validation",
    rrp_bind_rows(checks, rrp_empty_checks),
    rrp_bind_rows(issues, rrp_empty_issues)
  )
}
