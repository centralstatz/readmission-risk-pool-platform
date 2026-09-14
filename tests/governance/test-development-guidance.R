guidance_text <- function(repository_root, path) {
  gsub(
    "[[:space:]]+",
    " ",
    paste(readLines(file.path(repository_root, path), warn = FALSE), collapse = "\n")
  )
}

guidance_operation_map <- function(repository_root) {
  registry <- yaml::read_yaml(file.path(repository_root, "operations", "operations.yml"))
  stats::setNames(
    vapply(registry$operations, `[[`, character(1L), "command"),
    vapply(registry$operations, `[[`, character(1L), "operation_id")
  )
}

governance_test_cases <- function(repository_root) {
  operations <- guidance_operation_map(repository_root)
  agent <- guidance_text(repository_root, "AGENTS.md")
  readme <- guidance_text(repository_root, "README.md")
  contributing <- guidance_text(repository_root, "CONTRIBUTING.md")
  start <- guidance_text(repository_root, "docs/START-HERE.md")
  index <- guidance_text(repository_root, "docs/README.md")
  validation <- guidance_text(repository_root, "docs/operations/validation.md")
  maintained_operations <- vapply(
    c(
      "docs/operations/reference-history.md",
      "docs/operations/run-reference-estimation.md",
      "docs/operations/logical-products.md",
      "docs/operations/observability-and-diagnostics.md"
    ),
    function(path) guidance_text(repository_root, path),
    character(1L)
  )
  conventions <- guidance_text(
    repository_root, "docs/development/implementation-conventions.md"
  )

  list(
    "maintained guidance names one current authority chain" = function() {
      authority_paths <- c(
        "docs/vision/platform-true-north.md",
        "docs/architecture/platform-architecture.md",
        "docs/architecture/platform-implementation-plan.md",
        "docs/development/validation-governance.md",
        "docs/development/transition-ledger.md",
        "docs/architecture/platform-implementation-record.md"
      )
      phase0_assert_true(all(vapply(
        authority_paths, grepl, logical(1L), x = agent, fixed = TRUE
      )))
      phase0_assert_true(grepl("Validation Governance", readme, fixed = TRUE))
      phase0_assert_true(grepl("Transition Ledger", readme, fixed = TRUE))
      phase0_assert_true(grepl("Validation Governance", start, fixed = TRUE))
      phase0_assert_true(grepl("Current normative authority", index, fixed = TRUE))
    },

    "forward human and agent commands match registered operations" = function() {
      ids <- c(
        "platform.validate-source-changed",
        "platform.validate-source-fast",
        "platform.validate-ci-active"
      )
      commands <- unname(operations[ids])
      phase0_assert_true(!anyNA(commands))
      phase0_assert_true(all(vapply(
        commands, grepl, logical(1L), x = agent, fixed = TRUE
      )))
      phase0_assert_true(all(vapply(
        commands, grepl, logical(1L), x = validation, fixed = TRUE
      )))
      phase0_assert_true(grepl(commands[[1L]], readme, fixed = TRUE))
      phase0_assert_true(grepl(commands[[1L]], contributing, fixed = TRUE))
    },

    "legacy aggregates are explicit rather than forward defaults" = function() {
      legacy_ids <- c(
        "platform.validate-legacy-development",
        "platform.validate-legacy-checkpoint"
      )
      legacy_commands <- unname(operations[legacy_ids])
      phase0_assert_true(all(vapply(
        legacy_commands, grepl, logical(1L), x = agent, fixed = TRUE
      )))
      phase0_assert_true(all(vapply(
        legacy_commands, grepl, logical(1L), x = validation, fixed = TRUE
      )))
      phase0_assert_false(grepl("--mode development", contributing, fixed = TRUE))
      phase0_assert_false(grepl("--mode checkpoint", readme, fixed = TRUE))
      phase0_assert_false(any(grepl(
        "--mode development", maintained_operations, fixed = TRUE
      )))
      phase0_assert_false(any(grepl(
        "--mode checkpoint", maintained_operations, fixed = TRUE
      )))
      phase0_assert_true(grepl("deprecated", agent, ignore.case = TRUE))
      phase0_assert_true(grepl("legacy", validation, ignore.case = TRUE))
    },

    "forward conventions reject structural coupling without mandating rewrite" = function() {
      required <- c(
        "explicit software owner and namespace",
        ".GlobalEnv",
        "source order",
        "Project-dependent behavior",
        "dependency ownership",
        "component, contract, lifecycle, or operation",
        "Do not rewrite working core capability",
        "Historical structure is not a compatibility requirement",
        "Published `v0.1.0` artifacts and evidence are immutable",
        "Transition Ledger"
      )
      phase0_assert_true(all(vapply(
        required, grepl, logical(1L), x = conventions, fixed = TRUE
      )))
      phase0_assert_false(grepl("tests/<phase>", conventions, fixed = TRUE))
    }
  )
}
