library(rrpplatform)

materialization_internal <- function(name) {
  get(name, envir = asNamespace("rrpplatform"), inherits = FALSE)
}

materialization_failure <- function(result, code = NULL) {
  stopifnot(
    identical(result$status, "failure"), is.null(result$value),
    length(result$diagnostics) == 1L,
    result$diagnostics[[1L]]$code %in% c(
      "product_materialization_failed", "product_integrity_failed",
      "product_materialization_incompatible", "product_access_failed"
    ),
    !grepl("[/\\]", result$diagnostics[[1L]]$message)
  )
  if (!is.null(code)) stopifnot(identical(result$diagnostics[[1L]]$code, code))
  invisible(result)
}

materialization_copy_project <- function(source, parent, name) {
  dir.create(parent, recursive = TRUE, showWarnings = FALSE)
  stopifnot(file.copy(
    source, parent, recursive = TRUE, copy.mode = FALSE, copy.date = FALSE
  ))
  copied <- file.path(parent, basename(source))
  destination <- file.path(parent, name)
  stopifnot(file.rename(copied, destination))
  destination
}

materialization_bytes <- function(path) {
  readBin(path, "raw", n = file.info(path, extra_cols = FALSE)$size[[1L]])
}

materialization_read_dcf <- function(path) {
  value <- read.dcf(path, all = FALSE)
  stopifnot(nrow(value) == 1L)
  stats::setNames(as.character(value[1L, ]), colnames(value))
}

materialization_write_dcf <- function(value, path) {
  writeLines(paste0(names(value), ": ", unname(value)), path, useBytes = TRUE)
}

materialization_current_paths <- function(project) {
  root <- file.path(project, "state", "products")
  pointer_path <- file.path(root, "current.dcf")
  pointer <- materialization_read_dcf(pointer_path)
  set <- file.path(root, pointer[["Set-Directory"]])
  list(
    root = root, pointer_path = pointer_path, pointer = pointer, set = set,
    manifest_path = file.path(set, pointer[["Manifest-File"]])
  )
}

materialization_refresh_pointer <- function(paths) {
  pointer <- materialization_read_dcf(paths$pointer_path)
  pointer[["Manifest-Size"]] <- as.character(file.info(
    paths$manifest_path, extra_cols = FALSE
  )$size[[1L]])
  pointer[["Manifest-MD5"]] <- unname(tools::md5sum(paths$manifest_path)[[1L]])
  materialization_write_dcf(pointer, paths$pointer_path)
}

materialization_refresh_member <- function(paths, prefix, filename) {
  manifest <- materialization_read_dcf(paths$manifest_path)
  member <- file.path(paths$set, filename)
  manifest[[paste0(prefix, "-Byte-Size")]] <- as.character(file.info(
    member, extra_cols = FALSE
  )$size[[1L]])
  manifest[[paste0(prefix, "-MD5")]] <- unname(tools::md5sum(member)[[1L]])
  materialization_write_dcf(manifest, paths$manifest_path)
  materialization_refresh_pointer(paths)
}

materialization_corruption_case <- function(
  source, suite, name, mutate, expected = NULL
) {
  project <- materialization_copy_project(
    source, file.path(suite, paste0("case-", name)), paste0(name, "-project")
  )
  mutate(project, materialization_current_paths(project))
  materialization_failure(
    rrp_open_product_access(catalog, project), expected
  )
  invisible(project)
}

arguments <- commandArgs(trailingOnly = TRUE)
software_root <- if (length(arguments)) arguments[[1L]] else
  Sys.getenv("RRP_TEST_SOFTWARE_ROOT", unset = "")
stopifnot(nzchar(software_root), dir.exists(software_root))
catalog <- rrp_open_resource_catalog(software_root)
suite <- tempfile("rrp-product-materialization-")
dir.create(suite)
on.exit(unlink(suite, recursive = TRUE, force = TRUE), add = TRUE)

project <- file.path(suite, "fictional-project")
stopifnot(rrp_operation_succeeded(
  rrp_initialize_fictional_project(catalog, project)
))
generator <- new.env(parent = baseenv())
sys.source(file.path(project, "R", "generate-source.R"), generator,
  chdir = FALSE, keep.source = FALSE)
generator$rrp_generate_fictional_source(project)
stopifnot(rrp_operation_succeeded(rrp_initialize_project_state(catalog, project)))
state_root <- file.path(project, "state")
store <- file.path(state_root, "products")
stopifnot(
  !dir.exists(store),
  identical(sort(list.files(state_root), method = "radix"),
    c("history.duckdb", "state.dcf"))
)

first_time <- "2026-01-18T12:00:00Z"
first_run <- rrp_execute_durable_bundle(catalog, project, first_time, "products-one")
stopifnot(rrp_operation_succeeded(first_run))
first_set <- rrp_build_product_set(
  catalog, project, first_run$value$operation_run_id, first_time
)
stopifnot(rrp_operation_succeeded(first_set))

# A failed first publication leaves the optional product directory absent.
first_interruption <- tryCatch({
  materialization_internal("rrp_product_materialize")(
    catalog, project, first_set$value, failure_stage = "after_members"
  )
  NULL
}, rrp_materialization_error = identity)
stopifnot(
  inherits(first_interruption, "rrp_materialization_error"),
  !dir.exists(store),
  rrp_operation_succeeded(rrp_inspect_project_state(catalog, project))
)

first_publication <- rrp_materialize_product_set(catalog, project, first_set$value)
stopifnot(
  rrp_operation_succeeded(first_publication), dir.exists(store),
  identical(first_publication$value$reused, FALSE),
  identical(sort(list.files(store), method = "radix"), c("current.dcf", "sets"))
)
first_id <- first_publication$value$materialization_id
first_directory <- file.path(store, "sets", first_id)
stopifnot(identical(sort(list.files(first_directory), method = "radix"), c(
  "current-remaining-risk.csv", "operational-scope-summary.csv",
  "product-set.dcf", "remaining-risk-trajectory.csv"
)))
pointer <- file.path(store, "current.dcf")
pointer_bytes <- materialization_bytes(pointer)
repeat_publication <- rrp_materialize_product_set(catalog, project, first_set$value)
if (!rrp_operation_succeeded(repeat_publication)) stop(
  "repeat materialization failed: ",
  repeat_publication$diagnostics[[1L]]$code, call. = FALSE
)
stopifnot(
  identical(repeat_publication$value$materialization_id, first_id),
  identical(repeat_publication$value$reused, TRUE),
  identical(materialization_bytes(pointer), pointer_bytes)
)

opened <- rrp_open_product_access(catalog, project)
stopifnot(
  rrp_operation_succeeded(opened),
  identical(opened$value$freshness$status, "not-evaluated"),
  !any(c("path", "connection", "writer") %in% names(opened$value))
)
inventory <- rrp_list_products(opened$value)
stopifnot(
  length(inventory) == 3L,
  identical(vapply(inventory, `[[`, character(1L), "product_id"), c(
    "rrp.product.current-remaining-risk",
    "rrp.product.remaining-risk-trajectory",
    "rrp.product.operational-scope-summary"
  )),
  all(vapply(inventory, `[[`, character(1L), "product_set_id") ==
    first_set$value$product_set_id)
)
for (item in inventory) {
  product <- rrp_read_product(
    opened$value, item$product_id, item$product_version
  )
  metadata <- rrp_read_product(
    opened$value, item$product_id, item$product_version, metadata_only = TRUE
  )
  stopifnot(
    inherits(product, "rrp_logical_product"),
    identical(metadata$product_instance_id, product$product_instance_id),
    !"data" %in% names(metadata)
  )
  product$data <- NULL
  stopifnot(!is.null(rrp_read_product(
    opened$value, item$product_id, item$product_version
  )$data))
}
typed <- tryCatch({
  rrp_read_product(opened$value, "missing.product", "0.1.0"); NULL
}, rrp_product_access_error = identity)
stopifnot(
  inherits(typed, "rrp_product_access_error"),
  identical(typed$code, "product_access_failed"), identical(typed$call, NULL)
)

# A later cutoff with unchanged governed facts is fresh; the cutoff itself is
# lineage, not a staleness trigger.
fresh <- rrp_open_product_access(
  catalog, project, first_run$value$operation_run_id, "2026-01-20T12:00:00Z"
)
stopifnot(
  rrp_operation_succeeded(fresh), identical(fresh$value$freshness$status, "fresh")
)
materialization_failure(
  rrp_open_product_access(catalog, project, first_run$value$operation_run_id),
  "product_access_failed"
)

second_time <- "2026-01-20T12:00:00Z"
second_run <- rrp_execute_durable_bundle(
  catalog, project, second_time, "products-two"
)
stopifnot(rrp_operation_succeeded(second_run))
stale <- rrp_open_product_access(
  catalog, project, second_run$value$operation_run_id, second_time
)
stopifnot(
  rrp_operation_succeeded(stale), identical(stale$value$freshness$status, "stale"),
  identical(rrp_list_products(stale$value)[[1L]]$freshness$status, "stale")
)
second_set <- rrp_build_product_set(
  catalog, project, second_run$value$operation_run_id, second_time
)
stopifnot(rrp_operation_succeeded(second_set))
second_publication <- rrp_materialize_product_set(catalog, project, second_set$value)
second_id <- second_publication$value$materialization_id
stopifnot(
  rrp_operation_succeeded(second_publication), !identical(second_id, first_id),
  dir.exists(first_directory), dir.exists(file.path(store, "sets", second_id)),
  identical(rrp_open_product_access(catalog, project)$value$product_set_id,
    second_set$value$product_set_id)
)

# Every meaningful publication interruption leaves the prior current pointer
# intact. A deliberately retained owned staging orphan remains non-current,
# readers ignore it, and the next materialization removes it.
failure_stages <- c(
  "after_members", "after_manifest", "after_stage_validation",
  "after_set_promotion", "before_pointer_replace", "after_pointer_replace"
)
third_sets <- lapply(seq_along(failure_stages), function(index) {
  value <- rrp_build_product_set(
    catalog, project, second_run$value$operation_run_id,
    sprintf("2026-01-20T13:%02d:00Z", index - 1L)
  )
  stopifnot(rrp_operation_succeeded(value))
  value$value
})
pointer_before_failure <- materialization_bytes(pointer)
for (index in seq_along(failure_stages)) {
  interrupted <- tryCatch({
    materialization_internal("rrp_product_materialize")(
      catalog, project, third_sets[[index]],
      failure_stage = failure_stages[[index]],
      preserve_staging = identical(failure_stages[[index]], "after_members")
    ); NULL
  }, rrp_materialization_error = identity)
  stopifnot(
    inherits(interrupted, "rrp_materialization_error"),
    identical(materialization_bytes(pointer), pointer_before_failure),
    identical(rrp_open_product_access(catalog, project)$value$product_set_id,
      second_set$value$product_set_id)
  )
  if (index == 1L) stopifnot(any(startsWith(
    list.files(file.path(store, "sets"), all.files = TRUE, no.. = TRUE),
    ".rrp-product-staging-"
  )))
}
staging_names <- list.files(file.path(store, "sets"), all.files = TRUE,
  no.. = TRUE)
stopifnot(!any(startsWith(staging_names, ".rrp-product-staging-")))
third_set <- list(value = third_sets[[length(third_sets)]])
third_publication <- rrp_materialize_product_set(catalog, project, third_set$value)
stopifnot(
  rrp_operation_succeeded(third_publication),
  !any(startsWith(list.files(file.path(store, "sets"), all.files = TRUE,
    no.. = TRUE), ".rrp-product-staging-"))
)

# Full project copying carries products without embedding the original path.
copied <- materialization_copy_project(project, file.path(suite, "copy"), "copied")
copied_access <- rrp_open_product_access(catalog, copied)
stopifnot(
  rrp_operation_succeeded(copied_access),
  identical(copied_access$value$product_set_id, third_set$value$product_set_id),
  !grepl(project, paste(capture.output(str(copied_access)), collapse = " "),
    fixed = TRUE)
)

# Corruption and prohibited extras fail closed without exposing rows or paths.
materialization_corruption_case(project, suite, "missing-member",
  function(project, paths) unlink(file.path(
    paths$set, "current-remaining-risk.csv"
  )), "product_access_failed")
materialization_corruption_case(project, suite, "extra-member",
  function(project, paths) writeLines(
    "unexpected", file.path(paths$set, "unexpected.csv")
  ), "product_access_failed")
materialization_corruption_case(project, suite, "altered-bytes",
  function(project, paths) {
    member <- file.path(paths$set, "current-remaining-risk.csv")
    writeBin(c(materialization_bytes(member), charToRaw("altered")), member)
  }, "product_integrity_failed")
materialization_corruption_case(project, suite, "wrong-size",
  function(project, paths) {
    manifest <- materialization_read_dcf(paths$manifest_path)
    manifest[["Current-Remaining-Risk-Byte-Size"]] <- "1"
    materialization_write_dcf(manifest, paths$manifest_path)
    materialization_refresh_pointer(paths)
  }, "product_integrity_failed")
materialization_corruption_case(project, suite, "wrong-md5",
  function(project, paths) {
    manifest <- materialization_read_dcf(paths$manifest_path)
    manifest[["Current-Remaining-Risk-MD5"]] <- paste(rep("0", 32L),
      collapse = "")
    materialization_write_dcf(manifest, paths$manifest_path)
    materialization_refresh_pointer(paths)
  }, "product_integrity_failed")
materialization_corruption_case(project, suite, "malformed-csv",
  function(project, paths) {
    member <- file.path(paths$set, "current-remaining-risk.csv")
    writeLines('"not","the","schema"', member, useBytes = TRUE)
    materialization_refresh_member(
      paths, "Current-Remaining-Risk", "current-remaining-risk.csv"
    )
  }, "product_integrity_failed")
materialization_corruption_case(project, suite, "malformed-dcf",
  function(project, paths) writeLines(
    "not valid DCF", paths$pointer_path, useBytes = TRUE
  ), "product_access_failed")
materialization_corruption_case(project, suite, "incompatible-authority",
  function(project, paths) {
    pointer <- materialization_read_dcf(paths$pointer_path)
    pointer[["Materialization-Contract-Version"]] <- "9.9.9"
    materialization_write_dcf(pointer, paths$pointer_path)
  }, "product_materialization_incompatible")
materialization_corruption_case(project, suite, "wrong-product-contract",
  function(project, paths) {
    manifest <- materialization_read_dcf(paths$manifest_path)
    manifest[["Current-Remaining-Risk-Product-Contract-Version"]] <- "9.9.9"
    materialization_write_dcf(manifest, paths$manifest_path)
    materialization_refresh_pointer(paths)
  }, "product_materialization_incompatible")
materialization_corruption_case(project, suite, "wrong-member-identity",
  function(project, paths) {
    manifest <- materialization_read_dcf(paths$manifest_path)
    manifest[["Current-Remaining-Risk-Product-Instance-ID"]] <-
      "rrp.product.0000000000000000"
    materialization_write_dcf(manifest, paths$manifest_path)
    materialization_refresh_pointer(paths)
  }, "product_integrity_failed")
materialization_corruption_case(project, suite, "manifest-member-disagreement",
  function(project, paths) {
    manifest <- materialization_read_dcf(paths$manifest_path)
    manifest[["Current-Remaining-Risk-Row-Count"]] <- "999"
    materialization_write_dcf(manifest, paths$manifest_path)
    materialization_refresh_pointer(paths)
  }, "product_integrity_failed")
materialization_corruption_case(project, suite, "semantic-conformance",
  function(project, paths) {
    member_path <- file.path(paths$set, "current-remaining-risk.csv")
    member <- read.csv(member_path, stringsAsFactors = FALSE,
      check.names = FALSE, na.strings = "", colClasses = "character")
    member$estimate_value <- as.double(member$estimate_value)
    if (nrow(member)) member$estimate_value[[1L]] <- 2
    utils::write.table(member, member_path, sep = ",", row.names = FALSE,
      col.names = TRUE, quote = TRUE, qmethod = "double", na = "", eol = "\n")
    materialization_refresh_member(
      paths, "Current-Remaining-Risk", "current-remaining-risk.csv"
    )
  }, "product_integrity_failed")

# A pre-existing immutable identity with conflicting bytes is never repaired or
# overwritten, and the current pointer remains unchanged.
conflict <- materialization_copy_project(project, file.path(suite, "conflict"),
  "conflict-project")
target_set <- third_sets[[4L]]
set_roots <- list.dirs(file.path(conflict, "state", "products", "sets"),
  recursive = FALSE, full.names = TRUE)
target_root <- Filter(function(path) identical(
  materialization_read_dcf(file.path(path, "product-set.dcf"))[["Product-Set-ID"]],
  target_set$product_set_id
), set_roots)
stopifnot(length(target_root) == 1L)
conflict_member <- file.path(target_root[[1L]], "current-remaining-risk.csv")
writeBin(c(materialization_bytes(conflict_member), charToRaw("conflict")),
  conflict_member)
conflict_pointer <- materialization_bytes(file.path(
  conflict, "state", "products", "current.dcf"
))
conflicting <- rrp_materialize_product_set(catalog, conflict, target_set)
materialization_failure(conflicting, "product_integrity_failed")
stopifnot(identical(materialization_bytes(file.path(
  conflict, "state", "products", "current.dcf"
)), conflict_pointer))

# Authoritative backup excludes products. Restore creates only core state;
# history can rebuild and rematerialize the same logical set.
history_before <- unname(tools::md5sum(file.path(state_root, "history.duckdb")))
backup_path <- file.path(suite, "history-backup")
backup <- rrp_backup_project_state(catalog, project, backup_path)
stopifnot(
  rrp_operation_succeeded(backup),
  identical(sort(list.files(backup_path), method = "radix"),
    c("backup.dcf", "history.duckdb")),
  !dir.exists(file.path(backup_path, "products"))
)
restored <- materialization_copy_project(project, file.path(suite, "restore"),
  "restored-project")
unlink(file.path(restored, "state"), recursive = TRUE, force = TRUE)
stopifnot(rrp_operation_succeeded(
  rrp_restore_project_state(catalog, restored, backup_path)
))
stopifnot(!dir.exists(file.path(restored, "state", "products")))
rebuilt <- rrp_build_product_set(
  catalog, restored, second_run$value$operation_run_id, second_time
)
stopifnot(
  rrp_operation_succeeded(rebuilt),
  rrp_operation_succeeded(rrp_materialize_product_set(
    catalog, restored, rebuilt$value
  )),
  rrp_operation_succeeded(rrp_open_product_access(catalog, restored))
)

# Derived product deletion does not alter history and the store is rebuildable.
unlink(store, recursive = TRUE, force = TRUE)
stopifnot(
  identical(unname(tools::md5sum(file.path(state_root, "history.duckdb"))),
    history_before),
  !rrp_operation_succeeded(rrp_open_product_access(catalog, project)),
  rrp_operation_succeeded(rrp_materialize_product_set(
    catalog, project, third_set$value
  )),
  identical(unname(tools::md5sum(file.path(state_root, "history.duckdb"))),
    history_before)
)

# A later correction to the same explicit source scope changes the effective
# source fingerprint and makes the intact current set stale, not corrupt.
scope_history <- rrp_inspect_scope_history(
  catalog, project, second_run$value$operation_run_id
)
stopifnot(rrp_operation_succeeded(scope_history))
accepted <- Filter(function(value) {
  identical(value$analytical_kind, "initial") &&
    identical(value$outcome, "accepted_estimate")
}, scope_history$value$dispositions)
stopifnot(length(accepted) >= 1L)
corrected <- rrp_invalidate_history(
  catalog, project, "analytical_run", second_run$value$operation_run_id,
  accepted[[1L]]$analytical_run_id, "2026-01-20T14:00:00Z",
  "superseded_result", "maintainer"
)
stopifnot(rrp_operation_succeeded(corrected))
changed_source <- rrp_open_product_access(
  catalog, project, second_run$value$operation_run_id,
  "2026-01-20T14:00:00Z"
)
stopifnot(
  rrp_operation_succeeded(changed_source),
  identical(changed_source$value$freshness$status, "stale"),
  !is.null(rrp_read_product(
    changed_source$value,
    "rrp.product.operational-scope-summary", "0.1.0"
  )$data)
)

# Unsupported pre-0.2 development state is rejected rather than migrated.
old_state <- materialization_copy_project(project, file.path(suite, "old-state"),
  "old-state-project")
metadata_path <- file.path(old_state, "state", "state.dcf")
metadata <- readLines(metadata_path, warn = FALSE)
metadata <- sub("^State-Contract-Version: 0[.]2[.]0$",
  "State-Contract-Version: 0.1.0", metadata)
writeLines(metadata, metadata_path, useBytes = TRUE)
old_result <- rrp_inspect_project_state(catalog, old_state)
stopifnot(
  !rrp_operation_succeeded(old_result),
  identical(old_result$diagnostics[[1L]]$code, "state_incompatible")
)

# No prohibited private fixture markers occur in the materialized bytes.
materialized_files <- list.files(store, recursive = TRUE, full.names = TRUE,
  include.dirs = FALSE)
materialized_text <- paste(unlist(lapply(materialized_files, function(path) {
  readLines(path, warn = FALSE, encoding = "UTF-8")
})), collapse = "\n")
stopifnot(!grepl(
  "FIC STAY|FIC PERSON|FIC ENCOUNTER|provider_signal|identity-crosswalk|source/generated",
  materialized_text, ignore.case = TRUE
))

cat("rrpplatform product materialization tests passed\n")
