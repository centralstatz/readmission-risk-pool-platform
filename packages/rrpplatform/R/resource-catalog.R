rrp_resource_abort <- function(code, message) {
  if (!is.character(code) || length(code) != 1L || is.na(code) ||
      !grepl("^[a-z][a-z0-9_]*$", code) ||
      !is.character(message) || length(message) != 1L || is.na(message) ||
      !nzchar(message) || nchar(message, type = "bytes") > 160L ||
      grepl("[\r\n]", message)) {
    stop("Invalid internal resource-error definition.", call. = FALSE)
  }
  stop(structure(
    list(message = message, call = NULL, code = code),
    class = c("rrp_resource_error", "error", "condition")
  ))
}

rrp_resource_scalar_string <- function(value) {
  is.character(value) && length(value) == 1L && !is.na(value) && nzchar(value)
}

rrp_resource_require_fields <- function(record, fields, code, label) {
  valid_record <- is.list(record) && !is.null(names(record)) &&
    length(record) == length(names(record)) &&
    all(nzchar(names(record))) && !anyDuplicated(names(record))
  if (!valid_record || !setequal(names(record), fields)) {
    rrp_resource_abort(code, paste0(label, " fields are invalid."))
  }
  invisible(record)
}

rrp_resource_read_dcf <- function(path, malformed_code, label) {
  lines <- tryCatch(
    suppressWarnings(readLines(path, warn = FALSE, encoding = "UTF-8")),
    error = function(condition) rrp_resource_abort(
      malformed_code, paste0(label, " is malformed.")
    )
  )
  valid_layout <- length(lines) > 0L &&
    !any(grepl("^[[:space:]]*$", lines) & nzchar(lines))
  if (!valid_layout) {
    rrp_resource_abort(malformed_code, paste0(label, " is malformed."))
  }
  blank <- !nzchar(lines)
  if (blank[[1L]] || blank[[length(blank)]] ||
      any(blank[-length(blank)] & blank[-1L])) {
    rrp_resource_abort(malformed_code, paste0(label, " is malformed."))
  }

  separators <- which(blank)
  starts <- c(1L, separators + 1L)
  ends <- c(separators - 1L, length(lines))
  lapply(seq_along(starts), function(index) {
    block <- lines[starts[[index]]:ends[[index]]]
    if (!all(grepl(
      "^[A-Za-z][A-Za-z0-9-]*:[[:space:]]+[^[:space:]].*$", block
    ))) {
      rrp_resource_abort(malformed_code, paste0(label, " is malformed."))
    }
    fields <- sub(":.*$", "", block)
    if (anyDuplicated(fields)) {
      rrp_resource_abort(malformed_code, paste0(label, " is malformed."))
    }
    values <- sub("^[^:]+:[[:space:]]+", "", block)
    record <- as.list(values)
    names(record) <- fields
    record
  })
}

rrp_resource_schema_contract <- function() {
  c(
    "Record-Type" = "resource-catalog-schema",
    "Schema-ID" = "rrp.resource-catalog-schema",
    "Schema-Version" = "0.1.0",
    "Format-Version" = "1.0.0",
    "Catalog-Record-Type" = "catalog",
    "Resource-Record-Type" = "resource",
    "Catalog-ID" = "rrp.software-resources",
    "Catalog-Version" = "0.1.0",
    "Source-Catalog-Path" = "resources/source-catalog.dcf",
    "Installed-Catalog-Path" = "resources/resource-catalog.dcf",
    "Catalog-Fields" = paste(c(
      "Record-Type", "Catalog-ID", "Catalog-Version", "Format-Version",
      "Product-ID", "Development-Version", "Status"
    ), collapse = ","),
    "Source-Resource-Fields" = paste(c(
      "Record-Type", "Resource-ID", "Resource-Class", "Owner-Package",
      "Source-Path", "Installed-Path", "Format"
    ), collapse = ","),
    "Installed-Resource-Fields" = paste(c(
      "Record-Type", "Resource-ID", "Resource-Class", "Owner-Package",
      "Installed-Path", "Format"
    ), collapse = ","),
    "Resource-ID-Pattern" = "^rrp[.][a-z0-9]+(?:[.][a-z0-9-]+)+$",
    "Resource-Classes" = paste(c(
      "contract", "default", "template", "documentation",
      "static_application_asset"
    ), collapse = ","),
    "Owner-Packages" = "rrpplatform,rrpruntime",
    "Resource-Formats" = "dcf,r",
    "Status-Values" = "development_unpublished",
    "Unique-Fields" = "Resource-ID,Source-Path,Installed-Path",
    "Case-Folded-Path-Fields" = "Source-Path,Installed-Path",
    "Safe-Relative-Paths" = "true",
    "File-Directory-Conflicts-Prohibited" = "true",
    "Linked-Sources-Prohibited" = "true",
    "Regular-Sources-Required" = "true",
    "Closed-Source-Inventory" = "true",
    "Projection-Omitted-Fields" = "Source-Path"
  )
}

rrp_resource_validate_schema <- function(records) {
  if (length(records) != 1L) {
    rrp_resource_abort(
      "malformed_schema", "Installed resource schema is malformed."
    )
  }
  expected <- rrp_resource_schema_contract()
  record <- records[[1L]]
  rrp_resource_require_fields(
    record, names(expected), "invalid_schema_fields",
    "Installed resource schema"
  )
  for (field in names(expected)) {
    if (!identical(record[[field]], unname(expected[[field]]))) {
      rrp_resource_abort(
        "unsupported_schema", "Installed resource schema is unsupported."
      )
    }
  }
  record
}

rrp_resource_safe_path <- function(path) {
  if (!rrp_resource_scalar_string(path) ||
      !identical(path, trimws(path)) ||
      grepl("[[:cntrl:]\\\\]", path) || startsWith(path, "/") ||
      grepl("^[A-Za-z]:", path) || startsWith(path, "~") ||
      startsWith(path, "//") || endsWith(path, "/")) return(FALSE)
  segments <- strsplit(path, "/", fixed = TRUE)[[1L]]
  length(segments) > 0L && all(nzchar(segments)) &&
    !any(segments %in% c(".", ".."))
}

rrp_resource_has_link <- function(root, relative_path) {
  current <- root
  for (segment in strsplit(relative_path, "/", fixed = TRUE)[[1L]]) {
    current <- file.path(current, segment)
    target <- Sys.readlink(current)
    if (!is.na(target) && nzchar(target)) return(TRUE)
  }
  FALSE
}

rrp_resource_absolute <- function(root, relative_path) {
  gsub("\\\\", "/", file.path(root, relative_path))
}

rrp_resource_concrete_file <- function(root, relative_path, kind) {
  if (!rrp_resource_safe_path(relative_path)) {
    rrp_resource_abort(
      paste0("unsafe_", kind, "_path"),
      paste0("Installed ", kind, " path is unsafe.")
    )
  }
  if (rrp_resource_has_link(root, relative_path)) {
    rrp_resource_abort(
      paste0("linked_", kind),
      paste0("Installed ", kind, " must not be linked.")
    )
  }
  path <- rrp_resource_absolute(root, relative_path)
  if (!file.exists(path)) {
    rrp_resource_abort(
      paste0("missing_", kind), paste0("Installed ", kind, " is missing.")
    )
  }
  file_state <- file.info(path, extra_cols = FALSE)
  if (nrow(file_state) != 1L || is.na(file_state$isdir[[1L]]) ||
      isTRUE(file_state$isdir[[1L]])) {
    rrp_resource_abort(
      paste0("nonregular_", kind),
      paste0("Installed ", kind, " must be a regular file.")
    )
  }
  normalized <- normalizePath(path, winslash = "/", mustWork = TRUE)
  if (!startsWith(normalized, paste0(root, "/"))) {
    rrp_resource_abort(
      paste0("escaping_", kind),
      paste0("Installed ", kind, " escapes the software root.")
    )
  }
  normalized
}

rrp_resource_path_conflict <- function(paths) {
  folded <- tolower(paths)
  if (length(folded) < 2L) return(FALSE)
  for (left in seq_len(length(folded) - 1L)) {
    for (right in (left + 1L):length(folded)) {
      if (startsWith(folded[[left]], paste0(folded[[right]], "/")) ||
          startsWith(folded[[right]], paste0(folded[[left]], "/"))) {
        return(TRUE)
      }
    }
  }
  FALSE
}

rrp_resource_tree_files <- function(root) {
  resource_root <- file.path(root, "resources")
  if (!dir.exists(resource_root)) return(character())
  files <- list.files(
    resource_root, recursive = TRUE, all.files = TRUE, no.. = TRUE,
    full.names = FALSE, include.dirs = FALSE
  )
  sort(paste0("resources/", gsub("\\\\", "/", files)), method = "radix")
}

rrp_resource_validate_catalog <- function(records, schema, root) {
  if (length(records) < 2L) {
    rrp_resource_abort(
      "malformed_catalog", "Installed resource catalog is malformed."
    )
  }
  catalog_fields <- strsplit(
    schema[["Catalog-Fields"]], ",", fixed = TRUE
  )[[1L]]
  header <- records[[1L]]
  rrp_resource_require_fields(
    header, catalog_fields, "invalid_catalog_fields",
    "Installed resource catalog"
  )
  expected_header <- c(
    "Record-Type" = "catalog",
    "Catalog-ID" = "rrp.software-resources",
    "Catalog-Version" = "0.1.0",
    "Format-Version" = "1.0.0",
    "Product-ID" = "readmission-risk-pool-platform",
    "Development-Version" = "1.0.0-dev",
    "Status" = "development_unpublished"
  )
  for (field in names(expected_header)) {
    if (!identical(header[[field]], unname(expected_header[[field]]))) {
      rrp_resource_abort(
        "unsupported_catalog", "Installed resource catalog is unsupported."
      )
    }
  }

  entries <- records[-1L]
  fields <- strsplit(
    schema[["Installed-Resource-Fields"]], ",", fixed = TRUE
  )[[1L]]
  classes <- strsplit(schema[["Resource-Classes"]], ",", fixed = TRUE)[[1L]]
  owners <- strsplit(schema[["Owner-Packages"]], ",", fixed = TRUE)[[1L]]
  formats <- strsplit(schema[["Resource-Formats"]], ",", fixed = TRUE)[[1L]]
  pattern <- schema[["Resource-ID-Pattern"]]
  for (entry in entries) {
    rrp_resource_require_fields(
      entry, fields, "invalid_resource_fields", "Installed resource entry"
    )
    if (!identical(entry[["Record-Type"]], "resource") ||
        !rrp_resource_scalar_string(entry[["Resource-ID"]]) ||
        !grepl(pattern, entry[["Resource-ID"]], perl = TRUE)) {
      rrp_resource_abort(
        "invalid_resource_id", "Installed resource identity is invalid."
      )
    }
    if (!entry[["Resource-Class"]] %in% classes) {
      rrp_resource_abort(
        "unsupported_resource_class", "Installed resource class is unsupported."
      )
    }
    if (!entry[["Owner-Package"]] %in% owners) {
      rrp_resource_abort(
        "unsupported_resource_owner", "Installed resource owner is unsupported."
      )
    }
    if (!entry[["Format"]] %in% formats) {
      rrp_resource_abort(
        "unsupported_resource_format", "Installed resource format is unsupported."
      )
    }
    if (!rrp_resource_safe_path(entry[["Installed-Path"]]) ||
        !startsWith(entry[["Installed-Path"]], "resources/")) {
      rrp_resource_abort(
        "unsafe_resource_path", "Installed resource path is unsafe."
      )
    }
  }

  values <- function(field) vapply(entries, `[[`, character(1L), field)
  ids <- values("Resource-ID")
  paths <- values("Installed-Path")
  if (anyDuplicated(ids)) {
    rrp_resource_abort(
      "duplicate_resource_id", "Installed resource identities must be unique."
    )
  }
  if (anyDuplicated(paths)) {
    rrp_resource_abort(
      "duplicate_resource_path", "Installed resource paths must be unique."
    )
  }
  all_paths <- c(schema[["Installed-Catalog-Path"]], paths)
  if (anyDuplicated(tolower(all_paths))) {
    rrp_resource_abort(
      "case_resource_path_collision",
      "Installed resource paths collide after case folding."
    )
  }
  if (rrp_resource_path_conflict(all_paths)) {
    rrp_resource_abort(
      "resource_path_conflict",
      "Installed resource paths contain a file-directory conflict."
    )
  }

  schema_id <- which(ids == "rrp.contract.resource-catalog")
  if (length(schema_id) != 1L) {
    rrp_resource_abort(
      "missing_catalog_schema_resource",
      "Catalog schema resource declaration is missing."
    )
  }
  schema_entry <- entries[[schema_id]]
  expected_schema_entry <- c(
    "Resource-ID" = "rrp.contract.resource-catalog",
    "Resource-Class" = "contract",
    "Owner-Package" = "rrpplatform",
    "Installed-Path" = "resources/resource-catalog-schema.dcf",
    "Format" = "dcf"
  )
  for (field in names(expected_schema_entry)) {
    if (!identical(
      schema_entry[[field]], unname(expected_schema_entry[[field]])
    )) {
      rrp_resource_abort(
        "invalid_catalog_schema_resource",
        "Catalog schema resource declaration is invalid."
      )
    }
  }

  for (path in paths) {
    rrp_resource_concrete_file(root, path, "resource")
  }
  expected_files <- sort(unique(all_paths), method = "radix")
  if (!identical(rrp_resource_tree_files(root), expected_files)) {
    rrp_resource_abort(
      "closed_inventory_mismatch",
      "Installed resource inventory does not match the catalog."
    )
  }
  list(header = header, entries = entries)
}

rrp_resource_validate_root <- function(software_root) {
  if (!rrp_resource_scalar_string(software_root)) {
    rrp_resource_abort(
      "invalid_software_root", "Software root must be one explicit path."
    )
  }
  if (!dir.exists(software_root)) {
    rrp_resource_abort(
      "missing_software_root", "Explicit software root is missing."
    )
  }
  target <- Sys.readlink(software_root)
  if (!is.na(target) && nzchar(target)) {
    rrp_resource_abort(
      "linked_software_root", "Explicit software root must not be linked."
    )
  }
  normalizePath(software_root, winslash = "/", mustWork = TRUE)
}

#' Open an installed RRP resource catalog
#'
#' Validate the installed resource boundary beneath exactly one caller-supplied
#' software root. The function never discovers or selects a software root.
#'
#' @param software_root One explicit distribution-shaped software root.
#' @return A validated `rrp_resource_catalog` object.
#' @export
rrp_open_resource_catalog <- function(software_root) {
  root <- rrp_resource_validate_root(software_root)
  catalog_relative <- "resources/resource-catalog.dcf"
  schema_relative <- "resources/resource-catalog-schema.dcf"
  catalog_path <- rrp_resource_concrete_file(root, catalog_relative, "catalog")
  schema_path <- rrp_resource_concrete_file(root, schema_relative, "schema")
  schema <- rrp_resource_validate_schema(rrp_resource_read_dcf(
    schema_path, "malformed_schema", "Installed resource schema"
  ))
  catalog <- rrp_resource_validate_catalog(rrp_resource_read_dcf(
    catalog_path, "malformed_catalog", "Installed resource catalog"
  ), schema, root)
  structure(
    list(
      software_root = root,
      catalog_path = catalog_path,
      schema_path = schema_path,
      catalog = catalog
    ),
    class = c("rrp_resource_catalog", "list")
  )
}

rrp_resource_validate_catalog_object <- function(catalog) {
  fields <- c("software_root", "catalog_path", "schema_path", "catalog")
  if (!is.list(catalog) ||
      !identical(class(catalog), c("rrp_resource_catalog", "list")) ||
      !identical(names(catalog), fields) ||
      !rrp_resource_scalar_string(catalog$software_root)) {
    rrp_resource_abort(
      "invalid_catalog_object",
      "Resource lookup requires a validated resource catalog."
    )
  }
  root <- catalog$software_root
  expected_catalog <- rrp_resource_absolute(
    root, "resources/resource-catalog.dcf"
  )
  expected_schema <- rrp_resource_absolute(
    root, "resources/resource-catalog-schema.dcf"
  )
  if (!identical(catalog$catalog_path, expected_catalog) ||
      !identical(catalog$schema_path, expected_schema)) {
    rrp_resource_abort(
      "catalog_root_mismatch",
      "Resource catalog paths do not match the explicit software root."
    )
  }
  invisible(catalog)
}

#' Resolve an installed RRP resource
#'
#' Resolve one exact logical resource identity through a validated catalog.
#' The installed boundary is reopened before lookup so changed state fails
#' closed.
#'
#' @param catalog An object returned by [rrp_open_resource_catalog()].
#' @param resource_id One exact stable logical resource identity.
#' @return The normalized contained path to the declared regular resource file.
#' @export
rrp_resource_path <- function(catalog, resource_id) {
  rrp_resource_validate_catalog_object(catalog)
  if (!rrp_resource_scalar_string(resource_id) ||
      !grepl(
        "^rrp[.][a-z0-9]+(?:[.][a-z0-9-]+)+$", resource_id, perl = TRUE
      )) {
    rrp_resource_abort(
      "invalid_resource_id", "Resource identity is missing or malformed."
    )
  }
  current <- rrp_open_resource_catalog(catalog$software_root)
  if (!identical(current$catalog, catalog$catalog)) {
    rrp_resource_abort(
      "catalog_changed", "Installed resource catalog changed after opening."
    )
  }
  ids <- vapply(
    current$catalog$entries, `[[`, character(1L), "Resource-ID"
  )
  matched <- which(ids == resource_id)
  if (length(matched) != 1L) {
    rrp_resource_abort(
      "unknown_resource_id", "Resource identity is not declared."
    )
  }
  rrp_resource_concrete_file(
    current$software_root,
    current$catalog$entries[[matched]][["Installed-Path"]],
    "resource"
  )
}
