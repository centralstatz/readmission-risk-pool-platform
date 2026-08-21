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
composition <- rrp_local_hospital_composition(root, managed)
result <- rrp_validate_selected_canonical_producer(
  managed, composition$registry, composition$selection,
  list(
    producer_execution_id = "producer_local_conformance_001",
    canonical_as_of_time = NULL,
    producer_configuration = list(configuration_status = "not_implemented")
  )
)
if (!rrp_conforms(result)) {
  for (index in seq_len(nrow(result$issues))) message(
    "  [", result$issues$issue_code[[index]], "] ",
    result$issues$message[[index]]
  )
  message(paste(
    "Configured local producer is not conforming. Implement the trusted callable",
    "and source mapping under implementation/, then retry."
  ))
  quit(save = "no", status = 1L, runLast = FALSE)
}
cat("Operation: hospital.validate-producer\nStatus: succeeded\n")
