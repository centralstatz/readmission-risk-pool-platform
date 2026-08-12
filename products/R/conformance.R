# Product conformance is intentionally independent of builder ownership. It
# collects all detectable issues so malformed consumer interfaces are not
# accepted merely because repository code produced them.

rrp_product_field_type_ok <- function(value, type) {
  switch(type,
    string = rrp_product_scalar_string(value),
    semantic_version = rrp_product_semver(value),
    timestamp = rrp_product_timestamp(value),
    probability = is.numeric(value) && length(value) == 1L &&
      is.finite(value) && value >= 0 && value <= 1,
    nonnegative_integer = is.numeric(value) && length(value) == 1L &&
      is.finite(value) && value == as.integer(value) && value >= 0,
    model_reference_or_null = is.null(value) || (
      is.list(value) && rrp_product_scalar_string(value$model_id) &&
        rrp_product_semver(value$model_version)
    ),
    implementation_reference = is.list(value) &&
      rrp_product_scalar_string(value$implementation_id) &&
      rrp_product_semver(value$implementation_version),
    mapping_reference = is.list(value) &&
      rrp_product_scalar_string(value$mapping_id) &&
      rrp_product_semver(value$mapping_version),
    provenance_references = is.list(value) && all(vapply(value, function(item) {
      is.list(item) && rrp_product_scalar_string(item$provenance_type) &&
        rrp_product_scalar_string(item$provenance_id) &&
        rrp_product_scalar_string(item$relationship)
    }, logical(1))),
    provider_references = is.list(value) && all(vapply(value, function(item) {
      is.list(item) && rrp_product_scalar_string(item$provider_id) &&
        rrp_product_semver(item$provider_version)
    }, logical(1))),
    specification_references = is.list(value) && all(vapply(value, function(item) {
      is.list(item) && rrp_product_scalar_string(item$specification_kind) &&
        rrp_product_scalar_string(item$specification_id) &&
        rrp_product_semver(item$specification_version)
    }, logical(1))),
    FALSE
  )
}

rrp_validate_product_row <- function(
  row,
  row_index,
  product,
  contract,
  source_index = NULL
) {
  product_id <- contract$specification_id
  path <- paste0("$.rows[", row_index, "]")
  issues <- list()
  if (!is.list(row) || is.null(names(row))) return(list(rrp_product_issue(
    "product.row.structure",
    "invalid_product_row",
    "A product row must be a named record.",
    path,
    product_id
  )))
  required <- names(Filter(function(field) identical(field$required, TRUE), contract$fields))
  missing <- setdiff(required, names(row))
  for (field in missing) issues[[length(issues) + 1L]] <- rrp_product_issue(
    "product.row.required",
    "missing_product_field",
    paste0("Required product field is missing: ", field, "."),
    paste0(path, ".", field),
    product_id
  )
  unknown <- setdiff(names(row), names(contract$fields))
  for (field in unknown) issues[[length(issues) + 1L]] <- rrp_product_issue(
    "product.row.fields",
    "unknown_product_field",
    paste0("Product row contains an undeclared field: ", field, "."),
    paste0(path, ".", field),
    product_id
  )
  for (field in intersect(names(row), names(contract$fields))) {
    declaration <- contract$fields[[field]]
    if (!rrp_product_field_type_ok(row[[field]], declaration$type)) {
      issues[[length(issues) + 1L]] <- rrp_product_issue(
        "product.row.type",
        "invalid_product_field_type",
        paste0("Product field `", field, "` does not match type `", declaration$type, "`."),
        paste0(path, ".", field),
        product_id
      )
    }
    accepted <- unlist(declaration$accepted_values, use.names = FALSE)
    if (length(accepted) > 0L && rrp_product_scalar_string(row[[field]]) &&
        !row[[field]] %in% accepted) {
      issues[[length(issues) + 1L]] <- rrp_product_issue(
        "product.row.vocabulary",
        "unsupported_product_field_value",
        paste0("Product field `", field, "` has an unsupported value."),
        paste0(path, ".", field),
        product_id
      )
    }
  }
  if (!is.null(source_index)) {
    references <- c(
      source_runtime_run_id = "runtime_run_ids",
      state_id = "state_ids",
      estimate_id = "estimate_ids"
    )
    for (field in intersect(names(references), names(row))) {
      if (!row[[field]] %in% source_index[[references[[field]]]]) {
        issues[[length(issues) + 1L]] <- rrp_product_issue(
          "product.row.upstream_reference",
          "unknown_upstream_reference",
          paste0("Product field `", field, "` does not reference selected valid history."),
          paste0(path, ".", field),
          product_id
        )
      }
    }
  }
  issues
}

rrp_validate_logical_product <- function(product, contract, source_index = NULL) {
  target <- rrp_product_identity(contract)
  product_id <- contract$specification_id
  issues <- list()
  required_metadata <- c(
    "product_instance_id", "product_specification", "product_set_id",
    "availability_status", "source_cutoff_time", "source_as_of_time",
    "latest_source_runtime_run_id", "source_runtime_run_ids",
    "product_generated_at", "row_count", "rows", "provenance_references"
  )
  if (!is.list(product) || is.null(names(product))) return(
    rrp_product_conformance_result(target, list(rrp_product_issue(
      "product.structure", "invalid_product", "Logical product must be a named record.",
      "$", product_id
    )))
  )
  missing <- setdiff(required_metadata, names(product))
  for (field in missing) issues[[length(issues) + 1L]] <- rrp_product_issue(
    "product.metadata.required",
    "missing_product_metadata",
    paste0("Required product metadata is missing: ", field, "."),
    paste0("$.", field),
    product_id
  )
  metadata_ok <- identical(product$product_specification, target) &&
    rrp_product_scalar_string(product$product_set_id) &&
    identical(product$availability_status, "available") &&
    rrp_product_timestamp(product$source_cutoff_time) &&
    rrp_product_timestamp(product$source_as_of_time) &&
    rrp_product_scalar_string(product$latest_source_runtime_run_id) &&
    is.character(product$source_runtime_run_ids) &&
    length(product$source_runtime_run_ids) > 0L &&
    identical(product$source_runtime_run_ids, sort(unique(product$source_runtime_run_ids))) &&
    product$latest_source_runtime_run_id %in% product$source_runtime_run_ids &&
    rrp_product_timestamp(product$product_generated_at) &&
    rrp_product_time_number(product$source_as_of_time) <=
      rrp_product_time_number(product$source_cutoff_time) &&
    rrp_product_time_number(product$source_as_of_time) <=
      rrp_product_time_number(product$product_generated_at)
  if (!metadata_ok) issues[[length(issues) + 1L]] <- rrp_product_issue(
    "product.metadata.freshness",
    "invalid_product_freshness",
    "Product identity, availability, source references, or freshness metadata is invalid.",
    "$",
    product_id
  )
  if (rrp_product_scalar_string(product$product_set_id) &&
      !identical(product$product_instance_id, rrp_product_instance_id(
        contract,
        product$product_set_id
      ))) issues[[length(issues) + 1L]] <- rrp_product_issue(
    "product.identity",
    "nondeterministic_product_identity",
    "Product instance identity does not match specification and product set.",
    "$.product_instance_id",
    product_id
  )
  if (!is.list(product$rows)) {
    issues[[length(issues) + 1L]] <- rrp_product_issue(
      "product.rows", "invalid_product_rows", "Product rows must be a record collection.",
      "$.rows", product_id
    )
  } else {
    for (index in seq_along(product$rows)) issues <- c(
      issues,
      rrp_validate_product_row(product$rows[[index]], index, product, contract, source_index)
    )
    if (!is.numeric(product$row_count) || length(product$row_count) != 1L ||
        as.integer(product$row_count) != length(product$rows)) {
      issues[[length(issues) + 1L]] <- rrp_product_issue(
        "product.rows", "product_row_count_mismatch",
        "Product row_count must equal the number of rows.", "$.row_count", product_id
      )
    }
    keys <- unlist(contract$row_identity, use.names = FALSE)
    if (length(product$rows) > 0L && all(vapply(product$rows, function(row) {
      all(c("product_row_id", keys) %in% names(row))
    }, logical(1)))) {
      key_values <- vapply(product$rows, function(row) {
        rrp_product_deterministic_id("key", unlist(row[keys], use.names = FALSE))
      }, character(1))
      if (anyDuplicated(key_values)) issues[[length(issues) + 1L]] <- rrp_product_issue(
        "product.grain", "duplicate_product_row_key",
        "Product rows violate the declared grain and row identity.", "$.rows", product_id
      )
      expected_ids <- vapply(product$rows, function(row) {
        rrp_product_row_id(contract, product$product_set_id, unlist(row[keys], use.names = FALSE))
      }, character(1))
      actual_ids <- vapply(product$rows, `[[`, character(1), "product_row_id")
      if (!identical(actual_ids, expected_ids) || anyDuplicated(actual_ids)) {
        issues[[length(issues) + 1L]] <- rrp_product_issue(
          "product.identity", "invalid_product_row_identity",
          "Product row identities must be deterministic and unique.", "$.rows", product_id
        )
      }
      ordering <- unlist(contract$ordering, use.names = FALSE)
      if (length(ordering) > 0L && all(vapply(product$rows, function(row) {
        all(ordering %in% names(row))
      }, logical(1)))) {
        columns <- lapply(ordering, function(field) {
          type <- contract$fields[[field]]$type
          if (identical(type, "timestamp")) vapply(
            product$rows,
            function(row) rrp_product_time_number(row[[field]]),
            numeric(1)
          ) else vapply(
            product$rows,
            function(row) as.character(row[[field]]),
            character(1)
          )
        })
        expected_order <- do.call(order, c(columns, list(method = "radix")))
        if (!identical(expected_order, seq_along(product$rows))) {
          issues[[length(issues) + 1L]] <- rrp_product_issue(
            "product.ordering", "nondeterministic_product_order",
            "Product rows do not follow the contract ordering.", "$.rows", product_id
          )
        }
      }
    }
  }
  rrp_product_conformance_result(target, issues)
}

rrp_validate_product_set_coherence <- function(product_set, products, contract) {
  target <- rrp_product_identity(contract)
  issues <- list()
  required <- contract$required_products
  if (!is.list(product_set) || !is.list(products)) return(
    rrp_product_conformance_result(target, list(rrp_product_issue(
      "product_set.structure", "invalid_product_set",
      "Product set metadata and products must be named records."
    )))
  )
  required_metadata <- c(
    "product_set_id", "product_build_id", "product_set_specification",
    "builder_reference", "product_specifications", "source_runtime_run_ids",
    "source_cutoff_time", "source_as_of_time", "latest_source_runtime_run_id",
    "product_generated_at", "provenance_references", "build_status"
  )
  missing <- setdiff(required_metadata, names(product_set))
  for (field in missing) issues[[length(issues) + 1L]] <- rrp_product_issue(
    "product_set.metadata", "missing_product_set_metadata",
    paste0("Required product-set metadata is missing: ", field, "."),
    paste0("$.", field)
  )
  source_ids_ok <- is.character(product_set$source_runtime_run_ids) &&
    length(product_set$source_runtime_run_ids) > 0L &&
    identical(
      product_set$source_runtime_run_ids,
      sort(unique(product_set$source_runtime_run_ids), method = "radix")
    )
  freshness_ok <- rrp_product_timestamp(product_set$source_cutoff_time) &&
    rrp_product_timestamp(product_set$source_as_of_time) &&
    rrp_product_timestamp(product_set$product_generated_at) &&
    rrp_product_time_number(product_set$source_as_of_time) <=
      rrp_product_time_number(product_set$source_cutoff_time) &&
    rrp_product_time_number(product_set$source_as_of_time) <=
      rrp_product_time_number(product_set$product_generated_at) &&
    rrp_product_scalar_string(product_set$latest_source_runtime_run_id) &&
    product_set$latest_source_runtime_run_id %in% product_set$source_runtime_run_ids
  if (!source_ids_ok || !freshness_ok) issues[[length(issues) + 1L]] <-
    rrp_product_issue(
      "product_set.freshness", "invalid_product_set_freshness",
      "Product-set source scope or freshness metadata is invalid.", "$"
    )
  identity_ok <- identical(product_set$product_set_specification, target) &&
    identical(product_set$builder_reference, list(
      builder_id = contract$builder$builder_id,
      builder_version = contract$builder$builder_version
    ))
  if (!identity_ok) issues[[length(issues) + 1L]] <- rrp_product_issue(
    "product_set.identity", "invalid_product_set_contract_identity",
    "Product-set specification or builder identity is unsupported.", "$"
  )
  if (source_ids_ok && rrp_product_timestamp(product_set$source_cutoff_time)) {
    member_keys <- unlist(lapply(required, rrp_product_reference_key), use.names = FALSE)
    expected_set_id <- rrp_product_deterministic_id(
      "product_set",
      rrp_product_reference_key(target),
      contract$builder$builder_id,
      contract$builder$builder_version,
      product_set$source_cutoff_time,
      product_set$source_runtime_run_ids,
      member_keys
    )
    expected_build_id <- rrp_product_deterministic_id(
      "product_build",
      expected_set_id,
      contract$builder$builder_id,
      contract$builder$builder_version
    )
    if (!identical(product_set$product_set_id, expected_set_id) ||
        !identical(product_set$product_build_id, expected_build_id)) {
      issues[[length(issues) + 1L]] <- rrp_product_issue(
        "product_set.identity", "nondeterministic_product_set_identity",
        "Product-set and build IDs do not match their semantic inputs.", "$"
      )
    }
  }
  if (!setequal(names(products), names(required))) issues[[length(issues) + 1L]] <-
    rrp_product_issue(
      "product_set.members", "incomplete_core_product_set",
      "The product set must contain exactly the declared core products.", "$.products"
    )
  expected_references <- lapply(required, function(value) value)
  if (!identical(product_set$product_specifications, expected_references)) {
    issues[[length(issues) + 1L]] <- rrp_product_issue(
      "product_set.members", "product_set_specification_mismatch",
      "Product-set specification references do not match the declared core set.",
      "$.product_specifications"
    )
  }
  common <- c(
    "product_set_id", "source_cutoff_time", "source_as_of_time",
    "latest_source_runtime_run_id", "source_runtime_run_ids", "product_generated_at"
  )
  for (name in intersect(names(products), names(required))) {
    product <- products[[name]]
    reference <- required[[name]]
    if (!identical(product$product_specification, reference)) issues[[length(issues) + 1L]] <-
      rrp_product_issue(
        "product_set.members", "incorrect_product_specification",
        paste0("Product member `", name, "` has the wrong specification."),
        paste0("$.products.", name), reference$specification_id
      )
    if (!all(vapply(common, function(field) identical(
      product[[field]],
      product_set[[field]]
    ), logical(1)))) issues[[length(issues) + 1L]] <- rrp_product_issue(
      "product_set.coherence", "mixed_product_set_metadata",
      paste0("Product member `", name, "` does not share coherent set metadata."),
      paste0("$.products.", name), reference$specification_id
    )
  }
  if (!identical(product_set$build_status, "succeeded")) issues[[length(issues) + 1L]] <-
    rrp_product_issue(
      "product_set.status", "invalid_product_set_status",
      "A consumable product set must have succeeded build status.", "$.build_status"
    )
  rrp_product_conformance_result(target, issues)
}
