# Construction of the generated Hospital Implementation artifact and its exact
# proof-only Platform release-candidate archive.

rrp_load_hospital_distribution_runtime <- function(repository_root, envir = parent.frame()) {
  sys.source(file.path(
    repository_root, "distribution", "hospital", "R", "distribution-runtime.R"
  ), envir = envir)
  invisible(TRUE)
}

rrp_hospital_distribution_source_map <- function(repository_root) {
  source_root <- file.path(repository_root, "distribution", "hospital")
  maintained <- list.files(
    source_root, recursive = TRUE, all.files = TRUE, no.. = TRUE,
    include.dirs = FALSE, full.names = FALSE
  )
  maintained <- setdiff(maintained, "templates/gitignore")
  map <- file.path(source_root, maintained)
  names(map) <- maintained
  additions <- c(
    ".gitignore" = file.path(source_root, "templates", "gitignore"),
    ".renvignore" = file.path(repository_root, ".renvignore"),
    ".Rprofile" = file.path(repository_root, ".Rprofile"),
    "LICENSE-STATUS.md" = file.path(repository_root, "LICENSE-STATUS.md"),
    "renv.lock" = file.path(repository_root, "renv.lock"),
    "renv/activate.R" = file.path(repository_root, "renv", "activate.R"),
    "renv/settings.json" = file.path(repository_root, "renv", "settings.json"),
    "contracts/hospital-implementation-distribution.yml" = file.path(
      repository_root, "contracts", "distribution",
      "hospital-implementation-distribution.yml"
    )
  )
  example_root <- file.path(
    repository_root, "tests", "phase10", "fixtures", "adopter-producer"
  )
  example_files <- c(
    "producer.yml", "platform-instance.yml", "source-configuration.yml",
    "source-schema.yml", "R/foundation.R", "R/source-validation.R",
    "R/mapping.R", "R/adapter.R"
  )
  example_map <- file.path(example_root, example_files)
  names(example_map) <- paste0("examples/fictional-adopter/", example_files)
  result <- c(map, additions, example_map)
  result[order(names(result), method = "radix")]
}

rrp_hospital_platform_candidate_files <- function(repository_root) {
  roots <- c(
    "app", "config", "contracts", "deploy", "implementations", "operations",
    "products", "runtime"
  )
  files <- unlist(lapply(roots, function(root) {
    relative <- list.files(
      file.path(repository_root, root), recursive = TRUE, all.files = TRUE,
      no.. = TRUE, include.dirs = FALSE, full.names = FALSE
    )
    file.path(root, relative)
  }), use.names = FALSE)
  root_files <- c(
    ".Rprofile", ".renvignore", "LICENSE-STATUS.md", "README.md", "renv.lock",
    "renv/activate.R", "renv/settings.json"
  )
  excluded <- c(
    "operations/build-hospital-distribution.R",
    "operations/validate-hospital-distribution.R",
    "operations/validate.R",
    "operations/validate-documentation.R",
    "operations/lib/hospital-distribution-operation.R",
    "operations/lib/hospital-distribution-validation.R",
    "operations/lib/platform-validation.R"
  )
  sort(setdiff(unique(c(root_files, files)), excluded), method = "radix")
}

rrp_hospital_validate_lock_baseline <- function(platform_lock, top_level_lock,
                                                maintained_additions = list()) {
  platform_sha <- rrp_hospital_sha256_file(platform_lock)
  top_level_sha <- rrp_hospital_sha256_file(top_level_lock)
  if (length(maintained_additions) > 0L) stop(
    paste(
      "This proof distribution declares no maintained dependency additions;",
      "a general dependency solver or conflicting addition is not permitted."
    ), call. = FALSE
  )
  if (!identical(platform_sha, top_level_sha)) stop(
    "Top-level lock does not exactly preserve the Platform candidate lock.",
    call. = FALSE
  )
  list(
    source_platform_lock_sha256 = platform_sha,
    top_level_lock_sha256 = top_level_sha,
    maintained_dependency_additions = list(),
    lock_relationship = "exact_platform_lock_no_additions"
  )
}

rrp_hospital_copy_regular_file <- function(source, root, relative) {
  destination <- file.path(root, relative)
  dir.create(dirname(destination), recursive = TRUE, showWarnings = FALSE)
  if (!rrp_hospital_safe_relative_path(relative) || !file.exists(source) ||
      dir.exists(source) || nzchar(Sys.readlink(source)) ||
      !isTRUE(file.copy(source, destination, overwrite = FALSE, copy.mode = TRUE))) stop(
    "Could not copy required regular Hospital Implementation input: ", relative,
    call. = FALSE
  )
  invisible(destination)
}

rrp_hospital_inventory <- function(root, paths, role = NULL) {
  paths <- sort(paths, method = "radix")
  lapply(paths, function(path) list(
    path = path,
    role = if (is.function(role)) role(path) else role %||% "platform_source",
    byte_size = as.numeric(file.info(file.path(root, path))$size),
    checksum = list(
      algorithm = "sha256",
      value = rrp_hospital_sha256_file(file.path(root, path))
    )
  ))
}

rrp_hospital_tar_path_fields <- function(path) {
  if (!rrp_hospital_safe_relative_path(path)) stop(
    "Tar member path is unsafe: ", path, call. = FALSE
  )
  if (nchar(path, type = "bytes") <= 100L) return(list(name = path, prefix = ""))
  slash <- gregexpr("/", path, fixed = TRUE)[[1L]]
  slash <- slash[slash > 0L]
  valid <- slash[vapply(slash, function(index) {
    nchar(substr(path, 1L, index - 1L), type = "bytes") <= 155L &&
      nchar(substr(path, index + 1L, nchar(path)), type = "bytes") <= 100L
  }, logical(1))]
  if (length(valid) == 0L) stop(
    "Tar member path exceeds USTAR name/prefix limits: ", path, call. = FALSE
  )
  index <- max(valid)
  list(
    name = substr(path, index + 1L, nchar(path)),
    prefix = substr(path, 1L, index - 1L)
  )
}

rrp_hospital_tar_assign <- function(header, first, last, value) {
  width <- last - first + 1L
  if (length(value) > width) stop("Tar header field overflow.", call. = FALSE)
  header[first:last] <- c(value, rep(as.raw(0L), width - length(value)))
  header
}

rrp_hospital_tar_octal_raw <- function(value, width) {
  digits <- sprintf(paste0("%0", width - 1L, "o"), as.integer(value))
  c(charToRaw(digits), as.raw(0L))
}

rrp_hospital_tar_header <- function(path, size) {
  fields <- rrp_hospital_tar_path_fields(path)
  header <- rep(as.raw(0L), 512L)
  header <- rrp_hospital_tar_assign(header, 1L, 100L, charToRaw(fields$name))
  header <- rrp_hospital_tar_assign(header, 101L, 108L, rrp_hospital_tar_octal_raw(420L, 8L))
  header <- rrp_hospital_tar_assign(header, 109L, 116L, rrp_hospital_tar_octal_raw(0L, 8L))
  header <- rrp_hospital_tar_assign(header, 117L, 124L, rrp_hospital_tar_octal_raw(0L, 8L))
  header <- rrp_hospital_tar_assign(header, 125L, 136L, rrp_hospital_tar_octal_raw(size, 12L))
  header <- rrp_hospital_tar_assign(header, 137L, 148L, rrp_hospital_tar_octal_raw(0L, 12L))
  header[149:156] <- charToRaw("        ")
  header[157L] <- charToRaw("0")
  header <- rrp_hospital_tar_assign(
    header, 258L, 263L, c(charToRaw("ustar"), as.raw(0L))
  )
  header <- rrp_hospital_tar_assign(header, 264L, 265L, charToRaw("00"))
  header <- rrp_hospital_tar_assign(header, 266L, 297L, charToRaw("root"))
  header <- rrp_hospital_tar_assign(header, 298L, 329L, charToRaw("root"))
  header <- rrp_hospital_tar_assign(header, 346L, 500L, charToRaw(fields$prefix))
  checksum <- sum(as.integer(header))
  checksum_raw <- c(charToRaw(sprintf("%06o", checksum)), as.raw(0L), charToRaw(" "))
  header[149:156] <- checksum_raw
  header
}

rrp_hospital_write_tar <- function(root, paths, archive_path) {
  paths <- sort(paths, method = "radix")
  if (anyDuplicated(paths) || !all(vapply(paths, rrp_hospital_safe_relative_path, logical(1)))) {
    stop("Platform candidate tar paths must be unique safe relative paths.", call. = FALSE)
  }
  connection <- file(archive_path, open = "wb")
  on.exit(close(connection), add = TRUE)
  for (path in paths) {
    source <- file.path(root, path)
    if (!file.exists(source) || dir.exists(source) || nzchar(Sys.readlink(source))) stop(
      "Platform candidate tar input is not a regular file: ", path, call. = FALSE
    )
    size <- as.numeric(file.info(source)$size)
    if (size > .Machine$integer.max) stop(
      "Platform candidate member exceeds proof archive size support.", call. = FALSE
    )
    writeBin(rrp_hospital_tar_header(path, size), connection, useBytes = TRUE)
    input <- file(source, open = "rb")
    content <- readBin(input, "raw", n = as.integer(size))
    close(input)
    writeBin(content, connection, useBytes = TRUE)
    padding <- (512L - (as.integer(size) %% 512L)) %% 512L
    if (padding > 0L) writeBin(rep(as.raw(0L), padding), connection, useBytes = TRUE)
  }
  writeBin(rep(as.raw(0L), 1024L), connection, useBytes = TRUE)
  invisible(archive_path)
}

rrp_build_platform_release_candidate <- function(repository_root, staging_root) {
  source_files <- rrp_hospital_platform_candidate_files(repository_root)
  missing <- source_files[!file.exists(file.path(repository_root, source_files))]
  if (length(missing) > 0L) stop(
    "Platform candidate source is missing: ", paste(missing, collapse = ", "),
    call. = FALSE
  )
  candidate_root <- tempfile("rrp-platform-candidate-")
  dir.create(candidate_root)
  on.exit(unlink(candidate_root, recursive = TRUE, force = TRUE), add = TRUE)
  for (path in source_files) rrp_hospital_copy_regular_file(
    file.path(repository_root, path), candidate_root, path
  )
  inventory <- rrp_hospital_inventory(candidate_root, source_files, "platform_source")
  paths <- vapply(inventory, `[[`, character(1), "path")
  records <- vapply(inventory[order(paths, method = "radix")], function(item) paste(
    item$path, item$byte_size, item$checksum$value, sep = "|"
  ), character(1))
  platform_identity <- list(
    platform_id = "readmission-risk-pool-platform",
    platform_version = "0.0.0-proof.11.4"
  )
  instance_id <- paste0(
    "platform_release_candidate::",
    rrp_hospital_sha256_string(paste(c(
      platform_identity$platform_id, platform_identity$platform_version, records
    ), collapse = "\n"))
  )
  manifest <- list(
    manifest_kind = "platform_release_candidate_manifest",
    manifest_version = "0.1.0",
    platform_identity = platform_identity,
    candidate_instance_id = instance_id,
    candidate_status = "proof_only_not_published_not_v0.1.0",
    source_provenance = list(
      kind = "validated_allowlisted_working_tree_candidate",
      git_identity_is_semantic = FALSE,
      public_release = FALSE
    ),
    inventory = inventory,
    environment = list(
      r_version = jsonlite::read_json(
        file.path(repository_root, "renv.lock"), simplifyVector = FALSE
      )$R$Version,
      platform_lock_sha256 = rrp_hospital_sha256_file(file.path(
        repository_root, "renv.lock"
      ))
    ),
    compatibility = list(
      hospital_distribution_specification = rrp_hospital_distribution_specification(),
      exact_inclusion_required = TRUE
    ),
    nonclaims = list(
      "not a published Platform release",
      "not Platform v0.1.0",
      "not clinically validated or production authorized"
    )
  )
  rrp_hospital_write_yaml(manifest, file.path(candidate_root, "PLATFORM-CANDIDATE.yml"))
  archive_name <- "readmission-risk-pool-platform-candidate-11.4.tar"
  archive_path <- file.path(staging_root, "platform", archive_name)
  dir.create(dirname(archive_path), recursive = TRUE, showWarnings = FALSE)
  rrp_hospital_write_tar(
    candidate_root, c("PLATFORM-CANDIDATE.yml", source_files), archive_path
  )
  validation <- rrp_hospital_validate_platform_candidate_archive(
    archive_path, platform_identity
  )
  if (nrow(validation$issues) > 0L) stop(
    "Constructed Platform candidate archive is invalid: ",
    paste(paste0(
      validation$issues$issue_code, " (", validation$issues$message, ")"
    ), collapse = ", "), call. = FALSE
  )
  list(
    archive_path = archive_path,
    archive_filename = archive_name,
    archive_byte_size = as.numeric(file.info(archive_path)$size),
    archive_sha256 = rrp_hospital_sha256_file(archive_path),
    manifest = manifest
  )
}

rrp_hospital_distribution_role <- function(path) {
  if (startsWith(path, "platform/")) return("embedded_platform_candidate")
  if (startsWith(path, "contracts/")) return("distribution_contract")
  if (startsWith(path, "implementation/")) return("editable_producer_scaffold")
  if (startsWith(path, "examples/")) return("fictional_adopter_example")
  if (startsWith(path, "operations/")) return("hospital_operation")
  if (startsWith(path, "renv/") || path %in% c("renv.lock", ".Rprofile")) {
    return("top_level_environment")
  }
  if (startsWith(path, "R/")) return("distribution_runtime")
  "hospital_distribution_document"
}

rrp_hospital_trees_identical <- function(left, right) {
  left_tree <- rrp_hospital_scan_tree(left, allow_local_state = FALSE)
  right_tree <- rrp_hospital_scan_tree(right, allow_local_state = FALSE)
  identical(left_tree$files, right_tree$files) &&
    length(left_tree$symlinks) == 0L && length(right_tree$symlinks) == 0L &&
    all(vapply(left_tree$files, function(path) identical(
      rrp_hospital_sha256_file(file.path(left, path)),
      rrp_hospital_sha256_file(file.path(right, path))
    ), logical(1)))
}

rrp_resolve_hospital_distribution <- function(store_or_distribution) {
  candidate <- normalizePath(store_or_distribution, mustWork = FALSE)
  if (!dir.exists(candidate) || nzchar(Sys.readlink(candidate))) stop(
    "Hospital distribution path does not exist or is a symbolic link.", call. = FALSE
  )
  if (file.exists(file.path(candidate, "HOSPITAL-DISTRIBUTION.yml"))) return(candidate)
  pointer_path <- file.path(candidate, "CURRENT.yml")
  if (!file.exists(pointer_path) || nzchar(Sys.readlink(pointer_path))) stop(
    "Hospital distribution store has no regular CURRENT.yml pointer.", call. = FALSE
  )
  pointer <- rrp_hospital_read_yaml(pointer_path)
  valid <- is.list(pointer) &&
    identical(pointer$pointer_kind, "current_hospital_distribution_pointer") &&
    identical(pointer$pointer_version, "0.1.0") &&
    identical(pointer$distribution_specification,
              rrp_hospital_distribution_specification()) &&
    is.character(pointer$distribution_directory) &&
    grepl("^distributions/distribution-[a-f0-9]{64}$", pointer$distribution_directory)
  if (!valid) stop("Hospital distribution CURRENT.yml is invalid or unsafe.", call. = FALSE)
  root <- file.path(candidate, pointer$distribution_directory)
  manifest <- file.path(root, "HOSPITAL-DISTRIBUTION.yml")
  if (!dir.exists(root) || nzchar(Sys.readlink(root)) || !file.exists(manifest) ||
      !identical(pointer$manifest_sha256, rrp_hospital_sha256_file(manifest))) stop(
    "Current Hospital distribution pointer integrity is invalid.", call. = FALSE
  )
  root
}

rrp_build_hospital_distribution <- function(
  repository_root,
  distribution_store,
  built_at = rrp_hospital_now()
) {
  repository_root <- normalizePath(repository_root, mustWork = TRUE)
  distribution_store <- normalizePath(distribution_store, mustWork = FALSE)
  if (!rrp_hospital_timestamp(built_at)) stop(
    "Hospital distribution build time must be an RFC 3339 timestamp.", call. = FALSE
  )
  contract_path <- file.path(
    repository_root, "contracts", "distribution",
    "hospital-implementation-distribution.yml"
  )
  contract <- rrp_parse_yaml_specification(contract_path)
  if (!is.null(contract$parse_error)) stop(
    "Hospital distribution contract is not readable YAML: ",
    contract$parse_error, call. = FALSE
  )
  contract_validation <- rrp_validate_specification_envelope(
    contract$document, "contracts/distribution/hospital-implementation-distribution.yml"
  )
  if (!rrp_conforms(contract_validation) ||
      !identical(contract$document[c(
        "specification_kind", "specification_id", "specification_version"
      )], rrp_hospital_distribution_specification())) stop(
    "Hospital distribution contract envelope or identity is invalid.", call. = FALSE
  )
  source_map <- rrp_hospital_distribution_source_map(repository_root)
  if (anyDuplicated(names(source_map)) ||
      !all(vapply(names(source_map), rrp_hospital_safe_relative_path, logical(1))) ||
      !all(file.exists(unname(source_map))) ||
      any(vapply(unname(source_map), function(path) {
        dir.exists(path) || nzchar(Sys.readlink(path))
      }, logical(1)))) stop(
    "Maintained Hospital Implementation source allowlist is incomplete or unsafe.",
    call. = FALSE
  )
  if (file.exists(distribution_store) && !dir.exists(distribution_store)) stop(
    "Hospital distribution store exists and is not a directory.", call. = FALSE
  )
  dir.create(
    file.path(distribution_store, "distributions"),
    recursive = TRUE, showWarnings = FALSE
  )
  if (!dir.exists(distribution_store) || nzchar(Sys.readlink(distribution_store)) ||
      nzchar(Sys.readlink(file.path(distribution_store, "distributions")))) stop(
    "Hospital distribution store must use regular local directories.", call. = FALSE
  )
  staging <- tempfile(".staging-", tmpdir = file.path(
    distribution_store, "distributions"
  ))
  dir.create(staging)
  on.exit(if (dir.exists(staging)) unlink(staging, recursive = TRUE, force = TRUE), add = TRUE)
  for (relative in names(source_map)) rrp_hospital_copy_regular_file(
    unname(source_map[[relative]]), staging, relative
  )
  platform <- rrp_build_platform_release_candidate(repository_root, staging)
  payload_paths <- rrp_hospital_scan_tree(staging, allow_local_state = FALSE)$files
  inventory <- rrp_hospital_inventory(
    staging, payload_paths, rrp_hospital_distribution_role
  )
  platform_manifest <- platform$manifest
  lock_baseline <- rrp_hospital_validate_lock_baseline(
    file.path(repository_root, "renv.lock"), file.path(staging, "renv.lock")
  )
  manifest <- list(
    manifest_kind = "hospital_implementation_distribution_manifest",
    manifest_version = "0.1.0",
    distribution_specification = rrp_hospital_distribution_specification(),
    hospital_implementation = list(
      release_id = "readmission-risk-pool-hospital-implementation",
      release_version = "0.0.0-proof.11.4",
      release_status = "proof_only_not_published"
    ),
    distribution_instance_id = "pending",
    distribution_build_id = "pending",
    built_at = built_at,
    platform_candidate = list(
      platform_id = platform_manifest$platform_identity$platform_id,
      platform_version = platform_manifest$platform_identity$platform_version,
      candidate_instance_id = platform_manifest$candidate_instance_id,
      candidate_status = platform_manifest$candidate_status,
      archive_filename = platform$archive_filename,
      archive_byte_size = platform$archive_byte_size,
      archive_sha256 = platform$archive_sha256,
      archive_inventory_member_count = length(platform_manifest$inventory),
      public_release = FALSE
    ),
    compatibility = list(
      platform_inclusion = "exact_candidate_only",
      canonical_producer = list(
        specification_id = "platform.canonical-producer",
        specification_version = "0.1.0"
      ),
      reduced_application_artifact = list(
        specification_id = "platform.reduced-application-artifact",
        specification_version = "0.1.0"
      )
    ),
    builder = list(
      builder_id = "platform.hospital-implementation-distribution-builder",
      builder_version = "0.1.0",
      operation_id = "platform.build-hospital-distribution"
    ),
    environment = list(
      active_project = "hospital_implementation_root",
      declared_r_version = platform_manifest$environment$r_version,
      source_platform_lock_sha256 = lock_baseline$source_platform_lock_sha256,
      maintained_dependency_additions = lock_baseline$maintained_dependency_additions,
      top_level_lock_sha256 = lock_baseline$top_level_lock_sha256,
      lock_relationship = lock_baseline$lock_relationship,
      nested_platform_activation = "not_used",
      validation_environment = paste(R.version$platform, getRversion(), sep = "@")
    ),
    required_files = as.list(sort(payload_paths, method = "radix")),
    inventory = inventory,
    integrity = list(
      algorithm = "sha256",
      manifest_checksum_file = "HOSPITAL-DISTRIBUTION.sha256"
    ),
    validation_evidence = c(rrp_hospital_validator_reference(), list(status = "passed")),
    data_classification = "fictional_nonclinical",
    validation_status = "passed",
    nonclaims = list(
      "not a public Platform or Hospital Implementation release",
      "not a license grant",
      "not a clinical or production-ready implementation",
      "not a deployment or publication",
      "not a guarantee for recipient-modified content"
    )
  )
  manifest$distribution_instance_id <- rrp_hospital_distribution_instance_id(manifest)
  manifest$distribution_build_id <- rrp_hospital_distribution_build_id(
    manifest$distribution_instance_id, built_at
  )
  rrp_hospital_write_yaml(manifest, file.path(staging, "HOSPITAL-DISTRIBUTION.yml"))
  writeLines(
    rrp_hospital_sha256_file(file.path(staging, "HOSPITAL-DISTRIBUTION.yml")),
    file.path(staging, "HOSPITAL-DISTRIBUTION.sha256"), useBytes = TRUE
  )
  staged <- rrp_validate_hospital_distribution(staging, allow_local_state = FALSE)
  if (!identical(staged$overall_status, "pass")) stop(
    "Staged Hospital Implementation distribution failed validation: ",
    paste(paste0(staged$issues$issue_code, " (", staged$issues$message, ")"),
          collapse = "; "), call. = FALSE
  )
  final_name <- paste0(
    "distribution-", sub("^.*::", "", manifest$distribution_build_id)
  )
  final <- file.path(distribution_store, "distributions", final_name)
  idempotent <- FALSE
  if (dir.exists(final)) {
    if (!rrp_hospital_trees_identical(staging, final)) stop(
      "Existing immutable Hospital distribution conflicts with staged content.",
      call. = FALSE
    )
    unlink(staging, recursive = TRUE, force = TRUE)
    idempotent <- TRUE
  } else if (!file.rename(staging, final)) stop(
    "Could not atomically promote the Hospital Implementation distribution.",
    call. = FALSE
  )
  promoted <- rrp_validate_hospital_distribution(final, allow_local_state = FALSE)
  if (!identical(promoted$overall_status, "pass")) stop(
    "Promoted Hospital Implementation distribution failed validation.", call. = FALSE
  )
  independent <- rrp_hospital_run_process(
    file.path(final, "validate-distribution.R"), character(), final
  )
  if (!identical(independent$status, 0L)) stop(
    "Promoted Hospital Implementation failed artifact-owned validation: ",
    paste(independent$output, collapse = " | "), call. = FALSE
  )
  current <- list(
    pointer_kind = "current_hospital_distribution_pointer",
    pointer_version = "0.1.0",
    distribution_specification = rrp_hospital_distribution_specification(),
    distribution_instance_id = manifest$distribution_instance_id,
    distribution_build_id = manifest$distribution_build_id,
    distribution_directory = paste0("distributions/", final_name),
    manifest_sha256 = rrp_hospital_sha256_file(file.path(
      final, "HOSPITAL-DISTRIBUTION.yml"
    )),
    exposed_at = built_at
  )
  pointer_staging <- tempfile(".CURRENT-", tmpdir = distribution_store, fileext = ".yml")
  on.exit(if (file.exists(pointer_staging)) unlink(pointer_staging, force = TRUE), add = TRUE)
  rrp_hospital_write_yaml(current, pointer_staging)
  pointer <- file.path(distribution_store, "CURRENT.yml")
  if (!file.rename(pointer_staging, pointer)) stop(
    "Could not atomically expose the current Hospital distribution.", call. = FALSE
  )
  list(
    overall_status = "succeeded",
    distribution_store = distribution_store,
    distribution_path = final,
    distribution_instance_id = manifest$distribution_instance_id,
    distribution_build_id = manifest$distribution_build_id,
    platform_candidate_instance_id = platform_manifest$candidate_instance_id,
    platform_archive_sha256 = platform$archive_sha256,
    idempotent = idempotent,
    validation = promoted
  )
}

rrp_validate_completed_hospital_distribution <- function(store_or_distribution) {
  root <- rrp_resolve_hospital_distribution(store_or_distribution)
  result <- rrp_hospital_run_process(
    file.path(root, "validate-distribution.R"), character(), root
  )
  list(
    overall_status = if (identical(result$status, 0L)) "pass" else "fail",
    distribution_path = root,
    process_status = result$status,
    output = result$output
  )
}
