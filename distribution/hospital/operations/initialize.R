#!/usr/bin/env Rscript

script <- normalizePath(sub("^--file=", "", grep(
  "^--file=", commandArgs(trailingOnly = FALSE), value = TRUE
)[[1L]]), mustWork = TRUE)
root <- normalizePath(file.path(dirname(script), ".."), mustWork = TRUE)
source(file.path(root, "R", "distribution-runtime.R"))
result <- tryCatch(
  rrp_initialize_hospital_distribution(root),
  error = function(condition) condition
)
if (inherits(result, "condition")) {
  message("Hospital Implementation initialization failed: ", conditionMessage(result))
  quit(save = "no", status = 1L, runLast = FALSE)
}
cat("Operation: hospital.initialize\n")
cat("Status: succeeded\n")
cat("  platform_candidate: ", result$candidate_instance_id, "\n", sep = "")
cat("  managed_platform: ", result$managed_platform, "\n", sep = "")
cat("  idempotent: ", tolower(as.character(result$idempotent)), "\n", sep = "")
cat("No history, products, deployment, publication, or remote repository was created.\n")
