#!/usr/bin/env Rscript

script <- normalizePath(sub("^--file=", "", grep(
  "^--file=", commandArgs(trailingOnly = FALSE), value = TRUE
)[[1L]]), mustWork = TRUE)
root <- normalizePath(file.path(dirname(script), ".."), mustWork = TRUE)
source(file.path(root, "R", "distribution-runtime.R"))
state <- file.path(root, "build", "reference")
database <- file.path(state, "history.duckdb")
products <- file.path(state, "products")
artifacts <- file.path(state, "application-artifacts")
run_id <- "runtime_hospital_reference_001"

result <- tryCatch({
  rrp_initialize_hospital_distribution(root)
  rrp_hospital_print_process(rrp_hospital_delegate_platform(
    root, "doctor.R", c("--database", database, "--products", products)
  ))
  rrp_hospital_print_process(rrp_hospital_delegate_platform(
    root, "run-platform.R", c(
      "--scale", "test", "--database", database, "--run-id", run_id
    )
  ))
  rrp_hospital_print_process(rrp_hospital_delegate_platform(
    root, "build-reference-products.R", c(
      "--database", database, "--scale", "test", "--run-id", run_id,
      "--materialize", "--products", products
    )
  ))
  rrp_hospital_print_process(rrp_hospital_delegate_platform(
    root, "launch-reference-app.R", c("--products", products, "--validate-only")
  ))
  rrp_hospital_print_process(rrp_hospital_delegate_platform(
    root, "build-application-artifact.R", c(
      "--products", products, "--artifacts", artifacts
    )
  ))
  rrp_hospital_print_process(rrp_hospital_delegate_platform(
    root, "validate-application-artifact.R", c("--artifact", artifacts)
  ))
  TRUE
}, error = function(condition) condition)
if (inherits(result, "condition")) {
  message("Hospital reference acceptance failed: ", conditionMessage(result))
  quit(save = "no", status = 1L, runLast = FALSE)
}
cat("Operation: hospital.run-reference-acceptance\n")
cat("Status: succeeded\n")
cat("  runtime_run_id: ", run_id, "\n", sep = "")
cat("  state_scope: reference\n")
cat("  reduced_artifact: validated\n")
cat("No external repository, publication, or deployment was created.\n")
