# In-memory realization of the logical product-access boundary. It establishes
# the future app dependency without selecting a product store or format.

new_logical_product_access <- function(build_result) {
  if (!inherits(build_result, "rrp_product_build_result") ||
      !identical(build_result$overall_status, "succeeded")) stop(
    "Logical product access requires one successful complete product set.",
    call. = FALSE
  )
  product_set <- rrp_product_copy(build_result$product_set)
  products <- rrp_product_copy(build_result$products)
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
      "Requested logical product identity/version is not available.",
      call. = FALSE
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
    read_product_metadata = read_product_metadata
  ), class = "rrp_logical_product_access")
}
