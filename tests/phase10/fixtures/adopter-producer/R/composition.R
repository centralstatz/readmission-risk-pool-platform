# Isolated trusted test composition. It registers exactly one adopter producer;
# the normal installed composition continues to register exactly one reference
# producer from config/platform-instance.yml.

rrp_source_adopter_fixture_implementation <- function(repository_root) {
  directory <- file.path(
    repository_root, "tests", "phase10", "fixtures", "adopter-producer", "R"
  )
  for (file in c("foundation.R", "source-validation.R", "mapping.R", "adapter.R")) {
    sys.source(file.path(directory, file), envir = .GlobalEnv)
  }
  invisible(NULL)
}

rrp_adopter_fixture_composition <- function(repository_root, source_override = NULL) {
  rrp_source_adopter_fixture_implementation(repository_root)
  contract <- rrp_read_canonical_producer_contract(repository_root)
  configuration <- rrp_adopter_fixture_read_yaml(repository_root, "platform-instance.yml")
  rrp_validate_platform_instance_configuration(configuration)
  declaration <- rrp_read_adopter_fixture_declaration(repository_root)
  registry <- rrp_new_canonical_producer_registry()
  rrp_register_canonical_producer(
    registry, declaration,
    rrp_adopter_fixture_adapter(repository_root, source_override), contract
  )
  list(
    configuration = configuration,
    selection = configuration$selected_canonical_producer,
    registry = registry,
    contract = contract
  )
}

rrp_run_adopter_fixture_producer <- function(
  repository_root,
  as_of_time = NULL,
  producer_execution_id = "producer_adopter_conformance_001",
  source_override = NULL,
  event_emitter = NULL
) {
  composition <- rrp_adopter_fixture_composition(repository_root, source_override)
  selection <- composition$selection
  invocation <- list(
    producer_execution_id = producer_execution_id,
    canonical_as_of_time = as_of_time,
    producer_configuration = list(scenario_id = "fictional_export_case_v1")
  )
  rrp_execute_canonical_producer(
    composition$registry, selection$producer_id, selection$producer_version,
    invocation, repository_root, event_emitter
  )
}
