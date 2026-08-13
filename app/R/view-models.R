# Presentation-only transformations. Sorting current risk is not a priority or
# decision policy; history points preserve their actual operational timestamps.

rrp_app_reference_label <- function(reference, id, version) {
  if (is.null(reference)) return(NA_character_)
  paste0(reference[[id]], "@", reference[[version]])
}

rrp_app_current_risk_table <- function(product) {
  if (length(product$rows) == 0L) return(data.frame(
    episode_id = character(),
    estimate_value = numeric(),
    estimand = character(),
    provider = character(),
    state_as_of_time = character(),
    source_runtime_run_id = character(),
    stringsAsFactors = FALSE
  ))
  table <- data.frame(
    episode_id = vapply(product$rows, `[[`, character(1), "episode_id"),
    estimate_value = vapply(product$rows, `[[`, numeric(1), "estimate_value"),
    estimand = vapply(product$rows, function(row) paste0(
      row$estimand_id, "@", row$estimand_version
    ), character(1)),
    provider = vapply(product$rows, function(row) paste0(
      row$provider_id, "@", row$provider_version
    ), character(1)),
    state_as_of_time = vapply(product$rows, `[[`, character(1), "state_as_of_time"),
    source_runtime_run_id = vapply(
      product$rows, `[[`, character(1), "source_runtime_run_id"
    ),
    stringsAsFactors = FALSE
  )
  table[order(-table$estimate_value, table$episode_id, method = "radix"), , drop = FALSE]
}

rrp_app_history_table <- function(product, episode_id = NULL) {
  rows <- product$rows
  if (!is.null(episode_id)) rows <- Filter(function(row) {
    identical(row$episode_id, episode_id)
  }, rows)
  if (length(rows) == 0L) return(data.frame(
    estimate_as_of_time = character(),
    estimate_value = numeric(),
    estimand = character(),
    provider = character(),
    source_runtime_run_id = character(),
    estimate_id = character(),
    stringsAsFactors = FALSE
  ))
  data.frame(
    estimate_as_of_time = vapply(rows, `[[`, character(1), "estimate_as_of_time"),
    estimate_value = vapply(rows, `[[`, numeric(1), "estimate_value"),
    estimand = vapply(rows, function(row) paste0(
      row$estimand_id, "@", row$estimand_version
    ), character(1)),
    provider = vapply(rows, function(row) paste0(
      row$provider_id, "@", row$provider_version
    ), character(1)),
    source_runtime_run_id = vapply(rows, `[[`, character(1), "source_runtime_run_id"),
    estimate_id = vapply(rows, `[[`, character(1), "estimate_id"),
    stringsAsFactors = FALSE
  )
}

rrp_app_run_summary_table <- function(product) {
  if (length(product$rows) == 0L) return(data.frame(
    run_as_of_time = character(),
    runtime_run_id = character(),
    terminal_status = character(),
    successful_estimate_count = integer(),
    failed_execution_count = integer(),
    providers = character(),
    stringsAsFactors = FALSE
  ))
  data.frame(
    run_as_of_time = vapply(product$rows, `[[`, character(1), "run_as_of_time"),
    runtime_run_id = vapply(product$rows, `[[`, character(1), "runtime_run_id"),
    terminal_status = vapply(product$rows, `[[`, character(1), "terminal_status"),
    successful_estimate_count = vapply(
      product$rows, `[[`, integer(1), "successful_estimate_count"
    ),
    failed_execution_count = vapply(
      product$rows, `[[`, integer(1), "failed_execution_count"
    ),
    providers = vapply(product$rows, function(row) paste(vapply(
      row$provider_references,
      function(reference) paste0(reference$provider_id, "@", reference$provider_version),
      character(1)
    ), collapse = ", "), character(1)),
    stringsAsFactors = FALSE
  )
}

rrp_app_freshness_text <- function(freshness) paste0(
  "Platform data as of ", freshness$source_as_of_time,
  " | Source cutoff ", freshness$source_cutoff_time,
  " | Products generated ", freshness$product_generated_at,
  if (!is.null(freshness$product_published_at)) paste0(
    " | Published ", freshness$product_published_at
  ) else "",
  " | Latest represented run ", freshness$latest_source_runtime_run_id
)
