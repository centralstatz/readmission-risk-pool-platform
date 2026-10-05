library(rrpplatform)

internal <- function(name) get(name, envir = asNamespace("rrpplatform"))

product_rows <- function(episodes, estimates, times, runs) data.frame(
  product_row_id = paste0("row.", seq_along(episodes)),
  episode_id = episodes,
  target_id = "rrp.risk-target.readmission-remaining-30-day",
  target_version = "0.1.0", analytical_time = times,
  estimate_value = estimates,
  estimate_record_id = paste0("estimate.", seq_along(episodes)),
  analytical_run_id = runs, source_operation_run_id = "operation.1",
  state_id = "state.1", request_id = paste0("request.", seq_along(episodes)),
  provider_id = ifelse(seq_along(episodes) %% 2L, "provider.a", "provider.b"),
  provider_version = "1.0.0", implementation_id = "implementation.1",
  implementation_version = "1.0.0",
  model_id = ifelse(seq_along(episodes) %% 2L, "model.a", NA_character_),
  model_version = ifelse(seq_along(episodes) %% 2L, "1.0.0", NA_character_),
  target_interval_start = times,
  target_interval_end = "2026-02-19T12:00:00Z",
  target_interval_boundary = "(start,end]", stringsAsFactors = FALSE
)

episodes <- sprintf("episode.%02d", 1:12)
current <- product_rows(
  episodes, c(0.9, 0.9, seq(0.8, 0.1, length.out = 10L)),
  rep("2026-01-20T12:00:00Z", 12L), paste0("run.", 1:12)
)
trajectory <- product_rows(
  c("episode.01", "episode.01", "episode.02", "episode.historical"),
  c(0.7, 0.9, 0.9, 0.4),
  c("2026-01-18T12:00:00Z", "2026-01-20T12:00:00Z",
    "2026-01-20T12:00:00Z", "2026-01-19T12:00:00Z"),
  paste0("trajectory.", 1:4)
)
trajectory$analytical_kind <- c("initial", "continuation", "initial", "initial")
trajectory$related_analytical_run_id <- NA_character_
summary <- data.frame(
  product_row_id = "summary.1", operation_run_id = "operation.1",
  scope_record_id = "scope.1", state_id = "state.1", project_id = "project.1",
  project_version = "1.0.0", bundle_instance_id = "bundle.1",
  canonical_profile_id = "rrp.canonical-profile.readmission",
  canonical_profile_version = "0.1.0", producer_id = "producer.1",
  producer_version = "1.0.0", producer_implementation_id = "producer.impl",
  producer_implementation_version = "1.0.0", mapping_id = "mapping.1",
  mapping_version = "1.0.0",
  target_id = "rrp.risk-target.readmission-remaining-30-day",
  target_version = "0.1.0", analytical_time = "2026-01-20T12:00:00Z",
  scope_created_at = "2026-01-20T12:01:00Z", expected_episode_count = 14L,
  initial_disposition_count = 14L, effective_disposition_count = 14L,
  eligible_count = 12L, accepted_estimate_count = 12L,
  provider_incompatible_count = 0L, provider_declared_failure_count = 0L,
  detected_failure_count = 0L, ineligible_count = 2L,
  episode_before_discharge_count = 0L, target_horizon_exhausted_count = 1L,
  episode_already_readmitted_count = 1L, episode_already_dead_count = 0L,
  membership_fingerprint = "membership.1", complete = TRUE,
  stringsAsFactors = FALSE
)
product <- function(id, data) list(
  product_contract_id = id, product_contract_version = "0.1.0",
  product_instance_id = paste0(id, ".instance"), product_set_id = "set.1",
  row_count = as.integer(nrow(data)), data = data
)
snapshot <- structure(list(
  product_set_id = "set.1", source_operation_run_id = "operation.1",
  source_analytical_time = "2026-01-20T12:00:00Z",
  source_history_cutoff = "2026-01-20T12:00:00Z",
  source_history_fingerprint = "fingerprint.1",
  freshness = list(status = "not-evaluated", expected_operation_run_id = NULL,
    expected_history_cutoff = NULL, expected_source_history_fingerprint = NULL),
  products = list(
    current_remaining_risk = product(
      "rrp.product.current-remaining-risk", current
    ),
    remaining_risk_trajectory = product(
      "rrp.product.remaining-risk-trajectory", trajectory
    ),
    operational_scope_summary = product(
      "rrp.product.operational-scope-summary", summary
    )
  )
), class = c("rrp_application_product_snapshot", "list"))
presentation <- structure(list(
  brand_contract_id = "rrp.project-brand", brand_contract_version = "0.1.0",
  source = "rrp-defaults", display_name = "Readmission Risk Pool",
  primary_color = "#1F4E79", logo = NULL,
  rrp_css = ".rrp-test { color: #000; }"
), class = c("rrp_presentation_model", "list"))

current_view <- internal("rrp_application_current_view")(
  current, trajectory, page = 1L, page_size = 5L
)
second_page <- internal("rrp_application_current_view")(
  current, trajectory, page = 2L, page_size = 5L
)
ascending <- internal("rrp_application_current_view")(
  current, trajectory, sort = "risk_asc"
)
filtered <- internal("rrp_application_current_view")(
  current, trajectory, search = "episode.01", provider_id = "provider.a",
  model_id = "model.a"
)
stopifnot(
  identical(current_view$rows$episode_id,
    c("episode.01", "episode.02", "episode.03", "episode.04", "episode.05")),
  identical(second_page$rows$episode_id,
    c("episode.06", "episode.07", "episode.08", "episode.09", "episode.10")),
  identical(ascending$rows$episode_id[[1L]], "episode.12"),
  identical(filtered$rows$episode_id, "episode.01"),
  identical(current_view$total_count, 12L),
  identical(current_view$displayed_count, 5L),
  identical(current_view$rows$estimate_display[1:2], c("90.0%", "90.0%")),
  identical(current_view$rows$followup_context[[1L]],
    "30 days remaining at as-of"),
  identical(tail(current_view$episode_choices, 1L), "episode.historical"),
  grepl("no current estimate", tail(names(
    current_view$episode_choice_labels
  ), 1L), fixed = TRUE),
  identical(internal("rrp_application_selected_row")(
    current_view, "episode.01"
  ), 1L),
  is.na(internal("rrp_application_selected_row")(
    current_view, "episode.historical"
  )),
  is.na(internal("rrp_application_selected_row")(current_view, NULL))
)

sparks <- internal("rrp_application_sparklines")(
  trajectory, c("episode.01", "episode.02", "episode.03")
)
multiple_markup <- as.character(internal("rrp_application_sparkline_tag")(
  sparks$episode.01
))
single_markup <- as.character(internal("rrp_application_sparkline_tag")(
  sparks$episode.02
))
empty_markup <- as.character(internal("rrp_application_sparkline_tag")(
  sparks$episode.03
))
stopifnot(
  identical(unname(vapply(sparks, `[[`, character(1L), "state")),
    c("multiple", "single", "unavailable")),
  lengths(regmatches(multiple_markup, gregexpr("<circle", multiple_markup,
    fixed = TRUE))) == 2L,
  grepl("<polyline", multiple_markup, fixed = TRUE),
  lengths(regmatches(single_markup, gregexpr("<circle", single_markup,
    fixed = TRUE))) == 1L,
  !grepl("<polyline", single_markup, fixed = TRUE),
  grepl("No history", empty_markup, fixed = TRUE)
)

risk_low <- as.character(internal("rrp_application_risk_tag")(0.1, "10.0%"))
risk_high <- as.character(internal("rrp_application_risk_tag")(0.9, "90.0%"))
stopifnot(
  grepl("width:10%", risk_low, fixed = TRUE),
  grepl("width:90%", risk_high, fixed = TRUE),
  !grepl("high|medium|low", paste(risk_low, risk_high), ignore.case = TRUE)
)

trajectory_multiple <- internal("rrp_application_trajectory_view")(
  trajectory, "episode.01"
)
trajectory_single <- internal("rrp_application_trajectory_view")(
  trajectory, "episode.02"
)
trajectory_empty <- internal("rrp_application_trajectory_view")(
  trajectory, "episode.03"
)
multiple_plot <- plotly::plotly_build(
  internal("rrp_application_trajectory_plot")(trajectory_multiple)
)
single_plot <- plotly::plotly_build(
  internal("rrp_application_trajectory_plot")(trajectory_single)
)
stopifnot(
  identical(trajectory_multiple$state, "multiple"),
  identical(trajectory_single$state, "single"),
  identical(trajectory_empty$state, "unavailable"),
  nrow(trajectory_multiple$rows) == 2L,
  nrow(trajectory_single$rows) == 1L,
  nrow(trajectory_empty$rows) == 0L,
  identical(multiple_plot$x$data[[1L]]$mode, "lines+markers"),
  identical(single_plot$x$data[[1L]]$mode, "markers"),
  length(multiple_plot$x$data[[1L]]$y) == 2L,
  identical(multiple_plot$x$layout$yaxis$range, c(0, 1)),
  identical(multiple_plot$x$config$displayModeBar, FALSE),
  grepl("not estimates between points", trajectory_multiple$note, fixed = TRUE)
)

model <- internal("rrp_application_model")(snapshot, presentation)
table <- internal("rrp_application_current_table")(
  current_view, internal("rrp_application_sparklines")(
    trajectory, current_view$rows$episode_id
  )
)
observation_table <- internal("rrp_application_observation_table")(
  trajectory_multiple
)
ui_text <- as.character(internal("rrp_application_ui")(model))
stopifnot(
  inherits(table, "reactable"), inherits(observation_table, "reactable"),
  identical(model$view_models$status$label, "Freshness not evaluated"),
  identical(model$view_models$overview$accepted_current_count, 12L),
  identical(model$view_models$overview$minimum, 0.1),
  identical(model$view_models$overview$maximum, 0.9),
  grepl("Current Risk Pool", ui_text, fixed = TRUE),
  grepl("Overview", ui_text, fixed = TRUE),
  grepl("--rrp-brand-primary:#1F4E79", ui_text, fixed = TRUE),
  grepl("not clinical priority", ui_text, fixed = TRUE),
  !grepl("High risk|Medium risk|Low risk", ui_text)
)

for (status in c("fresh", "stale")) {
  state <- snapshot
  state$freshness$status <- status
  state_model <- internal("rrp_application_model")(state, presentation)
  stopifnot(identical(state_model$view_models$status$status, status))
}

branded <- presentation
branded$source <- "project-brand"
branded$display_name <- "Example Hospital"
branded$primary_color <- "#6A1B5D"
branded$logo <- list(
  media_type = "image/png",
  bytes = as.raw(c(0x89, 0x50, 0x4e, 0x47, 0x0d, 0x0a, 0x1a, 0x0a)),
  alt = "Example Hospital logo"
)
identity <- as.character(internal("rrp_application_identity")(branded))
stopifnot(
  grepl("Example Hospital", identity, fixed = TRUE),
  grepl("data:image/png;base64,iVBORw0KGgo=", identity, fixed = TRUE),
  grepl("Example Hospital logo", identity, fixed = TRUE)
)

shiny::testServer(internal("rrp_application_server")(model), {
  session$setInputs(
    rrp_search = "", rrp_sort = "risk_desc", rrp_page_size = "5",
    rrp_provider = "", rrp_model = ""
  )
  session$flushReact()
  stopifnot(
    identical(output$rrp_pool_count, "5 displayed / 12 matching"),
    identical(output$rrp_page_label, "Page 1 of 3")
  )
  session$setInputs(rrp_next = 1)
  session$flushReact()
  stopifnot(identical(output$rrp_page_label, "Page 2 of 3"))
  session$setInputs(rrp_search = "episode.01")
  session$flushReact()
  stopifnot(
    identical(output$rrp_pool_count, "1 displayed / 1 matching"),
    identical(output$rrp_page_label, "Page 1 of 1")
  )
})

cat("rrpplatform application-experience tests passed\n")
