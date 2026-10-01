rrp_product_current_fields <- function() c(
  "product_row_id", "episode_id", "target_id", "target_version",
  "analytical_time", "estimate_value", "estimate_record_id",
  "analytical_run_id", "source_operation_run_id", "state_id", "request_id",
  "provider_id", "provider_version", "implementation_id",
  "implementation_version", "model_id", "model_version",
  "target_interval_start", "target_interval_end", "target_interval_boundary"
)

rrp_product_trajectory_fields <- function() c(
  rrp_product_current_fields(), "analytical_kind", "related_analytical_run_id"
)

rrp_product_summary_fields <- function() c(
  "product_row_id", "operation_run_id", "scope_record_id", "state_id",
  "project_id", "project_version", "bundle_instance_id",
  "canonical_profile_id", "canonical_profile_version", "producer_id",
  "producer_version", "producer_implementation_id",
  "producer_implementation_version", "mapping_id", "mapping_version",
  "target_id", "target_version", "analytical_time", "scope_created_at",
  "expected_episode_count", "initial_disposition_count",
  "effective_disposition_count", "eligible_count", "accepted_estimate_count",
  "provider_incompatible_count", "provider_declared_failure_count",
  "detected_failure_count", "ineligible_count",
  "episode_before_discharge_count", "target_horizon_exhausted_count",
  "episode_already_readmitted_count", "episode_already_dead_count",
  "membership_fingerprint", "complete"
)

rrp_product_set_fields <- function() c(
  "product_set_contract_id", "product_set_contract_version", "product_set_id",
  "builder_id", "builder_version", "product_id", "development_version",
  "rrp_api_version", "project_id", "project_version", "state_id",
  "source_scope_contract_id", "source_scope_contract_version",
  "source_disposition_contract_id", "source_disposition_contract_version",
  "source_action_contract_id", "source_action_contract_version",
  "source_history_port_contract_id", "source_history_port_contract_version",
  "logical_history_format_version", "source_operation_run_id",
  "source_scope_record_id", "bundle_contract_id", "bundle_contract_version",
  "bundle_instance_id", "canonical_profile_id", "canonical_profile_version",
  "producer_id", "producer_version", "producer_implementation_id",
  "producer_implementation_version", "mapping_id", "mapping_version",
  "target_id", "target_version", "source_analytical_time",
  "source_history_cutoff", "source_history_fingerprint",
  "source_history_fingerprint_algorithm", "member_references", "members"
)

rrp_product_contract_header <- function(type, id) c(
  "Record-Type" = type,
  "Contract-ID" = id,
  "Contract-Version" = "0.1.0",
  "Format-Version" = "1.0.0",
  "Product-ID" = "readmission-risk-pool-platform",
  "Development-Version" = "1.0.0-dev",
  "Status" = "development_unpublished",
  "Owner-Package" = "rrpplatform"
)

rrp_product_contracts_expected <- function() {
  privacy <- paste(c(
    "patient_id", "encounter_id", "native_id", "crosswalk", "predictor",
    "source_path", "credential", "connection", "raw_record", "model_artifact"
  ), collapse = ",")
  current_characters <- setdiff(rrp_product_current_fields(), "estimate_value")
  trajectory_characters <- setdiff(rrp_product_trajectory_fields(), "estimate_value")
  summary_integers <- c(
    "expected_episode_count", "initial_disposition_count",
    "effective_disposition_count", "eligible_count", "accepted_estimate_count",
    "provider_incompatible_count", "provider_declared_failure_count",
    "detected_failure_count", "ineligible_count",
    "episode_before_discharge_count", "target_horizon_exhausted_count",
    "episode_already_readmitted_count", "episode_already_dead_count"
  )
  summary_characters <- setdiff(
    rrp_product_summary_fields(), c(summary_integers, "complete")
  )
  common <- function(id, key, fields, characters, doubles, integers, logicals,
                     nullable, timestamps, grain, ordering, empty, inputs) c(
    rrp_product_contract_header("product-contract", id),
    "Object-Class" = "rrp_logical_product,list",
    "Member-Key" = key,
    "Data-Class" = "data.frame",
    "Row-Fields" = paste(fields, collapse = ","),
    "Character-Fields" = if (length(characters)) paste(characters, collapse = ",") else "none",
    "Double-Fields" = if (length(doubles)) paste(doubles, collapse = ",") else "none",
    "Integer-Fields" = if (length(integers)) paste(integers, collapse = ",") else "none",
    "Logical-Fields" = if (length(logicals)) paste(logicals, collapse = ",") else "none",
    "Nullable-Fields" = if (length(nullable)) paste(nullable, collapse = ",") else "none",
    "Timestamp-Fields" = paste(timestamps, collapse = ","),
    "Grain" = grain,
    "Ordering" = ordering,
    "Empty-Rows" = empty,
    "Row-ID-Prefix" = "rrp.product-row.",
    "Row-ID-Algorithm" = "dual_modular_hash_v1",
    "Row-ID-Inputs" = paste(inputs, collapse = ",")
  )
  current <- c(common(
    "rrp.product.current-remaining-risk", "current_remaining_risk",
    rrp_product_current_fields(), current_characters, "estimate_value",
    character(), character(), c("model_id", "model_version"),
    c("analytical_time", "target_interval_start", "target_interval_end"),
    "at_most_one_effective_accepted_estimate_per_episode_target_at_source_analytical_time",
    "episode_id,target_id,target_version", "allowed",
    c("product_contract_id", "product_contract_version", "product_set_id",
      "episode_id", "target_id", "target_version")
  ), "Privacy-Prohibited" = privacy, "Unknown-Fields" = "prohibited",
  "Additional-Records" = "prohibited", "Executable-Content" = "prohibited")
  trajectory <- c(common(
    "rrp.product.remaining-risk-trajectory", "remaining_risk_trajectory",
    rrp_product_trajectory_fields(), trajectory_characters, "estimate_value",
    character(), character(), c("model_id", "model_version", "related_analytical_run_id"),
    c("analytical_time", "target_interval_start", "target_interval_end"),
    "one_effective_actual_accepted_estimate_per_episode_analytical_time",
    "episode_id,analytical_time,analytical_run_id", "allowed",
    c("product_contract_id", "product_contract_version", "product_set_id",
      "analytical_run_id")
  ), "Actual-Observations-Only" = "required",
  "Interpolation-Or-Replay" = "prohibited", "Privacy-Prohibited" = privacy,
  "Unknown-Fields" = "prohibited", "Additional-Records" = "prohibited",
  "Executable-Content" = "prohibited")
  summary <- c(common(
    "rrp.product.operational-scope-summary", "operational_scope_summary",
    rrp_product_summary_fields(), summary_characters, character(),
    summary_integers, "complete", character(),
    c("analytical_time", "scope_created_at"),
    "exactly_one_effective_complete_operational_scope", "one_row", "prohibited",
    c("product_contract_id", "product_contract_version", "product_set_id",
      "scope_record_id")
  ), "Count-Reconciliation" =
    "effective_disposition_count_equals_membership_and_outcome_counts_sum_to_membership",
  "Privacy-Prohibited" = privacy, "Unknown-Fields" = "prohibited",
  "Additional-Records" = "prohibited", "Executable-Content" = "prohibited")
  set <- c(
    rrp_product_contract_header(
      "product-set-contract", "rrp.product-set.initial-readmission-risk"
    ),
    "Object-Class" = "rrp_logical_product_set,list",
    "Builder-ID" = "rrp.product-builder.initial-readmission-risk",
    "Builder-Version" = "0.1.0",
    "Set-Fields" = paste(rrp_product_set_fields(), collapse = ","),
    "Member-Keys" = paste(c(
      "current_remaining_risk", "remaining_risk_trajectory",
      "operational_scope_summary"
    ), collapse = ","),
    "Member-Contracts" = paste(c(
      "rrp.product.current-remaining-risk@0.1.0",
      "rrp.product.remaining-risk-trajectory@0.1.0",
      "rrp.product.operational-scope-summary@0.1.0"
    ), collapse = ","),
    "Member-Fields" = paste(c(
      "product_contract_id", "product_contract_version", "product_instance_id",
      "product_set_id", "row_count", "data"
    ), collapse = ","),
    "All-Required" = "true", "Partial-Success" = "prohibited",
    "Set-ID-Prefix" = "rrp.product-set.",
    "Set-ID-Algorithm" = "dual_modular_hash_v1",
    "Set-ID-Encoding" = "length_delimited_utf8_v1",
    "Set-ID-Inputs" = paste(c(
      "product_set_contract", "builder", "member_contracts", "project_id",
      "state_id", "source_operation_run_id", "source_scope_record_id",
      "source_analytical_time", "source_history_cutoff", "target_id",
      "target_version", "source_history_fingerprint"
    ), collapse = ","),
    "Product-Instance-ID-Prefix" = "rrp.product.",
    "Product-Instance-ID-Algorithm" = "dual_modular_hash_v1",
    "Product-Instance-ID-Inputs" =
      "product_contract_id,product_contract_version,product_set_id",
    "Source-Fingerprint-Prefix" = "rrp.source-history.",
    "Source-Fingerprint-Algorithm" = "dual_modular_hash_v1",
    "Source-Fingerprint-Encoding" =
      "effective_governed_facts_length_delimited_utf8_v1",
    "Source-Fingerprint-Excludes" =
      "history_cutoff,paths,physical_files,materialization_time,git_state,database_order",
    "Source-Selection" = "explicit_operation_run_id_and_history_cutoff",
    "Source-Coherence" = "repeated_bounded_logical_read_equality",
    "Detached-Plain-Value" = "required", "Physical-Storage" = "prohibited",
    "Unknown-Fields" = "prohibited", "Additional-Records" = "prohibited",
    "Executable-Content" = "prohibited"
  )
  list(current = current, trajectory = trajectory, summary = summary, set = set)
}

rrp_product_contracts <- function(catalog) {
  expected <- rrp_product_contracts_expected()
  ids <- c(
    current = "rrp.product.current-remaining-risk",
    trajectory = "rrp.product.remaining-risk-trajectory",
    summary = "rrp.product.operational-scope-summary",
    set = "rrp.contract.product-set-initial-readmission-risk"
  )
  Map(function(id, document, label) {
    rrp_project_contract_record(catalog, id, document, label)
  }, ids, expected, paste0(names(ids), "_product_contract"))
}
