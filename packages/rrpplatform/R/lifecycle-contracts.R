rrp_lifecycle_contract_header <- function(record_type, contract_id) c(
  "Record-Type" = record_type,
  "Contract-ID" = contract_id,
  "Contract-Version" = "0.1.0",
  "Format-Version" = "1.0.0",
  "Product-ID" = "readmission-risk-pool-platform",
  "Development-Version" = "1.0.0-dev",
  "Status" = "development_unpublished",
  "Owner-Package" = "rrpplatform"
)

rrp_distribution_manifest_contract_expected <- function() c(
  rrp_lifecycle_contract_header(
    "distribution-manifest-contract", "rrp.distribution-manifest"
  ),
  "Manifest-Record-Type" = "rrp-distribution",
  "Manifest-Fields" = paste(c(
    "Record-Type", "Contract-ID", "Contract-Version", "Product-ID",
    "Product-Version", "Development-Version", "Distribution-ID", "Build-ID",
    "Target-R-Version", "Target-Platform", "Target-Architecture",
    "Dependency-Specification-ID", "Resource-Catalog-ID", "Inventory-Digest",
    "Source-Revision", "Source-State", "Built-At"
  ), collapse = ","),
  "Product-Version-Role" = "immutable_published_or_declared_development_identity",
  "Distribution-ID-Role" = "normalized_rrp_owned_content_identity",
  "Build-ID-Role" = "build_occurrence_identity",
  "Published-Version-Official-Content" = "exactly_one",
  "Payload-Closure" = "rrp_owned_members_only",
  "Third-Party-Artifact-Closure" = "not_required",
  "Dependency-Authority" = "rrp.dependency-specification@0.1.0",
  "Inventory-Authority" = "positive_role_classified_allowlist",
  "Path-In-Distribution-ID" = "prohibited",
  "Time-In-Distribution-ID" = "prohibited",
  "Durable-History-Attribution" = "product_development_api_component_only",
  "Distribution-Build-Installation-History-Fields" = "prohibited",
  "Unknown-Fields" = "prohibited",
  "Additional-Records" = "prohibited"
)

rrp_dependency_specification_contract_expected <- function() c(
  rrp_lifecycle_contract_header(
    "dependency-specification-contract", "rrp.dependency-specification"
  ),
  "Specification-Record-Type" = "rrp-dependency-specification",
  "Header-Fields" = paste(c(
    "Record-Type", "Contract-ID", "Contract-Version", "Specification-ID",
    "Product-ID", "Product-Version", "Target-R-Version", "Target-Platform",
    "Target-Architecture", "Repository-Set-ID", "Package-Count"
  ), collapse = ","),
  "Package-Record-Type" = "rrp-dependency",
  "Package-Fields" = paste(c(
    "Package", "Version", "Source-Type", "Repository", "Integrity"
  ), collapse = ","),
  "Ordering" = "package_name_radix",
  "Package-Uniqueness" = "exact_name_once",
  "Repository-Mode" = "explicit_configured_repositories",
  "Private-Library" = "required_per_installed_version",
  "Ambient-User-Or-Site-Library" = "prohibited_as_satisfaction_source",
  "Bundled-Transitive-Artifacts" = "not_required",
  "Offline-Installation" = "not_required",
  "Restoration-Engine" = "internal_implementation_detail",
  "Project-Dependency-Machinery" = "prohibited",
  "Credential-Retention" = "prohibited",
  "Verification" = "package_version_source_integrity_and_private_path",
  "Unknown-Fields" = "prohibited",
  "Additional-Record-Types" = "prohibited"
)

rrp_installation_record_contract_expected <- function() c(
  rrp_lifecycle_contract_header(
    "installation-record-contract", "rrp.installation-record"
  ),
  "Installation-Record-Type" = "rrp-installation",
  "Fields" = paste(c(
    "Record-Type", "Contract-ID", "Contract-Version", "Installation-ID",
    "Product-ID", "Product-Version", "Development-Version", "Distribution-ID",
    "Build-ID", "Dependency-Specification-ID", "Host-R-Executable",
    "Host-R-Version", "Platform", "Architecture", "Private-Library",
    "Resource-Root", "Distribution-Manifest-Digest", "Installed-At"
  ), collapse = ","),
  "Installation-ID-Role" = "local_immutable_realization_identity",
  "Distribution-Compatibility" = "exact_distribution_identity",
  "Dependency-Compatibility" = "exact_specification_and_verified_realization",
  "Library-Posture" = "version_private_then_base_r_only",
  "Ambient-Library-Substitution" = "prohibited",
  "Project-Fields" = "prohibited",
  "Project-Discovery-Or-Association" = "prohibited",
  "Mutable-After-Promotion" = "prohibited",
  "Path-In-Installation-ID" = "prohibited",
  "Durable-History-Attribution" = "prohibited",
  "Unknown-Fields" = "prohibited",
  "Additional-Records" = "prohibited"
)

rrp_activation_record_contract_expected <- function() c(
  rrp_lifecycle_contract_header(
    "activation-record-contract", "rrp.activation-record"
  ),
  "Activation-Record-Type" = "rrp-activation",
  "Fields" = paste(c(
    "Record-Type", "Contract-ID", "Contract-Version", "Product-ID",
    "Product-Version", "Installation-ID", "Distribution-ID", "Activated-At"
  ), collapse = ","),
  "Selection-Cardinality" = "one_verified_installed_version",
  "Mutation" = "atomic_record_replacement",
  "Per-Invocation-Selector" = "verified_override_without_record_mutation",
  "Project-Fields" = "prohibited",
  "Project-Discovery-Or-Validation" = "prohibited",
  "Project-Association" = "prohibited",
  "Unknown-Fields" = "prohibited",
  "Additional-Records" = "prohibited"
)

rrp_installed_diagnosis_contract_expected <- function() c(
  rrp_lifecycle_contract_header(
    "installed-diagnosis-contract", "rrp.installed-diagnosis"
  ),
  "Operation-Result-Contract" = "rrp.contract.operation-result@0.1.0",
  "Operation-IDs" = "rrp.verify-installed-software,rrp.software-doctor",
  "Value-Fields" = paste(c(
    "software_status", "product_id", "product_version", "installation_id",
    "distribution_id", "host_r_status", "private_library_status",
    "resource_status", "launcher_status", "activation_status", "checks"
  ), collapse = ","),
  "Software-Status-Values" = "ready,ready_with_warnings,blocked",
  "Check-Fields" = "check_id,status,recovery_code",
  "Check-Status-Values" = "pass,warning,failure",
  "Recovery-Code-Pattern" = "^[a-z][a-z0-9_]*$",
  "Read-Only" = "required",
  "Temporary-Probes" = "removed_before_return",
  "Project-Input" = "prohibited",
  "Project-Discovery-Or-Association" = "prohibited",
  "Repair-Or-Activation" = "prohibited",
  "Privacy" = "bounded_software_identity_and_diagnostics_only",
  "Unknown-Fields" = "prohibited",
  "Additional-Records" = "prohibited"
)

rrp_project_lifecycle_result_contract_expected <- function() c(
  rrp_lifecycle_contract_header(
    "project-lifecycle-result-contract", "rrp.project-lifecycle-result"
  ),
  "Operation-Result-Contract" = "rrp.contract.operation-result@0.1.0",
  "Operation-ID" = "rrp.project-status",
  "Value-Fields" = paste(c(
    "project_id", "project_version", "project_contract_id",
    "project_contract_version", "supported_rrp_api_version",
    "canonical_profile_id", "canonical_profile_version", "producer_id",
    "producer_version", "provider_id", "provider_version", "readiness",
    "extension_library_status", "state_status", "history_status",
    "product_status", "product_freshness", "application_status",
    "product_set_id", "materialization_id", "source_operation_run_id",
    "source_history_cutoff", "checks"
  ), collapse = ","),
  "Readiness-Values" = "ready,ready_with_warnings,blocked",
  "Extension-Library-Status-Values" = "available,not_initialized",
  "State-Status-Values" = "compatible,not_initialized",
  "History-Status-Values" = "compatible,not_initialized",
  "Product-Status-Values" = "valid,absent",
  "Product-Freshness-Values" = "not_evaluated,fresh,stale,not_available",
  "Application-Status-Values" = "ready,blocked_expected",
  "Check-Fields" = "check_id,status,recovery_code",
  "Check-Status-Values" = "pass,warning,failure",
  "Recovery-Code-Pattern" = "^[a-z][a-z0-9_]*$",
  "Freshness-Context" = "both_operation_run_id_and_history_cutoff_or_neither",
  "Selected-Callable-Invocation" = "prohibited",
  "Source-Connectivity" = "not_exercised",
  "Mutation-Or-Repair" = "prohibited",
  "Latest-Analytical-Inference" = "prohibited",
  "Privacy" = "bounded_identity_and_lifecycle_metadata_only",
  "Unknown-Fields" = "prohibited",
  "Additional-Records" = "prohibited"
)

rrp_cli_result_json_contract_expected <- function() c(
  rrp_lifecycle_contract_header(
    "cli-result-json-contract", "rrp.cli-result-json"
  ),
  "Schema-ID" = "rrp.cli-result",
  "Schema-Version" = "1.0.0",
  "Top-Level-Fields" = "schema_version,operation_id,status,value,diagnostics",
  "Underlying-Result-Contract" = "rrp.contract.operation-result@0.1.0",
  "Default-Rendering" = "human",
  "Machine-Rendering" = "explicit_json_only",
  "Behavior-Path" = "same_underlying_operation_result",
  "Value-Fields" = "operation_specific_explicit_allowlist",
  "Internal-Object-Serialization" = "prohibited",
  "Privacy" = "deliberately_curated_safe_fields_only",
  "Diagnostic-Fields" = "code,severity,message",
  "Exit-Success" = "0",
  "Exit-Operation-Failure" = "1",
  "Exit-Usage" = "2",
  "Interrupted-Status" = "conventional_signal_status",
  "DCF-Or-Tabular-Public-Contract" = "prohibited",
  "Unknown-Fields" = "prohibited",
  "Additional-Records" = "prohibited"
)

rrp_lifecycle_contract_definitions <- function() list(
  distribution = list(
    resource_id = "rrp.contract.distribution-manifest",
    path = "resources/contracts/lifecycle/distribution-manifest.dcf",
    expected = rrp_distribution_manifest_contract_expected()
  ),
  dependencies = list(
    resource_id = "rrp.contract.dependency-specification",
    path = "resources/contracts/lifecycle/dependency-specification.dcf",
    expected = rrp_dependency_specification_contract_expected()
  ),
  installation = list(
    resource_id = "rrp.contract.installation-record",
    path = "resources/contracts/lifecycle/installation-record.dcf",
    expected = rrp_installation_record_contract_expected()
  ),
  activation = list(
    resource_id = "rrp.contract.activation-record",
    path = "resources/contracts/lifecycle/activation-record.dcf",
    expected = rrp_activation_record_contract_expected()
  ),
  installed_diagnosis = list(
    resource_id = "rrp.contract.installed-diagnosis",
    path = "resources/contracts/lifecycle/installed-diagnosis.dcf",
    expected = rrp_installed_diagnosis_contract_expected()
  ),
  project_lifecycle = list(
    resource_id = "rrp.contract.project-lifecycle-result",
    path = "resources/contracts/lifecycle/project-lifecycle-result.dcf",
    expected = rrp_project_lifecycle_result_contract_expected()
  ),
  cli_json = list(
    resource_id = "rrp.contract.cli-result-json",
    path = "resources/contracts/lifecycle/cli-result-json.dcf",
    expected = rrp_cli_result_json_contract_expected()
  )
)

rrp_lifecycle_contracts <- function(catalog) {
  definitions <- rrp_lifecycle_contract_definitions()
  lapply(definitions, function(definition) {
    rrp_project_contract_record(
      catalog, definition$resource_id, definition$expected,
      "lifecycle_contract"
    )
  })
}
