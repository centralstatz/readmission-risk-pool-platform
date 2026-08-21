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

rrp_run_phase1_tests <- function(repository_root) {
  output <- tempfile("rrp-phase1-tests-", fileext = ".log")
  on.exit(unlink(output, force = TRUE), add = TRUE)

  rscript <- file.path(R.home("bin"), "Rscript")
  test_script <- file.path(repository_root, "tests", "run-phase1-tests.R")
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
    "phase1_tests", passed,
    if (passed) {
      if (length(result_lines) > 0L) tail(result_lines, 1L) else "Phase 1 tests passed"
    } else {
      "Phase 1 test process failed"
    }
  )
  issues <- if (passed) {
    rrp_empty_issues()
  } else {
    detail <- paste(tail(lines, 12L), collapse = " | ")
    rrp_issue(
      "phase1_tests", "phase1_test_failure",
      paste("Run Rscript tests/run-phase1-tests.R for details.", detail),
      "tests/run-phase1-tests.R"
    )
  }
  rrp_validation_result("Phase 1 tests", checks, issues)
}

rrp_run_phase2_tests <- function(repository_root) {
  output <- tempfile("rrp-phase2-tests-", fileext = ".log")
  on.exit(unlink(output, force = TRUE), add = TRUE)

  rscript <- file.path(R.home("bin"), "Rscript")
  test_script <- file.path(repository_root, "tests", "run-phase2-tests.R")
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
    "phase2_tests", passed,
    if (passed) {
      if (length(result_lines) > 0L) tail(result_lines, 1L) else "Phase 2 tests passed"
    } else {
      "Phase 2 test process failed"
    }
  )
  issues <- if (passed) {
    rrp_empty_issues()
  } else {
    detail <- paste(tail(lines, 12L), collapse = " | ")
    rrp_issue(
      "phase2_tests", "phase2_test_failure",
      paste("Run Rscript tests/run-phase2-tests.R for details.", detail),
      "tests/run-phase2-tests.R"
    )
  }
  rrp_validation_result("Phase 2 tests", checks, issues)
}

rrp_run_phase3_tests <- function(repository_root) {
  output <- tempfile("rrp-phase3-tests-", fileext = ".log")
  on.exit(unlink(output, force = TRUE), add = TRUE)
  rscript <- file.path(R.home("bin"), "Rscript")
  test_script <- file.path(repository_root, "tests", "run-phase3-tests.R")
  status <- system2(
    rscript, shQuote(test_script), stdout = output, stderr = output
  )
  lines <- if (file.exists(output)) readLines(output, warn = FALSE) else character()
  passed <- identical(status, 0L)
  result_lines <- lines[grepl("^Result:", lines)]
  checks <- rrp_check(
    "phase3_tests", passed,
    if (passed) {
      if (length(result_lines) > 0L) tail(result_lines, 1L) else "Phase 3 tests passed"
    } else {
      "Phase 3 test process failed"
    }
  )
  issues <- if (passed) {
    rrp_empty_issues()
  } else {
    detail <- paste(tail(lines, 12L), collapse = " | ")
    rrp_issue(
      "phase3_tests", "phase3_test_failure",
      paste("Run Rscript tests/run-phase3-tests.R for details.", detail),
      "tests/run-phase3-tests.R"
    )
  }
  rrp_validation_result("Phase 3 tests", checks, issues)
}

rrp_run_phase4_tests <- function(repository_root) {
  output <- tempfile("rrp-phase4-tests-", fileext = ".log")
  on.exit(unlink(output, force = TRUE), add = TRUE)
  rscript <- file.path(R.home("bin"), "Rscript")
  test_script <- file.path(repository_root, "tests", "run-phase4-tests.R")
  status <- system2(rscript, shQuote(test_script), stdout = output, stderr = output)
  lines <- if (file.exists(output)) readLines(output, warn = FALSE) else character()
  passed <- identical(status, 0L)
  result_lines <- lines[grepl("^Result:", lines)]
  checks <- rrp_check(
    "phase4_tests", passed,
    if (passed) {
      if (length(result_lines) > 0L) tail(result_lines, 1L) else "Phase 4 tests passed"
    } else "Phase 4 test process failed"
  )
  issues <- if (passed) rrp_empty_issues() else rrp_issue(
    "phase4_tests", "phase4_test_failure",
    paste(
      "Run Rscript tests/run-phase4-tests.R for details.",
      paste(tail(lines, 12L), collapse = " | ")
    ),
    "tests/run-phase4-tests.R"
  )
  rrp_validation_result("Phase 4 tests", checks, issues)
}

rrp_run_phase5_tests <- function(repository_root) {
  output <- tempfile("rrp-phase5-tests-", fileext = ".log")
  on.exit(unlink(output, force = TRUE), add = TRUE)
  rscript <- file.path(R.home("bin"), "Rscript")
  test_script <- file.path(repository_root, "tests", "run-phase5-tests.R")
  status <- system2(rscript, shQuote(test_script), stdout = output, stderr = output)
  lines <- if (file.exists(output)) readLines(output, warn = FALSE) else character()
  passed <- identical(status, 0L)
  result_lines <- lines[grepl("^Result:", lines)]
  checks <- rrp_check(
    "phase5_tests", passed,
    if (passed) {
      if (length(result_lines) > 0L) tail(result_lines, 1L) else "Phase 5 tests passed"
    } else "Phase 5 test process failed"
  )
  issues <- if (passed) rrp_empty_issues() else rrp_issue(
    "phase5_tests", "phase5_test_failure",
    paste(
      "Run Rscript tests/run-phase5-tests.R for details.",
      paste(tail(lines, 12L), collapse = " | ")
    ),
    "tests/run-phase5-tests.R"
  )
  rrp_validation_result("Phase 5 tests", checks, issues)
}

rrp_run_phase6_tests <- function(repository_root) {
  output <- tempfile("rrp-phase6-tests-", fileext = ".log")
  on.exit(unlink(output, force = TRUE), add = TRUE)
  rscript <- file.path(R.home("bin"), "Rscript")
  test_script <- file.path(repository_root, "tests", "run-phase6-tests.R")
  status <- system2(rscript, shQuote(test_script), stdout = output, stderr = output)
  lines <- if (file.exists(output)) readLines(output, warn = FALSE) else character()
  passed <- identical(status, 0L)
  result_lines <- lines[grepl("^Result:", lines)]
  checks <- rrp_check(
    "phase6_tests", passed,
    if (passed) {
      if (length(result_lines) > 0L) tail(result_lines, 1L) else "Phase 6 tests passed"
    } else "Phase 6 test process failed"
  )
  issues <- if (passed) rrp_empty_issues() else rrp_issue(
    "phase6_tests", "phase6_test_failure",
    paste(
      "Run Rscript tests/run-phase6-tests.R for details.",
      paste(tail(lines, 12L), collapse = " | ")
    ),
    "tests/run-phase6-tests.R"
  )
  rrp_validation_result("Phase 6 tests", checks, issues)
}

rrp_run_phase7_tests <- function(repository_root) {
  output <- tempfile("rrp-phase7-tests-", fileext = ".log")
  on.exit(unlink(output, force = TRUE), add = TRUE)
  rscript <- file.path(R.home("bin"), "Rscript")
  test_script <- file.path(repository_root, "tests", "run-phase7-tests.R")
  status <- system2(rscript, shQuote(test_script), stdout = output, stderr = output)
  lines <- if (file.exists(output)) readLines(output, warn = FALSE) else character()
  passed <- identical(status, 0L)
  result_lines <- lines[grepl("^Result:", lines)]
  checks <- rrp_check(
    "phase7_tests", passed,
    if (passed) {
      if (length(result_lines) > 0L) tail(result_lines, 1L) else "Phase 7 tests passed"
    } else "Phase 7 test process failed"
  )
  issues <- if (passed) rrp_empty_issues() else rrp_issue(
    "phase7_tests", "phase7_test_failure",
    paste(
      "Run Rscript tests/run-phase7-tests.R for details.",
      paste(tail(lines, 12L), collapse = " | ")
    ),
    "tests/run-phase7-tests.R"
  )
  rrp_validation_result("Phase 7 tests", checks, issues)
}

rrp_run_phase8_tests <- function(repository_root) {
  output <- tempfile("rrp-phase8-tests-", fileext = ".log")
  on.exit(unlink(output, force = TRUE), add = TRUE)
  rscript <- file.path(R.home("bin"), "Rscript")
  test_script <- file.path(repository_root, "tests", "run-phase8-tests.R")
  status <- system2(rscript, shQuote(test_script), stdout = output, stderr = output)
  lines <- if (file.exists(output)) readLines(output, warn = FALSE) else character()
  passed <- identical(status, 0L)
  result_lines <- lines[grepl("^Result:", lines)]
  checks <- rrp_check(
    "phase8_tests", passed,
    if (passed) {
      if (length(result_lines) > 0L) tail(result_lines, 1L) else "Phase 8 tests passed"
    } else "Phase 8 test process failed"
  )
  issues <- if (passed) rrp_empty_issues() else rrp_issue(
    "phase8_tests", "phase8_test_failure",
    paste(
      "Run Rscript tests/run-phase8-tests.R for details.",
      paste(tail(lines, 12L), collapse = " | ")
    ),
    "tests/run-phase8-tests.R"
  )
  rrp_validation_result("Phase 8 tests", checks, issues)
}

rrp_run_phase9_tests <- function(repository_root) {
  output <- tempfile("rrp-phase9-tests-", fileext = ".log")
  on.exit(unlink(output, force = TRUE), add = TRUE)
  status <- system2(
    file.path(R.home("bin"), "Rscript"),
    shQuote(file.path(repository_root, "tests", "run-phase9-tests.R")),
    stdout = output, stderr = output
  )
  lines <- if (file.exists(output)) readLines(output, warn = FALSE) else character()
  passed <- identical(status, 0L)
  result_lines <- lines[grepl("^Result:", lines)]
  checks <- rrp_check(
    "phase9_tests", passed,
    if (passed && length(result_lines) > 0L) tail(result_lines, 1L) else {
      if (passed) "Phase 9 tests passed" else "Phase 9 test process failed"
    }
  )
  issues <- if (passed) rrp_empty_issues() else rrp_issue(
    "phase9_tests", "phase9_test_failure",
    paste(
      "Run Rscript tests/run-phase9-tests.R for details.",
      paste(tail(lines, 12L), collapse = " | ")
    ), "tests/run-phase9-tests.R"
  )
  rrp_validation_result("Phase 9 tests", checks, issues)
}

rrp_run_phase10_tests <- function(repository_root) {
  output <- tempfile("rrp-phase10-tests-", fileext = ".log")
  on.exit(unlink(output, force = TRUE), add = TRUE)
  status <- system2(
    file.path(R.home("bin"), "Rscript"),
    shQuote(file.path(repository_root, "tests", "run-phase10-tests.R")),
    stdout = output, stderr = output
  )
  lines <- if (file.exists(output)) readLines(output, warn = FALSE) else character()
  passed <- identical(status, 0L)
  result_lines <- lines[grepl("^Result:", lines)]
  checks <- rrp_check(
    "phase10_tests", passed,
    if (passed && length(result_lines) > 0L) tail(result_lines, 1L) else {
      if (passed) "Phase 10 tests passed" else "Phase 10 test process failed"
    }
  )
  issues <- if (passed) rrp_empty_issues() else rrp_issue(
    "phase10_tests", "phase10_test_failure",
    paste(
      "Run Rscript tests/run-phase10-tests.R for details.",
      paste(tail(lines, 12L), collapse = " | ")
    ), "tests/run-phase10-tests.R"
  )
  rrp_validation_result("Phase 10 tests", checks, issues)
}

rrp_run_phase11_tests <- function(repository_root) {
  output <- tempfile("rrp-phase11-tests-", fileext = ".log")
  on.exit(unlink(output, force = TRUE), add = TRUE)
  status <- system2(
    file.path(R.home("bin"), "Rscript"),
    shQuote(file.path(repository_root, "tests", "run-phase11-tests.R")),
    stdout = output, stderr = output
  )
  lines <- if (file.exists(output)) readLines(output, warn = FALSE) else character()
  passed <- identical(status, 0L)
  result_lines <- lines[grepl("^Result:", lines)]
  checks <- rrp_check(
    "phase11_tests", passed,
    if (passed && length(result_lines) > 0L) tail(result_lines, 1L) else {
      if (passed) "Phase 11 tests passed" else "Phase 11 test process failed"
    }
  )
  issues <- if (passed) rrp_empty_issues() else rrp_issue(
    "phase11_tests", "phase11_test_failure",
    paste(
      "Run Rscript tests/run-phase11-tests.R for details.",
      paste(tail(lines, 12L), collapse = " | ")
    ), "tests/run-phase11-tests.R"
  )
  rrp_validation_result("Phase 11 tests", checks, issues)
}

rrp_validate_platform <- function(repository_root, mode) {
  if (!mode %in% rrp_validation_modes()) {
    stop("Unknown validation mode: ", mode, call. = FALSE)
  }

  results <- list(
    rrp_validate_documentation(repository_root),
    rrp_validate_repository_policies(repository_root),
    rrp_validate_specification_repository(repository_root),
    rrp_validate_canonical_specification_repository(repository_root),
    rrp_validate_synthetic_reference_repository(repository_root),
    rrp_validate_runtime_repository(repository_root),
    rrp_validate_history_repository(repository_root),
    rrp_validate_product_repository(repository_root),
    rrp_validate_operator_repository(repository_root),
    rrp_validate_application_artifact_repository(repository_root),
    rrp_validate_connect_cloud_repository(repository_root),
    rrp_validate_observability_repository(repository_root),
    rrp_validate_canonical_producer_repository(repository_root),
    rrp_validate_hospital_distribution_repository(repository_root),
    rrp_run_phase0_tests(repository_root),
    rrp_run_phase1_tests(repository_root),
    rrp_run_phase2_tests(repository_root),
    rrp_run_phase3_tests(repository_root),
    rrp_run_phase4_tests(repository_root),
    rrp_run_phase5_tests(repository_root),
    rrp_run_phase6_tests(repository_root),
    rrp_run_phase7_tests(repository_root),
    rrp_run_phase8_tests(repository_root),
    rrp_run_phase9_tests(repository_root),
    rrp_run_phase10_tests(repository_root),
    rrp_run_phase11_tests(repository_root)
  )
  if (identical(mode, "checkpoint")) {
    results <- append(
      results,
      list(
        rrp_validate_phase0_checkpoint(repository_root),
        rrp_validate_phase1_checkpoint(repository_root),
        rrp_validate_phase2_checkpoint(repository_root),
        rrp_validate_phase3_checkpoint(repository_root),
        rrp_validate_phase4_checkpoint(repository_root),
        rrp_validate_phase5_checkpoint(repository_root),
        rrp_validate_phase6_checkpoint(repository_root),
        rrp_validate_phase7_checkpoint(repository_root),
        rrp_validate_phase8_checkpoint(repository_root),
        rrp_validate_phase9_checkpoint(repository_root),
        rrp_validate_phase10_checkpoint(repository_root),
        rrp_validate_phase11_checkpoint(repository_root)
      ),
      after = 4L
    )
  }

  scope <- if (identical(mode, "development")) {
    "Development validation"
  } else {
    "Phase 11 Hospital distribution checkpoint validation"
  }
  rrp_combine_validation_results(scope, results)
}
