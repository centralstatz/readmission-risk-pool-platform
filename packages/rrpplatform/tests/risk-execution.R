library(rrpplatform)

rrp_risk_test_internal <- function(name) {
  get(name, envir = asNamespace("rrpplatform"), inherits = FALSE)
}

rrp_risk_test_write_record <- function(record, path) {
  dir.create(dirname(path), recursive = TRUE, showWarnings = FALSE)
  writeLines(paste0(names(record), ": ", unname(record)), path, useBytes = TRUE)
}

rrp_risk_test_write_records <- function(records, path) {
  lines <- unlist(lapply(seq_along(records), function(index) {
    rendered <- paste0(names(records[[index]]), ": ", unname(records[[index]]))
    if (index < length(records)) c(rendered, "") else rendered
  }), use.names = FALSE)
  dir.create(dirname(path), recursive = TRUE, showWarnings = FALSE)
  writeLines(lines, path, useBytes = TRUE)
}

rrp_risk_test_software_root <- function(root) {
  resources <- list(
    list(
      id = "rrp.contract.resource-catalog", owner = "rrpplatform",
      path = "resources/resource-catalog-schema.dcf",
      value = rrp_risk_test_internal("rrp_resource_schema_contract")()
    ),
    list(
      id = "rrp.contract.project-manifest", owner = "rrpplatform",
      path = "resources/contracts/project-manifest.dcf",
      value = rrp_risk_test_internal(
        "rrp_project_manifest_contract_expected"
      )()
    ),
    list(
      id = "rrp.contract.project-registration", owner = "rrpplatform",
      path = "resources/contracts/project-registration.dcf",
      value = rrp_risk_test_internal(
        "rrp_project_registration_contract_expected"
      )()
    )
  )
  canonical <- rrp_risk_test_internal("rrp_canonical_contract_definitions")()
  resources <- c(resources, lapply(canonical, function(definition) list(
    id = definition$resource_id,
    owner = definition$owner,
    path = definition$path,
    value = definition$expected
  )))
  runtime <- rrp_risk_test_internal("rrp_runtime_contract_definitions")()
  resources <- c(resources, lapply(runtime, function(definition) list(
    id = definition$resource_id,
    owner = definition$owner,
    path = definition$path,
    value = definition$expected
  )))
  for (resource in resources) {
    rrp_risk_test_write_record(resource$value, file.path(root, resource$path))
  }
  header <- c(
    "Record-Type" = "catalog",
    "Catalog-ID" = "rrp.software-resources",
    "Catalog-Version" = "0.1.0",
    "Format-Version" = "1.0.0",
    "Product-ID" = "readmission-risk-pool-platform",
    "Development-Version" = "1.0.0-dev",
    "Status" = "development_unpublished"
  )
  entries <- lapply(resources, function(resource) c(
    "Record-Type" = "resource",
    "Resource-ID" = resource$id,
    "Resource-Class" = "contract",
    "Owner-Package" = resource$owner,
    "Installed-Path" = resource$path,
    "Format" = "dcf"
  ))
  rrp_risk_test_write_records(
    c(list(header), entries),
    file.path(root, "resources", "resource-catalog.dcf")
  )
  root
}

rrp_risk_test_manifest <- function(project_id, installed_provider = FALSE) {
  c(
    "Record-Type" = "rrp-project",
    "Project-Contract-ID" = "rrp.project",
    "Project-Contract-Version" = "0.3.0",
    "Project-ID" = project_id,
    "Project-Version" = "1.0.0",
    "Project-Scope" = "one_health_system",
    "Supported-RRP-API-Version" = "0.3.0",
    "Canonical-Profile-ID" = "rrp.canonical-profile.readmission",
    "Canonical-Profile-Version" = "0.1.0",
    "Producer-ID" = paste0(project_id, ".producer"),
    "Producer-Version" = "1.0.0",
    "Provider-ID" = if (installed_provider) {
      "rrp.provider.transparent"
    } else {
      paste0(project_id, ".provider")
    },
    "Provider-Version" = if (installed_provider) "0.1.0" else "1.0.0",
    "Extension-Library-Path" = "extensions/library",
    "State-Path" = "state"
  )
}

rrp_risk_test_source <- function(
  project_root,
  discharge_time = "2026-02-01T12:00:00Z",
  followup_end = "2026-03-03T12:00:00Z",
  event_type = NULL,
  event_time = NULL
) {
  source_root <- file.path(project_root, "fictional-input")
  dir.create(source_root, recursive = TRUE)
  writeLines(c(
    "local_case,local_member,admitted_at,discharged_at,coverage_end",
    paste(c(
      "case-one", "member-one", "2026-01-31T12:00:00Z",
      discharge_time, followup_end
    ), collapse = ",")
  ), file.path(source_root, "episodes.csv"), useBytes = TRUE)
  event_lines <- "local_event,local_case,event_kind,event_time,loaded_time"
  if (!is.null(event_type)) {
    event_lines <- c(event_lines, paste(c(
      "event-one", "case-one", event_type, event_time, event_time
    ), collapse = ","))
  }
  writeLines(event_lines, file.path(source_root, "events.csv"), useBytes = TRUE)
}

rrp_risk_test_provider_body <- function(mode, probability) {
  if (mode %in% c(
    "provider_unavailable", "provider_input_unavailable",
    "provider_calculation_failed"
  )) {
    return(c(
      paste0("    if (provider_calls > 1L) stop('retry detected')"),
      "    list(request_id = request$request_id, status = 'failure',",
      "      estimate_value = NULL,",
      paste0("      failure_code = '", mode, "')")
    ))
  }
  if (identical(mode, "throw")) {
    return("    stop('private provider host=hidden credential=never-render', call. = FALSE)")
  }
  if (identical(mode, "malformed")) {
    return(c(
      "    result <- list(request_id = request$request_id, status = 'success', estimate_value = 0.42, failure_code = NULL)",
      "    result$unknown <- 'not allowed'",
      "    result"
    ))
  }
  if (identical(mode, "mismatch")) {
    return("    list(request_id = 'rrp.request.different', status = 'success', estimate_value = 0.42, failure_code = NULL)")
  }
  if (identical(mode, "invalid_estimate")) {
    return("    list(request_id = request$request_id, status = 'success', estimate_value = 1L, failure_code = NULL)")
  }
  if (identical(mode, "sentinel")) {
    return("    stop('pre-provider sentinel was invoked', call. = FALSE)")
  }
  c(
    "    if (provider_calls > 1L) stop('provider invoked more than once')",
    "    setwd(tempdir())",
    "    .libPaths(.Library, include.site = FALSE)",
    paste0(
      "    list(request_id = request$request_id, status = 'success', ",
      "estimate_value = as.numeric(", probability, "), failure_code = NULL)"
    )
  )
}

rrp_risk_test_registration <- function(
  project_id,
  installed_provider = FALSE,
  provider_mode = "success",
  probability = 0.61,
  incompatible_provider = FALSE
) {
  producer_id <- paste0(project_id, ".producer")
  provider_id <- paste0(project_id, ".provider")
  implementation_id <- paste0(project_id, ".implementation")
  mapping_id <- paste0(project_id, ".mapping")
  provider_lines <- if (installed_provider) {
    "    providers = list())"
  } else {
    c(
      "    providers = list(list(",
      paste0("      component_id = '", provider_id, "', component_version = '1.0.0',"),
      "      provider_api_id = 'rrp.provider-api', provider_api_version = '0.1.0',",
      paste0(
        "      target_id = 'rrp.risk-target.readmission-remaining-30-day', ",
        "target_version = '", if (incompatible_provider) "9.9.9" else "0.1.0", "',"
      ),
      "      state_contract_id = 'rrp.episode-state', state_contract_version = '0.1.0',",
      "      request_contract_id = 'rrp.risk-request', request_contract_version = '0.1.0',",
      "      estimate_contract_id = 'rrp.risk-estimate', estimate_contract_version = '0.1.0',",
      paste0("      implementation_id = '", provider_id, ".implementation', implementation_version = '1.0.0',"),
      "      model_id = NULL, model_version = NULL, callable = provider)))"
    )
  }
  c(
    "rrp_register_project <- function(project_root) {",
    "  captured_root <- project_root",
    "  producer_calls <- 0L",
    "  provider_calls <- 0L",
    "  capabilities <- list(list(capability_id = 'rrp.capability.discharge-episode', status = 'available'), list(capability_id = 'rrp.capability.terminal-event', status = 'available'))",
    "  producer <- function(request) {",
    "    producer_calls <<- producer_calls + 1L",
    "    if (producer_calls > 1L) stop('producer invoked more than once')",
    "    local_episodes <- utils::read.csv(file.path(captured_root, 'fictional-input', 'episodes.csv'), stringsAsFactors = FALSE)",
    "    local_events <- utils::read.csv(file.path(captured_root, 'fictional-input', 'events.csv'), stringsAsFactors = FALSE)",
    "    episodes <- data.frame(episode_id = paste0('episode-', local_episodes$local_case), patient_id = paste0('patient-', local_episodes$local_member), index_encounter_id = paste0('encounter-', local_episodes$local_case), admission_time = local_episodes$admitted_at, discharge_time = local_episodes$discharged_at, followup_window_end = local_episodes$coverage_end, stringsAsFactors = FALSE)",
    "    events <- if (nrow(local_events) == 0L) data.frame(terminal_event_id = character(), episode_id = character(), event_type = character(), occurred_at = character(), available_at = character(), stringsAsFactors = FALSE) else data.frame(terminal_event_id = paste0('terminal-', local_events$local_event), episode_id = paste0('episode-', local_events$local_case), event_type = local_events$event_kind, occurred_at = local_events$event_time, available_at = local_events$loaded_time, stringsAsFactors = FALSE)",
    "    candidate <- list(bundle_contract_id = 'rrp.canonical-bundle', bundle_contract_version = '0.1.0',",
    paste0("      bundle_instance_id = '", project_id, ".bundle', project_id = '", project_id, "', project_version = '1.0.0',"),
    paste0("      producer_id = '", producer_id, "', producer_version = '1.0.0', implementation_id = '", implementation_id, "', implementation_version = '1.0.0',"),
    paste0("      mapping_id = '", mapping_id, "', mapping_version = '1.0.0', canonical_profile_id = 'rrp.canonical-profile.readmission', canonical_profile_version = '0.1.0',"),
    "      as_of_time = request$as_of_time, capabilities = capabilities, domains = list(discharge_episode = episodes, terminal_event = events))",
    "    list(producer_contract_id = 'rrp.canonical-producer', producer_contract_version = '0.1.0', status = 'succeeded',",
    paste0("      producer_id = '", producer_id, "', producer_version = '1.0.0', implementation_id = '", implementation_id, "', implementation_version = '1.0.0',"),
    paste0("      mapping_id = '", mapping_id, "', mapping_version = '1.0.0', canonical_profile_id = 'rrp.canonical-profile.readmission', canonical_profile_version = '0.1.0',"),
    "      canonical_as_of_time = request$as_of_time, capabilities = capabilities, candidate_bundle = candidate, failure_code = NULL)",
    "  }",
    "  provider <- function(request) {",
    "    provider_calls <<- provider_calls + 1L",
    rrp_risk_test_provider_body(provider_mode, probability),
    "  }",
    "  list(registration_contract_id = 'rrp.project-registration', registration_contract_version = '0.3.0',",
    paste0("    project_id = '", project_id, "',"),
    "    producers = list(list(",
    paste0("      component_id = '", producer_id, "', component_version = '1.0.0',"),
    "      producer_api_id = 'rrp.producer-api', producer_api_version = '0.1.0',",
    "      canonical_bundle_id = 'rrp.canonical-bundle', canonical_bundle_version = '0.1.0',",
    "      canonical_profile_id = 'rrp.canonical-profile.readmission', canonical_profile_version = '0.1.0',",
    paste0("      implementation_id = '", implementation_id, "', implementation_version = '1.0.0',"),
    paste0("      mapping_id = '", mapping_id, "', mapping_version = '1.0.0', capabilities = capabilities, callable = producer)),"),
    provider_lines,
    "}"
  )
}

rrp_risk_test_project <- function(
  parent,
  label,
  project_id,
  installed_provider = FALSE,
  provider_mode = "success",
  probability = 0.61,
  incompatible_provider = FALSE,
  discharge_time = "2026-02-01T12:00:00Z",
  followup_end = "2026-03-03T12:00:00Z",
  event_type = NULL,
  event_time = NULL
) {
  root <- file.path(parent, label)
  dir.create(file.path(root, "R"), recursive = TRUE)
  manifest <- rrp_risk_test_manifest(project_id, installed_provider)
  writeLines(
    paste0(names(manifest), ": ", unname(manifest)),
    file.path(root, "rrp-project.dcf"), useBytes = TRUE
  )
  writeLines(
    rrp_risk_test_registration(
      project_id, installed_provider, provider_mode, probability,
      incompatible_provider
    ),
    file.path(root, "R", "register.R"), useBytes = TRUE
  )
  rrp_risk_test_source(
    root, discharge_time, followup_end, event_type, event_time
  )
  root
}

rrp_risk_test_files <- function(root) {
  sort(list.files(
    root, recursive = TRUE, all.files = TRUE, no.. = TRUE,
    full.names = FALSE, include.dirs = FALSE
  ), method = "radix")
}

rrp_risk_test_digests <- function(root) {
  files <- rrp_risk_test_files(root)
  result <- unname(tools::md5sum(file.path(root, files)))
  names(result) <- files
  result
}

rrp_risk_test_failure <- function(result, code, forbidden = character()) {
  stopifnot(
    identical(class(result), c("rrp_operation_result", "list")),
    identical(result$operation_id, "rrp.execute-risk"),
    identical(result$status, "failure"),
    is.null(result$value),
    length(result$diagnostics) == 1L,
    identical(result$diagnostics[[1L]]$code, code),
    identical(result$diagnostics[[1L]]$severity, "error"),
    identical(rrp_operation_succeeded(result), FALSE)
  )
  rendered <- paste(capture.output(str(result)), collapse = " ")
  for (value in forbidden[nzchar(forbidden)]) {
    stopifnot(!grepl(value, rendered, fixed = TRUE))
  }
  invisible(result)
}

local({
  suite_root <- tempfile("rrp-risk-execution-")
  dir.create(suite_root)
  on.exit(unlink(suite_root, recursive = TRUE, force = TRUE), add = TRUE)
  arguments <- commandArgs(trailingOnly = TRUE)
  software_root <- if (length(arguments) >= 1L && nzchar(arguments[[1L]])) {
    normalizePath(arguments[[1L]], winslash = "/", mustWork = TRUE)
  } else {
    rrp_risk_test_software_root(file.path(suite_root, "software"))
  }
  catalog <- rrp_open_resource_catalog(software_root)
  projects <- file.path(suite_root, "projects")
  dir.create(projects)
  unrelated <- file.path(suite_root, "unrelated-non-git-working-directory")
  dir.create(unrelated)
  previous_directory <- setwd(unrelated)
  on.exit(setwd(previous_directory), add = TRUE)
  before_libraries <- .libPaths()
  before_globals <- ls(.GlobalEnv, all.names = TRUE)
  as_of <- "2026-02-10T12:00:00Z"

  transparent <- rrp_risk_test_project(
    projects, "transparent", "fictional-transparent",
    installed_provider = TRUE
  )
  transparent_files <- rrp_risk_test_files(transparent)
  transparent_digests <- rrp_risk_test_digests(transparent)
  transparent_context <- rrp_load_project(catalog, transparent)
  transparent_admission <- rrp_execute_producer(catalog, transparent, as_of)
  transparent_result <- rrp_execute_risk(
    catalog, transparent, transparent_admission$value,
    "episode-case-one", as_of
  )
  transparent_repeat <- rrp_execute_risk(
    catalog, transparent, transparent_admission$value,
    "episode-case-one", as_of
  )
  transparent_estimate <- transparent_result$value
  stopifnot(
    identical(transparent_context$provider$origin, "installed"),
    identical(
      transparent_context$provider$component_id, "rrp.provider.transparent"
    ),
    identical(transparent_context$provider$component_version, "0.1.0"),
    identical(
      transparent_context$provider$implementation_id,
      "rrp.provider-implementation.transparent"
    ),
    is.null(transparent_context$provider$model_id),
    identical(transparent_result$operation_id, "rrp.execute-risk"),
    identical(transparent_result$status, "success"),
    identical(transparent_result$diagnostics, list()),
    identical(class(transparent_estimate), c("rrp_risk_estimate", "list")),
    identical(transparent_repeat$value, transparent_estimate),
    identical(transparent_estimate$estimate_value, 0.14),
    identical(
      transparent_estimate$target_id,
      "rrp.risk-target.readmission-remaining-30-day"
    ),
    identical(transparent_estimate$request_contract_id, "rrp.risk-request"),
    identical(transparent_estimate$state_contract_id, "rrp.episode-state"),
    identical(transparent_estimate$project_id, "fictional-transparent"),
    identical(transparent_estimate$episode_id, "episode-case-one"),
    identical(transparent_estimate$provider_id, "rrp.provider.transparent"),
    identical(
      transparent_estimate$implementation_id,
      "rrp.provider-implementation.transparent"
    ),
    is.null(transparent_estimate$model_id),
    is.null(transparent_estimate$model_version),
    identical(rrp_operation_succeeded(transparent_result), TRUE),
    identical(rrp_risk_test_files(transparent), transparent_files),
    identical(rrp_risk_test_digests(transparent), transparent_digests),
    !dir.exists(file.path(transparent, "state"))
  )

  project_provider <- rrp_risk_test_project(
    projects, "project-provider", "fictional-project-provider",
    probability = 0.61
  )
  dir.create(
    file.path(project_provider, "extensions", "library"), recursive = TRUE
  )
  project_files <- rrp_risk_test_files(project_provider)
  project_digests <- rrp_risk_test_digests(project_provider)
  project_context <- rrp_load_project(catalog, project_provider)
  project_admission <- rrp_execute_producer(catalog, project_provider, as_of)
  project_result <- rrp_execute_risk(
    catalog, project_provider, project_admission$value,
    "episode-case-one", as_of
  )
  stopifnot(
    identical(project_context$provider$origin, "project"),
    identical(project_result$status, "success"),
    identical(project_result$value$estimate_value, 0.61),
    !identical(
      project_result$value$estimate_value,
      transparent_result$value$estimate_value
    ),
    identical(
      project_result$value$provider_id,
      "fictional-project-provider.provider"
    ),
    identical(rrp_risk_test_files(project_provider), project_files),
    identical(rrp_risk_test_digests(project_provider), project_digests),
    identical(getwd(), normalizePath(unrelated, winslash = "/", mustWork = TRUE)),
    identical(.libPaths(), before_libraries),
    identical(ls(.GlobalEnv, all.names = TRUE), before_globals),
    !dir.exists(file.path(project_provider, "state"))
  )

  copy_parent <- file.path(suite_root, "copied-project")
  dir.create(copy_parent)
  stopifnot(file.copy(
    project_provider, copy_parent, recursive = TRUE, copy.mode = FALSE
  ))
  copied_project <- file.path(copy_parent, basename(project_provider))
  copied_result <- rrp_execute_risk(
    catalog, copied_project, project_admission$value,
    "episode-case-one", as_of
  )
  stopifnot(
    identical(copied_result$status, "success"),
    identical(copied_result$value$estimate_value, 0.61),
    !dir.exists(file.path(copied_project, "state"))
  )

  detached <- unserialize(serialize(transparent_estimate, NULL))
  transparent_admission$value$bundle_instance_id <- "changed-after-execution"
  stopifnot(identical(transparent_estimate, detached))

  for (code in c(
    "provider_unavailable", "provider_input_unavailable",
    "provider_calculation_failed"
  )) {
    fixture <- rrp_risk_test_project(
      projects, paste0("failure-", code), "fictional-project-provider",
      provider_mode = code
    )
    result <- rrp_execute_risk(
      catalog, fixture, project_admission$value, "episode-case-one", as_of
    )
    rrp_risk_test_failure(result, code)
  }

  detected <- list(
    throw = "provider_execution_failed",
    malformed = "invalid_provider_result",
    mismatch = "provider_result_identity_mismatch",
    invalid_estimate = "invalid_estimate"
  )
  for (mode in names(detected)) {
    fixture <- rrp_risk_test_project(
      projects, paste0("detected-", mode), "fictional-project-provider",
      provider_mode = mode
    )
    result <- rrp_execute_risk(
      catalog, fixture, project_admission$value, "episode-case-one", as_of
    )
    rrp_risk_test_failure(
      result, detected[[mode]],
      c("private provider", "host=hidden", "credential=never-render")
    )
  }

  sentinel <- rrp_risk_test_project(
    projects, "sentinel", "fictional-project-provider",
    provider_mode = "sentinel"
  )
  invalid_time <- rrp_execute_risk(
    catalog, file.path(suite_root, "never-loaded"), project_admission$value,
    "episode-case-one", "2026-02-10 12:00:00"
  )
  rrp_risk_test_failure(invalid_time, "invalid_analytical_as_of")
  mismatch <- rrp_execute_risk(
    catalog, sentinel, project_admission$value,
    "episode-case-one", "2026-02-10T12:00:01Z"
  )
  rrp_risk_test_failure(mismatch, "analytical_as_of_mismatch")
  unknown <- rrp_execute_risk(
    catalog, sentinel, project_admission$value, "episode-missing", as_of
  )
  rrp_risk_test_failure(unknown, "unknown_episode")

  temporal <- list(
    horizon = list(
      t = "2026-03-03T12:00:00Z", discharge = "2026-02-01T12:00:00Z",
      end = "2026-03-03T12:00:00Z", event = NULL,
      code = "target_horizon_exhausted"
    ),
    readmitted = list(
      t = as_of, discharge = "2026-02-01T12:00:00Z",
      end = "2026-03-03T12:00:00Z", event = "readmission",
      code = "episode_already_readmitted"
    ),
    dead = list(
      t = as_of, discharge = "2026-02-01T12:00:00Z",
      end = "2026-03-03T12:00:00Z", event = "death",
      code = "episode_already_dead"
    )
  )
  for (name in names(temporal)) {
    case <- temporal[[name]]
    fixture <- rrp_risk_test_project(
      projects, paste0("temporal-", name), paste0("temporal-", name),
      provider_mode = "sentinel", discharge_time = case$discharge,
      followup_end = case$end, event_type = case$event,
      event_time = if (is.null(case$event)) NULL else "2026-02-05T12:00:00Z"
    )
    admitted <- rrp_execute_producer(catalog, fixture, case$t)
    stopifnot(identical(admitted$status, "success"))
    result <- rrp_execute_risk(
      catalog, fixture, admitted$value, "episode-case-one", case$t
    )
    rrp_risk_test_failure(result, case$code)
  }

  incompatible <- rrp_risk_test_project(
    projects, "incompatible", "fictional-project-provider",
    provider_mode = "sentinel", incompatible_provider = TRUE
  )
  incompatible_result <- rrp_execute_risk(
    catalog, incompatible, project_admission$value, "episode-case-one", as_of
  )
  rrp_risk_test_failure(
    incompatible_result, "incompatible_provider_declaration"
  )

  no_default <- rrp_risk_test_project(
    projects, "no-default", "fictional-no-default",
    installed_provider = TRUE
  )
  no_default_manifest <- readLines(
    file.path(no_default, "rrp-project.dcf"), warn = FALSE
  )
  no_default_manifest <- sub(
    "^Provider-ID:.*$", "Provider-ID: missing.provider", no_default_manifest
  )
  writeLines(
    no_default_manifest, file.path(no_default, "rrp-project.dcf"),
    useBytes = TRUE
  )
  no_default_result <- rrp_execute_risk(
    catalog, no_default, transparent_admission$value,
    "episode-case-one", as_of
  )
  rrp_risk_test_failure(no_default_result, "unknown_provider_selection")

  other_project <- rrp_risk_test_project(
    projects, "other-project", "fictional-other-project",
    provider_mode = "sentinel"
  )
  project_mismatch <- rrp_execute_risk(
    catalog, other_project, project_admission$value, "episode-case-one", as_of
  )
  rrp_risk_test_failure(project_mismatch, "project_identity_mismatch")

  resource_condition <- tryCatch({
    rrp_execute_risk(
      list(), sentinel, project_admission$value, "episode-case-one", as_of
    )
    NULL
  }, error = identity)
  stopifnot(inherits(resource_condition, "rrp_resource_error"))

  generic_body <- paste(deparse(body(
    rrp_risk_test_internal("rrp_risk_execute")
  )), collapse = " ")
  public_body <- paste(deparse(body(rrp_execute_risk)), collapse = " ")
  stopifnot(
    !grepl("rrp.provider.transparent", generic_body, fixed = TRUE),
    !grepl("fictional-project-provider", generic_body, fixed = TRUE),
    !grepl("implementation_id", generic_body, fixed = TRUE),
    !grepl("model_id", generic_body, fixed = TRUE),
    !grepl("error = function", public_body, fixed = TRUE),
    identical(getwd(), normalizePath(unrelated, winslash = "/", mustWork = TRUE)),
    identical(.libPaths(), before_libraries),
    identical(ls(.GlobalEnv, all.names = TRUE), before_globals),
    !dir.exists(file.path(transparent, "state")),
    !dir.exists(file.path(project_provider, "state")),
    !dir.exists(file.path(unrelated, ".git"))
  )
})

cat("rrpplatform risk-execution tests passed\n")
