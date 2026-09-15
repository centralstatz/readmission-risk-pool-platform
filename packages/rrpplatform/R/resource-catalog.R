rrp_resource_abort <- function(code, message) {
  condition <- structure(
    list(message = message, call = NULL, code = code),
    class = c("rrp_resource_error", "error", "condition")
  )
  stop(condition)
}

rrp_resource_scalar_string <- function(value) {
  is.character(value) && length(value) == 1L && !is.na(value) && nzchar(value)
}

rrp_resource_values <- function(value) {
  if (is.null(value)) return(character())
  unname(unlist(value, use.names = FALSE))
}

rrp_resource_require_record <- function(value, fields, path) {
  if (!is.list(value) || is.null(names(value)) ||
      length(value) != length(names(value)) || any(!nzchar(names(value))) ||
      anyDuplicated(names(value))) {
    rrp_resource_abort("invalid_structure", paste0(path, " must be a named record."))
  }
  missing <- setdiff(fields, names(value))
  unknown <- setdiff(names(value), fields)
  if (length(missing) > 0L) rrp_resource_abort(
    "missing_required_field",
    paste0(path, " is missing required field `", missing[[1L]], "`.")
  )
  if (length(unknown) > 0L) rrp_resource_abort(
    "unknown_field",
    paste0(path, " contains unknown field `", unknown[[1L]], "`.")
  )
  invisible(TRUE)
}

rrp_resource_require_values <- function(actual, expected, path) {
  if (!identical(rrp_resource_values(actual), expected)) rrp_resource_abort(
    "invalid_schema_contract", paste0(path, " is not supported.")
  )
}

rrp_resource_safe_path <- function(path) {
  if (!rrp_resource_scalar_string(path) || grepl("\\\\", path) ||
      grepl("^/", path) || grepl("^[A-Za-z]:", path) || startsWith(path, "~") ||
      grepl("//", path, fixed = TRUE) || endsWith(path, "/")) return(FALSE)
  segments <- strsplit(path, "/", fixed = TRUE)[[1L]]
  length(segments) > 0L && all(nzchar(segments)) &&
    !any(segments %in% c(".", ".."))
}

rrp_resource_has_link <- function(root, relative_path) {
  current <- root
  for (segment in strsplit(relative_path, "/", fixed = TRUE)[[1L]]) {
    current <- file.path(current, segment)
    link <- Sys.readlink(current)
    if (!is.na(link) && nzchar(link)) return(TRUE)
  }
  FALSE
}

rrp_resource_output_conflicts <- function(paths) {
  if (length(paths) < 2L) return(character())
  conflicts <- character()
  for (left in seq_len(length(paths) - 1L)) {
    for (right in seq.int(left + 1L, length(paths))) {
      if (startsWith(paths[[left]], paste0(paths[[right]], "/")) ||
          startsWith(paths[[right]], paste0(paths[[left]], "/"))) {
        conflicts <- c(conflicts, paths[[left]], paths[[right]])
      }
    }
  }
  unique(conflicts)
}

rrp_resource_concrete_path <- function(root, relative_path, code_prefix) {
  if (!rrp_resource_safe_path(relative_path)) rrp_resource_abort(
    paste0("unsafe_", code_prefix, "_path"),
    paste0("Installed ", code_prefix, " path is not a safe relative path.")
  )
  if (rrp_resource_has_link(root, relative_path)) rrp_resource_abort(
    paste0("linked_", code_prefix),
    paste0("Installed ", code_prefix, " path or parent is a symbolic link.")
  )
  candidate <- file.path(root, relative_path)
  if (!file.exists(candidate)) rrp_resource_abort(
    paste0("missing_", code_prefix),
    paste0("Installed ", code_prefix, " does not exist: ", relative_path, ".")
  )
  if (isTRUE(file.info(candidate)$isdir)) rrp_resource_abort(
    paste0("non_regular_", code_prefix),
    paste0("Installed ", code_prefix, " is not a regular file: ", relative_path, ".")
  )
  normalized <- normalizePath(candidate, winslash = "/", mustWork = TRUE)
  if (!startsWith(normalized, paste0(root, "/"))) rrp_resource_abort(
    paste0("escaping_", code_prefix),
    paste0("Installed ", code_prefix, " escapes the explicit distribution root.")
  )
  normalized
}

rrp_validate_installed_schema <- function(schema) {
  top_fields <- c(
    "specification_kind", "specification_id", "specification_version",
    "specification_format_version", "identity_scope", "title", "status",
    "description", "catalog_contract", "installed_realization_contract",
    "resource_entry_contract", "excluded_family_contract",
    "deferred_role_contract", "path_rules", "cross_entry_invariants"
  )
  rrp_resource_require_record(schema, top_fields, "Installed resource schema")
  expected_identity <- list(
    specification_kind = "installed_resource_catalog_schema",
    specification_id = "platform.installed-resource-catalog-schema",
    specification_version = "0.1.0",
    specification_format_version = "1.0.0",
    identity_scope = "platform",
    status = "active"
  )
  for (field in names(expected_identity)) {
    if (!identical(schema[[field]], expected_identity[[field]])) {
      rrp_resource_abort(
        "invalid_schema_identity",
        paste0("Installed resource schema has unsupported `", field, "`.")
      )
    }
  }

  installed_fields <- c(
    "catalog_path", "schema_path", "required_top_level_fields",
    "allowed_top_level_fields", "source_only_top_level_fields",
    "required_resource_fields", "allowed_resource_fields",
    "source_only_resource_fields", "governed_output_roots",
    "expected_resource_count", "closed_output_inventory",
    "linked_outputs_prohibited", "required_outputs_must_be_regular_files"
  )
  installed <- schema$installed_realization_contract
  rrp_resource_require_record(
    installed, installed_fields, "Installed realization contract"
  )
  catalog_fields <- c(
    "catalog_kind", "catalog_id", "catalog_version", "catalog_format_version",
    "schema", "status", "product", "limitations", "resource_id_convention",
    "resources"
  )
  resource_fields <- c(
    "resource_id", "role", "owner", "output_path", "required", "format",
    "compatibility"
  )
  expected <- list(
    catalog_path = "resources/resource-catalog.yml",
    schema_path = "resources/resource-catalog-schema.yml",
    required_top_level_fields = catalog_fields,
    allowed_top_level_fields = catalog_fields,
    source_only_top_level_fields = c(
      "excluded_resource_families", "deferred_resource_roles"
    ),
    required_resource_fields = resource_fields,
    allowed_resource_fields = resource_fields,
    source_only_resource_fields = "source_path",
    governed_output_roots = c("resources", "docs", "legal")
  )
  for (field in names(expected)) {
    actual <- installed[[field]]
    if (is.character(expected[[field]]) && length(expected[[field]]) > 1L) {
      actual <- rrp_resource_values(actual)
    } else if (field %in% c(
      "required_top_level_fields", "allowed_top_level_fields",
      "source_only_top_level_fields", "required_resource_fields",
      "allowed_resource_fields", "governed_output_roots"
    )) {
      actual <- rrp_resource_values(actual)
    }
    if (!identical(actual, expected[[field]])) rrp_resource_abort(
      "invalid_schema_contract",
      paste0("Installed realization `", field, "` is not supported.")
    )
  }
  if (!identical(installed$expected_resource_count, 48L) ||
      !identical(installed$closed_output_inventory, TRUE) ||
      !identical(installed$linked_outputs_prohibited, TRUE) ||
      !identical(installed$required_outputs_must_be_regular_files, TRUE)) {
    rrp_resource_abort(
      "invalid_schema_contract",
      "Installed realization safety and inventory rules are not supported."
    )
  }

  catalog_contract_fields <- c(
    "catalog_kind", "catalog_id", "catalog_version", "catalog_format_version",
    "status_values", "required_top_level_fields", "allowed_top_level_fields",
    "schema_reference_fields", "product_fields", "limitation_fields"
  )
  rrp_resource_require_record(
    schema$catalog_contract, catalog_contract_fields, "Catalog contract"
  )
  catalog_identity <- list(
    catalog_kind = "installed_resource_catalog",
    catalog_id = "rrp.installed-resources",
    catalog_version = "0.1.0",
    catalog_format_version = "1.0.0"
  )
  for (field in names(catalog_identity)) {
    if (!identical(schema$catalog_contract[[field]], catalog_identity[[field]])) {
      rrp_resource_abort(
        "invalid_schema_contract", "Catalog identity contract is not supported."
      )
    }
  }
  rrp_resource_require_values(
    schema$catalog_contract$status_values, "development_unpublished",
    "Catalog status contract"
  )
  rrp_resource_require_values(
    schema$catalog_contract$schema_reference_fields,
    c("specification_id", "specification_version"), "Schema reference contract"
  )
  rrp_resource_require_values(
    schema$catalog_contract$product_fields,
    c("product_id", "development_version", "distribution_status"),
    "Product identity contract"
  )
  rrp_resource_require_values(
    schema$catalog_contract$limitation_fields,
    c("supported_installation", "clinical_use", "hospital_project",
      "final_release_payload"), "Limitation contract"
  )

  entry_fields <- c(
    "required_fields", "allowed_fields", "resource_id_pattern", "allowed_roles",
    "allowed_owners", "allowed_formats", "compatibility_fields",
    "compatibility_status_values"
  )
  entries <- schema$resource_entry_contract
  rrp_resource_require_record(entries, entry_fields, "Resource entry contract")
  if (!identical(
    entries$resource_id_pattern, "^rrp[.][a-z0-9]+(?:[.][a-z0-9-]+)+$"
  )) rrp_resource_abort(
    "invalid_schema_contract", "Resource ID pattern is not supported."
  )
  controlled <- list(
    allowed_roles = c(
      "normative_contract", "implementation_declaration",
      "application_identity", "artifact_dependency_declaration",
      "fictional_reference", "normative_documentation",
      "distribution_guidance", "legal_license", "legal_notice",
      "security_guidance", "support_guidance"
    ),
    allowed_owners = c(
      "platform.contracts", "rrp.supplied-adapters",
      "rrp.supplied-application", "reference.synthetic-source", "rrp.product",
      "rrp.software-distribution"
    ),
    allowed_formats = c("yaml", "markdown", "text", "apache-2.0-license"),
    compatibility_fields = c("status", "note"),
    compatibility_status_values = c(
      "current", "transitional_daily_hazard", "fictional_nonclinical",
      "development_unpublished"
    )
  )
  for (field in names(controlled)) rrp_resource_require_values(
    entries[[field]], controlled[[field]], paste0("Resource entry ", field)
  )
  invisible(schema)
}

rrp_validate_installed_catalog <- function(catalog, schema, root) {
  installed <- schema$installed_realization_contract
  catalog_fields <- rrp_resource_values(installed$required_top_level_fields)
  rrp_resource_require_record(catalog, catalog_fields, "Installed resource catalog")

  identities <- list(
    catalog_kind = "installed_resource_catalog",
    catalog_id = "rrp.installed-resources",
    catalog_version = "0.1.0",
    catalog_format_version = "1.0.0",
    status = "development_unpublished"
  )
  for (field in names(identities)) {
    if (!identical(catalog[[field]], identities[[field]])) rrp_resource_abort(
      "invalid_catalog_identity",
      paste0("Installed resource catalog has unsupported `", field, "`.")
    )
  }
  rrp_resource_require_record(
    catalog$schema, c("specification_id", "specification_version"),
    "Installed catalog schema reference"
  )
  if (!identical(catalog$schema$specification_id, schema$specification_id) ||
      !identical(catalog$schema$specification_version,
                 schema$specification_version)) rrp_resource_abort(
    "schema_reference_mismatch",
    "Installed catalog and schema identities do not agree."
  )
  rrp_resource_require_record(
    catalog$product,
    c("product_id", "development_version", "distribution_status"),
    "Installed catalog product identity"
  )
  if (!identical(catalog$product$product_id,
                 "readmission-risk-pool-platform") ||
      !identical(catalog$product$development_version, "0.2.0-dev") ||
      !identical(catalog$product$distribution_status, "not_built")) {
    rrp_resource_abort(
      "invalid_product_identity",
      "Installed catalog does not describe the accepted development product."
    )
  }
  rrp_resource_require_record(
    catalog$limitations,
    c("supported_installation", "clinical_use", "hospital_project",
      "final_release_payload"), "Installed catalog limitations"
  )
  limitations <- catalog$limitations
  if (!identical(limitations$supported_installation, FALSE) ||
      !identical(limitations$clinical_use, "prohibited") ||
      !identical(limitations$hospital_project, FALSE) ||
      !identical(limitations$final_release_payload, FALSE)) rrp_resource_abort(
    "invalid_catalog_limitation",
    "Installed catalog does not retain development-only limitations."
  )
  if (!rrp_resource_scalar_string(catalog$resource_id_convention)) {
    rrp_resource_abort(
      "invalid_resource_id_convention",
      "Installed catalog resource ID convention is missing."
    )
  }

  resources <- catalog$resources
  if (!is.list(resources) ||
      !identical(length(resources), installed$expected_resource_count)) {
    rrp_resource_abort(
      "invalid_resource_inventory",
      "Installed catalog does not contain the complete expected resource inventory."
    )
  }
  entry_fields <- rrp_resource_values(installed$required_resource_fields)
  entry_contract <- schema$resource_entry_contract
  roles <- rrp_resource_values(entry_contract$allowed_roles)
  owners <- rrp_resource_values(entry_contract$allowed_owners)
  formats <- rrp_resource_values(entry_contract$allowed_formats)
  compatibility_statuses <- rrp_resource_values(
    entry_contract$compatibility_status_values
  )
  ids <- outputs <- character()
  for (index in seq_along(resources)) {
    entry <- resources[[index]]
    label <- paste0("Installed resource entry ", index)
    rrp_resource_require_record(entry, entry_fields, label)
    for (field in c("resource_id", "role", "owner", "output_path", "format")) {
      if (!rrp_resource_scalar_string(entry[[field]])) rrp_resource_abort(
        "invalid_resource_field", paste0(label, " has invalid `", field, "`.")
      )
    }
    if (!grepl(entry_contract$resource_id_pattern, entry$resource_id, perl = TRUE)) {
      rrp_resource_abort("invalid_resource_id", paste0(label, " has malformed identity."))
    }
    if (!entry$role %in% roles || !entry$owner %in% owners ||
        !entry$format %in% formats) rrp_resource_abort(
      "invalid_resource_classification",
      paste0(label, " has an unsupported role, owner, or format.")
    )
    if (!is.logical(entry$required) || length(entry$required) != 1L ||
        is.na(entry$required)) rrp_resource_abort(
      "invalid_required_flag", paste0(label, " has an invalid required flag.")
    )
    rrp_resource_require_record(
      entry$compatibility, c("status", "note"), paste0(label, " compatibility")
    )
    if (!rrp_resource_scalar_string(entry$compatibility$status) ||
        !entry$compatibility$status %in% compatibility_statuses ||
        !rrp_resource_scalar_string(entry$compatibility$note)) {
      rrp_resource_abort(
        "invalid_compatibility", paste0(label, " has invalid compatibility metadata.")
      )
    }
    if (!rrp_resource_safe_path(entry$output_path)) rrp_resource_abort(
      "unsafe_output_path", paste0(label, " has an unsafe installed path.")
    )
    output_root <- strsplit(entry$output_path, "/", fixed = TRUE)[[1L]][[1L]]
    if (!output_root %in% rrp_resource_values(installed$governed_output_roots)) {
      rrp_resource_abort(
        "invalid_output_root", paste0(label, " uses an ungoverned output root.")
      )
    }
    ids <- c(ids, entry$resource_id)
    outputs <- c(outputs, entry$output_path)
  }
  if (anyDuplicated(ids)) rrp_resource_abort(
    "duplicate_resource_id", "Installed catalog contains a duplicate resource ID."
  )
  if (anyDuplicated(outputs)) rrp_resource_abort(
    "duplicate_output_path", "Installed catalog contains a duplicate output path."
  )
  if (anyDuplicated(tolower(outputs))) rrp_resource_abort(
    "case_folded_output_collision",
    "Installed catalog contains case-conflicting output paths."
  )
  if (length(rrp_resource_output_conflicts(outputs)) > 0L) rrp_resource_abort(
    "output_file_directory_conflict",
    "Installed catalog contains a file/directory output conflict."
  )

  for (index in seq_along(resources)) {
    if (identical(resources[[index]]$required, TRUE)) rrp_resource_concrete_path(
      root, resources[[index]]$output_path, "resource"
    )
  }
  metadata <- c(installed$catalog_path, installed$schema_path)
  expected_files <- sort(unique(c(outputs, metadata)), method = "radix")
  actual_files <- character()
  for (governed_root in rrp_resource_values(installed$governed_output_roots)) {
    directory <- file.path(root, governed_root)
    if (!dir.exists(directory)) next
    files <- list.files(
      directory, recursive = TRUE, full.names = TRUE, all.files = TRUE,
      no.. = TRUE, include.dirs = FALSE
    )
    prefix <- paste0(root, "/")
    relative <- substring(gsub("\\\\", "/", files), nchar(prefix) + 1L)
    actual_files <- c(actual_files, relative)
  }
  actual_files <- sort(unique(actual_files), method = "radix")
  if (!identical(actual_files, expected_files)) rrp_resource_abort(
    "closed_inventory_mismatch",
    paste0(
      "Installed governed roots differ from the closed catalog; missing: ",
      paste(setdiff(expected_files, actual_files), collapse = ", "),
      "; extra: ", paste(setdiff(actual_files, expected_files), collapse = ", "), "."
    )
  )
  invisible(TRUE)
}

#' Open an installed RRP resource catalog
#'
#' Validates the complete installed resource boundary beneath a caller-supplied
#' distribution root. It does not discover or select an installed RRP version.
#'
#' @param explicit_distribution_root One explicit distribution-shaped root.
#' @return A validated catalog object for use with [rrp_resource_path()].
#' @keywords internal
#' @export
rrp_open_resource_catalog <- function(explicit_distribution_root) {
  if (!rrp_resource_scalar_string(explicit_distribution_root)) {
    rrp_resource_abort(
      "invalid_distribution_root", "Distribution root must be one explicit path."
    )
  }
  if (!dir.exists(explicit_distribution_root)) rrp_resource_abort(
    "missing_distribution_root", "Explicit distribution root does not exist."
  )
  root_link <- Sys.readlink(explicit_distribution_root)
  if (!is.na(root_link) && nzchar(root_link)) rrp_resource_abort(
    "linked_distribution_root", "Explicit distribution root cannot be a symbolic link."
  )
  root <- normalizePath(
    explicit_distribution_root, winslash = "/", mustWork = TRUE
  )
  catalog_relative <- "resources/resource-catalog.yml"
  schema_relative <- "resources/resource-catalog-schema.yml"
  catalog_path <- rrp_resource_concrete_path(root, catalog_relative, "catalog")
  schema_path <- rrp_resource_concrete_path(root, schema_relative, "schema")
  schema <- tryCatch(
    yaml::read_yaml(schema_path),
    error = function(condition) rrp_resource_abort(
      "malformed_schema", paste0("Installed resource schema is malformed: ",
                                  conditionMessage(condition))
    )
  )
  catalog <- tryCatch(
    yaml::read_yaml(catalog_path),
    error = function(condition) rrp_resource_abort(
      "malformed_catalog", paste0("Installed resource catalog is malformed: ",
                                   conditionMessage(condition))
    )
  )
  rrp_validate_installed_schema(schema)
  rrp_validate_installed_catalog(catalog, schema, root)
  structure(
    list(
      distribution_root = root,
      catalog_path = catalog_path,
      schema_path = schema_path,
      catalog = catalog
    ),
    class = "rrp_validated_resource_catalog"
  )
}

#' Resolve an installed RRP resource
#'
#' Resolves one exact logical resource ID within an already validated catalog.
#' The boundary is revalidated before lookup to detect plausible changes made
#' after the catalog was opened.
#'
#' @param validated_catalog An object returned by [rrp_open_resource_catalog()].
#' @param resource_id One exact stable logical resource ID.
#' @return The normalized concrete path beneath the explicit distribution root.
#' @keywords internal
#' @export
rrp_resource_path <- function(validated_catalog, resource_id) {
  if (!inherits(validated_catalog, "rrp_validated_resource_catalog") ||
      !is.list(validated_catalog)) rrp_resource_abort(
    "invalid_validated_catalog",
    "Resource lookup requires a validated installed-resource catalog."
  )
  required_fields <- c("distribution_root", "catalog_path", "schema_path", "catalog")
  rrp_resource_require_record(
    unclass(validated_catalog), required_fields, "Validated catalog object"
  )
  root <- validated_catalog$distribution_root
  if (!rrp_resource_scalar_string(root) ||
      !identical(validated_catalog$catalog_path,
                 file.path(root, "resources", "resource-catalog.yml")) ||
      !identical(validated_catalog$schema_path,
                 file.path(root, "resources", "resource-catalog-schema.yml"))) {
    rrp_resource_abort(
      "catalog_root_mismatch",
      "Validated catalog paths do not agree with its explicit distribution root."
    )
  }
  if (!rrp_resource_scalar_string(resource_id) ||
      !grepl("^rrp[.][a-z0-9]+(?:[.][a-z0-9-]+)+$", resource_id, perl = TRUE)) {
    rrp_resource_abort("invalid_resource_id", "Resource ID is missing or malformed.")
  }
  current <- rrp_open_resource_catalog(root)
  if (!identical(current$catalog, validated_catalog$catalog)) rrp_resource_abort(
    "catalog_changed", "Installed resource catalog changed after validation."
  )
  ids <- vapply(current$catalog$resources, `[[`, character(1L), "resource_id")
  matched <- which(ids == resource_id)
  if (length(matched) != 1L) rrp_resource_abort(
    "unknown_resource_id", paste0("Resource ID is not declared: ", resource_id, ".")
  )
  relative_path <- current$catalog$resources[[matched]]$output_path
  rrp_resource_concrete_path(root, relative_path, "resource")
}
