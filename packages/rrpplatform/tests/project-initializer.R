library(rrpplatform)

rrp_init_internal <- function(name) {
  get(name, envir = asNamespace("rrpplatform"), inherits = FALSE)
}

rrp_init_write_record <- function(record, path) {
  dir.create(dirname(path), recursive = TRUE, showWarnings = FALSE)
  writeLines(paste0(names(record), ": ", unname(record)), path, useBytes = TRUE)
}

rrp_init_manifest_template <- c(
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

rrp_init_registration_template <- c(
  "rrp_register_project <- function(project_root) {",
  "  rrpplatform::rrp_register_authored_project(project_root)",
  "}"
)

rrp_init_authoring_template <- c(
  "Record-Type: rrp-project-authoring",
  "Authoring-Contract-ID: rrp.project-authoring",
  "Authoring-Contract-Version: 0.1.0",
  "Producer-Implementation-ID: @@RRP_PRODUCER_IMPLEMENTATION_ID@@",
  "Producer-Implementation-Version: @@RRP_PROJECT_VERSION@@",
  "Mapping-ID: @@RRP_MAPPING_ID@@",
  "Mapping-Version: @@RRP_PROJECT_VERSION@@",
  "Provider-Implementation-ID: @@RRP_PROVIDER_IMPLEMENTATION_ID@@",
  "Provider-Implementation-Version: @@RRP_PROJECT_VERSION@@",
  "Extension-Packages: none"
)

rrp_init_producer_template <- c(
  "rrp_produce_canonical <- function(project_root, as_of_time) {",
  "  Sys.setenv(RRP_INIT_SELECTED_CALLED = 'yes')",
  "  rrpplatform::rrp_authoring_failure('producer_unavailable')",
  "}"
)

rrp_init_provider_template <- c(
  "# The request has exact class c('rrp_risk_request', 'list') and 19 fields.",
  "# Return one finite unclassed double probability in [0,1].",
  "rrp_calculate_risk <- function(project_root, request) {",
  "  Sys.setenv(RRP_INIT_SELECTED_CALLED = 'yes')",
  "  rrpplatform::rrp_authoring_failure('provider_unavailable')",
  "}"
)

rrp_init_readme_template <- c(
  "# RRP hospital project",
  "Edit `R/produce-canonical.R` and `R/calculate-risk.R`.",
  "Resources: `rrp.documentation.project-authoring-guide` and",
  "`rrp.documentation.provider-request-reference`."
)

rrp_init_authoring_guide <- c(
  "# Project Authoring Guide",
  "The standard scaffold has exactly six files, including `rrp-authoring.dcf`,",
  "`R/produce-canonical.R`, and `R/calculate-risk.R`.",
  "Increment 8.B fictional source behavior is not part of this capability."
)

rrp_init_provider_reference <- c(
  "# Provider Request Reference",
  "The provider request has exactly 19 fields and class",
  "`c(\"rrp_risk_request\", \"list\")`."
)

rrp_init_software_root <- function(root) {
  schema <- rrp_init_internal("rrp_resource_schema_contract")()
  rrp_init_write_record(
    schema, file.path(root, "resources", "resource-catalog-schema.dcf")
  )
  manifest_contract <- rrp_init_internal(
    "rrp_project_manifest_contract_expected"
  )()
  registration_contract <- rrp_init_internal(
    "rrp_project_registration_contract_expected"
  )()
  authoring_contract <- rrp_init_internal(
    "rrp_authoring_contract_expected"
  )()
  canonical_definitions <- rrp_init_internal(
    "rrp_canonical_contract_definitions"
  )()
  runtime_definitions <- rrp_init_internal(
    "rrp_runtime_contract_definitions"
  )()
  rrp_init_write_record(
    manifest_contract,
    file.path(root, "resources", "contracts", "project-manifest.dcf")
  )
  for (definition in canonical_definitions) {
    rrp_init_write_record(
      definition$expected, file.path(root, definition$path)
    )
  }
  for (definition in runtime_definitions) {
    rrp_init_write_record(
      definition$expected, file.path(root, definition$path)
    )
  }
  rrp_init_write_record(
    registration_contract,
    file.path(root, "resources", "contracts", "project-registration.dcf")
  )
  rrp_init_write_record(
    authoring_contract,
    file.path(root, "resources", "contracts", "project-authoring.dcf")
  )
  rrp_init_write_record(
    c("Record-Type" = "contract"),
    file.path(root, "resources", "contracts", "diagnostic.dcf")
  )
  rrp_init_write_record(
    c("Record-Type" = "contract"),
    file.path(root, "resources", "contracts", "operation-result.dcf")
  )
  manifest_template_path <- file.path(
    root, "resources", "templates", "project", "rrp-project.dcf"
  )
  dir.create(dirname(manifest_template_path), recursive = TRUE, showWarnings = FALSE)
  writeLines(
    rrp_init_manifest_template,
    manifest_template_path,
    useBytes = TRUE
  )
  registration_path <- file.path(
    root, "resources", "templates", "project", "R", "register.R"
  )
  dir.create(dirname(registration_path), recursive = TRUE, showWarnings = FALSE)
  writeLines(rrp_init_registration_template, registration_path, useBytes = TRUE)
  project_template_root <- file.path(
    root, "resources", "templates", "project"
  )
  writeLines(
    rrp_init_authoring_template,
    file.path(project_template_root, "rrp-authoring.dcf"), useBytes = TRUE
  )
  writeLines(
    rrp_init_producer_template,
    file.path(project_template_root, "R", "produce-canonical.R"),
    useBytes = TRUE
  )
  writeLines(
    rrp_init_provider_template,
    file.path(project_template_root, "R", "calculate-risk.R"),
    useBytes = TRUE
  )
  writeLines(
    rrp_init_readme_template,
    file.path(project_template_root, "README.md"), useBytes = TRUE
  )
  documentation_root <- file.path(root, "resources", "documentation")
  dir.create(documentation_root, recursive = TRUE, showWarnings = FALSE)
  writeLines(
    rrp_init_authoring_guide,
    file.path(documentation_root, "project-authoring-guide.md"),
    useBytes = TRUE
  )
  writeLines(
    rrp_init_provider_reference,
    file.path(documentation_root, "provider-request-reference.md"),
    useBytes = TRUE
  )

  entries <- list(
    c("rrp.contract.resource-catalog", "contract", "resources/resource-catalog-schema.dcf", "dcf", "rrpplatform"),
    c("rrp.contract.diagnostic", "contract", "resources/contracts/diagnostic.dcf", "dcf", "rrpplatform"),
    c("rrp.contract.operation-result", "contract", "resources/contracts/operation-result.dcf", "dcf", "rrpplatform"),
    c("rrp.contract.project-manifest", "contract", "resources/contracts/project-manifest.dcf", "dcf", "rrpplatform"),
    c("rrp.contract.project-registration", "contract", "resources/contracts/project-registration.dcf", "dcf", "rrpplatform"),
    c("rrp.contract.project-authoring", "contract", "resources/contracts/project-authoring.dcf", "dcf", "rrpplatform"),
    c("rrp.template.project-manifest", "template", "resources/templates/project/rrp-project.dcf", "dcf", "rrpplatform"),
    c("rrp.template.project-registration", "template", "resources/templates/project/R/register.R", "r", "rrpplatform"),
    c("rrp.template.project-authoring-metadata", "template", "resources/templates/project/rrp-authoring.dcf", "dcf", "rrpplatform"),
    c("rrp.template.project-producer", "template", "resources/templates/project/R/produce-canonical.R", "r", "rrpplatform"),
    c("rrp.template.project-provider", "template", "resources/templates/project/R/calculate-risk.R", "r", "rrpplatform"),
    c("rrp.template.project-readme", "template", "resources/templates/project/README.md", "md", "rrpplatform"),
    c("rrp.documentation.project-authoring-guide", "documentation", "resources/documentation/project-authoring-guide.md", "md", "rrpplatform"),
    c("rrp.documentation.provider-request-reference", "documentation", "resources/documentation/provider-request-reference.md", "md", "rrpplatform")
  )
  entries <- c(entries, lapply(canonical_definitions, function(definition) c(
    definition$resource_id, "contract", definition$path, "dcf", definition$owner
  )))
  entries <- c(entries, lapply(runtime_definitions, function(definition) c(
    definition$resource_id, "contract", definition$path, "dcf",
    definition$owner
  )))
  header <- c(
    "Record-Type" = "catalog", "Catalog-ID" = "rrp.software-resources",
    "Catalog-Version" = "0.1.0", "Format-Version" = "1.0.0",
    "Product-ID" = "readmission-risk-pool-platform",
    "Development-Version" = "1.0.0-dev",
    "Status" = "development_unpublished"
  )
  records <- c(list(header), lapply(entries, function(entry) c(
    "Record-Type" = "resource", "Resource-ID" = entry[[1L]],
    "Resource-Class" = entry[[2L]], "Owner-Package" = entry[[5L]],
    "Installed-Path" = entry[[3L]], "Format" = entry[[4L]]
  )))
  lines <- unlist(lapply(seq_along(records), function(index) {
    record <- records[[index]]
    value <- paste0(names(record), ": ", unname(record))
    if (index < length(records)) c(value, "") else value
  }), use.names = FALSE)
  writeLines(lines, file.path(root, "resources", "resource-catalog.dcf"), useBytes = TRUE)
  root
}

rrp_init_expect_failure <- function(result, code, destination, forbidden = character()) {
  if (!identical(result$diagnostics[[1L]]$code, code)) {
    stop(
      "unexpected initialization failure code: ",
      result$diagnostics[[1L]]$code, "; expected: ", code,
      call. = FALSE
    )
  }
  stopifnot(
    identical(class(result), c("rrp_operation_result", "list")),
    identical(result$operation_id, "rrp.initialize-project"),
    identical(result$status, "failure"), is.null(result$value),
    length(result$diagnostics) == 1L,
    identical(result$diagnostics[[1L]]$severity, "error"),
    identical(result$diagnostics[[1L]]$message, "Project initialization failed."),
    identical(rrp_operation_succeeded(result), FALSE),
    !file.exists(destination), !dir.exists(destination)
  )
  for (text in forbidden[nzchar(forbidden)]) {
    stopifnot(!grepl(text, result$diagnostics[[1L]]$message, fixed = TRUE))
  }
  invisible(result)
}

rrp_init_expect_condition <- function(expression, code) {
  condition <- tryCatch({
    force(expression)
    NULL
  }, error = identity)
  if (is.null(condition) || !identical(condition$code, code)) {
    actual <- if (is.null(condition)) "no condition" else condition$code
    stop("unexpected authoring condition: ", actual, "; expected: ", code,
         call. = FALSE)
  }
  stopifnot(
    inherits(condition, "rrp_project_error"),
    !grepl("rrp-init-authoring", condition$message, fixed = TRUE)
  )
  invisible(condition)
}

rrp_init_copy_project <- function(source, parent) {
  dir.create(parent, recursive = TRUE, showWarnings = FALSE)
  stopifnot(file.copy(source, parent, recursive = TRUE, copy.mode = FALSE))
  file.path(parent, basename(source))
}

rrp_init_replace_field <- function(path, field, value) {
  lines <- readLines(path, warn = FALSE, encoding = "UTF-8")
  pattern <- paste0("^", field, ":.*$")
  stopifnot(sum(grepl(pattern, lines)) == 1L)
  lines <- sub(pattern, paste0(field, ": ", value), lines)
  writeLines(lines, path, useBytes = TRUE)
}

local({
suite_root <- tempfile("rrp-project-initializer-")
dir.create(suite_root)
on.exit(unlink(suite_root, recursive = TRUE, force = TRUE), add = TRUE)
software_root <- rrp_init_software_root(file.path(suite_root, "software"))
catalog <- rrp_open_resource_catalog(software_root)
Sys.setenv(RRP_INIT_SELECTED_CALLED = "no")
on.exit(Sys.unsetenv("RRP_INIT_SELECTED_CALLED"), add = TRUE)

destination <- file.path(suite_root, "independent-project")
result <- rrp_initialize_project(
  catalog, destination, "example-health", "2.3.4-rc.1"
)
expected_value <- list(
  project_id = "example-health", project_version = "2.3.4-rc.1",
  producer_id = "example-health.producer",
  producer_version = "2.3.4-rc.1",
  producer_implementation_id = "example-health.producer-implementation",
  producer_implementation_version = "2.3.4-rc.1",
  mapping_id = "example-health.mapping",
  mapping_version = "2.3.4-rc.1",
  canonical_profile_id = "rrp.canonical-profile.readmission",
  canonical_profile_version = "0.1.0",
  provider_id = "example-health.provider",
  provider_version = "2.3.4-rc.1",
  provider_implementation_id = "example-health.provider-implementation",
  provider_implementation_version = "2.3.4-rc.1",
  model_id = NULL, model_version = NULL, extension_packages = list(),
  created_paths = c(
    "rrp-project.dcf", "rrp-authoring.dcf", "R/register.R",
    "R/produce-canonical.R", "R/calculate-risk.R", "README.md"
  )
)
stopifnot(
  identical(class(result), c("rrp_operation_result", "list")),
  identical(names(result), c("operation_id", "status", "value", "diagnostics")),
  identical(result$operation_id, "rrp.initialize-project"),
  identical(result$status, "success"), identical(result$value, expected_value),
  identical(result$diagnostics, list()),
  identical(rrp_operation_succeeded(result), TRUE),
  identical(Sys.getenv("RRP_INIT_SELECTED_CALLED"), "no"),
  identical(sort(list.files(
    destination, recursive = TRUE, all.files = TRUE, no.. = TRUE,
    include.dirs = FALSE
  )), c(
    "R/calculate-risk.R", "R/produce-canonical.R", "R/register.R",
    "README.md", "rrp-authoring.dcf", "rrp-project.dcf"
  )),
  identical(list.dirs(destination, recursive = TRUE, full.names = FALSE), c("", "R")),
  !dir.exists(file.path(destination, "extensions")),
  !dir.exists(file.path(destination, "state")),
  !dir.exists(file.path(destination, ".git"))
)
manifest <- read.dcf(file.path(destination, "rrp-project.dcf"))
stopifnot(
  identical(colnames(manifest), c(
    "Record-Type", "Project-Contract-ID", "Project-Contract-Version",
    "Project-ID", "Project-Version", "Project-Scope",
    "Supported-RRP-API-Version", "Canonical-Profile-ID",
    "Canonical-Profile-Version", "Producer-ID", "Producer-Version",
    "Provider-ID", "Provider-Version", "Extension-Library-Path", "State-Path"
  )),
  identical(manifest[[1L, "Project-ID"]], "example-health"),
  identical(manifest[[1L, "Project-Version"]], "2.3.4-rc.1"),
  identical(
    manifest[[1L, "Canonical-Profile-ID"]],
    "rrp.canonical-profile.readmission"
  ),
  identical(manifest[[1L, "Producer-ID"]], "example-health.producer"),
  identical(manifest[[1L, "Provider-ID"]], "example-health.provider"),
  identical(manifest[[1L, "Producer-Version"]], "2.3.4-rc.1"),
  identical(manifest[[1L, "Provider-Version"]], "2.3.4-rc.1"),
  identical(manifest[[1L, "Extension-Library-Path"]], "extensions/library"),
  identical(manifest[[1L, "State-Path"]], "state")
)
context <- rrp_load_project(catalog, destination)
producer_result <- context$producer$callable(list(
  as_of_time = "2026-09-17T12:00:00Z"
))
stopifnot(
  identical(Sys.getenv("RRP_INIT_SELECTED_CALLED"), "yes"),
  identical(context$registration$project_id, "example-health"),
  identical(context$producer$component_id, "example-health.producer"),
  identical(
    context$producer$implementation_id,
    "example-health.producer-implementation"
  ),
  identical(context$producer$mapping_id, "example-health.mapping"),
  identical(context$producer$capabilities, rrp_init_internal(
    "rrp_canonical_required_capabilities"
  )(rrp_init_internal("rrp_canonical_contracts")(catalog))),
  identical(context$provider$component_id, "example-health.provider"),
  identical(
    context$provider$implementation_id,
    "example-health.provider-implementation"
  ),
  identical(context$producer$origin, "project"),
  identical(context$provider$origin, "project"),
  identical(producer_result$status, "failed"),
  identical(producer_result$failure_code, "producer_unavailable"),
  identical(
    producer_result$canonical_as_of_time, "2026-09-17T12:00:00Z"
  ),
  is.null(producer_result$candidate_bundle),
  inherits(try(context$provider$callable(), silent = TRUE), "try-error")
)

copy_parent <- file.path(suite_root, "portable-copy")
dir.create(copy_parent)
stopifnot(file.copy(destination, copy_parent, recursive = TRUE, copy.mode = FALSE))
copied_root <- file.path(copy_parent, basename(destination))
copied <- rrp_load_project(catalog, copied_root)
rendered_text <- paste(unlist(lapply(
  c(
    file.path(destination, "rrp-project.dcf"),
    file.path(destination, "rrp-authoring.dcf"),
    file.path(destination, "R", "register.R"),
    file.path(destination, "R", "produce-canonical.R"),
    file.path(destination, "R", "calculate-risk.R"),
    file.path(destination, "README.md")
  ),
  readLines, warn = FALSE
)), collapse = "\n")
stopifnot(
  identical(copied$manifest, context$manifest),
  identical(copied$producer$component_id, context$producer$component_id),
  identical(copied$provider$component_id, context$provider$component_id),
  !identical(copied$project_root, context$project_root),
  !grepl(suite_root, rendered_text, fixed = TRUE),
  !grepl("rrp-staging", rendered_text, fixed = TRUE)
)

# The generated standard layer must compile to the unchanged raw producer and
# provider protocols while leaving hospital code responsible only for mapping
# and calculation.
as_of_time <- "2026-02-10T12:00:00Z"
valid_producer <- c(
  "rrp_produce_canonical <- function(project_root, as_of_time) {",
  "  episodes <- data.frame(",
  "    episode_id = 'episode-one', patient_id = 'patient-one',",
  "    index_encounter_id = 'encounter-one',",
  "    admission_time = '2026-02-01T12:00:00Z',",
  "    discharge_time = '2026-02-02T12:00:00Z',",
  "    followup_window_end = '2026-03-04T12:00:00Z',",
  "    stringsAsFactors = FALSE)",
  "  events <- data.frame(",
  "    terminal_event_id = character(), episode_id = character(),",
  "    event_type = character(), occurred_at = character(),",
  "    available_at = character(), stringsAsFactors = FALSE)",
  "  list(discharge_episode = episodes, terminal_event = events)",
  "}"
)
valid_provider <- c(
  "rrp_calculate_risk <- function(project_root, request) {",
  "  0.42",
  "}"
)
writeLines(
  valid_producer, file.path(destination, "R", "produce-canonical.R"),
  useBytes = TRUE
)
writeLines(
  valid_provider, file.path(destination, "R", "calculate-risk.R"),
  useBytes = TRUE
)
before_directory <- getwd()
before_libraries <- .libPaths()
before_globals <- ls(.GlobalEnv, all.names = TRUE)
authored_context <- rrp_load_project(catalog, destination)
canonical_contracts <- rrp_init_internal("rrp_canonical_contracts")(catalog)
raw_request <- rrp_init_internal("rrp_producer_request")(
  authored_context, canonical_contracts$canonical_producer, as_of_time
)
raw_result <- authored_context$producer$callable(raw_request)
raw_repeat <- authored_context$producer$callable(raw_request)
producer_fields <- strsplit(
  canonical_contracts$canonical_producer[["Result-Fields"]], ",", fixed = TRUE
)[[1L]]
bundle_fields <- strsplit(
  canonical_contracts$canonical_bundle[["Bundle-Fields"]], ",", fixed = TRUE
)[[1L]]
admitted <- rrp_execute_producer(catalog, destination, as_of_time)
admitted_repeat <- rrp_execute_producer(catalog, destination, as_of_time)
stopifnot(
  identical(names(raw_result), producer_fields), length(raw_result) == 15L,
  identical(raw_result$status, "succeeded"),
  identical(names(raw_result$candidate_bundle), bundle_fields),
  length(raw_result$candidate_bundle) == 16L,
  identical(
    raw_result$candidate_bundle$bundle_instance_id,
    raw_repeat$candidate_bundle$bundle_instance_id
  ),
  startsWith(
    raw_result$candidate_bundle$bundle_instance_id, "rrp.bundle."
  ),
  identical(admitted$status, "success"),
  identical(class(admitted$value), c("rrp_admitted_canonical_bundle", "list")),
  identical(admitted$value, admitted_repeat$value)
)

changed_producer <- sub(
  "patient-one", "patient-two", valid_producer, fixed = TRUE
)
writeLines(
  changed_producer, file.path(destination, "R", "produce-canonical.R"),
  useBytes = TRUE
)
changed <- rrp_execute_producer(catalog, destination, as_of_time)
stopifnot(
  identical(changed$status, "success"),
  !identical(
    changed$value$bundle_instance_id, admitted$value$bundle_instance_id
  )
)
writeLines(
  valid_producer, file.path(destination, "R", "produce-canonical.R"),
  useBytes = TRUE
)

runtime_contracts <- rrp_init_internal("rrp_runtime_contracts")(
  catalog, canonical_contracts
)
episode_state <- rrpruntime::rrp_prepare_episode_state(
  admitted$value, "episode-one", as_of_time,
  rrp_init_internal("rrp_episode_state_expected_context")(
    runtime_contracts, canonical_contracts
  )
)
provider_context <- rrp_init_internal("rrp_provider_expected_context")(
  runtime_contracts, canonical_contracts
)
risk_request <- get(
  "rrp_runtime_risk_request", envir = asNamespace("rrpruntime"),
  inherits = FALSE
)(episode_state, provider_context)
authored_context <- rrp_load_project(catalog, destination)
raw_provider <- authored_context$provider$callable(risk_request)
risk <- rrp_execute_risk(
  catalog, destination, admitted$value, "episode-one", as_of_time
)
stopifnot(
  identical(class(risk_request), c("rrp_risk_request", "list")),
  length(risk_request) == 19L,
  identical(
    names(raw_provider),
    c("request_id", "status", "estimate_value", "failure_code")
  ),
  identical(raw_provider$status, "success"),
  identical(raw_provider$estimate_value, 0.42),
  identical(risk$status, "success"),
  identical(risk$value$estimate_value, 0.42)
)

expect_operation_failure <- function(result, operation_id, code) {
  stopifnot(
    identical(result$operation_id, operation_id),
    identical(result$status, "failure"), is.null(result$value),
    length(result$diagnostics) == 1L,
    identical(result$diagnostics[[1L]]$code, code),
    nchar(result$diagnostics[[1L]]$message, type = "bytes") <= 240L
  )
}
producer_cases <- list(
  declared = list(
    "  rrpplatform::rrp_authoring_failure('producer_source_failed')",
    "producer_source_failed"
  ),
  wrong_context = list(
    "  rrpplatform::rrp_authoring_failure('provider_input_unavailable')",
    "invalid_producer_result"
  ),
  invalid = list("  list(unexpected = TRUE)", "invalid_producer_result"),
  thrown = list(
    "  stop('private producer credential=never-render', call. = FALSE)",
    "producer_execution_failed"
  )
)
for (case in producer_cases) {
  writeLines(c(
    "rrp_produce_canonical <- function(project_root, as_of_time) {",
    case[[1L]], "}"
  ), file.path(destination, "R", "produce-canonical.R"), useBytes = TRUE)
  result_case <- rrp_execute_producer(catalog, destination, as_of_time)
  expect_operation_failure(result_case, "rrp.execute-producer", case[[2L]])
  stopifnot(!grepl(
    "credential=never-render", paste(capture.output(str(result_case)), collapse = " "),
    fixed = TRUE
  ))
}
writeLines(
  valid_producer, file.path(destination, "R", "produce-canonical.R"),
  useBytes = TRUE
)

provider_cases <- list(
  unavailable = list(
    "rrpplatform::rrp_authoring_failure('provider_input_unavailable')",
    "provider_input_unavailable"
  ),
  wrong_context = list(
    "rrpplatform::rrp_authoring_failure('producer_source_failed')",
    "invalid_provider_result"
  ),
  null = list("NULL", "invalid_estimate"),
  missing = list("NA_real_", "invalid_estimate"),
  nan = list("NaN", "invalid_estimate"),
  infinite = list("Inf", "invalid_estimate"),
  type = list("'0.42'", "invalid_estimate"),
  length = list("c(0.4, 0.5)", "invalid_estimate"),
  below = list("-0.1", "invalid_estimate"),
  above = list("1.1", "invalid_estimate"),
  thrown = list(
    "stop('private model host=never-render', call. = FALSE)",
    "provider_execution_failed"
  )
)
for (case in provider_cases) {
  writeLines(c(
    "rrp_calculate_risk <- function(project_root, request) {",
    paste0("  ", case[[1L]]), "}"
  ), file.path(destination, "R", "calculate-risk.R"), useBytes = TRUE)
  result_case <- rrp_execute_risk(
    catalog, destination, admitted$value, "episode-one", as_of_time
  )
  expect_operation_failure(result_case, "rrp.execute-risk", case[[2L]])
  stopifnot(!grepl(
    "host=never-render", paste(capture.output(str(result_case)), collapse = " "),
    fixed = TRUE
  ))
}
writeLines(
  valid_provider, file.path(destination, "R", "calculate-risk.R"),
  useBytes = TRUE
)

bad_failure <- tryCatch(
  rrp_authoring_failure("not_a_contract_failure"), error = identity
)
stopifnot(
  inherits(bad_failure, "rrp_project_error"),
  identical(bad_failure$code, "invalid_authoring_failure")
)

# Closed structural checks apply before hospital callables can run.
structural_parent <- file.path(suite_root, "authoring-structural-cases")
pristine_standard <- rrp_init_copy_project(destination, structural_parent)
new_structural_case <- local({
  number <- 0L
  function() {
    number <<- number + 1L
    rrp_init_copy_project(
      pristine_standard,
      file.path(suite_root, paste0("authoring-case-", number))
    )
  }
})
case <- new_structural_case()
writeLines("not dcf", file.path(case, "rrp-authoring.dcf"), useBytes = TRUE)
rrp_init_expect_condition(
  rrp_load_project(catalog, case), "malformed_authoring_metadata"
)
case <- new_structural_case()
writeLines(
  c(readLines(file.path(case, "rrp-authoring.dcf")), "Unknown: prohibited"),
  file.path(case, "rrp-authoring.dcf"), useBytes = TRUE
)
rrp_init_expect_condition(
  rrp_load_project(catalog, case), "malformed_authoring_metadata"
)
case <- new_structural_case()
unlink(file.path(case, "R", "produce-canonical.R"))
rrp_init_expect_condition(
  rrp_load_project(catalog, case), "missing_authoring_file"
)
case <- new_structural_case()
writeLines(c(
  valid_producer, "extra_binding <- TRUE"
), file.path(case, "R", "produce-canonical.R"), useBytes = TRUE)
rrp_init_expect_condition(
  rrp_load_project(catalog, case), "invalid_authoring_binding"
)
case <- new_structural_case()
writeLines(
  "different_binding <- function(project_root, as_of_time) NULL",
  file.path(case, "R", "produce-canonical.R"), useBytes = TRUE
)
rrp_init_expect_condition(
  rrp_load_project(catalog, case), "invalid_authoring_binding"
)
case <- new_structural_case()
writeLines(
  "rrp_produce_canonical <- function(as_of_time, project_root) NULL",
  file.path(case, "R", "produce-canonical.R"), useBytes = TRUE
)
rrp_init_expect_condition(
  rrp_load_project(catalog, case), "invalid_authoring_signature"
)
case <- new_structural_case()
unlink(file.path(case, "README.md"))
rrp_init_expect_condition(
  rrp_load_project(catalog, case), "missing_authoring_file"
)
case <- new_structural_case()
link_target <- file.path(suite_root, "linked-authoring-target.R")
writeLines(valid_producer, link_target, useBytes = TRUE)
unlink(file.path(case, "R", "produce-canonical.R"))
if (isTRUE(file.symlink(link_target, file.path(case, "R", "produce-canonical.R")))) {
  rrp_init_expect_condition(
    rrp_load_project(catalog, case), "linked_authoring_file"
  )
}

# The declared extension inventory is an exact preflight over the project
# library. Ambient packages do not satisfy it and RRP packages cannot be
# shadowed. One temporary installed package proves the positive path and
# software-first library ordering during invocation.
dependency_parent <- file.path(suite_root, "authoring-dependency")
dependency_project <- rrp_init_copy_project(destination, dependency_parent)
extension_library <- file.path(dependency_project, "extensions", "library")
dir.create(extension_library, recursive = TRUE)
extension_source <- file.path(suite_root, "rrptestextension")
dir.create(file.path(extension_source, "R"), recursive = TRUE)
writeLines(c(
  "Package: rrptestextension", "Type: Package", "Title: RRP Test Extension",
  "Version: 0.1.0",
  "Authors@R: person('Test', 'Author', email = 'test@example.invalid', role = c('aut', 'cre'))",
  "Description: Temporary package used only for authoring boundary tests.",
  "License: MIT", "Encoding: UTF-8"
), file.path(extension_source, "DESCRIPTION"), useBytes = TRUE)
writeLines(
  "export(rrp_extension_value)", file.path(extension_source, "NAMESPACE"),
  useBytes = TRUE
)
writeLines(
  "rrp_extension_value <- function() 'extension-ok'",
  file.path(extension_source, "R", "value.R"), useBytes = TRUE
)
installation <- suppressWarnings(system2(
  file.path(R.home("bin"), "R"),
  c(
    "CMD", "INSTALL", "--no-byte-compile",
    paste0("--library=", extension_library), extension_source
  ), stdout = TRUE, stderr = TRUE
))
if (!is.null(attr(installation, "status"))) {
  stop(
    "temporary extension installation failed: ",
    paste(installation, collapse = " | "), call. = FALSE
  )
}
rrp_init_replace_field(
  file.path(dependency_project, "rrp-authoring.dcf"),
  "Extension-Packages", "rrptestextension@0.1.0"
)
dependency_producer <- c(
  valid_producer[[1L]],
  "  if (!identical(rrptestextension::rrp_extension_value(), 'extension-ok')) stop('extension unavailable')",
  "  software_library <- normalizePath(dirname(find.package('rrpplatform')), winslash = '/', mustWork = TRUE)",
  "  extension_library <- normalizePath(file.path(project_root, 'extensions', 'library'), winslash = '/', mustWork = TRUE)",
  "  if (match(software_library, .libPaths()) >= match(extension_library, .libPaths())) stop('invalid library ordering')",
  valid_producer[-1L]
)
writeLines(
  dependency_producer,
  file.path(dependency_project, "R", "produce-canonical.R"), useBytes = TRUE
)
dependency_result <- rrp_execute_producer(
  catalog, dependency_project, as_of_time
)
stopifnot(
  identical(dependency_result$status, "success"),
  identical(getwd(), before_directory),
  identical(.libPaths(), before_libraries)
)

missing_dependency <- rrp_init_copy_project(
  destination, file.path(suite_root, "missing-dependency")
)
rrp_init_replace_field(
  file.path(missing_dependency, "rrp-authoring.dcf"),
  "Extension-Packages", "rrptestextension@0.1.0"
)
rrp_init_expect_condition(
  rrp_load_project(catalog, missing_dependency), "missing_extension_package"
)
wrong_dependency <- rrp_init_copy_project(
  dependency_project, file.path(suite_root, "wrong-dependency")
)
rrp_init_replace_field(
  file.path(wrong_dependency, "rrp-authoring.dcf"),
  "Extension-Packages", "rrptestextension@9.9.9"
)
rrp_init_expect_condition(
  rrp_load_project(catalog, wrong_dependency), "extension_version_mismatch"
)
ambient_dependency <- rrp_init_copy_project(
  destination, file.path(suite_root, "ambient-dependency")
)
rrp_init_replace_field(
  file.path(ambient_dependency, "rrp-authoring.dcf"),
  "Extension-Packages", paste0("DBI@", as.character(utils::packageVersion("DBI")))
)
rrp_init_expect_condition(
  rrp_load_project(catalog, ambient_dependency), "missing_extension_package"
)
shadow_dependency <- rrp_init_copy_project(
  destination, file.path(suite_root, "shadow-dependency")
)
rrp_init_replace_field(
  file.path(shadow_dependency, "rrp-authoring.dcf"),
  "Extension-Packages", paste0(
    "rrpplatform@", as.character(utils::packageVersion("rrpplatform"))
  )
)
rrp_init_expect_condition(
  rrp_load_project(catalog, shadow_dependency), "invalid_extension_inventory"
)

stopifnot(
  identical(getwd(), before_directory),
  identical(.libPaths(), before_libraries),
  identical(ls(.GlobalEnv, all.names = TRUE), before_globals)
)

guide_path <- rrp_resource_path(
  catalog, "rrp.documentation.project-authoring-guide"
)
reference_path <- rrp_resource_path(
  catalog, "rrp.documentation.provider-request-reference"
)
readme_text <- paste(readLines(file.path(destination, "README.md")), collapse = " ")
guide_text <- paste(readLines(guide_path), collapse = " ")
reference_text <- paste(readLines(reference_path), collapse = " ")
provider_template_text <- paste(readLines(file.path(
  software_root, "resources", "templates", "project", "R",
  "calculate-risk.R"
)), collapse = " ")
stopifnot(
  file.exists(guide_path), file.exists(reference_path),
  grepl("exactly six files", guide_text, fixed = TRUE),
  grepl("exactly 19 fields", reference_text, fixed = TRUE),
  grepl("rrp_risk_request", provider_template_text, fixed = TRUE),
  grepl("rrp.documentation.project-authoring-guide", readme_text, fixed = TRUE),
  grepl("rrp.documentation.provider-request-reference", readme_text, fixed = TRUE),
  !grepl("docs/", guide_text, fixed = TRUE),
  !grepl("docs/", reference_text, fixed = TRUE)
)

invalid_cases <- list(
  list("Uppercase", "1.0.0", "invalid_project_id"),
  list("rrp.protected", "1.0.0", "invalid_project_id"),
  list(paste0("a", paste(rep("b", 88L), collapse = "")), "1.0.0", "invalid_project_id"),
  list("valid-project", "version", "invalid_project_version")
)
for (index in seq_along(invalid_cases)) {
  case <- invalid_cases[[index]]
  rejected <- file.path(suite_root, paste0("invalid-input-", index))
  rrp_init_expect_failure(
    rrp_initialize_project(catalog, rejected, case[[1L]], case[[2L]]),
    case[[3L]], rejected, c(case[[1L]], rejected)
  )
}

existing_directory <- file.path(suite_root, "existing-directory")
dir.create(existing_directory)
writeLines("preserve", file.path(existing_directory, "sentinel"))
existing_result <- rrp_initialize_project(
  catalog, existing_directory, "existing-dir", "1.0.0"
)
stopifnot(
  identical(existing_result$status, "failure"),
  identical(existing_result$diagnostics[[1L]]$code, "project_destination_exists"),
  identical(readLines(file.path(existing_directory, "sentinel")), "preserve")
)
existing_file <- file.path(suite_root, "existing-file")
writeLines("preserve", existing_file)
file_result <- rrp_initialize_project(catalog, existing_file, "existing-file", "1.0.0")
stopifnot(
  identical(file_result$diagnostics[[1L]]$code, "project_destination_exists"),
  identical(readLines(existing_file), "preserve")
)
link_path <- file.path(suite_root, "existing-link")
if (isTRUE(file.symlink(existing_file, link_path))) {
  link_result <- rrp_initialize_project(catalog, link_path, "existing-link", "1.0.0")
  stopifnot(
    identical(link_result$diagnostics[[1L]]$code, "project_destination_exists"),
    nzchar(Sys.readlink(link_path)), identical(readLines(existing_file), "preserve")
  )
}
missing_parent_destination <- file.path(suite_root, "missing-parent", "project")
rrp_init_expect_failure(
  rrp_initialize_project(
    catalog, missing_parent_destination, "missing-parent", "1.0.0"
  ), "invalid_project_parent", missing_parent_destination,
  missing_parent_destination
)
invalid_destination <- file.path(suite_root, "..")
invalid_destination_result <- rrp_initialize_project(
  catalog, invalid_destination, "invalid-destination", "1.0.0"
)
stopifnot(
  identical(invalid_destination_result$status, "failure"),
  identical(
    invalid_destination_result$diagnostics[[1L]]$code,
    "invalid_project_destination"
  )
)
parent_file <- file.path(suite_root, "parent-file")
writeLines("preserve", parent_file)
file_parent_destination <- file.path(parent_file, "project")
rrp_init_expect_failure(
  rrp_initialize_project(catalog, file_parent_destination, "file-parent", "1.0.0"),
  "invalid_project_parent", file_parent_destination, file_parent_destination
)
linked_parent <- file.path(suite_root, "linked-parent")
ordinary_parent <- file.path(suite_root, "ordinary-parent")
dir.create(ordinary_parent)
if (isTRUE(file.symlink(ordinary_parent, linked_parent))) {
  linked_parent_destination <- file.path(linked_parent, "project")
  rrp_init_expect_failure(
    rrp_initialize_project(
      catalog, linked_parent_destination, "linked-parent", "1.0.0"
    ), "invalid_project_parent", linked_parent_destination,
    linked_parent_destination
  )
}

rollback_destination <- file.path(suite_root, "rollback-destination")
registration_template_path <- file.path(
  software_root, "resources", "templates", "project", "R", "register.R"
)
valid_registration_template <- readLines(registration_template_path, warn = FALSE)
writeLines(
  sub("rrp_register_project <- function", "rrp_register_project <- not_function",
      valid_registration_template, fixed = TRUE),
  registration_template_path, useBytes = TRUE
)
rollback <- rrp_initialize_project(
  catalog, rollback_destination, "rollback-project", "1.0.0"
)
rrp_init_expect_failure(
  rollback, "malformed_project_registration", rollback_destination,
  c(rollback_destination, "not_function")
)
stopifnot(
  !any(grepl("[.]rollback-destination[.]rrp-staging-", list.files(suite_root)))
)
writeLines(valid_registration_template, registration_template_path, useBytes = TRUE)

manifest_template_path <- file.path(
  software_root, "resources", "templates", "project", "rrp-project.dcf"
)
valid_manifest_template <- readLines(manifest_template_path, warn = FALSE)
writeLines(
  sub("@@RRP_PROVIDER_ID@@", "fixed.provider", valid_manifest_template, fixed = TRUE),
  manifest_template_path, useBytes = TRUE
)
token_destination <- file.path(suite_root, "token-drift")
rrp_init_expect_failure(
  rrp_initialize_project(catalog, token_destination, "render-project", "1.0.0"),
  "project_template_invalid", token_destination, token_destination
)
stopifnot(!any(grepl("[.]token-drift[.]rrp-staging-", list.files(suite_root))))
writeLines(valid_manifest_template, manifest_template_path, useBytes = TRUE)

second <- rrp_initialize_project(catalog, destination, "example-health", "2.3.4-rc.1")
stopifnot(
  identical(second$status, "failure"),
  identical(second$diagnostics[[1L]]$code, "project_destination_exists"),
  identical(rrp_load_project(catalog, destination)$manifest, context$manifest)
)

stopifnot(
  identical(sort(getNamespaceExports("rrpplatform")), c(
    "rrp_authoring_failure", "rrp_backup_project_state",
    "rrp_build_product_set",
    "rrp_execute_durable_bundle",
    "rrp_execute_producer", "rrp_execute_risk",
    "rrp_initialize_fictional_project",
    "rrp_initialize_project", "rrp_initialize_project_state",
    "rrp_inspect_current_history", "rrp_inspect_episode_history",
    "rrp_inspect_project_state", "rrp_inspect_scope_history",
    "rrp_invalidate_history",
    "rrp_load_project",
    "rrp_open_resource_catalog",
    "rrp_operation_succeeded", "rrp_register_authored_project",
    "rrp_resource_path",
    "rrp_restate_history", "rrp_restore_project_state", "rrp_retry_episode",
    "rrp_validate_project",
    "rrp_validate_software_resources"
  ))
)

cat("rrpplatform project-initializer tests passed\n")
})
