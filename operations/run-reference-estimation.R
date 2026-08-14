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
source(file.path(repository_root, "operations", "lib", "canonical-producer-operation.R"))
source(file.path(repository_root, "operations", "compositions", "installed-producers.R"))
source(file.path(repository_root, "operations", "lib", "runtime-operation.R"))
source(file.path(repository_root, "operations", "lib", "provider-operation.R"))

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
      "Usage: Rscript operations/run-reference-estimation.R",
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
  runtime_run_id <- "runtime_independent_estimation_001"
  provider_execution_run_id <- "provider_independent_estimation_001"
} else {
  produced <- rrp_run_installed_canonical_producer(repository_root, scale)
  if (!identical(produced$overall_status, "succeeded")) {
    message("Synthetic canonical production failed; provider was not invoked.")
    quit(save = "no", status = 1L, runLast = FALSE)
  }
  bundle <- produced$canonical_bundle
  runtime_run_id <- paste0("runtime_synthetic_estimation_", scale, "_001")
  provider_execution_run_id <- paste0("provider_synthetic_estimation_", scale, "_001")
}

runtime_result <- tryCatch(
  rrp_run_runtime_from_bundle(bundle, repository_root, runtime_run_id),
  error = function(condition) {
    message("Runtime failed: ", conditionMessage(condition))
    NULL
  }
)
if (is.null(runtime_result)) {
  quit(save = "no", status = 1L, runLast = FALSE)
}
result <- tryCatch(
  rrp_execute_reference_estimation(
    runtime_result, repository_root, provider_execution_run_id
  ),
  error = function(condition) {
    message("Reference estimation failed: ", conditionMessage(condition))
    NULL
  }
)
if (is.null(result)) {
  quit(save = "no", status = 1L, runLast = FALSE)
}
summary <- rrp_estimation_result_summary(result)
provider <- result$provider_specification
cat("Reference estimation: succeeded\n")
cat("  input: ", input_kind, "\n", sep = "")
if (identical(input_kind, "synthetic")) cat("  scale: ", scale, "\n", sep = "")
cat("  runtime package: rrpruntime@0.3.0\n")
cat("  estimand: platform.readmission-next-day-conditional-hazard@0.1.0\n")
cat("  provider: ", provider$provider_id, "@", provider$provider_version, "\n", sep = "")
cat("  estimate: platform.readmission-risk-estimate@0.1.0\n")
cat("  eligible_episodes: ", summary$eligible_episodes, "\n", sep = "")
cat("  estimand_requests: ", summary$estimand_requests, "\n", sep = "")
cat("  successful_estimates: ", summary$successful_estimates, "\n", sep = "")
for (status in names(summary$execution_statuses)) {
  count <- summary$execution_statuses[[status]]
  if (count > 0L) cat("  execution_", status, ": ", count, "\n", sep = "")
}
cat("\nNo estimates were persisted, no episodes were ranked, and no products were built.\n")
