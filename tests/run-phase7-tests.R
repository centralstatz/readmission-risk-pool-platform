#!/usr/bin/env Rscript

file_argument <- grep("^--file=", commandArgs(trailingOnly = FALSE), value = TRUE)
test_script <- normalizePath(sub("^--file=", "", file_argument[[1L]]), mustWork = TRUE)
repository_root <- normalizePath(file.path(dirname(test_script), ".."), mustWork = TRUE)

for (file in c(
  "validation-result.R", "documentation-validation.R", "repository-validation.R",
  "conformance-result.R", "specification-validation.R",
  "foundation-context-validation.R", "canonical-bundle-validation.R",
  "canonical-clinical-validation.R", "history-validation.R"
)) source(file.path(repository_root, "operations", "lib", file))
for (file in c(
  "identity-configuration.R", "generate-source.R", "source-validation.R",
  "map-to-canonical.R", "producer.R"
)) source(file.path(
  repository_root, "implementations", "synthetic-reference", "R", file
))
for (file in c(
  "runtime-operation.R", "provider-operation.R", "duckdb-persistence-operation.R",
  "reference-history-operation.R", "product-operation.R",
  "product-materialization-operation.R", "operator-operation.R",
  "operator-validation.R"
)) source(file.path(repository_root, "operations", "lib", file))
source(file.path(repository_root, "tests", "helpers", "assertions.R"))
rrp_load_duckdb_persistence_adapter(repository_root)
rrp_load_product_layer(repository_root)
rrp_load_yaml_product_adapter(repository_root)
rrp_load_reference_app(repository_root)

installed <- rrp_install_runtime_package(repository_root)
on.exit(rrp_unload_runtime_package(installed), add = TRUE)

test_files <- sort(list.files(
  file.path(repository_root, "tests", "phase7"),
  pattern = "^test-.*[.]R$", full.names = TRUE
))
if (length(test_files) == 0L) stop("No Phase 7 test files found.", call. = FALSE)

cases <- list()
for (test_file in test_files) {
  environment <- new.env(parent = globalenv())
  sys.source(test_file, envir = environment)
  if (!exists("phase7_test_cases", envir = environment, inherits = FALSE)) stop(
    "Test file does not define phase7_test_cases(): ", test_file,
    call. = FALSE
  )
  cases <- c(cases, environment$phase7_test_cases(repository_root))
}

failures <- list()
for (name in names(cases)) {
  failure <- tryCatch({
    cases[[name]]()
    NULL
  }, error = function(condition) conditionMessage(condition))
  if (is.null(failure)) cat("PASS ", name, "\n", sep = "") else {
    cat("FAIL ", name, " - ", failure, "\n", sep = "")
    failures[[name]] <- failure
  }
}
if (length(failures) > 0L) {
  cat(
    "Result: FAIL (", length(cases), " tests, ", length(failures), " failures)\n",
    sep = ""
  )
  quit(save = "no", status = 1L, runLast = FALSE)
}
cat("Result: PASS (", length(cases), " tests)\n", sep = "")
