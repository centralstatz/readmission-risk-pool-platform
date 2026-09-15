#!/usr/bin/env Rscript

script <- normalizePath(sub("^--file=", "", grep(
  "^--file=", commandArgs(trailingOnly = FALSE), value = TRUE
)[[1L]]), mustWork = TRUE)
repository_root <- normalizePath(file.path(dirname(script), ".."), mustWork = TRUE)

source(file.path(repository_root, "operations", "lib", "validation-result.R"))
source(file.path(repository_root, "operations", "lib", "documentation-validation.R"))
source(file.path(repository_root, "operations", "lib", "repository-validation.R"))

if (length(commandArgs(trailingOnly = TRUE)) > 0L) {
  message("Usage: Rscript operations/validate-repository-policy.R")
  quit(save = "no", status = 2L, runLast = FALSE)
}

rrp_exit_for_result(rrp_validate_repository_policies(repository_root))
