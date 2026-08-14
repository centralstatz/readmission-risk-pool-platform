#!/usr/bin/env Rscript

file_argument <- grep("^--file=", commandArgs(trailingOnly = FALSE), value = TRUE)
test_script <- normalizePath(sub("^--file=", "", file_argument[[1L]]), mustWork = TRUE)
repository_root <- normalizePath(file.path(dirname(test_script), ".."), mustWork = TRUE)

for (file in c(
  "validation-result.R", "documentation-validation.R", "repository-validation.R",
  "conformance-result.R", "specification-validation.R",
  "foundation-context-validation.R", "canonical-bundle-validation.R",
  "canonical-clinical-validation.R", "canonical-producer-operation.R"
)) source(file.path(repository_root, "operations", "lib", file))
source(file.path(repository_root, "operations", "compositions", "installed-producers.R"))
source(file.path(repository_root, "tests", "helpers", "assertions.R"))

test_files <- sort(list.files(
  file.path(repository_root, "tests", "phase10"),
  pattern = "^test-.*[.]R$", full.names = TRUE
))
if (length(test_files) == 0L) stop("No Phase 10 test files found.", call. = FALSE)

cases <- list()
for (test_file in test_files) {
  environment <- new.env(parent = globalenv())
  sys.source(test_file, envir = environment)
  cases <- c(cases, environment$phase10_test_cases(repository_root))
}
failures <- list()
for (name in names(cases)) {
  failure <- tryCatch({ cases[[name]](); NULL }, error = function(condition) conditionMessage(condition))
  if (is.null(failure)) cat("PASS ", name, "\n", sep = "") else {
    cat("FAIL ", name, " - ", failure, "\n", sep = "")
    failures[[name]] <- failure
  }
}
if (length(failures) > 0L) {
  cat("Result: FAIL (", length(cases), " tests, ", length(failures), " failures)\n", sep = "")
  quit(save = "no", status = 1L, runLast = FALSE)
}
cat("Result: PASS (", length(cases), " tests)\n", sep = "")

