#!/usr/bin/env Rscript

file_argument <- grep("^--file=", commandArgs(trailingOnly = FALSE), value = TRUE)
script_path <- normalizePath(
  sub("^--file=", "", file_argument[[1L]]), mustWork = TRUE
)
repository_root <- normalizePath(
  file.path(dirname(script_path), ".."), mustWork = TRUE
)

arguments <- commandArgs(trailingOnly = TRUE)
if (length(arguments) != 2L || !identical(arguments[[1L]], "--package") ||
    !arguments[[2L]] %in% c("rrpruntime", "rrpplatform")) stop(
  "Usage: Rscript tests/run-package-tests.R --package rrpruntime|rrpplatform",
  call. = FALSE
)
package_name <- arguments[[2L]]

source(file.path(
  repository_root, "tests", "software", "package-boundaries.R"
))
rrp_validate_package_boundaries(repository_root)

rrp_run_package_command <- function(command, arguments, environment = character()) {
  output <- suppressWarnings(system2(
    command, arguments, stdout = TRUE, stderr = TRUE, env = environment
  ))
  status <- attr(output, "status")
  if (is.null(status)) status <- 0L
  if (!identical(status, 0L)) {
    cat(paste(tail(output, 200L), collapse = "\n"), "\n", file = stderr())
    stop("Package command failed with exit status ", status, ".", call. = FALSE)
  }
  invisible(output)
}

rrp_build_package <- function(package_name, work_root) {
  package_path <- file.path(repository_root, "packages", package_name)
  description <- read.dcf(file.path(package_path, "DESCRIPTION"))
  version <- unname(description[[1L, "Version"]])
  rrp_run_package_command(
    file.path(R.home("bin"), "R"),
    c(
      "CMD", "build", "--no-manual", "--no-build-vignettes",
      shQuote(package_path)
    )
  )
  archive <- file.path(work_root, paste0(package_name, "_", version, ".tar.gz"))
  if (!file.exists(archive)) stop(
    "Package build did not create the expected archive: ", basename(archive),
    call. = FALSE
  )
  archive
}

work_root <- tempfile("rrp-package-validation-")
dir.create(work_root)
library_root <- file.path(work_root, "library")
dir.create(library_root)
old_directory <- setwd(work_root)
on.exit({
  setwd(old_directory)
  unlink(work_root, recursive = TRUE, force = TRUE)
}, add = TRUE)

runtime_archive <- rrp_build_package("rrpruntime", work_root)
rrp_run_package_command(
  file.path(R.home("bin"), "R"),
  c("CMD", "INSTALL", paste0("--library=", shQuote(library_root)),
    shQuote(runtime_archive))
)

archive <- if (identical(package_name, "rrpruntime")) {
  runtime_archive
} else {
  rrp_build_package("rrpplatform", work_root)
}
if (identical(package_name, "rrpplatform")) {
  rrp_run_package_command(
    file.path(R.home("bin"), "R"),
    c("CMD", "INSTALL", paste0("--library=", shQuote(library_root)),
      shQuote(archive)),
    paste0("R_LIBS_USER=", library_root)
  )
}

quoted_library <- encodeString(library_root, quote = "\"")
quoted_package <- encodeString(package_name, quote = "\"")
quoted_version <- encodeString(
  if (identical(package_name, "rrpruntime")) "0.3.0" else "0.1.0.9000",
  quote = "\""
)
load_expression <- paste0(
  ".libPaths(c(", quoted_library, ", .libPaths())); ",
  "library(", package_name, "); ",
  "stopifnot(identical(as.character(packageVersion(",
  quoted_package, ")), ", quoted_version,
  "))"
)
rrp_run_package_command(
  file.path(R.home("bin"), "Rscript"),
  c("--vanilla", "-e", shQuote(load_expression)),
  paste0("R_LIBS_USER=", library_root)
)

local_repository <- file.path(work_root, "repository")
local_contrib <- file.path(local_repository, "src", "contrib")
dir.create(local_contrib, recursive = TRUE)
writeLines(character(), file.path(local_contrib, "PACKAGES"))
check_profile <- file.path(work_root, "check-profile.R")
repository_url <- normalizePath(
  local_repository, winslash = "/", mustWork = TRUE
)
writeLines(paste0(
  "options(repos = c(CRAN = ",
  encodeString(repository_url, quote = "\""), "))"
), check_profile)
check_environment <- c(
  paste0("R_LIBS=", library_root),
  paste0("R_LIBS_USER=", library_root),
  paste0("R_PROFILE_USER=", check_profile)
)
rrp_run_package_command(
  file.path(R.home("bin"), "R"),
  c(
    "CMD", "check", "--no-manual",
    paste0("--library=", shQuote(library_root)),
    shQuote(archive)
  ),
  check_environment
)
check_log <- file.path(work_root, paste0(package_name, ".Rcheck"), "00check.log")
if (!file.exists(check_log)) stop("R CMD check log is missing.", call. = FALSE)
status <- grep("^Status:", readLines(check_log, warn = FALSE), value = TRUE)
if (!identical(status, "Status: OK")) stop(
  "R CMD check did not satisfy the zero error/warning/note gate: ",
  paste(status, collapse = " | "), call. = FALSE
)

cat(
  "Package validation: PASS\n",
  "  package: ", package_name, "\n",
  "  build: PASS\n",
  "  isolated install/load: PASS\n",
  "  R CMD check --no-manual: Status: OK\n",
  "  package-boundary checks: PASS\n",
  sep = ""
)
