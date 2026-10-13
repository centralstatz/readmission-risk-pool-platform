rrp_software_abort <- function(code, message = "Installed software is invalid.") {
  condition <- structure(
    list(message = message, call = NULL, code = code),
    class = c("rrp_software_error", "error", "condition")
  )
  stop(condition)
}

rrp_software_read_dcf <- function(path, code = "invalid_installed_software") {
  if (!file.exists(path) || !isTRUE(utils::file_test("-f", path)) ||
      nzchar(Sys.readlink(path))) {
    rrp_software_abort(code)
  }
  tryCatch(
    lapply(seq_len(nrow(records <- read.dcf(path, all = TRUE))), function(i) {
      row <- records[i, , drop = TRUE]
      unlist(row[!is.na(row)], use.names = TRUE)
    }),
    error = function(condition) rrp_software_abort(code)
  )
}

rrp_software_sha256 <- function(path) {
  utility <- Sys.which("sha256sum")
  arguments <- path
  if (!nzchar(utility)) {
    utility <- Sys.which("shasum")
    arguments <- c("-a", "256", path)
  }
  if (!nzchar(utility)) rrp_software_abort("integrity_tool_unavailable")
  output <- suppressWarnings(system2(
    utility, arguments, stdout = TRUE, stderr = TRUE
  ))
  status <- attr(output, "status")
  digest <- if (length(output)) sub("[[:space:]].*$", "", output[[1L]]) else ""
  if ((!is.null(status) && status != 0L) ||
      !grepl("^[0-9a-f]{64}$", digest)) {
    rrp_software_abort("integrity_check_failed")
  }
  digest
}

rrp_software_hash_lines <- function(lines) {
  temporary <- tempfile("rrp-software-identity-")
  on.exit(unlink(temporary, force = TRUE), add = TRUE)
  writeLines(enc2utf8(lines), temporary, useBytes = TRUE)
  rrp_software_sha256(temporary)
}

rrp_software_selector_valid <- function(selector) {
  rrp_resource_scalar_string(selector) && nchar(selector) <= 96L && grepl(
    paste0(
      "^[0-9]+[.][0-9]+[.][0-9]+",
      "(?:-[a-z0-9]+(?:[.-][a-z0-9]+)*)?/[0-9a-f]{64}$"
    ), selector, perl = TRUE
  )
}

rrp_software_root_from_installation <- function(software_root) {
  software_root <- normalizePath(software_root, winslash = "/", mustWork = TRUE)
  root <- dirname(dirname(dirname(software_root)))
  expected <- file.path(
    root, "installations", basename(dirname(software_root)),
    basename(software_root)
  )
  if (!identical(software_root, expected) || nzchar(Sys.readlink(root))) {
    rrp_software_abort("invalid_installation_root")
  }
  root
}

rrp_software_selector_path <- function(root, selector, must_work = TRUE) {
  if (!rrp_software_selector_valid(selector)) {
    rrp_software_abort("invalid_software_selector")
  }
  parts <- strsplit(selector, "/", fixed = TRUE)[[1L]]
  path <- file.path(root, "installations", parts[[1L]], parts[[2L]])
  link <- Sys.readlink(path)
  if (must_work && !is.na(link) && nzchar(link)) {
    rrp_software_abort("linked_installation_refused")
  }
  if (must_work && !dir.exists(path)) {
    rrp_software_abort("installed_software_not_found")
  }
  if (must_work) normalizePath(path, winslash = "/", mustWork = TRUE) else path
}

rrp_software_lifecycle_lock <- function(root, code) {
  staging <- file.path(root, "staging")
  if (!dir.exists(staging) || nzchar(Sys.readlink(staging))) {
    rrp_software_abort(code)
  }
  lock <- file.path(staging, ".software-lifecycle-lock")
  if (!dir.create(lock, showWarnings = FALSE)) rrp_software_abort(code)
  lock
}

rrp_software_remove_tree <- function(path) {
  entries <- list.files(
    path, all.files = TRUE, full.names = TRUE, recursive = TRUE,
    include.dirs = TRUE, no.. = TRUE
  )
  files <- entries[!dir.exists(entries)]
  directories <- c(entries[dir.exists(entries)], path)
  if (length(files)) Sys.chmod(files, mode = "0600", use_umask = FALSE)
  if (length(directories)) {
    Sys.chmod(directories, mode = "0700", use_umask = FALSE)
  }
  unlink(path, recursive = TRUE, force = TRUE)
  !file.exists(path) && !dir.exists(path)
}

rrp_software_record <- function(path) {
  records <- rrp_software_read_dcf(
    file.path(path, "INSTALLATION.dcf"), "invalid_installation_record"
  )
  fields <- c(
    "Record-Type", "Contract-ID", "Contract-Version", "Installation-ID",
    "Product-ID", "Product-Version", "Development-Version", "Distribution-ID",
    "Build-ID", "Dependency-Specification-ID", "Host-R-Executable",
    "Host-R-Version", "Platform", "Architecture", "Private-Library",
    "Resource-Root", "Distribution-Manifest-Digest", "Installed-At"
  )
  if (length(records) != 1L || !identical(names(records[[1L]]), fields)) {
    rrp_software_abort("invalid_installation_record")
  }
  record <- records[[1L]]
  expected <- c(
    "Record-Type" = "rrp-installation",
    "Contract-ID" = "rrp.installation-record",
    "Contract-Version" = "0.1.0",
    "Product-ID" = "readmission-risk-pool-platform",
    "Development-Version" = "1.0.0-dev"
  )
  if (!identical(unname(record[names(expected)]), unname(expected)) ||
      any(!grepl("^[0-9a-f]{64}$", record[c(
        "Installation-ID", "Distribution-ID", "Build-ID",
        "Dependency-Specification-ID", "Distribution-Manifest-Digest"
      )])) || !grepl(
        "^[0-9]{4}-[0-9]{2}-[0-9]{2}T[0-9]{2}:[0-9]{2}:[0-9]{2}Z$",
        record[["Installed-At"]]
      )) {
    rrp_software_abort("invalid_installation_record")
  }
  selector <- paste(
    record[["Product-Version"]], record[["Distribution-ID"]], sep = "/"
  )
  if (!rrp_software_selector_valid(selector) ||
      !identical(normalizePath(path, winslash = "/", mustWork = TRUE),
        record[["Resource-Root"]]) ||
      !identical(file.path(path, "library"), record[["Private-Library"]]) ||
      !identical(record[["Installation-ID"]], rrp_software_hash_lines(c(
        "rrp-installation-identity-v1",
        paste0("distribution=", record[["Distribution-ID"]]),
        paste0("build=", record[["Build-ID"]]),
        paste0("dependencies=", record[["Dependency-Specification-ID"]]),
        paste0("r-version=", record[["Host-R-Version"]]),
        paste0("platform=", record[["Platform"]]),
        paste0("architecture=", record[["Architecture"]]),
        paste0("manifest=", record[["Distribution-Manifest-Digest"]])
      )))) {
    rrp_software_abort("invalid_installation_record")
  }
  record
}

rrp_software_activation_record <- function(root, required = FALSE) {
  path <- file.path(root, "active.dcf")
  if (!file.exists(path)) {
    if (required) rrp_software_abort("active_software_not_selected")
    return(NULL)
  }
  records <- rrp_software_read_dcf(path, "invalid_active_selection")
  fields <- c(
    "Record-Type", "Contract-ID", "Contract-Version", "Product-ID",
    "Product-Version", "Installation-ID", "Distribution-ID", "Activated-At"
  )
  expected <- c(
    "Record-Type" = "rrp-activation",
    "Contract-ID" = "rrp.activation-record",
    "Contract-Version" = "0.1.0",
    "Product-ID" = "readmission-risk-pool-platform"
  )
  if (length(records) != 1L || !identical(names(records[[1L]]), fields) ||
      !identical(unname(records[[1L]][names(expected)]), unname(expected)) ||
      any(!grepl("^[0-9a-f]{64}$", records[[1L]][c(
        "Installation-ID", "Distribution-ID"
      )])) || !grepl(
        "^[0-9]{4}-[0-9]{2}-[0-9]{2}T[0-9]{2}:[0-9]{2}:[0-9]{2}Z$",
        records[[1L]][["Activated-At"]]
      )) {
    rrp_software_abort("invalid_active_selection")
  }
  activation <- records[[1L]]
  selector <- paste(
    activation[["Product-Version"]], activation[["Distribution-ID"]], sep = "/"
  )
  record <- tryCatch({
    installation <- rrp_software_selector_path(root, selector)
    rrp_software_record(installation)
  }, rrp_software_error = function(condition) {
    rrp_software_abort("invalid_active_selection")
  })
  if (!identical(record[["Installation-ID"]], activation[["Installation-ID"]])) {
    rrp_software_abort("invalid_active_selection")
  }
  c(activation, "Selector" = selector)
}

rrp_software_tree <- function(root) {
  result <- list()
  visit <- function(directory, relative = "") {
    entries <- list.files(
      directory, all.files = TRUE, full.names = TRUE, no.. = TRUE
    )
    for (entry in entries) {
      path <- if (nzchar(relative)) {
        paste(relative, basename(entry), sep = "/")
      } else basename(entry)
      linked <- nzchar(Sys.readlink(entry))
      directory_entry <- dir.exists(entry)
      result[[length(result) + 1L]] <<- list(
        path = path, absolute = entry, directory = directory_entry,
        link = linked
      )
      if (directory_entry && !linked) visit(entry, path)
    }
  }
  visit(root)
  result
}

rrp_software_description_hash <- function(path) {
  bytes <- readBin(path, "raw", n = file.info(path)$size)
  contents <- NULL
  for (encoding in c("UTF-8", "latin1", "")) {
    candidate <- iconv(list(bytes), from = encoding, to = "UTF-8")
    if (!is.na(candidate[[1L]])) {
      contents <- candidate[[1L]]
      break
    }
  }
  if (is.null(contents)) rrp_software_abort("dependency_integrity")
  parts <- strsplit(contents, "\\r?\\n(?=\\S)", perl = TRUE)[[1L]]
  parts <- gsub("\\r?\\n\\s*", " ", parts, perl = TRUE)
  index <- regexpr(":", parts, fixed = TRUE)
  keys <- substring(parts, 1L, index - 1L)
  values <- trimws(substring(parts, index + 1L))
  if (any(index < 1L) || any(!nzchar(keys))) {
    rrp_software_abort("dependency_integrity")
  }
  storage.mode(values) <- "list"
  names(values) <- keys
  fields <- c(
    "Package", "Version", "Title", "Author", "Maintainer", "Description",
    "Depends", "Imports", "Suggests", "LinkingTo"
  )
  selected <- values[intersect(fields, names(values))]
  selected <- selected[sort(names(selected), method = "radix")]
  text <- gsub(
    "[[:space:]]", "", paste(names(selected), selected, sep = ": ", collapse = "\n")
  )
  temporary <- tempfile("rrp-description-hash-")
  on.exit(unlink(temporary, force = TRUE), add = TRUE)
  writeLines(enc2utf8(text), temporary, useBytes = TRUE)
  unname(tools::md5sum(temporary))
}

rrp_software_archive_description <- function(archive, package) {
  members <- utils::untar(archive, list = TRUE)
  expected <- paste0(package, "/DESCRIPTION")
  if (sum(members == expected) != 1L || any(grepl(
    "(^|/)[.][.]($|/)|^[A-Za-z]:|^/|\\\\", members
  ))) rrp_software_abort("invalid_internal_package")
  temporary <- tempfile("rrp-package-description-")
  dir.create(temporary)
  on.exit(unlink(temporary, recursive = TRUE, force = TRUE), add = TRUE)
  utils::untar(archive, files = expected, exdir = temporary)
  description <- read.dcf(file.path(temporary, expected), all = TRUE)
  if (nrow(description) != 1L) rrp_software_abort("invalid_internal_package")
  description[1L, , drop = TRUE]
}

rrp_software_verify_success <- function(path, root) {
  if (nzchar(Sys.readlink(path))) rrp_software_abort("linked_installed_software")
  record <- rrp_software_record(path)
  manifest_records <- rrp_software_read_dcf(
    file.path(path, "manifest.dcf"), "invalid_distribution_manifest"
  )
  inventory <- rrp_software_read_dcf(
    file.path(path, "inventory.dcf"), "invalid_distribution_inventory"
  )
  if (length(manifest_records) != 1L || length(inventory) < 2L) {
    rrp_software_abort("invalid_distribution_inventory")
  }
  manifest <- manifest_records[[1L]]
  manifest_fields <- c(
    "Record-Type", "Contract-ID", "Contract-Version", "Product-ID",
    "Product-Version", "Development-Version", "Distribution-ID", "Build-ID",
    "Target-R-Version", "Target-Platform", "Target-Architecture",
    "Dependency-Specification-ID", "Resource-Catalog-ID", "Inventory-Digest",
    "Source-Revision", "Source-State", "Built-At"
  )
  manifest_expected <- c(
    "Record-Type" = "rrp-distribution",
    "Contract-ID" = "rrp.distribution-manifest",
    "Contract-Version" = "0.1.0",
    "Product-ID" = "readmission-risk-pool-platform",
    "Product-Version" = "1.0.0-dev",
    "Development-Version" = "1.0.0-dev",
    "Resource-Catalog-ID" = "rrp.software-resources"
  )
  identity_path <- file.path(path, "identity.txt")
  identity_lines <- if (file.exists(identity_path)) {
    readLines(identity_path, warn = FALSE, encoding = "UTF-8")
  } else character()
  identity_sources <- if (length(identity_lines) > 2L) {
    identity_lines[-c(1L, length(identity_lines))]
  } else character()
  if (!identical(names(manifest), manifest_fields) ||
      !identical(unname(manifest[names(manifest_expected)]),
        unname(manifest_expected)) ||
      any(!grepl("^[0-9a-f]{64}$", manifest[c(
        "Distribution-ID", "Build-ID", "Dependency-Specification-ID",
        "Inventory-Digest"
      )])) ||
      !identical(record[["Distribution-ID"]], manifest[["Distribution-ID"]]) ||
      !identical(record[["Build-ID"]], manifest[["Build-ID"]]) ||
      !identical(record[["Product-Version"]], manifest[["Product-Version"]]) ||
      !identical(record[["Dependency-Specification-ID"]],
        manifest[["Dependency-Specification-ID"]]) ||
      !identical(record[["Distribution-Manifest-Digest"]],
        rrp_software_sha256(file.path(path, "manifest.dcf"))) ||
      !identical(manifest[["Inventory-Digest"]],
        rrp_software_sha256(file.path(path, "inventory.dcf"))) ||
      !identical(rrp_software_sha256(identity_path),
        manifest[["Distribution-ID"]]) || length(identity_lines) < 3L ||
      !identical(identity_lines[[1L]], "rrp-distribution-identity-v1") ||
      any(!grepl("^source:[^=]+=[0-9a-f]{64}$", identity_sources)) ||
      !identical(utils::tail(identity_lines, 1L), paste0(
        "dependency-specification=", rrp_software_sha256(file.path(
          path, "dependencies", "dependencies.dcf"
        ))
      ))) {
    rrp_software_abort("installed_identity_mismatch")
  }
  files <- inventory[-1L]
  inventory_paths <- vapply(files, `[[`, character(1L), "Path")
  inventory_header <- inventory[[1L]]
  inventory_header_fields <- c(
    "Record-Type", "Inventory-Version", "Distribution-ID", "File-Count"
  )
  file_fields <- c("Record-Type", "Path", "Role", "Size", "SHA256")
  if (!identical(names(inventory_header), inventory_header_fields) ||
      !identical(unname(inventory_header[c(
        "Record-Type", "Inventory-Version", "Distribution-ID"
      )]), c(
        "distribution-inventory", "0.1.0", manifest[["Distribution-ID"]]
      )) || !identical(
        suppressWarnings(as.integer(inventory_header[["File-Count"]])),
        length(files)
      ) || any(vapply(files, function(entry) {
        !identical(names(entry), file_fields) ||
          !identical(entry[["Record-Type"]], "file") ||
          !grepl("^[0-9]+$", entry[["Size"]]) ||
          !grepl("^[0-9a-f]{64}$", entry[["SHA256"]])
      }, logical(1L))) || anyDuplicated(inventory_paths) ||
      anyDuplicated(tolower(inventory_paths)) || !identical(
        inventory_paths, sort(inventory_paths, method = "radix")
      )) rrp_software_abort("invalid_distribution_inventory")
  for (entry in files) {
    target <- file.path(path, entry[["Path"]])
    if (!rrp_project_safe_relative_path(entry[["Path"]]) ||
        !file.exists(target) || !isTRUE(utils::file_test("-f", target)) ||
        nzchar(Sys.readlink(target)) ||
        !identical(as.character(file.info(target)$size), entry[["Size"]]) ||
        !identical(rrp_software_sha256(target), entry[["SHA256"]])) {
      rrp_software_abort("installed_payload_integrity")
    }
  }
  tree <- rrp_software_tree(path)
  if (any(vapply(tree, `[[`, logical(1L), "link"))) {
    rrp_software_abort("linked_installed_software")
  }
  non_library_files <- vapply(Filter(function(entry) {
    !entry$directory && !startsWith(entry$path, "library/") &&
      !identical(entry$path, "INSTALLATION.dcf")
  }, tree), `[[`, character(1L), "path")
  if (!setequal(non_library_files, c(
    "manifest.dcf", "inventory.dcf", inventory_paths
  ))) rrp_software_abort("unexpected_installed_content")

  dependencies <- rrp_software_read_dcf(
    file.path(path, "dependencies", "dependencies.dcf"),
    "invalid_dependency_specification"
  )
  if (length(dependencies) < 2L || !identical(
    dependencies[[1L]][["Specification-ID"]],
    record[["Dependency-Specification-ID"]]
  )) rrp_software_abort("invalid_dependency_specification")
  packages <- dependencies[-1L]
  expected_versions <- stats::setNames(
    vapply(packages, `[[`, character(1L), "Version"),
    vapply(packages, `[[`, character(1L), "Package")
  )
  archives <- list.files(
    file.path(path, "packages"), pattern = "[.]tar[.]gz$", full.names = TRUE
  )
  for (package in c("rrpruntime", "rrpplatform")) {
    match <- archives[startsWith(basename(archives), paste0(package, "_"))]
    if (length(match) != 1L) rrp_software_abort("invalid_internal_package")
    description <- rrp_software_archive_description(match[[1L]], package)
    expected_versions[[package]] <- unname(description[["Version"]])
  }
  private_library <- record[["Private-Library"]]
  installed <- utils::installed.packages(lib.loc = private_library, noCache = TRUE)
  if (!setequal(rownames(installed), names(expected_versions)) ||
      !identical(
        unname(installed[names(expected_versions), "Version"]),
        unname(expected_versions)
      )) rrp_software_abort("private_dependency_closure")
  for (package in names(expected_versions)) {
    package_root <- file.path(private_library, package)
    if (!dir.exists(package_root) || nzchar(Sys.readlink(package_root)) ||
        !identical(
          unname(read.dcf(file.path(package_root, "DESCRIPTION"), all = TRUE)[
            1L, "Version"
          ]), expected_versions[[package]]
        )) rrp_software_abort("private_dependency_closure")
  }
  expected_integrity <- stats::setNames(
    sub("^renv:", "", vapply(packages, `[[`, character(1L), "Integrity")),
    vapply(packages, `[[`, character(1L), "Package")
  )
  actual_integrity <- vapply(names(expected_integrity), function(package) {
    rrp_software_description_hash(file.path(
      private_library, package, "DESCRIPTION"
    ))
  }, character(1L))
  integrity_matches <- identical(
    sort(names(actual_integrity), method = "radix"),
    sort(names(expected_integrity), method = "radix")
  ) && all(vapply(names(expected_integrity), function(package) {
    identical(
      unname(actual_integrity[[package]]),
      unname(expected_integrity[[package]])
    )
  }, logical(1L)))
  if (!integrity_matches) {
    rrp_software_abort("dependency_integrity")
  }

  host <- record[["Host-R-Executable"]]
  if (!file.exists(host) || dir.exists(host) || nzchar(Sys.readlink(host))) {
    rrp_software_abort("host_r_unavailable")
  }
  script <- tempfile("rrp-installed-verification-", fileext = ".R")
  on.exit(unlink(script, force = TRUE), add = TRUE)
  expression <- c(
    paste0("private <- ", encodeString(private_library, quote = "\"")),
    paste0("root <- ", encodeString(path, quote = "\"")),
    ".libPaths(c(private,.Library))",
    "packages <- installed.packages(lib.loc=private,noCache=TRUE)",
    paste0("expected <- c(", paste(vapply(
      names(expected_versions), encodeString, character(1L), quote = "\""
    ), collapse = ","), ")"),
    "stopifnot(setequal(rownames(packages),expected))",
    "paths <- vapply(expected,find.package,character(1L),quiet=TRUE)",
    "prefix <- paste0(normalizePath(private,winslash='/'),'/')",
    "stopifnot(all(startsWith(normalizePath(paths,winslash='/'),prefix)))",
    "library(rrpplatform)",
    "result <- rrp_validate_software_resources(root)",
    "stopifnot(rrp_operation_succeeded(result))",
    "cat(as.character(getRversion()),R.version$platform,R.version$arch,sep='\\n')"
  )
  writeLines(expression, script, useBytes = TRUE)
  environment <- c(
    "R_PROFILE_USER=", "R_ENVIRON_USER=", "R_LIBS=",
    paste0("R_LIBS_USER=", private_library),
    paste0("R_LIBS_SITE=", file.path(private_library, ".rrp-no-site-library"))
  )
  output <- suppressWarnings(system2(
    host, c("--vanilla", "--slave", paste0("--file=", shQuote(script))),
    stdout = TRUE, stderr = TRUE, env = environment
  ))
  status <- attr(output, "status")
  if ((!is.null(status) && status != 0L) || length(output) != 3L ||
      !identical(output, unname(record[c(
        "Host-R-Version", "Platform", "Architecture"
      )]))) rrp_software_abort("installed_runtime_verification")
  launcher <- file.path(path, "bin", "rrp")
  if (!file.exists(launcher) || !isTRUE(utils::file_test("-f", launcher)) ||
      nzchar(Sys.readlink(launcher)) || file.access(launcher, 1L) != 0L) {
    rrp_software_abort("version_launcher_unavailable")
  }
  active <- tryCatch(
    rrp_software_activation_record(root), rrp_software_error = function(e) e
  )
  activation_status <- if (inherits(active, "rrp_software_error")) {
    "invalid"
  } else if (is.null(active)) {
    "not_selected"
  } else if (identical(active[["Installation-ID"]], record[["Installation-ID"]])) {
    "active"
  } else {
    "inactive"
  }
  list(
    record = record,
    selector = paste(record[["Product-Version"]], record[["Distribution-ID"]], sep = "/"),
    activation_status = activation_status
  )
}

rrp_software_diagnosis_value <- function(verified, status = "ready", checks = NULL) {
  record <- verified$record
  if (is.null(checks)) checks <- list(
    rrp_lifecycle_check("installation_record", "pass"),
    rrp_lifecycle_check("distribution_integrity", "pass"),
    rrp_lifecycle_check("host_r", "pass"),
    rrp_lifecycle_check("private_library", "pass"),
    rrp_lifecycle_check("software_resources", "pass"),
    rrp_lifecycle_check("version_launcher", "pass")
  )
  value <- list(
    software_status = status,
    product_id = unname(record[["Product-ID"]]),
    product_version = unname(record[["Product-Version"]]),
    installation_id = unname(record[["Installation-ID"]]),
    distribution_id = unname(record[["Distribution-ID"]]),
    host_r_status = "ready",
    private_library_status = "ready",
    resource_status = "ready",
    launcher_status = "ready",
    activation_status = verified$activation_status,
    checks = checks
  )
  rrp_software_diagnosis_validate_value(value)
  value
}

rrp_software_diagnosis_validate_value <- function(value) {
  contract <- rrp_installed_diagnosis_contract_expected()
  fields <- strsplit(contract[["Value-Fields"]], ",", fixed = TRUE)[[1L]]
  statuses <- strsplit(
    contract[["Software-Status-Values"]], ",", fixed = TRUE
  )[[1L]]
  check_statuses <- strsplit(
    contract[["Check-Status-Values"]], ",", fixed = TRUE
  )[[1L]]
  scalar_fields <- setdiff(fields, "checks")
  optional_identity_fields <- c(
    "product_version", "installation_id", "distribution_id"
  )
  required_scalar_fields <- setdiff(
    scalar_fields, optional_identity_fields
  )
  valid <- is.list(value) && identical(names(value), fields) &&
    all(vapply(
      value[required_scalar_fields], rrp_resource_scalar_string, logical(1L)
    )) && all(vapply(value[optional_identity_fields], function(item) {
      is.character(item) && length(item) == 1L && !is.na(item)
    }, logical(1L))) &&
    value$software_status %in% statuses && is.list(value$checks) &&
    all(vapply(value$checks, function(check) {
      is.list(check) && identical(
        names(check), c("check_id", "status", "recovery_code")
      ) && rrp_diagnostic_code_is_valid(check$check_id) &&
        check$status %in% check_statuses &&
        rrp_diagnostic_code_is_valid(check$recovery_code)
    }, logical(1L)))
  if (!valid) stop("Invalid internal installed diagnosis.", call. = FALSE)
  invisible(value)
}

rrp_verify_installed_software <- function(root, selector) {
  tryCatch({
    path <- rrp_software_selector_path(root, selector)
    verified <- rrp_software_verify_success(path, root)
    rrp_new_operation_result(
      "rrp.verify-installed-software", "success",
      rrp_software_diagnosis_value(verified), list()
    )
  }, rrp_software_error = function(condition) rrp_lifecycle_failure(
    condition, "rrp.verify-installed-software",
    "Installed software verification failed."
  ), error = function(condition) rrp_lifecycle_failure(
    condition, "rrp.verify-installed-software",
    "Installed software verification failed.", "installed_verification_failed"
  ))
}

rrp_software_candidate_selectors <- function(root) {
  installations <- file.path(root, "installations")
  if (!dir.exists(installations) || nzchar(Sys.readlink(installations))) {
    return(character())
  }
  versions <- list.dirs(installations, recursive = FALSE, full.names = TRUE)
  selectors <- unlist(lapply(versions, function(version) {
    if (nzchar(Sys.readlink(version))) return(character())
    identities <- list.dirs(version, recursive = FALSE, full.names = TRUE)
    identities <- identities[!nzchar(Sys.readlink(identities))]
    paste(basename(version), basename(identities), sep = "/")
  }), use.names = FALSE)
  if (is.null(selectors)) selectors <- character()
  sort(selectors[vapply(selectors, rrp_software_selector_valid, logical(1L))],
    method = "radix")
}

rrp_list_installed_software <- function(root) {
  selectors <- rrp_software_candidate_selectors(root)
  active <- tryCatch(
    rrp_software_activation_record(root), rrp_software_error = function(e) e
  )
  entries <- lapply(selectors, function(selector) {
    path <- rrp_software_selector_path(root, selector)
    verified <- tryCatch(
      rrp_software_verify_success(path, root),
      rrp_software_error = function(condition) NULL
    )
    list(
      selector = selector,
      product_version = strsplit(selector, "/", fixed = TRUE)[[1L]][[1L]],
      installation_id = if (is.null(verified)) "" else
        unname(verified$record[["Installation-ID"]]),
      distribution_id = strsplit(selector, "/", fixed = TRUE)[[1L]][[2L]],
      status = if (is.null(verified)) "invalid" else if (
        !inherits(active, "rrp_software_error") && !is.null(active) &&
        identical(active[["Selector"]], selector)
      ) "active" else "verified"
    )
  })
  diagnostics <- if (inherits(active, "rrp_software_error")) {
    list(rrp_new_diagnostic(
      "invalid_active_selection", "warning", "The active software selection is invalid."
    ))
  } else list()
  rrp_new_operation_result(
    "rrp.software-list", "success",
    list(
      installation_root = root,
      active_selector = if (is.null(active) || inherits(active, "rrp_software_error")) "" else active[["Selector"]],
      installations = entries
    ), diagnostics
  )
}

rrp_current_installed_software <- function(root) {
  active <- tryCatch(
    rrp_software_activation_record(root), rrp_software_error = function(e) e
  )
  if (inherits(active, "rrp_software_error")) return(rrp_lifecycle_failure(
    active, "rrp.software-current", "Active software selection is invalid."
  ))
  if (is.null(active)) return(rrp_new_operation_result(
    "rrp.software-current", "success",
    list(
      active = FALSE, selector = "", product_version = "",
      installation_id = "", distribution_id = ""
    ), list(rrp_new_diagnostic(
      "active_software_not_selected", "warning", "No active software version is selected."
    ))
  ))
  rrp_new_operation_result(
    "rrp.software-current", "success",
    list(
      active = TRUE, selector = unname(active[["Selector"]]),
      product_version = unname(active[["Product-Version"]]),
      installation_id = unname(active[["Installation-ID"]]),
      distribution_id = unname(active[["Distribution-ID"]])
    ), list()
  )
}

rrp_software_activate <- function(root, selector, failure_stage = NULL) {
  tryCatch({
    lock <- rrp_software_lifecycle_lock(root, "activation_locked")
    on.exit(if (dir.exists(lock)) unlink(lock, recursive = TRUE, force = TRUE),
      add = TRUE)
    path <- rrp_software_selector_path(root, selector)
    verified <- rrp_software_verify_success(path, root)
    current <- tryCatch(
      rrp_software_activation_record(root), rrp_software_error = function(e) e
    )
    if (inherits(current, "rrp_software_error")) {
      rrp_software_abort("invalid_active_selection")
    }
    if (!is.null(current) && identical(
      current[["Installation-ID"]], verified$record[["Installation-ID"]]
    ) && is.null(failure_stage)) return(rrp_new_operation_result(
      "rrp.software-activate", "success",
      list(
        selector = selector,
        installation_id = unname(verified$record[["Installation-ID"]]),
        product_version = unname(verified$record[["Product-Version"]]),
        distribution_id = unname(verified$record[["Distribution-ID"]]),
        previous_selector = selector, reused = TRUE
      ), list()
    ))
    staging <- file.path(root, "staging")
    if (identical(failure_stage, "before_promotion")) {
      rrp_software_abort("activation_promotion_failed")
    }
    record <- c(
      "Record-Type" = "rrp-activation",
      "Contract-ID" = "rrp.activation-record",
      "Contract-Version" = "0.1.0",
      "Product-ID" = "readmission-risk-pool-platform",
      "Product-Version" = verified$record[["Product-Version"]],
      "Installation-ID" = verified$record[["Installation-ID"]],
      "Distribution-ID" = verified$record[["Distribution-ID"]],
      "Activated-At" = format(Sys.time(), "%Y-%m-%dT%H:%M:%SZ", tz = "UTC")
    )
    target <- file.path(root, "active.dcf")
    staged <- tempfile(".active-", tmpdir = staging, fileext = ".dcf")
    on.exit(if (file.exists(staged)) unlink(staged, force = TRUE), add = TRUE)
    write.dcf(matrix(unname(record), nrow = 1L,
      dimnames = list(NULL, names(record))), file = staged, width = 500L)
    previous <- if (file.exists(target)) readBin(target, "raw", n = file.info(target)$size) else NULL
    if (!isTRUE(file.rename(staged, target))) {
      rrp_software_abort("activation_promotion_failed")
    }
    promoted <- tryCatch(
      rrp_software_activation_record(root, required = TRUE),
      rrp_software_error = function(e) e
    )
    if (identical(failure_stage, "after_promotion") ||
        inherits(promoted, "rrp_software_error") ||
        !identical(promoted[["Installation-ID"]], record[["Installation-ID"]])) {
      if (is.null(previous)) {
        unlink(target, force = TRUE)
      } else {
        rollback <- tempfile(".active-rollback-", tmpdir = staging)
        connection <- file(rollback, open = "wb")
        writeBin(previous, connection)
        close(connection)
        if (!isTRUE(file.rename(rollback, target))) unlink(rollback, force = TRUE)
      }
      rrp_software_abort("activation_promotion_failed")
    }
    rrp_new_operation_result(
      "rrp.software-activate", "success",
      list(
        selector = selector,
        installation_id = unname(record[["Installation-ID"]]),
        product_version = unname(record[["Product-Version"]]),
        distribution_id = unname(record[["Distribution-ID"]]),
        previous_selector = if (is.null(current)) "" else unname(current[["Selector"]]),
        reused = FALSE
      ), list()
    )
  }, rrp_software_error = function(condition) rrp_lifecycle_failure(
    condition, "rrp.software-activate", "Software activation failed."
  ), error = function(condition) rrp_lifecycle_failure(
    condition, "rrp.software-activate", "Software activation failed.",
    "software_activation_failed"
  ))
}

rrp_software_uninstall <- function(
  root, selector, stable_shim, failure_stage = NULL
) {
  tryCatch({
    if (!rrp_resource_scalar_string(stable_shim) ||
        !file.exists(stable_shim) ||
        !isTRUE(utils::file_test("-f", stable_shim)) ||
        nzchar(Sys.readlink(stable_shim)) || file.access(stable_shim, 1L) != 0L) {
      rrp_software_abort("stable_shim_unavailable")
    }
    lock <- rrp_software_lifecycle_lock(root, "software_lifecycle_locked")
    on.exit(if (dir.exists(lock)) unlink(lock, recursive = TRUE, force = TRUE),
      add = TRUE)
    path <- rrp_software_selector_path(root, selector, must_work = FALSE)
    parts <- strsplit(selector, "/", fixed = TRUE)[[1L]]
    quarantine <- file.path(
      root, "staging", paste0(".uninstall-", parts[[1L]], "-", parts[[2L]])
    )
    if (file.exists(quarantine) || dir.exists(quarantine)) {
      rrp_software_abort("uninstall_recovery_required")
    }
    path <- rrp_software_selector_path(root, selector)
    installation_lock <- file.path(
      root, "staging", paste0(".lock-", parts[[1L]], "-", parts[[2L]])
    )
    if (dir.exists(installation_lock) || file.exists(installation_lock)) {
      rrp_software_abort("software_lifecycle_locked")
    }
    active <- rrp_software_activation_record(root)
    if (!is.null(active) && identical(active[["Selector"]], selector)) {
      rrp_software_abort("active_installation_uninstall_refused")
    }
    verified <- rrp_software_verify_success(path, root)
    candidates <- rrp_software_candidate_selectors(root)
    if (!selector %in% candidates) rrp_software_abort("installed_software_not_found")
    other_verified <- vapply(setdiff(candidates, selector), function(candidate) {
      tryCatch({
        rrp_software_verify_success(
          rrp_software_selector_path(root, candidate), root
        )
        TRUE
      }, rrp_software_error = function(condition) FALSE,
      error = function(condition) FALSE)
    }, logical(1L))
    if (!length(other_verified) || !any(other_verified)) {
      rrp_software_abort("final_installation_uninstall_refused")
    }
    if (identical(failure_stage, "before_quarantine") ||
        !isTRUE(file.rename(path, quarantine))) {
      rrp_software_abort("uninstall_removal_failed")
    }
    if (identical(failure_stage, "after_quarantine")) {
      if (!isTRUE(file.rename(quarantine, path))) {
        rrp_software_abort("uninstall_recovery_required")
      }
      rrp_software_abort("uninstall_removal_failed")
    }
    if (!rrp_software_remove_tree(quarantine)) {
      rrp_software_abort("uninstall_cleanup_failed")
    }
    version_root <- dirname(path)
    if (dir.exists(version_root) && !length(list.files(
      version_root, all.files = TRUE, no.. = TRUE
    ))) {
      Sys.chmod(version_root, mode = "0700", use_umask = FALSE)
      unlink(version_root, recursive = FALSE, force = TRUE)
    }
    remaining <- rrp_software_candidate_selectors(root)
    if (selector %in% remaining || file.exists(path) || dir.exists(path) ||
        !file.exists(stable_shim)) {
      rrp_software_abort("uninstall_cleanup_failed")
    }
    rrp_new_operation_result(
      "rrp.software-uninstall", "success",
      list(
        selector = selector,
        installation_id = unname(verified$record[["Installation-ID"]]),
        product_version = unname(verified$record[["Product-Version"]]),
        distribution_id = unname(verified$record[["Distribution-ID"]]),
        remaining_installation_count = as.integer(length(remaining)),
        final_installation = FALSE,
        shim_preserved = TRUE
      ), list()
    )
  }, rrp_software_error = function(condition) rrp_lifecycle_failure(
    condition, "rrp.software-uninstall", "Software uninstall failed."
  ), error = function(condition) rrp_lifecycle_failure(
    condition, "rrp.software-uninstall", "Software uninstall failed.",
    "software_uninstall_failed"
  ))
}

rrp_software_doctor <- function(root, selector, stable_shim = "") {
  active <- tryCatch(
    rrp_software_activation_record(root), rrp_software_error = function(e) e
  )
  selected <- selector
  if (is.null(selected) && !inherits(active, "rrp_software_error") &&
      !is.null(active)) selected <- active[["Selector"]]
  if (is.null(selected)) {
    candidates <- rrp_software_candidate_selectors(root)
    selected <- if (length(candidates)) candidates[[1L]] else NULL
  }
  if (is.null(selected)) {
    value <- list(
      software_status = "blocked", product_id = "readmission-risk-pool-platform",
      product_version = "", installation_id = "", distribution_id = "",
      host_r_status = "blocked", private_library_status = "blocked",
      resource_status = "blocked", launcher_status = "blocked",
      activation_status = "not_selected",
      checks = list(rrp_lifecycle_check(
        "installed_software", "failure", "install_software"
      ))
    )
    rrp_software_diagnosis_validate_value(value)
    return(rrp_new_operation_result(
      "rrp.software-doctor", "success", value, list(rrp_new_diagnostic(
      "installed_software_absent", "warning", "No installed software is available."
    ))
    ))
  }
  verified <- tryCatch(
    rrp_software_verify_success(rrp_software_selector_path(root, selected), root),
    rrp_software_error = function(e) e
  )
  if (inherits(verified, "rrp_software_error")) {
    value <- list(
      software_status = "blocked", product_id = "readmission-risk-pool-platform",
      product_version = strsplit(selected, "/", fixed = TRUE)[[1L]][[1L]],
      installation_id = "", distribution_id = strsplit(selected, "/", fixed = TRUE)[[1L]][[2L]],
      host_r_status = "blocked", private_library_status = "blocked",
      resource_status = "blocked", launcher_status = "blocked",
      activation_status = if (inherits(active, "rrp_software_error")) "invalid" else "not_selected",
      checks = list(rrp_lifecycle_check(
        "installed_software", "failure", "reinstall_software"
      ))
    )
    rrp_software_diagnosis_validate_value(value)
    return(rrp_new_operation_result(
      "rrp.software-doctor", "success", value, list(rrp_new_diagnostic(
      "installed_software_blocked", "warning", "Installed software integrity is blocked."
    ))
    ))
  }
  checks <- rrp_software_diagnosis_value(verified)$checks
  warnings <- list()
  status <- "ready"
  activation_status <- verified$activation_status
  if (inherits(active, "rrp_software_error")) {
    status <- "ready_with_warnings"
    activation_status <- "invalid"
    checks <- c(checks, list(rrp_lifecycle_check(
      "active_selection", "warning", "activate_software"
    )))
    warnings <- c(warnings, list(rrp_new_diagnostic(
      "invalid_active_selection", "warning", "The active software selection is invalid."
    )))
  } else if (is.null(active)) {
    status <- "ready_with_warnings"
    activation_status <- "not_selected"
    checks <- c(checks, list(rrp_lifecycle_check(
      "active_selection", "warning", "activate_software"
    )))
    warnings <- c(warnings, list(rrp_new_diagnostic(
      "active_software_not_selected", "warning", "No active software version is selected."
    )))
  } else {
    checks <- c(checks, list(rrp_lifecycle_check("active_selection", "pass")))
  }
  shim_ready <- rrp_resource_scalar_string(stable_shim) &&
    file.exists(stable_shim) && isTRUE(utils::file_test("-f", stable_shim)) &&
    !nzchar(Sys.readlink(stable_shim)) && file.access(stable_shim, 1L) == 0L
  if (!shim_ready) {
    status <- "ready_with_warnings"
    checks <- c(checks, list(rrp_lifecycle_check(
      "stable_shim", "warning", "provision_stable_shim"
    )))
    warnings <- c(warnings, list(rrp_new_diagnostic(
      "stable_shim_unavailable", "warning", "The stable software launcher is unavailable."
    )))
  } else checks <- c(checks, list(rrp_lifecycle_check("stable_shim", "pass")))
  value <- rrp_software_diagnosis_value(verified, status, checks)
  value$activation_status <- activation_status
  rrp_software_diagnosis_validate_value(value)
  rrp_new_operation_result("rrp.software-doctor", "success", value, warnings)
}
