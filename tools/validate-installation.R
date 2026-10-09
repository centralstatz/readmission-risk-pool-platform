#!/usr/bin/env Rscript

# Full Increment 11.E proof. This deliberately performs one real configured-
# repository restoration and reuses that realization for idempotency/CLI proof.

script_argument <- grep("^--file=", commandArgs(trailingOnly = FALSE), value = TRUE)
if (length(script_argument) != 1L) stop("Cannot determine validation path.", call. = FALSE)
script_path <- normalizePath(sub("^--file=", "", script_argument), mustWork = TRUE)
repository_root <- normalizePath(file.path(dirname(script_path), ".."), mustWork = TRUE)
source(file.path(repository_root, "tools", "distribution-lib.R"), local = TRUE)
source(file.path(repository_root, "distribution", "verify-distribution.R"), local = TRUE)
source(file.path(repository_root, "distribution", "install-engine.R"), local = TRUE)

require_true <- function(value, message) {
  if (!isTRUE(value)) stop(message, call. = FALSE)
}

expect_failure <- function(label, expression, pattern) {
  condition <- tryCatch({ force(expression); NULL }, error = identity)
  require_true(inherits(condition, "error"), paste(label, "did not fail."))
  require_true(
    grepl(pattern, conditionMessage(condition), fixed = TRUE),
    paste(label, "failed for the wrong reason:", conditionMessage(condition))
  )
  invisible(condition)
}

run <- function(command, arguments, environment = character()) {
  output <- suppressWarnings(system2(
    command, arguments, stdout = TRUE, stderr = TRUE, env = environment
  ))
  list(
    output = output,
    status = if (is.null(attr(output, "status"))) 0L else attr(output, "status")
  )
}

write_ambient_package <- function(library, package, version) {
  root <- file.path(library, package)
  dir.create(root, recursive = TRUE)
  fields <- c(
    Package = package, Version = version, Title = "Ambient isolation fixture",
    Description = "An intentionally wrong package used only by validation.",
    License = "Apache License (>= 2)", Author = "RRP validation",
    Maintainer = "RRP validation <noreply@example.invalid>"
  )
  write.dcf(
    matrix(unname(fields), nrow = 1L, dimnames = list(NULL, names(fields))),
    file = file.path(root, "DESCRIPTION")
  )
  invisible(root)
}

tree_digest <- function(root) {
  entries <- list.files(root, all.files = TRUE, full.names = TRUE,
    recursive = TRUE, include.dirs = FALSE, no.. = TRUE)
  entries <- entries[isTRUE(file.exists(entries)) | file.exists(entries)]
  relative <- substring(entries, nchar(root) + 2L)
  setNames(vapply(entries, function(path) {
    if (dir.exists(path)) "directory" else rrp_sha256(path)
  }, character(1L)), relative)
}

validate_installation <- function() {
  work <- tempfile("rrp-installation-validation-")
  dir.create(work)
  on.exit({
    entries <- list.files(work, all.files = TRUE, full.names = TRUE,
      recursive = TRUE, include.dirs = TRUE, no.. = TRUE)
    if (length(entries)) Sys.chmod(entries, mode = "0755", use_umask = FALSE)
    unlink(work, recursive = TRUE, force = TRUE)
  }, add = TRUE)

  archive <- file.path(work, "distribution.tar")
  repository <- Sys.getenv(
    "RRP_CRAN_REPOSITORY", unset = "https://cloud.r-project.org"
  )
  provenance <- Sys.getenv("RRP_DEPENDENCY_PROVENANCE", unset = "")
  build <- run(
    file.path(R.home("bin"), "Rscript"),
    c("--vanilla", file.path(repository_root, "tools", "build-distribution.R"), archive),
    c(
      paste0("RRP_CRAN_REPOSITORY=", repository),
      paste0("RRP_DEPENDENCY_PROVENANCE=", provenance),
      "R_PROFILE_USER=", "R_ENVIRON_USER="
    )
  )
  require_true(build$status == 0L, paste(build$output, collapse = "\n"))
  acquired <- file.path(work, "acquired-outside-git")
  dir.create(acquired)
  utils::untar(archive, exdir = acquired)
  distribution_root <- file.path(acquired, "rrp-1.0.0-dev")
  verified <- rrp_verify_distribution(distribution_root)
  repository <- unique(vapply(
    verified$dependencies[-1L], `[[`, character(1L), "Repository"
  ))
  require_true(length(repository) == 1L, "Distribution repository set is unsupported.")
  cat("PASS copied local acquisition and standalone distribution verification\n")

  host_r <- normalizePath(file.path(R.home("bin"), "R"), winslash = "/", mustWork = TRUE)
  project <- file.path(work, "independent-project")
  dir.create(project)
  writeLines("project-owned", file.path(project, "sentinel.txt"), useBytes = TRUE)
  project_before <- tree_digest(project)

  mismatch_root <- file.path(work, "repository-mismatch-root")
  expect_failure(
    "repository mismatch",
    rrp_install_distribution(
      distribution_root, "https://packages.example.invalid", host_r,
      mismatch_root
    ),
    "repository_mismatch"
  )
  require_true(!dir.exists(mismatch_root),
    "Repository mismatch created installation state.")

  controlled_failures <- c(
    before_restoration = "dependency_restoration",
    before_internal_packages = "internal_package",
    before_verification = "installation_verification",
    before_promotion = "installation_promotion"
  )
  for (stage in names(controlled_failures)) {
    failed_root <- file.path(work, paste0("controlled-", stage))
    expect_failure(
      stage,
      rrp_install_distribution(
        distribution_root, repository, host_r, failed_root,
        failure_stage = stage
      ),
      controlled_failures[[stage]]
    )
    failed_installations <- list.files(
      file.path(failed_root, "installations"), recursive = TRUE,
      all.files = TRUE, no.. = TRUE
    )
    require_true(
      !length(failed_installations) &&
        !length(list.files(file.path(failed_root, "staging"),
          all.files = TRUE, no.. = TRUE)),
      paste(stage, "left promoted or staged state.")
    )
  }

  locked_root <- file.path(work, "locked-root")
  lock_path <- file.path(
    locked_root, "staging", paste0(
      ".lock-", verified$manifest[["Product-Version"]], "-",
      verified$manifest[["Distribution-ID"]]
    )
  )
  dir.create(lock_path, recursive = TRUE)
  expect_failure(
    "installation lock",
    rrp_install_distribution(distribution_root, repository, host_r, locked_root),
    "installation_locked"
  )

  conflict_root <- file.path(work, "conflict-root")
  conflict_destination <- file.path(
    conflict_root, "installations", verified$manifest[["Product-Version"]],
    verified$manifest[["Distribution-ID"]]
  )
  dir.create(conflict_destination, recursive = TRUE)
  writeLines("conflict", file.path(conflict_destination, "INSTALLATION.dcf"))
  expect_failure(
    "existing conflict",
    rrp_install_distribution(
      distribution_root, repository, host_r, conflict_root
    ),
    "installation_conflict"
  )
  require_true(identical(
    readLines(file.path(conflict_destination, "INSTALLATION.dcf")), "conflict"
  ), "Installation conflict altered existing content.")
  cat("PASS repository, failure-cleanup, and conflict safeguards\n")

  installation_root <- file.path(work, "isolated-user-data")
  ambient_user <- file.path(work, "ambient-user-library")
  ambient_site <- file.path(work, "ambient-site-library")
  dir.create(ambient_user)
  dir.create(ambient_site)
  write_ambient_package(ambient_user, "DBI", "0.0.0")
  write_ambient_package(ambient_site, "rrpplatform", "9.9.9")
  profile <- file.path(work, "poison-profile.R")
  environ <- file.path(work, "poison-environ")
  writeLines("stop('user profile was evaluated')", profile, useBytes = TRUE)
  writeLines("RRP_INSTALL_TEST_FAILURE=before_restoration", environ,
    useBytes = TRUE)
  bootstrap <- run(
    file.path(R.home("bin"), "Rscript"),
    c(
      "--vanilla", file.path(distribution_root, "install.R"),
      "--repository", repository,
      "--installation-root", installation_root
    ),
    c(
      paste0("R_LIBS=", ambient_user),
      paste0("R_LIBS_USER=", ambient_user),
      paste0("R_LIBS_SITE=", ambient_site),
      paste0("R_PROFILE_USER=", profile), paste0("R_ENVIRON_USER=", environ),
      "RENV_CONFIG_CACHE_ENABLED=TRUE",
      "RRP_INSTALL_TEST_FAILURE=before_restoration"
    )
  )
  require_true(bootstrap$status == 0L, paste(bootstrap$output, collapse = "\n"))
  installation_root <- rrp_install_normalize_root(installation_root)
  destination <- file.path(
    installation_root, "installations",
    verified$manifest[["Product-Version"]], verified$manifest[["Distribution-ID"]]
  )
  record <- rrp_install_dcf(file.path(destination, "INSTALLATION.dcf"), "record")[[1L]]
  rrp_install_validate_record(record)
  require_true(
    identical(record[["Resource-Root"]], destination) &&
      identical(record[["Private-Library"]], file.path(destination, "library")) &&
      identical(record[["Host-R-Executable"]], host_r) &&
      !file.exists(file.path(installation_root, "active.dcf")) &&
      !dir.exists(file.path(project, "renv")) &&
      !file.exists(file.path(project, "renv.lock")) &&
      !dir.exists(file.path(destination, "library", "renv")) &&
      identical(project_before, tree_digest(project)) &&
      !length(list.files(file.path(installation_root, "staging"),
        all.files = TRUE, no.. = TRUE)),
    "Installed realization, project isolation, activation, or cleanup disagrees."
  )
  entries <- rrp_tree_entries(destination)
  require_true(!any(vapply(entries, `[[`, logical(1L), "link")),
    "Installed realization contains a symbolic link.")
  installed <- installed.packages(lib.loc = file.path(destination, "library"),
    noCache = TRUE)
  expected <- c(
    vapply(verified$dependencies[-1L], `[[`, character(1L), "Package"),
    "rrpruntime", "rrpplatform"
  )
  require_true(setequal(rownames(installed), expected),
    "Installed private package closure disagrees.")
  cat("PASS base-R bootstrap, exact private restoration, isolation, and promotion\n")

  launcher_environment <- c(
    paste0("RRP_R_EXECUTABLE=", host_r),
    paste0("RRP_PRIVATE_LIBRARY=", file.path(destination, "library")),
    paste0("RRP_SOFTWARE_ROOT=", destination),
    paste0("R_LIBS=", ambient_user),
    paste0("R_LIBS_USER=", ambient_user),
    paste0("R_LIBS_SITE=", ambient_site),
    paste0("R_PROFILE_USER=", profile), paste0("R_ENVIRON_USER=", environ),
    "RENV_CONFIG_CACHE_ENABLED=TRUE",
    "RRP_INSTALL_TEST_FAILURE=before_restoration"
  )
  cli <- run(
    file.path(destination, "bin", "rrp"),
    c(
      "software", "install", distribution_root, "--repository", repository,
      "--installation-root", installation_root, "--json"
    ),
    launcher_environment
  )
  require_true(
    cli$status == 0L &&
      grepl('"operation_id":"rrp.software-install"',
        paste(cli$output, collapse = "\n"), fixed = TRUE) &&
      grepl('"reused":true', paste(cli$output, collapse = "\n"), fixed = TRUE),
    paste("Installed CLI exact reinstall failed:", paste(cli$output, collapse = "\n"))
  )
  record_after <- rrp_install_dcf(file.path(destination, "INSTALLATION.dcf"), "record")[[1L]]
  require_true(
    identical(record, record_after) && identical(project_before, tree_digest(project)),
    "CLI reinstall changed immutable installation or project content."
  )
  cat("PASS bootstrap/CLI shared-engine equivalence and idempotent exact reinstall\n")

  cat("Result: PASS (bootstrap installation and private restoration)\n")
  invisible(TRUE)
}

passed <- tryCatch({ validate_installation(); TRUE }, error = function(condition) {
  cat("Result: FAIL\n", conditionMessage(condition), "\n", file = stderr())
  FALSE
})
if (!passed) quit(save = "no", status = 1L, runLast = FALSE)
