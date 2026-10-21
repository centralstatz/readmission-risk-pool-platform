rrp_application_contract_expected <- function() c(
  "Record-Type" = "application-contract",
  "Contract-ID" = "rrp.application.supplied",
  "Contract-Version" = "0.1.0",
  "Format-Version" = "1.0.0",
  "Product-ID" = "readmission-risk-pool-platform",
  "Development-Version" = "1.0.0-dev",
  "Status" = "development_unpublished",
  "Owner-Package" = "rrpplatform",
  "Application-Class" = "shiny.appobj",
  "Launch-Operation" = "rrp_launch_app",
  "Product-Set-Contract" =
    "rrp.product-set.initial-readmission-risk@0.1.0",
  "Required-Product-Members" = paste(c(
    "rrp.product.current-remaining-risk@0.1.0",
    "rrp.product.remaining-risk-trajectory@0.1.0",
    "rrp.product.operational-scope-summary@0.1.0"
  ), collapse = ","),
  "Component-Foundation" = "shiny,bslib,plotly,reactable",
  "Portable-Application-Contract" = "rrp.application.portable@0.1.0",
  "Brand-Contract" = "rrp.project-brand@0.1.0",
  "Frontend-Asset-IDs" = "rrp.asset.supplied-application-css",
  "Product-Access" = "validated_detached_once_at_startup",
  "Presentation-Model" = "closed_detached",
  "Application-Model" = "closed_detached",
  "Network-Binding" = "loopback_only",
  "Analytical-Posture" = "read_only",
  "Analytical-Execution" = "prohibited",
  "State-Or-Product-Mutation" = "prohibited",
  "Unknown-Fields" = "prohibited",
  "Additional-Records" = "prohibited"
)

rrp_portable_application_contract_expected <- function() c(
  "Record-Type" = "portable-application-contract",
  "Contract-ID" = "rrp.application.portable",
  "Contract-Version" = "0.1.0",
  "Format-Version" = "1.0.0",
  "Product-ID" = "readmission-risk-pool-platform",
  "Development-Version" = "1.0.0-dev",
  "Status" = "development_unpublished",
  "Owner-Package" = "rrpplatform",
  "Supplied-Application" = "rrp.application.supplied@0.1.0",
  "Operation-Result-Contract" = "rrp.operation-result@0.1.0",
  "Source-Members" = paste(c(
    "rrp.application.portable-core", "rrp.application.portable-products",
    "rrp.application.portable-ui", "rrp.application.portable-server",
    "rrp.asset.supplied-application-css"
  ), collapse = ","),
  "Source-Load-Order" = paste(c(
    "rrp.application.portable-core", "rrp.application.portable-products",
    "rrp.application.portable-ui", "rrp.application.portable-server"
  ), collapse = ","),
  "Installed-Host-Adapter" = "project_product_access_and_bounded_branding_only",
  "Standalone-Host-Adapter" = "relative_managed_set_and_frozen_presentation_only",
  "Product-Set-Contract" = "rrp.product-set.initial-readmission-risk@0.1.0",
  "Product-Representation" = "frozen_dcf_csv",
  "Product-Declaration-File" = "products.dcf",
  "Product-Inventory-File" = "inventory.dcf",
  "Product-Member-Files" = paste(c(
    "current-remaining-risk.csv", "remaining-risk-trajectory.csv",
    "operational-scope-summary.csv"
  ), collapse = ","),
  "Product-Declaration-Fields" = paste(c(
    "Record-Type", "Portable-Application-Contract-ID",
    "Portable-Application-Contract-Version", "Product-Set-Contract-ID",
    "Product-Set-Contract-Version", "Product-Set-ID", "Materialization-ID",
    "Source-Operation-Run-ID", "Source-Analytical-Time",
    "Source-History-Cutoff", "Source-History-Fingerprint",
    "Current-Remaining-Risk-Product-Contract-ID",
    "Current-Remaining-Risk-Product-Contract-Version",
    "Current-Remaining-Risk-Product-Instance-ID",
    "Current-Remaining-Risk-Row-Count", "Current-Remaining-Risk-File",
    "Remaining-Risk-Trajectory-Product-Contract-ID",
    "Remaining-Risk-Trajectory-Product-Contract-Version",
    "Remaining-Risk-Trajectory-Product-Instance-ID",
    "Remaining-Risk-Trajectory-Row-Count",
    "Remaining-Risk-Trajectory-File",
    "Operational-Scope-Summary-Product-Contract-ID",
    "Operational-Scope-Summary-Product-Contract-Version",
    "Operational-Scope-Summary-Product-Instance-ID",
    "Operational-Scope-Summary-Row-Count",
    "Operational-Scope-Summary-File"
  ), collapse = ","),
  "Presentation-Contract" = "rrp.application-presentation@0.1.0",
  "Presentation-Fields" = paste(c(
    "Record-Type", "Presentation-Contract-ID", "Presentation-Contract-Version",
    "Brand-Contract-ID", "Brand-Contract-Version", "Source", "Display-Name",
    "Primary-Color", "Logo-File", "Logo-Media-Type", "Logo-Alt"
  ), collapse = ","),
  "Presentation-Logo" = "optional_contained_png_or_jpeg",
  "Initial-Provenance-Contract" = "rrp.application-initialization@0.1.0",
  "Initial-Provenance-Fields" = paste(c(
    "Record-Type", "Contract-ID", "Contract-Version", "Software-Product-ID",
    "Software-Version", "Distribution-ID", "Package-Version",
    "Resource-Catalog-ID", "Resource-Catalog-Version",
    "Portable-Application-Contract-ID",
    "Portable-Application-Contract-Version", "Application-Baseline-ID",
    "Dependency-Identity", "Initial-Product-Set-ID",
    "Initial-Materialization-ID", "Source-Operation-Run-ID",
    "Source-Analytical-Time", "Source-History-Cutoff",
    "Source-History-Fingerprint", "Presentation-SHA256",
    "Source-Inventory-SHA256", "Managed-Inventory-SHA256"
  ), collapse = ","),
  "Initial-Provenance-Mutability" = "immutable_after_create",
  "Application-Baseline-Algorithm" =
    "sha256_over_length_delimited_authority_and_inventory_evidence",
  "Managed-Root" = "rrp-data",
  "Managed-Content-Contract" = "rrp.application-managed-content@0.1.0",
  "Managed-Content-Roles" = "product_declaration,product_member",
  "Managed-Inventory-Fields" = "Record-Type,Path,Role,Byte-Size,SHA256",
  "Managed-Digest-Algorithm" = "sha256",
  "Managed-Inventory-Closure" = "exact",
  "Managed-Relative-Paths" = "safe_nonempty_forward_slash",
  "Managed-Absolute-Or-Traversal-Paths" = "prohibited",
  "Managed-Links-Or-Nonregular-Files" = "prohibited",
  "Managed-Unexpected-Files" = "prohibited",
  "Hospital-Source-Under-Managed-Root" = "prohibited",
  "Standalone-Direct-Dependencies" = "shiny,bslib,plotly,reactable",
  "Standalone-Forbidden-Dependencies" =
    "rrpplatform,rrpruntime,readmit,brand.yml,DBI,duckdb",
  "Standalone-Lock-Format" = "renv-lock-json",
  "Standalone-Lock-Version" = "1",
  "Standalone-Lock-Package-Fields" =
    "Package,Version,Source,Repository,Requirements,Hash",
  "Standalone-Lock-Exact-Versions" = "required",
  "Standalone-Lock-Auto-Activation" = "prohibited",
  "Standalone-Private-RRP-Library" = "prohibited",
  "Analytical-Execution" = "prohibited",
  "Project-State-Or-History-Access" = "prohibited",
  "Product-Mutation" = "prohibited",
  "Unknown-Fields" = "prohibited",
  "Additional-Records" = "prohibited"
)

rrp_brand_contract_expected <- function() c(
  "Record-Type" = "brand-interpretation-contract",
  "Contract-ID" = "rrp.project-brand",
  "Contract-Version" = "0.1.0",
  "Format-Version" = "1.0.0",
  "Product-ID" = "readmission-risk-pool-platform",
  "Development-Version" = "1.0.0-dev",
  "Status" = "development_unpublished",
  "Owner-Package" = "rrpplatform",
  "Brand-Path" = "_brand.yml",
  "Parser-Package" = "brand.yml",
  "Parser-Function" = "read_brand_yml",
  "Supported-Concepts" = "meta.name,color.primary,logo,logo.medium",
  "Default-Display-Name" = "Readmission Risk Pool",
  "Default-Primary-Color" = "#1F4E79",
  "Logo-Role" = "application_header_identity",
  "Logo-Path" = "safe_project_relative_regular_nonlinked",
  "Logo-Formats" = "png,jpeg",
  "Logo-Max-Bytes" = "2097152",
  "Remote-Or-Absolute-Logo" = "prohibited",
  "Unsupported-Valid-Concepts" = "ignored",
  "Malformed-Or-Unsafe-Supported-Input" = "startup_failure",
  "Presentation-Only" = "required",
  "Analytical-Influence" = "prohibited",
  "Raw-Brand-Retention" = "prohibited",
  "Unknown-Fields" = "prohibited",
  "Additional-Records" = "prohibited"
)

rrp_application_contracts <- function(catalog) list(
  application = rrp_project_contract_record(
    catalog, "rrp.contract.supplied-application",
    rrp_application_contract_expected(), "supplied_application_contract"
  ),
  brand = rrp_project_contract_record(
    catalog, "rrp.contract.project-brand",
    rrp_brand_contract_expected(), "project_brand_contract"
  ),
  portable = rrp_project_contract_record(
    catalog, "rrp.contract.portable-application",
    rrp_portable_application_contract_expected(),
    "portable_application_contract"
  )
)
