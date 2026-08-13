phase0_test_cases <- function(repository_root) {
  list(
    "valid documentation navigation" = function() {
      fixture <- phase0_copy_repository_fixture(repository_root)
      on.exit(unlink(fixture, recursive = TRUE, force = TRUE), add = TRUE)
      result <- rrp_validate_documentation(fixture)
      phase0_assert_true(result$passed)
    },

    "broken local link" = function() {
      fixture <- phase0_copy_repository_fixture(repository_root)
      on.exit(unlink(fixture, recursive = TRUE, force = TRUE), add = TRUE)
      phase0_append_lines(
        file.path(fixture, "README.md"),
        "[Broken test link](docs/does-not-exist.md)"
      )
      result <- rrp_validate_documentation(fixture)
      phase0_assert_false(result$passed)
      phase0_assert_issue(result, "broken_local_link")
    },

    "missing governing document" = function() {
      fixture <- phase0_copy_repository_fixture(repository_root)
      on.exit(unlink(fixture, recursive = TRUE, force = TRUE), add = TRUE)
      unlink(file.path(fixture, "docs", "vision", "platform-true-north.md"))
      result <- rrp_validate_documentation(fixture)
      phase0_assert_false(result$passed)
      phase0_assert_issue(result, "missing_governing_document")
    },

    "machine-specific absolute path" = function() {
      fixture <- phase0_copy_repository_fixture(repository_root)
      on.exit(unlink(fixture, recursive = TRUE, force = TRUE), add = TRUE)
      machine_path <- paste0("/", "Users", "/example/private/project")
      phase0_append_lines(file.path(fixture, "README.md"), machine_path)
      result <- rrp_validate_documentation(fixture)
      phase0_assert_false(result$passed)
      phase0_assert_issue(result, "machine_specific_path")
    },

    "prohibited local-file URI" = function() {
      fixture <- phase0_copy_repository_fixture(repository_root)
      on.exit(unlink(fixture, recursive = TRUE, force = TRUE), add = TRUE)
      local_uri <- paste0("file", ":///temporary/private-document.md")
      phase0_append_lines(file.path(fixture, "README.md"), local_uri)
      result <- rrp_validate_documentation(fixture)
      phase0_assert_false(result$passed)
      phase0_assert_issue(result, "local_file_uri")
    },

    "permitted documented sibling reference" = function() {
      fixture <- phase0_copy_repository_fixture(repository_root)
      on.exit(unlink(fixture, recursive = TRUE, force = TRUE), add = TRUE)
      phase0_append_lines(
        file.path(fixture, "README.md"),
        paste("Development-time evidence:", rrp_sibling_reference_marker())
      )
      documentation <- rrp_validate_documentation(fixture)
      policies <- rrp_validate_repository_policies(fixture)
      phase0_assert_true(documentation$passed)
      phase0_assert_true(policies$passed)
    },

    "prohibited executable sibling dependency" = function() {
      fixture <- phase0_copy_repository_fixture(repository_root)
      on.exit(unlink(fixture, recursive = TRUE, force = TRUE), add = TRUE)
      probe <- file.path(fixture, "operations", "runtime-probe.R")
      writeLines(
        paste0("source('", rrp_sibling_reference_marker(), "/engine.R')"),
        probe
      )
      result <- rrp_validate_repository_policies(fixture)
      phase0_assert_false(result$passed)
      phase0_assert_issue(result, "executable_sibling_reference")
    },

    "unlabelled patient-like fixture" = function() {
      fixture <- phase0_copy_repository_fixture(repository_root)
      on.exit(unlink(fixture, recursive = TRUE, force = TRUE), add = TRUE)
      fixture_directory <- file.path(fixture, "tests", "fixtures")
      dir.create(fixture_directory, recursive = TRUE, showWarnings = FALSE)
      writeLines(
        c("patient_id,name", "1001,Example Person"),
        file.path(fixture_directory, "patient-example.csv")
      )
      result <- rrp_validate_repository_policies(fixture)
      phase0_assert_false(result$passed)
      phase0_assert_issue(result, "unlabelled_patient_fixture")
    },

    "validation modes are explicit" = function() {
      phase0_assert_true(identical(
        rrp_parse_validation_mode(c("--mode", "development")),
        "development"
      ))
      phase0_assert_true(identical(
        rrp_parse_validation_mode("--mode=checkpoint"),
        "checkpoint"
      ))
      phase0_assert_error(
        rrp_parse_validation_mode(c("--mode", "release")),
        "Unknown validation mode"
      )
    },

    "checkpoint rejects later-phase scaffolding" = function() {
      fixture <- phase0_copy_repository_fixture(repository_root)
      on.exit(unlink(fixture, recursive = TRUE, force = TRUE), add = TRUE)
      # Evaluate the original Phase 0 claim against a bootstrap-shaped copy;
      # later completed implementation directories are not retroactively a
      # Phase 0 failure in the live repository.
      for (directory in c("app", "contracts", "implementations", "products", "runtime")) {
        unlink(file.path(fixture, directory), recursive = TRUE, force = TRUE)
      }
      phase0_assert_true(rrp_validate_phase0_checkpoint(fixture)$passed)
      dir.create(file.path(fixture, "deploy"))
      result <- rrp_validate_phase0_checkpoint(fixture)
      phase0_assert_false(result$passed)
      phase0_assert_issue(result, "premature_architecture_directory")
    }
  )
}
