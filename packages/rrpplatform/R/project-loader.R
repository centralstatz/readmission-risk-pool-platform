rrp_project_validate_root <- function(project_root) {
  if (!rrp_project_scalar_string(project_root)) {
    rrp_project_abort(
      "invalid_project_root", "Project root must be one explicit path."
    )
  }
  if (!file.exists(project_root)) {
    rrp_project_abort("missing_project_root", "Explicit project root is missing.")
  }
  if (!dir.exists(project_root)) {
    rrp_project_abort(
      "non_directory_project_root", "Explicit project root must be a directory."
    )
  }
  target <- Sys.readlink(project_root)
  if (!is.na(target) && nzchar(target)) {
    rrp_project_abort(
      "linked_project_root", "Explicit project root must not be linked."
    )
  }
  normalizePath(project_root, winslash = "/", mustWork = TRUE)
}

rrp_project_contained <- function(root, path) {
  identical(path, root) || startsWith(path, paste0(root, "/"))
}

rrp_project_resolve_filesystem_path <- function(
  root,
  relative_path,
  missing_code,
  linked_code,
  invalid_code,
  label,
  must_exist,
  expected_directory
) {
  if (!rrp_project_safe_relative_path(relative_path)) {
    rrp_project_abort(invalid_code, paste0(label, " is invalid."))
  }

  segments <- strsplit(relative_path, "/", fixed = TRUE)[[1L]]
  current <- root
  for (index in seq_along(segments)) {
    segment <- segments[[index]]
    entries <- list.files(
      current, all.files = TRUE, no.. = TRUE, full.names = FALSE
    )
    folded_matches <- entries[tolower(entries) == tolower(segment)]
    if (length(folded_matches) > 1L ||
        (length(folded_matches) == 1L &&
         !identical(folded_matches[[1L]], segment))) {
      rrp_project_abort(invalid_code, paste0(label, " is invalid."))
    }

    current <- file.path(current, segment)
    link_target <- Sys.readlink(current)
    if (!is.na(link_target) && nzchar(link_target)) {
      rrp_project_abort(linked_code, paste0(label, " must not be linked."))
    }

    exists <- file.exists(current) || dir.exists(current)
    if (!exists) {
      if (must_exist) {
        rrp_project_abort(missing_code, paste0(label, " is missing."))
      }
      remaining <- if (index < length(segments)) {
        segments[(index + 1L):length(segments)]
      } else {
        character()
      }
      intended <- do.call(file.path, as.list(c(current, remaining)))
      intended <- gsub("\\\\", "/", intended)
      if (!rrp_project_contained(root, intended)) {
        rrp_project_abort(invalid_code, paste0(label, " is invalid."))
      }
      return(intended)
    }

    state <- file.info(current, extra_cols = FALSE)
    is_directory <- nrow(state) == 1L && !is.na(state$isdir[[1L]]) &&
      isTRUE(state$isdir[[1L]])
    if (index < length(segments) && !is_directory) {
      rrp_project_abort(invalid_code, paste0(label, " is invalid."))
    }
    if (index == length(segments)) {
      valid_type <- if (expected_directory) {
        is_directory
      } else {
        !is_directory && file.exists(current)
      }
      if (!valid_type) {
        rrp_project_abort(invalid_code, paste0(label, " is invalid."))
      }
    }
  }

  resolved <- normalizePath(current, winslash = "/", mustWork = TRUE)
  if (!rrp_project_contained(root, resolved)) {
    rrp_project_abort(invalid_code, paste0(label, " is invalid."))
  }
  resolved
}

rrp_project_manifest_path <- function(root) {
  rrp_project_resolve_filesystem_path(
    root = root,
    relative_path = "rrp-project.dcf",
    missing_code = "missing_project_manifest",
    linked_code = "linked_project_manifest",
    invalid_code = "malformed_project_manifest",
    label = "Project manifest",
    must_exist = TRUE,
    expected_directory = FALSE
  )
}

rrp_project_registration_path <- function(root) {
  rrp_project_resolve_filesystem_path(
    root = root,
    relative_path = "R/register.R",
    missing_code = "missing_project_registration",
    linked_code = "linked_project_registration",
    invalid_code = "malformed_project_registration",
    label = "Project registration",
    must_exist = TRUE,
    expected_directory = FALSE
  )
}

rrp_project_declared_directory <- function(root, relative_path, kind) {
  extension <- identical(kind, "extension_library")
  code <- if (extension) {
    "invalid_extension_library"
  } else {
    "invalid_state_location"
  }
  label <- if (extension) "Project extension library" else "Project state location"
  rrp_project_resolve_filesystem_path(
    root = root,
    relative_path = relative_path,
    missing_code = code,
    linked_code = code,
    invalid_code = code,
    label = label,
    must_exist = FALSE,
    expected_directory = TRUE
  )
}

rrp_project_reject_software_shadowing <- function(extension_library_path) {
  if (!dir.exists(extension_library_path)) return(invisible(NULL))
  owned_packages <- c("rrpplatform", "rrpruntime")
  entries <- list.files(
    extension_library_path, all.files = TRUE, no.. = TRUE,
    full.names = FALSE
  )
  if (any(tolower(entries) %in% owned_packages)) {
    rrp_project_abort(
      "invalid_extension_library", "Project extension library is invalid."
    )
  }

  for (entry in entries) {
    package_root <- file.path(extension_library_path, entry)
    description_path <- file.path(package_root, "DESCRIPTION")
    if (!dir.exists(package_root) || !file.exists(description_path) ||
        nzchar(Sys.readlink(package_root)) ||
        nzchar(Sys.readlink(description_path)) ||
        dir.exists(description_path)) next
    package_name <- tryCatch({
      description <- read.dcf(description_path, fields = "Package")
      if (nrow(description) == 1L) description[[1L, "Package"]] else NA_character_
    }, error = function(condition) NA_character_)
    if (is.character(package_name) && length(package_name) == 1L &&
        !is.na(package_name) && tolower(package_name) %in% owned_packages) {
      rrp_project_abort(
        "invalid_extension_library", "Project extension library is invalid."
      )
    }
  }
  invisible(NULL)
}

rrp_project_software_libraries <- function() {
  package_roots <- vapply(c("rrpplatform", "rrpruntime"), function(package) {
    normalizePath(find.package(package), winslash = "/", mustWork = TRUE)
  }, character(1L))
  unique(dirname(package_roots))
}

rrp_project_with_libraries <- function(extension_library_path, callback) {
  previous <- .libPaths()
  on.exit(.libPaths(previous, include.site = FALSE), add = TRUE)
  extension <- if (dir.exists(extension_library_path)) {
    extension_library_path
  } else {
    character()
  }
  controlled <- unique(c(
    rrp_project_software_libraries(), extension,
    normalizePath(.Library, winslash = "/", mustWork = TRUE)
  ))
  .libPaths(controlled, include.site = FALSE)
  callback()
}

rrp_project_evaluate_registration <- function(
  registration_path,
  registration_contract,
  project_root,
  extension_library_path
) {
  rrp_project_with_libraries(extension_library_path, function() {
    registration_environment <- new.env(parent = baseenv())
    tryCatch(
      sys.source(
        registration_path, envir = registration_environment,
        chdir = FALSE, keep.source = FALSE
      ),
      error = function(condition) rrp_project_abort(
        "malformed_project_registration", "Project registration is malformed."
      )
    )
    bindings <- ls(registration_environment, all.names = TRUE)
    if (!identical(bindings, registration_contract[["Registration-Function"]])) {
      rrp_project_abort(
        "malformed_project_registration", "Project registration is malformed."
      )
    }
    registration_function <- get(
      registration_contract[["Registration-Function"]],
      envir = registration_environment,
      inherits = FALSE
    )
    if (!is.function(registration_function)) {
      rrp_project_abort(
        "malformed_project_registration", "Project registration is malformed."
      )
    }
    tryCatch(
      registration_function(project_root),
      error = function(condition) rrp_project_abort(
        "invalid_registration_result", "Project registration result is invalid."
      )
    )
  })
}

rrp_project_order_entries <- function(entries) {
  if (length(entries) < 2L) return(entries)
  ids <- vapply(entries, `[[`, character(1L), "component_id")
  versions <- vapply(entries, `[[`, character(1L), "component_version")
  entries[order(ids, versions, method = "radix")]
}

rrp_project_installed_components <- function() {
  list(producers = list(), providers = list())
}

rrp_project_origin_entry <- function(entry, origin) {
  c(entry, list(origin = origin))
}

rrp_project_compose_kind <- function(installed, project) {
  installed_records <- lapply(installed, rrp_project_origin_entry, origin = "installed")
  project_records <- lapply(project, rrp_project_origin_entry, origin = "project")
  combined <- c(installed_records, project_records)
  if (length(combined) == 0L) return(combined)
  keys <- vapply(combined, function(entry) {
    paste(entry$component_id, entry$component_version, sep = "@")
  }, character(1L))
  if (anyDuplicated(keys)) {
    rrp_project_abort(
      "component_collision", "Installed and project registrations collide."
    )
  }
  ids <- vapply(combined, `[[`, character(1L), "component_id")
  versions <- vapply(combined, `[[`, character(1L), "component_version")
  combined[order(ids, versions, method = "radix")]
}

rrp_project_compose_components <- function(installed, registration) {
  expected <- c("producers", "providers")
  valid_installed <- is.list(installed) && identical(names(installed), expected) &&
    all(vapply(installed, is.list, logical(1L)))
  if (!valid_installed) {
    stop("Invalid internal installed-component definition.", call. = FALSE)
  }
  list(
    producers = rrp_project_compose_kind(
      installed$producers, registration$producers
    ),
    providers = rrp_project_compose_kind(
      installed$providers, registration$providers
    )
  )
}

rrp_project_resolve_component <- function(entries, component_id, version, kind) {
  matched <- which(vapply(entries, function(entry) {
    identical(entry$component_id, component_id) &&
      identical(entry$component_version, version)
  }, logical(1L)))
  if (length(matched) == 0L) {
    rrp_project_abort(
      paste0("unknown_", kind, "_selection"),
      paste0("Selected ", kind, " is not registered.")
    )
  }
  if (length(matched) > 1L) {
    rrp_project_abort(
      paste0("ambiguous_", kind, "_selection"),
      paste0("Selected ", kind, " is ambiguous.")
    )
  }
  entries[[matched]]
}

rrp_project_new_context <- function(
  software_catalog,
  project_root,
  manifest,
  registration,
  canonical_profile,
  producer,
  provider,
  extension_library_path,
  state_path
) {
  structure(
    list(
      software_catalog = software_catalog,
      project_root = project_root,
      manifest = manifest,
      registration = registration,
      canonical_profile = canonical_profile,
      producer = producer,
      provider = provider,
      extension_library_path = extension_library_path,
      state_path = state_path
    ),
    class = c("rrp_project_context", "list")
  )
}

#' Load an explicit independent RRP project
#'
#' Validate one caller-supplied project against an already validated software
#' resource catalog, execute only its fixed trusted registration boundary, and
#' validate its canonical-profile and semantic producer declarations, and
#' resolve its exact producer and provider selections. Registration
#' is trusted local R code and controlled evaluation is not a security sandbox.
#' The selected producer and provider callables are never invoked.
#'
#' @param software_catalog A validated `rrp_resource_catalog` returned by
#'   [rrp_open_resource_catalog()].
#' @param project_root One explicit existing independent project directory.
#' @return One validated `rrp_project_context` snapshot.
#' @export
rrp_load_project <- function(software_catalog, project_root) {
  canonical_contracts <- rrp_canonical_contracts(software_catalog)
  runtime_contracts <- rrp_runtime_contracts(
    software_catalog, canonical_contracts
  )
  manifest_contract <- rrp_project_manifest_contract(software_catalog)
  registration_contract <- rrp_project_registration_contract(software_catalog)
  root <- rrp_project_validate_root(project_root)

  manifest_path <- rrp_project_manifest_path(root)
  manifest_lines <- tryCatch(
    readLines(manifest_path, warn = FALSE, encoding = "UTF-8"),
    error = function(condition) rrp_project_abort(
      "malformed_project_manifest", "Project manifest is malformed."
    )
  )
  manifest <- rrp_project_validate_manifest(manifest_lines, manifest_contract)

  extension_library_path <- rrp_project_declared_directory(
    root, manifest[["Extension-Library-Path"]], "extension_library"
  )
  state_path <- rrp_project_declared_directory(
    root, manifest[["State-Path"]], "state"
  )
  rrp_project_reject_software_shadowing(extension_library_path)

  registration_path <- rrp_project_registration_path(root)
  candidate <- rrp_project_evaluate_registration(
    registration_path, registration_contract, root, extension_library_path
  )
  registration <- rrp_project_validate_registration(
    candidate, registration_contract, canonical_contracts, runtime_contracts,
    manifest
  )
  if (!identical(registration$project_id, manifest[["Project-ID"]])) {
    rrp_project_abort(
      "project_identity_mismatch",
      "Project registration identity does not match the manifest."
    )
  }
  registration$producers <- rrp_project_order_entries(registration$producers)
  registration$providers <- rrp_project_order_entries(registration$providers)

  components <- rrp_project_compose_components(
    rrp_project_installed_components(), registration
  )
  producer <- rrp_project_resolve_component(
    components$producers,
    manifest[["Producer-ID"]], manifest[["Producer-Version"]], "producer"
  )
  provider <- rrp_project_resolve_component(
    components$providers,
    manifest[["Provider-ID"]], manifest[["Provider-Version"]], "provider"
  )

  rrp_project_new_context(
    software_catalog = software_catalog,
    project_root = root,
    manifest = manifest,
    registration = registration,
    canonical_profile = list(
      profile_id = manifest[["Canonical-Profile-ID"]],
      profile_version = manifest[["Canonical-Profile-Version"]]
    ),
    producer = producer,
    provider = provider,
    extension_library_path = extension_library_path,
    state_path = state_path
  )
}
