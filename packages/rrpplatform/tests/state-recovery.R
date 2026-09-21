library(rrpplatform)

recovery_internal <- function(name) {
  get(name, envir = asNamespace("rrpplatform"), inherits = FALSE)
}

recovery_load_helpers <- function(path) {
  expressions <- parse(path)
  for (expression in expressions[-length(expressions)]) {
    eval(expression, envir = .GlobalEnv)
  }
}

recovery_copy_project_without_state <- function(source, destination) {
  dir.create(destination, recursive = TRUE)
  dir.create(file.path(destination, "R"))
  stopifnot(file.copy(
    file.path(source, "rrp-project.dcf"), destination,
    copy.mode = FALSE, copy.date = FALSE
  ))
  stopifnot(file.copy(
    file.path(source, "R", "register.R"), file.path(destination, "R"),
    copy.mode = FALSE, copy.date = FALSE
  ))
  destination
}

recovery_copy_backup <- function(source, parent, name) {
  dir.create(parent, recursive = TRUE, showWarnings = FALSE)
  stopifnot(file.copy(
    source, parent, recursive = TRUE, copy.mode = FALSE, copy.date = FALSE
  ))
  copied <- file.path(parent, basename(source))
  target <- file.path(parent, name)
  stopifnot(file.rename(copied, target))
  target
}

recovery_failure <- function(result, operation, code) {
  stopifnot(
    identical(result$operation_id, operation),
    identical(result$status, "failure"), is.null(result$value),
    length(result$diagnostics) == 1L,
    identical(result$diagnostics[[1L]]$code, code),
    !grepl("[/\\]", result$diagnostics[[1L]]$message)
  )
  invisible(result)
}

recovery_restate_one <- function(catalog, project, scope, effective_time) {
  accepted <- Filter(function(value) {
    identical(value$outcome, "accepted_estimate") &&
      identical(value$analytical_kind, "initial")
  }, scope$dispositions)[[1L]]
  fields <- c(
    "analytical_kind", "related_analytical_run_id", "analytical_key",
    "episode_id", "patient_id", "target_id", "target_version",
    "analytical_time", "outcome", "outcome_code", "eligibility_status",
    "state", "request", "provider_id", "provider_version",
    "implementation_id", "implementation_version", "model_id",
    "model_version", "provider_status", "estimate", "terminal_time"
  )
  values <- accepted[fields]
  values$analytical_kind <- "restatement"
  values$related_analytical_run_id <- accepted$analytical_run_id
  values$analytical_key <- "backup-correction"
  replacement <- rrpruntime::rrp_new_episode_disposition(scope$scope, values)
  result <- rrp_restate_history(
    catalog, project, "analytical_run", scope$scope$operation_run_id,
    accepted$analytical_run_id, replacement, effective_time,
    "superseded_result", "maintainer"
  )
  durable_success(result, "rrp.restate-history")
  replacement
}

local({
  arguments <- commandArgs(trailingOnly = TRUE)
  helper_root <- if (length(arguments) >= 2L) arguments[[2L]] else "."
  recovery_load_helpers(file.path(helper_root, "project-state.R"))
  recovery_load_helpers(file.path(helper_root, "durable-history.R"))
  software_root <- if (length(arguments) && nzchar(arguments[[1L]])) {
    normalizePath(arguments[[1L]], winslash = "/", mustWork = TRUE)
  } else {
    fixture <- tempfile("rrp-recovery-resources-")
    dir.create(fixture)
    on.exit(unlink(fixture, recursive = TRUE, force = TRUE), add = TRUE)
    state_software_root(file.path(fixture, "software"))
  }
  catalog <- rrp_open_resource_catalog(software_root)
  suite <- tempfile("rrp-state-recovery-")
  dir.create(suite)
  on.exit(unlink(suite, recursive = TRUE, force = TRUE), add = TRUE)
  as_of <- "2026-02-10T12:00:00Z"
  target <- "rrp.risk-target.readmission-remaining-30-day"

  # Empty initialized state is a valid backup and restore source.
  seed <- durable_write_project(file.path(suite, "seed"), "fictional-recovery")
  durable_success(rrp_initialize_project_state(catalog, seed),
    "rrp.initialize-project-state")
  seed_files <- sort(list.files(
    seed, recursive = TRUE, all.files = TRUE, no.. = TRUE,
    full.names = FALSE
  ), method = "radix")
  empty_backup <- file.path(suite, "empty-backup")
  backup <- rrp_backup_project_state(catalog, seed, empty_backup)
  durable_success(backup, "rrp.backup-project-state")
  stopifnot(
    identical(backup$value$backup_status, "created"),
    identical(backup$value$project_id, "fictional-recovery"),
    identical(sort(list.files(
      empty_backup, recursive = TRUE, all.files = TRUE, no.. = TRUE,
      full.names = FALSE
    ), method = "radix"), c("backup.dcf", "history.duckdb")),
    identical(sort(list.files(
      seed, recursive = TRUE, all.files = TRUE, no.. = TRUE,
      full.names = FALSE
    ), method = "radix"), seed_files)
  )
  recovery_failure(
    rrp_backup_project_state(catalog, seed, empty_backup),
    "rrp.backup-project-state", "backup_destination_exists"
  )
  stopifnot(rrp_operation_succeeded(rrp_inspect_project_state(catalog, seed)))

  path_a <- recovery_copy_project_without_state(
    seed, file.path(suite, "uninterrupted")
  )
  path_b <- recovery_copy_project_without_state(
    seed, file.path(suite, "interrupted")
  )
  durable_success(rrp_restore_project_state(catalog, path_a, empty_backup),
    "rrp.restore-project-state")
  durable_success(rrp_restore_project_state(catalog, path_b, empty_backup),
    "rrp.restore-project-state")
  recovery_failure(
    rrp_restore_project_state(catalog, path_a, empty_backup),
    "rrp.restore-project-state", "restore_destination_exists"
  )

  # Backups preserve the transaction boundary, not an inferred lifecycle flag.
  precommit <- recovery_copy_project_without_state(
    seed, file.path(suite, "precommit")
  )
  durable_success(rrp_restore_project_state(catalog, precommit, empty_backup),
    "rrp.restore-project-state")
  state_id <- rrp_inspect_project_state(catalog, precommit)$value$state_id
  boundary_scope <- state_scope(
    state_id, "transaction-boundary", "episode-boundary",
    project_id = "fictional-recovery"
  )
  condition <- tryCatch({
    rrpruntime::rrp_history_append_scope(
      recovery_internal("rrp_state_history_port")(
        catalog, precommit, "before_commit"
      ), boundary_scope
    )
    NULL
  }, rrp_state_error = identity)
  stopifnot(identical(condition$code, "injected_interruption"))
  precommit_backup <- file.path(suite, "precommit-backup")
  durable_success(
    rrp_backup_project_state(catalog, precommit, precommit_backup),
    "rrp.backup-project-state"
  )
  precommit_restored <- recovery_copy_project_without_state(
    seed, file.path(suite, "precommit-restored")
  )
  durable_success(
    rrp_restore_project_state(catalog, precommit_restored, precommit_backup),
    "rrp.restore-project-state"
  )
  missing_scope <- rrp_inspect_scope_history(
    catalog, precommit_restored, boundary_scope$operation_run_id
  )
  stopifnot(
    !rrp_operation_succeeded(missing_scope),
    identical(missing_scope$diagnostics[[1L]]$code, "invalid_read")
  )

  postcommit <- recovery_copy_project_without_state(
    seed, file.path(suite, "postcommit")
  )
  durable_success(rrp_restore_project_state(catalog, postcommit, empty_backup),
    "rrp.restore-project-state")
  condition <- tryCatch({
    rrpruntime::rrp_history_append_scope(
      recovery_internal("rrp_state_history_port")(
        catalog, postcommit, "after_commit"
      ), boundary_scope
    )
    NULL
  }, rrp_state_error = identity)
  stopifnot(identical(condition$code, "injected_interruption"))
  postcommit_backup <- file.path(suite, "postcommit-backup")
  durable_success(
    rrp_backup_project_state(catalog, postcommit, postcommit_backup),
    "rrp.backup-project-state"
  )
  postcommit_restored <- recovery_copy_project_without_state(
    seed, file.path(suite, "postcommit-restored")
  )
  durable_success(
    rrp_restore_project_state(catalog, postcommit_restored, postcommit_backup),
    "rrp.restore-project-state"
  )
  present_scope <- rrp_inspect_scope_history(
    catalog, postcommit_restored, boundary_scope$operation_run_id
  )
  durable_success(present_scope, "rrp.inspect-scope-history")
  stopifnot(identical(present_scope$value$scope, boundary_scope))
  stopifnot(identical(
    rrpruntime::rrp_history_append_scope(
      recovery_internal("rrp_state_history_port")(
        catalog, postcommit_restored
      ), boundary_scope
    ), invisible(boundary_scope)
  ))

  # Path A completes normally from the shared restored state identity.
  complete <- rrp_execute_durable_bundle(
    catalog, path_a, as_of, "recovery-operation"
  )
  durable_success(complete, "rrp.execute-durable-bundle")
  complete_history <- rrp_inspect_scope_history(
    catalog, path_a, complete$value$operation_run_id
  )
  durable_success(complete_history, "rrp.inspect-scope-history")

  # Path B commits two dispositions, backs up incomplete history, and restores.
  engine <- recovery_internal("rrp_durable_execute")
  interrupted <- tryCatch({
    engine(catalog, path_b, as_of, "recovery-operation", interrupt_after = 2L)
    NULL
  }, rrp_durable_error = identity)
  stopifnot(identical(interrupted$code, "injected_interruption"))
  partial <- rrp_inspect_scope_history(
    catalog, path_b, complete$value$operation_run_id
  )
  durable_success(partial, "rrp.inspect-scope-history")
  stopifnot(
    !partial$value$progress$complete,
    identical(partial$value$progress$dispositioned_episode_count, 2L)
  )
  partial_backup <- file.path(suite, "partial-backup")
  durable_success(
    rrp_backup_project_state(catalog, path_b, partial_backup),
    "rrp.backup-project-state"
  )
  recovered <- recovery_copy_project_without_state(
    seed, file.path(suite, "recovered")
  )
  durable_success(
    rrp_restore_project_state(catalog, recovered, partial_backup),
    "rrp.restore-project-state"
  )
  restored_partial <- rrp_inspect_scope_history(
    catalog, recovered, complete$value$operation_run_id
  )
  stopifnot(identical(restored_partial$value, partial$value))

  # A fresh process uses ordinary 7.C continuation and cannot recall commits.
  writeLines("enabled", file.path(recovered, "forbid-committed"))
  package_libraries <- paste(vapply(
    .libPaths(), encodeString, character(1L), quote = "\""
  ), collapse = ", ")
  continuation_script <- file.path(suite, "continue-restored.R")
  continuation_result <- file.path(suite, "continued.rds")
  continuation_output <- file.path(suite, "continued-output")
  writeLines(c(
    paste0(".libPaths(c(", package_libraries, "))"),
    "args <- commandArgs(trailingOnly = TRUE)",
    "library(rrpplatform)",
    "catalog <- rrp_open_resource_catalog(args[[1L]])",
    "value <- rrp_execute_durable_bundle(catalog, args[[2L]], args[[3L]], args[[4L]])",
    "stopifnot(rrp_operation_succeeded(value), isTRUE(value$value$complete))",
    "saveRDS(value, args[[5L]])"
  ), continuation_script, useBytes = TRUE)
  status <- system2(
    file.path(R.home("bin"), "Rscript"),
    c(
      "--vanilla", shQuote(continuation_script), shQuote(software_root),
      shQuote(recovered), shQuote(as_of), shQuote("recovery-operation"),
      shQuote(continuation_result)
    ), stdout = continuation_output, stderr = continuation_output,
    env = "R_TESTS="
  )
  if (!identical(status, 0L)) stop(
    "Fresh-process recovery continuation failed: ",
    paste(readLines(continuation_output, warn = FALSE), collapse = "\n"),
    call. = FALSE
  )
  continued <- readRDS(continuation_result)
  durable_success(continued, "rrp.execute-durable-bundle")
  recovered_history <- rrp_inspect_scope_history(
    catalog, recovered, complete$value$operation_run_id
  )
  stopifnot(identical(recovered_history$value, complete_history$value))

  # Complete nontrivial history includes retry, action, and restatement.
  detected <- Filter(function(value) {
    identical(value$episode_id, "episode-detected")
  }, recovered_history$value$dispositions)[[1L]]
  writeLines("enabled", file.path(recovered, "retry-ok"))
  retry <- rrp_retry_episode(
    catalog, recovered, complete$value$operation_run_id,
    detected$analytical_run_id, "backup-retry"
  )
  durable_success(retry, "rrp.retry-episode")
  unlink(file.path(recovered, "retry-ok"))
  invalidated <- rrp_invalidate_history(
    catalog, recovered, "analytical_run", complete$value$operation_run_id,
    retry$value$analytical_run_id, as_of, "superseded_result", "operator"
  )
  durable_success(invalidated, "rrp.invalidate-history")
  before_restatement <- rrp_inspect_scope_history(
    catalog, recovered, complete$value$operation_run_id
  )$value
  recovery_restate_one(catalog, recovered, before_restatement, as_of)
  rich_history <- rrp_inspect_scope_history(
    catalog, recovered, complete$value$operation_run_id
  )
  rich_episode <- rrp_inspect_episode_history(
    catalog, recovered, "episode-detected", target, as_of
  )
  rich_current <- rrp_inspect_current_history(
    catalog, recovered, "episode-accepted", target, as_of, as_of
  )
  rich_backup <- file.path(suite, "rich-backup")
  durable_success(rrp_backup_project_state(catalog, recovered, rich_backup),
    "rrp.backup-project-state")
  rich_destination <- recovery_copy_project_without_state(
    seed, file.path(suite, "rich-restored")
  )
  durable_success(
    rrp_restore_project_state(catalog, rich_destination, rich_backup),
    "rrp.restore-project-state"
  )
  stopifnot(
    identical(rrp_inspect_scope_history(
      catalog, rich_destination, complete$value$operation_run_id
    )$value, rich_history$value),
    identical(rrp_inspect_episode_history(
      catalog, rich_destination, "episode-detected", target, as_of
    )$value, rich_episode$value),
    identical(rrp_inspect_current_history(
      catalog, rich_destination, "episode-accepted", target, as_of, as_of
    )$value, rich_current$value)
  )

  # Interrupted backup/restore cleanup preserves source and absent destination.
  source_before <- rich_history$value
  interrupted_backup <- file.path(suite, "interrupted-backup")
  condition <- tryCatch({
    recovery_internal("rrp_state_backup")(
      catalog, recovered, interrupted_backup, "after_checkpoint"
    )
    NULL
  }, rrp_state_error = identity)
  stopifnot(
    identical(condition$code, "injected_interruption"),
    !file.exists(interrupted_backup), !dir.exists(interrupted_backup),
    identical(rrp_inspect_scope_history(
      catalog, recovered, complete$value$operation_run_id
    )$value, source_before)
  )
  interrupted_restore <- recovery_copy_project_without_state(
    seed, file.path(suite, "interrupted-restore")
  )
  condition <- tryCatch({
    recovery_internal("rrp_state_restore")(
      catalog, interrupted_restore, rich_backup, "after_promotion"
    )
    NULL
  }, rrp_state_error = identity)
  stopifnot(
    identical(condition$code, "injected_interruption"),
    !dir.exists(file.path(interrupted_restore, "state"))
  )

  # Invalid artifacts fail closed and never create destination state.
  invalid_cases <- list(
    missing_manifest = function(path) unlink(file.path(path, "backup.dcf")),
    unknown_file = function(path) writeLines("unknown", file.path(path, "extra")),
    missing_database = function(path) unlink(file.path(path, "history.duckdb")),
    malformed_manifest = function(path) writeLines("not dcf", file.path(path, "backup.dcf")),
    incompatible_manifest = function(path) {
      lines <- readLines(file.path(path, "backup.dcf"), warn = FALSE)
      lines[grepl("^Adapter-Version:", lines)] <- "Adapter-Version: 9.9.9"
      writeLines(lines, file.path(path, "backup.dcf"), useBytes = TRUE)
    },
    payload_size_mismatch = function(path) {
      lines <- readLines(file.path(path, "backup.dcf"), warn = FALSE)
      lines[grepl("^Payload-Size:", lines)] <- "Payload-Size: 1"
      writeLines(lines, file.path(path, "backup.dcf"), useBytes = TRUE)
    },
    invalid_metadata = function(path) {
      database <- file.path(path, "history.duckdb")
      connection <- DBI::dbConnect(duckdb::duckdb(database))
      on.exit(DBI::dbDisconnect(connection, shutdown = TRUE), add = TRUE)
      row <- DBI::dbGetQuery(
        connection,
        "SELECT payload_hex FROM rrp_state_metadata WHERE metadata_key = 'project_state'"
      )
      metadata <- recovery_internal("rrp_duckdb_payload_decode")(
        row$payload_hex[[1L]]
      )
      metadata[["Project-ID"]] <- "wrong-project"
      DBI::dbExecute(
        connection,
        paste(
          "UPDATE rrp_state_metadata SET project_id = ?, payload_hex = ?",
          "WHERE metadata_key = 'project_state'"
        ),
        params = list(
          "wrong-project",
          recovery_internal("rrp_duckdb_payload_encode")(metadata)
        )
      )
    },
    corrupt_database = function(path) writeBin(
      charToRaw("not-a-duckdb-database"),
      file.path(path, "history.duckdb")
    )
  )
  for (name in names(invalid_cases)) {
    artifact <- recovery_copy_backup(
      rich_backup, file.path(suite, paste0("invalid-", name)), "artifact"
    )
    invalid_cases[[name]](artifact)
    destination <- recovery_copy_project_without_state(
      seed, file.path(suite, paste0("destination-", name))
    )
    result <- rrp_restore_project_state(catalog, destination, artifact)
    stopifnot(
      !rrp_operation_succeeded(result),
      result$diagnostics[[1L]]$code %in% c("backup_invalid", "backup_incompatible"),
      !dir.exists(file.path(destination, "state"))
    )
  }

  # Same files are incompatible with a different project identity.
  other <- durable_write_project(file.path(suite, "other"), "other-project")
  recovery_failure(
    rrp_restore_project_state(catalog, other, rich_backup),
    "rrp.restore-project-state", "backup_incompatible"
  )
  stopifnot(!dir.exists(file.path(other, "state")))

  # A separate active writer produces a bounded failure and leaves source usable.
  if (identical(.Platform$OS.type, "unix")) {
    holder_script <- file.path(suite, "hold-recovery-duckdb.R")
    marker <- file.path(suite, "holder-ready")
    release <- file.path(suite, "holder-release")
    holder_output <- file.path(suite, "holder-output")
    writeLines(c(
      paste0(".libPaths(c(", package_libraries, "))"),
      "args <- commandArgs(trailingOnly = TRUE)",
      "connection <- DBI::dbConnect(duckdb::duckdb(args[[1L]]))",
      "writeLines(as.character(Sys.getpid()), args[[2L]])",
      "for (attempt in seq_len(400L)) { if (file.exists(args[[3L]])) break; Sys.sleep(0.05) }",
      "DBI::dbDisconnect(connection, shutdown = TRUE)"
    ), holder_script, useBytes = TRUE)
    system2(
      file.path(R.home("bin"), "Rscript"),
      c(
        "--vanilla", shQuote(holder_script),
        shQuote(file.path(recovered, "state", "history.duckdb")),
        shQuote(marker), shQuote(release)
      ), stdout = holder_output, stderr = holder_output, wait = FALSE,
      env = "R_TESTS="
    )
    for (attempt in seq_len(400L)) {
      if (file.exists(marker)) break
      Sys.sleep(0.05)
    }
    stopifnot(file.exists(marker))
    contention_backup <- file.path(suite, "contention-backup")
    recovery_failure(
      rrp_backup_project_state(catalog, recovered, contention_backup),
      "rrp.backup-project-state", "state_unavailable"
    )
    stopifnot(!dir.exists(contention_backup))
    writeLines("release", release)
    for (attempt in seq_len(400L)) {
      result <- rrp_inspect_project_state(catalog, recovered)
      if (rrp_operation_succeeded(result)) break
      Sys.sleep(0.05)
    }
    stopifnot(rrp_operation_succeeded(result))
  }
})
