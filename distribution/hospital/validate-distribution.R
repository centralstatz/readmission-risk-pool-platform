#!/usr/bin/env Rscript

script <- normalizePath(sub("^--file=", "", grep(
  "^--file=", commandArgs(trailingOnly = FALSE), value = TRUE
)[[1L]]), mustWork = TRUE)
root <- dirname(script)
source(file.path(root, "R", "distribution-runtime.R"))
result <- rrp_validate_hospital_distribution(root, allow_local_state = TRUE)
if (!identical(result$overall_status, "pass")) {
  for (index in seq_len(nrow(result$issues))) message(
    "[", result$issues$category[[index]], "/",
    result$issues$issue_code[[index]], "] ", result$issues$message[[index]]
  )
  quit(save = "no", status = 1L, runLast = FALSE)
}
platform_validation <- tryCatch(
  rrp_hospital_validate_platform_execution(root, result),
  error = function(condition) condition
)
if (inherits(platform_validation, "condition")) {
  message(
    "[platform_candidate/platform_execution_validation_failed] ",
    conditionMessage(platform_validation)
  )
  quit(save = "no", status = 1L, runLast = FALSE)
}
cat("Operation: hospital.validate-distribution\n")
cat("Status: succeeded\n")
cat("  distribution_instance_id: ", result$manifest$distribution_instance_id, "\n", sep = "")
cat("  platform_candidate: ", result$manifest$platform_candidate$candidate_instance_id, "\n", sep = "")
cat("  inventory_members: ", length(result$manifest$inventory), "\n", sep = "")
cat("  data_classification: fictional_nonclinical\n")
cat("  extracted_platform_validation: passed\n")
