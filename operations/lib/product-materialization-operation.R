# Human-operation composition for the concrete YAML reference adapter.

rrp_read_product_materialization_documents <- function(repository_root) {
  paths <- list(
    contract = file.path(
      repository_root, "contracts", "products", "product-materialization-adapter.yml"
    ),
    adapter = file.path(
      repository_root, "implementations", "products", "yaml", "adapter.yml"
    )
  )
  values <- lapply(paths, function(path) {
    parsed <- rrp_parse_yaml_specification(path)
    if (!is.null(parsed$error)) stop(
      "Could not read product materialization document: ", parsed$error,
      call. = FALSE
    )
    parsed$document
  })
  names(values) <- names(paths)
  values
}

rrp_load_yaml_product_adapter <- function(repository_root) {
  directory <- file.path(
    repository_root, "implementations", "products", "yaml", "R"
  )
  for (file in c("foundation.R", "validation.R", "adapter.R")) {
    sys.source(file.path(directory, file), envir = parent.frame())
  }
  invisible(TRUE)
}

rrp_materialize_reference_products <- function(
  build_result,
  repository_root,
  store_path,
  published_at = rrp_yaml_bundle_now()
) {
  documents <- rrp_read_product_materialization_documents(repository_root)
  rrp_materialize_yaml_product_set(
    build_result,
    store_path,
    documents$contract,
    documents$adapter,
    rrp_read_product_contracts(repository_root),
    published_at
  )
}

rrp_open_reference_product_access <- function(repository_root, store_path) {
  documents <- rrp_read_product_materialization_documents(repository_root)
  rrp_open_yaml_product_access(
    store_path,
    documents$contract,
    documents$adapter,
    rrp_read_product_contracts(repository_root)
  )
}

rrp_load_reference_app <- function(repository_root) {
  for (file in c("app-init.R", "view-models.R", "app.R")) {
    sys.source(file.path(repository_root, "app", "R", file), envir = parent.frame())
  }
  invisible(TRUE)
}
