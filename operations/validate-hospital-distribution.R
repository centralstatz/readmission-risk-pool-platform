#!/usr/bin/env Rscript

script <- normalizePath(sub("^--file=", "", grep(
  "^--file=", commandArgs(trailingOnly = FALSE), value = TRUE
)[[1L]]), mustWork = TRUE)
repository_root <- normalizePath(file.path(dirname(script), ".."), mustWork = TRUE)
source(file.path(
  repository_root, "operations", "lib", "hospital-distribution-operation.R"
))
rrp_load_hospital_distribution_runtime(repository_root, .GlobalEnv)

arguments <- commandArgs(trailingOnly = TRUE)
distribution <- file.path(
  repository_root, "build", "hospital-implementation-distributions"
)
if (length(arguments) == 2L && identical(arguments[[1L]], "--distribution")) {
  distribution <- arguments[[2L]]
} else if (length(arguments) > 0L) {
  message(paste(
    "Usage: Rscript operations/validate-hospital-distribution.R",
    "[--distribution PATH]"
  ))
  quit(save = "no", status = 2L, runLast = FALSE)
}
if (!grepl("^(/|[A-Za-z]:[/\\\\])", distribution)) {
  distribution <- file.path(repository_root, distribution)
}
result <- tryCatch(
  rrp_validate_completed_hospital_distribution(distribution),
  error = function(condition) condition
)
if (inherits(result, "condition")) {
  message("Hospital Implementation distribution validation failed: ",
          conditionMessage(result))
  quit(save = "no", status = 1L, runLast = FALSE)
}
cat(paste(result$output, collapse = "\n"), "\n", sep = "")
if (!identical(result$overall_status, "pass")) {
  quit(save = "no", status = 1L, runLast = FALSE)
}
cat("Operation: platform.validate-hospital-distribution\n")
cat("Status: succeeded\n")
cat("  distribution_path: ", result$distribution_path, "\n", sep = "")
cat("No Git repository, commit, remote, publication, or deployment was created.\n")
