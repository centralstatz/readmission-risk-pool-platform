#!/usr/bin/env Rscript

file_argument <- grep("^--file=", commandArgs(trailingOnly = FALSE), value = TRUE)
script_path <- normalizePath(sub("^--file=", "", file_argument[[1L]]), mustWork = TRUE)
repository_root <- normalizePath(file.path(dirname(script_path), ".."), mustWork = TRUE)

source(file.path(repository_root, "operations", "lib", "validation-result.R"))
source(file.path(repository_root, "operations", "lib", "documentation-validation.R"))
source(file.path(repository_root, "operations", "lib", "repository-validation.R"))
source(file.path(repository_root, "operations", "lib", "conformance-result.R"))
source(file.path(repository_root, "operations", "lib", "specification-validation.R"))
source(file.path(repository_root, "operations", "lib", "foundation-context-validation.R"))
source(file.path(repository_root, "operations", "lib", "canonical-bundle-validation.R"))
source(file.path(repository_root, "operations", "lib", "canonical-clinical-validation.R"))
for (file in c(
  "identity-configuration.R", "generate-source.R", "source-validation.R",
  "map-to-canonical.R", "producer.R"
)) {
  source(file.path(
    repository_root, "implementations", "synthetic-reference", "R", file
  ))
}
source(file.path(repository_root, "operations", "lib", "runtime-operation.R"))

arguments <- commandArgs(trailingOnly = TRUE)
input_kind <- "synthetic"
scale <- "test"
while (length(arguments) > 0L) {
  if (length(arguments) >= 2L && identical(arguments[[1L]], "--input")) {
    input_kind <- arguments[[2L]]
    arguments <- arguments[-c(1L, 2L)]
  } else if (length(arguments) >= 2L && identical(arguments[[1L]], "--scale")) {
    scale <- arguments[[2L]]
    arguments <- arguments[-c(1L, 2L)]
  } else {
    message(paste(
      "Usage: Rscript operations/run-reference-runtime.R",
      "[--input independent|synthetic] [--scale test|reference]"
    ))
    quit(save = "no", status = 2L, runLast = FALSE)
  }
}
if (!input_kind %in% c("independent", "synthetic") ||
    !scale %in% c("test", "reference")) {
  message("Input must be independent or synthetic; scale must be test or reference.")
  quit(save = "no", status = 2L, runLast = FALSE)
}

installed <- tryCatch(
  rrp_install_runtime_package(repository_root),
  error = function(condition) {
    message(conditionMessage(condition))
    quit(save = "no", status = 1L, runLast = FALSE)
  }
)
on.exit(rrp_unload_runtime_package(installed), add = TRUE)

if (identical(input_kind, "independent")) {
  document <- yaml::read_yaml(file.path(
    repository_root, "contracts", "canonical", "examples",
    "readmission-initial-profile-valid.yml"
  ))
  bundle <- document$bundle_instance
  runtime_run_id <- "runtime_independent_fixture_001"
} else {
  produced <- rrp_run_synthetic_reference(repository_root, scale)
  if (!identical(produced$overall_status, "succeeded")) {
    message("Synthetic canonical production failed; runtime was not invoked.")
    quit(save = "no", status = 1L, runLast = FALSE)
  }
  bundle <- produced$candidate_bundle
  runtime_run_id <- paste0("runtime_synthetic_", scale, "_001")
}

result <- tryCatch(
  rrp_run_runtime_from_bundle(bundle, repository_root, runtime_run_id),
  error = function(condition) {
    message("Reference runtime failed: ", conditionMessage(condition))
    NULL
  }
)
if (is.null(result)) {
  quit(save = "no", status = 1L, runLast = FALSE)
}
summary <- rrp_runtime_result_summary(result)
cat("Reference runtime: succeeded\n")
cat("  input: ", input_kind, "\n", sep = "")
if (identical(input_kind, "synthetic")) cat("  scale: ", scale, "\n", sep = "")
cat("  runtime package: rrpruntime@0.1.0\n")
cat("  state: platform.readmission-episode-state@0.1.0\n")
cat("  estimand: platform.readmission-next-day-conditional-hazard@0.1.0\n")
cat("  as_of_time: ", result$runtime_context$as_of_time, "\n", sep = "")
cat("  episodes_evaluated: ", summary$episodes_evaluated, "\n", sep = "")
cat("  states_created: ", summary$states_created, "\n", sep = "")
cat("  estimand_requests_created: ", summary$estimand_requests_created, "\n", sep = "")
for (reason in names(summary$eligibility_reasons)) {
  cat("  eligibility_", reason, ": ", summary$eligibility_reasons[[reason]], "\n", sep = "")
}
cat("\nNo provider ran, no risk was estimated, and no data were persisted.\n")
