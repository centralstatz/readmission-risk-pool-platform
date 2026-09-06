phase11_publication_fake_preflight <- function(root) list(
  overall_status = "pass",
  version = "0.1.0",
  source_revision = "0123456789012345678901234567890123456789",
  repository_root = root,
  preparation_root = file.path(root, "prepared"),
  config = list(
    platform_repository = "centralstatz/readmission-risk-pool-platform",
    hospital_repository =
      "centralstatz/readmission-risk-pool-hospital-implementation",
    platform_tag = "v0.1.0", hospital_tag = "v0.1.0"
  ),
  preparation = list(
    platform = list(
      candidate_instance_id = "platform_release_candidate::test",
      archive_sha256 = paste(rep("a", 64L), collapse = "")
    ),
    hospital = list(
      distribution_instance_id = "hospital_distribution::test",
      git_realization_instance_id = "hospital_git::test"
    )
  ),
  authenticated_login = "maintainer"
)

phase11_publication_test_cases <- function(repository_root, suite_root) list(
  "publication operation modes are maintainer-only" = function() {
    registry <- yaml::read_yaml(file.path(repository_root, "operations", "operations.yml"))
    operations <- Filter(function(item) grepl(
      "publish-release[.]R", item$command
    ), registry$operations)
    phase0_assert_true(length(operations) == 3L)
    phase0_assert_true(all(vapply(
      operations, function(item) identical(item$classification, "maintainer"),
      logical(1)
    )))
  },
  "publication requires one explicit operation mode" = function() {
    text <- paste(readLines(file.path(
      repository_root, "operations", "publish-release.R"
    )), collapse = "\n")
    phase0_assert_true(grepl("is.null(mode)", text, fixed = TRUE))
    phase0_assert_true(grepl("--preflight|--publish|--verify", text, fixed = TRUE))
  },
  "preflight code has no remote-mutating client call" = function() {
    text <- paste(deparse(body(rrp_publication_preflight)), collapse = "\n")
    phase0_assert_false(any(vapply(c(
      "enable_private", "create_repository", "create_release", "upload_binary",
      'c("tag"'
    ), grepl, logical(1), x = text, fixed = TRUE)))
    phase0_assert_true(grepl('c("push", "--dry-run"', text, fixed = TRUE))
  },
  "wrong authoritative repository identity is refused" = function() {
    phase0_assert_error(
      rrp_publication_remote_identity("https://example.com/owner/repo.git"),
      "exact HTTPS GitHub"
    )
    identity <- rrp_publication_remote_identity(
      "https://github.com/centralstatz/readmission-risk-pool-platform.git"
    )
    phase0_assert_true(identical(
      identity$repository, "centralstatz/readmission-risk-pool-platform"
    ))
  },
  "wrong branch has an explicit preflight refusal" = function() {
    text <- paste(deparse(body(rrp_publication_preflight)), collapse = "\n")
    phase0_assert_true(grepl(
      "requires the expected authoritative branch", text, fixed = TRUE
    ))
  },
  "dirty source remains a publication refusal" = function() {
    text <- paste(deparse(
      body(rrp_publication_preflight), width.cutoff = 500L
    ), collapse = "\n")
    phase0_assert_true(grepl(
      "rrp_release_source_revision(repository_root, require_clean = TRUE)",
      text, fixed = TRUE
    ))
  },
  "candidate revision mismatch is refused" = function() {
    text <- paste(deparse(body(rrp_publication_preflight)), collapse = "\n")
    phase0_assert_true(grepl(
      "Prepared candidate source revision does not equal", text, fixed = TRUE
    ))
  },
  "missing preparation evidence is not synthesized" = function() {
    text <- paste(deparse(body(rrp_publication_preflight)), collapse = "\n")
    phase0_assert_true(grepl(
      "rrp_validate_release_preparation(preparation_root", text, fixed = TRUE
    ))
  },
  "tag conflict is fail-closed" = function() {
    phase0_assert_error(rrp_publication_validate_absent_or_exact(
      list(status = 200L, data = list()), 404L, function(value) FALSE,
      "tag conflict"
    ), "tag conflict")
  },
  "GitHub Release conflict is fail-closed" = function() {
    phase0_assert_error(rrp_publication_validate_absent_or_exact(
      list(status = 422L, data = list()), 404L, function(value) FALSE,
      "release conflict"
    ), "release conflict")
  },
  "Hospital repository identity is fixed in release authority" = function() {
    authority <- rrp_release_authority(repository_root)
    phase0_assert_true(identical(
      authority$publication$hospital_repository,
      "centralstatz/readmission-risk-pool-hospital-implementation"
    ))
  },
  "unauthenticated GitHub response is refused" = function() {
    phase0_assert_error(
      rrp_publication_api_ok(list(status = 401L), 200L, "authentication"),
      "HTTP status 401"
    )
  },
  "annotated Platform tag resolves to exact release commit" = function() {
    client <- list(
      tag = function(repository, tag) list(
        status = 200L, data = list(object = list(type = "tag", sha = "tag-object"))
      ),
      annotated_tag = function(repository, sha) list(
        status = 200L, data = list(object = list(
          type = "commit", sha = "0123456789012345678901234567890123456789"
        ))
      )
    )
    phase0_assert_true(identical(
      rrp_publication_exact_tag_commit(client, "owner/repo", "v0.1.0"),
      "0123456789012345678901234567890123456789"
    ))
  },
  "Platform published verification compares prepared artifact digest" = function() {
    text <- paste(deparse(body(rrp_publication_verify_platform)), collapse = "\n")
    phase0_assert_true(grepl("rrp_hospital_sha256_file(downloaded)", text, fixed = TRUE))
    phase0_assert_true(grepl("rrp_release_prove_platform_acquisition", text, fixed = TRUE))
  },
  "Hospital publication copies the exact prepared realization" = function() {
    text <- paste(deparse(body(rrp_publication_prepare_hospital_repository)),
                  collapse = "\n")
    phase0_assert_true(grepl("rrp_release_copy_tree(source, root)", text, fixed = TRUE))
    phase0_assert_true(grepl(
      "rrp_validate_hospital_git_realization", text, fixed = TRUE
    ))
  },
  "Hospital embedded Platform digest is compared with preparation" = function() {
    text <- paste(deparse(body(rrp_publication_verify_hospital)), collapse = "\n")
    phase0_assert_true(grepl(
      "manifest$included_platform$archive_sha256", text, fixed = TRUE
    ))
    phase0_assert_true(grepl(
      "preflight$preparation$platform$archive_sha256", text, fixed = TRUE
    ))
  },
  "publication stage state is checksummed and ordered" = function() {
    root <- file.path(suite_root, "publication-stage-state")
    dir.create(file.path(root, "prepared"), recursive = TRUE)
    preflight <- phase11_publication_fake_preflight(root)
    state <- rrp_publication_initial_state(preflight)
    rrp_publication_write_state(preflight$preparation_root, state)
    state <- rrp_publication_complete_stage(
      preflight$preparation_root, state, "platform_tag_pushed", list(commit = "test")
    )
    reread <- rrp_publication_read_state(preflight$preparation_root)
    phase0_assert_true(rrp_publication_stage_complete(reread, "preflight_complete"))
    phase0_assert_true(rrp_publication_stage_complete(reread, "platform_tag_pushed"))
  },
  "partial publication state remains explicitly in progress" = function() {
    preflight <- phase11_publication_fake_preflight(suite_root)
    state <- rrp_publication_initial_state(preflight)
    phase0_assert_true(identical(state$overall_status, "publication_in_progress"))
    phase0_assert_false(rrp_publication_stage_complete(state, "publication_complete"))
  },
  "exact-stage rerun does not duplicate a completed stage" = function() {
    root <- file.path(suite_root, "publication-idempotency")
    dir.create(file.path(root, "prepared"), recursive = TRUE)
    preflight <- phase11_publication_fake_preflight(root)
    state <- rrp_publication_initial_state(preflight)
    state <- rrp_publication_complete_stage(
      preflight$preparation_root, state, "platform_verified", list(verified = TRUE)
    )
    state <- rrp_publication_complete_stage(
      preflight$preparation_root, state, "platform_verified", list(verified = TRUE)
    )
    phase0_assert_true(sum(unlist(state$completed_stages) == "platform_verified") == 1L)
  },
  "unrelated existing remote state is never accepted as exact" = function() {
    phase0_assert_error(rrp_publication_validate_absent_or_exact(
      list(status = 200L, data = list(sha = "unrelated")), 404L,
      function(value) identical(value$sha, "expected"), "unrelated remote"
    ), "unrelated remote")
  },
  "retained remote stages must still exist with exact identities" = function() {
    text <- paste(deparse(
      body(rrp_publication_preflight), width.cutoff = 500L
    ), collapse = "\n")
    for (message in c(
      "Retained Platform tag stage is missing",
      "Retained Platform release stage is missing",
      "Retained Hospital commit stage differs",
      "Existing Hospital tag is not proven",
      "Retained Hospital release stage is missing"
    )) phase0_assert_true(grepl(message, text, fixed = TRUE))
  },
  "publication implementation has no force push or delete rollback" = function() {
    text <- paste(readLines(file.path(
      repository_root, "operations", "lib", "release-publication-operation.R"
    )), collapse = "\n")
    phase0_assert_false(grepl('"--force"', text, fixed = TRUE))
    phase0_assert_false(grepl('request("DELETE"', text, fixed = TRUE))
    phase0_assert_false(grepl('c("push", "--force"', text, fixed = TRUE))
  },
  "publication evidence separates both release identities" = function() {
    preflight <- phase11_publication_fake_preflight(suite_root)
    state <- rrp_publication_initial_state(preflight)
    state$started_at <- "2026-09-06T12:00:00Z"
    state$completed_at <- "2026-09-06T13:00:00Z"
    state$stage_evidence <- list(
      platform_verified = list(
        release_id = "1", release_url = "https://github.com/platform/release"
      ),
      hospital_verified = list(
        commit = "abcdefabcdefabcdefabcdefabcdefabcdefabcd", release_id = "2",
        release_url = "https://github.com/hospital/release",
        embedded_platform_candidate_instance_id =
          "platform_release_candidate::test",
        embedded_platform_archive_sha256 = paste(rep("a", 64L), collapse = "")
      )
    )
    evidence <- rrp_publication_evidence(preflight, state)
    phase0_assert_true(identical(evidence$overall_status, "published_and_verified"))
    phase0_assert_true(!identical(
      evidence$platform$repository, evidence$hospital$repository
    ))
  },
  "development transition refuses incomplete publication" = function() {
    phase0_assert_error(rrp_record_published_release(suite_root, list(
      overall_status = "publication_in_progress",
      platform = list(verified = FALSE), hospital = list(verified = FALSE)
    )), "cannot advance")
  },
  "Hospital repository is documented as generated not source authority" = function() {
    text <- paste(readLines(file.path(
      repository_root, "docs", "operations", "release-publication.md"
    )), collapse = "\n")
    phase0_assert_true(grepl("generated public target", text, fixed = TRUE))
    phase0_assert_true(grepl("continues only in the Platform repository", text,
                             fixed = TRUE))
  },
  "agent publication intents map to the human operation" = function() {
    text <- paste(readLines(file.path(repository_root, "AGENTS.md")), collapse = "\n")
    for (mode in c("--preflight", "--publish", "--verify")) {
      phase0_assert_true(grepl(paste(
        "Rscript operations/publish-release.R --version 0.1.0", mode
      ), text, fixed = TRUE))
    }
  }
)

phase11_test_cases <- function(repository_root, suite_root) {
  phase11_publication_test_cases(repository_root, suite_root)
}
