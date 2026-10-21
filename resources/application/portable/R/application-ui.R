# Portable Shiny UI and presentation components.
# Analytical work is complete before these functions are called.

rrp_application_raw_base64 <- function(bytes) {
  alphabet <- strsplit(
    "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/", "",
    fixed = TRUE
  )[[1L]]
  values <- as.integer(bytes)
  if (!length(values)) return("")
  groups <- split(values, ceiling(seq_along(values) / 3L))
  paste0(vapply(groups, function(group) {
    size <- length(group)
    group <- c(group, rep(0L, 3L - size))
    number <- group[[1L]] * 65536L + group[[2L]] * 256L + group[[3L]]
    indices <- c(
      bitwAnd(bitwShiftR(number, 18L), 63L),
      bitwAnd(bitwShiftR(number, 12L), 63L),
      bitwAnd(bitwShiftR(number, 6L), 63L), bitwAnd(number, 63L)
    ) + 1L
    encoded <- alphabet[indices]
    if (size < 3L) encoded[(size + 2L):4L] <- "="
    paste0(encoded, collapse = "")
  }, character(1L)), collapse = "")
}

rrp_application_identity <- function(presentation) {
  logo <- if (is.null(presentation$logo)) NULL else shiny::tags$img(
    class = "rrp-brand-logo",
    src = paste0(
      "data:", presentation$logo$media_type, ";base64,",
      rrp_application_raw_base64(presentation$logo$bytes)
    ),
    alt = presentation$logo$alt
  )
  shiny::tags$div(
    class = "rrp-brand-identity", logo,
    shiny::tags$span(class = "rrp-brand-name", presentation$display_name)
  )
}

rrp_application_sparkline_tag <- function(view) {
  if (identical(view$state, "unavailable")) return(shiny::tags$span(
    class = "rrp-sparkline-unavailable", "No history"
  ))
  rows <- view$rows
  times <- as.numeric(as.POSIXct(
    rows$analytical_time, format = "%Y-%m-%dT%H:%M:%OSZ", tz = "UTC"
  ))
  x <- if (length(times) == 1L || diff(range(times)) == 0) 50 else
    6 + 88 * (times - min(times)) / diff(range(times))
  y <- 30 - 24 * rows$estimate_value
  points <- paste0(round(x, 2), ",", round(y, 2), collapse = " ")
  connector <- if (nrow(rows) > 1L) shiny::tags$polyline(
    points = points, fill = "none", class = "rrp-sparkline-line"
  ) else NULL
  markers <- Map(function(x_value, y_value) shiny::tags$circle(
    cx = x_value, cy = y_value, r = 2.7, class = "rrp-sparkline-point"
  ), x, y)
  shiny::tags$svg(
    class = "rrp-sparkline", viewBox = "0 0 100 36", role = "img",
    `aria-label` = paste(
      view$observation_count,
      if (view$observation_count == 1L) "actual observation" else
        "actual observations"
    ), connector, markers
  )
}

rrp_application_risk_tag <- function(value, display) {
  shiny::tags$div(
    class = "rrp-risk-cell",
    shiny::tags$span(class = "rrp-risk-value", display),
    shiny::tags$span(
      class = "rrp-risk-track", `aria-hidden` = "true",
      shiny::tags$span(
        class = "rrp-risk-fill",
        style = paste0("width:", format(100 * value, trim = TRUE), "%")
      )
    )
  )
}

rrp_application_current_table <- function(view, sparklines) {
  rows <- view$rows
  rows$risk <- rows$estimate_display
  rows$trajectory <- rows$episode_id
  rows$as_of <- rows$analytical_time
  rows$follow_up <- rows$followup_context
  rows$provider_model <- rows$attribution
  rows <- rows[c(
    "episode_id", "risk", "trajectory", "as_of", "follow_up",
    "provider_model", "estimate_value"
  )]
  reactable::reactable(
    rows, class = "rrp-current-table", compact = TRUE, bordered = FALSE,
    striped = FALSE, highlight = TRUE, selection = "single",
    pagination = FALSE, sortable = FALSE,
    defaultColDef = reactable::colDef(headerClass = "rrp-table-header"),
    columns = list(
      episode_id = reactable::colDef(name = "Canonical episode", minWidth = 150),
      risk = reactable::colDef(
        name = "Accepted risk", minWidth = 130,
        cell = function(value, index) rrp_application_risk_tag(
          rows$estimate_value[[index]], value
        )
      ),
      trajectory = reactable::colDef(
        name = "Actual trajectory", minWidth = 120,
        cell = function(value) rrp_application_sparkline_tag(sparklines[[value]])
      ),
      as_of = reactable::colDef(name = "Analytical as-of", minWidth = 175),
      follow_up = reactable::colDef(name = "Follow-up context", minWidth = 180),
      provider_model = reactable::colDef(name = "Provider / model", minWidth = 180),
      estimate_value = reactable::colDef(show = FALSE)
    ),
    language = reactable::reactableLang(
      noData = "No current accepted risk estimates"
    )
  )
}

rrp_application_trajectory_plot <- function(view) {
  rows <- view$rows
  if (!nrow(rows)) return(plotly::layout(
    plotly::plot_ly(), xaxis = list(visible = FALSE),
    yaxis = list(visible = FALSE),
    annotations = list(list(
      text = "No accepted trajectory observations", showarrow = FALSE,
      x = 0.5, y = 0.5, xref = "paper", yref = "paper"
    )), margin = list(l = 20, r = 20, t = 15, b = 20)
  ))
  marker <- list(color = "#16697A", size = 10, line = list(
    color = "#FFFFFF", width = 1.5
  ))
  plot <- if (nrow(rows) > 1L) plotly::plot_ly(
    data = rows, x = ~analytical_time, y = ~estimate_value,
    text = ~tooltip, hoverinfo = "text", type = "scatter",
    mode = "lines+markers", line = list(color = "#7A8793", width = 1.5),
    marker = marker, connectgaps = FALSE, showlegend = FALSE
  ) else plotly::plot_ly(
    data = rows, x = ~analytical_time, y = ~estimate_value,
    text = ~tooltip, hoverinfo = "text", type = "scatter", mode = "markers",
    marker = marker, connectgaps = FALSE, showlegend = FALSE
  )
  plotly::layout(
    plot, hovermode = "closest",
    xaxis = list(title = "Governed evaluation time", fixedrange = FALSE,
      showgrid = FALSE, zeroline = FALSE, automargin = TRUE),
    yaxis = list(title = "Accepted risk", range = c(0, 1),
      tickformat = ".0%", fixedrange = TRUE, gridcolor = "#E7ECF0",
      zeroline = FALSE, automargin = TRUE),
    margin = list(l = 65, r = 20, t = 15, b = 55),
    paper_bgcolor = "rgba(0,0,0,0)", plot_bgcolor = "rgba(0,0,0,0)"
  ) |>
    plotly::config(displayModeBar = FALSE, responsive = TRUE)
}

rrp_application_observation_table <- function(view) {
  rows <- view$rows[c(
    "analytical_time", "estimate_display", "followup_context", "attribution",
    "analytical_kind"
  )]
  names(rows) <- c(
    "Analytical as-of", "Accepted risk", "Follow-up context",
    "Provider / model", "Evaluation"
  )
  reactable::reactable(
    rows, compact = TRUE, bordered = FALSE, striped = FALSE,
    pagination = FALSE, sortable = FALSE,
    defaultColDef = reactable::colDef(headerClass = "rrp-table-header"),
    language = reactable::reactableLang(noData = "No trajectory observations")
  )
}

rrp_application_stat <- function(label, value) shiny::tags$div(
  class = "rrp-stat",
  shiny::tags$span(class = "rrp-stat-label", label),
  shiny::tags$strong(class = "rrp-stat-value", value)
)

rrp_application_status_tag <- function(status) shiny::tags$div(
  class = paste("rrp-status", paste0("rrp-status-", status$tone)),
  role = if (identical(status$tone, "warning")) "alert" else "status",
  shiny::tags$strong(status$label), shiny::tags$span(status$detail)
)

rrp_application_ui <- function(model) {
  overview <- model$view_models$overview
  probability_or_dash <- function(value) if (is.na(value)) "Not available" else
    rrp_application_probability(value)
  scope <- overview$scope
  bslib::page_navbar(
    title = rrp_application_identity(model$presentation),
    id = "rrp_top_view", fillable = FALSE,
    header = shiny::tagList(
      shiny::tags$style(shiny::HTML(model$presentation$rrp_css)),
      shiny::tags$style(shiny::HTML(paste0(
        ":root{--rrp-brand-primary:", model$presentation$primary_color, ";}"
      ))),
      shiny::tags$div(
        class = "rrp-shell-header",
        rrp_application_status_tag(model$view_models$status)
      )
    ),
    bslib::nav_panel(
      "Current Risk Pool",
      shiny::tags$main(
        class = "rrp-page rrp-current-page",
        shiny::tags$div(
          class = "rrp-page-intro",
          shiny::tags$div(
            shiny::tags$h1("Current Risk Pool"),
            shiny::tags$p(
              "Accepted remaining readmission-risk estimates at the selected source state."
            )
          ),
          shiny::tags$p(
            class = "rrp-nonclinical-note",
            "Sorting supports review only; it is not clinical priority or a recommendation."
          )
        ),
        bslib::card(
          class = "rrp-control-card",
          bslib::card_body(shiny::tags$div(
            class = "rrp-controls",
            shiny::textInput(
              "rrp_search", "Episode ID search",
              placeholder = "Canonical episode ID"
            ),
            shiny::uiOutput("rrp_provider_control"),
            shiny::uiOutput("rrp_model_control"),
            shiny::selectInput("rrp_sort", "Sort", choices = c(
              "Risk: highest first" = "risk_desc",
              "Risk: lowest first" = "risk_asc",
              "Episode ID" = "episode_asc"
            )),
            shiny::selectInput(
              "rrp_page_size", "Rows", choices = c(10, 25, 50), selected = 25
            )
          ))
        ),
        bslib::layout_columns(
          col_widths = c(7, 5), class = "rrp-content-grid",
          bslib::card(
            class = "rrp-table-card", full_screen = TRUE,
            bslib::card_header(
              shiny::tags$div(
                class = "rrp-card-heading",
                shiny::tags$div(
                  shiny::tags$h2("Accepted current estimates"),
                  shiny::textOutput("rrp_pool_count", inline = TRUE)
                ),
                shiny::tags$div(
                  class = "rrp-paging",
                  shiny::actionButton("rrp_previous", "Previous"),
                  shiny::textOutput("rrp_page_label", inline = TRUE),
                  shiny::actionButton("rrp_next", "Next")
                )
              )
            ),
            bslib::card_body(shiny::uiOutput("rrp_current_pool_region"))
          ),
          bslib::card(
            class = "rrp-detail-card", full_screen = TRUE,
            bslib::card_header(shiny::tags$div(
              class = "rrp-detail-header",
              shiny::tags$div(
                shiny::tags$h2("Episode Risk Trajectory"),
                shiny::tags$p("Actual governed evaluations only")
              ),
              shiny::uiOutput("rrp_episode_control")
            )),
            bslib::card_body(
              shiny::uiOutput("rrp_trajectory_state"),
              plotly::plotlyOutput("rrp_episode_trajectory", height = "310px"),
              shiny::tags$h3("Exact observations"),
              reactable::reactableOutput("rrp_observation_table")
            )
          )
        )
      )
    ),
    bslib::nav_panel(
      "Overview",
      shiny::tags$main(
        class = "rrp-page rrp-overview-page",
        shiny::tags$div(
          class = "rrp-page-intro",
          shiny::tags$div(
            shiny::tags$h1("Overview"),
            shiny::tags$p(paste(
              "Direct descriptive summaries of the accepted current pool",
              "and selected source scope."
            ))
          )
        ),
        shiny::tags$h2("Current accepted risk"),
        shiny::tags$div(
          class = "rrp-stat-grid",
          rrp_application_stat(
            "Accepted current", overview$accepted_current_count
          ),
          rrp_application_stat("Minimum", probability_or_dash(overview$minimum)),
          rrp_application_stat(
            "First quartile", probability_or_dash(overview$first_quartile)
          ),
          rrp_application_stat("Median", probability_or_dash(overview$median)),
          rrp_application_stat(
            "Third quartile", probability_or_dash(overview$third_quartile)
          ),
          rrp_application_stat("Maximum", probability_or_dash(overview$maximum))
        ),
        shiny::tags$h2("Selected source scope"),
        shiny::tags$div(
          class = "rrp-stat-grid rrp-scope-grid",
          rrp_application_stat(
            "Expected episodes", scope$expected_episode_count
          ),
          rrp_application_stat(
            "Effective dispositions", scope$effective_disposition_count
          ),
          rrp_application_stat("Eligible", scope$eligible_count),
          rrp_application_stat(
            "Accepted estimates", scope$accepted_estimate_count
          ),
          rrp_application_stat(
            "Provider incompatible", scope$provider_incompatible_count
          ),
          rrp_application_stat(
            "Provider-declared failure", scope$provider_declared_failure_count
          ),
          rrp_application_stat("Detected failure", scope$detected_failure_count),
          rrp_application_stat("Total ineligible", scope$ineligible_count),
          rrp_application_stat(
            "Before discharge", scope$episode_before_discharge_count
          ),
          rrp_application_stat(
            "Horizon exhausted", scope$target_horizon_exhausted_count
          ),
          rrp_application_stat(
            "Already readmitted", scope$episode_already_readmitted_count
          ),
          rrp_application_stat(
            "Already dead", scope$episode_already_dead_count
          )
        ),
        shiny::tags$p(class = "rrp-scope-footnote", paste0(
          "Count reconciliation: ", scope$effective_disposition_count,
          " effective dispositions = ", scope$accepted_estimate_count,
          " accepted + ", scope$provider_incompatible_count,
          " incompatible + ", scope$provider_declared_failure_count,
          " provider-declared failures + ", scope$detected_failure_count,
          " detected failures + ", scope$ineligible_count, " ineligible."
        ))
      )
    )
  )
}


