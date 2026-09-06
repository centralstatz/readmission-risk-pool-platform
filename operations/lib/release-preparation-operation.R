# Maintainer-only local release preparation. Publication is deliberately absent.

rrp_release_authority <- function(repository_root) {
  path <- file.path(repository_root, "RELEASE.yml")
  authority <- yaml::read_yaml(path)
  if (!is.list(authority) ||
      !authority$release_authority_version %in% c(1L, 2L)) {
    stop("RELEASE.yml is not the supported release authority.", call. = FALSE)
  }
  authority
}

rrp_release_git <- function(repository_root, arguments) {
  git <- Sys.which("git")
  if (!nzchar(git)) stop("Git is required for release preparation.", call. = FALSE)
  output <- suppressWarnings(system2(
    git, c("-C", shQuote(repository_root), arguments), stdout = TRUE, stderr = TRUE
  ))
  status <- attr(output, "status")
  if (is.null(status)) status <- 0L
  list(status = as.integer(status), output = as.character(output))
}

rrp_release_source_revision <- function(repository_root, require_clean = TRUE) {
  status <- rrp_release_git(
    repository_root, c("status", "--porcelain=v1", "--untracked-files=all")
  )
  if (!identical(status$status, 0L)) stop(
    "Could not inspect authoritative Git source state.", call. = FALSE
  )
  if (require_clean && length(status$output) > 0L) stop(
    "Release preparation requires a clean authoritative source tree; review and commit or remove every change before retrying.",
    call. = FALSE
  )
  revision <- rrp_release_git(repository_root, c("rev-parse", "--verify", "HEAD"))
  if (!identical(revision$status, 0L) || length(revision$output) != 1L ||
      !grepl("^[a-f0-9]{40}$", revision$output)) stop(
    "Release preparation requires one committed authoritative source revision.",
    call. = FALSE
  )
  revision$output[[1L]]
}

rrp_release_validate_governance <- function(repository_root, version) {
  required <- c(
    "LICENSE", "NOTICE", "LICENSE-STATUS.md", "CONTRIBUTING.md", "SECURITY.md",
    "SUPPORT.md", "CHANGELOG.md", "RELEASE.yml",
    "docs/architecture/release-license-review.md",
    "docs/operations/release-preparation.md",
    "docs/operations/release-publication.md"
  )
  missing <- required[!file.exists(file.path(repository_root, required))]
  if (length(missing) > 0L) stop(
    "Release governance is incomplete: ", paste(missing, collapse = ", "),
    call. = FALSE
  )
  authority <- rrp_release_authority(repository_root)
  expected <- authority$targets$platform$intended_version
  hospital <- authority$targets$hospital$intended_version
  if (!identical(version, expected) || !identical(version, hospital) ||
      !identical(authority$publication$status, "not_published") ||
      !identical(authority$publication$platform_repository,
                 "centralstatz/readmission-risk-pool-platform") ||
      !identical(authority$publication$hospital_repository,
                 "centralstatz/readmission-risk-pool-hospital-implementation") ||
      !identical(authority$publication$expected_branch, "main") ||
      !identical(authority$publication$expected_platform_tag, paste0("v", version)) ||
      !identical(authority$publication$expected_hospital_tag, paste0("v", version)) ||
      !identical(authority$license$spdx_id, "Apache-2.0") ||
      !identical(authority$source$development_version, paste0(version, "-dev"))) {
    stop("Requested version conflicts with RELEASE.yml release authority.", call. = FALSE)
  }
  text <- function(path) paste(readLines(
    file.path(repository_root, path), warn = FALSE, encoding = "UTF-8"
  ), collapse = "\n")
  conditions <- c(
    grepl("Apache License", text("LICENSE"), fixed = TRUE),
    grepl("Version 2.0, January 2004", text("LICENSE"), fixed = TRUE),
    grepl("CentralStatz Statistical & Data Sciences LLC", text("NOTICE"), fixed = TRUE),
    grepl("git commit -s", text("CONTRIBUTING.md"), fixed = TRUE),
    grepl("private vulnerability reporting", text("SECURITY.md"), fixed = TRUE),
    grepl("no support or response-time SLA", text("SUPPORT.md"), fixed = TRUE),
    grepl(paste0("## [", version, "]"), text("CHANGELOG.md"), fixed = TRUE)
  )
  if (!all(conditions)) stop(
    "Apache-2.0 or the minimum governance policy surface is invalid.", call. = FALSE
  )
  list(
    license = "pass", governance = "pass", support = "pass",
    platform_version = expected, hospital_version = hospital,
    development_version = authority$source$development_version
  )
}

rrp_release_validate_renv <- function(repository_root) {
  output <- tempfile("rrp-release-renv-", fileext = ".log")
  on.exit(unlink(output, force = TRUE), add = TRUE)
  previous <- setwd(repository_root)
  on.exit(setwd(previous), add = TRUE)
  expression <- paste(
    "result <- renv::status(project = '.')",
    "if (!isTRUE(result$synchronized)) quit(save = 'no', status = 1L)",
    sep = "; "
  )
  process_status <- system2(
    file.path(R.home("bin"), "Rscript"),
    c("--vanilla", "-e", shQuote(expression)), stdout = output, stderr = output,
    env = rrp_hospital_library_environment()
  )
  if (!identical(process_status, 0L)) stop(
    "renv status is inconsistent; release readiness is blocked: ",
    paste(tail(readLines(output, warn = FALSE), 12L), collapse = " | "),
    call. = FALSE
  )
  invisible(TRUE)
}

rrp_release_run_operation <- function(root, script, arguments = character()) {
  result <- rrp_hospital_run_process(file.path(root, script), arguments, root)
  if (!identical(result$status, 0L)) stop(
    "Clean-acquisition operation failed (`", script, "`): ",
    paste(tail(result$output, 12L), collapse = " | "), call. = FALSE
  )
  invisible(result)
}

rrp_release_copy_tree <- function(source, destination) {
  dir.create(destination, recursive = TRUE, showWarnings = FALSE)
  queue <- ""
  while (length(queue) > 0L) {
    relative_root <- queue[[1L]]
    queue <- queue[-1L]
    root <- if (nzchar(relative_root)) file.path(source, relative_root) else source
    for (name in list.files(root, all.files = TRUE, no.. = TRUE)) {
      relative <- if (nzchar(relative_root)) file.path(relative_root, name) else name
      from <- file.path(source, relative)
      to <- file.path(destination, relative)
      if (nzchar(Sys.readlink(from))) stop(
        "Clean-acquisition copy refuses symbolic links: ", relative, call. = FALSE
      )
      if (dir.exists(from)) {
        dir.create(to, recursive = TRUE, showWarnings = FALSE)
        queue <- c(queue, relative)
      } else {
        dir.create(dirname(to), recursive = TRUE, showWarnings = FALSE)
        if (!isTRUE(file.copy(from, to, overwrite = FALSE, copy.mode = TRUE))) stop(
          "Could not copy clean-acquisition member: ", relative, call. = FALSE
        )
      }
    }
  }
  invisible(destination)
}

rrp_release_prove_platform_acquisition <- function(archive_path) {
  candidate <- rrp_hospital_validate_platform_candidate_archive(archive_path)
  if (nrow(candidate$issues) > 0L) stop(
    "Platform candidate failed before acquisition proof.", call. = FALSE
  )
  root <- tempfile("rrp-platform-acquisition-")
  dir.create(root)
  on.exit(unlink(root, recursive = TRUE, force = TRUE), add = TRUE)
  rrp_hospital_extract_platform_entries(candidate$entries, root)
  if (!rrp_hospital_validate_extracted_platform(root, candidate$manifest)) stop(
    "Extracted Platform candidate differs from its inventory.", call. = FALSE
  )
  database <- file.path(root, "build", "acquisition", "history.duckdb")
  products <- file.path(root, "build", "acquisition", "products")
  artifacts <- file.path(root, "build", "acquisition", "artifacts")
  rrp_release_run_operation(root, "operations/initialize-platform.R",
                            c("--build-root", file.path(root, "build")))
  rrp_release_run_operation(root, "operations/doctor.R",
                            c("--database", database, "--products", products))
  rrp_release_run_operation(root, "operations/run-platform.R",
                            c("--scale", "test", "--database", database))
  rrp_release_run_operation(root, "operations/inspect-reference-history.R",
                            c("--scale", "test", "--database", database))
  rrp_release_run_operation(root, "operations/build-reference-products.R", c(
    "--scale", "test", "--database", database, "--materialize", "--products", products
  ))
  rrp_release_run_operation(root, "operations/launch-reference-app.R",
                            c("--products", products, "--validate-only"))
  rrp_release_run_operation(root, "operations/build-application-artifact.R",
                            c("--products", products, "--artifacts", artifacts))
  rrp_release_run_operation(root, "operations/validate-application-artifact.R",
                            c("--artifact", artifacts))
  list(status = "passed", authoritative_tree_lookup = FALSE,
       sibling_lookup = FALSE, network_used = FALSE)
}

rrp_release_prove_hospital_acquisition <- function(realization_root) {
  parent <- tempfile("rrp-hospital-acquisition-")
  dir.create(parent)
  on.exit(unlink(parent, recursive = TRUE, force = TRUE), add = TRUE)
  root <- file.path(parent, "readmission-risk-pool-hospital-implementation")
  rrp_release_copy_tree(realization_root, root)
  validated <- rrp_validate_completed_hospital_git_realization(root)
  if (!identical(validated$overall_status, "pass")) stop(
    "Copied Hospital Git realization failed standalone validation.", call. = FALSE
  )
  for (script in c(
    "operations/initialize.R", "operations/doctor.R",
    "operations/run-reference-acceptance.R", "operations/run-fictional-adopter-proof.R"
  )) rrp_release_run_operation(root, script)
  list(status = "passed", authoritative_tree_lookup = FALSE,
       sibling_lookup = FALSE, network_used = FALSE)
}

rrp_release_manifest_checksum <- function(root) rrp_hospital_sha256_file(file.path(
  root, "RELEASE-PREPARATION.yml"
))

rrp_release_output_exists <- function(path) {
  link <- Sys.readlink(path)
  file.exists(path) || (length(link) == 1L && !is.na(link) && nzchar(link))
}

rrp_validate_release_preparation <- function(root, run_acquisition = FALSE) {
  root <- normalizePath(root, mustWork = TRUE)
  manifest_path <- file.path(root, "RELEASE-PREPARATION.yml")
  checksum_path <- file.path(root, "RELEASE-PREPARATION.sha256")
  if (!file.exists(manifest_path) || !file.exists(checksum_path)) stop(
    "Release preparation manifest/checksum is missing.", call. = FALSE
  )
  checksum <- trimws(readLines(checksum_path, warn = FALSE))
  if (length(checksum) != 1L || !identical(checksum, rrp_release_manifest_checksum(root))) {
    stop("Release preparation manifest checksum mismatch.", call. = FALSE)
  }
  manifest <- rrp_hospital_read_yaml(manifest_path)
  if (!identical(manifest$manifest_kind, "release_preparation_manifest") ||
      !identical(manifest$manifest_version, "0.1.0") ||
      !identical(manifest$intended_versions$platform,
                 manifest$intended_versions$hospital) ||
      !identical(manifest$intended_versions$relationship, "independently_versioned") ||
      !identical(manifest$source$development_version,
                 paste0(manifest$intended_versions$platform, "-dev")) ||
      !identical(manifest$source$clean, TRUE) ||
      !is.character(manifest$source$revision) ||
      length(manifest$source$revision) != 1L ||
      !grepl("^[a-f0-9]{40}$", manifest$source$revision) ||
      !identical(manifest$platform$platform_version,
                 manifest$intended_versions$platform) ||
      !identical(manifest$platform$candidate_status,
                 "release_candidate_not_published") ||
      !identical(manifest$hospital$release_version,
                 manifest$intended_versions$hospital) ||
      !identical(manifest$governance,
                 list(license = "pass", governance = "pass", support = "pass")) ||
      !identical(manifest$validation$repository_checkpoint, "passed") ||
      !identical(manifest$validation$platform_candidate, "passed") ||
      !identical(manifest$validation$hospital_distribution, "passed") ||
      !identical(manifest$validation$hospital_git_realization, "passed") ||
      !identical(manifest$validation$platform_acquisition, "passed") ||
      !identical(manifest$validation$hospital_acquisition, "passed") ||
      !identical(manifest$validation$authoritative_tree_lookup, FALSE) ||
      !identical(manifest$validation$sibling_lookup, FALSE) ||
      !rrp_hospital_timestamp(manifest$prepared_at) ||
      !identical(manifest$publication$status, "not_published") ||
      !identical(manifest$publication$commit_created, FALSE) ||
      !identical(manifest$publication$tag_created, FALSE) ||
      !identical(manifest$publication$remote_added, FALSE) ||
      !identical(manifest$publication$pushed, FALSE) ||
      !identical(manifest$publication$github_release_created, FALSE) ||
      !identical(manifest$readiness$result, "READY FOR PUBLICATION")) stop(
    "Release preparation status or manifest identity is invalid.", call. = FALSE
  )
  relative_paths <- c(
    manifest$platform$archive_path, manifest$hospital$distribution_path,
    manifest$hospital$git_realization_path
  )
  if (length(relative_paths) != 3L ||
      !all(vapply(relative_paths, rrp_hospital_safe_relative_path, logical(1)))) stop(
    "Release preparation contains an unsafe artifact path.", call. = FALSE
  )
  archive <- file.path(root, manifest$platform$archive_path)
  candidate <- rrp_hospital_validate_platform_candidate_archive(
    archive, manifest$platform
  )
  if (nrow(candidate$issues) > 0L ||
      !identical(rrp_hospital_sha256_file(archive), manifest$platform$archive_sha256)) {
    stop("Platform release candidate validation failed.", call. = FALSE)
  }
  distribution <- rrp_validate_hospital_distribution(
    file.path(root, manifest$hospital$distribution_path), allow_local_state = FALSE
  )
  if (!identical(distribution$overall_status, "pass")) stop(
    "Hospital distribution release candidate validation failed.", call. = FALSE
  )
  distribution_manifest <- distribution$manifest
  realization <- rrp_validate_completed_hospital_git_realization(file.path(
    root, manifest$hospital$git_realization_path
  ))
  if (!identical(realization$overall_status, "pass")) stop(
    "Hospital Git realization release candidate validation failed.", call. = FALSE
  )
  realization_manifest <- rrp_hospital_read_yaml(file.path(
    root, manifest$hospital$git_realization_path, "HOSPITAL-GIT-REALIZATION.yml"
  ))
  embedded <- distribution_manifest$platform_candidate
  if (!identical(candidate$manifest$candidate_instance_id,
                 embedded$candidate_instance_id) ||
      !identical(manifest$platform$candidate_instance_id,
                 candidate$manifest$candidate_instance_id) ||
      !identical(manifest$platform$archive_sha256, embedded$archive_sha256) ||
      !identical(manifest$hospital$embedded_platform_candidate_instance_id,
                 embedded$candidate_instance_id) ||
      !identical(manifest$hospital$embedded_platform_archive_sha256,
                 embedded$archive_sha256) ||
      !identical(manifest$hospital$release_id,
                 distribution_manifest$hospital_implementation$release_id) ||
      !identical(manifest$hospital$release_version,
                 distribution_manifest$hospital_implementation$release_version) ||
      !identical(manifest$hospital$distribution_instance_id,
                 distribution_manifest$distribution_instance_id) ||
      !identical(manifest$hospital$distribution_build_id,
                 distribution_manifest$distribution_build_id) ||
      !identical(manifest$hospital$git_realization_instance_id,
                 realization_manifest$realization_instance_id)) stop(
    "Release evidence identity or embedded Platform digest mismatch.", call. = FALSE
  )
  if (run_acquisition) {
    rrp_release_prove_platform_acquisition(archive)
    rrp_release_prove_hospital_acquisition(file.path(
      root, manifest$hospital$git_realization_path
    ))
  }
  structure(list(overall_status = "pass", manifest = manifest, root = root),
            class = "rrp_release_preparation_validation_result")
}

rrp_prepare_release <- function(repository_root, version, prepared_at = rrp_hospital_now()) {
  repository_root <- normalizePath(repository_root, mustWork = TRUE)
  governance <- rrp_release_validate_governance(repository_root, version)
  source_revision <- rrp_release_source_revision(repository_root, require_clean = TRUE)
  release_parent <- file.path(repository_root, "build", "releases")
  final <- file.path(release_parent, version)
  if (rrp_release_output_exists(final)) stop(
    "Release preparation destination already exists; validate or preserve it for review rather than replacing it.",
    call. = FALSE
  )
  rrp_release_validate_renv(repository_root)
  repository_validation <- rrp_hospital_run_process(
    file.path(repository_root, "operations", "validate.R"),
    c("--mode", "checkpoint"), repository_root
  )
  if (!identical(repository_validation$status, 0L)) stop(
    "Repository checkpoint validation failed; release readiness is blocked: ",
    paste(tail(repository_validation$output, 12L), collapse = " | "), call. = FALSE
  )
  if (rrp_release_output_exists(final)) stop(
    "Release preparation destination appeared during prerequisite validation; stop concurrent or interrupted preparation and inspect it before retrying.",
    call. = FALSE
  )
  dir.create(release_parent, recursive = TRUE, showWarnings = FALSE)
  staging <- tempfile(paste0(".", version, "-staging-"), tmpdir = release_parent)
  dir.create(staging)
  on.exit(if (dir.exists(staging)) unlink(staging, recursive = TRUE, force = TRUE), add = TRUE)

  platform <- rrp_build_platform_release_candidate(
    repository_root, staging, version, "release_candidate_not_published",
    source_revision
  )
  platform_directory <- file.path(staging, "platform")
  writeLines(platform$archive_sha256, file.path(
    platform_directory, paste0(platform$archive_filename, ".sha256")
  ), useBytes = TRUE)
  rrp_hospital_write_yaml(platform$manifest, file.path(
    platform_directory, "PLATFORM-CANDIDATE.yml"
  ))

  distribution_store <- file.path(staging, "hospital", "distribution-store")
  hospital <- rrp_build_hospital_distribution(
    repository_root, distribution_store, prepared_at, version, version,
    "release_candidate_not_published", source_revision
  )
  if (!identical(platform$manifest$candidate_instance_id,
                 hospital$platform_candidate_instance_id) ||
      !identical(platform$archive_sha256, hospital$platform_archive_sha256)) stop(
    "Hospital candidate does not embed the exact prepared Platform candidate.",
    call. = FALSE
  )
  realization_path <- file.path(staging, "hospital", "git-realization")
  realization <- rrp_build_hospital_git_realization(
    repository_root, hospital$distribution_path, realization_path, prepared_at,
    allow_ignored_release_area = TRUE
  )

  platform_acquisition <- rrp_release_prove_platform_acquisition(platform$archive_path)
  hospital_acquisition <- rrp_release_prove_hospital_acquisition(realization_path)
  distribution_manifest <- rrp_hospital_read_yaml(file.path(
    hospital$distribution_path, "HOSPITAL-DISTRIBUTION.yml"
  ))
  realization_manifest <- rrp_hospital_read_yaml(file.path(
    realization_path, "HOSPITAL-GIT-REALIZATION.yml"
  ))
  manifest <- list(
    manifest_kind = "release_preparation_manifest",
    manifest_version = "0.1.0",
    intended_versions = list(platform = version, hospital = version,
                             relationship = "independently_versioned"),
    source = list(revision = source_revision,
                  development_version = governance$development_version,
                  clean = TRUE),
    platform = list(
      platform_id = platform$manifest$platform_identity$platform_id,
      platform_version = version,
      candidate_instance_id = platform$manifest$candidate_instance_id,
      candidate_status = platform$manifest$candidate_status,
      archive_path = file.path("platform", platform$archive_filename),
      archive_sha256 = platform$archive_sha256
    ),
    hospital = list(
      release_id = distribution_manifest$hospital_implementation$release_id,
      release_version = distribution_manifest$hospital_implementation$release_version,
      distribution_instance_id = hospital$distribution_instance_id,
      distribution_build_id = hospital$distribution_build_id,
      distribution_path = file.path(
        "hospital", "distribution-store", "distributions",
        basename(hospital$distribution_path)
      ),
      git_realization_instance_id = realization$realization_instance_id,
      git_realization_path = file.path("hospital", "git-realization"),
      embedded_platform_candidate_instance_id =
        distribution_manifest$platform_candidate$candidate_instance_id,
      embedded_platform_archive_sha256 =
        distribution_manifest$platform_candidate$archive_sha256
    ),
    governance = list(license = governance$license,
                      governance = governance$governance, support = governance$support),
    tested_environment = list(
      r_version = R.version.string, platform = R.version$platform,
      operating_system = paste(Sys.info()[c("sysname", "release", "machine")],
                               collapse = " "),
      renv_restore = "declared_by_shipped_lock",
      dependency_acquisition = "may_require_network_on_first_restore"
    ),
    validation = list(
      repository_checkpoint = "passed", platform_candidate = "passed",
      hospital_distribution = "passed", hospital_git_realization = "passed",
      platform_acquisition = platform_acquisition$status,
      hospital_acquisition = hospital_acquisition$status,
      authoritative_tree_lookup = FALSE, sibling_lookup = FALSE
    ),
    prepared_at = prepared_at,
    publication = list(status = "not_published", commit_created = FALSE,
                       tag_created = FALSE, remote_added = FALSE,
                       pushed = FALSE, github_release_created = FALSE),
    readiness = list(result = "READY FOR PUBLICATION")
  )
  dir.create(file.path(staging, "evidence"), recursive = TRUE, showWarnings = FALSE)
  file.copy(file.path(repository_root, "CHANGELOG.md"), file.path(
    staging, "evidence", "RELEASE-NOTES.md"
  ), overwrite = FALSE)
  rrp_hospital_write_yaml(manifest, file.path(staging, "RELEASE-PREPARATION.yml"))
  writeLines(rrp_release_manifest_checksum(staging), file.path(
    staging, "RELEASE-PREPARATION.sha256"
  ), useBytes = TRUE)
  validation <- rrp_validate_release_preparation(staging, run_acquisition = FALSE)
  if (!identical(validation$overall_status, "pass")) stop(
    "Staged release preparation failed final validation.", call. = FALSE
  )
  if (!file.rename(staging, final)) stop(
    "Could not atomically expose the release-preparation result.", call. = FALSE
  )
  structure(list(overall_status = "pass", root = final, manifest = manifest),
            class = "rrp_release_preparation_result")
}
