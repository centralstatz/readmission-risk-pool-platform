#!/usr/bin/env Rscript

repository_root <- normalizePath(
  file.path(dirname(sub("^--file=", "", grep(
    "^--file=", commandArgs(trailingOnly = FALSE), value = TRUE
  )[[1L]])), ".."),
  mustWork = TRUE
)

source(file.path(repository_root, "operations", "lib", "validation-result.R"))
source(file.path(repository_root, "operations", "lib", "documentation-validation.R"))

rrp_exit_for_result(rrp_validate_documentation(repository_root))
