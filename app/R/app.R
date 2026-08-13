# Minimal product-only reference application. All platform state is loaded once
# through injected access; reactive behavior is presentation-only.

rrp_create_reference_app <- function(access) {
  if (!requireNamespace("shiny", quietly = TRUE)) stop(
    "Package `shiny` is required. Restore this repository's renv environment.",
    call. = FALSE
  )
  initialized <- rrp_initialize_reference_app(access)
  if (!identical(initialized$overall_status, "succeeded")) return(shiny::shinyApp(
    shiny::fluidPage(
      shiny::titlePanel("Readmission Risk Pool — reference application"),
      shiny::div(
        style = paste(
          "padding: 1rem; border-left: 0.35rem solid #a33;",
          "background: #fff4f4;"
        ),
        shiny::h3("Product access unavailable"),
        shiny::p(initialized$message),
        shiny::p(
          "Validate the current materialized product set, then rebuild it if needed."
        )
      )
    ),
    function(input, output, session) invisible(NULL)
  ))

  current <- rrp_app_current_risk_table(initialized$products$current_episode_risk)
  history_product <- initialized$products$episode_risk_history
  history_episodes <- sort(unique(vapply(
    history_product$rows, `[[`, character(1), "episode_id"
  )), method = "radix")
  runs <- rrp_app_run_summary_table(initialized$products$operational_run_summary)
  freshness <- rrp_app_freshness_text(initialized$freshness)

  table_or_empty <- function(id, empty_message) {
    if (identical(id, "current") && nrow(current) == 0L) return(shiny::div(
      class = "rrp-empty-state", empty_message
    ))
    if (identical(id, "runs") && nrow(runs) == 0L) return(shiny::div(
      class = "rrp-empty-state", empty_message
    ))
    shiny::tableOutput(id)
  }
  ui <- shiny::fluidPage(
    shiny::titlePanel("Readmission Risk Pool — fictional reference"),
    shiny::div(
      style = "padding: 0.75rem; background: #eef5ff; margin-bottom: 1rem;",
      shiny::strong("Freshness: "), freshness
    ),
    shiny::div(
      style = "padding: 0.75rem; background: #fff3cd; margin-bottom: 1rem;",
      "Synthetic, nonclinical demonstration only. Risk display is not a care priority."
    ),
    shiny::tabsetPanel(
      shiny::tabPanel(
        "Current episode risk",
        shiny::p("Sorted by estimate value for display only; no priority policy is applied."),
        table_or_empty("current", "No current accepted risk estimates are available.")
      ),
      shiny::tabPanel(
        "Episode risk history",
        if (length(history_episodes) == 0L) shiny::div(
          class = "rrp-empty-state",
          "No accepted risk history is available."
        ) else shiny::tagList(
          shiny::selectInput("episode_id", "Episode", choices = history_episodes),
          shiny::p("Points are actual persisted observations; no interpolation is applied."),
          shiny::plotOutput("history_plot"),
          shiny::tableOutput("history")
        )
      ),
      shiny::tabPanel(
        "Platform / run status",
        shiny::p(freshness),
        table_or_empty("runs", "No represented terminal runs are available.")
      )
    )
  )
  server <- function(input, output, session) {
    if (nrow(current) > 0L) output$current <- shiny::renderTable(
      current, striped = TRUE, bordered = TRUE
    )
    if (length(history_episodes) > 0L) {
      selected_history <- shiny::reactive(rrp_app_history_table(
        history_product, input$episode_id
      ))
      output$history <- shiny::renderTable(
        selected_history(), striped = TRUE, bordered = TRUE
      )
      output$history_plot <- shiny::renderPlot({
        values <- selected_history()
        providers <- factor(values$provider)
        times <- as.POSIXct(values$estimate_as_of_time, tz = "UTC")
        graphics::plot(
          times,
          values$estimate_value,
          type = "p",
          pch = 19,
          col = as.integer(providers),
          xlab = "Actual estimate as-of time",
          ylab = "Estimate value",
          ylim = c(0, 1)
        )
        graphics::legend(
          "topright",
          legend = levels(providers),
          col = seq_along(levels(providers)),
          pch = 19,
          cex = 0.8
        )
      })
    }
    if (nrow(runs) > 0L) output$runs <- shiny::renderTable(
      runs, striped = TRUE, bordered = TRUE
    )
  }
  shiny::shinyApp(ui, server)
}
