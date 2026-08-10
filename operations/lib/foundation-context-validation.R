# Validation of the Phase 1 identity/time vocabulary and teaching examples.

rrp_foundation_vocabulary_identity <- function() {
  list(
    specification_kind = "foundation_vocabulary",
    specification_id = "platform.foundation-vocabulary",
    specification_version = "0.1.0"
  )
}

rrp_rfc3339_timestamp_pattern <- function() {
  paste0(
    "^[0-9]{4}-[0-9]{2}-[0-9]{2}T[0-9]{2}:[0-9]{2}:[0-9]{2}",
    "(?:[.][0-9]+)?(?:Z|[+-][0-9]{2}:[0-9]{2})$"
  )
}

rrp_is_rfc3339_timestamp <- function(value) {
  if (!rrp_is_scalar_character(value) ||
      !grepl(rrp_rfc3339_timestamp_pattern(), value, perl = TRUE)) {
    return(FALSE)
  }

  normalized <- sub("Z$", "+0000", value)
  normalized <- sub("([+-][0-9]{2}):([0-9]{2})$", "\\1\\2", normalized, perl = TRUE)
  parsed <- strptime(normalized, format = "%Y-%m-%dT%H:%M:%OS%z", tz = "UTC")
  !is.na(parsed)
}

rrp_validate_as_of_context <- function(context, required = TRUE, location = NA_character_) {
  target <- rrp_foundation_vocabulary_identity()
  issues <- list()

  if (is.null(context)) {
    if (isTRUE(required)) {
      issues[[1L]] <- rrp_conformance_issue(
        "as_of.required", "error", "missing_as_of_context",
        "Required as-of context is absent.", "$.as_of_context", location, target
      )
    }
    return(rrp_conformance_result(context, target, rrp_bind_rows(
      issues, rrp_empty_conformance_issues
    )))
  }

  if (!is.list(context)) {
    issues[[1L]] <- rrp_conformance_issue(
      "as_of.mapping", "error", "invalid_as_of_context",
      "As-of context must be a mapping.", "$.as_of_context", location, target
    )
    return(rrp_conformance_result(context, target, do.call(rbind, issues)))
  }

  timestamp_fields <- c(
    "as_of_time", "source_extracted_at", "generated_at", "executed_at"
  )
  if (is.null(context$as_of_time)) {
    issues[[length(issues) + 1L]] <- rrp_conformance_issue(
      "as_of.required", "error", "missing_as_of_time",
      "As-of context requires one authoritative `as_of_time`.",
      "$.as_of_context.as_of_time", location, target
    )
  }

  for (field in intersect(timestamp_fields, names(context))) {
    if (!rrp_is_rfc3339_timestamp(context[[field]])) {
      issues[[length(issues) + 1L]] <- rrp_conformance_issue(
        "as_of.timestamp", "error", paste0("invalid_", field),
        paste0("Field `", field, "` must be an RFC 3339 timestamp with an explicit offset."),
        paste0("$.as_of_context.", field), location, target
      )
    }
  }

  rrp_conformance_result(
    context, target, rrp_bind_rows(issues, rrp_empty_conformance_issues)
  )
}

rrp_validate_versioned_identity <- function(
  identity,
  id_field,
  version_field,
  object_path,
  location = NA_character_
) {
  target <- rrp_foundation_vocabulary_identity()
  issues <- list()

  if (!is.list(identity)) {
    issue <- rrp_conformance_issue(
      "identity.mapping", "error", "invalid_identity",
      "Versioned identity must be a mapping.", object_path, location, target
    )
    return(rrp_conformance_result(identity, target, issue))
  }

  if (!rrp_is_scalar_character(identity[[id_field]]) ||
      !grepl(rrp_identifier_pattern(), identity[[id_field]] %||% "", perl = TRUE)) {
    issues[[length(issues) + 1L]] <- rrp_conformance_issue(
      "identity.id", "error", paste0("invalid_", id_field),
      paste0("Field `", id_field, "` must be a stable logical identifier."),
      paste0(object_path, ".", id_field), location, target
    )
  }
  if (!rrp_is_semver(identity[[version_field]])) {
    issues[[length(issues) + 1L]] <- rrp_conformance_issue(
      "identity.version", "error", paste0("invalid_", version_field),
      paste0("Field `", version_field, "` must be a Semantic Versioning string."),
      paste0(object_path, ".", version_field), location, target
    )
  }

  rrp_conformance_result(
    identity, target, rrp_bind_rows(issues, rrp_empty_conformance_issues)
  )
}

rrp_capability_statuses <- function() {
  c("available", "unavailable", "unsupported", "failed_conformance")
}

rrp_validate_capability_declaration <- function(declaration, location = NA_character_) {
  target <- rrp_foundation_vocabulary_identity()
  issues <- list()

  if (!is.list(declaration)) {
    issue <- rrp_conformance_issue(
      "capability.mapping", "error", "invalid_capability_declaration",
      "Capability declaration must be a mapping.",
      "$.capability_declaration", location, target
    )
    return(rrp_conformance_result(declaration, target, issue))
  }

  if (!rrp_is_scalar_character(declaration$capability_id) ||
      !grepl(rrp_identifier_pattern(), declaration$capability_id %||% "", perl = TRUE)) {
    issues[[length(issues) + 1L]] <- rrp_conformance_issue(
      "capability.id", "error", "invalid_capability_id",
      "Capability ID must be a stable logical identifier.",
      "$.capability_declaration.capability_id", location, target
    )
  }
  if (!rrp_is_scalar_character(declaration$status) ||
      !declaration$status %in% rrp_capability_statuses()) {
    issues[[length(issues) + 1L]] <- rrp_conformance_issue(
      "capability.status", "error", "invalid_capability_status",
      paste0(
        "Capability status must be one of: ",
        paste(rrp_capability_statuses(), collapse = ", "), "."
      ),
      "$.capability_declaration.status", location, target
    )
  }

  rrp_conformance_result(
    declaration, target, rrp_bind_rows(issues, rrp_empty_conformance_issues)
  )
}

rrp_validate_provenance_reference <- function(reference, location = NA_character_) {
  target <- rrp_foundation_vocabulary_identity()
  issues <- list()
  required <- c("provenance_type", "provenance_id", "relationship")

  if (!is.list(reference)) {
    issue <- rrp_conformance_issue(
      "provenance.mapping", "error", "invalid_provenance_reference",
      "Provenance reference must be a mapping.",
      "$.provenance_reference", location, target
    )
    return(rrp_conformance_result(reference, target, issue))
  }

  for (field in required) {
    if (!rrp_is_scalar_character(reference[[field]]) ||
        !grepl(rrp_identifier_pattern(), reference[[field]] %||% "", perl = TRUE)) {
      issues[[length(issues) + 1L]] <- rrp_conformance_issue(
        "provenance.required", "error", paste0("invalid_", field),
        paste0("Field `", field, "` must be a stable logical identifier."),
        paste0("$.provenance_reference.", field), location, target
      )
    }
  }
  if (!is.null(reference$version_or_revision) &&
      !rrp_is_scalar_character(reference$version_or_revision)) {
    issues[[length(issues) + 1L]] <- rrp_conformance_issue(
      "provenance.revision", "error", "invalid_version_or_revision",
      "Optional provenance version/revision must be one non-empty string.",
      "$.provenance_reference.version_or_revision", location, target
    )
  }

  rrp_conformance_result(
    reference, target, rrp_bind_rows(issues, rrp_empty_conformance_issues)
  )
}

rrp_validate_run_context <- function(context, location = NA_character_) {
  target <- rrp_foundation_vocabulary_identity()
  issues <- list()

  if (!is.list(context)) {
    issue <- rrp_conformance_issue(
      "run.mapping", "error", "invalid_run_context",
      "Run context must be a mapping.", "$.run_context", location, target
    )
    return(rrp_conformance_result(context, target, issue))
  }

  for (field in c("run_id", "operation_id")) {
    if (!rrp_is_scalar_character(context[[field]]) ||
        !grepl(rrp_identifier_pattern(), context[[field]] %||% "", perl = TRUE)) {
      issues[[length(issues) + 1L]] <- rrp_conformance_issue(
        "run.identity", "error", paste0("invalid_", field),
        paste0("Field `", field, "` must be a stable logical identifier."),
        paste0("$.run_context.", field), location, target
      )
    }
  }
  as_of <- rrp_validate_as_of_context(
    list(as_of_time = context$as_of_time),
    required = TRUE,
    location = location
  )

  rrp_conformance_result(
    context,
    target,
    rrp_bind_rows(c(issues, list(as_of$issues)), rrp_empty_conformance_issues)
  )
}

rrp_diagnostic_severities <- function() c("info", "warning", "error")
rrp_diagnostic_statuses <- function() c("started", "succeeded", "failed")

rrp_validate_diagnostic_envelope <- function(event, location = NA_character_) {
  target <- rrp_foundation_vocabulary_identity()
  issues <- list()
  required <- c(
    "event_timestamp", "run_id", "operation_id", "component", "stage",
    "severity", "status", "diagnostic_code", "message"
  )

  if (!is.list(event)) {
    issue <- rrp_conformance_issue(
      "diagnostic.mapping", "error", "invalid_diagnostic_envelope",
      "Diagnostic envelope must be a mapping.",
      "$.diagnostic_envelope", location, target
    )
    return(rrp_conformance_result(event, target, issue))
  }

  for (field in required) {
    if (!rrp_is_scalar_character(event[[field]])) {
      issues[[length(issues) + 1L]] <- rrp_conformance_issue(
        "diagnostic.required", "error", paste0("invalid_", field),
        paste0("Diagnostic field `", field, "` must be one non-empty string."),
        paste0("$.diagnostic_envelope.", field), location, target
      )
    }
  }
  if (rrp_is_scalar_character(event$event_timestamp) &&
      !rrp_is_rfc3339_timestamp(event$event_timestamp)) {
    issues[[length(issues) + 1L]] <- rrp_conformance_issue(
      "diagnostic.timestamp", "error", "invalid_event_timestamp",
      "Diagnostic event timestamp must be RFC 3339 with an explicit offset.",
      "$.diagnostic_envelope.event_timestamp", location, target
    )
  }
  if (rrp_is_scalar_character(event$severity) &&
      !event$severity %in% rrp_diagnostic_severities()) {
    issues[[length(issues) + 1L]] <- rrp_conformance_issue(
      "diagnostic.severity", "error", "invalid_diagnostic_severity",
      "Unknown diagnostic severity.",
      "$.diagnostic_envelope.severity", location, target
    )
  }
  if (rrp_is_scalar_character(event$status) &&
      !event$status %in% rrp_diagnostic_statuses()) {
    issues[[length(issues) + 1L]] <- rrp_conformance_issue(
      "diagnostic.status", "error", "invalid_diagnostic_status",
      "Unknown diagnostic status.",
      "$.diagnostic_envelope.status", location, target
    )
  }

  rrp_conformance_result(
    event, target, rrp_bind_rows(issues, rrp_empty_conformance_issues)
  )
}

rrp_validate_conformance_fixture <- function(fixture, location = NA_character_) {
  target <- rrp_foundation_vocabulary_identity()
  issues <- list()

  if (!is.list(fixture)) {
    issue <- rrp_conformance_issue(
      "conformance.mapping", "error", "invalid_conformance_fixture",
      "Conformance-result fixture must be a mapping.",
      "$.conformance_result", location, target
    )
    return(rrp_conformance_result(fixture, target, issue))
  }

  if (!rrp_is_scalar_character(fixture$overall_status) ||
      !fixture$overall_status %in% c("pass", "fail")) {
    issues[[length(issues) + 1L]] <- rrp_conformance_issue(
      "conformance.status", "error", "invalid_overall_status",
      "Overall conformance status must be `pass` or `fail`.",
      "$.conformance_result.overall_status", location, target
    )
  }

  fixture_issues <- fixture$issues
  if (is.null(fixture_issues)) fixture_issues <- list()
  if (!is.list(fixture_issues)) {
    issues[[length(issues) + 1L]] <- rrp_conformance_issue(
      "conformance.issues", "error", "invalid_issue_collection",
      "Conformance issues must be a list.",
      "$.conformance_result.issues", location, target
    )
    fixture_issues <- list()
  }

  observed_severities <- character()
  for (index in seq_along(fixture_issues)) {
    issue <- fixture_issues[[index]]
    base_path <- paste0("$.conformance_result.issues[", index, "]")
    for (field in c("rule_id", "severity", "issue_code", "message")) {
      if (!is.list(issue) || !rrp_is_scalar_character(issue[[field]])) {
        issues[[length(issues) + 1L]] <- rrp_conformance_issue(
          "conformance.issue_fields", "error", paste0("invalid_issue_", field),
          paste0("Conformance issue field `", field, "` must be one non-empty string."),
          paste0(base_path, ".", field), location, target
        )
      }
    }
    if (is.list(issue) && rrp_is_scalar_character(issue$severity)) {
      observed_severities <- c(observed_severities, issue$severity)
      if (!issue$severity %in% rrp_diagnostic_severities()) {
        issues[[length(issues) + 1L]] <- rrp_conformance_issue(
          "conformance.severity", "error", "invalid_issue_severity",
          "Conformance issue severity must be info, warning, or error.",
          paste0(base_path, ".severity"), location, target
        )
      }
    }
  }

  derived_status <- if ("error" %in% observed_severities) "fail" else "pass"
  if (rrp_is_scalar_character(fixture$overall_status) &&
      fixture$overall_status %in% c("pass", "fail") &&
      !identical(fixture$overall_status, derived_status)) {
    issues[[length(issues) + 1L]] <- rrp_conformance_issue(
      "conformance.derivation", "error", "inconsistent_overall_status",
      paste0("Overall status must be derived as `", derived_status, "` from issue severity."),
      "$.conformance_result.overall_status", location, target
    )
  }

  rrp_conformance_result(
    fixture, target, rrp_bind_rows(issues, rrp_empty_conformance_issues)
  )
}

rrp_validate_foundation_example <- function(document, location) {
  example <- document$example
  target <- rrp_foundation_vocabulary_identity()
  if (!is.list(example)) {
    issue <- rrp_conformance_issue(
      "foundation_example.mapping", "error", "missing_foundation_example",
      "Foundation example requires an `example` mapping.",
      "$.example", location, target
    )
    return(rrp_conformance_result(document, target, issue))
  }

  results <- list(
    rrp_validate_as_of_context(example$as_of_context, TRUE, location),
    rrp_validate_versioned_identity(
      example$implementation_identity,
      "implementation_id", "implementation_version",
      "$.example.implementation_identity", location
    ),
    rrp_validate_versioned_identity(
      example$mapping_identity,
      "mapping_id", "mapping_version",
      "$.example.mapping_identity", location
    ),
    rrp_validate_run_context(example$run_context, location),
    rrp_validate_capability_declaration(example$capability_declaration, location),
    rrp_validate_provenance_reference(example$provenance_reference, location),
    rrp_validate_diagnostic_envelope(example$diagnostic_envelope, location)
  )
  rrp_combine_conformance_results(document, target, results)
}

rrp_validate_foundation_vocabulary <- function(document, location) {
  target <- rrp_foundation_vocabulary_identity()
  issues <- list()
  expected <- list(
    identity_scopes = rrp_specification_identity_scopes(),
    specification_statuses = rrp_specification_statuses(),
    capability_statuses = rrp_capability_statuses(),
    conformance_statuses = c("pass", "fail"),
    check_statuses = c("pass", "fail", "not_applicable"),
    severities = rrp_diagnostic_severities(),
    diagnostic_statuses = rrp_diagnostic_statuses()
  )

  if (!is.list(document$vocabulary)) {
    issues[[1L]] <- rrp_conformance_issue(
      "vocabulary.mapping", "error", "missing_foundation_vocabulary",
      "Foundation vocabulary requires a `vocabulary` mapping.",
      "$.vocabulary", location, target
    )
  } else {
    for (name in names(expected)) {
      if (!identical(unlist(document$vocabulary[[name]], use.names = FALSE), expected[[name]])) {
        issues[[length(issues) + 1L]] <- rrp_conformance_issue(
          "vocabulary.values", "error", paste0("invalid_", name),
          paste0("Vocabulary `", name, "` does not match the authoritative values."),
          paste0("$.vocabulary.", name), location, target
        )
      }
    }
  }

  rrp_conformance_result(
    document, target, rrp_bind_rows(issues, rrp_empty_conformance_issues)
  )
}

rrp_specification_paths <- function(repository_root) {
  sort(c(
    list.files(
      file.path(repository_root, "contracts", "foundation"),
      pattern = "[.]ya?ml$", full.names = TRUE
    ),
    list.files(
      file.path(repository_root, "contracts", "examples"),
      pattern = "[.]ya?ml$", full.names = TRUE
    )
  ))
}

rrp_validate_specification_repository <- function(repository_root) {
  repository_root <- normalizePath(repository_root, mustWork = TRUE)
  paths <- rrp_specification_paths(repository_root)
  checks <- list()
  issues <- list()
  documents <- list()

  for (path in paths) {
    relative <- rrp_repository_relative_path(repository_root, path)
    envelope <- rrp_validate_specification_file(path, repository_root)
    document <- attr(envelope, "document")
    results <- list(envelope)

    if (rrp_conforms(envelope)) {
      if (identical(document$specification_kind, "foundation_vocabulary")) {
        results[[length(results) + 1L]] <- rrp_validate_foundation_vocabulary(document, relative)
      } else if (identical(document$specification_kind, "foundation_example")) {
        results[[length(results) + 1L]] <- rrp_validate_foundation_example(document, relative)
      } else if (identical(document$specification_kind, "conformance_result_example")) {
        results[[length(results) + 1L]] <- rrp_validate_conformance_fixture(
          document$example, relative
        )
      }
    }

    combined <- rrp_combine_conformance_results(
      document %||% list(), rrp_specification_envelope_identity(), results
    )
    documents[[relative]] <- document
    checks[[length(checks) + 1L]] <- rrp_check(
      paste0("specification:", relative),
      rrp_conforms(combined),
      if (rrp_conforms(combined)) {
        paste0(document$specification_id, "@", document$specification_version)
      } else {
        paste(nrow(combined$issues), "conformance issues")
      }
    )

    if (nrow(combined$issues) > 0L) {
      for (index in seq_len(nrow(combined$issues))) {
        issue <- combined$issues[index, ]
        issues[[length(issues) + 1L]] <- rrp_issue(
          paste0("specification:", relative),
          issue$issue_code,
          paste0("[", issue$rule_id, "/", issue$severity, "] ", issue$message),
          if (is.na(issue$location) || !nzchar(issue$location)) relative else issue$location
        )
      }
    }
  }

  identity_keys <- vapply(documents, function(document) {
    if (is.null(document)) return(NA_character_)
    paste(
      document$specification_kind,
      document$specification_id,
      document$specification_version,
      sep = "|"
    )
  }, character(1))
  duplicate_keys <- unique(identity_keys[!is.na(identity_keys) & duplicated(identity_keys)])
  for (key in duplicate_keys) {
    issues[[length(issues) + 1L]] <- rrp_issue(
      "specification_identity_uniqueness", "duplicate_specification_identity",
      paste0("Duplicate kind/ID/version identity: ", key), "contracts"
    )
  }
  checks[[length(checks) + 1L]] <- rrp_check(
    "specification_identity_uniqueness", length(duplicate_keys) == 0L,
    paste(length(identity_keys), "unique specification identities")
  )

  rrp_validation_result(
    "Specification foundation validation",
    rrp_bind_rows(checks, rrp_empty_checks),
    rrp_bind_rows(issues, rrp_empty_issues)
  )
}

rrp_validate_phase1_checkpoint <- function(repository_root) {
  repository_root <- normalizePath(repository_root, mustWork = TRUE)
  checks <- list()
  issues <- list()

  required_files <- c(
    "contracts/README.md",
    "contracts/foundation/foundation-vocabulary.yml",
    "contracts/examples/example-identity-context.yml",
    "contracts/examples/example-conformance-result.yml",
    "docs/architecture/specification-foundation.md",
    "operations/lib/conformance-result.R",
    "operations/lib/specification-validation.R",
    "operations/lib/foundation-context-validation.R",
    "tests/run-phase1-tests.R"
  )
  missing <- required_files[!file.exists(file.path(repository_root, required_files))]
  for (file in missing) {
    issues[[length(issues) + 1L]] <- rrp_issue(
      "phase1_required_files", "missing_phase1_file",
      "Required Phase 1 foundation file is missing.", file
    )
  }
  checks[[length(checks) + 1L]] <- rrp_check(
    "phase1_required_files", length(missing) == 0L,
    paste(length(required_files), "required Phase 1 files")
  )

  canonical_paths <- c(
    "contracts/schemas", "contracts/domains"
  )
  later_directories <- c(
    "runtime", "products", "app", "deploy", "config"
  )
  premature <- c(
    canonical_paths[dir.exists(file.path(repository_root, canonical_paths))],
    later_directories[dir.exists(file.path(repository_root, later_directories))]
  )
  for (path in premature) {
    issues[[length(issues) + 1L]] <- rrp_issue(
      "phase1_scope", "premature_phase1_content",
      "Canonical-domain or later-phase implementation content is premature.", path
    )
  }
  checks[[length(checks) + 1L]] <- rrp_check(
    "phase1_scope", length(premature) == 0L,
    "no canonical domains or later-phase implementation scaffolding"
  )

  dependency_files <- c(".Rprofile", "renv.lock", "renv/activate.R")
  missing_dependency_files <- dependency_files[
    !file.exists(file.path(repository_root, dependency_files))
  ]
  lockfile_path <- file.path(repository_root, "renv.lock")
  lockfile_text <- if (file.exists(lockfile_path)) {
    paste(rrp_read_text(lockfile_path), collapse = "\n")
  } else {
    ""
  }
  yaml_recorded <- grepl('"yaml"[[:space:]]*:', lockfile_text, perl = TRUE)
  if (length(missing_dependency_files) > 0L || !yaml_recorded) {
    issues[[length(issues) + 1L]] <- rrp_issue(
      "phase1_dependency_state", "incomplete_phase1_dependency_state",
      "renv must independently lock the justified YAML parser dependency.",
      "renv.lock"
    )
  }
  checks[[length(checks) + 1L]] <- rrp_check(
    "phase1_dependency_state",
    length(missing_dependency_files) == 0L && yaml_recorded,
    "repository-owned renv state records yaml"
  )

  rrp_validation_result(
    "Phase 1 checkpoint validation",
    rrp_bind_rows(checks, rrp_empty_checks),
    rrp_bind_rows(issues, rrp_empty_issues)
  )
}
