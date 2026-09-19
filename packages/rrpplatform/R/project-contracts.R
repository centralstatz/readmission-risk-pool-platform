rrp_project_manifest_contract_expected <- function() {
  c(
    "Record-Type" = "project-manifest-contract",
    "Contract-ID" = "rrp.project",
    "Contract-Version" = "0.3.0",
    "Format-Version" = "1.0.0",
    "Product-ID" = "readmission-risk-pool-platform",
    "Development-Version" = "1.0.0-dev",
    "Status" = "development_unpublished",
    "Owner-Package" = "rrpplatform",
    "Manifest-Path" = "rrp-project.dcf",
    "Registration-Path" = "R/register.R",
    "Manifest-Record-Type" = "rrp-project",
    "Project-API-ID" = "rrp.project-api",
    "Project-API-Version" = "0.3.0",
    "Fields" = paste(c(
      "Record-Type", "Project-Contract-ID", "Project-Contract-Version",
      "Project-ID", "Project-Version", "Project-Scope",
      "Supported-RRP-API-Version", "Canonical-Profile-ID",
      "Canonical-Profile-Version", "Producer-ID", "Producer-Version",
      "Provider-ID", "Provider-Version", "Extension-Library-Path", "State-Path"
    ), collapse = ","),
    "Optional-Fields" = "none",
    "Identity-Fields" = "Project-ID,Producer-ID,Provider-ID",
    "Project-ID-Pattern" = "^[a-z][a-z0-9]*(?:[.-][a-z0-9]+)*$",
    "Identity-Max-Bytes" = "96",
    "Protected-Project-ID-Prefix" = "rrp.",
    "Version-Fields" = paste(c(
      "Project-Version", "Canonical-Profile-Version", "Producer-Version",
      "Provider-Version"
    ), collapse = ","),
    "Version-Pattern" = paste0(
      "^[0-9]+[.][0-9]+[.][0-9]+",
      "(?:-[0-9A-Za-z]+(?:[.-][0-9A-Za-z]+)*)?$"
    ),
    "Version-Max-Bytes" = "64",
    "Project-Scope-Value" = "one_health_system",
    "Canonical-Profile-ID-Value" = "rrp.canonical-profile.readmission",
    "Canonical-Profile-Version-Value" = "0.1.0",
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
    "Contract-Version" = "0.3.0",
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
    "Producer-Fields" = paste(c(
      "component_id", "component_version", "producer_api_id",
      "producer_api_version", "canonical_bundle_id",
      "canonical_bundle_version", "canonical_profile_id",
      "canonical_profile_version", "implementation_id",
      "implementation_version", "mapping_id", "mapping_version",
      "capabilities", "callable"
    ), collapse = ","),
    "Provider-Fields" = paste(c(
      "component_id", "component_version", "provider_api_id",
      "provider_api_version", "target_id", "target_version",
      "state_contract_id", "state_contract_version", "request_contract_id",
      "request_contract_version", "estimate_contract_id",
      "estimate_contract_version", "implementation_id",
      "implementation_version", "model_id", "model_version", "callable"
    ), collapse = ","),
    "Capability-Fields" = "capability_id,status",
    "Producer-API-ID" = "rrp.producer-api",
    "Producer-API-Version" = "0.1.0",
    "Canonical-Bundle-ID" = "rrp.canonical-bundle",
    "Canonical-Bundle-Version" = "0.1.0",
    "Canonical-Profile-ID" = "rrp.canonical-profile.readmission",
    "Canonical-Profile-Version" = "0.1.0",
    "Provider-API-ID" = "rrp.provider-api",
    "Provider-API-Version" = "0.1.0",
    "Target-ID" = "rrp.risk-target.readmission-remaining-30-day",
    "Target-Version" = "0.1.0",
    "State-Contract-ID" = "rrp.episode-state",
    "State-Contract-Version" = "0.1.0",
    "Request-Contract-ID" = "rrp.risk-request",
    "Request-Contract-Version" = "0.1.0",
    "Estimate-Contract-ID" = "rrp.risk-estimate",
    "Estimate-Contract-Version" = "0.1.0",
    "Model-Identity-Rule" = "both_null_or_both_bounded",
    "Required-Capability-IDs" = paste(c(
      "rrp.capability.discharge-episode", "rrp.capability.terminal-event"
    ), collapse = ","),
    "Capability-Status-Value" = "available",
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
    "Additional-Producer-Fields" = "prohibited",
    "Additional-Provider-Fields" = "prohibited",
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
    "Project-Scope" = contract[["Project-Scope-Value"]],
    "Canonical-Profile-ID" = contract[["Canonical-Profile-ID-Value"]],
    "Canonical-Profile-Version" = contract[["Canonical-Profile-Version-Value"]]
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

rrp_project_validate_component_identity <- function(entry, contract) {
  identity_limit <- as.integer(contract[["Identity-Max-Bytes"]])
  if (!rrp_project_valid_identity(
    entry$component_id, contract[["Component-ID-Pattern"]], identity_limit
  ) || startsWith(entry$component_id, contract[["Protected-ID-Prefix"]])) {
    code <- if (rrp_project_scalar_string(entry$component_id) &&
                startsWith(entry$component_id, contract[["Protected-ID-Prefix"]])) {
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
      "Project registration result is invalid.", "invalid_registration_result"
    )
  }
  if (!is.function(entry$callable)) {
    rrp_project_stop(
      "Project registration result is invalid.", "invalid_registration_result"
    )
  }
  entry
}

rrp_project_validate_capabilities <- function(capabilities, contract) {
  if (!is.list(capabilities) || !is.null(attributes(capabilities))) {
    rrp_project_stop(
      "Producer capability declaration is invalid.",
      "invalid_producer_declaration"
    )
  }
  fields <- rrp_project_split_fields(contract[["Capability-Fields"]])
  validated <- lapply(capabilities, function(capability) {
    if (!rrp_project_plain_named_list(capability, fields)) {
      rrp_project_stop(
        "Producer capability declaration is invalid.",
        "invalid_producer_declaration"
      )
    }
    capability <- capability[fields]
    if (!rrp_project_scalar_string(capability$capability_id) ||
        !identical(
          capability$status, contract[["Capability-Status-Value"]]
        )) {
      rrp_project_stop(
        "Producer capability declaration is invalid.",
        "invalid_producer_declaration"
      )
    }
    capability
  })
  ids <- vapply(validated, `[[`, character(1L), "capability_id")
  if (anyDuplicated(ids)) {
    rrp_project_stop(
      "Producer capability declaration is duplicated.",
      "duplicate_capability_declaration"
    )
  }
  required <- rrp_project_split_fields(contract[["Required-Capability-IDs"]])
  if (!setequal(ids, required)) {
    rrp_project_stop(
      "Producer capability declaration is incompatible.",
      "incompatible_producer_capabilities"
    )
  }
  validated[match(required, ids)]
}

rrp_project_validate_producer <- function(entry, contract, manifest) {
  fields <- rrp_project_split_fields(contract[["Producer-Fields"]])
  if (!rrp_project_plain_named_list(entry, fields)) {
    rrp_project_stop(
      "Producer declaration is invalid.", "invalid_producer_declaration"
    )
  }
  entry <- entry[fields]
  entry <- rrp_project_validate_component_identity(entry, contract)
  fixed <- c(
    "producer_api_id" = contract[["Producer-API-ID"]],
    "producer_api_version" = contract[["Producer-API-Version"]],
    "canonical_bundle_id" = contract[["Canonical-Bundle-ID"]],
    "canonical_bundle_version" = contract[["Canonical-Bundle-Version"]],
    "canonical_profile_id" = contract[["Canonical-Profile-ID"]],
    "canonical_profile_version" = contract[["Canonical-Profile-Version"]]
  )
  if (any(!vapply(names(fixed), function(field) {
    identical(entry[[field]], unname(fixed[[field]]))
  }, logical(1L)))) {
    rrp_project_stop(
      "Producer declaration is incompatible.",
      "incompatible_producer_declaration"
    )
  }
  if (!is.null(manifest) && (!identical(
    entry$canonical_profile_id, manifest[["Canonical-Profile-ID"]]
  ) || !identical(
    entry$canonical_profile_version, manifest[["Canonical-Profile-Version"]]
  ))) {
    rrp_project_stop(
      "Producer canonical profile does not match the manifest.",
      "producer_profile_mismatch"
    )
  }
  identity_limit <- as.integer(contract[["Identity-Max-Bytes"]])
  version_limit <- as.integer(contract[["Component-Version-Max-Bytes"]])
  for (field in c("implementation_id", "mapping_id")) {
    if (!rrp_project_valid_identity(
      entry[[field]], contract[["Component-ID-Pattern"]], identity_limit
    ) || startsWith(entry[[field]], contract[["Protected-ID-Prefix"]])) {
      rrp_project_stop(
        "Producer implementation or mapping identity is invalid.",
        "invalid_producer_declaration"
      )
    }
  }
  for (field in c("implementation_version", "mapping_version")) {
    if (!rrp_project_valid_version(
      entry[[field]], contract[["Component-Version-Pattern"]], version_limit
    )) {
      rrp_project_stop(
        "Producer implementation or mapping version is invalid.",
        "invalid_producer_declaration"
      )
    }
  }
  entry$capabilities <- rrp_project_validate_capabilities(
    entry$capabilities, contract
  )
  entry
}

rrp_project_validate_provider <- function(entry, contract, runtime_contracts) {
  fields <- rrp_project_split_fields(contract[["Provider-Fields"]])
  if (!rrp_project_plain_named_list(entry, fields)) {
    rrp_project_stop(
      "Project registration result is invalid.", "invalid_registration_result"
    )
  }
  entry <- rrp_project_validate_component_identity(entry[fields], contract)
  fixed <- c(
    provider_api_id = "Provider-API-ID",
    provider_api_version = "Provider-API-Version",
    target_id = "Target-ID", target_version = "Target-Version",
    state_contract_id = "State-Contract-ID",
    state_contract_version = "State-Contract-Version",
    request_contract_id = "Request-Contract-ID",
    request_contract_version = "Request-Contract-Version",
    estimate_contract_id = "Estimate-Contract-ID",
    estimate_contract_version = "Estimate-Contract-Version"
  )
  if (any(!vapply(names(fixed), function(field) {
    identical(entry[[field]], contract[[fixed[[field]]]])
  }, logical(1L)))) {
    rrp_project_stop(
      "Provider declaration is incompatible.",
      "incompatible_provider_declaration"
    )
  }
  identity_limit <- as.integer(contract[["Identity-Max-Bytes"]])
  version_limit <- as.integer(contract[["Component-Version-Max-Bytes"]])
  if (!rrp_project_valid_identity(
    entry$implementation_id, contract[["Component-ID-Pattern"]],
    identity_limit
  ) || startsWith(entry$implementation_id, contract[["Protected-ID-Prefix"]]) ||
      !rrp_project_valid_version(
        entry$implementation_version,
        contract[["Component-Version-Pattern"]], version_limit
      )) {
    rrp_project_stop(
      "Provider implementation identity is invalid.",
      "invalid_provider_declaration"
    )
  }
  model_null <- is.null(entry$model_id) && is.null(entry$model_version)
  model_set <- rrp_project_valid_identity(
    entry$model_id, contract[["Component-ID-Pattern"]], identity_limit
  ) && !startsWith(entry$model_id, contract[["Protected-ID-Prefix"]]) &&
    rrp_project_valid_version(
      entry$model_version, contract[["Component-Version-Pattern"]],
      version_limit
    )
  if (!model_null && !model_set) {
    rrp_project_stop(
      "Provider model identity is invalid.", "invalid_provider_declaration"
    )
  }
  arguments <- formals(entry$callable)
  if (!identical(names(arguments), "request")) {
    rrp_project_stop(
      "Provider callable is invalid.", "invalid_provider_declaration"
    )
  }
  expected_runtime <- list(
    provider_api_id = runtime_contracts$risk_provider[["Specification-ID"]],
    provider_api_version = runtime_contracts$risk_provider[["Specification-Version"]],
    target_id = runtime_contracts$readmission_risk_target[["Specification-ID"]],
    target_version = runtime_contracts$readmission_risk_target[["Specification-Version"]],
    state_contract_id = runtime_contracts$episode_state[["Specification-ID"]],
    state_contract_version = runtime_contracts$episode_state[["Specification-Version"]],
    request_contract_id = runtime_contracts$risk_request[["Specification-ID"]],
    request_contract_version = runtime_contracts$risk_request[["Specification-Version"]],
    estimate_contract_id = runtime_contracts$risk_estimate[["Specification-ID"]],
    estimate_contract_version = runtime_contracts$risk_estimate[["Specification-Version"]]
  )
  if (any(!vapply(names(expected_runtime), function(field) {
    identical(entry[[field]], expected_runtime[[field]])
  }, logical(1L)))) {
    rrp_project_stop(
      "Provider declaration is incompatible.",
      "incompatible_provider_declaration"
    )
  }
  entry
}

rrp_project_validate_registration <- function(
  candidate,
  contract,
  canonical_contracts,
  runtime_contracts,
  manifest = NULL
) {
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

  for (kind in rrp_project_split_fields(contract[["Collection-Fields"]])) {
    entries <- candidate[[kind]]
    if (!is.list(entries) || !is.null(attributes(entries))) {
      rrp_project_stop(
        "Project registration result is invalid.", "invalid_registration_result"
      )
    }
    validated_entries <- if (identical(kind, "producers")) {
      lapply(entries, rrp_project_validate_producer,
             contract = contract, manifest = manifest)
    } else {
      lapply(
        entries, rrp_project_validate_provider, contract = contract,
        runtime_contracts = runtime_contracts
      )
    }
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
  if (!is.list(canonical_contracts) || !identical(
    canonical_contracts$canonical_producer[["Producer-API-ID"]],
    contract[["Producer-API-ID"]]
  ) || !identical(
    canonical_contracts$canonical_producer[["Producer-API-Version"]],
    contract[["Producer-API-Version"]]
  ) || !identical(
    canonical_contracts$canonical_producer[["Canonical-Bundle-ID"]],
    contract[["Canonical-Bundle-ID"]]
  ) || !identical(
    canonical_contracts$canonical_producer[["Canonical-Bundle-Version"]],
    contract[["Canonical-Bundle-Version"]]
  ) || !identical(
    canonical_contracts$canonical_producer[["Canonical-Profile-ID"]],
    contract[["Canonical-Profile-ID"]]
  ) || !identical(
    canonical_contracts$canonical_producer[["Canonical-Profile-Version"]],
    contract[["Canonical-Profile-Version"]]
  ) || !identical(
    canonical_contracts$canonical_producer[["Required-Capability-IDs"]],
    contract[["Required-Capability-IDs"]]
  )) {
    rrp_project_stop(
      "Producer declaration contract is incompatible.",
      "incompatible_producer_declaration"
    )
  }
  if (!is.list(runtime_contracts) || !all(c(
    "readmission_risk_target", "episode_state", "risk_request",
    "risk_provider", "risk_estimate"
  ) %in% names(runtime_contracts))) {
    rrp_project_stop(
      "Provider declaration contract is incompatible.",
      "incompatible_provider_declaration"
    )
  }
  candidate
}
