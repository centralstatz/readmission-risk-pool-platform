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
      "current", "sparklines", "trajectory", "overview", "status"
    )) && !rrp_application_contains_reference(model)
  if (!valid) rrp_application_abort("application_input_invalid")
  rrp_application_validate_presentation(model$presentation)
  invisible(model)
}

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
