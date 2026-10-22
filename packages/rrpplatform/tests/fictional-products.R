library(rrpplatform)

arguments <- commandArgs(trailingOnly = TRUE)
software_root <- if (length(arguments) >= 1L) arguments[[1L]] else
  Sys.getenv("RRP_TEST_SOFTWARE_ROOT", unset = "")
stopifnot(nzchar(software_root), dir.exists(software_root))
software_root <- normalizePath(software_root, winslash = "/", mustWork = TRUE)
catalog <- rrp_open_resource_catalog(software_root)

suite <- tempfile("rrp-fictional-products-")
dir.create(suite)
on.exit(unlink(suite, recursive = TRUE, force = TRUE), add = TRUE)
unrelated <- file.path(suite, "unrelated-working-directory")
dir.create(unrelated)
unrelated <- normalizePath(unrelated, winslash = "/", mustWork = TRUE)
old_working_directory <- setwd(unrelated)
on.exit(setwd(old_working_directory), add = TRUE)
stopifnot(!dir.exists(".git"), !dir.exists(file.path(software_root, ".git")))

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

expect_access_failure <- function(result, code) {
  stopifnot(
    !rrp_operation_succeeded(result), identical(result$status, "failure"),
    is.null(result$value), length(result$diagnostics) == 1L,
    identical(result$diagnostics[[1L]]$code, code),
    !grepl("[/\\]", result$diagnostics[[1L]]$message)
  )
}

read_bytes <- function(path) {
  readBin(path, "raw", n = file.info(path, extra_cols = FALSE)$size[[1L]])
}

private_pattern <- paste(c(
  "FIC STAY", "FIC PERSON", "FIC ENCOUNTER", "LOCAL_", "provider_signal",
  "identity-crosswalk", "source/generated", "credential", "connection"
), collapse = "|")

guide_path <- rrp_resource_path(
  catalog, "rrp.documentation.logical-products-guide"
)
guide <- paste(readLines(guide_path, warn = FALSE, encoding = "UTF-8"),
  collapse = "\n")
stopifnot(
  startsWith(guide_path, paste0(software_root, .Platform$file.sep)),
  grepl("rrp_build_product_set", guide, fixed = TRUE),
  grepl("rrp_materialize_product_set", guide, fixed = TRUE),
  grepl("rrp_open_product_access", guide, fixed = TRUE),
  grepl("zero episodes", guide, fixed = TRUE),
  grepl("fresh", guide, fixed = TRUE),
  grepl("stale", guide, fixed = TRUE),
  grepl("backup", guide, fixed = TRUE),
  grepl("application", guide, fixed = TRUE)
)

project <- file.path(suite, "ordinary-fictional-project")
stopifnot(rrp_operation_succeeded(
  rrp_initialize_fictional_project(catalog, project)
))
generator <- new.env(parent = baseenv())
sys.source(file.path(project, "R", "generate-source.R"), generator,
  chdir = FALSE, keep.source = FALSE)
generator$rrp_generate_fictional_source(project)
initialized <- rrp_initialize_project_state(catalog, project)
stopifnot(rrp_operation_succeeded(initialized), !dir.exists(file.path(
  project, "state", "products"
)))

first_time <- "2026-01-19T12:00:00Z"
second_time <- "2026-01-20T12:00:00Z"
newer_time <- "2026-01-22T12:00:00Z"
empty_time <- "2025-12-19T12:00:00Z"
empty_run <- rrp_execute_durable_bundle(
  catalog, project, empty_time, "fictional-products-empty"
)
first_run <- rrp_execute_durable_bundle(
  catalog, project, first_time, "fictional-products-first"
)
second_run <- rrp_execute_durable_bundle(
  catalog, project, second_time, "fictional-products-second"
)
stopifnot(
  rrp_operation_succeeded(empty_run),
  identical(empty_run$value$expected_episode_count, 0L),
  rrp_operation_succeeded(first_run), rrp_operation_succeeded(second_run),
  identical(first_run$value$expected_episode_count, 4L),
  identical(second_run$value$expected_episode_count, 4L),
  isTRUE(first_run$value$complete), isTRUE(second_run$value$complete)
)

built <- rrp_build_product_set(
  catalog, project, second_run$value$operation_run_id, second_time
)
stopifnot(rrp_operation_succeeded(built))
product_set <- built$value
current <- product_set$members$current_remaining_risk$data
trajectory <- product_set$members$remaining_risk_trajectory$data
summary <- product_set$members$operational_scope_summary$data
stopifnot(
  identical(class(product_set), c("rrp_logical_product_set", "list")),
  identical(names(product_set$members), c(
    "current_remaining_risk", "remaining_risk_trajectory",
    "operational_scope_summary"
  )),
  identical(product_set$project_id, "fictional-reference-hospital"),
  identical(product_set$source_operation_run_id,
    second_run$value$operation_run_id),
  identical(product_set$source_analytical_time, second_time),
  identical(product_set$source_history_cutoff, second_time),
  grepl("^rrp[.]product-set[.][0-9a-f]{16}$", product_set$product_set_id),
  grepl("^rrp[.]source-history[.][0-9a-f]{16}$",
    product_set$source_history_fingerprint),
  nrow(current) == 1L, nrow(trajectory) == 2L, nrow(summary) == 1L,
  identical(current$episode_id, "fictional.episode.001"),
  identical(current$analytical_time, second_time),
  isTRUE(all.equal(current$estimate_value, 0.3833333333333333)),
  identical(trajectory$episode_id,
    rep("fictional.episode.001", 2L)),
  identical(trajectory$analytical_time, c(first_time, second_time)),
  isTRUE(all.equal(trajectory$estimate_value,
    c(0.39, 0.3833333333333333))),
  identical(trajectory$analytical_kind, c("initial", "initial")),
  identical(current$provider_id, "fictional-reference-hospital.provider"),
  all(trajectory$provider_id == "fictional-reference-hospital.provider"),
  identical(summary$expected_episode_count, 4L),
  identical(summary$initial_disposition_count, 4L),
  identical(summary$effective_disposition_count, 4L),
  identical(summary$eligible_count, 1L),
  identical(summary$accepted_estimate_count, 1L),
  identical(summary$ineligible_count, 3L),
  identical(summary$episode_before_discharge_count, 0L),
  identical(summary$target_horizon_exhausted_count, 1L),
  identical(summary$episode_already_readmitted_count, 1L),
  identical(summary$episode_already_dead_count, 1L),
  isTRUE(summary$complete)
)

logical_text <- paste(capture.output(dput(product_set)), collapse = "\n")
stopifnot(!grepl(private_pattern, logical_text, ignore.case = TRUE))

published <- rrp_materialize_product_set(catalog, project, product_set)
stopifnot(
  rrp_operation_succeeded(published), identical(published$value$reused, FALSE)
)
product_root <- file.path(project, "state", "products")
materialized_files <- list.files(product_root, recursive = TRUE,
  full.names = TRUE, include.dirs = FALSE)
materialized_text <- paste(unlist(lapply(materialized_files, readLines,
  warn = FALSE, encoding = "UTF-8")), collapse = "\n")
stopifnot(!grepl(private_pattern, materialized_text, ignore.case = TRUE))

# Reopen in a genuinely fresh process and return only detached logical values.
child_script <- file.path(suite, "fresh-product-reader.R")
child_output <- file.path(suite, "fresh-product-reader.rds")
writeLines(c(
  "arguments <- commandArgs(trailingOnly = TRUE)",
  "library(rrpplatform)",
  "catalog <- rrp_open_resource_catalog(arguments[[1L]])",
  "opened <- rrp_open_product_access(catalog, arguments[[2L]])",
  "stopifnot(rrp_operation_succeeded(opened))",
  "inventory <- rrp_list_products(opened$value)",
  "products <- lapply(inventory, function(item) rrp_read_product(",
  "  opened$value, item$product_id, item$product_version))",
  "metadata <- lapply(inventory, function(item) rrp_read_product(",
  "  opened$value, item$product_id, item$product_version, metadata_only = TRUE))",
  "saveRDS(list(access = opened$value, inventory = inventory,",
  "  products = products, metadata = metadata), arguments[[3L]])"
), child_script, useBytes = TRUE)
status <- system2(file.path(R.home("bin"), "Rscript"), c(
  "--vanilla", shQuote(child_script), shQuote(software_root),
  shQuote(project), shQuote(child_output)
), stdout = TRUE, stderr = TRUE, env = "R_TESTS=")
stopifnot(identical(attr(status, "status"), NULL), file.exists(child_output))
fresh_process <- readRDS(child_output)
logical_members <- unname(product_set$members)
same_products <- vapply(seq_along(logical_members), function(index) {
  expected <- logical_members[[index]]
  actual <- fresh_process$products[[index]]
  expected_data <- expected$data
  actual_data <- actual$data
  row.names(expected_data) <- NULL
  row.names(actual_data) <- NULL
  expected$data <- NULL
  actual$data <- NULL
  identical(actual, expected) && identical(actual_data, expected_data)
}, logical(1L))
stopifnot(
  length(fresh_process$inventory) == 3L,
  identical(vapply(fresh_process$inventory, `[[`, character(1L),
    "product_id"), c(
      "rrp.product.current-remaining-risk",
      "rrp.product.remaining-risk-trajectory",
      "rrp.product.operational-scope-summary"
    )),
  all(same_products),
  all(vapply(fresh_process$metadata, function(value) !"data" %in% names(value),
    logical(1L))),
  !any(c("path", "connection", "writer") %in% names(fresh_process$access))
)

history_path <- file.path(project, "state", "history.duckdb")
history_before <- unname(tools::md5sum(history_path))
rebuilt <- rrp_build_product_set(
  catalog, project, second_run$value$operation_run_id, second_time
)
republished <- rrp_materialize_product_set(catalog, project, rebuilt$value)
stopifnot(
  rrp_operation_succeeded(rebuilt), identical(rebuilt$value, product_set),
  rrp_operation_succeeded(republished), identical(republished$value$reused, TRUE),
  identical(republished$value$materialization_id,
    published$value$materialization_id),
  identical(unname(tools::md5sum(history_path)), history_before)
)

fresh <- rrp_open_product_access(
  catalog, project, second_run$value$operation_run_id, second_time
)
later_cutoff_same_source <- rrp_open_product_access(
  catalog, project, second_run$value$operation_run_id,
  "2026-01-20T13:00:00Z"
)
stopifnot(
  identical(rrp_open_product_access(catalog, project)$value$freshness$status,
    "not-evaluated"),
  identical(fresh$value$freshness$status, "fresh"),
  identical(later_cutoff_same_source$value$freshness$status, "fresh")
)

copied <- copy_project(project, file.path(suite, "copy"), "copied-project")
copied_access <- rrp_open_product_access(catalog, copied)
stopifnot(
  rrp_operation_succeeded(copied_access),
  identical(copied_access$value$product_set_id, product_set$product_set_id),
  !grepl(project, paste(capture.output(str(copied_access)), collapse = " "),
    fixed = TRUE), !dir.exists(file.path(copied, ".git"))
)

corrupt <- copy_project(project, file.path(suite, "corrupt"), "project")
corrupt_member <- file.path(
  corrupt, "state", "products", "sets", published$value$materialization_id,
  "current-remaining-risk.csv"
)
writeBin(c(read_bytes(corrupt_member), charToRaw("corrupt")), corrupt_member)
expect_access_failure(
  rrp_open_product_access(catalog, corrupt), "product_integrity_failed"
)
incompatible <- copy_project(
  project, file.path(suite, "incompatible"), "project"
)
pointer <- file.path(incompatible, "state", "products", "current.dcf")
pointer_lines <- readLines(pointer, warn = FALSE, encoding = "UTF-8")
pointer_lines <- sub(
  "^Materialization-Contract-Version: 0[.]1[.]0$",
  "Materialization-Contract-Version: 9.9.9", pointer_lines
)
writeLines(pointer_lines, pointer, useBytes = TRUE)
expect_access_failure(
  rrp_open_product_access(catalog, incompatible),
  "product_materialization_incompatible"
)

newer_run <- rrp_execute_durable_bundle(
  catalog, project, newer_time, "fictional-products-newer"
)
stopifnot(rrp_operation_succeeded(newer_run))
stale <- rrp_open_product_access(
  catalog, project, newer_run$value$operation_run_id, newer_time
)
stopifnot(
  rrp_operation_succeeded(stale),
  identical(stale$value$freshness$status, "stale"),
  nrow(rrp_read_product(stale$value,
    "rrp.product.current-remaining-risk", "0.1.0")$data) == 1L
)
newer_set <- rrp_build_product_set(
  catalog, project, newer_run$value$operation_run_id, newer_time
)
newer_publication <- rrp_materialize_product_set(
  catalog, project, newer_set$value
)
stopifnot(
  rrp_operation_succeeded(newer_set), rrp_operation_succeeded(newer_publication),
  !identical(newer_set$value$product_set_id, product_set$product_set_id),
  dir.exists(file.path(project, "state", "products", "sets",
    published$value$materialization_id))
)

empty_set <- rrp_build_product_set(
  catalog, project, empty_run$value$operation_run_id, empty_time
)
stopifnot(
  rrp_operation_succeeded(empty_set),
  nrow(empty_set$value$members$current_remaining_risk$data) == 0L,
  nrow(empty_set$value$members$remaining_risk_trajectory$data) == 0L,
  nrow(empty_set$value$members$operational_scope_summary$data) == 1L,
  all(empty_set$value$members$operational_scope_summary$data[c(
    "expected_episode_count", "initial_disposition_count",
    "effective_disposition_count", "eligible_count",
    "accepted_estimate_count", "ineligible_count"
  )] == 0L),
  isTRUE(empty_set$value$members$operational_scope_summary$data$complete),
  rrp_operation_succeeded(rrp_materialize_product_set(
    catalog, project, empty_set$value
  )),
  rrp_operation_succeeded(rrp_open_product_access(catalog, project))
)

# Products are derived: deletion preserves history and exact rebuilding works.
history_before_deletion <- unname(tools::md5sum(history_path))
unlink(file.path(project, "state", "products"), recursive = TRUE, force = TRUE)
expect_access_failure(
  rrp_open_product_access(catalog, project), "product_integrity_failed"
)
recovered_set <- rrp_build_product_set(
  catalog, project, second_run$value$operation_run_id, second_time
)
stopifnot(
  rrp_operation_succeeded(recovered_set),
  identical(recovered_set$value, product_set),
  rrp_operation_succeeded(rrp_materialize_product_set(
    catalog, project, recovered_set$value
  )),
  identical(unname(tools::md5sum(history_path)), history_before_deletion)
)

# Authoritative backup excludes products; restore leaves them absent and
# history can reproduce the same logical set.
backup_path <- file.path(suite, "state-backup")
backup <- rrp_backup_project_state(catalog, project, backup_path)
stopifnot(
  rrp_operation_succeeded(backup),
  identical(sort(list.files(backup_path), method = "radix"),
    c("backup.dcf", "history.duckdb")),
  !dir.exists(file.path(backup_path, "products"))
)
restored <- copy_project(project, file.path(suite, "restore"), "project")
unlink(file.path(restored, "state"), recursive = TRUE, force = TRUE)
stopifnot(rrp_operation_succeeded(
  rrp_restore_project_state(catalog, restored, backup_path)
))
expect_access_failure(
  rrp_open_product_access(catalog, restored), "product_integrity_failed"
)
restored_set <- rrp_build_product_set(
  catalog, restored, second_run$value$operation_run_id, second_time
)
stopifnot(
  rrp_operation_succeeded(restored_set),
  identical(restored_set$value, product_set),
  rrp_operation_succeeded(rrp_materialize_product_set(
    catalog, restored, restored_set$value
  )),
  rrp_operation_succeeded(rrp_open_product_access(catalog, restored))
)

# A distribution-shaped software root additionally proves the create-only
# standalone initializer. The ordinary package projection intentionally has no
# distribution manifest and therefore cannot make this installed-software
# identity claim.
if (file.exists(file.path(software_root, "manifest.dcf"))) {
  application <- rrp_initialize_app(
    catalog, project, second_run$value$operation_run_id, second_time
  )
  if (!rrp_operation_succeeded(application)) stop(
    paste0("Standalone initialization failed: ",
      application$diagnostics[[1L]]$code), call. = FALSE
  )
  app_root <- file.path(project, "app")
  stopifnot(
    rrp_operation_succeeded(application), dir.exists(app_root),
    identical(application$value$destination,
      normalizePath(app_root, winslash = "/", mustWork = TRUE)),
    identical(sort(list.files(app_root), method = "radix"), sort(c(
      "app.R", "LICENSE", "NOTICE", "R", "README.md", "renv.lock", "rrp-data",
      "rrp-initialization.dcf", "rrp-source-inventory.dcf", "www"
    ), method = "radix")),
    is.expression(parse(file.path(app_root, "app.R"))),
    !file.exists(file.path(app_root, ".Rprofile"))
  )
  app_expression <- parse(file.path(app_root, "app.R"))
  app_symbols <- unique(all.names(app_expression, functions = TRUE))
  stopifnot(!any(c(
    "rrpplatform", "rrpruntime", "readmit", "DBI", "duckdb",
    "rrp_load_project", "rrp_execute_durable_bundle"
  ) %in% app_symbols))
  prior_directory <- setwd(app_root)
  standalone <- tryCatch(
    eval(app_expression, envir = new.env(parent = baseenv())),
    finally = setwd(prior_directory)
  )
  stopifnot(inherits(standalone, "shiny.appobj"))
  curl <- Sys.which("curl")
  if (nzchar(curl)) {
    port <- as.integer(40000L + Sys.getpid() %% 10000L)
    index_probe <- file.path(suite, "standalone-index.html")
    asset_probe <- file.path(suite, "standalone-asset.css")
    probe <- new.env(parent = emptyenv()); probe$ok <- FALSE
    later_call <- get("later", envir = asNamespace("later"), inherits = FALSE)
    later_call(function() {
      system2(curl, c("--fail", "--silent", "--show-error",
        paste0("http://127.0.0.1:", port, "/"), "--output", index_probe),
        wait = FALSE)
      system2(curl, c("--fail", "--silent", "--show-error",
        paste0("http://127.0.0.1:", port, "/rrp.css"), "--output", asset_probe),
        wait = FALSE)
    }, delay = 0.5)
    later_call(function() {
      probe$ok <- file.exists(index_probe) && file.exists(asset_probe) &&
        file.info(index_probe)$size[[1L]] > 0L &&
        file.info(asset_probe)$size[[1L]] > 0L
      shiny::stopApp()
    }, delay = 2)
    shiny::runApp(app_root, host = "127.0.0.1", port = port,
      launch.browser = FALSE, quiet = TRUE)
    stopifnot(isTRUE(probe$ok))
  }
  baseline <- read_bytes(file.path(app_root, "rrp-initialization.dcf"))
  existing <- rrp_initialize_app(
    catalog, project, second_run$value$operation_run_id, second_time
  )
  stopifnot(
    !rrp_operation_succeeded(existing),
    identical(existing$diagnostics[[1L]]$code, "application_destination_exists"),
    identical(read_bytes(file.path(app_root, "rrp-initialization.dcf")), baseline)
  )
  alternative_root <- file.path(suite, "alternative-app")
  alternative <- rrp_initialize_app(
    catalog, project, second_run$value$operation_run_id, second_time,
    alternative_root
  )
  stopifnot(
    rrp_operation_succeeded(alternative),
    identical(read_bytes(file.path(alternative_root, "rrp-initialization.dcf")),
      baseline)
  )
  injected_root <- file.path(suite, "injected-app")
  injected <- getFromNamespace("rrp_app_initialize", "rrpplatform")(
    catalog, project, second_run$value$operation_run_id, second_time,
    injected_root, failure_stage = "before_promotion"
  )
  stopifnot(
    !rrp_operation_succeeded(injected),
    identical(injected$diagnostics[[1L]]$code, "application_injected_failure"),
    !file.exists(injected_root), !dir.exists(injected_root),
    !length(list.files(suite, pattern = "^[.]rrp-app-staging-"))
  )
  empty_project <- copy_project(
    restored, file.path(suite, "empty-app-project"), "project"
  )
  stopifnot(rrp_operation_succeeded(rrp_materialize_product_set(
    catalog, empty_project, empty_set$value
  )))
  empty_application <- rrp_initialize_app(
    catalog, empty_project, empty_run$value$operation_run_id, empty_time
  )
  stopifnot(
    rrp_operation_succeeded(empty_application),
    dir.exists(file.path(empty_project, "app"))
  )
  corrupt_application <- rrp_initialize_app(
    catalog, corrupt, second_run$value$operation_run_id, second_time
  )
  incompatible_application <- rrp_initialize_app(
    catalog, incompatible, second_run$value$operation_run_id, second_time
  )
  stopifnot(
    !rrp_operation_succeeded(corrupt_application),
    !rrp_operation_succeeded(incompatible_application),
    !dir.exists(file.path(corrupt, "app")),
    !dir.exists(file.path(incompatible, "app"))
  )
  stale_root <- file.path(suite, "stale-app")
  stale_application <- rrp_initialize_app(
    catalog, project, newer_run$value$operation_run_id, newer_time, stale_root
  )
  stopifnot(
    !rrp_operation_succeeded(stale_application),
    identical(stale_application$diagnostics[[1L]]$code,
      "application_products_stale"),
    !file.exists(stale_root), !dir.exists(stale_root)
  )
  later_cutoff_root <- file.path(suite, "later-cutoff-app")
  later_cutoff_application <- rrp_initialize_app(
    catalog, project, second_run$value$operation_run_id,
    "2026-01-20T13:00:00Z", later_cutoff_root
  )
  stopifnot(
    !rrp_operation_succeeded(later_cutoff_application),
    identical(later_cutoff_application$diagnostics[[1L]]$code,
      "application_products_stale"),
    !file.exists(later_cutoff_root), !dir.exists(later_cutoff_root)
  )

  # Complete 12.B lifecycle: hospital source changes remain outside RRP's
  # reserved boundary while a later, already-materialized set is promoted.
  writeLines(c(readLines(file.path(app_root, "app.R"), warn = FALSE),
    "# hospital customization"), file.path(app_root, "app.R"), useBytes = TRUE)
  writeLines(c(readLines(file.path(app_root, "R", "application-ui.R"),
    warn = FALSE), "# hospital module customization"),
    file.path(app_root, "R", "application-ui.R"), useBytes = TRUE)
  writeLines(c(readLines(file.path(app_root, "www", "rrp.css"), warn = FALSE),
    "/* hospital style */"), file.path(app_root, "www", "rrp.css"),
    useBytes = TRUE)
  writeLines(c(readLines(file.path(app_root, "README.md"), warn = FALSE),
    "Hospital operating note."), file.path(app_root, "README.md"),
    useBytes = TRUE)
  writeLines("hospital dependency declaration", file.path(app_root, "DESCRIPTION"))
  dir.create(file.path(app_root, "R", "hospital"))
  writeLines("hospital_helper <- function() TRUE",
    file.path(app_root, "R", "hospital", "helper.R"))
  writeBin(as.raw(c(1L, 2L, 3L)), file.path(app_root, "www", "hospital.bin"))
  dir.create(file.path(app_root, "deployment"))
  writeLines("operator: owned", file.path(app_root, "deployment", "config.yml"))
  dir.create(file.path(app_root, ".git"))
  writeLines("ref: refs/heads/main", file.path(app_root, ".git", "HEAD"))
  writeLines("unrelated", file.path(app_root, "HOSPITAL-NOTES.md"))
  execution_marker <- file.path(suite, "detached-source-executed")
  writeLines(paste0("writeLines('executed', ", dQuote(execution_marker), ")"),
    file.path(app_root, "R", "execute-if-sourced.R"), useBytes = TRUE)
  outside_files <- function(root) {
    values <- list.files(root, recursive = TRUE, all.files = TRUE,
      no.. = TRUE, full.names = FALSE, include.dirs = FALSE)
    values[!startsWith(values, "rrp-data/")]
  }
  outside_snapshot <- function(root) {
    paths <- sort(outside_files(root), method = "radix")
    structure(lapply(paths, function(path) read_bytes(file.path(root, path))),
      names = paths)
  }
  source_before_refresh <- outside_snapshot(app_root)
  initialization_before_refresh <- read_bytes(file.path(
    app_root, "rrp-initialization.dcf"
  ))
  history_before_refresh <- read_bytes(history_path)
  stopifnot(rrp_operation_succeeded(rrp_materialize_product_set(
    catalog, project, newer_set$value
  )))
  source_materialization_before <- list.files(product_root, recursive = TRUE,
    all.files = TRUE, no.. = TRUE, full.names = FALSE)
  source_materialization_bytes <- structure(lapply(
    source_materialization_before,
    function(path) read_bytes(file.path(product_root, path))
  ), names = source_materialization_before)
  before_refresh_validation <- rrp_validate_app(catalog, app_root)
  if (!rrp_operation_succeeded(before_refresh_validation)) stop(
    paste0("Pre-refresh standalone validation failed: ",
      before_refresh_validation$diagnostics[[1L]]$code), call. = FALSE
  )
  pointer_before_refresh <- read_bytes(file.path(app_root, "rrp-data", "current.dcf"))
  refreshed <- rrp_refresh_app(
    catalog, project, newer_run$value$operation_run_id, newer_time
  )
  if (!rrp_operation_succeeded(refreshed)) stop(
    paste0("Standalone refresh failed: ", refreshed$diagnostics[[1L]]$code),
    call. = FALSE
  )
  validated <- rrp_validate_app(catalog, app_root)
  stopifnot(
    rrp_operation_succeeded(refreshed), isTRUE(refreshed$value$changed),
    identical(refreshed$value$previous_product_set_id,
      application$value$product_set_id),
    identical(refreshed$value$product_set_id, newer_set$value$product_set_id),
    !identical(read_bytes(file.path(app_root, "rrp-data", "current.dcf")),
      pointer_before_refresh),
    rrp_operation_succeeded(validated),
    identical(validated$value$product_set_id, newer_set$value$product_set_id),
    identical(validated$value$managed_content_status, "valid"),
    identical(validated$value$initial_provenance_status, "available"),
    identical(validated$value$source_baseline_status, "drifted"),
    identical(outside_snapshot(app_root), source_before_refresh),
    identical(read_bytes(file.path(app_root, "rrp-initialization.dcf")),
      initialization_before_refresh),
    identical(read_bytes(history_path), history_before_refresh),
    identical(list.files(product_root, recursive = TRUE, all.files = TRUE,
      no.. = TRUE, full.names = FALSE), source_materialization_before),
    identical(structure(lapply(source_materialization_before,
      function(path) read_bytes(file.path(product_root, path))),
      names = source_materialization_before), source_materialization_bytes),
    !file.exists(execution_marker)
  )
  repeated <- rrp_refresh_app(
    catalog, project, newer_run$value$operation_run_id, newer_time
  )
  stopifnot(
    rrp_operation_succeeded(repeated), !isTRUE(repeated$value$changed),
    identical(repeated$value$product_set_id, newer_set$value$product_set_id),
    identical(outside_snapshot(app_root), source_before_refresh)
  )

  # A detached copy requires neither the project nor application-source
  # execution. Initial evidence may drift or disappear without weakening the
  # independent managed-content result.
  detached <- copy_project(app_root, file.path(suite, "detached"), "app")
  detached_before <- outside_snapshot(detached)
  detached_valid <- rrp_validate_app(catalog, detached)
  stopifnot(
    rrp_operation_succeeded(detached_valid),
    identical(detached_valid$value$product_set_id, newer_set$value$product_set_id),
    identical(detached_valid$value$source_baseline_status, "drifted"),
    identical(outside_snapshot(detached), detached_before),
    !file.exists(execution_marker)
  )
  unlink(file.path(detached, "rrp-initialization.dcf"))
  missing_initial <- rrp_validate_app(catalog, detached)
  stopifnot(
    rrp_operation_succeeded(missing_initial),
    identical(missing_initial$value$initial_provenance_status, "missing"),
    identical(missing_initial$value$source_baseline_status, "unavailable")
  )
  writeLines("altered", file.path(detached, "rrp-initialization.dcf"))
  invalid_initial <- rrp_validate_app(catalog, detached)
  stopifnot(
    rrp_operation_succeeded(invalid_initial),
    identical(invalid_initial$value$initial_provenance_status, "invalid"),
    identical(invalid_initial$value$source_baseline_status, "unavailable")
  )

  # Every precommit injection retains the old active set. Postcommit
  # injections report committed uncertainty while retaining the new valid set.
  refresh_internal <- getFromNamespace("rrp_app_refresh", "rrpplatform")
  precommit <- c(
    "before_staging", "during_staged_construction",
    "during_staged_validation", "before_pointer_replacement"
  )
  for (stage in precommit) {
    target <- copy_project(alternative_root, file.path(suite, paste0("fail-", stage)), "app")
    old_pointer <- read_bytes(file.path(target, "rrp-data", "current.dcf"))
    failed <- refresh_internal(
      catalog, project, newer_run$value$operation_run_id, newer_time,
      target, failure_stage = stage
    )
    stopifnot(
      !rrp_operation_succeeded(failed),
      identical(failed$diagnostics[[1L]]$code, "application_injected_failure"),
      identical(read_bytes(file.path(target, "rrp-data", "current.dcf")),
        old_pointer),
      rrp_operation_succeeded(rrp_validate_app(catalog, target))
    )
  }
  for (stage in c("after_pointer_replacement", "during_cleanup")) {
    target <- copy_project(alternative_root, file.path(suite, paste0("fail-", stage)), "app")
    failed <- refresh_internal(
      catalog, project, newer_run$value$operation_run_id, newer_time,
      target, failure_stage = stage
    )
    after_failure <- rrp_validate_app(catalog, target)
    stopifnot(
      !rrp_operation_succeeded(failed),
      identical(failed$diagnostics[[1L]]$code, "application_refresh_committed"),
      rrp_operation_succeeded(after_failure),
      identical(after_failure$value$product_set_id, newer_set$value$product_set_id),
      rrp_operation_succeeded(rrp_refresh_app(
        catalog, project, newer_run$value$operation_run_id, newer_time, target
      ))
    )
  }
  cleanup_target <- copy_project(alternative_root,
    file.path(suite, "bounded-cleanup"), "app")
  cleanup_pointer <- read.dcf(file.path(cleanup_target, "rrp-data", "current.dcf"),
    all = TRUE)[1L, , drop = TRUE]
  cleanup_source <- file.path(cleanup_target, "rrp-data",
    cleanup_pointer[["Set-Directory"]])
  cleanup_copy_parent <- file.path(suite, "bounded-cleanup-copy")
  dir.create(cleanup_copy_parent)
  stopifnot(file.copy(cleanup_source, cleanup_copy_parent,
    recursive = TRUE, copy.mode = FALSE))
  obsolete <- file.path(cleanup_target, "rrp-data", "sets",
    "set-111111111111111111111111")
  stopifnot(file.rename(file.path(cleanup_copy_parent, basename(cleanup_source)),
    obsolete))
  cleanup_refresh <- rrp_refresh_app(
    catalog, project, newer_run$value$operation_run_id, newer_time,
    cleanup_target
  )
  cleanup_validation <- rrp_validate_app(catalog, cleanup_target)
  stopifnot(
    rrp_operation_succeeded(cleanup_refresh),
    !dir.exists(obsolete),
    rrp_operation_succeeded(cleanup_validation),
    identical(cleanup_validation$value$inactive_set_count, 1L)
  )
  changed_pointer <- copy_project(alternative_root,
    file.path(suite, "pointer-race"), "app")
  race <- refresh_internal(
    catalog, project, newer_run$value$operation_run_id, newer_time,
    changed_pointer, promotion_hook = function(path) writeBin(
      c(read_bytes(path), charToRaw("\n")), path
    )
  )
  stopifnot(
    !rrp_operation_succeeded(race),
    identical(race$diagnostics[[1L]]$code, "application_current_changed"),
    rrp_operation_succeeded(rrp_validate_app(catalog, changed_pointer))
  )

  # Managed corruption, traversal, links, and reserved-path collisions fail
  # closed without touching any hospital-owned source byte.
  corrupt_managed <- copy_project(app_root,
    file.path(suite, "corrupt-managed"), "app")
  active <- read.dcf(file.path(corrupt_managed, "rrp-data", "current.dcf"),
    all = TRUE)[1L, "Set-Directory"]
  member <- file.path(corrupt_managed, "rrp-data", active,
    "current-remaining-risk.csv")
  writeBin(c(read_bytes(member), charToRaw("corrupt")), member)
  corrupt_before <- outside_snapshot(corrupt_managed)
  corrupt_result <- rrp_validate_app(catalog, corrupt_managed)
  corrupt_refresh <- rrp_refresh_app(
    catalog, project, newer_run$value$operation_run_id, newer_time,
    corrupt_managed
  )
  stopifnot(
    !rrp_operation_succeeded(corrupt_result),
    !rrp_operation_succeeded(corrupt_refresh),
    identical(outside_snapshot(corrupt_managed), corrupt_before)
  )
  traversal <- copy_project(app_root, file.path(suite, "traversal"), "app")
  traversal_pointer <- file.path(traversal, "rrp-data", "current.dcf")
  traversal_lines <- readLines(traversal_pointer, warn = FALSE)
  traversal_lines <- sub("^Set-Directory: .*$", "Set-Directory: ../outside",
    traversal_lines)
  writeLines(traversal_lines, traversal_pointer, useBytes = TRUE)
  stopifnot(!rrp_operation_succeeded(rrp_validate_app(catalog, traversal)))
  linked <- copy_project(app_root, file.path(suite, "linked-managed"), "app")
  linked_presentation <- file.path(linked, "rrp-data", "presentation.dcf")
  linked_target <- file.path(suite, "outside-presentation.dcf")
  stopifnot(file.copy(linked_presentation, linked_target),
    unlink(linked_presentation) == 0L)
  if (isTRUE(file.symlink(linked_target, linked_presentation))) {
    stopifnot(!rrp_operation_succeeded(rrp_validate_app(catalog, linked)))
  }
  collision <- copy_project(app_root, file.path(suite, "collision"), "app")
  writeLines("unexpected", file.path(collision, "rrp-data", "unexpected"))
  stopifnot(!rrp_operation_succeeded(rrp_validate_app(catalog, collision)))

  inactive <- copy_project(app_root, file.path(suite, "inactive"), "app")
  inactive_pointer <- read.dcf(file.path(inactive, "rrp-data", "current.dcf"),
    all = TRUE)[1L, , drop = TRUE]
  inactive_source <- file.path(inactive, "rrp-data",
    inactive_pointer[["Set-Directory"]])
  inactive_name <- "set-000000000000000000000000"
  inactive_copy_parent <- file.path(suite, "inactive-set-copy")
  dir.create(inactive_copy_parent)
  stopifnot(file.copy(inactive_source, inactive_copy_parent,
    recursive = TRUE, copy.mode = FALSE))
  copied_inactive <- file.path(inactive_copy_parent, basename(inactive_source))
  stopifnot(file.rename(copied_inactive,
    file.path(inactive, "rrp-data", "sets", inactive_name)))
  inactive_member <- file.path(inactive, "rrp-data", "sets", inactive_name,
    "current-remaining-risk.csv")
  writeBin(c(read_bytes(inactive_member), charToRaw("corrupt")), inactive_member)
  incomplete <- file.path(inactive, "rrp-data", "sets",
    ".rrp-set-staging-interrupted")
  dir.create(incomplete)
  writeLines("partial", file.path(incomplete, "products.dcf"))
  inactive_result <- rrp_validate_app(catalog, inactive)
  stopifnot(
    rrp_operation_succeeded(inactive_result),
    identical(inactive_result$value$invalid_inactive_set_count, 1L),
    identical(inactive_result$value$stale_work_count, 1L)
  )

  old_pointer <- read_bytes(file.path(app_root, "rrp-data", "current.dcf"))
  stale_refresh <- rrp_refresh_app(
    catalog, project, second_run$value$operation_run_id, second_time, app_root
  )
  corrupt_source_refresh <- rrp_refresh_app(
    catalog, corrupt, second_run$value$operation_run_id, second_time, app_root
  )
  stopifnot(
    !rrp_operation_succeeded(stale_refresh),
    identical(stale_refresh$diagnostics[[1L]]$code,
      "application_products_stale"),
    !rrp_operation_succeeded(corrupt_source_refresh),
    identical(read_bytes(file.path(app_root, "rrp-data", "current.dcf")),
      old_pointer),
    identical(outside_snapshot(app_root), source_before_refresh)
  )
}

if (length(arguments) >= 2L && nzchar(arguments[[2L]])) {
  installed_library <- normalizePath(
    arguments[[2L]], winslash = "/", mustWork = TRUE
  )
  dependency_paths <- vapply(
    c("rrpplatform", "rrpruntime", "DBI", "duckdb"),
    function(package) normalizePath(
      find.package(package), winslash = "/", mustWork = TRUE
    ), character(1L)
  )
  stopifnot(all(startsWith(
    dependency_paths, paste0(installed_library, .Platform$file.sep)
  )))
}

stopifnot(
  identical(getwd(), unrelated),
  !dir.exists(file.path(project, ".git")),
  !dir.exists(file.path(restored, ".git"))
)
cat("rrpplatform fictional installed product tests passed\n")
