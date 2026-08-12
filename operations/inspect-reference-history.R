#!/usr/bin/env Rscript

file_argument <- grep("^--file=", commandArgs(trailingOnly = FALSE), value = TRUE)
script_path <- normalizePath(sub("^--file=", "", file_argument[[1L]]), mustWork = TRUE)
repository_root <- normalizePath(file.path(dirname(script_path), ".."), mustWork = TRUE)
for (file in c(
  "validation-result.R", "conformance-result.R", "specification-validation.R",
  "history-validation.R", "runtime-operation.R", "duckdb-persistence-operation.R"
)) source(file.path(repository_root, "operations", "lib", file))
rrp_load_duckdb_persistence_adapter(repository_root)

arguments <- commandArgs(trailingOnly = TRUE)
database_path <- NULL
runtime_run_id <- NULL
view <- "valid"
while (length(arguments) > 0L) {
  if (length(arguments) >= 2L && identical(arguments[[1L]], "--database")) {
    database_path <- arguments[[2L]]
    arguments <- arguments[-c(1L, 2L)]
  } else if (length(arguments) >= 2L && identical(arguments[[1L]], "--run-id")) {
    runtime_run_id <- arguments[[2L]]
    arguments <- arguments[-c(1L, 2L)]
  } else if (length(arguments) >= 2L && identical(arguments[[1L]], "--view")) {
    view <- arguments[[2L]]
    arguments <- arguments[-c(1L, 2L)]
  } else {
    message(paste(
      "Usage: Rscript operations/inspect-reference-history.R",
      "--database PATH --run-id ID [--view valid|raw]"
    ))
    quit(save = "no", status = 2L, runLast = FALSE)
  }
}
if (is.null(database_path) || is.null(runtime_run_id) || !view %in% c("valid", "raw")) {
  message("Database, run ID, and a valid/raw view are required.")
  quit(save = "no", status = 2L, runLast = FALSE)
}
if (!grepl("^(/|[A-Za-z]:[/\\\\])", database_path)) {
  database_path <- file.path(repository_root, database_path)
}
installed <- rrp_install_runtime_package(repository_root)
on.exit(rrp_unload_runtime_package(installed), add = TRUE)
contracts <- rrp_read_history_contracts(repository_root)
session <- rrp_open_duckdb_persistence(database_path, contracts, read_only = TRUE)
on.exit(rrp_close_duckdb_persistence(session), add = TRUE)
history <- rrpruntime::read_run_history(
  rrp_duckdb_persistence_port(session), runtime_run_id, view
)
cat("Reference history inspection\n")
cat("  data_classification: fictional_nonclinical\n")
cat("  runtime_run_id: ", runtime_run_id, "\n", sep = "")
cat("  view: ", view, "\n", sep = "")
for (name in names(history)) cat("  ", name, ": ", length(history[[name]]), "\n", sep = "")
if (length(history$operational_run) > 0L) cat(
  "  lifecycle: ", paste(vapply(
    history$operational_run, `[[`, character(1), "run_status"
  ), collapse = " -> "), "\n", sep = ""
)

