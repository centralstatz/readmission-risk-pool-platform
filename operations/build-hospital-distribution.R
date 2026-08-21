#!/usr/bin/env Rscript

script <- normalizePath(sub("^--file=", "", grep(
  "^--file=", commandArgs(trailingOnly = FALSE), value = TRUE
)[[1L]]), mustWork = TRUE)
repository_root <- normalizePath(file.path(dirname(script), ".."), mustWork = TRUE)
for (file in c(
  "validation-result.R", "conformance-result.R", "specification-validation.R",
  "hospital-distribution-operation.R"
)) source(file.path(repository_root, "operations", "lib", file))
rrp_load_hospital_distribution_runtime(repository_root, .GlobalEnv)

arguments <- commandArgs(trailingOnly = TRUE)
store <- file.path(repository_root, "build", "hospital-implementation-distributions")
built_at <- rrp_hospital_now()
while (length(arguments) > 0L) {
  if (length(arguments) >= 2L && identical(arguments[[1L]], "--store")) {
    store <- arguments[[2L]]
    arguments <- arguments[-c(1L, 2L)]
  } else if (length(arguments) >= 2L && identical(arguments[[1L]], "--built-at")) {
    built_at <- arguments[[2L]]
    arguments <- arguments[-c(1L, 2L)]
  } else {
    message(paste(
      "Usage: Rscript operations/build-hospital-distribution.R",
      "[--store PATH] [--built-at RFC3339]"
    ))
    quit(save = "no", status = 2L, runLast = FALSE)
  }
}
if (!grepl("^(/|[A-Za-z]:[/\\\\])", store)) store <- file.path(repository_root, store)
result <- tryCatch(
  rrp_build_hospital_distribution(repository_root, store, built_at),
  error = function(condition) condition
)
if (inherits(result, "condition")) {
  message("Hospital Implementation distribution build failed: ", conditionMessage(result))
  quit(save = "no", status = 1L, runLast = FALSE)
}
cat("Operation: platform.build-hospital-distribution\n")
cat("Status: succeeded\n")
cat("  distribution_instance_id: ", result$distribution_instance_id, "\n", sep = "")
cat("  distribution_build_id: ", result$distribution_build_id, "\n", sep = "")
cat("  platform_candidate: ", result$platform_candidate_instance_id, "\n", sep = "")
cat("  platform_archive_sha256: ", result$platform_archive_sha256, "\n", sep = "")
cat("  distribution_path: ", result$distribution_path, "\n", sep = "")
cat("  idempotent: ", tolower(as.character(result$idempotent)), "\n", sep = "")
cat("  publication_status: not_published\n")
cat("Next: Rscript operations/validate-hospital-distribution.R\n")
