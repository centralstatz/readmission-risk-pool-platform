dispatcher_registry <- function(repository_root) {
  rrp_validation_load_registry(repository_root)
}

dispatcher_unit_ids <- function(plan) {
  vapply(plan$units, function(unit) unit$validator_id, character(1L))
}

dispatcher_git <- function(root, arguments) {
  output <- suppressWarnings(system2(
    Sys.which("git"),
    c("-C", shQuote(root), vapply(arguments, shQuote, character(1L))),
    stdout = TRUE,
    stderr = TRUE
  ))
  status <- attr(output, "status")
  if (!is.null(status) && !identical(status, 0L)) stop(
    "Git fixture command failed: ", paste(output, collapse = " | "),
    call. = FALSE
  )
  invisible(output)
}

dispatcher_write_script <- function(path, lines) {
  dir.create(dirname(path), recursive = TRUE, showWarnings = FALSE)
  writeLines(c("#!/usr/bin/env Rscript", lines), path)
  invisible(path)
}

governance_test_cases <- function(repository_root) {
  registry <- dispatcher_registry(repository_root)

  list(
    "named profiles resolve deterministically without duplicates" = function() {
      first <- rrp_validation_resolve_profile(registry, "ci-active")
      second <- rrp_validation_resolve_profile(registry, "ci-active")
      first_ids <- dispatcher_unit_ids(first)
      phase0_assert_true(identical(first_ids, dispatcher_unit_ids(second)))
      phase0_assert_true(!anyDuplicated(first_ids))
      phase0_assert_true(first_ids[[1L]] == "repository.validation-governance")
      phase0_assert_true(first_ids[[length(first_ids)]] == "suite.phase10")
    },

    "unknown profiles and validators fail closed" = function() {
      phase0_assert_error(
        rrp_validation_resolve_profile(registry, "missing-profile"),
        "Unknown validation profile"
      )
      phase0_assert_error(
        rrp_validation_resolve_validator(registry, "missing.validator"),
        "Unknown validator ID"
      )
      phase0_assert_error(
        rrp_validation_resolve_validator(registry, "checkpoint.phase0"),
        "not directly executable"
      )
    },

    "recursive profiles and prerequisites precede dependents" = function() {
      fast <- rrp_validation_resolve_profile(registry, "source-fast")
      phase0_assert_true(identical(
        dispatcher_unit_ids(fast),
        c(
          "repository.validation-governance",
          "repository.documentation",
          "repository.policy"
        )
      ))
      phase5 <- rrp_validation_resolve_validator(registry, "suite.phase5")
      ids <- dispatcher_unit_ids(phase5)
      phase0_assert_true(match("suite.phase2", ids) < match("suite.phase4", ids))
      phase0_assert_true(match("suite.phase4", ids) < match("suite.phase5", ids))
      phase0_assert_true(!anyDuplicated(ids))
    },

    "literal trigger matching covers exact prefix and suffix" = function() {
      triggers <- list(
        exact = "exact/file.yml",
        prefixes = "owned/directory/",
        suffixes = ".md"
      )
      phase0_assert_true(rrp_validation_path_matches("exact/file.yml", triggers))
      phase0_assert_true(rrp_validation_path_matches("owned/directory/file.R", triggers))
      phase0_assert_true(rrp_validation_path_matches("docs/file.md", triggers))
      phase0_assert_false(rrp_validation_path_matches("owned/directoryish/file.R", triggers))
      phase0_assert_false(rrp_validation_path_matches("docs/file.md.bak", triggers))
      phase0_assert_false(rrp_validation_path_matches("exact/fileXyml", triggers))
    },

    "trigger values never acquire glob or regex behavior" = function() {
      triggers <- list(exact = "a*.R", prefixes = "b[0-9]/", suffixes = ".R$")
      phase0_assert_true(rrp_validation_path_matches("a*.R", triggers))
      phase0_assert_false(rrp_validation_path_matches("actual.R", triggers))
      phase0_assert_false(rrp_validation_path_matches("b1/file", triggers))
      phase0_assert_false(rrp_validation_path_matches("file.R", triggers))
    },

    "changed paths select multiple owners and no-match stays fast" = function() {
      selected <- rrp_validation_resolve_profile(
        registry,
        "source-changed",
        "contracts/foundation/new-example.yml"
      )
      ids <- dispatcher_unit_ids(selected)
      phase0_assert_true("repository.specification-foundation" %in% ids)
      phase0_assert_true("suite.phase1" %in% ids)
      phase0_assert_true(any(vapply(selected$units, function(unit) {
        any(unit$reasons == "path-matched: contracts/foundation/new-example.yml")
      }, logical(1L))))

      unmatched <- rrp_validation_resolve_profile(
        registry,
        "source-changed",
        "unowned/file.txt"
      )
      phase0_assert_true(isTRUE(unmatched$no_scoped_matches))
      phase0_assert_true(identical(
        dispatcher_unit_ids(unmatched),
        dispatcher_unit_ids(rrp_validation_resolve_profile(registry, "source-fast"))
      ))
    },

    "explicit changed paths are normalized and unsafe paths fail" = function() {
      parsed <- rrp_validation_parse_cli(c(
        "--profile", "source-changed", "--paths",
        "./contracts/foundation/a.yml", "validation/ownership.yml", "--explain"
      ))
      phase0_assert_true(identical(parsed$action, "explain"))
      paths <- rrp_validation_normalize_paths(parsed$paths)
      phase0_assert_true(identical(
        paths,
        c("contracts/foundation/a.yml", "validation/ownership.yml")
      ))
      for (path in c("/tmp/file.R", "../file.R", "file*.R", "a;touch")) {
        phase0_assert_error(rrp_validation_normalize_paths(path), "unsafe_path")
      }
    },

    "working-tree discovery includes dirty staged and untracked paths" = function() {
      git <- Sys.which("git")
      phase0_assert_true(nzchar(git), "Git is required for this governance test.")
      root <- tempfile("rrp-dispatch-git-")
      dir.create(root)
      on.exit(unlink(root, recursive = TRUE, force = TRUE), add = TRUE)
      dispatcher_git(root, "init")
      writeLines("base", file.path(root, "tracked.txt"))
      dispatcher_git(root, c("add", "tracked.txt"))
      dispatcher_git(root, c(
        "-c", "user.name=RRP Test", "-c", "user.email=rrp@example.invalid",
        "commit", "--no-gpg-sign", "-m", "base"
      ))
      writeLines("dirty", file.path(root, "tracked.txt"))
      writeLines("staged", file.path(root, "staged.R"))
      dispatcher_git(root, c("add", "staged.R"))
      writeLines("untracked", file.path(root, "untracked.yml"))

      paths <- rrp_validation_changed_paths(root)
      phase0_assert_true(identical(
        paths,
        c("staged.R", "tracked.txt", "untracked.yml")
      ))
    },

    "forward profiles cannot reach eager legacy aggregate runners" = function() {
      plans <- list(
        rrp_validation_resolve_profile(registry, "source-fast"),
        rrp_validation_resolve_profile(
          registry,
          "source-changed",
          c("operations/validate.R", "operations/lib/runtime-operation.R")
        ),
        rrp_validation_resolve_profile(registry, "ci-active")
      )
      for (plan in plans) {
        scripts <- vapply(plan$units, function(unit) unit$runner$script, character(1L))
        phase0_assert_false(any(scripts %in% c(
          "operations/validate.R",
          "operations/validate-legacy.R"
        )))
        phase0_assert_true(is.null(plan$legacy_aggregate))
      }
    },

    "ci-active excludes historical delivery and release evidence" = function() {
      ids <- dispatcher_unit_ids(rrp_validation_resolve_profile(registry, "ci-active"))
      prohibited <- c(
        "repository.hospital-distribution", "suite.phase0", "suite.phase11",
        paste0("checkpoint.phase", 0:11),
        "lifecycle.hospital-validation",
        "lifecycle.release-candidate-validation",
        "lifecycle.publication-preflight",
        "lifecycle.publication-verification"
      )
      phase0_assert_true(length(intersect(ids, prohibited)) == 0L)
    },

    "compatibility adapter is finite code-owned and non-eager" = function() {
      expected <- c(
        "repository.specification-foundation", "repository.canonical",
        "repository.synthetic-reference", "repository.runtime-provider",
        "repository.history-persistence", "repository.products-application",
        "repository.operations", "repository.application-artifact",
        "repository.connect-cloud", "repository.observability",
        "repository.canonical-producer", "repository.hospital-distribution"
      )
      phase0_assert_true(identical(rrp_current_boundary_ids(), expected))
      definitions <- rrp_current_boundary_definitions()
      all_sources <- unlist(lapply(definitions, `[[`, "sources"), use.names = FALSE)
      phase0_assert_false("operations/lib/platform-validation.R" %in% all_sources)
      phase0_assert_false("operations/validate.R" %in% all_sources)
      phase0_assert_false(any(grepl("eval[(]parse", readLines(
        file.path(repository_root, "validation", "R", "current-boundary.R"),
        warn = FALSE
      ))))
      phase0_assert_error(
        rrp_current_boundary_definition("base.system"),
        "not allowlisted"
      )
      history_sources <- definitions[["repository.history-persistence"]]$sources
      phase0_assert_false(any(grepl("runtime-operation|provider-operation|phase", history_sources)))

      root <- tempfile("rrp-current-boundary-")
      dir.create(root)
      on.exit(unlink(root, recursive = TRUE, force = TRUE), add = TRUE)
      definition <- definitions[["repository.specification-foundation"]]
      for (relative in definition$sources) {
        dispatcher_write_script(file.path(root, relative), character())
      }
      writeLines(
        paste(
          "rrp_validate_specification_repository <- function(repository_root)",
          "structure(list(passed = FALSE), class = 'rrp_validation_result')"
        ),
        file.path(root, tail(definition$sources, 1L))
      )
      failed <- rrp_run_current_boundary(
        root, "repository.specification-foundation"
      )
      phase0_assert_false(failed$passed)
    },

    "repository policy direct runner is isolated from aggregate execution" = function() {
      script <- readLines(
        file.path(repository_root, "operations", "validate-repository-policy.R"),
        warn = FALSE
      )
      phase0_assert_true(any(grepl("rrp_validate_repository_policies", script, fixed = TRUE)))
      phase0_assert_false(any(grepl("platform-validation.R", script, fixed = TRUE)))
      phase0_assert_false(any(grepl("run-phase", script, fixed = TRUE)))
      result <- rrp_validation_run_process(
        list(script = "operations/validate-repository-policy.R", arguments = list()),
        repository_root
      )
      phase0_assert_true(identical(result$status, 0L))
      phase0_assert_false(any(grepl("Phase [0-9]+ tests", result$output)))
    },

    "legacy profiles and mode aliases preserve frozen membership" = function() {
      actual <- rrp_governance_extract_current_aggregates(repository_root)
      for (mode in c("development", "checkpoint")) {
        profile_id <- paste0("legacy-v0.1-", mode)
        plan <- rrp_validation_resolve_profile(registry, profile_id)
        aggregate <- plan$legacy_aggregate
        phase0_assert_true(identical(aggregate$aggregate_id, mode))
        phase0_assert_true(identical(
          dispatcher_unit_ids(plan),
          rrp_governance_values(aggregate$ordered_members)
        ))
        phase0_assert_true(identical(length(actual[[mode]]), length(plan$units)))
        parsed <- rrp_validation_parse_cli(c("--mode", mode))
        phase0_assert_true(identical(parsed$profile_id, profile_id))
        phase0_assert_true(identical(parsed$legacy_alias, mode))
      }
    },

    "list and explain rendering never execute validators" = function() {
      sentinel <- tempfile("rrp-explain-sentinel-")
      on.exit(unlink(sentinel, force = TRUE), add = TRUE)
      plan <- rrp_validation_resolve_profile(
        registry,
        "source-changed",
        "contracts/foundation/example.yml"
      )
      output <- capture.output({
        rrp_validation_render_profiles(registry)
        rrp_validation_render_plan(plan)
      })
      phase0_assert_true(length(output) > 0L)
      phase0_assert_false(file.exists(sentinel))
    },

    "execution is isolated deduplicated and combines child failures" = function() {
      root <- tempfile("rrp-dispatch-process-")
      dir.create(file.path(root, "tests"), recursive = TRUE)
      on.exit(unlink(root, recursive = TRUE, force = TRUE), add = TRUE)
      dispatcher_write_script(
        file.path(root, "tests", "pass.R"),
        "cat(paste0('PID=', Sys.getpid(), '\\n'))"
      )
      dispatcher_write_script(
        file.path(root, "tests", "fail.R"),
        c("cat(paste0('PID=', Sys.getpid(), '\\n'))", "quit(save='no', status=7L)")
      )
      plan <- list(
        legacy_aggregate = NULL,
        units = list(
          list(validator_id = "fixture.pass", runner = list(
            script = "tests/pass.R", arguments = list()
          )),
          list(validator_id = "fixture.fail", runner = list(
            script = "tests/fail.R", arguments = list()
          ))
        )
      )
      execution <- rrp_validation_execute_plan(plan, root)
      phase0_assert_false(execution$passed)
      phase0_assert_true(identical(execution$status, 1L))
      phase0_assert_true(identical(
        vapply(execution$results, `[[`, integer(1L), "status"),
        c(0L, 7L)
      ))
      pids <- sub("^PID=", "", vapply(
        execution$results,
        function(result) result$output[grepl("^PID=", result$output)][[1L]],
        character(1L)
      ))
      phase0_assert_true(length(unique(pids)) == 2L)
      phase0_assert_false(as.character(Sys.getpid()) %in% pids)
    },

    "CLI parsing rejects conflicting and unsafe selectors" = function() {
      phase0_assert_error(rrp_validation_parse_cli(character()), "Usage:")
      phase0_assert_error(
        rrp_validation_parse_cli(c("--profile", "source-fast", "--validator", "repository.policy")),
        "Select exactly one"
      )
      phase0_assert_error(
        rrp_validation_parse_cli(c("--profile", "ci-active", "--paths", "file.R")),
        "only by source-changed"
      )
      phase0_assert_error(
        rrp_validation_parse_cli(c("--profile", "source-changed", "--paths")),
        "requires at least one path"
      )
      phase0_assert_error(
        rrp_validation_parse_cli(c("--mode", "unknown")),
        "Unknown validation mode"
      )
    }
  )
}
