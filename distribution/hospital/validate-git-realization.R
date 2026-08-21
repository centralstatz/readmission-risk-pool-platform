#!/usr/bin/env Rscript

script <- normalizePath(sub("^--file=", "", grep(
  "^--file=", commandArgs(trailingOnly = FALSE), value = TRUE
)[[1L]]), mustWork = TRUE)
root <- dirname(script)
source(file.path(root, "R", "distribution-runtime.R"))
source(file.path(root, "R", "git-realization-runtime.R"))
result <- rrp_validate_hospital_git_realization(
  root, check_git = TRUE, run_distribution_validator = TRUE
)
if (!identical(result$overall_status, "pass")) {
  for (index in seq_len(nrow(result$issues))) message(
    "[", result$issues$category[[index]], "/",
    result$issues$issue_code[[index]], "] ", result$issues$message[[index]]
  )
  quit(save = "no", status = 1L, runLast = FALSE)
}
cat("Operation: hospital.validate-git-realization\n")
cat("Status: succeeded\n")
cat("  realization_instance_id: ",
    result$manifest$realization_instance_id, "\n", sep = "")
cat("  distribution_instance_id: ",
    result$manifest$source_distribution$distribution_instance_id, "\n", sep = "")
cat("  distribution_build_id: ",
    result$manifest$source_distribution$distribution_build_id, "\n", sep = "")
cat("  platform_candidate: ",
    result$manifest$included_platform$candidate_instance_id, "\n", sep = "")
cat("  git: main; staged; zero commits; zero remotes\n")
cat("  distribution_validation: passed\n")
cat("  publication_status: not_published\n")
