rrp_app_init_abort <- function(code, message = "Standalone application initialization failed.") {
  stop(structure(list(message = message, call = NULL, code = code),
    class = c("rrp_application_initialization_error", "error", "condition")))
}

rrp_app_structural_context <- function(catalog, project_root) {
  root <- rrp_project_validate_root(project_root)
  contract <- rrp_project_manifest_contract(catalog)
  path <- rrp_project_manifest_path(root)
  lines <- tryCatch(readLines(path, warn = FALSE, encoding = "UTF-8"),
    error = function(e) rrp_app_init_abort("application_project_invalid"))
  manifest <- tryCatch(rrp_project_validate_manifest(lines, contract),
    rrp_project_error = function(e) rrp_app_init_abort("application_project_invalid"))
  state <- tryCatch(rrp_project_declared_directory(
    root, manifest[["State-Path"]], "state"),
    rrp_project_error = function(e) rrp_app_init_abort("application_project_invalid"))
  structure(list(software_catalog = catalog, project_root = root,
    manifest = manifest, state_path = state), class = c("rrp_app_structural_context", "list"))
}

rrp_app_structural_access <- function(catalog, project_root, scope_id, cutoff) {
  context <- rrp_app_structural_context(catalog, project_root)
  contracts <- rrp_state_contracts(catalog)
  metadata <- tryCatch(rrp_state_inspect_root(context$state_path, context, contracts),
    error = function(e) rrp_app_init_abort("application_state_invalid"))
  materialization <- rrp_product_materialization_contract(catalog)
  product_contracts <- rrp_product_contracts(catalog)
  store <- file.path(context$state_path, materialization[["Store-Directory"]])
  opened <- tryCatch(rrp_product_open_current(store,
    materialization[["Pointer-File"]], materialization, product_contracts),
    error = function(e) rrp_app_init_abort("application_products_unavailable"))
  if (!identical(opened$product_set$state_id, metadata[["State-ID"]]) ||
      !identical(opened$product_set$project_id, metadata[["Project-ID"]])) {
    rrp_app_init_abort("application_product_incompatible")
  }
  port <- rrpruntime::rrp_new_history_port(rrp_duckdb_adapter(
    file.path(context$state_path, "history.duckdb"), metadata, contracts))
  freshness <- tryCatch(rrp_product_freshness(opened$product_set, scope_id, cutoff,
    list(port = port)), error = function(e) rrp_app_init_abort("application_freshness_failed"))
  if (!identical(freshness$status, "fresh") ||
      !identical(opened$product_set$source_history_cutoff,
        freshness$expected_history_cutoff)) {
    rrp_app_init_abort("application_products_stale")
  }
  list(context = context, access = rrp_product_access_new(
    opened$product_set, opened$pointer, freshness))
}

rrp_app_write_dcf <- function(records, path) {
  lines <- unlist(lapply(seq_along(records), function(index) {
    record <- records[[index]]
    block <- paste0(names(record), ": ", unname(record))
    if (index < length(records)) c(block, "") else block
  }), use.names = FALSE)
  writeLines(lines, path, useBytes = TRUE)
}

rrp_app_write_csv <- function(data, path) utils::write.table(
  data, path, sep = ",", row.names = FALSE, col.names = TRUE, quote = TRUE,
  qmethod = "double", na = "", eol = "\n", fileEncoding = "UTF-8")

rrp_app_sha256 <- function(path) {
  utility <- Sys.which("sha256sum"); arguments <- path
  if (!nzchar(utility)) { utility <- Sys.which("shasum"); arguments <- c("-a", "256", path) }
  output <- if (nzchar(utility)) suppressWarnings(system2(utility, arguments,
    stdout = TRUE, stderr = FALSE)) else character()
  digest <- if (length(output)) sub("[[:space:]].*$", "", output[[1L]]) else ""
  if (!grepl("^[0-9a-f]{64}$", digest)) rrp_app_init_abort("application_digest_failed")
  digest
}

rrp_app_write_frozen_set <- function(access, root) {
  snapshot <- rrp_application_product_snapshot(access)
  files <- c(current_remaining_risk = "current-remaining-risk.csv",
    remaining_risk_trajectory = "remaining-risk-trajectory.csv",
    operational_scope_summary = "operational-scope-summary.csv")
  for (name in names(files)) rrp_app_write_csv(snapshot$products[[name]]$data,
    file.path(root, files[[name]]))
  prefixes <- c(current_remaining_risk = "Current-Remaining-Risk",
    remaining_risk_trajectory = "Remaining-Risk-Trajectory",
    operational_scope_summary = "Operational-Scope-Summary")
  declaration <- c("Record-Type" = "rrp-application-product-set",
    "Portable-Application-Contract-ID" = "rrp.application.portable",
    "Portable-Application-Contract-Version" = "0.1.0",
    "Product-Set-Contract-ID" = "rrp.product-set.initial-readmission-risk",
    "Product-Set-Contract-Version" = "0.1.0",
    "Product-Set-ID" = snapshot$product_set_id,
    "Materialization-ID" = access$materialization_id,
    "Source-Operation-Run-ID" = snapshot$source_operation_run_id,
    "Source-Analytical-Time" = snapshot$source_analytical_time,
    "Source-History-Cutoff" = snapshot$source_history_cutoff,
    "Source-History-Fingerprint" = snapshot$source_history_fingerprint)
  for (name in names(files)) {
    item <- snapshot$products[[name]]; prefix <- prefixes[[name]]
    named <- function(value, field) {
      value <- as.character(value); names(value) <- field; value
    }
    declaration <- c(declaration,
      named(item$product_contract_id, paste0(prefix, "-Product-Contract-ID")),
      named(item$product_contract_version, paste0(prefix, "-Product-Contract-Version")),
      named(item$product_instance_id, paste0(prefix, "-Product-Instance-ID")),
      named(item$row_count, paste0(prefix, "-Row-Count")),
      named(files[[name]], paste0(prefix, "-File")))
  }
  rrp_app_write_dcf(list(declaration), file.path(root, "products.dcf"))
  paths <- sort(c(unname(files), "products.dcf"), method = "radix")
  inventory <- lapply(paths, function(relative) c("Record-Type" = "managed-file",
    "Path" = relative, "Role" = if (relative == "products.dcf") "product_declaration" else "product_member",
    "Byte-Size" = as.character(file.info(file.path(root, relative))$size[[1L]]),
    "SHA256" = rrp_app_sha256(file.path(root, relative))))
  rrp_app_write_dcf(inventory, file.path(root, "inventory.dcf"))
  invisible(snapshot)
}

rrp_app_destination <- function(project_root, output_path) {
  candidate <- if (is.null(output_path)) file.path(project_root, "app") else output_path
  if (!rrp_application_scalar(candidate, 4096L)) {
    rrp_app_init_abort("application_destination_invalid")
  }
  link <- Sys.readlink(candidate)
  if (file.exists(candidate) || dir.exists(candidate) || (!is.na(link) && nzchar(link))) {
    rrp_app_init_abort("application_destination_exists")
  }
  parent <- dirname(candidate); leaf <- basename(candidate)
  if (!dir.exists(parent) || leaf %in% c("", ".", "..") || nzchar(Sys.readlink(parent))) {
    rrp_app_init_abort("application_destination_invalid")
  }
  supplied_parent <- gsub("\\\\", "/", path.expand(parent))
  parent <- normalizePath(parent, winslash = "/", mustWork = TRUE)
  if (!identical(normalizePath(supplied_parent, winslash = "/", mustWork = TRUE), parent)) {
    rrp_app_init_abort("application_destination_invalid")
  }
  if (any(vapply(strsplit(gsub("\\\\", "/", parent), "/", fixed = TRUE)[[1L]],
      function(x) identical(x, ".."), logical(1L)))) rrp_app_init_abort("application_destination_invalid")
  file.path(parent, leaf)
}

rrp_app_copy_portable <- function(catalog, staging) {
  dir.create(file.path(staging, "R")); dir.create(file.path(staging, "www"))
  ids <- rrp_application_portable_resource_ids()
  names(ids) <- c(
    "application-core.R", "product-loader.R", "application-ui.R",
    "application-server.R"
  )
  for (name in names(ids)) if (!file.copy(
      rrp_resource_path(catalog, ids[[name]]), file.path(staging, "R", name),
      copy.mode = FALSE)) rrp_app_init_abort("application_copy_failed")
  if (!file.copy(rrp_resource_path(catalog, "rrp.application.standalone-managed-loader"),
      file.path(staging, "R", "managed-loader.R"), copy.mode = FALSE)) {
    rrp_app_init_abort("application_copy_failed")
  }
  if (!file.copy(rrp_resource_path(catalog, "rrp.application.standalone-host"),
      file.path(staging, "app.R"), copy.mode = FALSE)) {
    rrp_app_init_abort("application_copy_failed")
  }
  if (!file.copy(rrp_resource_path(catalog, "rrp.asset.supplied-application-css"),
      file.path(staging, "www", "rrp.css"), copy.mode = FALSE)) rrp_app_init_abort("application_copy_failed")
}

rrp_app_write_presentation <- function(model, staging) {
  logo_file <- logo_type <- logo_alt <- "none"
  if (!is.null(model$logo)) {
    extension <- if (model$logo$media_type == "image/png") "png" else "jpg"
    logo_file <- paste0("rrp-data/brand-logo.", extension); logo_type <- model$logo$media_type
    logo_alt <- model$logo$alt; writeBin(model$logo$bytes, file.path(staging, logo_file))
  }
  record <- c("Record-Type" = "rrp-application-presentation",
    "Presentation-Contract-ID" = "rrp.application-presentation",
    "Presentation-Contract-Version" = "0.1.0", "Brand-Contract-ID" = "rrp.project-brand",
    "Brand-Contract-Version" = "0.1.0", "Source" = model$source,
    "Display-Name" = model$display_name, "Primary-Color" = model$primary_color,
    "Logo-File" = logo_file, "Logo-Media-Type" = logo_type, "Logo-Alt" = logo_alt)
  rrp_app_write_dcf(list(record), file.path(staging, "rrp-data", "presentation.dcf"))
  rrp_app_sha256(file.path(staging, "rrp-data", "presentation.dcf"))
}

rrp_app_dependency_context <- function(header, artifact, installation_record,
                                       host) {
  valid <- identical(header[["Record-Type"]], "rrp-dependency-specification") &&
    identical(header[["Target-R-Version"]], artifact[["Target-R-Version"]]) &&
    identical(header[["Target-Platform"]], artifact[["Target-Platform"]]) &&
    identical(header[["Target-Architecture"]], artifact[["Target-Architecture"]]) &&
    identical(artifact[["Target-Platform"]], host[["platform"]]) &&
    identical(artifact[["Target-Architecture"]], host[["architecture"]]) &&
    identical(installation_record[["Host-R-Version"]], host[["version"]]) &&
    identical(installation_record[["Platform"]], host[["platform"]]) &&
    identical(installation_record[["Architecture"]], host[["architecture"]]) &&
    isTRUE(tryCatch(
      numeric_version(host[["version"]]) >=
        numeric_version(artifact[["Technical-Minimum-R-Version"]]),
      error = function(e) FALSE
    ))
  if (!valid) rrp_app_init_abort("application_dependency_provenance_invalid")
  invisible(list(
    build_target_r_version = artifact[["Target-R-Version"]],
    host_r_version = host[["version"]],
    eligibility_status = if (identical(
      artifact[["Target-R-Version"]], host[["version"]]
    )) "exact_build_target_unqualified" else "eligible_best_effort"
  ))
}

rrp_app_dependency_lock <- function(staging, catalog) {
  roots <- c("bslib", "plotly", "reactable", "shiny")
  manifest_records <- tryCatch(rrp_resource_read_dcf(
    file.path(catalog$software_root, "manifest.dcf"),
    "application_dependency_provenance_invalid", "Distribution manifest"),
    error = function(e) rrp_app_init_abort("application_dependency_provenance_invalid"))
  if (length(manifest_records) != 1L) {
    rrp_app_init_abort("application_dependency_provenance_invalid")
  }
  installation_record <- tryCatch(
    rrp_software_record(catalog$software_root),
    error = function(e) rrp_app_init_abort("application_dependency_provenance_invalid")
  )
  artifact_info <- tryCatch(rrp_software_artifact(
    catalog$software_root, manifest_records[[1L]], installation_record
  ), error = function(e) rrp_app_init_abort("application_dependency_provenance_invalid"))
  artifact <- artifact_info$artifact
  specification <- tryCatch(rrp_resource_read_dcf(
    file.path(catalog$software_root, "dependencies", "dependencies.dcf"),
    "application_dependency_provenance_invalid", "Dependency specification"),
    error = function(e) rrp_app_init_abort("application_dependency_provenance_invalid"))
  header <- specification[[1L]]
  rrp_app_dependency_context(
    header, artifact, installation_record,
    list(
      version = as.character(getRversion()), platform = R.version$platform,
      architecture = R.version$arch
    )
  )
  packages <- Filter(function(record) identical(record[["Record-Type"]], "rrp-dependency"), specification)
  by_name <- split(packages, vapply(packages, `[[`, character(1L), "Package"))
  requirements <- function(package) {
    description <- tryCatch(utils::packageDescription(package), error = function(e) NULL)
    if (is.null(description)) rrp_app_init_abort("application_dependency_provenance_invalid")
    fields <- unname(unlist(description[c("Depends", "Imports", "LinkingTo")], use.names = FALSE))
    fields <- fields[!is.na(fields) & nzchar(fields)]
    values <- if (!length(fields)) character() else trimws(unlist(strsplit(fields, ",", fixed = TRUE)))
    values <- sub("[[:space:]]*\\(.*$", "", values)
    sort(intersect(values, names(by_name)), method = "radix")
  }
  closure <- roots; index <- 1L
  while (index <= length(closure)) {
    closure <- unique(c(closure, requirements(closure[[index]])))
    index <- index + 1L
  }
  closure <- sort(closure, method = "radix")
  selected <- lapply(closure, function(package) {
    matches <- by_name[[package]]
    if (length(matches) != 1L) rrp_app_init_abort("application_dependency_provenance_invalid")
    matches[[1L]]
  })
  repositories <- unique(vapply(selected, `[[`, character(1L), "Repository"))
  repository <- if (length(repositories) == 1L) repositories[[1L]] else ""
  if (!rrp_application_scalar(repository, 1000L) || !grepl("^https://", repository) ||
      any(vapply(selected, function(record) !identical(record[["Source-Type"]], "repository") ||
        !grepl("^renv:[0-9a-f]{32}$", record[["Integrity"]]), logical(1L)))) {
    rrp_app_init_abort("application_dependency_provenance_invalid")
  }
  versions <- vapply(selected, `[[`, character(1L), "Version")
  hashes <- sub("^renv:", "", vapply(selected, `[[`, character(1L), "Integrity"))
  package_lines <- unlist(Map(function(package, version, hash) {
    needs <- requirements(package)
    needs_json <- paste0("[", paste(paste0('"', needs, '"'), collapse = ", "), "]")
    value <- c(
    paste0('    "', package, '": {'), paste0('      "Package": "', package, '",'),
    paste0('      "Version": "', version, '",'), '      "Source": "Repository",',
    '      "Repository": "RRP",', '      "Requirements": [],',
    paste0('      "Hash": "', hash, '"'),
    "    }")
    value[[6L]] <- paste0('      "Requirements": ', needs_json, ',')
    value
  }, closure, versions, hashes), use.names = FALSE)
  ends <- which(package_lines == "    }"); package_lines[ends[-length(ends)]] <- "    },"
  lines <- c("{", '  "R": {', paste0('    "Version": "', getRversion(), '",'),
    '    "Repositories": [', paste0('      {"Name": "RRP", "URL": "', repository, '"}'),
    "    ]", "  },", '  "Packages": {', package_lines, "  }", "}")
  writeLines(lines, file.path(staging, "renv.lock"), useBytes = TRUE)
  if (!rrp_application_scalar(header[["Specification-ID"]])) {
    rrp_app_init_abort("application_dependency_provenance_invalid")
  }
  unname(header[["Specification-ID"]])
}

rrp_app_distribution_identity <- function(catalog) {
  records <- tryCatch(rrp_resource_read_dcf(
    file.path(catalog$software_root, "manifest.dcf"),
    "application_software_identity_invalid", "Distribution manifest"),
    error = function(e) rrp_app_init_abort("application_software_identity_invalid"))
  record <- if (length(records) == 1L) records[[1L]] else list()
  required <- c("Record-Type" = "rrp-distribution",
    "Contract-ID" = "rrp.distribution-manifest", "Contract-Version" = "0.1.0",
    "Product-ID" = "readmission-risk-pool-platform", "Product-Version" = "1.0.0-dev",
    "Resource-Catalog-ID" = "rrp.software-resources")
  if (!all(vapply(names(required), function(field) identical(
      record[[field]], unname(required[[field]])), logical(1L))) ||
      !rrp_application_scalar(record[["Distribution-ID"]]) ||
      !rrp_application_scalar(record[["Dependency-Specification-ID"]])) {
    rrp_app_init_abort("application_software_identity_invalid")
  }
  record
}

rrp_app_validate_staging <- function(staging, portable, pointer) {
  expected <- sort(c(
    "app.R", "LICENSE", "NOTICE", "R", "README.md", "renv.lock", "rrp-data",
    "rrp-initialization.dcf", "rrp-source-inventory.dcf", "www"
  ), method = "radix")
  actual <- sort(list.files(staging, all.files = TRUE, no.. = TRUE),
    method = "radix")
  logo <- list.files(file.path(staging, "rrp-data"), pattern = "^brand-logo[.](png|jpg)$")
  data_expected <- sort(c("current.dcf", "presentation.dcf", "sets", logo), method = "radix")
  data_actual <- sort(list.files(file.path(staging, "rrp-data"), all.files = TRUE,
    no.. = TRUE), method = "radix")
  valid <- identical(actual, expected) && identical(data_actual, data_expected) &&
    is.expression(tryCatch(parse(file.path(staging, "app.R")), error = function(e) NULL)) &&
    all(vapply(c("app.R", "LICENSE", "NOTICE", "README.md", "renv.lock",
      "rrp-initialization.dcf", "rrp-source-inventory.dcf", "www/rrp.css",
      "rrp-data/current.dcf", "rrp-data/presentation.dcf"), function(relative) {
        rrp_product_regular_file(file.path(staging, relative))
      }, logical(1L)))
  if (!valid) rrp_app_init_abort("application_staging_invalid")
  set <- portable$rrp_application_load_product_set(file.path(
    staging, "rrp-data", pointer[["Set-Directory"]]))
  presentation <- portable$rrp_application_load_presentation(
    staging, "www/rrp.css", "rrp-data/presentation.dcf")
  portable$rrp_application_model(set, presentation)
  lock <- paste(readLines(file.path(staging, "renv.lock"), warn = FALSE,
    encoding = "UTF-8"), collapse = "\n")
  if (!all(vapply(c('"shiny"', '"bslib"', '"plotly"', '"reactable"'),
      grepl, logical(1L), x = lock, fixed = TRUE)) ||
      any(vapply(c('"rrpplatform"', '"rrpruntime"', '"readmit"', '"DBI"',
        '"duckdb"'), grepl, logical(1L), x = lock, fixed = TRUE))) {
    rrp_app_init_abort("application_dependency_provenance_invalid")
  }
  invisible(TRUE)
}

# Private failure injection is limited to package-native transactional cleanup
# evidence. The exported operation below does not expose it.
rrp_app_initialize <- function(software_catalog, project_root, scope_id,
    history_cutoff, output_path = NULL, failure_stage = NULL) tryCatch({
  if (!is.null(failure_stage) && !failure_stage %in% c(
      "after_staging", "before_promotion")) {
    rrp_app_init_abort("application_failure_stage_invalid")
  }
  rrp_resource_validate_catalog_object(software_catalog)
  resource_result <- rrp_validate_software_resources(software_catalog$software_root)
  if (!rrp_operation_succeeded(resource_result)) {
    rrp_app_init_abort("application_software_identity_invalid")
  }
  software <- rrp_app_distribution_identity(software_catalog)
  resolved <- rrp_app_structural_access(software_catalog, project_root, scope_id, history_cutoff)
  destination <- rrp_app_destination(resolved$context$project_root, output_path)
  parent <- dirname(destination); staging <- tempfile(".rrp-app-staging-", tmpdir = parent)
  if (!dir.create(staging)) rrp_app_init_abort("application_staging_failed")
  promoted <- FALSE; on.exit(if (!promoted && dir.exists(staging)) unlink(staging, recursive = TRUE), add = TRUE)
  rrp_app_copy_portable(software_catalog, staging)
  if (identical(failure_stage, "after_staging")) {
    rrp_app_init_abort("application_injected_failure")
  }
  dir.create(file.path(staging, "rrp-data")); dir.create(file.path(staging, "rrp-data", "sets"))
  set_staging <- file.path(staging, "rrp-data", "sets", ".rrp-set-staging")
  dir.create(set_staging); rrp_app_write_frozen_set(resolved$access, set_staging)
  set_id <- paste0("set-", substr(rrp_app_sha256(file.path(set_staging, "inventory.dcf")), 1L, 24L))
  set_relative <- paste0("sets/", set_id); set_root <- file.path(staging, "rrp-data", set_relative)
  if (!file.rename(set_staging, set_root)) rrp_app_init_abort("application_staging_failed")
  portable <- rrp_application_portable(software_catalog)
  portable$rrp_application_load_product_set(set_root)
  presentation <- rrp_application_presentation_model(software_catalog, resolved$context$project_root,
    rrp_application_contracts(software_catalog))
  presentation_sha <- rrp_app_write_presentation(presentation, staging)
  managed_sha <- rrp_app_sha256(file.path(set_root, "inventory.dcf"))
  pointer <- c("Record-Type" = "rrp-application-current",
    "Managed-Content-Contract-ID" = "rrp.application-managed-content",
    "Managed-Content-Contract-Version" = "0.1.0", "Set-Directory" = set_relative,
    "Product-Set-ID" = resolved$access$product_set_id,
    "Materialization-ID" = resolved$access$materialization_id,
    "Source-Operation-Run-ID" = resolved$access$source_operation_run_id,
    "Source-History-Cutoff" = resolved$access$source_history_cutoff,
    "Source-History-Fingerprint" = resolved$access$source_history_fingerprint,
    "Managed-Inventory-SHA256" = managed_sha)
  rrp_app_write_dcf(list(pointer), file.path(staging, "rrp-data", "current.dcf"))
  dependency_identity <- rrp_app_dependency_lock(staging, software_catalog)
  if (!identical(dependency_identity, software[["Dependency-Specification-ID"]])) {
    rrp_app_init_abort("application_dependency_provenance_invalid")
  }
  legal <- file.path(software_catalog$software_root, c("LICENSE", "NOTICE"))
  if (!all(vapply(legal, rrp_product_regular_file, logical(1L))) ||
      !all(file.copy(legal, staging, copy.mode = FALSE))) {
    rrp_app_init_abort("application_copy_failed")
  }
  writeLines(c("# Standalone RRP application", "",
    "Direct runtime packages: `shiny`, `bslib`, `plotly`, and `reactable`.",
    "Run `renv::restore()` once, then launch with `shiny::runApp('.')`.",
    "RRP manages only `rrp-data/`; keep hospital-owned source outside that directory."),
    file.path(staging, "README.md"), useBytes = TRUE)
  source_paths <- sort(c(
    "app.R", paste0("R/", c(
      "application-core.R", "product-loader.R", "application-ui.R",
      "application-server.R", "managed-loader.R"
    )), "www/rrp.css", "README.md", "renv.lock", "LICENSE", "NOTICE"
  ), method = "radix")
  source_inventory <- lapply(source_paths, function(path) c("Record-Type" = "source-file",
    "Path" = path, "Byte-Size" = as.character(file.info(file.path(staging, path))$size[[1L]]),
    "SHA256" = rrp_app_sha256(file.path(staging, path))))
  rrp_app_write_dcf(source_inventory, file.path(staging, "rrp-source-inventory.dcf"))
  source_sha <- rrp_app_sha256(file.path(staging, "rrp-source-inventory.dcf"))
  baseline_input <- file.path(staging, ".rrp-baseline-input")
  baseline_values <- c(
    "rrp.application.portable@0.1.0", dependency_identity,
    resolved$access$product_set_id, resolved$access$materialization_id,
    resolved$access$source_operation_run_id, resolved$access$source_analytical_time,
    resolved$access$source_history_cutoff,
    resolved$access$source_history_fingerprint, presentation_sha, source_sha,
    managed_sha
  )
  writeLines(paste0(nchar(baseline_values, type = "bytes"), ":", baseline_values),
    baseline_input, useBytes = TRUE)
  baseline <- rrp_app_sha256(baseline_input)
  unlink(baseline_input)
  provenance <- c("Record-Type" = "rrp-application-initialization",
    "Contract-ID" = "rrp.application-initialization", "Contract-Version" = "0.1.0",
    "Software-Product-ID" = software[["Product-ID"]], "Software-Version" = software[["Product-Version"]],
    "Distribution-ID" = software[["Distribution-ID"]], "Package-Version" = as.character(utils::packageVersion("rrpplatform")),
    "Resource-Catalog-ID" = "rrp.software-resources", "Resource-Catalog-Version" = "0.1.0",
    "Portable-Application-Contract-ID" = "rrp.application.portable",
    "Portable-Application-Contract-Version" = "0.1.0", "Application-Baseline-ID" = baseline,
    "Dependency-Identity" = dependency_identity, "Initial-Product-Set-ID" = resolved$access$product_set_id,
    "Initial-Materialization-ID" = resolved$access$materialization_id,
    "Source-Operation-Run-ID" = resolved$access$source_operation_run_id,
    "Source-Analytical-Time" = resolved$access$source_analytical_time,
    "Source-History-Cutoff" = resolved$access$source_history_cutoff,
    "Source-History-Fingerprint" = resolved$access$source_history_fingerprint,
    "Presentation-SHA256" = presentation_sha, "Source-Inventory-SHA256" = source_sha,
    "Managed-Inventory-SHA256" = managed_sha)
  rrp_app_write_dcf(list(provenance), file.path(staging, "rrp-initialization.dcf"))
  rrp_app_validate_staging(staging, portable, pointer)
  if (identical(failure_stage, "before_promotion")) {
    rrp_app_init_abort("application_injected_failure")
  }
  destination_link <- Sys.readlink(destination)
  if (file.exists(destination) || dir.exists(destination) ||
      (!is.na(destination_link) && nzchar(destination_link)) ||
      !file.rename(staging, destination)) rrp_app_init_abort("application_destination_race")
  promoted <- TRUE
  rrp_new_operation_result("rrp.initialize-app", "success", list(
    application_id = "rrp.application.supplied", application_version = "0.1.0",
    destination = destination, product_set_id = resolved$access$product_set_id,
    source_operation_run_id = resolved$access$source_operation_run_id,
    source_history_cutoff = resolved$access$source_history_cutoff), list())
}, rrp_application_initialization_error = function(condition) rrp_new_operation_result(
  "rrp.initialize-app", "failure", NULL,
  list(rrp_new_diagnostic(condition$code, "error", condition$message))),
error = function(condition) rrp_new_operation_result(
  "rrp.initialize-app", "failure", NULL,
  list(rrp_new_diagnostic("application_initialization_failed", "error",
    "Standalone application initialization failed."))))

#' Initialize a create-only standalone RRP application
#' @param software_catalog A validated explicit-root software resource catalog.
#' @param project_root One explicit initialized independent-project root.
#' @param scope_id Exact source operation-run identity.
#' @param history_cutoff Exact RFC 3339 UTC history cutoff.
#' @param output_path Optional absent destination; defaults to `app` in the project.
#' @return A common RRP operation result.
#' @export
rrp_initialize_app <- function(software_catalog, project_root, scope_id,
    history_cutoff, output_path = NULL) rrp_app_initialize(
  software_catalog, project_root, scope_id, history_cutoff, output_path
)
