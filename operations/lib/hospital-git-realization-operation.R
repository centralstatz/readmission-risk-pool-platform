# Maintainer-only construction of a standalone Git repository from one already
# validated Hospital Implementation distribution artifact.

rrp_load_hospital_git_realization_runtime <- function(
  distribution_root,
  envir = parent.frame()
) {
  sys.source(file.path(
    distribution_root, "R", "distribution-runtime.R"
  ), envir = envir)
  sys.source(file.path(
    distribution_root, "R", "git-realization-runtime.R"
  ), envir = envir)
  invisible(TRUE)
}

rrp_hospital_git_path_within <- function(path, root) {
  path <- normalizePath(path, mustWork = FALSE)
  root <- normalizePath(root, mustWork = FALSE)
  identical(path, root) || startsWith(path, paste0(root, .Platform$file.sep))
}

rrp_hospital_git_is_link <- function(path) {
  target <- Sys.readlink(path)
  length(target) == 1L && !is.na(target) && nzchar(target)
}

rrp_hospital_git_copy_distribution <- function(source_root, destination_root) {
  tree <- rrp_hospital_scan_tree(
    source_root, allow_local_state = FALSE, allow_git_realization = FALSE
  )
  if (length(tree$symlinks) > 0L) stop(
    "Validated source distribution unexpectedly contains symbolic links.",
    call. = FALSE
  )
  for (relative in tree$files) rrp_hospital_copy_regular_file(
    file.path(source_root, relative), destination_root, relative
  )
  invisible(tree$files)
}

rrp_hospital_git_write_manifest <- function(root, distribution, realized_at) {
  tree <- rrp_hospital_git_scan_tree(root)
  source_inventory <- rrp_hospital_git_inventory_records(root, tree$files)
  distribution_manifest <- distribution$manifest
  manifest <- list(
    manifest_kind = "hospital_implementation_git_realization_manifest",
    manifest_version = "0.1.0",
    realization_specification = rrp_hospital_git_specification(),
    realization_instance_id = "pending",
    realized_at = realized_at,
    source_distribution = list(
      distribution_specification = distribution_manifest$distribution_specification,
      hospital_implementation = distribution_manifest$hospital_implementation,
      distribution_instance_id = distribution_manifest$distribution_instance_id,
      distribution_build_id = distribution_manifest$distribution_build_id,
      manifest_sha256 = rrp_hospital_sha256_file(file.path(
        root, "HOSPITAL-DISTRIBUTION.yml"
      ))
    ),
    included_platform = list(
      platform_id = distribution_manifest$platform_candidate$platform_id,
      platform_version = distribution_manifest$platform_candidate$platform_version,
      candidate_instance_id = distribution_manifest$platform_candidate$candidate_instance_id,
      archive_filename = distribution_manifest$platform_candidate$archive_filename,
      archive_sha256 = distribution_manifest$platform_candidate$archive_sha256,
      public_release = FALSE
    ),
    builder = rrp_hospital_git_builder_reference(),
    repository_semantics = list(
      ownership = "pristine_generated_output_only",
      initial_branch = "main",
      generated_files_staged = TRUE,
      generated_commit = FALSE,
      configured_remote = FALSE,
      replacement_after_change = "prohibited"
    ),
    expected_repository_files = as.list(sort(c(
      tree$files, rrp_hospital_git_metadata_files()
    ), method = "radix")),
    source_inventory = source_inventory,
    provenance = list(
      input_kind = "independently_validated_hospital_distribution",
      input_validation = "artifact_owned_validator_passed",
      exact_distribution_copy = TRUE,
      authoritative_source_lookup = FALSE,
      destination_is_identity = FALSE,
      git_commit_is_identity = FALSE,
      published = FALSE
    ),
    validation_evidence = c(
      rrp_hospital_git_validator_reference(), list(status = "passed")
    ),
    validation_status = "passed",
    nonclaims = list(
      "not a maintained CentralStatz source repository",
      "not committed tagged remote-configured pushed or published",
      "release candidate only; not a published Platform or Hospital release",
      "not an upgrade merge or preservation mechanism for recipient changes",
      "not clinically validated security approved or production authorized"
    )
  )
  manifest$realization_instance_id <- rrp_hospital_git_realization_id(manifest)
  rrp_hospital_write_yaml(manifest, file.path(
    root, "HOSPITAL-GIT-REALIZATION.yml"
  ))
  writeLines(
    rrp_hospital_sha256_file(file.path(root, "HOSPITAL-GIT-REALIZATION.yml")),
    file.path(root, "HOSPITAL-GIT-REALIZATION.sha256"), useBytes = TRUE
  )
  manifest
}

rrp_hospital_git_initialize <- function(root) {
  if (!nzchar(Sys.which("git"))) stop(
    "Git is required to initialize the Hospital Implementation realization.",
    call. = FALSE
  )
  initialized <- rrp_hospital_git_run(root, c("init", "--initial-branch=main"))
  if (!identical(initialized$status, 0L)) stop(
    "Could not initialize the Hospital Implementation Git repository: ",
    paste(initialized$output, collapse = " | "), call. = FALSE
  )
  staged <- rrp_hospital_git_run(root, c("add", "--all"))
  if (!identical(staged$status, 0L)) stop(
    "Could not stage generated Hospital Implementation files: ",
    paste(staged$output, collapse = " | "), call. = FALSE
  )
  invisible(TRUE)
}

rrp_hospital_git_promote <- function(staging, destination, existing_owned) {
  if (!existing_owned) {
    if (!file.rename(staging, destination)) stop(
      "Could not atomically expose the Hospital Implementation Git realization.",
      call. = FALSE
    )
    return(list(destination = destination, backup = NULL))
  }
  parent <- dirname(destination)
  backup <- tempfile(".rrp-hospital-git-previous-", tmpdir = parent)
  if (!file.rename(destination, backup)) stop(
    "Could not move the pristine generated destination aside safely.",
    call. = FALSE
  )
  if (!file.rename(staging, destination)) {
    restored <- file.rename(backup, destination)
    stop(
      "Could not expose the replacement realization; prior pristine state ",
      if (restored) "was restored." else "could not be restored automatically.",
      call. = FALSE
    )
  }
  list(destination = destination, backup = backup)
}

rrp_hospital_git_finish_promotion <- function(promotion, validation) {
  if (identical(validation$overall_status, "pass")) {
    if (!is.null(promotion$backup)) unlink(
      promotion$backup, recursive = TRUE, force = TRUE
    )
    return(invisible(TRUE))
  }
  unlink(promotion$destination, recursive = TRUE, force = TRUE)
  restored <- is.null(promotion$backup) || file.rename(
    promotion$backup, promotion$destination
  )
  stop(
    "Promoted Hospital Git realization failed standalone validation; ",
    if (restored) {
      if (is.null(promotion$backup)) "the failed destination was removed."
      else "the prior pristine destination was restored."
    } else "the prior pristine destination could not be restored automatically.",
    call. = FALSE
  )
}

rrp_build_hospital_git_realization <- function(
  repository_root,
  distribution_path,
  destination,
  realized_at = rrp_hospital_now(),
  allow_ignored_release_area = FALSE
) {
  repository_root <- normalizePath(repository_root, mustWork = TRUE)
  destination_link <- rrp_hospital_git_is_link(destination)
  destination <- normalizePath(destination, mustWork = FALSE)
  if (!rrp_hospital_timestamp(realized_at)) stop(
    "Hospital Git realization time must be an RFC 3339 timestamp.", call. = FALSE
  )
  inside_repository <- rrp_hospital_git_path_within(destination, repository_root)
  release_root <- normalizePath(file.path(
    repository_root, "build", "releases"
  ), mustWork = FALSE)
  allowed_release_destination <- isTRUE(allow_ignored_release_area) &&
    rrp_hospital_git_path_within(destination, release_root) &&
    !identical(destination, release_root)
  if (destination_link || (inside_repository && !allowed_release_destination)) stop(
    paste(
      "Hospital Git destination must be a non-linked path outside the authoritative",
      "repository unless the release preparer selects its exact ignored build/releases area."
    ), call. = FALSE
  )
  parent_input <- dirname(destination)
  parent_link <- rrp_hospital_git_is_link(parent_input)
  parent <- normalizePath(parent_input, mustWork = FALSE)
  if (!dir.exists(parent) || parent_link) stop(
    "Hospital Git destination parent must already exist as a regular directory.",
    call. = FALSE
  )
  destination <- file.path(parent, basename(destination))
  if (file.exists(destination) && (!dir.exists(destination) ||
      rrp_hospital_git_is_link(destination))) stop(
    "Existing Hospital Git destination is not a regular directory.", call. = FALSE
  )

  distribution_root <- rrp_resolve_hospital_distribution(distribution_path)
  if (rrp_hospital_git_path_within(destination, distribution_root) ||
      rrp_hospital_git_path_within(distribution_root, destination)) stop(
    "Hospital distribution and Git destination must not contain one another.",
    call. = FALSE
  )
  independent <- rrp_validate_completed_hospital_distribution(distribution_root)
  if (!identical(independent$overall_status, "pass")) stop(
    "Git realization requires an independently valid Hospital distribution: ",
    paste(independent$output, collapse = " | "), call. = FALSE
  )
  rrp_load_hospital_git_realization_runtime(distribution_root, parent.frame())
  distribution <- rrp_validate_hospital_distribution(
    distribution_root, allow_local_state = FALSE, allow_git_realization = FALSE
  )
  if (!identical(distribution$overall_status, "pass")) stop(
    "Git realization source distribution is invalid: ",
    paste(distribution$issues$issue_code, collapse = ", "), call. = FALSE
  )

  staging <- tempfile(".rrp-hospital-git-staging-", tmpdir = parent)
  dir.create(staging)
  if (!dir.exists(staging) || rrp_hospital_git_is_link(staging)) stop(
    "Could not create a regular Hospital Git staging directory.", call. = FALSE
  )
  on.exit(if (dir.exists(staging)) unlink(
    staging, recursive = TRUE, force = TRUE
  ), add = TRUE)
  rrp_hospital_git_copy_distribution(distribution_root, staging)
  manifest <- rrp_hospital_git_write_manifest(staging, distribution, realized_at)
  staged_content <- rrp_validate_hospital_git_realization(
    staging, check_git = FALSE, run_distribution_validator = FALSE
  )
  if (!identical(staged_content$overall_status, "pass")) stop(
    "Staged Hospital Git realization failed content validation: ",
    paste(paste0(
      staged_content$issues$issue_code, " (", staged_content$issues$message, ")"
    ), collapse = "; "), call. = FALSE
  )
  rrp_hospital_git_initialize(staging)
  staged <- rrp_validate_hospital_git_realization(
    staging, check_git = TRUE, run_distribution_validator = FALSE
  )
  if (!identical(staged$overall_status, "pass")) stop(
    "Staged Hospital Git realization failed Git validation: ",
    paste(staged$issues$issue_code, collapse = ", "), call. = FALSE
  )

  existing_owned <- dir.exists(destination)
  if (existing_owned) {
    existing <- rrp_validate_hospital_git_realization(
      destination, check_git = TRUE, run_distribution_validator = FALSE
    )
    if (!identical(existing$overall_status, "pass")) stop(
      "Existing destination is unrelated, modified, committed, remote-configured, ",
      "or otherwise outside pristine generator ownership: ",
      paste(existing$issues$issue_code, collapse = ", "), call. = FALSE
    )
    if (identical(
      existing$manifest$realization_instance_id,
      manifest$realization_instance_id
    )) {
      unlink(staging, recursive = TRUE, force = TRUE)
      return(structure(list(
        overall_status = "succeeded",
        realization_instance_id = manifest$realization_instance_id,
        distribution_instance_id = manifest$source_distribution$distribution_instance_id,
        distribution_build_id = manifest$source_distribution$distribution_build_id,
        platform_candidate_instance_id = manifest$included_platform$candidate_instance_id,
        destination = destination,
        idempotent = TRUE,
        replaced = FALSE,
        validation = existing
      ), class = "rrp_hospital_git_realization_build_result"))
    }
  }

  promotion <- rrp_hospital_git_promote(staging, destination, existing_owned)
  promoted <- rrp_validate_completed_hospital_git_realization(destination)
  rrp_hospital_git_finish_promotion(promotion, promoted)
  structure(list(
    overall_status = "succeeded",
    realization_instance_id = manifest$realization_instance_id,
    distribution_instance_id = manifest$source_distribution$distribution_instance_id,
    distribution_build_id = manifest$source_distribution$distribution_build_id,
    platform_candidate_instance_id = manifest$included_platform$candidate_instance_id,
    destination = destination,
    idempotent = FALSE,
    replaced = existing_owned,
    validation = promoted
  ), class = "rrp_hospital_git_realization_build_result")
}

rrp_validate_completed_hospital_git_realization <- function(destination) {
  root <- normalizePath(destination, mustWork = TRUE)
  script <- file.path(root, "validate-git-realization.R")
  if (!file.exists(script) || dir.exists(script) || nzchar(Sys.readlink(script))) stop(
    "Generated repository has no regular standalone Hospital Git validator.",
    call. = FALSE
  )
  result <- rrp_hospital_run_process(script, character(), root)
  structure(list(
    overall_status = if (identical(result$status, 0L)) "pass" else "fail",
    realization_path = root,
    process_status = result$status,
    output = result$output
  ), class = "rrp_hospital_git_realization_process_validation_result")
}
