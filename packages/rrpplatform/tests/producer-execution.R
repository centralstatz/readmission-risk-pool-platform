library(rrpplatform)

rrp_producer_test_internal <- function(name) {
  get(name, envir = asNamespace("rrpplatform"), inherits = FALSE)
}

rrp_producer_test_write_record <- function(record, path) {
  dir.create(dirname(path), recursive = TRUE, showWarnings = FALSE)
  writeLines(paste0(names(record), ": ", unname(record)), path, useBytes = TRUE)
}

rrp_producer_test_write_records <- function(records, path) {
  lines <- unlist(lapply(seq_along(records), function(index) {
    record <- records[[index]]
    rendered <- paste0(names(record), ": ", unname(record))
    if (index < length(records)) c(rendered, "") else rendered
  }), use.names = FALSE)
  dir.create(dirname(path), recursive = TRUE, showWarnings = FALSE)
  writeLines(lines, path, useBytes = TRUE)
}

rrp_producer_test_software_root <- function(root) {
  resources <- list(
    list(
      id = "rrp.contract.resource-catalog", owner = "rrpplatform",
      path = "resources/resource-catalog-schema.dcf",
      value = rrp_producer_test_internal("rrp_resource_schema_contract")()
    ),
    list(
      id = "rrp.contract.project-manifest", owner = "rrpplatform",
      path = "resources/contracts/project-manifest.dcf",
      value = rrp_producer_test_internal(
        "rrp_project_manifest_contract_expected"
      )()
    ),
    list(
      id = "rrp.contract.project-registration", owner = "rrpplatform",
      path = "resources/contracts/project-registration.dcf",
      value = rrp_producer_test_internal(
        "rrp_project_registration_contract_expected"
      )()
    )
  )
  canonical <- rrp_producer_test_internal(
    "rrp_canonical_contract_definitions"
  )()
  resources <- c(resources, lapply(canonical, function(definition) list(
    id = definition$resource_id,
    owner = definition$owner,
    path = definition$path,
    value = definition$expected
  )))
  for (resource in resources) {
    rrp_producer_test_write_record(
      resource$value, file.path(root, resource$path)
    )
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
  rrp_producer_test_write_records(
    c(list(header), entries),
    file.path(root, "resources", "resource-catalog.dcf")
  )
  root
}

rrp_producer_test_manifest <- function(project_id) {
  c(
    "Record-Type" = "rrp-project",
    "Project-Contract-ID" = "rrp.project",
    "Project-Contract-Version" = "0.2.0",
    "Project-ID" = project_id,
    "Project-Version" = "1.0.0",
    "Project-Scope" = "one_health_system",
    "Supported-RRP-API-Version" = "0.2.0",
    "Canonical-Profile-ID" = "rrp.canonical-profile.readmission",
    "Canonical-Profile-Version" = "0.1.0",
    "Producer-ID" = paste0(project_id, ".producer"),
    "Producer-Version" = "1.0.0",
    "Provider-ID" = paste0(project_id, ".provider"),
    "Provider-Version" = "1.0.0",
    "Extension-Library-Path" = "extensions/library",
    "State-Path" = "state"
  )
}

rrp_producer_test_source_a <- function(project_root) {
  path <- file.path(project_root, "incoming", "encounters.csv")
  dir.create(dirname(path), recursive = TRUE)
  writeLines(c(
    paste(c(
      "visit_key", "person_key", "admitted_at", "left_at",
      "coverage_until", "return_key", "returned_at", "return_loaded_at"
    ), collapse = ","),
    paste(c(
      "alpha-visit", "alpha-person", "2026-01-01T08:00:00-06:00",
      "2026-01-02T08:00:00-06:00", "2026-02-01T14:00:00Z",
      "alpha-return", "2026-01-15T12:00:00-06:00",
      "2026-01-16T01:00:00+07:00"
    ), collapse = ",")
  ), path, useBytes = TRUE)
}

rrp_producer_test_source_b <- function(project_root) {
  stay_path <- file.path(project_root, "stays", "stays.csv")
  return_path <- file.path(project_root, "events", "returns.csv")
  death_path <- file.path(project_root, "events", "deaths.csv")
  dir.create(dirname(stay_path), recursive = TRUE)
  dir.create(dirname(return_path), recursive = TRUE)
  writeLines(c(
    "unit_case,member_token,start_time,end_time,coverage_end",
    paste(c(
      "beta-stay", "beta-member", "2026-01-01T14:00:00Z",
      "2026-01-02T14:00:00Z", "2026-02-01T14:00:00Z"
    ), collapse = ",")
  ), stay_path, useBytes = TRUE)
  writeLines(c(
    "return_ref,unit_case,event_time,loaded_time",
    paste(c(
      "beta-return", "beta-stay", "2026-01-15T18:00:00Z",
      "2026-01-15T19:00:00Z"
    ), collapse = ",")
  ), return_path, useBytes = TRUE)
  writeLines(
    "death_ref,unit_case,event_time,loaded_time",
    death_path, useBytes = TRUE
  )
}

rrp_producer_test_mapping_lines <- function(source_kind) {
  if (identical(source_kind, "encounter")) {
    return(c(
      "    local_source <- utils::read.csv(file.path(captured_root, 'incoming', 'encounters.csv'), stringsAsFactors = FALSE)",
      "    episodes <- data.frame(episode_id = paste0('episode-', local_source$visit_key), patient_id = paste0('patient-', local_source$person_key), index_encounter_id = paste0('encounter-', local_source$visit_key), admission_time = local_source$admitted_at, discharge_time = local_source$left_at, followup_window_end = local_source$coverage_until, stringsAsFactors = FALSE)",
      "    events <- data.frame(terminal_event_id = paste0('event-', local_source$return_key), episode_id = paste0('episode-', local_source$visit_key), event_type = 'readmission', occurred_at = local_source$returned_at, available_at = local_source$return_loaded_at, stringsAsFactors = FALSE)",
      "    bundle_id <- 'fictional-a.bundle-001'"
    ))
  }
  c(
    "    local_stays <- utils::read.csv(file.path(captured_root, 'stays', 'stays.csv'), stringsAsFactors = FALSE)",
    "    local_returns <- utils::read.csv(file.path(captured_root, 'events', 'returns.csv'), stringsAsFactors = FALSE)",
    "    local_deaths <- utils::read.csv(file.path(captured_root, 'events', 'deaths.csv'), stringsAsFactors = FALSE)",
    "    episodes <- data.frame(episode_id = paste0('episode-', local_stays$unit_case), patient_id = paste0('patient-', local_stays$member_token), index_encounter_id = paste0('encounter-', local_stays$unit_case), admission_time = local_stays$start_time, discharge_time = local_stays$end_time, followup_window_end = local_stays$coverage_end, stringsAsFactors = FALSE)",
    "    return_events <- data.frame(terminal_event_id = paste0('event-', local_returns$return_ref), episode_id = paste0('episode-', local_returns$unit_case), event_type = 'readmission', occurred_at = local_returns$event_time, available_at = local_returns$loaded_time, stringsAsFactors = FALSE)",
    "    death_events <- if (nrow(local_deaths) == 0L) data.frame(terminal_event_id = character(), episode_id = character(), event_type = character(), occurred_at = character(), available_at = character(), stringsAsFactors = FALSE) else data.frame(terminal_event_id = paste0('event-', local_deaths$death_ref), episode_id = paste0('episode-', local_deaths$unit_case), event_type = rep('death', nrow(local_deaths)), occurred_at = local_deaths$event_time, available_at = local_deaths$loaded_time, stringsAsFactors = FALSE)",
    "    events <- rbind(return_events, death_events)",
    "    row.names(events) <- NULL",
    "    bundle_id <- 'fictional-b.bundle-001'"
  )
}

rrp_producer_test_registration <- function(
  project_id,
  source_kind = "encounter",
  failure_code = NULL,
  throw_condition = FALSE,
  result_mutation = character(),
  candidate_mutation = character(),
  alter_process = FALSE
) {
  producer_id <- paste0(project_id, ".producer")
  provider_id <- paste0(project_id, ".provider")
  implementation_id <- paste0(project_id, ".implementation")
  mapping_id <- paste0(project_id, ".mapping")
  request_fields <- paste(c(
    "producer_api_id", "producer_api_version", "project_id",
    "project_version", "producer_id", "producer_version",
    "canonical_bundle_id", "canonical_bundle_version",
    "canonical_profile_id", "canonical_profile_version", "as_of_time"
  ), collapse = "','")
  prelude <- c(
    "rrp_register_project <- function(project_root) {",
    "  captured_root <- project_root",
    "  calls <- 0L",
    "  capabilities <- list(list(capability_id = 'rrp.capability.discharge-episode', status = 'available'), list(capability_id = 'rrp.capability.terminal-event', status = 'available'))",
    "  provider <- function(...) stop('private provider condition 86420', call. = FALSE)",
    "  producer <- function(request) {",
    "    calls <<- calls + 1L",
    "    if (!identical(calls, 1L)) stop('producer invoked more than once', call. = FALSE)",
    paste0("    expected_fields <- c('", request_fields, "')"),
    "    if (!is.list(request) || is.object(request) || !identical(names(attributes(request)), 'names') || !identical(names(request), expected_fields)) stop('invalid request shape', call. = FALSE)",
    paste0("    if (!identical(request$project_id, '", project_id, "') || !identical(request$project_version, '1.0.0') || !identical(request$producer_id, '", producer_id, "') || !identical(request$producer_version, '1.0.0')) stop('invalid request identity', call. = FALSE)"),
    "    if (!identical(request$producer_api_id, 'rrp.producer-api') || !identical(request$producer_api_version, '0.1.0') || !identical(request$canonical_bundle_id, 'rrp.canonical-bundle') || !identical(request$canonical_bundle_version, '0.1.0') || !identical(request$canonical_profile_id, 'rrp.canonical-profile.readmission') || !identical(request$canonical_profile_version, '0.1.0')) stop('invalid request contract', call. = FALSE)",
    "    software_libraries <- unique(dirname(vapply(c('rrpplatform', 'rrpruntime'), find.package, character(1L))))",
    "    extension_library <- file.path(captured_root, 'extensions', 'library')",
    "    expected_libraries <- unique(c(software_libraries, if (dir.exists(extension_library)) extension_library else character(), normalizePath(.Library, winslash = '/', mustWork = TRUE)))",
    "    if (!identical(.libPaths(), expected_libraries)) stop('invalid library ordering', call. = FALSE)"
  )
  if (throw_condition) {
    producer_body <- "    stop('private source host=fictional and credential=do-not-render', call. = FALSE)"
  } else if (!is.null(failure_code)) {
    producer_body <- c(
      "    list(producer_contract_id = 'rrp.canonical-producer', producer_contract_version = '0.1.0', status = 'failed',",
      paste0("      producer_id = '", producer_id, "', producer_version = '1.0.0',"),
      paste0("      implementation_id = '", implementation_id, "', implementation_version = '1.0.0',"),
      paste0("      mapping_id = '", mapping_id, "', mapping_version = '1.0.0',"),
      "      canonical_profile_id = 'rrp.canonical-profile.readmission', canonical_profile_version = '0.1.0',",
      "      canonical_as_of_time = request$as_of_time, capabilities = capabilities, candidate_bundle = NULL,",
      paste0("      failure_code = '", failure_code, "')")
    )
  } else {
    process_lines <- if (alter_process) c(
      "    setwd(captured_root)",
      "    .libPaths(.Library, include.site = FALSE)"
    ) else character()
    producer_body <- c(
      rrp_producer_test_mapping_lines(source_kind),
      process_lines,
      "    candidate <- list(bundle_contract_id = 'rrp.canonical-bundle', bundle_contract_version = '0.1.0', bundle_instance_id = bundle_id,",
      paste0("      project_id = '", project_id, "', project_version = '1.0.0', producer_id = '", producer_id, "', producer_version = '1.0.0',"),
      paste0("      implementation_id = '", implementation_id, "', implementation_version = '1.0.0', mapping_id = '", mapping_id, "', mapping_version = '1.0.0',"),
      "      canonical_profile_id = 'rrp.canonical-profile.readmission', canonical_profile_version = '0.1.0', as_of_time = request$as_of_time, capabilities = capabilities, domains = list(discharge_episode = episodes, terminal_event = events))",
      candidate_mutation,
      "    result <- list(producer_contract_id = 'rrp.canonical-producer', producer_contract_version = '0.1.0', status = 'succeeded',",
      paste0("      producer_id = '", producer_id, "', producer_version = '1.0.0', implementation_id = '", implementation_id, "', implementation_version = '1.0.0',"),
      paste0("      mapping_id = '", mapping_id, "', mapping_version = '1.0.0', canonical_profile_id = 'rrp.canonical-profile.readmission', canonical_profile_version = '0.1.0',"),
      "      canonical_as_of_time = request$as_of_time, capabilities = capabilities, candidate_bundle = candidate, failure_code = NULL)",
      result_mutation,
      "    result"
    )
  }
  c(
    prelude,
    producer_body,
    "  }",
    "  list(registration_contract_id = 'rrp.project-registration', registration_contract_version = '0.2.0',",
    paste0("    project_id = '", project_id, "',"),
    "    producers = list(list(",
    paste0("      component_id = '", producer_id, "', component_version = '1.0.0',"),
    "      producer_api_id = 'rrp.producer-api', producer_api_version = '0.1.0',",
    "      canonical_bundle_id = 'rrp.canonical-bundle', canonical_bundle_version = '0.1.0',",
    "      canonical_profile_id = 'rrp.canonical-profile.readmission', canonical_profile_version = '0.1.0',",
    paste0("      implementation_id = '", implementation_id, "', implementation_version = '1.0.0',"),
    paste0("      mapping_id = '", mapping_id, "', mapping_version = '1.0.0', capabilities = capabilities, callable = producer)),"),
    paste0("    providers = list(list(component_id = '", provider_id, "', component_version = '1.0.0', callable = provider)))"),
    "}"
  )
}

rrp_producer_test_project <- function(
  parent,
  project_id,
  source_kind = "encounter",
  ...
) {
  root <- file.path(parent, project_id)
  dir.create(file.path(root, "R"), recursive = TRUE)
  manifest <- rrp_producer_test_manifest(project_id)
  writeLines(
    paste0(names(manifest), ": ", unname(manifest)),
    file.path(root, "rrp-project.dcf"), useBytes = TRUE
  )
  writeLines(
    rrp_producer_test_registration(project_id, source_kind, ...),
    file.path(root, "R", "register.R"), useBytes = TRUE
  )
  if (identical(source_kind, "encounter")) {
    rrp_producer_test_source_a(root)
  } else {
    rrp_producer_test_source_b(root)
  }
  root
}

rrp_producer_test_files <- function(root) {
  sort(list.files(
    root, recursive = TRUE, all.files = TRUE, no.. = TRUE,
    full.names = FALSE, include.dirs = FALSE
  ), method = "radix")
}

rrp_producer_test_digests <- function(root) {
  files <- rrp_producer_test_files(root)
  values <- unname(tools::md5sum(file.path(root, files)))
  names(values) <- files
  values
}

rrp_producer_test_expect_failure <- function(
  result,
  code,
  forbidden = character()
) {
  stopifnot(
    identical(class(result), c("rrp_operation_result", "list")),
    identical(result$operation_id, "rrp.execute-producer"),
    identical(result$status, "failure"),
    is.null(result$value),
    length(result$diagnostics) == 1L,
    identical(result$diagnostics[[1L]]$code, code),
    identical(result$diagnostics[[1L]]$severity, "error"),
    is.character(result$diagnostics[[1L]]$message),
    length(result$diagnostics[[1L]]$message) == 1L,
    nchar(result$diagnostics[[1L]]$message, type = "bytes") <= 240L,
    identical(rrp_operation_succeeded(result), FALSE)
  )
  rendered <- paste(capture.output(str(result)), collapse = " ")
  for (value in forbidden[nzchar(forbidden)]) {
    stopifnot(!grepl(value, rendered, fixed = TRUE))
  }
  invisible(result)
}

local({
  suite_root <- tempfile("rrp-producer-execution-")
  dir.create(suite_root)
  on.exit(unlink(suite_root, recursive = TRUE, force = TRUE), add = TRUE)

  arguments <- commandArgs(trailingOnly = TRUE)
  software_root <- if (length(arguments) >= 1L && nzchar(arguments[[1L]])) {
    normalizePath(arguments[[1L]], winslash = "/", mustWork = TRUE)
  } else {
    rrp_producer_test_software_root(file.path(suite_root, "software"))
  }
  catalog <- rrp_open_resource_catalog(software_root)
  projects <- file.path(suite_root, "projects")
  dir.create(projects)
  unrelated <- file.path(suite_root, "unrelated-non-git-working-directory")
  dir.create(unrelated)
  previous_directory <- setwd(unrelated)
  on.exit(setwd(previous_directory), add = TRUE)
  before_globals <- ls(.GlobalEnv, all.names = TRUE)
  before_libraries <- .libPaths()

  hospital_a <- rrp_producer_test_project(
    projects, "fictional-hospital-a", "encounter", alter_process = TRUE
  )
  dir.create(file.path(hospital_a, "extensions", "library"), recursive = TRUE)
  a_files <- rrp_producer_test_files(hospital_a)
  a_digests <- rrp_producer_test_digests(hospital_a)
  a_result <- rrp_execute_producer(
    catalog, hospital_a, "2026-02-10T06:00:00-06:00"
  )
  stopifnot(
    identical(a_result$operation_id, "rrp.execute-producer"),
    identical(a_result$status, "success"),
    identical(a_result$diagnostics, list()),
    identical(class(a_result$value), c("rrp_admitted_canonical_bundle", "list")),
    identical(a_result$value$project_id, "fictional-hospital-a"),
    nrow(a_result$value$domains$discharge_episode) == 1L,
    nrow(a_result$value$domains$terminal_event) == 1L,
    identical(rrp_operation_succeeded(a_result), TRUE),
    identical(rrp_producer_test_files(hospital_a), a_files),
    identical(rrp_producer_test_digests(hospital_a), a_digests),
    !dir.exists(file.path(hospital_a, "state")),
    dir.exists(file.path(hospital_a, "extensions", "library")),
    identical(list.files(file.path(hospital_a, "extensions")), "library"),
    identical(getwd(), normalizePath(unrelated, winslash = "/", mustWork = TRUE)),
    identical(.libPaths(), before_libraries),
    identical(ls(.GlobalEnv, all.names = TRUE), before_globals)
  )

  copy_parent <- file.path(suite_root, "copied-project")
  dir.create(copy_parent)
  stopifnot(file.copy(
    hospital_a, copy_parent, recursive = TRUE, copy.mode = FALSE
  ))
  copied_a <- file.path(copy_parent, basename(hospital_a))
  unlink(hospital_a, recursive = TRUE, force = TRUE)
  copied_result <- rrp_execute_producer(
    catalog, copied_a, "2026-02-10T06:00:00-06:00"
  )
  stopifnot(
    identical(copied_result$status, "success"),
    identical(
      unclass(copied_result$value),
      unclass(a_result$value)
    ),
    !dir.exists(file.path(copied_a, "state")),
    dir.exists(file.path(copied_a, "extensions", "library")),
    identical(list.files(file.path(copied_a, "extensions")), "library")
  )

  hospital_b <- rrp_producer_test_project(
    projects, "fictional-hospital-b", "split"
  )
  b_files <- rrp_producer_test_files(hospital_b)
  b_digests <- rrp_producer_test_digests(hospital_b)
  b_result <- rrp_execute_producer(
    catalog, hospital_b, "2026-02-10T12:00:00Z"
  )
  stopifnot(
    identical(b_result$status, "success"),
    identical(class(b_result$value), c("rrp_admitted_canonical_bundle", "list")),
    identical(b_result$value$project_id, "fictional-hospital-b"),
    nrow(b_result$value$domains$discharge_episode) == 1L,
    nrow(b_result$value$domains$terminal_event) == 1L,
    identical(rrp_producer_test_files(hospital_b), b_files),
    identical(rrp_producer_test_digests(hospital_b), b_digests),
    !dir.exists(file.path(hospital_b, "state")),
    !dir.exists(file.path(hospital_b, "extensions")),
    identical(getwd(), normalizePath(unrelated, winslash = "/", mustWork = TRUE)),
    identical(.libPaths(), before_libraries),
    identical(ls(.GlobalEnv, all.names = TRUE), before_globals)
  )

  for (code in c(
    "producer_unavailable", "producer_source_failed", "producer_mapping_failed"
  )) {
    root <- rrp_producer_test_project(
      projects, paste0("fixture-", gsub("_", "-", code)),
      failure_code = code
    )
    result <- rrp_execute_producer(catalog, root, "2026-02-10T12:00:00Z")
    rrp_producer_test_expect_failure(result, code)
  }

  thrown <- rrp_producer_test_project(
    projects, "fixture-thrown-condition", throw_condition = TRUE,
    alter_process = TRUE
  )
  thrown_result <- rrp_execute_producer(
    catalog, thrown, "2026-02-10T12:00:00Z"
  )
  rrp_producer_test_expect_failure(
    thrown_result, "producer_execution_failed",
    c("private source", "fictional", "credential", thrown)
  )
  stopifnot(
    identical(getwd(), normalizePath(unrelated, winslash = "/", mustWork = TRUE)),
    identical(.libPaths(), before_libraries)
  )

  malformed_cases <- list(
    unknown_field = "    result$unknown <- 'not-allowed'",
    missing_field = "    result$failure_code <- NULL; result <- result[names(result) != 'failure_code']",
    wrong_producer = "    result$producer_id <- 'different.producer'",
    wrong_implementation = "    result$implementation_id <- 'different.implementation'",
    wrong_mapping = "    result$mapping_id <- 'different.mapping'",
    wrong_profile = "    result$canonical_profile_id <- 'rrp.canonical-profile.other'",
    wrong_capabilities = "    result$capabilities <- result$capabilities[-2L]",
    wrong_as_of = "    result$canonical_as_of_time <- '2026-02-10T12:00:01Z'",
    unsupported_status = "    result$status <- 'unknown'",
    classed_result = "    class(result) <- 'custom-result'",
    succeeded_with_failure = "    result$failure_code <- 'producer_source_failed'",
    unsafe_candidate = "    result$candidate_bundle <- new.env(parent = emptyenv())"
  )
  for (name in names(malformed_cases)) {
    root <- rrp_producer_test_project(
      projects, paste0("malformed-", gsub("_", "-", name)),
      result_mutation = malformed_cases[[name]]
    )
    result <- rrp_execute_producer(catalog, root, "2026-02-10T12:00:00Z")
    rrp_producer_test_expect_failure(result, "invalid_producer_result")
  }

  candidate_cases <- list(
    producer = list(
      line = "    candidate$producer_id <- 'different.producer'",
      code = "producer_identity_mismatch"
    ),
    implementation = list(
      line = "    candidate$implementation_id <- 'different.implementation'",
      code = "implementation_identity_mismatch"
    ),
    mapping = list(
      line = "    candidate$mapping_id <- 'different.mapping'",
      code = "mapping_identity_mismatch"
    ),
    profile = list(
      line = "    candidate$canonical_profile_id <- 'rrp.canonical-profile.other'",
      code = "unsupported_canonical_profile"
    ),
    capabilities = list(
      line = "    candidate$capabilities <- candidate$capabilities[-2L]",
      code = "missing_capability"
    ),
    as_of = list(
      line = "    candidate$as_of_time <- '2026-02-10T12:00:01Z'",
      code = "as_of_time_mismatch"
    )
  )
  for (name in names(candidate_cases)) {
    fixture <- candidate_cases[[name]]
    root <- rrp_producer_test_project(
      projects, paste0("candidate-", gsub("_", "-", name)),
      candidate_mutation = fixture$line
    )
    result <- rrp_execute_producer(catalog, root, "2026-02-10T12:00:00Z")
    rrp_producer_test_expect_failure(result, fixture$code)
  }

  invalid_candidate <- rrp_producer_test_project(
    projects, "candidate-private-value",
    candidate_mutation = paste0(
      "    candidate$domains$discharge_episode$episode_id[[1L]] <- ",
      "'private patient value 778899'"
    )
  )
  invalid_candidate_result <- rrp_execute_producer(
    catalog, invalid_candidate, "2026-02-10T12:00:00Z"
  )
  rrp_producer_test_expect_failure(
    invalid_candidate_result, "invalid_domain_value",
    c("private patient value 778899", "778899")
  )

  invalid_time <- rrp_execute_producer(
    catalog, file.path(suite_root, "never-loaded"), "2026-02-10 12:00:00"
  )
  rrp_producer_test_expect_failure(invalid_time, "invalid_as_of_time")
  missing_project <- rrp_execute_producer(
    catalog, file.path(suite_root, "missing-project"),
    "2026-02-10T12:00:00Z"
  )
  rrp_producer_test_expect_failure(missing_project, "missing_project_root")

  stopifnot(
    identical(getwd(), normalizePath(unrelated, winslash = "/", mustWork = TRUE)),
    identical(.libPaths(), before_libraries),
    identical(ls(.GlobalEnv, all.names = TRUE), before_globals),
    !dir.exists(file.path(copied_a, "state")),
    !dir.exists(file.path(hospital_b, "state")),
    dir.exists(file.path(copied_a, "extensions", "library")),
    !dir.exists(file.path(hospital_b, "extensions")),
    !dir.exists(file.path(unrelated, ".git"))
  )
})

cat("rrpplatform producer-execution tests passed\n")
