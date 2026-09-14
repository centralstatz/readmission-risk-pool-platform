#!/usr/bin/env Rscript

script <- normalizePath(sub("^--file=", "", grep(
  "^--file=", commandArgs(trailingOnly = FALSE), value = TRUE
)[[1L]]), mustWork = TRUE)
repository_root <- normalizePath(file.path(dirname(script), ".."), mustWork = TRUE)

source(file.path(repository_root, "validation", "R", "current-boundary.R"))

arguments <- commandArgs(trailingOnly = TRUE)
if (length(arguments) != 2L || !identical(arguments[[1L]], "--validator")) {
  message(paste(
    "Usage: Rscript operations/validate-current-boundary.R",
    "--validator ALLOWLISTED_ID"
  ))
  quit(save = "no", status = 2L, runLast = FALSE)
}

result <- tryCatch(
  rrp_run_current_boundary(repository_root, arguments[[2L]]),
  error = function(condition) condition
)
if (inherits(result, "condition")) {
  message("Current-boundary validation failed: ", conditionMessage(result))
  quit(save = "no", status = 1L, runLast = FALSE)
}

if (!exists("rrp_exit_for_result", envir = .GlobalEnv, inherits = TRUE)) {
  source(file.path(repository_root, "operations", "lib", "validation-result.R"))
}
rrp_exit_for_result(result)
