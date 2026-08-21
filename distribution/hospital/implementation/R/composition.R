# Fixed trusted composition for the editable local scaffold. Declarations and
# selection remain data; this reviewed code performs the executable pairing.

rrp_local_hospital_composition <- function(distribution_root, platform_root) {
  declaration <- yaml::read_yaml(file.path(
    distribution_root, "implementation", "producer.yml"
  ))
  configuration <- yaml::read_yaml(file.path(
    distribution_root, "implementation", "platform-instance.yml"
  ))
  rrp_validate_platform_instance_configuration(configuration)
  sys.source(
    file.path(distribution_root, "implementation", "R", "producer.R"),
    envir = .GlobalEnv
  )
  contract <- rrp_read_canonical_producer_contract(platform_root)
  registry <- rrp_new_canonical_producer_registry()
  rrp_register_canonical_producer(
    registry, declaration,
    rrp_local_hospital_producer_adapter(distribution_root, declaration),
    contract
  )
  list(
    configuration = configuration,
    selection = configuration$selected_canonical_producer,
    registry = registry,
    contract = contract
  )
}
