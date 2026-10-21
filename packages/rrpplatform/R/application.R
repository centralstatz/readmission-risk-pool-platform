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
  portable <- rrp_application_portable(catalog)
  portable$rrp_application_validate_presentation(model)
  model
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


rrp_application_portable_resource_ids <- function() c(
  "rrp.application.portable-core",
  "rrp.application.portable-products",
  "rrp.application.portable-ui",
  "rrp.application.portable-server"
)

rrp_application_portable <- function(catalog) {
  dependencies <- c("shiny", "bslib", "plotly", "reactable")
  available <- vapply(dependencies, requireNamespace, logical(1L), quietly = TRUE)
  if (!all(available)) rrp_application_abort("application_dependency_unavailable")
  environment <- new.env(parent = baseenv())
  for (resource_id in rrp_application_portable_resource_ids()) {
    path <- tryCatch(
      rrp_resource_path(catalog, resource_id),
      rrp_resource_error = function(condition) {
        rrp_application_abort("application_dependency_unavailable")
      }
    )
    tryCatch(
      sys.source(path, envir = environment, chdir = FALSE, keep.source = TRUE),
      error = function(condition) {
        rrp_application_abort("application_dependency_unavailable")
      }
    )
  }
  required <- c(
    "rrp_application_load_product_set",
    "rrp_application_load_presentation",
    "rrp_application_model", "rrp_application_ui",
    "rrp_application_server", "rrp_application_shiny"
  )
  if (!all(vapply(required, exists, logical(1L), envir = environment,
      inherits = FALSE))) {
    rrp_application_abort("application_dependency_unavailable")
  }
  environment
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
  portable <- rrp_application_portable(software_catalog)
  portable$rrp_application_model(snapshot, presentation)
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
  portable <- rrp_application_portable(software_catalog)
  app <- portable$rrp_application_shiny(model)
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
