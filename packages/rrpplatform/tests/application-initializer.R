library(rrpplatform)

internal <- function(name) get(name, envir = asNamespace("rrpplatform"), inherits = FALSE)
destination <- internal("rrp_app_destination")
parse_cli <- internal("rrp_cli_parse")
dependency_context <- internal("rrp_app_dependency_context")

target_r <- as.character(getRversion())
header <- c(
  "Record-Type" = "rrp-dependency-specification",
  "Target-R-Version" = target_r,
  "Target-Platform" = R.version$platform,
  "Target-Architecture" = R.version$arch
)
artifact <- c(
  "Target-R-Version" = target_r,
  "Target-Platform" = R.version$platform,
  "Target-Architecture" = R.version$arch,
  "Technical-Minimum-R-Version" = "4.4.0"
)
host <- list(
  version = target_r, platform = R.version$platform,
  architecture = R.version$arch
)
installation <- c(
  "Host-R-Version" = host$version, "Platform" = host$platform,
  "Architecture" = host$architecture
)
exact_context <- dependency_context(header, artifact, installation, host)
stopifnot(
  identical(exact_context$build_target_r_version, target_r),
  identical(exact_context$host_r_version, target_r),
  identical(exact_context$eligibility_status,
    "exact_build_target_unqualified")
)
varied_host <- host
varied_host$version <- "4.99.0"
varied_installation <- installation
varied_installation[["Host-R-Version"]] <- varied_host$version
varied_context <- dependency_context(
  header, artifact, varied_installation, varied_host
)
stopifnot(
  identical(varied_context$build_target_r_version, target_r),
  identical(varied_context$host_r_version, "4.99.0"),
  identical(varied_context$eligibility_status, "eligible_best_effort")
)
old_host <- varied_host
old_host$version <- "4.3.99"
old_installation <- varied_installation
old_installation[["Host-R-Version"]] <- old_host$version
old_failure <- tryCatch(
  dependency_context(header, artifact, old_installation, old_host),
  error = identity
)
stopifnot(
  inherits(old_failure, "rrp_application_initialization_error"),
  identical(old_failure$code, "application_dependency_provenance_invalid")
)
wrong_platform <- varied_host
wrong_platform$platform <- "wrong-platform"
wrong_installation <- varied_installation
wrong_installation[["Platform"]] <- wrong_platform$platform
platform_failure <- tryCatch(
  dependency_context(header, artifact, wrong_installation, wrong_platform),
  error = identity
)
stopifnot(
  inherits(platform_failure, "rrp_application_initialization_error"),
  identical(platform_failure$code,
    "application_dependency_provenance_invalid")
)

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
