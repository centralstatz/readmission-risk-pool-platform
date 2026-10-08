library(rrpplatform)

internal <- function(name) getFromNamespace(name, "rrpplatform")
software_root <- Sys.getenv("RRP_TEST_SOFTWARE_ROOT", unset = "")
arguments <- commandArgs(trailingOnly = TRUE)
if (length(arguments) >= 1L) software_root <- arguments[[1L]]
stopifnot(nzchar(software_root), dir.exists(software_root))
software_root <- normalizePath(software_root, winslash = "/", mustWork = TRUE)
catalog <- rrp_open_resource_catalog(software_root)
cli_contract <- internal("rrp_lifecycle_contracts")(catalog)$cli_json

expect_usage <- function(expression, code) {
  condition <- tryCatch({
    force(expression)
    NULL
  }, rrp_cli_usage_error = identity)
  stopifnot(inherits(condition, "rrp_cli_usage_error"), identical(condition$code, code))
}

# The grammar is shallow, closed, and discoverable without aliases.
stopifnot(
  identical(internal("rrp_cli_nouns")(), c(
    "software", "project", "reference", "state", "history", "products",
    "app", "run"
  )),
  identical(internal("rrp_cli_parse")("help")$kind, "help"),
  identical(internal("rrp_cli_parse")("--help")$kind, "help"),
  identical(internal("rrp_cli_parse")(character())$kind, "help"),
  all(vapply(internal("rrp_cli_nouns")(), function(noun) {
    parsed <- internal("rrp_cli_parse")(c(noun, "--help"))
    identical(parsed$kind, "help") && identical(parsed$noun, noun)
  }, logical(1L))),
  identical(internal("rrp_cli_parse")("version")$command, "version"),
  isTRUE(internal("rrp_cli_parse")(c("version", "--json"))$json)
)
expect_usage(internal("rrp_cli_parse")("init"), "unsupported_command")
expect_usage(internal("rrp_cli_parse")("project"), "missing_subcommand")
expect_usage(
  internal("rrp_cli_parse")(c("project", "validate")),
  "command_not_implemented"
)
expect_usage(
  internal("rrp_cli_parse")(c("version", "--json", "--json")),
  "duplicate_option"
)
expect_usage(
  internal("rrp_cli_parse")(c("project", "status", "--project")),
  "missing_option_value"
)
expect_usage(
  internal("rrp_cli_parse")(c("project", "status", "--yes")),
  "invalid_project_status_arguments"
)

# Common syntax parsing is bounded and does not claim domain validation.
stopifnot(
  identical(
    internal("rrp_cli_parse_time")("2026-10-07T12:34:56Z"),
    "2026-10-07T12:34:56Z"
  ),
  identical(
    internal("rrp_cli_parse_identity")("scope.example-001"),
    "scope.example-001"
  )
)
expect_usage(
  internal("rrp_cli_parse_time")("2026-10-07 12:34:56"), "invalid_time"
)
expect_usage(internal("rrp_cli_parse_identity")("Not Valid"), "invalid_identity")
expect_usage(
  internal("rrp_cli_creation_destination")(character()),
  "destination_required"
)

# Project resolution uses exactly the supplied path or exact working directory.
resolution_root <- tempfile("rrp-cli-resolution-")
dir.create(resolution_root)
on.exit(unlink(resolution_root, recursive = TRUE, force = TRUE), add = TRUE)
project <- file.path(resolution_root, "project")
child <- file.path(project, "child")
other <- file.path(resolution_root, "other")
dir.create(project)
dir.create(child)
dir.create(other)
implicit <- internal("rrp_cli_parse")(
  c("project", "status"), working_directory = project
)
explicit <- internal("rrp_cli_parse")(
  c("project", "status", "--project", "../project"),
  working_directory = other
)
child_only <- internal("rrp_cli_parse")(
  c("project", "status"), working_directory = child
)
stopifnot(
  identical(implicit$project_root, normalizePath(project, winslash = "/")),
  identical(explicit$project_root, normalizePath(project, winslash = "/")),
  identical(child_only$project_root, normalizePath(child, winslash = "/"))
)

# Confirmation is inert for reads and exact for future mutation classes.
stopifnot(
  internal("rrp_cli_confirm")("read_only", interactive_session = FALSE),
  internal("rrp_cli_confirm")(
    "destructive", assume_yes = TRUE, interactive_session = FALSE
  ),
  !internal("rrp_cli_confirm")(
    "corrective", interactive_session = FALSE
  ),
  internal("rrp_cli_confirm")(
    "create_only", interactive_session = TRUE,
    read_response = function(prompt) "yes"
  ),
  !internal("rrp_cli_confirm")(
    "create_only", interactive_session = TRUE,
    read_response = function(prompt) "y"
  )
)

# Human and JSON render the same curated result payload.
context <- list(catalog = catalog, cli_contract = cli_contract)
version_result <- internal("rrp_cli_version_result")(context)
human_connection <- textConnection("human", "w", local = TRUE)
human_payload <- internal("rrp_cli_render_human")(
  version_result, cli_contract, human_connection
)
close(human_connection)
json_connection <- textConnection("json", "w", local = TRUE)
json_payload <- internal("rrp_cli_render_json")(
  version_result, cli_contract, json_connection
)
close(json_connection)
stopifnot(
  identical(human_payload, json_payload),
  identical(human_payload$schema_version, "1.0.0"),
  identical(human_payload$operation_id, "rrp.version"),
  grepl("Operation: rrp.version", paste(human, collapse = "\n"), fixed = TRUE),
  grepl('"schema_version":"1.0.0"', paste(json, collapse = "\n"), fixed = TRUE),
  !grepl("environment|callable|connection", paste(json, collapse = "\n"),
    ignore.case = TRUE)
)

malformed <- version_result
malformed$value$unexpected <- "not allowed"
condition <- tryCatch({
  internal("rrp_cli_result_payload")(malformed, cli_contract)
  NULL
}, error = identity)
stopifnot(inherits(condition, "error"))

wrong_r <- internal("rrp_cli_preflight")(
  software_root, normalizePath(.libPaths()[[1L]], winslash = "/"), "/bin/sh"
)
stopifnot(
  inherits(wrong_r, "rrp_operation_result"),
  identical(wrong_r$diagnostics[[1L]]$code, "incompatible_host_r")
)
condition <- tryCatch({
  internal("rrp_cli_result_payload")(list(status = "success"), cli_contract)
  NULL
}, error = identity)
stopifnot(inherits(condition, "error"))
unknown <- internal("rrp_new_operation_result")(
  "rrp.unknown", "failure", NULL,
  list(internal("rrp_new_diagnostic")(
    "unsupported", "error", "The operation is unsupported."
  ))
)
condition <- tryCatch({
  internal("rrp_cli_result_payload")(unknown, cli_contract)
  NULL
}, error = identity)
stopifnot(inherits(condition, "error"))
condition <- tryCatch({
  internal("rrp_new_diagnostic")(
    "unsafe", "error", "credential=do-not-render"
  )
  NULL
}, error = identity)
stopifnot(inherits(condition, "error"))

# Exit and interruption semantics are deterministic without a mutating command.
stopifnot(
  identical(internal("rrp_cli_exit_status")("success"), 0L),
  identical(internal("rrp_cli_exit_status")("operation_failure"), 1L),
  identical(internal("rrp_cli_exit_status")("usage"), 2L),
  identical(internal("rrp_cli_exit_status")("invalid_software_context"), 3L),
  identical(internal("rrp_cli_exit_status")("interrupted"), 130L)
)
interrupt_condition <- structure(
  list(message = "interrupted", call = NULL),
  class = c("interrupt", "condition")
)
interrupted <- internal("rrp_cli_execute_safely")(
  list(kind = "operation", command = "version"), context,
  operation_overrides = list(version = function() stop(interrupt_condition))
)
stopifnot(
  identical(interrupted$status, "failure"),
  identical(interrupted$diagnostics[[1L]]$code, "operation_interrupted")
)

# The optional installed proof exercises the actual package exec launcher.
if (length(arguments) >= 3L) {
  private_library <- normalizePath(arguments[[2L]], winslash = "/", mustWork = TRUE)
  launcher <- normalizePath(arguments[[3L]], winslash = "/", mustWork = TRUE)
  host_r <- normalizePath(file.path(R.home("bin"), "R"), winslash = "/", mustWork = TRUE)
  proof <- tempfile("rrp-cli-installed-")
  dir.create(proof)
  on.exit(unlink(proof, recursive = TRUE, force = TRUE), add = TRUE)
  unrelated <- file.path(proof, "unrelated")
  dir.create(unrelated)
  project_root <- file.path(proof, "project")
  stopifnot(rrp_operation_succeeded(rrp_initialize_project(
    catalog, project_root, "cli-proof-hospital", "1.0.0"
  )))
  project_child <- file.path(project_root, "child")
  dir.create(project_child)

  tree_evidence <- function(root) {
    files <- sort(list.files(
      root, all.files = TRUE, no.. = TRUE, recursive = TRUE,
      include.dirs = FALSE, full.names = FALSE
    ), method = "radix")
    list(
      files = files,
      md5 = unname(tools::md5sum(file.path(root, files))),
      size = unname(file.info(file.path(root, files), extra_cols = FALSE)$size)
    )
  }

  profile_marker <- file.path(proof, "profile-ran")
  profile <- file.path(proof, "user-profile.R")
  writeLines(paste0("writeLines('ran', ", deparse(profile_marker), ")"), profile)
  ambient_user <- file.path(proof, "ambient-user")
  ambient_site <- file.path(proof, "ambient-site")
  dir.create(ambient_user)
  dir.create(ambient_site)

  run_cli <- function(cli_arguments, directory, root = software_root,
                      library = private_library) {
    stdout_path <- tempfile("rrp-cli-stdout-")
    stderr_path <- tempfile("rrp-cli-stderr-")
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
        paste0("RRP_PRIVATE_LIBRARY=", library),
        paste0("RRP_SOFTWARE_ROOT=", root),
        paste0("R_PROFILE_USER=", profile),
        paste0("R_LIBS_USER=", ambient_user),
        paste0("R_LIBS_SITE=", ambient_site)
      )
    )
    list(
      status = as.integer(status),
      stdout = readLines(stdout_path, warn = FALSE, encoding = "UTF-8"),
      stderr = readLines(stderr_path, warn = FALSE, encoding = "UTF-8")
    )
  }

  version_human <- run_cli("version", unrelated)
  version_json <- run_cli(c("version", "--json"), unrelated)
  stopifnot(
    identical(version_human$status, 0L), identical(version_json$status, 0L),
    grepl("rrpplatform_version: 0.1.0.9000", paste(version_human$stdout, collapse = "\n"), fixed = TRUE),
    grepl('"operation_id":"rrp.version"', paste(version_json$stdout, collapse = "\n"), fixed = TRUE),
    !file.exists(profile_marker)
  )

  help <- run_cli("--help", unrelated)
  stopifnot(
    identical(help$status, 0L),
    all(vapply(internal("rrp_cli_nouns")(), function(noun) {
      grepl(paste0("  ", noun, " ..."), paste(help$stdout, collapse = "\n"), fixed = TRUE)
    }, logical(1L)))
  )
  for (noun in internal("rrp_cli_nouns")()) {
    noun_help <- run_cli(c(noun, "--help"), unrelated)
    stopifnot(identical(noun_help$status, 0L))
  }

  before <- tree_evidence(project_root)
  implicit <- run_cli(c("project", "status"), project_root)
  explicit <- run_cli(
    c("project", "status", "--project", project_root), unrelated
  )
  json_status <- run_cli(
    c("project", "status", "--project", project_root, "--json"), unrelated
  )
  after <- tree_evidence(project_root)
  stopifnot(
    identical(implicit$status, 0L), identical(explicit$status, 0L),
    identical(json_status$status, 0L), identical(before, after),
    grepl("project_id: cli-proof-hospital", paste(implicit$stdout, collapse = "\n"), fixed = TRUE),
    grepl('"project_id":"cli-proof-hospital"', paste(json_status$stdout, collapse = "\n"), fixed = TRUE),
    grepl("project_state_not_initialized", paste(implicit$stdout, collapse = "\n"), fixed = TRUE),
    grepl('"schema_version":"1.0.0"', paste(json_status$stdout, collapse = "\n"), fixed = TRUE)
  )

  child_result <- run_cli(c("project", "status"), project_child)
  unrelated_result <- run_cli(c("project", "status"), unrelated)
  unrelated_json <- run_cli(c("project", "status", "--json"), unrelated)
  unsupported <- run_cli(c("project", "validate"), unrelated)
  stopifnot(
    identical(child_result$status, 1L), identical(unrelated_result$status, 1L),
    identical(unrelated_json$status, 1L),
    identical(unsupported$status, 2L),
    grepl('"status":"failure"', paste(unrelated_json$stderr, collapse = "\n"), fixed = TRUE),
    grepl("command_not_implemented", paste(unsupported$stderr, collapse = "\n"), fixed = TRUE)
  )

  empty_library <- file.path(proof, "empty-library")
  dir.create(empty_library)
  missing_packages <- run_cli("version", unrelated, library = empty_library)
  invalid_root <- file.path(proof, "invalid-software")
  dir.create(invalid_root)
  invalid_context <- run_cli("version", unrelated, root = invalid_root)
  stopifnot(
    identical(missing_packages$status, 3L),
    identical(invalid_context$status, 3L),
    grepl("invalid_software_context", paste(c(
      missing_packages$stderr, invalid_context$stderr
    ), collapse = "\n"), fixed = TRUE)
  )

  # The shell boundary execs the selected R process, so termination status is
  # not hidden behind a surviving launcher process.
  blocking_project <- file.path(proof, "blocking-project")
  stopifnot(rrp_operation_succeeded(rrp_initialize_project(
    catalog, blocking_project, "cli-blocking-proof", "1.0.0"
  )))
  writeLines(c(
    "rrp_register_project <- function(project_root) {",
    "  Sys.sleep(60)",
    "  rrpplatform::rrp_register_authored_project(project_root)",
    "}"
  ), file.path(blocking_project, "R", "register.R"), useBytes = TRUE)
  signal_script <- file.path(proof, "signal-proof.sh")
  writeLines(c(
    "#!/bin/sh",
    paste0("RRP_R_EXECUTABLE=", shQuote(host_r), " \\"),
    paste0("RRP_PRIVATE_LIBRARY=", shQuote(private_library), " \\"),
    paste0("RRP_SOFTWARE_ROOT=", shQuote(software_root), " \\"),
    paste(
      "/bin/sh", shQuote(launcher), "project status --project",
      shQuote(blocking_project), ">/dev/null 2>&1 &"
    ),
    "pid=$!",
    "sleep 1",
    "kill -TERM \"$pid\"",
    "wait \"$pid\"",
    "status=$?",
    "[ \"$status\" -eq 143 ]"
  ), signal_script, useBytes = TRUE)
  signal_status <- system2("/bin/sh", shQuote(signal_script))
  stopifnot(identical(as.integer(signal_status), 0L))
}
