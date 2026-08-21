#!/usr/bin/env Rscript

script <- normalizePath(sub("^--file=", "", grep(
  "^--file=", commandArgs(trailingOnly = FALSE), value = TRUE
)[[1L]]), mustWork = TRUE)
root <- normalizePath(file.path(dirname(script), ".."), mustWork = TRUE)
source(file.path(root, "R", "distribution-runtime.R"))
result <- tryCatch(rrp_hospital_delegate_platform(
  root, "build-application-artifact.R", c(
    "--products", file.path(root, "build", "local", "products"),
    "--artifacts", file.path(root, "build", "local", "application-artifacts")
  )
), error = function(condition) condition)
if (inherits(result, "condition")) {
  message("Hospital application artifact build failed: ", conditionMessage(result))
  quit(save = "no", status = 1L, runLast = FALSE)
}
rrp_hospital_print_process(result)
