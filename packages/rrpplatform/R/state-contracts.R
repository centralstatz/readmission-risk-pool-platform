rrp_project_state_contract_expected <- function() {
  c(
    "Record-Type" = "contract",
    "Contract-ID" = "rrp.project-state",
    "Contract-Version" = "0.1.0",
    "Format-Version" = "1.0.0",
    "Product-ID" = "readmission-risk-pool-platform",
    "Development-Version" = "1.0.0-dev",
    "Status" = "development_unpublished",
    "Owner-Package" = "rrpplatform",
    "Metadata-Record-Type" = "rrp-project-state",
    "Metadata-File" = "state.dcf",
    "Database-File" = "history.duckdb",
    "Inventory" = "history.duckdb,state.dcf",
    "Fields" = paste(c(
      "Record-Type", "State-Contract-ID", "State-Contract-Version",
      "Format-Version", "Product-ID", "Development-Version", "State-ID",
      "Initializing-Package-ID", "Initializing-Package-Version", "Project-ID",
      "Initializing-Project-Version", "Supported-RRP-API-Version",
      "Project-API-ID", "Project-API-Version", "Target-ID", "Target-Version",
      "History-Scope-Contract-ID", "History-Scope-Contract-Version",
      "History-Disposition-Contract-ID", "History-Disposition-Contract-Version",
      "History-Action-Contract-ID", "History-Action-Contract-Version",
      "History-Port-Contract-ID", "History-Port-Contract-Version",
      "Logical-History-Format-Version", "Adapter-ID", "Adapter-Version",
      "Physical-Schema-Version", "Payload-Encoding-Version", "Created-At",
      "Inventory"
    ), collapse = ","),
    "State-ID-Pattern" = "^rrp[.]state[.][0-9a-f]{32}$",
    "State-ID-Generation" = "opaque_process_time_sequence_v1",
    "State-ID-Path-Derivation" = "prohibited",
    "Project-ID-Pattern" = "^[a-z][a-z0-9]*(?:[.-][a-z0-9]+)*$",
    "Initializing-Package-Version-Pattern" =
      "^[0-9]+[.][0-9]+[.][0-9]+(?:[.][0-9]+)?$",
    "Initializing-Project-Version-Pattern" = paste0(
      "^[0-9]+[.][0-9]+[.][0-9]+",
      "(?:-[0-9A-Za-z]+(?:[.-][0-9A-Za-z]+)*)?$"
    ),
    "Project-ID-Compatibility" = "exact_manifest_identity",
    "Initializing-Project-Version-Compatibility" = "provenance_only",
    "Initializing-Package-ID" = "rrpplatform",
    "Supported-RRP-API-Version" = "0.3.0",
    "Project-API-ID" = "rrp.project-api",
    "Project-API-Version" = "0.3.0",
    "Target-ID" = "rrp.risk-target.readmission-remaining-30-day",
    "Target-Version" = "0.1.0",
    "History-Scope-Contract-ID" = "rrp.history.operational-scope",
    "History-Scope-Contract-Version" = "0.1.0",
    "History-Disposition-Contract-ID" = "rrp.history.episode-disposition",
    "History-Disposition-Contract-Version" = "0.1.0",
    "History-Action-Contract-ID" = "rrp.history.action",
    "History-Action-Contract-Version" = "0.1.0",
    "History-Port-Contract-ID" = "rrp.history.port",
    "History-Port-Contract-Version" = "0.1.0",
    "Logical-History-Format-Version" = "0.1.0",
    "Timestamp-Representation" = "rfc3339_utc",
    "Unknown-Fields" = "prohibited",
    "Additional-Records" = "prohibited",
    "Linked-Or-Nonregular-Inventory" = "prohibited",
    "Automatic-Migration-Or-Repair" = "prohibited"
  )
}

rrp_duckdb_history_contract_expected <- function() {
  c(
    "Record-Type" = "contract",
    "Contract-ID" = "rrp.adapter.duckdb-history",
    "Contract-Version" = "0.1.0",
    "Format-Version" = "1.0.0",
    "Product-ID" = "readmission-risk-pool-platform",
    "Development-Version" = "1.0.0-dev",
    "Status" = "development_unpublished",
    "Owner-Package" = "rrpplatform",
    "Adapter-ID" = "rrp.adapter.duckdb-history",
    "Adapter-Version" = "0.1.0",
    "History-Port-Contract-ID" = "rrp.history.port",
    "History-Port-Contract-Version" = "0.1.0",
    "State-Contract-ID" = "rrp.project-state",
    "State-Contract-Version" = "0.1.0",
    "Physical-Schema-Version" = "0.1.0",
    "Payload-Encoding-Version" = "r-serialize-v3-xdr-hex-v1",
    "Payload-Representation" = "exact_logical_record",
    "Database-File" = "history.duckdb",
    "Tables" = paste(c(
      "rrp_state_metadata", "operational_scopes", "episode_dispositions",
      "history_actions"
    ), collapse = ","),
    "Metadata-Columns" = "metadata_key,state_id,project_id,payload_hex",
    "Scope-Columns" = paste(c(
      "operation_run_id", "operation_key", "target_id", "analytical_time",
      "created_at", "payload_hex"
    ), collapse = ","),
    "Disposition-Columns" = paste(c(
      "analytical_run_id", "operation_run_id", "episode_id", "target_id",
      "analytical_time", "terminal_time", "payload_hex"
    ), collapse = ","),
    "Action-Columns" = paste(c(
      "action_id", "target_kind", "target_id", "target_operation_run_id",
      "replacement_operation_run_id", "effective_time", "payload_hex"
    ), collapse = ","),
    "Write-Transactions" = "scope,disposition,action,restatement",
    "Read-Bounds" = "operation_scope_or_episode_target_relationship_closure",
    "Connection-Lifecycle" = "private_bounded_session",
    "Writer-Posture" = "one_controlled_local_writer",
    "Raw-Connection-Exposure" = "prohibited",
    "Physical-Validity-Logic" = "prohibited",
    "Automatic-Migration-Or-Repair" = "prohibited"
  )
}

rrp_state_contracts <- function(catalog) {
  list(
    state = rrp_project_contract_record(
      catalog, "rrp.contract.project-state",
      rrp_project_state_contract_expected(), "project_state_contract"
    ),
    adapter = rrp_project_contract_record(
      catalog, "rrp.contract.duckdb-history-adapter",
      rrp_duckdb_history_contract_expected(), "duckdb_history_contract"
    )
  )
}
