# Composition of currently meaningful validation claims.

rrp_validation_modes <- function() c("development", "checkpoint")

rrp_parse_validation_mode <- function(arguments) {
  if (length(arguments) == 2L && identical(arguments[[1L]], "--mode")) {
    mode <- arguments[[2L]]
  } else if (length(arguments) == 1L && startsWith(arguments[[1L]], "--mode=")) {
    mode <- sub("^--mode=", "", arguments[[1L]])
  } else {
    stop(
      "Usage: Rscript operations/validate.R --mode development|checkpoint",
      call. = FALSE
    )
  }

  if (!mode %in% rrp_validation_modes()) {
    stop("Unknown validation mode: ", mode, call. = FALSE)
  }
  mode
}

rrp_run_phase0_tests <- function(repository_root) {
  output <- tempfile("rrp-phase0-tests-", fileext = ".log")
  on.exit(unlink(output, force = TRUE), add = TRUE)

  rscript <- file.path(R.home("bin"), "Rscript")
  test_script <- file.path(repository_root, "tests", "run-phase0-tests.R")
  status <- system2(
    rscript,
    shQuote(test_script),
    stdout = output,
    stderr = output
  )
  lines <- if (file.exists(output)) readLines(output, warn = FALSE) else character()
  passed <- identical(status, 0L)
  result_lines <- lines[grepl("^Result:", lines)]

  checks <- rrp_check(
    "phase0_tests", passed,
    if (passed) {
      if (length(result_lines) > 0L) tail(result_lines, 1L) else "Phase 0 tests passed"
    } else {
      "Phase 0 test process failed"
    }
  )
  issues <- if (passed) {
    rrp_empty_issues()
  } else {
    detail <- paste(tail(lines, 12L), collapse = " | ")
    rrp_issue(
      "phase0_tests", "phase0_test_failure",
      paste("Run Rscript tests/run-phase0-tests.R for details.", detail),
      "tests/run-phase0-tests.R"
    )
  }
  rrp_validation_result("Phase 0 tests", checks, issues)
}

rrp_validate_platform <- function(repository_root, mode) {
  if (!mode %in% rrp_validation_modes()) {
    stop("Unknown validation mode: ", mode, call. = FALSE)
  }

  results <- list(
    rrp_validate_documentation(repository_root),
    rrp_validate_repository_policies(repository_root),
    rrp_run_phase0_tests(repository_root)
  )
  if (identical(mode, "checkpoint")) {
    results <- append(results, list(rrp_validate_phase0_checkpoint(repository_root)), after = 2L)
  }

  scope <- if (identical(mode, "development")) {
    "Development validation"
  } else {
    "Phase 0 strict checkpoint validation"
  }
  rrp_combine_validation_results(scope, results)
}
