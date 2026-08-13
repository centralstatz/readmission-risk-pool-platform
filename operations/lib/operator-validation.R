# Repository validation for the stable Phase 7 human operation surface.

rrp_read_operations_registry <- function(repository_root) {
  path <- file.path(repository_root, "operations", "operations.yml")
  parsed <- rrp_parse_yaml_specification(path)
  if (!is.null(parsed$error)) stop(
    "Could not read the operations registry: ", parsed$error, call. = FALSE
  )
  parsed$document
}

rrp_operation_command_script <- function(command) {
  fields <- strsplit(command, "[[:space:]]+", perl = TRUE)[[1L]]
  if (length(fields) < 2L || !identical(fields[[1L]], "Rscript")) return(NULL)
  fields[[2L]]
}

rrp_validate_operator_repository <- function(repository_root) {
  repository_root <- normalizePath(repository_root, mustWork = TRUE)
  checks <- list()
  issues <- list()
  required_files <- c(
    "operations/operations.yml", "operations/initialize-platform.R",
    "operations/doctor.R", "operations/run-platform.R",
    "operations/lib/operator-operation.R",
    "operations/lib/operator-validation.R",
    "docs/operations/operator-manual.md",
    "docs/adoption/progressive-implementation.md",
    "tests/run-phase7-tests.R", "tests/phase7/test-stable-operations.R"
  )
  missing <- required_files[!file.exists(file.path(repository_root, required_files))]
  for (path in missing) issues[[length(issues) + 1L]] <- rrp_issue(
    "operator_required_files", "missing_operator_file",
    "Required Phase 7 operator file is missing.", path
  )
  checks[[length(checks) + 1L]] <- rrp_check(
    "operator_required_files", length(missing) == 0L,
    paste(length(required_files), "required Phase 7 files")
  )

  registry <- tryCatch(
    rrp_read_operations_registry(repository_root),
    error = function(condition) condition
  )
  registry_ok <- !inherits(registry, "condition") &&
    identical(registry$registry_version, 1L) && is.list(registry$operations)
  checks[[length(checks) + 1L]] <- rrp_check(
    "operation_registry", registry_ok,
    "lightweight registry is readable and versioned"
  )
  if (!registry_ok) {
    issues[[length(issues) + 1L]] <- rrp_issue(
      "operation_registry", "invalid_operation_registry",
      if (inherits(registry, "condition")) conditionMessage(registry) else {
        "Operations registry has an invalid top-level shape."
      },
      "operations/operations.yml"
    )
  } else {
    required_fields <- c(
      "operation_id", "command", "purpose", "mutation",
      "classification", "documentation"
    )
    ids <- character()
    for (index in seq_along(registry$operations)) {
      operation <- registry$operations[[index]]
      location <- paste0("operations/operations.yml#", index)
      absent <- required_fields[!required_fields %in% names(operation)]
      if (length(absent) > 0L) issues[[length(issues) + 1L]] <- rrp_issue(
        "operation_registry", "incomplete_operation_registration",
        paste("Operation is missing:", paste(absent, collapse = ", ")), location
      )
      if (!is.null(operation$operation_id)) ids <- c(ids, operation$operation_id)
      if (!is.null(operation$classification) &&
          !operation$classification %in% c("public", "advanced", "development")) {
        issues[[length(issues) + 1L]] <- rrp_issue(
          "operation_registry", "invalid_operation_classification",
          "Operation classification must be public, advanced, or development.", location
        )
      }
      script <- if (is.null(operation$command)) NULL else {
        rrp_operation_command_script(operation$command)
      }
      if (is.null(script) || !file.exists(file.path(repository_root, script))) {
        issues[[length(issues) + 1L]] <- rrp_issue(
          "operation_registry", "missing_operation_script",
          "Registered human command does not name an existing Rscript entry point.", location
        )
      }
      document <- if (is.null(operation$documentation)) "" else operation$documentation
      document_path <- file.path(repository_root, document)
      document_text <- if (file.exists(document_path)) {
        paste(rrp_read_text(document_path), collapse = " ")
      } else ""
      normalized_document <- gsub("[[:space:]]+", " ", document_text)
      normalized_command <- if (is.null(operation$command)) "" else {
        gsub("[[:space:]]+", " ", operation$command)
      }
      command_documented <- nzchar(normalized_command) && grepl(
        normalized_command, normalized_document, fixed = TRUE
      )
      if (!command_documented) issues[[length(issues) + 1L]] <- rrp_issue(
        "operation_documentation", "undocumented_operation_command",
        "Registered exact command is absent from its human documentation.", document
      )
    }
    duplicate_ids <- unique(ids[duplicated(ids)])
    for (id in duplicate_ids) issues[[length(issues) + 1L]] <- rrp_issue(
      "operation_registry", "duplicate_operation_id",
      paste("Operation ID is duplicated:", id), "operations/operations.yml"
    )
    public_ids <- ids[vapply(registry$operations, function(operation) {
      identical(operation$classification, "public")
    }, logical(1))]
    expected_public <- c(
      "platform.initialize-local", "platform.doctor",
      "platform.validate-development", "platform.validate-checkpoint",
      "reference.run-platform", "reference.inspect-history",
      "reference.materialize-products", "reference.validate-app",
      "reference.launch-app"
    )
    missing_public <- setdiff(expected_public, public_ids)
    for (id in missing_public) issues[[length(issues) + 1L]] <- rrp_issue(
      "public_operation_surface", "missing_public_operation",
      paste("Public operation is not registered:", id), "operations/operations.yml"
    )
    checks[[length(checks) + 1L]] <- rrp_check(
      "public_operation_surface", length(missing_public) == 0L,
      paste(length(expected_public), "stable public operation IDs")
    )
  }

  agent_text <- paste(rrp_read_text(file.path(repository_root, "AGENTS.md")), collapse = "\n")
  agent_commands <- c(
    "Rscript operations/doctor.R",
    "Rscript operations/run-platform.R --profile reference --scale test",
    "Rscript operations/build-reference-products.R --scale test --materialize",
    "Rscript operations/launch-reference-app.R --validate-only"
  )
  agent_aligned <- all(vapply(agent_commands, grepl, logical(1), x = agent_text, fixed = TRUE))
  if (!agent_aligned) issues[[length(issues) + 1L]] <- rrp_issue(
    "agent_human_alignment", "missing_agent_operation_mapping",
    "Agent guidance must name the exact stable human operations.", "AGENTS.md"
  )
  checks[[length(checks) + 1L]] <- rrp_check(
    "agent_human_alignment", agent_aligned,
    "agent shorthand maps to documented human commands"
  )

  prohibited <- c("deploy", "observability", "scheduler", "scheduling")
  implemented <- prohibited[dir.exists(file.path(repository_root, prohibited))]
  for (path in implemented) issues[[length(issues) + 1L]] <- rrp_issue(
    "phase7_scope", "premature_later_phase_directory",
    "Deployment, scheduling, or observability implementation is outside Phase 7.", path
  )
  checks[[length(checks) + 1L]] <- rrp_check(
    "phase7_scope", length(implemented) == 0L,
    "no deployment, scheduler, or observability implementation"
  )

  record_text <- paste(rrp_read_text(file.path(
    repository_root, "docs", "architecture", "platform-implementation-record.md"
  )), collapse = "\n")
  recorded <- grepl(
    "### Iteration 7.1 — Human initialization, doctor, workflow, and adoption guidance",
    record_text, fixed = TRUE
  )
  if (!recorded) issues[[length(issues) + 1L]] <- rrp_issue(
    "phase7_implementation_record", "missing_iteration_7_1_record",
    "Implementation record must contain the Iteration 7.1 entry.",
    "docs/architecture/platform-implementation-record.md"
  )
  checks[[length(checks) + 1L]] <- rrp_check(
    "phase7_implementation_record", recorded,
    "Iteration 7.1 implementation evidence is recorded"
  )

  rrp_validation_result(
    "Stable human operation validation",
    rrp_bind_rows(checks, rrp_empty_checks),
    rrp_bind_rows(issues, rrp_empty_issues)
  )
}

rrp_validate_phase7_checkpoint <- function(repository_root) {
  result <- rrp_validate_operator_repository(repository_root)
  fresh_root <- tempfile("rrp-phase7-checkpoint-")
  dir.create(fresh_root)
  on.exit(unlink(fresh_root, recursive = TRUE, force = TRUE), add = TRUE)
  doctor <- tryCatch(
    rrp_doctor(
      repository_root,
      file.path(fresh_root, "history.duckdb"),
      file.path(fresh_root, "products")
    ),
    error = function(condition) condition
  )
  doctor_ready <- !inherits(doctor, "condition") &&
    identical(doctor$overall_status, "ready_with_warnings") &&
    identical(doctor$lifecycle$operational_history, "absent") &&
    identical(doctor$lifecycle$current_product_bundle, "absent") &&
    identical(doctor$lifecycle$app, "blocked_expected")
  doctor_check <- rrp_check(
    "phase7_fresh_doctor", doctor_ready,
    "fresh environment is ready with expected absent-state warnings"
  )
  doctor_issues <- if (doctor_ready) rrp_empty_issues() else rrp_issue(
    "phase7_fresh_doctor", "fresh_doctor_failed",
    if (inherits(doctor, "condition")) conditionMessage(doctor) else {
      "Doctor did not report the expected healthy fresh-install lifecycle."
    },
    "operations/doctor.R"
  )
  structure(
    list(
      scope = "Completed Phase 7 human operations and adoption checkpoint",
      checks = rbind(result$checks, doctor_check),
      issues = rbind(result$issues, doctor_issues),
      passed = result$passed && doctor_ready
    ),
    class = "rrp_validation_result"
  )
}
