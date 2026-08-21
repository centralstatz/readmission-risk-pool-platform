#!/usr/bin/env Rscript

script <- normalizePath(sub("^--file=", "", grep(
  "^--file=", commandArgs(trailingOnly = FALSE), value = TRUE
)[[1L]]), mustWork = TRUE)
repository_root <- normalizePath(file.path(dirname(script), ".."), mustWork = TRUE)
for (file in c(
  "validation-result.R", "conformance-result.R", "specification-validation.R",
  "hospital-distribution-operation.R", "hospital-git-realization-operation.R"
)) source(file.path(repository_root, "operations", "lib", file))
rrp_load_hospital_distribution_runtime(repository_root, .GlobalEnv)

arguments <- commandArgs(trailingOnly = TRUE)
distribution <- file.path(
  repository_root, "build", "hospital-implementation-distributions"
)
destination <- NULL
realized_at <- rrp_hospital_now()
while (length(arguments) > 0L) {
  if (length(arguments) >= 2L && identical(arguments[[1L]], "--distribution")) {
    distribution <- arguments[[2L]]
    arguments <- arguments[-c(1L, 2L)]
  } else if (length(arguments) >= 2L && identical(arguments[[1L]], "--destination")) {
    destination <- arguments[[2L]]
    arguments <- arguments[-c(1L, 2L)]
  } else if (length(arguments) >= 2L && identical(arguments[[1L]], "--realized-at")) {
    realized_at <- arguments[[2L]]
    arguments <- arguments[-c(1L, 2L)]
  } else {
    message(paste(
      "Usage: Rscript operations/build-hospital-git-realization.R",
      "--destination PATH [--distribution PATH] [--realized-at RFC3339]"
    ))
    quit(save = "no", status = 2L, runLast = FALSE)
  }
}
if (is.null(destination)) {
  message("Hospital Git realization requires an explicit --destination PATH.")
  quit(save = "no", status = 2L, runLast = FALSE)
}
for (name in c("distribution", "destination")) {
  value <- get(name)
  if (!grepl("^(/|[A-Za-z]:[/\\\\])", value)) {
    assign(name, file.path(repository_root, value))
  }
}
result <- tryCatch(rrp_build_hospital_git_realization(
  repository_root, distribution, destination, realized_at
), error = function(condition) condition)
if (inherits(result, "condition")) {
  message("Hospital Implementation Git realization failed: ",
          conditionMessage(result))
  quit(save = "no", status = 1L, runLast = FALSE)
}
cat("Operation: platform.build-hospital-git-realization\n")
cat("Status: succeeded\n")
cat("  realization_instance_id: ", result$realization_instance_id, "\n", sep = "")
cat("  distribution_instance_id: ", result$distribution_instance_id, "\n", sep = "")
cat("  distribution_build_id: ", result$distribution_build_id, "\n", sep = "")
cat("  platform_candidate: ", result$platform_candidate_instance_id, "\n", sep = "")
cat("  destination: ", result$destination, "\n", sep = "")
cat("  idempotent: ", tolower(as.character(result$idempotent)), "\n", sep = "")
cat("  replaced_pristine_destination: ",
    tolower(as.character(result$replaced)), "\n", sep = "")
cat("  git: initialized on main; generated files staged; zero commits; zero remotes\n")
cat("  publication_status: not_published\n")
cat("Next: Rscript operations/validate-hospital-git-realization.R --destination ",
    result$destination, "\n", sep = "")
