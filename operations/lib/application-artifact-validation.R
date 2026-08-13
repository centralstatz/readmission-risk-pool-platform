# Repository validation for the target-neutral reduced application artifact.

rrp_validate_application_artifact_repository <- function(repository_root) {
  repository_root <- normalizePath(repository_root, mustWork = TRUE)
  checks <- list()
  issues <- list()
  required_files <- c(
    "contracts/deployment/application-artifact.yml",
    "app/application.yml",
    "deploy/application-artifact/runtime-dependencies.yml",
    "deploy/application-artifact/app.R",
    "deploy/application-artifact/validate-artifact.R",
    "deploy/application-artifact/R/artifact-runtime.R",
    "implementations/products/yaml/R/access.R",
    "operations/lib/application-artifact-operation.R",
    "operations/lib/application-artifact-validation.R",
    "operations/build-application-artifact.R",
    "operations/validate-application-artifact.R",
    "tests/phase8/test-application-artifact.R",
    "tests/run-phase8-tests.R",
    "docs/architecture/application-artifact-foundation.md",
    "docs/operations/application-artifacts.md"
  )
  missing <- required_files[!file.exists(file.path(repository_root, required_files))]
  for (path in missing) issues[[length(issues) + 1L]] <- rrp_issue(
    "phase8_required_files", "missing_phase8_file",
    "Required Iteration 8.1 application-artifact file is missing.", path
  )
  checks[[length(checks) + 1L]] <- rrp_check(
    "phase8_required_files", length(missing) == 0L,
    paste(length(required_files), "required Iteration 8.1 files")
  )

  documents <- tryCatch(
    rrp_read_application_artifact_documents(repository_root),
    error = function(condition) condition
  )
  documents_ok <- !inherits(documents, "condition")
  checks[[length(checks) + 1L]] <- rrp_check(
    "application_artifact_documents", documents_ok,
    "artifact contract, application, and runtime dependency declarations load"
  )
  if (!documents_ok) {
    issues[[length(issues) + 1L]] <- rrp_issue(
      "application_artifact_documents", "artifact_document_read_failure",
      conditionMessage(documents), "contracts/deployment/application-artifact.yml"
    )
  } else {
    for (name in c("contract", "application")) {
      result <- rrp_validate_specification_envelope(documents[[name]])
      if (!rrp_conforms(result)) for (index in seq_len(nrow(result$issues))) {
        issues[[length(issues) + 1L]] <- rrp_issue(
          "application_artifact_documents",
          result$issues$issue_code[[index]], result$issues$message[[index]],
          if (identical(name, "contract")) {
            "contracts/deployment/application-artifact.yml"
          } else "app/application.yml"
        )
      }
    }
    compatibility <- rrp_artifact_static_compatibility(list(
      artifact_contract = documents$contract,
      application = documents$application
    ))
    for (item in compatibility) issues[[length(issues) + 1L]] <- rrp_issue(
      "application_artifact_compatibility", item$issue_code[[1L]],
      item$message[[1L]], item$path[[1L]]
    )
    dependency_issues <- rrp_artifact_validate_dependencies(
      documents$dependencies, check_installed = TRUE
    )
    for (item in dependency_issues) issues[[length(issues) + 1L]] <- rrp_issue(
      "application_artifact_dependencies", item$issue_code[[1L]],
      item$message[[1L]], item$path[[1L]]
    )
    checks[[length(checks) + 1L]] <- rrp_check(
      "application_artifact_compatibility",
      length(compatibility) + length(dependency_issues) == 0L,
      "artifact, app, product, YAML, R, Shiny, and dependency lines agree"
    )
  }

  source_map <- rrp_application_artifact_source_map(repository_root)
  map_ok <- identical(names(source_map), rrp_artifact_runtime_files()) &&
    all(file.exists(unname(source_map))) && !anyDuplicated(names(source_map))
  if (!map_ok) issues[[length(issues) + 1L]] <- rrp_issue(
    "application_artifact_allowlist", "invalid_artifact_source_allowlist",
    "Builder source map must exactly match the closed runtime-file allowlist.",
    "operations/lib/application-artifact-operation.R"
  )
  checks[[length(checks) + 1L]] <- rrp_check(
    "application_artifact_allowlist", map_ok,
    paste(length(rrp_artifact_runtime_files()), "allowlisted runtime files")
  )

  runtime_files <- c(
    file.path(repository_root, "deploy", "application-artifact", "app.R"),
    file.path(repository_root, "deploy", "application-artifact", "validate-artifact.R"),
    file.path(repository_root, "deploy", "application-artifact", "R", "artifact-runtime.R")
  )
  runtime_text <- paste(unlist(lapply(runtime_files, readLines, warn = FALSE)), collapse = "\n")
  forbidden <- c(
    "DBI::", "duckdb::", "rrpruntime::", "read_run_history(",
    "execute_provider(", "generate_source", "rsconnect::", "git "
  )
  leaked <- forbidden[vapply(forbidden, grepl, logical(1), x = runtime_text, fixed = TRUE)]
  for (value in leaked) issues[[length(issues) + 1L]] <- rrp_issue(
    "application_artifact_boundary", "forbidden_artifact_runtime_dependency",
    paste0("Artifact runtime references prohibited upstream/target behavior: ", value),
    "deploy/application-artifact"
  )
  target_entries <- setdiff(
    list.files(file.path(repository_root, "deploy")),
    c("application-artifact", "connect-cloud")
  )
  if (length(target_entries) > 0L) for (entry in target_entries) {
    issues[[length(issues) + 1L]] <- rrp_issue(
      "phase8_scope", "premature_deployment_target",
      "Only completed Phase 8 artifact and Connect target implementations are authorized.",
      file.path("deploy", entry)
    )
  }
  checks[[length(checks) + 1L]] <- rrp_check(
    "application_artifact_boundary",
    length(leaked) + length(target_entries) == 0L,
    "no upstream runtime or unauthorized deployment target implementation"
  )

  record <- paste(rrp_read_text(file.path(
    repository_root, "docs", "architecture", "platform-implementation-record.md"
  )), collapse = "\n")
  recorded <- grepl(
    "### Iteration 8.1 — Target-neutral reduced application artifact",
    record, fixed = TRUE
  )
  if (!recorded) issues[[length(issues) + 1L]] <- rrp_issue(
    "phase8_implementation_record", "missing_iteration_8_1_record",
    "Implementation record must contain the Iteration 8.1 entry.",
    "docs/architecture/platform-implementation-record.md"
  )
  checks[[length(checks) + 1L]] <- rrp_check(
    "phase8_implementation_record", recorded,
    "Iteration 8.1 implementation evidence is recorded"
  )

  rrp_validation_result(
    "Target-neutral application artifact validation",
    rrp_bind_rows(checks, rrp_empty_checks),
    rrp_bind_rows(issues, rrp_empty_issues)
  )
}

rrp_validate_phase8_checkpoint <- function(repository_root) {
  result <- rrp_validate_application_artifact_repository(repository_root)
  structure(list(
    scope = "Completed Iteration 8.1 application-artifact checkpoint",
    checks = result$checks,
    issues = result$issues,
    passed = result$passed
  ), class = "rrp_validation_result")
}
