#!/usr/bin/env Rscript

# Full clean installed-operation proof. This deliberately performs one real
# configured-repository RRP restoration and reuses its side-by-side
# realizations for installation, project operation, installed and standalone
# applications, diagnosis, compatibility, rollback, and exact-uninstall
# evidence. Increment 12.C also restores the standalone app's smaller declared
# closure into a separate clean library.

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

run_in <- function(command, arguments, environment, directory) {
  previous <- setwd(directory)
  on.exit(setwd(previous), add = TRUE)
  run(command, arguments, environment)
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

tree_change_summary <- function(before, after) {
  before_names <- names(before)
  after_names <- names(after)
  common <- intersect(before_names, after_names)
  changed <- common[before[common] != after[common]]
  paste0(
    "added=", length(setdiff(after_names, before_names)),
    ", removed=", length(setdiff(before_names, after_names)),
    ", changed=", length(changed)
  )
}

require_tree_unchanged <- function(label, before, after) {
  require_true(
    identical(before, after),
    paste0(label, " changed (", tree_change_summary(before, after), ").")
  )
}

tree_digest_outside_managed_data <- function(root) {
  digest <- tree_digest(root)
  digest[!startsWith(names(digest), "rrp-data/")]
}

path_is_within <- function(path, parent) {
  path <- normalizePath(path, winslash = "/", mustWork = TRUE)
  parent <- normalizePath(parent, winslash = "/", mustWork = TRUE)
  identical(path, parent) || startsWith(path, paste0(parent, "/"))
}

read_file_bytes <- function(path) {
  readBin(path, "raw", n = file.info(path, extra_cols = FALSE)$size[[1L]])
}

require_run_success <- function(label, result) {
  require_true(
    identical(result$status, 0L),
    paste0(label, " failed with exit status ", result$status, ":\n",
      paste(result$output, collapse = "\n"))
  )
}

require_run_text <- function(label, result, expected) {
  require_true(
    grepl(expected, paste(result$output, collapse = "\n"), fixed = TRUE),
    paste0(label, " did not report the expected bounded identity:\n",
      paste(result$output, collapse = "\n"))
  )
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

  damaged_distribution <- file.path(work, "damaged-copied-distribution")
  rrp_install_copy_tree(distribution_root, damaged_distribution)
  damaged_notice <- file.path(damaged_distribution, "NOTICE")
  write("damaged copied payload", damaged_notice, append = TRUE)
  expect_failure(
    "damaged copied distribution",
    rrp_verify_distribution(damaged_distribution),
    "Integrity failed"
  )
  cat("PASS damaged copied distribution fails standalone verification\n")

  alternate_source <- file.path(work, "alternate-development-source")
  authority <- distribution_source_authority(repository_root)
  resources <- distribution_resource_authority(repository_root)
  alternate_paths <- sort(unique(c(
    authority$source_paths, resources$source_paths,
    "distribution/source-inclusion.dcf", "tools/distribution-lib.R",
    "tools/build-distribution.R"
  )), method = "radix")
  for (relative in alternate_paths) distribution_copy(
    file.path(repository_root, relative), file.path(alternate_source, relative),
    identical(relative, "tools/build-distribution.R") ||
      identical(relative, "packages/rrpplatform/exec/rrp") ||
      identical(relative, "distribution/verify-distribution.R") ||
      identical(relative, "distribution/install.R") ||
      identical(relative, "distribution/rrp-shim")
  )
  alternate_readme <- file.path(
    alternate_source, "packages", "rrpplatform", "README.md"
  )
  writeLines(c(
    readLines(alternate_readme, warn = FALSE, encoding = "UTF-8"), "",
    "Controlled newer development identity with project API 0.4.0."
  ), alternate_readme, useBytes = TRUE)
  alternate_manifest <- file.path(
    alternate_source, "resources", "contracts", "project-manifest.dcf"
  )
  manifest_lines <- readLines(alternate_manifest, warn = FALSE, encoding = "UTF-8")
  require_true(
    identical(sum(manifest_lines == "Project-API-Version: 0.3.0"), 1L),
    "Controlled newer fixture did not find the exact project API authority."
  )
  manifest_lines[manifest_lines == "Project-API-Version: 0.3.0"] <-
    "Project-API-Version: 0.4.0"
  writeLines(manifest_lines, alternate_manifest, useBytes = TRUE)
  alternate_contracts <- file.path(
    alternate_source, "packages", "rrpplatform", "R", "project-contracts.R"
  )
  contract_lines <- readLines(alternate_contracts, warn = FALSE, encoding = "UTF-8")
  old_api <- '    "Project-API-Version" = "0.3.0",'
  require_true(
    identical(sum(contract_lines == old_api), 1L),
    "Controlled newer fixture did not find the package project API expectation."
  )
  contract_lines[contract_lines == old_api] <-
    '    "Project-API-Version" = "0.4.0",'
  writeLines(contract_lines, alternate_contracts, useBytes = TRUE)
  alternate_archive <- file.path(work, "alternate-distribution.tar")
  alternate_build <- run(
    file.path(R.home("bin"), "Rscript"),
    c(
      "--vanilla", file.path(alternate_source, "tools", "build-distribution.R"),
      alternate_archive
    ),
    c(
      paste0("RRP_CRAN_REPOSITORY=", repository),
      paste0("RRP_DEPENDENCY_PROVENANCE=", provenance),
      "R_PROFILE_USER=", "R_ENVIRON_USER="
    )
  )
  require_true(
    alternate_build$status == 0L,
    paste("Alternate development build failed:", paste(
      alternate_build$output, collapse = "\n"
    ))
  )
  alternate_acquired <- file.path(work, "alternate-acquired")
  dir.create(alternate_acquired)
  utils::untar(alternate_archive, exdir = alternate_acquired)
  alternate_distribution <- file.path(alternate_acquired, "rrp-1.0.0-dev")
  alternate_verified <- rrp_verify_distribution(alternate_distribution)
  require_true(
    !identical(
      alternate_verified$manifest[["Distribution-ID"]],
      verified$manifest[["Distribution-ID"]]
    ) && identical(
      alternate_verified$manifest[["Dependency-Specification-ID"]],
      verified$manifest[["Dependency-Specification-ID"]]
    ),
    "Controlled alternate development identity is not distinct and compatible."
  )

  host_r <- normalizePath(file.path(R.home("bin"), "R"), winslash = "/", mustWork = TRUE)
  host_rscript <- normalizePath(
    file.path(dirname(host_r), "Rscript"), winslash = "/", mustWork = TRUE
  )
  exact_host <- c(
    version = verified$manifest[["Target-R-Version"]],
    platform = verified$manifest[["Target-Platform"]],
    architecture = verified$manifest[["Target-Architecture"]],
    executable = host_r
  )
  require_true(identical(
    rrp_install_target(
      verified$manifest, verified$artifact, verified$dependencies,
      exact_host, repository
    ),
    "exact_build_target_unqualified"
  ), "Exact build target was not classified as unqualified exact-target use.")
  varied_host <- exact_host
  varied_host[["version"]] <- "4.99.0"
  provenance_before <- unname(verified$manifest[c(
    "Target-R-Version", "Target-Platform", "Target-Architecture"
  )])
  require_true(identical(
    rrp_install_target(
      verified$manifest, verified$artifact, verified$dependencies,
      varied_host, repository
    ),
    "eligible_best_effort"
  ) && identical(provenance_before, unname(verified$manifest[c(
    "Target-R-Version", "Target-Platform", "Target-Architecture"
  )])), "Eligible R variation changed build provenance or classification.")
  old_host <- exact_host
  old_host[["version"]] <- "4.3.99"
  expect_failure(
    "below-minimum host R",
    rrp_install_target(
      verified$manifest, verified$artifact, verified$dependencies,
      old_host, repository
    ),
    "below the technical minimum"
  )
  wrong_platform <- exact_host
  wrong_platform[["platform"]] <- "wrong-platform"
  expect_failure(
    "cross-platform host",
    rrp_install_target(
      verified$manifest, verified$artifact, verified$dependencies,
      wrong_platform, repository
    ),
    "incompatible_host_platform"
  )
  wrong_architecture <- exact_host
  wrong_architecture[["architecture"]] <- "wrong-architecture"
  expect_failure(
    "cross-architecture host",
    rrp_install_target(
      verified$manifest, verified$artifact, verified$dependencies,
      wrong_architecture, repository
    ),
    "incompatible_host_architecture"
  )
  cat("PASS exact-target and bounded best-effort environment-eligibility contract\n")

  incompatible_host <- file.path(work, "incompatible-host-r")
  writeLines(c(
    "#!/bin/sh",
    "printf '0.0.0\\nwrong-platform\\nwrong-architecture\\n%s\\n' \"$0\""
  ), incompatible_host, useBytes = TRUE)
  Sys.chmod(incompatible_host, mode = "0755", use_umask = FALSE)
  expect_failure(
    "incompatible host R",
    rrp_install_distribution(
      distribution_root, repository, incompatible_host,
      file.path(work, "incompatible-host-root")
    ),
    "incompatible_host_platform"
  )
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
  official_version_root <- file.path(work, "official-version", "1.0.0")
  dir.create(file.path(official_version_root, paste(rep("a", 64L), collapse = "")),
    recursive = TRUE)
  official_manifest <- verified$manifest
  official_manifest[["Product-Version"]] <- "1.0.0"
  official_manifest[["Development-Version"]] <- "1.0.0-dev"
  official_manifest[["Distribution-ID"]] <- paste(rep("b", 64L), collapse = "")
  expect_failure(
    "published version identity conflict",
    rrp_install_assert_version_identity(official_manifest, official_version_root),
    "published_version_conflict"
  )
  official_manifest[["Distribution-ID"]] <- paste(rep("a", 64L), collapse = "")
  rrp_install_assert_version_identity(official_manifest, official_version_root)
  official_staging <- file.path(work, "official-lock", "staging")
  dir.create(official_staging, recursive = TRUE)
  official_lock <- rrp_install_version_lock(official_manifest, official_staging)
  require_true(dir.exists(official_lock),
    "Published-version serialization lock was not created.")
  expect_failure(
    "published version serialization lock",
    rrp_install_version_lock(official_manifest, official_staging),
    "published_version_locked"
  )
  unlink(official_lock, recursive = TRUE, force = TRUE)
  development_manifest <- official_manifest
  development_manifest[["Product-Version"]] <- "1.0.0-dev"
  development_manifest[["Development-Version"]] <- "1.0.0-dev"
  development_manifest[["Distribution-ID"]] <- paste(rep("c", 64L), collapse = "")
  rrp_install_assert_version_identity(development_manifest, official_version_root)
  require_true(
    is.null(rrp_install_version_lock(development_manifest, official_staging)),
    "Development installation unexpectedly acquired a published-version lock."
  )
  cat("PASS repository, failure-cleanup, and version-identity safeguards\n")

  installation_root <- file.path(work, "isolated-user-data")
  executable_root <- file.path(work, "isolated-user-bin")
  ambient_user <- file.path(work, "ambient-user-library")
  ambient_site <- file.path(work, "ambient-site-library")
  user_home <- file.path(work, "isolated-user-home")
  user_config <- file.path(work, "isolated-user-config")
  user_cache <- file.path(work, "isolated-user-cache")
  process_temporary <- file.path(work, "isolated-process-temporary")
  local_app_data <- file.path(work, "isolated-local-app-data")
  dir.create(user_home)
  dir.create(user_config)
  dir.create(user_cache)
  dir.create(process_temporary)
  dir.create(local_app_data)
  dir.create(ambient_user)
  dir.create(ambient_site)
  write_ambient_package(ambient_user, "DBI", "0.0.0")
  write_ambient_package(ambient_site, "rrpplatform", "9.9.9")
  profile <- file.path(work, "poison-profile.R")
  environ <- file.path(work, "poison-environ")
  writeLines("stop('user profile was evaluated')", profile, useBytes = TRUE)
  writeLines("RRP_INSTALL_TEST_FAILURE=before_restoration", environ,
    useBytes = TRUE)
  writeLines("stop('home profile was evaluated')",
    file.path(user_home, ".Rprofile"), useBytes = TRUE)
  writeLines("RRP_INSTALL_TEST_FAILURE=before_restoration",
    file.path(user_home, ".Renviron"), useBytes = TRUE)
  isolated_environment <- c(
    paste0("HOME=", user_home), paste0("XDG_DATA_HOME=", installation_root),
    paste0("XDG_CONFIG_HOME=", user_config),
    paste0("XDG_CACHE_HOME=", user_cache),
    paste0("LOCALAPPDATA=", local_app_data),
    paste0("TMPDIR=", process_temporary)
  )
  bootstrap <- run_in(
    file.path(R.home("bin"), "Rscript"),
    c(
      "--vanilla", file.path(distribution_root, "install.R"),
      "--repository", repository,
      "--installation-root", installation_root,
      "--executable-root", executable_root
    ),
    c(isolated_environment,
      paste0("R_LIBS=", ambient_user),
      paste0("R_LIBS_USER=", ambient_user),
      paste0("R_LIBS_SITE=", ambient_site),
      paste0("R_PROFILE_USER=", profile), paste0("R_ENVIRON_USER=", environ),
      "RENV_CONFIG_CACHE_ENABLED=TRUE",
      "RRP_INSTALL_TEST_FAILURE=before_restoration"
    ), project
  )
  require_true(bootstrap$status == 0L, paste(bootstrap$output, collapse = "\n"))
  installation_root <- rrp_install_normalize_root(installation_root)
  destination <- file.path(
    installation_root, "installations",
    verified$manifest[["Product-Version"]], verified$manifest[["Distribution-ID"]]
  )
  record <- rrp_install_dcf(file.path(destination, "INSTALLATION.dcf"), "record")[[1L]]
  rrp_install_validate_record(record)
  library_inventory <- rrp_install_dcf(
    file.path(destination, record[["Private-Library-Inventory-Path"]]),
    "library_inventory"
  )
  require_true(
    identical(record[["Contract-Version"]], "0.2.0") &&
      identical(
        record[["Private-Library-Inventory-Digest"]],
        rrp_sha256(file.path(
          destination, record[["Private-Library-Inventory-Path"]]
        ))
      ) && length(library_inventory) > 1L &&
      identical(record[["Resource-Root"]], destination) &&
      identical(record[["Private-Library"]], file.path(destination, "library")) &&
      identical(record[["Host-R-Executable"]], host_r) &&
      !file.exists(file.path(installation_root, "active.dcf")) &&
      file.exists(file.path(executable_root, "rrp")) &&
      file.access(file.path(executable_root, "rrp"), 1L) == 0L &&
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
  private_entries <- list.files(
    file.path(destination, "library"), all.files = TRUE, full.names = TRUE,
    recursive = TRUE, include.dirs = TRUE, no.. = TRUE
  )
  representative_regular <- private_entries[
    !dir.exists(private_entries) & vapply(private_entries, function(path) {
      isTRUE(file_test("-f", path))
    }, logical(1L))
  ]
  representative_directories <- c(
    file.path(destination, "library"), private_entries[dir.exists(private_entries)]
  )
  require_true(
    length(representative_regular) > 0L &&
      all(file.access(representative_regular, 2L) == 0L) &&
      all(file.access(representative_directories, 2L) == 0L) &&
      file.access(file.path(destination, "bin", "rrp"), 1L) == 0L &&
      file.access(file.path(destination, "install.R"), 1L) == 0L,
    "Installed package permissions are not conventional owner-writable R permissions."
  )
  inventory_files <- library_inventory[-1L]
  inventory_paths <- vapply(inventory_files, `[[`, character(1L), "Path")
  inventory_hash_time <- system.time({
    regenerated_hashes <- rrp_install_sha256_many(file.path(
      destination, "library", inventory_paths
    ))
  })[["elapsed"]]
  require_true(
    identical(
      regenerated_hashes,
      vapply(inventory_files, `[[`, character(1L), "SHA256")
    ),
    "Regenerated private-library hashes disagree with installation evidence."
  )
  strict_verify_time <- system.time(
    rrp_install_verify_library_inventory(destination, record)
  )[["elapsed"]]
  cat(sprintf(
    "PASS conventional permissions and %d-file inventory (hash %.2fs; strict %.2fs)\n",
    length(inventory_files), inventory_hash_time, strict_verify_time
  ))
  cat("PASS base-R bootstrap, exact private restoration, isolation, and promotion\n")

  integrity_script <- file.path(work, "installed-integrity-probe.R")
  writeLines(c(
    sprintf("private <- %s", deparse(file.path(destination, "library"))),
    sprintf("root <- %s", deparse(destination)),
    "source(file.path(root,'install-engine.R'),local=TRUE)",
    ".libPaths(c(private,.Library))",
    "library(rrpplatform)",
    "internal <- function(name) getFromNamespace(name,'rrpplatform')",
    "records <- internal('rrp_software_read_dcf')(file.path(root,'dependencies','dependencies.dcf'))",
    "packages <- records[-1L]",
    "expected <- setNames(sub('^renv:','',vapply(packages,`[[`,character(1L),'Integrity')),vapply(packages,`[[`,character(1L),'Package'))",
    "runtime_actual <- vapply(names(expected),function(package) internal('rrp_software_description_hash')(file.path(private,package,'DESCRIPTION')),character(1L))",
    "installer_actual <- vapply(names(expected),function(package) rrp_install_description_hash(file.path(private,package,'DESCRIPTION')),character(1L))",
    "stopifnot(identical(runtime_actual,installer_actual))",
    "mismatch <- names(expected)[runtime_actual != expected]",
    "if (length(mismatch)) stop(paste('dependency integrity mismatch:',paste(mismatch,collapse=',')),call.=FALSE)",
    "fixture <- tempfile('damaged-description-')",
    "on.exit(unlink(fixture,force=TRUE),add=TRUE)",
    "fixture_lines <- readLines(file.path(private,names(expected)[[1L]],'DESCRIPTION'),warn=FALSE,encoding='UTF-8')",
    "title <- grep('^Title:',fixture_lines)",
    "stopifnot(length(title)==1L)",
    "fixture_lines[[title]] <- paste(fixture_lines[[title]],'damaged')",
    "writeLines(fixture_lines,fixture,useBytes=TRUE)",
    "damaged_installer <- rrp_install_description_hash(fixture)",
    "damaged_runtime <- internal('rrp_software_description_hash')(fixture)",
    "stopifnot(identical(damaged_installer,damaged_runtime),!identical(damaged_installer,unname(expected[[1L]])))",
    "cat('integrity-probe-ok\\n')"
  ), integrity_script, useBytes = TRUE)
  integrity_probe <- run_in(
    host_r, c(
      "--vanilla", "--slave", paste0("--file=", shQuote(integrity_script))
    ),
    c(
      "LC_ALL=C",
      paste0("R_LIBS_USER=", file.path(destination, "library")),
      "R_LIBS_SITE="
    ), project
  )
  require_true(
    integrity_probe$status == 0L &&
      identical(integrity_probe$output, "integrity-probe-ok"),
    paste("Installed dependency integrity probe failed:",
      paste(integrity_probe$output, collapse = "\n"))
  )

  stable_launcher <- file.path(executable_root, "rrp")
  selector <- paste(
    verified$manifest[["Product-Version"]],
    verified$manifest[["Distribution-ID"]], sep = "/"
  )
  stable_run <- function(arguments, directory = work) {
    old <- setwd(directory)
    on.exit(setwd(old), add = TRUE)
    run(
      "/bin/sh", c(shQuote(stable_launcher), vapply(
        arguments, shQuote, character(1L)
      )), c(isolated_environment,
        paste0("R_LIBS=", ambient_user),
        paste0("R_LIBS_USER=", ambient_user),
        paste0("R_LIBS_SITE=", ambient_site),
        paste0("R_PROFILE_USER=", profile), paste0("R_ENVIRON_USER=", environ)
      )
    )
  }
  json_string <- function(result, field) {
    output <- paste(result$output, collapse = "\n")
    pattern <- paste0('"', field, '":"([^"]+)"')
    matches <- regmatches(output, gregexpr(pattern, output, perl = TRUE))[[1L]]
    require_true(length(matches) >= 1L, paste("Missing JSON field", field))
    sub(pattern, "\\1", matches[[1L]], perl = TRUE)
  }
  version_run <- function(transport, transport_selector, arguments,
                          directory = work) {
    transport_record <- rrp_install_dcf(
      file.path(transport, "INSTALLATION.dcf"), "record"
    )[[1L]]
    old <- setwd(directory)
    on.exit(setwd(old), add = TRUE)
    run(
      "/bin/sh", c(shQuote(file.path(transport, "bin", "rrp")), vapply(
        arguments, shQuote, character(1L)
      )), c(isolated_environment,
        paste0("RRP_R_EXECUTABLE=", transport_record[["Host-R-Executable"]]),
        paste0("RRP_PRIVATE_LIBRARY=", transport_record[["Private-Library"]]),
        paste0("RRP_SOFTWARE_ROOT=", transport),
        paste0("RRP_INSTALLATION_ROOT=", installation_root),
        paste0("RRP_SELECTED_SOFTWARE_SELECTOR=", transport_selector),
        "RRP_SELECTION_MODE=transport_only",
        paste0("RRP_STABLE_SHIM=", stable_launcher),
        paste0("R_LIBS=", ambient_user),
        paste0("R_LIBS_USER=", ambient_user),
        paste0("R_LIBS_SITE=", ambient_site),
        paste0("R_PROFILE_USER=", profile), paste0("R_ENVIRON_USER=", environ)
      )
    )
  }
  before_activation <- stable_run(c("software", "current", "--json"), project)
  listed <- stable_run(c("software", "list", "--json"), project)
  diagnosed <- stable_run(c("software", "doctor", "--json"), project)
  verified_cli <- stable_run(c(
    "software", "verify", "--software", selector, "--json"
  ), project)
  require_true(
    all(vapply(list(before_activation, listed, diagnosed, verified_cli),
      function(value) value$status == 0L, logical(1L))) &&
      grepl('"active":false', paste(before_activation$output, collapse = "\n"),
        fixed = TRUE) &&
      grepl('"status":"verified"', paste(listed$output, collapse = "\n"),
        fixed = TRUE) &&
      grepl('"software_status":"ready_with_warnings"',
        paste(diagnosed$output, collapse = "\n"), fixed = TRUE) &&
      grepl('"software_status":"ready"',
        paste(verified_cli$output, collapse = "\n"), fixed = TRUE) &&
      identical(project_before, tree_digest(project)),
    paste("Pre-activation lifecycle proof failed:", paste(c(
      before_activation$output, listed$output, diagnosed$output,
      verified_cli$output
    ), collapse = "\n"))
  )
  tamper_candidates <- inventory_paths[grepl(
    "(^|/)(AnIndex|LICENSE|LICENCE|NEWS(?:[.]md)?)$",
    inventory_paths, perl = TRUE
  )]
  require_true(length(tamper_candidates) > 0L,
    "No safe arbitrary library-file tamper fixture is available.")
  tamper_path <- file.path(
    destination, "library", tamper_candidates[[1L]]
  )
  tamper_bytes <- readBin(tamper_path, "raw", n = file.info(tamper_path)$size)
  connection <- file(tamper_path, open = "ab")
  writeBin(charToRaw("\n11-i-library-tamper\n"), connection)
  close(connection)
  structural_during_tamper <- stable_run(c(
    "--software", selector, "version", "--json"
  ), project)
  tampered_verify <- stable_run(c(
    "software", "verify", "--software", selector, "--json"
  ), project)
  connection <- file(tamper_path, open = "wb")
  writeBin(tamper_bytes, connection)
  close(connection)
  recovered_after_tamper <- stable_run(c(
    "software", "verify", "--software", selector, "--json"
  ), project)

  missing_fixture <- tempfile("rrp-library-missing-", tmpdir = work)
  require_true(file.rename(tamper_path, missing_fixture),
    "Could not create missing library-file fixture.")
  missing_verify <- stable_run(c(
    "software", "verify", "--software", selector, "--json"
  ), project)
  require_true(file.rename(missing_fixture, tamper_path),
    "Could not restore missing library-file fixture.")

  additional_path <- file.path(
    destination, "library", "rrpplatform", "11-i-unrecorded.txt"
  )
  writeLines("unrecorded", additional_path, useBytes = TRUE)
  additional_verify <- stable_run(c(
    "software", "verify", "--software", selector, "--json"
  ), project)
  unlink(additional_path, force = TRUE)

  library_link <- file.path(
    destination, "library", "rrpplatform", "11-i-linked.txt"
  )
  link_created <- isTRUE(file.symlink(tamper_path, library_link))
  linked_verify <- if (link_created) stable_run(c(
    "software", "verify", "--software", selector, "--json"
  ), project) else NULL
  if (link_created) unlink(library_link, force = TRUE)

  inventory_path <- file.path(
    destination, record[["Private-Library-Inventory-Path"]]
  )
  inventory_bytes <- readBin(
    inventory_path, "raw", n = file.info(inventory_path)$size
  )
  connection <- file(inventory_path, open = "ab")
  writeBin(charToRaw("\n"), connection)
  close(connection)
  damaged_inventory <- stable_run(c(
    "software", "verify", "--software", selector, "--json"
  ), project)
  connection <- file(inventory_path, open = "wb")
  writeBin(inventory_bytes, connection)
  close(connection)

  installation_record_path <- file.path(destination, "INSTALLATION.dcf")
  installation_record_bytes <- readBin(
    installation_record_path, "raw", n = file.info(installation_record_path)$size
  )
  legacy_record <- record[!names(record) %in% c(
    "Private-Library-Inventory-Path", "Private-Library-Inventory-Digest"
  )]
  legacy_record[["Contract-Version"]] <- "0.1.0"
  rrp_install_write_dcf(legacy_record, installation_record_path)
  legacy_verify <- stable_run(c(
    "software", "verify", "--software", selector, "--json"
  ), project)
  connection <- file(installation_record_path, open = "wb")
  writeBin(installation_record_bytes, connection)
  close(connection)
  final_inventory_recovery <- stable_run(c(
    "software", "verify", "--software", selector, "--json"
  ), project)
  adversarial_results <- list(
    tampered_verify, missing_verify, additional_verify
  )
  require_true(
    structural_during_tamper$status == 0L &&
      all(vapply(adversarial_results, function(value) {
        value$status == 1L && grepl(
          "installed_library_integrity", paste(value$output, collapse = "\n"),
          fixed = TRUE
        )
      }, logical(1L))) && (!link_created || (
        linked_verify$status %in% c(1L, 3L) && grepl(
          "linked_installed_software", paste(linked_verify$output, collapse = "\n"),
          fixed = TRUE
        )
      )) &&
      recovered_after_tamper$status == 0L &&
      damaged_inventory$status %in% c(1L, 3L) && grepl(
        "invalid_library_inventory", paste(
          damaged_inventory$output, collapse = "\n"
        ), fixed = TRUE
      ) && legacy_verify$status %in% c(1L, 3L) && grepl(
        "incomplete_library_integrity_evidence", paste(
          legacy_verify$output, collapse = "\n"
        ), fixed = TRUE
      ) && final_inventory_recovery$status == 0L &&
      identical(project_before, tree_digest(project)),
    paste("Installed-library adversarial verification failed:", paste(c(
      structural_during_tamper$output,
      unlist(lapply(adversarial_results, `[[`, "output"), use.names = FALSE),
      if (link_created) linked_verify$output else character(),
      damaged_inventory$output, legacy_verify$output,
      final_inventory_recovery$output
    ), collapse = "\n"))
  )
  cat(paste(
    "PASS closed library inventory rejects changed, missing, added, linked,",
    "damaged-evidence, and legacy-record cases\n"
  ))
  activated <- stable_run(c("software", "activate", selector, "--json"), project)
  reactivated <- stable_run(c("software", "activate", selector, "--json"), project)
  current <- stable_run(c("software", "current", "--json"), project)
  current_human <- stable_run(c("software", "current"), project)
  healthy_doctor <- stable_run(c("software", "doctor", "--json"), project)
  healthy_doctor_human <- stable_run(c("software", "doctor"), project)
  version <- stable_run(c("version", "--json"), project)
  explicit <- stable_run(c("--software", selector, "version", "--json"), project)
  active_before_failure <- readBin(
    file.path(installation_root, "active.dcf"), "raw",
    n = file.info(file.path(installation_root, "active.dcf"))$size
  )
  failure_script <- file.path(work, "activation-failure.R")
  writeLines(c(
    sprintf(".libPaths(c(%s,.Library))", deparse(file.path(destination, "library"))),
    "library(rrpplatform)",
    sprintf("root <- %s", deparse(installation_root)),
    sprintf("selector <- %s", deparse(selector)),
    "result <- getFromNamespace('rrp_software_activate','rrpplatform')(root,selector,'after_promotion')",
    "stopifnot(!rrp_operation_succeeded(result))"
  ), failure_script, useBytes = TRUE)
  controlled_activation <- run_in(
    host_rscript, c("--vanilla", shQuote(failure_script)),
    c(paste0("R_LIBS_USER=", file.path(destination, "library")), "R_LIBS_SITE="),
    project
  )
  active_after_failure <- readBin(
    file.path(installation_root, "active.dcf"), "raw",
    n = file.info(file.path(installation_root, "active.dcf"))$size
  )
  require_true(
    activated$status == 0L && reactivated$status == 0L &&
      current$status == 0L && current_human$status == 0L &&
      healthy_doctor$status == 0L && healthy_doctor_human$status == 0L &&
      version$status == 0L && explicit$status == 0L &&
      controlled_activation$status == 0L &&
      grepl('"reused":true', paste(reactivated$output, collapse = "\n"),
        fixed = TRUE) &&
      grepl(paste0('"selector":"', selector, '"'),
        paste(current$output, collapse = "\n"), fixed = TRUE) &&
      grepl(selector, paste(current_human$output, collapse = "\n"),
        fixed = TRUE) &&
      grepl('"software_status":"ready"',
        paste(healthy_doctor$output, collapse = "\n"), fixed = TRUE) &&
      !grepl(normalizePath(project, winslash = "/", mustWork = TRUE), paste(
        c(healthy_doctor$output, healthy_doctor_human$output), collapse = "\n"
      ), fixed = TRUE) &&
      grepl('"selection":"active"', paste(version$output, collapse = "\n"),
        fixed = TRUE) &&
      grepl('"selection":"explicit_override"',
        paste(explicit$output, collapse = "\n"), fixed = TRUE) &&
      identical(active_before_failure, active_after_failure) &&
      identical(project_before, tree_digest(project)),
    "Stable selection, activation, or failure-preservation proof failed."
  )
  signal_script <- file.path(work, "stable-signal-proof.sh")
  writeLines(c(
    "#!/bin/sh",
    "\"$1\" software list --json >/dev/null 2>&1 &",
    "child=$!",
    "sleep 1",
    "kill -TERM \"$child\" 2>/dev/null || exit 1",
    "wait \"$child\"",
    "status=$?",
    "[ \"$status\" -eq 143 ] || [ \"$status\" -eq 130 ]"
  ), signal_script, useBytes = TRUE)
  signal_proof <- run_in(
    "/bin/sh", c(shQuote(signal_script), shQuote(stable_launcher)),
    c(isolated_environment,
      paste0("R_LIBS=", ambient_user),
      paste0("R_LIBS_USER=", ambient_user),
      paste0("R_LIBS_SITE=", ambient_site),
      paste0("R_PROFILE_USER=", profile), paste0("R_ENVIRON_USER=", environ)
    ), project
  )
  require_true(
    signal_proof$status == 0L,
    paste("Stable launcher signal propagation failed:", paste(
      signal_proof$output, collapse = "\n"
    ))
  )
  cat("PASS stable shim, exact selection, verification, doctor, and atomic activation\n")

  retained_project <- file.path(work, "retained-fictional-project")
  first_analytical_time <- "2026-01-20T12:00:00Z"
  second_analytical_time <- "2026-01-21T12:00:00Z"
  reference_initialized <- stable_run(c(
    "reference", "init", retained_project, "--json"
  ), project)
  source_prepared <- stable_run(c(
    "reference", "prepare-source", "--project", retained_project, "--json"
  ), project)
  state_initialized <- stable_run(c(
    "state", "init", "--project", retained_project, "--json"
  ), project)
  retained_run <- stable_run(c(
    "run", "--at", first_analytical_time, "--operation-key", "accepted-first",
    "--project", retained_project, "--json"
  ), project)
  require_true(
    all(vapply(
      list(reference_initialized, source_prepared, state_initialized, retained_run),
      function(value) value$status == 0L, logical(1L)
    )),
    paste("Retained-project setup failed:", paste(c(
      reference_initialized$output, source_prepared$output,
      state_initialized$output, retained_run$output
    ), collapse = "\n"))
  )
  first_scope <- json_string(retained_run, "operation_run_id")
  second_run <- stable_run(c(
    "run", "--at", second_analytical_time, "--operation-key", "accepted-second",
    "--project", retained_project, "--json"
  ), project)
  require_true(
    second_run$status == 0L,
    paste("Second governed run failed:", paste(second_run$output, collapse = "\n"))
  )
  second_scope <- json_string(second_run, "operation_run_id")
  require_true(!identical(first_scope, second_scope),
    "Two analytical times produced the same operation-run identity.")
  retained_products <- stable_run(c(
    "products", "materialize", "--scope", second_scope, "--cutoff",
    second_analytical_time, "--project", retained_project, "--json"
  ), project)
  retained_product_status <- stable_run(c(
    "products", "status", "--scope", second_scope, "--cutoff",
    second_analytical_time, "--project", retained_project, "--json"
  ), project)
  first_history <- stable_run(c(
    "history", "scope", "--scope", first_scope, "--project",
    retained_project, "--json"
  ), project)
  second_history <- stable_run(c(
    "history", "scope", "--scope", second_scope, "--project",
    retained_project, "--json"
  ), project)
  state_inspected <- stable_run(c(
    "state", "inspect", "--project", retained_project, "--json"
  ), project)
  retained_validate <- stable_run(c(
    "project", "validate", "--project", retained_project, "--json"
  ), project)
  project_doctor <- stable_run(c(
    "project", "doctor", "--scope", second_scope, "--cutoff",
    second_analytical_time, "--project", retained_project, "--json"
  ), project)
  project_doctor_human <- stable_run(c(
    "project", "doctor", "--scope", second_scope, "--cutoff",
    second_analytical_time, "--project", retained_project
  ), project)
  project_status <- stable_run(c(
    "project", "status", "--scope", second_scope, "--cutoff",
    second_analytical_time, "--project", retained_project, "--json"
  ), project)
  retained_history_text <- paste(c(
    first_history$output, second_history$output
  ), collapse = "\n")
  require_true(
    all(vapply(list(
      retained_products, retained_product_status, first_history,
      second_history, state_inspected, retained_validate, project_doctor,
      project_doctor_human, project_status
    ), function(value) value$status == 0L, logical(1L))) &&
      grepl(first_analytical_time, paste(first_history$output, collapse = "\n"),
        fixed = TRUE) &&
      grepl(second_analytical_time, paste(second_history$output, collapse = "\n"),
        fixed = TRUE) &&
      grepl(paste0('"source_operation_run_id":"', second_scope, '"'), paste(
        retained_product_status$output, collapse = "\n"
      ), fixed = TRUE) &&
      grepl('"freshness_status":"fresh"', paste(
        retained_product_status$output, collapse = "\n"
      ), fixed = TRUE) &&
      grepl('"product_status":"valid"', paste(
        project_doctor$output, collapse = "\n"
      ), fixed = TRUE) &&
      grepl('"product_freshness":"fresh"', paste(
        project_doctor$output, collapse = "\n"
      ), fixed = TRUE) &&
      grepl('"application_status":"ready"', paste(
        project_status$output, collapse = "\n"
      ), fixed = TRUE) &&
      !grepl(
        "distribution_id|build_id|installation_id|activation",
        retained_history_text, ignore.case = TRUE, perl = TRUE
      ),
    paste("Clean project/history/product/doctor proof failed:", paste(c(
      retained_products$output, retained_product_status$output,
      first_history$output, second_history$output, state_inspected$output,
      retained_validate$output, project_doctor$output,
      project_doctor_human$output, project_status$output
    ), collapse = "\n"))
  )

  port_script <- file.path(work, "installed-random-port.R")
  writeLines(c(
    ".libPaths(c(Sys.getenv('RRP_PRIVATE_LIBRARY'), .Library))",
    "namespace <- loadNamespace('httpuv', lib.loc = Sys.getenv('RRP_PRIVATE_LIBRARY'))",
    "cat(get('randomPort', envir = namespace, inherits = FALSE)())"
  ), port_script, useBytes = TRUE)
  port_result <- run_in(
    host_rscript, c("--vanilla", shQuote(port_script)),
    c(isolated_environment,
      paste0("RRP_PRIVATE_LIBRARY=", file.path(destination, "library")),
      paste0("R_LIBS_USER=", file.path(destination, "library")),
      "R_LIBS_SITE="), project
  )
  app_port <- suppressWarnings(as.integer(if (length(port_result$output)) {
    port_result$output[[1L]]
  } else {
    NA_character_
  }))
  require_true(port_result$status == 0L && length(app_port) == 1L &&
    !is.na(app_port) && app_port >= 1024L && app_port <= 65535L,
    "Could not obtain a bounded loopback application port.")
  app_log <- file.path(work, "installed-app.log")
  app_probe <- file.path(work, "installed-app-probe.R")
  writeLines(c(
    "port <- as.integer(commandArgs(trailingOnly = TRUE)[[1L]])",
    "base <- sprintf('http://127.0.0.1:%d', port)",
    "fetch <- function(path) {",
    "  connection <- url(paste0(base, path), open = 'rb', method = 'libcurl')",
    "  on.exit(close(connection), add = TRUE)",
    "  readBin(connection, what = 'raw', n = 50000000L)",
    "}",
    "started <- Sys.time()",
    "initial <- NULL",
    "for (attempt in seq_len(60L)) {",
    "  initial <- try(suppressWarnings(fetch('/')), silent = TRUE)",
    "  if (!inherits(initial, 'try-error') && length(initial) > 100L) break",
    "  initial <- NULL",
    "  Sys.sleep(1)",
    "}",
    "if (is.null(initial)) quit(status = 1L)",
    "html <- rawToChar(initial)",
    "tags <- regmatches(html, gregexpr(",
    "  '(?:src|href)=[\\\"\\\'][^\\\"\\\']+[\\\"\\\']', html, perl = TRUE",
    "))[[1L]]",
    "assets <- unique(gsub('^(?:src|href)=[\\\"\\\']|[\\\"\\\']$', '', tags, perl = TRUE))",
    "assets <- assets[!grepl('^(?:https?:|//|data:|#)', assets, perl = TRUE)]",
    "assets <- paste0('/', sub('^/', '', assets))",
    "stopifnot(length(assets) > 0L)",
    "asset_paths <- sub('[?#].*$', '', assets)",
    "stopifnot(any(grepl('[.]js$', asset_paths, ignore.case = TRUE)))",
    "stopifnot(any(grepl('[.]css$', asset_paths, ignore.case = TRUE)))",
    "responses <- lapply(assets, function(path) suppressWarnings(fetch(path)))",
    "stopifnot(all(lengths(responses) > 0L))",
    "resolve <- function(base_path, relative) {",
    "  if (startsWith(relative, '/')) return(relative)",
    "  parts <- strsplit(paste(dirname(base_path), relative, sep = '/'), '/', fixed = TRUE)[[1L]]",
    "  result <- character()",
    "  for (part in parts) {",
    "    if (!nzchar(part) || identical(part, '.')) next",
    "    if (identical(part, '..')) { if (length(result)) result <- head(result, -1L) } else result <- c(result, part)",
    "  }",
    "  paste0('/', paste(result, collapse = '/'))",
    "}",
    "css_index <- which(grepl('[.]css$', asset_paths, ignore.case = TRUE))",
    "dependencies <- character()",
    "for (index in css_index) {",
    "  css <- rawToChar(responses[[index]])",
    "  references <- regmatches(css, gregexpr('url[(][^)]*[)]', css, perl = TRUE))[[1L]]",
    "  references <- gsub('^url[(][\\\"\\\']?|[\\\"\\\']?[)]$', '', references, perl = TRUE)",
    "  references <- references[!grepl('^(?:data:|https?:|//|#)', references, perl = TRUE)]",
    "  if (length(references)) dependencies <- c(dependencies, vapply(",
    "    references, resolve, character(1L), base_path = asset_paths[[index]]",
    "  ))",
    "}",
    "dependencies <- unique(dependencies)",
    "if (length(dependencies)) stopifnot(all(vapply(",
    "  dependencies, function(path) length(suppressWarnings(fetch(path))) > 0L, logical(1L)",
    ")))",
    "repeated <- lapply(seq_len(2L), function(index) suppressWarnings(fetch('/')))",
    "stopifnot(all(lengths(repeated) > 100L))",
    "elapsed <- as.numeric(difftime(Sys.time(), started, units = 'secs'))",
    "cat(sprintf('http-probe-ok requests=%d startup_seconds=%.2f\\n',",
    "  3L + length(assets) + length(dependencies), elapsed))"
  ), app_probe, useBytes = TRUE)
  app_supervisor <- file.path(work, "installed-app-supervisor.sh")
  writeLines(c(
    "#!/bin/sh",
    "launcher=$1", "project=$2", "scope=$3", "cutoff=$4", "port=$5", "log=$6",
    "host_rscript=$7", "probe=$8",
    "application_pid=$$",
    "(",
    "  if ! \"$host_rscript\" --vanilla \"$probe\" \"$port\"; then",
    "    echo 'app-supervisor-error=http-probe-failed' >&2",
    "    kill -TERM \"$application_pid\" 2>/dev/null",
    "    exit 1",
    "  fi",
    "  if ! kill -0 \"$application_pid\" 2>/dev/null; then",
    "    echo 'app-supervisor-error=application-exited-before-interrupt' >&2",
    "    exit 1",
    "  fi",
    "  if ! kill -INT \"$application_pid\" 2>/dev/null; then",
    "    echo 'app-supervisor-error=interrupt-delivery-failed' >&2",
    "    exit 1",
    "  fi",
    ") &",
    "exec \"$launcher\" app launch --project \"$project\" --scope \"$scope\" --cutoff \"$cutoff\" --port \"$port\" --json >\"$log\" 2>&1"
  ), app_supervisor, useBytes = TRUE)
  app_before <- tree_digest(retained_project)
  installation_before_app <- tree_digest(destination)
  runtime_temporary_before_app <- tree_digest(process_temporary)
  pre_app_verify <- stable_run(c(
    "software", "verify", "--software", selector, "--json"
  ), project)
  app_launch <- run_in(
    "/bin/sh", c(
      shQuote(app_supervisor), shQuote(stable_launcher),
      shQuote(retained_project), shQuote(second_scope),
      shQuote(second_analytical_time), shQuote(as.character(app_port)),
      shQuote(app_log), shQuote(host_rscript), shQuote(app_probe)
    ), c(isolated_environment,
      paste0("R_LIBS=", ambient_user),
      paste0("R_LIBS_USER=", ambient_user),
      paste0("R_LIBS_SITE=", ambient_site),
      paste0("R_PROFILE_USER=", profile), paste0("R_ENVIRON_USER=", environ)),
    project
  )
  app_output <- if (file.exists(app_log)) paste(
    readLines(app_log, warn = FALSE, encoding = "UTF-8"), collapse = "\n"
  ) else ""
  post_app_verify <- stable_run(c(
    "software", "verify", "--software", selector, "--json"
  ), project)
  require_run_success("Pre-application installed verification", pre_app_verify)
  require_true(
    identical(app_launch$status, 130L),
    paste0(
      "Installed application interrupt did not produce exit 130; status=",
      app_launch$status, ":\n", paste(app_launch$output, collapse = "\n")
    )
  )
  require_run_text(
    "Installed application HTTP probe", app_launch, "http-probe-ok"
  )
  require_true(
    file.exists(app_log), "Installed application log was not created."
  )
  require_true(
    !grepl(
      "permission denied|operation not permitted|sass.*(?:error|failed)|bslib.*(?:error|failed)",
      app_output, ignore.case = TRUE, perl = TRUE
    ),
    paste("Installed application reported a runtime permission or asset error:",
      app_output)
  )
  require_run_success("Post-application installed verification", post_app_verify)
  require_tree_unchanged(
    "Installed software after application", installation_before_app,
    tree_digest(destination)
  )
  require_tree_unchanged(
    "Isolated runtime temporary tree after application",
    runtime_temporary_before_app, tree_digest(process_temporary)
  )
  require_tree_unchanged(
    "Hospital project after application", app_before,
    tree_digest(retained_project)
  )
  runtime_roots <- normalizePath(c(
    distribution_root, destination, installation_root, executable_root,
    retained_project, work
  ), winslash = "/", mustWork = TRUE)
  repository_prefix <- paste0(repository_root, "/")
  require_true(
    all(!startsWith(runtime_roots, repository_prefix)) &&
      !dir.exists(file.path(distribution_root, ".git")) &&
      !dir.exists(file.path(retained_project, ".git")) &&
      !grepl(repository_root, paste(c(
        readLines(file.path(destination, "INSTALLATION.dcf"), warn = FALSE),
        retained_history_text, retained_product_status$output,
        project_doctor$output, app_output
      ), collapse = "\n"), fixed = TRUE),
    "Installed operation retained a source-repository runtime dependency."
  )
  privacy_text <- paste(c(
    retained_history_text, retained_product_status$output,
    project_doctor$output, project_status$output
  ), collapse = "\n")
  require_true(
    !grepl(
      "private-patient|private-episode|source_patient|native_patient|credential|connection_string|crosswalk",
      privacy_text, ignore.case = TRUE, perl = TRUE
    ),
    "Acceptance evidence exposed project-private or source-native content."
  )
  retained_before <- tree_digest(retained_project)
  cat(paste(
    "PASS clean installed two-time project, history, fresh products,",
    "both doctors, and supervised application\n"
  ))

  # Increment 12.C extends this same installed clean-user path. The existing
  # second materialization is the standalone lifecycle's time-1 input; a later
  # third governed run supplies its distinct time-2 refresh input.
  standalone_first_scope <- second_scope
  standalone_first_time <- second_analytical_time
  original_app <- file.path(retained_project, "app")
  state_before_init <- tree_digest(file.path(retained_project, "state"))
  installation_before_init <- tree_digest(destination)
  initialized_app <- stable_run(c(
    "app", "init", "--scope", standalone_first_scope, "--cutoff",
    standalone_first_time, "--project", retained_project, "--json"
  ), project)
  validated_app <- stable_run(c(
    "app", "validate", "--project", retained_project, "--json"
  ), project)
  require_run_success("Installed standalone application initialization", initialized_app)
  require_run_success("Installed standalone application validation", validated_app)
  standalone_first_product_set <- json_string(validated_app, "product_set_id")
  standalone_first_materialization <- json_string(
    validated_app, "materialization_id"
  )
  require_true(
    dir.exists(original_app) &&
      grepl(paste0('"source_operation_run_id":"', standalone_first_scope, '"'),
        paste(validated_app$output, collapse = "\n"), fixed = TRUE) &&
      grepl(paste0('"source_history_cutoff":"', standalone_first_time, '"'),
        paste(validated_app$output, collapse = "\n"), fixed = TRUE),
    "Initialized standalone application does not carry the exact time-1 lineage."
  )
  require_tree_unchanged(
    "Project state during standalone initialization", state_before_init,
    tree_digest(file.path(retained_project, "state"))
  )
  require_tree_unchanged(
    "Installed software during standalone initialization", installation_before_init,
    tree_digest(destination)
  )

  original_before_existing_refusal <- tree_digest(original_app)
  existing_refusal <- stable_run(c(
    "app", "init", "--scope", standalone_first_scope, "--cutoff",
    standalone_first_time, "--project", retained_project, "--json"
  ), project)
  require_true(
    identical(existing_refusal$status, 1L) && grepl(
      "application_destination_exists",
      paste(existing_refusal$output, collapse = "\n"), fixed = TRUE
    ),
    paste("Existing standalone destination was not refused:", paste(
      existing_refusal$output, collapse = "\n"
    ))
  )
  require_tree_unchanged(
    "Existing standalone destination after refusal",
    original_before_existing_refusal, tree_digest(original_app)
  )

  detached_parent <- file.path(work, "detached-standalone-root")
  dir.create(detached_parent)
  detached_app <- file.path(detached_parent, "app")
  rrp_install_copy_tree(original_app, detached_app)
  separation_roots <- c(
    repository_root, retained_project, file.path(retained_project, "state"),
    file.path(retained_project, "state", "products"), distribution_root,
    destination, installation_root, ambient_user, ambient_site
  )
  require_true(
    all(!vapply(separation_roots, function(root) {
      path_is_within(detached_app, root) || path_is_within(root, detached_app)
    }, logical(1L))),
    "Detached application is not canonically separated from an originating root."
  )
  detached_validation <- stable_run(c(
    "app", "validate", "--app", detached_app, "--json"
  ), project)
  require_run_success("Detached standalone application validation", detached_validation)
  require_true(
    identical(json_string(detached_validation, "product_set_id"),
      standalone_first_product_set) &&
      identical(json_string(detached_validation, "materialization_id"),
        standalone_first_materialization),
    "Detached standalone application does not preserve exact time-1 products."
  )
  detached_entries <- list.files(
    detached_app, recursive = TRUE, all.files = TRUE, no.. = TRUE,
    include.dirs = TRUE, full.names = FALSE
  )
  forbidden_paths <- c(
    "register.R", "history.duckdb", ".Renviron", ".Rprofile",
    "project.dcf", "provider.R", "producer.R", "model.rds"
  )
  require_true(
    !any(basename(detached_entries) %in% forbidden_paths) &&
      !any(grepl("(^|/)(state|products|renv/library)(/|$)", detached_entries,
        ignore.case = TRUE, perl = TRUE)),
    "Detached application contains a forbidden analytical or secret-bearing path."
  )
  detached_text_paths <- list.files(
    detached_app, recursive = TRUE, all.files = TRUE, no.. = TRUE,
    full.names = TRUE
  )
  detached_text_paths <- detached_text_paths[!dir.exists(detached_text_paths)]
  detached_text_paths <- detached_text_paths[grepl(
    "(?:[.](?:R|dcf|csv|css|md|json|txt|ya?ml)|/(?:HEAD|NOTICE|LICENSE|DESCRIPTION))$",
    detached_text_paths, ignore.case = TRUE, perl = TRUE
  )]
  detached_text <- paste(unlist(lapply(detached_text_paths, function(path) {
    if (file.info(path, extra_cols = FALSE)$size[[1L]] > 2000000L) return("")
    paste(readLines(path, warn = FALSE, encoding = "UTF-8"), collapse = "\n")
  }), use.names = FALSE), collapse = "\n")
  require_true(
    !grepl(repository_root, detached_text, fixed = TRUE) &&
      !grepl(retained_project, detached_text, fixed = TRUE) &&
      !grepl(destination, detached_text, fixed = TRUE),
    "Detached application retained an originating absolute path."
  )
  detached_initial_digest <- tree_digest(detached_app)
  project_before_detached_runtime <- tree_digest(retained_project)
  installation_before_detached_runtime <- tree_digest(destination)

  standalone_runner <- file.path(work, "standalone-app-runner.R")
  writeLines(c(
    "arguments <- commandArgs(trailingOnly = TRUE)",
    "stopifnot(length(arguments) == 6L)",
    "app <- normalizePath(arguments[[1L]], winslash = '/', mustWork = TRUE)",
    "port <- as.integer(arguments[[2L]])",
    "expected_scope <- arguments[[3L]]",
    "expected_cutoff <- arguments[[4L]]",
    "expected_product_set <- arguments[[5L]]",
    "isolated <- identical(arguments[[6L]], 'isolated')",
    "if (isolated) {",
    "  expected_library <- normalizePath(Sys.getenv('RRP_STANDALONE_LIBRARY'), winslash = '/', mustWork = TRUE)",
    "  effective <- normalizePath(.libPaths(), winslash = '/', mustWork = TRUE)",
    "  allowed <- unique(c(expected_library, normalizePath(.Library, winslash = '/', mustWork = TRUE)))",
    "  stopifnot(identical(effective, allowed))",
    "  packages <- strsplit(Sys.getenv('RRP_STANDALONE_PACKAGES'), ',', fixed = TRUE)[[1L]]",
    "  stopifnot(length(packages) > 0L, !requireNamespace('rrpplatform', quietly = TRUE),",
    "    !requireNamespace('rrpruntime', quietly = TRUE))",
    "  resolved <- vapply(packages, function(package) normalizePath(find.package(package), winslash = '/', mustWork = TRUE), character(1L))",
    "  stopifnot(all(startsWith(resolved, paste0(expected_library, '/'))))",
    "}",
    "stopifnot(!'rrpplatform' %in% loadedNamespaces(), !'rrpruntime' %in% loadedNamespaces())",
    "source_environment <- new.env(parent = baseenv())",
    "for (file in c('application-core.R', 'product-loader.R', 'application-ui.R', 'application-server.R', 'managed-loader.R')) {",
    "  sys.source(file.path(app, 'R', file), envir = source_environment, chdir = FALSE)",
    "}",
    "model <- source_environment$rrp_standalone_application_model(app)",
    "snapshot <- model$product_snapshot",
    "stopifnot(identical(snapshot$source_operation_run_id, expected_scope),",
    "  identical(snapshot$source_history_cutoff, expected_cutoff),",
    "  identical(snapshot$product_set_id, expected_product_set))",
    "values <- model$view_models$overview$distribution",
    "maximum <- if (length(values)) format(max(values), digits = 17L, scientific = FALSE) else 'empty'",
    "cat(sprintf('standalone-model-ok product_set=%s scope=%s cutoff=%s rows=%d maximum=%s mode=%s\\n',",
    "  snapshot$product_set_id, snapshot$source_operation_run_id,",
    "  snapshot$source_history_cutoff, length(values), maximum, arguments[[6L]]))",
    "flush.console()",
    "shiny::runApp(app, host = '127.0.0.1', port = port, launch.browser = FALSE, quiet = TRUE)"
  ), standalone_runner, useBytes = TRUE)
  parse(standalone_runner)
  standalone_supervisor <- file.path(work, "standalone-app-supervisor.sh")
  writeLines(c(
    "#!/bin/sh",
    "host_rscript=$1", "runner=$2", "app=$3", "port=$4", "log=$5",
    "probe=$6", "scope=$7", "cutoff=$8", "product_set=$9", "mode=${10}",
    "application_pid=$$",
    "(",
    "  if ! \"$host_rscript\" --vanilla \"$probe\" \"$port\"; then",
    "    echo 'standalone-supervisor-error=http-probe-failed' >&2",
    "    kill -TERM \"$application_pid\" 2>/dev/null",
    "    exit 1",
    "  fi",
    "  if ! kill -0 \"$application_pid\" 2>/dev/null; then",
    "    echo 'standalone-supervisor-error=application-exited-before-interrupt' >&2",
    "    exit 1",
    "  fi",
    "  kill -INT \"$application_pid\" 2>/dev/null || exit 1",
    ") &",
    "exec \"$host_rscript\" --vanilla \"$runner\" \"$app\" \"$port\" \"$scope\" \"$cutoff\" \"$product_set\" \"$mode\" >\"$log\" 2>&1"
  ), standalone_supervisor, useBytes = TRUE)

  standalone_port <- function(library, environment) {
    result <- run_in(host_rscript, c("--vanilla", shQuote(port_script)), c(
      environment, paste0("RRP_PRIVATE_LIBRARY=", library),
      paste0("R_LIBS_USER=", library),
      paste0("R_LIBS_SITE=", file.path(library, ".rrp-no-site-library"))
    ), project)
    value <- suppressWarnings(as.integer(if (length(result$output)) {
      result$output[[1L]]
    } else NA_character_))
    require_true(result$status == 0L && !is.na(value) && value >= 1024L &&
      value <= 65535L, "Could not obtain a standalone loopback port.")
    value
  }
  run_standalone <- function(label, app, scope, cutoff, product_set, library,
      environment, mode, packages = character()) {
    port <- standalone_port(library, environment)
    log <- file.path(work, paste0(label, ".log"))
    before <- tree_digest(app)
    result <- run_in("/bin/sh", c(
      shQuote(standalone_supervisor), shQuote(host_rscript),
      shQuote(standalone_runner), shQuote(app), shQuote(as.character(port)),
      shQuote(log), shQuote(app_probe), shQuote(scope), shQuote(cutoff),
      shQuote(product_set), shQuote(mode)
    ), c(environment,
      paste0("RRP_STANDALONE_LIBRARY=", if (identical(mode, "isolated")) library else ""),
      paste0("RRP_STANDALONE_PACKAGES=", paste(packages, collapse = ","))
    ), detached_parent)
    output <- if (file.exists(log)) paste(
      readLines(log, warn = FALSE, encoding = "UTF-8"), collapse = "\n"
    ) else ""
    conventional_interrupt <- identical(result$status, 130L) ||
      identical(result$status, 1L) && grepl(
        "Execution halted", output, fixed = TRUE
      )
    require_true(conventional_interrupt, paste0(
      label, " did not report a conventional foreground interrupt; status=",
      result$status,
      ":\n", paste(result$output, collapse = "\n"), "\n", output
    ))
    require_run_text(label, result, "http-probe-ok")
    require_true(
      grepl(paste0("standalone-model-ok product_set=", product_set,
        " scope=", scope, " cutoff=", cutoff), output, fixed = TRUE) &&
        !grepl("permission denied|operation not permitted|sass.*(?:error|failed)|bslib.*(?:error|failed)",
          output, ignore.case = TRUE, perl = TRUE),
      paste(label, "did not report the expected product model or reported an asset error:", output)
    )
    require_tree_unchanged(paste(label, "application"), before, tree_digest(app))
    output
  }

  ordinary_environment <- c(
    isolated_environment, "R_PROFILE_USER=", "R_ENVIRON_USER=", "R_LIBS=",
    paste0("R_LIBS_USER=", file.path(destination, "library")),
    paste0("R_LIBS_SITE=", file.path(work, "no-ordinary-site-library")),
    "RENV_CONFIG_AUTOLOADER_ENABLED=FALSE"
  )
  ordinary_first_output <- run_standalone(
    "detached-ordinary-time-1", detached_app, standalone_first_scope,
    standalone_first_time, standalone_first_product_set,
    file.path(destination, "library"), ordinary_environment, "ordinary"
  )
  require_tree_unchanged(
    "Originating project during detached ordinary runtime",
    project_before_detached_runtime, tree_digest(retained_project)
  )
  require_tree_unchanged(
    "Installed software during detached ordinary runtime",
    installation_before_detached_runtime, tree_digest(destination)
  )
  cat(sprintf(
    paste0(
      "PASS detached time-1 standalone app through ordinary Shiny HTTP/assets ",
      "scope=%s product_set=%s materialization=%s\n"
    ),
    standalone_first_scope, standalone_first_product_set,
    standalone_first_materialization
  ))

  lock_path <- file.path(detached_app, "renv.lock")
  lock_lines <- readLines(lock_path, warn = FALSE, encoding = "UTF-8")
  package_starts <- grep('^    "[A-Za-z][A-Za-z0-9.]*": \\{$', lock_lines)
  lock_packages <- sub('^    "([A-Za-z][A-Za-z0-9.]*)": \\{$', '\\1',
    lock_lines[package_starts])
  require_true(length(lock_packages) > 0L && !anyDuplicated(lock_packages),
    "Standalone lock has no unique package closure.")
  dependency_records <- verified$dependencies[-1L]
  dependency_names <- vapply(dependency_records, `[[`, character(1L), "Package")
  selected_dependencies <- lapply(lock_packages, function(package) {
    matches <- which(dependency_names == package)
    require_true(length(matches) == 1L,
      paste("Standalone lock package is absent from distribution evidence:", package))
    dependency_records[[matches]]
  })
  for (index in seq_along(package_starts)) {
    first <- package_starts[[index]]
    last <- if (index < length(package_starts)) package_starts[[index + 1L]] - 1L else
      length(lock_lines)
    block <- lock_lines[first:last]
    version <- sub('^      "Version": "([^"]+)",$', '\\1',
      block[grepl('^      "Version": "[^"]+",$', block)])
    hash <- sub('^      "Hash": "([0-9a-f]{32})"[,]?$', '\\1',
      block[grepl('^      "Hash": "[0-9a-f]{32}"[,]?$', block)])
    dependency_record <- selected_dependencies[[index]]
    require_true(length(version) == 1L && length(hash) == 1L &&
      identical(version, dependency_record[["Version"]]) &&
      identical(hash, sub("^renv:", "", dependency_record[["Integrity"]])),
      paste("Standalone lock provenance disagrees for", lock_packages[[index]]))
  }
  isolated_app_library <- file.path(work, "isolated-standalone-library")
  isolated_restoration_tool <- file.path(work, "isolated-restoration-tool")
  dir.create(isolated_app_library)
  restoration_environment_names <- c(
    "HOME", "XDG_DATA_HOME", "XDG_CONFIG_HOME", "XDG_CACHE_HOME",
    "LOCALAPPDATA", "TMPDIR"
  )
  restoration_environment_before <- Sys.getenv(
    restoration_environment_names, unset = NA_character_
  )
  do.call(Sys.setenv, as.list(stats::setNames(c(
    user_home, installation_root, user_config, user_cache, local_app_data,
    process_temporary
  ), restoration_environment_names)))
  on.exit({
    present <- !is.na(restoration_environment_before)
    if (any(present)) do.call(Sys.setenv, as.list(
      restoration_environment_before[present]
    ))
    if (any(!present)) Sys.unsetenv(restoration_environment_names[!present])
  }, add = TRUE)
  rrp_install_restore_dependencies(
    list(executable = host_r),
    c(list(verified$dependencies[[1L]]), selected_dependencies),
    isolated_app_library, repository, isolated_restoration_tool
  )
  present <- !is.na(restoration_environment_before)
  if (any(present)) do.call(Sys.setenv, as.list(
    restoration_environment_before[present]
  ))
  if (any(!present)) Sys.unsetenv(restoration_environment_names[!present])
  isolated_installed <- installed.packages(
    lib.loc = isolated_app_library, noCache = TRUE
  )
  require_true(
    setequal(rownames(isolated_installed), lock_packages) &&
      all(vapply(seq_along(selected_dependencies), function(index) {
        dependency_record <- selected_dependencies[[index]]
        package <- dependency_record[["Package"]]
        identical(isolated_installed[package, "Version"],
          dependency_record[["Version"]]) &&
          identical(
            rrp_install_description_hash(file.path(
              isolated_app_library, package, "DESCRIPTION"
            )), sub("^renv:", "", dependency_record[["Integrity"]])
          )
      }, logical(1L))) &&
      !dir.exists(file.path(isolated_app_library, "rrpplatform")) &&
      !dir.exists(file.path(isolated_app_library, "rrpruntime")),
    "Isolated standalone library disagrees with the exact declared closure."
  )
  isolated_app_environment <- c(
    isolated_environment, rrp_install_environment(isolated_app_library),
    "R_LIBS=", "RENV_CONFIG_AUTOLOADER_ENABLED=FALSE"
  )
  isolated_first_output <- run_standalone(
    "detached-isolated-time-1", detached_app, standalone_first_scope,
    standalone_first_time, standalone_first_product_set,
    isolated_app_library, isolated_app_environment, "isolated", lock_packages
  )
  require_true(
    grepl("mode=ordinary", ordinary_first_output, fixed = TRUE) &&
      grepl("mode=isolated", isolated_first_output, fixed = TRUE),
    "Standalone runtime modes did not produce distinct bounded evidence."
  )
  require_tree_unchanged(
    "Detached app after exact-closure restoration and execution",
    detached_initial_digest, tree_digest(detached_app)
  )
  require_tree_unchanged(
    "Originating project after isolated detached runtime",
    project_before_detached_runtime, tree_digest(retained_project)
  )
  require_tree_unchanged(
    "Installed software after isolated detached runtime",
    installation_before_detached_runtime, tree_digest(destination)
  )
  cat(sprintf(
    "PASS isolated standalone closure packages=%d without RRP runtime packages\n",
    length(lock_packages)
  ))

  # Controlled fixtures cover every hospital-owned class named by the plan.
  writeLines(c(readLines(file.path(original_app, "app.R"), warn = FALSE),
    "# hospital app customization"), file.path(original_app, "app.R"),
    useBytes = TRUE)
  module_path <- file.path(original_app, "R", "application-ui.R")
  writeLines(c(readLines(module_path, warn = FALSE),
    "# hospital module customization"), module_path, useBytes = TRUE)
  writeLines("hospital_extra <- function() 'hospital-owned'",
    file.path(original_app, "R", "hospital-extra.R"), useBytes = TRUE)
  style_path <- file.path(original_app, "www", "rrp.css")
  writeLines(c(readLines(style_path, warn = FALSE), "/* hospital style */"),
    style_path, useBytes = TRUE)
  writeBin(as.raw(c(0x52, 0x52, 0x50)),
    file.path(original_app, "www", "hospital-asset.bin"))
  writeLines(c(readLines(file.path(original_app, "README.md"), warn = FALSE),
    "Hospital operating note."), file.path(original_app, "README.md"),
    useBytes = TRUE)
  writeLines("Package: hospital-app-dependencies",
    file.path(original_app, "DESCRIPTION"), useBytes = TRUE)
  dir.create(file.path(original_app, "deployment"))
  writeLines("operator: hospital", file.path(
    original_app, "deployment", "configuration.yml"
  ), useBytes = TRUE)
  dir.create(file.path(original_app, ".git"))
  writeLines("ref: refs/heads/main", file.path(original_app, ".git", "HEAD"),
    useBytes = TRUE)
  writeLines("Hospital-owned unrelated note.",
    file.path(original_app, "HOSPITAL-NOTES.md"), useBytes = TRUE)
  customized_bytes <- tree_digest_outside_managed_data(original_app)
  detached_before_refresh <- tree_digest(detached_app)

  standalone_second_time <- "2026-01-22T12:00:00Z"
  standalone_second_run <- stable_run(c(
    "run", "--at", standalone_second_time, "--operation-key",
    "standalone-second", "--project", retained_project, "--json"
  ), project)
  require_run_success("Standalone time-2 governed run", standalone_second_run)
  standalone_second_scope <- json_string(
    standalone_second_run, "operation_run_id"
  )
  require_true(!identical(standalone_second_scope, standalone_first_scope),
    "Standalone time-1 and time-2 operation identities are equal.")
  standalone_second_materialization <- stable_run(c(
    "products", "materialize", "--scope", standalone_second_scope,
    "--cutoff", standalone_second_time, "--project", retained_project,
    "--json"
  ), project)
  require_run_success(
    "Standalone time-2 product materialization",
    standalone_second_materialization
  )
  product_source_before_refresh <- tree_digest(file.path(
    retained_project, "state", "products"
  ))
  history_before_refresh <- tree_digest(file.path(retained_project, "state"))
  installation_before_refresh <- tree_digest(destination)
  pointer_before_refresh <- read_file_bytes(file.path(
    original_app, "rrp-data", "current.dcf"
  ))
  refreshed_app <- stable_run(c(
    "app", "refresh", "--scope", standalone_second_scope, "--cutoff",
    standalone_second_time, "--project", retained_project, "--json"
  ), project)
  validated_refreshed_app <- stable_run(c(
    "app", "validate", "--project", retained_project, "--json"
  ), project)
  require_run_success("Installed standalone application refresh", refreshed_app)
  require_run_success("Refreshed standalone application validation",
    validated_refreshed_app)
  standalone_second_product_set <- json_string(
    validated_refreshed_app, "product_set_id"
  )
  require_true(
    !identical(standalone_second_product_set, standalone_first_product_set) &&
      grepl(paste0('"source_operation_run_id":"', standalone_second_scope, '"'),
        paste(validated_refreshed_app$output, collapse = "\n"), fixed = TRUE) &&
      grepl('"inactive_set_count":1', paste(
        validated_refreshed_app$output, collapse = "\n"
      ), fixed = TRUE) &&
      !identical(pointer_before_refresh, read_file_bytes(file.path(
        original_app, "rrp-data", "current.dcf"
      ))) &&
      identical(customized_bytes,
        tree_digest_outside_managed_data(original_app)) &&
      identical(detached_before_refresh, tree_digest(detached_app)),
    "Time-2 refresh did not preserve source bytes, prior set, or detached time 1."
  )
  require_tree_unchanged(
    "Source materialization during standalone refresh",
    product_source_before_refresh,
    tree_digest(file.path(retained_project, "state", "products"))
  )
  require_tree_unchanged(
    "Project state/history during standalone refresh", history_before_refresh,
    tree_digest(file.path(retained_project, "state"))
  )
  require_tree_unchanged(
    "Installed software during standalone refresh", installation_before_refresh,
    tree_digest(destination)
  )

  refreshed_output <- run_standalone(
    "original-ordinary-time-2", original_app, standalone_second_scope,
    standalone_second_time, standalone_second_product_set,
    file.path(destination, "library"), ordinary_environment, "ordinary"
  )
  detached_recheck_output <- run_standalone(
    "detached-ordinary-time-1-recheck", detached_app, standalone_first_scope,
    standalone_first_time, standalone_first_product_set,
    file.path(destination, "library"), ordinary_environment, "ordinary"
  )
  require_true(
    !identical(
      sub("^.*standalone-model-ok ", "", refreshed_output),
      sub("^.*standalone-model-ok ", "", detached_recheck_output)
    ) && grepl(standalone_second_scope, refreshed_output, fixed = TRUE) &&
      grepl(standalone_first_scope, detached_recheck_output, fixed = TRUE),
    "Runtime model evidence does not distinguish refreshed time 2 from detached time 1."
  )
  require_tree_unchanged(
    "Detached time-1 snapshot after refreshed runtime proof",
    detached_before_refresh, tree_digest(detached_app)
  )
  require_true(identical(customized_bytes,
    tree_digest_outside_managed_data(original_app)),
    "Refreshed runtime changed hospital-owned application bytes.")
  cat(sprintf(
    paste0(
      "PASS customized original serves time 2 while detached copy remains ",
      "time 1 time_1_scope=%s time_1_product_set=%s time_2_scope=%s ",
      "time_2_product_set=%s\n"
    ),
    standalone_first_scope, standalone_first_product_set,
    standalone_second_scope, standalone_second_product_set
  ))

  # Installed adversaries complement, without duplicating, the exhaustive
  # package-native 12.B matrix run by validate-packages.R.
  app_before_incompatible <- tree_digest(original_app)
  incompatible_project <- file.path(work, "incompatible-refresh-project")
  rrp_install_copy_tree(retained_project, incompatible_project)
  incompatible_pointer <- file.path(
    incompatible_project, "state", "products", "current.dcf"
  )
  incompatible_lines <- readLines(incompatible_pointer, warn = FALSE,
    encoding = "UTF-8")
  incompatible_lines <- sub(
    "^Materialization-Contract-Version: 0[.]1[.]0$",
    "Materialization-Contract-Version: 9.9.9", incompatible_lines
  )
  writeLines(incompatible_lines, incompatible_pointer, useBytes = TRUE)
  incompatible_refresh <- stable_run(c(
    "app", "refresh", "--scope", standalone_second_scope, "--cutoff",
    standalone_second_time, "--project", incompatible_project, "--app",
    original_app, "--json"
  ), project)
  require_true(
    identical(incompatible_refresh$status, 1L) && grepl(
      "application_product", paste(incompatible_refresh$output, collapse = "\n"),
      fixed = TRUE
    ),
    paste("Incompatible standalone refresh was not refused:", paste(
      incompatible_refresh$output, collapse = "\n"
    ))
  )
  require_tree_unchanged(
    "Original application after incompatible refresh",
    app_before_incompatible, tree_digest(original_app)
  )

  corrupt_app <- file.path(work, "corrupt-detached-app")
  rrp_install_copy_tree(detached_app, corrupt_app)
  corrupt_pointer <- read.dcf(file.path(corrupt_app, "rrp-data", "current.dcf"),
    all = TRUE)[1L, "Set-Directory"]
  corrupt_member <- file.path(
    corrupt_app, "rrp-data", corrupt_pointer, "current-remaining-risk.csv"
  )
  writeBin(c(read_file_bytes(corrupt_member), charToRaw("corrupt")), corrupt_member)
  corrupt_before_validation <- tree_digest(corrupt_app)
  corrupt_validation <- stable_run(c(
    "app", "validate", "--app", corrupt_app, "--json"
  ), project)
  require_true(
    identical(corrupt_validation$status, 1L) && grepl(
      "application_managed_content_invalid",
      paste(corrupt_validation$output, collapse = "\n"), fixed = TRUE
    ),
    paste("Corrupt detached managed content was not diagnosed:", paste(
      corrupt_validation$output, collapse = "\n"
    ))
  )
  require_tree_unchanged(
    "Corrupt detached app during read-only validation",
    corrupt_before_validation, tree_digest(corrupt_app)
  )

  stale_app <- file.path(work, "stale-work-detached-app")
  rrp_install_copy_tree(detached_app, stale_app)
  stale_directory <- file.path(
    stale_app, "rrp-data", "sets", ".rrp-set-staging-interrupted"
  )
  dir.create(stale_directory)
  writeLines("partial", file.path(stale_directory, "products.dcf"), useBytes = TRUE)
  stale_before_validation <- tree_digest(stale_app)
  stale_validation <- stable_run(c(
    "app", "validate", "--app", stale_app, "--json"
  ), project)
  require_true(
    identical(stale_validation$status, 0L) && grepl(
      '"stale_work_count":1', paste(stale_validation$output, collapse = "\n"),
      fixed = TRUE
    ),
    paste("Stale managed work was not diagnosed:", paste(
      stale_validation$output, collapse = "\n"
    ))
  )
  require_tree_unchanged(
    "Stale detached app during read-only validation",
    stale_before_validation, tree_digest(stale_app)
  )

  failure_probe <- file.path(work, "installed-app-refresh-failure-probe.R")
  precommit_app <- file.path(work, "precommit-detached-app")
  postcommit_app <- file.path(work, "postcommit-detached-app")
  rrp_install_copy_tree(detached_app, precommit_app)
  rrp_install_copy_tree(detached_app, postcommit_app)
  writeLines(c(
    "arguments <- commandArgs(trailingOnly = TRUE)",
    ".libPaths(c(arguments[[1L]], .Library))",
    "library(rrpplatform)",
    "catalog <- rrp_open_resource_catalog(arguments[[2L]])",
    "project <- arguments[[3L]]; scope <- arguments[[4L]]; cutoff <- arguments[[5L]]",
    "validate <- function(path, expected) {",
    "  result <- rrp_validate_app(catalog, path)",
    "  stopifnot(rrp_operation_succeeded(result), identical(result$value$product_set_id, expected))",
    "}",
    "pre <- arguments[[6L]]; post <- arguments[[7L]]",
    "before <- readBin(file.path(pre, 'rrp-data', 'current.dcf'), 'raw', n = file.info(file.path(pre, 'rrp-data', 'current.dcf'))$size)",
    "pre_result <- rrpplatform:::rrp_app_refresh(catalog, project, scope, cutoff, pre, failure_stage = 'before_pointer_replacement')",
    "stopifnot(!rrp_operation_succeeded(pre_result), identical(pre_result$diagnostics[[1L]]$code, 'application_injected_failure'),",
    "  identical(before, readBin(file.path(pre, 'rrp-data', 'current.dcf'), 'raw', n = file.info(file.path(pre, 'rrp-data', 'current.dcf'))$size)))",
    "validate(pre, arguments[[8L]])",
    "post_result <- rrpplatform:::rrp_app_refresh(catalog, project, scope, cutoff, post, failure_stage = 'after_pointer_replacement')",
    "stopifnot(!rrp_operation_succeeded(post_result), identical(post_result$diagnostics[[1L]]$code, 'application_refresh_committed'))",
    "validate(post, arguments[[9L]])",
    "cat('installed-refresh-failure-probe-ok\\n')"
  ), failure_probe, useBytes = TRUE)
  parse(failure_probe)
  failure_result <- run_in(host_rscript, c(
    "--vanilla", shQuote(failure_probe),
    shQuote(file.path(destination, "library")), shQuote(destination),
    shQuote(retained_project), shQuote(standalone_second_scope),
    shQuote(standalone_second_time), shQuote(precommit_app),
    shQuote(postcommit_app), shQuote(standalone_first_product_set),
    shQuote(standalone_second_product_set)
  ), c(isolated_environment,
    paste0("R_LIBS_USER=", file.path(destination, "library")),
    paste0("R_LIBS_SITE=", file.path(work, "no-failure-probe-site")),
    "R_PROFILE_USER=", "R_ENVIRON_USER="
  ), project)
  require_true(
    identical(failure_result$status, 0L) && grepl(
      "installed-refresh-failure-probe-ok",
      paste(failure_result$output, collapse = "\n"), fixed = TRUE
    ),
    paste("Installed refresh interruption proof failed:", paste(
      failure_result$output, collapse = "\n"
    ))
  )
  require_true(
    identical(customized_bytes, tree_digest_outside_managed_data(original_app)) &&
      identical(detached_before_refresh, tree_digest(detached_app)),
    "Installed adversarial proof changed an authoritative application."
  )
  cat(paste(
    "PASS standalone destination/incompatibility/corruption/staging and",
    "precommit/postcommit safeguards\n"
  ))

  privacy_paths <- c(original_app, detached_app)
  privacy_files <- unlist(lapply(privacy_paths, function(root) list.files(
    root, recursive = TRUE, all.files = TRUE, no.. = TRUE, full.names = TRUE
  )), use.names = FALSE)
  privacy_files <- privacy_files[!dir.exists(privacy_files)]
  privacy_files <- privacy_files[grepl(
    "(?:[.](?:R|dcf|csv|css|md|json|txt|ya?ml)|/(?:HEAD|NOTICE|LICENSE|DESCRIPTION))$",
    privacy_files, ignore.case = TRUE, perl = TRUE
  )]
  privacy_content <- paste(unlist(lapply(privacy_files, function(path) {
    if (file.info(path, extra_cols = FALSE)$size[[1L]] > 2000000L) return("")
    paste(readLines(path, warn = FALSE, encoding = "UTF-8"), collapse = "\n")
  }), use.names = FALSE), collapse = "\n")
  private_key_prefix <- "BEGIN "
  private_key_suffix <- "(?:RSA |OPENSSH )?PRIVATE KEY"
  require_true(
    !grepl(
      paste0(
        "private-patient|private-episode|source_patient|native_patient|",
        "connection_string|", private_key_prefix, private_key_suffix
      ),
      privacy_content, ignore.case = TRUE, perl = TRUE
    ) && !grepl(repository_root, privacy_content, fixed = TRUE) &&
      !grepl(destination, privacy_content, fixed = TRUE),
    "Standalone payload privacy/content-boundary inspection failed."
  )
  require_tree_unchanged(
    "Installed software after standalone operational proof",
    installation_before_detached_runtime, tree_digest(destination)
  )
  retained_before <- tree_digest(retained_project)
  cat("PASS standalone privacy, path separation, nonmutation, and cleanup ownership\n")

  working_directory_before_alternate <- tree_digest(project)
  active_before_alternate <- readBin(
    file.path(installation_root, "active.dcf"), "raw",
    n = file.info(file.path(installation_root, "active.dcf"))$size
  )
  alternate_install <- stable_run(c(
    "software", "install", alternate_distribution, "--repository", repository,
    "--installation-root", installation_root,
    "--executable-root", executable_root, "--json"
  ), project)
  require_true(
    alternate_install$status == 0L && grepl(
      '"operation_id":"rrp.software-install"', paste(
        alternate_install$output, collapse = "\n"
      ), fixed = TRUE
    ),
    paste("Second installed realization failed:", paste(
      alternate_install$output, collapse = "\n"
    ))
  )
  alternate_result <- list(
    product_version = alternate_verified$manifest[["Product-Version"]],
    distribution_id = alternate_verified$manifest[["Distribution-ID"]]
  )
  alternate_result$installation_root <- file.path(
    installation_root, "installations", alternate_result$product_version,
    alternate_result$distribution_id
  )
  alternate_record <- rrp_install_dcf(
    file.path(alternate_result$installation_root, "INSTALLATION.dcf"), "record"
  )[[1L]]
  alternate_result$private_library <- alternate_record[["Private-Library"]]
  alternate_selector <- paste(
    alternate_result$product_version, alternate_result$distribution_id,
    sep = "/"
  )
  active_after_alternate <- readBin(
    file.path(installation_root, "active.dcf"), "raw",
    n = file.info(file.path(installation_root, "active.dcf"))$size
  )
  prior_verified <- stable_run(c(
    "software", "verify", "--software", selector, "--json"
  ), project)
  newer_verified <- stable_run(c(
    "software", "verify", "--software", alternate_selector, "--json"
  ), project)
  alternate_explicit <- stable_run(c(
    "--software", alternate_selector, "version", "--json"
  ), project)
  two_listed <- stable_run(c("software", "list", "--json"), project)
  current_after_alternate <- stable_run(c(
    "software", "current", "--json"
  ), project)
  active_after_explicit <- readBin(
    file.path(installation_root, "active.dcf"), "raw",
    n = file.info(file.path(installation_root, "active.dcf"))$size
  )
  require_run_success("Prior installed-software verification", prior_verified)
  require_run_success("Alternate installed-software verification", newer_verified)
  require_run_success("Explicit alternate software selection", alternate_explicit)
  require_run_success("Two-realization installed-software listing", two_listed)
  require_run_success("Active selection after explicit override", current_after_alternate)
  require_true(
    !identical(destination, alternate_result$installation_root),
    "Distinct software realizations resolved to the same installation root."
  )
  require_true(
    !identical(record[["Private-Library"]], alternate_result$private_library),
    "Distinct software realizations resolved to the same private library."
  )
  require_run_text(
    "Explicit alternate software selection", alternate_explicit,
    '"selection":"explicit_override"'
  )
  require_run_text("Two-realization listing (prior selector)", two_listed, selector)
  require_run_text(
    "Two-realization listing (alternate selector)", two_listed,
    alternate_selector
  )
  require_run_text(
    "Active selection after explicit override", current_after_alternate,
    paste0('"selector":"', selector, '"')
  )
  require_true(
    identical(active_before_alternate, active_after_alternate),
    "Installing a distinct realization changed the active-selection record bytes."
  )
  require_true(
    identical(active_after_alternate, active_after_explicit),
    "Explicit per-invocation software selection changed the active-selection record bytes."
  )
  require_tree_unchanged(
    "Distinct installation/selection working directory",
    working_directory_before_alternate, tree_digest(project)
  )
  require_tree_unchanged(
    "Retained independent project during distinct installation/selection",
    retained_before, tree_digest(retained_project)
  )
  cat("PASS verified side-by-side development identities without implicit activation\n")

  newer_activated <- stable_run(c(
    "software", "activate", alternate_selector, "--json"
  ), project)
  prior_verified_after_activation <- stable_run(c(
    "software", "verify", "--software", selector, "--json"
  ), project)
  active_before_prior_explicit <- readBin(
    file.path(installation_root, "active.dcf"), "raw",
    n = file.info(file.path(installation_root, "active.dcf"))$size
  )
  prior_explicit_version <- stable_run(c(
    "--software", selector, "version", "--json"
  ), project)
  active_after_prior_explicit <- readBin(
    file.path(installation_root, "active.dcf"), "raw",
    n = file.info(file.path(installation_root, "active.dcf"))$size
  )
  require_run_success(
    "Prior installed-software verification after alternate activation",
    prior_verified_after_activation
  )
  require_run_success(
    "Explicit prior software selection after alternate activation",
    prior_explicit_version
  )
  require_run_text(
    "Explicit prior software selection after alternate activation",
    prior_explicit_version, '"selection":"explicit_override"'
  )
  require_true(
    identical(active_before_prior_explicit, active_after_prior_explicit),
    "Explicit prior software selection changed the alternate active-selection record bytes."
  )
  newer_doctor <- stable_run(c("software", "doctor", "--json"), project)
  incompatible_under_newer <- stable_run(c(
    "project", "validate", "--project", retained_project, "--json"
  ), project)
  incompatible_doctor <- stable_run(c(
    "project", "doctor", "--scope", standalone_second_scope, "--cutoff",
    standalone_second_time, "--project", retained_project, "--json"
  ), project)
  retained_after_rejection <- tree_digest(retained_project)
  compatible_explicit <- stable_run(c(
    "--software", selector, "project", "doctor", "--scope",
    standalone_second_scope, "--cutoff", standalone_second_time,
    "--project", retained_project, "--json"
  ), project)
  current_while_explicit <- stable_run(c(
    "software", "current", "--json"
  ), project)
  rolled_back <- stable_run(c(
    "software", "activate", selector, "--json"
  ), project)
  compatible_after_rollback <- stable_run(c(
    "project", "validate", "--project", retained_project, "--json"
  ), project)
  current_after_rollback <- stable_run(c(
    "software", "current", "--json"
  ), project)
  require_true(
    newer_activated$status == 0L &&
      prior_verified_after_activation$status == 0L &&
      prior_explicit_version$status == 0L && newer_doctor$status == 0L &&
      grepl(paste0('"distribution_id":"',
        alternate_result$distribution_id, '"'), paste(
          newer_doctor$output, collapse = "\n"
        ), fixed = TRUE) &&
      grepl('"activation_status":"active"', paste(
        newer_doctor$output, collapse = "\n"
      ), fixed = TRUE) && incompatible_under_newer$status == 1L &&
      incompatible_doctor$status == 1L &&
      grepl("incompatible_project_api", paste(
        incompatible_under_newer$output, collapse = "\n"
      ), fixed = TRUE) &&
      grepl("incompatible_project_api", paste(
        incompatible_doctor$output, collapse = "\n"
      ), fixed = TRUE) &&
      compatible_explicit$status == 0L && current_while_explicit$status == 0L &&
      grepl(paste0('"selector":"', alternate_selector, '"'), paste(
        current_while_explicit$output, collapse = "\n"
      ), fixed = TRUE) &&
      grepl('"product_freshness":"fresh"', paste(
        compatible_explicit$output, collapse = "\n"
      ), fixed = TRUE) &&
      rolled_back$status == 0L && compatible_after_rollback$status == 0L &&
      current_after_rollback$status == 0L &&
      grepl(paste0('"selector":"', selector, '"'), paste(
        current_after_rollback$output, collapse = "\n"
      ), fixed = TRUE) &&
      identical(retained_before, retained_after_rejection) &&
      identical(retained_before, tree_digest(retained_project)) &&
      identical(working_directory_before_alternate, tree_digest(project)),
    paste("Upgrade compatibility gate or rollback proof failed:", paste(c(
      newer_activated$output, newer_doctor$output,
      prior_verified_after_activation$output, prior_explicit_version$output,
      incompatible_under_newer$output,
      incompatible_doctor$output, compatible_explicit$output,
      current_while_explicit$output,
      rolled_back$output, compatible_after_rollback$output,
      current_after_rollback$output
    ), collapse = "\n"))
  )
  cat(paste(
    "PASS incompatible active version refusal, explicit compatible operation,",
    "and exact rollback\n"
  ))

  active_path <- file.path(installation_root, "active.dcf")
  valid_active <- readBin(active_path, "raw", n = file.info(active_path)$size)
  alternate <- paste(rep("b", 64L), collapse = "")
  invalid_active <- c(
    "Record-Type" = "rrp-activation",
    "Contract-ID" = "rrp.activation-record",
    "Contract-Version" = "0.1.0",
    "Product-ID" = "readmission-risk-pool-platform",
    "Product-Version" = verified$manifest[["Product-Version"]],
    "Installation-ID" = alternate,
    "Distribution-ID" = alternate,
    "Activated-At" = "2026-01-01T00:00:00Z"
  )
  write.dcf(matrix(unname(invalid_active), nrow = 1L,
    dimnames = list(NULL, names(invalid_active))), active_path, width = 500L)
  invalid_list <- stable_run(c("software", "list", "--json"), project)
  invalid_current <- stable_run(c("software", "current", "--json"), project)
  invalid_doctor <- stable_run(c("software", "doctor", "--json"), project)
  explicit_around_invalid <- stable_run(c(
    "--software", selector, "version", "--json"
  ), project)
  require_true(
    invalid_list$status == 0L && invalid_current$status == 1L &&
      invalid_doctor$status == 0L && explicit_around_invalid$status == 0L &&
      grepl("invalid_active_selection",
        paste(invalid_list$output, collapse = "\n"), fixed = TRUE) &&
      grepl("invalid_active_selection",
        paste(invalid_current$output, collapse = "\n"), fixed = TRUE) &&
      grepl('"activation_status":"invalid"',
        paste(invalid_doctor$output, collapse = "\n"), fixed = TRUE) &&
      grepl('"selection":"explicit_override"',
        paste(explicit_around_invalid$output, collapse = "\n"), fixed = TRUE) &&
      identical(working_directory_before_alternate, tree_digest(project)),
    paste("Invalid activation diagnosis or explicit-selection isolation failed:",
      paste(c(
        invalid_list$output, invalid_current$output, invalid_doctor$output,
        explicit_around_invalid$output
      ), collapse = "\n"))
  )
  connection <- file(active_path, open = "wb")
  writeBin(valid_active, connection)
  close(connection)

  active_uninstall <- stable_run(c(
    "software", "uninstall", selector, "--yes", "--json"
  ), project)
  confirmation_denied <- stable_run(c(
    "software", "uninstall", alternate_selector, "--json"
  ), project)
  malformed_uninstall <- stable_run(c(
    "software", "uninstall", verified$manifest[["Product-Version"]],
    "--yes", "--json"
  ), project)
  unknown_selector <- paste(
    verified$manifest[["Product-Version"]], paste(rep("c", 64L), collapse = ""),
    sep = "/"
  )
  unknown_uninstall <- stable_run(c(
    "software", "uninstall", unknown_selector, "--yes", "--json"
  ), project)
  linked_selector <- paste(
    verified$manifest[["Product-Version"]], paste(rep("d", 64L), collapse = ""),
    sep = "/"
  )
  linked_path <- file.path(
    installation_root, "installations", verified$manifest[["Product-Version"]],
    paste(rep("d", 64L), collapse = "")
  )
  require_true(file.symlink(alternate_result$installation_root, linked_path),
    "Could not create the linked-installation adversarial fixture.")
  linked_uninstall <- stable_run(c(
    "software", "uninstall", linked_selector, "--yes", "--json"
  ), project)
  unlink(linked_path, force = TRUE)
  lifecycle_lock <- file.path(installation_root, "staging", ".software-lifecycle-lock")
  require_true(dir.create(lifecycle_lock), "Could not create lifecycle lock fixture.")
  locked_uninstall <- stable_run(c(
    "software", "uninstall", alternate_selector, "--yes", "--json"
  ), project)
  unlink(lifecycle_lock, recursive = TRUE, force = TRUE)
  installer_lock <- file.path(
    installation_root, "staging", paste0(
      ".lock-", alternate_result$product_version, "-",
      alternate_result$distribution_id
    )
  )
  require_true(dir.create(installer_lock), "Could not create installer lock fixture.")
  installer_locked_uninstall <- stable_run(c(
    "software", "uninstall", alternate_selector, "--yes", "--json"
  ), project)
  unlink(installer_lock, recursive = TRUE, force = TRUE)
  stale_quarantine <- file.path(
    installation_root, "staging", paste0(
      ".uninstall-", alternate_result$product_version, "-",
      alternate_result$distribution_id
    )
  )
  require_true(dir.create(stale_quarantine),
    "Could not create stale uninstall quarantine fixture.")
  stale_quarantine_uninstall <- stable_run(c(
    "software", "uninstall", alternate_selector, "--yes", "--json"
  ), project)
  unlink(stale_quarantine, recursive = TRUE, force = TRUE)
  uninstall_failure_script <- file.path(work, "uninstall-failure.R")
  writeLines(c(
    sprintf(".libPaths(c(%s,.Library))", deparse(file.path(destination, "library"))),
    "library(rrpplatform)",
    sprintf("root <- %s", deparse(installation_root)),
    sprintf("selector <- %s", deparse(alternate_selector)),
    sprintf("shim <- %s", deparse(stable_launcher)),
    "internal <- function(name) getFromNamespace(name,'rrpplatform')",
    "result <- internal('rrp_software_uninstall')(root,selector,shim,'after_quarantine')",
    "stopifnot(!rrp_operation_succeeded(result))",
    "codes <- vapply(result$diagnostics,`[[`,character(1L),'code')",
    "stopifnot('uninstall_removal_failed' %in% codes)"
  ), uninstall_failure_script, useBytes = TRUE)
  controlled_uninstall <- run_in(
    host_rscript, c("--vanilla", shQuote(uninstall_failure_script)),
    c(paste0("R_LIBS_USER=", file.path(destination, "library")), "R_LIBS_SITE="),
    project
  )
  alternate_manifest_path <- file.path(
    alternate_result$installation_root, "manifest.dcf"
  )
  alternate_manifest_bytes <- readBin(
    alternate_manifest_path, "raw", n = file.info(alternate_manifest_path)$size
  )
  Sys.chmod(alternate_manifest_path, mode = "0644", use_umask = FALSE)
  connection <- file(alternate_manifest_path, open = "ab")
  writeBin(charToRaw("\n"), connection)
  close(connection)
  Sys.chmod(alternate_manifest_path, mode = "0644", use_umask = FALSE)
  damaged_uninstall <- stable_run(c(
    "software", "uninstall", alternate_selector, "--yes", "--json"
  ), project)
  Sys.chmod(alternate_manifest_path, mode = "0644", use_umask = FALSE)
  connection <- file(alternate_manifest_path, open = "wb")
  writeBin(alternate_manifest_bytes, connection)
  close(connection)
  Sys.chmod(alternate_manifest_path, mode = "0644", use_umask = FALSE)
  require_true(
    active_uninstall$status == 1L &&
      grepl("active_installation_uninstall_refused", paste(
        active_uninstall$output, collapse = "\n"
      ), fixed = TRUE) &&
      confirmation_denied$status == 1L && grepl(
        "confirmation_required", paste(confirmation_denied$output, collapse = "\n"),
        fixed = TRUE
      ) &&
      malformed_uninstall$status == 2L &&
      unknown_uninstall$status == 1L && grepl(
        "installed_software_not_found", paste(unknown_uninstall$output, collapse = "\n"),
        fixed = TRUE
      ) &&
      linked_uninstall$status == 1L && grepl(
        "linked_installation_refused", paste(linked_uninstall$output, collapse = "\n"),
        fixed = TRUE
      ) &&
      locked_uninstall$status == 1L && grepl(
        "software_lifecycle_locked", paste(locked_uninstall$output, collapse = "\n"),
        fixed = TRUE
      ) &&
      installer_locked_uninstall$status == 1L && grepl(
        "software_lifecycle_locked",
        paste(installer_locked_uninstall$output, collapse = "\n"), fixed = TRUE
      ) &&
      stale_quarantine_uninstall$status == 1L && grepl(
        "uninstall_recovery_required",
        paste(stale_quarantine_uninstall$output, collapse = "\n"), fixed = TRUE
      ) &&
      controlled_uninstall$status == 0L && damaged_uninstall$status == 1L &&
      grepl("installed_identity_mismatch", paste(
        damaged_uninstall$output, collapse = "\n"
      ), fixed = TRUE) &&
      dir.exists(alternate_result$installation_root) &&
      identical(valid_active, readBin(
        active_path, "raw", n = file.info(active_path)$size
      )) &&
      identical(working_directory_before_alternate, tree_digest(project)) &&
      identical(retained_before, tree_digest(retained_project)),
    paste("Exact-uninstall refusal or recovery proof failed:", paste(c(
      active_uninstall$output, confirmation_denied$output,
      malformed_uninstall$output, unknown_uninstall$output,
      linked_uninstall$output, locked_uninstall$output,
      installer_locked_uninstall$output, stale_quarantine_uninstall$output,
      controlled_uninstall$output, damaged_uninstall$output
    ), collapse = "\n"))
  )
  cat("PASS uninstall confirmation, exact-target denials, and recovery preservation\n")

  manifest_path <- file.path(destination, "manifest.dcf")
  manifest_bytes <- readBin(
    manifest_path, "raw", n = file.info(manifest_path)$size
  )
  manifest_digest <- rrp_sha256(manifest_path)
  damaged_manifest_bytes <- c(manifest_bytes, charToRaw("\n"))
  Sys.chmod(manifest_path, mode = "0644", use_umask = FALSE)
  connection <- file(manifest_path, open = "wb")
  writeBin(damaged_manifest_bytes, connection)
  close(connection)
  Sys.chmod(manifest_path, mode = "0644", use_umask = FALSE)
  damaged_manifest_digest <- rrp_sha256(manifest_path)
  require_true(
    !identical(damaged_manifest_digest, manifest_digest) &&
      !identical(
        damaged_manifest_digest, record[["Distribution-Manifest-Digest"]]
      ) && identical(
        readBin(manifest_path, "raw", n = file.info(manifest_path)$size),
        damaged_manifest_bytes
      ),
    "Damaged installed-software fixture did not alter the recorded manifest."
  )
  damaged_verify <- stable_run(c(
    "software", "verify", "--software", selector, "--json"
  ), project)
  damaged_context_verify <- version_run(
    destination, selector,
    c("software", "verify", "--software", selector, "--json"), project
  )
  damaged_operation_verify <- version_run(
    alternate_result$installation_root, alternate_selector,
    c("software", "verify", "--software", selector, "--json"), project
  )
  require_true(
    damaged_verify$status %in% c(1L, 3L) &&
      damaged_context_verify$status == 3L &&
      damaged_operation_verify$status == 1L &&
      all(vapply(
        list(damaged_verify, damaged_context_verify, damaged_operation_verify),
        function(value) grepl(
          "installed_identity_mismatch", paste(value$output, collapse = "\n"),
          fixed = TRUE
        ), logical(1L)
      )) && identical(rrp_sha256(manifest_path), damaged_manifest_digest) &&
      identical(
        readBin(manifest_path, "raw", n = file.info(manifest_path)$size),
        damaged_manifest_bytes
      ) && identical(
        working_directory_before_alternate, tree_digest(project)
      ) &&
      identical(retained_before, tree_digest(retained_project)),
    paste(
      "Damaged installed-software verification did not fail closed:",
      paste(c(
        damaged_verify$output, damaged_context_verify$output,
        damaged_operation_verify$output
      ), collapse = "\n")
    )
  )
  Sys.chmod(manifest_path, mode = "0644", use_umask = FALSE)
  connection <- file(manifest_path, open = "wb")
  writeBin(manifest_bytes, connection)
  close(connection)
  Sys.chmod(manifest_path, mode = "0644", use_umask = FALSE)
  require_true(
    identical(rrp_sha256(manifest_path), manifest_digest),
    "Installed-software fixture recovery did not restore the original manifest."
  )
  recovered_verify <- stable_run(c(
    "software", "verify", "--software", selector, "--json"
  ), project)
  invalid_selector <- stable_run(c("--software", "latest", "version"), project)
  shim_text <- paste(readLines(stable_launcher, warn = FALSE), collapse = "\n")
  require_true(
    recovered_verify$status == 0L && invalid_selector$status == 2L &&
      grepl('exec "$installation/bin/rrp" "$@"', shim_text, fixed = TRUE) &&
      identical(working_directory_before_alternate, tree_digest(project)),
    "Recovery, selector rejection, argument, or signal delegation failed."
  )
  cat("PASS invalid-pointer diagnosis, damaged-install denial, and launcher delegation\n")

  active_before_uninstall <- readBin(
    active_path, "raw", n = file.info(active_path)$size
  )
  uninstalled_newer <- stable_run(c(
    "software", "uninstall", alternate_selector, "--yes", "--json"
  ), project)
  repeated_uninstall <- stable_run(c(
    "software", "uninstall", alternate_selector, "--yes", "--json"
  ), project)
  remaining_list <- stable_run(c("software", "list", "--json"), project)
  remaining_version <- stable_run(c("version", "--json"), project)
  remaining_verify <- stable_run(c(
    "software", "verify", "--software", selector, "--json"
  ), project)
  remaining_doctor <- stable_run(c("software", "doctor", "--json"), project)
  require_true(
    uninstalled_newer$status == 0L &&
      grepl('"operation_id":"rrp.software-uninstall"', paste(
        uninstalled_newer$output, collapse = "\n"
      ), fixed = TRUE) &&
      grepl('"final_installation":false', paste(
        uninstalled_newer$output, collapse = "\n"
      ), fixed = TRUE) &&
      repeated_uninstall$status == 1L && grepl(
        "installed_software_not_found", paste(repeated_uninstall$output, collapse = "\n"),
        fixed = TRUE
      ) &&
      remaining_list$status == 0L && remaining_version$status == 0L &&
      remaining_verify$status == 0L && remaining_doctor$status == 0L &&
      grepl(selector, paste(remaining_list$output, collapse = "\n"), fixed = TRUE) &&
      !grepl(alternate_selector, paste(remaining_list$output, collapse = "\n"),
        fixed = TRUE) &&
      grepl('"software_status":"ready"', paste(
        remaining_doctor$output, collapse = "\n"
      ), fixed = TRUE) &&
      !file.exists(alternate_result$installation_root) &&
      !dir.exists(alternate_result$installation_root) &&
      identical(active_before_uninstall, readBin(
        active_path, "raw", n = file.info(active_path)$size
      )) &&
      file.exists(stable_launcher) && file.access(stable_launcher, 1L) == 0L &&
      identical(working_directory_before_alternate, tree_digest(project)) &&
      identical(retained_before, tree_digest(retained_project)),
    paste("Exact inactive uninstall or repeated-removal proof failed:", paste(c(
      uninstalled_newer$output, repeated_uninstall$output,
      remaining_list$output, remaining_version$output,
      remaining_verify$output, remaining_doctor$output
    ), collapse = "\n"))
  )
  cat("PASS exact inactive uninstall with active selection, shim, and project preservation\n")

  shim_bytes <- readBin(
    stable_launcher, "raw", n = file.info(stable_launcher)$size
  )
  Sys.chmod(stable_launcher, mode = "0644", use_umask = FALSE)
  writeLines("unrelated executable", stable_launcher, useBytes = TRUE)
  Sys.chmod(stable_launcher, mode = "0755", use_umask = FALSE)
  expect_failure(
    "stable shim conflict",
    rrp_install_provision_shim(destination, installation_root, executable_root),
    "stable_shim_conflict"
  )
  connection <- file(stable_launcher, open = "wb")
  writeBin(shim_bytes, connection)
  close(connection)
  Sys.chmod(stable_launcher, mode = "0755", use_umask = FALSE)
  require_true(
    stable_run(c("version", "--json"), project)$status == 0L &&
      identical(working_directory_before_alternate, tree_digest(project)),
    "Stable-shim conflict recovery altered software selection or project state."
  )
  cat("PASS stable-shim conflict refusal and recovery\n")

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
  cli <- run_in(
    file.path(destination, "bin", "rrp"),
    c(
      "software", "install", distribution_root, "--repository", repository,
      "--installation-root", installation_root,
      "--executable-root", executable_root, "--json"
    ),
    c(isolated_environment, launcher_environment), project
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
    identical(record, record_after) && identical(
      working_directory_before_alternate, tree_digest(project)
    ) &&
      identical(retained_before, tree_digest(retained_project)),
    "CLI reinstall changed immutable installation or project content."
  )
  cat("PASS bootstrap/CLI shared-engine equivalence and idempotent exact reinstall\n")

  unlink(active_path, force = TRUE)
  final_uninstall <- stable_run(c(
    "software", "uninstall", selector, "--yes", "--json"
  ), project)
  no_active_software <- stable_run(c("software", "current", "--json"), project)
  require_true(
    final_uninstall$status == 1L &&
      grepl("final_installation_uninstall_refused", paste(
        final_uninstall$output, collapse = "\n"
      ), fixed = TRUE) &&
      file.exists(destination) && dir.exists(destination) &&
      file.exists(stable_launcher) && file.access(stable_launcher, 1L) == 0L &&
      !file.exists(active_path) && no_active_software$status == 0L &&
      grepl('"active":false', paste(
        no_active_software$output, collapse = "\n"
      ), fixed = TRUE) &&
      identical(working_directory_before_alternate, tree_digest(project)) &&
      identical(retained_before, tree_digest(retained_project)),
    paste("Final inactive installation behavior failed:", paste(c(
      final_uninstall$output, no_active_software$output
    ), collapse = "\n"))
  )
  cat("PASS final-inactive refusal with stable shim and no project mutation\n")

  cat(paste(
    "Result: PASS (clean installed operation, standalone ordinary/isolated",
    "time-1/time-2 proof, side-by-side compatibility, rollback, and exact uninstall)\n"
  ))
  invisible(TRUE)
}

passed <- tryCatch({ validate_installation(); TRUE }, error = function(condition) {
  cat("Result: FAIL\n", conditionMessage(condition), "\n", file = stderr())
  FALSE
})
if (!passed) quit(save = "no", status = 1L, runLast = FALSE)
