phase2_valid_bundle <- function(repository_root) {
  document <- yaml::read_yaml(file.path(
    repository_root,
    "contracts",
    "canonical",
    "examples",
    "valid-bundle.yml"
  ))
  document$bundle_instance
}

phase2_issue_codes <- function(result) unique(result$issues$issue_code)

phase2_test_cases <- function(repository_root) {
  list(
    "valid generic canonical bundle" = function() {
      result <- rrp_validate_canonical_bundle_instance(
        phase2_valid_bundle(repository_root)
      )
      phase0_assert_true(rrp_conforms(result))
      phase0_assert_true(identical(
        result$candidate$bundle_instance_id,
        "reference_bundle_valid_001"
      ))
    },

    "missing bundle instance ID" = function() {
      bundle <- phase2_valid_bundle(repository_root)
      bundle$bundle_instance_id <- NULL
      result <- rrp_validate_canonical_bundle_instance(bundle)
      phase0_assert_false(rrp_conforms(result))
      phase0_assert_true(
        "missing_or_invalid_bundle_instance_id" %in% phase2_issue_codes(result)
      )
    },

    "missing and incompatible bundle specification version" = function() {
      missing <- phase2_valid_bundle(repository_root)
      missing$bundle_specification$specification_version <- NULL
      missing_result <- rrp_validate_canonical_bundle_instance(missing)
      phase0_assert_false(rrp_conforms(missing_result))
      phase0_assert_true(
        "invalid_specification_version" %in% phase2_issue_codes(missing_result)
      )

      incompatible <- phase2_valid_bundle(repository_root)
      incompatible$bundle_specification$specification_version <- "0.2.0"
      incompatible_result <- rrp_validate_canonical_bundle_instance(incompatible)
      phase0_assert_false(rrp_conforms(incompatible_result))
      phase0_assert_true(
        "unsupported_referenced_specification_version" %in%
          phase2_issue_codes(incompatible_result)
      )
    },

    "duplicate domain registration and instance identity" = function() {
      bundle <- phase2_valid_bundle(repository_root)
      duplicate <- bundle$domains[[1L]]
      bundle$domains[[length(bundle$domains) + 1L]] <- duplicate
      result <- rrp_validate_canonical_bundle_instance(bundle)
      phase0_assert_false(rrp_conforms(result))
      phase0_assert_true(
        "duplicate_domain_registration" %in% phase2_issue_codes(result)
      )
      phase0_assert_true(
        "duplicate_domain_instance_id" %in% phase2_issue_codes(result)
      )
    },

    "implementation and mapping identities are technology independent" = function() {
      bundle <- phase2_valid_bundle(repository_root)
      phase0_assert_true(is.null(bundle$git_commit))
      phase0_assert_true(is.null(bundle$file_path))
      phase0_assert_true(is.null(bundle$technology))
      phase0_assert_true(rrp_conforms(
        rrp_validate_canonical_bundle_instance(bundle)
      ))
    },

    "missing implementation identity" = function() {
      bundle <- phase2_valid_bundle(repository_root)
      bundle$implementation_identity <- NULL
      result <- rrp_validate_canonical_bundle_instance(bundle)
      phase0_assert_false(rrp_conforms(result))
      phase0_assert_true("invalid_identity" %in% phase2_issue_codes(result))
    },

    "missing mapping identity" = function() {
      bundle <- phase2_valid_bundle(repository_root)
      bundle$mapping_identity <- NULL
      result <- rrp_validate_canonical_bundle_instance(bundle)
      phase0_assert_false(rrp_conforms(result))
      phase0_assert_true("invalid_identity" %in% phase2_issue_codes(result))
    },

    "bundle as-of requires explicit offset and is not execution time" = function() {
      valid <- phase2_valid_bundle(repository_root)
      phase0_assert_true(rrp_conforms(
        rrp_validate_canonical_bundle_instance(valid)
      ))

      no_offset <- phase2_valid_bundle(repository_root)
      no_offset$run_context$as_of_time <- "2026-08-10T12:00:00"
      no_offset_result <- rrp_validate_canonical_bundle_instance(no_offset)
      phase0_assert_false(rrp_conforms(no_offset_result))
      phase0_assert_true("invalid_as_of_time" %in% phase2_issue_codes(no_offset_result))

      execution_only <- phase2_valid_bundle(repository_root)
      execution_only$run_context$as_of_time <- NULL
      execution_only$run_context$executed_at <- "2026-08-10T12:00:00Z"
      execution_result <- rrp_validate_canonical_bundle_instance(execution_only)
      phase0_assert_false(rrp_conforms(execution_result))
      phase0_assert_true("missing_as_of_time" %in% phase2_issue_codes(execution_result))
    },

    "all capability statuses and unknown status" = function() {
      for (status in rrp_capability_statuses()) {
        bundle <- phase2_valid_bundle(repository_root)
        bundle$capabilities[[2L]]$status <- status
        result <- rrp_validate_canonical_bundle_instance(bundle)
        if (identical(status, "failed_conformance")) {
          phase0_assert_false(rrp_conforms(result))
          phase0_assert_true(
            "failed_capability_conformance" %in% phase2_issue_codes(result)
          )
        } else {
          phase0_assert_true(rrp_conforms(result), paste("Rejected status", status))
        }
      }

      bundle <- phase2_valid_bundle(repository_root)
      bundle$capabilities[[2L]]$status <- "unknown"
      result <- rrp_validate_canonical_bundle_instance(bundle)
      phase0_assert_false(rrp_conforms(result))
      phase0_assert_true("invalid_capability_status" %in% phase2_issue_codes(result))
    },

    "required conditional and optional requirement classes" = function() {
      for (class in rrp_canonical_requirement_classes()) {
        bundle <- phase2_valid_bundle(repository_root)
        bundle$domains[[3L]]$requirement_class <- class
        if (identical(class, "conditional")) {
          bundle$domains[[3L]]$condition <- list(
            subject_type = "capability",
            subject_id = "reference.entity-access",
            required_status = "available"
          )
        }
        result <- rrp_validate_canonical_bundle_instance(bundle)
        phase0_assert_true(rrp_conforms(result), paste("Rejected class", class))
      }

      bundle <- phase2_valid_bundle(repository_root)
      bundle$domains[[3L]]$requirement_class <- "sometimes"
      result <- rrp_validate_canonical_bundle_instance(bundle)
      phase0_assert_false(rrp_conforms(result))
      phase0_assert_true("invalid_requirement_class" %in% phase2_issue_codes(result))
    },

    "inactive conditional requirement may be unavailable" = function() {
      bundle <- phase2_valid_bundle(repository_root)
      bundle$domains[[3L]]$requirement_class <- "conditional"
      bundle$domains[[3L]]$status <- "unavailable"
      bundle$domains[[3L]]$domain_instance_id <- NULL
      bundle$domains[[3L]]$condition <- list(
        subject_type = "capability",
        subject_id = "reference.optional-feature",
        required_status = "available"
      )
      bundle$capabilities[[3L]]$status <- "unsupported"
      result <- rrp_validate_canonical_bundle_instance(bundle)
      phase0_assert_true(rrp_conforms(result))
    },

    "satisfied and missing dependencies" = function() {
      bundle <- phase2_valid_bundle(repository_root)
      phase0_assert_true(rrp_conforms(
        rrp_validate_canonical_bundle_instance(bundle)
      ))

      bundle$domains[[1L]]$requirement_class <- "optional"
      bundle$domains[[1L]]$status <- "unavailable"
      bundle$domains[[1L]]$domain_instance_id <- NULL
      bundle$capabilities[[1L]]$requirement_class <- "optional"
      bundle$capabilities[[1L]]$status <- "unavailable"
      result <- rrp_validate_canonical_bundle_instance(bundle)
      phase0_assert_false(rrp_conforms(result))
      phase0_assert_true(
        "missing_available_prerequisite" %in% phase2_issue_codes(result)
      )
    },

    "circular dependencies are prohibited" = function() {
      bundle <- phase2_valid_bundle(repository_root)
      bundle$dependencies[[length(bundle$dependencies) + 1L]] <- list(
        dependency_id = "reference.entity-requires-event",
        subject_type = "domain",
        subject_id = "reference.entity",
        prerequisite_type = "domain",
        prerequisite_id = "reference.event"
      )
      result <- rrp_validate_canonical_bundle_instance(bundle)
      phase0_assert_false(rrp_conforms(result))
      phase0_assert_true("circular_dependency" %in% phase2_issue_codes(result))
    },

    "generic occurrence and availability semantics" = function() {
      valid <- phase2_valid_bundle(repository_root)
      phase0_assert_true(rrp_conforms(
        rrp_validate_canonical_bundle_instance(valid)
      ))

      impossible <- phase2_valid_bundle(repository_root)
      record <- impossible$reference_test_realization$domain_payloads[[1L]]$records[[1L]]
      record$available_at <- "2026-08-10T08:59:00Z"
      impossible$reference_test_realization$domain_payloads[[1L]]$records[[1L]] <- record
      impossible_result <- rrp_validate_canonical_bundle_instance(impossible)
      phase0_assert_false(rrp_conforms(impossible_result))
      phase0_assert_true(
        "availability_before_occurrence" %in% phase2_issue_codes(impossible_result)
      )

      future <- phase2_valid_bundle(repository_root)
      future$reference_test_realization$domain_payloads[[1L]]$records[[1L]]$available_at <-
        "2026-08-10T12:01:00Z"
      future_result <- rrp_validate_canonical_bundle_instance(future)
      phase0_assert_false(rrp_conforms(future_result))
      phase0_assert_true("information_after_as_of" %in% phase2_issue_codes(future_result))
    },

    "logical validation ignores ordering filenames and paths" = function() {
      bundle <- phase2_valid_bundle(repository_root)
      bundle$domains <- rev(bundle$domains)
      bundle$capabilities <- rev(bundle$capabilities)
      bundle$dependencies <- rev(bundle$dependencies)
      bundle$reference_test_realization$domain_payloads <-
        rev(bundle$reference_test_realization$domain_payloads)
      result <- rrp_validate_canonical_bundle_instance(bundle, "memory:reordered")
      phase0_assert_true(rrp_conforms(result))
    },

    "structured bundle failures collect multiple nonclinical issues" = function() {
      bundle <- phase2_valid_bundle(repository_root)
      bundle$bundle_instance_id <- NULL
      bundle$implementation_identity <- NULL
      bundle$capabilities[[2L]]$status <- "unknown"
      result <- rrp_validate_canonical_bundle_instance(bundle)
      phase0_assert_false(rrp_conforms(result))
      phase0_assert_true(nrow(result$issues) >= 3L)
      phase0_assert_true(all(nzchar(result$issues$rule_id)))
      phase0_assert_true(all(nzchar(result$issues$issue_code)))
      phase0_assert_true(all(nzchar(result$issues$message)))
      phase0_assert_true(!"clinical_validity" %in% names(result))
    },

    "malformed registrations return structured issues" = function() {
      bundle <- phase2_valid_bundle(repository_root)
      bundle$domains[[1L]] <- "not-a-domain-mapping"
      bundle$capabilities[[1L]] <- 42
      bundle$dependencies[[1L]] <- list(
        dependency_id = "reference.malformed-dependency"
      )
      result <- rrp_validate_canonical_bundle_instance(bundle)
      phase0_assert_false(rrp_conforms(result))
      phase0_assert_true(
        "invalid_domain_registration" %in% phase2_issue_codes(result)
      )
      phase0_assert_true(
        "invalid_capability_declaration" %in% phase2_issue_codes(result)
      )
      phase0_assert_true(
        "invalid_subject_type" %in% phase2_issue_codes(result)
      )
    },

    "maintained canonical examples match expected conformance" = function() {
      result <- rrp_validate_canonical_specification_repository(repository_root)
      phase0_assert_true(result$passed)
    }
  )
}
