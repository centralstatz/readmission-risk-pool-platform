library(rrpplatform)

arguments <- commandArgs(trailingOnly = TRUE)
software_root <- if (length(arguments) >= 1L) arguments[[1L]] else
  Sys.getenv("RRP_TEST_SOFTWARE_ROOT", unset = "")
stopifnot(nzchar(software_root), dir.exists(software_root))
software_root <- normalizePath(software_root, winslash = "/", mustWork = TRUE)
catalog <- rrp_open_resource_catalog(software_root)
internal <- function(name) get(name, envir = asNamespace("rrpplatform"))

suite <- tempfile("rrp-fictional-application-")
dir.create(suite)
on.exit(unlink(suite, recursive = TRUE, force = TRUE), add = TRUE)
unrelated <- file.path(suite, "unrelated-working-directory")
dir.create(unrelated)
unrelated <- normalizePath(unrelated, winslash = "/", mustWork = TRUE)
old_working_directory <- setwd(unrelated)
on.exit(setwd(old_working_directory), add = TRUE)
stopifnot(!dir.exists(".git"), !dir.exists(file.path(software_root, ".git")))

read_bytes <- function(path) {
  readBin(path, "raw", n = file.info(path, extra_cols = FALSE)$size[[1L]])
}

copy_project <- function(source, parent, name) {
  dir.create(parent, recursive = TRUE)
  stopifnot(file.copy(
    source, parent, recursive = TRUE, copy.mode = FALSE, copy.date = FALSE
  ))
  copied <- file.path(parent, basename(source))
  destination <- file.path(parent, name)
  stopifnot(file.rename(copied, destination))
  destination
}

all_project_files <- function(root) {
  paths <- list.files(root, recursive = TRUE, all.files = TRUE, no.. = TRUE,
    full.names = TRUE, include.dirs = FALSE)
  paths[order(paths, method = "radix")]
}

project_digest <- function(root) {
  paths <- all_project_files(root)
  values <- unname(tools::md5sum(paths))
  names(values) <- substring(paths, nchar(root) + 2L)
  values
}

expect_failure <- function(result, code) stopifnot(
  !rrp_operation_succeeded(result), identical(result$status, "failure"),
  is.null(result$value), length(result$diagnostics) == 1L,
  identical(result$diagnostics[[1L]]$code, code),
  !grepl("[/\\]", result$diagnostics[[1L]]$message)
)

launch_installed <- function(project_root, operation_run_id, cutoff) {
  script <- tempfile("rrp-launch-installed-", tmpdir = suite, fileext = ".R")
  result_path <- tempfile("rrp-launch-result-", tmpdir = suite, fileext = ".rds")
  writeLines(c(
    "arguments <- commandArgs(trailingOnly = TRUE)",
    "library(rrpplatform)",
    "catalog <- rrp_open_resource_catalog(arguments[[1L]])",
    "later_call <- get('later', envir = asNamespace('later'), inherits = FALSE)",
    "random_port <- get('randomPort', envir = asNamespace('httpuv'), inherits = FALSE)",
    "later_call(function() shiny::stopApp(), delay = 1)",
    "result <- rrp_launch_app(catalog, arguments[[2L]], arguments[[3L]],",
    "  arguments[[4L]], launch_browser = FALSE, port = random_port())",
    "saveRDS(result, arguments[[5L]])"
  ), script, useBytes = TRUE)
  output <- system2(file.path(R.home("bin"), "Rscript"), c(
    "--vanilla", shQuote(script), shQuote(software_root), shQuote(project_root),
    shQuote(operation_run_id), shQuote(cutoff), shQuote(result_path)
  ), stdout = TRUE, stderr = TRUE, env = "R_TESTS=")
  if (!identical(attr(output, "status"), NULL)) {
    stop(paste(output, collapse = "\n"), call. = FALSE)
  }
  stopifnot(file.exists(result_path))
  readRDS(result_path)
}

# The fifth installed product document is cataloged, byte-resolved, and teaches
# only the public package-level launch boundary.
guide_path <- rrp_resource_path(
  catalog, "rrp.documentation.supplied-application-guide"
)
guide <- paste(readLines(guide_path, warn = FALSE, encoding = "UTF-8"),
  collapse = "\n")
css_path <- rrp_resource_path(catalog, "rrp.asset.supplied-application-css")
application_contract <- rrp_resource_path(
  catalog, "rrp.contract.supplied-application"
)
stopifnot(
  startsWith(guide_path, paste0(software_root, .Platform$file.sep)),
  startsWith(css_path, paste0(software_root, .Platform$file.sep)),
  startsWith(application_contract, paste0(software_root, .Platform$file.sep)),
  grepl("rrp_launch_app", guide, fixed = TRUE),
  grepl("rrp.application.supplied@0.1.0", guide, fixed = TRUE),
  grepl("rrp.project-brand@0.1.0", guide, fixed = TRUE),
  !grepl("source\\s*\\(", guide), !grepl("devtools::load_all", guide, fixed = TRUE),
  !grepl("setwd\\s*\\(", guide), !grepl(":::", guide, fixed = TRUE)
)

project <- file.path(suite, "ordinary-fictional-project")
initialized <- rrp_initialize_fictional_project(catalog, project)
expected_inventory <- c(
  "rrp-project.dcf", "rrp-authoring.dcf", "R/register.R",
  "R/produce-canonical.R", "R/calculate-risk.R", "README.md",
  "_brand.yml", "assets/project-logo.png", "R/generate-source.R"
)
stopifnot(
  rrp_operation_succeeded(initialized), !dir.exists(file.path(project, ".git")),
  identical(initialized$value$created_paths, expected_inventory),
  identical(sort(list.files(project, recursive = TRUE, all.files = TRUE,
    no.. = TRUE, include.dirs = FALSE), method = "radix"),
    sort(expected_inventory, method = "radix")),
  !dir.exists(file.path(project, "app")),
  !any(grepl("[.](css|js|html)$", expected_inventory, ignore.case = TRUE)),
  identical(sum(grepl("^R/", expected_inventory)), 4L)
)

generator <- new.env(parent = baseenv())
sys.source(file.path(project, "R", "generate-source.R"), generator,
  chdir = FALSE, keep.source = FALSE)
generator$rrp_generate_fictional_source(project)
stopifnot(rrp_operation_succeeded(rrp_initialize_project_state(catalog, project)))

empty_time <- "2025-12-19T12:00:00Z"
first_time <- "2026-01-19T12:00:00Z"
second_time <- "2026-01-20T12:00:00Z"
newer_time <- "2026-01-22T12:00:00Z"
empty_run <- rrp_execute_durable_bundle(
  catalog, project, empty_time, "fictional-application-empty"
)
first_run <- rrp_execute_durable_bundle(
  catalog, project, first_time, "fictional-application-first"
)
second_run <- rrp_execute_durable_bundle(
  catalog, project, second_time, "fictional-application-second"
)
stopifnot(
  rrp_operation_succeeded(empty_run), rrp_operation_succeeded(first_run),
  rrp_operation_succeeded(second_run),
  identical(empty_run$value$expected_episode_count, 0L),
  identical(second_run$value$expected_episode_count, 4L)
)

# A first realization proves the one-observation state. The current realization
# then uses the exact two actual fictional observations planned for Stage 10.
first_set <- rrp_build_product_set(
  catalog, project, first_run$value$operation_run_id, first_time
)
stopifnot(rrp_operation_succeeded(first_set))
stopifnot(rrp_operation_succeeded(
  rrp_materialize_product_set(catalog, project, first_set$value)
))
one_point_model <- internal("rrp_application_prepare")(
  catalog, project, first_run$value$operation_run_id, first_time
)
stopifnot(
  identical(one_point_model$view_models$trajectory$state, "single"),
  nrow(one_point_model$view_models$trajectory$rows) == 1L
)

built <- rrp_build_product_set(
  catalog, project, second_run$value$operation_run_id, second_time
)
stopifnot(rrp_operation_succeeded(built))
published <- rrp_materialize_product_set(catalog, project, built$value)
stopifnot(rrp_operation_succeeded(published))
opened <- rrp_open_product_access(
  catalog, project, second_run$value$operation_run_id, second_time
)
stopifnot(rrp_operation_succeeded(opened))

model <- internal("rrp_application_prepare")(
  catalog, project, second_run$value$operation_run_id, second_time
)
not_evaluated <- internal("rrp_application_prepare")(
  catalog, project, NULL, NULL
)
current <- model$product_snapshot$products$current_remaining_risk$data
trajectory <- model$product_snapshot$products$remaining_risk_trajectory$data
scope <- model$product_snapshot$products$operational_scope_summary$data
view <- model$view_models$current
trajectory_view <- model$view_models$trajectory
overview <- model$view_models$overview
table <- internal("rrp_application_current_table")(
  view, internal("rrp_application_sparklines")(trajectory, view$rows$episode_id)
)
plot <- plotly::plotly_build(
  internal("rrp_application_trajectory_plot")(trajectory_view)
)
observation_table <- internal("rrp_application_observation_table")(
  trajectory_view
)
ui <- as.character(internal("rrp_application_ui")(model))
spark <- internal("rrp_application_sparklines")(
  trajectory, "fictional.episode.001"
)$fictional.episode.001
spark_markup <- as.character(internal("rrp_application_sparkline_tag")(spark))
risk_markup <- as.character(internal("rrp_application_risk_tag")(
  view$rows$estimate_value[[1L]], view$rows$estimate_display[[1L]]
))
stopifnot(
  identical(model$product_snapshot$product_set_id, built$value$product_set_id),
  identical(model$product_snapshot$freshness$status, "fresh"),
  identical(not_evaluated$product_snapshot$freshness$status, "not-evaluated"),
  identical(current$episode_id, "fictional.episode.001"),
  isTRUE(all.equal(current$estimate_value, 0.3833333333333333)),
  identical(trajectory$analytical_time, c(first_time, second_time)),
  isTRUE(all.equal(trajectory$estimate_value, c(0.39, 0.3833333333333333))),
  identical(view$rows$episode_id, "fictional.episode.001"),
  identical(view$rows$estimate_display, "38.3%"),
  identical(view$rows$provider_id, "fictional-reference-hospital.provider"),
  identical(view$rows$analytical_time, second_time),
  grepl("days remaining at as-of", view$rows$followup_context, fixed = TRUE),
  inherits(table, "reactable"), inherits(observation_table, "reactable"),
  identical(spark$state, "multiple"), nrow(spark$rows) == 2L,
  lengths(regmatches(spark_markup, gregexpr("<circle", spark_markup,
    fixed = TRUE))) == 2L,
  grepl("<polyline", spark_markup, fixed = TRUE),
  grepl("38.3%", risk_markup, fixed = TRUE), grepl("width:38.333", risk_markup),
  !grepl("high|medium|low", risk_markup, ignore.case = TRUE),
  identical(trajectory_view$state, "multiple"),
  nrow(trajectory_view$rows) == 2L,
  identical(plot$x$data[[1L]]$mode, "lines+markers"),
  identical(plot$x$layout$yaxis$range, c(0, 1)),
  identical(plot$x$config$displayModeBar, FALSE),
  all(grepl("Accepted risk:|Provider / model:|Evaluation:",
    trajectory_view$rows$tooltip)),
  identical(overview$accepted_current_count, nrow(current)),
  identical(overview$minimum, min(current$estimate_value)),
  identical(overview$first_quartile,
    unname(stats::quantile(current$estimate_value, 0.25, names = FALSE))),
  identical(overview$median, stats::median(current$estimate_value)),
  identical(overview$third_quartile,
    unname(stats::quantile(current$estimate_value, 0.75, names = FALSE))),
  identical(overview$maximum, max(current$estimate_value)),
  identical(overview$scope$expected_episode_count, scope$expected_episode_count),
  identical(overview$scope$effective_disposition_count,
    scope$effective_disposition_count),
  identical(overview$scope$accepted_estimate_count,
    scope$accepted_estimate_count),
  grepl("Current Risk Pool", ui, fixed = TRUE),
  grepl("Episode Risk Trajectory", ui, fixed = TRUE),
  grepl("Overview", ui, fixed = TRUE),
  !grepl("readmission rate|business KPI|care-management queue|Recommended action|priority class|intervention performance|outcome claim",
    ui, ignore.case = TRUE)
)

# Actual installed composition retains search/filter/sort/paging semantics and
# keeps a retained historical-only selector distinct from current rows.
searched <- internal("rrp_application_current_view")(
  current, trajectory, search = "fictional.episode.001",
  provider_id = "fictional-reference-hospital.provider",
  sort = "episode_asc", page = 1L, page_size = 1L
)
filtered_out <- internal("rrp_application_current_view")(
  current, trajectory, provider_id = "provider.not-present"
)
stopifnot(
  identical(searched$rows$episode_id, "fictional.episode.001"),
  identical(searched$displayed_count, 1L), identical(searched$total_count, 1L),
  identical(filtered_out$total_count, 0L),
  identical(internal("rrp_application_selected_row")(
    searched, "fictional.episode.001"
  ), 1L)
)

# An earlier valid empty scope is published without fabricating current or
# trajectory values, then the intended current realization is restored.
empty_set <- rrp_build_product_set(
  catalog, project, empty_run$value$operation_run_id, empty_time
)
stopifnot(rrp_operation_succeeded(empty_set))
stopifnot(rrp_operation_succeeded(
  rrp_materialize_product_set(catalog, project, empty_set$value)
))
empty_model <- internal("rrp_application_prepare")(
  catalog, project, empty_run$value$operation_run_id, empty_time
)
stopifnot(
  identical(empty_model$view_models$current$total_count, 0L),
  identical(empty_model$view_models$trajectory$state, "unavailable"),
  identical(empty_model$view_models$overview$accepted_current_count, 0L),
  inherits(internal("rrp_application_shiny")(empty_model), "shiny.appobj")
)
shiny::testServer(internal("rrp_application_server")(empty_model), {
  session$setInputs(
    rrp_search = "", rrp_sort = "risk_desc", rrp_page_size = "25",
    rrp_provider = "", rrp_model = ""
  )
  session$flushReact()
  stopifnot(any(grepl(
    "No current accepted risk estimates",
    as.character(output$rrp_current_pool_region), fixed = TRUE
  )))
})
# Shiny's test harness owns its process working-directory behavior; restore the
# unrelated directory before testing the package-level operations below.
setwd(unrelated)
stopifnot(rrp_operation_succeeded(
  rrp_materialize_product_set(catalog, project, built$value)
))

newer_run <- rrp_execute_durable_bundle(
  catalog, project, newer_time, "fictional-application-newer"
)
stopifnot(rrp_operation_succeeded(newer_run))
stale_model <- internal("rrp_application_prepare")(
  catalog, project, newer_run$value$operation_run_id, newer_time
)
stopifnot(
  identical(stale_model$product_snapshot$freshness$status, "stale"),
  identical(stale_model$product_snapshot$product_set_id,
    model$product_snapshot$product_set_id),
  grepl("Stale product realization", as.character(internal("rrp_application_ui")(
    stale_model
  )), fixed = TRUE)
)

# Standard branding, no-brand defaults, and one bounded custom standard brand
# all preserve the exact analytical snapshot and fixed risk encoding.
stopifnot(
  identical(model$presentation$source, "project-brand"),
  identical(model$presentation$display_name, "Fictional Hospital"),
  identical(model$presentation$primary_color, "#6A1B5D"),
  identical(model$presentation$logo$media_type, "image/png"),
  identical(model$presentation$logo$alt, "Fictional Reference Hospital logo"),
  identical(model$presentation$rrp_css,
    paste(readLines(css_path, warn = FALSE, encoding = "UTF-8"), collapse = "\n"))
)
default_project <- copy_project(
  project, file.path(suite, "default-copy"), "project"
)
unlink(file.path(default_project, "_brand.yml"))
default_model <- internal("rrp_application_prepare")(
  catalog, default_project, second_run$value$operation_run_id, second_time
)
stopifnot(
  identical(default_model$presentation$source, "rrp-defaults"),
  identical(default_model$presentation$display_name, "Readmission Risk Pool"),
  identical(default_model$presentation$primary_color, "#1F4E79"),
  is.null(default_model$presentation$logo),
  identical(default_model$product_snapshot, model$product_snapshot)
)
custom_project <- copy_project(
  project, file.path(suite, "custom-copy"), "project"
)
writeLines(c(
  "meta:", "  name:", "    full: Example Health System",
  "    short: Example Health", "color:", "  primary: '#6A1B5D'",
  "logo:", "  medium:", "    path: assets/project-logo.png",
  "    alt: Example Health logo", "typography:", "  fonts:",
  "    - family: Source Sans 3", "      source: google"
), file.path(custom_project, "_brand.yml"), useBytes = TRUE)
custom_model <- internal("rrp_application_prepare")(
  catalog, custom_project, second_run$value$operation_run_id, second_time
)
stopifnot(
  identical(custom_model$presentation$display_name, "Example Health"),
  identical(custom_model$presentation$primary_color, "#6A1B5D"),
  identical(custom_model$presentation$logo$alt, "Example Health logo"),
  identical(custom_model$presentation$logo$bytes,
    read_bytes(file.path(custom_project, "assets", "project-logo.png"))),
  !"path" %in% names(custom_model$presentation$logo),
  identical(custom_model$product_snapshot, model$product_snapshot),
  identical(custom_model$view_models, model$view_models),
  identical(as.character(internal("rrp_application_risk_tag")(
    view$rows$estimate_value[[1L]], view$rows$estimate_display[[1L]]
  )), risk_markup)
)

invalid_brand <- copy_project(
  project, file.path(suite, "invalid-brand-copy"), "project"
)
writeLines(c("logo:", "  medium: https://example.test/logo.png"),
  file.path(invalid_brand, "_brand.yml"), useBytes = TRUE)
expect_failure(
  rrp_launch_app(catalog, invalid_brand, launch_browser = FALSE),
  "application_brand_invalid"
)

# Missing, corrupt, and incompatible products are bounded before server start.
absent <- file.path(suite, "products-absent")
stopifnot(
  rrp_operation_succeeded(rrp_initialize_fictional_project(catalog, absent)),
  rrp_operation_succeeded(rrp_initialize_project_state(catalog, absent))
)
expect_failure(
  rrp_launch_app(catalog, absent, launch_browser = FALSE),
  "application_product_integrity_failed"
)
corrupt <- copy_project(project, file.path(suite, "corrupt-copy"), "project")
corrupt_member <- file.path(
  corrupt, "state", "products", "sets", published$value$materialization_id,
  "current-remaining-risk.csv"
)
writeBin(c(read_bytes(corrupt_member), charToRaw("corrupt")), corrupt_member)
expect_failure(
  rrp_launch_app(catalog, corrupt, launch_browser = FALSE),
  "application_product_integrity_failed"
)
incompatible <- copy_project(
  project, file.path(suite, "incompatible-copy"), "project"
)
pointer <- file.path(incompatible, "state", "products", "current.dcf")
lines <- readLines(pointer, warn = FALSE, encoding = "UTF-8")
writeLines(sub(
  "^Materialization-Contract-Version: 0[.]1[.]0$",
  "Materialization-Contract-Version: 9.9.9", lines
), pointer, useBytes = TRUE)
expect_failure(
  rrp_launch_app(catalog, incompatible, launch_browser = FALSE),
  "application_product_incompatible"
)

# Test-only executable presentation sentinels and analytical-call sentinels
# prove that only declarative branding is consulted during installed launch.
sentinel <- file.path(suite, "forbidden-execution")
instrument_callable <- function(path, declaration, label) {
  lines <- readLines(path, warn = FALSE, encoding = "UTF-8")
  location <- which(lines == declaration)
  stopifnot(length(location) == 1L)
  evidence <- paste0(
    "  cat(", encodeString(paste0(label, "\n"), quote = "\""),
    ", file = ", encodeString(sentinel, quote = "\""), ", append = TRUE)"
  )
  writeLines(append(lines, evidence, after = location), path, useBytes = TRUE)
}
instrument_callable(
  file.path(project, "R", "produce-canonical.R"),
  "rrp_produce_canonical <- function(project_root, as_of_time) {", "producer"
)
instrument_callable(
  file.path(project, "R", "calculate-risk.R"),
  "rrp_calculate_risk <- function(project_root, request) {", "provider"
)
dir.create(file.path(project, "app"))
writeLines(paste0("cat('app', file = ", encodeString(sentinel, quote = "\""), ")"),
  file.path(project, "app", "app.R"), useBytes = TRUE)
dir.create(file.path(project, "www"))
for (name in c("hospital.css", "hospital.js", "hospital.html")) {
  writeLines(paste0("forbidden-", name), file.path(project, "www", name),
    useBytes = TRUE)
}
writeLines(paste0("cat('module', file = ",
  encodeString(sentinel, quote = "\""), ")"),
  file.path(project, "R", "application-module.R"), useBytes = TRUE)

before <- project_digest(project)
launch <- launch_installed(
  project, second_run$value$operation_run_id, second_time
)
after <- project_digest(project)
stopifnot(
  rrp_operation_succeeded(launch),
  identical(launch$value, list(
    application_id = "rrp.application.supplied", application_version = "0.1.0"
  )),
  !file.exists(sentinel), identical(names(before), names(after)),
  identical(before, after)
)

# The detached model exposes product-defined facts only, not project/raw-source
# content or physical/storage/executable objects.
model_text <- paste(capture.output(str(model)), collapse = " ")
private_pattern <- paste(c(
  "FIC STAY", "FIC PERSON", "FIC ENCOUNTER", "LOCAL_", "provider_signal",
  "identity-crosswalk", "source/generated", "credential", "connection",
  "history.duckdb", "produce-canonical.R", "calculate-risk.R"
), collapse = "|")
stopifnot(
  !grepl(private_pattern, model_text, ignore.case = TRUE),
  !grepl(project, model_text, fixed = TRUE),
  !grepl(software_root, model_text, fixed = TRUE),
  !any(c("path", "project_root", "connection", "writer", "history_port",
    "producer", "provider_callable", "credential") %in% names(model))
)

# Relocation preserves validation, existing product access, branding, and the
# same generic public launch without rebuilding products.
copied <- copy_project(project, file.path(suite, "relocated"), "project-copy")
copied_before <- project_digest(copied)
copied_doctor <- rrp_validate_project(catalog, copied)
copied_access <- rrp_open_product_access(
  catalog, copied, second_run$value$operation_run_id, second_time
)
copied_model <- internal("rrp_application_prepare")(
  catalog, copied, second_run$value$operation_run_id, second_time
)
copied_launch <- launch_installed(
  copied, second_run$value$operation_run_id, second_time
)
stopifnot(
  rrp_operation_succeeded(copied_doctor),
  rrp_operation_succeeded(copied_access),
  identical(copied_model$product_snapshot, model$product_snapshot),
  identical(copied_model$presentation, model$presentation),
  rrp_operation_succeeded(copied_launch),
  identical(copied_before, project_digest(copied)),
  !dir.exists(file.path(copied, ".git")), !file.exists(sentinel)
)

if (length(arguments) >= 2L && nzchar(arguments[[2L]])) {
  installed_library <- normalizePath(
    arguments[[2L]], winslash = "/", mustWork = TRUE
  )
  dependency_paths <- vapply(
    c("rrpplatform", "rrpruntime", "shiny", "bslib", "plotly", "reactable",
      "brand.yml"),
    function(package) normalizePath(
      find.package(package), winslash = "/", mustWork = TRUE
    ), character(1L)
  )
  stopifnot(all(startsWith(
    dependency_paths, paste0(installed_library, .Platform$file.sep)
  )))
}

stopifnot(
  identical(getwd(), unrelated), !dir.exists(file.path(project, ".git")),
  !file.exists(sentinel)
)
cat("rrpplatform installed fictional application tests passed\n")
