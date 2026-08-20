# Repository and checkpoint evidence for the generic canonical-producer seam.

rrp_validate_canonical_producer_repository <- function(repository_root) {
  required <- c(
    "contracts/canonical/canonical-producer.yml",
    "config/platform-instance.yml",
    "implementations/synthetic-reference/producer.yml",
    "implementations/synthetic-reference/R/canonical-producer-adapter.R",
    "operations/lib/canonical-producer-operation.R",
    "operations/compositions/installed-producers.R",
    "operations/validate-producer.R",
    "tests/run-phase10-tests.R",
    "tests/phase10/test-canonical-producer-foundation.R",
    "tests/phase10/test-independent-adopter-producer.R",
    "tests/phase10/fixtures/adopter-producer/README.md",
    "tests/phase10/fixtures/adopter-producer/producer.yml",
    "tests/phase10/fixtures/adopter-producer/platform-instance.yml",
    "tests/phase10/fixtures/adopter-producer/source-configuration.yml",
    "tests/phase10/fixtures/adopter-producer/source-schema.yml",
    "tests/phase10/fixtures/adopter-producer/R/foundation.R",
    "tests/phase10/fixtures/adopter-producer/R/source-validation.R",
    "tests/phase10/fixtures/adopter-producer/R/mapping.R",
    "tests/phase10/fixtures/adopter-producer/R/adapter.R",
    "tests/phase10/fixtures/adopter-producer/R/composition.R",
    "docs/architecture/canonical-producer-foundation.md"
  )
  present <- file.exists(file.path(repository_root, required))
  checks <- do.call(rbind, lapply(seq_along(required), function(index) {
    rrp_check(
      paste0("producer_required_", index), present[[index]],
      paste0("Required producer-seam file exists: ", required[[index]])
    )
  }))
  issues <- lapply(required[!present], function(path) rrp_issue(
    "canonical_producer_repository", "missing_canonical_producer_file",
    paste0("Required canonical-producer file is missing: ", path), path
  ))
  if (all(present)) {
    composition <- tryCatch(
      rrp_installed_canonical_producer_composition(repository_root),
      error = function(condition) condition
    )
    valid <- !inherits(composition, "condition")
    checks <- rbind(checks, rrp_check(
      "producer_installed_composition", valid,
      if (valid) "Installed producer declaration, registration, and selection conform" else {
        conditionMessage(composition)
      }
    ))
    if (!valid) issues[[length(issues) + 1L]] <- rrp_issue(
      "canonical_producer_repository", "invalid_installed_producer_composition",
      conditionMessage(composition), "config/platform-instance.yml"
    )
  }
  run_text <- paste(readLines(
    file.path(repository_root, "operations", "run-platform.R"), warn = FALSE
  ), collapse = "\n")
  generic_run <- !grepl(
    "synthetic-reference|rrp_run_synthetic|generate-source|map-to-canonical",
    run_text
  )
  checks <- rbind(checks, rrp_check(
    "producer_generic_platform_run", generic_run,
    "Stable platform run contains no source-specific producer orchestration"
  ))
  if (!generic_run) issues[[length(issues) + 1L]] <- rrp_issue(
    "canonical_producer_repository", "source_specific_platform_run",
    "Stable platform run must invoke the installed producer through the generic seam.",
    "operations/run-platform.R"
  )
  rrp_validation_result(
    "Canonical producer repository", checks,
    rrp_bind_rows(issues, rrp_empty_issues)
  )
}

rrp_validate_phase10_checkpoint <- function(repository_root) {
  record <- readLines(file.path(
    repository_root, "docs", "architecture", "platform-implementation-record.md"
  ), warn = FALSE)
  text <- paste(record, collapse = "\n")
  evidence <- grepl(
    "Iteration 10.1 — Generic canonical-producer interface and adopter handoff foundation",
    text, fixed = TRUE
  ) && grepl(
    "Iteration 10.2 — Independent adopter-side producer conformance proof",
    text, fixed = TRUE
  ) && grepl("Phase 10 status", text, fixed = TRUE) &&
    grepl("**COMPLETE.**", text, fixed = TRUE)
  checks <- rrp_check(
    "phase10_iteration_checkpoint", evidence,
    "Iterations 10.1 and 10.2 are recorded and Phase 10 is complete"
  )
  issues <- if (evidence) rrp_empty_issues() else rrp_issue(
    "phase10_checkpoint", "missing_phase10_iteration_record",
    "Implementation record must record Iteration 10.2 evidence and close Phase 10.",
    "docs/architecture/platform-implementation-record.md"
  )
  rrp_validation_result("Phase 10 checkpoint", checks, issues)
}
