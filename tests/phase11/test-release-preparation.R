phase11_release_archive_path <- function(distribution_root) {
  manifest <- rrp_hospital_read_yaml(file.path(
    distribution_root, "HOSPITAL-DISTRIBUTION.yml"
  ))
  file.path(distribution_root, "platform", manifest$platform_candidate$archive_filename)
}

phase11_release_candidate_proof <- local({
  cached <- NULL
  function(repository_root, suite_root) {
    if (!is.null(cached)) return(cached)
    store <- file.path(suite_root, "release-candidate-store")
    distribution <- rrp_build_hospital_distribution(
      repository_root, store, "2026-08-20T18:00:00Z",
      "0.1.0", "0.1.0", "release_candidate_not_published",
      "0123456789012345678901234567890123456789"
    )
    realization_root <- file.path(suite_root, "release-candidate-git")
    realization <- rrp_build_hospital_git_realization(
      repository_root, distribution$distribution_path, realization_root,
      "2026-08-20T18:00:00Z"
    )
    candidate <- rrp_hospital_validate_platform_candidate_archive(
      phase11_release_archive_path(distribution$distribution_path)
    )
    cached <<- list(distribution = distribution, realization = realization,
                    realization_root = realization_root, candidate = candidate)
    cached
  }
})

phase11_release_test_cases <- function(repository_root, suite_root) list(
  "Apache-2.0 release state and governance are valid" = function() {
    result <- rrp_release_validate_governance(repository_root, "0.1.0")
    description <- read.dcf(file.path(repository_root, "runtime", "DESCRIPTION"))
    phase0_assert_true(identical(result$license, "pass"))
    phase0_assert_true(file.exists(file.path(repository_root, "NOTICE")))
    phase0_assert_true(identical(
      unname(description[1L, "License"]), "Apache License (>= 2)"
    ))
    phase0_assert_false(file.exists(file.path(repository_root, "runtime", "LICENSE")))
  },
  "DCO security support and tested-environment guidance are explicit" = function() {
    contributing <- paste(readLines(file.path(repository_root, "CONTRIBUTING.md")),
                          collapse = "\n")
    security <- paste(readLines(file.path(repository_root, "SECURITY.md")), collapse = "\n")
    support <- paste(readLines(file.path(repository_root, "SUPPORT.md")), collapse = "\n")
    phase0_assert_true(grepl("git commit -s", contributing, fixed = TRUE))
    phase0_assert_true(grepl("private vulnerability reporting", security, fixed = TRUE))
    phase0_assert_true(grepl("no support or response-time SLA", support, fixed = TRUE))
    phase0_assert_true(grepl("R 4.4.1", support, fixed = TRUE))
  },
  "release authority separates development candidate and publication identity" = function() {
    authority <- rrp_release_authority(repository_root)
    phase0_assert_true(identical(authority$source$development_version, "0.1.0-dev"))
    phase0_assert_true(identical(authority$targets$platform$intended_version, "0.1.0"))
    phase0_assert_true(identical(authority$targets$hospital$version_relationship,
                                 "independently_versioned"))
    phase0_assert_true(identical(authority$publication$status, "not_published"))
  },
  "Platform v0.1.0 candidate has deterministic identity checksum and inventory" = function() {
    proof <- phase11_release_candidate_proof(repository_root, suite_root)
    candidate <- proof$candidate$manifest
    phase0_assert_true(nrow(proof$candidate$issues) == 0L)
    phase0_assert_true(identical(candidate$platform_identity$platform_version, "0.1.0"))
    phase0_assert_true(identical(candidate$candidate_status,
                                 "release_candidate_not_published"))
    phase0_assert_true(length(candidate$inventory) > 100L)
  },
  "Hospital candidate embeds the exact Platform candidate and remains independently versioned" = function() {
    proof <- phase11_release_candidate_proof(repository_root, suite_root)
    manifest <- rrp_hospital_read_yaml(file.path(
      proof$distribution$distribution_path, "HOSPITAL-DISTRIBUTION.yml"
    ))
    phase0_assert_true(identical(manifest$hospital_implementation$release_version, "0.1.0"))
    phase0_assert_true(identical(manifest$hospital_implementation$release_status,
                                 "release_candidate_not_published"))
    phase0_assert_true(identical(manifest$platform_candidate$candidate_instance_id,
                                 proof$candidate$manifest$candidate_instance_id))
    phase0_assert_true(identical(manifest$platform_candidate$archive_sha256,
      rrp_hospital_sha256_file(phase11_release_archive_path(
        proof$distribution$distribution_path
      ))))
  },
  "Hospital release Git realization remains staged uncommitted and remote-free" = function() {
    proof <- phase11_release_candidate_proof(repository_root, suite_root)
    result <- rrp_validate_completed_hospital_git_realization(proof$realization_root)
    phase0_assert_true(identical(result$overall_status, "pass"))
    phase0_assert_true(rrp_hospital_git_run(proof$realization_root, "remote")$status == 0L)
    phase0_assert_true(length(rrp_hospital_git_run(proof$realization_root, "remote")$output) == 0L)
    phase0_assert_true(rrp_hospital_git_run(
      proof$realization_root, c("rev-parse", "--verify", "HEAD")
    )$status != 0L)
  },
  "release preparation operation orchestrates existing boundaries and prohibits publication" = function() {
    text <- paste(readLines(file.path(
      repository_root, "operations", "lib", "release-preparation-operation.R"
    )), collapse = "\n")
    phase0_assert_true(all(vapply(c(
      "rrp_release_validate_renv(", "rrp_build_platform_release_candidate(",
      "rrp_build_hospital_distribution(",
      "rrp_build_hospital_git_realization(", "rrp_validate_release_preparation("
    ), grepl, logical(1), x = text, fixed = TRUE)))
    phase0_assert_false(any(vapply(c(
      'c("commit"', 'c("tag"', 'c("remote", "add"', 'c("push"',
      "gh release create"
    ), grepl, logical(1), x = text, fixed = TRUE)))
  },
  "release manifest schema carries required evidence and explicit not_published" = function() {
    text <- paste(readLines(file.path(
      repository_root, "operations", "lib", "release-preparation-operation.R"
    )), collapse = "\n")
    phase0_assert_true(all(vapply(c(
      "source_revision", "archive_sha256", "distribution_instance_id",
      "git_realization_instance_id", "tested_environment", "prepared_at",
      'status = "not_published"', 'result = "READY FOR PUBLICATION"'
    ), grepl, logical(1), x = text, fixed = TRUE)))
  },
  "release output safety distinguishes absent paths and symbolic links" = function() {
    root <- file.path(suite_root, "release-output-state")
    dir.create(root)
    absent <- file.path(root, "absent")
    target <- file.path(root, "target")
    linked <- file.path(root, "linked")
    writeLines("test", target)
    phase0_assert_false(rrp_release_output_exists(absent))
    phase0_assert_true(file.symlink(target, linked))
    phase0_assert_true(rrp_release_output_exists(linked))
  },
  "clean acquisition proof invokes unchanged Platform and Hospital workflows" = function() {
    text <- paste(readLines(file.path(
      repository_root, "operations", "lib", "release-preparation-operation.R"
    )), collapse = "\n")
    phase0_assert_true(all(vapply(c(
      "operations/initialize-platform.R", "operations/run-platform.R",
      "operations/build-reference-products.R", "operations/launch-reference-app.R",
      "operations/run-reference-acceptance.R",
      "operations/run-fictional-adopter-proof.R"
    ), grepl, logical(1), x = text, fixed = TRUE)))
  },
  "dirty authoritative source refuses release preparation" = function() {
    root <- file.path(suite_root, "dirty-release-source")
    dir.create(root)
    writeLines("baseline", file.path(root, "source.txt"))
    git <- Sys.which("git")
    for (arguments in list(
      c("init", "--initial-branch=main"),
      c("config", "user.name", "Phase11-Test"),
      c("config", "user.email", "phase11@example.invalid"),
      c("config", "commit.gpgsign", "false"),
      c("add", "source.txt"),
      c("commit", "-m", "test-baseline")
    )) phase0_assert_true(identical(suppressWarnings(system2(
      git, c("-C", shQuote(root), arguments), stdout = FALSE, stderr = FALSE
    )), 0L))
    writeLines(c("baseline", "dirty"), file.path(root, "source.txt"))
    phase0_assert_error(
      rrp_release_source_revision(root, require_clean = TRUE),
      "requires a clean authoritative source tree"
    )
  },
  "conflicting intended version refuses governance readiness" = function() {
    phase0_assert_error(
      rrp_release_validate_governance(repository_root, "0.2.0"),
      "conflicts with RELEASE.yml"
    )
  },
  "license or governance removal refuses readiness" = function() {
    root <- file.path(suite_root, "governance-failure")
    dir.create(file.path(root, "docs", "architecture"), recursive = TRUE)
    dir.create(file.path(root, "docs", "operations"), recursive = TRUE)
    files <- c("NOTICE", "LICENSE-STATUS.md", "CONTRIBUTING.md", "SECURITY.md",
               "SUPPORT.md", "CHANGELOG.md", "RELEASE.yml")
    for (file in files) file.copy(file.path(repository_root, file), file.path(root, file))
    file.copy(file.path(repository_root, "docs", "architecture", "release-license-review.md"),
              file.path(root, "docs", "architecture", "release-license-review.md"))
    file.copy(file.path(repository_root, "docs", "operations", "release-preparation.md"),
              file.path(root, "docs", "operations", "release-preparation.md"))
    phase0_assert_error(rrp_release_validate_governance(root, "0.1.0"),
                        "Release governance is incomplete")
  }
)

phase11_test_cases <- function(repository_root, suite_root) {
  phase11_release_test_cases(repository_root, suite_root)
}
