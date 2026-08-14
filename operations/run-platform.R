#!/usr/bin/env Rscript

file_argument <- grep("^--file=", commandArgs(trailingOnly = FALSE), value = TRUE)
script_path <- normalizePath(sub("^--file=", "", file_argument[[1L]]), mustWork = TRUE)
repository_root <- normalizePath(file.path(dirname(script_path), ".."), mustWork = TRUE)

for (file in c(
  "observability-operation.R",
  "validation-result.R", "documentation-validation.R", "repository-validation.R",
  "conformance-result.R", "specification-validation.R",
  "foundation-context-validation.R", "canonical-bundle-validation.R",
  "canonical-clinical-validation.R", "canonical-producer-operation.R",
  "history-validation.R"
)) source(file.path(repository_root, "operations", "lib", file))
source(file.path(
  repository_root, "operations", "compositions", "installed-producers.R"
))
source(file.path(repository_root, "operations", "lib", "runtime-operation.R"))
source(file.path(repository_root, "operations", "lib", "provider-operation.R"))
source(file.path(repository_root, "operations", "lib", "duckdb-persistence-operation.R"))
rrp_load_duckdb_persistence_adapter(repository_root)
source(file.path(repository_root, "operations", "lib", "reference-history-operation.R"))

arguments <- commandArgs(trailingOnly = TRUE)
scale <- "test"
database_path <- NULL
runtime_run_id <- NULL
as_of_time <- NULL
while (length(arguments) > 0L) {
  if (length(arguments) >= 2L && identical(arguments[[1L]], "--scale")) {
    scale <- arguments[[2L]]
    arguments <- arguments[-c(1L, 2L)]
  } else if (length(arguments) >= 2L && identical(arguments[[1L]], "--database")) {
    database_path <- arguments[[2L]]
    arguments <- arguments[-c(1L, 2L)]
  } else if (length(arguments) >= 2L && identical(arguments[[1L]], "--run-id")) {
    runtime_run_id <- arguments[[2L]]
    arguments <- arguments[-c(1L, 2L)]
  } else if (length(arguments) >= 2L && identical(arguments[[1L]], "--as-of")) {
    as_of_time <- arguments[[2L]]
    arguments <- arguments[-c(1L, 2L)]
  } else {
    message(paste(
      "Usage: Rscript operations/run-platform.R",
      "[--scale test|reference] [--database PATH] [--run-id ID]",
      "[--as-of RFC3339]"
    ))
    quit(save = "no", status = 2L, runLast = FALSE)
  }
}
if (!scale %in% c("test", "reference")) {
  message("Scale must be test or reference.")
  quit(save = "no", status = 2L, runLast = FALSE)
}
if (!is.null(as_of_time) && is.null(runtime_run_id)) {
  runtime_run_id <- paste0(
    "runtime_reference_", scale, "_", gsub("[^0-9A-Za-z]", "", as_of_time)
  )
}
if (!is.null(runtime_run_id) && (!is.character(runtime_run_id) ||
    length(runtime_run_id) != 1L || !nzchar(runtime_run_id))) {
  message("Run ID must be one non-empty value.")
  quit(save = "no", status = 2L, runLast = FALSE)
}
if (is.null(database_path)) {
  configuration <- rrp_read_duckdb_configuration(repository_root)
  database_path <- file.path(repository_root, configuration$database_path)
} else if (!grepl("^(/|[A-Za-z]:[/\\\\])", database_path)) {
  database_path <- file.path(repository_root, database_path)
}

installed <- tryCatch(
  rrp_install_runtime_package(repository_root),
  error = function(condition) {
    message(conditionMessage(condition))
    quit(save = "no", status = 1L, runLast = FALSE)
  }
)
on.exit(rrp_unload_runtime_package(installed), add = TRUE)
emitter <- rrp_start_operation_observability(
  "platform.run",
  list(scale = scale, data_classification = "fictional_nonclinical")
)
result <- tryCatch(
  rrp_run_reference_history(
    repository_root, scale, database_path, runtime_run_id, as_of_time, emitter
  ),
  error = function(condition) {
    rrp_fail_operation_observability(
      emitter, "run.failed", "Reference platform operation failed.",
      "Review the operation error and doctor output, then retry the run."
    )
    message("Reference platform run failed: ", conditionMessage(condition))
    NULL
  }
)
if (is.null(result)) quit(save = "no", status = 1L, runLast = FALSE)
rrp_complete_operation_observability(
  emitter,
  related_identities = list(analytical_runtime_run_id = result$runtime_run_id),
  details = list(run_status = result$run_status)
)

cat("Operation: platform.run\n")
cat("Status: succeeded\n")
cat("  data_classification: fictional_nonclinical\n")
cat("  scale: ", scale, "\n", sep = "")
cat("  producer: ", result$producer_reference$producer_id, "@",
    result$producer_reference$producer_version, "\n", sep = "")
cat("  runtime_run_id: ", result$runtime_run_id, "\n", sep = "")
cat("  run_status: ", result$run_status, "\n", sep = "")
cat("  operational_history: ", result$database_path, "\n", sep = "")
for (name in names(result$counts)) cat("  ", name, ": ", result$counts[[name]], "\n", sep = "")
cat("Next: inspect history, then materialize products.\n")
cat("No products, application process, schedule, or deployment was created.\n")
