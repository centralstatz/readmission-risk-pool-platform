#!/usr/bin/env Rscript

file_argument <- grep("^--file=", commandArgs(trailingOnly = FALSE), value = TRUE)
artifact_root <- normalizePath(dirname(sub(
  "^--file=", "", file_argument[[1L]]
)), mustWork = TRUE)
sys.source(
  file.path(artifact_root, "R", "artifact-runtime.R"),
  envir = environment()
)
rrp_load_application_artifact_runtime(artifact_root)
result <- rrp_validate_application_artifact(
  artifact_root,
  construct_app = TRUE,
  check_dependencies = TRUE
)
cat("Application artifact validation\n")
cat("-------------------------------\n")
if (identical(result$overall_status, "pass")) {
  cat("PASS closed inventory and integrity\n")
  cat("PASS product identity, compatibility, and coherence\n")
  cat("PASS runtime dependency declaration and availability\n")
  cat("PASS isolated product-only Shiny construction\n")
  cat("Artifact instance: ", result$manifest$artifact_instance_id, "\n", sep = "")
  cat("Artifact build: ", result$manifest$artifact_build_id, "\n", sep = "")
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
