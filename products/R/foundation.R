# Dependency-light primitives for logical product identity and structured
# conformance. Physical serialization and integrity hashes are deliberately
# outside this layer.

rrp_product_scalar_string <- function(value) {
  is.character(value) && length(value) == 1L && !is.na(value) && nzchar(value)
}

rrp_product_semver <- function(value) {
  rrp_product_scalar_string(value) && grepl(
    paste0(
      "^(0|[1-9][0-9]*)\\.(0|[1-9][0-9]*)\\.(0|[1-9][0-9]*)",
      "(?:-[0-9A-Za-z-]+(?:\\.[0-9A-Za-z-]+)*)?",
      "(?:\\+[0-9A-Za-z-]+(?:\\.[0-9A-Za-z-]+)*)?$"
    ),
    value,
    perl = TRUE
  )
}

rrp_product_timestamp <- function(value) {
  if (!rrp_product_scalar_string(value) || !grepl(
    paste0(
      "^[0-9]{4}-[0-9]{2}-[0-9]{2}T[0-9]{2}:[0-9]{2}:[0-9]{2}",
      "(?:[.][0-9]+)?(?:Z|[+-][0-9]{2}:[0-9]{2})$"
    ),
    value,
    perl = TRUE
  )) return(FALSE)
  !is.na(rrp_product_time_number(value))
}

rrp_product_time_number <- function(value) {
  normalized <- sub("Z$", "+0000", value)
  normalized <- sub("([+-][0-9]{2}):([0-9]{2})$", "\\1\\2", normalized)
  suppressWarnings(as.numeric(as.POSIXct(
    normalized,
    format = "%Y-%m-%dT%H:%M:%OS%z",
    tz = "UTC"
  )))
}

rrp_product_identity <- function(document) {
  list(
    specification_kind = document$specification_kind,
    specification_id = document$specification_id,
    specification_version = document$specification_version
  )
}

rrp_product_deterministic_id <- function(prefix, ...) {
  values <- unlist(list(...), recursive = TRUE, use.names = FALSE)
  encoded <- vapply(values, function(value) {
    value <- enc2utf8(as.character(value))
    paste0(nchar(value, type = "bytes"), ":", value)
  }, character(1))
  paste0(prefix, "::", paste(encoded, collapse = "|"))
}

rrp_product_reference_key <- function(reference) {
  paste(
    reference$specification_kind,
    reference$specification_id,
    reference$specification_version,
    sep = "@"
  )
}

rrp_product_row_id <- function(specification, product_set_id, key_values) {
  rrp_product_deterministic_id(
    "product_row",
    specification$specification_id,
    specification$specification_version,
    product_set_id,
    key_values
  )
}

rrp_product_instance_id <- function(specification, product_set_id) {
  rrp_product_deterministic_id(
    "logical_product",
    specification$specification_id,
    specification$specification_version,
    product_set_id
  )
}

rrp_product_issue <- function(
  rule_id,
  issue_code,
  message,
  object_path = "$",
  product_id = NA_character_
) {
  data.frame(
    rule_id = rule_id,
    severity = "error",
    issue_code = issue_code,
    message = message,
    object_path = object_path,
    product_id = product_id,
    stringsAsFactors = FALSE
  )
}

rrp_empty_product_issues <- function() {
  data.frame(
    rule_id = character(),
    severity = character(),
    issue_code = character(),
    message = character(),
    object_path = character(),
    product_id = character(),
    stringsAsFactors = FALSE
  )
}

rrp_bind_product_issues <- function(issues) {
  issues <- Filter(function(value) !is.null(value) && nrow(value) > 0L, issues)
  if (length(issues) == 0L) return(rrp_empty_product_issues())
  do.call(rbind, issues)
}

rrp_product_conformance_result <- function(target, issues = list()) {
  bound <- rrp_bind_product_issues(issues)
  structure(list(
    overall_status = if (nrow(bound) == 0L) "pass" else "fail",
    evaluated_against = target,
    issues = bound
  ), class = "rrp_product_conformance_result")
}

rrp_product_conforms <- function(result) {
  inherits(result, "rrp_product_conformance_result") &&
    identical(result$overall_status, "pass")
}

rrp_product_build_result <- function(
  overall_status,
  failure_stage = NULL,
  message,
  product_set = NULL,
  products = list(),
  conformance_results = list()
) {
  structure(list(
    overall_status = overall_status,
    failure_stage = failure_stage,
    message = message,
    product_set = product_set,
    products = products,
    conformance_results = conformance_results
  ), class = "rrp_product_build_result")
}

rrp_product_copy <- function(value) unserialize(serialize(value, NULL))

rrp_product_version_supported <- function(reference, declaration) {
  if (!is.list(reference) || !is.list(declaration)) return(FALSE)
  expected <- declaration$supported_specification_version
  actual_parts <- strsplit(reference$specification_version, ".", fixed = TRUE)[[1L]]
  expected_parts <- strsplit(expected, ".", fixed = TRUE)[[1L]]
  identical(reference$specification_kind, declaration$specification_kind) &&
    identical(reference$specification_id, declaration$specification_id) &&
    rrp_product_semver(reference$specification_version) &&
    rrp_product_semver(expected) &&
    identical(actual_parts[1:2], expected_parts[1:2])
}

rrp_product_builder_reference <- function(product_set_contract) {
  list(
    builder_id = product_set_contract$builder$builder_id,
    builder_version = product_set_contract$builder$builder_version
  )
}

