# Target-neutral reduced-artifact Shiny entry point.

artifact_root <- normalizePath(dirname(sys.frame(1L)$ofile), mustWork = TRUE)
sys.source(
  file.path(artifact_root, "R", "artifact-runtime.R"),
  envir = environment()
)
rrp_load_application_artifact_runtime(artifact_root)
validation <- rrp_validate_application_artifact(
  artifact_root,
  construct_app = TRUE,
  check_dependencies = TRUE
)
if (!identical(validation$overall_status, "pass")) stop(
  "Application artifact validation failed: ",
  paste(validation$issues$issue_code, collapse = ", "),
  call. = FALSE
)
validation$application
