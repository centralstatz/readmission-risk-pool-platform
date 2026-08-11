# Repository validation for the completed Phase 4 runtime/provider boundary.

rrp_runtime_contract_identity <- function(document) {
  list(
    specification_kind = document$specification_kind,
    specification_id = document$specification_id,
    specification_version = document$specification_version
  )
}

rrp_validate_runtime_repository <- function(repository_root) {
  repository_root <- normalizePath(repository_root, mustWork = TRUE)
  checks <- list()
  issues <- list()
  contracts <- tryCatch(
    rrp_read_runtime_contracts(repository_root),
    error = function(condition) condition
  )
  if (inherits(contracts, "condition")) {
    checks[[1L]] <- rrp_check("runtime_contracts", FALSE, "runtime contracts could not be read")
    issues[[1L]] <- rrp_issue(
      "runtime_contracts", "runtime_contract_read_failed",
      conditionMessage(contracts), "contracts/runtime"
    )
    return(rrp_validation_result(
      "Runtime specification and package validation",
      rrp_bind_rows(checks, rrp_empty_checks),
      rrp_bind_rows(issues, rrp_empty_issues)
    ))
  }
  for (name in names(contracts)) {
    path <- rrp_runtime_contract_paths(repository_root)[[name]]
    relative <- rrp_repository_relative_path(repository_root, path)
    envelope <- rrp_validate_specification_envelope(contracts[[name]], relative)
    checks[[length(checks) + 1L]] <- rrp_check(
      paste0("runtime_specification:", name),
      rrp_conforms(envelope),
      paste0(
        contracts[[name]]$specification_id, "@",
        contracts[[name]]$specification_version
      )
    )
    for (index in seq_len(nrow(envelope$issues))) {
      issue <- envelope$issues[index, ]
      issues[[length(issues) + 1L]] <- rrp_issue(
        paste0("runtime_specification:", name), issue$issue_code,
        issue$message, relative
      )
    }
  }

  provider_contracts <- tryCatch(
    rrp_read_provider_contracts(repository_root),
    error = function(condition) condition
  )
  reference_provider <- tryCatch(
    rrp_read_reference_provider_specification(repository_root),
    error = function(condition) condition
  )
  provider_documents_ok <- !inherits(provider_contracts, "condition") &&
    !inherits(reference_provider, "condition")
  checks[[length(checks) + 1L]] <- rrp_check(
    "provider_contract_documents", provider_documents_ok,
    if (provider_documents_ok) {
      "four provider contracts and one reference provider declaration loaded"
    } else "provider contract documents could not be read"
  )
  if (!provider_documents_ok) {
    conditions <- Filter(function(value) inherits(value, "condition"), list(
      provider_contracts, reference_provider
    ))
    issues[[length(issues) + 1L]] <- rrp_issue(
      "provider_contract_documents", "provider_contract_read_failed",
      paste(vapply(conditions, conditionMessage, character(1)), collapse = " "),
      "contracts/runtime"
    )
  } else {
    documents <- c(provider_contracts, list(reference_provider = reference_provider))
    paths <- c(
      rrp_provider_contract_paths(repository_root),
      reference_provider = file.path(
        repository_root, "contracts", "runtime", "providers",
        "transparent-reference-provider.yml"
      )
    )
    for (name in names(documents)) {
      relative <- rrp_repository_relative_path(repository_root, paths[[name]])
      envelope <- rrp_validate_specification_envelope(documents[[name]], relative)
      checks[[length(checks) + 1L]] <- rrp_check(
        paste0("provider_specification:", name),
        rrp_conforms(envelope),
        paste0(
          documents[[name]]$specification_id, "@",
          documents[[name]]$specification_version
        )
      )
      for (index in seq_len(nrow(envelope$issues))) {
        issue <- envelope$issues[index, ]
        issues[[length(issues) + 1L]] <- rrp_issue(
          paste0("provider_specification:", name), issue$issue_code,
          issue$message, relative
        )
      }
    }
  }

  installed <- tryCatch(
    rrp_install_runtime_package(repository_root),
    error = function(condition) condition
  )
  installed_ok <- !inherits(installed, "condition")
  checks[[length(checks) + 1L]] <- rrp_check(
    "runtime_package_install", installed_ok,
    if (installed_ok) "rrpruntime@0.2.0 installed and loaded in a temporary library" else {
      "rrpruntime installation failed"
    }
  )
  if (!installed_ok) {
    issues[[length(issues) + 1L]] <- rrp_issue(
      "runtime_package_install", "runtime_package_install_failed",
      conditionMessage(installed), "runtime/DESCRIPTION"
    )
  } else {
    on.exit(rrp_unload_runtime_package(installed), add = TRUE)
    contract_result <- rrpruntime::validate_runtime_contracts(contracts)
    checks[[length(checks) + 1L]] <- rrp_check(
      "runtime_contract_support",
      rrpruntime::runtime_conforms(contract_result),
      "all four runtime contract identities and semantics are supported"
    )
    for (index in seq_len(nrow(contract_result$issues))) {
      issue <- contract_result$issues[index, ]
      issues[[length(issues) + 1L]] <- rrp_issue(
        "runtime_contract_support", issue$issue_code,
        paste0("[", issue$rule_id, "] ", issue$message),
        "contracts/runtime"
      )
    }
    if (provider_documents_ok) {
      provider_contract_result <- rrpruntime::validate_provider_contracts(
        provider_contracts
      )
      provider_specification_result <- rrpruntime::validate_provider_specification(
        reference_provider, provider_contracts$provider_specification
      )
      provider_ok <- rrpruntime::runtime_conforms(provider_contract_result) &&
        rrpruntime::runtime_conforms(provider_specification_result)
      checks[[length(checks) + 1L]] <- rrp_check(
        "provider_contract_support", provider_ok,
        "provider declarations, adapter semantics, results, and estimates are supported"
      )
      for (result in list(provider_contract_result, provider_specification_result)) {
        for (index in seq_len(nrow(result$issues))) {
          issue <- result$issues[index, ]
          issues[[length(issues) + 1L]] <- rrp_issue(
            "provider_contract_support", issue$issue_code,
            paste0("[", issue$rule_id, "] ", issue$message),
            "contracts/runtime"
          )
        }
      }
    }

    independent_document <- yaml::read_yaml(file.path(
      repository_root, "contracts", "canonical", "examples",
      "readmission-initial-profile-valid.yml"
    ))
    independent <- tryCatch(
      rrp_run_runtime_from_bundle(
        independent_document$bundle_instance,
        repository_root,
        "runtime_validation_independent"
      ),
      error = function(condition) condition
    )
    synthetic <- tryCatch({
      produced <- rrp_run_synthetic_reference(repository_root, "test")
      if (!identical(produced$overall_status, "succeeded")) {
        stop("Synthetic producer failed.", call. = FALSE)
      }
      rrp_run_runtime_from_bundle(
        produced$candidate_bundle,
        repository_root,
        "runtime_validation_synthetic"
      )
    }, error = function(condition) condition)
    flow_results <- list(independent = independent, synthetic = synthetic)
    for (name in names(flow_results)) {
      result <- flow_results[[name]]
      ok <- inherits(result, "rrp_runtime_operation_result") &&
        length(result$states$records) == length(result$estimand_requests$records)
      checks[[length(checks) + 1L]] <- rrp_check(
        paste0("runtime_flow:", name), ok,
        if (ok) {
          paste0(
            length(result$eligibility$records), " episodes; ",
            length(result$states$records), " states/requests"
          )
        } else {
          "runtime reference flow failed"
        }
      )
      if (!ok) {
        issues[[length(issues) + 1L]] <- rrp_issue(
          paste0("runtime_flow:", name), "runtime_reference_flow_failed",
          if (inherits(result, "condition")) conditionMessage(result) else {
            "Runtime result had inconsistent state/request cardinality."
          },
          "operations/run-reference-runtime.R"
        )
      }
    }
    if (provider_documents_ok) {
      for (name in names(flow_results)) {
        runtime_result <- flow_results[[name]]
        estimation <- if (inherits(runtime_result, "rrp_runtime_operation_result")) {
          tryCatch(
            rrp_execute_reference_estimation(
              runtime_result,
              repository_root,
              paste0("provider_validation_", name)
            ),
            error = function(condition) condition
          )
        } else runtime_result
        ok <- inherits(estimation, "rrp_estimation_operation_result") &&
          length(estimation$estimates) ==
            length(runtime_result$estimand_requests$records) &&
          all(vapply(estimation$execution_results, function(result) {
            identical(result$execution_status, "successful_estimate")
          }, logical(1)))
        checks[[length(checks) + 1L]] <- rrp_check(
          paste0("provider_flow:", name), ok,
          if (ok) {
            paste(length(estimation$estimates), "conforming estimates")
          } else "reference provider flow failed"
        )
        if (!ok) {
          issues[[length(issues) + 1L]] <- rrp_issue(
            paste0("provider_flow:", name), "provider_reference_flow_failed",
            if (inherits(estimation, "condition")) conditionMessage(estimation) else {
              "Provider result had failures or inconsistent estimate cardinality."
            },
            "operations/run-reference-estimation.R"
          )
        }
      }
    }
  }
  rrp_validation_result(
    "Runtime, provider, and estimate validation",
    rrp_bind_rows(checks, rrp_empty_checks),
    rrp_bind_rows(issues, rrp_empty_issues)
  )
}

rrp_validate_phase4_checkpoint <- function(repository_root) {
  repository_root <- normalizePath(repository_root, mustWork = TRUE)
  checks <- list()
  issues <- list()
  required_files <- c(
    "contracts/runtime/eligibility-result.yml",
    "contracts/runtime/episode-state.yml",
    "contracts/runtime/estimands/readmission-next-day-conditional-hazard.yml",
    "contracts/runtime/estimand-request.yml",
    "contracts/runtime/provider-specification.yml",
    "contracts/runtime/provider-execution-adapter.yml",
    "contracts/runtime/provider-execution-result.yml",
    "contracts/runtime/readmission-risk-estimate.yml",
    "contracts/runtime/providers/transparent-reference-provider.yml",
    "runtime/DESCRIPTION", "runtime/LICENSE", "runtime/NAMESPACE",
    "runtime/README.md", "runtime/R/utils.R", "runtime/R/conformance.R",
    "runtime/R/specifications.R", "runtime/R/input.R",
    "runtime/R/eligibility.R", "runtime/R/state.R",
    "runtime/R/estimand-request.R", "runtime/tests/runtime-unit.R",
    "runtime/R/provider-specification.R", "runtime/R/provider-registry.R",
    "runtime/R/provider-compatibility.R", "runtime/R/reference-provider.R",
    "runtime/R/estimate.R", "runtime/R/provider-execution.R",
    "runtime/man/runtime-api.Rd",
    "runtime/man/provider-api.Rd",
    "operations/lib/runtime-operation.R", "operations/lib/runtime-validation.R",
    "operations/lib/provider-operation.R",
    "operations/run-reference-runtime.R",
    "operations/run-reference-estimation.R",
    "tests/phase4/test-runtime-foundation.R", "tests/run-phase4-tests.R",
    "tests/phase4/test-provider-foundation.R",
    "docs/architecture/runtime-foundation.md",
    "docs/architecture/provider-foundation.md",
    "docs/operations/run-reference-runtime.md",
    "docs/operations/run-reference-estimation.md"
  )
  missing <- required_files[!file.exists(file.path(repository_root, required_files))]
  for (path in missing) {
    issues[[length(issues) + 1L]] <- rrp_issue(
      "phase4_required_files", "missing_phase4_file",
      "Required completed Phase 4 file is missing.", path
    )
  }
  checks[[length(checks) + 1L]] <- rrp_check(
    "phase4_required_files", length(missing) == 0L,
    paste(length(required_files), "required completed Phase 4 files")
  )

  expected_runtime <- sub("^runtime/", "", required_files[
    startsWith(required_files, "runtime/")
  ])
  actual_runtime <- if (dir.exists(file.path(repository_root, "runtime"))) {
    sort(list.files(
      file.path(repository_root, "runtime"), recursive = TRUE,
      all.files = TRUE, no.. = TRUE, include.dirs = FALSE
    ))
  } else character()
  unexpected_runtime <- setdiff(actual_runtime, expected_runtime)
  for (path in unexpected_runtime) {
    issues[[length(issues) + 1L]] <- rrp_issue(
      "phase4_runtime_scope", "unexpected_runtime_file",
      "Completed Phase 4 runtime package contains an unapproved file.",
      file.path("runtime", path)
    )
  }
  checks[[length(checks) + 1L]] <- rrp_check(
    "phase4_runtime_scope", length(unexpected_runtime) == 0L,
    "focused package contains runtime/provider/estimate code only"
  )

  prohibited_directories <- c(
    "persistence", "products", "app", "deploy", "config", "observability"
  )
  premature <- prohibited_directories[dir.exists(file.path(
    repository_root, prohibited_directories
  ))]
  runtime_r <- list.files(
    file.path(repository_root, "runtime", "R"), pattern = "[.]R$",
    full.names = TRUE
  )
  runtime_text <- if (length(runtime_r) > 0L) {
    unlist(lapply(runtime_r, readLines, warn = FALSE))
  } else character()
  prohibited_runtime <- c(
    "reference.synthetic", "activity_events", "source-schema",
    "priority_rank", "recommended_action", "storage_backend"
  )
  leaked <- prohibited_runtime[vapply(prohibited_runtime, function(value) {
    any(grepl(value, runtime_text, fixed = TRUE))
  }, logical(1))]
  for (path in premature) {
    issues[[length(issues) + 1L]] <- rrp_issue(
      "phase4_later_scope", "premature_phase4_directory",
      "Persistence or later-phase implementation content is premature.", path
    )
  }
  for (value in leaked) {
    issues[[length(issues) + 1L]] <- rrp_issue(
      "phase4_later_scope", "prohibited_runtime_implementation",
      paste0("Runtime code contains prohibited completed-Phase-4 concept: ", value, "."),
      "runtime/R"
    )
  }
  checks[[length(checks) + 1L]] <- rrp_check(
    "phase4_later_scope", length(premature) + length(leaked) == 0L,
    "no persistence/product/app/deployment/decision-policy/observability implementation"
  )

  record_path <- file.path(
    repository_root, "docs", "architecture", "platform-implementation-record.md"
  )
  record_text <- if (file.exists(record_path)) {
    paste(rrp_read_text(record_path), collapse = "\n")
  } else ""
  heading <- paste(
    "### Iteration 4.2 — Provider contract, registry, reference provider,",
    "and estimate records"
  )
  recorded <- grepl(heading, record_text, fixed = TRUE)
  if (!recorded) {
    issues[[length(issues) + 1L]] <- rrp_issue(
      "phase4_implementation_record", "missing_phase4_implementation_record",
      "Implementation record must contain the Iteration 4.2 entry.",
      "docs/architecture/platform-implementation-record.md"
    )
  }
  checks[[length(checks) + 1L]] <- rrp_check(
    "phase4_implementation_record", recorded,
    "Iteration 4.2 implementation evidence is recorded"
  )
  rrp_validation_result(
    "Completed Phase 4 checkpoint validation",
    rrp_bind_rows(checks, rrp_empty_checks),
    rrp_bind_rows(issues, rrp_empty_issues)
  )
}
