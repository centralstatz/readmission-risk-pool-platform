#!/usr/bin/env Rscript

repository_root <- normalizePath(
  file.path(dirname(sub("^--file=", "", grep(
    "^--file=", commandArgs(trailingOnly = FALSE), value = TRUE
  )[[1L]])), ".."),
  mustWork = TRUE
)

source(file.path(repository_root, "operations", "lib", "validation-result.R"))
source(file.path(repository_root, "operations", "lib", "documentation-validation.R"))
source(file.path(repository_root, "operations", "lib", "repository-validation.R"))
source(file.path(repository_root, "operations", "lib", "conformance-result.R"))
source(file.path(repository_root, "operations", "lib", "specification-validation.R"))
source(file.path(repository_root, "operations", "lib", "foundation-context-validation.R"))
source(file.path(repository_root, "operations", "lib", "canonical-bundle-validation.R"))
source(file.path(repository_root, "operations", "lib", "canonical-clinical-validation.R"))
source(file.path(repository_root, "operations", "lib", "canonical-specification-validation.R"))
for (file in c(
  "identity-configuration.R", "generate-source.R", "source-validation.R",
  "map-to-canonical.R", "producer.R"
)) {
  source(file.path(
    repository_root, "implementations", "synthetic-reference", "R", file
  ))
}
source(file.path(repository_root, "operations", "lib", "synthetic-reference-validation.R"))
source(file.path(repository_root, "operations", "lib", "runtime-operation.R"))
source(file.path(repository_root, "operations", "lib", "provider-operation.R"))
source(file.path(repository_root, "operations", "lib", "runtime-validation.R"))
source(file.path(repository_root, "operations", "lib", "history-validation.R"))
source(file.path(repository_root, "operations", "lib", "duckdb-persistence-operation.R"))
rrp_load_duckdb_persistence_adapter(repository_root)
source(file.path(repository_root, "operations", "lib", "product-operation.R"))
rrp_load_product_layer(repository_root)
source(file.path(
  repository_root, "operations", "lib", "product-materialization-operation.R"
))
rrp_load_yaml_product_adapter(repository_root)
source(file.path(repository_root, "operations", "lib", "product-validation.R"))
source(file.path(repository_root, "operations", "lib", "operator-operation.R"))
source(file.path(repository_root, "operations", "lib", "operator-validation.R"))
source(file.path(
  repository_root, "operations", "lib", "application-artifact-operation.R"
))
rrp_load_application_artifact_contract_runtime(repository_root)
source(file.path(
  repository_root, "operations", "lib", "application-artifact-validation.R"
))
source(file.path(repository_root, "operations", "lib", "platform-validation.R"))

mode <- tryCatch(
  rrp_parse_validation_mode(commandArgs(trailingOnly = TRUE)),
  error = function(condition) {
    message(conditionMessage(condition))
    quit(save = "no", status = 2L, runLast = FALSE)
  }
)

rrp_exit_for_result(rrp_validate_platform(repository_root, mode))
