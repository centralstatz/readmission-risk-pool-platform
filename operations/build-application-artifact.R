#!/usr/bin/env Rscript

file_argument <- grep("^--file=", commandArgs(trailingOnly = FALSE), value = TRUE)
script_path <- normalizePath(sub("^--file=", "", file_argument[[1L]]), mustWork = TRUE)
repository_root <- normalizePath(file.path(dirname(script_path), ".."), mustWork = TRUE)
for (file in c(
  "conformance-result.R", "specification-validation.R", "product-operation.R",
  "product-materialization-operation.R", "application-artifact-operation.R"
)) source(file.path(repository_root, "operations", "lib", file))
rrp_load_product_layer(repository_root)
rrp_load_yaml_product_adapter(repository_root)
rrp_load_reference_app(repository_root)
rrp_load_application_artifact_contract_runtime(repository_root)

arguments <- commandArgs(trailingOnly = TRUE)
product_store <- file.path(repository_root, "build", "reference-products")
artifact_store <- file.path(repository_root, "build", "reference-application-artifacts")
built_at <- rrp_application_artifact_now()
while (length(arguments) > 0L) {
  if (length(arguments) >= 2L && identical(arguments[[1L]], "--products")) {
    product_store <- arguments[[2L]]
    arguments <- arguments[-c(1L, 2L)]
  } else if (length(arguments) >= 2L && identical(arguments[[1L]], "--artifacts")) {
    artifact_store <- arguments[[2L]]
    arguments <- arguments[-c(1L, 2L)]
  } else if (length(arguments) >= 2L && identical(arguments[[1L]], "--built-at")) {
    built_at <- arguments[[2L]]
    arguments <- arguments[-c(1L, 2L)]
  } else {
    message(paste(
      "Usage: Rscript operations/build-application-artifact.R",
      "[--products PATH] [--artifacts PATH] [--built-at RFC3339]"
    ))
    quit(save = "no", status = 2L, runLast = FALSE)
  }
}
for (name in c("product_store", "artifact_store")) {
  value <- get(name)
  if (!grepl("^(/|[A-Za-z]:[/\\\\])", value)) {
    assign(name, file.path(repository_root, value))
  }
}
result <- tryCatch(
  rrp_build_reference_application_artifact(
    repository_root, product_store, artifact_store, built_at
  ),
  error = function(condition) condition
)
if (inherits(result, "condition")) {
  message("Application artifact build failed: ", conditionMessage(result))
  quit(save = "no", status = 1L, runLast = FALSE)
}
cat("Operation: platform.build-application-artifact\n")
cat("Status: succeeded\n")
cat("  data_classification: fictional_nonclinical\n")
cat("  artifact_instance_id: ", result$artifact_instance_id, "\n", sep = "")
cat("  artifact_build_id: ", result$artifact_build_id, "\n", sep = "")
cat("  product_set_id: ", result$product_set_id, "\n", sep = "")
cat("  source_as_of_time: ", result$source_as_of_time, "\n", sep = "")
cat("  artifact_path: ", result$artifact_path, "\n", sep = "")
cat("  idempotent: ", tolower(as.character(result$idempotent)), "\n", sep = "")
cat("Next: Rscript operations/validate-application-artifact.R\n")
