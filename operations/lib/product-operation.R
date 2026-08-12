# Human-operation composition for the backend-neutral logical product layer.
# Contract parsing and concrete adapter opening stay outside products/R.

rrp_product_contract_paths <- function(repository_root) c(
  product_set = file.path(
    repository_root, "contracts", "products", "initial-risk-product-set.yml"
  ),
  current_episode_risk = file.path(
    repository_root, "contracts", "products", "current-episode-risk.yml"
  ),
  episode_risk_history = file.path(
    repository_root, "contracts", "products", "episode-risk-history.yml"
  ),
  operational_run_summary = file.path(
    repository_root, "contracts", "products", "operational-run-summary.yml"
  )
)

rrp_read_product_contracts <- function(repository_root) {
  paths <- rrp_product_contract_paths(repository_root)
  contracts <- lapply(paths, function(path) {
    parsed <- rrp_parse_yaml_specification(path)
    if (!is.null(parsed$error)) stop(
      "Could not read logical product contract: ", parsed$error,
      call. = FALSE
    )
    parsed$document
  })
  names(contracts) <- names(paths)
  contracts
}

rrp_load_product_layer <- function(repository_root) {
  directory <- file.path(repository_root, "products", "R")
  for (file in c("foundation.R", "conformance.R", "builders.R", "access.R")) {
    sys.source(file.path(directory, file), envir = parent.frame())
  }
  invisible(TRUE)
}

rrp_product_generated_at <- function() {
  format(Sys.time(), "%Y-%m-%dT%H:%M:%SZ", tz = "UTC")
}

rrp_reference_product_cutoff <- function(port, source_run_ids) {
  terminal <- lapply(source_run_ids, function(run_id) {
    history <- rrpruntime::read_run_history(port, run_id, "valid")
    statuses <- Filter(function(value) value$run_status %in% c(
      "completed", "completed_with_failures"
    ), history$operational_run)
    if (length(statuses) != 1L) stop(
      "Selected run has no single valid completed terminal status: ", run_id,
      call. = FALSE
    )
    statuses[[1L]]
  })
  numbers <- vapply(terminal, function(value) {
    rrp_product_time_number(value$as_of_time)
  }, numeric(1))
  terminal[[which.max(numbers)]]$as_of_time
}

rrp_build_reference_products <- function(
  repository_root,
  database_path,
  source_run_ids,
  source_cutoff_time = NULL,
  product_generated_at = rrp_product_generated_at()
) {
  history_contracts <- rrp_read_history_contracts(repository_root)
  product_contracts <- rrp_read_product_contracts(repository_root)
  session <- rrp_open_duckdb_persistence(
    database_path,
    history_contracts,
    read_only = TRUE
  )
  on.exit(rrp_close_duckdb_persistence(session), add = TRUE)
  port <- rrp_duckdb_persistence_port(session)
  source_run_ids <- sort(unique(source_run_ids), method = "radix")
  if (is.null(source_cutoff_time)) source_cutoff_time <-
    rrp_reference_product_cutoff(port, source_run_ids)
  result <- rrp_build_logical_product_set(
    port,
    source_run_ids,
    source_cutoff_time,
    product_generated_at,
    product_contracts
  )
  if (!identical(result$overall_status, "succeeded")) stop(
    "Logical product build failed at ", result$failure_stage, ": ", result$message,
    call. = FALSE
  )
  result
}

rrp_reference_product_summary <- function(result) {
  list(
    product_set_id = result$product_set$product_set_id,
    product_build_id = result$product_set$product_build_id,
    source_runtime_run_ids = result$product_set$source_runtime_run_ids,
    latest_source_runtime_run_id = result$product_set$latest_source_runtime_run_id,
    source_cutoff_time = result$product_set$source_cutoff_time,
    source_as_of_time = result$product_set$source_as_of_time,
    product_generated_at = result$product_set$product_generated_at,
    products = lapply(result$products, function(product) list(
      product_id = product$product_specification$specification_id,
      product_version = product$product_specification$specification_version,
      availability_status = product$availability_status,
      row_count = product$row_count
    ))
  )
}

