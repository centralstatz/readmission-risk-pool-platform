#!/usr/bin/env Rscript

file_argument <- grep("^--file=", commandArgs(trailingOnly = FALSE), value = TRUE)
realization_root <- normalizePath(dirname(sub(
  "^--file=", "", file_argument[[1L]]
)), mustWork = TRUE)
sys.source(
  file.path(realization_root, "artifact", "R", "artifact-runtime.R"),
  envir = environment()
)
rrp_load_application_artifact_runtime(
  file.path(realization_root, "artifact"), environment()
)
sys.source(
  file.path(realization_root, "R", "connect-cloud-validation.R"),
  envir = environment()
)
result <- rrp_validate_connect_cloud_realization(
  realization_root,
  construct_app = TRUE,
  check_dependencies = TRUE,
  check_git = TRUE
)
cat("Connect Cloud realization validation\n")
cat("------------------------------------\n")
if (identical(result$overall_status, "pass")) {
  cat("PASS exact manifest-backed inventory and integrity\n")
  cat("PASS source artifact identity, integrity, and compatibility\n")
  cat("PASS Connect Cloud dependency manifest\n")
  cat("PASS remote-free staged Git repository state\n")
  cat("PASS isolated product-only Shiny construction\n")
  cat("Realization: ", result$manifest$realization_id, "\n", sep = "")
  cat("Source artifact: ", result$manifest$source_artifact$artifact_build_id,
      "\n", sep = "")
  cat("Result: PASS (0 issues)\n")
  quit(save = "no", status = 0L, runLast = FALSE)
}
for (index in seq_len(nrow(result$issues))) cat(
  "FAIL [", result$issues$category[[index]], "/",
  result$issues$issue_code[[index]], "] ",
  result$issues$message[[index]], " (", result$issues$path[[index]], ")\n",
  sep = ""
)
cat("Result: FAIL (", nrow(result$issues), " issues)\n", sep = "")
quit(save = "no", status = 1L, runLast = FALSE)
