#!/usr/bin/env Rscript

script <- normalizePath(sub("^--file=", "", grep(
  "^--file=", commandArgs(trailingOnly = FALSE), value = TRUE
)[[1L]]), mustWork = TRUE)
root <- normalizePath(file.path(dirname(script), ".."), mustWork = TRUE)
source(file.path(root, "R", "distribution-runtime.R"))
result <- tryCatch(rrp_hospital_delegate_platform(
  root, "validate-application-artifact.R", c(
    "--artifact", file.path(root, "build", "local", "application-artifacts")
  )
), error = function(condition) condition)
if (inherits(result, "condition")) {
  message("Hospital application artifact validation failed: ", conditionMessage(result))
  quit(save = "no", status = 1L, runLast = FALSE)
}
rrp_hospital_print_process(result)
