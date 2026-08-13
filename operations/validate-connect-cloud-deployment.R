#!/usr/bin/env Rscript

file_argument <- grep("^--file=", commandArgs(trailingOnly = FALSE), value = TRUE)
script_path <- normalizePath(sub("^--file=", "", file_argument[[1L]]), mustWork = TRUE)
repository_root <- normalizePath(file.path(dirname(script_path), ".."), mustWork = TRUE)
for (file in c(
  "conformance-result.R", "specification-validation.R",
  "application-artifact-operation.R", "connect-cloud-operation.R"
)) source(file.path(repository_root, "operations", "lib", file))
rrp_load_application_artifact_contract_runtime(repository_root)
rrp_load_connect_cloud_runtime(repository_root)

arguments <- commandArgs(trailingOnly = TRUE)
if (length(arguments) != 2L || !identical(arguments[[1L]], "--destination")) {
  message(paste(
    "Usage: Rscript operations/validate-connect-cloud-deployment.R",
    "--destination PATH"
  ))
  quit(save = "no", status = 2L, runLast = FALSE)
}
destination <- arguments[[2L]]
if (!grepl("^(/|[A-Za-z]:[/\\\\])", destination)) {
  destination <- file.path(repository_root, destination)
}
result <- tryCatch(
  rrp_validate_completed_connect_cloud_deployment(destination),
  error = function(condition) condition
)
if (inherits(result, "condition")) {
  message("Connect Cloud deployment validation failed: ", conditionMessage(result))
  quit(save = "no", status = 1L, runLast = FALSE)
}
cat(paste(result$output, collapse = "\n"), "\n", sep = "")
if (!identical(result$overall_status, "pass")) {
  quit(save = "no", status = 1L, runLast = FALSE)
}
cat("Operation: platform.validate-connect-cloud-deployment\n")
cat("Status: succeeded\n")
cat("  destination: ", result$realization_path, "\n", sep = "")
cat("Next: review and commit with your own Git identity before external publication.\n")
