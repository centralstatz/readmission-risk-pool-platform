#!/usr/bin/env Rscript

# Standalone, base-R verification for an extracted RRP distribution. This file
# is copied into the payload and deliberately has no repository dependency.

rrp_distribution_fail <- function(code, message) {
  stop(sprintf("[%s] %s", code, message), call. = FALSE)
}

rrp_safe_relative_path <- function(path) {
  is.character(path) && length(path) == 1L && !is.na(path) && nzchar(path) &&
    !grepl("^[A-Za-z]:|^[/\\\\]", path) &&
    !grepl("(^|/)[.][.]($|/)|(^|/)[.]($|/)|//|\\\\", path) &&
    identical(path, gsub("\\\\", "/", path))
}

rrp_read_dcf <- function(path, code) {
  if (!file.exists(path) || !isTRUE(file_test("-f", path))) {
    rrp_distribution_fail(code, "Required DCF file is missing or nonregular.")
  }
  tryCatch(
    lapply(seq_len(nrow(x <- read.dcf(path, all = TRUE))), function(i) {
      row <- x[i, , drop = TRUE]
      row[!is.na(row)]
    }),
    error = function(e) rrp_distribution_fail(code, "DCF parsing failed.")
  )
}

rrp_require_fields <- function(record, fields, code) {
  if (!identical(sort(names(record), method = "radix"),
                 sort(fields, method = "radix"))) {
    rrp_distribution_fail(code, "Record fields do not match the closed contract.")
  }
}

rrp_sha256 <- function(path) {
  utility <- Sys.which("sha256sum")
  args <- path
  if (!nzchar(utility)) {
    utility <- Sys.which("shasum")
    args <- c("-a", "256", path)
  }
  if (!nzchar(utility)) {
    rrp_distribution_fail(
      "integrity_tool", "Verification requires sha256sum or shasum."
    )
  }
  output <- suppressWarnings(system2(utility, args, stdout = TRUE, stderr = TRUE))
  status <- attr(output, "status")
  digest <- if (length(output)) sub("[[:space:]].*$", "", output[[1L]]) else ""
  if ((!is.null(status) && status != 0L) ||
      !grepl("^[0-9a-f]{64}$", digest)) {
    rrp_distribution_fail("integrity_tool", "SHA-256 calculation failed.")
  }
  digest
}

rrp_tree_entries <- function(root) {
  records <- list()
  visit <- function(directory, relative = "") {
    entries <- list.files(directory, all.files = TRUE, full.names = TRUE,
                          no.. = TRUE)
    for (entry in entries) {
      path <- if (nzchar(relative)) paste(relative, basename(entry), sep = "/") else basename(entry)
      link <- Sys.readlink(entry)
      linked <- !is.na(link) && nzchar(link)
      directory_entry <- dir.exists(entry)
      records[[length(records) + 1L]] <<- list(
        path = path, absolute = entry, directory = directory_entry, link = linked
      )
      if (directory_entry && !linked) visit(entry, path)
    }
  }
  visit(root)
  records
}

rrp_package_description <- function(archive, package) {
  members <- utils::untar(archive, list = TRUE)
  expected <- paste0(package, "/DESCRIPTION")
  if (sum(members == expected) != 1L ||
      any(grepl("(^|/)[.][.]($|/)|^[A-Za-z]:|^/|\\\\", members))) {
    rrp_distribution_fail("package_artifact", "Package archive members are unsafe or incomplete.")
  }
  temporary <- tempfile("rrp-package-")
  dir.create(temporary)
  on.exit(unlink(temporary, recursive = TRUE, force = TRUE), add = TRUE)
  utils::untar(archive, files = expected, exdir = temporary)
  description <- read.dcf(file.path(temporary, expected), all = TRUE)
  if (nrow(description) != 1L) {
    rrp_distribution_fail("package_artifact", "Package DESCRIPTION is invalid.")
  }
  result <- description[1L, , drop = TRUE]
  attr(result, "archive_members") <- members
  result
}

rrp_verify_distribution <- function(root) {
  if (!is.character(root) || length(root) != 1L || !dir.exists(root)) {
    rrp_distribution_fail("distribution_root", "Supply one extracted distribution directory.")
  }
  if (nzchar(Sys.readlink(root))) {
    rrp_distribution_fail("distribution_root", "Distribution root must not be a symbolic link.")
  }
  root <- normalizePath(root, winslash = "/", mustWork = TRUE)
  entries <- rrp_tree_entries(root)
  if (any(vapply(entries, `[[`, logical(1L), "link"))) {
    rrp_distribution_fail("linked_path", "Distribution contains a symbolic link.")
  }
  paths <- vapply(entries, `[[`, character(1L), "path")
  if (any(!vapply(paths, rrp_safe_relative_path, logical(1L))) ||
      anyDuplicated(tolower(paths))) {
    rrp_distribution_fail("unsafe_path", "Distribution paths are unsafe or case-conflicting.")
  }

  manifest_records <- rrp_read_dcf(file.path(root, "manifest.dcf"), "manifest")
  if (length(manifest_records) != 1L) {
    rrp_distribution_fail("manifest", "Manifest must contain exactly one record.")
  }
  manifest <- manifest_records[[1L]]
  manifest_fields <- c(
    "Record-Type", "Contract-ID", "Contract-Version", "Product-ID",
    "Product-Version", "Development-Version", "Distribution-ID", "Build-ID",
    "Target-R-Version", "Target-Platform", "Target-Architecture",
    "Dependency-Specification-ID", "Resource-Catalog-ID", "Inventory-Digest",
    "Source-Revision", "Source-State", "Built-At"
  )
  rrp_require_fields(manifest, manifest_fields, "manifest")
  expected_manifest <- c(
    "Record-Type" = "rrp-distribution",
    "Contract-ID" = "rrp.distribution-manifest",
    "Contract-Version" = "0.1.0",
    "Product-ID" = "readmission-risk-pool-platform",
    "Product-Version" = "1.0.0-dev",
    "Development-Version" = "1.0.0-dev",
    "Resource-Catalog-ID" = "rrp.software-resources"
  )
  for (field in names(expected_manifest)) {
    if (!identical(manifest[[field]], expected_manifest[[field]])) {
      rrp_distribution_fail("manifest", paste("Unsupported manifest", field))
    }
  }
  for (field in c("Distribution-ID", "Build-ID", "Inventory-Digest")) {
    if (!grepl("^[0-9a-f]{64}$", manifest[[field]])) {
      rrp_distribution_fail("manifest", paste(field, "must be SHA-256."))
    }
  }
  if (any(!nzchar(manifest[c(
    "Target-R-Version", "Target-Platform", "Target-Architecture",
    "Dependency-Specification-ID", "Source-Revision"
  )])) ||
      !manifest[["Source-State"]] %in% c("clean", "modified", "unavailable") ||
      !grepl("^[0-9]{4}-[0-9]{2}-[0-9]{2}T[0-9]{2}:[0-9]{2}:[0-9]{2}Z$",
             manifest[["Built-At"]])) {
    rrp_distribution_fail("manifest", "Manifest target, source, or build metadata is invalid.")
  }

  inventory_path <- file.path(root, "inventory.dcf")
  if (!identical(rrp_sha256(inventory_path), manifest[["Inventory-Digest"]])) {
    rrp_distribution_fail("inventory_digest", "Inventory digest does not match the manifest.")
  }
  inventory <- rrp_read_dcf(inventory_path, "inventory")
  if (length(inventory) < 2L) rrp_distribution_fail("inventory", "Inventory is empty.")
  rrp_require_fields(inventory[[1L]], c(
    "Record-Type", "Inventory-Version", "Distribution-ID", "File-Count"
  ), "inventory")
  if (!identical(inventory[[1L]][["Record-Type"]], "distribution-inventory") ||
      !identical(inventory[[1L]][["Inventory-Version"]], "0.1.0") ||
      !identical(inventory[[1L]][["Distribution-ID"]], manifest[["Distribution-ID"]])) {
    rrp_distribution_fail("inventory", "Inventory header disagrees with the manifest.")
  }
  files <- inventory[-1L]
  for (record in files) {
    rrp_require_fields(record, c("Record-Type", "Path", "Role", "Size", "SHA256"), "inventory")
    if (!identical(record[["Record-Type"]], "file") ||
        !rrp_safe_relative_path(record[["Path"]]) ||
        !grepl("^[0-9]+$", record[["Size"]]) ||
        !grepl("^[0-9a-f]{64}$", record[["SHA256"]])) {
      rrp_distribution_fail("inventory", "Inventory file record is invalid.")
    }
  }
  file_paths <- vapply(files, `[[`, character(1L), "Path")
  if (anyDuplicated(file_paths) || anyDuplicated(tolower(file_paths)) ||
      !identical(file_paths, sort(file_paths, method = "radix")) ||
      !identical(as.integer(inventory[[1L]][["File-Count"]]), length(files))) {
    rrp_distribution_fail("inventory", "Inventory paths/count are not closed and canonical.")
  }
  actual_files <- sort(c(
    "manifest.dcf", "inventory.dcf",
    vapply(entries, function(x) if (!x$directory) x$path else NA_character_, character(1L))
  ), method = "radix")
  actual_files <- unique(actual_files[!is.na(actual_files)])
  expected_files <- sort(c("manifest.dcf", "inventory.dcf", file_paths), method = "radix")
  if (!identical(actual_files, expected_files)) {
    rrp_distribution_fail("inventory_closure", "Distribution has missing or unexpected files.")
  }
  expected_directories <- unique(unlist(lapply(expected_files, function(path) {
    parts <- strsplit(dirname(path), "/", fixed = TRUE)[[1L]]
    if (identical(parts, ".")) return(character())
    vapply(seq_along(parts), function(i) paste(parts[seq_len(i)], collapse = "/"), character(1L))
  }), use.names = FALSE))
  actual_directories <- sort(vapply(
    entries[vapply(entries, `[[`, logical(1L), "directory")],
    `[[`, character(1L), "path"
  ), method = "radix")
  if (!identical(actual_directories, sort(expected_directories, method = "radix"))) {
    rrp_distribution_fail("inventory_closure", "Distribution has unexpected directory structure.")
  }
  for (record in files) {
    path <- file.path(root, record[["Path"]])
    if (!isTRUE(file_test("-f", path)) ||
        !identical(as.numeric(file.info(path)$size), as.numeric(record[["Size"]])) ||
        !identical(rrp_sha256(path), record[["SHA256"]])) {
      rrp_distribution_fail("file_integrity", paste("Integrity failed for", record[["Path"]]))
    }
  }

  roles <- vapply(files, `[[`, character(1L), "Role")
  required_role_counts <- c(
    "internal-package" = 2L, "version-launcher" = 1L,
    "resource-catalog" = 1L, "dependency-specification" = 1L,
    "distribution-identity" = 1L,
    "standalone-verifier" = 1L, "license" = 1L, "notice" = 1L,
    "version-information" = 1L, "installation-engine" = 1L,
    "bootstrap-installer" = 1L
  )
  for (role in names(required_role_counts)) {
    if (sum(roles == role) != required_role_counts[[role]]) {
      rrp_distribution_fail("required_role", paste("Incorrect role count:", role))
    }
  }
  allowed_roles <- c(names(required_role_counts), "documentation", "installed-resource")
  if (any(!roles %in% allowed_roles)) {
    rrp_distribution_fail("required_role", "Inventory contains an unsupported role.")
  }

  dependencies <- rrp_read_dcf(
    file.path(root, "dependencies", "dependencies.dcf"), "dependency_specification"
  )
  identity_path <- file.path(root, "identity.txt")
  identity_lines <- readLines(identity_path, warn = FALSE, encoding = "UTF-8")
  identity_sources <- if (length(identity_lines) > 2L) {
    identity_lines[-c(1L, length(identity_lines))]
  } else character()
  identity_source_paths <- sub("^source:([^=]+)=.*$", "\\1", identity_sources)
  if (!identical(rrp_sha256(identity_path), manifest[["Distribution-ID"]]) ||
      length(identity_lines) < 3L ||
      !identical(identity_lines[[1L]], "rrp-distribution-identity-v1") ||
      !identical(
        tail(identity_lines, 1L),
        paste0("dependency-specification=", rrp_sha256(file.path(
          root, "dependencies", "dependencies.dcf"
        )))
      ) || any(!grepl("^source:[^=]+=[0-9a-f]{64}$", identity_sources)) ||
      any(!vapply(identity_source_paths, rrp_safe_relative_path, logical(1L))) ||
      anyDuplicated(tolower(identity_source_paths)) ||
      !identical(identity_source_paths, sort(identity_source_paths, method = "radix"))) {
    rrp_distribution_fail("distribution_identity", "Normalized distribution identity evidence is invalid.")
  }
  header <- dependencies[[1L]]
  rrp_require_fields(header, c(
    "Record-Type", "Contract-ID", "Contract-Version", "Specification-ID",
    "Product-ID", "Product-Version", "Target-R-Version", "Target-Platform",
    "Target-Architecture", "Repository-Set-ID", "Package-Count"
  ), "dependency_specification")
  if (!identical(header[["Record-Type"]], "rrp-dependency-specification") ||
      !identical(header[["Contract-ID"]], "rrp.dependency-specification") ||
      !identical(header[["Contract-Version"]], "0.1.0") ||
      !identical(header[["Specification-ID"]], manifest[["Dependency-Specification-ID"]]) ||
      !identical(header[["Product-ID"]], manifest[["Product-ID"]]) ||
      !identical(header[["Product-Version"]], manifest[["Product-Version"]]) ||
      !identical(header[["Target-R-Version"]], manifest[["Target-R-Version"]]) ||
      !identical(header[["Target-Platform"]], manifest[["Target-Platform"]]) ||
      !identical(header[["Target-Architecture"]], manifest[["Target-Architecture"]]) ||
      !grepl("^[0-9a-f]{64}$", header[["Specification-ID"]]) ||
      !grepl("^[0-9a-f]{64}$", header[["Repository-Set-ID"]])) {
    rrp_distribution_fail("dependency_specification", "Dependency header disagrees with manifest.")
  }
  packages <- dependencies[-1L]
  if (!identical(as.integer(header[["Package-Count"]]), length(packages)) || !length(packages)) {
    rrp_distribution_fail("dependency_specification", "Dependency closure is empty or miscounted.")
  }
  for (record in packages) {
    rrp_require_fields(record, c(
      "Record-Type", "Package", "Version", "Source-Type", "Repository", "Integrity"
    ), "dependency_specification")
    if (!identical(record[["Record-Type"]], "rrp-dependency") ||
        !grepl("^[A-Za-z][A-Za-z0-9.]+$", record[["Package"]]) ||
        !nzchar(record[["Version"]]) ||
        !identical(record[["Source-Type"]], "repository") ||
        !grepl("^https://", record[["Repository"]]) ||
        !grepl("^renv:[0-9a-f]{32}$", record[["Integrity"]])) {
      rrp_distribution_fail("dependency_specification", "Dependency record lacks provenance or integrity.")
    }
  }
  package_names <- vapply(packages, `[[`, character(1L), "Package")
  if (anyDuplicated(package_names) ||
      !identical(package_names, sort(package_names, method = "radix"))) {
    rrp_distribution_fail("dependency_specification", "Dependency packages are not exact and sorted.")
  }

  package_records <- files[roles == "internal-package"]
  descriptions <- lapply(c("rrpruntime", "rrpplatform"), function(package) {
    match <- package_records[grepl(paste0("/", package, "_"),
                                  paste0("/", vapply(package_records, `[[`, character(1L), "Path")),
                                  fixed = TRUE)]
    if (length(match) != 1L) rrp_distribution_fail("package_artifact", "Internal package artifact is missing.")
    rrp_package_description(file.path(root, match[[1L]][["Path"]]), package)
  })
  names(descriptions) <- c("rrpruntime", "rrpplatform")
  for (package in names(descriptions)) {
    if (!identical(unname(descriptions[[package]][["Package"]]), package) ||
        !identical(unname(descriptions[[package]][["License"]]), "Apache License (>= 2)") ||
        any(grepl("(^|/)tests/", attr(descriptions[[package]], "archive_members"))) ||
        !any(vapply(package_records, function(x) identical(
          basename(x[["Path"]]),
          paste0(package, "_", unname(descriptions[[package]][["Version"]]), ".tar.gz")
        ), logical(1L)))) {
      rrp_distribution_fail("package_artifact", "Internal package identity/license mismatch.")
    }
  }
  imports <- trimws(strsplit(unname(descriptions$rrpplatform[["Imports"]]), ",", fixed = TRUE)[[1L]])
  imports <- sub("[[:space:]]*\\(.*$", "", imports)
  external_direct <- setdiff(imports, "rrpruntime")
  if (!all(external_direct %in% package_names) || !"rrpruntime" %in% imports) {
    rrp_distribution_fail("dependency_drift", "Package Imports disagree with the dependency specification.")
  }

  catalog_records <- rrp_read_dcf(
    file.path(root, "resources", "resource-catalog.dcf"), "resource_catalog"
  )
  if (length(catalog_records) < 2L ||
      !identical(catalog_records[[1L]][["Catalog-ID"]], "rrp.software-resources") ||
      !identical(catalog_records[[1L]][["Development-Version"]], "1.0.0-dev")) {
    rrp_distribution_fail("resource_catalog", "Projected resource catalog is invalid.")
  }
  resources <- catalog_records[-1L]
  if (length(resources) != 67L) {
    rrp_distribution_fail("resource_catalog", "Projected resource count is unsupported.")
  }
  resource_fields <- c(
    "Record-Type", "Resource-ID", "Resource-Class", "Owner-Package",
    "Installed-Path", "Format"
  )
  for (resource in resources) {
    rrp_require_fields(resource, resource_fields, "resource_catalog")
    if (!identical(resource[["Record-Type"]], "resource")) {
      rrp_distribution_fail("resource_catalog", "Projected resource record type is invalid.")
    }
  }
  installed_paths <- vapply(resources, `[[`, character(1L), "Installed-Path")
  if (any(vapply(resources, function(x) "Source-Path" %in% names(x), logical(1L))) ||
      anyDuplicated(installed_paths) || anyDuplicated(tolower(installed_paths))) {
    rrp_distribution_fail("resource_catalog", "Projected resource catalog is not closed.")
  }
  projected <- paste0("resources/", sub("^resources/", "", installed_paths))
  resource_inventory <- file_paths[roles == "installed-resource"]
  if (!identical(sort(projected, method = "radix"),
                 sort(resource_inventory, method = "radix"))) {
    rrp_distribution_fail("resource_catalog", "Projected resources disagree with the inventory.")
  }
  ids <- vapply(resources, `[[`, character(1L), "Resource-ID")
  if (anyDuplicated(ids)) {
    rrp_distribution_fail("resource_catalog", "Projected resource IDs are duplicated.")
  }
  platform_members <- attr(descriptions$rrpplatform, "archive_members")
  expected_package_resources <- paste0("rrpplatform/inst/", installed_paths)
  expected_package_resource_members <- sort(c(
    "rrpplatform/inst/resources/resource-catalog.dcf", expected_package_resources
  ), method = "radix")
  actual_package_resource_members <- sort(
    platform_members[startsWith(platform_members, "rrpplatform/inst/resources/") &
                       !endsWith(platform_members, "/")],
    method = "radix"
  )
  if (!all(expected_package_resources %in% platform_members) ||
      !identical(expected_package_resource_members, actual_package_resource_members) ||
      !"rrpplatform/exec/rrp" %in% platform_members) {
    rrp_distribution_fail(
      "package_artifact",
      "rrpplatform artifact lacks its exact installed resources or version launcher."
    )
  }
  if (!all(c(
    "rrp.documentation.distribution-guide",
    "rrp.documentation.installation-guide",
    "rrp.documentation.software-lifecycle-guide"
  ) %in% ids)) {
    rrp_distribution_fail("documentation", "Required software lifecycle guidance is absent from the resource catalog.")
  }
  if (!all(c("LICENSE", "NOTICE", "README.md",
             "documentation/SECURITY.md", "documentation/SUPPORT.md",
             "VERSION.yml", "bin/rrp", "verify-distribution.R",
             "install.R", "install-engine.R") %in% file_paths)) {
    rrp_distribution_fail("required_content", "Required legal, documentation, version, launcher, or verifier content is absent.")
  }
  license_text <- paste(readLines(file.path(root, "LICENSE"), warn = FALSE), collapse = "\n")
  notice_text <- paste(readLines(file.path(root, "NOTICE"), warn = FALSE), collapse = "\n")
  version_lines <- readLines(file.path(root, "VERSION.yml"), warn = FALSE)
  if (!all(vapply(c(
    "Apache License", "Version 2.0, January 2004", "END OF TERMS AND CONDITIONS"
  ), grepl, logical(1L), x = license_text, fixed = TRUE)) ||
      !grepl("Readmission Risk Pool Platform", notice_text, fixed = TRUE) ||
      !all(c(
        "product_id: readmission-risk-pool-platform",
        "development_version: 1.0.0-dev",
        "release_status: not_released"
      ) %in% version_lines)) {
    rrp_distribution_fail("legal_identity", "Legal or product-version content is inconsistent.")
  }
  invisible(list(manifest = manifest, dependencies = dependencies, inventory = inventory))
}

rrp_distribution_main <- function(arguments = commandArgs(trailingOnly = TRUE)) {
  if (length(arguments) != 1L) {
    cat("Usage: Rscript --vanilla verify-distribution.R DISTRIBUTION_ROOT\n", file = stderr())
    return(2L)
  }
  tryCatch({
    result <- rrp_verify_distribution(arguments[[1L]])
    cat(sprintf("PASS distribution %s\n", result$manifest[["Distribution-ID"]]))
    0L
  }, error = function(e) {
    cat("FAIL distribution verification\n", conditionMessage(e), "\n", file = stderr())
    1L
  })
}

if (sys.nframe() == 0L) {
  quit(save = "no", status = rrp_distribution_main(), runLast = FALSE)
}
