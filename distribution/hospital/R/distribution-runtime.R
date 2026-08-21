# Standalone runtime for a generated Hospital Implementation distribution.
# It validates and extracts only its own declared payload and never discovers
# the authoritative development repository.

rrp_hospital_distribution_specification <- function() list(
  specification_kind = "hospital_implementation_distribution_contract",
  specification_id = "platform.hospital-implementation-distribution",
  specification_version = "0.1.0"
)

rrp_hospital_validator_reference <- function() list(
  validator_id = "platform.hospital-implementation-distribution-validator",
  validator_version = "0.1.0"
)

rrp_hospital_issue <- function(category, issue_code, message, path = "$") {
  data.frame(
    category = category,
    severity = "error",
    issue_code = issue_code,
    message = message,
    path = path,
    stringsAsFactors = FALSE
  )
}

rrp_hospital_empty_issues <- function() data.frame(
  category = character(), severity = character(), issue_code = character(),
  message = character(), path = character(), stringsAsFactors = FALSE
)

rrp_hospital_bind_issues <- function(issues) {
  issues <- Filter(function(value) !is.null(value) && nrow(value) > 0L, issues)
  if (length(issues) == 0L) return(rrp_hospital_empty_issues())
  do.call(rbind, issues)
}

rrp_hospital_result <- function(issues = list(), manifest = NULL, candidate = NULL) {
  issues <- rrp_hospital_bind_issues(issues)
  structure(list(
    overall_status = if (nrow(issues) == 0L) "pass" else "fail",
    issues = issues,
    manifest = manifest,
    platform_candidate = candidate
  ), class = "rrp_hospital_distribution_validation_result")
}

rrp_hospital_read_yaml <- function(path) {
  if (!requireNamespace("yaml", quietly = TRUE)) stop(
    "Package `yaml` is required by the Hospital Implementation distribution.",
    call. = FALSE
  )
  yaml::read_yaml(path)
}

rrp_hospital_write_yaml <- function(value, path) {
  if (!requireNamespace("yaml", quietly = TRUE)) stop(
    "Package `yaml` is required to build Hospital Implementation metadata.",
    call. = FALSE
  )
  yaml::write_yaml(value, path, handlers = list(
    integer = function(value) as.integer(value)
  ))
  invisible(path)
}

rrp_hospital_sha256_file <- function(path) {
  if (!requireNamespace("digest", quietly = TRUE)) stop(
    "Package `digest` is required for Hospital Implementation SHA-256 validation.",
    call. = FALSE
  )
  digest::digest(path, algo = "sha256", file = TRUE, serialize = FALSE)
}

rrp_hospital_sha256_raw <- function(value) {
  if (!requireNamespace("digest", quietly = TRUE)) stop(
    "Package `digest` is required for Hospital Implementation SHA-256 validation.",
    call. = FALSE
  )
  digest::digest(value, algo = "sha256", serialize = FALSE)
}

rrp_hospital_sha256_string <- function(value) {
  rrp_hospital_sha256_raw(charToRaw(enc2utf8(value)))
}

rrp_hospital_safe_relative_path <- function(path) {
  if (!is.character(path) || length(path) != 1L || is.na(path) || !nzchar(path) ||
      grepl("^(/|~|[A-Za-z]:[/\\\\])", path) || grepl("\\\\", path)) return(FALSE)
  parts <- strsplit(path, "/", fixed = TRUE)[[1L]]
  !any(parts %in% c("", ".", "..")) && identical(path, paste(parts, collapse = "/"))
}

rrp_hospital_timestamp <- function(value) {
  is.character(value) && length(value) == 1L && !is.na(value) && grepl(
    "^[0-9]{4}-[0-9]{2}-[0-9]{2}T[0-9]{2}:[0-9]{2}:[0-9]{2}(Z|[+-][0-9]{2}:[0-9]{2})$",
    value
  ) && !is.na(as.POSIXct(value, format = "%Y-%m-%dT%H:%M:%S", tz = "UTC"))
}

rrp_hospital_now <- function() format(
  Sys.time(), "%Y-%m-%dT%H:%M:%SZ", tz = "UTC"
)

rrp_hospital_git_realization_envelope_present <- function(root) {
  metadata <- file.path(root, c(
    "HOSPITAL-GIT-REALIZATION.yml", "HOSPITAL-GIT-REALIZATION.sha256"
  ))
  dir.exists(file.path(root, ".git")) &&
    !nzchar(Sys.readlink(file.path(root, ".git"))) &&
    all(file.exists(metadata)) &&
    !any(dir.exists(metadata)) &&
    !any(nzchar(Sys.readlink(metadata)))
}

rrp_hospital_scan_tree <- function(root, allow_local_state = TRUE,
                                   allow_git_realization = FALSE) {
  files <- character()
  directories <- ""
  symlinks <- character()
  queue <- ""
  ignored_roots <- if (allow_local_state) c(".rrp", "build", ".Rproj.user") else character()
  if (allow_git_realization) ignored_roots <- c(
    ignored_roots, ".git", "HOSPITAL-GIT-REALIZATION.yml",
    "HOSPITAL-GIT-REALIZATION.sha256"
  )
  while (length(queue) > 0L) {
    relative_directory <- queue[[1L]]
    queue <- queue[-1L]
    directory <- if (nzchar(relative_directory)) file.path(root, relative_directory) else root
    children <- list.files(
      directory, all.files = TRUE, no.. = TRUE, full.names = FALSE,
      recursive = FALSE
    )
    for (child in children) {
      relative <- if (nzchar(relative_directory)) {
        paste(relative_directory, child, sep = "/")
      } else child
      path <- file.path(root, relative)
      linked <- nzchar(Sys.readlink(path))
      if (linked) {
        symlinks <- c(symlinks, relative)
      } else if (relative %in% ignored_roots ||
                 identical(relative, "renv/library")) {
        directories <- c(directories, relative)
      } else if (dir.exists(path)) {
        directories <- c(directories, relative)
        queue <- c(queue, relative)
      } else {
        files <- c(files, relative)
      }
    }
  }
  list(
    files = sort(files, method = "radix"),
    directories = sort(directories, method = "radix"),
    symlinks = sort(symlinks, method = "radix")
  )
}

rrp_hospital_tar_text_field <- function(header, first, last) {
  value <- header[first:last]
  zero <- which(value == as.raw(0L))
  if (length(zero) > 0L) value <- value[seq_len(zero[[1L]] - 1L)]
  if (length(value) == 0L) return("")
  trimws(rawToChar(value, multiple = FALSE))
}

rrp_hospital_tar_octal <- function(header, first, last) {
  value <- rrp_hospital_tar_text_field(header, first, last)
  value <- gsub(" ", "", value, fixed = TRUE)
  if (!nzchar(value) || grepl("[^0-7]", value)) return(NA_real_)
  sum(as.numeric(strtoi(strsplit(value, "", fixed = TRUE)[[1L]], base = 8L)) *
        8 ^ rev(seq_along(strsplit(value, "", fixed = TRUE)[[1L]]) - 1L))
}

rrp_hospital_tar_header_checksum <- function(header) {
  candidate <- header
  candidate[149:156] <- charToRaw("        ")
  sum(as.integer(candidate))
}

rrp_hospital_read_tar <- function(path, include_content = TRUE) {
  connection <- file(path, open = "rb")
  on.exit(close(connection), add = TRUE)
  entries <- list()
  zero_blocks <- 0L
  repeat {
    header <- readBin(connection, "raw", n = 512L)
    if (length(header) == 0L) break
    if (length(header) != 512L) stop("Platform archive has a truncated header.", call. = FALSE)
    if (all(header == as.raw(0L))) {
      zero_blocks <- zero_blocks + 1L
      if (zero_blocks >= 2L) break
      next
    }
    zero_blocks <- 0L
    name <- rrp_hospital_tar_text_field(header, 1L, 100L)
    prefix <- rrp_hospital_tar_text_field(header, 346L, 500L)
    relative <- if (nzchar(prefix)) paste(prefix, name, sep = "/") else name
    size <- rrp_hospital_tar_octal(header, 125L, 136L)
    checksum <- rrp_hospital_tar_octal(header, 149L, 156L)
    type <- rawToChar(header[157L], multiple = FALSE)
    if (!nzchar(type)) type <- "0"
    if (is.na(size) || is.na(checksum) ||
        !identical(checksum, as.numeric(rrp_hospital_tar_header_checksum(header)))) stop(
      "Platform archive header size or checksum is invalid.", call. = FALSE
    )
    if (!rrp_hospital_safe_relative_path(relative)) stop(
      "Platform archive contains an unsafe relative path: ", relative, call. = FALSE
    )
    if (!identical(type, "0")) stop(
      "Platform archive contains a non-regular member: ", relative, call. = FALSE
    )
    if (relative %in% names(entries)) stop(
      "Platform archive contains a duplicate member: ", relative, call. = FALSE
    )
    content <- readBin(connection, "raw", n = as.integer(size))
    if (length(content) != as.integer(size)) stop(
      "Platform archive member is truncated: ", relative, call. = FALSE
    )
    padding <- (512L - (as.integer(size) %% 512L)) %% 512L
    if (padding > 0L && length(readBin(connection, "raw", n = padding)) != padding) stop(
      "Platform archive padding is truncated.", call. = FALSE
    )
    entries[[relative]] <- list(
      path = relative,
      size = as.numeric(size),
      sha256 = rrp_hospital_sha256_raw(content),
      content = if (include_content) content else NULL
    )
  }
  entries
}

rrp_hospital_validate_platform_candidate_archive <- function(
  archive_path,
  expected_reference = NULL
) {
  issues <- list()
  entries <- tryCatch(
    rrp_hospital_read_tar(archive_path, include_content = TRUE),
    error = function(condition) condition
  )
  if (inherits(entries, "condition")) return(list(
    issues = rrp_hospital_issue(
      "platform_candidate", "unsafe_or_invalid_platform_archive",
      conditionMessage(entries), "platform/"
    ), manifest = NULL, entries = NULL
  ))
  manifest_entry <- entries[["PLATFORM-CANDIDATE.yml"]]
  if (is.null(manifest_entry)) return(list(
    issues = rrp_hospital_issue(
      "platform_candidate", "missing_platform_candidate_manifest",
      "Embedded Platform candidate archive has no PLATFORM-CANDIDATE.yml.",
      "platform/"
    ), manifest = NULL, entries = entries
  ))
  candidate <- tryCatch(
    yaml::yaml.load(rawToChar(manifest_entry$content)),
    error = function(condition) condition
  )
  if (inherits(candidate, "condition") || !is.list(candidate)) return(list(
    issues = rrp_hospital_issue(
      "platform_candidate", "invalid_platform_candidate_manifest",
      "PLATFORM-CANDIDATE.yml is not readable candidate metadata.",
      "platform/PLATFORM-CANDIDATE.yml"
    ), manifest = NULL, entries = entries
  ))
  required <- c(
    "manifest_kind", "manifest_version", "platform_identity",
    "candidate_instance_id", "candidate_status", "source_provenance",
    "inventory", "environment", "compatibility", "nonclaims"
  )
  missing <- setdiff(required, names(candidate))
  for (field in missing) issues[[length(issues) + 1L]] <- rrp_hospital_issue(
    "platform_candidate", "missing_platform_candidate_field",
    paste0("Platform candidate manifest is missing `", field, "`."),
    paste0("PLATFORM-CANDIDATE.yml#", field)
  )
  expected_compatibility <- list(
    hospital_distribution_specification =
      rrp_hospital_distribution_specification(),
    exact_inclusion_required = TRUE
  )
  candidate_contract_ok <- identical(
    candidate$manifest_kind, "platform_release_candidate_manifest"
  ) && identical(candidate$manifest_version, "0.1.0") &&
    identical(candidate$candidate_status,
              "proof_only_not_published_not_v0.1.0") &&
    identical(candidate$source_provenance$kind,
              "validated_allowlisted_working_tree_candidate") &&
    identical(candidate$source_provenance$git_identity_is_semantic, FALSE) &&
    identical(candidate$source_provenance$public_release, FALSE) &&
    identical(candidate$compatibility, expected_compatibility)
  if (!candidate_contract_ok) issues[[length(issues) + 1L]] <- rrp_hospital_issue(
    "platform_candidate", "unsupported_platform_candidate_manifest",
    "Platform candidate manifest kind, status, provenance, or compatibility is unsupported.",
    "platform/PLATFORM-CANDIDATE.yml"
  )
  inventory <- candidate$inventory
  inventory_ok <- is.list(inventory) && length(inventory) > 0L && all(vapply(
    inventory,
    function(item) is.list(item) && rrp_hospital_safe_relative_path(item$path) &&
      is.numeric(item$byte_size) && length(item$byte_size) == 1L &&
      is.list(item$checksum) && identical(item$checksum$algorithm, "sha256") &&
      is.character(item$checksum$value) && length(item$checksum$value) == 1L &&
      grepl("^[a-f0-9]{64}$", item$checksum$value),
    logical(1)
  ))
  if (!inventory_ok) {
    issues[[length(issues) + 1L]] <- rrp_hospital_issue(
      "platform_candidate", "invalid_platform_candidate_inventory",
      "Platform candidate inventory requires safe paths, sizes, and SHA-256 checksums.",
      "PLATFORM-CANDIDATE.yml#inventory"
    )
  } else {
    inventory_paths <- vapply(inventory, `[[`, character(1), "path")
    archive_payload <- setdiff(names(entries), "PLATFORM-CANDIDATE.yml")
    if (anyDuplicated(inventory_paths) ||
        !identical(sort(inventory_paths, method = "radix"),
                   sort(archive_payload, method = "radix"))) {
      issues[[length(issues) + 1L]] <- rrp_hospital_issue(
        "platform_candidate", "platform_candidate_inventory_mismatch",
        "Platform candidate archive members differ from its closed inventory.",
        "PLATFORM-CANDIDATE.yml#inventory"
      )
    }
    for (item in inventory) {
      entry <- entries[[item$path]]
      if (is.null(entry) || !identical(entry$size, as.numeric(item$byte_size)) ||
          !identical(entry$sha256, item$checksum$value)) {
        issues[[length(issues) + 1L]] <- rrp_hospital_issue(
          "platform_candidate", "platform_candidate_member_mismatch",
          "A Platform candidate member differs from its declared size or digest.",
          item$path
        )
      }
    }
    lock_index <- match("renv.lock", inventory_paths)
    lock_item <- if (is.na(lock_index)) NULL else inventory[[lock_index]]
    if (is.null(lock_item) ||
        !identical(candidate$environment$platform_lock_sha256,
                   lock_item$checksum$value)) {
      issues[[length(issues) + 1L]] <- rrp_hospital_issue(
        "platform_candidate", "platform_candidate_lock_mismatch",
        "Platform candidate lock provenance does not match its inventoried renv.lock.",
        "PLATFORM-CANDIDATE.yml#environment"
      )
    }
    records <- vapply(inventory[order(inventory_paths, method = "radix")], function(item) {
      paste(item$path, item$byte_size, item$checksum$value, sep = "|")
    }, character(1))
    expected_instance <- paste0(
      "platform_release_candidate::",
      rrp_hospital_sha256_string(paste(c(
        candidate$platform_identity$platform_id,
        candidate$platform_identity$platform_version,
        records
      ), collapse = "\n"))
    )
    if (!identical(candidate$candidate_instance_id, expected_instance)) {
      issues[[length(issues) + 1L]] <- rrp_hospital_issue(
        "platform_candidate", "platform_candidate_identity_mismatch",
        "Platform candidate instance identity does not match its exact inventory.",
        "PLATFORM-CANDIDATE.yml#candidate_instance_id"
      )
    }
  }
  expected_identity <- if (is.list(expected_reference)) list(
    platform_id = expected_reference$platform_id,
    platform_version = expected_reference$platform_version
  ) else NULL
  if (!is.null(expected_identity) &&
      !identical(candidate$platform_identity, expected_identity)) {
    issues[[length(issues) + 1L]] <- rrp_hospital_issue(
      "compatibility", "platform_candidate_reference_mismatch",
      "Distribution and embedded Platform candidate identity/version differ.",
      "HOSPITAL-DISTRIBUTION.yml#platform_candidate"
    )
  }
  list(
    issues = rrp_hospital_bind_issues(issues),
    manifest = candidate,
    entries = entries
  )
}

rrp_hospital_distribution_instance_id <- function(manifest) {
  inventory <- manifest$inventory
  paths <- vapply(inventory, `[[`, character(1), "path")
  records <- vapply(inventory[order(paths, method = "radix")], function(item) paste(
    item$path, item$byte_size, item$checksum$value, sep = "|"
  ), character(1))
  paste0("hospital_implementation_distribution::", rrp_hospital_sha256_string(
    paste(c(
      manifest$distribution_specification$specification_id,
      manifest$distribution_specification$specification_version,
      manifest$hospital_implementation$release_id,
      manifest$hospital_implementation$release_version,
      manifest$platform_candidate$candidate_instance_id,
      manifest$platform_candidate$archive_sha256,
      manifest$environment$top_level_lock_sha256,
      records
    ), collapse = "\n")
  ))
}

rrp_hospital_distribution_build_id <- function(instance_id, built_at) paste0(
  "hospital_implementation_distribution_build::",
  rrp_hospital_sha256_string(paste(instance_id, built_at, sep = "\n"))
)

rrp_validate_hospital_distribution <- function(
  root,
  allow_local_state = TRUE,
  allow_git_realization = FALSE
) {
  issues <- list()
  root_link <- nzchar(Sys.readlink(root))
  root <- normalizePath(root, mustWork = FALSE)
  if (!dir.exists(root) || root_link) return(rrp_hospital_result(list(
    rrp_hospital_issue(
      "integrity", "distribution_root_unavailable",
      "Distribution root must be an existing regular directory, not a symbolic link."
    )
  )))
  tree <- rrp_hospital_scan_tree(root, allow_local_state, allow_git_realization)
  for (path in tree$symlinks) issues[[length(issues) + 1L]] <- rrp_hospital_issue(
    "integrity", "distribution_symbolic_link",
    "Symbolic links are prohibited in the generated distribution baseline.", path
  )
  required_root <- c(
    ".Rprofile", ".gitignore", ".renvignore", "README.md", "HOSPITAL-DISTRIBUTION.yml",
    "HOSPITAL-DISTRIBUTION.sha256", "renv.lock", "validate-distribution.R"
  )
  missing_root <- setdiff(required_root, tree$files)
  for (path in missing_root) issues[[length(issues) + 1L]] <- rrp_hospital_issue(
    "inventory", "missing_required_distribution_file",
    "A required Hospital Implementation root file is missing.", path
  )
  if (length(missing_root) > 0L) return(rrp_hospital_result(issues))

  manifest_path <- file.path(root, "HOSPITAL-DISTRIBUTION.yml")
  checksum <- trimws(readLines(
    file.path(root, "HOSPITAL-DISTRIBUTION.sha256"), warn = FALSE
  ))
  if (length(checksum) != 1L || !grepl("^[a-f0-9]{64}$", checksum) ||
      !identical(checksum, rrp_hospital_sha256_file(manifest_path))) return(
    rrp_hospital_result(c(issues, list(rrp_hospital_issue(
      "integrity", "distribution_manifest_checksum_mismatch",
      "HOSPITAL-DISTRIBUTION.sha256 does not match the manifest.",
      "HOSPITAL-DISTRIBUTION.sha256"
    ))))
  )
  manifest <- tryCatch(rrp_hospital_read_yaml(manifest_path), error = function(value) value)
  if (inherits(manifest, "condition") || !is.list(manifest)) return(
    rrp_hospital_result(c(issues, list(rrp_hospital_issue(
      "contract", "invalid_distribution_manifest",
      "HOSPITAL-DISTRIBUTION.yml is not readable metadata.",
      "HOSPITAL-DISTRIBUTION.yml"
    ))))
  )
  required <- c(
    "manifest_kind", "manifest_version", "distribution_specification",
    "hospital_implementation",
    "distribution_instance_id", "distribution_build_id", "built_at",
    "platform_candidate", "compatibility", "builder", "environment",
    "required_files", "inventory", "integrity", "validation_evidence",
    "data_classification", "validation_status", "nonclaims"
  )
  for (field in setdiff(required, names(manifest))) {
    issues[[length(issues) + 1L]] <- rrp_hospital_issue(
      "contract", "missing_distribution_manifest_field",
      paste0("Distribution manifest is missing `", field, "`."),
      paste0("HOSPITAL-DISTRIBUTION.yml#", field)
    )
  }
  if (!identical(manifest$manifest_kind,
                 "hospital_implementation_distribution_manifest") ||
      !identical(manifest$manifest_version, "0.1.0")) {
    issues[[length(issues) + 1L]] <- rrp_hospital_issue(
      "contract", "unsupported_distribution_manifest",
      "Distribution manifest kind/version is unsupported.",
      "HOSPITAL-DISTRIBUTION.yml#manifest_version"
    )
  }
  if (!identical(manifest$distribution_specification,
                 rrp_hospital_distribution_specification())) {
    issues[[length(issues) + 1L]] <- rrp_hospital_issue(
      "compatibility", "unsupported_distribution_specification",
      "Distribution specification identity/version is unsupported.",
      "HOSPITAL-DISTRIBUTION.yml#distribution_specification"
    )
  }
  expected_release <- list(
    release_id = "readmission-risk-pool-hospital-implementation",
    release_version = "0.0.0-proof.11.4",
    release_status = "proof_only_not_published"
  )
  expected_compatibility <- list(
    platform_inclusion = "exact_candidate_only",
    canonical_producer = list(
      specification_id = "platform.canonical-producer",
      specification_version = "0.1.0"
    ),
    reduced_application_artifact = list(
      specification_id = "platform.reduced-application-artifact",
      specification_version = "0.1.0"
    )
  )
  if (!identical(manifest$hospital_implementation, expected_release) ||
      !identical(manifest$compatibility, expected_compatibility)) {
    issues[[length(issues) + 1L]] <- rrp_hospital_issue(
      "compatibility", "incompatible_hospital_platform_declaration",
      "Hospital release or Platform compatibility declaration is unsupported.",
      "HOSPITAL-DISTRIBUTION.yml#compatibility"
    )
  }
  inventory <- manifest$inventory
  inventory_ok <- is.list(inventory) && length(inventory) > 0L && all(vapply(
    inventory,
    function(item) is.list(item) && rrp_hospital_safe_relative_path(item$path) &&
      is.character(item$role) && length(item$role) == 1L && nzchar(item$role) &&
      is.numeric(item$byte_size) && length(item$byte_size) == 1L &&
      is.list(item$checksum) && identical(item$checksum$algorithm, "sha256") &&
      is.character(item$checksum$value) && length(item$checksum$value) == 1L &&
      grepl("^[a-f0-9]{64}$", item$checksum$value),
    logical(1)
  ))
  if (!inventory_ok) return(rrp_hospital_result(c(issues, list(rrp_hospital_issue(
    "inventory", "invalid_distribution_inventory",
    "Distribution inventory requires safe paths, roles, sizes, and SHA-256 checksums.",
    "HOSPITAL-DISTRIBUTION.yml#inventory"
  ))), manifest))
  inventory_paths <- vapply(inventory, `[[`, character(1), "path")
  required_files <- unlist(manifest$required_files, use.names = FALSE)
  if (!is.character(required_files) || anyDuplicated(required_files) ||
      !identical(sort(required_files, method = "radix"),
                 sort(inventory_paths, method = "radix"))) {
    issues[[length(issues) + 1L]] <- rrp_hospital_issue(
      "inventory", "required_files_mismatch",
      "Required files must exactly equal the closed payload inventory.",
      "HOSPITAL-DISTRIBUTION.yml#required_files"
    )
  }
  expected_files <- sort(c(
    "HOSPITAL-DISTRIBUTION.yml", "HOSPITAL-DISTRIBUTION.sha256", inventory_paths
  ), method = "radix")
  if (anyDuplicated(inventory_paths) || !identical(tree$files, expected_files)) {
    issues[[length(issues) + 1L]] <- rrp_hospital_issue(
      "inventory", "distribution_inventory_mismatch",
      paste0(
        "Closed distribution inventory differs from disk. Unexpected: ",
        paste(setdiff(tree$files, expected_files), collapse = ", "),
        "; missing: ", paste(setdiff(expected_files, tree$files), collapse = ", "), "."
      ), "$"
    )
  }
  for (item in inventory) {
    path <- file.path(root, item$path)
    size <- if (file.exists(path)) as.numeric(file.info(path)$size) else NA_real_
    if (!file.exists(path) || dir.exists(path) || nzchar(Sys.readlink(path)) ||
        !identical(size, as.numeric(item$byte_size)) ||
        !identical(rrp_hospital_sha256_file(path), item$checksum$value)) {
      issues[[length(issues) + 1L]] <- rrp_hospital_issue(
        "integrity", "distribution_member_mismatch",
        "A distribution member is missing, linked, or differs from its declared content.",
        item$path
      )
    }
  }
  if (!rrp_hospital_timestamp(manifest$built_at) ||
      !identical(manifest$distribution_instance_id,
                 rrp_hospital_distribution_instance_id(manifest)) ||
      !identical(manifest$distribution_build_id, rrp_hospital_distribution_build_id(
        manifest$distribution_instance_id, manifest$built_at
      ))) issues[[length(issues) + 1L]] <- rrp_hospital_issue(
    "identity", "distribution_identity_mismatch",
    "Distribution logical/build identity or build time is invalid.",
    "HOSPITAL-DISTRIBUTION.yml#distribution_instance_id"
  )
  if (!identical(manifest$data_classification, "fictional_nonclinical") ||
      !identical(manifest$validation_status, "passed") ||
      !identical(manifest$validation_evidence, c(
        rrp_hospital_validator_reference(), list(status = "passed")
      ))) issues[[length(issues) + 1L]] <- rrp_hospital_issue(
    "validation", "invalid_distribution_validation_evidence",
    "Distribution must retain fictional classification and supported passed validation.",
    "HOSPITAL-DISTRIBUTION.yml#validation_evidence"
  )

  archives <- inventory_paths[grepl("^platform/.*[.]tar$", inventory_paths)]
  declared_archive <- manifest$platform_candidate$archive_filename
  if (length(archives) != 1L ||
      !identical(archives, paste0("platform/", declared_archive))) {
    issues[[length(issues) + 1L]] <- rrp_hospital_issue(
      "platform_candidate", "platform_archive_count_mismatch",
      "Distribution must contain exactly its one declared Platform candidate archive.",
      "platform"
    )
  }
  archive_path <- file.path(root, "platform", declared_archive)
  archive_size <- if (file.exists(archive_path)) as.numeric(file.info(archive_path)$size) else NA_real_
  if (!file.exists(archive_path) ||
      !identical(archive_size, as.numeric(manifest$platform_candidate$archive_byte_size)) ||
      !identical(rrp_hospital_sha256_file(archive_path),
                 manifest$platform_candidate$archive_sha256)) {
    issues[[length(issues) + 1L]] <- rrp_hospital_issue(
      "platform_candidate", "platform_archive_digest_mismatch",
      "Embedded Platform candidate filename, size, or SHA-256 does not match.",
      paste0("platform/", declared_archive)
    )
    return(rrp_hospital_result(issues, manifest))
  }
  candidate <- rrp_hospital_validate_platform_candidate_archive(
    archive_path, manifest$platform_candidate
  )
  if (nrow(candidate$issues) > 0L) issues[[length(issues) + 1L]] <- candidate$issues
  if (!is.null(candidate$manifest)) {
    if (!identical(candidate$manifest$candidate_instance_id,
                   manifest$platform_candidate$candidate_instance_id) ||
        !identical(length(candidate$manifest$inventory), as.integer(
          manifest$platform_candidate$archive_inventory_member_count
        )) ||
        !identical(candidate$manifest$candidate_status,
                   "proof_only_not_published_not_v0.1.0") ||
        !identical(candidate$manifest$source_provenance$public_release, FALSE) ||
        !identical(manifest$platform_candidate$public_release, FALSE) ||
        !identical(candidate$manifest$environment$platform_lock_sha256,
                   manifest$environment$source_platform_lock_sha256) ||
        !identical(manifest$environment$source_platform_lock_sha256,
                   manifest$environment$top_level_lock_sha256) ||
        !identical(rrp_hospital_sha256_file(file.path(root, "renv.lock")),
                   manifest$environment$top_level_lock_sha256) ||
        length(manifest$environment$maintained_dependency_additions) != 0L ||
        !identical(manifest$environment$active_project, "hospital_implementation_root") ||
        !identical(manifest$environment$nested_platform_activation, "not_used")) {
      issues[[length(issues) + 1L]] <- rrp_hospital_issue(
        "environment", "hospital_environment_mismatch",
        "Top-level lock/environment does not exactly preserve the Platform lock with zero additions.",
        "HOSPITAL-DISTRIBUTION.yml#environment"
      )
    }
  }
  required_baseline <- c(
    "contracts/hospital-implementation-distribution.yml",
    "implementation/producer.yml", "implementation/platform-instance.yml",
    "implementation/producer-configuration.yml",
    "implementation/R/producer.R", "implementation/R/composition.R",
    "examples/fictional-adopter/README.md",
    "contracts/hospital-implementation-git-realization.yml",
    "R/git-realization-runtime.R", "validate-git-realization.R",
    "operations/initialize.R", "operations/doctor.R",
    "operations/run-reference-acceptance.R",
    "operations/validate-producer.R", "operations/run-platform.R",
    "operations/inspect-history.R", "operations/build-products.R",
    "operations/validate-app.R",
    "operations/build-application-artifact.R",
    "operations/validate-application-artifact.R",
    "operations/run-fictional-adopter-proof.R"
  )
  if (length(setdiff(required_baseline, inventory_paths)) > 0L) {
    issues[[length(issues) + 1L]] <- rrp_hospital_issue(
      "readiness", "hospital_baseline_incomplete",
      "Required wrappers, producer scaffold, or fictional example are absent.", "$"
    )
  }
  prohibited <- grepl(
    "(^|/)([.]git|[.]env|[.]Rhistory|[.]RData|renv/library|build)(/|$)",
    inventory_paths
  ) | grepl("(^|/)(history[.]duckdb|CURRENT[.]yml)$", inventory_paths)
  if (any(prohibited)) {
    issues[[length(issues) + 1L]] <- rrp_hospital_issue(
      "scope", "prohibited_distribution_content",
      "Distribution baseline contains prohibited generated, secret, or Git content.", "$"
    )
  }
  rrp_hospital_result(issues, manifest, candidate$manifest)
}

rrp_hospital_validate_platform_execution <- function(root, validation = NULL) {
  if (is.null(validation)) validation <- rrp_validate_hospital_distribution(
    root, allow_local_state = TRUE,
    allow_git_realization = rrp_hospital_git_realization_envelope_present(root)
  )
  if (!identical(validation$overall_status, "pass")) stop(
    "Distribution must pass structural validation before Platform validation.",
    call. = FALSE
  )
  archive <- file.path(
    root, "platform", validation$manifest$platform_candidate$archive_filename
  )
  candidate <- rrp_hospital_validate_platform_candidate_archive(
    archive, validation$manifest$platform_candidate
  )
  if (nrow(candidate$issues) > 0L) stop(
    "Embedded Platform candidate failed before execution validation.", call. = FALSE
  )
  staging <- tempfile("rrp-hospital-platform-validation-")
  dir.create(staging)
  on.exit(unlink(staging, recursive = TRUE, force = TRUE), add = TRUE)
  rrp_hospital_extract_platform_entries(candidate$entries, staging)
  if (!rrp_hospital_validate_extracted_platform(staging, candidate$manifest)) stop(
    "Temporary Platform extraction differs from the candidate inventory.", call. = FALSE
  )
  doctor_state <- tempfile("rrp-hospital-doctor-state-")
  dir.create(doctor_state)
  on.exit(unlink(doctor_state, recursive = TRUE, force = TRUE), add = TRUE)
  doctor <- rrp_hospital_run_process(
    file.path(staging, "operations", "doctor.R"),
    c(
      "--database", file.path(doctor_state, "history.duckdb"),
      "--products", file.path(doctor_state, "products")
    ), staging
  )
  if (!identical(doctor$status, 0L)) stop(
    "Temporary extracted Platform failed Platform-owned doctor: ",
    paste(doctor$output, collapse = " | "), call. = FALSE
  )
  list(status = "passed", candidate_instance_id = candidate$manifest$candidate_instance_id)
}

rrp_hospital_validate_extracted_platform <- function(root, candidate_manifest) {
  tree <- rrp_hospital_scan_tree(root, allow_local_state = FALSE)
  inventory <- candidate_manifest$inventory
  paths <- vapply(inventory, `[[`, character(1), "path")
  expected <- sort(c("PLATFORM-CANDIDATE.yml", paths), method = "radix")
  if (length(tree$symlinks) > 0L || !identical(tree$files, expected)) return(FALSE)
  all(vapply(inventory, function(item) {
    path <- file.path(root, item$path)
    file.exists(path) && !dir.exists(path) && !nzchar(Sys.readlink(path)) &&
      identical(as.numeric(file.info(path)$size), as.numeric(item$byte_size)) &&
      identical(rrp_hospital_sha256_file(path), item$checksum$value)
  }, logical(1)))
}

rrp_hospital_extract_platform_entries <- function(entries, root) {
  for (entry in entries) {
    destination <- file.path(root, entry$path)
    dir.create(dirname(destination), recursive = TRUE, showWarnings = FALSE)
    connection <- file(destination, open = "wb")
    writeBin(entry$content, connection, useBytes = TRUE)
    close(connection)
  }
  invisible(root)
}

rrp_hospital_library_environment <- function() paste0(
  "R_LIBS=", shQuote(paste(.libPaths(), collapse = .Platform$path.sep))
)

rrp_hospital_run_process <- function(script, arguments = character(), working_directory) {
  output <- tempfile("rrp-hospital-process-", fileext = ".log")
  on.exit(unlink(output, force = TRUE), add = TRUE)
  previous <- setwd(working_directory)
  on.exit(setwd(previous), add = TRUE)
  status <- system2(
    file.path(R.home("bin"), "Rscript"),
    c("--vanilla", shQuote(script), vapply(arguments, shQuote, character(1))),
    stdout = output, stderr = output,
    env = rrp_hospital_library_environment()
  )
  list(
    status = status,
    output = if (file.exists(output)) readLines(output, warn = FALSE) else character()
  )
}

rrp_initialize_hospital_distribution <- function(root) {
  validation <- rrp_validate_hospital_distribution(
    root, allow_local_state = TRUE,
    allow_git_realization = rrp_hospital_git_realization_envelope_present(root)
  )
  if (!identical(validation$overall_status, "pass")) stop(
    "Hospital Implementation distribution is invalid: ",
    paste(validation$issues$issue_code, collapse = ", "), call. = FALSE
  )
  manifest <- validation$manifest
  archive_path <- file.path(
    root, "platform", manifest$platform_candidate$archive_filename
  )
  candidate <- rrp_hospital_validate_platform_candidate_archive(
    archive_path, manifest$platform_candidate
  )
  if (nrow(candidate$issues) > 0L) stop(
    "Embedded Platform candidate is invalid: ",
    paste(candidate$issues$issue_code, collapse = ", "), call. = FALSE
  )
  digest <- sub("^.*::", "", candidate$manifest$candidate_instance_id)
  platform_parent <- file.path(root, ".rrp", "platform")
  final <- file.path(platform_parent, digest)
  dir.create(platform_parent, recursive = TRUE, showWarnings = FALSE)
  if (!dir.exists(platform_parent) || nzchar(Sys.readlink(platform_parent))) stop(
    "Managed Platform parent must be a regular local directory.", call. = FALSE
  )
  if (dir.exists(final)) {
    if (!rrp_hospital_validate_extracted_platform(final, candidate$manifest)) stop(
      "Managed Platform baseline differs from the declared candidate; preserve it for review and remove or relocate it before retrying.",
      call. = FALSE
    )
    return(list(
      status = "succeeded", managed_platform = final,
      candidate_instance_id = candidate$manifest$candidate_instance_id,
      idempotent = TRUE
    ))
  }
  staging <- tempfile(".staging-", tmpdir = platform_parent)
  dir.create(staging)
  on.exit(if (dir.exists(staging)) unlink(staging, recursive = TRUE, force = TRUE), add = TRUE)
  rrp_hospital_extract_platform_entries(candidate$entries, staging)
  if (!rrp_hospital_validate_extracted_platform(staging, candidate$manifest)) stop(
    "Extracted Platform candidate failed exact inventory validation.", call. = FALSE
  )
  doctor <- rrp_hospital_run_process(
    file.path(staging, "operations", "doctor.R"),
    c(
      "--database", file.path(root, "build", "initialization-check", "history.duckdb"),
      "--products", file.path(root, "build", "initialization-check", "products")
    ),
    staging
  )
  if (!identical(doctor$status, 0L)) stop(
    "Extracted Platform candidate failed Platform-owned doctor validation: ",
    paste(doctor$output, collapse = " | "), call. = FALSE
  )
  if (!file.rename(staging, final)) stop(
    "Could not atomically promote the validated managed Platform candidate.", call. = FALSE
  )
  list(
    status = "succeeded", managed_platform = final,
    candidate_instance_id = candidate$manifest$candidate_instance_id,
    idempotent = FALSE
  )
}

rrp_hospital_managed_platform <- function(root) {
  initialized <- rrp_initialize_hospital_distribution(root)
  initialized$managed_platform
}

rrp_hospital_delegate_platform <- function(root, script, arguments = character()) {
  managed <- rrp_hospital_managed_platform(root)
  path <- file.path(managed, "operations", script)
  if (!file.exists(path) || nzchar(Sys.readlink(path))) stop(
    "Managed Platform operation is unavailable: ", script, call. = FALSE
  )
  result <- rrp_hospital_run_process(path, arguments, managed)
  if (!identical(result$status, 0L)) stop(
    "Delegated Platform operation failed (`", script, "`): ",
    paste(result$output, collapse = " | "), call. = FALSE
  )
  result
}

rrp_hospital_root_from_script <- function(script_path) normalizePath(
  file.path(dirname(script_path), ".."), mustWork = TRUE
)

rrp_hospital_print_process <- function(result) {
  cat(paste(result$output, collapse = "\n"), "\n", sep = "")
  invisible(result)
}

rrp_hospital_source_platform_cycle <- function(managed_root, envir = parent.frame()) {
  library_files <- c(
    "observability-operation.R", "validation-result.R", "conformance-result.R",
    "specification-validation.R", "foundation-context-validation.R",
    "canonical-bundle-validation.R", "canonical-clinical-validation.R",
    "canonical-producer-operation.R", "history-validation.R",
    "runtime-operation.R", "provider-operation.R", "duckdb-persistence-operation.R",
    "reference-history-operation.R", "platform-cycle-operation.R",
    "product-operation.R", "product-materialization-operation.R",
    "application-artifact-operation.R"
  )
  for (file in library_files) sys.source(
    file.path(managed_root, "operations", "lib", file), envir = envir
  )
  for (file in c("foundation.R", "schema.R", "adapter.R", "session.R")) {
    sys.source(file.path(
      managed_root, "implementations", "persistence", "duckdb", "R", file
    ), envir = envir)
  }
  for (file in c("foundation.R", "conformance.R", "builders.R", "access.R")) {
    sys.source(file.path(managed_root, "products", "R", file), envir = envir)
  }
  for (file in c("foundation.R", "validation.R", "adapter.R", "access.R")) {
    sys.source(file.path(
      managed_root, "implementations", "products", "yaml", "R", file
    ), envir = envir)
  }
  for (file in c("app-init.R", "view-models.R", "app.R")) {
    sys.source(file.path(managed_root, "app", "R", file), envir = envir)
  }
  sys.source(file.path(
    managed_root, "deploy", "application-artifact", "R", "artifact-runtime.R"
  ), envir = envir)
  invisible(TRUE)
}
