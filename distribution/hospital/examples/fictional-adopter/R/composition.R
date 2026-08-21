# Trusted composition for the shipped fictional adopter example.

rrp_adopter_fixture_root <- function(repository_root) file.path(
  repository_root, "examples", "fictional-adopter"
)

rrp_source_hospital_fictional_adopter <- function(distribution_root) {
  directory <- file.path(distribution_root, "examples", "fictional-adopter", "R")
  for (file in c("foundation.R", "source-validation.R", "mapping.R", "adapter.R")) {
    sys.source(file.path(directory, file), envir = .GlobalEnv)
  }
  # foundation.R carries the original test location helper; replace it with the
  # generated distribution's explicit example location.
  assign("rrp_adopter_fixture_root", function(repository_root) file.path(
    repository_root, "examples", "fictional-adopter"
  ), envir = .GlobalEnv)
  invisible(TRUE)
}

rrp_hospital_fictional_adopter_composition <- function(
  distribution_root,
  platform_root,
  source_override = NULL
) {
  rrp_source_hospital_fictional_adopter(distribution_root)
  contract <- rrp_read_canonical_producer_contract(platform_root)
  configuration <- rrp_adopter_fixture_read_yaml(
    distribution_root, "platform-instance.yml"
  )
  rrp_validate_platform_instance_configuration(configuration)
  declaration <- rrp_read_adopter_fixture_declaration(distribution_root)
  registry <- rrp_new_canonical_producer_registry()
  rrp_register_canonical_producer(
    registry, declaration,
    rrp_adopter_fixture_adapter(distribution_root, source_override), contract
  )
  list(
    configuration = configuration,
    selection = configuration$selected_canonical_producer,
    registry = registry,
    contract = contract
  )
}
