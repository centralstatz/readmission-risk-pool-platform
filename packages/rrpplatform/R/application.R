rrp_application_abort <- function(code) {
  messages <- c(
    application_products_unavailable = "Application products are unavailable.",
    application_product_integrity_failed =
      "Application product integrity validation failed.",
    application_product_incompatible = "Application products are incompatible.",
    application_brand_invalid = "Project branding is invalid or unsafe.",
    application_dependency_unavailable =
      "A required application dependency is unavailable.",
    application_input_invalid = "Application launch input is invalid."
  )
  stop(structure(
    list(message = unname(messages[[code]]), call = NULL, code = code),
    class = c("rrp_application_error", "error", "condition")
  ))
}

rrp_application_dependencies <- function() {
  dependencies <- c("shiny", "bslib", "plotly", "reactable", "brand.yml")
  available <- vapply(dependencies, requireNamespace, logical(1L), quietly = TRUE)
  if (!all(available)) rrp_application_abort("application_dependency_unavailable")
  invisible(dependencies)
}

rrp_application_scalar <- function(value, max_bytes = 120L) {
  is.character(value) && length(value) == 1L && !is.na(value) &&
    nzchar(value) && identical(value, trimws(value)) &&
    nchar(value, type = "bytes") <= max_bytes && !grepl("[[:cntrl:]]", value)
}

rrp_application_brand_logo_resource <- function(brand) {
  logo <- brand$logo
  if (inherits(logo, "brand_logo_resource")) return(logo)
  if (!is.list(logo) || is.null(logo$medium)) return(NULL)
  medium <- logo$medium
  if (inherits(medium, "brand_logo_resource")) return(medium)
  if (inherits(medium, "brand_logo_resource_light_dark") &&
      inherits(medium$light, "brand_logo_resource")) return(medium$light)
  NULL
}

rrp_application_logo <- function(root, resource, contract, display_name) {
  if (is.null(resource)) return(NULL)
  path <- resource$path
  if (!rrp_application_scalar(path, 240L) ||
      grepl("^[A-Za-z][A-Za-z0-9+.-]*:", path) ||
      !rrp_project_safe_relative_path(path)) {
    rrp_application_abort("application_brand_invalid")
  }
  resolved <- tryCatch(rrp_project_resolve_filesystem_path(
    root, path, "application_brand_invalid", "application_brand_invalid",
    "application_brand_invalid", "Brand logo", TRUE, FALSE
  ), rrp_project_error = function(condition) {
    rrp_application_abort("application_brand_invalid")
  })
  size <- file.info(resolved, extra_cols = FALSE)$size[[1L]]
  if (is.na(size) || size < 1 ||
      size > as.numeric(contract[["Logo-Max-Bytes"]])) {
    rrp_application_abort("application_brand_invalid")
  }
  bytes <- readBin(resolved, "raw", n = size)
  png <- length(bytes) >= 8L && identical(bytes[1:8], as.raw(c(
    0x89, 0x50, 0x4e, 0x47, 0x0d, 0x0a, 0x1a, 0x0a
  )))
  jpeg <- length(bytes) >= 3L && identical(bytes[1:3], as.raw(c(0xff, 0xd8, 0xff)))
  if (!png && !jpeg) rrp_application_abort("application_brand_invalid")
  alt <- resource$alt
  if (is.null(alt) || !rrp_application_scalar(alt, 200L)) alt <- display_name
  list(
    media_type = if (png) "image/png" else "image/jpeg",
    bytes = bytes,
    alt = alt
  )
}

rrp_application_presentation_model <- function(catalog, project_root, contracts) {
  root <- tryCatch(
    rrp_project_validate_root(project_root),
    rrp_project_error = function(condition) {
      rrp_application_abort("application_input_invalid")
    }
  )
  brand_contract <- contracts$brand
  brand_path <- file.path(root, brand_contract[["Brand-Path"]])
  display_name <- brand_contract[["Default-Display-Name"]]
  primary_color <- brand_contract[["Default-Primary-Color"]]
  logo <- NULL
  source <- "rrp-defaults"
  if (file.exists(brand_path) || dir.exists(brand_path)) {
    if (!rrp_product_regular_file(brand_path)) {
      rrp_application_abort("application_brand_invalid")
    }
    parsed <- tryCatch(
      brand.yml::read_brand_yml(brand_path),
      error = function(condition) rrp_application_abort("application_brand_invalid")
    )
    candidate_name <- parsed$meta$name$short
    if (is.null(candidate_name)) candidate_name <- parsed$meta$name$full
    if (!is.null(candidate_name)) {
      if (!rrp_application_scalar(candidate_name)) {
        rrp_application_abort("application_brand_invalid")
      }
      display_name <- candidate_name
    }
    candidate_color <- parsed$color$primary
    if (!is.null(candidate_color)) {
      if (!rrp_application_scalar(candidate_color, 7L) ||
          !grepl("^#[0-9A-Fa-f]{6}$", candidate_color)) {
        rrp_application_abort("application_brand_invalid")
      }
      primary_color <- toupper(candidate_color)
    }
    logo <- rrp_application_logo(
      root, rrp_application_brand_logo_resource(parsed),
      brand_contract, display_name
    )
    source <- "project-brand"
  }
  css_path <- rrp_resource_path(catalog, "rrp.asset.supplied-application-css")
  css <- paste(readLines(css_path, warn = FALSE, encoding = "UTF-8"), collapse = "\n")
  model <- structure(list(
    brand_contract_id = "rrp.project-brand",
    brand_contract_version = "0.1.0",
    source = source,
    display_name = display_name,
    primary_color = primary_color,
    logo = logo,
    rrp_css = css
  ), class = c("rrp_presentation_model", "list"))
  rrp_application_validate_presentation(model)
  model
}

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
  if (!valid) rrp_application_abort("application_brand_invalid")
  invisible(model)
}

rrp_application_required_products <- function() c(
  current_remaining_risk = "rrp.product.current-remaining-risk@0.1.0",
  remaining_risk_trajectory = "rrp.product.remaining-risk-trajectory@0.1.0",
  operational_scope_summary = "rrp.product.operational-scope-summary@0.1.0"
)

rrp_application_product_snapshot <- function(access) {
  inventory <- rrp_list_products(access)
  actual <- vapply(inventory, function(item) paste0(
    item$product_id, "@", item$product_version
  ), character(1L))
  required <- unname(rrp_application_required_products())
  if (!identical(actual, required)) {
    rrp_application_abort("application_product_incompatible")
  }
  products <- Map(function(identity, item) {
    parts <- strsplit(identity, "@", fixed = TRUE)[[1L]]
    product <- rrp_read_product(access, parts[[1L]], parts[[2L]])
    if (!is.list(product) || !identical(product$product_contract_id, parts[[1L]]) ||
        !identical(product$product_contract_version, parts[[2L]]) ||
        !is.data.frame(product$data)) {
      rrp_application_abort("application_product_incompatible")
    }
    rrp_product_copy(product)
  }, required, inventory)
  names(products) <- names(rrp_application_required_products())
  snapshot <- structure(list(
    product_set_id = access$product_set_id,
    source_operation_run_id = access$source_operation_run_id,
    source_analytical_time = access$source_analytical_time,
    source_history_cutoff = access$source_history_cutoff,
    source_history_fingerprint = access$source_history_fingerprint,
    freshness = rrp_product_copy(access$freshness),
    products = products
  ), class = c("rrp_application_product_snapshot", "list"))
  snapshot
}

rrp_application_probability <- function(value) sprintf("%.1f%%", 100 * value)

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
  selected <- selected_episode_id
  if (is.null(selected) || !selected %in% choices) {
    selected <- if (length(choices)) choices[[1L]] else NULL
  }
  list(
    rows = display_rows, displayed_count = as.integer(nrow(display_rows)),
    total_count = as.integer(total), page = as.integer(page),
    page_size = as.integer(page_size), episode_choices = choices,
    selected_episode_id = selected,
    provider_choices = sort(unique(current$provider_id), method = "radix"),
    model_choices = sort(unique(stats::na.omit(current$model_id)), method = "radix")
  )
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
    provider_id = rows$provider_id,
    model_id = rows$model_id,
    attribution = rrp_application_attribution(rows$provider_id, rows$model_id),
    tooltip = if (nrow(rows)) paste0(
      rows$analytical_time, " | ",
      rrp_application_probability(rows$estimate_value), " | ",
      rrp_application_attribution(rows$provider_id, rows$model_id)
    ) else character(),
    stringsAsFactors = FALSE
  )
}

rrp_application_sparklines <- function(trajectory, episode_ids) {
  stats::setNames(lapply(episode_ids, function(episode_id) {
    rrp_application_trajectory_rows(trajectory, episode_id)[c(
      "analytical_time", "estimate_value"
    )]
  }), episode_ids)
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
    trajectory = rrp_application_trajectory_rows(
      trajectory, current_view$selected_episode_id
    ),
    overview = rrp_application_overview(current, summary)
  )
}

rrp_application_model <- function(snapshot, presentation) {
  rrp_application_validate_presentation(presentation)
  model <- structure(list(
    application_contract_id = "rrp.application.supplied",
    application_contract_version = "0.1.0",
    product_snapshot = rrp_product_copy(snapshot),
    presentation = rrp_product_copy(presentation),
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
      "current", "sparklines", "trajectory", "overview"
    )) && !rrp_application_contains_reference(model)
  if (!valid) rrp_application_abort("application_input_invalid")
  rrp_application_validate_presentation(model$presentation)
  invisible(model)
}

rrp_application_shiny <- function(model) {
  rrp_application_validate_model(model)
  current <- model$view_models$current$rows
  trajectory <- model$view_models$trajectory
  overview <- model$view_models$overview
  ui <- bslib::page_navbar(
    title = model$presentation$display_name,
    header = shiny::tags$style(shiny::HTML(model$presentation$rrp_css)),
    bslib::nav_panel(
      "Current Risk Pool",
      reactable::reactableOutput("rrp_current_pool"),
      plotly::plotlyOutput("rrp_episode_trajectory")
    ),
    bslib::nav_panel(
      "Overview",
      shiny::tags$p(paste("Accepted current estimates:",
        overview$accepted_current_count))
    )
  )
  server <- function(input, output, session) {
    output$rrp_current_pool <- reactable::renderReactable(
      reactable::reactable(current, selection = "single", searchable = TRUE)
    )
    output$rrp_episode_trajectory <- plotly::renderPlotly({
      selected <- reactable::getReactableState("rrp_current_pool", "selected")
      rows <- trajectory
      if (length(selected) == 1L && nrow(current) >= selected) {
        episode <- current$episode_id[[selected]]
        rows <- rrp_application_trajectory_rows(
          model$product_snapshot$products$remaining_risk_trajectory$data,
          episode
        )
      }
      plotly::plot_ly(
        x = rows$analytical_time, y = rows$estimate_value,
        text = rows$tooltip, hoverinfo = "text", type = "scatter",
        mode = "markers"
      )
    })
  }
  shiny::shinyApp(ui = ui, server = server)
}

rrp_application_validate_launch <- function(launch_browser, port) {
  if (!is.logical(launch_browser) || length(launch_browser) != 1L ||
      is.na(launch_browser)) rrp_application_abort("application_input_invalid")
  if (!is.null(port) && (!is.numeric(port) || length(port) != 1L ||
      is.na(port) || !is.finite(port) || port < 1024L || port > 65535L ||
      port != as.integer(port))) {
    rrp_application_abort("application_input_invalid")
  }
  invisible(TRUE)
}

rrp_application_prepare <- function(
  software_catalog, project_root, expected_operation_run_id, history_cutoff
) {
  rrp_application_dependencies()
  contracts <- rrp_application_contracts(software_catalog)
  presentation <- rrp_application_presentation_model(
    software_catalog, project_root, contracts
  )
  opened <- rrp_open_product_access(
    software_catalog, project_root, expected_operation_run_id, history_cutoff
  )
  if (!rrp_operation_succeeded(opened)) {
    source_code <- opened$diagnostics[[1L]]$code
    target_code <- if (identical(source_code, "product_integrity_failed")) {
      "application_product_integrity_failed"
    } else if (identical(source_code, "product_materialization_incompatible")) {
      "application_product_incompatible"
    } else "application_products_unavailable"
    rrp_application_abort(target_code)
  }
  snapshot <- rrp_application_product_snapshot(opened$value)
  rrp_application_model(snapshot, presentation)
}

rrp_application_failure <- function(condition) rrp_new_operation_result(
  "rrp.launch-app", "failure", NULL,
  list(rrp_new_diagnostic(condition$code, "error", condition$message))
)

#' Launch the installed supplied application
#'
#' Validate one existing product realization and optional standard project
#' branding, construct a closed detached application model, and run the supplied
#' application on the loopback interface. The operation returns after the app
#' session exits.
#'
#' @param software_catalog A validated explicit-root software resource catalog.
#' @param project_root One explicit initialized independent-project root.
#' @param expected_operation_run_id Optional explicit governed source operation.
#' @param history_cutoff Optional paired RFC 3339 UTC history cutoff.
#' @param launch_browser Whether Shiny should open a local browser.
#' @param port Optional nonprivileged local TCP port.
#' @return One validated `rrp_operation_result`.
#' @export
rrp_launch_app <- function(
  software_catalog, project_root, expected_operation_run_id = NULL,
  history_cutoff = NULL, launch_browser = interactive(), port = NULL
) tryCatch({
  rrp_application_validate_launch(launch_browser, port)
  model <- rrp_application_prepare(
    software_catalog, project_root, expected_operation_run_id, history_cutoff
  )
  app <- rrp_application_shiny(model)
  shiny::runApp(
    app, host = "127.0.0.1", port = port, launch.browser = launch_browser,
    quiet = TRUE
  )
  rrp_new_operation_result(
    "rrp.launch-app", "success",
    list(application_id = "rrp.application.supplied",
      application_version = "0.1.0"), list()
  )
}, rrp_application_error = rrp_application_failure)
