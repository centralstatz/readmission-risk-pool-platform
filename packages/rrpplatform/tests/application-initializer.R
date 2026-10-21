library(rrpplatform)

internal <- function(name) get(name, envir = asNamespace("rrpplatform"), inherits = FALSE)
destination <- internal("rrp_app_destination")
parse_cli <- internal("rrp_cli_parse")

stopifnot(identical(as.list(formals(rrp_initialize_app)), as.list(alist(
  software_catalog = , project_root = , scope_id = , history_cutoff = ,
  output_path = NULL
))))

suite <- tempfile("rrp-app-initializer-foundation-")
dir.create(suite)
on.exit(unlink(suite, recursive = TRUE, force = TRUE), add = TRUE)
project <- file.path(suite, "project")
dir.create(project)

parsed <- parse_cli(c(
  "app", "init", "--scope", "scope.1", "--cutoff",
  "2026-01-20T12:00:00Z", "--project", project, "--output", "standalone"
), suite)
stopifnot(
  identical(parsed$command, "app_init"),
  identical(parsed$project_root, normalizePath(project, winslash = "/")),
  identical(parsed$output_path, file.path(normalizePath(suite, winslash = "/"),
    "standalone")),
  identical(destination(normalizePath(project, winslash = "/"), NULL),
    file.path(normalizePath(project, winslash = "/"), "app"))
)

existing <- file.path(suite, "existing")
dir.create(existing)
failure <- tryCatch(destination(project, existing), error = identity)
stopifnot(
  inherits(failure, "rrp_application_initialization_error"),
  identical(failure$code, "application_destination_exists")
)

existing_file <- file.path(suite, "existing-file")
writeLines("preserve", existing_file)
file_failure <- tryCatch(destination(project, existing_file), error = identity)
stopifnot(
  inherits(file_failure, "rrp_application_initialization_error"),
  identical(file_failure$code, "application_destination_exists"),
  identical(readLines(existing_file, warn = FALSE), "preserve")
)

linked_destination <- file.path(suite, "linked-destination")
if (isTRUE(file.symlink(existing_file, linked_destination))) {
  link_failure <- tryCatch(
    destination(project, linked_destination), error = identity
  )
  stopifnot(
    inherits(link_failure, "rrp_application_initialization_error"),
    identical(link_failure$code, "application_destination_exists"),
    identical(Sys.readlink(linked_destination), existing_file)
  )
}

linked_parent <- file.path(suite, "linked-parent")
if (isTRUE(file.symlink(project, linked_parent))) {
  linked_failure <- tryCatch(parse_cli(c(
    "app", "init", "--scope", "scope.1", "--cutoff",
    "2026-01-20T12:00:00Z", "--project", project, "--output",
    file.path(linked_parent, "app")
  ), suite), error = identity)
  stopifnot(
    inherits(linked_failure, "rrp_cli_usage_error"),
    identical(linked_failure$code, "invalid_destination")
  )
  direct_linked_failure <- tryCatch(destination(
    project, file.path(linked_parent, "app")
  ), error = identity)
  stopifnot(
    inherits(direct_linked_failure, "rrp_application_initialization_error"),
    identical(direct_linked_failure$code, "application_destination_invalid")
  )
}

invalid <- rrp_initialize_app(list(), project, "scope.1", "2026-01-20T12:00:00Z")
stopifnot(
  identical(invalid$status, "failure"), is.null(invalid$value),
  identical(invalid$diagnostics[[1L]]$code, "application_initialization_failed")
)

structural <- paste(deparse(body(internal("rrp_app_structural_access"))), collapse = "\n")
stopifnot(
  !grepl("rrp_load_project", structural, fixed = TRUE),
  !grepl("register.R", structural, fixed = TRUE),
  !grepl("rrp_execute", structural, fixed = TRUE)
)

cat("rrpplatform application initializer foundation tests passed\n")
