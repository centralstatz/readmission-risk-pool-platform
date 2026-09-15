rrp_software_resource_empty_issues <- function() {
  data.frame(
    code = character(),
    path = character(),
    message = character(),
    stringsAsFactors = FALSE
  )
}

rrp_software_resource_issue <- function(code, path, message) {
  data.frame(
    code = as.character(code),
    path = as.character(path),
    message = as.character(message),
    stringsAsFactors = FALSE
  )
}

rrp_software_resource_result <- function(issues = rrp_software_resource_empty_issues()) {
  rownames(issues) <- NULL
  list(passed = nrow(issues) == 0L, issues = issues)
}

rrp_software_resource_add_issue <- function(issues, code, path, message) {
  rbind(issues, rrp_software_resource_issue(code, path, message))
}

rrp_software_resource_scalar_string <- function(value) {
  is.character(value) && length(value) == 1L && !is.na(value) && nzchar(value)
}

rrp_software_resource_named_record <- function(value) {
  is.list(value) && !is.null(names(value)) &&
    length(value) == length(names(value)) &&
    all(nzchar(names(value))) && !anyDuplicated(names(value))
}

rrp_software_resource_values <- function(value) {
  if (is.null(value)) return(character())
  unname(unlist(value, use.names = FALSE))
}

rrp_software_resource_check_fields <- function(
  value, required, allowed, path, issues
) {
  if (!rrp_software_resource_named_record(value)) {
    return(rrp_software_resource_add_issue(
      issues, "invalid_structure", path, "Expected a named record."
    ))
  }
  missing <- setdiff(required, names(value))
  unknown <- setdiff(names(value), allowed)
  for (field in missing) issues <- rrp_software_resource_add_issue(
    issues, "missing_required_field", paste0(path, ".", field),
    paste0("Required field is missing: ", field, ".")
  )
  for (field in unknown) issues <- rrp_software_resource_add_issue(
    issues, "unknown_field", paste0(path, ".", field),
    paste0("Field is not allowed by the closed schema: ", field, ".")
  )
  issues
}

rrp_software_resource_safe_path <- function(path) {
  if (!rrp_software_resource_scalar_string(path)) return(FALSE)
  if (grepl("\\\\", path) || grepl("^/", path) || grepl("^[A-Za-z]:", path) ||
      startsWith(path, "~") || grepl("//", path, fixed = TRUE) ||
      endsWith(path, "/")) return(FALSE)
  segments <- strsplit(path, "/", fixed = TRUE)[[1L]]
  length(segments) > 0L && all(nzchar(segments)) &&
    !any(segments %in% c(".", ".."))
}

rrp_software_resource_has_link <- function(root, path) {
  current <- root
  for (segment in strsplit(path, "/", fixed = TRUE)[[1L]]) {
    current <- file.path(current, segment)
    if (nzchar(Sys.readlink(current))) return(TRUE)
  }
  FALSE
}

rrp_software_resource_is_contained <- function(root, path) {
  root <- normalizePath(root, winslash = "/", mustWork = TRUE)
  candidate <- normalizePath(
    file.path(root, path), winslash = "/", mustWork = TRUE
  )
  startsWith(candidate, paste0(root, "/"))
}

rrp_software_resource_files <- function(repository_root, relative_root) {
  absolute_root <- file.path(repository_root, relative_root)
  if (!dir.exists(absolute_root)) return(character())
  files <- list.files(
    absolute_root, recursive = TRUE, full.names = TRUE,
    all.files = TRUE, no.. = TRUE
  )
  files <- files[file.info(files)$isdir %in% FALSE]
  root <- paste0(normalizePath(repository_root, winslash = "/"), "/")
  sort(substring(normalizePath(files, winslash = "/"), nchar(root) + 1L))
}

rrp_expected_installed_resource_sources <- function(repository_root) {
  contract_roots <- c(
    "contracts/foundation",
    "contracts/canonical/domains",
    "contracts/canonical/profiles",
    "contracts/canonical/vocabularies",
    "contracts/runtime",
    "contracts/persistence",
    "contracts/products",
    "contracts/observability"
  )
  contract_files <- unlist(lapply(
    contract_roots,
    function(root) rrp_software_resource_files(repository_root, root)
  ), use.names = FALSE)
  exact_files <- c(
    "contracts/canonical/canonical-bundle.yml",
    "contracts/canonical/canonical-producer.yml",
    "contracts/deployment/application-artifact.yml",
    "implementations/persistence/duckdb/adapter.yml",
    "implementations/products/yaml/adapter.yml",
    "app/application.yml",
    "deploy/application-artifact/runtime-dependencies.yml",
    "implementations/synthetic-reference/README.md",
    "implementations/synthetic-reference/config/reference.yml",
    "implementations/synthetic-reference/config/test.yml",
    "implementations/synthetic-reference/implementation.yml",
    "implementations/synthetic-reference/producer.yml",
    "implementations/synthetic-reference/source-schema.yml",
    "README.md",
    "docs/vision/platform-true-north.md",
    "docs/architecture/platform-architecture.md",
    "contracts/README.md",
    "distribution/software/README.md",
    "LICENSE",
    "NOTICE",
    "SECURITY.md",
    "SUPPORT.md"
  )
  sort(unique(c(contract_files, exact_files)))
}

rrp_expected_resource_exclusion_ids <- function() {
  c(
    "rrp.exclusion.connect-target",
    "rrp.exclusion.repository-configuration",
    "rrp.exclusion.tests-and-fixtures",
    "rrp.exclusion.validation-and-ci",
    "rrp.exclusion.architecture-development",
    "rrp.exclusion.repository-guidance",
    "rrp.exclusion.maintainer-operations",
    "rrp.exclusion.development-environment",
    "rrp.exclusion.hospital-delivery",
    "rrp.exclusion.release-evidence",
    "rrp.exclusion.generated-state"
  )
}

rrp_validate_resource_catalog_schema <- function(schema) {
  issues <- rrp_software_resource_empty_issues()
  top_fields <- c(
    "specification_kind", "specification_id", "specification_version",
    "specification_format_version", "identity_scope", "title", "status",
    "description", "catalog_contract", "resource_entry_contract",
    "excluded_family_contract", "deferred_role_contract", "path_rules",
    "cross_entry_invariants"
  )
  issues <- rrp_software_resource_check_fields(
    schema, top_fields, top_fields, "$schema", issues
  )
  if (!rrp_software_resource_named_record(schema)) {
    return(rrp_software_resource_result(issues))
  }

  expected_identity <- c(
    specification_kind = "installed_resource_catalog_schema",
    specification_id = "platform.installed-resource-catalog-schema",
    specification_version = "0.1.0",
    specification_format_version = "1.0.0",
    identity_scope = "platform",
    status = "active"
  )
  for (field in names(expected_identity)) {
    if (!identical(schema[[field]], unname(expected_identity[[field]]))) {
      issues <- rrp_software_resource_add_issue(
        issues, "invalid_schema_identity", paste0("$schema.", field),
        paste0("Unsupported schema ", field, ".")
      )
    }
  }

  required_sections <- list(
    catalog_contract = c(
      "catalog_kind", "catalog_id", "catalog_version",
      "catalog_format_version", "status_values",
      "required_top_level_fields", "allowed_top_level_fields",
      "schema_reference_fields", "product_fields", "limitation_fields"
    ),
    resource_entry_contract = c(
      "required_fields", "allowed_fields", "resource_id_pattern",
      "allowed_roles", "allowed_owners", "allowed_formats",
      "compatibility_fields", "compatibility_status_values"
    ),
    excluded_family_contract = c(
      "required_fields", "allowed_fields", "family_id_pattern",
      "allowed_classifications"
    ),
    deferred_role_contract = c(
      "required_fields", "allowed_fields", "role_id_pattern"
    ),
    path_rules = c(
      "relative_only", "forward_slashes_only", "dot_segments_prohibited",
      "parent_segments_prohibited", "linked_sources_prohibited",
      "required_sources_must_be_regular_files", "allowed_output_roots",
      "forbidden_shipped_source_prefixes", "forbidden_shipped_sources"
    ),
    cross_entry_invariants = c(
      "unique_resource_ids", "unique_source_paths", "unique_output_paths",
      "case_folded_output_paths_unique",
      "file_directory_output_conflicts_prohibited",
      "shipped_and_excluded_overlap_prohibited",
      "accepted_classification_complete"
    )
  )
  for (section in names(required_sections)) {
    issues <- rrp_software_resource_check_fields(
      schema[[section]], required_sections[[section]],
      required_sections[[section]], paste0("$schema.", section), issues
    )
  }

  valid_sections <- vapply(names(required_sections), function(section) {
    rrp_software_resource_named_record(schema[[section]])
  }, logical(1L))
  if (!all(valid_sections)) return(rrp_software_resource_result(issues))

  list_fields <- list(
    c("catalog_contract", "status_values"),
    c("catalog_contract", "required_top_level_fields"),
    c("catalog_contract", "allowed_top_level_fields"),
    c("catalog_contract", "schema_reference_fields"),
    c("catalog_contract", "product_fields"),
    c("catalog_contract", "limitation_fields"),
    c("resource_entry_contract", "required_fields"),
    c("resource_entry_contract", "allowed_fields"),
    c("resource_entry_contract", "allowed_roles"),
    c("resource_entry_contract", "allowed_owners"),
    c("resource_entry_contract", "allowed_formats"),
    c("resource_entry_contract", "compatibility_fields"),
    c("resource_entry_contract", "compatibility_status_values"),
    c("excluded_family_contract", "required_fields"),
    c("excluded_family_contract", "allowed_fields"),
    c("excluded_family_contract", "allowed_classifications"),
    c("deferred_role_contract", "required_fields"),
    c("deferred_role_contract", "allowed_fields"),
    c("path_rules", "allowed_output_roots")
  )
  for (location in list_fields) {
    values <- rrp_software_resource_values(schema[[location[[1L]]]][[location[[2L]]]])
    if (length(values) == 0L || any(!nzchar(values)) || anyDuplicated(values)) {
      issues <- rrp_software_resource_add_issue(
        issues, "invalid_schema_values",
        paste0("$schema.", paste(location, collapse = ".")),
        "Schema controlled values must be non-empty and unique."
      )
    }
  }

  required_allowed_pairs <- list(
    c("catalog_contract", "required_top_level_fields", "allowed_top_level_fields"),
    c("resource_entry_contract", "required_fields", "allowed_fields"),
    c("excluded_family_contract", "required_fields", "allowed_fields"),
    c("deferred_role_contract", "required_fields", "allowed_fields")
  )
  for (pair in required_allowed_pairs) {
    required_values <- rrp_software_resource_values(
      schema[[pair[[1L]]]][[pair[[2L]]]]
    )
    allowed_values <- rrp_software_resource_values(
      schema[[pair[[1L]]]][[pair[[3L]]]]
    )
    if (!all(required_values %in% allowed_values)) issues <-
      rrp_software_resource_add_issue(
        issues, "invalid_schema_values",
        paste0("$schema.", pair[[1L]]),
        "Required fields must be a subset of allowed fields."
      )
  }
  for (field in c("resource_id_pattern", "family_id_pattern", "role_id_pattern")) {
    section <- if (identical(field, "resource_id_pattern")) {
      "resource_entry_contract"
    } else if (identical(field, "family_id_pattern")) {
      "excluded_family_contract"
    } else {
      "deferred_role_contract"
    }
    pattern <- schema[[section]][[field]]
    valid_pattern <- rrp_software_resource_scalar_string(pattern) &&
      !inherits(try(grepl(pattern, "rrp.example.value", perl = TRUE), silent = TRUE),
                "try-error")
    if (!valid_pattern) issues <- rrp_software_resource_add_issue(
      issues, "invalid_schema_pattern", paste0("$schema.", section, ".", field),
      "Schema identity pattern must be one valid regular expression."
    )
  }
  boolean_rules <- c(
    "relative_only", "forward_slashes_only", "dot_segments_prohibited",
    "parent_segments_prohibited", "linked_sources_prohibited",
    "required_sources_must_be_regular_files"
  )
  for (field in boolean_rules) {
    if (!identical(schema$path_rules[[field]], TRUE)) issues <-
      rrp_software_resource_add_issue(
        issues, "invalid_schema_rule", paste0("$schema.path_rules.", field),
        "Required path-safety rules cannot be disabled."
      )
  }
  for (field in names(schema$cross_entry_invariants)) {
    if (!identical(schema$cross_entry_invariants[[field]], TRUE)) issues <-
      rrp_software_resource_add_issue(
        issues, "invalid_schema_rule",
        paste0("$schema.cross_entry_invariants.", field),
        "Required cross-entry invariants cannot be disabled."
      )
  }
  rrp_software_resource_result(issues)
}

rrp_software_resource_is_forbidden <- function(path, path_rules) {
  exact <- rrp_software_resource_values(path_rules$forbidden_shipped_sources)
  prefixes <- rrp_software_resource_values(
    path_rules$forbidden_shipped_source_prefixes
  )
  path %in% exact || any(vapply(prefixes, function(prefix) {
    identical(path, prefix) || startsWith(path, paste0(prefix, "/"))
  }, logical(1L)))
}

rrp_software_resource_format_matches <- function(path, format) {
  if (identical(format, "yaml")) return(grepl("[.](yml|yaml)$", path))
  if (identical(format, "markdown")) return(endsWith(path, ".md"))
  if (identical(format, "apache-2.0-license")) {
    return(identical(basename(path), "LICENSE"))
  }
  identical(format, "text")
}

rrp_software_resource_output_conflicts <- function(paths) {
  conflicts <- character()
  if (length(paths) < 2L) return(conflicts)
  for (left in seq_len(length(paths) - 1L)) {
    for (right in seq.int(left + 1L, length(paths))) {
      if (startsWith(paths[[right]], paste0(paths[[left]], "/")) ||
          startsWith(paths[[left]], paste0(paths[[right]], "/"))) {
        conflicts <- c(conflicts, paths[[left]], paths[[right]])
      }
    }
  }
  unique(conflicts)
}

rrp_validate_installed_resource_catalog <- function(
  catalog, schema, repository_root
) {
  schema_result <- rrp_validate_resource_catalog_schema(schema)
  if (!schema_result$passed) return(schema_result)

  issues <- rrp_software_resource_empty_issues()
  contract <- schema$catalog_contract
  required <- rrp_software_resource_values(contract$required_top_level_fields)
  allowed <- rrp_software_resource_values(contract$allowed_top_level_fields)
  issues <- rrp_software_resource_check_fields(
    catalog, required, allowed, "$catalog", issues
  )
  if (!rrp_software_resource_named_record(catalog)) {
    return(rrp_software_resource_result(issues))
  }
  if (!all(required %in% names(catalog))) {
    return(rrp_software_resource_result(issues))
  }

  expected <- c(
    catalog_kind = contract$catalog_kind,
    catalog_id = contract$catalog_id,
    catalog_version = contract$catalog_version,
    catalog_format_version = contract$catalog_format_version
  )
  for (field in names(expected)) {
    if (!identical(catalog[[field]], unname(expected[[field]]))) {
      issues <- rrp_software_resource_add_issue(
        issues, "invalid_catalog_identity", paste0("$catalog.", field),
        paste0("Catalog ", field, " does not match the schema contract.")
      )
    }
  }
  if (!rrp_software_resource_scalar_string(catalog$status) ||
      !catalog$status %in% rrp_software_resource_values(contract$status_values)) {
    issues <- rrp_software_resource_add_issue(
      issues, "invalid_catalog_status", "$catalog.status",
      "Catalog status is not allowed."
    )
  }

  reference_fields <- rrp_software_resource_values(contract$schema_reference_fields)
  issues <- rrp_software_resource_check_fields(
    catalog$schema, reference_fields, reference_fields, "$catalog.schema", issues
  )
  if (rrp_software_resource_named_record(catalog$schema) &&
      (!identical(catalog$schema$specification_id, schema$specification_id) ||
       !identical(catalog$schema$specification_version, schema$specification_version))) {
    issues <- rrp_software_resource_add_issue(
      issues, "schema_reference_mismatch", "$catalog.schema",
      "Catalog schema identity does not match the loaded schema."
    )
  }

  product_fields <- rrp_software_resource_values(contract$product_fields)
  issues <- rrp_software_resource_check_fields(
    catalog$product, product_fields, product_fields, "$catalog.product", issues
  )
  if (rrp_software_resource_named_record(catalog$product)) {
    if (!identical(catalog$product$product_id, "readmission-risk-pool-platform") ||
        !identical(catalog$product$development_version, "0.2.0-dev") ||
        !identical(catalog$product$distribution_status, "not_built")) {
      issues <- rrp_software_resource_add_issue(
        issues, "invalid_product_status", "$catalog.product",
        "Catalog must retain product 0.2.0-dev with no built distribution."
      )
    }
  }

  limitation_fields <- rrp_software_resource_values(contract$limitation_fields)
  issues <- rrp_software_resource_check_fields(
    catalog$limitations, limitation_fields, limitation_fields,
    "$catalog.limitations", issues
  )
  if (rrp_software_resource_named_record(catalog$limitations)) {
    expected_limitations <- list(
      supported_installation = FALSE,
      clinical_use = "prohibited",
      hospital_project = FALSE,
      final_release_payload = FALSE
    )
    for (field in names(expected_limitations)) {
      if (!identical(catalog$limitations[[field]], expected_limitations[[field]])) {
        issues <- rrp_software_resource_add_issue(
          issues, "invalid_limitation", paste0("$catalog.limitations.", field),
          "Catalog limitation does not preserve development-only status."
        )
      }
    }
  }

  if (!rrp_software_resource_scalar_string(catalog$resource_id_convention)) {
    issues <- rrp_software_resource_add_issue(
      issues, "invalid_resource_id_convention", "$catalog.resource_id_convention",
      "Resource ID convention must be a non-empty string."
    )
  }

  resources <- catalog$resources
  if (!is.list(resources) || length(resources) == 0L) {
    issues <- rrp_software_resource_add_issue(
      issues, "invalid_resources", "$catalog.resources",
      "Catalog resources must be a non-empty list."
    )
    resources <- list()
  }

  entry_contract <- schema$resource_entry_contract
  entry_required <- rrp_software_resource_values(entry_contract$required_fields)
  entry_allowed <- rrp_software_resource_values(entry_contract$allowed_fields)
  roles <- rrp_software_resource_values(entry_contract$allowed_roles)
  owners <- rrp_software_resource_values(entry_contract$allowed_owners)
  formats <- rrp_software_resource_values(entry_contract$allowed_formats)
  compatibility_fields <- rrp_software_resource_values(
    entry_contract$compatibility_fields
  )
  compatibility_statuses <- rrp_software_resource_values(
    entry_contract$compatibility_status_values
  )
  output_roots <- rrp_software_resource_values(
    schema$path_rules$allowed_output_roots
  )

  resource_ids <- source_paths <- output_paths <- character()
  for (index in seq_along(resources)) {
    entry <- resources[[index]]
    path <- paste0("$catalog.resources[", index, "]")
    issues <- rrp_software_resource_check_fields(
      entry, entry_required, entry_allowed, path, issues
    )
    if (!rrp_software_resource_named_record(entry)) next

    scalar_fields <- c("resource_id", "role", "owner", "source_path",
                       "output_path", "format")
    for (field in scalar_fields) {
      if (!rrp_software_resource_scalar_string(entry[[field]])) issues <-
        rrp_software_resource_add_issue(
          issues, "invalid_resource_field", paste0(path, ".", field),
          "Resource field must be one non-empty string."
        )
    }
    if (!is.logical(entry$required) || length(entry$required) != 1L ||
        is.na(entry$required)) issues <- rrp_software_resource_add_issue(
      issues, "invalid_required_flag", paste0(path, ".required"),
      "Required must be one explicit boolean."
    )

    if (rrp_software_resource_scalar_string(entry$resource_id)) {
      resource_ids <- c(resource_ids, entry$resource_id)
      if (!grepl(entry_contract$resource_id_pattern, entry$resource_id, perl = TRUE)) {
        issues <- rrp_software_resource_add_issue(
          issues, "invalid_resource_id", paste0(path, ".resource_id"),
          "Resource ID does not follow the stable logical-ID convention."
        )
      }
    }
    if (rrp_software_resource_scalar_string(entry$role) &&
        !entry$role %in% roles) issues <- rrp_software_resource_add_issue(
      issues, "invalid_resource_role", paste0(path, ".role"),
      "Resource role is not allowed."
    )
    if (rrp_software_resource_scalar_string(entry$owner) &&
        !entry$owner %in% owners) issues <- rrp_software_resource_add_issue(
      issues, "invalid_resource_owner", paste0(path, ".owner"),
      "Resource owner is not allowed."
    )
    if (rrp_software_resource_scalar_string(entry$format) &&
        !entry$format %in% formats) issues <- rrp_software_resource_add_issue(
      issues, "invalid_resource_format", paste0(path, ".format"),
      "Resource format is not allowed."
    )

    issues <- rrp_software_resource_check_fields(
      entry$compatibility, compatibility_fields, compatibility_fields,
      paste0(path, ".compatibility"), issues
    )
    if (rrp_software_resource_named_record(entry$compatibility)) {
      if (!entry$compatibility$status %in% compatibility_statuses) {
        issues <- rrp_software_resource_add_issue(
          issues, "invalid_compatibility_status",
          paste0(path, ".compatibility.status"),
          "Compatibility status is not allowed."
        )
      }
      if (!rrp_software_resource_scalar_string(entry$compatibility$note)) {
        issues <- rrp_software_resource_add_issue(
          issues, "invalid_compatibility_note",
          paste0(path, ".compatibility.note"),
          "Compatibility note must be one non-empty string."
        )
      }
    }

    if (rrp_software_resource_scalar_string(entry$source_path)) {
      source_paths <- c(source_paths, entry$source_path)
      if (!rrp_software_resource_safe_path(entry$source_path)) {
        issues <- rrp_software_resource_add_issue(
          issues, "unsafe_source_path", paste0(path, ".source_path"),
          "Source path must be normalized and repository-relative."
        )
      } else if (rrp_software_resource_is_forbidden(
        entry$source_path, schema$path_rules
      )) {
        issues <- rrp_software_resource_add_issue(
          issues, "forbidden_resource_class", paste0(path, ".source_path"),
          "Repository-only or deferred content cannot be shipped."
        )
      } else {
        absolute <- file.path(repository_root, entry$source_path)
        linked <- rrp_software_resource_has_link(repository_root, entry$source_path)
        if (linked) issues <- rrp_software_resource_add_issue(
          issues, "linked_source", paste0(path, ".source_path"),
          "Catalog sources and their repository-relative parents cannot be links."
        )
        exists <- file.exists(absolute)
        required <- identical(entry$required, TRUE)
        if (!exists && required) issues <- rrp_software_resource_add_issue(
          issues, "missing_required_source", paste0(path, ".source_path"),
          "Required catalog source does not exist."
        )
        if (exists && !linked) {
          info <- file.info(absolute)
          if (isTRUE(info$isdir)) issues <- rrp_software_resource_add_issue(
            issues, "non_regular_source", paste0(path, ".source_path"),
            "Catalog sources must be regular files."
          ) else if (!rrp_software_resource_is_contained(
            repository_root, entry$source_path
          )) issues <- rrp_software_resource_add_issue(
            issues, "escaping_source", paste0(path, ".source_path"),
            "Resolved catalog source escapes the repository root."
          )
        }
      }
    }

    if (rrp_software_resource_scalar_string(entry$output_path)) {
      output_paths <- c(output_paths, entry$output_path)
      if (!rrp_software_resource_safe_path(entry$output_path)) {
        issues <- rrp_software_resource_add_issue(
          issues, "unsafe_output_path", paste0(path, ".output_path"),
          "Output path must be normalized and distribution-relative."
        )
      } else if (!strsplit(entry$output_path, "/", fixed = TRUE)[[1L]][[1L]] %in%
                 output_roots) issues <- rrp_software_resource_add_issue(
        issues, "invalid_output_root", paste0(path, ".output_path"),
        "Output path does not use an allowed resource root."
      )
    }
    if (rrp_software_resource_scalar_string(entry$source_path) &&
        rrp_software_resource_scalar_string(entry$format) &&
        entry$format %in% formats &&
        !rrp_software_resource_format_matches(entry$source_path, entry$format)) {
      issues <- rrp_software_resource_add_issue(
        issues, "format_path_mismatch", paste0(path, ".format"),
        "Declared format does not match the source path."
      )
    }
  }

  duplicate_sets <- list(
    duplicate_resource_id = resource_ids[duplicated(resource_ids)],
    duplicate_source_path = source_paths[duplicated(source_paths)],
    duplicate_output_path = output_paths[duplicated(output_paths)],
    case_folded_output_collision = output_paths[duplicated(tolower(output_paths))]
  )
  for (code in names(duplicate_sets)) {
    if (length(duplicate_sets[[code]]) > 0L) issues <-
      rrp_software_resource_add_issue(
        issues, code, "$catalog.resources",
        paste0("Conflicting values: ", paste(unique(duplicate_sets[[code]]), collapse = ", "), ".")
      )
  }
  output_conflicts <- rrp_software_resource_output_conflicts(output_paths)
  if (length(output_conflicts) > 0L) issues <- rrp_software_resource_add_issue(
    issues, "output_file_directory_conflict", "$catalog.resources",
    paste0("Output file/directory conflicts: ", paste(output_conflicts, collapse = ", "), ".")
  )

  expected_sources <- rrp_expected_installed_resource_sources(repository_root)
  if (!setequal(source_paths, expected_sources) ||
      length(source_paths) != length(expected_sources)) {
    missing <- setdiff(expected_sources, source_paths)
    extra <- setdiff(source_paths, expected_sources)
    issues <- rrp_software_resource_add_issue(
      issues, "classification_incomplete", "$catalog.resources",
      paste0(
        "Catalog differs from the accepted shipped-resource classification; missing: ",
        paste(missing, collapse = ", "), "; extra: ", paste(extra, collapse = ", "), "."
      )
    )
  }

  exclusions <- catalog$excluded_resource_families
  if (!is.list(exclusions) || length(exclusions) == 0L) {
    issues <- rrp_software_resource_add_issue(
      issues, "invalid_exclusions", "$catalog.excluded_resource_families",
      "Excluded resource families must be a non-empty list."
    )
    exclusions <- list()
  }
  exclusion_contract <- schema$excluded_family_contract
  exclusion_required <- rrp_software_resource_values(
    exclusion_contract$required_fields
  )
  exclusion_allowed <- rrp_software_resource_values(
    exclusion_contract$allowed_fields
  )
  exclusion_ids <- exclusion_paths <- character()
  classifications <- rrp_software_resource_values(
    exclusion_contract$allowed_classifications
  )
  for (index in seq_along(exclusions)) {
    exclusion <- exclusions[[index]]
    path <- paste0("$catalog.excluded_resource_families[", index, "]")
    issues <- rrp_software_resource_check_fields(
      exclusion, exclusion_required, exclusion_allowed, path, issues
    )
    if (!rrp_software_resource_named_record(exclusion)) next
    if (rrp_software_resource_scalar_string(exclusion$family_id)) {
      exclusion_ids <- c(exclusion_ids, exclusion$family_id)
      if (!grepl(exclusion_contract$family_id_pattern, exclusion$family_id,
                 perl = TRUE)) issues <- rrp_software_resource_add_issue(
        issues, "invalid_exclusion_id", paste0(path, ".family_id"),
        "Exclusion family ID does not follow the closed convention."
      )
    }
    if (!rrp_software_resource_scalar_string(exclusion$classification) ||
        !exclusion$classification %in% classifications) issues <-
      rrp_software_resource_add_issue(
        issues, "invalid_exclusion_classification",
        paste0(path, ".classification"),
        "Exclusion classification is not allowed."
      )
    paths <- rrp_software_resource_values(exclusion$source_paths)
    if (length(paths) == 0L || any(!vapply(
      paths, rrp_software_resource_safe_path, logical(1L)
    ))) issues <- rrp_software_resource_add_issue(
      issues, "unsafe_exclusion_path", paste0(path, ".source_paths"),
      "Exclusion paths must be exact normalized repository-relative paths."
    )
    exclusion_paths <- c(exclusion_paths, paths)
    for (field in c("reason", "future_stage")) {
      if (!rrp_software_resource_scalar_string(exclusion[[field]])) issues <-
        rrp_software_resource_add_issue(
          issues, "invalid_exclusion_field", paste0(path, ".", field),
          "Exclusion field must be one non-empty string."
        )
    }
  }
  if (anyDuplicated(exclusion_ids)) issues <- rrp_software_resource_add_issue(
    issues, "duplicate_exclusion_id", "$catalog.excluded_resource_families",
    "Excluded resource family IDs must be unique."
  )
  if (!setequal(exclusion_ids, rrp_expected_resource_exclusion_ids()) ||
      length(exclusion_ids) != length(rrp_expected_resource_exclusion_ids())) {
    issues <- rrp_software_resource_add_issue(
      issues, "exclusion_classification_incomplete",
      "$catalog.excluded_resource_families",
      "Catalog does not contain the complete accepted exclusion-family set."
    )
  }
  overlap <- source_paths[vapply(source_paths, function(source) {
    any(vapply(exclusion_paths, function(excluded) {
      identical(source, excluded) || startsWith(source, paste0(excluded, "/"))
    }, logical(1L)))
  }, logical(1L))]
  if (length(overlap) > 0L) issues <- rrp_software_resource_add_issue(
    issues, "shipped_excluded_overlap", "$catalog.resources",
    paste0("Shipped sources overlap excluded families: ", paste(overlap, collapse = ", "), ".")
  )

  deferred <- catalog$deferred_resource_roles
  deferred_contract <- schema$deferred_role_contract
  deferred_required <- rrp_software_resource_values(deferred_contract$required_fields)
  deferred_allowed <- rrp_software_resource_values(deferred_contract$allowed_fields)
  if (!is.list(deferred) || length(deferred) != 1L) {
    issues <- rrp_software_resource_add_issue(
      issues, "invalid_deferred_roles", "$catalog.deferred_resource_roles",
      "Exactly the not-yet-existing project-template role must be deferred."
    )
  } else {
    entry <- deferred[[1L]]
    issues <- rrp_software_resource_check_fields(
      entry, deferred_required, deferred_allowed,
      "$catalog.deferred_resource_roles[1]", issues
    )
    if (rrp_software_resource_named_record(entry)) {
      if (!identical(entry$role_id, "rrp.deferred.project-template") ||
          !identical(entry$planned_stage, "stage_4") ||
          !rrp_software_resource_scalar_string(entry$reason)) issues <-
        rrp_software_resource_add_issue(
          issues, "invalid_deferred_project_template",
          "$catalog.deferred_resource_roles[1]",
          "Deferred role must describe the absent Stage 4 project template."
        )
    }
  }

  rrp_software_resource_result(issues)
}

rrp_validate_software_resource_repository <- function(repository_root) {
  catalog_path <- file.path(
    repository_root, "distribution", "software", "resource-catalog.yml"
  )
  schema_path <- file.path(
    repository_root, "distribution", "software", "resource-catalog-schema.yml"
  )
  issues <- rrp_software_resource_empty_issues()
  for (path in c(catalog_path, schema_path)) {
    if (!file.exists(path)) issues <- rrp_software_resource_add_issue(
      issues, "missing_catalog_control", path,
      "Required resource catalog control file is missing."
    ) else if (nzchar(Sys.readlink(path)) || isTRUE(file.info(path)$isdir)) {
      issues <- rrp_software_resource_add_issue(
        issues, "invalid_catalog_control", path,
        "Catalog control must be one regular non-linked file."
      )
    }
  }
  if (nrow(issues) > 0L) return(rrp_software_resource_result(issues))

  loaded <- tryCatch(
    list(
      catalog = yaml::read_yaml(catalog_path),
      schema = yaml::read_yaml(schema_path)
    ),
    error = function(condition) condition
  )
  if (inherits(loaded, "condition")) return(rrp_software_resource_result(
    rrp_software_resource_issue(
      "invalid_catalog_yaml", "$catalog",
      paste0("Catalog or schema YAML could not be parsed: ", conditionMessage(loaded))
    )
  ))
  rrp_validate_installed_resource_catalog(
    loaded$catalog, loaded$schema, repository_root
  )
}
