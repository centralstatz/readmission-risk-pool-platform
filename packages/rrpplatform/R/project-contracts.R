rrp_project_manifest_contract_expected <- function() {
  c(
    "Record-Type" = "project-manifest-contract",
    "Contract-ID" = "rrp.project",
    "Contract-Version" = "0.1.0",
    "Format-Version" = "1.0.0",
    "Product-ID" = "readmission-risk-pool-platform",
    "Development-Version" = "1.0.0-dev",
    "Status" = "development_unpublished",
    "Owner-Package" = "rrpplatform",
    "Manifest-Path" = "rrp-project.dcf",
    "Registration-Path" = "R/register.R",
    "Manifest-Record-Type" = "rrp-project",
    "Project-API-ID" = "rrp.project-api",
    "Project-API-Version" = "0.1.0",
    "Fields" = paste(c(
      "Record-Type", "Project-Contract-ID", "Project-Contract-Version",
      "Project-ID", "Project-Version", "Project-Scope",
      "Supported-RRP-API-Version", "Producer-ID", "Producer-Version",
      "Provider-ID", "Provider-Version", "Extension-Library-Path",
      "State-Path"
    ), collapse = ","),
    "Optional-Fields" = "none",
    "Identity-Fields" = "Project-ID,Producer-ID,Provider-ID",
    "Project-ID-Pattern" = "^[a-z][a-z0-9]*(?:[.-][a-z0-9]+)*$",
    "Identity-Max-Bytes" = "96",
    "Protected-Project-ID-Prefix" = "rrp.",
    "Version-Fields" = "Project-Version,Producer-Version,Provider-Version",
    "Version-Pattern" = paste0(
      "^[0-9]+[.][0-9]+[.][0-9]+",
      "(?:-[0-9A-Za-z]+(?:[.-][0-9A-Za-z]+)*)?$"
    ),
    "Version-Max-Bytes" = "64",
    "Project-Scope-Value" = "one_health_system",
    "Path-Fields" = "Extension-Library-Path,State-Path",
    "Path-Syntax" = "safe_relative_forward_segments",
    "Path-Case-Folded-Conflicts" = "prohibited",
    "Path-Overlap" = "prohibited",
    "Fixed-Path-Conflicts" = "rrp-project.dcf,R/register.R",
    "Unknown-Fields" = "prohibited",
    "Additional-Records" = "prohibited",
    "Multiline-Values" = "prohibited",
    "Secret-Or-Arbitrary-Content" = "prohibited"
  )
}

rrp_project_registration_contract_expected <- function() {
  c(
    "Record-Type" = "project-registration-contract",
    "Contract-ID" = "rrp.project-registration",
    "Contract-Version" = "0.1.0",
    "Format-Version" = "1.0.0",
    "Product-ID" = "readmission-risk-pool-platform",
    "Development-Version" = "1.0.0-dev",
    "Status" = "development_unpublished",
    "Owner-Package" = "rrpplatform",
    "Registration-Path" = "R/register.R",
    "Registration-Function" = "rrp_register_project",
    "Result-Fields" = paste(c(
      "registration_contract_id", "registration_contract_version",
      "project_id", "producers", "providers"
    ), collapse = ","),
    "Collection-Fields" = "producers,providers",
    "Collection-Representation" = "ordered_unnamed_list",
    "Empty-Collections" = "allowed",
    "Component-Fields" = "component_id,component_version,callable",
    "Project-ID-Pattern" = "^[a-z][a-z0-9]*(?:[.-][a-z0-9]+)*$",
    "Component-ID-Pattern" = "^[a-z][a-z0-9]*(?:[.-][a-z0-9]+)*$",
    "Identity-Max-Bytes" = "96",
    "Protected-ID-Prefix" = "rrp.",
    "Component-Version-Pattern" = paste0(
      "^[0-9]+[.][0-9]+[.][0-9]+",
      "(?:-[0-9A-Za-z]+(?:[.-][0-9A-Za-z]+)*)?$"
    ),
    "Component-Version-Max-Bytes" = "64",
    "Callable-Type" = "function",
    "Duplicate-Kind-ID-Version" = "prohibited",
    "Unknown-Component-Kinds" = "prohibited",
    "Additional-Result-Fields" = "prohibited",
    "Additional-Component-Fields" = "prohibited",
    "Callable-Invocation-During-Validation" = "prohibited"
  )
}

rrp_project_contract_record <- function(catalog, resource_id, expected, label) {
  path <- rrp_resource_path(catalog, resource_id)
  records <- rrp_resource_read_dcf(
    path, paste0("malformed_", label), paste0("Installed ", label)
  )
  if (length(records) != 1L) {
    rrp_resource_abort(
      paste0("malformed_", label),
      paste0("Installed ", label, " is malformed.")
    )
  }
  record <- records[[1L]]
  rrp_resource_require_fields(
    record, names(expected), paste0("invalid_", label, "_fields"),
    paste0("Installed ", label)
  )
  for (field in names(expected)) {
    if (!identical(record[[field]], unname(expected[[field]]))) {
      rrp_resource_abort(
        paste0("unsupported_", label),
        paste0("Installed ", label, " is unsupported.")
      )
    }
  }
  record
}

rrp_project_manifest_contract <- function(catalog) {
  rrp_project_contract_record(
    catalog, "rrp.contract.project-manifest",
    rrp_project_manifest_contract_expected(), "project_manifest_contract"
  )
}

rrp_project_registration_contract <- function(catalog) {
  rrp_project_contract_record(
    catalog, "rrp.contract.project-registration",
    rrp_project_registration_contract_expected(),
    "project_registration_contract"
  )
}

rrp_project_abort <- function(code, message) {
  if (!is.character(code) || length(code) != 1L || is.na(code) ||
      !grepl("^[a-z][a-z0-9_]*$", code) ||
      !is.character(message) || length(message) != 1L || is.na(message) ||
      !nzchar(message) || nchar(message, type = "bytes") > 160L ||
      grepl("[\r\n]", message)) {
    stop("Invalid internal project-error definition.", call. = FALSE)
  }
  stop(structure(
    list(message = message, call = NULL, code = code),
    class = c("rrp_project_error", "error", "condition")
  ))
}

rrp_project_stop <- function(message, code = "invalid_project_contract") {
  rrp_project_abort(code, message)
}

rrp_project_split_fields <- function(value) {
  strsplit(value, ",", fixed = TRUE)[[1L]]
}

rrp_project_plain_named_list <- function(value, fields) {
  is.list(value) && !is.null(names(value)) &&
    length(value) == length(names(value)) &&
    !anyDuplicated(names(value)) && all(nzchar(names(value))) &&
    setequal(names(value), fields) &&
    identical(setdiff(names(attributes(value)), "names"), character())
}

rrp_project_parse_dcf_record <- function(lines) {
  if (!is.character(lines) || length(lines) == 0L || anyNA(lines) ||
      any(!nzchar(lines)) || any(grepl("^[[:space:]]", lines)) ||
      !all(grepl(
        "^[A-Za-z][A-Za-z0-9-]*:[[:space:]]+[^[:space:]].*[^[:space:]]$|^[A-Za-z][A-Za-z0-9-]*:[[:space:]]+[^[:space:]]$",
        lines
      ))) {
    rrp_project_stop(
      "Project manifest is malformed.", "malformed_project_manifest"
    )
  }
  fields <- sub(":.*$", "", lines)
  if (anyDuplicated(fields)) {
    rrp_project_stop(
      "Project manifest is malformed.", "malformed_project_manifest"
    )
  }
  connection <- textConnection(lines)
  parsed <- tryCatch(
    read.dcf(connection, all = TRUE),
    error = function(condition) {
      rrp_project_stop(
        "Project manifest is malformed.", "malformed_project_manifest"
      )
    },
    finally = close(connection)
  )
  if (nrow(parsed) != 1L) {
    rrp_project_stop(
      "Project manifest is malformed.", "malformed_project_manifest"
    )
  }
  record <- as.list(as.character(parsed[1L, ]))
  names(record) <- colnames(parsed)
  record
}

rrp_project_scalar_string <- function(value) {
  is.character(value) && length(value) == 1L && !is.na(value) &&
    nzchar(value) && identical(value, trimws(value))
}

rrp_project_has_prohibited_content <- function(value) {
  patterns <- c(
    "[A-Za-z][A-Za-z0-9+.-]*://",
    "(?i)(^|[./_-])(passwords?|passwd|secrets?|credentials?|tokens?|authorization|bearer|access[-_.]?key|private[-_.]?key|patient|mrn)([./_-]|$)",
    "(?i)(^|[;[:space:]])(server|host|database|db|uid|user[[:space:]]*id|password|pwd)[[:space:]]*=",
    "(?i)-----BEGIN[[:space:]].*PRIVATE[[:space:]]KEY-----",
    "(?i)(^|[^A-Za-z0-9_])(source|system|system2|eval|parse|library|require|install[.]packages)[[:space:]]*[(]"
  )
  any(vapply(patterns, grepl, logical(1L), x = value, perl = TRUE))
}

rrp_project_valid_identity <- function(value, pattern, max_bytes) {
  rrp_project_scalar_string(value) &&
    nchar(value, type = "bytes") <= max_bytes &&
    grepl(pattern, value, perl = TRUE) &&
    !rrp_project_has_prohibited_content(value)
}

rrp_project_valid_version <- function(value, pattern, max_bytes) {
  rrp_project_scalar_string(value) &&
    nchar(value, type = "bytes") <= max_bytes &&
    grepl(pattern, value, perl = TRUE)
}

rrp_project_safe_relative_path <- function(path) {
  if (!rrp_project_scalar_string(path) ||
      grepl("[[:cntrl:]\\\\]", path) || startsWith(path, "/") ||
      grepl("^[A-Za-z]:", path) || startsWith(path, "~") ||
      startsWith(path, "//") || endsWith(path, "/") ||
      rrp_project_has_prohibited_content(path)) return(FALSE)
  segments <- strsplit(path, "/", fixed = TRUE)[[1L]]
  length(segments) > 0L && all(nzchar(segments)) &&
    !any(segments %in% c(".", ".."))
}

rrp_project_paths_overlap <- function(left, right) {
  left <- tolower(left)
  right <- tolower(right)
  identical(left, right) || startsWith(left, paste0(right, "/")) ||
    startsWith(right, paste0(left, "/"))
}

rrp_project_validate_manifest <- function(lines, contract) {
  expected_contract <- rrp_project_manifest_contract_expected()
  if (!is.list(contract) || !identical(names(contract), names(expected_contract)) ||
      !identical(unlist(contract, use.names = TRUE), expected_contract)) {
    rrp_project_stop(
      "Project manifest contract is unsupported.",
      "unsupported_project_contract"
    )
  }
  record <- rrp_project_parse_dcf_record(lines)
  fields <- rrp_project_split_fields(contract[["Fields"]])
  if (!rrp_project_plain_named_list(record, fields)) {
    rrp_project_stop(
      "Project manifest is malformed.", "malformed_project_manifest"
    )
  }
  record <- record[fields]
  contract_fixed <- c(
    "Record-Type" = contract[["Manifest-Record-Type"]],
    "Project-Contract-ID" = contract[["Contract-ID"]],
    "Project-Contract-Version" = contract[["Contract-Version"]],
    "Project-Scope" = contract[["Project-Scope-Value"]]
  )
  if (any(!vapply(names(contract_fixed), function(field) {
    identical(record[[field]], unname(contract_fixed[[field]]))
  }, logical(1L)))) {
    rrp_project_stop(
      "Project manifest contract is unsupported.",
      "unsupported_project_contract"
    )
  }
  if (!identical(
    record[["Supported-RRP-API-Version"]], contract[["Project-API-Version"]]
  )) {
    rrp_project_stop(
      "Project API compatibility is unsupported.", "incompatible_project_api"
    )
  }

  identity_pattern <- contract[["Project-ID-Pattern"]]
  identity_limit <- as.integer(contract[["Identity-Max-Bytes"]])
  for (field in rrp_project_split_fields(contract[["Identity-Fields"]])) {
    if (!rrp_project_valid_identity(
      record[[field]], identity_pattern, identity_limit
    )) {
      rrp_project_stop(
        "Project manifest is malformed.", "malformed_project_manifest"
      )
    }
  }
  if (startsWith(
    record[["Project-ID"]], contract[["Protected-Project-ID-Prefix"]]
  )) {
    rrp_project_stop(
      "Project manifest is malformed.", "malformed_project_manifest"
    )
  }
  version_pattern <- contract[["Version-Pattern"]]
  version_limit <- as.integer(contract[["Version-Max-Bytes"]])
  for (field in rrp_project_split_fields(contract[["Version-Fields"]])) {
    if (!rrp_project_valid_version(
      record[[field]], version_pattern, version_limit
    )) {
      rrp_project_stop(
        "Project manifest is malformed.", "malformed_project_manifest"
      )
    }
  }

  path_fields <- rrp_project_split_fields(contract[["Path-Fields"]])
  paths <- unlist(record[path_fields], use.names = FALSE)
  if (!all(vapply(paths, rrp_project_safe_relative_path, logical(1L)))) {
    rrp_project_stop("Project path declaration is unsafe.", "unsafe_project_path")
  }
  protected_paths <- rrp_project_split_fields(
    contract[["Fixed-Path-Conflicts"]]
  )
  combined_paths <- c(paths, protected_paths)
  comparisons <- list()
  for (left in seq_len(length(combined_paths) - 1L)) {
    for (right in (left + 1L):length(combined_paths)) {
      comparisons[[length(comparisons) + 1L]] <- combined_paths[c(left, right)]
    }
  }
  # The two fixed public files share no path relationship. Every overlap in the
  # combined set therefore represents a manifest-owned path conflict.
  if (any(vapply(comparisons, function(pair) {
    rrp_project_paths_overlap(pair[[1L]], pair[[2L]])
  }, logical(1L)))) {
    rrp_project_stop("Project path declaration is unsafe.", "unsafe_project_path")
  }
  record
}

rrp_project_validate_registration <- function(candidate, contract) {
  expected_contract <- rrp_project_registration_contract_expected()
  if (!is.list(contract) || !identical(names(contract), names(expected_contract)) ||
      !identical(unlist(contract, use.names = TRUE), expected_contract)) {
    rrp_project_stop(
      "Project registration result is invalid.", "invalid_registration_result"
    )
  }
  fields <- rrp_project_split_fields(contract[["Result-Fields"]])
  if (!rrp_project_plain_named_list(candidate, fields)) {
    rrp_project_stop(
      "Project registration result is invalid.", "invalid_registration_result"
    )
  }
  candidate <- candidate[fields]
  if (!identical(
    candidate$registration_contract_id, contract[["Contract-ID"]]
  ) || !identical(
    candidate$registration_contract_version, contract[["Contract-Version"]]
  )) {
    rrp_project_stop(
      "Project registration result is invalid.", "invalid_registration_result"
    )
  }
  identity_limit <- as.integer(contract[["Identity-Max-Bytes"]])
  if (!rrp_project_valid_identity(
    candidate$project_id, contract[["Project-ID-Pattern"]], identity_limit
  ) || startsWith(candidate$project_id, contract[["Protected-ID-Prefix"]])) {
    rrp_project_stop(
      "Project registration result is invalid.", "invalid_registration_result"
    )
  }

  component_fields <- rrp_project_split_fields(contract[["Component-Fields"]])
  for (kind in rrp_project_split_fields(contract[["Collection-Fields"]])) {
    entries <- candidate[[kind]]
    if (!is.list(entries) || !is.null(attributes(entries))) {
      rrp_project_stop(
        "Project registration result is invalid.", "invalid_registration_result"
      )
    }
    validated_entries <- lapply(entries, function(entry) {
      if (!rrp_project_plain_named_list(entry, component_fields)) {
        rrp_project_stop(
          "Project registration result is invalid.",
          "invalid_registration_result"
        )
      }
      entry <- entry[component_fields]
      if (!rrp_project_valid_identity(
        entry$component_id, contract[["Component-ID-Pattern"]], identity_limit
      ) || startsWith(
        entry$component_id, contract[["Protected-ID-Prefix"]]
      )) {
        code <- if (rrp_project_scalar_string(entry$component_id) &&
                    startsWith(
                      entry$component_id, contract[["Protected-ID-Prefix"]]
                    )) {
          "protected_registration"
        } else {
          "invalid_registration_result"
        }
        rrp_project_stop("Project registration identity is invalid.", code)
      }
      if (!rrp_project_valid_version(
        entry$component_version,
        contract[["Component-Version-Pattern"]],
        as.integer(contract[["Component-Version-Max-Bytes"]])
      )) {
        rrp_project_stop(
          "Project registration result is invalid.",
          "invalid_registration_result"
        )
      }
      if (!is.function(entry$callable)) {
        rrp_project_stop(
          "Project registration result is invalid.",
          "invalid_registration_result"
        )
      }
      entry
    })
    keys <- vapply(validated_entries, function(entry) {
      paste(entry$component_id, entry$component_version, sep = "@")
    }, character(1L))
    if (anyDuplicated(keys)) {
      rrp_project_stop(
        "Project registration identity is duplicated.",
        "duplicate_registration"
      )
    }
    candidate[[kind]] <- validated_entries
  }
  candidate
}
