# Generated Connect Cloud root adapter. The target-neutral artifact remains
# intact below artifact/ and remains authoritative for application startup.

deployment_root <- normalizePath(getwd(), mustWork = TRUE)
artifact_root <- file.path(deployment_root, "artifact")
sys.source(
  file.path(artifact_root, "R", "artifact-runtime.R"),
  envir = environment()
)
rrp_load_application_artifact_runtime(artifact_root, environment())
validation <- rrp_validate_application_artifact(
  artifact_root,
  construct_app = TRUE,
  check_dependencies = TRUE
)
if (!identical(validation$overall_status, "pass")) stop(
  "Embedded application artifact validation failed: ",
  paste(validation$issues$issue_code, collapse = ", "),
  call. = FALSE
)
validation$application
