# Physical bundle primitives. Logical product identity remains owned by
# products/R and never includes these paths, hashes, or adapter identities.

rrp_yaml_bundle_format_reference <- function() list(
  format_id = "yaml-product-bundle",
  format_version = "0.1.0"
)

rrp_yaml_bundle_now <- function() {
  format(Sys.time(), "%Y-%m-%dT%H:%M:%SZ", tz = "UTC")
}

rrp_yaml_bundle_member_files <- function() c(
  current_episode_risk = "current-episode-risk.yml",
  episode_risk_history = "episode-risk-history.yml",
  operational_run_summary = "operational-run-summary.yml"
)

rrp_yaml_bundle_checksum <- function(path) {
  unname(as.character(tools::md5sum(path)[[1L]]))
}

rrp_yaml_bundle_string_checksum <- function(value) {
  path <- tempfile("rrp-product-identity-")
  on.exit(unlink(path, force = TRUE), add = TRUE)
  writeLines(enc2utf8(value), path, useBytes = TRUE)
  rrp_yaml_bundle_checksum(path)
}

rrp_yaml_bundle_directory_name <- function(product_set, declaration) {
  identity <- paste(
    product_set$product_set_id,
    product_set$product_generated_at,
    declaration$adapter_id,
    declaration$adapter_version,
    sep = "\n"
  )
  paste0("bundle-", rrp_yaml_bundle_string_checksum(identity))
}

rrp_yaml_bundle_issue <- function(
  category,
  issue_code,
  message,
  object_path = "$",
  member = NA_character_
) {
  data.frame(
    category = category,
    severity = "error",
    issue_code = issue_code,
    message = message,
    object_path = object_path,
    member = member,
    stringsAsFactors = FALSE
  )
}

rrp_empty_yaml_bundle_issues <- function() data.frame(
  category = character(),
  severity = character(),
  issue_code = character(),
  message = character(),
  object_path = character(),
  member = character(),
  stringsAsFactors = FALSE
)

rrp_bind_yaml_bundle_issues <- function(issues) {
  issues <- Filter(function(value) !is.null(value) && nrow(value) > 0L, issues)
  if (length(issues) == 0L) return(rrp_empty_yaml_bundle_issues())
  do.call(rbind, issues)
}

rrp_yaml_bundle_category_status <- function(issues, category, evaluated = TRUE) {
  if (!evaluated) return("not_evaluated")
  if (any(issues$category == category)) "fail" else "pass"
}

rrp_yaml_bundle_validation_result <- function(
  issues = list(),
  freshness = NULL,
  evaluated = c("integrity", "compatibility", "coherence", "freshness"),
  pointer = NULL,
  manifest = NULL,
  products = NULL
) {
  bound <- rrp_bind_yaml_bundle_issues(issues)
  statuses <- stats::setNames(lapply(
    c("integrity", "compatibility", "coherence", "freshness"),
    function(category) rrp_yaml_bundle_category_status(
      bound,
      category,
      category %in% evaluated
    )
  ), c("integrity", "compatibility", "coherence", "freshness"))
  pass <- all(vapply(statuses, identical, logical(1), "pass"))
  structure(list(
    overall_status = if (pass) "pass" else "fail",
    categories = statuses,
    freshness = freshness,
    issues = bound,
    pointer = pointer,
    manifest = manifest,
    products = products
  ), class = "rrp_yaml_bundle_validation_result")
}

rrp_yaml_bundle_read <- function(path) {
  if (!requireNamespace("yaml", quietly = TRUE)) stop(
    "Package `yaml` is required. Restore this repository's renv environment.",
    call. = FALSE
  )
  yaml::read_yaml(path)
}

rrp_yaml_bundle_write <- function(value, path) {
  if (!requireNamespace("yaml", quietly = TRUE)) stop(
    "Package `yaml` is required. Restore this repository's renv environment.",
    call. = FALSE
  )
  yaml::write_yaml(value, path, handlers = list(
    integer = function(value) as.integer(value)
  ))
  invisible(path)
}

rrp_yaml_bundle_is_symlink <- function(path) {
  file.exists(path) && nzchar(Sys.readlink(path))
}

rrp_yaml_bundle_scalar_string <- function(value) {
  is.character(value) && length(value) == 1L && !is.na(value) && nzchar(value)
}

rrp_yaml_bundle_safe_relative_path <- function(value) {
  rrp_yaml_bundle_scalar_string(value) &&
    !grepl("^(/|[A-Za-z]:[/\\\\])", value) &&
    !grepl("(^|[/\\\\])[.][.]([/\\\\]|$)", value) &&
    identical(value, basename(value))
}
