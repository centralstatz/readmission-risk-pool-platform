library(rrpplatform)

internal <- function(name) getFromNamespace(name, "rrpplatform")
arguments <- commandArgs(trailingOnly = TRUE)
software_root <- Sys.getenv("RRP_TEST_SOFTWARE_ROOT", unset = "")
if (length(arguments) >= 1L) software_root <- arguments[[1L]]
stopifnot(nzchar(software_root), dir.exists(software_root))
software_root <- normalizePath(software_root, winslash = "/", mustWork = TRUE)

expect_usage <- function(expression, code) {
  condition <- tryCatch({
    force(expression)
    NULL
  }, rrp_cli_usage_error = identity)
  stopifnot(inherits(condition, "rrp_cli_usage_error"),
    identical(condition$code, code))
}

# The parser exposes the accepted command table without discovering projects.
parse_root <- tempfile("rrp-cli-project-parse-")
dir.create(parse_root)
on.exit(unlink(parse_root, recursive = TRUE, force = TRUE), add = TRUE)
existing <- file.path(parse_root, "existing")
dir.create(existing)
commands <- list(
  internal("rrp_cli_parse")(c(
    "project", "init", "new", "--project-id", "example-project",
    "--project-version", "1.0.0"
  ), parse_root),
  internal("rrp_cli_parse")(c("reference", "init", "reference"), parse_root),
  internal("rrp_cli_parse")(c(
    "reference", "prepare-source", "--project", existing
  ), parse_root),
  internal("rrp_cli_parse")(c("project", "validate"), existing),
  internal("rrp_cli_parse")(c("project", "doctor"), existing),
  internal("rrp_cli_parse")(c("project", "status"), existing),
  internal("rrp_cli_parse")(c("state", "init"), existing),
  internal("rrp_cli_parse")(c("state", "inspect"), existing),
  internal("rrp_cli_parse")(c("state", "backup", "backup"), existing),
  internal("rrp_cli_parse")(c(
    "run", "--at", "2026-01-20T12:00:00Z", "--operation-key", "daily-one"
  ), existing),
  internal("rrp_cli_parse")(c(
    "history", "scope", "--scope", "rrp.operation-run.0123456789abcdef"
  ), existing),
  internal("rrp_cli_parse")(c(
    "history", "episode", "--episode", "episode-one", "--target",
    "rrp.risk-target.readmission-remaining-30-day", "--cutoff",
    "2026-01-20T12:00:00Z"
  ), existing),
  internal("rrp_cli_parse")(c(
    "history", "current", "--episode", "episode-one", "--target",
    "rrp.risk-target.readmission-remaining-30-day", "--at",
    "2026-01-20T12:00:00Z", "--cutoff", "2026-01-20T12:00:00Z"
  ), existing),
  internal("rrp_cli_parse")(c(
    "products", "materialize", "--scope",
    "rrp.operation-run.0123456789abcdef", "--cutoff",
    "2026-01-20T12:00:00Z"
  ), existing),
  internal("rrp_cli_parse")(c("products", "status"), existing),
  internal("rrp_cli_parse")(c("app", "launch", "--port", "4545"), existing)
)
stopifnot(identical(vapply(commands, `[[`, character(1L), "command"), c(
  "project_init", "reference_init", "reference_prepare_source",
  "project_validate", "project_doctor", "project_status", "state_init",
  "state_inspect", "state_backup", "run", "history_scope",
  "history_episode", "history_current", "products_materialize",
  "products_status", "app_launch"
)))
expect_usage(
  internal("rrp_cli_parse")(c("project", "init"), parse_root),
  "missing_required_option"
)
expect_usage(
  internal("rrp_cli_parse")(c(
    "products", "status", "--scope", "rrp.operation-run.0123456789abcdef"
  ), existing),
  "paired_options_required"
)
expect_usage(
  internal("rrp_cli_parse")(c(
    "history", "restate", "--target-kind", "analytical_run", "--scope",
    "rrp.operation-run.0123456789abcdef", "--target",
    "rrp.analytical-run.0123456789abcdef", "--replacement-scope",
    "rrp.operation-run.abcdef0123456789", "--effective-at",
    "2026-01-20T12:00:00Z", "--reason", "corrected-result", "--actor",
    "operator"
  ), existing),
  "missing_required_option"
)
stopifnot(
  !internal("rrp_cli_mutation_requires_confirmation")("create_only"),
  !internal("rrp_cli_mutation_requires_confirmation")("append_or_idempotent"),
  internal("rrp_cli_mutation_requires_confirmation")("corrective")
)

# Curated history output retains reusable analytical identities but excludes
# patient, episode, state, request, estimate, and physical-storage content.
disposition <- structure(list(
  record_contract_id = "rrp.history.episode-disposition",
  record_contract_version = "0.1.0", record_id = "rrp.record.example",
  operation_run_id = "rrp.operation-run.0123456789abcdef",
  analytical_run_id = "rrp.analytical-run.0123456789abcdef",
  analytical_kind = "initial", related_analytical_run_id = NULL,
  analytical_key = "initial", episode_id = "private-episode",
  patient_id = "private-patient",
  target_id = "rrp.risk-target.readmission-remaining-30-day",
  target_version = "0.1.0", analytical_time = "2026-01-20T12:00:00Z",
  outcome = "accepted_estimate", outcome_code = "estimate_accepted",
  eligibility_status = "eligible", state = list(private = "value"),
  request = list(private = "value"), provider_id = "provider",
  provider_version = "1.0.0", implementation_id = "implementation",
  implementation_version = "1.0.0", model_id = NULL, model_version = NULL,
  provider_status = "succeeded", provider_execution_id = "execution",
  estimate_record_id = "estimate-record", estimate = list(private = "value"),
  terminal_time = "2026-01-20T12:00:00Z"
), class = c("rrp_episode_disposition", "list"))
raw_episode <- internal("rrp_new_operation_result")(
  "rrp.inspect-episode-history", "success",
  list(scopes = list(), dispositions = list(disposition), actions = list()),
  list()
)
curated_episode <- internal("rrp_cli_curate_result")(raw_episode)
text <- paste(capture.output(str(curated_episode$value)), collapse = " ")
stopifnot(
  identical(curated_episode$value$record_count, 1L),
  identical(
    curated_episode$value$analytical_runs[[1L]]$analytical_run_id,
    disposition$analytical_run_id
  ),
  !grepl("private-episode|private-patient|estimate-record", text),
  !any(c("episode_id", "patient_id", "state", "request", "estimate") %in%
    names(curated_episode$value$analytical_runs[[1L]]))
)

# The optional installed proof exercises all project-facing commands through
# the real launcher and one isolated installed software context.
if (length(arguments) >= 3L) {
  private_library <- normalizePath(arguments[[2L]], winslash = "/", mustWork = TRUE)
  launcher <- normalizePath(arguments[[3L]], winslash = "/", mustWork = TRUE)
  host_r <- normalizePath(file.path(R.home("bin"), "R"), winslash = "/",
    mustWork = TRUE)
  proof <- tempfile("rrp-cli-project-installed-")
  dir.create(proof)
  on.exit(unlink(proof, recursive = TRUE, force = TRUE), add = TRUE)
  unrelated <- file.path(proof, "unrelated")
  dir.create(unrelated)

  tree_evidence <- function(root) {
    files <- sort(list.files(root, recursive = TRUE, all.files = TRUE,
      no.. = TRUE, include.dirs = FALSE, full.names = TRUE), method = "radix")
    values <- unname(tools::md5sum(files))
    names(values) <- substring(files, nchar(root) + 2L)
    values
  }
  run_cli <- function(cli_arguments, directory = unrelated) {
    stdout_path <- tempfile("rrp-cli-project-stdout-")
    stderr_path <- tempfile("rrp-cli-project-stderr-")
    on.exit(unlink(c(stdout_path, stderr_path), force = TRUE), add = TRUE)
    old <- setwd(directory)
    on.exit(setwd(old), add = TRUE)
    status <- system2(
      "/bin/sh", c(shQuote(launcher), vapply(
        cli_arguments, shQuote, character(1L)
      )),
      stdout = stdout_path, stderr = stderr_path,
      env = c(
        paste0("RRP_R_EXECUTABLE=", host_r),
        paste0("RRP_PRIVATE_LIBRARY=", private_library),
        paste0("RRP_SOFTWARE_ROOT=", software_root)
      )
    )
    list(
      status = as.integer(status),
      stdout = readLines(stdout_path, warn = FALSE, encoding = "UTF-8"),
      stderr = readLines(stderr_path, warn = FALSE, encoding = "UTF-8")
    )
  }
  output_text <- function(result) paste(c(result$stdout, result$stderr),
    collapse = "\n")
  json_string <- function(result, field, occurrence = 1L) {
    pattern <- paste0('"', field, '":"([^"]+)"')
    matches <- regmatches(output_text(result), gregexpr(
      pattern, output_text(result), perl = TRUE
    ))[[1L]]
    stopifnot(length(matches) >= occurrence)
    sub(pattern, "\\1", matches[[occurrence]], perl = TRUE)
  }
  copy_project <- function(source, destination) {
    holder <- tempfile("rrp-cli-copy-", tmpdir = proof)
    dir.create(holder)
    stopifnot(file.copy(source, holder, recursive = TRUE,
      copy.mode = FALSE, copy.date = FALSE))
    copied <- file.path(holder, basename(source))
    stopifnot(file.rename(copied, destination))
    unlink(holder, recursive = TRUE, force = TRUE)
    destination
  }

  standard <- file.path(proof, "standard-project")
  standard_init <- run_cli(c(
    "project", "init", standard, "--project-id", "cli-standard-project",
    "--project-version", "1.0.0", "--json"
  ))
  stopifnot(
    identical(standard_init$status, 0L), dir.exists(standard),
    identical(run_cli(c("project", "init", standard, "--project-id",
      "cli-standard-project", "--project-version", "1.0.0"))$status, 2L)
  )
  standard_before <- tree_evidence(standard)
  standard_validate <- run_cli(c("project", "validate", "--project", standard,
    "--json"))
  standard_doctor <- run_cli(c("project", "doctor"), standard)
  standard_status <- run_cli(c("project", "status"), standard)
  stopifnot(
    identical(standard_validate$status, 0L),
    identical(standard_doctor$status, 0L),
    identical(standard_status$status, 0L),
    identical(standard_before, tree_evidence(standard)),
    grepl("project_state_not_initialized", output_text(standard_status), fixed = TRUE)
  )
  child <- file.path(standard, "child")
  dir.create(child)
  stopifnot(identical(run_cli(c("project", "status"), child)$status, 1L))

  reference <- file.path(proof, "reference-project")
  stopifnot(identical(run_cli(c(
    "reference", "init", reference, "--json"
  ))$status, 0L))
  prepared <- run_cli(c(
    "reference", "prepare-source", "--project", reference, "--json"
  ))
  prepared_repeat <- run_cli(c("reference", "prepare-source"), reference)
  stopifnot(
    identical(prepared$status, 0L), identical(prepared_repeat$status, 0L),
    grepl('"reused":false', output_text(prepared), fixed = TRUE),
    grepl("reused: TRUE", output_text(prepared_repeat), fixed = TRUE)
  )
  state_absent <- run_cli(c("state", "inspect", "--project", reference, "--json"))
  initialized <- run_cli(c("state", "init", "--project", reference, "--json"))
  initialized_repeat <- run_cli(c("state", "init"), reference)
  stopifnot(
    identical(state_absent$status, 0L), identical(initialized$status, 0L),
    identical(initialized_repeat$status, 0L),
    grepl('"created":true', output_text(initialized), fixed = TRUE),
    grepl("created: FALSE", output_text(initialized_repeat), fixed = TRUE)
  )

  as_of <- "2026-01-20T12:00:00Z"
  target <- "rrp.risk-target.readmission-remaining-30-day"
  provider_path <- file.path(reference, "R", "calculate-risk.R")
  provider_raw <- readBin(provider_path, "raw", n = file.info(provider_path)$size)
  provider_lines <- readLines(provider_path, warn = FALSE, encoding = "UTF-8")
  provider_lines <- append(provider_lines, c(
    "  if (identical(request$episode_id, 'fictional.episode.001')) {",
    "    return(rrpplatform::rrp_authoring_failure('provider_input_unavailable'))",
    "  }"
  ), after = 4L)
  writeLines(provider_lines, provider_path, useBytes = TRUE)
  first_run <- run_cli(c(
    "run", "--at", as_of, "--operation-key", "cli-first", "--project",
    reference, "--json"
  ))
  if (!identical(first_run$status, 0L)) stop(
    paste0("The first installed CLI run failed:\n", output_text(first_run)),
    call. = FALSE
  )
  stopifnot(identical(first_run$status, 0L))
  first_scope <- json_string(first_run, "operation_run_id")
  first_episode <- run_cli(c(
    "history", "episode", "--episode", "fictional.episode.001", "--target",
    target, "--cutoff", as_of, "--project", reference, "--json"
  ))
  failed_analytical <- json_string(first_episode, "analytical_run_id")
  stopifnot(
    identical(first_episode$status, 0L),
    grepl('"outcome":"provider_declared_failure"', output_text(first_episode),
      fixed = TRUE),
    !grepl("FIC STAY|FIC PERSON|provider_signal", output_text(first_episode))
  )
  writeBin(provider_raw, provider_path, useBytes = TRUE)

  retry_denied <- run_cli(c(
    "history", "retry", "--scope", first_scope, "--analytical-run",
    failed_analytical, "--retry-key", "cli-retry", "--project", reference,
    "--json"
  ))
  retry <- run_cli(c(
    "history", "retry", "--scope", first_scope, "--analytical-run",
    failed_analytical, "--retry-key", "cli-retry", "--project", reference,
    "--yes", "--json"
  ))
  stopifnot(
    identical(retry_denied$status, 1L),
    grepl("confirmation_required", output_text(retry_denied), fixed = TRUE),
    identical(retry$status, 0L)
  )
  retry_analytical <- json_string(retry, "analytical_run_id")
  invalidate_denied <- run_cli(c(
    "history", "invalidate", "--target-kind", "analytical_run", "--scope",
    first_scope, "--target", retry_analytical, "--effective-at", as_of,
    "--reason", "superseded_result", "--actor", "operator", "--project",
    reference, "--json"
  ))
  invalidated <- run_cli(c(
    "history", "invalidate", "--target-kind", "analytical_run", "--scope",
    first_scope, "--target", retry_analytical, "--effective-at", as_of,
    "--reason", "superseded_result", "--actor", "operator", "--project",
    reference, "--yes", "--json"
  ))
  stopifnot(
    identical(invalidate_denied$status, 1L),
    identical(invalidated$status, 0L),
    grepl('"action_id":"rrp.history-action.', output_text(invalidated),
      fixed = TRUE)
  )

  second_run <- run_cli(c(
    "run", "--at", as_of, "--operation-key", "cli-second", "--project",
    reference, "--json"
  ))
  second_scope <- json_string(second_run, "operation_run_id")
  restated <- run_cli(c(
    "history", "restate", "--target-kind", "operational_scope", "--scope",
    first_scope, "--target", first_scope, "--replacement-scope", second_scope,
    "--effective-at", as_of, "--reason", "incorrect_scope", "--actor",
    "maintainer", "--project", reference, "--yes", "--json"
  ))
  stopifnot(
    identical(second_run$status, 0L), identical(restated$status, 0L),
    identical(json_string(restated, "replacement_operation_run_id"), second_scope)
  )

  scope_read <- run_cli(c(
    "history", "scope", "--scope", second_scope, "--project", reference,
    "--json"
  ))
  current_read <- run_cli(c(
    "history", "current", "--episode", "fictional.episode.001", "--target",
    target, "--at", as_of, "--cutoff", as_of, "--project", reference,
    "--json"
  ))
  stopifnot(
    identical(scope_read$status, 0L), identical(current_read$status, 0L),
    grepl('"complete":true', output_text(scope_read), fixed = TRUE),
    !grepl("fictional.episode.001", output_text(current_read), fixed = TRUE)
  )

  materialized <- run_cli(c(
    "products", "materialize", "--scope", second_scope, "--cutoff", as_of,
    "--project", reference, "--json"
  ))
  products_human <- run_cli(c("products", "status", "--project", reference))
  products_json <- run_cli(c(
    "products", "status", "--project", reference, "--json"
  ))
  stopifnot(
    identical(materialized$status, 0L), identical(products_human$status, 0L),
    identical(products_json$status, 0L),
    grepl(json_string(products_json, "product_set_id"),
      output_text(products_human), fixed = TRUE)
  )

  newer_time <- "2026-01-21T12:00:00Z"
  newer_run <- run_cli(c(
    "run", "--at", newer_time, "--operation-key", "cli-newer", "--project",
    reference, "--json"
  ))
  newer_scope <- json_string(newer_run, "operation_run_id")
  stale <- run_cli(c(
    "products", "status", "--scope", newer_scope, "--cutoff", newer_time,
    "--project", reference, "--json"
  ))
  stopifnot(
    identical(newer_run$status, 0L), identical(stale$status, 0L),
    grepl('"freshness_status":"stale"', output_text(stale), fixed = TRUE)
  )

  backup <- file.path(proof, "state-backup")
  backed_up <- run_cli(c(
    "state", "backup", backup, "--project", reference, "--json"
  ))
  stopifnot(identical(backed_up$status, 0L), dir.exists(backup))
  restored_project <- copy_project(reference, file.path(proof, "restored-project"))
  unlink(file.path(restored_project, "state"), recursive = TRUE, force = TRUE)
  restore_denied <- run_cli(c(
    "state", "restore", backup, "--project", restored_project, "--json"
  ))
  stopifnot(
    identical(restore_denied$status, 1L),
    !dir.exists(file.path(restored_project, "state"))
  )
  restored <- run_cli(c(
    "state", "restore", backup, "--project", restored_project, "--yes",
    "--json"
  ))
  stopifnot(
    identical(restored$status, 0L), dir.exists(file.path(restored_project, "state")),
    !dir.exists(file.path(restored_project, "state", "products"))
  )

  copied <- copy_project(reference, file.path(proof, "copied-project"))
  copied_before <- tree_evidence(copied)
  copied_status <- run_cli(c("project", "status", "--project", copied, "--json"))
  copied_products <- run_cli(c("products", "status", "--project", copied, "--json"))
  stopifnot(
    identical(copied_status$status, 0L), identical(copied_products$status, 0L),
    identical(copied_before, tree_evidence(copied)),
    !dir.exists(file.path(copied, ".git"))
  )

  incompatible <- copy_project(standard, file.path(proof, "incompatible-project"))
  manifest <- file.path(incompatible, "rrp-project.dcf")
  lines <- readLines(manifest, warn = FALSE, encoding = "UTF-8")
  lines <- sub("^Supported-RRP-API-Version: .+$",
    "Supported-RRP-API-Version: 9.9.9", lines)
  writeLines(lines, manifest, useBytes = TRUE)
  incompatible_before <- tree_evidence(incompatible)
  incompatible_result <- run_cli(c(
    "project", "validate", "--project", incompatible, "--json"
  ))
  stopifnot(
    identical(incompatible_result$status, 1L),
    identical(incompatible_before, tree_evidence(incompatible))
  )
  invalid <- file.path(proof, "invalid")
  dir.create(invalid)
  stopifnot(identical(run_cli(c("project", "validate"), invalid)$status, 1L))

  corrupt <- copy_project(reference, file.path(proof, "corrupt-project"))
  cat("Corrupt: yes\n", file = file.path(corrupt, "state", "products", "current.dcf"),
    append = TRUE)
  corrupt_before <- tree_evidence(corrupt)
  corrupt_result <- run_cli(c(
    "products", "status", "--project", corrupt, "--json"
  ))
  stopifnot(
    identical(corrupt_result$status, 1L),
    identical(corrupt_before, tree_evidence(corrupt))
  )

  # Project registration schedules a normal foreground Shiny stop. The CLI
  # remains the supervising process and the read-only launch leaves all files.
  registration <- file.path(reference, "R", "register.R")
  registration_raw <- readBin(registration, "raw", n = file.info(registration)$size)
  registration_lines <- readLines(registration, warn = FALSE, encoding = "UTF-8")
  registration_lines <- append(registration_lines,
    "  later::later(function() shiny::stopApp(), delay = 1)", after = 1L)
  writeLines(registration_lines, registration, useBytes = TRUE)
  app_before <- tree_evidence(reference)
  port <- get("randomPort", envir = asNamespace("httpuv"), inherits = FALSE)()
  launched <- run_cli(c(
    "app", "launch", "--scope", second_scope, "--cutoff", as_of,
    "--project", reference, "--port", as.character(port), "--json"
  ))
  stopifnot(
    identical(launched$status, 0L),
    grepl('"application_id":"rrp.application.supplied"', output_text(launched),
      fixed = TRUE),
    identical(app_before, tree_evidence(reference))
  )
  writeBin(registration_raw, registration, useBytes = TRUE)

  signal_script <- file.path(proof, "app-signal.sh")
  writeLines(c(
    "#!/bin/sh",
    paste0("RRP_R_EXECUTABLE=", shQuote(host_r), " \\"),
    paste0("RRP_PRIVATE_LIBRARY=", shQuote(private_library), " \\"),
    paste0("RRP_SOFTWARE_ROOT=", shQuote(software_root), " \\"),
    paste(
      "/bin/sh", shQuote(launcher), "app launch --project",
      shQuote(reference), "--port", as.character(port), ">/dev/null 2>&1 &"
    ),
    "pid=$!", "sleep 2", "kill -TERM \"$pid\"", "wait \"$pid\"",
    "status=$?", "[ \"$status\" -eq 143 ]"
  ), signal_script, useBytes = TRUE)
  stopifnot(identical(as.integer(system2("/bin/sh", shQuote(signal_script))), 0L))
}

cat("rrpplatform CLI project-lifecycle tests passed\n")
