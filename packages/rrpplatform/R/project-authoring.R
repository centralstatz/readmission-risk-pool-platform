rrp_authoring_contract_expected <- function() {
  c(
    "Record-Type" = "project-authoring-contract",
    "Contract-ID" = "rrp.project-authoring",
    "Contract-Version" = "0.1.0",
    "Format-Version" = "1.0.0",
    "Product-ID" = "readmission-risk-pool-platform",
    "Development-Version" = "1.0.0-dev",
    "Status" = "development_unpublished",
    "Owner-Package" = "rrpplatform",
    "Project-Contract-ID" = "rrp.project",
    "Project-Contract-Version" = "0.3.0",
    "Registration-Contract-ID" = "rrp.project-registration",
    "Registration-Contract-Version" = "0.3.0",
    "Metadata-Path" = "rrp-authoring.dcf",
    "Registration-Path" = "R/register.R",
    "Producer-Path" = "R/produce-canonical.R",
    "Provider-Path" = "R/calculate-risk.R",
    "Readme-Path" = "README.md",
    "Standard-Paths" = paste(c(
      "rrp-project.dcf", "rrp-authoring.dcf", "R/register.R",
      "R/produce-canonical.R", "R/calculate-risk.R", "README.md"
    ), collapse = ","),
    "Producer-Binding" = "rrp_produce_canonical",
    "Producer-Arguments" = "project_root,as_of_time",
    "Producer-Success-Fields" = "discharge_episode,terminal_event",
    "Provider-Binding" = "rrp_calculate_risk",
    "Provider-Arguments" = "project_root,request",
    "Provider-Success-Type" = "finite_unclassed_base_double_probability",
    "Failure-Class" = "rrp_authoring_failure,list",
    "Producer-Failure-Codes" = paste(c(
      "producer_unavailable", "producer_source_failed",
      "producer_mapping_failed"
    ), collapse = ","),
    "Provider-Failure-Codes" = paste(c(
      "provider_unavailable", "provider_input_unavailable",
      "provider_calculation_failed"
    ), collapse = ","),
    "Metadata-Record-Type" = "rrp-project-authoring",
    "Metadata-Required-Fields" = paste(c(
      "Record-Type", "Authoring-Contract-ID", "Authoring-Contract-Version",
      "Producer-Implementation-ID", "Producer-Implementation-Version",
      "Mapping-ID", "Mapping-Version", "Provider-Implementation-ID",
      "Provider-Implementation-Version", "Extension-Packages"
    ), collapse = ","),
    "Metadata-Optional-Fields" = "Model-ID,Model-Version",
    "Extension-Inventory-Encoding" =
      "none_or_comma_separated_package_at_version",
    "Extension-Empty-Value" = "none",
    "Package-Name-Pattern" = "^[A-Za-z][A-Za-z0-9.]*[A-Za-z0-9]$",
    "Package-Version-Pattern" = "^[0-9]+(?:[.-][0-9A-Za-z]+)*$",
    "Identity-Pattern" = "^[a-z][a-z0-9]*(?:[.-][a-z0-9]+)*$",
    "Identity-Max-Bytes" = "96",
    "Version-Pattern" = paste0(
      "^[0-9]+[.][0-9]+[.][0-9]+",
      "(?:-[0-9A-Za-z]+(?:[.-][0-9A-Za-z]+)*)?$"
    ),
    "Version-Max-Bytes" = "64",
    "Protected-ID-Prefix" = "rrp.",
    "Bundle-Identity-Algorithm" = "dual_modular_hash_v1",
    "Bundle-Identity-Prefix" = "rrp.bundle.",
    "Bundle-Identity-Encoding" = "length_delimited_utf8_v1",
    "Bundle-Identity-Inputs" = paste(c(
      "producer_request", "producer_implementation_identity",
      "mapping_identity", "canonical_domain_content"
    ), collapse = ","),
    "Raw-Producer-Adaptation" = "rrp.canonical-producer@0.1.0",
    "Raw-Provider-Adaptation" = "rrp.provider-api@0.1.0",
    "Unknown-Metadata-Fields" = "prohibited",
    "Extra-Authoring-Bindings" = "prohibited",
    "Callable-Invocation-During-Registration" = "prohibited"
  )
}

rrp_authoring_contract <- function(catalog) {
  rrp_project_contract_record(
    catalog, "rrp.contract.project-authoring",
    rrp_authoring_contract_expected(), "project_authoring_contract"
  )
}

rrp_authoring_abort <- function(code, message) {
  if (!is.character(code) || length(code) != 1L || is.na(code) ||
      !grepl("^[a-z][a-z0-9_]*$", code) ||
      !is.character(message) || length(message) != 1L || is.na(message) ||
      !nzchar(message) || nchar(message, type = "bytes") > 160L ||
      grepl("[\r\n]", message)) {
    stop("Invalid internal authoring-error definition.", call. = FALSE)
  }
  stop(structure(
    list(message = message, call = NULL, code = code),
    class = c(
      "rrp_authoring_error", "rrp_project_error", "error", "condition"
    )
  ))
}

rrp_authoring_active_context <- local({
  context <- NULL
  list(
    get = function() context,
    with = function(value, callback) {
      previous <- context
      context <<- value
      on.exit(context <<- previous, add = TRUE)
      callback()
    }
  )
})

rrp_authoring_with_context <- function(catalog, project_root, callback) {
  rrp_authoring_active_context$with(
    list(catalog = catalog, project_root = project_root), callback
  )
}

rrp_authoring_split <- function(value) {
  strsplit(value, ",", fixed = TRUE)[[1L]]
}

rrp_authoring_parse_metadata <- function(path, contract) {
  lines <- tryCatch(
    readLines(path, warn = FALSE, encoding = "UTF-8"),
    error = function(condition) rrp_authoring_abort(
      "malformed_authoring_metadata", "Project authoring metadata is malformed."
    )
  )
  if (length(lines) == 0L || anyNA(lines) || any(!nzchar(lines)) ||
      any(grepl("^[[:space:]]", lines)) || !all(grepl(
        "^[A-Za-z][A-Za-z0-9-]*:[[:space:]]+[^[:space:]].*$", lines
      ))) {
    rrp_authoring_abort(
      "malformed_authoring_metadata", "Project authoring metadata is malformed."
    )
  }
  fields <- sub(":.*$", "", lines)
  if (anyDuplicated(fields)) {
    rrp_authoring_abort(
      "malformed_authoring_metadata", "Project authoring metadata is malformed."
    )
  }
  connection <- textConnection(lines)
  parsed <- tryCatch(
    read.dcf(connection, all = TRUE),
    error = function(condition) rrp_authoring_abort(
      "malformed_authoring_metadata", "Project authoring metadata is malformed."
    ),
    finally = close(connection)
  )
  if (nrow(parsed) != 1L) {
    rrp_authoring_abort(
      "malformed_authoring_metadata", "Project authoring metadata is malformed."
    )
  }
  record <- as.list(as.character(parsed[1L, ]))
  names(record) <- colnames(parsed)
  required <- rrp_authoring_split(contract[["Metadata-Required-Fields"]])
  optional <- rrp_authoring_split(contract[["Metadata-Optional-Fields"]])
  has_optional <- optional %in% names(record)
  if (length(setdiff(required, names(record))) > 0L ||
      length(setdiff(names(record), c(required, optional))) > 0L ||
      (any(has_optional) && !all(has_optional))) {
    rrp_authoring_abort(
      "malformed_authoring_metadata", "Project authoring metadata is malformed."
    )
  }
  record
}

rrp_authoring_validate_metadata <- function(record, contract) {
  fixed <- c(
    "Record-Type" = contract[["Metadata-Record-Type"]],
    "Authoring-Contract-ID" = contract[["Contract-ID"]],
    "Authoring-Contract-Version" = contract[["Contract-Version"]]
  )
  if (any(!vapply(names(fixed), function(field) {
    identical(record[[field]], unname(fixed[[field]]))
  }, logical(1L)))) {
    rrp_authoring_abort(
      "unsupported_authoring_contract", "Project authoring contract is unsupported."
    )
  }

  identity_fields <- c(
    "Producer-Implementation-ID", "Mapping-ID", "Provider-Implementation-ID"
  )
  if ("Model-ID" %in% names(record)) identity_fields <- c(
    identity_fields, "Model-ID"
  )
  version_fields <- c(
    "Producer-Implementation-Version", "Mapping-Version",
    "Provider-Implementation-Version"
  )
  if ("Model-Version" %in% names(record)) version_fields <- c(
    version_fields, "Model-Version"
  )
  valid_id <- function(value) {
    rrp_project_valid_identity(
      value, contract[["Identity-Pattern"]],
      as.integer(contract[["Identity-Max-Bytes"]])
    ) && !startsWith(value, contract[["Protected-ID-Prefix"]])
  }
  valid_version <- function(value) rrp_project_valid_version(
    value, contract[["Version-Pattern"]],
    as.integer(contract[["Version-Max-Bytes"]])
  )
  if (any(!vapply(record[identity_fields], valid_id, logical(1L))) ||
      any(!vapply(record[version_fields], valid_version, logical(1L)))) {
    rrp_authoring_abort(
      "invalid_authoring_metadata", "Project authoring metadata is invalid."
    )
  }
  record
}

rrp_authoring_dependencies <- function(value, contract) {
  if (!rrp_project_scalar_string(value)) {
    rrp_authoring_abort(
      "invalid_extension_inventory", "Project extension inventory is invalid."
    )
  }
  if (identical(value, contract[["Extension-Empty-Value"]])) return(list())
  entries <- strsplit(value, ",", fixed = TRUE)[[1L]]
  parsed <- lapply(entries, function(entry) {
    parts <- strsplit(entry, "@", fixed = TRUE)[[1L]]
    if (length(parts) != 2L || any(!nzchar(parts)) ||
        !grepl(contract[["Package-Name-Pattern"]], parts[[1L]], perl = TRUE) ||
        !grepl(contract[["Package-Version-Pattern"]], parts[[2L]], perl = TRUE)) {
      rrp_authoring_abort(
        "invalid_extension_inventory", "Project extension inventory is invalid."
      )
    }
    list(package = parts[[1L]], version = parts[[2L]])
  })
  packages <- vapply(parsed, `[[`, character(1L), "package")
  if (anyDuplicated(tolower(packages)) ||
      any(tolower(packages) %in% c("rrpplatform", "rrpruntime"))) {
    rrp_authoring_abort(
      "invalid_extension_inventory", "Project extension inventory is invalid."
    )
  }
  parsed
}

rrp_authoring_validate_dependencies <- function(inventory, extension_path) {
  declared <- vapply(inventory, `[[`, character(1L), "package")
  if (!dir.exists(extension_path)) {
    if (length(inventory) > 0L) rrp_authoring_abort(
      "missing_extension_package", "A declared project extension is unavailable."
    )
    return(invisible(inventory))
  }
  entries <- list.files(
    extension_path, all.files = TRUE, no.. = TRUE, full.names = FALSE
  )
  if (!identical(sort(entries, method = "radix"),
                 sort(declared, method = "radix"))) {
    rrp_authoring_abort(
      "invalid_extension_inventory", "Project extension inventory is invalid."
    )
  }
  for (dependency in inventory) {
    package_root <- file.path(extension_path, dependency$package)
    description <- file.path(package_root, "DESCRIPTION")
    linked <- nzchar(Sys.readlink(package_root)) || nzchar(Sys.readlink(description))
    if (!dir.exists(package_root) || !file.exists(description) ||
        dir.exists(description) || linked) {
      rrp_authoring_abort(
        "missing_extension_package", "A declared project extension is unavailable."
      )
    }
    metadata <- tryCatch(
      read.dcf(description, fields = c("Package", "Version")),
      error = function(condition) NULL
    )
    if (is.null(metadata) || nrow(metadata) != 1L ||
        !identical(metadata[[1L, "Package"]], dependency$package)) {
      rrp_authoring_abort(
        "missing_extension_package", "A declared project extension is unavailable."
      )
    }
    if (!identical(metadata[[1L, "Version"]], dependency$version)) {
      rrp_authoring_abort(
        "extension_version_mismatch", "A project extension version is incompatible."
      )
    }
  }
  invisible(inventory)
}

rrp_authoring_evaluate_callable <- function(
  root, relative_path, binding, arguments, label
) {
  path <- tryCatch(
    rrp_project_resolve_filesystem_path(
      root = root, relative_path = relative_path,
      missing_code = "missing_authoring_file",
      linked_code = "linked_authoring_file",
      invalid_code = "invalid_authoring_path",
      label = label, must_exist = TRUE, expected_directory = FALSE
    ),
    rrp_project_error = function(condition) rrp_authoring_abort(
      condition$code, paste0(label, " is invalid.")
    )
  )
  environment <- new.env(parent = baseenv())
  tryCatch(
    sys.source(path, envir = environment, chdir = FALSE, keep.source = FALSE),
    error = function(condition) rrp_authoring_abort(
      "malformed_authoring_file", paste0(label, " is malformed.")
    )
  )
  bindings <- ls(environment, all.names = TRUE)
  if (!identical(bindings, binding)) {
    rrp_authoring_abort(
      "invalid_authoring_binding", paste0(label, " binding is invalid.")
    )
  }
  callable <- get(binding, envir = environment, inherits = FALSE)
  expected_arguments <- rrp_authoring_split(arguments)
  if (!is.function(callable) ||
      !identical(names(formals(callable)), expected_arguments) ||
      any(!vapply(formals(callable), identical, logical(1L), quote(expr = )))) {
    rrp_authoring_abort(
      "invalid_authoring_signature", paste0(label, " signature is invalid.")
    )
  }
  callable
}

rrp_authoring_failure_valid <- function(value) {
  is.list(value) && identical(names(value), "code") &&
    identical(class(value), c("rrp_authoring_failure", "list")) &&
    rrp_project_scalar_string(value$code)
}

#' Construct one intentional standard-authoring failure
#'
#' Return a closed failure token carrying only one existing producer or provider
#' failure code. The applicable adapter validates the code again against its raw
#' contract; arbitrary text and details are never admitted.
#'
#' @param code One admitted producer or provider failure code.
#' @return One closed `rrp_authoring_failure` value.
#' @export
rrp_authoring_failure <- function(code) {
  admitted <- c(
    "producer_unavailable", "producer_source_failed",
    "producer_mapping_failed", "provider_unavailable",
    "provider_input_unavailable", "provider_calculation_failed"
  )
  if (!rrp_project_scalar_string(code) || !code %in% admitted) {
    rrp_authoring_abort(
      "invalid_authoring_failure", "Authoring failure code is invalid."
    )
  }
  structure(list(code = code), class = c("rrp_authoring_failure", "list"))
}

rrp_authoring_capabilities <- function() {
  list(
    list(
      capability_id = "rrp.capability.discharge-episode", status = "available"
    ),
    list(
      capability_id = "rrp.capability.terminal-event", status = "available"
    )
  )
}

rrp_authoring_segment <- function(value) {
  value <- enc2utf8(as.character(value))
  paste0(nchar(value, type = "bytes"), ":", value)
}

rrp_authoring_domain_tokens <- function(name, value) {
  tokens <- c("domain", name, as.character(nrow(value)), names(value))
  for (field in names(value)) {
    column <- value[[field]]
    tokens <- c(tokens, "column", field, as.character(length(column)))
    for (item in column) {
      tokens <- c(tokens, if (is.na(item)) "missing" else "value")
      if (!is.na(item)) tokens <- c(tokens, item)
    }
  }
  tokens
}

rrp_authoring_hash <- function(value, multiplier, modulus) {
  bytes <- as.integer(charToRaw(enc2utf8(value)))
  hash <- 0
  for (byte in bytes) hash <- (hash * multiplier + byte + 1) %% modulus
  as.integer(hash)
}

rrp_authoring_bundle_identity <- function(request, metadata, domains) {
  tokens <- c(
    "rrp.standard-bundle-identity", "1",
    "producer-request", names(request), unlist(request, use.names = FALSE),
    "producer-implementation",
    metadata[["Producer-Implementation-ID"]],
    metadata[["Producer-Implementation-Version"]],
    "mapping", metadata[["Mapping-ID"]], metadata[["Mapping-Version"]],
    rrp_authoring_domain_tokens("discharge_episode", domains$discharge_episode),
    rrp_authoring_domain_tokens("terminal_event", domains$terminal_event)
  )
  encoded <- paste(vapply(tokens, rrp_authoring_segment, character(1L)),
                   collapse = "|")
  first <- rrp_authoring_hash(encoded, 257, 2147483629)
  second <- rrp_authoring_hash(encoded, 263, 2147483587)
  paste0("rrp.bundle.", sprintf("%08x%08x", first, second))
}

rrp_authoring_valid_domains <- function(value) {
  fields <- list(
    discharge_episode = c(
      "episode_id", "patient_id", "index_encounter_id", "admission_time",
      "discharge_time", "followup_window_end"
    ),
    terminal_event = c(
      "terminal_event_id", "episode_id", "event_type", "occurred_at",
      "available_at"
    )
  )
  rrp_producer_plain_named_list(value, names(fields)) &&
    all(vapply(names(fields), function(name) {
      domain <- value[[name]]
      is.data.frame(domain) && identical(class(domain), "data.frame") &&
        identical(names(domain), fields[[name]]) &&
        all(vapply(domain, is.character, logical(1L)))
    }, logical(1L)))
}

rrp_authoring_producer_result <- function(
  request, manifest, metadata, authored_producer
) {
  capabilities <- rrp_authoring_capabilities()
  common <- list(
    producer_contract_id = "rrp.canonical-producer",
    producer_contract_version = "0.1.0",
    producer_id = manifest[["Producer-ID"]],
    producer_version = manifest[["Producer-Version"]],
    implementation_id = metadata[["Producer-Implementation-ID"]],
    implementation_version = metadata[["Producer-Implementation-Version"]],
    mapping_id = metadata[["Mapping-ID"]],
    mapping_version = metadata[["Mapping-Version"]],
    canonical_profile_id = manifest[["Canonical-Profile-ID"]],
    canonical_profile_version = manifest[["Canonical-Profile-Version"]],
    canonical_as_of_time = request$as_of_time,
    capabilities = capabilities
  )
  value <- authored_producer(request$project_root, request$as_of_time)
  if (rrp_authoring_failure_valid(value)) return(c(
    common[1:2], list(status = "failed"), common[-(1:2)],
    list(candidate_bundle = NULL, failure_code = value$code)
  ))
  if (!rrp_authoring_valid_domains(value)) return(c(
    common[1:2], list(status = "succeeded"), common[-(1:2)],
    list(candidate_bundle = NULL, failure_code = NULL)
  ))
  candidate <- list(
    bundle_contract_id = "rrp.canonical-bundle",
    bundle_contract_version = "0.1.0",
    bundle_instance_id = rrp_authoring_bundle_identity(
      request[setdiff(names(request), "project_root")], metadata, value
    ),
    project_id = request$project_id,
    project_version = request$project_version,
    producer_id = request$producer_id,
    producer_version = request$producer_version,
    implementation_id = metadata[["Producer-Implementation-ID"]],
    implementation_version = metadata[["Producer-Implementation-Version"]],
    mapping_id = metadata[["Mapping-ID"]],
    mapping_version = metadata[["Mapping-Version"]],
    canonical_profile_id = request$canonical_profile_id,
    canonical_profile_version = request$canonical_profile_version,
    as_of_time = request$as_of_time,
    capabilities = capabilities,
    domains = value
  )
  c(
    common[1:2], list(status = "succeeded"), common[-(1:2)],
    list(candidate_bundle = candidate, failure_code = NULL)
  )
}

rrp_authoring_provider_result <- function(
  request, project_root, authored_provider
) {
  value <- authored_provider(project_root, request)
  if (rrp_authoring_failure_valid(value)) return(list(
    request_id = request$request_id, status = "failure",
    estimate_value = NULL, failure_code = value$code
  ))
  list(
    request_id = request$request_id, status = "success",
    estimate_value = value, failure_code = NULL
  )
}

rrp_authoring_registration <- function(catalog, project_root) {
  contract <- rrp_authoring_contract(catalog)
  root <- rrp_project_validate_root(project_root)
  manifest_contract <- rrp_project_manifest_contract(catalog)
  manifest_path <- rrp_project_manifest_path(root)
  manifest <- rrp_project_validate_manifest(
    readLines(manifest_path, warn = FALSE, encoding = "UTF-8"),
    manifest_contract
  )
  if (!identical(contract[["Project-Contract-ID"]],
                 manifest[["Project-Contract-ID"]]) ||
      !identical(contract[["Project-Contract-Version"]],
                 manifest[["Project-Contract-Version"]])) {
    rrp_authoring_abort(
      "authoring_manifest_mismatch", "Project authoring metadata disagrees with the manifest."
    )
  }
  metadata_path <- tryCatch(
    rrp_project_resolve_filesystem_path(
      root, contract[["Metadata-Path"]], "missing_authoring_metadata",
      "linked_authoring_metadata", "invalid_authoring_path",
      "Project authoring metadata", TRUE, FALSE
    ),
    rrp_project_error = function(condition) rrp_authoring_abort(
      condition$code, "Project authoring metadata is invalid."
    )
  )
  metadata <- rrp_authoring_validate_metadata(
    rrp_authoring_parse_metadata(metadata_path, contract), contract
  )
  tryCatch(
    rrp_project_resolve_filesystem_path(
      root, contract[["Readme-Path"]], "missing_authoring_file",
      "linked_authoring_file", "invalid_authoring_path",
      "Project authoring README", TRUE, FALSE
    ),
    rrp_project_error = function(condition) rrp_authoring_abort(
      condition$code, "Project authoring README is invalid."
    )
  )
  extension_path <- rrp_project_declared_directory(
    root, manifest[["Extension-Library-Path"]], "extension_library"
  )
  inventory <- rrp_authoring_dependencies(
    metadata[["Extension-Packages"]], contract
  )
  rrp_authoring_validate_dependencies(inventory, extension_path)

  producer <- rrp_authoring_evaluate_callable(
    root, contract[["Producer-Path"]], contract[["Producer-Binding"]],
    contract[["Producer-Arguments"]], "Project producer authoring file"
  )
  provider <- rrp_authoring_evaluate_callable(
    root, contract[["Provider-Path"]], contract[["Provider-Binding"]],
    contract[["Provider-Arguments"]], "Project provider authoring file"
  )
  capabilities <- rrp_authoring_capabilities()
  producer_callable <- local({
    project_root <- root
    manifest <- manifest
    metadata <- metadata
    authored_producer <- producer
    function(request) {
      request$project_root <- project_root
      rrp_authoring_producer_result(
        request, manifest, metadata, authored_producer
      )
    }
  })
  provider_callable <- local({
    project_root <- root
    authored_provider <- provider
    function(request) rrp_authoring_provider_result(
      request, project_root, authored_provider
    )
  })

  list(
    registration_contract_id = "rrp.project-registration",
    registration_contract_version = "0.3.0",
    project_id = manifest[["Project-ID"]],
    producers = list(list(
      component_id = manifest[["Producer-ID"]],
      component_version = manifest[["Producer-Version"]],
      producer_api_id = "rrp.producer-api",
      producer_api_version = "0.1.0",
      canonical_bundle_id = "rrp.canonical-bundle",
      canonical_bundle_version = "0.1.0",
      canonical_profile_id = manifest[["Canonical-Profile-ID"]],
      canonical_profile_version = manifest[["Canonical-Profile-Version"]],
      implementation_id = metadata[["Producer-Implementation-ID"]],
      implementation_version = metadata[["Producer-Implementation-Version"]],
      mapping_id = metadata[["Mapping-ID"]],
      mapping_version = metadata[["Mapping-Version"]],
      capabilities = capabilities,
      callable = producer_callable
    )),
    providers = list(list(
      component_id = manifest[["Provider-ID"]],
      component_version = manifest[["Provider-Version"]],
      provider_api_id = "rrp.provider-api",
      provider_api_version = "0.1.0",
      target_id = "rrp.risk-target.readmission-remaining-30-day",
      target_version = "0.1.0",
      state_contract_id = "rrp.episode-state",
      state_contract_version = "0.1.0",
      request_contract_id = "rrp.risk-request",
      request_contract_version = "0.1.0",
      estimate_contract_id = "rrp.risk-estimate",
      estimate_contract_version = "0.1.0",
      implementation_id = metadata[["Provider-Implementation-ID"]],
      implementation_version = metadata[["Provider-Implementation-Version"]],
      model_id = if ("Model-ID" %in% names(metadata)) metadata[["Model-ID"]] else NULL,
      model_version = if ("Model-Version" %in% names(metadata)) metadata[["Model-Version"]] else NULL,
      callable = provider_callable
    ))
  )
}

#' Register a standard-authored RRP project
#'
#' Validate the fixed standard-authoring files and dependency inventory beneath
#' one explicit project root, evaluate the two exact hospital callables without
#' invoking them, and compile them into the unchanged raw project registration.
#' This entry point is used by the generated trusted `R/register.R` while the
#' authoritative loader supplies its validated software-resource context.
#'
#' @param project_root One explicit existing independent project root.
#' @return One closed `rrp.project-registration@0.3.0` value.
#' @export
rrp_register_authored_project <- function(project_root) {
  context <- rrp_authoring_active_context$get()
  if (!is.list(context) || !identical(names(context), c("catalog", "project_root")) ||
      !identical(project_root, context$project_root)) {
    rrp_authoring_abort(
      "authoring_context_unavailable",
      "Standard authoring registration requires the authoritative project loader."
    )
  }
  rrp_authoring_registration(context$catalog, project_root)
}
