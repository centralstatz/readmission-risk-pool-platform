library(rrpplatform)

arguments <- commandArgs(trailingOnly = TRUE)
software_root <- if (length(arguments) >= 1L) arguments[[1L]] else
  Sys.getenv("RRP_TEST_SOFTWARE_ROOT", unset = "")
stopifnot(nzchar(software_root), dir.exists(software_root))
catalog <- rrp_open_resource_catalog(software_root)

suite <- tempfile("rrp-application-foundation-")
dir.create(suite)
on.exit(unlink(suite, recursive = TRUE, force = TRUE), add = TRUE)

contracts <- rrpplatform:::rrp_application_contracts(catalog)
application_css <- rrp_resource_path(
  catalog, "rrp.asset.supplied-application-css"
)
stopifnot(
  identical(contracts$application[["Contract-ID"]],
    "rrp.application.supplied"),
  identical(contracts$application[["Contract-Version"]], "0.1.0"),
  identical(contracts$brand[["Contract-ID"]], "rrp.project-brand"),
  identical(contracts$brand[["Parser-Package"]], "brand.yml"),
  file.exists(application_css), !dir.exists(application_css),
  identical(basename(application_css), "supplied-application.css")
)

brand_root <- file.path(suite, "brand-project")
dir.create(brand_root)
defaults <- rrpplatform:::rrp_application_presentation_model(
  catalog, brand_root, contracts
)
stopifnot(
  identical(defaults$source, "rrp-defaults"),
  identical(defaults$display_name, "Readmission Risk Pool"),
  identical(defaults$primary_color, "#1F4E79"), is.null(defaults$logo),
  !any(c("path", "project_root", "brand") %in% names(defaults))
)

dir.create(file.path(brand_root, "assets"))
logo_path <- file.path(brand_root, "assets", "logo.png")
writeBin(as.raw(c(0x89, 0x50, 0x4e, 0x47, 0x0d, 0x0a, 0x1a, 0x0a,
  0x00)), logo_path)
writeLines(c(
  "meta:", "  name:", "    full: Example Health System",
  "    short: Example Health", "color:", "  primary: '#123456'",
  "logo:", "  medium:", "    path: assets/logo.png",
  "    alt: Example logo", "typography:", "  fonts:",
  "    - family: Source Sans 3", "      source: google"
), file.path(brand_root, "_brand.yml"), useBytes = TRUE)
branded <- rrpplatform:::rrp_application_presentation_model(
  catalog, brand_root, contracts
)
stopifnot(
  identical(branded$source, "project-brand"),
  identical(branded$display_name, "Example Health"),
  identical(branded$primary_color, "#123456"),
  identical(branded$logo$media_type, "image/png"),
  identical(branded$logo$bytes, readBin(logo_path, "raw", n = 9L)),
  identical(branded$logo$alt, "Example logo"),
  !"typography" %in% names(branded), !"path" %in% names(branded$logo)
)

expect_brand_failure <- function(lines) {
  writeLines(lines, file.path(brand_root, "_brand.yml"), useBytes = TRUE)
  condition <- tryCatch({
    rrpplatform:::rrp_application_presentation_model(
      catalog, brand_root, contracts
    )
    NULL
  }, rrp_application_error = identity)
  stopifnot(
    inherits(condition, "rrp_application_error"),
    identical(condition$code, "application_brand_invalid"),
    identical(condition$message, "Project branding is invalid or unsafe."),
    !grepl("[/\\]", condition$message)
  )
}
expect_brand_failure(c("meta:", " broken"))
expect_brand_failure(c("logo:", "  medium: https://example.test/logo.png"))
expect_brand_failure(c("logo:", "  medium: ../logo.png"))
expect_brand_failure(c("color:", "  primary: not-a-color"))
expect_brand_failure(c("logo:", paste0("  medium: ", logo_path)))

product_fields <- function(episodes, estimates, times, runs) data.frame(
  product_row_id = paste0("rrp.product-row.", seq_along(episodes)),
  episode_id = episodes,
  target_id = rep("rrp.risk-target.readmission-remaining-30-day",
    length(episodes)), target_version = rep("0.1.0", length(episodes)),
  analytical_time = times, estimate_value = estimates,
  estimate_record_id = paste0("estimate.", seq_along(episodes)),
  analytical_run_id = runs,
  source_operation_run_id = rep("operation.1", length(episodes)),
  state_id = rep("state.1", length(episodes)),
  request_id = paste0("request.", seq_along(episodes)),
  provider_id = c("provider.b", "provider.a", "provider.a")[seq_along(episodes)],
  provider_version = rep("1.0.0", length(episodes)),
  implementation_id = rep("implementation.1", length(episodes)),
  implementation_version = rep("1.0.0", length(episodes)),
  model_id = c(NA_character_, "model.a", "model.a")[seq_along(episodes)],
  model_version = c(NA_character_, "1.0.0", "1.0.0")[seq_along(episodes)],
  target_interval_start = times,
  target_interval_end = rep("2026-02-19T12:00:00Z", length(episodes)),
  target_interval_boundary = rep("(start,end]", length(episodes)),
  stringsAsFactors = FALSE
)
current <- product_fields(
  c("episode.b", "episode.a", "episode.c"), c(0.8, 0.8, 0.2),
  rep("2026-01-20T12:00:00Z", 3L), paste0("run.", 1:3)
)
trajectory <- product_fields(
  c("episode.a", "episode.a", "episode.historical"), c(0.7, 0.8, 0.4),
  c("2026-01-19T12:00:00Z", "2026-01-20T12:00:00Z",
    "2026-01-18T12:00:00Z"), paste0("trajectory.", 1:3)
)
trajectory$analytical_kind <- "initial"
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
  scope_created_at = "2026-01-20T12:01:00Z", expected_episode_count = 5L,
  initial_disposition_count = 5L, effective_disposition_count = 5L,
  eligible_count = 3L, accepted_estimate_count = 3L,
  provider_incompatible_count = 0L, provider_declared_failure_count = 0L,
  detected_failure_count = 0L, ineligible_count = 2L,
  episode_before_discharge_count = 0L, target_horizon_exhausted_count = 1L,
  episode_already_readmitted_count = 1L, episode_already_dead_count = 0L,
  membership_fingerprint = "membership.1", complete = TRUE,
  stringsAsFactors = FALSE
)
member <- function(id, data) list(
  product_contract_id = id, product_contract_version = "0.1.0",
  product_instance_id = paste0(id, ".instance"), product_set_id = "set.1",
  row_count = as.integer(nrow(data)), data = data
)
access <- structure(list(
  product_set_id = "set.1", materialization_id = "materialization.1",
  source_operation_run_id = "operation.1",
  source_analytical_time = "2026-01-20T12:00:00Z",
  source_history_cutoff = "2026-01-20T12:00:00Z",
  source_history_fingerprint = "fingerprint.1",
  freshness = list(status = "not-evaluated", expected_operation_run_id = NULL,
    expected_history_cutoff = NULL, expected_source_history_fingerprint = NULL),
  members = list(
    current_remaining_risk = member(
      "rrp.product.current-remaining-risk", current
    ),
    remaining_risk_trajectory = member(
      "rrp.product.remaining-risk-trajectory", trajectory
    ),
    operational_scope_summary = member(
      "rrp.product.operational-scope-summary", summary
    )
  )
), class = c("rrp_product_access", "list"))

snapshot <- rrpplatform:::rrp_application_product_snapshot(access)
view <- rrpplatform:::rrp_application_view_models(snapshot)
incompatible_access <- access
incompatible_access$members$current_remaining_risk$product_contract_version <-
  "9.9.9"
incompatible_condition <- tryCatch({
  rrpplatform:::rrp_application_product_snapshot(incompatible_access)
  NULL
}, rrp_application_error = identity)
stopifnot(
  identical(incompatible_condition$code, "application_product_incompatible"),
  identical(view$current$rows$episode_id,
    c("episode.a", "episode.b", "episode.c")),
  identical(view$current$rows$estimate_display, c("80.0%", "80.0%", "20.0%")),
  identical(view$current$episode_choices,
    c("episode.a", "episode.b", "episode.c", "episode.historical")),
  nrow(view$sparklines$episode.a) == 2L,
  nrow(view$sparklines$episode.b) == 0L,
  nrow(view$sparklines$episode.historical) == 1L,
  identical(view$trajectory$estimate_value, c(0.7, 0.8)),
  identical(view$overview$accepted_current_count, 3L),
  identical(view$overview$minimum, 0.2), identical(view$overview$maximum, 0.8),
  identical(view$overview$median, 0.8),
  identical(view$overview$scope$expected_episode_count, 5L)
)
searched <- rrpplatform:::rrp_application_current_view(
  current, trajectory, search = "episode.a", provider_id = "provider.a",
  model_id = "model.a", page = 1L, page_size = 1L
)
stopifnot(
  identical(searched$rows$episode_id, "episode.a"),
  identical(searched$displayed_count, 1L), identical(searched$total_count, 1L)
)

empty_access <- access
empty_access$members$current_remaining_risk <- member(
  "rrp.product.current-remaining-risk", current[FALSE, , drop = FALSE]
)
empty_access$members$remaining_risk_trajectory <- member(
  "rrp.product.remaining-risk-trajectory", trajectory[FALSE, , drop = FALSE]
)
empty_summary <- summary
count_fields <- names(empty_summary)[vapply(empty_summary, is.integer, logical(1L))]
empty_summary[count_fields] <- 0L
empty_access$members$operational_scope_summary <- member(
  "rrp.product.operational-scope-summary", empty_summary
)
empty_snapshot <- rrpplatform:::rrp_application_product_snapshot(empty_access)
empty_model <- rrpplatform:::rrp_application_model(empty_snapshot, defaults)
stopifnot(
  identical(empty_model$view_models$current$displayed_count, 0L),
  identical(empty_model$view_models$current$total_count, 0L),
  length(empty_model$view_models$current$episode_choices) == 0L,
  nrow(empty_model$view_models$trajectory) == 0L,
  identical(empty_model$view_models$overview$accepted_current_count, 0L),
  inherits(rrpplatform:::rrp_application_shiny(empty_model), "shiny.appobj")
)

model <- rrpplatform:::rrp_application_model(snapshot, defaults)
branded_model <- rrpplatform:::rrp_application_model(snapshot, branded)
app <- rrpplatform:::rrp_application_shiny(model)
model_text <- paste(capture.output(str(model)), collapse = " ")
stopifnot(
  inherits(app, "shiny.appobj"),
  identical(model$product_snapshot, branded_model$product_snapshot),
  identical(model$view_models, branded_model$view_models),
  !grepl(software_root, model_text, fixed = TRUE),
  !grepl(brand_root, model_text, fixed = TRUE),
  !any(c("software_catalog", "product_access", "project_root", "path",
    "connection", "history_port", "producer", "provider", "credential",
    "writer") %in% names(model)),
  identical(as.list(formals(rrp_launch_app)), as.list(alist(
    software_catalog = , project_root = , expected_operation_run_id = NULL,
    history_cutoff = NULL, launch_browser = interactive(), port = NULL
  )))
)

invalid <- rrp_launch_app(catalog, brand_root, launch_browser = NA)
stopifnot(
  !rrp_operation_succeeded(invalid),
  identical(invalid$diagnostics[[1L]]$code, "application_input_invalid")
)

# Exercise the public path through one real initialized project and one existing
# Stage 9 realization. The test schedules a normal Shiny stop through Shiny's
# own event-loop dependency; production code receives no test-only hook.
project <- file.path(suite, "installed-fictional-project")
stopifnot(rrp_operation_succeeded(
  rrp_initialize_fictional_project(catalog, project)
))
generator <- new.env(parent = baseenv())
sys.source(file.path(project, "R", "generate-source.R"), generator,
  chdir = FALSE, keep.source = FALSE)
generator$rrp_generate_fictional_source(project)
stopifnot(rrp_operation_succeeded(rrp_initialize_project_state(catalog, project)))
first_time <- "2026-01-19T12:00:00Z"
second_time <- "2026-01-20T12:00:00Z"
newer_time <- "2026-01-22T12:00:00Z"
first_run <- rrp_execute_durable_bundle(
  catalog, project, first_time, "application-first"
)
second_run <- rrp_execute_durable_bundle(
  catalog, project, second_time, "application-second"
)
stopifnot(rrp_operation_succeeded(first_run), rrp_operation_succeeded(second_run))
built <- rrp_build_product_set(
  catalog, project, second_run$value$operation_run_id, second_time
)
stopifnot(
  rrp_operation_succeeded(built)
)
published <- rrp_materialize_product_set(catalog, project, built$value)
stopifnot(rrp_operation_succeeded(published))

newer_run <- rrp_execute_durable_bundle(
  catalog, project, newer_time, "application-newer"
)
stopifnot(rrp_operation_succeeded(newer_run))

# Add test-only invocation sentinels after analytical preparation is complete.
# Loading the trusted project remains permitted; invoking either callable during
# application preparation or launch would create the sentinel and fail below.
call_sentinel <- file.path(suite, "application-analytical-call")
instrument_callable <- function(path, declaration, label) {
  lines <- readLines(path, warn = FALSE, encoding = "UTF-8")
  location <- which(lines == declaration)
  stopifnot(length(location) == 1L)
  evidence <- paste0(
    "  cat(", encodeString(paste0(label, "\n"), quote = "\""),
    ", file = ", encodeString(call_sentinel, quote = "\""),
    ", append = TRUE)"
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

all_project_files <- function(root) {
  paths <- list.files(root, recursive = TRUE, all.files = TRUE,
    no.. = TRUE, full.names = TRUE, include.dirs = FALSE)
  paths[order(paths, method = "radix")]
}
project_files <- all_project_files(project)
before <- unname(tools::md5sum(project_files))
names(before) <- substring(project_files, nchar(project) + 2L)

not_evaluated <- rrpplatform:::rrp_application_prepare(
  catalog, project, NULL, NULL
)
fresh <- rrpplatform:::rrp_application_prepare(
  catalog, project, second_run$value$operation_run_id, second_time
)
stale <- rrpplatform:::rrp_application_prepare(
  catalog, project, newer_run$value$operation_run_id, newer_time
)
stopifnot(
  identical(not_evaluated$product_snapshot$freshness$status, "not-evaluated"),
  identical(fresh$product_snapshot$freshness$status, "fresh"),
  identical(stale$product_snapshot$freshness$status, "stale"),
  isTRUE(all.equal(fresh$view_models$current$rows$estimate_value,
    0.3833333333333333)),
  inherits(rrpplatform:::rrp_application_shiny(fresh), "shiny.appobj")
)

launch_script <- file.path(suite, "launch-child.R")
launch_result <- file.path(suite, "launch-result.rds")
writeLines(c(
  "arguments <- commandArgs(trailingOnly = TRUE)",
  "library(rrpplatform)",
  "catalog <- rrp_open_resource_catalog(arguments[[1L]])",
  "later_call <- get('later', envir = asNamespace('later'), inherits = FALSE)",
  "random_port <- get('randomPort', envir = asNamespace('httpuv'), inherits = FALSE)",
  "later_call(function() shiny::stopApp(), delay = 2)",
  "result <- rrp_launch_app(catalog, arguments[[2L]], arguments[[3L]],",
  "  arguments[[4L]], launch_browser = FALSE, port = random_port())",
  "saveRDS(result, arguments[[5L]])"
), launch_script, useBytes = TRUE)
status <- system2(file.path(R.home("bin"), "Rscript"), c(
  "--vanilla", shQuote(launch_script), shQuote(software_root),
  shQuote(project), shQuote(second_run$value$operation_run_id),
  shQuote(second_time), shQuote(launch_result)
), stdout = TRUE, stderr = TRUE, env = "R_TESTS=")
stopifnot(identical(attr(status, "status"), NULL), file.exists(launch_result))
launched <- readRDS(launch_result)
project_files_after <- all_project_files(project)
after <- unname(tools::md5sum(project_files_after))
names(after) <- substring(project_files_after, nchar(project) + 2L)
stopifnot(
  rrp_operation_succeeded(launched),
  identical(launched$value, list(
    application_id = "rrp.application.supplied",
    application_version = "0.1.0"
  )),
  !file.exists(call_sentinel),
  identical(names(before), names(after)), identical(before, after)
)

copy_project <- function(source, parent, name) {
  dir.create(parent, recursive = TRUE)
  stopifnot(file.copy(source, parent, recursive = TRUE, copy.mode = FALSE,
    copy.date = FALSE))
  copied <- file.path(parent, basename(source))
  destination <- file.path(parent, name)
  stopifnot(file.rename(copied, destination))
  destination
}
corrupt <- copy_project(project, file.path(suite, "corrupt-copy"), "project")
corrupt_member <- file.path(
  corrupt, "state", "products", "sets", published$value$materialization_id,
  "current-remaining-risk.csv"
)
writeBin(c(readBin(corrupt_member, "raw", n = file.info(corrupt_member)$size),
  charToRaw("corrupt")), corrupt_member)
corrupt_result <- rrp_launch_app(catalog, corrupt, launch_browser = FALSE)
incompatible <- copy_project(
  project, file.path(suite, "incompatible-copy"), "project"
)
pointer <- file.path(incompatible, "state", "products", "current.dcf")
pointer_lines <- readLines(pointer, warn = FALSE, encoding = "UTF-8")
pointer_lines <- sub(
  "^Materialization-Contract-Version: 0[.]1[.]0$",
  "Materialization-Contract-Version: 9.9.9", pointer_lines
)
writeLines(pointer_lines, pointer, useBytes = TRUE)
incompatible_result <- rrp_launch_app(
  catalog, incompatible, launch_browser = FALSE
)
stopifnot(
  identical(corrupt_result$diagnostics[[1L]]$code,
    "application_product_integrity_failed"),
  identical(incompatible_result$diagnostics[[1L]]$code,
    "application_product_incompatible")
)

absent <- file.path(suite, "products-absent")
stopifnot(
  rrp_operation_succeeded(rrp_initialize_fictional_project(catalog, absent)),
  rrp_operation_succeeded(rrp_initialize_project_state(catalog, absent))
)
absent_result <- rrp_launch_app(catalog, absent, launch_browser = FALSE)
stopifnot(
  !rrp_operation_succeeded(absent_result),
  identical(absent_result$diagnostics[[1L]]$code,
    "application_product_integrity_failed")
)
