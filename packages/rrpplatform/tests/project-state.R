library(rrpplatform)

state_internal <- function(name) {
  get(name, envir = asNamespace("rrpplatform"), inherits = FALSE)
}

state_write_record <- function(record, path) {
  dir.create(dirname(path), recursive = TRUE, showWarnings = FALSE)
  writeLines(paste0(names(record), ": ", unname(record)), path, useBytes = TRUE)
}

state_manifest_template <- c(
  "Record-Type: rrp-project",
  "Project-Contract-ID: rrp.project",
  "Project-Contract-Version: 0.3.0",
  "Project-ID: @@RRP_PROJECT_ID@@",
  "Project-Version: @@RRP_PROJECT_VERSION@@",
  "Project-Scope: one_health_system",
  "Supported-RRP-API-Version: 0.3.0",
  "Canonical-Profile-ID: rrp.canonical-profile.readmission",
  "Canonical-Profile-Version: 0.1.0",
  "Producer-ID: @@RRP_PRODUCER_ID@@",
  "Producer-Version: @@RRP_PROJECT_VERSION@@",
  "Provider-ID: @@RRP_PROVIDER_ID@@",
  "Provider-Version: @@RRP_PROJECT_VERSION@@",
  "Extension-Library-Path: extensions/library",
  "State-Path: state"
)

state_registration_template <- c(
  "rrp_register_project <- function(project_root) {",
  "  unavailable <- function(request) stop('selected callable executed', call. = FALSE)",
  "  capabilities <- list(list(capability_id = 'rrp.capability.discharge-episode', status = 'available'), list(capability_id = 'rrp.capability.terminal-event', status = 'available'))",
  "  producer <- function() list(component_id = '@@RRP_PRODUCER_ID@@', component_version = '@@RRP_PROJECT_VERSION@@', producer_api_id = 'rrp.producer-api', producer_api_version = '0.1.0', canonical_bundle_id = 'rrp.canonical-bundle', canonical_bundle_version = '0.1.0', canonical_profile_id = 'rrp.canonical-profile.readmission', canonical_profile_version = '0.1.0', implementation_id = '@@RRP_IMPLEMENTATION_ID@@', implementation_version = '@@RRP_PROJECT_VERSION@@', mapping_id = '@@RRP_MAPPING_ID@@', mapping_version = '@@RRP_PROJECT_VERSION@@', capabilities = capabilities, callable = unavailable)",
  "  provider <- function() list(component_id = '@@RRP_PROVIDER_ID@@', component_version = '@@RRP_PROJECT_VERSION@@', provider_api_id = 'rrp.provider-api', provider_api_version = '0.1.0', target_id = 'rrp.risk-target.readmission-remaining-30-day', target_version = '0.1.0', state_contract_id = 'rrp.episode-state', state_contract_version = '0.1.0', request_contract_id = 'rrp.risk-request', request_contract_version = '0.1.0', estimate_contract_id = 'rrp.risk-estimate', estimate_contract_version = '0.1.0', implementation_id = '@@RRP_IMPLEMENTATION_ID@@', implementation_version = '@@RRP_PROJECT_VERSION@@', model_id = NULL, model_version = NULL, callable = unavailable)",
  "  list(registration_contract_id = 'rrp.project-registration', registration_contract_version = '0.3.0', project_id = '@@RRP_PROJECT_ID@@', producers = list(producer()), providers = list(provider()))",
  "}"
)

state_software_root <- function(root) {
  resources <- list(
    list(
      id = "rrp.contract.resource-catalog", owner = "rrpplatform",
      path = "resources/resource-catalog-schema.dcf", format = "dcf",
      value = state_internal("rrp_resource_schema_contract")()
    ),
    list(
      id = "rrp.contract.diagnostic", owner = "rrpplatform",
      path = "resources/contracts/diagnostic.dcf", format = "dcf",
      value = c("Record-Type" = "contract")
    ),
    list(
      id = "rrp.contract.operation-result", owner = "rrpplatform",
      path = "resources/contracts/operation-result.dcf", format = "dcf",
      value = c("Record-Type" = "contract")
    ),
    list(
      id = "rrp.contract.project-manifest", owner = "rrpplatform",
      path = "resources/contracts/project-manifest.dcf", format = "dcf",
      value = state_internal("rrp_project_manifest_contract_expected")()
    ),
    list(
      id = "rrp.contract.project-registration", owner = "rrpplatform",
      path = "resources/contracts/project-registration.dcf", format = "dcf",
      value = state_internal("rrp_project_registration_contract_expected")()
    ),
    list(
      id = "rrp.contract.project-state", owner = "rrpplatform",
      path = "resources/contracts/state/project-state.dcf", format = "dcf",
      value = state_internal("rrp_project_state_contract_expected")()
    ),
    list(
      id = "rrp.contract.duckdb-history-adapter", owner = "rrpplatform",
      path = "resources/contracts/state/duckdb-history-adapter.dcf", format = "dcf",
      value = state_internal("rrp_duckdb_history_contract_expected")()
    ),
    list(
      id = "rrp.template.project-manifest", owner = "rrpplatform",
      path = "resources/templates/project/rrp-project.dcf", format = "dcf",
      value = state_manifest_template
    ),
    list(
      id = "rrp.template.project-registration", owner = "rrpplatform",
      path = "resources/templates/project/R/register.R", format = "r",
      value = state_registration_template
    )
  )
  canonical <- state_internal("rrp_canonical_contract_definitions")()
  resources <- c(resources, lapply(canonical, function(definition) list(
    id = definition$resource_id, owner = definition$owner,
    path = definition$path, format = "dcf", value = definition$expected
  )))
  runtime <- state_internal("rrp_runtime_contract_definitions")()
  resources <- c(resources, lapply(runtime, function(definition) list(
    id = definition$resource_id, owner = definition$owner,
    path = definition$path, format = "dcf", value = definition$expected
  )))
  for (resource in resources) {
    path <- file.path(root, resource$path)
    if (identical(resource$format, "dcf") && !is.null(names(resource$value))) {
      state_write_record(resource$value, path)
    } else {
      dir.create(dirname(path), recursive = TRUE, showWarnings = FALSE)
      writeLines(resource$value, path, useBytes = TRUE)
    }
  }
  header <- c(
    "Record-Type" = "catalog", "Catalog-ID" = "rrp.software-resources",
    "Catalog-Version" = "0.1.0", "Format-Version" = "1.0.0",
    "Product-ID" = "readmission-risk-pool-platform",
    "Development-Version" = "1.0.0-dev", "Status" = "development_unpublished"
  )
  entries <- lapply(resources, function(resource) c(
    "Record-Type" = "resource", "Resource-ID" = resource$id,
    "Resource-Class" = if (startsWith(resource$id, "rrp.template.")) {
      "template"
    } else "contract",
    "Owner-Package" = resource$owner, "Installed-Path" = resource$path,
    "Format" = resource$format
  ))
  records <- c(list(header), entries)
  lines <- unlist(lapply(seq_along(records), function(index) {
    rendered <- paste0(names(records[[index]]), ": ", unname(records[[index]]))
    if (index < length(records)) c(rendered, "") else rendered
  }), use.names = FALSE)
  writeLines(lines, file.path(root, "resources", "resource-catalog.dcf"),
    useBytes = TRUE)
  root
}

state_expect_failure <- function(result, operation_id, code) {
  stopifnot(
    identical(class(result), c("rrp_operation_result", "list")),
    identical(result$operation_id, operation_id),
    identical(result$status, "failure"), is.null(result$value),
    length(result$diagnostics) == 1L,
    identical(result$diagnostics[[1L]]$code, code),
    identical(result$diagnostics[[1L]]$severity, "error"),
    !grepl("[/\\]", result$diagnostics[[1L]]$message)
  )
  invisible(result)
}

state_expect_condition <- function(callback, code) {
  condition <- tryCatch({ callback(); NULL }, error = identity)
  stopifnot(
    inherits(condition, "rrp_state_error"), identical(condition$code, code),
    identical(condition$call, NULL), !grepl("[/\\]", condition$message)
  )
  invisible(condition)
}

state_copy_project <- function(project, parent) {
  dir.create(parent, recursive = TRUE, showWarnings = FALSE)
  stopifnot(file.copy(project, parent, recursive = TRUE, copy.mode = FALSE))
  file.path(parent, basename(project))
}

state_scope <- function(state_id, key, episodes, project_id = "state-project") {
  rrpruntime::rrp_new_operational_scope(list(
    operation_key = key, state_id = state_id,
    product_id = "readmission-risk-pool-platform",
    development_version = "1.0.0-dev", rrp_api_version = "0.3.0",
    project_api_id = "rrp.project-api", project_api_version = "0.3.0",
    project_id = project_id, project_version = "1.0.0",
    bundle_contract_id = "rrp.canonical-bundle",
    bundle_contract_version = "0.1.0",
    bundle_instance_id = paste0(
      "fictional.bundle.", gsub("_", "-", key, fixed = TRUE)
    ),
    canonical_profile_id = "rrp.canonical-profile.readmission",
    canonical_profile_version = "0.1.0",
    producer_id = paste0(project_id, ".producer"), producer_version = "1.0.0",
    producer_implementation_id = paste0(project_id, ".implementation"),
    producer_implementation_version = "1.0.0",
    mapping_id = paste0(project_id, ".mapping"), mapping_version = "1.0.0",
    target_id = "rrp.risk-target.readmission-remaining-30-day",
    target_version = "0.1.0", analytical_time = "2026-01-20T12:00:00Z",
    created_at = "2026-01-20T12:01:00Z"
  ), episodes)
}

state_disposition <- function(
  scope, episode, kind = "initial", related = NULL, key = NULL,
  terminal_time = "2026-01-20T12:02:00Z"
) {
  rrpruntime::rrp_new_episode_disposition(scope, list(
    analytical_kind = kind, related_analytical_run_id = related,
    analytical_key = key, episode_id = episode,
    patient_id = paste0("fictional-patient-", episode),
    target_id = scope$target_id, target_version = scope$target_version,
    analytical_time = scope$analytical_time, outcome = "ineligible",
    outcome_code = "episode_before_discharge", eligibility_status = "ineligible",
    state = NULL, request = NULL, provider_id = NULL, provider_version = NULL,
    implementation_id = NULL, implementation_version = NULL,
    model_id = NULL, model_version = NULL, provider_status = "not_invoked",
    estimate = NULL, terminal_time = terminal_time
  ))
}

state_action <- function(target, type = "invalidate", replacement = NULL) {
  rrpruntime::rrp_new_history_action(list(
    target_kind = if (inherits(target, "rrp_operational_scope")) {
      "operational_scope"
    } else "analytical_run",
    target_id = if (inherits(target, "rrp_operational_scope")) {
      target$operation_run_id
    } else target$analytical_run_id,
    target_operation_run_id = target$operation_run_id,
    action_type = type, effective_time = "2026-01-20T12:04:00Z",
    reason_code = if (inherits(target, "rrp_operational_scope")) {
      "incorrect_scope"
    } else "superseded_result",
    replacement_operation_run_id = if (is.null(replacement)) NULL else
      replacement$operation_run_id,
    replacement_analytical_run_id = if (is.null(replacement) ||
      inherits(replacement, "rrp_operational_scope")) NULL else
      replacement$analytical_run_id,
    actor_category = "operator"
  ))
}

state_adapter <- function(catalog, project, failure_stage = NULL) {
  state_internal("rrp_state_history_port")(catalog, project, failure_stage)
}

state_sort_dispositions <- function(values) {
  if (length(values) < 2L) return(values)
  values[order(
    vapply(values, `[[`, character(1L), "analytical_time"),
    vapply(values, `[[`, character(1L), "operation_run_id"),
    vapply(values, `[[`, character(1L), "analytical_run_id"),
    method = "radix"
  )]
}

state_sort_actions <- function(values) {
  if (length(values) < 2L) return(values)
  values[order(
    vapply(values, `[[`, character(1L), "effective_time"),
    vapply(values, `[[`, character(1L), "action_id"), method = "radix"
  )]
}

state_memory_port <- function() {
  store <- new.env(parent = emptyenv())
  store$scopes <- list()
  store$dispositions <- list()
  store$actions <- list()
  copy <- function(value) unserialize(serialize(value, NULL))
  add <- function(collection, record, field) {
    values <- store[[collection]]
    ids <- vapply(values, `[[`, character(1L), field)
    at <- which(ids == record[[field]])
    if (!length(at)) {
      values[[length(values) + 1L]] <- copy(record)
      store[[collection]] <- values
    } else if (!identical(values[[at[[1L]]]], record)) {
      stop("memory identity conflict", call. = FALSE)
    }
    copy(record)
  }
  raw <- function(operation_run_id) list(
    scopes = copy(Filter(function(value) {
      identical(value$operation_run_id, operation_run_id)
    }, store$scopes)),
    dispositions = copy(state_sort_dispositions(Filter(function(value) {
      identical(value$operation_run_id, operation_run_id)
    }, store$dispositions))),
    actions = copy(state_sort_actions(Filter(function(value) {
      identical(value$target_operation_run_id, operation_run_id) ||
        identical(value$replacement_operation_run_id, operation_run_id)
    }, store$actions)))
  )
  methods <- list(
    append_scope = function(value) add("scopes", value, "operation_run_id"),
    append_disposition = function(value) {
      add("dispositions", value, "analytical_run_id")
    },
    append_action = function(value) add("actions", value, "action_id"),
    append_restatement = function(replacement, action) {
      collection <- if (inherits(replacement, "rrp_operational_scope")) {
        "scopes"
      } else "dispositions"
      field <- if (identical(collection, "scopes")) {
        "operation_run_id"
      } else "analytical_run_id"
      add(collection, replacement, field)
      add("actions", action, "action_id")
      copy(list(replacement = replacement, action = action))
    },
    read_scope_history = raw,
    read_episode_history = function(episode_id, target_id, history_cutoff) {
      selected <- Filter(function(value) {
        identical(value$episode_id, episode_id) &&
          identical(value$target_id, target_id)
      }, store$dispositions)
      operations <- unique(vapply(
        selected, `[[`, character(1L), "operation_run_id"
      ))
      if (!length(operations)) return(list(
        scopes = list(), dispositions = list(), actions = list()
      ))
      raw(operations[[1L]])
    }
  )
  rrpruntime::rrp_new_history_port(list(
    adapter_id = "rrp.test.state-memory", adapter_version = "0.1.0",
    contract_id = "rrp.history.port", contract_version = "0.1.0",
    capabilities = structure(as.list(rep(TRUE, 8L)), names = c(
      "atomic_scope_append", "atomic_episode_append",
      "atomic_restatement_append", "identical_append_idempotency",
      "conflicting_identity_rejection", "immutable_raw_retention",
      "bounded_raw_reads", "detached_reads"
    )), methods = methods
  ))
}

local({
  suite <- tempfile("rrp-project-state-")
  dir.create(suite)
  on.exit(unlink(suite, recursive = TRUE, force = TRUE), add = TRUE)
  software <- state_software_root(file.path(suite, "software"))
  catalog <- rrp_open_resource_catalog(software)
  project <- file.path(suite, "state-project")
  stopifnot(rrp_operation_succeeded(rrp_initialize_project(
    catalog, project, "state-project", "1.0.0"
  )))

  absent <- rrp_inspect_project_state(catalog, project)
  doctor_absent <- rrp_validate_project(catalog, project)
  stopifnot(
    rrp_operation_succeeded(absent),
    identical(absent$value$state_status, "not_initialized"),
    is.null(absent$value$state_id),
    identical(absent$diagnostics[[1L]]$code, "project_state_not_initialized"),
    identical(doctor_absent$value$state_status, "not_initialized"),
    !dir.exists(file.path(project, "state"))
  )

  initialized <- rrp_initialize_project_state(catalog, project)
  stopifnot(
    rrp_operation_succeeded(initialized), isTRUE(initialized$value$created),
    identical(initialized$value$state_status, "compatible"),
    grepl("^rrp[.]state[.][0-9a-f]{32}$", initialized$value$state_id),
    identical(sort(list.files(file.path(project, "state"))),
      c("history.duckdb", "state.dcf"))
  )
  state_files <- file.path(project, "state", c("history.duckdb", "state.dcf"))
  before <- list(md5 = tools::md5sum(state_files), size = file.info(state_files)$size)
  repeated <- rrp_initialize_project_state(catalog, project)
  inspected <- rrp_inspect_project_state(catalog, project)
  doctor <- rrp_validate_project(catalog, project)
  stopifnot(
    rrp_operation_succeeded(repeated), identical(repeated$value$created, FALSE),
    identical(repeated$value$state_id, initialized$value$state_id),
    identical(inspected$value$state_status, "compatible"),
    identical(inspected$value$state_id, initialized$value$state_id),
    identical(doctor$value$state_status, "compatible"),
    identical(doctor$diagnostics, list()),
    identical(tools::md5sum(state_files), before$md5),
    identical(file.info(state_files)$size, before$size)
  )

  # Exact logical roundtrip, incomplete/complete progress, and reopen.
  episodes <- c("episode-001", "episode-002")
  scope <- state_scope(initialized$value$state_id, "operation-001", episodes)
  first <- state_disposition(scope, episodes[[1L]])
  second <- state_disposition(scope, episodes[[2L]])
  port <- state_adapter(catalog, project)
  rrpruntime::rrp_history_append_scope(port, scope)
  rrpruntime::rrp_history_append_disposition(port, first)
  partial <- rrpruntime::rrp_history_read_scope(port, scope$operation_run_id)
  stopifnot(
    identical(partial$scope, scope), identical(partial$dispositions, list(first)),
    identical(partial$progress$dispositioned_episode_count, 1L),
    identical(partial$progress$complete, FALSE)
  )
  rrpruntime::rrp_history_append_disposition(port, second)
  complete <- rrpruntime::rrp_history_read_scope(port, scope$operation_run_id)
  stopifnot(
    identical(complete$progress$complete, TRUE),
    identical(complete$dispositions, state_sort_dispositions(list(first, second)))
  )
  rm(port)
  gc()
  reopened <- state_adapter(catalog, project)
  after_reopen <- rrpruntime::rrp_history_read_scope(
    reopened, scope$operation_run_id
  )
  stopifnot(identical(after_reopen, complete))
  after_reopen$dispositions[[1L]]$outcome_code <- "mutated"
  stopifnot(identical(
    rrpruntime::rrp_history_read_scope(reopened, scope$operation_run_id), complete
  ))

  replacement <- state_disposition(
    scope, episodes[[1L]], kind = "restatement",
    related = first$analytical_run_id, key = "correction-001",
    terminal_time = "2026-01-20T12:03:00Z"
  )
  restatement <- state_action(first, "restate", replacement)
  rrpruntime::rrp_history_append_restatement(
    reopened, replacement, restatement
  )
  episode_history <- rrpruntime::rrp_history_read_episode(
    reopened, episodes[[1L]], scope$target_id, "2026-01-20T13:00:00Z"
  )
  stopifnot(
    identical(episode_history$scopes, list(scope)),
    identical(episode_history$dispositions,
      state_sort_dispositions(list(first, replacement))),
    identical(episode_history$actions, list(restatement)),
    identical(rrpruntime::rrp_history_read_current(
      reopened, episodes[[1L]], scope$target_id,
      "2026-01-20T12:00:00Z", "2026-01-20T13:00:00Z"
    ), replacement)
  )
  memory <- state_memory_port()
  rrpruntime::rrp_history_append_scope(memory, scope)
  rrpruntime::rrp_history_append_disposition(memory, first)
  rrpruntime::rrp_history_append_disposition(memory, second)
  rrpruntime::rrp_history_append_restatement(
    memory, replacement, restatement
  )
  stopifnot(
    identical(
      rrpruntime::rrp_history_read_scope(memory, scope$operation_run_id),
      rrpruntime::rrp_history_read_scope(reopened, scope$operation_run_id)
    ),
    identical(
      rrpruntime::rrp_history_read_episode(
        memory, episodes[[1L]], scope$target_id, "2026-01-20T13:00:00Z"
      ),
      rrpruntime::rrp_history_read_episode(
        reopened, episodes[[1L]], scope$target_id, "2026-01-20T13:00:00Z"
      )
    ),
    identical(
      rrpruntime::rrp_history_read_current(
        memory, episodes[[1L]], scope$target_id,
        "2026-01-20T12:00:00Z", "2026-01-20T13:00:00Z"
      ),
      rrpruntime::rrp_history_read_current(
        reopened, episodes[[1L]], scope$target_id,
        "2026-01-20T12:00:00Z", "2026-01-20T13:00:00Z"
      )
    )
  )
  conflict_values <- unclass(scope)
  class(conflict_values) <- NULL
  conflict <- scope
  conflict$bundle_instance_id <- "fictional.bundle.conflict"
  condition <- tryCatch({
    rrpruntime::rrp_history_append_scope(reopened, conflict); NULL
  }, error = identity)
  stopifnot(inherits(condition, "rrp_history_error"),
    identical(condition$code, "invalid_scope") ||
      identical(condition$code, "identity_conflict"))

  # Copied state is path-independent; copied source without state is uninitialized.
  copy <- state_copy_project(project, file.path(suite, "copy-parent"))
  copy_inspection <- rrp_inspect_project_state(catalog, copy)
  copy_port <- state_adapter(catalog, copy)
  stopifnot(
    identical(copy_inspection$value$state_id, initialized$value$state_id),
    identical(rrpruntime::rrp_history_read_scope(
      copy_port, scope$operation_run_id
    )$scope, scope)
  )
  no_state <- state_copy_project(project, file.path(suite, "no-state-parent"))
  unlink(file.path(no_state, "state"), recursive = TRUE, force = TRUE)
  stopifnot(identical(
    rrp_inspect_project_state(catalog, no_state)$value$state_status,
    "not_initialized"
  ))

  other <- file.path(suite, "other-project")
  stopifnot(rrp_operation_succeeded(rrp_initialize_project(
    catalog, other, "other-project", "1.0.0"
  )))
  stopifnot(file.copy(file.path(project, "state"), other, recursive = TRUE))
  state_expect_failure(
    rrp_inspect_project_state(catalog, other),
    "rrp.inspect-project-state", "state_incompatible"
  )

  # Partial, unknown, malformed, linked, and corrupt state fail closed.
  invalid_case <- function(label) state_copy_project(
    project, file.path(suite, paste0("invalid-", label))
  )
  partial_project <- invalid_case("partial")
  unlink(file.path(partial_project, "state", "history.duckdb"), force = TRUE)
  state_expect_failure(
    rrp_inspect_project_state(catalog, partial_project),
    "rrp.inspect-project-state", "state_invalid"
  )
  unknown_project <- invalid_case("unknown")
  writeLines("unknown", file.path(unknown_project, "state", "unknown.txt"))
  state_expect_failure(
    rrp_inspect_project_state(catalog, unknown_project),
    "rrp.inspect-project-state", "state_invalid"
  )
  incompatible_project <- invalid_case("metadata")
  metadata_path <- file.path(incompatible_project, "state", "state.dcf")
  metadata_lines <- readLines(metadata_path, warn = FALSE)
  metadata_lines <- sub(
    "^Adapter-Version:.*$", "Adapter-Version: 9.9.9", metadata_lines
  )
  writeLines(metadata_lines, metadata_path, useBytes = TRUE)
  state_expect_failure(
    rrp_inspect_project_state(catalog, incompatible_project),
    "rrp.inspect-project-state", "state_incompatible"
  )
  compatibility_fields <- c(
    "Record-Type", "State-Contract-ID", "State-Contract-Version",
    "Format-Version", "Product-ID", "Development-Version", "Project-ID",
    "Supported-RRP-API-Version", "Project-API-ID", "Project-API-Version",
    "Target-ID", "Target-Version", "History-Scope-Contract-ID",
    "History-Scope-Contract-Version", "History-Disposition-Contract-ID",
    "History-Disposition-Contract-Version", "History-Action-Contract-ID",
    "History-Action-Contract-Version", "History-Port-Contract-ID",
    "History-Port-Contract-Version", "Logical-History-Format-Version",
    "Adapter-ID", "Physical-Schema-Version", "Payload-Encoding-Version",
    "Inventory"
  )
  compatibility_context <- rrp_load_project(catalog, project)
  compatibility_contracts <- state_internal("rrp_state_contracts")(catalog)
  compatibility_metadata <- state_internal("rrp_state_read_metadata")(
    file.path(project, "state", "state.dcf")
  )
  for (field in compatibility_fields) {
    candidate <- compatibility_metadata
    candidate[[field]] <- "unsupported"
    state_expect_condition(function() state_internal(
      "rrp_state_validate_metadata"
    )(candidate, compatibility_context, compatibility_contracts),
    "state_incompatible")
  }
  embedded_project <- invalid_case("embedded-metadata")
  embedded_path <- file.path(embedded_project, "state", "history.duckdb")
  embedded_connection <- DBI::dbConnect(duckdb::duckdb(embedded_path))
  DBI::dbExecute(
    embedded_connection,
    "UPDATE rrp_state_metadata SET state_id = 'rrp.state.00000000000000000000000000000000'"
  )
  DBI::dbDisconnect(embedded_connection, shutdown = TRUE)
  embedded_result <- rrp_inspect_project_state(catalog, embedded_project)
  state_expect_failure(
    embedded_result,
    "rrp.inspect-project-state", "state_incompatible"
  )
  schema_project <- invalid_case("schema")
  schema_path <- file.path(schema_project, "state", "history.duckdb")
  schema_connection <- DBI::dbConnect(duckdb::duckdb(schema_path))
  DBI::dbExecute(schema_connection, "CREATE TABLE unexpected_table (value INTEGER)")
  DBI::dbDisconnect(schema_connection, shutdown = TRUE)
  state_expect_failure(
    rrp_inspect_project_state(catalog, schema_project),
    "rrp.inspect-project-state", "state_incompatible"
  )
  corrupt_project <- invalid_case("corrupt")
  writeLines("not a database", file.path(
    corrupt_project, "state", "history.duckdb"
  ))
  corrupt <- rrp_inspect_project_state(catalog, corrupt_project)
  stopifnot(identical(corrupt$status, "failure"),
    identical(corrupt$diagnostics[[1L]]$code, "state_corrupt"))

  linked_project <- state_copy_project(project, file.path(suite, "linked-parent"))
  unlink(file.path(linked_project, "state"), recursive = TRUE, force = TRUE)
  external <- file.path(suite, "external-state")
  dir.create(external)
  if (isTRUE(file.symlink(external, file.path(linked_project, "state")))) {
    state_expect_failure(
      rrp_inspect_project_state(catalog, linked_project),
      "rrp.inspect-project-state", "invalid_state_location"
    )
  }

  # Nested safe paths are created deliberately; unsafe manifest paths remain rejected.
  nested <- file.path(suite, "nested-project")
  stopifnot(rrp_operation_succeeded(rrp_initialize_project(
    catalog, nested, "nested-project", "1.0.0"
  )))
  nested_manifest <- file.path(nested, "rrp-project.dcf")
  nested_lines <- readLines(nested_manifest, warn = FALSE)
  nested_lines <- sub("^State-Path:.*$", "State-Path: local/state", nested_lines)
  writeLines(nested_lines, nested_manifest, useBytes = TRUE)
  stopifnot(rrp_operation_succeeded(rrp_initialize_project_state(catalog, nested)),
    dir.exists(file.path(nested, "local", "state")))

  # Failed staged initialization removes only attempt-owned output.
  for (stage in c(
    "after_metadata", "after_database", "before_promotion", "after_promotion"
  )) {
    candidate <- file.path(suite, paste0("staging-", stage))
    stopifnot(rrp_operation_succeeded(rrp_initialize_project(
      catalog, candidate, paste0("staging-", gsub("_", "-", stage)), "1.0.0"
    )))
    state_expect_condition(function() state_internal("rrp_state_initialize")(
      catalog, candidate, failure_stage = stage
    ), "injected_interruption")
    stopifnot(
      !dir.exists(file.path(candidate, "state")),
      !any(startsWith(list.files(candidate, all.files = TRUE, no.. = TRUE),
        ".rrp-state-staging-"))
    )
  }

  # Transaction interruptions expose none before commit and durable facts after it.
  transaction_project <- state_copy_project(
    no_state, file.path(suite, "transaction-parent")
  )
  stopifnot(rrp_operation_succeeded(rrp_initialize_project_state(
    catalog, transaction_project
  )))
  transaction_state <- rrp_inspect_project_state(
    catalog, transaction_project
  )$value$state_id
  for (stage in c("before_transaction", "after_scope_insert", "before_commit")) {
    candidate <- state_scope(
      transaction_state, paste0("scope-", stage), character(),
      project_id = "state-project"
    )
    state_expect_condition(function() rrpruntime::rrp_history_append_scope(
      state_adapter(catalog, transaction_project, stage), candidate
    ), "injected_interruption")
    raw <- state_adapter(catalog, transaction_project)$adapter$methods$
      read_scope_history(candidate$operation_run_id)
    stopifnot(length(raw$scopes) == 0L)
  }
  committed_scope <- state_scope(
    transaction_state, "scope-after-commit", character(),
    project_id = "state-project"
  )
  state_expect_condition(function() rrpruntime::rrp_history_append_scope(
    state_adapter(catalog, transaction_project, "after_commit"), committed_scope
  ), "injected_interruption")
  normal <- state_adapter(catalog, transaction_project)
  stopifnot(identical(
    rrpruntime::rrp_history_append_scope(normal, committed_scope),
    invisible(committed_scope)
  ))
  stopifnot(identical(rrpruntime::rrp_history_read_scope(
    normal, committed_scope$operation_run_id
  )$scope, committed_scope))

  disposition_scope <- state_scope(
    transaction_state, "disposition-boundaries", "episode-boundary",
    project_id = "state-project"
  )
  rrpruntime::rrp_history_append_scope(normal, disposition_scope)
  disposition <- state_disposition(disposition_scope, "episode-boundary")
  state_expect_condition(function() rrpruntime::rrp_history_append_disposition(
    state_adapter(catalog, transaction_project, "after_disposition_insert"),
    disposition
  ), "injected_interruption")
  stopifnot(length(rrpruntime::rrp_history_read_scope(
    normal, disposition_scope$operation_run_id
  )$dispositions) == 0L)
  state_expect_condition(function() rrpruntime::rrp_history_append_disposition(
    state_adapter(catalog, transaction_project, "after_commit"), disposition
  ), "injected_interruption")
  stopifnot(identical(
    rrpruntime::rrp_history_append_disposition(normal, disposition),
    invisible(disposition)
  ))

  action <- state_action(disposition)
  state_expect_condition(function() rrpruntime::rrp_history_append_invalidation(
    state_adapter(catalog, transaction_project, "after_action_insert"), action
  ), "injected_interruption")
  stopifnot(length(rrpruntime::rrp_history_read_scope(
    normal, disposition_scope$operation_run_id
  )$actions) == 0L)
  rrpruntime::rrp_history_append_invalidation(normal, action)

  restate_scope <- state_scope(
    transaction_state, "restate-boundaries", "episode-restate",
    project_id = "state-project"
  )
  rrpruntime::rrp_history_append_scope(normal, restate_scope)
  original <- state_disposition(restate_scope, "episode-restate")
  rrpruntime::rrp_history_append_disposition(normal, original)
  for (stage in c("after_replacement_insert", "after_action_insert", "before_commit")) {
    replacement_candidate <- state_disposition(
      restate_scope, "episode-restate", kind = "restatement",
      related = original$analytical_run_id, key = paste0("key-", stage),
      terminal_time = "2026-01-20T12:03:00Z"
    )
    action_candidate <- state_action(original, "restate", replacement_candidate)
    state_expect_condition(function() rrpruntime::rrp_history_append_restatement(
      state_adapter(catalog, transaction_project, stage),
      replacement_candidate, action_candidate
    ), "injected_interruption")
    raw <- rrpruntime::rrp_history_read_scope(normal, restate_scope$operation_run_id)
    stopifnot(
      !replacement_candidate$analytical_run_id %in% vapply(
        raw$dispositions, `[[`, character(1L), "analytical_run_id"
      ),
      !action_candidate$action_id %in% vapply(
        raw$actions, `[[`, character(1L), "action_id"
      )
    )
  }
  committed_replacement <- state_disposition(
    restate_scope, "episode-restate", kind = "restatement",
    related = original$analytical_run_id, key = "key-after-commit",
    terminal_time = "2026-01-20T12:03:00Z"
  )
  committed_action <- state_action(original, "restate", committed_replacement)
  state_expect_condition(function() rrpruntime::rrp_history_append_restatement(
    state_adapter(catalog, transaction_project, "after_commit"),
    committed_replacement, committed_action
  ), "injected_interruption")
  stopifnot(identical(
    rrpruntime::rrp_history_append_restatement(
      normal, committed_replacement, committed_action
    ),
    invisible(list(
      replacement = committed_replacement, action = committed_action
    ))
  ))

  # Explicit unrelated working directory and missing-state protected adapter failure.
  previous <- getwd()
  unrelated <- file.path(suite, "unrelated-working-directory")
  dir.create(unrelated)
  setwd(unrelated)
  on.exit(setwd(previous), add = TRUE)
  stopifnot(rrp_operation_succeeded(rrp_inspect_project_state(catalog, project)))
  state_expect_condition(function() state_adapter(catalog, no_state),
    "state_uninitialized")

  # A separate process reopens the copied state without repository or Git context.
  package_libraries <- paste(vapply(
    .libPaths(), encodeString, character(1L), quote = "\""
  ), collapse = ", ")
  reopen_script <- file.path(suite, "reopen-state.R")
  writeLines(c(
    paste0(".libPaths(c(", package_libraries, "))"),
    "args <- commandArgs(trailingOnly = TRUE)",
    "library(rrpplatform)",
    "catalog <- rrp_open_resource_catalog(args[[1L]])",
    "result <- rrp_inspect_project_state(catalog, args[[2L]])",
    "stopifnot(rrp_operation_succeeded(result))",
    "stopifnot(identical(result$value$state_status, 'compatible'))"
  ), reopen_script, useBytes = TRUE)
  reopen_output <- file.path(suite, "reopen-output")
  status <- system2(
    file.path(R.home("bin"), "Rscript"),
    c("--vanilla", shQuote(reopen_script), shQuote(software), shQuote(copy)),
    stdout = reopen_output, stderr = reopen_output, env = "R_TESTS="
  )
  if (!identical(status, 0L)) {
    stop(paste(
      "Separate-process state reopen failed:",
      paste(readLines(reopen_output, warn = FALSE), collapse = "\n")
    ), call. = FALSE)
  }

  # A distinct process holding the local database proves bounded writer exclusion.
  if (identical(.Platform$OS.type, "unix")) {
    holder_script <- file.path(suite, "hold-duckdb.R")
    marker <- file.path(suite, "holder-ready")
    holder_output <- file.path(suite, "holder-output")
    writeLines(c(
      paste0(".libPaths(c(", package_libraries, "))"),
      "args <- commandArgs(trailingOnly = TRUE)",
      "connection <- DBI::dbConnect(duckdb::duckdb(args[[1L]]))",
      "writeLines(as.character(Sys.getpid()), args[[2L]])",
      "Sys.sleep(30)",
      "DBI::dbDisconnect(connection, shutdown = TRUE)"
    ), holder_script, useBytes = TRUE)
    system2(
      file.path(R.home("bin"), "Rscript"),
      c("--vanilla", shQuote(holder_script),
        shQuote(file.path(project, "state", "history.duckdb")), shQuote(marker)),
      stdout = holder_output, stderr = holder_output, wait = FALSE,
      env = "R_TESTS="
    )
    for (attempt in seq_len(400L)) {
      if (file.exists(marker)) break
      Sys.sleep(0.05)
    }
    stopifnot(file.exists(marker))
    holder_pid <- as.integer(readLines(marker, warn = FALSE)[[1L]])
    on.exit(try(tools::pskill(holder_pid), silent = TRUE), add = TRUE)
    state_expect_condition(function() state_adapter(catalog, project),
      "state_unavailable")
    try(tools::pskill(holder_pid), silent = TRUE)
  }
})
