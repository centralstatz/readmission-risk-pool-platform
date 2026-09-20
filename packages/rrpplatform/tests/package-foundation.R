library(rrpplatform)

description <- utils::packageDescription("rrpplatform")
namespace_imports <- getNamespaceImports("rrpplatform")

stopifnot(
  identical(description[["Package"]], "rrpplatform"),
  identical(as.character(utils::packageVersion("rrpplatform")), "0.1.0.9000"),
  identical(description[["Depends"]], "R (>= 4.4.0)"),
  identical(description[["Imports"]], "DBI, duckdb, rrpruntime"),
  is.null(description[["Suggests"]]),
  is.null(description[["LinkingTo"]]),
  "rrpruntime" %in% names(namespace_imports),
  identical(as.character(utils::packageVersion("rrpruntime")), "0.4.0.9000"),
  identical(
    sort(getNamespaceExports("rrpplatform")),
    c(
      "rrp_execute_producer", "rrp_execute_risk", "rrp_initialize_project",
      "rrp_initialize_project_state", "rrp_inspect_project_state",
      "rrp_load_project",
      "rrp_open_resource_catalog",
      "rrp_operation_succeeded",
      "rrp_resource_path", "rrp_validate_project",
      "rrp_validate_software_resources"
    )
  ),
  is.function(rrp_execute_producer),
  is.function(rrp_execute_risk),
  is.function(rrp_initialize_project),
  is.function(rrp_initialize_project_state),
  is.function(rrp_inspect_project_state),
  is.function(rrp_load_project),
  is.function(rrp_open_resource_catalog),
  is.function(rrp_operation_succeeded),
  is.function(rrp_resource_path),
  is.function(rrp_validate_project),
  is.function(rrp_validate_software_resources)
)
