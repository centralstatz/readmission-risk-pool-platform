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
sys.source(file.path(
  root, "examples", "fictional-adopter", "R", "composition.R"
), envir = .GlobalEnv)

state <- file.path(root, "build", "fictional-adopter")
database <- file.path(state, "history.duckdb")
products <- file.path(state, "products")
artifacts <- file.path(state, "application-artifacts")
run_id <- "runtime_hospital_fictional_adopter_001"
composition <- rrp_hospital_fictional_adopter_composition(root, managed)
invocation <- list(
  producer_execution_id = "producer_hospital_fictional_adopter_001",
  canonical_as_of_time = NULL,
  producer_configuration = list(scenario_id = "fictional_export_case_v1")
)
conformance <- rrp_validate_selected_canonical_producer(
  managed, composition$registry, composition$selection, invocation
)
if (!rrp_conforms(conformance)) {
  print(conformance)
  message("Fictional adopter producer failed shared conformance.")
  quit(save = "no", status = 1L, runLast = FALSE)
}

installed <- rrp_install_runtime_package(managed)
on.exit(rrp_unload_runtime_package(installed), add = TRUE)
cycle <- tryCatch(rrp_run_selected_platform_cycle(
  repository_root = managed,
  registry = composition$registry,
  selection = composition$selection,
  producer_invocation = invocation,
  database_path = database,
  runtime_run_id = run_id,
  run_label = "fictional_adopter"
), error = function(condition) condition)
if (inherits(cycle, "condition")) {
  message("Fictional adopter Platform cycle failed: ", conditionMessage(cycle))
  quit(save = "no", status = 1L, runLast = FALSE)
}

downstream <- tryCatch({
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
if (inherits(downstream, "condition")) {
  message("Fictional adopter downstream proof failed: ", conditionMessage(downstream))
  quit(save = "no", status = 1L, runLast = FALSE)
}
cat("Operation: hospital.run-fictional-adopter-proof\n")
cat("Status: succeeded\n")
cat("  producer: ", composition$selection$producer_id, "@",
    composition$selection$producer_version, "\n", sep = "")
cat("  runtime_run_id: ", run_id, "\n", sep = "")
cat("  state_scope: fictional-adopter\n")
cat("  reduced_artifact: validated\n")
cat("No external repository, publication, or deployment was created.\n")
