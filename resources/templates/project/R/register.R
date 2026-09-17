rrp_register_project <- function(project_root) {
  if (!is.character(project_root) || length(project_root) != 1L ||
      is.na(project_root) || !nzchar(project_root)) {
    stop("Project root is invalid.", call. = FALSE)
  }

  capabilities <- list(
    list(
      capability_id = "rrp.capability.discharge-episode",
      status = "available"
    ),
    list(
      capability_id = "rrp.capability.terminal-event",
      status = "available"
    )
  )

  unavailable_producer <- function(request) {
    list(
      producer_contract_id = "rrp.canonical-producer",
      producer_contract_version = "0.1.0",
      status = "failed",
      producer_id = "@@RRP_PRODUCER_ID@@",
      producer_version = "@@RRP_PROJECT_VERSION@@",
      implementation_id = "@@RRP_IMPLEMENTATION_ID@@",
      implementation_version = "@@RRP_PROJECT_VERSION@@",
      mapping_id = "@@RRP_MAPPING_ID@@",
      mapping_version = "@@RRP_PROJECT_VERSION@@",
      canonical_profile_id = "rrp.canonical-profile.readmission",
      canonical_profile_version = "0.1.0",
      canonical_as_of_time = request$as_of_time,
      capabilities = capabilities,
      candidate_bundle = NULL,
      failure_code = "producer_unavailable"
    )
  }

  unavailable_provider <- function(...) {
    stop("Initialized structural component has no execution behavior.", call. = FALSE)
  }

  list(
    registration_contract_id = "rrp.project-registration",
    registration_contract_version = "0.2.0",
    project_id = "@@RRP_PROJECT_ID@@",
    producers = list(list(
      component_id = "@@RRP_PRODUCER_ID@@",
      component_version = "@@RRP_PROJECT_VERSION@@",
      producer_api_id = "rrp.producer-api",
      producer_api_version = "0.1.0",
      canonical_bundle_id = "rrp.canonical-bundle",
      canonical_bundle_version = "0.1.0",
      canonical_profile_id = "rrp.canonical-profile.readmission",
      canonical_profile_version = "0.1.0",
      implementation_id = "@@RRP_IMPLEMENTATION_ID@@",
      implementation_version = "@@RRP_PROJECT_VERSION@@",
      mapping_id = "@@RRP_MAPPING_ID@@",
      mapping_version = "@@RRP_PROJECT_VERSION@@",
      capabilities = capabilities,
      callable = unavailable_producer
    )),
    providers = list(list(
      component_id = "@@RRP_PROVIDER_ID@@",
      component_version = "@@RRP_PROJECT_VERSION@@",
      callable = unavailable_provider
    ))
  )
}
