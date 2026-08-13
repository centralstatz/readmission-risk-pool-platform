#!/usr/bin/env Rscript

file_argument <- grep("^--file=", commandArgs(trailingOnly = FALSE), value = TRUE)
script_path <- normalizePath(sub("^--file=", "", file_argument[[1L]]), mustWork = TRUE)
repository_root <- normalizePath(file.path(dirname(script_path), ".."), mustWork = TRUE)
for (file in c(
  "conformance-result.R", "specification-validation.R",
  "application-artifact-operation.R"
)) source(file.path(repository_root, "operations", "lib", file))
rrp_load_application_artifact_contract_runtime(repository_root)

arguments <- commandArgs(trailingOnly = TRUE)
artifact_path <- file.path(repository_root, "build", "reference-application-artifacts")
if (length(arguments) == 2L && identical(arguments[[1L]], "--artifact")) {
  artifact_path <- arguments[[2L]]
} else if (length(arguments) > 0L) {
  message(paste(
    "Usage: Rscript operations/validate-application-artifact.R",
    "[--artifact PATH]"
  ))
  quit(save = "no", status = 2L, runLast = FALSE)
}
if (!grepl("^(/|[A-Za-z]:[/\\\\])", artifact_path)) {
  artifact_path <- file.path(repository_root, artifact_path)
}
result <- tryCatch(
  rrp_validate_completed_application_artifact(artifact_path),
  error = function(condition) condition
)
if (inherits(result, "condition")) {
  message("Application artifact validation failed: ", conditionMessage(result))
  quit(save = "no", status = 1L, runLast = FALSE)
}
cat(paste(result$output, collapse = "\n"), "\n", sep = "")
if (!identical(result$overall_status, "pass")) {
  quit(save = "no", status = 1L, runLast = FALSE)
}
cat("Operation: platform.validate-application-artifact\n")
cat("Status: succeeded\n")
cat("  artifact_path: ", result$artifact_path, "\n", sep = "")
cat("Next: retain this local artifact for a future explicit target realization.\n")
