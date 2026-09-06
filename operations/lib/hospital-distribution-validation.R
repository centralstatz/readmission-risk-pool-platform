# Repository and checkpoint evidence for the generated Hospital Implementation.

rrp_validate_hospital_distribution_repository <- function(repository_root) {
  required <- c(
    ".renvignore",
    "contracts/distribution/hospital-implementation-distribution.yml",
    "contracts/distribution/hospital-implementation-git-realization.yml",
    "distribution/hospital/README.md",
    "distribution/hospital/R/distribution-runtime.R",
    "distribution/hospital/R/git-realization-runtime.R",
    "distribution/hospital/validate-distribution.R",
    "distribution/hospital/validate-git-realization.R",
    "distribution/hospital/implementation/producer.yml",
    "distribution/hospital/implementation/platform-instance.yml",
    "distribution/hospital/implementation/producer-configuration.yml",
    "distribution/hospital/implementation/R/producer.R",
    "distribution/hospital/implementation/R/composition.R",
    "distribution/hospital/examples/fictional-adopter/README.md",
    "distribution/hospital/examples/fictional-adopter/R/composition.R",
    "operations/lib/platform-cycle-operation.R",
    "operations/lib/hospital-distribution-operation.R",
    "operations/lib/hospital-distribution-validation.R",
    "operations/lib/hospital-git-realization-operation.R",
    "operations/lib/release-preparation-operation.R",
    "operations/build-hospital-distribution.R",
    "operations/validate-hospital-distribution.R",
    "operations/build-hospital-git-realization.R",
    "operations/validate-hospital-git-realization.R",
    "operations/prepare-release.R",
    "tests/run-phase11-tests.R",
    "tests/phase11/test-hospital-distribution.R",
    "docs/operations/hospital-implementation-distribution.md",
    "docs/operations/hospital-git-realization.md",
    "docs/operations/release-preparation.md",
    "docs/architecture/release-license-review.md",
    "LICENSE", "NOTICE", "CONTRIBUTING.md", "SECURITY.md", "SUPPORT.md",
    "CHANGELOG.md", "RELEASE.yml"
  )
  present <- file.exists(file.path(repository_root, required))
  checks <- lapply(seq_along(required), function(index) rrp_check(
    paste0("hospital_distribution_required_", index), present[[index]],
    paste0("Required Hospital distribution source exists: ", required[[index]])
  ))
  issues <- lapply(required[!present], function(path) rrp_issue(
    "hospital_distribution_repository", "missing_hospital_distribution_file",
    "Required Hospital distribution source is missing.", path
  ))

  contract_ok <- FALSE
  contract_path <- "contracts/distribution/hospital-implementation-distribution.yml"
  if (file.exists(file.path(repository_root, contract_path))) {
    parsed <- rrp_parse_yaml_specification(file.path(repository_root, contract_path))
    envelope <- if (is.null(parsed$parse_error)) {
      rrp_validate_specification_envelope(parsed$document, contract_path)
    } else NULL
    contract_ok <- !is.null(envelope) && rrp_conforms(envelope) && identical(
      parsed$document[c("specification_kind", "specification_id", "specification_version")],
      rrp_hospital_distribution_specification()
    )
  }
  checks[[length(checks) + 1L]] <- rrp_check(
    "hospital_distribution_contract", contract_ok,
    "Hospital distribution contract has the supported exact envelope"
  )
  if (!contract_ok) issues[[length(issues) + 1L]] <- rrp_issue(
    "hospital_distribution_repository", "invalid_hospital_distribution_contract",
    "Hospital distribution contract must conform with its exact supported identity.",
    contract_path
  )

  git_contract_ok <- FALSE
  git_contract_path <- "contracts/distribution/hospital-implementation-git-realization.yml"
  if (file.exists(file.path(repository_root, git_contract_path))) {
    parsed <- rrp_parse_yaml_specification(file.path(repository_root, git_contract_path))
    envelope <- if (is.null(parsed$parse_error)) {
      rrp_validate_specification_envelope(parsed$document, git_contract_path)
    } else NULL
    git_contract_ok <- !is.null(envelope) && rrp_conforms(envelope) && identical(
      parsed$document[c(
        "specification_kind", "specification_id", "specification_version"
      )], rrp_hospital_git_specification()
    )
  }
  checks[[length(checks) + 1L]] <- rrp_check(
    "hospital_git_realization_contract", git_contract_ok,
    "Hospital Git realization contract has the supported exact envelope"
  )
  if (!git_contract_ok) issues[[length(issues) + 1L]] <- rrp_issue(
    "hospital_distribution_repository", "invalid_hospital_git_realization_contract",
    "Hospital Git realization contract must conform with its exact identity.",
    git_contract_path
  )

  source_map <- tryCatch(
    rrp_hospital_distribution_source_map(repository_root),
    error = function(condition) condition
  )
  source_ok <- !inherits(source_map, "condition") && !anyDuplicated(names(source_map)) &&
    all(vapply(names(source_map), rrp_hospital_safe_relative_path, logical(1))) &&
    all(file.exists(source_map)) && !any(vapply(source_map, function(path) {
      dir.exists(path) || nzchar(Sys.readlink(path))
    }, logical(1)))
  checks[[length(checks) + 1L]] <- rrp_check(
    "hospital_distribution_source_allowlist", source_ok,
    "Maintained generated inputs form one closed regular-file allowlist"
  )
  if (!source_ok) issues[[length(issues) + 1L]] <- rrp_issue(
    "hospital_distribution_repository", "invalid_hospital_distribution_source_map",
    "Maintained Hospital distribution inputs must be exact safe regular files.",
    "distribution/hospital"
  )

  ignore <- readLines(file.path(repository_root, ".gitignore"), warn = FALSE)
  build_ignored <- any(trimws(ignore) == "build/")
  checks[[length(checks) + 1L]] <- rrp_check(
    "hospital_distribution_build_ignored", build_ignored,
    "Generated Hospital distributions remain under ignored build state"
  )
  if (!build_ignored) issues[[length(issues) + 1L]] <- rrp_issue(
    "hospital_distribution_repository", "hospital_build_not_ignored",
    "The generated build root must remain ignored.", ".gitignore"
  )

  maintained_r <- list.files(
    file.path(repository_root, "distribution", "hospital"),
    pattern = "[.]R$", recursive = TRUE, full.names = TRUE
  )
  maintained_text <- paste(unlist(lapply(maintained_r, readLines, warn = FALSE)),
                           collapse = "\n")
  forbidden_logic <- c(
    "new_episode_state <- function", "rrp_build_reference_products <- function",
    "rrp_execute_reference_provider <- function", "rrp_open_duckdb_persistence <- function"
  )
  thin <- !any(vapply(forbidden_logic, grepl, logical(1), x = maintained_text,
                      fixed = TRUE))
  checks[[length(checks) + 1L]] <- rrp_check(
    "hospital_distribution_thin_source", thin,
    "Hospital maintained source does not copy Platform domain or adapter logic"
  )
  if (!thin) issues[[length(issues) + 1L]] <- rrp_issue(
    "hospital_distribution_repository", "copied_platform_logic",
    "Hospital distribution source must delegate to the embedded Platform.",
    "distribution/hospital"
  )

  realization_operation <- paste(readLines(file.path(
    repository_root, "operations", "lib", "hospital-git-realization-operation.R"
  ), warn = FALSE), collapse = "\n")
  artifact_only <- !any(vapply(c(
    "rrp_build_hospital_distribution(",
    "rrp_build_platform_release_candidate(",
    "distribution/hospital/"
  ), grepl, logical(1), x = realization_operation, fixed = TRUE))
  no_publication <- !any(vapply(c(
    "git push", "git commit", "git remote add", "gh repo create",
    "gh release create"
  ), grepl, logical(1), x = realization_operation, fixed = TRUE))
  checks[[length(checks) + 1L]] <- rrp_check(
    "hospital_git_artifact_only_boundary", artifact_only && no_publication,
    "Hospital Git realization consumes only the artifact and stops before publication"
  )
  if (!artifact_only || !no_publication) issues[[length(issues) + 1L]] <- rrp_issue(
    "hospital_distribution_repository", "hospital_git_boundary_leak",
    "Hospital Git realization must not rebuild maintained inputs or publish.",
    "operations/lib/hospital-git-realization-operation.R"
  )

  operation_text <- paste(readLines(file.path(
    repository_root, "operations", "operations.yml"
  ), warn = FALSE), collapse = "\n")
  operations_registered <- all(vapply(c(
    "platform.build-hospital-distribution",
    "platform.validate-hospital-distribution",
    "platform.build-hospital-git-realization",
    "platform.validate-hospital-git-realization", "platform.prepare-release"
  ), grepl, logical(1), x = operation_text, fixed = TRUE))
  checks[[length(checks) + 1L]] <- rrp_check(
    "hospital_distribution_operations_registered", operations_registered,
    "Hospital artifact and Git-realization operations are registered maintainer operations"
  )
  if (!operations_registered) issues[[length(issues) + 1L]] <- rrp_issue(
    "hospital_distribution_repository", "unregistered_hospital_operation",
    "Register all Hospital distribution and realization operations.",
    "operations/operations.yml"
  )

  rrp_validation_result(
    "Hospital distribution repository",
    rrp_bind_rows(checks, rrp_empty_checks),
    rrp_bind_rows(issues, rrp_empty_issues)
  )
}

rrp_validate_phase11_checkpoint <- function(repository_root) {
  record <- paste(readLines(file.path(
    repository_root, "docs", "architecture", "platform-implementation-record.md"
  ), warn = FALSE), collapse = "\n")
  evidence <- grepl(
    "Iteration 11.6 — v0.1.0 release-candidate and governance hardening",
    record, fixed = TRUE
  ) && grepl("Phase 11 status", record, fixed = TRUE)
  checks <- rrp_check(
    "phase11_iteration_checkpoint", evidence,
    "Iteration 11.6 implementation and Phase 11 status are recorded"
  )
  issues <- if (evidence) rrp_empty_issues() else rrp_issue(
    "phase11_checkpoint", "missing_phase11_iteration_record",
    "Implementation record must record Iteration 11.6 and Phase 11 status.",
    "docs/architecture/platform-implementation-record.md"
  )
  rrp_validation_result("Phase 11 checkpoint", checks, issues)
}
