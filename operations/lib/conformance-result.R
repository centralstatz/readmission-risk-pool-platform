# Structured software-conformance results.
#
# A conformance result evaluates a candidate against a specification. It is not
# an operation log and makes no claim about clinical validity.

rrp_empty_conformance_issues <- function() {
  data.frame(
    rule_id = character(),
    severity = character(),
    issue_code = character(),
    message = character(),
    object_path = character(),
    location = character(),
    specification_kind = character(),
    specification_id = character(),
    specification_version = character(),
    stringsAsFactors = FALSE
  )
}

rrp_conformance_issue <- function(
  rule_id,
  severity,
  issue_code,
  message,
  object_path = NA_character_,
  location = NA_character_,
  specification = NULL
) {
  data.frame(
    rule_id = rule_id,
    severity = severity,
    issue_code = issue_code,
    message = message,
    object_path = object_path,
    location = location,
    specification_kind = specification$specification_kind %||% NA_character_,
    specification_id = specification$specification_id %||% NA_character_,
    specification_version = specification$specification_version %||% NA_character_,
    stringsAsFactors = FALSE
  )
}

`%||%` <- function(value, fallback) {
  if (is.null(value) || length(value) == 0L) fallback else value
}

rrp_candidate_identity <- function(candidate) {
  if (!is.list(candidate)) return(list())
  list(
    specification_kind = candidate$specification_kind %||% NULL,
    specification_id = candidate$specification_id %||% NULL,
    specification_version = candidate$specification_version %||% NULL
  )
}

rrp_conformance_result <- function(candidate, evaluated_against, issues) {
  if (is.null(issues)) issues <- rrp_empty_conformance_issues()
  has_error <- nrow(issues) > 0L && any(issues$severity == "error")

  structure(
    list(
      overall_status = if (has_error) "fail" else "pass",
      candidate = rrp_candidate_identity(candidate),
      evaluated_against = evaluated_against,
      issues = issues
    ),
    class = "rrp_conformance_result"
  )
}

rrp_combine_conformance_results <- function(candidate, evaluated_against, results) {
  issues <- rrp_bind_rows(lapply(results, `[[`, "issues"), rrp_empty_conformance_issues)
  rrp_conformance_result(candidate, evaluated_against, issues)
}

rrp_conforms <- function(result) {
  inherits(result, "rrp_conformance_result") &&
    identical(result$overall_status, "pass")
}

print.rrp_conformance_result <- function(x, ...) {
  target <- paste0(
    x$evaluated_against$specification_id %||% "unknown",
    "@",
    x$evaluated_against$specification_version %||% "unknown"
  )
  cat("<rrp_conformance_result> ", x$overall_status, " against ", target, "\n", sep = "")
  if (nrow(x$issues) > 0L) print(x$issues, row.names = FALSE)
  invisible(x)
}
