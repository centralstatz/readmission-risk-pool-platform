rrp_project_validation_failure <- function(condition) {
  diagnostic <- rrp_new_diagnostic(
    code = condition$code,
    severity = "error",
    message = "RRP project validation failed."
  )
  rrp_new_operation_result(
    operation_id = "rrp.validate-project",
    status = "failure",
    value = NULL,
    diagnostics = list(diagnostic)
  )
}

rrp_project_location_status <- function(path) {
  if (dir.exists(path)) "available" else "not_initialized"
}

rrp_project_validation_success <- function(context) {
  extension_library_status <- rrp_project_location_status(
    context$extension_library_path
  )
  state_status <- rrp_project_location_status(context$state_path)
  diagnostics <- if (identical(state_status, "not_initialized")) {
    list(rrp_new_diagnostic(
      code = "project_state_not_initialized",
      severity = "warning",
      message = "Project state has not been initialized."
    ))
  } else {
    list()
  }

  value <- list(
    project_id = context$manifest[["Project-ID"]],
    project_version = context$manifest[["Project-Version"]],
    project_contract_id = context$manifest[["Project-Contract-ID"]],
    project_contract_version = context$manifest[["Project-Contract-Version"]],
    supported_rrp_api_version = context$manifest[["Supported-RRP-API-Version"]],
    producer = list(
      component_id = context$producer$component_id,
      component_version = context$producer$component_version,
      origin = context$producer$origin
    ),
    provider = list(
      component_id = context$provider$component_id,
      component_version = context$provider$component_version,
      origin = context$provider$origin
    ),
    extension_library_status = extension_library_status,
    state_status = state_status
  )
  rrp_new_operation_result(
    operation_id = "rrp.validate-project",
    status = "success",
    value = value,
    diagnostics = diagnostics
  )
}

#' Validate an explicit independent RRP project
#'
#' Load one explicit project through the authoritative project loader and
#' translate its structural identity and declared location status into a
#' bounded operation result. This operation executes the trusted registration
#' boundary but never invokes the selected producer or provider.
#'
#' @param software_catalog A validated `rrp_resource_catalog` returned by
#'   [rrp_open_resource_catalog()].
#' @param project_root One explicit existing independent project directory.
#' @return One validated `rrp_operation_result`.
#' @export
rrp_validate_project <- function(software_catalog, project_root) {
  tryCatch(
    rrp_project_validation_success(rrp_load_project(
      software_catalog = software_catalog,
      project_root = project_root
    )),
    rrp_project_error = rrp_project_validation_failure
  )
}
