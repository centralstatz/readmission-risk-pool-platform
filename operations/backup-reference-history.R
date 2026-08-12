#!/usr/bin/env Rscript

file_argument <- grep("^--file=", commandArgs(trailingOnly = FALSE), value = TRUE)
script_path <- normalizePath(sub("^--file=", "", file_argument[[1L]]), mustWork = TRUE)
repository_root <- normalizePath(file.path(dirname(script_path), ".."), mustWork = TRUE)
source(file.path(repository_root, "operations", "lib", "duckdb-persistence-operation.R"))
rrp_load_duckdb_persistence_adapter(repository_root)

arguments <- commandArgs(trailingOnly = TRUE)
source_path <- NULL
backup_path <- NULL
while (length(arguments) > 0L) {
  if (length(arguments) >= 2L && identical(arguments[[1L]], "--database")) {
    source_path <- arguments[[2L]]
    arguments <- arguments[-c(1L, 2L)]
  } else if (length(arguments) >= 2L && identical(arguments[[1L]], "--backup")) {
    backup_path <- arguments[[2L]]
    arguments <- arguments[-c(1L, 2L)]
  } else {
    message(paste(
      "Usage: Rscript operations/backup-reference-history.R",
      "--database SOURCE --backup NEW_DESTINATION"
    ))
    quit(save = "no", status = 2L, runLast = FALSE)
  }
}
if (is.null(source_path) || is.null(backup_path)) {
  message("Source database and new backup destination are required.")
  quit(save = "no", status = 2L, runLast = FALSE)
}
resolve <- function(path) if (grepl("^(/|[A-Za-z]:[/\\\\])", path)) path else {
  file.path(repository_root, path)
}
result <- tryCatch(
  rrp_backup_duckdb_history(resolve(source_path), resolve(backup_path)),
  error = function(condition) {
    message("Reference history backup failed: ", conditionMessage(condition))
    NULL
  }
)
if (is.null(result)) quit(save = "no", status = 1L, runLast = FALSE)
cat("Reference history backup: succeeded\n")
cat("  source: ", result$source, "\n", sep = "")
cat("  backup: ", result$backup, "\n", sep = "")
cat("The source was checkpointed and the new backup was reopened and validated.\n")
