# Repository validation for the Connect Cloud Git realization.

rrp_validate_connect_cloud_repository <- function(repository_root) {
  repository_root <- normalizePath(repository_root, mustWork = TRUE)
  checks <- list()
  issues <- list()
  required_files <- c(
    "contracts/deployment/connect-cloud-realization.yml",
    "deploy/connect-cloud/app.R",
    "deploy/connect-cloud/validate-connect-cloud.R",
    "deploy/connect-cloud/R/realization-runtime.R",
    "deploy/connect-cloud/README.md",
    "operations/lib/connect-cloud-operation.R",
    "operations/lib/connect-cloud-validation.R",
    "operations/build-connect-cloud-deployment.R",
    "operations/validate-connect-cloud-deployment.R",
    "tests/phase8/test-connect-cloud-realization.R",
    "docs/architecture/connect-cloud-realization.md",
    "docs/operations/connect-cloud-deployment.md"
  )
  missing <- required_files[!file.exists(file.path(repository_root, required_files))]
  for (path in missing) issues[[length(issues) + 1L]] <- rrp_issue(
    "connect_required_files", "missing_connect_realization_file",
    "Required Iteration 8.2 Connect realization file is missing.", path
  )
  checks[[length(checks) + 1L]] <- rrp_check(
    "connect_required_files", length(missing) == 0L,
    paste(length(required_files), "required Iteration 8.2 files")
  )

  contract_path <- file.path(
    repository_root, "contracts", "deployment", "connect-cloud-realization.yml"
  )
  contract <- tryCatch(yaml::read_yaml(contract_path), error = function(value) value)
  contract_ok <- !inherits(contract, "condition") && identical(
    contract[c("specification_kind", "specification_id", "specification_version")],
    rrp_connect_specification()
  ) && identical(contract$target$primary_file, "app.R") &&
    identical(contract$target$dependency_file, "manifest.json") &&
    identical(contract$repository_semantics$generated_commit, FALSE) &&
    identical(contract$repository_semantics$configured_remote, FALSE)
  if (!contract_ok) issues[[length(issues) + 1L]] <- rrp_issue(
    "connect_contract", "invalid_connect_realization_contract",
    "Connect realization contract identity or repository boundary is invalid.",
    "contracts/deployment/connect-cloud-realization.yml"
  )
  checks[[length(checks) + 1L]] <- rrp_check(
    "connect_contract", contract_ok,
    "Connect target, artifact compatibility, manifest, and Git boundary declared"
  )

  source_map <- rrp_connect_cloud_source_map(repository_root)
  allowlist_ok <- identical(names(source_map), rrp_connect_target_payload_files()) &&
    !anyDuplicated(names(source_map)) && all(file.exists(unname(source_map)))
  if (!allowlist_ok) issues[[length(issues) + 1L]] <- rrp_issue(
    "connect_allowlist", "invalid_connect_target_allowlist",
    "Connect target source map must exactly match standalone target payload files.",
    "operations/lib/connect-cloud-operation.R"
  )
  checks[[length(checks) + 1L]] <- rrp_check(
    "connect_allowlist", allowlist_ok,
    paste(length(rrp_connect_target_payload_files()), "allowlisted target files")
  )

  lock <- tryCatch(jsonlite::read_json(
    file.path(repository_root, "renv.lock"), simplifyVector = FALSE
  ), error = function(value) value)
  rsconnect_locked <- !inherits(lock, "condition") &&
    "rsconnect" %in% names(lock$Packages) &&
    identical(lock$Packages$rsconnect$Version, "1.3.1")
  if (!rsconnect_locked) issues[[length(issues) + 1L]] <- rrp_issue(
    "connect_builder_dependency", "rsconnect_not_locked",
    "Connect manifest generation requires repository-owned rsconnect@1.3.1.",
    "renv.lock"
  )
  checks[[length(checks) + 1L]] <- rrp_check(
    "connect_builder_dependency", rsconnect_locked,
    "rsconnect@1.3.1 is a build-only locked dependency"
  )

  core_directories <- c("app", "products", "runtime", "implementations/synthetic-reference")
  core_files <- unlist(lapply(core_directories, function(directory) list.files(
    file.path(repository_root, directory), recursive = TRUE, full.names = TRUE,
    pattern = "[.](R|yml)$"
  )), use.names = FALSE)
  core_text <- paste(unlist(lapply(core_files, readLines, warn = FALSE)), collapse = "\n")
  no_leak <- !grepl("Connect Cloud", core_text, fixed = TRUE) &&
    !grepl("posit.connect-cloud", core_text, fixed = TRUE)
  operation_text <- paste(rrp_read_text(file.path(
    repository_root, "operations", "lib", "connect-cloud-operation.R"
  )), collapse = "\n")
  no_publication <- !any(vapply(c(
    "git push", "git remote add", "gh repo create", "connect.posit.cloud",
    "rsconnect::deploy"
  ), grepl, logical(1), x = operation_text, fixed = TRUE))
  if (!no_leak || !no_publication) issues[[length(issues) + 1L]] <- rrp_issue(
    "connect_boundary", "connect_target_boundary_leak",
    "Connect logic must remain target-owned and stop before remote publication.",
    "deploy/connect-cloud"
  )
  checks[[length(checks) + 1L]] <- rrp_check(
    "connect_boundary", no_leak && no_publication,
    "target-only local generation with no publication or core leakage"
  )

  record <- paste(rrp_read_text(file.path(
    repository_root, "docs", "architecture", "platform-implementation-record.md"
  )), collapse = "\n")
  recorded <- grepl(
    "### Iteration 8.2 — Connect Cloud realization from the validated artifact",
    record, fixed = TRUE
  )
  if (!recorded) issues[[length(issues) + 1L]] <- rrp_issue(
    "phase8_implementation_record", "missing_iteration_8_2_record",
    "Implementation record must contain the Iteration 8.2 entry.",
    "docs/architecture/platform-implementation-record.md"
  )
  checks[[length(checks) + 1L]] <- rrp_check(
    "phase8_implementation_record", recorded,
    "Iteration 8.2 implementation evidence is recorded"
  )

  rrp_validation_result(
    "Connect Cloud realization validation",
    rrp_bind_rows(checks, rrp_empty_checks),
    rrp_bind_rows(issues, rrp_empty_issues)
  )
}

rrp_validate_phase8_checkpoint <- function(repository_root) {
  rrp_combine_validation_results(
    "Completed Phase 8 deployment-build checkpoint",
    list(
      rrp_validate_application_artifact_repository(repository_root),
      rrp_validate_connect_cloud_repository(repository_root)
    )
  )
}
