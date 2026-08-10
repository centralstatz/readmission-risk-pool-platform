# Validation of maintained Phase 2.1 canonical specification assets.

rrp_validate_canonical_bundle_specification <- function(
  document,
  location = NA_character_
) {
  issues <- list()
  expected_foundation <- rrp_foundation_vocabulary_identity()
  foundation <- rrp_validate_canonical_specification_reference(
    document$foundation_vocabulary,
    "$.foundation_vocabulary",
    location,
    expected_kind = expected_foundation$specification_kind,
    expected_id = expected_foundation$specification_id,
    supported_version = expected_foundation$specification_version
  )
  issues[[length(issues) + 1L]] <- foundation$issues

  expected_values <- list(
    requirement_classes = rrp_canonical_requirement_classes(),
    availability_statuses = rrp_capability_statuses(),
    dependency_subject_types = rrp_canonical_subject_types(),
    condition_subject_types = rrp_canonical_subject_types(),
    temporal_order_rules = rrp_canonical_temporal_order_rules()
  )
  controlled <- document$controlled_values
  if (!rrp_is_named_mapping(controlled)) {
    issues[[length(issues) + 1L]] <- rrp_canonical_issue(
      "canonical.specification.controlled_values",
      "missing_canonical_controlled_values",
      "Canonical bundle specification requires controlled values.",
      "$.controlled_values",
      location
    )
  } else {
    for (name in names(expected_values)) {
      observed <- unlist(controlled[[name]], use.names = FALSE)
      if (!identical(observed, expected_values[[name]])) {
        issues[[length(issues) + 1L]] <- rrp_canonical_issue(
          "canonical.specification.controlled_values",
          paste0("invalid_", name),
          paste0("Canonical controlled values do not match `", name, "`."),
          paste0("$.controlled_values.", name),
          location
        )
      }
    }
  }

  observed_layers <- unlist(document$conformance_layers, use.names = FALSE)
  if (!identical(observed_layers, rrp_canonical_conformance_layers())) {
    issues[[length(issues) + 1L]] <- rrp_canonical_issue(
      "canonical.specification.conformance_layers",
      "invalid_conformance_layers",
      "Canonical conformance layers do not match the implemented vocabulary.",
      "$.conformance_layers",
      location
    )
  }

  observed_categories <- unlist(
    document$conformance_failure_categories,
    use.names = TRUE
  )
  if (!identical(observed_categories, rrp_canonical_failure_categories())) {
    issues[[length(issues) + 1L]] <- rrp_canonical_issue(
      "canonical.specification.conformance_layers",
      "invalid_conformance_failure_categories",
      "Canonical failure categories do not match the layered result vocabulary.",
      "$.conformance_failure_categories",
      location
    )
  }

  required_sections <- c(
    "bundle_instance",
    "domain_registration",
    "capability_declaration",
    "dependency_declaration",
    "conditional_requirement",
    "temporal_declaration",
    "reference_test_realization"
  )
  for (section in required_sections) {
    if (!rrp_is_named_mapping(document[[section]])) {
      issues[[length(issues) + 1L]] <- rrp_canonical_issue(
        "canonical.specification.sections",
        paste0("missing_", section),
        paste0("Canonical bundle specification requires section `", section, "`."),
        paste0("$.", section),
        location
      )
    }
  }

  rrp_canonical_result(document, issues)
}

rrp_validate_canonical_example_document <- function(
  document,
  location = NA_character_
) {
  issues <- list()
  expectation <- document$expected_conformance
  if (!rrp_is_named_mapping(expectation) ||
      !rrp_is_scalar_character(expectation$overall_status) ||
      !expectation$overall_status %in% c("pass", "fail") ||
      is.null(expectation$issue_codes)) {
    issues[[1L]] <- rrp_canonical_issue(
      "canonical.example.expectation",
      "invalid_example_expectation",
      "Canonical example requires pass/fail status and an issue-code sequence.",
      "$.expected_conformance",
      location
    )
    return(rrp_canonical_result(document, issues))
  }

  bundle_result <- rrp_validate_canonical_bundle_instance(
    document$bundle_instance,
    location
  )
  expected_codes <- sort(unique(as.character(unlist(
    expectation$issue_codes, use.names = FALSE
  ))))
  observed_codes <- sort(unique(as.character(bundle_result$issues$issue_code)))
  if (!identical(bundle_result$overall_status, expectation$overall_status)) {
    issues[[length(issues) + 1L]] <- rrp_canonical_issue(
      "canonical.example.expectation",
      "unexpected_example_status",
      paste0(
        "Expected bundle status `", expectation$overall_status,
        "` but observed `", bundle_result$overall_status, "`."
      ),
      "$.expected_conformance.overall_status",
      location
    )
  }
  if (!identical(expected_codes, observed_codes)) {
    issues[[length(issues) + 1L]] <- rrp_canonical_issue(
      "canonical.example.expectation",
      "unexpected_example_issue_codes",
      paste0(
        "Expected issue codes [", paste(expected_codes, collapse = ", "),
        "]; observed [", paste(observed_codes, collapse = ", "), "]."
      ),
      "$.expected_conformance.issue_codes",
      location
    )
  }

  result <- rrp_canonical_result(document, issues)
  attr(result, "bundle_result") <- bundle_result
  result
}

rrp_canonical_specification_paths <- function(repository_root) {
  directory <- file.path(repository_root, "contracts", "canonical")
  if (!dir.exists(directory)) return(character())
  sort(list.files(
    directory,
    pattern = "[.]ya?ml$",
    recursive = TRUE,
    full.names = TRUE
  ))
}

rrp_validate_canonical_specification_repository <- function(repository_root) {
  repository_root <- normalizePath(repository_root, mustWork = TRUE)
  paths <- rrp_canonical_specification_paths(repository_root)
  checks <- list()
  issues <- list()
  identities <- character()

  for (path in paths) {
    relative <- rrp_repository_relative_path(repository_root, path)
    envelope <- rrp_validate_specification_file(path, repository_root)
    document <- attr(envelope, "document")
    results <- list(envelope)

    if (rrp_conforms(envelope)) {
      identities <- c(identities, paste(
        document$specification_kind,
        document$specification_id,
        document$specification_version,
        sep = "|"
      ))
      if (identical(document$specification_kind, "canonical_bundle")) {
        results[[length(results) + 1L]] <-
          rrp_validate_canonical_bundle_specification(document, relative)
      } else if (identical(
        document$specification_kind, "canonical_bundle_example"
      )) {
        results[[length(results) + 1L]] <-
          rrp_validate_canonical_example_document(document, relative)
      } else {
        issue <- rrp_canonical_issue(
          "canonical.specification.kind",
          "unsupported_canonical_specification_kind",
          "Canonical foundation directory contains an unsupported specification kind.",
          "$.specification_kind",
          relative
        )
        results[[length(results) + 1L]] <- rrp_canonical_result(document, list(issue))
      }
    }

    combined <- rrp_combine_conformance_results(
      document %||% list(),
      rrp_canonical_bundle_specification_identity(),
      results
    )
    checks[[length(checks) + 1L]] <- rrp_check(
      paste0("canonical_specification:", relative),
      rrp_conforms(combined),
      if (rrp_conforms(combined)) {
        paste0(document$specification_id, "@", document$specification_version)
      } else {
        paste(nrow(combined$issues), "conformance issues")
      }
    )
    for (index in seq_len(nrow(combined$issues))) {
      issue <- combined$issues[index, ]
      issues[[length(issues) + 1L]] <- rrp_issue(
        paste0("canonical_specification:", relative),
        issue$issue_code,
        paste0("[", issue$rule_id, "/", issue$severity, "] ", issue$message),
        relative
      )
    }
  }

  duplicate_identities <- unique(identities[duplicated(identities)])
  for (identity in duplicate_identities) {
    issues[[length(issues) + 1L]] <- rrp_issue(
      "canonical_specification_identity_uniqueness",
      "duplicate_canonical_specification_identity",
      paste0("Duplicate canonical specification identity: ", identity),
      "contracts/canonical"
    )
  }
  checks[[length(checks) + 1L]] <- rrp_check(
    "canonical_specification_identity_uniqueness",
    length(duplicate_identities) == 0L,
    paste(length(identities), "unique canonical specification identities")
  )

  rrp_validation_result(
    "Canonical bundle foundation validation",
    rrp_bind_rows(checks, rrp_empty_checks),
    rrp_bind_rows(issues, rrp_empty_issues)
  )
}

rrp_validate_phase2_checkpoint <- function(repository_root) {
  repository_root <- normalizePath(repository_root, mustWork = TRUE)
  checks <- list()
  issues <- list()

  required_files <- c(
    "contracts/canonical/canonical-bundle.yml",
    "contracts/canonical/examples/valid-bundle.yml",
    "contracts/canonical/examples/unavailable-optional-capability.yml",
    "contracts/canonical/examples/unsupported-capability.yml",
    "contracts/canonical/examples/failed-capability-claim.yml",
    "contracts/canonical/examples/dependency-failure.yml",
    "contracts/canonical/examples/temporal-availability-failure.yml",
    "docs/architecture/canonical-bundle-foundation.md",
    "operations/lib/canonical-bundle-validation.R",
    "operations/lib/canonical-specification-validation.R",
    "tests/phase2/test-canonical-bundle-foundation.R",
    "tests/run-phase2-tests.R"
  )
  missing <- required_files[!file.exists(file.path(repository_root, required_files))]
  for (file in missing) {
    issues[[length(issues) + 1L]] <- rrp_issue(
      "phase2_required_files",
      "missing_phase2_file",
      "Required Phase 2.1 foundation file is missing.",
      file
    )
  }
  checks[[length(checks) + 1L]] <- rrp_check(
    "phase2_required_files",
    length(missing) == 0L,
    paste(length(required_files), "required Phase 2.1 files")
  )

  actual_canonical_files <- vapply(
    rrp_canonical_specification_paths(repository_root),
    function(path) rrp_repository_relative_path(repository_root, path),
    character(1)
  )
  expected_canonical_files <- required_files[startsWith(
    required_files, "contracts/canonical/"
  )]
  unexpected <- setdiff(actual_canonical_files, expected_canonical_files)
  prohibited_directories <- c(
    "contracts/schemas",
    "contracts/domains",
    "implementations",
    "runtime",
    "products",
    "app",
    "deploy",
    "config"
  )
  premature <- prohibited_directories[dir.exists(file.path(
    repository_root, prohibited_directories
  ))]
  for (path in c(unexpected, premature)) {
    issues[[length(issues) + 1L]] <- rrp_issue(
      "phase2_scope",
      "premature_phase2_content",
      "Clinical-domain or later-phase implementation content is premature.",
      path
    )
  }
  checks[[length(checks) + 1L]] <- rrp_check(
    "phase2_scope",
    length(unexpected) + length(premature) == 0L,
    "only approved generic canonical assets; no clinical or later-phase scaffold"
  )

  record_path <- file.path(
    repository_root, "docs", "architecture", "platform-implementation-record.md"
  )
  record_text <- if (file.exists(record_path)) {
    paste(rrp_read_text(record_path), collapse = "\n")
  } else {
    ""
  }
  record_heading <-
    "### Iteration 2.1 — Canonical capability and bundle identity foundation"
  recorded <- grepl(record_heading, record_text, fixed = TRUE)
  if (!recorded) {
    issues[[length(issues) + 1L]] <- rrp_issue(
      "phase2_implementation_record",
      "missing_phase2_implementation_record",
      "Implementation record must contain the completed Iteration 2.1 entry.",
      "docs/architecture/platform-implementation-record.md"
    )
  }
  checks[[length(checks) + 1L]] <- rrp_check(
    "phase2_implementation_record",
    recorded,
    "Iteration 2.1 implementation evidence is recorded"
  )

  rrp_validation_result(
    "Phase 2.1 checkpoint validation",
    rrp_bind_rows(checks, rrp_empty_checks),
    rrp_bind_rows(issues, rrp_empty_issues)
  )
}
