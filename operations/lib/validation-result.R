# Shared result primitives for Phase 0 validation.
#
# Validators return data instead of stopping at the first problem. Thin command
# wrappers decide how to render the result and which process status to return.

rrp_empty_checks <- function() {
  data.frame(
    check_id = character(),
    status = character(),
    message = character(),
    stringsAsFactors = FALSE
  )
}

rrp_empty_issues <- function() {
  data.frame(
    check_id = character(),
    code = character(),
    file = character(),
    line = integer(),
    message = character(),
    stringsAsFactors = FALSE
  )
}

rrp_check <- function(check_id, passed, message) {
  data.frame(
    check_id = check_id,
    status = if (isTRUE(passed)) "PASS" else "FAIL",
    message = message,
    stringsAsFactors = FALSE
  )
}

rrp_issue <- function(check_id, code, message, file = NA_character_, line = NA_integer_) {
  data.frame(
    check_id = check_id,
    code = code,
    file = file,
    line = as.integer(line),
    message = message,
    stringsAsFactors = FALSE
  )
}

rrp_bind_rows <- function(rows, empty) {
  rows <- Filter(function(row) !is.null(row) && nrow(row) > 0L, rows)
  if (length(rows) == 0L) return(empty())
  do.call(rbind, rows)
}

rrp_validation_result <- function(scope, checks, issues = rrp_empty_issues()) {
  passed <- nrow(issues) == 0L &&
    nrow(checks) > 0L &&
    all(checks$status == "PASS")

  structure(
    list(scope = scope, passed = passed, checks = checks, issues = issues),
    class = "rrp_validation_result"
  )
}

rrp_combine_validation_results <- function(scope, results) {
  checks <- rrp_bind_rows(lapply(results, `[[`, "checks"), rrp_empty_checks)
  issues <- rrp_bind_rows(lapply(results, `[[`, "issues"), rrp_empty_issues)
  rrp_validation_result(scope, checks, issues)
}

print.rrp_validation_result <- function(x, ...) {
  cat(x$scope, "\n", sep = "")
  cat(strrep("-", nchar(x$scope)), "\n", sep = "")

  for (index in seq_len(nrow(x$checks))) {
    check <- x$checks[index, ]
    cat(sprintf("%-4s %-30s %s\n", check$status, check$check_id, check$message))
  }

  if (nrow(x$issues) > 0L) {
    cat("\nActionable issues:\n")
    for (index in seq_len(nrow(x$issues))) {
      issue <- x$issues[index, ]
      location <- if (is.na(issue$file) || !nzchar(issue$file)) {
        "repository"
      } else if (is.na(issue$line)) {
        issue$file
      } else {
        paste0(issue$file, ":", issue$line)
      }
      cat(sprintf("- %s [%s] %s\n", location, issue$code, issue$message))
    }
  }

  cat(
    "\nResult: ", if (x$passed) "PASS" else "FAIL",
    " (", nrow(x$checks), " checks, ", nrow(x$issues), " issues)\n",
    sep = ""
  )
  invisible(x)
}

rrp_exit_for_result <- function(result) {
  print(result)
  if (!result$passed) quit(save = "no", status = 1L, runLast = FALSE)
  invisible(result)
}

rrp_script_repository_root <- function() {
  file_argument <- grep("^--file=", commandArgs(trailingOnly = FALSE), value = TRUE)
  if (length(file_argument) != 1L) {
    stop("Cannot determine the operation script path.", call. = FALSE)
  }

  script_path <- normalizePath(sub("^--file=", "", file_argument), mustWork = TRUE)
  normalizePath(file.path(dirname(script_path), ".."), mustWork = TRUE)
}
