# Trusted composition for this installed platform instance. Declarations select
# no code: this maintained file explicitly pairs shipped code and declarations.

rrp_source_synthetic_reference_implementation <- function(repository_root) {
  for (file in c(
    "identity-configuration.R", "generate-source.R", "source-validation.R",
    "map-to-canonical.R", "producer.R", "canonical-producer-adapter.R"
  )) source(file.path(
    repository_root, "implementations", "synthetic-reference", "R", file
  ), local = .GlobalEnv)
  invisible(NULL)
}

rrp_validate_platform_instance_configuration <- function(configuration) {
  selection <- configuration$selected_canonical_producer
  valid <- identical(configuration$specification_kind, "platform_instance_configuration") &&
    rrp_is_identifier(configuration$specification_id) &&
    rrp_is_semver(configuration$specification_version) &&
    identical(configuration$producer_configuration_owner, "producer_implementation") &&
    identical(configuration$health_system_scope, "one") &&
    identical(configuration$multi_tenant, FALSE) &&
    rrp_is_identifier(selection$producer_id) &&
    rrp_is_semver(selection$producer_version) &&
    identical(sort(names(selection)), c("producer_id", "producer_version"))
  if (!valid) stop(
    "Platform-instance configuration must select one exact producer for one health system.",
    call. = FALSE
  )
  invisible(configuration)
}

rrp_read_platform_instance_configuration <- function(repository_root) {
  parsed <- rrp_parse_yaml_specification(file.path(
    repository_root, "config", "platform-instance.yml"
  ))
  if (!is.null(parsed$error)) stop(
    "Could not read platform-instance configuration: ", parsed$error,
    call. = FALSE
  )
  rrp_validate_platform_instance_configuration(parsed$document)
  parsed$document
}

rrp_installed_canonical_producer_composition <- function(repository_root) {
  contract <- rrp_read_canonical_producer_contract(repository_root)
  configuration <- rrp_read_platform_instance_configuration(repository_root)
  rrp_source_synthetic_reference_implementation(repository_root)
  declaration <- rrp_read_synthetic_producer_declaration(repository_root)
  registry <- rrp_new_canonical_producer_registry()
  rrp_register_canonical_producer(
    registry, declaration,
    rrp_synthetic_canonical_producer_adapter(repository_root), contract
  )
  list(
    configuration = configuration,
    selection = configuration$selected_canonical_producer,
    registry = registry,
    contract = contract
  )
}

rrp_run_installed_canonical_producer <- function(
  repository_root,
  scale = "test",
  as_of_time = NULL,
  producer_execution_id = NULL,
  event_emitter = NULL
) {
  composition <- rrp_installed_canonical_producer_composition(repository_root)
  selection <- composition$selection
  execution_id <- producer_execution_id %||% paste0(
    "producer_reference_", scale, "_001"
  )
  invocation <- list(
    producer_execution_id = execution_id,
    canonical_as_of_time = as_of_time,
    producer_configuration = list(scale = scale)
  )
  rrp_execute_canonical_producer(
    composition$registry,
    selection$producer_id,
    selection$producer_version,
    invocation,
    repository_root,
    event_emitter
  )
}
