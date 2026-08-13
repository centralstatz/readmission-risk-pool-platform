#!/usr/bin/env Rscript

file_argument <- grep("^--file=", commandArgs(trailingOnly = FALSE), value = TRUE)
script_path <- normalizePath(sub("^--file=", "", file_argument[[1L]]), mustWork = TRUE)
repository_root <- normalizePath(file.path(dirname(script_path), ".."), mustWork = TRUE)
source(file.path(repository_root, "operations", "lib", "validation-result.R"))
source(file.path(repository_root, "operations", "lib", "conformance-result.R"))
source(file.path(repository_root, "operations", "lib", "specification-validation.R"))
source(file.path(repository_root, "operations", "lib", "duckdb-persistence-operation.R"))
source(file.path(repository_root, "operations", "lib", "operator-operation.R"))

arguments <- commandArgs(trailingOnly = TRUE)
build_root <- file.path(repository_root, "build")
while (length(arguments) > 0L) {
  if (length(arguments) >= 2L && identical(arguments[[1L]], "--build-root")) {
    build_root <- rrp_operator_path(repository_root, arguments[[2L]])
    arguments <- arguments[-c(1L, 2L)]
  } else {
    message("Usage: Rscript operations/initialize-platform.R [--build-root PATH]")
    quit(save = "no", status = 2L, runLast = FALSE)
  }
}

result <- tryCatch(
  rrp_initialize_local_platform(repository_root, build_root),
  error = function(condition) {
    message("Operation: platform.initialize-local")
    message("Status: failed")
    message(conditionMessage(condition))
    quit(save = "no", status = 1L, runLast = FALSE)
  }
)
cat("Operation: ", result$operation_id, "\n", sep = "")
cat("Status: ", result$status, "\n", sep = "")
cat("  local_build_root: ", result$build_root, "\n", sep = "")
cat("  operational_history_created: no\n")
cat("  product_bundle_created: no\n")
cat("Next: Rscript operations/doctor.R\n")
