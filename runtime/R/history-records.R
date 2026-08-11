rrp_run_status_id <- function(runtime_run_id, status_sequence, run_status) {
  rrp_deterministic_id("run_status", runtime_run_id, status_sequence, run_status)
}

#' Construct an immutable operational run lifecycle record
#' @export
new_operational_run_status <- function(
  runtime_run_id,
  run_status,
  status_time,
  as_of_time,
  bundle_instance_id,
  canonical_run_id,
  implementation_reference,
  mapping_reference,
  contract,
  previous_run_status_record_id = NULL,
  status_summary = NULL,
  provenance_references = list()
) {
  sequence <- if (identical(run_status, "started")) 1L else 2L
  record <- list(
    run_status_record_id = rrp_run_status_id(runtime_run_id, sequence, run_status),
    run_status_specification = rrp_identity(
      contract$specification_kind, contract$specification_id,
      contract$specification_version
    ),
    runtime_run_id = runtime_run_id,
    status_sequence = sequence,
    previous_run_status_record_id = previous_run_status_record_id,
    run_status = run_status,
    status_time = status_time,
    as_of_time = as_of_time,
    bundle_instance_id = bundle_instance_id,
    canonical_run_id = canonical_run_id,
    implementation_reference = implementation_reference,
    mapping_reference = mapping_reference,
    status_summary = status_summary,
    provenance_references = provenance_references
  )
  rrp_assert_runtime_conforms(
    validate_operational_run_status(record, contract),
    "Operational run status"
  )
  structure(record, class = "rrp_operational_run_status")
}

#' Validate one operational run lifecycle record
#' @export
validate_operational_run_status <- function(record, contract) {
  target <- rrp_history_contract_identities()$operational_run_status
  issues <- list()
  if (!rrp_specification_matches(contract, target)) {
    return(rrp_runtime_result(target, list(rrp_runtime_issue(
      "history.run.contract", "unsupported_run_status_contract",
      "Operational run status contract identity/version is unsupported.",
      "$.contract"
    ))))
  }
  if (!is.list(record)) {
    return(rrp_runtime_result(target, list(rrp_runtime_issue(
      "history.run.structure", "invalid_run_status_record",
      "Operational run status must be a named record.", "$"
    ))))
  }
  required <- unlist(contract$required_fields, use.names = FALSE)
  missing <- required[!required %in% names(record)]
  if (length(missing) > 0L) issues[[length(issues) + 1L]] <- rrp_runtime_issue(
    "history.run.required", "missing_run_status_field",
    paste0("Run status fields are missing: ", paste(missing, collapse = ", "), "."), "$"
  )
  statuses <- names(contract$run_statuses)
  status_ok <- rrp_is_scalar_string(record$run_status) && record$run_status %in% statuses
  if (!status_ok) issues[[length(issues) + 1L]] <- rrp_runtime_issue(
    "history.run.status", "invalid_run_status", "Run status is not recognized.",
    "$.run_status"
  )
  started <- identical(record$run_status, "started")
  sequence_ok <- if (started) {
    identical(as.integer(record$status_sequence), 1L) &&
      is.null(record$previous_run_status_record_id) && is.null(record$status_summary)
  } else {
    identical(as.integer(record$status_sequence), 2L) &&
      rrp_is_scalar_string(record$previous_run_status_record_id)
  }
  if (!sequence_ok) issues[[length(issues) + 1L]] <- rrp_runtime_issue(
    "history.run.lifecycle", "invalid_run_status_transition",
    "Started is sequence 1 without predecessor/summary; terminal status is sequence 2 with predecessor.", "$"
  )
  identity_fields <- c(
    "runtime_run_id", "bundle_instance_id", "canonical_run_id"
  )
  identity_ok <- all(vapply(identity_fields, function(field) {
    rrp_is_scalar_string(record[[field]])
  }, logical(1))) && rrp_is_timestamp(record$status_time) &&
    rrp_is_timestamp(record$as_of_time) && is.list(record$implementation_reference) &&
    is.list(record$mapping_reference) && rrp_named_records(record$provenance_references)
  if (!identity_ok) issues[[length(issues) + 1L]] <- rrp_runtime_issue(
    "history.run.context", "invalid_run_context",
    "Run identity, timestamps, implementation, mapping, or provenance context is invalid.", "$"
  )
  if (all(c("runtime_run_id", "status_sequence", "run_status", "run_status_record_id") %in% names(record)) &&
      !identical(record$run_status_record_id, rrp_run_status_id(
        record$runtime_run_id, as.integer(record$status_sequence), record$run_status
      ))) issues[[length(issues) + 1L]] <- rrp_runtime_issue(
    "history.run.identity", "nondeterministic_run_status_identity",
    "Run status identity does not match its semantic components.",
    "$.run_status_record_id"
  )
  rrp_runtime_result(target, issues)
}

#' Construct an append-only operational-history invalidation
#' @export
new_history_invalidation <- function(
  target_record_family,
  target_record_id,
  target_runtime_run_id,
  invalidated_at,
  reason_code,
  reason,
  contract,
  replacement_runtime_run_id = NULL,
  provenance_references = list()
) {
  record <- list(
    invalidation_id = rrp_deterministic_id(
      "history_invalidation", target_record_family, target_record_id,
      target_runtime_run_id, invalidated_at, reason_code
    ),
    invalidation_specification = rrp_identity(
      contract$specification_kind, contract$specification_id,
      contract$specification_version
    ),
    target_record_family = target_record_family,
    target_record_id = target_record_id,
    target_runtime_run_id = target_runtime_run_id,
    invalidated_at = invalidated_at,
    reason_code = reason_code,
    reason = reason,
    replacement_runtime_run_id = replacement_runtime_run_id,
    provenance_references = provenance_references
  )
  rrp_assert_runtime_conforms(
    validate_history_invalidation(record, contract), "History invalidation"
  )
  structure(record, class = "rrp_history_invalidation")
}

#' Validate one operational-history invalidation
#' @export
validate_history_invalidation <- function(record, contract) {
  target <- rrp_history_contract_identities()$invalidation
  issues <- list()
  if (!rrp_specification_matches(contract, target)) {
    return(rrp_runtime_result(target, list(rrp_runtime_issue(
      "history.invalidation.contract", "unsupported_invalidation_contract",
      "Invalidation contract identity/version is unsupported.", "$.contract"
    ))))
  }
  if (!is.list(record)) return(rrp_runtime_result(target, list(rrp_runtime_issue(
    "history.invalidation.structure", "invalid_invalidation_record",
    "Invalidation must be a named record.", "$"
  ))))
  required <- unlist(contract$required_fields, use.names = FALSE)
  missing <- required[!required %in% names(record)]
  if (length(missing) > 0L) issues[[length(issues) + 1L]] <- rrp_runtime_issue(
    "history.invalidation.required", "missing_invalidation_field",
    paste0("Invalidation fields are missing: ", paste(missing, collapse = ", "), "."), "$"
  )
  families <- unlist(contract$target_record_families, use.names = FALSE)
  shape_ok <- rrp_is_scalar_string(record$invalidation_id) &&
    rrp_is_scalar_string(record$target_record_family) &&
    record$target_record_family %in% families &&
    rrp_is_scalar_string(record$target_record_id) &&
    rrp_is_scalar_string(record$target_runtime_run_id) &&
    rrp_is_timestamp(record$invalidated_at) &&
    rrp_is_scalar_string(record$reason_code) && rrp_is_scalar_string(record$reason) &&
    (is.null(record$replacement_runtime_run_id) ||
       rrp_is_scalar_string(record$replacement_runtime_run_id)) &&
    rrp_named_records(record$provenance_references)
  if (!shape_ok) issues[[length(issues) + 1L]] <- rrp_runtime_issue(
    "history.invalidation.fields", "invalid_invalidation_fields",
    "Invalidation target, reason, time, replacement, or provenance is invalid.", "$"
  )
  rrp_runtime_result(target, issues)
}

