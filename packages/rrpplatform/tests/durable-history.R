library(rrpplatform)

durable_write_project <- function(root, project_id, mode = "multiple") {
  dir.create(file.path(root, "R"), recursive = TRUE)
  manifest <- c(
    "Record-Type: rrp-project",
    "Project-Contract-ID: rrp.project",
    "Project-Contract-Version: 0.3.0",
    paste0("Project-ID: ", project_id),
    "Project-Version: 1.0.0",
    "Project-Scope: one_health_system",
    "Supported-RRP-API-Version: 0.3.0",
    "Canonical-Profile-ID: rrp.canonical-profile.readmission",
    "Canonical-Profile-Version: 0.1.0",
    paste0("Producer-ID: ", project_id, ".producer"),
    "Producer-Version: 1.0.0",
    paste0("Provider-ID: ", project_id, ".provider"),
    "Provider-Version: 1.0.0",
    "Extension-Library-Path: extensions/library",
    "State-Path: state"
  )
  writeLines(manifest, file.path(root, "rrp-project.dcf"), useBytes = TRUE)
  registration <- c(
    "rrp_register_project <- function(project_root) {",
    paste0("  project_id <- '", project_id, "'"),
    paste0("  mode <- '", mode, "'"),
    "  capabilities <- list(list(capability_id = 'rrp.capability.discharge-episode', status = 'available'), list(capability_id = 'rrp.capability.terminal-event', status = 'available'))",
    "  producer_calls <- 0L",
    "  provider_calls <- new.env(parent = emptyenv())",
    "  producer <- function(request) {",
    "    producer_calls <<- producer_calls + 1L",
    "    if (producer_calls != 1L) stop('producer recalled')",
    "    if (identical(mode, 'producer-failure')) return(list(producer_contract_id = 'rrp.canonical-producer', producer_contract_version = '0.1.0', status = 'failed', producer_id = paste0(project_id, '.producer'), producer_version = '1.0.0', implementation_id = paste0(project_id, '.producer-implementation'), implementation_version = '1.0.0', mapping_id = paste0(project_id, '.mapping'), mapping_version = '1.0.0', canonical_profile_id = 'rrp.canonical-profile.readmission', canonical_profile_version = '0.1.0', canonical_as_of_time = request$as_of_time, capabilities = capabilities, candidate_bundle = NULL, failure_code = 'producer_source_failed'))",
    "    ids <- if (identical(mode, 'zero')) character() else c('episode-accepted', 'episode-declared', 'episode-detected', 'episode-invalid-result', 'episode-invalid-estimate', 'episode-ineligible')",
    "    if (file.exists(file.path(project_root, 'include-extra'))) ids <- c(ids, 'episode-extra')",
    "    episodes <- data.frame(episode_id = ids, patient_id = sub('episode-', 'patient-', ids, fixed = TRUE), index_encounter_id = sub('episode-', 'encounter-', ids, fixed = TRUE), admission_time = rep('2026-01-31T12:00:00Z', length(ids)), discharge_time = rep('2026-02-01T12:00:00Z', length(ids)), followup_window_end = rep('2026-03-03T12:00:00Z', length(ids)), stringsAsFactors = FALSE)",
    "    events <- if ('episode-ineligible' %in% ids) data.frame(terminal_event_id = 'event-readmission', episode_id = 'episode-ineligible', event_type = 'readmission', occurred_at = '2026-02-05T12:00:00Z', available_at = '2026-02-05T12:00:00Z', stringsAsFactors = FALSE) else data.frame(terminal_event_id = character(), episode_id = character(), event_type = character(), occurred_at = character(), available_at = character(), stringsAsFactors = FALSE)",
    "    candidate <- list(bundle_contract_id = 'rrp.canonical-bundle', bundle_contract_version = '0.1.0', bundle_instance_id = paste0(project_id, '.bundle'), project_id = project_id, project_version = '1.0.0', producer_id = paste0(project_id, '.producer'), producer_version = '1.0.0', implementation_id = paste0(project_id, '.producer-implementation'), implementation_version = '1.0.0', mapping_id = paste0(project_id, '.mapping'), mapping_version = '1.0.0', canonical_profile_id = 'rrp.canonical-profile.readmission', canonical_profile_version = '0.1.0', as_of_time = request$as_of_time, capabilities = capabilities, domains = list(discharge_episode = episodes, terminal_event = events))",
    "    if (identical(mode, 'admission-failure')) candidate$bundle_instance_id <- 'INVALID BUNDLE'",
    "    list(producer_contract_id = 'rrp.canonical-producer', producer_contract_version = '0.1.0', status = 'succeeded', producer_id = paste0(project_id, '.producer'), producer_version = '1.0.0', implementation_id = paste0(project_id, '.producer-implementation'), implementation_version = '1.0.0', mapping_id = paste0(project_id, '.mapping'), mapping_version = '1.0.0', canonical_profile_id = 'rrp.canonical-profile.readmission', canonical_profile_version = '0.1.0', canonical_as_of_time = request$as_of_time, capabilities = capabilities, candidate_bundle = candidate, failure_code = NULL)",
    "  }",
    "  provider <- function(request) {",
    "    prior <- if (exists(request$episode_id, provider_calls, inherits = FALSE)) get(request$episode_id, provider_calls, inherits = FALSE) else 0L",
    "    assign(request$episode_id, prior + 1L, provider_calls)",
    "    if (file.exists(file.path(project_root, 'forbid-provider'))) stop('committed provider was recalled')",
    "    if (file.exists(file.path(project_root, 'forbid-committed')) && request$episode_id %in% c('episode-accepted', 'episode-declared')) stop('committed provider was recalled')",
    "    if (identical(request$episode_id, 'episode-declared')) return(list(request_id = request$request_id, status = 'failure', estimate_value = NULL, failure_code = 'provider_unavailable'))",
    "    if (identical(request$episode_id, 'episode-detected') && !file.exists(file.path(project_root, 'retry-ok'))) stop('private failure')",
    "    if (identical(request$episode_id, 'episode-invalid-result')) return(c(list(request_id = request$request_id, status = 'success', estimate_value = as.numeric(0.37), failure_code = NULL), list(extra = 'not-allowed')))",
    "    if (identical(request$episode_id, 'episode-invalid-estimate')) return(list(request_id = request$request_id, status = 'success', estimate_value = 1L, failure_code = NULL))",
    "    setwd(tempdir())",
    "    .libPaths(.Library, include.site = FALSE)",
    "    list(request_id = request$request_id, status = 'success', estimate_value = as.numeric(0.37), failure_code = NULL)",
    "  }",
    "  provider_target <- if (identical(mode, 'incompatible')) '9.9.9' else '0.1.0'",
    "  list(registration_contract_id = 'rrp.project-registration', registration_contract_version = '0.3.0', project_id = project_id, producers = list(list(component_id = paste0(project_id, '.producer'), component_version = '1.0.0', producer_api_id = 'rrp.producer-api', producer_api_version = '0.1.0', canonical_bundle_id = 'rrp.canonical-bundle', canonical_bundle_version = '0.1.0', canonical_profile_id = 'rrp.canonical-profile.readmission', canonical_profile_version = '0.1.0', implementation_id = paste0(project_id, '.producer-implementation'), implementation_version = '1.0.0', mapping_id = paste0(project_id, '.mapping'), mapping_version = '1.0.0', capabilities = capabilities, callable = producer)), providers = list(list(component_id = paste0(project_id, '.provider'), component_version = '1.0.0', provider_api_id = 'rrp.provider-api', provider_api_version = '0.1.0', target_id = 'rrp.risk-target.readmission-remaining-30-day', target_version = provider_target, state_contract_id = 'rrp.episode-state', state_contract_version = '0.1.0', request_contract_id = 'rrp.risk-request', request_contract_version = '0.1.0', estimate_contract_id = 'rrp.risk-estimate', estimate_contract_version = '0.1.0', implementation_id = paste0(project_id, '.provider-implementation'), implementation_version = '1.0.0', model_id = NULL, model_version = NULL, callable = provider)))",
    "}"
  )
  writeLines(registration, file.path(root, "R", "register.R"), useBytes = TRUE)
  root
}

durable_success <- function(value, operation_id) {
  if (!identical(value$operation_id, operation_id) ||
      !identical(value$status, "success") ||
      !identical(rrp_operation_succeeded(value), TRUE)) {
    code <- if (length(value$diagnostics)) {
      value$diagnostics[[1L]]$code
    } else {
      "missing_diagnostic"
    }
    stop(operation_id, " failed with ", code, ".", call. = FALSE)
  }
  invisible(value)
}

local({
  arguments <- commandArgs(trailingOnly = TRUE)
  software_root <- if (length(arguments) && nzchar(arguments[[1L]])) {
    normalizePath(arguments[[1L]], winslash = "/", mustWork = TRUE)
  } else {
    helper_expressions <- parse("project-state.R")
    for (expression in helper_expressions[-length(helper_expressions)]) {
      eval(expression, envir = .GlobalEnv)
    }
    fixture_root <- tempfile("rrp-durable-resources-")
    dir.create(fixture_root)
    on.exit(unlink(fixture_root, recursive = TRUE, force = TRUE), add = TRUE)
    state_software_root(file.path(fixture_root, "software"))
  }
  catalog <- rrp_open_resource_catalog(software_root)
  root <- tempfile("rrp-durable-history-")
  dir.create(root)
  on.exit(unlink(root, recursive = TRUE, force = TRUE), add = TRUE)
  as_of <- "2026-02-10T12:00:00Z"
  target <- "rrp.risk-target.readmission-remaining-30-day"

  uninitialized <- durable_write_project(
    file.path(root, "uninitialized"), "fictional-uninitialized"
  )
  uninitialized_result <- rrp_execute_durable_bundle(
    catalog, uninitialized, as_of, "must-not-run"
  )
  stopifnot(
    !rrp_operation_succeeded(uninitialized_result),
    identical(
      uninitialized_result$diagnostics[[1L]]$code, "state_uninitialized"
    ),
    !dir.exists(file.path(uninitialized, "state"))
  )

  project <- durable_write_project(file.path(root, "project"), "fictional-durable")
  durable_success(
    rrp_initialize_project_state(catalog, project),
    "rrp.initialize-project-state"
  )
  before <- sort(list.files(project, recursive = TRUE, all.files = TRUE,
    no.. = TRUE, full.names = FALSE), method = "radix")
  original_directory <- getwd()
  original_libraries <- .libPaths()
  result <- rrp_execute_durable_bundle(catalog, project, as_of, "daily-one")
  durable_success(result, "rrp.execute-durable-bundle")
  stopifnot(
    identical(result$value$expected_episode_count, 6L),
    identical(result$value$dispositioned_episode_count, 6L),
    isTRUE(result$value$complete),
    identical(getwd(), original_directory),
    identical(.libPaths(), original_libraries)
  )
  scope_id <- result$value$operation_run_id
  scope <- rrp_inspect_scope_history(catalog, project, scope_id)
  durable_success(scope, "rrp.inspect-scope-history")
  outcomes <- sort(vapply(scope$value$dispositions, `[[`, character(1L), "outcome"))
  stopifnot(identical(outcomes, sort(c(
    "accepted_estimate", "provider_declared_failure",
    "detected_failure", "detected_failure", "detected_failure", "ineligible"
  ))))
  stopifnot(all(c(
    "provider_execution_failed", "invalid_provider_result", "invalid_estimate"
  ) %in% vapply(scope$value$dispositions, `[[`, character(1L), "outcome_code")))
  ineligible <- Filter(function(value) identical(value$outcome, "ineligible"),
    scope$value$dispositions)[[1L]]
  stopifnot(is.null(ineligible$state), is.null(ineligible$request),
    identical(ineligible$provider_status, "not_invoked"))
  after <- sort(list.files(project, recursive = TRUE, all.files = TRUE,
    no.. = TRUE, full.names = FALSE), method = "radix")
  stopifnot(identical(after, before))

  writeLines("enabled", file.path(project, "forbid-provider"))
  repeat_result <- rrp_execute_durable_bundle(catalog, project, as_of, "daily-one")
  durable_success(repeat_result, "rrp.execute-durable-bundle")
  stopifnot(identical(repeat_result$value, result$value))
  unlink(file.path(project, "forbid-provider"))
  writeLines("change", file.path(project, "include-extra"))
  conflict <- rrp_execute_durable_bundle(catalog, project, as_of, "daily-one")
  stopifnot(!rrp_operation_succeeded(conflict),
    identical(conflict$diagnostics[[1L]]$code, "identity_conflict"))
  unlink(file.path(project, "include-extra"))

  detected <- Filter(function(value) {
    identical(value$episode_id, "episode-detected")
  }, scope$value$dispositions)[[1L]]
  writeLines("enabled", file.path(project, "retry-ok"))
  retry <- rrp_retry_episode(
    catalog, project, scope_id, detected$analytical_run_id, "manual-one"
  )
  durable_success(retry, "rrp.retry-episode")
  stopifnot(
    identical(retry$value$related_analytical_run_id, detected$analytical_run_id),
    identical(retry$value$outcome, "accepted_estimate")
  )
  unlink(file.path(project, "retry-ok"))
  retry_repeat <- rrp_retry_episode(
    catalog, project, scope_id, detected$analytical_run_id, "manual-one"
  )
  durable_success(retry_repeat, "rrp.retry-episode")
  stopifnot(identical(retry_repeat$value, retry$value))
  retry_conflict <- rrp_retry_episode(
    catalog, project, scope_id, detected$analytical_run_id, "manual-two"
  )
  stopifnot(!rrp_operation_succeeded(retry_conflict), identical(
    retry_conflict$diagnostics[[1L]]$code, "retry_target_already_used"
  ))
  after_retry <- rrp_inspect_scope_history(catalog, project, scope_id)
  stopifnot(isTRUE(after_retry$value$progress$complete),
    identical(after_retry$value$progress$dispositioned_episode_count, 6L),
    length(after_retry$value$dispositions) == 7L)

  episode <- rrp_inspect_episode_history(
    catalog, project, "episode-detected", target, as_of
  )
  durable_success(episode, "rrp.inspect-episode-history")
  stopifnot(length(episode$value$dispositions) == 2L)
  current <- rrp_inspect_current_history(
    catalog, project, "episode-detected", target, as_of, as_of
  )
  durable_success(current, "rrp.inspect-current-history")
  stopifnot(identical(current$value$analytical_run_id, retry$value$analytical_run_id))

  invalidated <- rrp_invalidate_history(
    catalog, project, "analytical_run", scope_id,
    retry$value$analytical_run_id, as_of, "superseded_result", "operator"
  )
  durable_success(invalidated, "rrp.invalidate-history")
  current_after <- rrp_inspect_current_history(
    catalog, project, "episode-detected", target, as_of, as_of
  )
  stopifnot(identical(current_after$value$analytical_run_id,
    detected$analytical_run_id))

  accepted <- Filter(function(value) {
    identical(value$outcome, "accepted_estimate") &&
      identical(value$analytical_kind, "initial")
  }, scope$value$dispositions)[[1L]]
  replacement_values <- accepted[c(
    "analytical_kind", "related_analytical_run_id", "analytical_key",
    "episode_id", "patient_id", "target_id", "target_version",
    "analytical_time", "outcome", "outcome_code", "eligibility_status",
    "state", "request", "provider_id", "provider_version",
    "implementation_id", "implementation_version", "model_id",
    "model_version", "provider_status", "estimate", "terminal_time"
  )]
  replacement_values$analytical_kind <- "restatement"
  replacement_values$related_analytical_run_id <- accepted$analytical_run_id
  replacement_values$analytical_key <- "corrected-one"
  replacement <- rrpruntime::rrp_new_episode_disposition(
    scope$value$scope, replacement_values
  )
  restated <- rrp_restate_history(
    catalog, project, "analytical_run", scope_id,
    accepted$analytical_run_id, replacement, as_of,
    "superseded_result", "maintainer"
  )
  durable_success(restated, "rrp.restate-history")
  accepted_current <- rrp_inspect_current_history(
    catalog, project, accepted$episode_id, target, as_of, as_of
  )
  stopifnot(identical(
    accepted_current$value$analytical_run_id, replacement$analytical_run_id
  ))

  early <- rrp_inspect_current_history(
    catalog, project, accepted$episode_id, target, as_of,
    "2026-02-09T12:00:00Z"
  )
  durable_success(early, "rrp.inspect-current-history")
  stopifnot(is.null(early$value))

  zero <- durable_write_project(file.path(root, "zero"), "fictional-zero", "zero")
  durable_success(rrp_initialize_project_state(catalog, zero),
    "rrp.initialize-project-state")
  zero_result <- rrp_execute_durable_bundle(catalog, zero, as_of, "zero-one")
  durable_success(zero_result, "rrp.execute-durable-bundle")
  stopifnot(isTRUE(zero_result$value$complete),
    identical(zero_result$value$expected_episode_count, 0L))
  zero_scope <- rrp_inspect_scope_history(
    catalog, zero, zero_result$value$operation_run_id
  )$value$scope
  zero_replacement <- rrpruntime::rrp_new_operational_scope(list(
    operation_key = "zero-corrected",
    state_id = zero_scope$state_id,
    product_id = zero_scope$product_id,
    development_version = zero_scope$development_version,
    rrp_api_version = zero_scope$rrp_api_version,
    project_api_id = zero_scope$project_api_id,
    project_api_version = zero_scope$project_api_version,
    project_id = zero_scope$project_id,
    project_version = zero_scope$project_version,
    bundle_contract_id = zero_scope$bundle_contract_id,
    bundle_contract_version = zero_scope$bundle_contract_version,
    bundle_instance_id = zero_scope$bundle_instance_id,
    canonical_profile_id = zero_scope$canonical_profile_id,
    canonical_profile_version = zero_scope$canonical_profile_version,
    producer_id = zero_scope$producer_id,
    producer_version = zero_scope$producer_version,
    producer_implementation_id = zero_scope$producer_implementation_id,
    producer_implementation_version = zero_scope$producer_implementation_version,
    mapping_id = zero_scope$mapping_id,
    mapping_version = zero_scope$mapping_version,
    target_id = zero_scope$target_id,
    target_version = zero_scope$target_version,
    analytical_time = zero_scope$analytical_time,
    created_at = zero_scope$created_at
  ), character())
  scope_restatement <- rrp_restate_history(
    catalog, zero, "operational_scope", zero_scope$operation_run_id,
    zero_scope$operation_run_id, zero_replacement, as_of,
    "incorrect_scope", "maintainer"
  )
  durable_success(scope_restatement, "rrp.restate-history")

  interrupted <- durable_write_project(
    file.path(root, "interrupted"), "fictional-interrupted"
  )
  durable_success(rrp_initialize_project_state(catalog, interrupted),
    "rrp.initialize-project-state")
  engine <- get("rrp_durable_execute", asNamespace("rrpplatform"))
  partial <- tryCatch({
    engine(catalog, interrupted, as_of, "interrupt-one", interrupt_after = 2L)
    NULL
  }, rrp_durable_error = identity)
  stopifnot(identical(partial$code, "injected_interruption"))
  state <- rrp_inspect_project_state(catalog, interrupted)
  operation_id <- get("rrp_history_id", asNamespace("rrpruntime"))(
    "rrp.operation-run.",
    list(state$value$state_id, "rrp.operation.evaluate-admitted-bundle", "interrupt-one")
  )
  partial_scope <- rrp_inspect_scope_history(catalog, interrupted, operation_id)
  stopifnot(!partial_scope$value$progress$complete,
    identical(partial_scope$value$progress$dispositioned_episode_count, 2L))
  writeLines("enabled", file.path(interrupted, "forbid-committed"))
  package_libraries <- paste(vapply(
    .libPaths(), encodeString, character(1L), quote = "\""
  ), collapse = ", ")
  continuation_script <- file.path(root, "continue-durable.R")
  continuation_result <- file.path(root, "continued.rds")
  continuation_output <- file.path(root, "continuation-output")
  writeLines(c(
    paste0(".libPaths(c(", package_libraries, "))"),
    "args <- commandArgs(trailingOnly = TRUE)",
    "library(rrpplatform)",
    "catalog <- rrp_open_resource_catalog(args[[1L]])",
    "result <- rrp_execute_durable_bundle(catalog, args[[2L]], args[[3L]], args[[4L]])",
    "stopifnot(rrp_operation_succeeded(result), isTRUE(result$value$complete))",
    "saveRDS(result, args[[5L]])"
  ), continuation_script, useBytes = TRUE)
  continuation_status <- system2(
    file.path(R.home("bin"), "Rscript"),
    c(
      "--vanilla", shQuote(continuation_script), shQuote(software_root),
      shQuote(interrupted), shQuote(as_of), shQuote("interrupt-one"),
      shQuote(continuation_result)
    ),
    stdout = continuation_output, stderr = continuation_output,
    env = "R_TESTS="
  )
  if (!identical(continuation_status, 0L)) stop(
    "Separate-process durable continuation failed: ",
    paste(readLines(continuation_output, warn = FALSE), collapse = "\n"),
    call. = FALSE
  )
  continued <- readRDS(continuation_result)
  durable_success(continued, "rrp.execute-durable-bundle")
  stopifnot(isTRUE(continued$value$complete),
    identical(continued$value$dispositioned_episode_count, 6L))

  failed <- durable_write_project(
    file.path(root, "producer-failure"), "fictional-producer-failure",
    "producer-failure"
  )
  durable_success(rrp_initialize_project_state(catalog, failed),
    "rrp.initialize-project-state")
  database <- file.path(failed, "state", "history.duckdb")
  before_failure <- unname(tools::md5sum(database))
  producer_failure <- rrp_execute_durable_bundle(
    catalog, failed, as_of, "never-scoped"
  )
  stopifnot(!rrp_operation_succeeded(producer_failure),
    identical(producer_failure$diagnostics[[1L]]$code, "producer_source_failed"),
    identical(unname(tools::md5sum(database)), before_failure))

  admission_failed <- durable_write_project(
    file.path(root, "admission-failure"), "fictional-admission-failure",
    "admission-failure"
  )
  durable_success(rrp_initialize_project_state(catalog, admission_failed),
    "rrp.initialize-project-state")
  admission_database <- file.path(admission_failed, "state", "history.duckdb")
  before_admission <- unname(tools::md5sum(admission_database))
  admission_failure <- rrp_execute_durable_bundle(
    catalog, admission_failed, as_of, "never-admitted"
  )
  stopifnot(!rrp_operation_succeeded(admission_failure),
    identical(
      admission_failure$diagnostics[[1L]]$code, "invalid_bundle_identity"
    ),
    identical(unname(tools::md5sum(admission_database)), before_admission))

  copy_parent <- file.path(root, "copy-parent")
  dir.create(copy_parent)
  stopifnot(file.copy(interrupted, copy_parent, recursive = TRUE))
  copied <- file.path(copy_parent, basename(interrupted))
  copied_result <- rrp_execute_durable_bundle(
    catalog, copied, as_of, "interrupt-one"
  )
  durable_success(copied_result, "rrp.execute-durable-bundle")
  stopifnot(identical(copied_result$value, continued$value))
})
