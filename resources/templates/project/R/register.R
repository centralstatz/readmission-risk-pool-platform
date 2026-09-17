rrp_register_project <- function(project_root) {
  if (!is.character(project_root) || length(project_root) != 1L ||
      is.na(project_root) || !nzchar(project_root)) {
    stop("Project root is invalid.", call. = FALSE)
  }

  unavailable <- function(...) {
    stop("Initialized structural component has no execution behavior.", call. = FALSE)
  }

  list(
    registration_contract_id = "rrp.project-registration",
    registration_contract_version = "0.1.0",
    project_id = "@@RRP_PROJECT_ID@@",
    producers = list(list(
      component_id = "@@RRP_PRODUCER_ID@@",
      component_version = "@@RRP_PROJECT_VERSION@@",
      callable = unavailable
    )),
    providers = list(list(
      component_id = "@@RRP_PROVIDER_ID@@",
      component_version = "@@RRP_PROJECT_VERSION@@",
      callable = unavailable
    ))
  )
}
