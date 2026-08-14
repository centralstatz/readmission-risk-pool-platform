#!/usr/bin/env Rscript

file_argument <- grep("^--file=", commandArgs(trailingOnly = FALSE), value = TRUE)
script_path <- normalizePath(sub("^--file=", "", file_argument[[1L]]), mustWork = TRUE)
repository_root <- normalizePath(file.path(dirname(script_path), ".."), mustWork = TRUE)

for (file in c(
  "validation-result.R", "documentation-validation.R", "repository-validation.R",
  "conformance-result.R", "specification-validation.R",
  "foundation-context-validation.R", "canonical-bundle-validation.R",
  "canonical-clinical-validation.R", "canonical-producer-operation.R",
  "history-validation.R"
)) source(file.path(repository_root, "operations", "lib", file))
source(file.path(repository_root, "operations", "compositions", "installed-producers.R"))
source(file.path(repository_root, "operations", "lib", "runtime-operation.R"))
source(file.path(repository_root, "operations", "lib", "provider-operation.R"))
source(file.path(repository_root, "operations", "lib", "duckdb-persistence-operation.R"))
rrp_load_duckdb_persistence_adapter(repository_root)
source(file.path(repository_root, "operations", "lib", "reference-history-operation.R"))

arguments <- commandArgs(trailingOnly = TRUE)
scale <- "test"
database_path <- NULL
while (length(arguments) > 0L) {
  if (length(arguments) >= 2L && identical(arguments[[1L]], "--scale")) {
    scale <- arguments[[2L]]
    arguments <- arguments[-c(1L, 2L)]
  } else if (length(arguments) >= 2L && identical(arguments[[1L]], "--database")) {
    database_path <- arguments[[2L]]
    arguments <- arguments[-c(1L, 2L)]
  } else {
    message(paste(
      "Usage: Rscript operations/run-reference-history.R",
      "[--scale test|reference] [--database PATH]"
    ))
    quit(save = "no", status = 2L, runLast = FALSE)
  }
}
if (!scale %in% c("test", "reference")) {
  message("Scale must be test or reference.")
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

result <- tryCatch(
  rrp_run_reference_history(repository_root, scale, database_path),
  error = function(condition) {
    message("Reference history run failed: ", conditionMessage(condition))
    NULL
  }
)
if (is.null(result)) quit(save = "no", status = 1L, runLast = FALSE)

cat("Reference durable history: succeeded\n")
cat("  data_classification: fictional_nonclinical\n")
cat("  scale: ", scale, "\n", sep = "")
cat("  adapter: ", result$adapter$adapter_id, "@", result$adapter$adapter_version, "\n", sep = "")
cat("  schema: ", result$adapter$schema_version, "\n", sep = "")
cat("  runtime_run_id: ", result$runtime_run_id, "\n", sep = "")
cat("  run_status: ", result$run_status, "\n", sep = "")
cat("  database: ", result$database_path, "\n", sep = "")
for (name in names(result$counts)) cat("  ", name, ": ", result$counts[[name]], "\n", sep = "")
cat("\nThe database was closed, reopened read-only, and read through the persistence port.\n")
cat("No products, priorities, tasks, application data, or deployments were created.\n")
