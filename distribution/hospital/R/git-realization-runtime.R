# Standalone validation primitives for the generated Hospital Implementation
# Git form. This runtime relies only on the validated distribution beside it.

rrp_hospital_git_specification <- function() list(
  specification_kind = "hospital_implementation_git_realization",
  specification_id = "platform.hospital-implementation-git-realization",
  specification_version = "0.1.0"
)

rrp_hospital_git_validator_reference <- function() list(
  validator_id = "platform.hospital-implementation-git-realization-validator",
  validator_version = "0.1.0"
)

rrp_hospital_git_builder_reference <- function() list(
  builder_id = "platform.hospital-implementation-git-realization-builder",
  builder_version = "0.1.0",
  operation_id = "platform.build-hospital-git-realization"
)

rrp_hospital_git_metadata_files <- function() c(
  "HOSPITAL-GIT-REALIZATION.yml", "HOSPITAL-GIT-REALIZATION.sha256"
)

rrp_hospital_git_result <- function(issues = list(), manifest = NULL,
                                    distribution = NULL) {
  issues <- rrp_hospital_bind_issues(issues)
  structure(list(
    overall_status = if (nrow(issues) == 0L) "pass" else "fail",
    issues = issues,
    manifest = manifest,
    distribution = distribution
  ), class = "rrp_hospital_git_realization_validation_result")
}

rrp_hospital_git_scan_tree <- function(root, exclude_root_git = TRUE) {
  files <- character()
  directories <- character()
  symlinks <- character()
  queue <- ""
  while (length(queue) > 0L) {
    relative_directory <- queue[[1L]]
    queue <- queue[-1L]
    directory <- if (nzchar(relative_directory)) {
      file.path(root, relative_directory)
    } else root
    children <- list.files(
      directory, all.files = TRUE, no.. = TRUE, recursive = FALSE,
      full.names = FALSE
    )
    if (exclude_root_git && !nzchar(relative_directory)) {
      children <- setdiff(children, ".git")
    }
    for (child in children) {
      relative <- if (nzchar(relative_directory)) {
        paste(relative_directory, child, sep = "/")
      } else child
      path <- file.path(root, relative)
      if (nzchar(Sys.readlink(path))) {
        symlinks <- c(symlinks, relative)
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

rrp_hospital_git_run <- function(root, arguments) {
  git <- Sys.which("git")
  if (!nzchar(git)) return(list(status = 127L, output = "Git is unavailable."))
  output <- suppressWarnings(system2(
    git, c("-C", shQuote(root), arguments), stdout = TRUE, stderr = TRUE
  ))
  status <- attr(output, "status")
  if (is.null(status)) status <- 0L
  list(status = as.integer(status), output = as.character(output))
}

rrp_hospital_git_inventory_records <- function(root, paths) {
  paths <- sort(paths, method = "radix")
  lapply(paths, function(path) list(
    path = path,
    byte_size = as.numeric(file.info(file.path(root, path))$size),
    checksum = list(
      algorithm = "sha256",
      value = rrp_hospital_sha256_file(file.path(root, path))
    )
  ))
}

rrp_hospital_git_expected_directories <- function(paths) {
  directories <- unlist(lapply(paths, function(path) {
    parts <- strsplit(path, "/", fixed = TRUE)[[1L]]
    if (length(parts) <= 1L) return(character())
    vapply(seq_len(length(parts) - 1L), function(index) {
      paste(parts[seq_len(index)], collapse = "/")
    }, character(1))
  }), use.names = FALSE)
  sort(unique(directories), method = "radix")
}

rrp_hospital_git_realization_id <- function(manifest) {
  inventory <- manifest$source_inventory
  paths <- vapply(inventory, `[[`, character(1), "path")
  records <- vapply(inventory[order(paths, method = "radix")], function(item) {
    paste(item$path, item$byte_size, item$checksum$value, sep = "|")
  }, character(1))
  paste0("hospital_implementation_git_realization::", rrp_hospital_sha256_string(
    paste(c(
      manifest$realization_specification$specification_id,
      manifest$realization_specification$specification_version,
      manifest$builder$builder_id,
      manifest$builder$builder_version,
      manifest$source_distribution$distribution_instance_id,
      manifest$source_distribution$distribution_build_id,
      manifest$source_distribution$manifest_sha256,
      manifest$included_platform$candidate_instance_id,
      manifest$included_platform$archive_sha256,
      records
    ), collapse = "\n")
  ))
}

rrp_hospital_git_validate_git_state <- function(root, expected_files) {
  issues <- list()
  git_path <- file.path(root, ".git")
  if (!dir.exists(git_path) || nzchar(Sys.readlink(git_path))) return(list(
    rrp_hospital_issue(
      "git", "missing_independent_git_repository",
      "Realization must contain one regular independent .git directory.", ".git"
    )
  ))
  git_tree <- rrp_hospital_git_scan_tree(git_path, exclude_root_git = FALSE)
  suspicious <- c(
    git_tree$symlinks,
    git_tree$files[git_tree$files %in% c(
      "commondir", "gitdir", "shallow", "objects/info/alternates"
    )],
    git_tree$files[startsWith(git_tree$files, "modules/")],
    git_tree$files[startsWith(git_tree$files, "worktrees/")]
  )
  if (length(suspicious) > 0L) issues[[length(issues) + 1L]] <- rrp_hospital_issue(
    "git", "suspicious_git_metadata",
    "Generated Git metadata contains links, alternates, modules, worktrees, or shallow state.",
    ".git"
  )
  inside <- rrp_hospital_git_run(root, c("rev-parse", "--is-inside-work-tree"))
  top <- rrp_hospital_git_run(root, c("rev-parse", "--show-toplevel"))
  git_dir <- rrp_hospital_git_run(root, c("rev-parse", "--absolute-git-dir"))
  expected_root <- normalizePath(root, mustWork = TRUE)
  expected_git <- normalizePath(git_path, mustWork = TRUE)
  if (!identical(inside$status, 0L) || !identical(inside$output, "true") ||
      !identical(top$status, 0L) || length(top$output) != 1L ||
      !identical(normalizePath(top$output, mustWork = FALSE), expected_root) ||
      !identical(git_dir$status, 0L) || length(git_dir$output) != 1L ||
      !identical(normalizePath(git_dir$output, mustWork = FALSE), expected_git)) {
    issues[[length(issues) + 1L]] <- rrp_hospital_issue(
      "git", "invalid_independent_git_work_tree",
      "Destination must be one independent Git work tree rooted exactly here.", ".git"
    )
  }
  remotes <- rrp_hospital_git_run(root, "remote")
  if (!identical(remotes$status, 0L) || length(remotes$output) > 0L) {
    issues[[length(issues) + 1L]] <- rrp_hospital_issue(
      "git", "configured_git_remote",
      "Pristine realization must have zero configured remotes.", ".git/config"
    )
  }
  head <- rrp_hospital_git_run(root, c("rev-parse", "--verify", "HEAD"))
  if (identical(head$status, 0L)) issues[[length(issues) + 1L]] <- rrp_hospital_issue(
    "git", "generated_repository_has_commit",
    "Pristine realization must have zero commits; publication authorship remains explicit.",
    ".git/HEAD"
  )
  branch <- rrp_hospital_git_run(root, c("symbolic-ref", "--short", "HEAD"))
  if (!identical(branch$status, 0L) || !identical(branch$output, "main")) {
    issues[[length(issues) + 1L]] <- rrp_hospital_issue(
      "git", "unexpected_initial_branch",
      "Pristine realization must use the uncommitted main branch.", ".git/HEAD"
    )
  }
  tracked <- rrp_hospital_git_run(root, "ls-files")
  if (!identical(tracked$status, 0L) || !identical(
      sort(tracked$output, method = "radix"), sort(expected_files, method = "radix")
  )) issues[[length(issues) + 1L]] <- rrp_hospital_issue(
    "git", "git_index_inventory_mismatch",
    "Every generated file, and only generated files, must be staged.", ".git/index"
  )
  unstaged <- rrp_hospital_git_run(root, c("diff", "--quiet"))
  if (!identical(unstaged$status, 0L)) issues[[length(issues) + 1L]] <-
    rrp_hospital_issue(
      "git", "unstaged_realization_change",
      "Working-tree files differ from the staged generated baseline.", "$"
    )
  status <- rrp_hospital_git_run(
    root, c("status", "--porcelain=v1", "--untracked-files=all")
  )
  expected_status <- paste0("A  ", sort(expected_files, method = "radix"))
  if (!identical(status$status, 0L) || !identical(
      sort(status$output, method = "radix"), expected_status
  )) issues[[length(issues) + 1L]] <- rrp_hospital_issue(
    "git", "unexpected_generated_git_status",
    "Repository must contain only the complete staged initial addition.", "$"
  )
  ignored <- rrp_hospital_git_run(
    root, c("status", "--ignored", "--porcelain=v1", "--untracked-files=all")
  )
  ignored_state <- ignored$output[startsWith(ignored$output, "!! ")]
  if (!identical(ignored$status, 0L) || length(ignored_state) > 0L) {
    issues[[length(issues) + 1L]] <- rrp_hospital_issue(
      "git", "unexpected_ignored_git_state",
      "Pristine realization must not hide generated or recipient state through ignore rules.",
      "$"
    )
  }
  for (key in c("user.name", "user.email", "core.worktree")) {
    configured <- rrp_hospital_git_run(root, c("config", "--local", "--get", key))
    if (identical(configured$status, 0L) && length(configured$output) > 0L) {
      issues[[length(issues) + 1L]] <- rrp_hospital_issue(
        "git", "unexpected_local_git_configuration",
        "Generator must not configure author identity or an alternate work tree.",
        ".git/config"
      )
    }
  }
  issues
}

rrp_validate_hospital_git_realization <- function(
  root,
  check_git = TRUE,
  run_distribution_validator = TRUE
) {
  issues <- list()
  root_link <- nzchar(Sys.readlink(root))
  root <- normalizePath(root, mustWork = FALSE)
  if (!dir.exists(root) || root_link) return(rrp_hospital_git_result(list(
    rrp_hospital_issue(
      "integrity", "git_realization_root_unavailable",
      "Realization root must be an existing regular directory, not a symbolic link."
    )
  )))
  tree <- rrp_hospital_git_scan_tree(root)
  for (path in tree$symlinks) issues[[length(issues) + 1L]] <- rrp_hospital_issue(
    "integrity", "git_realization_symbolic_link",
    "Symbolic links are prohibited in a pristine realization.", path
  )
  nested_git <- c(
    tree$directories[basename(tree$directories) == ".git"],
    tree$files[basename(tree$files) == ".git"]
  )
  if (length(nested_git) > 0L) issues[[length(issues) + 1L]] <- rrp_hospital_issue(
    "git", "nested_git_state",
    "Nested or file-based Git state is prohibited in the generated realization.",
    paste(nested_git, collapse = ", ")
  )
  required <- c(
    "HOSPITAL-DISTRIBUTION.yml", "HOSPITAL-DISTRIBUTION.sha256",
    "HOSPITAL-GIT-REALIZATION.yml", "HOSPITAL-GIT-REALIZATION.sha256",
    "validate-distribution.R", "validate-git-realization.R",
    "R/distribution-runtime.R", "R/git-realization-runtime.R",
    "contracts/hospital-implementation-git-realization.yml"
  )
  missing <- setdiff(required, tree$files)
  for (path in missing) issues[[length(issues) + 1L]] <- rrp_hospital_issue(
    "inventory", "missing_git_realization_member",
    "A required Git-realization member is missing.", path
  )
  if (length(missing) > 0L) return(rrp_hospital_git_result(issues))

  checksum <- trimws(readLines(file.path(
    root, "HOSPITAL-GIT-REALIZATION.sha256"
  ), warn = FALSE))
  manifest_path <- file.path(root, "HOSPITAL-GIT-REALIZATION.yml")
  if (length(checksum) != 1L || !grepl("^[a-f0-9]{64}$", checksum) ||
      !identical(checksum, rrp_hospital_sha256_file(manifest_path))) return(
    rrp_hospital_git_result(c(issues, list(rrp_hospital_issue(
      "integrity", "git_realization_manifest_checksum_mismatch",
      "HOSPITAL-GIT-REALIZATION.sha256 does not match its manifest.",
      "HOSPITAL-GIT-REALIZATION.sha256"
    ))))
  )
  manifest <- tryCatch(rrp_hospital_read_yaml(manifest_path), error = function(value) value)
  contract <- tryCatch(rrp_hospital_read_yaml(file.path(
    root, "contracts", "hospital-implementation-git-realization.yml"
  )), error = function(value) value)
  distribution_manifest <- tryCatch(rrp_hospital_read_yaml(file.path(
    root, "HOSPITAL-DISTRIBUTION.yml"
  )), error = function(value) value)
  if (inherits(manifest, "condition") || !is.list(manifest) ||
      inherits(contract, "condition") || !is.list(contract) ||
      inherits(distribution_manifest, "condition") || !is.list(distribution_manifest)) {
    return(rrp_hospital_git_result(c(issues, list(rrp_hospital_issue(
      "contract", "unreadable_git_realization_metadata",
      "Realization, contract, and distribution metadata must be readable.", "$"
    )))))
  }
  required_fields <- c(
    "manifest_kind", "manifest_version", "realization_specification",
    "realization_instance_id", "realized_at", "source_distribution",
    "included_platform", "builder", "repository_semantics",
    "expected_repository_files", "source_inventory", "provenance",
    "validation_evidence", "validation_status", "nonclaims"
  )
  if (length(setdiff(required_fields, names(manifest))) > 0L ||
      !identical(manifest$manifest_kind,
                 "hospital_implementation_git_realization_manifest") ||
      !identical(manifest$manifest_version, "0.1.0") ||
      !identical(manifest$realization_specification,
                 rrp_hospital_git_specification()) ||
      !identical(contract[c(
        "specification_kind", "specification_id", "specification_version"
      )], rrp_hospital_git_specification())) {
    issues[[length(issues) + 1L]] <- rrp_hospital_issue(
      "contract", "unsupported_git_realization_manifest",
      "Realization manifest or contract identity/version is unsupported.",
      "HOSPITAL-GIT-REALIZATION.yml"
    )
  }
  inventory <- manifest$source_inventory
  inventory_ok <- is.list(inventory) && length(inventory) > 0L && all(vapply(
    inventory, function(item) {
      is.list(item) && rrp_hospital_safe_relative_path(item$path) &&
        is.numeric(item$byte_size) && length(item$byte_size) == 1L &&
        is.list(item$checksum) && identical(item$checksum$algorithm, "sha256") &&
        is.character(item$checksum$value) && length(item$checksum$value) == 1L &&
        grepl("^[a-f0-9]{64}$", item$checksum$value)
    }, logical(1)
  ))
  if (!inventory_ok) return(rrp_hospital_git_result(c(issues, list(
    rrp_hospital_issue(
      "inventory", "invalid_git_realization_source_inventory",
      "Source inventory requires unique safe paths, sizes, and SHA-256 checksums.",
      "HOSPITAL-GIT-REALIZATION.yml#source_inventory"
    )
  )), manifest))
  source_paths <- vapply(inventory, `[[`, character(1), "path")
  expected_files <- sort(c(source_paths, rrp_hospital_git_metadata_files()),
                         method = "radix")
  expected_directories <- rrp_hospital_git_expected_directories(expected_files)
  declared_files <- unlist(manifest$expected_repository_files, use.names = FALSE)
  if (anyDuplicated(source_paths) || !identical(tree$files, expected_files) ||
      !identical(tree$directories, expected_directories) ||
      !identical(sort(declared_files, method = "radix"), expected_files)) {
    issues[[length(issues) + 1L]] <- rrp_hospital_issue(
      "inventory", "git_realization_inventory_mismatch",
      paste0(
        "Repository differs from its closed inventory. Unexpected: ",
        paste(setdiff(tree$files, expected_files), collapse = ", "),
        "; missing: ", paste(setdiff(expected_files, tree$files), collapse = ", "),
        "; unexpected directories: ",
        paste(setdiff(tree$directories, expected_directories), collapse = ", "), "."
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
        "integrity", "git_realization_member_mismatch",
        "A copied distribution member is missing, linked, or modified.", item$path
      )
    }
  }
  source_reference <- list(
    distribution_specification = distribution_manifest$distribution_specification,
    hospital_implementation = distribution_manifest$hospital_implementation,
    distribution_instance_id = distribution_manifest$distribution_instance_id,
    distribution_build_id = distribution_manifest$distribution_build_id,
    manifest_sha256 = rrp_hospital_sha256_file(file.path(
      root, "HOSPITAL-DISTRIBUTION.yml"
    ))
  )
  platform_reference <- list(
    platform_id = distribution_manifest$platform_candidate$platform_id,
    platform_version = distribution_manifest$platform_candidate$platform_version,
    candidate_instance_id = distribution_manifest$platform_candidate$candidate_instance_id,
    archive_filename = distribution_manifest$platform_candidate$archive_filename,
    archive_sha256 = distribution_manifest$platform_candidate$archive_sha256,
    public_release = FALSE
  )
  expected_repository_semantics <- list(
    ownership = "pristine_generated_output_only",
    initial_branch = "main",
    generated_files_staged = TRUE,
    generated_commit = FALSE,
    configured_remote = FALSE,
    replacement_after_change = "prohibited"
  )
  expected_provenance <- list(
    input_kind = "independently_validated_hospital_distribution",
    input_validation = "artifact_owned_validator_passed",
    exact_distribution_copy = TRUE,
    authoritative_source_lookup = FALSE,
    destination_is_identity = FALSE,
    git_commit_is_identity = FALSE,
    published = FALSE
  )
  expected_nonclaims <- c(
    "not a maintained CentralStatz source repository",
    "not committed tagged remote-configured pushed or published",
    "not a final Platform or Hospital Implementation v0.1.0 release",
    "not an upgrade merge or preservation mechanism for recipient changes",
    "not clinically validated security approved or production authorized"
  )
  if (!identical(manifest$source_distribution, source_reference) ||
      !identical(manifest$included_platform, platform_reference) ||
      !identical(manifest$builder, rrp_hospital_git_builder_reference()) ||
      !identical(manifest$repository_semantics, expected_repository_semantics) ||
      !identical(manifest$provenance, expected_provenance) ||
      !identical(manifest$nonclaims, expected_nonclaims) ||
      !identical(manifest$validation_evidence, c(
        rrp_hospital_git_validator_reference(), list(status = "passed")
      )) || !identical(manifest$validation_status, "passed") ||
      !rrp_hospital_timestamp(manifest$realized_at)) {
    issues[[length(issues) + 1L]] <- rrp_hospital_issue(
      "provenance", "git_realization_provenance_mismatch",
      "Realization provenance, Git semantics, builder, time, or validation evidence is invalid.",
      "HOSPITAL-GIT-REALIZATION.yml"
    )
  }
  if (!identical(manifest$realization_instance_id,
                 rrp_hospital_git_realization_id(manifest))) {
    issues[[length(issues) + 1L]] <- rrp_hospital_issue(
      "identity", "git_realization_identity_mismatch",
      "Realization identity does not match its exact distribution and Platform provenance.",
      "HOSPITAL-GIT-REALIZATION.yml#realization_instance_id"
    )
  }
  distribution <- rrp_validate_hospital_distribution(
    root, allow_local_state = FALSE, allow_git_realization = TRUE
  )
  if (!identical(distribution$overall_status, "pass")) {
    issues[[length(issues) + 1L]] <- rrp_hospital_issue(
      "source_distribution", "invalid_realized_hospital_distribution",
      paste(
        "Copied Hospital distribution failed exact validation:",
        paste(distribution$issues$issue_code, collapse = ", ")
      ), "HOSPITAL-DISTRIBUTION.yml"
    )
  }
  if (run_distribution_validator && identical(distribution$overall_status, "pass")) {
    process <- rrp_hospital_run_process(
      file.path(root, "validate-distribution.R"), character(), root
    )
    if (!identical(process$status, 0L)) issues[[length(issues) + 1L]] <-
      rrp_hospital_issue(
        "source_distribution", "artifact_owned_distribution_validation_failed",
        paste(
          "Artifact-owned Hospital validation failed:",
          paste(process$output, collapse = " | ")
        ), "validate-distribution.R"
      )
  }
  prohibited <- tree$files[grepl(
    "(^|/)([.]env($|[.])|[.]Rhistory|[.]RData|credentials?|secrets?|history[.]duckdb)$|[.](pem|key|p12|pfx)$",
    tree$files, ignore.case = TRUE, perl = TRUE
  )]
  if (length(prohibited) > 0L) issues[[length(issues) + 1L]] <-
    rrp_hospital_issue(
      "scope", "prohibited_git_realization_content",
      paste("Realization contains prohibited sensitive or operational content:",
            paste(prohibited, collapse = ", ")), "$"
    )
  text_files <- tree$files[grepl(
    "[.](R|ya?ml|md|json|Rprofile|gitignore|renvignore)$",
    tree$files, ignore.case = TRUE
  )]
  text <- unlist(lapply(file.path(root, text_files), readLines, warn = FALSE),
                 use.names = FALSE)
  machine_pattern <- paste(
    paste0("/", "(Users|home)", "/[^/]+/"),
    "(^|[[:space:]\"'])[A-Za-z]:[/\\\\]", sep = "|"
  )
  sibling_pattern <- paste0("[.][.]/", "readmission-risk-pool", "(/|$)")
  secret_pattern <- paste(
    paste("BEGIN", "(RSA |EC |OPENSSH )?PRIVATE KEY"),
    paste0("AK", "IA[0-9A-Z]{16}"),
    paste0("gh", "[pousr]_[A-Za-z0-9]{20,}"), sep = "|"
  )
  if (any(grepl(machine_pattern, text, perl = TRUE)) ||
      any(grepl(sibling_pattern, text, perl = TRUE)) ||
      any(grepl(secret_pattern, text, perl = TRUE))) {
    issues[[length(issues) + 1L]] <- rrp_hospital_issue(
      "scope", "nonportable_sensitive_or_sibling_content",
      "Realization contains a machine path, sibling dependency, or possible secret.", "$"
    )
  }
  if (check_git) issues <- c(
    issues, rrp_hospital_git_validate_git_state(root, expected_files)
  )
  rrp_hospital_git_result(issues, manifest, distribution)
}
