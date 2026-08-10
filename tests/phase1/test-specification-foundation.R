phase1_valid_specification <- function() {
  list(
    specification_kind = "foundation_example",
    specification_id = "platform.test-foundation-example",
    specification_version = "0.1.0",
    specification_format_version = "1.0.0",
    identity_scope = "platform",
    title = "Test foundation example",
    status = "experimental"
  )
}

phase1_test_cases <- function(repository_root) {
  list(
    "valid specification identity" = function() {
      result <- rrp_validate_specification_envelope(phase1_valid_specification())
      phase0_assert_true(rrp_conforms(result))
    },

    "missing specification ID" = function() {
      candidate <- phase1_valid_specification()
      candidate$specification_id <- NULL
      result <- rrp_validate_specification_envelope(candidate)
      phase0_assert_false(rrp_conforms(result))
      phase0_assert_true("missing_specification_id" %in% result$issues$issue_code)
    },

    "missing specification version" = function() {
      candidate <- phase1_valid_specification()
      candidate$specification_version <- NULL
      result <- rrp_validate_specification_envelope(candidate)
      phase0_assert_false(rrp_conforms(result))
      phase0_assert_true("missing_specification_version" %in% result$issues$issue_code)
    },

    "invalid specification version" = function() {
      candidate <- phase1_valid_specification()
      candidate$specification_version <- "draft-one"
      result <- rrp_validate_specification_envelope(candidate)
      phase0_assert_false(rrp_conforms(result))
      phase0_assert_true("invalid_specification_version" %in% result$issues$issue_code)

      candidate$specification_version <- "0.1.0-01"
      invalid_prerelease <- rrp_validate_specification_envelope(candidate)
      phase0_assert_false(rrp_conforms(invalid_prerelease))
      phase0_assert_true(
        "invalid_specification_version" %in% invalid_prerelease$issues$issue_code
      )
    },

    "unsupported specification format version" = function() {
      candidate <- phase1_valid_specification()
      candidate$specification_format_version <- "2.0.0"
      result <- rrp_validate_specification_envelope(candidate)
      phase0_assert_false(rrp_conforms(result))
      phase0_assert_true(
        "unsupported_specification_format_version" %in% result$issues$issue_code
      )
    },

    "supported and incompatible specification lines" = function() {
      candidate <- phase1_valid_specification()
      supported <- rrp_validate_specification_support(
        candidate,
        "foundation_example",
        "platform.test-foundation-example",
        "0.1.0"
      )
      phase0_assert_true(rrp_conforms(supported))

      candidate$specification_version <- "0.2.0"
      incompatible <- rrp_validate_specification_support(
        candidate,
        "foundation_example",
        "platform.test-foundation-example",
        "0.1.0"
      )
      phase0_assert_false(rrp_conforms(incompatible))
      phase0_assert_true(
        "unsupported_specification_version" %in% incompatible$issues$issue_code
      )
    },

    "reference identity is not universal platform identity" = function() {
      candidate <- phase1_valid_specification()
      candidate$specification_id <- "reference.default-example"
      result <- rrp_validate_specification_envelope(candidate)
      phase0_assert_false(rrp_conforms(result))
      phase0_assert_true("identity_scope_mismatch" %in% result$issues$issue_code)

      candidate$identity_scope <- "reference"
      corrected <- rrp_validate_specification_envelope(candidate)
      phase0_assert_true(rrp_conforms(corrected))
    },

    "valid as-of context distinguishes other timestamps" = function() {
      context <- list(
        as_of_time = "2026-08-09T12:00:00Z",
        source_extracted_at = "2026-08-09T12:02:00Z",
        generated_at = "2026-08-09T12:03:00Z",
        executed_at = "2026-08-09T12:04:00Z"
      )
      result <- rrp_validate_as_of_context(context)
      phase0_assert_true(rrp_conforms(result))
      phase0_assert_true(!identical(context$as_of_time, context$executed_at))
    },

    "malformed and absent as-of time" = function() {
      malformed <- rrp_validate_as_of_context(list(
        as_of_time = "2026-08-09 12:00 local"
      ))
      phase0_assert_false(rrp_conforms(malformed))
      phase0_assert_true("invalid_as_of_time" %in% malformed$issues$issue_code)

      absent <- rrp_validate_as_of_context(NULL, required = TRUE)
      phase0_assert_false(rrp_conforms(absent))
      phase0_assert_true("missing_as_of_context" %in% absent$issues$issue_code)
    },

    "all capability statuses and unknown rejection" = function() {
      for (status in rrp_capability_statuses()) {
        result <- rrp_validate_capability_declaration(list(
          capability_id = "platform.test-capability",
          status = status
        ))
        phase0_assert_true(rrp_conforms(result), paste("Rejected status", status))
      }

      invalid <- rrp_validate_capability_declaration(list(
        capability_id = "platform.test-capability",
        status = "missing"
      ))
      phase0_assert_false(rrp_conforms(invalid))
      phase0_assert_true("invalid_capability_status" %in% invalid$issues$issue_code)
    },

    "structured conformance derives status from multiple issues" = function() {
      target <- rrp_specification_envelope_identity()
      issues <- rbind(
        rrp_conformance_issue(
          "test.rule.one", "error", "first_machine_code",
          "First human-readable message.", "$.one", specification = target
        ),
        rrp_conformance_issue(
          "test.rule.two", "warning", "second_machine_code",
          "Second human-readable message.", "$.two", specification = target
        )
      )
      result <- rrp_conformance_result(phase1_valid_specification(), target, issues)
      phase0_assert_true(identical(result$overall_status, "fail"))
      phase0_assert_true(nrow(result$issues) == 2L)
      phase0_assert_true(all(nzchar(result$issues$issue_code)))
      phase0_assert_true(all(nzchar(result$issues$message)))
      phase0_assert_true(!"clinical_validity" %in% names(result))

      warning_only <- rrp_conformance_result(
        phase1_valid_specification(), target, issues[2L, , drop = FALSE]
      )
      phase0_assert_true(identical(warning_only$overall_status, "pass"))
    },

    "implementation mapping run and provenance identities are distinct" = function() {
      implementation <- rrp_validate_versioned_identity(
        list(
          implementation_id = "reference.test-implementation",
          implementation_version = "0.1.0"
        ),
        "implementation_id", "implementation_version", "$.implementation"
      )
      mapping <- rrp_validate_versioned_identity(
        list(mapping_id = "reference.test-mapping", mapping_version = "0.2.0"),
        "mapping_id", "mapping_version", "$.mapping"
      )
      run <- rrp_validate_run_context(list(
        run_id = "run_test_001",
        operation_id = "validate_specifications",
        as_of_time = "2026-08-09T12:00:00Z"
      ))
      provenance <- rrp_validate_provenance_reference(list(
        provenance_type = "specification_source",
        provenance_id = "provenance_test_001",
        relationship = "authored_from"
      ))

      phase0_assert_true(rrp_conforms(implementation))
      phase0_assert_true(rrp_conforms(mapping))
      phase0_assert_true(rrp_conforms(run))
      phase0_assert_true(rrp_conforms(provenance))
    },

    "malformed YAML returns structured conformance failure" = function() {
      fixture <- tempfile(fileext = ".yml")
      on.exit(unlink(fixture, force = TRUE), add = TRUE)
      writeLines(c("specification_kind: example", "  invalid: indentation"), fixture)
      result <- rrp_validate_specification_file(fixture, dirname(fixture))
      phase0_assert_false(rrp_conforms(result))
      phase0_assert_true("malformed_yaml" %in% result$issues$issue_code)
    },

    "foundation examples conform without sibling repository" = function() {
      result <- rrp_validate_specification_repository(repository_root)
      phase0_assert_true(result$passed)

      fixture_root <- tempfile("phase1-independent-")
      dir.create(file.path(fixture_root, "contracts", "foundation"), recursive = TRUE)
      dir.create(file.path(fixture_root, "contracts", "examples"), recursive = TRUE)
      on.exit(unlink(fixture_root, recursive = TRUE, force = TRUE), add = TRUE)
      independent_document <- phase1_valid_specification()
      independent_document$specification_kind <- "future_specification_example"
      yaml::write_yaml(
        independent_document,
        file.path(fixture_root, "contracts", "examples", "independent.yml")
      )
      independent <- rrp_validate_specification_repository(fixture_root)
      phase0_assert_true(independent$passed)
      phase0_assert_true(!dir.exists(file.path(fixture_root, "readmission-risk-pool")))
    }
  )
}
