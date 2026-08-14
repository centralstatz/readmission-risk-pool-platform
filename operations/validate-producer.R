#!/usr/bin/env Rscript

file_argument <- grep("^--file=", commandArgs(trailingOnly = FALSE), value = TRUE)
script_path <- normalizePath(sub("^--file=", "", file_argument[[1L]]), mustWork = TRUE)
repository_root <- normalizePath(file.path(dirname(script_path), ".."), mustWork = TRUE)

for (file in c(
  "observability-operation.R", "validation-result.R", "conformance-result.R",
  "specification-validation.R", "foundation-context-validation.R",
  "canonical-bundle-validation.R", "canonical-clinical-validation.R",
  "canonical-producer-operation.R"
)) source(file.path(repository_root, "operations", "lib", file))
source(file.path(
  repository_root, "operations", "compositions", "installed-producers.R"
))

arguments <- commandArgs(trailingOnly = TRUE)
scale <- "test"
if (length(arguments) == 2L && identical(arguments[[1L]], "--scale")) {
  scale <- arguments[[2L]]
} else if (length(arguments) > 0L) {
  message("Usage: Rscript operations/validate-producer.R [--scale test|reference]")
  quit(save = "no", status = 2L, runLast = FALSE)
}
if (!scale %in% c("test", "reference")) {
  message("Scale must be test or reference for the shipped producer.")
  quit(save = "no", status = 2L, runLast = FALSE)
}

emitter <- rrp_start_operation_observability(
  "platform.validate-producer",
  list(scale = scale, data_classification = "fictional_nonclinical")
)
composition <- tryCatch(
  rrp_installed_canonical_producer_composition(repository_root),
  error = function(condition) {
    rrp_fail_operation_observability(
      emitter, "producer.validation_failed", "Producer composition validation failed.",
      "Review the producer declaration, trusted registration, and platform-instance selection."
    )
    message(conditionMessage(condition))
    NULL
  }
)
if (is.null(composition)) quit(save = "no", status = 1L, runLast = FALSE)
selection <- composition$selection
invocation <- list(
  producer_execution_id = paste0("producer_conformance_", scale, "_001"),
  canonical_as_of_time = NULL,
  producer_configuration = list(scale = scale)
)
result <- rrp_conform_registered_canonical_producer(
  composition$registry, selection$producer_id, selection$producer_version,
  invocation, repository_root
)
if (!rrp_conforms(result)) {
  rrp_fail_operation_observability(
    emitter, "producer.validation_failed", "Configured producer failed conformance.",
    "Resolve the structured conformance issues before running the platform."
  )
  print(result)
  quit(save = "no", status = 1L, runLast = FALSE)
}
rrp_complete_operation_observability(
  emitter,
  related_identities = list(
    producer_id = selection$producer_id,
    producer_version = selection$producer_version
  ),
  details = list(validation_status = "pass")
)
cat("Operation: platform.validate-producer\n")
cat("Status: succeeded\n")
cat("  producer: ", selection$producer_id, "@", selection$producer_version, "\n", sep = "")
cat("  canonical_profile: platform.readmission-initial-profile@0.1.0\n")
cat("  conformance: pass\n")
cat("  data_classification: fictional_nonclinical\n")
cat("No source or canonical data were written and no downstream runtime was invoked.\n")

