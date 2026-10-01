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
