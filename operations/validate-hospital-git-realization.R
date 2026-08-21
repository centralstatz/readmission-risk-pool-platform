#!/usr/bin/env Rscript

script <- normalizePath(sub("^--file=", "", grep(
  "^--file=", commandArgs(trailingOnly = FALSE), value = TRUE
)[[1L]]), mustWork = TRUE)
repository_root <- normalizePath(file.path(dirname(script), ".."), mustWork = TRUE)
for (file in c(
  "hospital-distribution-operation.R", "hospital-git-realization-operation.R"
)) source(file.path(repository_root, "operations", "lib", file))
rrp_load_hospital_distribution_runtime(repository_root, .GlobalEnv)

arguments <- commandArgs(trailingOnly = TRUE)
if (length(arguments) != 2L || !identical(arguments[[1L]], "--destination")) {
  message(paste(
    "Usage: Rscript operations/validate-hospital-git-realization.R",
    "--destination PATH"
  ))
  quit(save = "no", status = 2L, runLast = FALSE)
}
destination <- arguments[[2L]]
if (!grepl("^(/|[A-Za-z]:[/\\\\])", destination)) {
  destination <- file.path(repository_root, destination)
}
result <- tryCatch(
  rrp_validate_completed_hospital_git_realization(destination),
  error = function(condition) condition
)
if (inherits(result, "condition")) {
  message("Hospital Implementation Git validation failed: ",
          conditionMessage(result))
  quit(save = "no", status = 1L, runLast = FALSE)
}
cat(paste(result$output, collapse = "\n"), "\n", sep = "")
if (!identical(result$overall_status, "pass")) {
  quit(save = "no", status = 1L, runLast = FALSE)
}
cat("Operation: platform.validate-hospital-git-realization\n")
cat("Status: succeeded\n")
cat("  destination: ", result$realization_path, "\n", sep = "")
cat("STOP: review only; no commit, remote, tag, push, release, or publication was created.\n")
