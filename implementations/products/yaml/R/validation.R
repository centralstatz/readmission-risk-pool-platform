# Whole-set validation precedes every access instance. Integrity,
# compatibility, coherence, and freshness remain distinct claims.

rrp_validate_yaml_adapter_declarations <- function(contract, declaration) {
  issues <- list()
  supported_contract <- list(
    specification_kind = "product_materialization_contract",
    specification_id = "platform.product-materialization-adapter",
    specification_version = "0.1.0"
  )
  if (!identical(rrp_product_identity(contract), supported_contract)) {
    issues[[length(issues) + 1L]] <- rrp_yaml_bundle_issue(
      "compatibility", "unsupported_materialization_contract",
      "Reference adapter supports the platform materialization contract 0.1 line only.",
      "$.contract"
    )
  }
  if (!identical(declaration$specification_id, declaration$adapter_id) ||
      !identical(declaration$specification_version, declaration$adapter_version) ||
      !identical(declaration$adapter_id, "reference.yaml-product-bundle") ||
      !identical(declaration$adapter_version, "0.1.0")) {
    issues[[length(issues) + 1L]] <- rrp_yaml_bundle_issue(
      "compatibility", "unsupported_materialization_adapter",
      "Reference adapter declaration identity/version is unsupported.",
      "$.adapter"
    )
  }
  required_fields <- unlist(contract$required_adapter_fields, use.names = FALSE)
  missing <- setdiff(required_fields, names(declaration))
  for (field in missing) issues[[length(issues) + 1L]] <- rrp_yaml_bundle_issue(
    "compatibility", "missing_adapter_field",
    paste0("Adapter declaration is missing required field: ", field, "."),
    paste0("$.adapter.", field)
  )
  expected_contract <- rrp_product_identity(contract)
  if (!identical(declaration$contract_reference, expected_contract)) {
    issues[[length(issues) + 1L]] <- rrp_yaml_bundle_issue(
      "compatibility", "unsupported_materialization_contract",
      "Adapter declaration does not implement the supported materialization contract.",
      "$.adapter.contract_reference"
    )
  }
  capabilities <- unlist(contract$required_capabilities, use.names = TRUE)
  actual <- unlist(declaration$capabilities[names(capabilities)], use.names = TRUE)
  if (!identical(actual, capabilities)) issues[[length(issues) + 1L]] <-
    rrp_yaml_bundle_issue(
      "compatibility", "missing_materialization_capability",
      "Adapter declaration does not claim every required capability.",
      "$.adapter.capabilities"
    )
  required_methods <- unlist(contract$required_methods, use.names = FALSE)
  actual_methods <- unlist(declaration$methods, use.names = FALSE)
  if (!all(required_methods %in% actual_methods)) issues[[length(issues) + 1L]] <-
    rrp_yaml_bundle_issue(
      "compatibility", "missing_materialization_method",
      "Adapter declaration omits one or more required methods.",
      "$.adapter.methods"
    )
  if (!identical(
    declaration$format_reference[c("format_id", "format_version")],
    rrp_yaml_bundle_format_reference()
  )) issues[[length(issues) + 1L]] <- rrp_yaml_bundle_issue(
    "compatibility", "unsupported_bundle_format",
    "Adapter declares an unsupported physical bundle format.",
    "$.adapter.format_reference"
  )
  rrp_bind_yaml_bundle_issues(issues)
}

rrp_yaml_bundle_freshness <- function(manifest, pointer) {
  set <- manifest$product_set
  list(
    source_cutoff_time = set$source_cutoff_time,
    source_as_of_time = set$source_as_of_time,
    latest_source_runtime_run_id = set$latest_source_runtime_run_id,
    product_generated_at = set$product_generated_at,
    product_published_at = pointer$published_at,
    staleness_assessment = "not_evaluated_no_platform_threshold"
  )
}

rrp_validate_yaml_product_bundle <- function(
  store_path,
  materialization_contract,
  adapter_declaration,
  product_contracts,
  pointer_file = "CURRENT.yml"
) {
  issues <- list()
  store_path <- normalizePath(store_path, mustWork = FALSE)
  pointer_path <- file.path(store_path, pointer_file)
  if (!dir.exists(store_path) || rrp_yaml_bundle_is_symlink(store_path)) {
    issues[[1L]] <- rrp_yaml_bundle_issue(
      "integrity", "product_store_unavailable",
      "Product store does not exist or is a symbolic link.", "$", store_path
    )
    return(rrp_yaml_bundle_validation_result(
      issues, evaluated = "integrity"
    ))
  }
  if (!file.exists(pointer_path) || rrp_yaml_bundle_is_symlink(pointer_path)) {
    issues[[1L]] <- rrp_yaml_bundle_issue(
      "integrity", "current_pointer_unavailable",
      "Current pointer is missing or is a symbolic link.", "$.CURRENT"
    )
    return(rrp_yaml_bundle_validation_result(
      issues, evaluated = "integrity"
    ))
  }
  pointer <- tryCatch(rrp_yaml_bundle_read(pointer_path), error = function(value) value)
  if (inherits(pointer, "condition") || !is.list(pointer)) {
    issues[[1L]] <- rrp_yaml_bundle_issue(
      "integrity", "invalid_current_pointer",
      "CURRENT.yml is not readable YAML metadata.", "$.CURRENT"
    )
    return(rrp_yaml_bundle_validation_result(
      issues, evaluated = "integrity"
    ))
  }
  required_pointer <- c(
    "pointer_kind", "pointer_version", "adapter_reference", "format_reference",
    "materialization_id", "bundle_directory", "manifest_file",
    "manifest_checksum", "published_at"
  )
  if (!all(required_pointer %in% names(pointer)) ||
      !rrp_yaml_bundle_safe_relative_path(pointer$manifest_file) ||
      !rrp_yaml_bundle_scalar_string(pointer$bundle_directory) ||
      !grepl("^sets/bundle-[a-f0-9]{32}$", pointer$bundle_directory)) {
    issues[[1L]] <- rrp_yaml_bundle_issue(
      "integrity", "invalid_current_pointer_structure",
      "CURRENT.yml has missing or unsafe required fields.", "$.CURRENT"
    )
    return(rrp_yaml_bundle_validation_result(
      issues, evaluated = "integrity", pointer = pointer
    ))
  }
  bundle_path <- file.path(store_path, pointer$bundle_directory)
  manifest_path <- file.path(bundle_path, pointer$manifest_file)
  if (!dir.exists(bundle_path) || rrp_yaml_bundle_is_symlink(bundle_path) ||
      !file.exists(manifest_path) || rrp_yaml_bundle_is_symlink(manifest_path)) {
    issues[[1L]] <- rrp_yaml_bundle_issue(
      "integrity", "published_bundle_unavailable",
      "Current bundle directory or manifest is missing or symbolic-linked.",
      "$.CURRENT.bundle_directory"
    )
    return(rrp_yaml_bundle_validation_result(
      issues, evaluated = "integrity", pointer = pointer
    ))
  }
  manifest_checksum <- pointer$manifest_checksum
  if (!is.list(manifest_checksum) ||
      !identical(manifest_checksum$algorithm, "md5") ||
      !identical(manifest_checksum$value, rrp_yaml_bundle_checksum(manifest_path))) {
    issues[[1L]] <- rrp_yaml_bundle_issue(
      "integrity", "manifest_checksum_mismatch",
      "Product-set manifest checksum does not match CURRENT.yml.",
      "$.CURRENT.manifest_checksum"
    )
    return(rrp_yaml_bundle_validation_result(
      issues, evaluated = "integrity", pointer = pointer
    ))
  }
  manifest <- tryCatch(rrp_yaml_bundle_read(manifest_path), error = function(value) value)
  if (inherits(manifest, "condition") || !is.list(manifest)) {
    issues[[1L]] <- rrp_yaml_bundle_issue(
      "integrity", "invalid_product_set_manifest",
      "PRODUCT_SET.yml is not readable YAML metadata.", "$.manifest"
    )
    return(rrp_yaml_bundle_validation_result(
      issues, evaluated = "integrity", pointer = pointer
    ))
  }
  required_manifest <- c(
    "manifest_kind", "manifest_version", "materialization_id",
    "adapter_reference", "format_reference", "product_set", "members"
  )
  member_files <- rrp_yaml_bundle_member_files()
  declared_files <- if (is.list(manifest$members)) vapply(
    manifest$members,
    function(value) if (is.list(value) && rrp_yaml_bundle_scalar_string(value$file)) {
      value$file
    } else NA_character_,
    character(1)
  ) else character()
  exact_files <- sort(c("PRODUCT_SET.yml", unname(member_files)), method = "radix")
  actual_files <- sort(list.files(bundle_path, all.files = FALSE, no.. = TRUE),
    method = "radix"
  )
  manifest_structure_ok <- all(required_manifest %in% names(manifest)) &&
    identical(manifest$materialization_id, pointer$materialization_id) &&
    setequal(names(manifest$members), names(member_files)) &&
    identical(unname(declared_files[names(member_files)]), unname(member_files)) &&
    identical(actual_files, exact_files)
  if (!manifest_structure_ok) issues[[length(issues) + 1L]] <- rrp_yaml_bundle_issue(
    "integrity", "invalid_product_set_manifest_structure",
    "Manifest identity, members, or physical file inventory is incomplete or unexpected.",
    "$.manifest"
  )
  products <- list()
  if (manifest_structure_ok) for (name in names(member_files)) {
    member <- manifest$members[[name]]
    path <- file.path(bundle_path, member$file)
    checksum <- member$checksum
    if (!file.exists(path) || rrp_yaml_bundle_is_symlink(path) ||
        !is.list(checksum) || !identical(checksum$algorithm, "md5") ||
        !identical(checksum$value, rrp_yaml_bundle_checksum(path))) {
      issues[[length(issues) + 1L]] <- rrp_yaml_bundle_issue(
        "integrity", "product_member_checksum_mismatch",
        "A declared product member is missing, linked, or has the wrong checksum.",
        paste0("$.manifest.members.", name, ".checksum"), name
      )
    } else {
      value <- tryCatch(rrp_yaml_bundle_read(path), error = function(value) value)
      if (inherits(value, "condition") || !is.list(value)) {
        issues[[length(issues) + 1L]] <- rrp_yaml_bundle_issue(
          "integrity", "invalid_product_member_yaml",
          "A product member is not readable YAML.",
          paste0("$.manifest.members.", name), name
        )
      } else products[[name]] <- value
    }
  }
  integrity <- rrp_bind_yaml_bundle_issues(issues)
  if (any(integrity$category == "integrity")) return(
    rrp_yaml_bundle_validation_result(
      issues, evaluated = "integrity", pointer = pointer, manifest = manifest
    )
  )

  declaration_issues <- rrp_validate_yaml_adapter_declarations(
    materialization_contract,
    adapter_declaration
  )
  issues[[length(issues) + 1L]] <- declaration_issues
  supported_set <- adapter_declaration$supported_product_set
  if (!identical(manifest$adapter_reference, list(
    adapter_id = adapter_declaration$adapter_id,
    adapter_version = adapter_declaration$adapter_version
  )) || !identical(pointer$adapter_reference, manifest$adapter_reference) ||
      !identical(manifest$format_reference, rrp_yaml_bundle_format_reference()) ||
      !identical(pointer$format_reference, manifest$format_reference) ||
      !identical(manifest$product_set$product_set_specification, supported_set)) {
    issues[[length(issues) + 1L]] <- rrp_yaml_bundle_issue(
      "compatibility", "unsupported_materialization_identity",
      "Current bundle adapter, format, or product-set identity is unsupported.",
      "$.manifest"
    )
  }
  for (name in intersect(names(products), names(product_contracts)[-1L])) {
    member <- manifest$members[[name]]
    product <- products[[name]]
    if (!identical(member$product_specification, product$product_specification) ||
        !identical(member$product_instance_id, product$product_instance_id) ||
        !identical(as.integer(member$row_count), product$row_count)) {
      issues[[length(issues) + 1L]] <- rrp_yaml_bundle_issue(
        "compatibility", "product_manifest_metadata_mismatch",
        "A product member does not match its declared identity or row count.",
        paste0("$.manifest.members.", name), name
      )
    }
  }
  compatibility <- rrp_bind_yaml_bundle_issues(issues)
  if (any(compatibility$category == "compatibility")) return(
    rrp_yaml_bundle_validation_result(
      issues,
      evaluated = c("integrity", "compatibility"),
      pointer = pointer,
      manifest = manifest
    )
  )

  for (name in names(products)) {
    conformance <- rrp_validate_logical_product(
      products[[name]], product_contracts[[name]]
    )
    if (!rrp_product_conforms(conformance)) for (index in seq_len(nrow(
      conformance$issues
    ))) issues[[length(issues) + 1L]] <- rrp_yaml_bundle_issue(
      "coherence",
      conformance$issues$issue_code[[index]],
      conformance$issues$message[[index]],
      conformance$issues$object_path[[index]],
      name
    )
  }
  coherence <- rrp_validate_product_set_coherence(
    manifest$product_set,
    products,
    product_contracts$product_set
  )
  if (!rrp_product_conforms(coherence)) for (index in seq_len(nrow(
    coherence$issues
  ))) issues[[length(issues) + 1L]] <- rrp_yaml_bundle_issue(
    "coherence",
    coherence$issues$issue_code[[index]],
    coherence$issues$message[[index]],
    coherence$issues$object_path[[index]]
  )
  freshness <- rrp_yaml_bundle_freshness(manifest, pointer)
  if (!rrp_product_timestamp(pointer$published_at) ||
      rrp_product_time_number(pointer$published_at) <
        rrp_product_time_number(manifest$product_set$product_generated_at)) {
    issues[[length(issues) + 1L]] <- rrp_yaml_bundle_issue(
      "freshness", "invalid_publication_time",
      "Publication time must be valid and not precede product generation.",
      "$.CURRENT.published_at"
    )
  }
  rrp_yaml_bundle_validation_result(
    issues,
    freshness,
    pointer = pointer,
    manifest = manifest,
    products = products
  )
}
