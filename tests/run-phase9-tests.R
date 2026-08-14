#!/usr/bin/env Rscript

file_argument <- grep("^--file=", commandArgs(trailingOnly = FALSE), value = TRUE)
test_script <- normalizePath(sub("^--file=", "", file_argument[[1L]]), mustWork = TRUE)
repository_root <- normalizePath(file.path(dirname(test_script), ".."), mustWork = TRUE)

source(file.path(repository_root, "operations", "lib", "validation-result.R"))
source(file.path(repository_root, "operations", "lib", "conformance-result.R"))
source(file.path(repository_root, "operations", "lib", "specification-validation.R"))
source(file.path(repository_root, "operations", "lib", "observability-operation.R"))
source(file.path(repository_root, "tests", "helpers", "assertions.R"))

test_files <- sort(list.files(
  file.path(repository_root, "tests", "phase9"),
  pattern = "^test-.*[.]R$", full.names = TRUE
))
if (length(test_files) == 0L) stop("No Phase 9 test files found.", call. = FALSE)

cases <- list()
for (test_file in test_files) {
  environment <- new.env(parent = globalenv())
  sys.source(test_file, envir = environment)
  if (!exists("phase9_test_cases", envir = environment, inherits = FALSE)) stop(
    "Test file does not define phase9_test_cases(): ", test_file, call. = FALSE
  )
  cases <- c(cases, environment$phase9_test_cases(repository_root))
}

failures <- list()
for (name in names(cases)) {
  failure <- tryCatch({ cases[[name]](); NULL }, error = conditionMessage)
  if (is.null(failure)) cat("PASS ", name, "\n", sep = "") else {
    cat("FAIL ", name, " - ", failure, "\n", sep = "")
    failures[[name]] <- failure
  }
}
if (length(failures) > 0L) {
  cat("Result: FAIL (", length(cases), " tests, ", length(failures),
      " failures)\n", sep = "")
  quit(save = "no", status = 1L, runLast = FALSE)
}
cat("Result: PASS (", length(cases), " tests)\n", sep = "")
