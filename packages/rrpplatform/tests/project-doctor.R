library(rrpplatform)

rrp_doctor_internal <- function(name) {
  get(name, envir = asNamespace("rrpplatform"), inherits = FALSE)
}

rrp_doctor_write_record <- function(record, path) {
  dir.create(dirname(path), recursive = TRUE, showWarnings = FALSE)
  writeLines(paste0(names(record), ": ", unname(record)), path, useBytes = TRUE)
}

rrp_doctor_manifest_template <- c(
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

rrp_doctor_registration_template <- c(
  "rrp_register_project <- function(project_root) {",
  "  unavailable <- function(request) stop('selected callable executed', call. = FALSE)",
  "  capabilities <- list(list(capability_id = 'rrp.capability.discharge-episode', status = 'available'), list(capability_id = 'rrp.capability.terminal-event', status = 'available'))",
  "  producer <- function() list(component_id = '@@RRP_PRODUCER_ID@@', component_version = '@@RRP_PROJECT_VERSION@@', producer_api_id = 'rrp.producer-api', producer_api_version = '0.1.0', canonical_bundle_id = 'rrp.canonical-bundle', canonical_bundle_version = '0.1.0', canonical_profile_id = 'rrp.canonical-profile.readmission', canonical_profile_version = '0.1.0', implementation_id = '@@RRP_IMPLEMENTATION_ID@@', implementation_version = '@@RRP_PROJECT_VERSION@@', mapping_id = '@@RRP_MAPPING_ID@@', mapping_version = '@@RRP_PROJECT_VERSION@@', capabilities = capabilities, callable = unavailable)",
  "  provider <- function() list(component_id = '@@RRP_PROVIDER_ID@@', component_version = '@@RRP_PROJECT_VERSION@@', provider_api_id = 'rrp.provider-api', provider_api_version = '0.1.0', target_id = 'rrp.risk-target.readmission-remaining-30-day', target_version = '0.1.0', state_contract_id = 'rrp.episode-state', state_contract_version = '0.1.0', request_contract_id = 'rrp.risk-request', request_contract_version = '0.1.0', estimate_contract_id = 'rrp.risk-estimate', estimate_contract_version = '0.1.0', implementation_id = '@@RRP_IMPLEMENTATION_ID@@', implementation_version = '@@RRP_PROJECT_VERSION@@', model_id = NULL, model_version = NULL, callable = unavailable)",
  "  list(",
  "    registration_contract_id = 'rrp.project-registration',",
  "    registration_contract_version = '0.3.0',",
  "    project_id = '@@RRP_PROJECT_ID@@',",
  "    producers = list(producer()),",
  "    providers = list(provider())",
  "  )",
  "}"
)

rrp_doctor_software_root <- function(root) {
  resources <- list(
    list(
      id = "rrp.contract.resource-catalog", class = "contract", format = "dcf",
      path = "resources/resource-catalog-schema.dcf",
      value = rrp_doctor_internal("rrp_resource_schema_contract")()
    ),
    list(
      id = "rrp.contract.diagnostic", class = "contract", format = "dcf",
      path = "resources/contracts/diagnostic.dcf",
      value = c("Record-Type" = "contract")
    ),
    list(
      id = "rrp.contract.operation-result", class = "contract", format = "dcf",
      path = "resources/contracts/operation-result.dcf",
      value = c("Record-Type" = "contract")
    ),
    list(
      id = "rrp.contract.project-manifest", class = "contract", format = "dcf",
      path = "resources/contracts/project-manifest.dcf",
      value = rrp_doctor_internal("rrp_project_manifest_contract_expected")()
    ),
    list(
      id = "rrp.contract.project-registration", class = "contract", format = "dcf",
      path = "resources/contracts/project-registration.dcf",
      value = rrp_doctor_internal("rrp_project_registration_contract_expected")()
    ),
    list(
      id = "rrp.template.project-manifest", class = "template", format = "dcf",
      path = "resources/templates/project/rrp-project.dcf",
      value = rrp_doctor_manifest_template
    ),
    list(
      id = "rrp.template.project-registration", class = "template", format = "r",
      path = "resources/templates/project/R/register.R",
      value = rrp_doctor_registration_template
    )
  )
  canonical_definitions <- rrp_doctor_internal(
    "rrp_canonical_contract_definitions"
  )()
  resources <- c(resources, lapply(canonical_definitions, function(definition) {
    list(
      id = definition$resource_id, class = "contract", format = "dcf",
      owner = definition$owner, path = definition$path,
      value = definition$expected
    )
  }))
  runtime_definitions <- rrp_doctor_internal(
    "rrp_runtime_contract_definitions"
  )()
  resources <- c(resources, lapply(runtime_definitions, function(definition) {
    list(
      id = definition$resource_id, class = "contract", format = "dcf",
      owner = definition$owner, path = definition$path,
      value = definition$expected
    )
  }))
  for (resource in resources) {
    path <- file.path(root, resource$path)
    if (identical(resource$format, "dcf") && !is.null(names(resource$value))) {
      rrp_doctor_write_record(resource$value, path)
    } else {
      dir.create(dirname(path), recursive = TRUE, showWarnings = FALSE)
      writeLines(resource$value, path, useBytes = TRUE)
    }
  }
  header <- c(
    "Record-Type" = "catalog", "Catalog-ID" = "rrp.software-resources",
    "Catalog-Version" = "0.1.0", "Format-Version" = "1.0.0",
    "Product-ID" = "readmission-risk-pool-platform",
    "Development-Version" = "1.0.0-dev",
    "Status" = "development_unpublished"
  )
  entries <- lapply(resources, function(resource) c(
    "Record-Type" = "resource", "Resource-ID" = resource$id,
    "Resource-Class" = resource$class,
    "Owner-Package" = if (is.null(resource$owner)) "rrpplatform" else resource$owner,
    "Installed-Path" = resource$path, "Format" = resource$format
  ))
  records <- c(list(header), entries)
  lines <- unlist(lapply(seq_along(records), function(index) {
    record <- records[[index]]
    rendered <- paste0(names(record), ": ", unname(record))
    if (index < length(records)) c(rendered, "") else rendered
  }), use.names = FALSE)
  writeLines(lines, file.path(root, "resources", "resource-catalog.dcf"), useBytes = TRUE)
  root
}

rrp_doctor_copy_project <- function(project_root, parent) {
  dir.create(parent, recursive = TRUE, showWarnings = FALSE)
  stopifnot(file.copy(project_root, parent, recursive = TRUE, copy.mode = FALSE))
  file.path(parent, basename(project_root))
}

rrp_doctor_replace_manifest <- function(root, pattern, replacement) {
  path <- file.path(root, "rrp-project.dcf")
  lines <- readLines(path, warn = FALSE)
  lines <- sub(pattern, replacement, lines)
  writeLines(lines, path, useBytes = TRUE)
}

rrp_doctor_expect_failure <- function(result, code, forbidden = character()) {
  stopifnot(
    identical(class(result), c("rrp_operation_result", "list")),
    identical(names(result), c("operation_id", "status", "value", "diagnostics")),
    identical(result$operation_id, "rrp.validate-project"),
    identical(result$status, "failure"), is.null(result$value),
    length(result$diagnostics) == 1L,
    identical(class(result$diagnostics[[1L]]), c("rrp_diagnostic", "list")),
    identical(result$diagnostics[[1L]]$code, code),
    identical(result$diagnostics[[1L]]$severity, "error"),
    identical(
      result$diagnostics[[1L]]$message,
      "RRP project validation failed."
    ),
    identical(rrp_operation_succeeded(result), FALSE)
  )
  serialized <- paste(capture.output(str(result)), collapse = " ")
  for (value in forbidden[nzchar(forbidden)]) {
    stopifnot(!grepl(value, serialized, fixed = TRUE))
  }
  invisible(result)
}

local({
suite_root <- tempfile("rrp-project-doctor-")
dir.create(suite_root)
on.exit(unlink(suite_root, recursive = TRUE, force = TRUE), add = TRUE)
software_root <- rrp_doctor_software_root(file.path(suite_root, "software"))
catalog <- rrp_open_resource_catalog(software_root)
project_root <- file.path(suite_root, "independent-project")
initialized <- rrp_initialize_project(
  catalog, project_root, "doctor-project", "2.4.0"
)
stopifnot(rrp_operation_succeeded(initialized))

expected_value <- list(
  project_id = "doctor-project",
  project_version = "2.4.0",
  project_contract_id = "rrp.project",
  project_contract_version = "0.3.0",
  supported_rrp_api_version = "0.3.0",
  canonical_profile = list(
    profile_id = "rrp.canonical-profile.readmission",
    profile_version = "0.1.0"
  ),
  producer = list(
    component_id = "doctor-project.producer",
    component_version = "2.4.0",
    implementation_id = "doctor-project.implementation",
    implementation_version = "2.4.0",
    mapping_id = "doctor-project.mapping",
    mapping_version = "2.4.0",
    origin = "project"
  ),
  provider = list(
    component_id = "doctor-project.provider",
    component_version = "2.4.0",
    implementation_id = "doctor-project.implementation",
    implementation_version = "2.4.0",
    model_id = NULL,
    model_version = NULL,
    origin = "project"
  ),
  extension_library_status = "not_initialized",
  state_status = "not_initialized"
)

previous_directory <- getwd()
previous_globals <- ls(.GlobalEnv, all.names = TRUE)
previous_libraries <- .libPaths()
unrelated <- file.path(suite_root, "unrelated-working-directory")
dir.create(unrelated)
setwd(unrelated)
unrelated <- normalizePath(unrelated, winslash = "/", mustWork = TRUE)
on.exit(setwd(previous_directory), add = TRUE)
before_files <- vapply(
  c(file.path(project_root, "rrp-project.dcf"), file.path(project_root, "R", "register.R")),
  function(path) paste(readLines(path, warn = FALSE), collapse = "\n"),
  character(1L)
)
result <- rrp_validate_project(catalog, project_root)
after_files <- vapply(
  c(file.path(project_root, "rrp-project.dcf"), file.path(project_root, "R", "register.R")),
  function(path) paste(readLines(path, warn = FALSE), collapse = "\n"),
  character(1L)
)
stopifnot(
  identical(class(result), c("rrp_operation_result", "list")),
  identical(names(result), c("operation_id", "status", "value", "diagnostics")),
  identical(result$operation_id, "rrp.validate-project"),
  identical(result$status, "success"), identical(result$value, expected_value),
  length(result$diagnostics) == 1L,
  identical(result$diagnostics[[1L]]$code, "project_state_not_initialized"),
  identical(result$diagnostics[[1L]]$severity, "warning"),
  identical(
    result$diagnostics[[1L]]$message,
    "Project state has not been initialized."
  ),
  identical(rrp_operation_succeeded(result), TRUE),
  identical(before_files, after_files),
  !dir.exists(file.path(project_root, "extensions")),
  !dir.exists(file.path(project_root, "state")),
  identical(getwd(), unrelated),
  identical(.libPaths(), previous_libraries),
  identical(ls(.GlobalEnv, all.names = TRUE), previous_globals)
)
serialized <- paste(capture.output(str(result)), collapse = " ")
stopifnot(
  !grepl(project_root, serialized, fixed = TRUE),
  !grepl(software_root, serialized, fixed = TRUE),
  !grepl("function", serialized, fixed = TRUE),
  !grepl("selected callable executed", serialized, fixed = TRUE)
)

dir.create(file.path(project_root, "extensions", "library"), recursive = TRUE)
dir.create(file.path(project_root, "state"))
writeLines("opaque extension content", file.path(
  project_root, "extensions", "library", "sentinel.txt"
))
writeLines("opaque state content", file.path(project_root, "state", "sentinel.txt"))
extension_before <- readLines(file.path(
  project_root, "extensions", "library", "sentinel.txt"
))
state_before <- readLines(file.path(project_root, "state", "sentinel.txt"))
available <- rrp_validate_project(catalog, project_root)
available_serialized <- paste(capture.output(str(available)), collapse = " ")
stopifnot(
  identical(available$status, "success"),
  identical(available$value$extension_library_status, "available"),
  identical(available$value$state_status, "available"),
  identical(available$diagnostics, list()),
  identical(readLines(file.path(
    project_root, "extensions", "library", "sentinel.txt"
  )), extension_before),
  identical(readLines(file.path(project_root, "state", "sentinel.txt")), state_before),
  !grepl("opaque extension content", available_serialized, fixed = TRUE),
  !grepl("opaque state content", available_serialized, fixed = TRUE),
  !grepl(project_root, available_serialized, fixed = TRUE)
)

copy_parent <- file.path(suite_root, "portable-copy-parent")
copied_root <- rrp_doctor_copy_project(project_root, copy_parent)
copied_context <- rrp_load_project(catalog, copied_root)
copied_result <- rrp_validate_project(catalog, copied_root)
stopifnot(
  identical(copied_result, available),
  identical(copied_context$manifest[["Project-ID"]], available$value$project_id),
  identical(copied_context$producer$component_id, available$value$producer$component_id),
  identical(copied_context$provider$component_id, available$value$provider$component_id),
  !grepl(project_root, paste(capture.output(str(copied_result)), collapse = " "), fixed = TRUE)
)

# A trusted registration may have side effects, so explicit counters establish
# that the doctor performs exactly one load and never invokes selected callables.
count_path <- file.path(suite_root, "registration-count")
Sys.setenv(
  RRP_DOCTOR_REGISTRATION_COUNT = count_path,
  RRP_DOCTOR_SELECTED_CALLED = "no"
)
on.exit(Sys.unsetenv(c(
  "RRP_DOCTOR_REGISTRATION_COUNT", "RRP_DOCTOR_SELECTED_CALLED"
)), add = TRUE)
instrumented <- c(
  "rrp_register_project <- function(project_root) {",
  "  count_path <- Sys.getenv('RRP_DOCTOR_REGISTRATION_COUNT')",
  "  count <- if (file.exists(count_path)) as.integer(readLines(count_path)) else 0L",
  "  writeLines(as.character(count + 1L), count_path)",
  "  unavailable <- function(request) { Sys.setenv(RRP_DOCTOR_SELECTED_CALLED = 'yes') }",
  "  capabilities <- list(list(capability_id = 'rrp.capability.discharge-episode', status = 'available'), list(capability_id = 'rrp.capability.terminal-event', status = 'available'))",
  "  producer <- list(component_id = 'doctor-project.producer', component_version = '2.4.0', producer_api_id = 'rrp.producer-api', producer_api_version = '0.1.0', canonical_bundle_id = 'rrp.canonical-bundle', canonical_bundle_version = '0.1.0', canonical_profile_id = 'rrp.canonical-profile.readmission', canonical_profile_version = '0.1.0', implementation_id = 'doctor-project.implementation', implementation_version = '2.4.0', mapping_id = 'doctor-project.mapping', mapping_version = '2.4.0', capabilities = capabilities, callable = unavailable)",
  "  provider <- list(component_id = 'doctor-project.provider', component_version = '2.4.0', provider_api_id = 'rrp.provider-api', provider_api_version = '0.1.0', target_id = 'rrp.risk-target.readmission-remaining-30-day', target_version = '0.1.0', state_contract_id = 'rrp.episode-state', state_contract_version = '0.1.0', request_contract_id = 'rrp.risk-request', request_contract_version = '0.1.0', estimate_contract_id = 'rrp.risk-estimate', estimate_contract_version = '0.1.0', implementation_id = 'doctor-project.implementation', implementation_version = '2.4.0', model_id = NULL, model_version = NULL, callable = unavailable)",
  "  list(registration_contract_id = 'rrp.project-registration',",
  "    registration_contract_version = '0.3.0', project_id = 'doctor-project',",
  "    producers = list(producer), providers = list(provider)) ",
  "}"
)
writeLines(instrumented, file.path(project_root, "R", "register.R"), useBytes = TRUE)
registration_before <- readLines(file.path(project_root, "R", "register.R"), warn = FALSE)
counted <- rrp_validate_project(catalog, project_root)
stopifnot(
  identical(counted$status, "success"),
  identical(readLines(count_path), "1"),
  identical(Sys.getenv("RRP_DOCTOR_SELECTED_CALLED"), "no"),
  identical(
    readLines(file.path(project_root, "R", "register.R"), warn = FALSE),
    registration_before
  )
)

# Each case begins from the pristine initialized two-file project so loader-
# owned failure categories are translated without parallel doctor validation.
pristine <- file.path(suite_root, "pristine")
stopifnot(rrp_operation_succeeded(rrp_initialize_project(
  catalog, pristine, "adversarial-project", "1.0.0"
)))
case_number <- 0L
new_case <- function() {
  case_number <<- case_number + 1L
  rrp_doctor_copy_project(
    pristine, file.path(suite_root, paste0("case-", case_number))
  )
}
check_case <- function(root, code, secret = "DOCTOR-SECRET") {
  result <- rrp_validate_project(catalog, root)
  if (!identical(result$status, "failure") ||
      !identical(result$diagnostics[[1L]]$code, code)) {
    actual <- if (length(result$diagnostics)) {
      result$diagnostics[[1L]]$code
    } else {
      result$status
    }
    stop(
      "unexpected doctor case ", case_number, ": ", actual,
      "; expected ", code, call. = FALSE
    )
  }
  rrp_doctor_expect_failure(
    result, code,
    c(root, suite_root, secret, "selected callable executed")
  )
}

case <- new_case()
writeLines("not dcf DOCTOR-SECRET", file.path(case, "rrp-project.dcf"))
check_case(case, "malformed_project_manifest")

case <- new_case()
rrp_doctor_replace_manifest(
  case, "^Supported-RRP-API-Version:.*$",
  "Supported-RRP-API-Version: 9.9.9"
)
check_case(case, "incompatible_project_api")

case <- new_case()
rrp_doctor_replace_manifest(case, "^State-Path:.*$", "State-Path: ../DOCTOR-SECRET")
check_case(case, "unsafe_project_path")

case <- new_case()
unlink(file.path(case, "R", "register.R"))
check_case(case, "missing_project_registration")

case <- new_case()
registration_path <- file.path(case, "R", "register.R")
registration <- readLines(registration_path, warn = FALSE)
registration <- sub(
  "project_id = 'adversarial-project'",
  "project_id = 'different-project'", registration, fixed = TRUE
)
writeLines(registration, registration_path, useBytes = TRUE)
check_case(case, "project_identity_mismatch")

case <- new_case()
registration <- readLines(file.path(case, "R", "register.R"), warn = FALSE)
registration <- gsub(
  "adversarial-project.producer", "rrp.protected", registration, fixed = TRUE
)
writeLines(registration, file.path(case, "R", "register.R"), useBytes = TRUE)
rrp_doctor_replace_manifest(
  case, "^Producer-ID:.*$", "Producer-ID: rrp.protected"
)
check_case(case, "protected_registration")

case <- new_case()
registration <- readLines(file.path(case, "R", "register.R"), warn = FALSE)
registration <- sub(
  "producers = list(producer())",
  "producers = list(producer(), producer())",
  registration, fixed = TRUE
)
writeLines(registration, file.path(case, "R", "register.R"), useBytes = TRUE)
check_case(case, "duplicate_registration")

case <- new_case()
rrp_doctor_replace_manifest(
  case, "^Producer-ID:.*$", "Producer-ID: missing.producer"
)
check_case(case, "unknown_producer_selection")

case <- new_case()
rrp_doctor_replace_manifest(
  case, "^Provider-ID:.*$", "Provider-ID: missing.provider"
)
check_case(case, "unknown_provider_selection")

case <- new_case()
dir.create(file.path(case, "extensions"))
writeLines("not a directory", file.path(case, "extensions", "library"))
check_case(case, "invalid_extension_library")

case <- new_case()
writeLines("not a directory", file.path(case, "state"))
check_case(case, "invalid_state_location")

case <- new_case()
writeLines("stop('DOCTOR-SECRET')", file.path(case, "R", "register.R"))
check_case(case, "malformed_project_registration")

link_target <- file.path(suite_root, "link-target")
dir.create(link_target)
case <- new_case()
dir.create(file.path(case, "extensions"))
if (isTRUE(file.symlink(link_target, file.path(case, "extensions", "library")))) {
  check_case(case, "invalid_extension_library")
}
case <- new_case()
if (isTRUE(file.symlink(link_target, file.path(case, "state")))) {
  check_case(case, "invalid_state_location")
}

# A changed software authority remains a resource-owned failure rather than a
# project diagnostic, and arbitrary internal errors are not broadly swallowed.
resource_case <- new_case()
unlink(file.path(software_root, "resources", "contracts", "project-manifest.dcf"))
resource_condition <- tryCatch({
  rrp_validate_project(catalog, resource_case)
  NULL
}, error = identity)
stopifnot(
  inherits(resource_condition, "rrp_resource_error"),
  identical(resource_condition$code, "missing_resource")
)

unexpected <- tryCatch(
  rrp_doctor_internal("rrp_project_validation_success")(list()),
  error = identity
)
stopifnot(
  inherits(unexpected, "error"),
  !inherits(unexpected, "rrp_project_error"),
  !inherits(unexpected, "rrp_operation_result"),
  identical(getwd(), unrelated),
  identical(.libPaths(), previous_libraries),
  identical(ls(.GlobalEnv, all.names = TRUE), previous_globals)
)
})
