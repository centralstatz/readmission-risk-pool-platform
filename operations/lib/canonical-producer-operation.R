# Generic source-to-canonical producer declaration, trust, selection, execution,
# and conformance. Source implementations remain below the callable boundary.

rrp_canonical_producer_contract_identity <- function() {
  list(
    specification_kind = "canonical_producer_contract",
    specification_id = "platform.canonical-producer",
    specification_version = "0.1.0"
  )
}

rrp_canonical_producer_result_identity <- function() {
  list(
    specification_kind = "canonical_producer_result",
    specification_id = "platform.canonical-producer-result",
    specification_version = "0.1.0"
  )
}

rrp_read_canonical_producer_contract <- function(repository_root) {
  parsed <- rrp_parse_yaml_specification(file.path(
    repository_root, "contracts", "canonical", "canonical-producer.yml"
  ))
  if (!is.null(parsed$error)) stop(
    "Could not read canonical-producer contract: ", parsed$error,
    call. = FALSE
  )
  parsed$document
}

rrp_producer_issue <- function(rule_id, issue_code, message, object_path = "$") {
  rrp_conformance_issue(
    rule_id, "error", issue_code, message, object_path,
    specification = rrp_canonical_producer_contract_identity()
  )
}

rrp_producer_conformance <- function(candidate, issues) {
  rrp_conformance_result(
    candidate,
    rrp_canonical_producer_contract_identity(),
    rrp_bind_rows(issues, rrp_empty_conformance_issues)
  )
}

rrp_exact_identity <- function(value, id_field, version_field) {
  rrp_is_named_mapping(value) &&
    rrp_is_identifier(value[[id_field]]) &&
    rrp_is_semver(value[[version_field]]) &&
    identical(sort(names(value)), sort(c(id_field, version_field)))
}

rrp_validate_canonical_producer_declaration <- function(declaration, contract) {
  issues <- list()
  if (!rrp_is_named_mapping(contract) ||
      !identical(
        contract[c("specification_kind", "specification_id", "specification_version")],
        rrp_canonical_producer_contract_identity()
      )) {
    return(rrp_producer_conformance(declaration, list(rrp_producer_issue(
      "producer.contract.support", "unsupported_canonical_producer_contract",
      "Canonical-producer contract identity or version is unsupported.",
      "$.contract"
    ))))
  }
  if (!rrp_is_named_mapping(declaration)) {
    return(rrp_producer_conformance(declaration, list(rrp_producer_issue(
      "producer.declaration.structure", "invalid_producer_declaration",
      "Producer declaration must be a named language-neutral record."
    ))))
  }
  required <- c(
    "specification_kind", "specification_id", "specification_version",
    "specification_format_version", "identity_scope", "title", "status",
    unlist(contract$producer_declaration$required_fields, use.names = FALSE)
  )
  missing <- setdiff(required, names(declaration))
  if (length(missing) > 0L) issues[[length(issues) + 1L]] <- rrp_producer_issue(
    "producer.declaration.required", "missing_producer_declaration_field",
    paste0("Producer declaration fields are missing: ", paste(missing, collapse = ", "), ".")
  )
  allowed <- c(required, "description", "clinical_use")
  unknown <- setdiff(names(declaration), allowed)
  if (length(unknown) > 0L) issues[[length(issues) + 1L]] <- rrp_producer_issue(
    "producer.declaration.closed", "unknown_producer_declaration_field",
    paste0("Unknown producer declaration fields: ", paste(unknown, collapse = ", "), ".")
  )
  identity_ok <- identical(declaration$specification_kind, "canonical_producer") &&
    rrp_is_identifier(declaration$producer_id) &&
    rrp_is_semver(declaration$producer_version) &&
    identical(declaration$specification_id, declaration$producer_id) &&
    identical(declaration$specification_version, declaration$producer_version) &&
    identical(declaration$specification_format_version, "1.0.0")
  if (!identity_ok) issues[[length(issues) + 1L]] <- rrp_producer_issue(
    "producer.declaration.identity", "invalid_producer_identity",
    "Producer identity/version must match its specification envelope.", "$.producer_id"
  )
  selectable <- unlist(
    contract$producer_declaration$selectable_statuses, use.names = FALSE
  )
  if (!rrp_is_scalar_character(declaration$status) ||
      !declaration$status %in% c(selectable, "experimental", "deprecated", "retired")) {
    issues[[length(issues) + 1L]] <- rrp_producer_issue(
      "producer.declaration.lifecycle", "invalid_producer_lifecycle",
      "Producer lifecycle status is not recognized.", "$.status"
    )
  }
  if (!rrp_exact_identity(
    declaration$implementation_identity, "implementation_id", "implementation_version"
  )) issues[[length(issues) + 1L]] <- rrp_producer_issue(
    "producer.declaration.implementation", "invalid_implementation_identity",
    "Producer must declare an exact implementation ID and semantic version.",
    "$.implementation_identity"
  )
  if (!rrp_exact_identity(
    declaration$mapping_identity, "mapping_id", "mapping_version"
  )) issues[[length(issues) + 1L]] <- rrp_producer_issue(
    "producer.declaration.mapping", "invalid_mapping_identity",
    "Producer must declare an exact mapping ID and semantic version.",
    "$.mapping_identity"
  )
  profiles <- declaration$supported_canonical_profiles
  profiles_ok <- rrp_is_sequence(profiles) && length(profiles) > 0L &&
    all(vapply(profiles, function(profile) {
      rrp_is_named_mapping(profile) &&
        identical(profile$specification_kind, "canonical_profile") &&
        rrp_is_identifier(profile$specification_id) &&
        rrp_is_semver(profile$minimum_version) &&
        rrp_is_semver(profile$maximum_version) &&
        identical(profile$minimum_version, profile$maximum_version)
    }, logical(1)))
  if (!profiles_ok) issues[[length(issues) + 1L]] <- rrp_producer_issue(
    "producer.declaration.profiles", "invalid_supported_canonical_profiles",
    "Producer must declare at least one exact supported canonical profile.",
    "$.supported_canonical_profiles"
  )
  capabilities <- declaration$capabilities
  statuses <- c("available", "unavailable", "unsupported")
  capabilities_ok <- rrp_is_named_mapping(capabilities) && length(capabilities) > 0L &&
    all(vapply(names(capabilities), rrp_is_identifier, logical(1))) &&
    all(vapply(capabilities, function(value) {
      rrp_is_scalar_character(value) && value %in% statuses
    }, logical(1)))
  if (!capabilities_ok) issues[[length(issues) + 1L]] <- rrp_producer_issue(
    "producer.declaration.capabilities", "invalid_producer_capabilities",
    "Producer capabilities must explicitly declare available, unavailable, or unsupported.",
    "$.capabilities"
  )
  execution <- declaration$execution
  execution_ok <- rrp_is_named_mapping(execution) &&
    identical(
      execution$adapter_contract,
      contract$producer_declaration$adapter_contract
    ) && is.logical(execution$deterministic) &&
    length(execution$deterministic) == 1L && !is.na(execution$deterministic) &&
    identical(execution$simultaneous_execution, "unsupported")
  if (!execution_ok) issues[[length(issues) + 1L]] <- rrp_producer_issue(
    "producer.declaration.execution", "invalid_producer_execution_declaration",
    "Producer must declare the supported adapter, determinism, and single-producer execution.",
    "$.execution"
  )
  ownership <- declaration$configuration_ownership
  ownership_ok <- rrp_is_named_mapping(ownership) &&
    identical(ownership$owner, "producer_implementation") &&
    identical(ownership$secrets_in_declaration, "prohibited") &&
    identical(ownership$source_details_cross_canonical_boundary, "prohibited")
  if (!ownership_ok) issues[[length(issues) + 1L]] <- rrp_producer_issue(
    "producer.declaration.configuration", "invalid_configuration_ownership",
    "Source configuration and secrets must remain producer-owned and below the canonical boundary.",
    "$.configuration_ownership"
  )
  failure <- declaration$failure_behavior
  failure_ok <- rrp_is_named_mapping(failure) && all(vapply(
    c("partial_canonical_bundle", "continue_after_failed_stage", "fabricated_canonical_input"),
    function(name) identical(failure[[name]], "prohibited"), logical(1)
  ))
  if (!failure_ok) issues[[length(issues) + 1L]] <- rrp_producer_issue(
    "producer.declaration.failure", "invalid_producer_failure_behavior",
    "Producer failure behavior must prohibit partial output, continuation, and fabrication.",
    "$.failure_behavior"
  )
  rrp_producer_conformance(declaration, issues)
}

rrp_new_canonical_producer_registry <- function() {
  registry <- new.env(parent = emptyenv())
  registry$entries <- list()
  class(registry) <- c("rrp_canonical_producer_registry", "environment")
  registry
}

rrp_assert_canonical_producer_registry <- function(registry) {
  if (!inherits(registry, "rrp_canonical_producer_registry") || !is.environment(registry)) {
    stop("Producer registry must come from rrp_new_canonical_producer_registry().", call. = FALSE)
  }
}

rrp_canonical_producer_registry_key <- function(producer_id, producer_version) {
  paste(producer_id, producer_version, sep = "@")
}

rrp_register_canonical_producer <- function(registry, declaration, adapter, contract) {
  rrp_assert_canonical_producer_registry(registry)
  conformance <- rrp_validate_canonical_producer_declaration(declaration, contract)
  if (!rrp_conforms(conformance)) stop(
    "invalid_producer_declaration: declaration did not conform.", call. = FALSE
  )
  if (!is.function(adapter)) stop(
    "Producer adapter must be a trusted callable registered by code; declarations cannot execute code.",
    call. = FALSE
  )
  key <- rrp_canonical_producer_registry_key(
    declaration$producer_id, declaration$producer_version
  )
  if (!is.null(registry$entries[[key]])) stop(
    "duplicate_registered_producer: producer ID/version is already registered.",
    call. = FALSE
  )
  registry$entries[[key]] <- list(
    declaration = unserialize(serialize(declaration, NULL)), adapter = adapter
  )
  invisible(registry)
}

rrp_resolve_canonical_producer <- function(registry, producer_id, producer_version) {
  rrp_assert_canonical_producer_registry(registry)
  if (!rrp_is_identifier(producer_id) || !rrp_is_semver(producer_version)) stop(
    "Producer selection requires an exact valid ID and semantic version.", call. = FALSE
  )
  entry <- registry$entries[[rrp_canonical_producer_registry_key(
    producer_id, producer_version
  )]]
  if (is.null(entry)) stop(
    "unknown_registered_producer: exact producer ID/version is not registered.",
    call. = FALSE
  )
  entry
}

rrp_new_canonical_producer_adapter_result <- function(
  status,
  producer_execution_id,
  implementation_identity,
  mapping_identity,
  canonical_profile,
  canonical_as_of_time,
  capabilities,
  stage_statuses,
  conformance_results = list(),
  provenance_references = list(),
  candidate_bundle = NULL,
  summary = list()
) {
  list(
    status = status,
    producer_execution_id = producer_execution_id,
    implementation_identity = implementation_identity,
    mapping_identity = mapping_identity,
    canonical_profile = canonical_profile,
    canonical_as_of_time = canonical_as_of_time,
    capabilities = capabilities,
    stage_statuses = stage_statuses,
    conformance_results = conformance_results,
    provenance_references = provenance_references,
    candidate_bundle = candidate_bundle,
    summary = summary
  )
}

rrp_failed_canonical_producer_result <- function(
  declaration, execution_id, stages, conformance_results = list(),
  as_of_time = NA_character_, provenance_references = list(), summary = list(),
  failure_code = "producer_execution_failed"
) {
  structure(list(
    result_specification = rrp_canonical_producer_result_identity(),
    overall_status = "failed",
    producer_reference = list(
      producer_id = declaration$producer_id,
      producer_version = declaration$producer_version
    ),
    implementation_identity = declaration$implementation_identity,
    mapping_identity = declaration$mapping_identity,
    producer_execution_id = execution_id,
    canonical_profile = NULL,
    canonical_as_of_time = as_of_time,
    capabilities = declaration$capabilities,
    stage_statuses = stages,
    conformance_results = conformance_results,
    provenance_references = provenance_references,
    canonical_bundle = NULL,
    summary = summary,
    failure_code = failure_code
  ), class = "rrp_canonical_producer_result")
}

rrp_producer_profile_supported <- function(declaration, profile) {
  any(vapply(declaration$supported_canonical_profiles, function(supported) {
    identical(profile$specification_kind, supported$specification_kind) &&
      identical(profile$specification_id, supported$specification_id) &&
      identical(profile$specification_version, supported$minimum_version) &&
      identical(profile$specification_version, supported$maximum_version)
  }, logical(1)))
}

rrp_bundle_capabilities <- function(bundle) {
  values <- vapply(bundle$capabilities, `[[`, character(1), "status")
  names(values) <- vapply(bundle$capabilities, `[[`, character(1), "capability_id")
  as.list(values[order(names(values))])
}

rrp_ordered_capabilities <- function(capabilities) {
  capabilities[order(names(capabilities))]
}

rrp_validate_canonical_producer_adapter_result <- function(value, declaration) {
  issues <- list()
  if (!is.list(value)) return(rrp_producer_conformance(value, list(rrp_producer_issue(
    "producer.result.structure", "invalid_producer_adapter_result",
    "Trusted producer callable must return a structured adapter result."
  ))))
  stages <- c("producer_configuration", "source_local_validation", "mapping")
  statuses <- c("not_run", "succeeded", "failed")
  stage_ok <- is.character(value$stage_statuses) &&
    identical(names(value$stage_statuses), stages) &&
    all(value$stage_statuses %in% statuses)
  if (!stage_ok) issues[[length(issues) + 1L]] <- rrp_producer_issue(
    "producer.result.stages", "invalid_producer_stage_statuses",
    "Adapter result must report the ordered producer stages with controlled statuses.",
    "$.stage_statuses"
  )
  success <- identical(value$status, "succeeded")
  failure <- identical(value$status, "failed")
  if (!success && !failure) issues[[length(issues) + 1L]] <- rrp_producer_issue(
    "producer.result.status", "invalid_producer_result_status",
    "Adapter result status must be succeeded or failed.", "$.status"
  )
  if (!rrp_is_identifier(value$producer_execution_id)) issues[[length(issues) + 1L]] <- rrp_producer_issue(
    "producer.result.execution", "invalid_producer_execution_id",
    "Producer execution ID must be a stable non-patient identifier.",
    "$.producer_execution_id"
  )
  if (!identical(value$implementation_identity, declaration$implementation_identity) ||
      !identical(value$mapping_identity, declaration$mapping_identity)) {
    issues[[length(issues) + 1L]] <- rrp_producer_issue(
      "producer.result.identity", "producer_result_identity_mismatch",
      "Producer result implementation and mapping identities must match its declaration.",
      "$.implementation_identity"
    )
  }
  if (!identical(value$capabilities, declaration$capabilities)) issues[[length(issues) + 1L]] <- rrp_producer_issue(
    "producer.result.capabilities", "producer_result_capability_mismatch",
    "Producer result capabilities must match the trusted declaration.", "$.capabilities"
  )
  if (success && is.null(value$candidate_bundle)) issues[[length(issues) + 1L]] <- rrp_producer_issue(
    "producer.result.bundle", "missing_candidate_canonical_bundle",
    "A successful adapter result must supply one candidate canonical bundle.",
    "$.candidate_bundle"
  )
  if (failure && !is.null(value$candidate_bundle)) issues[[length(issues) + 1L]] <- rrp_producer_issue(
    "producer.result.bundle", "canonical_bundle_on_failed_production",
    "A failed adapter result must not expose a canonical bundle.",
    "$.candidate_bundle"
  )
  if (stage_ok) {
    failed_index <- which(value$stage_statuses == "failed")
    continued <- length(failed_index) > 0L && min(failed_index) < length(stages) &&
      any(value$stage_statuses[seq.int(
        min(failed_index) + 1L, length(stages)
      )] == "succeeded")
    if (continued) issues[[length(issues) + 1L]] <- rrp_producer_issue(
      "producer.result.short_circuit", "producer_stage_continued_after_failure",
      "No producer stage may succeed after an earlier failed stage.",
      "$.stage_statuses"
    )
    if (success && !all(value$stage_statuses == "succeeded")) {
      issues[[length(issues) + 1L]] <- rrp_producer_issue(
        "producer.result.success", "incomplete_successful_producer_stages",
        "Successful production requires every producer-owned stage to succeed.",
        "$.stage_statuses"
      )
    }
  }
  rrp_producer_conformance(value, issues)
}

rrp_producer_emit <- function(event_emitter, ...) {
  if (is.null(event_emitter)) return(invisible(NULL))
  rrp_emit_operational_event(event_emitter, ...)
}

rrp_execute_canonical_producer <- function(
  registry,
  producer_id,
  producer_version,
  invocation,
  repository_root,
  event_emitter = NULL
) {
  entry <- rrp_resolve_canonical_producer(registry, producer_id, producer_version)
  declaration <- entry$declaration
  execution_id <- invocation$producer_execution_id %||% paste0(
    "producer_", gsub("[^0-9A-Za-z]", "_", producer_id), "_001"
  )
  related <- list(
    producer_id = producer_id,
    producer_version = producer_version,
    implementation_id = declaration$implementation_identity$implementation_id,
    implementation_version = declaration$implementation_identity$implementation_version,
    mapping_id = declaration$mapping_identity$mapping_id,
    mapping_version = declaration$mapping_identity$mapping_version,
    producer_execution_id = execution_id
  )
  rrp_producer_emit(
    event_emitter, "source_implementation", "producer_resolution", "info",
    "stage_started", "producer.selection_started",
    "Configured canonical producer resolution started.",
    related_identities = related
  )
  rrp_producer_emit(
    event_emitter, "source_implementation", "producer_resolution", "info",
    "stage_completed", "producer.selection_resolved",
    "Configured canonical producer resolved through trusted registration.",
    related_identities = related, details = list(status = "succeeded")
  )
  rrp_producer_emit(
    event_emitter, "source_implementation", "producer_execution", "info",
    "stage_started", "producer.execution_started",
    "Canonical producer execution started.", related_identities = related
  )
  adapter_result <- tryCatch(
    entry$adapter(invocation),
    error = function(condition) structure(
      list(message = conditionMessage(condition)), class = "rrp_producer_adapter_error"
    )
  )
  if (inherits(adapter_result, "rrp_producer_adapter_error")) {
    stages <- c(
      producer_configuration = "failed", source_local_validation = "not_run",
      mapping = "not_run", canonical_admission = "not_run"
    )
    rrp_producer_emit(
      event_emitter, "source_implementation", "producer_execution", "error",
      "stage_completed", "producer.execution_failed",
      "Canonical producer execution failed before canonical admission.",
      related_identities = related,
      details = list(failure_category = "producer_execution_failure")
    )
    return(rrp_failed_canonical_producer_result(
      declaration, execution_id, stages,
      failure_code = "producer_adapter_execution_failed"
    ))
  }
  adapter_conformance <- rrp_validate_canonical_producer_adapter_result(
    adapter_result, declaration
  )
  if (!rrp_conforms(adapter_conformance) || !identical(adapter_result$status, "succeeded")) {
    owned_stages <- adapter_result$stage_statuses
    if (!is.character(owned_stages) || length(owned_stages) != 3L) owned_stages <- c(
      producer_configuration = "failed", source_local_validation = "not_run", mapping = "not_run"
    )
    stages <- c(owned_stages, canonical_admission = "not_run")
    rrp_producer_emit(
      event_emitter, "source_implementation", "producer_execution", "error",
      "stage_completed", "producer.execution_failed",
      "Canonical producer did not produce admissible candidate output.",
      related_identities = related,
      details = list(failure_category = "producer_result_failure")
    )
    return(rrp_failed_canonical_producer_result(
      declaration, execution_id, stages,
      c(adapter_result$conformance_results %||% list(), list(adapter_conformance)),
      adapter_result$canonical_as_of_time %||% NA_character_,
      adapter_result$provenance_references %||% list(),
      adapter_result$summary %||% list(), "producer_result_failed"
    ))
  }
  rrp_producer_emit(
    event_emitter, "source_implementation", "producer_execution", "info",
    "stage_completed", "producer.execution_completed",
    "Canonical producer completed its owned stages.",
    related_identities = related,
    details = list(
      episode_count = adapter_result$summary$discharge_episodes %||% 0L,
      status = "succeeded"
    )
  )
  bundle <- adapter_result$candidate_bundle
  rrp_producer_emit(
    event_emitter, "canonical_boundary", "canonical_admission", "info",
    "stage_started", "producer.canonical_admission_started",
    "Canonical admission of producer output started.",
    related_identities = related
  )
  metadata_ok <- rrp_producer_profile_supported(declaration, bundle$profile_specification) &&
    identical(bundle$implementation_identity, declaration$implementation_identity) &&
    identical(bundle$mapping_identity, declaration$mapping_identity) &&
    identical(bundle$run_context$as_of_time, adapter_result$canonical_as_of_time) &&
    identical(
      rrp_bundle_capabilities(bundle),
      rrp_ordered_capabilities(declaration$capabilities)
    )
  metadata_conformance <- rrp_producer_conformance(bundle, if (metadata_ok) list() else list(
    rrp_producer_issue(
      "producer.result.handoff", "producer_handoff_metadata_mismatch",
      "Candidate profile, as-of, identities, or capabilities disagree with the producer declaration/result.",
      "$.candidate_bundle"
    )
  ))
  admission <- if (metadata_ok) {
    rrp_validate_clinical_bundle_instance(bundle, repository_root, "canonical-producer")
  } else {
    rrp_producer_conformance(bundle, list(rrp_producer_issue(
      "producer.result.admission", "canonical_admission_not_attempted",
      "Canonical admission was not attempted because handoff metadata disagreed.",
      "$.candidate_bundle"
    )))
  }
  conformance <- c(
    adapter_result$conformance_results,
    list(adapter_result = adapter_conformance, handoff_metadata = metadata_conformance,
         canonical_admission = admission)
  )
  if (!metadata_ok || !rrp_conforms(admission)) {
    stages <- c(adapter_result$stage_statuses, canonical_admission = "failed")
    rrp_producer_emit(
      event_emitter, "canonical_boundary", "canonical_admission", "error",
      "stage_completed", "producer.canonical_admission_failed",
      "Producer output failed canonical admission.", related_identities = related,
      details = list(failure_category = "canonical_conformance_failure")
    )
    return(rrp_failed_canonical_producer_result(
      declaration, adapter_result$producer_execution_id, stages, conformance,
      adapter_result$canonical_as_of_time, adapter_result$provenance_references,
      adapter_result$summary, "canonical_admission_failed"
    ))
  }
  stages <- c(adapter_result$stage_statuses, canonical_admission = "succeeded")
  rrp_producer_emit(
    event_emitter, "canonical_boundary", "canonical_admission", "info",
    "stage_completed", "producer.canonical_admission_completed",
    "Producer output passed canonical admission.", related_identities = related,
    details = list(
      episode_count = adapter_result$summary$discharge_episodes %||% 0L,
      status = "succeeded"
    )
  )
  structure(list(
    result_specification = rrp_canonical_producer_result_identity(),
    overall_status = "succeeded",
    producer_reference = list(producer_id = producer_id, producer_version = producer_version),
    implementation_identity = declaration$implementation_identity,
    mapping_identity = declaration$mapping_identity,
    producer_execution_id = adapter_result$producer_execution_id,
    canonical_profile = bundle$profile_specification,
    canonical_as_of_time = adapter_result$canonical_as_of_time,
    capabilities = declaration$capabilities,
    stage_statuses = stages,
    conformance_results = conformance,
    provenance_references = adapter_result$provenance_references,
    canonical_bundle = bundle,
    summary = adapter_result$summary,
    failure_code = NULL
  ), class = "rrp_canonical_producer_result")
}

rrp_validate_canonical_producer_result <- function(result) {
  issues <- list()
  if (!inherits(result, "rrp_canonical_producer_result") ||
      !identical(result$result_specification, rrp_canonical_producer_result_identity())) {
    issues[[length(issues) + 1L]] <- rrp_producer_issue(
      "producer.result.contract", "invalid_canonical_producer_result",
      "Result must use platform.canonical-producer-result@0.1.0."
    )
    return(rrp_producer_conformance(result, issues))
  }
  success <- identical(result$overall_status, "succeeded")
  failure <- identical(result$overall_status, "failed")
  if (!success && !failure) issues[[length(issues) + 1L]] <- rrp_producer_issue(
    "producer.result.status", "invalid_canonical_producer_result_status",
    "Producer result status must be succeeded or failed.", "$.overall_status"
  )
  if (success && is.null(result$canonical_bundle)) issues[[length(issues) + 1L]] <- rrp_producer_issue(
    "producer.result.bundle", "missing_admitted_canonical_bundle",
    "Successful producer result requires an admitted canonical bundle.", "$.canonical_bundle"
  )
  if (failure && !is.null(result$canonical_bundle)) issues[[length(issues) + 1L]] <- rrp_producer_issue(
    "producer.result.bundle", "canonical_bundle_on_failed_result",
    "Failed producer result must contain no canonical bundle.", "$.canonical_bundle"
  )
  expected_stages <- c(
    "producer_configuration", "source_local_validation", "mapping", "canonical_admission"
  )
  if (!is.character(result$stage_statuses) ||
      !identical(names(result$stage_statuses), expected_stages) ||
      !all(result$stage_statuses %in% c("not_run", "succeeded", "failed"))) {
    issues[[length(issues) + 1L]] <- rrp_producer_issue(
      "producer.result.stages", "invalid_canonical_producer_result_stages",
      "Final result must report every ordered producer/admission stage.", "$.stage_statuses"
    )
  }
  rrp_producer_conformance(result, issues)
}

rrp_conform_registered_canonical_producer <- function(
  registry, producer_id, producer_version, invocation, repository_root
) {
  first <- rrp_execute_canonical_producer(
    registry, producer_id, producer_version, invocation, repository_root
  )
  issues <- list(rrp_validate_canonical_producer_result(first)$issues)
  entry <- rrp_resolve_canonical_producer(registry, producer_id, producer_version)
  if (!identical(first$overall_status, "succeeded")) issues[[length(issues) + 1L]] <- rrp_producer_issue(
    "producer.conformance.execution", "producer_conformance_execution_failed",
    "Producer must successfully reach canonical admission in its conformance scenario."
  )
  if (identical(entry$declaration$execution$deterministic, TRUE) &&
      identical(first$overall_status, "succeeded")) {
    second <- rrp_execute_canonical_producer(
      registry, producer_id, producer_version, invocation, repository_root
    )
    if (!identical(
      serialize(first$canonical_bundle, NULL), serialize(second$canonical_bundle, NULL)
    )) issues[[length(issues) + 1L]] <- rrp_producer_issue(
      "producer.conformance.determinism", "nondeterministic_producer_output",
      "Producer declared deterministic behavior but repeated output differed."
    )
  }
  rrp_producer_conformance(entry$declaration, issues)
}

print.rrp_canonical_producer_result <- function(x, ...) {
  cat("Canonical producer: ", x$overall_status, "\n", sep = "")
  cat("  producer: ", x$producer_reference$producer_id, "@",
      x$producer_reference$producer_version, "\n", sep = "")
  for (stage in names(x$stage_statuses)) cat(
    "  ", stage, ": ", x$stage_statuses[[stage]], "\n", sep = ""
  )
  invisible(x)
}
