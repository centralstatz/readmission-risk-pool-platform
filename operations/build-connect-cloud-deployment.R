#!/usr/bin/env Rscript

file_argument <- grep("^--file=", commandArgs(trailingOnly = FALSE), value = TRUE)
script_path <- normalizePath(sub("^--file=", "", file_argument[[1L]]), mustWork = TRUE)
repository_root <- normalizePath(file.path(dirname(script_path), ".."), mustWork = TRUE)
for (file in c(
  "observability-operation.R",
  "conformance-result.R", "specification-validation.R",
  "application-artifact-operation.R", "connect-cloud-operation.R"
)) source(file.path(repository_root, "operations", "lib", file))
rrp_load_application_artifact_contract_runtime(repository_root)
rrp_load_connect_cloud_runtime(repository_root)

arguments <- commandArgs(trailingOnly = TRUE)
artifact_path <- file.path(repository_root, "build", "reference-application-artifacts")
destination <- NULL
generated_at <- rrp_application_artifact_now()
while (length(arguments) > 0L) {
  if (length(arguments) >= 2L && identical(arguments[[1L]], "--artifact")) {
    artifact_path <- arguments[[2L]]
    arguments <- arguments[-c(1L, 2L)]
  } else if (length(arguments) >= 2L && identical(arguments[[1L]], "--destination")) {
    destination <- arguments[[2L]]
    arguments <- arguments[-c(1L, 2L)]
  } else if (length(arguments) >= 2L && identical(arguments[[1L]], "--generated-at")) {
    generated_at <- arguments[[2L]]
    arguments <- arguments[-c(1L, 2L)]
  } else {
    message(paste(
      "Usage: Rscript operations/build-connect-cloud-deployment.R",
      "--destination PATH [--artifact PATH] [--generated-at RFC3339]"
    ))
    quit(save = "no", status = 2L, runLast = FALSE)
  }
}
if (is.null(destination)) {
  message("Connect deployment generation requires an explicit --destination PATH.")
  quit(save = "no", status = 2L, runLast = FALSE)
}
for (name in c("artifact_path", "destination")) {
  value <- get(name)
  if (!grepl("^(/|[A-Za-z]:[/\\\\])", value)) {
    assign(name, file.path(repository_root, value))
  }
}
emitter <- rrp_start_operation_observability(
  "platform.build-connect-cloud-deployment",
  list(data_classification = "fictional_nonclinical")
)
rrp_emit_operational_event(
  emitter, "connect_realization", "connect_realization", "info", "stage_started",
  "connect.realization_started", "Connect Cloud realization started."
)
result <- tryCatch(rrp_build_connect_cloud_deployment(
  repository_root, artifact_path, destination, generated_at
), error = function(condition) condition)
if (inherits(result, "condition")) {
  rrp_fail_operation_observability(
    emitter, "connect.realization_failed", "Connect Cloud realization failed.",
    "Validate the source artifact and destination safety, then retry."
  )
  message("Connect Cloud deployment generation failed: ", conditionMessage(result))
  quit(save = "no", status = 1L, runLast = FALSE)
}
rrp_emit_operational_event(
  emitter, "connect_realization", "connect_realization", "info", "stage_completed",
  "connect.realization_completed", "Connect Cloud realization completed.",
  related_identities = list(
    artifact_build_id = result$source_artifact_build_id,
    deployment_realization_id = result$realization_id
  ), details = list(
    idempotent = result$idempotent, replaced = result$replaced,
    status = "succeeded", validation_status = "pass"
  )
)
rrp_complete_operation_observability(
  emitter,
  related_identities = list(deployment_realization_id = result$realization_id),
  details = list(idempotent = result$idempotent, replaced = result$replaced)
)
cat("Operation: platform.build-connect-cloud-deployment\n")
cat("Status: succeeded\n")
cat("  realization_id: ", result$realization_id, "\n", sep = "")
cat("  source_artifact_build_id: ", result$source_artifact_build_id, "\n", sep = "")
cat("  destination: ", result$destination, "\n", sep = "")
cat("  idempotent: ", tolower(as.character(result$idempotent)), "\n", sep = "")
cat("  replaced_owned_destination: ",
    tolower(as.character(result$replaced)), "\n", sep = "")
cat("  git: initialized on main; generated files staged; no commit; no remote\n")
cat("Next: Rscript operations/validate-connect-cloud-deployment.R --destination ",
    result$destination, "\n", sep = "")
