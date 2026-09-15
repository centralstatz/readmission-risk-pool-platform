rrp_runtime_empty_issues <- function() {
  data.frame(
    rule_id = character(), issue_code = character(), message = character(),
    object_path = character(), stringsAsFactors = FALSE
  )
}

rrp_runtime_issue <- function(rule_id, issue_code, message, object_path = "$.") {
  data.frame(
    rule_id = rule_id,
    issue_code = issue_code,
    message = message,
    object_path = object_path,
    stringsAsFactors = FALSE
  )
}

rrp_runtime_bind_issues <- function(issues) {
  issues <- Filter(function(value) !is.null(value) && nrow(value) > 0L, issues)
  if (length(issues) == 0L) return(rrp_runtime_empty_issues())
  do.call(rbind, issues)
}

rrp_runtime_result <- function(evaluated_against, issues = list()) {
  issues <- rrp_runtime_bind_issues(issues)
  structure(
    list(
      overall_status = if (nrow(issues) == 0L) "pass" else "fail",
      evaluated_against = evaluated_against,
      issues = issues
    ),
    class = "rrp_runtime_conformance_result"
  )
}

#' Test whether a runtime conformance result passed
#' @export
runtime_conforms <- function(result) {
  inherits(result, "rrp_runtime_conformance_result") &&
    identical(result$overall_status, "pass")
}

rrp_assert_runtime_conforms <- function(result, context) {
  if (runtime_conforms(result)) return(invisible(TRUE))
  codes <- paste(unique(result$issues$issue_code), collapse = ", ")
  stop(context, " failed conformance: ", codes, call. = FALSE)
}

#' @export
print.rrp_runtime_conformance_result <- function(x, ...) {
  cat("<rrp_runtime_conformance_result> ", x$overall_status, "\n", sep = "")
  if (nrow(x$issues) > 0L) print(x$issues, row.names = FALSE)
  invisible(x)
}
