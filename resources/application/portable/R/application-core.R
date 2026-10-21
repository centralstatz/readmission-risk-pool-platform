# Portable product-only application behavior.
#
# This ordinary source is shared by installed launch and, in a later increment,
# standalone initialization. It deliberately has no dependency on rrpplatform
# internals, project state, history, producers, providers, or model execution.

rrp_application_abort <- function(code) {
  messages <- c(
    application_product_integrity_failed =
      "Application product integrity validation failed.",
    application_product_incompatible = "Application products are incompatible.",
    application_dependency_unavailable =
      "A required application dependency is unavailable.",
    application_input_invalid = "Application input is invalid."
  )
  message <- messages[[code]]
  if (is.null(message)) message <- "Application input is invalid."
  stop(structure(
    list(message = unname(message), call = NULL, code = code),
    class = c("rrp_application_error", "error", "condition")
  ))
}

rrp_application_scalar <- function(value, max_bytes = 120L) {
  is.character(value) && length(value) == 1L && !is.na(value) &&
    nzchar(value) && identical(value, trimws(value)) &&
    nchar(value, type = "bytes") <= max_bytes && !grepl("[[:cntrl:]]", value)
}

rrp_application_copy <- function(value) unserialize(serialize(value, NULL))

rrp_application_required_products <- function() c(
  current_remaining_risk = "rrp.product.current-remaining-risk@0.1.0",
  remaining_risk_trajectory = "rrp.product.remaining-risk-trajectory@0.1.0",
  operational_scope_summary = "rrp.product.operational-scope-summary@0.1.0"
)

rrp_application_validate_presentation <- function(model) {
  valid_logo <- is.null(model$logo) || (
    is.list(model$logo) && identical(names(model$logo),
      c("media_type", "bytes", "alt")) &&
      model$logo$media_type %in% c("image/png", "image/jpeg") &&
      is.raw(model$logo$bytes) && length(model$logo$bytes) > 0L &&
      rrp_application_scalar(model$logo$alt, 200L)
  )
  valid <- is.list(model) &&
    identical(class(model), c("rrp_presentation_model", "list")) &&
    identical(names(model), c(
      "brand_contract_id", "brand_contract_version", "source",
      "display_name", "primary_color", "logo", "rrp_css"
    )) && identical(model$brand_contract_id, "rrp.project-brand") &&
    identical(model$brand_contract_version, "0.1.0") &&
    model$source %in% c("rrp-defaults", "project-brand") &&
    rrp_application_scalar(model$display_name) &&
    grepl("^#[0-9A-F]{6}$", model$primary_color) &&
    is.character(model$rrp_css) && length(model$rrp_css) == 1L &&
    nzchar(model$rrp_css) && valid_logo
  if (!valid) rrp_application_abort("application_input_invalid")
  invisible(model)
}

rrp_application_validate_snapshot <- function(snapshot) {
  expected_fields <- c(
    "product_set_id", "source_operation_run_id", "source_analytical_time",
    "source_history_cutoff", "source_history_fingerprint", "freshness", "products"
  )
  valid <- is.list(snapshot) &&
    identical(class(snapshot), c("rrp_application_product_snapshot", "list")) &&
    identical(names(snapshot), expected_fields) &&
    rrp_application_scalar(snapshot$product_set_id, 160L) &&
    rrp_application_scalar(snapshot$source_operation_run_id, 160L) &&
    rrp_application_scalar(snapshot$source_analytical_time, 32L) &&
    rrp_application_scalar(snapshot$source_history_cutoff, 32L) &&
    rrp_application_scalar(snapshot$source_history_fingerprint, 160L) &&
    is.list(snapshot$freshness) &&
    identical(names(snapshot$products), names(rrp_application_required_products()))
  if (valid) {
    expected <- unname(rrp_application_required_products())
    actual <- vapply(snapshot$products, function(product) {
      if (!is.list(product) || !rrp_application_scalar(
          product$product_contract_id, 160L
        ) || !rrp_application_scalar(product$product_contract_version, 64L)) {
        return("")
      }
      paste0(product$product_contract_id, "@", product$product_contract_version)
    }, character(1L))
    valid <- identical(unname(actual), expected) &&
      all(vapply(snapshot$products, function(product) {
        identical(names(product), c(
          "product_contract_id", "product_contract_version",
          "product_instance_id", "product_set_id", "row_count", "data"
        )) && identical(product$product_set_id, snapshot$product_set_id) &&
          is.integer(product$row_count) && length(product$row_count) == 1L &&
          !is.na(product$row_count) && product$row_count >= 0L &&
          is.data.frame(product$data) &&
          identical(product$row_count, as.integer(nrow(product$data)))
      }, logical(1L)))
  }
  if (!valid) rrp_application_abort("application_product_incompatible")
  invisible(snapshot)
}

rrp_application_probability <- function(value) sprintf("%.1f%%", 100 * value)

rrp_application_followup <- function(analytical_time, target_interval_end) {
  analytical <- as.POSIXct(
    analytical_time, format = "%Y-%m-%dT%H:%M:%OSZ", tz = "UTC"
  )
  endpoint <- as.POSIXct(
    target_interval_end, format = "%Y-%m-%dT%H:%M:%OSZ", tz = "UTC"
  )
  days <- as.numeric(difftime(endpoint, analytical, units = "days"))
  ifelse(
    is.na(days), "Follow-up context unavailable",
    paste0(format(round(days, 1), trim = TRUE), " days remaining at as-of")
  )
}

rrp_application_attribution <- function(provider_id, model_id) {
  ifelse(is.na(model_id) | !nzchar(model_id), provider_id,
    paste0(provider_id, " / ", model_id))
}

rrp_application_current_view <- function(
  current, trajectory, search = "", provider_id = NULL, model_id = NULL,
  sort = "risk_desc", page = 1L, page_size = 25L,
  selected_episode_id = NULL
) {
  if (!is.character(search) || length(search) != 1L || is.na(search) ||
      !is.null(provider_id) && !rrp_application_scalar(provider_id, 96L) ||
      !is.null(model_id) && !rrp_application_scalar(model_id, 96L) ||
      !sort %in% c("risk_desc", "risk_asc", "episode_asc") ||
      !is.numeric(page) || length(page) != 1L || is.na(page) ||
      page != as.integer(page) || page < 1L ||
      !is.numeric(page_size) || length(page_size) != 1L || is.na(page_size) ||
      page_size != as.integer(page_size) || page_size < 1L || page_size > 100L) {
    rrp_application_abort("application_input_invalid")
  }
  rows <- current
  if (nrow(rows)) {
    keep <- grepl(tolower(search), tolower(rows$episode_id), fixed = TRUE)
    if (!is.null(provider_id)) keep <- keep & rows$provider_id == provider_id
    if (!is.null(model_id)) {
      keep <- keep & !is.na(rows$model_id) & rows$model_id == model_id
    }
    rows <- rows[keep, , drop = FALSE]
    order_index <- switch(sort,
      risk_desc = order(-rows$estimate_value, rows$episode_id, method = "radix"),
      risk_asc = order(rows$estimate_value, rows$episode_id, method = "radix"),
      episode_asc = order(rows$episode_id, method = "radix")
    )
    rows <- rows[order_index, , drop = FALSE]
  }
  total <- nrow(rows)
  first <- (as.integer(page) - 1L) * as.integer(page_size) + 1L
  indices <- if (total && first <= total) {
    seq.int(first, min(total, first + as.integer(page_size) - 1L))
  } else integer()
  displayed <- rows[indices, , drop = FALSE]
  display_rows <- data.frame(
    episode_id = displayed$episode_id,
    estimate_value = displayed$estimate_value,
    estimate_display = rrp_application_probability(displayed$estimate_value),
    analytical_time = displayed$analytical_time,
    target_interval_end = displayed$target_interval_end,
    followup_context = rrp_application_followup(
      displayed$analytical_time, displayed$target_interval_end
    ),
    provider_id = displayed$provider_id,
    model_id = displayed$model_id,
    attribution = rrp_application_attribution(
      displayed$provider_id, displayed$model_id
    ),
    stringsAsFactors = FALSE
  )
  current_order <- if (nrow(current)) order(
    -current$estimate_value, current$episode_id, method = "radix"
  ) else integer()
  current_ids <- unique(current$episode_id[current_order])
  trajectory_ids <- sort(unique(trajectory$episode_id), method = "radix")
  choices <- c(current_ids, setdiff(trajectory_ids, current_ids))
  choice_labels <- ifelse(
    choices %in% current_ids, choices,
    paste0(choices, " (retained trajectory; no current estimate)")
  )
  selected <- selected_episode_id
  if (is.null(selected) || !selected %in% choices) {
    selected <- if (length(choices)) choices[[1L]] else NULL
  }
  list(
    rows = display_rows, displayed_count = as.integer(nrow(display_rows)),
    total_count = as.integer(total), page = as.integer(page),
    page_size = as.integer(page_size), episode_choices = choices,
    episode_choice_labels = stats::setNames(choices, choice_labels),
    selected_episode_id = selected,
    provider_choices = sort(unique(current$provider_id), method = "radix"),
    model_choices = sort(unique(stats::na.omit(current$model_id)), method = "radix")
  )
}

rrp_application_selected_row <- function(view, episode_id) {
  if (is.null(episode_id)) return(NA_integer_)
  selected <- match(episode_id, view$rows$episode_id)
  if (is.na(selected)) NA_integer_ else as.integer(selected)
}

rrp_application_trajectory_rows <- function(trajectory, episode_id) {
  rows <- if (is.null(episode_id)) trajectory[FALSE, , drop = FALSE] else
    trajectory[trajectory$episode_id == episode_id, , drop = FALSE]
  if (nrow(rows)) rows <- rows[order(
    rows$analytical_time, rows$analytical_run_id, method = "radix"
  ), , drop = FALSE]
  data.frame(
    episode_id = rows$episode_id,
    analytical_time = rows$analytical_time,
    estimate_value = rows$estimate_value,
    estimate_display = rrp_application_probability(rows$estimate_value),
    followup_context = rrp_application_followup(
      rows$analytical_time, rows$target_interval_end
    ),
    provider_id = rows$provider_id,
    model_id = rows$model_id,
    attribution = rrp_application_attribution(rows$provider_id, rows$model_id),
    analytical_kind = rows$analytical_kind,
    tooltip = if (nrow(rows)) paste0(
      "As of ", rows$analytical_time, "<br>",
      rrp_application_followup(rows$analytical_time, rows$target_interval_end),
      "<br>Accepted risk: ",
      rrp_application_probability(rows$estimate_value), "<br>",
      "Provider / model: ",
      rrp_application_attribution(rows$provider_id, rows$model_id), "<br>",
      "Evaluation: ", rows$analytical_kind
    ) else character(),
    stringsAsFactors = FALSE
  )
}

rrp_application_sparklines <- function(trajectory, episode_ids) {
  stats::setNames(lapply(episode_ids, function(episode_id) {
    rows <- rrp_application_trajectory_rows(trajectory, episode_id)[c(
      "analytical_time", "estimate_value"
    )]
    list(
      state = c("unavailable", "single", "multiple")[[
        min(nrow(rows), 2L) + 1L
      ]],
      observation_count = as.integer(nrow(rows)), rows = rows
    )
  }), episode_ids)
}

rrp_application_trajectory_view <- function(trajectory, episode_id) {
  rows <- rrp_application_trajectory_rows(trajectory, episode_id)
  count <- nrow(rows)
  list(
    episode_id = episode_id,
    state = c("unavailable", "single", "multiple")[[min(count, 2L) + 1L]],
    observation_count = as.integer(count),
    note = switch(as.character(min(count, 2L)),
      `0` = "No accepted trajectory observations are available for this episode.",
      `1` = paste(
        "One governed observation is available.",
        "No change between evaluations can be inferred."
      ),
      `2` = paste(
        "Markers are actual governed observations.",
        "The connector shows observation order, not estimates between points."
      )
    ),
    rows = rows
  )
}

rrp_application_overview <- function(current, summary) {
  values <- current$estimate_value
  quantiles <- if (length(values)) unname(stats::quantile(
    values, probs = c(0, 0.25, 0.5, 0.75, 1), names = FALSE, type = 7
  )) else rep(NA_real_, 5L)
  list(
    accepted_current_count = as.integer(length(values)),
    minimum = quantiles[[1L]], first_quartile = quantiles[[2L]],
    median = quantiles[[3L]], third_quartile = quantiles[[4L]],
    maximum = quantiles[[5L]], distribution = as.numeric(values),
    scope = as.list(summary[1L, c(
      "expected_episode_count", "initial_disposition_count",
      "effective_disposition_count", "eligible_count",
      "accepted_estimate_count", "provider_incompatible_count",
      "provider_declared_failure_count", "detected_failure_count",
      "ineligible_count", "episode_before_discharge_count",
      "target_horizon_exhausted_count", "episode_already_readmitted_count",
      "episode_already_dead_count", "complete"
    ), drop = FALSE])
  )
}

rrp_application_status <- function(snapshot) {
  status <- snapshot$freshness$status
  if (!status %in% c("not-evaluated", "fresh", "stale")) {
    rrp_application_abort("application_input_invalid")
  }
  details <- c(
    `not-evaluated` = paste0(
      "No comparison context was supplied. Source analytical time ",
      snapshot$source_analytical_time, "; history cutoff ",
      snapshot$source_history_cutoff, "."
    ),
    fresh = paste0(
      "Fresh for the supplied comparison context. Source analytical time ",
      snapshot$source_analytical_time, "."
    ),
    stale = paste0(
      "This read-only view retains its original lineage at ",
      snapshot$source_analytical_time,
      ". Refresh and materialization are separate operations."
    )
  )
  list(
    status = status,
    label = c(
      `not-evaluated` = "Freshness not evaluated",
      fresh = "Fresh for the supplied comparison context",
      stale = "Stale product realization"
    )[[status]],
    tone = c(`not-evaluated` = "neutral", fresh = "fresh", stale = "warning")[[status]],
    detail = details[[status]]
  )
}

rrp_application_view_models <- function(snapshot) {
  current <- snapshot$products$current_remaining_risk$data
  trajectory <- snapshot$products$remaining_risk_trajectory$data
  summary <- snapshot$products$operational_scope_summary$data
  current_view <- rrp_application_current_view(current, trajectory)
  list(
    current = current_view,
    sparklines = rrp_application_sparklines(
      trajectory, current_view$episode_choices
    ),
    trajectory = rrp_application_trajectory_view(
      trajectory, current_view$selected_episode_id
    ),
    overview = rrp_application_overview(current, summary),
    status = rrp_application_status(snapshot)
  )
}

rrp_application_model <- function(snapshot, presentation) {
  rrp_application_validate_snapshot(snapshot)
  rrp_application_validate_presentation(presentation)
  model <- structure(list(
    application_contract_id = "rrp.application.supplied",
    application_contract_version = "0.1.0",
    product_snapshot = rrp_application_copy(snapshot),
    presentation = rrp_application_copy(presentation),
    view_models = rrp_application_view_models(snapshot)
  ), class = c("rrp_application_model", "list"))
  rrp_application_validate_model(model)
  model
}

rrp_application_contains_reference <- function(value) {
  if (is.function(value) || is.environment(value) || inherits(value, "connection")) {
    return(TRUE)
  }
  if (is.list(value)) {
    return(any(vapply(value, rrp_application_contains_reference, logical(1L))))
  }
  FALSE
}

rrp_application_validate_model <- function(model) {
  snapshot_fields <- c(
    "product_set_id", "source_operation_run_id", "source_analytical_time",
    "source_history_cutoff", "source_history_fingerprint", "freshness", "products"
  )
  valid <- is.list(model) &&
    identical(class(model), c("rrp_application_model", "list")) &&
    identical(names(model), c(
      "application_contract_id", "application_contract_version",
      "product_snapshot", "presentation", "view_models"
    )) && identical(model$application_contract_id, "rrp.application.supplied") &&
    identical(model$application_contract_version, "0.1.0") &&
    inherits(model$product_snapshot, "rrp_application_product_snapshot") &&
    identical(names(model$product_snapshot), snapshot_fields) &&
    identical(names(model$product_snapshot$products),
      names(rrp_application_required_products())) &&
    is.list(model$view_models) && identical(names(model$view_models), c(
      "current", "sparklines", "trajectory", "overview", "status"
    )) && !rrp_application_contains_reference(model)
  if (!valid) rrp_application_abort("application_input_invalid")
  rrp_application_validate_presentation(model$presentation)
  invisible(model)
}

