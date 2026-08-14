#!/usr/bin/env Rscript

file_argument <- grep("^--file=", commandArgs(trailingOnly = FALSE), value = TRUE)
script_path <- normalizePath(sub("^--file=", "", file_argument[[1L]]), mustWork = TRUE)
repository_root <- normalizePath(file.path(dirname(script_path), ".."), mustWork = TRUE)
for (file in c(
  "observability-operation.R",
  "validation-result.R", "conformance-result.R", "specification-validation.R",
  "history-validation.R", "runtime-operation.R", "duckdb-persistence-operation.R",
  "product-operation.R", "product-materialization-operation.R", "operator-operation.R"
)) source(file.path(repository_root, "operations", "lib", file))
rrp_load_duckdb_persistence_adapter(repository_root)
rrp_load_product_layer(repository_root)
rrp_load_yaml_product_adapter(repository_root)

paths <- rrp_operator_default_paths(repository_root)
arguments <- commandArgs(trailingOnly = TRUE)
while (length(arguments) > 0L) {
  if (length(arguments) >= 2L && identical(arguments[[1L]], "--database")) {
    paths$database <- rrp_operator_path(repository_root, arguments[[2L]])
    arguments <- arguments[-c(1L, 2L)]
  } else if (length(arguments) >= 2L && identical(arguments[[1L]], "--products")) {
    paths$products <- rrp_operator_path(repository_root, arguments[[2L]])
    arguments <- arguments[-c(1L, 2L)]
  } else {
    message(paste(
      "Usage: Rscript operations/doctor.R",
      "[--database PATH] [--products PATH]"
    ))
    quit(save = "no", status = 2L, runLast = FALSE)
  }
}

emitter <- rrp_start_operation_observability(
  "platform.doctor",
  list(data_classification = "no_patient_data")
)
rrp_emit_operational_event(
  emitter, "environment", "preflight", "info", "stage_started",
  "doctor.preflight_started", "Platform readiness checks started."
)
result <- tryCatch(
  rrp_doctor(repository_root, paths$database, paths$products),
  error = function(condition) condition
)
if (inherits(result, "condition")) {
  rrp_fail_operation_observability(
    emitter, "doctor.failed", "Doctor could not complete readiness checks.",
    "Review the doctor error, restore prerequisites, and run doctor again."
  )
  message("Doctor failed: ", conditionMessage(result))
  quit(save = "no", status = 1L, runLast = FALSE)
}
warning_count <- sum(result$checks$status == "warning")
failure_count <- sum(result$checks$status == "failure")
rrp_emit_operational_event(
  emitter, "environment", "preflight",
  if (failure_count > 0L) "warning" else "info", "stage_completed",
  "doctor.preflight_completed", "Platform readiness checks completed.",
  details = list(
    check_count = nrow(result$checks), warning_count = warning_count,
    failure_count = failure_count, status = result$overall_status
  )
)
rrp_print_doctor(result)
if (identical(result$overall_status, "blocked")) {
  rrp_fail_operation_observability(
    emitter, "doctor.blocked", "Doctor found blocking readiness failures.",
    "Follow the documented recovery guidance, then run doctor again."
  )
  quit(save = "no", status = 1L, runLast = FALSE)
}
rrp_complete_operation_observability(emitter, warning_count)
