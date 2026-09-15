#!/usr/bin/env Rscript

file_argument <- grep("^--file=", commandArgs(trailingOnly = FALSE), value = TRUE)
test_script <- normalizePath(sub("^--file=", "", file_argument[[1L]]), mustWork = TRUE)
repository_root <- normalizePath(file.path(dirname(test_script), ".."), mustWork = TRUE)

source(file.path(repository_root, "validation", "R", "software-resources.R"))
source(file.path(repository_root, "tests", "helpers", "assertions.R"))

test_file <- file.path(
  repository_root, "tests", "software", "test-resource-catalog.R"
)
environment <- new.env(parent = globalenv())
sys.source(test_file, envir = environment)
cases <- environment$software_resource_test_cases(repository_root)

failures <- list()
for (name in names(cases)) {
  failure <- tryCatch(
    {
      cases[[name]]()
      NULL
    },
    error = function(condition) conditionMessage(condition)
  )
  if (is.null(failure)) {
    cat("PASS ", name, "\n", sep = "")
  } else {
    cat("FAIL ", name, " - ", failure, "\n", sep = "")
    failures[[name]] <- failure
  }
}

if (length(failures) > 0L) {
  cat(
    "Result: FAIL (", length(cases), " tests, ", length(failures),
    " failures)\n", sep = ""
  )
  quit(save = "no", status = 1L, runLast = FALSE)
}

catalog <- yaml::read_yaml(file.path(
  repository_root, "distribution", "software", "resource-catalog.yml"
))
cat(
  "Result: PASS (", length(cases), " tests; ", length(catalog$resources),
  " cataloged resources)\n", sep = ""
)
