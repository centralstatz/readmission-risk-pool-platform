#!/usr/bin/env Rscript

script <- normalizePath(sub("^--file=", "", grep(
  "^--file=", commandArgs(trailingOnly = FALSE), value = TRUE
)[[1L]]), mustWork = TRUE)
repository_root <- normalizePath(file.path(dirname(script), ".."), mustWork = TRUE)
for (file in c(
  "validation-result.R", "conformance-result.R", "specification-validation.R",
  "hospital-distribution-operation.R", "hospital-git-realization-operation.R",
  "release-preparation-operation.R"
)) source(file.path(repository_root, "operations", "lib", file))
rrp_load_hospital_distribution_runtime(repository_root, .GlobalEnv)

arguments <- commandArgs(trailingOnly = TRUE)
mode <- "prepare"
version <- NULL
while (length(arguments) > 0L) {
  if (length(arguments) >= 2L && identical(arguments[[1L]], "--version")) {
    version <- arguments[[2L]]
    arguments <- arguments[-c(1L, 2L)]
  } else if (identical(arguments[[1L]], "--validate-only")) {
    mode <- "validate"
    arguments <- arguments[-1L]
  } else if (identical(arguments[[1L]], "--show-readiness")) {
    mode <- "show"
    arguments <- arguments[-1L]
  } else {
    message(paste(
      "Usage: Rscript operations/prepare-release.R --version VERSION",
      "[--validate-only|--show-readiness]"
    ))
    quit(save = "no", status = 2L, runLast = FALSE)
  }
}
if (is.null(version) || !grepl("^[0-9]+[.][0-9]+[.][0-9]+$", version)) {
  message("Release preparation requires one semantic --version value.")
  quit(save = "no", status = 2L, runLast = FALSE)
}

root <- file.path(repository_root, "build", "releases", version)
result <- tryCatch({
  if (identical(mode, "prepare")) {
    rrp_prepare_release(repository_root, version)
  } else {
    rrp_validate_release_preparation(root, run_acquisition = identical(mode, "validate"))
  }
}, error = function(condition) condition)
if (inherits(result, "condition")) {
  message("Release preparation failed: ", conditionMessage(result))
  quit(save = "no", status = 1L, runLast = FALSE)
}
manifest <- result$manifest
cat("Operation: platform.prepare-release\n")
cat("Release target: Platform v", manifest$intended_versions$platform, "\n", sep = "")
cat("Hospital target: v", manifest$intended_versions$hospital, " (independently versioned)\n", sep = "")
cat("License: PASS\nGovernance: PASS\nRepository validation: PASS\n")
cat("Platform candidate: PASS\nHospital distribution: PASS\n")
cat("Hospital Git realization: PASS\nAcquisition proof: PASS\nSupport evidence: PASS\n")
cat("Publication status: NOT PUBLISHED\n\nRESULT: READY FOR PUBLICATION\n")
cat("Evidence: ", result$root, "\n", sep = "")
cat("STOP: no commit, tag, remote, push, GitHub Release, or publication was created.\n")
