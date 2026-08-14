#!/usr/bin/env Rscript

file_argument <- grep("^--file=", commandArgs(trailingOnly = FALSE), value = TRUE)
script_path <- normalizePath(sub("^--file=", "", file_argument[[1L]]), mustWork = TRUE)
repository_root <- normalizePath(file.path(dirname(script_path), ".."), mustWork = TRUE)

source(file.path(repository_root, "operations", "lib", "validation-result.R"))
source(file.path(repository_root, "operations", "lib", "documentation-validation.R"))
source(file.path(repository_root, "operations", "lib", "repository-validation.R"))
source(file.path(repository_root, "operations", "lib", "conformance-result.R"))
source(file.path(repository_root, "operations", "lib", "specification-validation.R"))
source(file.path(repository_root, "operations", "lib", "foundation-context-validation.R"))
source(file.path(repository_root, "operations", "lib", "canonical-bundle-validation.R"))
source(file.path(repository_root, "operations", "lib", "canonical-clinical-validation.R"))
source(file.path(repository_root, "operations", "lib", "canonical-producer-operation.R"))
source(file.path(repository_root, "operations", "compositions", "installed-producers.R"))

arguments <- commandArgs(trailingOnly = TRUE)
if (length(arguments) == 0L) {
  scale <- "reference"
} else if (length(arguments) == 2L && identical(arguments[[1L]], "--scale")) {
  scale <- arguments[[2L]]
} else if (length(arguments) == 1L && startsWith(arguments[[1L]], "--scale=")) {
  scale <- sub("^--scale=", "", arguments[[1L]])
} else {
  message("Usage: Rscript operations/generate-reference.R [--scale test|reference]")
  quit(save = "no", status = 2L, runLast = FALSE)
}

result <- tryCatch(
  rrp_run_installed_canonical_producer(repository_root, scale),
  error = function(condition) {
    message("Synthetic reference operation failed: ", conditionMessage(condition))
    NULL
  }
)
if (is.null(result)) {
  quit(save = "no", status = 1L, runLast = FALSE)
}
print(result)
if (!identical(result$overall_status, "succeeded")) {
  for (name in names(result$conformance_results)) {
    conformance <- result$conformance_results[[name]]
    if (!is.null(conformance) && nrow(conformance$issues) > 0L) {
      cat("\n", name, " issues:\n", sep = "")
      print(conformance$issues, row.names = FALSE)
    }
  }
  quit(save = "no", status = 1L, runLast = FALSE)
}

cat("\nNo generated source or canonical data were written to disk.\n")
