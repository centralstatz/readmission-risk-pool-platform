governance_copy <- function(value) unserialize(serialize(value, NULL))

governance_assert_issue <- function(result, code) {
  phase0_assert_false(result$passed)
  phase0_assert_true(
    any(startsWith(result$issues, paste0(code, ":"))),
    paste0("Expected issue `", code, "`; found: ", paste(result$issues, collapse = " | "))
  )
}

governance_validate <- function(registry, repository_root) {
  rrp_governance_validate_registry(
    registry,
    repository_root,
    rrp_governance_ledger_ids(repository_root)
  )
}

governance_test_cases <- function(repository_root) {
  registry <- rrp_governance_read_registry(repository_root)
  ledger_ids <- rrp_governance_ledger_ids(repository_root)

  list(
    "ownership registry conforms" = function() {
      result <- governance_validate(registry, repository_root)
      phase0_assert_true(result$passed, paste(result$issues, collapse = " | "))
      phase0_assert_false(registry$governance_state$classification_only)
      phase0_assert_true(isTRUE(registry$governance_state$activated_dispatcher))
      phase0_assert_true(identical(
        rrp_governance_values(
          registry$governance_state$current_development_runner$arguments
        ),
        c("--profile", "source-changed")
      ))
      phase0_assert_true(identical(
        rrp_governance_values(
          registry$governance_state$current_checkpoint_runner$arguments
        ),
        c("--profile", "legacy-v0.1-checkpoint")
      ))
    },

    "status vocabulary is exact and closed" = function() {
      phase0_assert_true(identical(
        rrp_governance_statuses(),
        c(
          "active_global", "active_scoped", "composite", "legacy_callable",
          "historical_evidence", "replace_later", "retire_later"
        )
      ))
      candidate <- governance_copy(registry)
      candidate$validators[[1L]]$status <- "active"
      governance_assert_issue(governance_validate(candidate, repository_root), "invalid_status")
    },

    "closed schema rejects unknown fields" = function() {
      candidate <- governance_copy(registry)
      candidate$validators[[1L]]$shell_command <- "Rscript anything.R"
      governance_assert_issue(governance_validate(candidate, repository_root), "unknown_field")
    },

    "closed schema requires declared fields" = function() {
      candidate <- governance_copy(registry)
      candidate$registry_version <- NULL
      governance_assert_issue(governance_validate(candidate, repository_root), "missing_field")

      nested <- governance_copy(registry)
      nested$validators[[1L]]$validator_id <- NULL
      governance_assert_issue(governance_validate(nested, repository_root), "missing_field")
    },

    "validator and profile identities are unique" = function() {
      duplicate <- governance_copy(registry)
      duplicate$validators[[2L]]$validator_id <- duplicate$validators[[1L]]$validator_id
      governance_assert_issue(governance_validate(duplicate, repository_root), "duplicate_id")

      ambiguous <- governance_copy(registry)
      ambiguous$profiles[[1L]]$profile_id <- ambiguous$validators[[1L]]$validator_id
      governance_assert_issue(governance_validate(ambiguous, repository_root), "ambiguous_id")
    },

    "unknown references fail closed" = function() {
      prerequisite <- governance_copy(registry)
      prerequisite$validators[[1L]]$prerequisites <- "missing.validator"
      governance_assert_issue(governance_validate(prerequisite, repository_root), "unknown_reference")

      profile <- governance_copy(registry)
      profile$profiles[[1L]]$includes <- c(profile$profiles[[1L]]$includes, "missing.validator")
      governance_assert_issue(governance_validate(profile, repository_root), "unknown_reference")
    },

    "validator and profile cycles fail closed" = function() {
      validator_cycle <- governance_copy(registry)
      validator_cycle$validators[[1L]]$prerequisites <- validator_cycle$validators[[2L]]$validator_id
      validator_cycle$validators[[2L]]$prerequisites <- validator_cycle$validators[[1L]]$validator_id
      governance_assert_issue(governance_validate(validator_cycle, repository_root), "dependency_cycle")

      profile_cycle <- governance_copy(registry)
      profile_cycle$profiles[[1L]]$includes <- c(
        profile_cycle$profiles[[1L]]$includes,
        profile_cycle$profiles[[2L]]$profile_id
      )
      governance_assert_issue(governance_validate(profile_cycle, repository_root), "dependency_cycle")
    },

    "unsafe trigger paths fail closed" = function() {
      for (unsafe in c("../outside.R", "/tmp/outside.R", "operations/*.R", "a;touch-b")) {
        candidate <- governance_copy(registry)
        candidate$validators[[1L]]$trigger_paths$exact <- unsafe
        governance_assert_issue(governance_validate(candidate, repository_root), "unsafe_path")
      }
    },

    "runner representation rejects shell text missing files and symlinks" = function() {
      shell_text <- governance_copy(registry)
      shell_text$validators[[1L]]$runner$command <- "Rscript tests/run-governance-tests.R"
      governance_assert_issue(governance_validate(shell_text, repository_root), "unknown_field")

      missing <- governance_copy(registry)
      missing$validators[[1L]]$runner$script <- "tests/not-present.R"
      governance_assert_issue(governance_validate(missing, repository_root), "missing_runner")

      fixture_root <- tempfile("rrp-governance-runner-")
      dir.create(file.path(fixture_root, "tests"), recursive = TRUE)
      on.exit(unlink(fixture_root, recursive = TRUE, force = TRUE), add = TRUE)
      linked <- file.path(fixture_root, "tests", "linked.R")
      created <- file.symlink(
        file.path(repository_root, "tests", "run-governance-tests.R"),
        linked
      )
      phase0_assert_true(created, "Could not create runner-safety symlink fixture.")
      issues <- rrp_governance_validate_runner(
        list(script = "tests/linked.R", arguments = list()),
        fixture_root,
        "runner"
      )
      phase0_assert_true(any(startsWith(issues, "linked_runner:")))
    },

    "current validator inventory is complete" = function() {
      expected <- rrp_governance_expected_current_checks(repository_root)
      represented <- unique(unlist(lapply(
        registry$validators,
        function(validator) rrp_governance_values(validator$current_checks)
      ), use.names = FALSE))
      phase0_assert_true(all(expected %in% represented))

      candidate <- governance_copy(registry)
      index <- which(vapply(candidate$validators, function(validator) {
        "rrp_validate_documentation" %in% rrp_governance_values(validator$current_checks)
      }, logical(1L)))[1L]
      candidate$validators[[index]]$current_checks <- setdiff(
        rrp_governance_values(candidate$validators[[index]]$current_checks),
        "rrp_validate_documentation"
      )
      governance_assert_issue(
        governance_validate(candidate, repository_root),
        "unclassified_current_validator"
      )
    },

    "transition ledger links are complete and unique" = function() {
      phase0_assert_true(length(ledger_ids) > 0L)
      phase0_assert_true(!anyDuplicated(ledger_ids))
      candidate <- governance_copy(registry)
      candidate$validators[[1L]]$transition_ledger_id <- "missing-transition"
      governance_assert_issue(governance_validate(candidate, repository_root), "unknown_ledger_reference")
    },

    "protected invariants retain a current owner" = function() {
      target <- registry$protected_invariants[[1L]]$invariant_id
      candidate <- governance_copy(registry)
      for (index in seq_along(candidate$validators)) {
        candidate$validators[[index]]$invariant <- setdiff(
          rrp_governance_values(candidate$validators[[index]]$invariant),
          target
        )
      }
      governance_assert_issue(governance_validate(candidate, repository_root), "orphaned_invariant")
    },

    "forward profiles exclude legacy and historical evidence" = function() {
      candidate <- governance_copy(registry)
      source_fast <- which(vapply(candidate$profiles, function(profile) {
        identical(profile$profile_id, "source-fast")
      }, logical(1L)))[1L]
      candidate$profiles[[source_fast]]$includes <- c(
        candidate$profiles[[source_fast]]$includes,
        "checkpoint.phase0"
      )
      governance_assert_issue(governance_validate(candidate, repository_root), "legacy_profile_leak")
    },

    "legacy aggregate membership and order are exact" = function() {
      actual <- rrp_governance_extract_current_aggregates(repository_root)
      phase0_assert_true(length(actual$development) == 26L)
      phase0_assert_true(length(actual$checkpoint) == 38L)

      candidate <- governance_copy(registry)
      checkpoint <- which(vapply(candidate$legacy_aggregates, function(aggregate) {
        identical(aggregate$aggregate_id, "checkpoint")
      }, logical(1L)))[1L]
      members <- candidate$legacy_aggregates[[checkpoint]]$ordered_members
      candidate$legacy_aggregates[[checkpoint]]$ordered_members[1:2] <- members[2:1]
      governance_assert_issue(governance_validate(candidate, repository_root), "legacy_membership_mismatch")
    }
  )
}
