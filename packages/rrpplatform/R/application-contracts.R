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
  )
)
