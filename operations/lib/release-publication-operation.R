# Explicit maintainer publication for the two v0.1.0 release products.
# Every remote-changing stage follows one complete fail-closed preflight and is
# recorded locally so an interrupted run can distinguish exact prior work from
# a conflict. No stage deletes, force-pushes, or rewrites remote state.

rrp_publication_stage_names <- function() c(
  "preflight_complete",
  "platform_security_enabled",
  "platform_tag_pushed",
  "platform_release_created",
  "platform_verified",
  "hospital_repository_ready",
  "hospital_commit_pushed",
  "hospital_tag_pushed",
  "hospital_release_created",
  "hospital_verified",
  "publication_complete"
)

rrp_publication_api_ok <- function(response, expected, action) {
  if (!is.list(response) || length(response$status) != 1L ||
      !response$status %in% expected) stop(
    action, " failed with GitHub HTTP status ",
    if (is.list(response)) response$status else "unknown", ".",
    call. = FALSE
  )
  response
}

rrp_publication_git_output <- function(root, arguments, action) {
  result <- rrp_release_git(root, arguments)
  if (!identical(result$status, 0L)) stop(
    action, " failed: ", paste(tail(result$output, 8L), collapse = " | "),
    call. = FALSE
  )
  result$output
}

rrp_publication_remote_identity <- function(remote_url) {
  match <- regexec(
    "^https://github[.]com/([A-Za-z0-9_.-]+)/([A-Za-z0-9_.-]+?)([.]git)?$",
    remote_url, perl = TRUE
  )
  values <- regmatches(remote_url, match)[[1L]]
  if (length(values) != 4L) stop(
    "The publication remote must be one exact HTTPS GitHub repository URL.",
    call. = FALSE
  )
  list(owner = values[[2L]], name = values[[3L]],
       repository = paste(values[[2L]], values[[3L]], sep = "/"))
}

rrp_publication_configuration <- function(repository_root, version) {
  authority <- rrp_release_authority(repository_root)
  publication <- authority$publication
  required <- c(
    "remote", "expected_branch", "platform_repository", "hospital_repository",
    "expected_platform_tag", "expected_hospital_tag"
  )
  if (length(setdiff(required, names(publication))) > 0L ||
      !identical(publication$status, "not_published") ||
      !identical(authority$targets$platform$intended_version, version) ||
      !identical(authority$targets$hospital$intended_version, version) ||
      !identical(publication$expected_platform_tag, paste0("v", version)) ||
      !identical(publication$expected_hospital_tag, paste0("v", version))) stop(
    "RELEASE.yml does not authorize this exact unpublished release target.",
    call. = FALSE
  )
  platform <- strsplit(publication$platform_repository, "/", fixed = TRUE)[[1L]]
  hospital <- strsplit(publication$hospital_repository, "/", fixed = TRUE)[[1L]]
  if (length(platform) != 2L || length(hospital) != 2L ||
      !identical(platform[[1L]], hospital[[1L]])) stop(
    "Platform and Hospital publication targets must name one expected GitHub owner.",
    call. = FALSE
  )
  list(
    owner = platform[[1L]], platform_repository = publication$platform_repository,
    hospital_repository = publication$hospital_repository,
    hospital_name = hospital[[2L]], remote = publication$remote,
    branch = publication$expected_branch,
    platform_tag = publication$expected_platform_tag,
    hospital_tag = publication$expected_hospital_tag
  )
}

rrp_publication_state_root <- function(preparation_root) file.path(
  preparation_root, "publication"
)

rrp_publication_state_checksum <- function(root) rrp_hospital_sha256_file(file.path(
  root, "PUBLICATION-STATE.yml"
))

rrp_publication_read_state <- function(preparation_root) {
  root <- rrp_publication_state_root(preparation_root)
  manifest_path <- file.path(root, "PUBLICATION-STATE.yml")
  checksum_path <- file.path(root, "PUBLICATION-STATE.sha256")
  if (!file.exists(manifest_path) && !file.exists(checksum_path)) {
    unexpected <- if (dir.exists(root)) {
      list.files(root, all.files = TRUE, no.. = TRUE)
    } else character()
    if (length(unexpected) > 0L) stop(
      "Publication directory contains untracked state without a valid stage manifest.",
      call. = FALSE
    )
    return(NULL)
  }
  if (!file.exists(manifest_path) || !file.exists(checksum_path)) stop(
    "Publication state is incomplete; preserve it and inspect before retrying.",
    call. = FALSE
  )
  checksum <- trimws(readLines(checksum_path, warn = FALSE))
  if (length(checksum) != 1L ||
      !identical(checksum, rrp_publication_state_checksum(root))) stop(
    "Publication state checksum mismatch; no remote action is safe.", call. = FALSE
  )
  state <- rrp_hospital_read_yaml(manifest_path)
  if (!is.list(state) || !identical(state$manifest_kind, "release_publication_state") ||
      !identical(state$manifest_version, "0.1.0") ||
      !all(vapply(state$completed_stages, function(stage) {
        stage %in% rrp_publication_stage_names()
      }, logical(1)))) stop(
    "Publication state is unsupported or contains an unknown stage.", call. = FALSE
  )
  state
}

rrp_publication_write_state <- function(preparation_root, state) {
  root <- rrp_publication_state_root(preparation_root)
  dir.create(root, recursive = TRUE, showWarnings = FALSE)
  manifest_path <- file.path(root, "PUBLICATION-STATE.yml")
  checksum_path <- file.path(root, "PUBLICATION-STATE.sha256")
  temporary_manifest <- tempfile(".publication-state-", tmpdir = root)
  temporary_checksum <- tempfile(".publication-state-", tmpdir = root)
  on.exit(unlink(c(temporary_manifest, temporary_checksum), force = TRUE), add = TRUE)
  rrp_hospital_write_yaml(state, temporary_manifest)
  writeLines(
    rrp_hospital_sha256_file(temporary_manifest), temporary_checksum,
    useBytes = TRUE
  )
  if (!file.rename(temporary_manifest, manifest_path) ||
      !file.rename(temporary_checksum, checksum_path)) stop(
    "Could not atomically retain publication state.", call. = FALSE
  )
  invisible(state)
}

rrp_publication_initial_state <- function(preflight) list(
  manifest_kind = "release_publication_state",
  manifest_version = "0.1.0",
  version = preflight$version,
  source_revision = preflight$source_revision,
  platform_repository = preflight$config$platform_repository,
  hospital_repository = preflight$config$hospital_repository,
  platform_candidate_instance_id =
    preflight$preparation$platform$candidate_instance_id,
  platform_archive_sha256 = preflight$preparation$platform$archive_sha256,
  hospital_distribution_instance_id =
    preflight$preparation$hospital$distribution_instance_id,
  hospital_git_realization_instance_id =
    preflight$preparation$hospital$git_realization_instance_id,
  completed_stages = list("preflight_complete"),
  stage_evidence = list(),
  overall_status = "publication_in_progress",
  started_at = rrp_hospital_now(),
  updated_at = rrp_hospital_now()
)

rrp_publication_complete_stage <- function(
  preparation_root, state, stage, evidence = list()
) {
  if (!stage %in% rrp_publication_stage_names()) stop(
    "Unknown publication stage: ", stage, call. = FALSE
  )
  if (!stage %in% unlist(state$completed_stages, use.names = FALSE)) {
    state$completed_stages <- c(state$completed_stages, list(stage))
  }
  state$stage_evidence[[stage]] <- evidence
  state$updated_at <- rrp_hospital_now()
  if (identical(stage, "publication_complete")) {
    state$overall_status <- "published_and_verified"
    state$completed_at <- state$updated_at
  }
  rrp_publication_write_state(preparation_root, state)
  state
}

rrp_publication_stage_complete <- function(state, stage) {
  stage %in% unlist(state$completed_stages, use.names = FALSE)
}

rrp_publication_checkpoint <- function(repository_root) {
  result <- rrp_hospital_run_process(
    file.path(repository_root, "operations", "validate.R"),
    c("--mode", "checkpoint"), repository_root
  )
  if (!identical(result$status, 0L)) stop(
    "Publication preflight checkpoint validation failed: ",
    paste(tail(result$output, 12L), collapse = " | "), call. = FALSE
  )
  invisible(TRUE)
}

rrp_publication_exact_tag_commit <- function(client, repository, tag) {
  reference <- rrp_publication_api_ok(
    client$tag(repository, tag), 200L, "GitHub tag lookup"
  )$data
  if (identical(reference$object$type, "commit")) return(reference$object$sha)
  if (!identical(reference$object$type, "tag")) stop(
    "GitHub tag has an unsupported target type.", call. = FALSE
  )
  tag_object <- rrp_publication_api_ok(
    client$annotated_tag(repository, reference$object$sha), 200L,
    "Annotated tag lookup"
  )$data
  if (!identical(tag_object$object$type, "commit")) stop(
    "Annotated tag does not resolve directly to a commit.", call. = FALSE
  )
  tag_object$object$sha
}

rrp_publication_validate_absent_or_exact <- function(
  response, absent_status, exact, conflict_message
) {
  if (identical(response$status, absent_status)) return("absent")
  if (identical(response$status, 200L) && isTRUE(exact(response$data))) return("exact")
  stop(conflict_message, call. = FALSE)
}

rrp_publication_preflight <- function(
  repository_root,
  version,
  client,
  run_checkpoint = TRUE
) {
  repository_root <- normalizePath(repository_root, mustWork = TRUE)
  config <- rrp_publication_configuration(repository_root, version)
  git <- Sys.which("git")
  if (!nzchar(git)) stop("Git is unavailable for publication.", call. = FALSE)
  if (!nzchar(Sys.which("curl"))) stop("curl is unavailable for publication.", call. = FALSE)
  branch <- rrp_publication_git_output(
    repository_root, c("branch", "--show-current"), "Branch inspection"
  )
  if (length(branch) != 1L || !identical(branch, config$branch)) stop(
    "Publication requires the expected authoritative branch `", config$branch, "`.",
    call. = FALSE
  )
  source_revision <- rrp_release_source_revision(repository_root, require_clean = TRUE)
  remote_url <- rrp_publication_git_output(
    repository_root, c("remote", "get-url", config$remote), "Remote inspection"
  )
  if (length(remote_url) != 1L) stop(
    "Publication requires one exact authoritative remote URL.", call. = FALSE
  )
  identity <- rrp_publication_remote_identity(remote_url)
  if (!identical(identity$repository, config$platform_repository)) stop(
    "Authoritative Platform remote identity conflicts with RELEASE.yml.",
    call. = FALSE
  )
  dry_run <- rrp_release_git(
    repository_root, c("push", "--dry-run", config$remote, config$branch)
  )
  if (!identical(dry_run$status, 0L)) stop(
    "Authenticated Git push dry-run failed; publication capability is unavailable.",
    call. = FALSE
  )
  author_name <- rrp_publication_git_output(
    repository_root, c("config", "user.name"), "Git author-name inspection"
  )
  author_email <- rrp_publication_git_output(
    repository_root, c("config", "user.email"), "Git author-email inspection"
  )
  if (length(author_name) != 1L || !nzchar(author_name) ||
      length(author_email) != 1L || !grepl("@", author_email, fixed = TRUE)) stop(
    "Git cannot determine safe release authorship.", call. = FALSE
  )
  preparation_root <- file.path(repository_root, "build", "releases", version)
  prepared <- rrp_validate_release_preparation(preparation_root, run_acquisition = FALSE)
  if (!identical(prepared$manifest$source$revision, source_revision)) stop(
    "Prepared candidate source revision does not equal the intended release commit.",
    call. = FALSE
  )
  release_notes <- file.path(preparation_root, "evidence", "RELEASE-NOTES.md")
  if (!file.exists(release_notes) || file.info(release_notes)$size == 0) stop(
    "Prepared release notes are missing.", call. = FALSE
  )
  if (isTRUE(run_checkpoint)) rrp_publication_checkpoint(repository_root)

  user <- rrp_publication_api_ok(
    client$authenticated_user(), 200L, "GitHub authentication"
  )$data
  if (!is.character(user$login) || length(user$login) != 1L || !nzchar(user$login)) stop(
    "Authenticated GitHub identity is unavailable.", call. = FALSE
  )
  platform <- rrp_publication_api_ok(
    client$repository(config$platform_repository), 200L,
    "Authoritative Platform repository lookup"
  )$data
  if (!identical(platform$full_name, config$platform_repository) ||
      !identical(platform$default_branch, config$branch) ||
      isTRUE(platform$private) || isTRUE(platform$archived) || isTRUE(platform$disabled) ||
      !isTRUE(platform$permissions$push) || !isTRUE(platform$permissions$admin)) stop(
    "Authenticated Platform repository identity or publication permission is invalid.",
    call. = FALSE
  )
  remote_branch <- rrp_publication_api_ok(
    client$branch(config$platform_repository, config$branch), 200L,
    "Authoritative Platform branch lookup"
  )$data
  remote_revision <- remote_branch$object$sha
  if (!is.character(remote_revision) || length(remote_revision) != 1L ||
      !grepl("^[a-f0-9]{40}$", remote_revision)) stop(
    "Authoritative remote branch revision is invalid.", call. = FALSE
  )
  ancestry <- rrp_release_git(
    repository_root, c("merge-base", "--is-ancestor", remote_revision, source_revision)
  )
  if (!identical(ancestry$status, 0L)) stop(
    "Authoritative remote branch has diverged from the intended release commit.",
    call. = FALSE
  )
  membership <- rrp_publication_api_ok(
    client$membership(config$owner, user$login), 200L,
    "GitHub organization membership lookup"
  )$data
  if (!identical(membership$state, "active") || !identical(membership$role, "admin")) stop(
    "Authenticated identity is not an active administrator of the expected owner.",
    call. = FALSE
  )
  organization <- rrp_publication_api_ok(
    client$organization(config$owner), 200L, "GitHub organization lookup"
  )$data
  if (!isTRUE(organization$members_can_create_public_repositories)) stop(
    "Expected GitHub owner does not permit public repository creation.", call. = FALSE
  )
  rules <- client$branch_rules(config$platform_repository, config$branch)
  if (!rules$status %in% c(200L, 404L) ||
      (identical(rules$status, 200L) && length(rules$data) > 0L)) stop(
    "Platform branch rules conflict with the controlled publication workflow.",
    call. = FALSE
  )
  protection <- client$branch_protection(config$platform_repository, config$branch)
  if (!protection$status %in% c(200L, 404L) || identical(protection$status, 200L)) stop(
    "Platform branch protection requires maintainer review before publication.",
    call. = FALSE
  )

  state <- rrp_publication_read_state(preparation_root)
  partial <- !is.null(state)
  local_tag <- rrp_release_git(
    repository_root, c("rev-parse", "--verify", paste0("refs/tags/", config$platform_tag))
  )
  if (!partial && identical(local_tag$status, 0L)) stop(
    "Platform release tag already exists locally; preflight refuses a conflict.",
    call. = FALSE
  )
  if (partial && identical(local_tag$status, 0L)) {
    local_commit <- rrp_publication_git_output(
      repository_root, c("rev-list", "-n", "1", config$platform_tag),
      "Local Platform tag inspection"
    )
    if (!identical(local_commit, source_revision)) stop(
      "Existing local Platform tag targets a different revision.", call. = FALSE
    )
  }
  tag_response <- client$tag(config$platform_repository, config$platform_tag)
  release_response <- client$release(config$platform_repository, config$platform_tag)
  if (!partial) {
    rrp_publication_validate_absent_or_exact(
      tag_response, 404L, function(value) FALSE,
      "Platform release tag already exists; preflight refuses a conflict."
    )
    rrp_publication_validate_absent_or_exact(
      release_response, 404L, function(value) FALSE,
      "Platform GitHub Release already exists; preflight refuses a conflict."
    )
  } else {
    if (!identical(state$source_revision, source_revision) ||
        !identical(state$platform_archive_sha256,
                   prepared$manifest$platform$archive_sha256)) stop(
      "Retained publication state belongs to a different release candidate.",
      call. = FALSE
    )
    if (identical(tag_response$status, 200L)) {
      if (!identical(rrp_publication_exact_tag_commit(
        client, config$platform_repository, config$platform_tag
      ), source_revision)) stop(
        "Existing Platform tag does not identify this release commit.", call. = FALSE
      )
    } else if (identical(tag_response$status, 404L)) {
      if (rrp_publication_stage_complete(state, "platform_tag_pushed")) stop(
        "Retained Platform tag stage is missing from the remote repository.",
        call. = FALSE
      )
    } else stop(
      "Unexpected Platform tag exists outside retained publication state.", call. = FALSE
    )
    if (identical(release_response$status, 200L)) {
      exact_release <- identical(release_response$status, 200L) &&
        identical(release_response$data$tag_name, config$platform_tag) &&
        !isTRUE(release_response$data$draft) &&
        !isTRUE(release_response$data$prerelease)
      if (!exact_release) stop(
        "Unexpected Platform release exists outside retained publication state.",
        call. = FALSE
      )
    } else if (identical(release_response$status, 404L)) {
      if (rrp_publication_stage_complete(state, "platform_release_created")) stop(
        "Retained Platform release stage is missing from GitHub.", call. = FALSE
      )
    } else stop(
      "Platform GitHub Release lookup returned unexpected state.", call. = FALSE
    )
  }
  hospital <- client$repository(config$hospital_repository)
  if (!partial && !identical(hospital$status, 404L)) stop(
    "Hospital repository identity is already occupied; publication refuses it.",
    call. = FALSE
  )
  if (partial && rrp_publication_stage_complete(state, "hospital_repository_ready")) {
    if (!identical(hospital$status, 200L) ||
        !identical(hospital$data$full_name, config$hospital_repository) ||
        isTRUE(hospital$data$private)) stop(
      "Retained Hospital publication stage conflicts with the remote repository.",
      call. = FALSE
    )
  } else if (!identical(hospital$status, 404L)) {
    exact_empty_target <- identical(hospital$status, 200L) &&
      identical(hospital$data$full_name, config$hospital_repository) &&
      !isTRUE(hospital$data$private) &&
      identical(as.numeric(hospital$data$size), 0)
    if (!exact_empty_target) stop(
      "Unexpected Hospital repository exists outside retained publication state.",
      call. = FALSE
    )
  }
  hospital_tag <- client$tag(config$hospital_repository, config$hospital_tag)
  hospital_release <- client$release(config$hospital_repository, config$hospital_tag)
  if (identical(hospital$status, 404L)) {
    if (!hospital_tag$status %in% c(404L) || !hospital_release$status %in% c(404L)) stop(
      "Hospital tag or release lookup returned unexpected state.", call. = FALSE
    )
  } else if (partial) {
    commit_stage <- rrp_publication_stage_complete(state, "hospital_commit_pushed")
    expected_commit <- state$stage_evidence$hospital_commit_pushed$commit
    if (commit_stage) {
      if (!is.character(expected_commit) || length(expected_commit) != 1L ||
          !grepl("^[a-f0-9]{40}$", expected_commit)) stop(
        "Retained Hospital commit stage has invalid evidence.", call. = FALSE
      )
      branch_response <- rrp_publication_api_ok(
        client$branch(config$hospital_repository, "main"), 200L,
        "Retained Hospital branch lookup"
      )$data
      if (!identical(branch_response$object$sha, expected_commit)) stop(
        "Retained Hospital commit stage differs from the remote main branch.",
        call. = FALSE
      )
    } else if (!identical(as.numeric(hospital$data$size), 0)) stop(
      "Hospital repository contains unrecorded content before its commit stage.",
      call. = FALSE
    )

    if (identical(hospital_tag$status, 200L)) {
      if (!commit_stage || !identical(rrp_publication_exact_tag_commit(
        client, config$hospital_repository, config$hospital_tag
      ), expected_commit)) stop(
        "Existing Hospital tag is not proven by retained publication state.",
        call. = FALSE
      )
    } else if (identical(hospital_tag$status, 404L)) {
      if (rrp_publication_stage_complete(state, "hospital_tag_pushed")) stop(
        "Retained Hospital tag stage is missing from the remote repository.",
        call. = FALSE
      )
    } else stop(
      "Hospital tag lookup returned unexpected state.", call. = FALSE
    )

    if (identical(hospital_release$status, 200L)) {
      exact_release <- commit_stage &&
        identical(hospital_release$data$tag_name, config$hospital_tag) &&
        !isTRUE(hospital_release$data$draft) &&
        !isTRUE(hospital_release$data$prerelease)
      if (!exact_release) stop(
        "Existing Hospital release is not proven by retained publication state.",
        call. = FALSE
      )
    } else if (identical(hospital_release$status, 404L)) {
      if (rrp_publication_stage_complete(state, "hospital_release_created")) stop(
        "Retained Hospital release stage is missing from GitHub.", call. = FALSE
      )
    } else stop(
      "Hospital GitHub Release lookup returned unexpected state.", call. = FALSE
    )
  }
  security <- rrp_publication_api_ok(
    client$private_vulnerability_reporting(config$platform_repository), 200L,
    "Private vulnerability reporting lookup"
  )$data
  list(
    overall_status = "pass", version = version, source_revision = source_revision,
    repository_root = repository_root, preparation_root = preparation_root,
    preparation = prepared$manifest, config = config,
    authenticated_login = user$login,
    private_vulnerability_reporting_enabled = isTRUE(security$enabled),
    author = list(name = author_name, email = author_email),
    retained_state = state,
    result = "PUBLICATION PREFLIGHT: PASS",
    remote_mutation = "NOT PERFORMED"
  )
}

rrp_publication_ensure_local_tag <- function(root, tag, revision, message) {
  existing <- rrp_release_git(root, c("rev-parse", "--verify", paste0("refs/tags/", tag)))
  if (identical(existing$status, 0L)) {
    peeled <- rrp_publication_git_output(
      root, c("rev-list", "-n", "1", tag), "Local tag inspection"
    )
    if (length(peeled) == 1L && identical(peeled, revision)) return(invisible(TRUE))
    stop("Existing local release tag targets a different revision.", call. = FALSE)
  }
  rrp_publication_git_output(
    root, c("tag", "-a", tag, revision, "-m", shQuote(message)),
    "Annotated release-tag creation"
  )
  invisible(TRUE)
}

rrp_publication_release_assets <- function(release) {
  assets <- release$assets
  if (is.null(assets)) return(list())
  assets
}

rrp_publication_find_asset <- function(release, name) {
  assets <- rrp_publication_release_assets(release)
  matches <- Filter(function(asset) identical(asset$name, name), assets)
  if (length(matches) == 1L) matches[[1L]] else NULL
}

rrp_publication_upload_missing_asset <- function(
  client, repository, release, path, media_type
) {
  name <- basename(path)
  existing <- rrp_publication_find_asset(release, name)
  if (!is.null(existing)) return(existing)
  uploaded <- rrp_publication_api_ok(
    client$upload_binary_asset(repository, release$id, name, path, media_type),
    201L, paste("GitHub release asset upload", name)
  )
  uploaded$data
}

rrp_publication_platform_notes <- function(path) paste(
  readLines(path, warn = FALSE, encoding = "UTF-8"), collapse = "\n"
)

rrp_publication_hospital_notes <- function(version) paste(
  paste0("# Readmission Risk Pool Hospital Implementation v", version),
  "",
  paste0(
    "This is the hospital-facing implementation product generated from the ",
    "authoritative Readmission Risk Pool Platform v", version, " release."
  ),
  "It embeds the exact verified Platform archive; hospitals normally begin here.",
  "Run the synthetic acceptance workflow before adapting the explicit producer scaffold.",
  "Deployment is not automatic. Connect Cloud is the reference/tutorial path.",
  "Operators retain responsibility for production approval, security, access, PHI, and local validation.",
  sep = "\n"
)

rrp_publication_verify_platform <- function(preflight, client) {
  config <- preflight$config
  commit <- rrp_publication_exact_tag_commit(
    client, config$platform_repository, config$platform_tag
  )
  if (!identical(commit, preflight$source_revision)) stop(
    "Published Platform tag does not target the release commit.", call. = FALSE
  )
  release <- rrp_publication_api_ok(
    client$release(config$platform_repository, config$platform_tag), 200L,
    "Published Platform release lookup"
  )$data
  if (isTRUE(release$draft) || isTRUE(release$prerelease)) stop(
    "Published Platform release is unexpectedly draft or prerelease.", call. = FALSE
  )
  archive_name <- basename(preflight$preparation$platform$archive_path)
  asset <- rrp_publication_find_asset(release, archive_name)
  checksum_asset <- rrp_publication_find_asset(release, paste0(archive_name, ".sha256"))
  if (is.null(asset) || !is.character(asset$browser_download_url) ||
      is.null(checksum_asset) || !is.character(checksum_asset$browser_download_url)) stop(
    "Published Platform archive or checksum asset is missing.", call. = FALSE
  )
  downloaded <- tempfile("rrp-published-platform-", fileext = ".tar")
  on.exit(unlink(downloaded, force = TRUE), add = TRUE)
  rrp_publication_api_ok(
    client$download(asset$browser_download_url, downloaded), 200L,
    "Published Platform archive acquisition"
  )
  digest <- rrp_hospital_sha256_file(downloaded)
  if (!identical(digest, preflight$preparation$platform$archive_sha256)) stop(
    "Published Platform archive digest differs from preparation evidence.",
    call. = FALSE
  )
  downloaded_checksum <- tempfile("rrp-published-platform-checksum-")
  on.exit(unlink(downloaded_checksum, force = TRUE), add = TRUE)
  rrp_publication_api_ok(
    client$download(checksum_asset$browser_download_url, downloaded_checksum), 200L,
    "Published Platform checksum acquisition"
  )
  if (!identical(trimws(readLines(downloaded_checksum, warn = FALSE)), digest)) stop(
    "Published Platform checksum asset differs from the archive digest.", call. = FALSE
  )
  rrp_release_prove_platform_acquisition(downloaded)
  list(
    commit = commit, release_id = as.character(release$id),
    release_url = release$html_url, archive_url = asset$browser_download_url,
    archive_sha256 = digest, verified = TRUE
  )
}

rrp_publication_prepare_hospital_repository <- function(preflight) {
  root <- file.path(
    rrp_publication_state_root(preflight$preparation_root), "hospital-repository"
  )
  source <- file.path(
    preflight$preparation_root,
    preflight$preparation$hospital$git_realization_path
  )
  if (!dir.exists(root)) {
    rrp_release_copy_tree(source, root)
  }
  validation <- rrp_validate_hospital_git_realization(
    root, check_git = FALSE, run_distribution_validator = TRUE
  )
  if (!identical(validation$overall_status, "pass")) stop(
    "Publication copy of Hospital realization is not the exact validated candidate.",
    call. = FALSE
  )
  root
}

rrp_publication_hospital_commit <- function(root, preflight) {
  config <- preflight$config
  remotes <- rrp_release_git(root, "remote")
  if (!identical(remotes$status, 0L)) stop(
    "Could not inspect Hospital publication remote.", call. = FALSE
  )
  expected_url <- paste0("https://github.com/", config$hospital_repository, ".git")
  if (length(remotes$output) == 0L) {
    rrp_publication_git_output(
      root, c("remote", "add", "origin", expected_url),
      "Hospital publication remote configuration"
    )
  } else {
    actual <- rrp_publication_git_output(
      root, c("remote", "get-url", "origin"), "Hospital remote inspection"
    )
    if (!identical(remotes$output, "origin") || !identical(actual, expected_url)) stop(
      "Hospital publication copy has an unexpected remote.", call. = FALSE
    )
  }
  head <- rrp_release_git(root, c("rev-parse", "--verify", "HEAD"))
  if (!identical(head$status, 0L)) {
    rrp_publication_git_output(
      root, c("commit", "-s", "-m", shQuote(paste0(
        "Release Hospital Implementation v", preflight$version
      ))), "Hospital release commit"
    )
    head <- rrp_release_git(root, c("rev-parse", "--verify", "HEAD"))
  }
  if (!identical(head$status, 0L) || length(head$output) != 1L ||
      !grepl("^[a-f0-9]{40}$", head$output)) stop(
    "Hospital release commit is unavailable.", call. = FALSE
  )
  status <- rrp_publication_git_output(
    root, c("status", "--porcelain=v1", "--untracked-files=all"),
    "Hospital release worktree inspection"
  )
  if (length(status) > 0L) stop(
    "Hospital release commit does not preserve the exact validated tree.",
    call. = FALSE
  )
  rrp_publication_ensure_local_tag(
    root, config$hospital_tag, head$output[[1L]],
    paste0("Readmission Risk Pool Hospital Implementation v", preflight$version)
  )
  head$output[[1L]]
}

rrp_publication_verify_hospital <- function(preflight, client, expected_commit) {
  config <- preflight$config
  repository <- rrp_publication_api_ok(
    client$repository(config$hospital_repository), 200L,
    "Published Hospital repository lookup"
  )$data
  if (!identical(repository$full_name, config$hospital_repository) ||
      !identical(repository$default_branch, "main") || isTRUE(repository$private) ||
      isTRUE(repository$archived) || isTRUE(repository$disabled)) stop(
    "Published Hospital repository identity, visibility, or default branch is invalid.",
    call. = FALSE
  )
  commit <- rrp_publication_exact_tag_commit(
    client, config$hospital_repository, config$hospital_tag
  )
  if (!identical(commit, expected_commit)) stop(
    "Published Hospital tag does not target the exact release commit.", call. = FALSE
  )
  release <- rrp_publication_api_ok(
    client$release(config$hospital_repository, config$hospital_tag), 200L,
    "Published Hospital release lookup"
  )$data
  if (isTRUE(release$draft) || isTRUE(release$prerelease)) stop(
    "Published Hospital release is unexpectedly draft or prerelease.", call. = FALSE
  )
  parent <- tempfile("rrp-published-hospital-")
  dir.create(parent)
  on.exit(unlink(parent, recursive = TRUE, force = TRUE), add = TRUE)
  root <- file.path(parent, "readmission-risk-pool-hospital-implementation")
  clone <- suppressWarnings(system2(Sys.which("git"), c(
    "clone", "--depth", "1", "--branch", config$hospital_tag,
    shQuote(paste0("https://github.com/", config$hospital_repository, ".git")),
    shQuote(root)
  ), stdout = TRUE, stderr = TRUE))
  clone_status <- attr(clone, "status")
  if (!is.null(clone_status) && !identical(as.integer(clone_status), 0L)) stop(
    "Published Hospital repository could not be acquired.", call. = FALSE
  )
  acquired_commit <- rrp_publication_git_output(
    root, c("rev-parse", "HEAD"), "Published Hospital commit inspection"
  )
  if (!identical(acquired_commit, expected_commit)) stop(
    "Acquired Hospital repository does not match the release commit.", call. = FALSE
  )
  content <- rrp_validate_hospital_git_realization(
    root, check_git = FALSE, run_distribution_validator = TRUE
  )
  if (!identical(content$overall_status, "pass")) stop(
    "Published Hospital content failed standalone validation: ",
    paste(content$issues$issue_code, collapse = ", "), call. = FALSE
  )
  for (script in c(
    "operations/initialize.R", "operations/doctor.R",
    "operations/run-reference-acceptance.R",
    "operations/run-fictional-adopter-proof.R"
  )) rrp_release_run_operation(root, script)
  manifest <- content$manifest
  if (!identical(
    manifest$included_platform$archive_sha256,
    preflight$preparation$platform$archive_sha256
  )) stop("Published Hospital embeds the wrong Platform digest.", call. = FALSE)
  list(
    commit = commit, release_id = as.character(release$id),
    release_url = release$html_url,
    embedded_platform_candidate_instance_id =
      manifest$included_platform$candidate_instance_id,
    embedded_platform_archive_sha256 = manifest$included_platform$archive_sha256,
    verified = TRUE
  )
}

rrp_publication_evidence <- function(preflight, state) {
  platform <- state$stage_evidence$platform_verified
  hospital <- state$stage_evidence$hospital_verified
  list(
    evidence_kind = "release_publication_evidence",
    evidence_version = "0.1.0",
    overall_status = "published_and_verified",
    platform = list(
      version = preflight$version, repository = preflight$config$platform_repository,
      release_commit = preflight$source_revision,
      tag = preflight$config$platform_tag,
      github_release_id = platform$release_id,
      github_release_url = platform$release_url,
      candidate_instance_id = preflight$preparation$platform$candidate_instance_id,
      artifact_sha256 = preflight$preparation$platform$archive_sha256,
      verified = TRUE
    ),
    hospital = list(
      version = preflight$version, repository = preflight$config$hospital_repository,
      release_commit = hospital$commit, tag = preflight$config$hospital_tag,
      github_release_id = hospital$release_id,
      github_release_url = hospital$release_url,
      distribution_instance_id =
        preflight$preparation$hospital$distribution_instance_id,
      git_realization_instance_id =
        preflight$preparation$hospital$git_realization_instance_id,
      embedded_platform_candidate_instance_id =
        hospital$embedded_platform_candidate_instance_id,
      embedded_platform_archive_sha256 =
        hospital$embedded_platform_archive_sha256,
      verified = TRUE
    ),
    publication = list(
      authenticated_login = preflight$authenticated_login,
      started_at = state$started_at, completed_at = state$completed_at,
      private_vulnerability_reporting = "enabled",
      remote_verification = "passed"
    )
  )
}

rrp_publication_write_final_evidence <- function(preflight, evidence) {
  root <- rrp_publication_state_root(preflight$preparation_root)
  path <- file.path(root, "PUBLICATION-EVIDENCE.yml")
  checksum <- file.path(root, "PUBLICATION-EVIDENCE.sha256")
  rrp_hospital_write_yaml(evidence, path)
  writeLines(rrp_hospital_sha256_file(path), checksum, useBytes = TRUE)
  invisible(path)
}

rrp_record_published_release <- function(repository_root, evidence) {
  if (!identical(evidence$overall_status, "published_and_verified") ||
      !isTRUE(evidence$platform$verified) || !isTRUE(evidence$hospital$verified)) stop(
    "Development version cannot advance before both releases are verified.",
    call. = FALSE
  )
  release_root <- file.path(repository_root, "releases", evidence$platform$version)
  dir.create(release_root, recursive = TRUE, showWarnings = FALSE)
  path <- file.path(release_root, "PUBLICATION.yml")
  if (file.exists(path)) stop(
    "Tracked publication evidence already exists; preserve it for review.",
    call. = FALSE
  )
  rrp_hospital_write_yaml(evidence, path)
  writeLines(
    rrp_hospital_sha256_file(path),
    file.path(release_root, "PUBLICATION.sha256"), useBytes = TRUE
  )
  authority <- rrp_release_authority(repository_root)
  authority$release_authority_version <- 2L
  authority$source$development_version <- "0.2.0-dev"
  authority$targets$platform$intended_version <- NULL
  authority$targets$platform$candidate_status <- "not_prepared"
  authority$targets$hospital$intended_version <- NULL
  authority$targets$hospital$candidate_status <- "not_prepared"
  authority$publication$status <- "published"
  authority$publication$tag_exists <- TRUE
  authority$publication$github_release_exists <- TRUE
  authority$publication$latest_published <- evidence$platform$version
  authority$publication$evidence <- file.path(
    "releases", evidence$platform$version, "PUBLICATION.yml"
  )
  authority$history <- list(list(
    platform_version = evidence$platform$version,
    hospital_version = evidence$hospital$version,
    status = "published_and_verified",
    evidence = authority$publication$evidence
  ))
  rrp_hospital_write_yaml(authority, file.path(repository_root, "RELEASE.yml"))
  changelog_path <- file.path(repository_root, "CHANGELOG.md")
  changelog <- readLines(changelog_path, warn = FALSE, encoding = "UTF-8")
  release_heading <- grepl("^## \\[0[.]1[.]0\\]", changelog)
  changelog[release_heading] <- paste0(
    "## [0.1.0] — ", substr(evidence$publication$completed_at, 1L, 10L)
  )
  if (!any(changelog == "## [Unreleased]")) {
    changelog <- append(changelog, c("", "## [Unreleased]", "", "No changes yet."), 1L)
  }
  writeLines(changelog, changelog_path, useBytes = TRUE)
  invisible(list(authority = authority, evidence_path = path))
}

rrp_publish_release <- function(repository_root, preflight, client) {
  if (!identical(preflight$overall_status, "pass")) stop(
    "Publication requires a passed preflight result.", call. = FALSE
  )
  preparation_root <- preflight$preparation_root
  state <- preflight$retained_state
  if (is.null(state)) {
    state <- rrp_publication_initial_state(preflight)
    rrp_publication_write_state(preparation_root, state)
  }
  config <- preflight$config
  archive <- file.path(
    preparation_root, preflight$preparation$platform$archive_path
  )
  checksum <- paste0(archive, ".sha256")
  notes_path <- file.path(preparation_root, "evidence", "RELEASE-NOTES.md")

  if (!rrp_publication_stage_complete(state, "platform_security_enabled")) {
    if (!preflight$private_vulnerability_reporting_enabled) {
      rrp_publication_api_ok(
        client$enable_private_vulnerability_reporting(config$platform_repository),
        204L, "Enable Platform private vulnerability reporting"
      )
    }
    verified_security <- rrp_publication_api_ok(
      client$private_vulnerability_reporting(config$platform_repository), 200L,
      "Verify Platform private vulnerability reporting"
    )$data
    if (!isTRUE(verified_security$enabled)) stop(
      "Private vulnerability reporting was not enabled.", call. = FALSE
    )
    state <- rrp_publication_complete_stage(
      preparation_root, state, "platform_security_enabled", list(enabled = TRUE)
    )
  }
  if (!rrp_publication_stage_complete(state, "platform_tag_pushed")) {
    rrp_publication_ensure_local_tag(
      repository_root, config$platform_tag, preflight$source_revision,
      paste0("Readmission Risk Pool Platform v", preflight$version)
    )
    rrp_publication_git_output(
      repository_root, c("push", config$remote, config$branch),
      "Platform release-commit push"
    )
    rrp_publication_git_output(
      repository_root, c("push", config$remote, config$platform_tag),
      "Platform release-tag push"
    )
    commit <- rrp_publication_exact_tag_commit(
      client, config$platform_repository, config$platform_tag
    )
    if (!identical(commit, preflight$source_revision)) stop(
      "Pushed Platform tag does not target the release commit.", call. = FALSE
    )
    state <- rrp_publication_complete_stage(
      preparation_root, state, "platform_tag_pushed",
      list(commit = commit, tag = config$platform_tag)
    )
  }
  if (!rrp_publication_stage_complete(state, "platform_release_created")) {
    response <- client$release(config$platform_repository, config$platform_tag)
    release <- if (identical(response$status, 404L)) {
      rrp_publication_api_ok(client$create_release(
        config$platform_repository, config$platform_tag,
        paste0("Readmission Risk Pool Platform v", preflight$version),
        rrp_publication_platform_notes(notes_path), preflight$source_revision
      ), 201L, "Create Platform GitHub Release")$data
    } else rrp_publication_api_ok(
      response, 200L, "Inspect existing Platform GitHub Release"
    )$data
    rrp_publication_upload_missing_asset(
      client, config$platform_repository, release, archive, "application/x-tar"
    )
    release <- rrp_publication_api_ok(
      client$release(config$platform_repository, config$platform_tag), 200L,
      "Refresh Platform GitHub Release"
    )$data
    rrp_publication_upload_missing_asset(
      client, config$platform_repository, release, checksum, "text/plain"
    )
    release <- rrp_publication_api_ok(
      client$release(config$platform_repository, config$platform_tag), 200L,
      "Verify Platform GitHub Release assets"
    )$data
    state <- rrp_publication_complete_stage(
      preparation_root, state, "platform_release_created",
      list(release_id = as.character(release$id), release_url = release$html_url)
    )
  }
  if (!rrp_publication_stage_complete(state, "platform_verified")) {
    verified <- rrp_publication_verify_platform(preflight, client)
    state <- rrp_publication_complete_stage(
      preparation_root, state, "platform_verified", verified
    )
  }
  if (!rrp_publication_stage_complete(state, "hospital_repository_ready")) {
    response <- client$repository(config$hospital_repository)
    repository <- if (identical(response$status, 404L)) {
      rrp_publication_api_ok(client$create_repository(
        config$owner, config$hospital_name,
        "Generated public Readmission Risk Pool Hospital Implementation"
      ), 201L, "Create Hospital Implementation repository")$data
    } else if (identical(response$status, 200L) &&
               identical(response$data$full_name, config$hospital_repository) &&
               !isTRUE(response$data$private) &&
               identical(as.numeric(response$data$size), 0)) {
      response$data
    } else stop(
      "Hospital repository appeared after preflight with conflicting state; publication refuses it.",
      call. = FALSE
    )
    if (!identical(repository$full_name, config$hospital_repository) ||
        isTRUE(repository$private)) stop(
      "Created Hospital repository has the wrong identity or visibility.",
      call. = FALSE
    )
    state <- rrp_publication_complete_stage(
      preparation_root, state, "hospital_repository_ready",
      list(repository = repository$full_name, public = TRUE)
    )
  }
  hospital_root <- rrp_publication_prepare_hospital_repository(preflight)
  hospital_commit <- rrp_publication_hospital_commit(hospital_root, preflight)
  if (!rrp_publication_stage_complete(state, "hospital_commit_pushed")) {
    rrp_publication_git_output(
      hospital_root, c("push", "--set-upstream", "origin", "main"),
      "Hospital release-commit push"
    )
    state <- rrp_publication_complete_stage(
      preparation_root, state, "hospital_commit_pushed",
      list(commit = hospital_commit, branch = "main")
    )
  }
  if (!rrp_publication_stage_complete(state, "hospital_tag_pushed")) {
    rrp_publication_git_output(
      hospital_root, c("push", "origin", config$hospital_tag),
      "Hospital release-tag push"
    )
    commit <- rrp_publication_exact_tag_commit(
      client, config$hospital_repository, config$hospital_tag
    )
    if (!identical(commit, hospital_commit)) stop(
      "Pushed Hospital tag does not target the release commit.", call. = FALSE
    )
    state <- rrp_publication_complete_stage(
      preparation_root, state, "hospital_tag_pushed",
      list(commit = commit, tag = config$hospital_tag)
    )
  }
  if (!rrp_publication_stage_complete(state, "hospital_release_created")) {
    response <- client$release(config$hospital_repository, config$hospital_tag)
    release <- if (identical(response$status, 404L)) {
      rrp_publication_api_ok(client$create_release(
        config$hospital_repository, config$hospital_tag,
        paste0("Readmission Risk Pool Hospital Implementation v", preflight$version),
        rrp_publication_hospital_notes(preflight$version), hospital_commit
      ), 201L, "Create Hospital GitHub Release")$data
    } else rrp_publication_api_ok(
      response, 200L, "Inspect existing Hospital GitHub Release"
    )$data
    state <- rrp_publication_complete_stage(
      preparation_root, state, "hospital_release_created",
      list(release_id = as.character(release$id), release_url = release$html_url)
    )
  }
  if (!rrp_publication_stage_complete(state, "hospital_verified")) {
    verified <- rrp_publication_verify_hospital(preflight, client, hospital_commit)
    state <- rrp_publication_complete_stage(
      preparation_root, state, "hospital_verified", verified
    )
  }
  if (!rrp_publication_stage_complete(state, "publication_complete")) {
    state <- rrp_publication_complete_stage(
      preparation_root, state, "publication_complete",
      list(platform = "published_and_verified", hospital = "published_and_verified")
    )
  }
  evidence <- rrp_publication_evidence(preflight, state)
  rrp_publication_write_final_evidence(preflight, evidence)
  rrp_record_published_release(repository_root, evidence)
  list(overall_status = "published_and_verified", state = state,
       evidence = evidence, source_transition = "0.2.0-dev_pending_commit")
}

rrp_verify_published_release <- function(repository_root, version, client) {
  preparation_root <- file.path(repository_root, "build", "releases", version)
  state <- rrp_publication_read_state(preparation_root)
  if (is.null(state) || !rrp_publication_stage_complete(state, "publication_complete")) stop(
    "Complete retained publication evidence is required for remote verification.",
    call. = FALSE
  )
  evidence_path <- file.path(
    rrp_publication_state_root(preparation_root), "PUBLICATION-EVIDENCE.yml"
  )
  checksum_path <- file.path(
    rrp_publication_state_root(preparation_root), "PUBLICATION-EVIDENCE.sha256"
  )
  if (!file.exists(evidence_path) || !file.exists(checksum_path) ||
      !identical(trimws(readLines(checksum_path, warn = FALSE)),
                 rrp_hospital_sha256_file(evidence_path))) stop(
    "Publication evidence is missing or has changed.", call. = FALSE
  )
  evidence <- rrp_hospital_read_yaml(evidence_path)
  platform_commit <- rrp_publication_exact_tag_commit(
    client, evidence$platform$repository, evidence$platform$tag
  )
  hospital_commit <- rrp_publication_exact_tag_commit(
    client, evidence$hospital$repository, evidence$hospital$tag
  )
  if (!identical(platform_commit, evidence$platform$release_commit) ||
      !identical(hospital_commit, evidence$hospital$release_commit) ||
      !identical(client$release(
        evidence$platform$repository, evidence$platform$tag
      )$status, 200L) ||
      !identical(client$release(
        evidence$hospital$repository, evidence$hospital$tag
      )$status, 200L)) stop(
    "Published release identities no longer match retained evidence.", call. = FALSE
  )
  list(overall_status = "published_and_verified", evidence = evidence)
}
