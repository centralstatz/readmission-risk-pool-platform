#!/usr/bin/env Rscript

# Prove only the local two-package foundation implemented in Stage 2.
# This is repository-maintainer tooling, not an installed RRP operation or a
# general validation dispatcher.

script_argument <- grep(
  "^--file=", commandArgs(trailingOnly = FALSE), value = TRUE
)
if (length(script_argument) != 1L) {
  stop("Cannot determine the package-validation script path.", call. = FALSE)
}
script_path <- normalizePath(
  sub("^--file=", "", script_argument), mustWork = TRUE
)
repository_root <- normalizePath(
  file.path(dirname(script_path), ".."), mustWork = TRUE
)

package_specs <- list(
  rrpruntime = list(
    version = "0.3.0.9000",
    imports = character()
  ),
  rrpplatform = list(
    version = "0.1.0.9000",
    imports = "rrpruntime"
  )
)

fail <- function(...) {
  stop(paste0(...), call. = FALSE)
}

require_true <- function(condition, message) {
  if (!isTRUE(condition)) fail(message)
}

package_expected_files <- function(package_name) {
  c(
    "DESCRIPTION", "NAMESPACE",
    file.path("R", paste0(package_name, "-package.R")),
    "README.md",
    file.path("man", paste0(package_name, "-package.Rd")),
    file.path("tests", "package-foundation.R")
  )
}

package_dependency_names <- function(description, field) {
  if (!field %in% colnames(description)) return(character())
  values <- trimws(strsplit(description[[1L, field]], ",", fixed = TRUE)[[1L]])
  sub("[[:space:]]*[(].*$", "", values)
}

read_package_description <- function(package_root, package_name) {
  description_path <- file.path(package_root, "DESCRIPTION")
  description <- tryCatch(
    read.dcf(description_path),
    error = function(condition) fail(
      package_name, " DESCRIPTION is not valid DCF: ", conditionMessage(condition)
    )
  )
  require_true(
    nrow(description) == 1L,
    paste0(package_name, " DESCRIPTION must contain exactly one record.")
  )
  description
}

validate_package_layout <- function(package_root, package_name) {
  actual_files <- sort(list.files(
    package_root, recursive = TRUE, all.files = TRUE,
    full.names = FALSE, include.dirs = FALSE, no.. = TRUE
  ), method = "radix")
  expected_files <- sort(package_expected_files(package_name), method = "radix")
  missing_files <- setdiff(expected_files, actual_files)
  unexpected_files <- setdiff(actual_files, expected_files)
  if (length(missing_files) > 0L) fail(
    package_name, " is missing required package file(s): ",
    paste(missing_files, collapse = ", ")
  )
  if (length(unexpected_files) > 0L) fail(
    package_name, " contains unexpected package file(s): ",
    paste(unexpected_files, collapse = ", ")
  )

  actual_directories <- list.dirs(
    package_root, recursive = TRUE, full.names = FALSE
  )
  actual_directories <- sort(
    actual_directories[nzchar(actual_directories)], method = "radix"
  )
  expected_directories <- sort(c("R", "man", "tests"), method = "radix")
  require_true(
    identical(actual_directories, expected_directories),
    paste0(
      package_name,
      " must contain exactly the conventional R, man, and tests directories."
    )
  )
}

validate_package_metadata <- function(package_root, package_name, spec) {
  description <- read_package_description(package_root, package_name)
  expected_fields <- c(
    Package = package_name,
    Type = "Package",
    Title = if (identical(package_name, "rrpruntime")) {
      "Dependency-Light Readmission Runtime Foundation"
    } else {
      "Internal Readmission Risk Pool Implementation"
    },
    Version = spec$version,
    License = "Apache License (>= 2)",
    URL = "https://github.com/centralstatz/readmission-risk-pool-platform",
    BugReports = paste0(
      "https://github.com/centralstatz/readmission-risk-pool-platform/issues"
    ),
    Encoding = "UTF-8",
    Depends = "R (>= 4.4.0)"
  )
  for (field in names(expected_fields)) {
    actual <- if (field %in% colnames(description)) {
      unname(description[[1L, field]])
    } else {
      NA_character_
    }
    require_true(
      identical(actual, expected_fields[[field]]),
      paste0(
        package_name, " DESCRIPTION field ", field, " must be `",
        expected_fields[[field]], "`."
      )
    )
  }
  for (field in c("Authors@R", "Description")) {
    require_true(
      field %in% colnames(description) && nzchar(description[[1L, field]]),
      paste0(package_name, " DESCRIPTION must define ", field, ".")
    )
  }

  imports <- package_dependency_names(description, "Imports")
  suggest_dependencies <- package_dependency_names(description, "Suggests")
  linking_dependencies <- package_dependency_names(description, "LinkingTo")
  require_true(
    identical(imports, spec$imports),
    paste0(
      package_name, " Imports must be exactly: ",
      if (length(spec$imports) == 0L) "none" else paste(spec$imports, collapse = ", "),
      "."
    )
  )
  require_true(
    length(suggest_dependencies) == 0L && length(linking_dependencies) == 0L,
    paste0(package_name, " must not declare Suggests or LinkingTo dependencies.")
  )

  r_files <- list.files(
    package_root, pattern = "[.]R$", recursive = TRUE, full.names = TRUE
  )
  for (r_file in r_files) {
    tryCatch(
      parse(r_file),
      error = function(condition) fail(
        package_name, " R file does not parse: ",
        sub(paste0("^", package_root, .Platform$file.sep), "", r_file),
        ": ", conditionMessage(condition)
      )
    )
  }
  tryCatch(
    invisible(tools::parse_Rd(file.path(
      package_root, "man", paste0(package_name, "-package.Rd")
    ))),
    error = function(condition) fail(
      package_name, " package documentation does not parse: ",
      conditionMessage(condition)
    )
  )

  namespace <- tryCatch(
    base::parseNamespaceFile(package_name, dirname(package_root)),
    error = function(condition) fail(
      package_name, " NAMESPACE does not parse: ", conditionMessage(condition)
    )
  )
  require_true(
    length(namespace$exports) == 0L,
    paste0(package_name, " must export no callable API.")
  )
  namespace_lines <- trimws(readLines(
    file.path(package_root, "NAMESPACE"), warn = FALSE, encoding = "UTF-8"
  ))
  namespace_directives <- namespace_lines[
    nzchar(namespace_lines) & !startsWith(namespace_lines, "#")
  ]
  expected_directives <- if (identical(package_name, "rrpplatform")) {
    "import(rrpruntime)"
  } else {
    character()
  }
  require_true(
    identical(namespace_directives, expected_directives),
    paste0(
      package_name, " NAMESPACE must contain exactly ",
      if (length(expected_directives) == 0L) {
        "no directives."
      } else {
        paste0("`", expected_directives, "`.")
      }
    )
  )

  invisible(description)
}

validate_source_boundaries <- function(package_roots) {
  runtime_files <- list.files(
    package_roots[["rrpruntime"]], recursive = TRUE, full.names = TRUE
  )
  runtime_text <- paste(unlist(lapply(
    runtime_files, readLines, warn = FALSE, encoding = "UTF-8"
  ), use.names = FALSE), collapse = "\n")
  require_true(
    !grepl("rrpplatform", runtime_text, fixed = TRUE),
    "rrpruntime must not refer to rrpplatform."
  )

  forbidden_source_patterns <- c(
    "\\.GlobalEnv", "getwd\\s*\\(", "Sys\\.getenv\\s*\\(",
    "(?:^|[^[:alnum:]_.])(?:sys\\.)?source\\s*\\(",
    "repository_root", "[.]git(?:/|\\\\|\"|')",
    "readmission-risk-pool(?:/|\\\\)"
  )
  for (package_name in names(package_roots)) {
    source_files <- list.files(
      file.path(package_roots[[package_name]], "R"),
      pattern = "[.]R$", full.names = TRUE
    )
    source_text <- paste(unlist(lapply(
      source_files, readLines, warn = FALSE, encoding = "UTF-8"
    ), use.names = FALSE), collapse = "\n")
    matched <- forbidden_source_patterns[vapply(
      forbidden_source_patterns, grepl, logical(1L), x = source_text,
      perl = TRUE, ignore.case = TRUE
    )]
    if (length(matched) > 0L) fail(
      package_name, " source contains prohibited repository coupling: ",
      paste(matched, collapse = ", ")
    )
  }
}

run_command <- function(command, arguments, environment = character()) {
  output <- suppressWarnings(system2(
    command, arguments, stdout = TRUE, stderr = TRUE, env = environment
  ))
  status <- attr(output, "status")
  if (is.null(status)) status <- 0L
  list(status = as.integer(status), output = output)
}

require_command_success <- function(label, command, arguments, environment = character()) {
  result <- run_command(command, arguments, environment)
  if (!identical(result$status, 0L)) {
    details <- paste(tail(result$output, 80L), collapse = "\n")
    fail(label, " failed with exit status ", result$status, ".\n", details)
  }
  invisible(result$output)
}

write_validation_profile <- function(path, library_root, repository_url = NULL) {
  lines <- paste0(
    ".libPaths(c(",
    encodeString(normalizePath(library_root, mustWork = TRUE), quote = "\""),
    ", .Library))"
  )
  if (!is.null(repository_url)) {
    lines <- c(lines, paste0(
      "options(repos = c(CRAN = ",
      encodeString(repository_url, quote = "\""), "))"
    ))
  }
  writeLines(lines, path, useBytes = TRUE)
}

validation_environment <- function(profile_path, library_root) {
  c(
    paste0("R_LIBS=", library_root),
    paste0("R_LIBS_USER=", library_root),
    paste0("R_PROFILE_USER=", profile_path),
    "R_ENVIRON_USER=/dev/null"
  )
}

build_package <- function(package_name, package_root, work_root) {
  spec <- package_specs[[package_name]]
  require_command_success(
    paste0(package_name, " build"),
    file.path(R.home("bin"), "R"),
    c("CMD", "build", "--no-manual", shQuote(package_root))
  )
  archive <- file.path(
    work_root, paste0(package_name, "_", spec$version, ".tar.gz")
  )
  require_true(
    file.exists(archive),
    paste0(package_name, " build did not create ", basename(archive), ".")
  )
  archive
}

install_package <- function(package_name, archive, library_root, environment) {
  require_command_success(
    paste0(package_name, " isolated installation"),
    file.path(R.home("bin"), "R"),
    c(
      "CMD", "INSTALL", paste0("--library=", shQuote(library_root)),
      shQuote(archive)
    ),
    environment
  )
}

load_package_fresh <- function(package_name, library_root) {
  spec <- package_specs[[package_name]]
  expression <- paste0(
    "library_root <- ",
    encodeString(normalizePath(library_root, mustWork = TRUE), quote = "\""),
    "; .libPaths(c(library_root, .Library)); package_name <- ",
    encodeString(package_name, quote = "\""),
    "; library(package_name, character.only = TRUE); ",
    "stopifnot(startsWith(normalizePath(find.package(package_name)), ",
    "paste0(library_root, .Platform$file.sep)), ",
    "identical(as.character(packageVersion(package_name)), ",
    encodeString(spec$version, quote = "\""),
    "), length(getNamespaceExports(package_name)) == 0L)",
    if (identical(package_name, "rrpplatform")) {
      "; stopifnot(\"rrpruntime\" %in% loadedNamespaces())"
    } else {
      ""
    }
  )
  require_command_success(
    paste0(package_name, " fresh-process load"),
    file.path(R.home("bin"), "Rscript"),
    c("--vanilla", "-e", shQuote(expression))
  )
}

check_package <- function(
  package_name, archive, work_root, library_root, environment
) {
  require_command_success(
    paste0(package_name, " R CMD check --no-manual"),
    file.path(R.home("bin"), "R"),
    c(
      "CMD", "check", "--no-manual",
      paste0("--library=", shQuote(library_root)), shQuote(archive)
    ),
    environment
  )
  check_log <- file.path(work_root, paste0(package_name, ".Rcheck"), "00check.log")
  require_true(
    file.exists(check_log),
    paste0(package_name, " check log is missing.")
  )
  status <- grep(
    "^Status:", readLines(check_log, warn = FALSE, encoding = "UTF-8"),
    value = TRUE
  )
  require_true(
    identical(status, "Status: OK"),
    paste0(
      package_name, " check must end with exact `Status: OK`; found: ",
      if (length(status) == 0L) "no status" else paste(status, collapse = " | ")
    )
  )
}

validate_packages <- function() {
  cat("RRP local package-foundation validation\n")
  cat("=======================================\n")

  package_root <- file.path(repository_root, "packages")
  require_true(dir.exists(package_root), "The packages directory is missing.")
  actual_package_roots <- sort(list.dirs(
    package_root, recursive = FALSE, full.names = FALSE
  ), method = "radix")
  expected_package_roots <- sort(names(package_specs), method = "radix")
  require_true(
    identical(actual_package_roots, expected_package_roots),
    paste0(
      "Package roots must be exactly: ",
      paste(expected_package_roots, collapse = ", "), "."
    )
  )

  package_roots <- setNames(
    file.path(package_root, names(package_specs)), names(package_specs)
  )
  for (package_name in names(package_specs)) {
    validate_package_layout(package_roots[[package_name]], package_name)
    validate_package_metadata(
      package_roots[[package_name]], package_name, package_specs[[package_name]]
    )
    cat(sprintf("PASS %-11s static package boundary\n", package_name))
  }
  validate_source_boundaries(package_roots)
  cat("PASS one-way dependency and repository-independence boundary\n")

  work_root <- tempfile("rrp-package-validation-")
  dir.create(work_root)
  old_directory <- setwd(work_root)
  on.exit({
    setwd(old_directory)
    unlink(work_root, recursive = TRUE, force = TRUE)
  }, add = TRUE)

  library_root <- file.path(work_root, "library")
  missing_dependency_library <- file.path(work_root, "missing-dependency-library")
  local_contrib <- file.path(work_root, "repository", "src", "contrib")
  dir.create(library_root)
  dir.create(missing_dependency_library)
  dir.create(local_contrib, recursive = TRUE)
  writeLines(character(), file.path(local_contrib, "PACKAGES"))

  profile_path <- file.path(work_root, "check-profile.R")
  repository_url <- paste0(
    "file://", normalizePath(file.path(work_root, "repository"),
                              winslash = "/", mustWork = TRUE)
  )
  write_validation_profile(profile_path, library_root, repository_url)
  environment <- validation_environment(profile_path, library_root)

  archives <- lapply(names(package_specs), function(package_name) {
    archive <- build_package(
      package_name, package_roots[[package_name]], work_root
    )
    cat(sprintf("PASS %-11s source build\n", package_name))
    archive
  })
  names(archives) <- names(package_specs)

  missing_profile <- file.path(work_root, "missing-dependency-profile.R")
  write_validation_profile(
    missing_profile, missing_dependency_library, repository_url
  )
  missing_environment <- validation_environment(
    missing_profile, missing_dependency_library
  )
  missing_result <- run_command(
    file.path(R.home("bin"), "R"),
    c(
      "CMD", "INSTALL",
      paste0("--library=", shQuote(missing_dependency_library)),
      shQuote(archives[["rrpplatform"]])
    ),
    missing_environment
  )
  require_true(
    !identical(missing_result$status, 0L),
    paste0(
      "rrpplatform unexpectedly installed without rrpruntime in its isolated ",
      "library."
    )
  )
  cat("PASS rrpplatform rejects installation without rrpruntime\n")

  for (package_name in names(package_specs)) {
    install_package(
      package_name, archives[[package_name]], library_root, environment
    )
    load_package_fresh(package_name, library_root)
    check_package(
      package_name, archives[[package_name]], work_root, library_root,
      environment
    )
    cat(sprintf(
      paste0(
        "PASS %-11s isolated install/load and R CMD check ",
        "--no-manual (Status: OK)\n"
      ),
      package_name
    ))
  }

  cat("\nResult: PASS (two-package local foundation)\n")
  cat(
    "Scope: package topology, metadata, dependency direction, zero-export ",
    "namespaces, build, isolated install/load, and package-native check only.\n",
    sep = ""
  )
}

passed <- tryCatch(
  {
    validate_packages()
    TRUE
  },
  error = function(condition) {
    cat("\nResult: FAIL\n", file = stderr())
    cat("  ", conditionMessage(condition), "\n", sep = "", file = stderr())
    FALSE
  }
)

if (!passed) quit(save = "no", status = 1L, runLast = FALSE)
