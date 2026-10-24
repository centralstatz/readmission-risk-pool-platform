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

distribution_git_output <- function(repository_root, arguments) {
  output <- suppressWarnings(system2(
    "git", c("-C", repository_root, arguments), stdout = TRUE, stderr = TRUE
  ))
  status <- attr(output, "status")
  if (!is.null(status) && status != 0L) return(NULL)
  output
}

distribution_source_state <- function(repository_root, require_clean = FALSE) {
  top <- distribution_git_output(
    repository_root, c("rev-parse", "--show-toplevel")
  )
  revision <- distribution_git_output(repository_root, c("rev-parse", "HEAD"))
  status <- distribution_git_output(
    repository_root, c("status", "--porcelain", "--untracked-files=all")
  )
  valid <- !is.null(top) && length(top) == 1L && !is.null(revision) &&
    length(revision) == 1L && !is.null(status) &&
    identical(
      normalizePath(top[[1L]], winslash = "/", mustWork = TRUE),
      normalizePath(repository_root, winslash = "/", mustWork = TRUE)
    ) && grepl("^[0-9a-f]{40,64}$", revision[[1L]])
  result <- if (valid) list(
    revision = revision[[1L]],
    state = if (length(status)) "modified" else "clean"
  ) else list(revision = "unavailable", state = "unavailable")
  if (isTRUE(require_clean) &&
      (!identical(result$state, "clean") ||
        !grepl("^[0-9a-f]{40,64}$", result$revision))) {
    distribution_stop(
      "candidate_source_state",
      "A qualification candidate requires one exact clean Git source revision."
    )
  }
  result
}

distribution_candidate_families <- function() list(
  "macos-arm64" = c(
    platform = "aarch64-apple-darwin20", architecture = "aarch64"
  ),
  "ubuntu-x86_64" = c(
    platform = "x86_64-pc-linux-gnu", architecture = "x86_64"
  )
)

distribution_candidate_set_id <- function(source_revision) {
  if (!is.character(source_revision) || length(source_revision) != 1L ||
      !grepl("^[0-9a-f]{40,64}$", source_revision)) {
    distribution_stop(
      "candidate_source_revision", "Candidate-set source revision is invalid."
    )
  }
  distribution_hash_lines(c(
    "rrp-qualification-candidate-set-v1",
    "product=readmission-risk-pool-platform",
    "product-version=1.0.0-dev",
    paste0("source-revision=", source_revision),
    "families=macos-arm64,ubuntu-x86_64"
  ))
}

distribution_artifact_record <- function(mode, family, target, source) {
  if (!identical(sort(names(target)), sort(c(
    "Target-R-Version", "Target-Platform", "Target-Architecture"
  )))) distribution_stop("artifact_target", "Artifact target is incomplete.")
  if (identical(mode, "development")) {
    values <- list(
      state = "development", family = "development-local",
      archive = "caller-selected-development-archive",
      root = "rrp-1.0.0-dev", set_id = "not_applicable",
      qualification = "not_applicable"
    )
  } else if (identical(mode, "qualification_candidate")) {
    families <- distribution_candidate_families()
    if (!family %in% names(families) || !identical(
      unname(target[c("Target-Platform", "Target-Architecture")]),
      unname(families[[family]])
    )) distribution_stop(
      "candidate_target_family",
      "Qualification candidate family does not match the exact build platform and architecture."
    )
    if (!identical(source$state, "clean") ||
        !grepl("^[0-9a-f]{40,64}$", source$revision)) {
      distribution_stop(
        "candidate_source_state",
        "A qualification candidate requires one exact clean Git source revision."
      )
    }
    base <- paste0("rrp-1.0.0-candidate-", family)
    values <- list(
      state = "qualification_candidate", family = family,
      archive = paste0(base, ".tar"), root = base,
      set_id = distribution_candidate_set_id(source$revision),
      qualification = "pending_external_evidence"
    )
  } else distribution_stop("artifact_state", "Artifact state is unsupported.")
  c(
    "Record-Type" = "rrp-distribution-artifact",
    "Contract-ID" = "rrp.distribution-artifact",
    "Contract-Version" = "0.1.0",
    "Product-ID" = "readmission-risk-pool-platform",
    "Product-Version" = "1.0.0-dev",
    "Artifact-State" = values$state,
    "Target-Family" = values$family,
    "Expected-Archive-Name" = values$archive,
    "Extraction-Root" = values$root,
    "Candidate-Set-ID" = values$set_id,
    "Technical-Minimum-R-Version" = "4.4.0",
    "Qualification-Status" = values$qualification,
    "Official-Release-State" = "not_assigned",
    "Source-Revision" = source$revision,
    "Source-State" = source$state,
    target
  )
}

distribution_validate_artifact_record <- function(record, manifest = NULL) {
  fields <- c(
    "Record-Type", "Contract-ID", "Contract-Version", "Product-ID",
    "Product-Version", "Artifact-State", "Target-Family",
    "Expected-Archive-Name", "Extraction-Root", "Candidate-Set-ID",
    "Technical-Minimum-R-Version", "Qualification-Status",
    "Official-Release-State", "Source-Revision", "Source-State",
    "Target-R-Version", "Target-Platform", "Target-Architecture"
  )
  expected <- c(
    "Record-Type" = "rrp-distribution-artifact",
    "Contract-ID" = "rrp.distribution-artifact",
    "Contract-Version" = "0.1.0",
    "Product-ID" = "readmission-risk-pool-platform",
    "Product-Version" = "1.0.0-dev",
    "Technical-Minimum-R-Version" = "4.4.0",
    "Official-Release-State" = "not_assigned"
  )
  valid <- (is.character(record) || is.list(record)) &&
    identical(names(record), fields) &&
    all(vapply(record, function(value) {
      is.character(value) && length(value) == 1L && !is.na(value)
    }, logical(1L))) &&
    all(vapply(names(expected), function(field) {
      identical(unname(record[[field]]), unname(expected[[field]]))
    }, logical(1L))) &&
    nzchar(record[["Target-R-Version"]]) &&
    nzchar(record[["Target-Platform"]]) &&
    nzchar(record[["Target-Architecture"]])
  if (!valid) distribution_stop("artifact_metadata", "Artifact metadata is invalid.")
  if (identical(record[["Artifact-State"]], "development")) {
    valid <- identical(as.character(unname(record[c(
      "Target-Family", "Expected-Archive-Name", "Extraction-Root",
      "Candidate-Set-ID", "Qualification-Status"
    )])), c(
      "development-local", "caller-selected-development-archive",
      "rrp-1.0.0-dev", "not_applicable", "not_applicable"
    )) && record[["Source-State"]] %in% c("clean", "modified", "unavailable")
  } else if (identical(record[["Artifact-State"]], "qualification_candidate")) {
    family <- record[["Target-Family"]]
    families <- distribution_candidate_families()
    base <- paste0("rrp-1.0.0-candidate-", family)
    valid <- family %in% names(families) && identical(
      as.character(unname(record[c("Target-Platform", "Target-Architecture")])),
      unname(families[[family]])
    ) && identical(record[["Expected-Archive-Name"]], paste0(base, ".tar")) &&
      identical(record[["Extraction-Root"]], base) &&
      identical(record[["Qualification-Status"]], "pending_external_evidence") &&
      identical(record[["Source-State"]], "clean") &&
      grepl("^[0-9a-f]{40,64}$", record[["Source-Revision"]]) &&
      identical(
        record[["Candidate-Set-ID"]],
        distribution_candidate_set_id(record[["Source-Revision"]])
      )
  } else valid <- FALSE
  if (!isTRUE(valid)) distribution_stop(
    "artifact_metadata", "Artifact state, target, source, or qualification metadata conflicts."
  )
  agreement_fields <- c(
    "Product-ID", "Product-Version", "Source-Revision", "Source-State",
    "Target-R-Version", "Target-Platform", "Target-Architecture"
  )
  if (!is.null(manifest) && any(!vapply(agreement_fields, function(field) {
    identical(unname(record[[field]]), unname(manifest[[field]]))
  }, logical(1L)))) distribution_stop(
    "artifact_metadata", "Artifact metadata disagrees with the distribution manifest."
  )
  invisible(record)
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

distribution_direct_dependencies <- function(repository_root) {
  direct <- unique(c(
    distribution_description_dependencies(file.path(repository_root, "packages/rrpruntime/DESCRIPTION")),
    distribution_description_dependencies(file.path(repository_root, "packages/rrpplatform/DESCRIPTION"))
  ))
  setdiff(direct, c("R", "rrpruntime"))
}

distribution_dependency_snapshot <- function(repository_root) {
  if (!requireNamespace("renv", quietly = TRUE)) {
    distribution_stop("dependency_engine", "Maintainer build requires renv.")
  }
  direct <- distribution_direct_dependencies(repository_root)
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
  source_paths <- setNames(vapply(closure, find.package, character(1L), quiet = TRUE), closure)
  installed_repository <- setNames(character(length(closure)), closure)
  package_records <- lapply(closure, function(package) {
    path <- file.path(controlled_library, package)
    if (!nzchar(path)) distribution_stop("dependency_closure", paste("Cannot locate", package))
    description_path <- file.path(path, "DESCRIPTION")
    description <- read.dcf(description_path, all = TRUE)[1L, , drop = TRUE]
    installed_repository[[package]] <<- if ("Repository" %in% names(description)) {
      unname(description[["Repository"]])
    } else ""
    hash <- renv:::renv_hash_description(description_path)
    if (!grepl("^[0-9a-f]{32}$", hash)) distribution_stop("dependency_integrity", paste("Cannot hash", package))
    c("Record-Type" = "rrp-dependency", "Package" = package,
      "Version" = unname(description[["Version"]]), "Source-Type" = "repository",
      "Integrity" = paste0("renv:", hash))
  })
  target <- c(
    "Target-R-Version" = as.character(getRversion()),
    "Target-Platform" = R.version$platform,
    "Target-Architecture" = R.version$arch
  )
  list(direct = direct, packages = closure, package_records = package_records,
       installed_repository = installed_repository, source_paths = source_paths,
       target = target)
}

distribution_dependency_provenance_records <- function(snapshot, repository) {
  header <- c(
    "Record-Type" = "rrp-dependency-provenance",
    "Format-Version" = "1.0.0",
    "Method" = "fresh-library-single-repository-install",
    "Repository" = repository,
    snapshot$target,
    "Package-Count" = as.character(length(snapshot$package_records))
  )
  packages <- lapply(snapshot$package_records, function(record) c(
    "Record-Type" = "provisioned-dependency",
    "Package" = record[["Package"]],
    "Version" = record[["Version"]],
    "Integrity" = record[["Integrity"]]
  ))
  c(list(header), packages)
}

distribution_write_dependency_provenance <- function(repository_root, library_root,
                                                     repository, path) {
  if (!grepl("^https://", repository) || identical(repository, "@CRAN@")) {
    distribution_stop("dependency_repository", "Configure one concrete HTTPS package repository.")
  }
  if (!dir.exists(library_root) || nzchar(Sys.readlink(library_root)) || file.exists(path)) {
    distribution_stop("dependency_provenance", "Provenance output requires a nonlinked library and a new file.")
  }
  library_root <- normalizePath(library_root, winslash = "/", mustWork = TRUE)
  snapshot <- distribution_dependency_snapshot(repository_root)
  source_paths <- normalizePath(unname(snapshot$source_paths), winslash = "/", mustWork = TRUE)
  if (any(!startsWith(source_paths, paste0(library_root, "/")))) {
    distribution_stop("dependency_provenance", "The tested closure is not wholly supplied by the controlled library.")
  }
  actual <- sort(list.dirs(library_root, recursive = FALSE, full.names = FALSE), method = "radix")
  expected <- sort(unique(c(snapshot$packages, "renv")), method = "radix")
  if (!identical(actual, expected)) {
    distribution_stop("dependency_provenance", "The controlled library contains an unexpected package set.")
  }
  distribution_write_dcf(
    distribution_dependency_provenance_records(snapshot, repository), path
  )
  invisible(path)
}

distribution_validate_dependency_provenance <- function(snapshot, repository,
                                                        provenance_path = "") {
  if (!nzchar(provenance_path)) {
    if (!identical(sub("/+$", "", repository), "https://cloud.r-project.org")) {
      distribution_stop(
        "dependency_provenance",
        "A noncanonical configured repository requires a controlled provisioning receipt."
      )
    }
    invalid <- names(snapshot$installed_repository)[snapshot$installed_repository != "CRAN"]
    if (length(invalid)) {
      distribution_stop(
        "dependency_provenance",
        paste(invalid[[1L]],
              "has no accepted installed-package provenance and no controlled provisioning receipt.")
      )
    }
    return(invisible("installed-description"))
  }
  if (!file.exists(provenance_path) || !isTRUE(file_test("-f", provenance_path)) ||
      nzchar(Sys.readlink(provenance_path))) {
    distribution_stop("dependency_provenance", "The configured provisioning receipt is missing, linked, or nonregular.")
  }
  records <- distribution_read_dcf(provenance_path)
  if (length(records) < 2L) distribution_stop("dependency_provenance", "Provisioning receipt is incomplete.")
  header <- records[[1L]]
  expected_header <- c(
    "Record-Type", "Format-Version", "Method", "Repository",
    "Target-R-Version", "Target-Platform", "Target-Architecture", "Package-Count"
  )
  if (!identical(sort(names(header)), sort(expected_header)) ||
      !identical(header[["Record-Type"]], "rrp-dependency-provenance") ||
      !identical(header[["Format-Version"]], "1.0.0") ||
      !identical(header[["Method"]], "fresh-library-single-repository-install") ||
      !identical(header[["Repository"]], repository) ||
      !identical(
        unname(vapply(header[names(snapshot$target)], `[[`, character(1L), 1L)),
        unname(snapshot$target)
      )) {
    distribution_stop("dependency_provenance", "Provisioning receipt header, target, or repository disagrees.")
  }
  packages <- records[-1L]
  expected_fields <- c("Record-Type", "Package", "Version", "Integrity")
  if (length(packages) != as.integer(header[["Package-Count"]]) ||
      length(packages) != length(snapshot$package_records) ||
      any(!vapply(packages, function(x) identical(sort(names(x)), sort(expected_fields)), logical(1L))) ||
      any(!vapply(packages, function(x) identical(x[["Record-Type"]], "provisioned-dependency"), logical(1L)))) {
    distribution_stop("dependency_provenance", "Provisioning receipt records or count disagree.")
  }
  names_found <- vapply(packages, `[[`, character(1L), "Package")
  expected_names <- vapply(snapshot$package_records, `[[`, character(1L), "Package")
  if (!identical(names_found, expected_names) || anyDuplicated(names_found)) {
    distribution_stop("dependency_provenance", "Provisioning receipt package closure or order disagrees.")
  }
  for (i in seq_along(packages)) {
    expected <- snapshot$package_records[[i]]
    if (!identical(packages[[i]][["Version"]], expected[["Version"]]) ||
        !identical(packages[[i]][["Integrity"]], expected[["Integrity"]])) {
      distribution_stop("dependency_provenance", paste("Provisioning receipt disagrees for", expected[["Package"]]))
    }
  }
  invisible("controlled-provisioning-receipt")
}

distribution_dependency_specification <- function(repository_root) {
  repository <- Sys.getenv("RRP_CRAN_REPOSITORY", unset = "")
  if (!nzchar(repository)) repository <- unname(getOption("repos")[["CRAN"]])
  if (is.null(repository) || !grepl("^https://", repository) || identical(repository, "@CRAN@")) {
    distribution_stop("dependency_repository", "Configure one concrete HTTPS package repository.")
  }
  snapshot <- distribution_dependency_snapshot(repository_root)
  distribution_validate_dependency_provenance(
    snapshot, repository, Sys.getenv("RRP_DEPENDENCY_PROVENANCE", unset = "")
  )
  package_records <- lapply(snapshot$package_records, function(record) c(
    record[c("Record-Type", "Package", "Version", "Source-Type")],
    "Repository" = repository,
    record["Integrity"]
  ))
  target <- snapshot$target
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
       target = target, direct = snapshot$direct, packages = snapshot$packages)
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
                                         dependency_path, artifact_path) {
  paths <- sort(unique(c(authority$source_paths, resources$source_paths,
                         "distribution/source-inclusion.dcf")), method = "radix")
  facts <- vapply(paths, function(path) paste0(
    "source:", path, "=", distribution_sha256(file.path(repository_root, path))
  ), character(1L))
  lines <- c("rrp-distribution-identity-v2",
             paste0("artifact-metadata=", distribution_sha256(artifact_path)), facts,
             paste0("dependency-specification=", distribution_sha256(dependency_path)))
  list(id = distribution_hash_lines(lines), lines = lines)
}

distribution_candidate_evidence <- function(archive, artifact, manifest) {
  distribution_validate_artifact_record(artifact, manifest)
  if (!identical(artifact[["Artifact-State"]], "qualification_candidate") ||
      !file.exists(archive) || !isTRUE(file_test("-f", archive)) ||
      nzchar(Sys.readlink(archive)) ||
      !identical(basename(archive), artifact[["Expected-Archive-Name"]])) {
    distribution_stop(
      "candidate_evidence", "Candidate archive or artifact metadata is invalid."
    )
  }
  c(
    "Record-Type" = "rrp-qualification-candidate-evidence",
    "Contract-ID" = "rrp.qualification-candidate-evidence",
    "Contract-Version" = "0.1.0",
    "Product-ID" = manifest[["Product-ID"]],
    "Product-Version" = manifest[["Product-Version"]],
    "Candidate-Set-ID" = artifact[["Candidate-Set-ID"]],
    "Target-Family" = artifact[["Target-Family"]],
    "Archive-Name" = basename(archive),
    "Extraction-Root" = artifact[["Extraction-Root"]],
    "Archive-SHA256" = distribution_sha256(archive),
    "Distribution-ID" = manifest[["Distribution-ID"]],
    "Build-ID" = manifest[["Build-ID"]],
    "Dependency-Specification-ID" = manifest[["Dependency-Specification-ID"]],
    "Source-Revision" = manifest[["Source-Revision"]],
    "Target-R-Version" = manifest[["Target-R-Version"]],
    "Target-Platform" = manifest[["Target-Platform"]],
    "Target-Architecture" = manifest[["Target-Architecture"]],
    "Qualification-Status" = "pending_external_evidence"
  )
}

distribution_candidate_set_evidence <- function(candidate_records) {
  fields <- c(
    "Record-Type", "Contract-ID", "Contract-Version", "Product-ID",
    "Product-Version", "Candidate-Set-ID", "Target-Family", "Archive-Name",
    "Extraction-Root", "Archive-SHA256", "Distribution-ID", "Build-ID",
    "Dependency-Specification-ID", "Source-Revision", "Target-R-Version",
    "Target-Platform", "Target-Architecture", "Qualification-Status"
  )
  families <- names(distribution_candidate_families())
  valid <- is.list(candidate_records) && length(candidate_records) == 2L &&
    all(vapply(candidate_records, function(record) {
      (is.character(record) || is.list(record)) &&
        identical(names(record), fields) &&
        all(vapply(record, function(value) {
          is.character(value) && length(value) == 1L && !is.na(value)
        }, logical(1L))) &&
        all(vapply(names(c(
          "Record-Type" = "rrp-qualification-candidate-evidence",
          "Contract-ID" = "rrp.qualification-candidate-evidence",
          "Contract-Version" = "0.1.0",
          "Product-ID" = "readmission-risk-pool-platform",
          "Product-Version" = "1.0.0-dev",
          "Qualification-Status" = "pending_external_evidence"
        )), function(field) identical(
          as.character(record[[field]]),
          c(
            "Record-Type" = "rrp-qualification-candidate-evidence",
            "Contract-ID" = "rrp.qualification-candidate-evidence",
            "Contract-Version" = "0.1.0",
            "Product-ID" = "readmission-risk-pool-platform",
            "Product-Version" = "1.0.0-dev",
            "Qualification-Status" = "pending_external_evidence"
          )[[field]]
        ), logical(1L))) && all(grepl("^[0-9a-f]{64}$", record[c(
          "Candidate-Set-ID", "Archive-SHA256", "Distribution-ID", "Build-ID",
          "Dependency-Specification-ID"
        )])) && grepl("^[0-9a-f]{40,64}$", record[["Source-Revision"]])
    }, logical(1L)))
  if (!valid) distribution_stop(
    "candidate_set_evidence", "Candidate-set evidence is incomplete or invalid."
  )
  found <- vapply(candidate_records, `[[`, character(1L), "Target-Family")
  shared <- c("Candidate-Set-ID", "Source-Revision")
  mapped <- all(vapply(candidate_records, function(record) {
    family <- record[["Target-Family"]]
    if (!family %in% families) return(FALSE)
    base <- paste0("rrp-1.0.0-candidate-", family)
    identical(record[["Archive-Name"]], paste0(base, ".tar")) &&
      identical(record[["Extraction-Root"]], base) &&
      identical(
        as.character(unname(record[c(
          "Target-Platform", "Target-Architecture"
        )])),
        unname(distribution_candidate_families()[[family]])
      ) && nzchar(record[["Target-R-Version"]]) &&
      identical(
        record[["Candidate-Set-ID"]],
        distribution_candidate_set_id(record[["Source-Revision"]])
      )
  }, logical(1L)))
  if (!identical(sort(found, method = "radix"), sort(families, method = "radix")) ||
      !mapped ||
      any(vapply(shared, function(field) {
        length(unique(vapply(candidate_records, `[[`, character(1L), field))) != 1L
      }, logical(1L))) || anyDuplicated(vapply(
        candidate_records, `[[`, character(1L), "Archive-Name"
      ))) distribution_stop(
    "candidate_set_evidence",
    "Candidate artifacts do not form one source-consistent closed target set."
  )
  ordered <- candidate_records[match(families, found)]
  header <- c(
    "Record-Type" = "rrp-qualification-candidate-set",
    "Contract-ID" = "rrp.qualification-candidate-set-evidence",
    "Contract-Version" = "0.1.0",
    "Product-ID" = "readmission-risk-pool-platform",
    "Product-Version" = "1.0.0-dev",
    "Candidate-Set-ID" = ordered[[1L]][["Candidate-Set-ID"]],
    "Source-Revision" = ordered[[1L]][["Source-Revision"]],
    "Artifact-Count" = "2",
    "Qualification-Status" = "pending_external_evidence"
  )
  c(list(header), ordered)
}
