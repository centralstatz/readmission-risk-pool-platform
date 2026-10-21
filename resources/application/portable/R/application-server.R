# Portable Shiny server composition.
# The server is read-only and receives one detached application model.

rrp_application_server <- function(model) {
  force(model)
  function(input, output, session) {
    current <- model$product_snapshot$products$current_remaining_risk$data
    trajectory <- model$product_snapshot$products$remaining_risk_trajectory$data
    page <- shiny::reactiveVal(1L)
    selected_episode <- shiny::reactiveVal(
      model$view_models$current$selected_episode_id
    )
    provider_filter <- shiny::reactive({
      value <- input$rrp_provider
      if (is.null(value) || identical(value, "")) NULL else value
    })
    model_filter <- shiny::reactive({
      value <- input$rrp_model
      if (is.null(value) || identical(value, "")) NULL else value
    })
    current_view <- shiny::reactive(rrp_application_current_view(
      current, trajectory,
      search = if (is.null(input$rrp_search)) "" else input$rrp_search,
      provider_id = provider_filter(), model_id = model_filter(),
      sort = if (is.null(input$rrp_sort)) "risk_desc" else input$rrp_sort,
      page = page(),
      page_size = as.integer(if (is.null(input$rrp_page_size))
        25L else input$rrp_page_size),
      selected_episode_id = selected_episode()
    ))
    shiny::observeEvent(list(
      input$rrp_search, input$rrp_provider, input$rrp_model,
      input$rrp_sort, input$rrp_page_size
    ), page(1L), ignoreInit = TRUE)
    shiny::observeEvent(input$rrp_previous, page(max(1L, page() - 1L)))
    shiny::observeEvent(input$rrp_next, {
      view <- current_view()
      if (page() * view$page_size < view$total_count) page(page() + 1L)
    })
    shiny::observeEvent(input$rrp_episode, {
      if (!is.null(input$rrp_episode) && nzchar(input$rrp_episode)) {
        selected_episode(input$rrp_episode)
      }
    }, ignoreInit = TRUE)
    shiny::observe({
      selected <- reactable::getReactableState("rrp_current_pool", "selected")
      view <- current_view()
      if (length(selected) == 1L && selected <= nrow(view$rows)) {
        selected_episode(view$rows$episode_id[[selected]])
      }
    })
    shiny::observe({
      view <- current_view()
      selected <- rrp_application_selected_row(view, selected_episode())
      reactable::updateReactable(
        "rrp_current_pool",
        selected = selected,
        session = session
      )
    })
    output$rrp_provider_control <- shiny::renderUI({
      choices <- model$view_models$current$provider_choices
      if (length(choices) < 2L) return(NULL)
      shiny::selectInput(
        "rrp_provider", "Provider", c("All providers" = "", choices)
      )
    })
    output$rrp_model_control <- shiny::renderUI({
      choices <- model$view_models$current$model_choices
      if (!length(choices)) return(NULL)
      shiny::selectInput("rrp_model", "Model", c("All models" = "", choices))
    })
    output$rrp_episode_control <- shiny::renderUI({
      view <- current_view()
      shiny::selectInput(
        "rrp_episode", "Episode", choices = view$episode_choice_labels,
        selected = selected_episode(), width = "100%"
      )
    })
    output$rrp_pool_count <- shiny::renderText({
      view <- current_view()
      paste0(
        view$displayed_count, " displayed / ", view$total_count, " matching"
      )
    })
    output$rrp_page_label <- shiny::renderText({
      view <- current_view()
      pages <- max(1L, ceiling(view$total_count / view$page_size))
      paste("Page", min(view$page, pages), "of", pages)
    })
    output$rrp_current_pool_region <- shiny::renderUI({
      view <- current_view()
      if (!view$total_count) return(shiny::tags$div(
        class = "rrp-empty-state",
        shiny::tags$h3("No current accepted risk estimates"),
        shiny::tags$p(paste0(
          "Empty is a valid product state at ",
          model$product_snapshot$source_analytical_time, "."
        ))
      ))
      reactable::reactableOutput("rrp_current_pool")
    })
    output$rrp_current_pool <- reactable::renderReactable({
      view <- current_view()
      rrp_application_current_table(
        view, rrp_application_sparklines(trajectory, view$rows$episode_id)
      )
    })
    trajectory_view <- shiny::reactive(rrp_application_trajectory_view(
      trajectory, selected_episode()
    ))
    output$rrp_trajectory_state <- shiny::renderUI({
      view <- trajectory_view()
      shiny::tags$div(
        class = paste(
          "rrp-trajectory-note", paste0("rrp-trajectory-", view$state)
        ),
        shiny::tags$strong(if (is.null(view$episode_id))
          "No episode selected" else view$episode_id),
        shiny::tags$span(view$note)
      )
    })
    output$rrp_episode_trajectory <- plotly::renderPlotly(
      rrp_application_trajectory_plot(trajectory_view())
    )
    output$rrp_observation_table <- reactable::renderReactable(
      rrp_application_observation_table(trajectory_view())
    )
  }
}

rrp_application_shiny <- function(model) {
  rrp_application_validate_model(model)
  shiny::shinyApp(
    ui = rrp_application_ui(model), server = rrp_application_server(model)
  )
}


