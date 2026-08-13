# Read-only YAML realization of logical product access. It is separated from
# materialization so a reduced application artifact carries no product writer.

rrp_yaml_product_access <- function(validation) {
  if (!inherits(validation, "rrp_yaml_bundle_validation_result") ||
      !identical(validation$overall_status, "pass")) stop(
    "Physical product access requires a fully validated bundle.", call. = FALSE
  )
  product_set <- rrp_product_copy(validation$manifest$product_set)
  products <- rrp_product_copy(validation$products)
  list_products <- function() lapply(products, function(product) list(
    product_specification = product$product_specification,
    product_set_id = product$product_set_id,
    availability_status = product$availability_status,
    row_count = product$row_count,
    source_as_of_time = product$source_as_of_time,
    product_generated_at = product$product_generated_at
  ))
  read_product <- function(product_id, product_version, product_set_id) {
    if (!identical(product_set_id, product_set$product_set_id)) stop(
      "Requested product set is not available through this access instance.",
      call. = FALSE
    )
    matches <- Filter(function(product) {
      identical(product$product_specification$specification_id, product_id) &&
        identical(product$product_specification$specification_version, product_version)
    }, products)
    if (length(matches) != 1L) stop(
      "Requested logical product identity/version is not available.", call. = FALSE
    )
    rrp_product_copy(matches[[1L]])
  }
  read_product_metadata <- function(product_id, product_version, product_set_id) {
    product <- read_product(product_id, product_version, product_set_id)
    product$rows <- NULL
    product
  }
  structure(list(
    list_products = list_products,
    read_product = read_product,
    read_product_metadata = read_product_metadata,
    freshness = function() rrp_product_copy(validation$freshness)
  ), class = c("rrp_yaml_product_access", "rrp_logical_product_access"))
}

rrp_open_yaml_product_access <- function(
  store_path,
  materialization_contract,
  adapter_declaration,
  product_contracts
) {
  validation <- rrp_validate_yaml_product_bundle(
    store_path,
    materialization_contract,
    adapter_declaration,
    product_contracts
  )
  if (!identical(validation$overall_status, "pass")) {
    failed <- names(Filter(function(value) identical(value, "fail"), validation$categories))
    return(structure(list(
      overall_status = "failed",
      failure_category = failed[[1L]],
      message = paste0(
        "Materialized product access failed ", failed[[1L]], " validation."
      ),
      validation = validation,
      access = NULL
    ), class = "rrp_product_access_open_result"))
  }
  structure(list(
    overall_status = "succeeded",
    failure_category = NULL,
    message = "Complete materialized product set validated and opened.",
    validation = validation,
    access = rrp_yaml_product_access(validation)
  ), class = "rrp_product_access_open_result")
}
