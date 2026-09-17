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
  "Project-Contract-Version: 0.2.0",
  "Project-ID: @@RRP_PROJECT_ID@@",
  "Project-Version: @@RRP_PROJECT_VERSION@@",
  "Project-Scope: one_health_system",
  "Supported-RRP-API-Version: 0.2.0",
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
  "  if (!is.character(project_root) || length(project_root) != 1L ||",
  "      is.na(project_root) || !nzchar(project_root)) {",
  "    stop(\"Project root is invalid.\", call. = FALSE)",
  "  }",
  "  capabilities <- list(",
  "    list(capability_id = \"rrp.capability.discharge-episode\", status = \"available\"),",
  "    list(capability_id = \"rrp.capability.terminal-event\", status = \"available\")",
  "  )",
  "  unavailable_producer <- function(request) {",
  "    Sys.setenv(RRP_INIT_SELECTED_CALLED = \"yes\")",
  "    list(producer_contract_id = \"rrp.canonical-producer\",",
  "         producer_contract_version = \"0.1.0\", status = \"failed\",",
  "         producer_id = \"@@RRP_PRODUCER_ID@@\", producer_version = \"@@RRP_PROJECT_VERSION@@\",",
  "         implementation_id = \"@@RRP_IMPLEMENTATION_ID@@\", implementation_version = \"@@RRP_PROJECT_VERSION@@\",",
  "         mapping_id = \"@@RRP_MAPPING_ID@@\", mapping_version = \"@@RRP_PROJECT_VERSION@@\",",
  "         canonical_profile_id = \"rrp.canonical-profile.readmission\", canonical_profile_version = \"0.1.0\",",
  "         canonical_as_of_time = request$as_of_time, capabilities = capabilities,",
  "         candidate_bundle = NULL, failure_code = \"producer_unavailable\")",
  "  }",
  "  unavailable_provider <- function(...) {",
  "    Sys.setenv(RRP_INIT_SELECTED_CALLED = \"yes\")",
  "    stop(\"Initialized structural component has no execution behavior.\", call. = FALSE)",
  "  }",
  "  list(",
  "    registration_contract_id = \"rrp.project-registration\",",
  "    registration_contract_version = \"0.2.0\",",
  "    project_id = \"@@RRP_PROJECT_ID@@\",",
  "    producers = list(list(",
  "      component_id = \"@@RRP_PRODUCER_ID@@\",",
  "      component_version = \"@@RRP_PROJECT_VERSION@@\",",
  "      producer_api_id = \"rrp.producer-api\",",
  "      producer_api_version = \"0.1.0\",",
  "      canonical_bundle_id = \"rrp.canonical-bundle\",",
  "      canonical_bundle_version = \"0.1.0\",",
  "      canonical_profile_id = \"rrp.canonical-profile.readmission\",",
  "      canonical_profile_version = \"0.1.0\",",
  "      implementation_id = \"@@RRP_IMPLEMENTATION_ID@@\",",
  "      implementation_version = \"@@RRP_PROJECT_VERSION@@\",",
  "      mapping_id = \"@@RRP_MAPPING_ID@@\",",
  "      mapping_version = \"@@RRP_PROJECT_VERSION@@\",",
  "      capabilities = capabilities,",
  "      callable = unavailable_producer",
  "    )),",
  "    providers = list(list(",
  "      component_id = \"@@RRP_PROVIDER_ID@@\",",
  "      component_version = \"@@RRP_PROJECT_VERSION@@\",",
  "      callable = unavailable_provider",
  "    ))",
  "  )",
  "}"
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
  canonical_definitions <- rrp_init_internal(
    "rrp_canonical_contract_definitions"
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
  rrp_init_write_record(
    registration_contract,
    file.path(root, "resources", "contracts", "project-registration.dcf")
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

  entries <- list(
    c("rrp.contract.resource-catalog", "contract", "resources/resource-catalog-schema.dcf", "dcf", "rrpplatform"),
    c("rrp.contract.diagnostic", "contract", "resources/contracts/diagnostic.dcf", "dcf", "rrpplatform"),
    c("rrp.contract.operation-result", "contract", "resources/contracts/operation-result.dcf", "dcf", "rrpplatform"),
    c("rrp.contract.project-manifest", "contract", "resources/contracts/project-manifest.dcf", "dcf", "rrpplatform"),
    c("rrp.contract.project-registration", "contract", "resources/contracts/project-registration.dcf", "dcf", "rrpplatform"),
    c("rrp.template.project-manifest", "template", "resources/templates/project/rrp-project.dcf", "dcf", "rrpplatform"),
    c("rrp.template.project-registration", "template", "resources/templates/project/R/register.R", "r", "rrpplatform")
  )
  entries <- c(entries, lapply(canonical_definitions, function(definition) c(
    definition$resource_id, "contract", definition$path, "dcf", definition$owner
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
  implementation_id = "example-health.implementation",
  implementation_version = "2.3.4-rc.1",
  mapping_id = "example-health.mapping",
  mapping_version = "2.3.4-rc.1",
  canonical_profile_id = "rrp.canonical-profile.readmission",
  canonical_profile_version = "0.1.0",
  provider_id = "example-health.provider",
  provider_version = "2.3.4-rc.1",
  created_paths = c("rrp-project.dcf", "R/register.R")
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
  )), c("R/register.R", "rrp-project.dcf")),
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
  identical(context$producer$implementation_id, "example-health.implementation"),
  identical(context$producer$mapping_id, "example-health.mapping"),
  identical(context$producer$capabilities, rrp_init_internal(
    "rrp_canonical_required_capabilities"
  )(rrp_init_internal("rrp_canonical_contracts")(catalog))),
  identical(context$provider$component_id, "example-health.provider"),
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
  c(file.path(destination, "rrp-project.dcf"), file.path(destination, "R", "register.R")),
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
    "rrp_execute_producer", "rrp_initialize_project", "rrp_load_project",
    "rrp_open_resource_catalog",
    "rrp_operation_succeeded", "rrp_resource_path",
    "rrp_validate_project",
    "rrp_validate_software_resources"
  ))
)

cat("rrpplatform project-initializer tests passed\n")
})
