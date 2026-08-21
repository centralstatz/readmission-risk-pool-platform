#!/usr/bin/env Rscript

script <- normalizePath(sub("^--file=", "", grep(
  "^--file=", commandArgs(trailingOnly = FALSE), value = TRUE
)[[1L]]), mustWork = TRUE)
root <- normalizePath(file.path(dirname(script), ".."), mustWork = TRUE)
source(file.path(root, "R", "distribution-runtime.R"))
managed <- rrp_hospital_managed_platform(root)
rrp_hospital_source_platform_cycle(managed, .GlobalEnv)
sys.source(file.path(
  managed, "operations", "compositions", "installed-producers.R"
), envir = .GlobalEnv)
sys.source(file.path(root, "implementation", "R", "composition.R"), envir = .GlobalEnv)
installed <- rrp_install_runtime_package(managed)
on.exit(rrp_unload_runtime_package(installed), add = TRUE)
composition <- rrp_local_hospital_composition(root, managed)
result <- tryCatch(rrp_run_selected_platform_cycle(
  repository_root = managed,
  registry = composition$registry,
  selection = composition$selection,
  producer_invocation = list(
    producer_execution_id = "producer_local_run_001",
    canonical_as_of_time = NULL,
    producer_configuration = list(configuration_status = "not_implemented")
  ),
  database_path = file.path(root, "build", "local", "history.duckdb"),
  runtime_run_id = "runtime_hospital_local_001",
  run_label = "local"
), error = function(condition) condition)
if (inherits(result, "condition")) {
  message("Hospital Platform run failed: ", conditionMessage(result))
  quit(save = "no", status = 1L, runLast = FALSE)
}
cat("Operation: hospital.run-platform\nStatus: succeeded\n")
cat("  runtime_run_id: ", result$runtime_run_id, "\n", sep = "")
