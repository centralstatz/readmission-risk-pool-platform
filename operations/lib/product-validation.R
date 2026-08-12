# Repository validation for the Iteration 6.1 logical product boundary.

rrp_validate_product_repository <- function(repository_root) {
  repository_root <- normalizePath(repository_root, mustWork = TRUE)
  checks <- list()
  issues <- list()
  required_files <- c(
    "contracts/products/initial-risk-product-set.yml",
    "contracts/products/current-episode-risk.yml",
    "contracts/products/episode-risk-history.yml",
    "contracts/products/operational-run-summary.yml",
    "products/README.md",
    "products/R/foundation.R",
    "products/R/conformance.R",
    "products/R/builders.R",
    "products/R/access.R",
    "operations/lib/product-operation.R",
    "operations/build-reference-products.R",
    "tests/phase6/test-logical-products.R",
    "tests/run-phase6-tests.R",
    "docs/architecture/logical-product-foundation.md",
    "docs/operations/logical-products.md"
  )
  missing <- required_files[!file.exists(file.path(repository_root, required_files))]
  for (path in missing) issues[[length(issues) + 1L]] <- rrp_issue(
    "product_required_files", "missing_product_file",
    "Required Iteration 6.1 logical product file is missing.", path
  )
  checks[[length(checks) + 1L]] <- rrp_check(
    "product_required_files", length(missing) == 0L,
    paste(length(required_files), "required logical product files")
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

  prohibited_directories <- c("app", "deploy", "observability")
  premature <- prohibited_directories[dir.exists(file.path(
    repository_root,
    prohibited_directories
  ))]
  for (path in premature) issues[[length(issues) + 1L]] <- rrp_issue(
    "product_iteration_scope", "premature_iteration_6_1_content",
    "Application, deployment, or observability content is outside Iteration 6.1.",
    path
  )
  checks[[length(checks) + 1L]] <- rrp_check(
    "product_iteration_scope", length(premature) == 0L,
    "no application, deployment, or observability implementation"
  )

  record_text <- paste(rrp_read_text(file.path(
    repository_root,
    "docs", "architecture", "platform-implementation-record.md"
  )), collapse = "\n")
  heading <- "### Iteration 6.1 — Logical product contracts and product-building boundary"
  recorded <- grepl(heading, record_text, fixed = TRUE)
  if (!recorded) issues[[length(issues) + 1L]] <- rrp_issue(
    "product_implementation_record", "missing_iteration_6_1_record",
    "Implementation record must contain the Iteration 6.1 entry.",
    "docs/architecture/platform-implementation-record.md"
  )
  checks[[length(checks) + 1L]] <- rrp_check(
    "product_implementation_record", recorded,
    "Iteration 6.1 implementation evidence is recorded"
  )

  rrp_validation_result(
    "Logical product contract and boundary validation",
    rrp_bind_rows(checks, rrp_empty_checks),
    rrp_bind_rows(issues, rrp_empty_issues)
  )
}
