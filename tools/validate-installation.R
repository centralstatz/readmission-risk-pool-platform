#!/usr/bin/env Rscript

# Full Increment 11.G proof. This deliberately performs one real configured-
# repository restoration and reuses its side-by-side realizations for the
# accepted installation, selection, rollback, and exact-uninstall proof.

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
      "--installation-root", installation_root,
      "--executable-root", executable_root
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
  cat("PASS base-R bootstrap, exact private restoration, isolation, and promotion\n")

  integrity_script <- file.path(work, "installed-integrity-probe.R")
  writeLines(c(
    sprintf("private <- %s", deparse(file.path(destination, "library"))),
    sprintf("root <- %s", deparse(destination)),
    ".libPaths(c(private,.Library))",
    "library(rrpplatform)",
    "internal <- function(name) getFromNamespace(name,'rrpplatform')",
    "records <- internal('rrp_software_read_dcf')(file.path(root,'dependencies','dependencies.dcf'))",
    "packages <- records[-1L]",
    "expected <- setNames(sub('^renv:','',vapply(packages,`[[`,character(1L),'Integrity')),vapply(packages,`[[`,character(1L),'Package'))",
    "actual <- vapply(names(expected),function(package) internal('rrp_software_description_hash')(file.path(private,package,'DESCRIPTION')),character(1L))",
    "mismatch <- names(expected)[actual != expected]",
    "if (length(mismatch)) stop(paste('dependency integrity mismatch:',paste(mismatch,collapse=',')),call.=FALSE)",
    "invisible(TRUE)"
  ), integrity_script, useBytes = TRUE)
  integrity_probe <- run(
    host_r, c("--vanilla", shQuote(integrity_script)),
    c(
      "LC_ALL=C",
      paste0("R_LIBS_USER=", file.path(destination, "library")),
      "R_LIBS_SITE="
    )
  )
  require_true(
    integrity_probe$status == 0L,
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
      )), c(
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
      )), c(
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
  activated <- stable_run(c("software", "activate", selector, "--json"), project)
  reactivated <- stable_run(c("software", "activate", selector, "--json"), project)
  current <- stable_run(c("software", "current", "--json"), project)
  current_human <- stable_run(c("software", "current"), project)
  healthy_doctor <- stable_run(c("software", "doctor", "--json"), project)
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
  controlled_activation <- run(
    host_rscript, c("--vanilla", shQuote(failure_script)),
    c(paste0("R_LIBS_USER=", file.path(destination, "library")), "R_LIBS_SITE=")
  )
  active_after_failure <- readBin(
    file.path(installation_root, "active.dcf"), "raw",
    n = file.info(file.path(installation_root, "active.dcf"))$size
  )
  require_true(
    activated$status == 0L && reactivated$status == 0L &&
      current$status == 0L && current_human$status == 0L &&
      healthy_doctor$status == 0L &&
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
  signal_proof <- run(
    "/bin/sh", c(shQuote(signal_script), shQuote(stable_launcher)),
    c(
      paste0("R_LIBS=", ambient_user),
      paste0("R_LIBS_USER=", ambient_user),
      paste0("R_LIBS_SITE=", ambient_site),
      paste0("R_PROFILE_USER=", profile), paste0("R_ENVIRON_USER=", environ)
    )
  )
  require_true(
    signal_proof$status == 0L,
    paste("Stable launcher signal propagation failed:", paste(
      signal_proof$output, collapse = "\n"
    ))
  )
  cat("PASS stable shim, exact selection, verification, doctor, and atomic activation\n")

  retained_project <- file.path(work, "retained-fictional-project")
  analytical_time <- "2026-01-20T12:00:00Z"
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
    "run", "--at", analytical_time, "--operation-key", "version-transition-proof",
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
  retained_scope <- json_string(retained_run, "operation_run_id")
  retained_products <- stable_run(c(
    "products", "materialize", "--scope", retained_scope, "--cutoff",
    analytical_time, "--project", retained_project, "--json"
  ), project)
  retained_validate <- stable_run(c(
    "project", "validate", "--project", retained_project, "--json"
  ), project)
  retained_history <- stable_run(c(
    "history", "scope", "--scope", retained_scope, "--project",
    retained_project, "--json"
  ), project)
  retained_history_text <- paste(retained_history$output, collapse = "\n")
  require_true(
    retained_products$status == 0L && retained_validate$status == 0L &&
      retained_history$status == 0L &&
      !grepl(
        "distribution_id|build_id|installation_id|activation",
        retained_history_text, ignore.case = TRUE, perl = TRUE
      ),
    paste("Retained project or history-attribution setup failed:", paste(c(
      retained_products$output, retained_validate$output,
      retained_history$output
    ), collapse = "\n"))
  )
  retained_before <- tree_digest(retained_project)
  cat("PASS retained project with durable history and products under prior software\n")

  alternate_result <- rrp_install_distribution(
    alternate_distribution, repository, host_r, installation_root,
    executable_root
  )
  alternate_selector <- paste(
    alternate_result$product_version, alternate_result$distribution_id,
    sep = "/"
  )
  active_after_alternate <- readBin(
    file.path(installation_root, "active.dcf"), "raw",
    n = file.info(file.path(installation_root, "active.dcf"))$size
  )
  alternate_explicit <- stable_run(c(
    "--software", alternate_selector, "version", "--json"
  ), project)
  prior_verified <- stable_run(c(
    "software", "verify", "--software", selector, "--json"
  ), project)
  newer_verified <- stable_run(c(
    "software", "verify", "--software", alternate_selector, "--json"
  ), project)
  two_listed <- stable_run(c("software", "list", "--json"), project)
  current_after_alternate <- stable_run(c(
    "software", "current", "--json"
  ), project)
  require_true(
    alternate_explicit$status == 0L && prior_verified$status == 0L &&
      newer_verified$status == 0L && two_listed$status == 0L &&
      current_after_alternate$status == 0L &&
      !identical(destination, alternate_result$installation_root) &&
      !identical(record[["Private-Library"]], alternate_result$private_library) &&
      grepl('"selection":"explicit_override"',
        paste(alternate_explicit$output, collapse = "\n"), fixed = TRUE) &&
      grepl(selector, paste(two_listed$output, collapse = "\n"), fixed = TRUE) &&
      grepl(alternate_selector, paste(two_listed$output, collapse = "\n"),
        fixed = TRUE) &&
      grepl(paste0('"selector":"', selector, '"'),
        paste(current_after_alternate$output, collapse = "\n"), fixed = TRUE) &&
      identical(active_before_failure, active_after_alternate) &&
      identical(project_before, tree_digest(project)) &&
      identical(retained_before, tree_digest(retained_project)),
    "Distinct explicit installed selection changed the active default or project."
  )
  cat("PASS verified side-by-side development identities without implicit activation\n")

  newer_activated <- stable_run(c(
    "software", "activate", alternate_selector, "--json"
  ), project)
  incompatible_under_newer <- stable_run(c(
    "project", "validate", "--project", retained_project, "--json"
  ), project)
  retained_after_rejection <- tree_digest(retained_project)
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
    newer_activated$status == 0L && incompatible_under_newer$status == 1L &&
      grepl("incompatible_project_api", paste(
        incompatible_under_newer$output, collapse = "\n"
      ), fixed = TRUE) &&
      rolled_back$status == 0L && compatible_after_rollback$status == 0L &&
      current_after_rollback$status == 0L &&
      grepl(paste0('"selector":"', selector, '"'), paste(
        current_after_rollback$output, collapse = "\n"
      ), fixed = TRUE) &&
      identical(retained_before, retained_after_rejection) &&
      identical(retained_before, tree_digest(retained_project)) &&
      identical(project_before, tree_digest(project)),
    paste("Upgrade compatibility gate or rollback proof failed:", paste(c(
      newer_activated$output, incompatible_under_newer$output,
      rolled_back$output, compatible_after_rollback$output,
      current_after_rollback$output
    ), collapse = "\n"))
  )
  cat("PASS activate-newer compatibility refusal and exact rollback to prior software\n")

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
      identical(project_before, tree_digest(project)),
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
  controlled_uninstall <- run(
    host_rscript, c("--vanilla", shQuote(uninstall_failure_script)),
    c(paste0("R_LIBS_USER=", file.path(destination, "library")), "R_LIBS_SITE=")
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
  Sys.chmod(alternate_manifest_path, mode = "0444", use_umask = FALSE)
  damaged_uninstall <- stable_run(c(
    "software", "uninstall", alternate_selector, "--yes", "--json"
  ), project)
  Sys.chmod(alternate_manifest_path, mode = "0644", use_umask = FALSE)
  connection <- file(alternate_manifest_path, open = "wb")
  writeBin(alternate_manifest_bytes, connection)
  close(connection)
  Sys.chmod(alternate_manifest_path, mode = "0444", use_umask = FALSE)
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
      identical(project_before, tree_digest(project)) &&
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
  Sys.chmod(manifest_path, mode = "0444", use_umask = FALSE)
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
      ) && identical(project_before, tree_digest(project)) &&
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
  Sys.chmod(manifest_path, mode = "0444", use_umask = FALSE)
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
      identical(project_before, tree_digest(project)),
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
      grepl(selector, paste(remaining_list$output, collapse = "\n"), fixed = TRUE) &&
      !grepl(alternate_selector, paste(remaining_list$output, collapse = "\n"),
        fixed = TRUE) &&
      !file.exists(alternate_result$installation_root) &&
      !dir.exists(alternate_result$installation_root) &&
      identical(active_before_uninstall, readBin(
        active_path, "raw", n = file.info(active_path)$size
      )) &&
      file.exists(stable_launcher) && file.access(stable_launcher, 1L) == 0L &&
      identical(project_before, tree_digest(project)) &&
      identical(retained_before, tree_digest(retained_project)),
    paste("Exact inactive uninstall or repeated-removal proof failed:", paste(c(
      uninstalled_newer$output, repeated_uninstall$output,
      remaining_list$output, remaining_version$output
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
      identical(project_before, tree_digest(project)),
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
  cli <- run(
    file.path(destination, "bin", "rrp"),
    c(
      "software", "install", distribution_root, "--repository", repository,
      "--installation-root", installation_root,
      "--executable-root", executable_root, "--json"
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
    identical(record, record_after) && identical(project_before, tree_digest(project)) &&
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
      identical(project_before, tree_digest(project)) &&
      identical(retained_before, tree_digest(retained_project)),
    paste("Final inactive installation behavior failed:", paste(c(
      final_uninstall$output, no_active_software$output
    ), collapse = "\n"))
  )
  cat("PASS final-inactive refusal with stable shim and no project mutation\n")

  cat("Result: PASS (side-by-side lifecycle, rollback, and exact uninstall)\n")
  invisible(TRUE)
}

passed <- tryCatch({ validate_installation(); TRUE }, error = function(condition) {
  cat("Result: FAIL\n", conditionMessage(condition), "\n", file = stderr())
  FALSE
})
if (!passed) quit(save = "no", status = 1L, runLast = FALSE)
