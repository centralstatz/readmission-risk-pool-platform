# Application initialization depends only on the logical product-access method
# set. It has no knowledge of materialization paths, YAML, DuckDB, runtime, or
# source/provider implementations.

rrp_app_required_products <- function() list(
  current_episode_risk = list(
    product_id = "platform.current-episode-risk",
    product_version = "0.1.0"
  ),
  episode_risk_history = list(
    product_id = "platform.episode-risk-history",
    product_version = "0.1.0"
  ),
  operational_run_summary = list(
    product_id = "platform.operational-run-summary",
    product_version = "0.1.0"
  )
)

rrp_app_failure <- function(category, message) structure(list(
  overall_status = "failed",
  failure_category = category,
  message = message,
  products = list(),
  freshness = NULL
), class = "rrp_app_initialization_result")

rrp_initialize_reference_app <- function(access) {
  methods <- c("list_products", "read_product", "read_product_metadata")
  if (!is.list(access) || !all(vapply(methods, function(name) {
    is.function(access[[name]])
  }, logical(1)))) return(rrp_app_failure(
    "product_access",
    "A validated product-access instance with list/read/metadata methods is required."
  ))
  available <- tryCatch(access$list_products(), error = function(value) value)
  if (inherits(available, "condition") || !is.list(available)) return(rrp_app_failure(
    "product_access",
    "Products could not be listed. Validate or rebuild the materialized product set."
  ))
  required <- rrp_app_required_products()
  loaded <- list()
  for (name in names(required)) {
    reference <- required[[name]]
    matches <- Filter(function(metadata) identical(
      metadata$product_specification$specification_id,
      reference$product_id
    ) && identical(
      metadata$product_specification$specification_version,
      reference$product_version
    ), available)
    if (length(matches) != 1L) return(rrp_app_failure(
      "app_compatibility",
      paste0("Required product is unavailable or ambiguous: ", reference$product_id, "@",
        reference$product_version, "."
      )
    ))
    value <- tryCatch(access$read_product(
      reference$product_id,
      reference$product_version,
      matches[[1L]]$product_set_id
    ), error = function(value) value)
    if (inherits(value, "condition")) return(rrp_app_failure(
      "product_access",
      paste0("Required product could not be read: ", reference$product_id, ".")
    ))
    loaded[[name]] <- value
  }
  common_fields <- c(
    "product_set_id", "source_cutoff_time", "source_as_of_time",
    "latest_source_runtime_run_id", "source_runtime_run_ids", "product_generated_at"
  )
  first <- loaded[[1L]]
  coherent <- all(vapply(loaded, function(product) {
    is.list(product) && identical(product$availability_status, "available") &&
      is.list(product$rows) && identical(as.integer(product$row_count), length(product$rows)) &&
      all(vapply(common_fields, function(field) identical(
        product[[field]], first[[field]]
      ), logical(1)))
  }, logical(1)))
  if (!coherent) return(rrp_app_failure(
    "app_coherence",
    "Required products do not form one coherent available product set."
  ))
  freshness <- list(
    source_cutoff_time = first$source_cutoff_time,
    source_as_of_time = first$source_as_of_time,
    latest_source_runtime_run_id = first$latest_source_runtime_run_id,
    product_generated_at = first$product_generated_at,
    staleness_assessment = "not_evaluated_no_platform_threshold"
  )
  if (is.function(access$freshness)) freshness <- access$freshness()
  structure(list(
    overall_status = "succeeded",
    failure_category = NULL,
    message = "Application products loaded through validated product access.",
    products = loaded,
    freshness = freshness
  ), class = "rrp_app_initialization_result")
}
