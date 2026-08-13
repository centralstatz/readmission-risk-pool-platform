#!/usr/bin/env Rscript

file_argument <- grep("^--file=", commandArgs(trailingOnly = FALSE), value = TRUE)
script_path <- normalizePath(sub("^--file=", "", file_argument[[1L]]), mustWork = TRUE)
repository_root <- normalizePath(file.path(dirname(script_path), ".."), mustWork = TRUE)
for (file in c(
  "validation-result.R", "conformance-result.R", "specification-validation.R",
  "history-validation.R", "runtime-operation.R", "duckdb-persistence-operation.R",
  "product-operation.R", "product-materialization-operation.R", "operator-operation.R"
)) source(file.path(repository_root, "operations", "lib", file))
rrp_load_duckdb_persistence_adapter(repository_root)
rrp_load_product_layer(repository_root)
rrp_load_yaml_product_adapter(repository_root)

paths <- rrp_operator_default_paths(repository_root)
arguments <- commandArgs(trailingOnly = TRUE)
while (length(arguments) > 0L) {
  if (length(arguments) >= 2L && identical(arguments[[1L]], "--database")) {
    paths$database <- rrp_operator_path(repository_root, arguments[[2L]])
    arguments <- arguments[-c(1L, 2L)]
  } else if (length(arguments) >= 2L && identical(arguments[[1L]], "--products")) {
    paths$products <- rrp_operator_path(repository_root, arguments[[2L]])
    arguments <- arguments[-c(1L, 2L)]
  } else {
    message(paste(
      "Usage: Rscript operations/doctor.R",
      "[--database PATH] [--products PATH]"
    ))
    quit(save = "no", status = 2L, runLast = FALSE)
  }
}

result <- rrp_doctor(repository_root, paths$database, paths$products)
rrp_print_doctor(result)
if (identical(result$overall_status, "blocked")) {
  quit(save = "no", status = 1L, runLast = FALSE)
}
