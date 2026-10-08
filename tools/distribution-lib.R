# Shared maintainer-only mechanics for Increment 11.D distribution assembly.
# This file implements no installation or product behavior.

distribution_stop <- function(code, message) {
  stop(sprintf("[%s] %s", code, message), call. = FALSE)
}

distribution_safe_path <- function(path) {
  is.character(path) && length(path) == 1L && !is.na(path) && nzchar(path) &&
    !grepl("^[A-Za-z]:|^[/\\\\]", path) &&
    !grepl("(^|/)[.][.]($|/)|(^|/)[.]($|/)|//|\\\\", path) &&
    identical(path, gsub("\\\\", "/", path))
}

distribution_read_dcf <- function(path) {
  tryCatch({
    value <- read.dcf(path, all = TRUE)
    lapply(seq_len(nrow(value)), function(i) {
      record <- value[i, , drop = TRUE]
      record[!is.na(record)]
    })
  }, error = function(e) distribution_stop("dcf", paste("Cannot parse", path)))
}

distribution_write_dcf <- function(records, path) {
  if (!dir.exists(dirname(path))) dir.create(dirname(path), recursive = TRUE)
  connection <- file(path, open = "wb")
  on.exit(close(connection), add = TRUE)
  for (i in seq_along(records)) {
    record <- records[[i]]
    if (!length(record) || is.null(names(record)) || any(!nzchar(names(record)))) {
      distribution_stop("dcf", "Cannot write an unnamed DCF record.")
    }
    lines <- paste0(names(record), ": ", unname(record))
    writeLines(lines, connection, sep = "\n", useBytes = TRUE)
    if (i < length(records)) writeLines("", connection, sep = "\n", useBytes = TRUE)
  }
}

distribution_sha256 <- function(path) {
  utility <- Sys.which("sha256sum")
  arguments <- path
  if (!nzchar(utility)) {
    utility <- Sys.which("shasum")
    arguments <- c("-a", "256", path)
  }
  if (!nzchar(utility)) distribution_stop("sha256", "sha256sum or shasum is required.")
  output <- suppressWarnings(system2(utility, arguments, stdout = TRUE, stderr = TRUE))
  status <- attr(output, "status")
  digest <- if (length(output)) sub("[[:space:]].*$", "", output[[1L]]) else ""
  if ((!is.null(status) && status != 0L) || !grepl("^[0-9a-f]{64}$", digest)) {
    distribution_stop("sha256", paste("Cannot hash", path))
  }
  digest
}

distribution_hash_lines <- function(lines) {
  path <- tempfile("rrp-normalized-")
  on.exit(unlink(path, force = TRUE), add = TRUE)
  writeLines(enc2utf8(lines), path, useBytes = TRUE)
  distribution_sha256(path)
}

distribution_copy <- function(source, destination, executable = FALSE) {
  if (!file.exists(source) || !isTRUE(file_test("-f", source)) || nzchar(Sys.readlink(source))) {
    distribution_stop("source_file", paste("Source is missing, linked, or nonregular:", source))
  }
  if (!dir.exists(dirname(destination))) dir.create(dirname(destination), recursive = TRUE)
  if (!isTRUE(file.copy(source, destination, overwrite = FALSE,
                        copy.mode = FALSE, copy.date = FALSE))) {
    distribution_stop("copy", paste("Cannot copy to", destination))
  }
  Sys.chmod(destination, if (executable) "0755" else "0644")
  invisible(destination)
}

distribution_files <- function(root) {
  found <- character()
  visit <- function(directory, relative = "") {
    for (entry in list.files(directory, all.files = TRUE, full.names = TRUE, no.. = TRUE)) {
      path <- if (nzchar(relative)) paste(relative, basename(entry), sep = "/") else basename(entry)
      if (nzchar(Sys.readlink(entry))) distribution_stop("linked_source", paste("Linked input:", path))
      if (dir.exists(entry)) visit(entry, path) else {
        if (!isTRUE(file_test("-f", entry))) distribution_stop("source_type", paste("Nonregular input:", path))
        found <<- c(found, path)
      }
    }
  }
  visit(root)
  sort(found, method = "radix")
}

distribution_split_csv <- function(value) {
  result <- trimws(strsplit(value, ",", fixed = TRUE)[[1L]])
  result[nzchar(result)]
}

distribution_source_authority <- function(repository_root) {
  path <- file.path(repository_root, "distribution", "source-inclusion.dcf")
  records <- distribution_read_dcf(path)
  if (length(records) < 4L) distribution_stop("source_authority", "Source authority is incomplete.")
  header <- records[[1L]]
  expected <- c(
    "Record-Type", "Authority-ID", "Authority-Version", "Product-ID",
    "Development-Version", "Resource-Catalog", "Package-Count", "Direct-Payload-Count"
  )
  if (!identical(sort(names(header)), sort(expected)) ||
      !identical(header[["Record-Type"]], "distribution-source-inclusion") ||
      !identical(header[["Authority-ID"]], "rrp.distribution-source-inclusion") ||
      !identical(header[["Authority-Version"]], "0.1.0")) {
    distribution_stop("source_authority", "Source authority header is unsupported.")
  }
  package_records <- records[vapply(records, function(x) identical(x[["Record-Type"]], "package-source"), logical(1L))]
  direct_records <- records[vapply(records, function(x) identical(x[["Record-Type"]], "direct-payload"), logical(1L))]
  if (length(package_records) != as.integer(header[["Package-Count"]]) ||
      length(direct_records) != as.integer(header[["Direct-Payload-Count"]])) {
    distribution_stop("source_authority", "Source authority counts disagree.")
  }
  if (!identical(sort(vapply(package_records, `[[`, character(1L), "Package")),
                 c("rrpplatform", "rrpruntime"))) {
    distribution_stop("source_authority", "Exactly the two internal packages must be declared.")
  }
  all_declared <- character()
  for (record in package_records) {
    if (!identical(sort(names(record)), sort(c(
      "Record-Type", "Package", "Package-Root", "Excluded-Directories", "Files"
    )))) distribution_stop("source_authority", "Package-source fields are invalid.")
    root <- record[["Package-Root"]]
    files <- distribution_split_csv(record[["Files"]])
    if (!distribution_safe_path(root) || any(!vapply(files, distribution_safe_path, logical(1L))) ||
        anyDuplicated(files) || anyDuplicated(tolower(files))) {
      distribution_stop("source_authority", "Package source paths are unsafe or duplicated.")
    }
    actual <- distribution_files(file.path(repository_root, root))
    excluded <- paste0(record[["Excluded-Directories"]], "/")
    distributable <- actual[!startsWith(actual, excluded)]
    if (!identical(sort(files, method = "radix"), distributable)) {
      distribution_stop("source_closure", paste("Declared package source differs from", root))
    }
    all_declared <- c(all_declared, paste0(root, "/", files))
  }
  destinations <- character()
  for (record in direct_records) {
    if (!identical(sort(names(record)), sort(c(
      "Record-Type", "Source-Path", "Destination-Path", "Role"
    ))) || !distribution_safe_path(record[["Source-Path"]]) ||
        !distribution_safe_path(record[["Destination-Path"]])) {
      distribution_stop("source_authority", "Direct payload record is invalid.")
    }
    source <- file.path(repository_root, record[["Source-Path"]])
    if (!file.exists(source) || !isTRUE(file_test("-f", source)) || nzchar(Sys.readlink(source))) {
      distribution_stop("source_authority", paste("Missing direct source:", record[["Source-Path"]]))
    }
    destinations <- c(destinations, record[["Destination-Path"]])
    all_declared <- c(all_declared, record[["Source-Path"]])
  }
  if (anyDuplicated(destinations) || anyDuplicated(tolower(destinations))) {
    distribution_stop("source_authority", "Direct payload destinations conflict.")
  }
  list(header = header, packages = package_records, direct = direct_records,
       source_paths = sort(unique(all_declared), method = "radix"), authority_path = path)
}

distribution_resource_authority <- function(repository_root) {
  records <- distribution_read_dcf(file.path(repository_root, "resources", "source-catalog.dcf"))
  header <- records[[1L]]
  entries <- records[-1L]
  if (!identical(header[["Catalog-ID"]], "rrp.software-resources") || !length(entries)) {
    distribution_stop("resource_catalog", "Source resource catalog is invalid.")
  }
  sources <- vapply(entries, `[[`, character(1L), "Source-Path")
  installed <- vapply(entries, `[[`, character(1L), "Installed-Path")
  if (any(!vapply(sources, distribution_safe_path, logical(1L))) ||
      any(!vapply(installed, distribution_safe_path, logical(1L))) ||
      anyDuplicated(sources) || anyDuplicated(installed) || anyDuplicated(tolower(installed))) {
    distribution_stop("resource_catalog", "Resource paths are unsafe or duplicated.")
  }
  expected_source <- sort(c("resources/source-catalog.dcf", sources), method = "radix")
  actual_source <- distribution_files(file.path(repository_root, "resources"))
  actual_source <- paste0("resources/", actual_source)
  if (!identical(expected_source, actual_source)) {
    distribution_stop("resource_closure", "Resource source tree differs from its catalog.")
  }
  list(header = header, entries = entries,
       source_paths = expected_source, installed_paths = installed)
}

distribution_project_resources <- function(authority, repository_root, destination_root) {
  projected <- c(list(authority$header), lapply(authority$entries, function(x) {
    x[["Source-Path"]] <- NULL
    x
  }))
  distribution_write_dcf(projected, file.path(destination_root, "resources", "resource-catalog.dcf"))
  for (entry in authority$entries) {
    distribution_copy(
      file.path(repository_root, entry[["Source-Path"]]),
      file.path(destination_root, entry[["Installed-Path"]])
    )
  }
  invisible(destination_root)
}

distribution_description_dependencies <- function(path) {
  description <- read.dcf(path, all = TRUE)[1L, , drop = TRUE]
  fields <- intersect(c("Depends", "Imports", "LinkingTo"), names(description))
  values <- unlist(lapply(unname(description[fields]), distribution_split_csv), use.names = FALSE)
  unique(sub("[[:space:]]*\\(.*$", "", trimws(values)))
}

distribution_dependency_specification <- function(repository_root) {
  if (!requireNamespace("renv", quietly = TRUE)) {
    distribution_stop("dependency_engine", "Maintainer build requires renv.")
  }
  repository <- Sys.getenv("RRP_CRAN_REPOSITORY", unset = "")
  if (!nzchar(repository)) repository <- unname(getOption("repos")[["CRAN"]])
  if (is.null(repository) || !grepl("^https://", repository) || identical(repository, "@CRAN@")) {
    distribution_stop("dependency_repository", "Configure one concrete HTTPS CRAN repository.")
  }
  direct <- unique(c(
    distribution_description_dependencies(file.path(repository_root, "packages/rrpruntime/DESCRIPTION")),
    distribution_description_dependencies(file.path(repository_root, "packages/rrpplatform/DESCRIPTION"))
  ))
  direct <- setdiff(direct, c("R", "rrpruntime"))
  database <- as.data.frame(installed.packages(), stringsAsFactors = FALSE)
  priority <- database[, "Priority"]
  external <- rownames(database)[is.na(priority) | !priority %in% c("base", "recommended")]
  missing_direct <- setdiff(direct, rownames(database))
  if (length(missing_direct)) distribution_stop("dependency_closure", paste("Missing direct dependency:", missing_direct[[1L]]))
  graph <- tools::package_dependencies(direct, db = database, which = c("Depends", "Imports", "LinkingTo"), recursive = TRUE)
  closure <- sort(unique(c(direct, unlist(graph, use.names = FALSE))), method = "radix")
  closure <- intersect(closure, external)
  if (!length(closure) || any(!closure %in% rownames(database))) {
    distribution_stop("dependency_closure", "Cannot resolve complete external dependency closure.")
  }
  controlled_library <- tempfile("rrp-dependency-library-")
  dir.create(controlled_library)
  on.exit(unlink(controlled_library, recursive = TRUE, force = TRUE), add = TRUE)
  for (package in closure) {
    source <- find.package(package, quiet = TRUE)
    if (!nzchar(source) || !isTRUE(file.copy(
      source, controlled_library, recursive = TRUE,
      copy.mode = TRUE, copy.date = FALSE
    ))) {
      distribution_stop("dependency_closure", paste("Cannot project", package, "into the controlled library."))
    }
  }
  expression <- paste0(
    "library_root <- ", encodeString(controlled_library, quote = "\""),
    "; .libPaths(c(library_root, .Library)); packages <- c(",
    paste(vapply(closure, encodeString, character(1L), quote = "\""), collapse = ","),
    "); paths <- vapply(packages, find.package, character(1L)); ",
    "metadata <- installed.packages(lib.loc = library_root); ",
    "stopifnot(setequal(rownames(metadata), packages), ",
    "all(startsWith(normalizePath(paths), paste0(normalizePath(library_root), .Platform$file.sep))))"
  )
  proof <- suppressWarnings(system2(
    file.path(R.home("bin"), "Rscript"), c("--vanilla", "-e", shQuote(expression)),
    stdout = TRUE, stderr = TRUE,
    env = c("R_PROFILE_USER=", "R_ENVIRON_USER=", "R_LIBS_USER=", "R_LIBS_SITE=")
  ))
  if (!is.null(attr(proof, "status")) && attr(proof, "status") != 0L) {
    distribution_stop("dependency_closure", "Controlled dependency projection validation failed.")
  }
  package_records <- lapply(closure, function(package) {
    path <- file.path(controlled_library, package)
    if (!nzchar(path)) distribution_stop("dependency_closure", paste("Cannot locate", package))
    description_path <- file.path(path, "DESCRIPTION")
    description <- read.dcf(description_path, all = TRUE)[1L, , drop = TRUE]
    source_repository <- if ("Repository" %in% names(description)) unname(description[["Repository"]]) else ""
    if (!identical(source_repository, "CRAN")) {
      distribution_stop("dependency_provenance", paste(package, "is not an installed CRAN package."))
    }
    hash <- renv:::renv_hash_description(description_path)
    if (!grepl("^[0-9a-f]{32}$", hash)) distribution_stop("dependency_integrity", paste("Cannot hash", package))
    c("Record-Type" = "rrp-dependency", "Package" = package,
      "Version" = unname(description[["Version"]]), "Source-Type" = "repository",
      "Repository" = repository, "Integrity" = paste0("renv:", hash))
  })
  target <- c(
    "Target-R-Version" = as.character(getRversion()),
    "Target-Platform" = R.version$platform,
    "Target-Architecture" = R.version$arch
  )
  repository_id <- distribution_hash_lines(paste0("repository=", repository))
  normalized <- c(unname(paste(names(target), target, sep = "=")),
                  vapply(package_records, function(x) paste(x, collapse = "|"), character(1L)))
  specification_id <- distribution_hash_lines(normalized)
  header <- c(
    "Record-Type" = "rrp-dependency-specification",
    "Contract-ID" = "rrp.dependency-specification",
    "Contract-Version" = "0.1.0",
    "Specification-ID" = specification_id,
    "Product-ID" = "readmission-risk-pool-platform",
    "Product-Version" = "1.0.0-dev",
    target,
    "Repository-Set-ID" = repository_id,
    "Package-Count" = as.character(length(package_records))
  )
  list(records = c(list(header), package_records), id = specification_id,
       target = target, direct = direct, packages = closure)
}

distribution_run <- function(command, arguments, working_directory, code) {
  old <- setwd(working_directory)
  on.exit(setwd(old), add = TRUE)
  output <- suppressWarnings(system2(command, arguments, stdout = TRUE, stderr = TRUE))
  status <- attr(output, "status")
  if (!is.null(status) && status != 0L) {
    distribution_stop(code, paste(c(output, collapse = "\n")))
  }
  output
}

distribution_build_package <- function(package_record, repository_root, build_root,
                                       resource_authority = NULL) {
  package <- package_record[["Package"]]
  source_root <- file.path(build_root, "source", package)
  for (relative in distribution_split_csv(package_record[["Files"]])) {
    distribution_copy(file.path(repository_root, package_record[["Package-Root"]], relative),
                      file.path(source_root, relative), identical(relative, "exec/rrp"))
  }
  if (!is.null(resource_authority)) {
    distribution_project_resources(resource_authority, repository_root, file.path(source_root, "inst"))
  }
  description <- read.dcf(file.path(source_root, "DESCRIPTION"), all = TRUE)[1L, , drop = TRUE]
  expected <- paste0(package, "_", unname(description[["Version"]]), ".tar.gz")
  distribution_run(file.path(R.home("bin"), "R"),
                   c("CMD", "build", source_root, "--no-build-vignettes"),
                   build_root, paste0("build_", package))
  archive <- file.path(build_root, expected)
  if (!file.exists(archive)) distribution_stop("package_artifact", paste("Missing built archive", expected))
  list(path = archive, filename = expected, version = unname(description[["Version"]]))
}

distribution_inventory <- function(payload_root, roles, distribution_id) {
  files <- distribution_files(payload_root)
  files <- setdiff(files, c("manifest.dcf", "inventory.dcf"))
  if (!identical(sort(names(roles), method = "radix"), files)) {
    distribution_stop("inventory_roles", "Every payload file must have exactly one declared role.")
  }
  records <- lapply(files, function(path) c(
    "Record-Type" = "file", "Path" = path, "Role" = unname(roles[[path]]),
    "Size" = as.character(file.info(file.path(payload_root, path))$size),
    "SHA256" = distribution_sha256(file.path(payload_root, path))
  ))
  c(list(c("Record-Type" = "distribution-inventory", "Inventory-Version" = "0.1.0",
                "Distribution-ID" = distribution_id,
                "File-Count" = as.character(length(records)))), records)
}

distribution_source_identity <- function(authority, resources, repository_root,
                                         dependency_path) {
  paths <- sort(unique(c(authority$source_paths, resources$source_paths,
                         "distribution/source-inclusion.dcf")), method = "radix")
  facts <- vapply(paths, function(path) paste0(
    "source:", path, "=", distribution_sha256(file.path(repository_root, path))
  ), character(1L))
  lines <- c("rrp-distribution-identity-v1", facts,
             paste0("dependency-specification=", distribution_sha256(dependency_path)))
  list(id = distribution_hash_lines(lines), lines = lines)
}
