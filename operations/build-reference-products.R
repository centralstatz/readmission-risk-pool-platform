#!/usr/bin/env Rscript

file_argument <- grep("^--file=", commandArgs(trailingOnly = FALSE), value = TRUE)
script_path <- normalizePath(sub("^--file=", "", file_argument[[1L]]), mustWork = TRUE)
repository_root <- normalizePath(file.path(dirname(script_path), ".."), mustWork = TRUE)
for (file in c(
  "validation-result.R", "conformance-result.R", "specification-validation.R",
  "history-validation.R", "runtime-operation.R", "duckdb-persistence-operation.R",
  "product-operation.R"
)) source(file.path(repository_root, "operations", "lib", file))
rrp_load_duckdb_persistence_adapter(repository_root)
rrp_load_product_layer(repository_root)

arguments <- commandArgs(trailingOnly = TRUE)
database_path <- NULL
scale <- "test"
source_run_ids <- character()
while (length(arguments) > 0L) {
  if (length(arguments) >= 2L && identical(arguments[[1L]], "--database")) {
    database_path <- arguments[[2L]]
    arguments <- arguments[-c(1L, 2L)]
  } else if (length(arguments) >= 2L && identical(arguments[[1L]], "--scale")) {
    scale <- arguments[[2L]]
    arguments <- arguments[-c(1L, 2L)]
  } else if (length(arguments) >= 2L && identical(arguments[[1L]], "--run-id")) {
    source_run_ids <- c(source_run_ids, arguments[[2L]])
    arguments <- arguments[-c(1L, 2L)]
  } else {
    message(paste(
      "Usage: Rscript operations/build-reference-products.R",
      "[--database PATH] [--scale test|reference] [--run-id ID ...]"
    ))
    quit(save = "no", status = 2L, runLast = FALSE)
  }
}
if (!scale %in% c("test", "reference")) {
  message("Scale must be test or reference.")
  quit(save = "no", status = 2L, runLast = FALSE)
}
if (is.null(database_path)) {
  configuration <- rrp_read_duckdb_configuration(repository_root)
  database_path <- file.path(repository_root, configuration$database_path)
} else if (!grepl("^(/|[A-Za-z]:[/\\\\])", database_path)) {
  database_path <- file.path(repository_root, database_path)
}
if (length(source_run_ids) == 0L) source_run_ids <- paste0(
  "runtime_synthetic_history_", scale, "_001"
)

installed <- tryCatch(
  rrp_install_runtime_package(repository_root),
  error = function(condition) {
    message(conditionMessage(condition))
    quit(save = "no", status = 1L, runLast = FALSE)
  }
)
on.exit(rrp_unload_runtime_package(installed), add = TRUE)
result <- tryCatch(
  rrp_build_reference_products(
    repository_root,
    database_path,
    source_run_ids
  ),
  error = function(condition) {
    message("Reference logical product build failed: ", conditionMessage(condition))
    NULL
  }
)
if (is.null(result)) quit(save = "no", status = 1L, runLast = FALSE)

summary <- rrp_reference_product_summary(result)
cat("Reference logical products: succeeded\n")
cat("  data_classification: fictional_nonclinical\n")
cat("  product_set_id: ", summary$product_set_id, "\n", sep = "")
cat("  product_build_id: ", summary$product_build_id, "\n", sep = "")
cat("  source_cutoff_time: ", summary$source_cutoff_time, "\n", sep = "")
cat("  source_as_of_time: ", summary$source_as_of_time, "\n", sep = "")
cat("  latest_source_runtime_run_id: ", summary$latest_source_runtime_run_id, "\n", sep = "")
cat("  product_generated_at: ", summary$product_generated_at, "\n", sep = "")
for (name in names(summary$products)) {
  product <- summary$products[[name]]
  cat(
    "  ", name, ": ", product$product_id, "@", product$product_version,
    ", status=", product$availability_status, ", rows=", product$row_count, "\n",
    sep = ""
  )
}
cat("\nProducts were conformed and inspected in memory; no product files or tables were written.\n")
