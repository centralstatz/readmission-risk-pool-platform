ci_workflow_read <- function(repository_root) {
  yaml::read_yaml(file.path(repository_root, ".github", "workflows", "validation.yml"))
}

ci_workflow_operation_map <- function(repository_root) {
  registry <- yaml::read_yaml(file.path(repository_root, "operations", "operations.yml"))
  stats::setNames(
    vapply(registry$operations, `[[`, character(1L), "command"),
    vapply(registry$operations, `[[`, character(1L), "operation_id")
  )
}

ci_workflow_step_values <- function(job, field) {
  values <- lapply(job$steps, `[[`, field)
  unname(vapply(Filter(Negate(is.null), values), as.character, character(1L)))
}

ci_workflow_normalized_text <- function(repository_root, path) {
  gsub(
    "[[:space:]]+",
    " ",
    paste(readLines(file.path(repository_root, path), warn = FALSE), collapse = "\n")
  )
}

governance_test_cases <- function(repository_root) {
  workflow <- ci_workflow_read(repository_root)
  operations <- ci_workflow_operation_map(repository_root)
  forward <- workflow$jobs$checkpoint
  legacy <- workflow$jobs[["legacy-regression"]]
  forward_runs <- ci_workflow_step_values(forward, "run")
  legacy_runs <- ci_workflow_step_values(legacy, "run")
  all_runs <- c(forward_runs, legacy_runs)

  list(
    "push and pull request CI invokes registered ci-active exactly once" = function() {
      events <- names(workflow[["on"]])
      phase0_assert_true(setequal(
        events, c("push", "pull_request", "workflow_dispatch")
      ))
      ci_command <- unname(operations[["platform.validate-ci-active"]])
      phase0_assert_true(!is.null(ci_command))
      phase0_assert_true(identical(
        forward[["if"]], "github.event_name != 'workflow_dispatch'"
      ))
      phase0_assert_true(identical(forward_runs, ci_command))
      phase0_assert_true(sum(all_runs == ci_command) == 1L)
    },

    "ordinary CI does not duplicate or invoke historical validation" = function() {
      prohibited <- c(
        "validate-documentation[.]R",
        "--mode[[:space:]]+(development|checkpoint)",
        "legacy-v0[.]1-(development|checkpoint)",
        "tests/run-phase[0-9]+-tests[.]R"
      )
      phase0_assert_false(any(vapply(
        prohibited,
        grepl,
        logical(1L),
        x = paste(forward_runs, collapse = "\n"),
        perl = TRUE
      )))
    },

    "manual legacy validation is closed allowlisted and exact" = function() {
      input <- workflow[["on"]]$workflow_dispatch$inputs$profile
      choices <- c("legacy-v0.1-development", "legacy-v0.1-checkpoint")
      legacy_commands <- unname(operations[c(
        "platform.validate-legacy-development",
        "platform.validate-legacy-checkpoint"
      )])
      phase0_assert_true(isTRUE(input$required))
      phase0_assert_true(identical(input$type, "choice"))
      phase0_assert_true(identical(input$options, choices))
      phase0_assert_true(identical(
        legacy[["if"]], "github.event_name == 'workflow_dispatch'"
      ))
      phase0_assert_true(all(vapply(
        legacy_commands,
        function(command) sum(legacy_runs == command) == 1L,
        logical(1L)
      )))
      phase0_assert_false(any(grepl("inputs.profile", legacy_runs, fixed = TRUE)))
      phase0_assert_true(any(grepl(
        "Unsupported legacy validation profile", legacy_runs, fixed = TRUE
      )))
    },

    "workflow retains least privilege and hosted environment" = function() {
      phase0_assert_true(identical(workflow$permissions, list(contents = "read")))
      phase0_assert_true(all(vapply(
        workflow$jobs,
        function(job) is.null(job$permissions),
        logical(1L)
      )))
      phase0_assert_true(all(vapply(
        workflow$jobs,
        function(job) identical(job[["runs-on"]], "ubuntu-latest"),
        logical(1L)
      )))
      phase0_assert_true(all(vapply(workflow$jobs, function(job) {
        uses <- ci_workflow_step_values(job, "uses")
        setup_r <- Filter(
          function(step) identical(step$uses, "r-lib/actions/setup-r@v2"),
          job$steps
        )
        "actions/checkout@v4" %in% uses &&
          "r-lib/actions/setup-renv@v2" %in% uses &&
          length(setup_r) == 1L &&
          identical(setup_r[[1L]]$with[["r-version"]], "4.4") &&
          isTRUE(setup_r[[1L]]$with[["use-public-rspm"]])
      }, logical(1L))))
    },

    "workflow cannot publish deploy or mutate remotes" = function() {
      all_uses <- unlist(lapply(
        workflow$jobs, ci_workflow_step_values, field = "uses"
      ), use.names = FALSE)
      executable <- paste(c(all_runs, all_uses), collapse = "\n")
      prohibited <- c(
        "publish-release", "prepare-release", "hospital", "acquisition",
        "connect-cloud", "deploy", "git[[:space:]]+(push|tag|remote)",
        "gh[[:space:]]+release", "upload-artifact", "create-release"
      )
      phase0_assert_false(any(vapply(
        prohibited, grepl, logical(1L), x = executable,
        ignore.case = TRUE, perl = TRUE
      )))
      workflow_text <- paste(
        readLines(
          file.path(repository_root, ".github", "workflows", "validation.yml"),
          warn = FALSE
        ),
        collapse = "\n"
      )
      phase0_assert_false(grepl("secrets[.]", workflow_text, ignore.case = TRUE))
    },

    "documentation distinguishes local hosted and legacy validation" = function() {
      paths <- c(
        "AGENTS.md",
        "CONTRIBUTING.md",
        "README.md",
        "docs/operations/validation.md",
        "docs/development/validation-governance.md"
      )
      documents <- vapply(
        paths,
        function(path) ci_workflow_normalized_text(repository_root, path),
        character(1L)
      )
      source_changed <- unname(operations[["platform.validate-source-changed"]])
      ci_active <- unname(operations[["platform.validate-ci-active"]])
      legacy_profiles <- c("legacy-v0.1-development", "legacy-v0.1-checkpoint")
      phase0_assert_true(all(grepl(source_changed, documents, fixed = TRUE)))
      phase0_assert_true(all(grepl(ci_active, documents, fixed = TRUE)))
      phase0_assert_true(all(vapply(documents, function(document) {
        grepl("hosted", document, ignore.case = TRUE) &&
          grepl("local", document, ignore.case = TRUE) &&
          all(vapply(legacy_profiles, grepl, logical(1L), x = document, fixed = TRUE))
      }, logical(1L))))
    }
  )
}
