# Repository validation for the completed Phase 6 product/application boundary.

rrp_validate_product_repository <- function(repository_root) {
  repository_root <- normalizePath(repository_root, mustWork = TRUE)
  checks <- list()
  issues <- list()
  required_files <- c(
    "contracts/products/initial-risk-product-set.yml",
    "contracts/products/current-episode-risk.yml",
    "contracts/products/episode-risk-history.yml",
    "contracts/products/operational-run-summary.yml",
    "contracts/products/product-materialization-adapter.yml",
    "products/README.md",
    "products/R/foundation.R",
    "products/R/conformance.R",
    "products/R/builders.R",
    "products/R/access.R",
    "operations/lib/product-operation.R",
    "operations/lib/product-materialization-operation.R",
    "operations/build-reference-products.R",
    "operations/launch-reference-app.R",
    "implementations/products/yaml/adapter.yml",
    "implementations/products/yaml/R/foundation.R",
    "implementations/products/yaml/R/validation.R",
    "implementations/products/yaml/R/adapter.R",
    "implementations/products/yaml/R/access.R",
    "app/app.R",
    "app/R/app-init.R",
    "app/R/view-models.R",
    "app/R/app.R",
    "tests/phase6/test-logical-products.R",
    "tests/phase6/test-materialized-products-app.R",
    "tests/run-phase6-tests.R",
    "docs/architecture/logical-product-foundation.md",
    "docs/architecture/reference-product-materialization.md",
    "docs/architecture/reference-application.md",
    "docs/operations/logical-products.md"
  )
  missing <- required_files[!file.exists(file.path(repository_root, required_files))]
  for (path in missing) issues[[length(issues) + 1L]] <- rrp_issue(
    "product_required_files", "missing_product_file",
    "Required Phase 6 product/application file is missing.", path
  )
  checks[[length(checks) + 1L]] <- rrp_check(
    "product_required_files", length(missing) == 0L,
    paste(length(required_files), "required Phase 6 product/application files")
  )

  contracts <- tryCatch(
    rrp_read_product_contracts(repository_root),
    error = function(condition) condition
  )
  loaded <- !inherits(contracts, "condition")
  checks[[length(checks) + 1L]] <- rrp_check(
    "product_contract_documents", loaded,
    if (loaded) "four logical product contracts loaded" else {
      "logical product contracts could not be read"
    }
  )
  if (!loaded) issues[[length(issues) + 1L]] <- rrp_issue(
    "product_contract_documents", "product_contract_read_failed",
    conditionMessage(contracts), "contracts/products"
  ) else {
    paths <- rrp_product_contract_paths(repository_root)
    for (name in names(contracts)) {
      relative <- rrp_repository_relative_path(repository_root, paths[[name]])
      envelope <- rrp_validate_specification_envelope(contracts[[name]], relative)
      checks[[length(checks) + 1L]] <- rrp_check(
        paste0("product_specification:", name),
        rrp_conforms(envelope),
        paste0(contracts[[name]]$specification_id, "@",
          contracts[[name]]$specification_version
        )
      )
      for (index in seq_len(nrow(envelope$issues))) {
        issue <- envelope$issues[index, ]
        issues[[length(issues) + 1L]] <- rrp_issue(
          paste0("product_specification:", name),
          issue$issue_code,
          issue$message,
          relative
        )
      }
    }
    suite <- rrp_product_contracts_conformance(contracts)
    checks[[length(checks) + 1L]] <- rrp_check(
      "product_contract_suite", rrp_product_conforms(suite),
      "required core product identities and builder identity agree"
    )
    for (index in seq_len(nrow(suite$issues))) issues[[length(issues) + 1L]] <-
      rrp_issue(
        "product_contract_suite", suite$issues$issue_code[[index]],
        suite$issues$message[[index]], "contracts/products"
      )
  }

  materialization <- tryCatch(
    rrp_read_product_materialization_documents(repository_root),
    error = function(condition) condition
  )
  materialization_ok <- !inherits(materialization, "condition") &&
    nrow(rrp_validate_yaml_adapter_declarations(
      materialization$contract, materialization$adapter
    )) == 0L && all(vapply(materialization, function(document) {
      rrp_conforms(rrp_validate_specification_envelope(document))
    }, logical(1)))
  checks[[length(checks) + 1L]] <- rrp_check(
    "product_materialization_declaration", materialization_ok,
    "reference YAML adapter satisfies the materialization contract"
  )
  if (!materialization_ok) issues[[length(issues) + 1L]] <- rrp_issue(
    "product_materialization_declaration", "invalid_materialization_adapter",
    "Reference product materialization declarations are missing or incompatible.",
    "implementations/products/yaml/adapter.yml"
  )

  product_files <- list.files(
    file.path(repository_root, "products", "R"),
    pattern = "[.]R$",
    full.names = TRUE
  )
  product_text <- paste(unlist(lapply(product_files, rrp_read_text)), collapse = "\n")
  forbidden <- c("DBI::", "duckdb::", "dbGetQuery", "dbExecute", "shiny::")
  found <- forbidden[vapply(forbidden, grepl, logical(1), x = product_text, fixed = TRUE)]
  for (value in found) issues[[length(issues) + 1L]] <- rrp_issue(
    "product_backend_independence", "forbidden_product_dependency",
    paste0("Generic product code references a forbidden backend/app API: ", value, "."),
    "products/R"
  )
  checks[[length(checks) + 1L]] <- rrp_check(
    "product_backend_independence", length(found) == 0L,
    "generic products use logical history reads and base R only"
  )

  app_files <- list.files(
    file.path(repository_root, "app"), pattern = "[.]R$", recursive = TRUE,
    full.names = TRUE
  )
  app_text <- paste(unlist(lapply(app_files, rrp_read_text)), collapse = "\n")
  forbidden_app_apis <- c(
    "DBI::", "duckdb::", "rrpruntime::", "yaml::", "read_run_history(",
    "read_current_estimate(", "execute_provider(", "generate_source"
  )
  leaked <- forbidden_app_apis[vapply(
    forbidden_app_apis, grepl, logical(1), x = app_text, fixed = TRUE
  )]
  for (value in leaked) issues[[length(issues) + 1L]] <- rrp_issue(
    "application_product_only_boundary", "forbidden_app_dependency",
    paste0("Application references an upstream or physical API: ", value, "."),
    "app"
  )
  checks[[length(checks) + 1L]] <- rrp_check(
    "application_product_only_boundary", length(leaked) == 0L,
    "application depends only on injected logical product access and Shiny"
  )

  prohibited_directories <- "observability"
  premature <- prohibited_directories[dir.exists(file.path(
    repository_root,
    prohibited_directories
  ))]
  for (path in premature) issues[[length(issues) + 1L]] <- rrp_issue(
    "product_iteration_scope", "premature_post_phase6_content",
    "Deployment or observability content remains outside Phase 6.",
    path
  )
  checks[[length(checks) + 1L]] <- rrp_check(
    "product_iteration_scope", length(premature) == 0L,
    "no still-unauthorized observability implementation"
  )

  record_text <- paste(rrp_read_text(file.path(
    repository_root,
    "docs", "architecture", "platform-implementation-record.md"
  )), collapse = "\n")
  headings <- c(
    "### Iteration 6.1 — Logical product contracts and product-building boundary",
    "### Iteration 6.2 — Reference product materialization and minimal product-only application"
  )
  recorded <- all(vapply(headings, grepl, logical(1), x = record_text, fixed = TRUE))
  if (!recorded) issues[[length(issues) + 1L]] <- rrp_issue(
    "product_implementation_record", "missing_iteration_6_1_record",
    "Implementation record must contain the Iteration 6.1 and 6.2 entries.",
    "docs/architecture/platform-implementation-record.md"
  )
  checks[[length(checks) + 1L]] <- rrp_check(
    "product_implementation_record", recorded,
    "Iterations 6.1 and 6.2 implementation evidence are recorded"
  )

  lock_text <- paste(rrp_read_text(file.path(repository_root, "renv.lock")), collapse = "\n")
  shiny_locked <- grepl('"shiny"[[:space:]]*:', lock_text, perl = TRUE)
  if (!shiny_locked) issues[[length(issues) + 1L]] <- rrp_issue(
    "application_dependency", "missing_shiny_dependency",
    "renv.lock must record the app-owned Shiny dependency.", "renv.lock"
  )
  checks[[length(checks) + 1L]] <- rrp_check(
    "application_dependency", shiny_locked,
    "app-owned Shiny dependency is locked"
  )

  rrp_validation_result(
    "Logical product contract and boundary validation",
    rrp_bind_rows(checks, rrp_empty_checks),
    rrp_bind_rows(issues, rrp_empty_issues)
  )
}

rrp_validate_phase6_checkpoint <- function(repository_root) {
  result <- rrp_validate_product_repository(repository_root)
  structure(
    list(
      scope = "Completed Phase 6 product/materialization/application checkpoint",
      checks = result$checks,
      issues = result$issues,
      passed = result$passed
    ),
    class = "rrp_validation_result"
  )
}
