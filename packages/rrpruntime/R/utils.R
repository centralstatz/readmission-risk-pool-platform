rrp_null_default <- function(value, fallback) {
  if (is.null(value) || length(value) == 0L) fallback else value
}

rrp_is_scalar_string <- function(value) {
  is.character(value) && length(value) == 1L && !is.na(value) && nzchar(value)
}

rrp_is_timestamp <- function(value) {
  if (!rrp_is_scalar_string(value) || !grepl(
    "^[0-9]{4}-[0-9]{2}-[0-9]{2}T[0-9]{2}:[0-9]{2}:[0-9]{2}(?:[.][0-9]+)?(?:Z|[+-][0-9]{2}:[0-9]{2})$",
    value,
    perl = TRUE
  )) return(FALSE)
  !is.na(suppressWarnings(rrp_parse_time(value)))
}

rrp_parse_time <- function(value) {
  normalized <- sub("Z$", "+0000", value)
  normalized <- sub("([+-][0-9]{2}):([0-9]{2})$", "\\1\\2", normalized)
  as.POSIXct(normalized, format = "%Y-%m-%dT%H:%M:%OS%z", tz = "UTC")
}

rrp_time_number <- function(value) {
  if (!rrp_is_timestamp(value)) return(NA_real_)
  as.numeric(rrp_parse_time(value))
}

rrp_format_time <- function(value) {
  format(as.POSIXct(value, origin = "1970-01-01", tz = "UTC"),
         "%Y-%m-%dT%H:%M:%SZ", tz = "UTC")
}

rrp_identity <- function(kind, id, version) {
  list(
    specification_kind = kind,
    specification_id = id,
    specification_version = version
  )
}

rrp_deterministic_id <- function(prefix, ...) {
  components <- lapply(list(...), function(value) {
    value <- enc2utf8(as.character(value))
    paste0(nchar(value, type = "bytes"), ":", value)
  })
  paste0(prefix, "::", paste(unlist(components), collapse = "|"))
}

rrp_named_records <- function(value) {
  is.list(value) && (length(value) == 0L || all(vapply(value, is.list, logical(1))))
}
