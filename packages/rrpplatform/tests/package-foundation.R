library(rrpplatform)

description <- utils::packageDescription("rrpplatform")
namespace_imports <- getNamespaceImports("rrpplatform")
description_imports <- trimws(strsplit(
  gsub("[[:space:]]+", " ", description[["Imports"]]), ",", fixed = TRUE
)[[1L]])

stopifnot(
  identical(description[["Package"]], "rrpplatform"),
  identical(as.character(utils::packageVersion("rrpplatform")), "0.1.0.9000"),
  identical(description[["Depends"]], "R (>= 4.4.0)"),
  identical(description_imports, c(
    "DBI", "duckdb", "rrpruntime", "shiny", "bslib", "plotly",
    "reactable", "brand.yml"
  )),
  is.null(description[["Suggests"]]),
  is.null(description[["LinkingTo"]]),
  "rrpruntime" %in% names(namespace_imports),
  identical(as.character(utils::packageVersion("rrpruntime")), "0.4.0.9000"),
  identical(
    sort(getNamespaceExports("rrpplatform")),
    c(
      "rrp_authoring_failure", "rrp_backup_project_state",
      "rrp_build_and_materialize_products",
      "rrp_build_product_set",
      "rrp_cli_dispatch",
      "rrp_execute_durable_bundle",
      "rrp_execute_producer", "rrp_execute_risk",
      "rrp_initialize_fictional_project",
      "rrp_initialize_project",
      "rrp_initialize_project_state",
      "rrp_inspect_current_history", "rrp_inspect_episode_history",
      "rrp_inspect_project_state", "rrp_inspect_scope_history",
      "rrp_invalidate_history",
      "rrp_launch_app",
      "rrp_list_products", "rrp_load_project",
      "rrp_materialize_product_set",
      "rrp_open_product_access",
      "rrp_open_resource_catalog",
      "rrp_operation_succeeded",
      "rrp_prepare_fictional_source", "rrp_project_status",
      "rrp_read_product", "rrp_register_authored_project", "rrp_resource_path",
      "rrp_restate_history", "rrp_restore_project_state",
      "rrp_retry_episode",
      "rrp_validate_project",
      "rrp_validate_software_resources"
    )
  ),
  is.function(rrp_authoring_failure),
  is.function(rrp_backup_project_state),
  is.function(rrp_build_and_materialize_products),
  is.function(rrp_build_product_set),
  is.function(rrp_cli_dispatch),
  is.function(rrp_execute_producer),
  is.function(rrp_execute_durable_bundle),
  is.function(rrp_execute_risk),
  is.function(rrp_initialize_fictional_project),
  is.function(rrp_initialize_project),
  is.function(rrp_initialize_project_state),
  is.function(rrp_inspect_project_state),
  is.function(rrp_inspect_current_history),
  is.function(rrp_inspect_episode_history),
  is.function(rrp_inspect_scope_history),
  is.function(rrp_invalidate_history),
  is.function(rrp_launch_app),
  is.function(rrp_list_products),
  is.function(rrp_load_project),
  is.function(rrp_materialize_product_set),
  is.function(rrp_open_product_access),
  is.function(rrp_open_resource_catalog),
  is.function(rrp_register_authored_project),
  is.function(rrp_operation_succeeded),
  is.function(rrp_prepare_fictional_source),
  is.function(rrp_project_status),
  is.function(rrp_resource_path),
  is.function(rrp_read_product),
  is.function(rrp_restate_history),
  is.function(rrp_restore_project_state),
  is.function(rrp_retry_episode),
  is.function(rrp_validate_project),
  is.function(rrp_validate_software_resources)
)
