#!/usr/bin/env Rscript

script_argument <- grep("^--file=", commandArgs(trailingOnly = FALSE), value = TRUE)
if (length(script_argument) != 1L) stop("Cannot determine validation script path.", call. = FALSE)
script_path <- normalizePath(sub("^--file=", "", script_argument), mustWork = TRUE)
repository_root <- normalizePath(file.path(dirname(script_path), ".."), mustWork = TRUE)
source(file.path(repository_root, "tools", "distribution-lib.R"), local = TRUE)
source(file.path(repository_root, "distribution", "verify-distribution.R"), local = TRUE)

require_true <- function(value, message) {
  if (!isTRUE(value)) stop(message, call. = FALSE)
}

expect_failure <- function(label, expression, pattern = NULL) {
  condition <- tryCatch({ force(expression); NULL }, error = identity)
  require_true(inherits(condition, "error"), paste(label, "did not fail."))
  if (!is.null(pattern)) require_true(
    grepl(pattern, conditionMessage(condition), fixed = TRUE),
    paste(label, "failed for the wrong reason:", conditionMessage(condition))
  )
}

copy_tree <- function(source, parent, name) {
  destination <- file.path(parent, name)
  dir.create(destination)
  entries <- list.files(source, all.files = TRUE, full.names = TRUE, no.. = TRUE)
  require_true(all(file.copy(entries, destination, recursive = TRUE,
                             copy.mode = TRUE, copy.date = FALSE)),
               paste("Could not copy", name))
  destination
}

rewrite_payload <- function(root, mutate_inventory = NULL, mutate_dependency = NULL) {
  inventory_path <- file.path(root, "inventory.dcf")
  inventory <- distribution_read_dcf(inventory_path)
  new_distribution_id <- NULL
  if (!is.null(mutate_dependency)) {
    dependency_path <- file.path(root, "dependencies", "dependencies.dcf")
    dependency <- distribution_read_dcf(dependency_path)
    dependency <- mutate_dependency(dependency)
    distribution_write_dcf(dependency, dependency_path)
    paths <- vapply(inventory[-1L], `[[`, character(1L), "Path")
    index <- which(paths == "dependencies/dependencies.dcf") + 1L
    inventory[[index]][["Size"]] <- as.character(file.info(dependency_path)$size)
    inventory[[index]][["SHA256"]] <- distribution_sha256(dependency_path)
    identity_path <- file.path(root, "identity.txt")
    identity <- readLines(identity_path, warn = FALSE)
    identity[[length(identity)]] <- paste0(
      "dependency-specification=", distribution_sha256(dependency_path)
    )
    writeLines(identity, identity_path, useBytes = TRUE)
    identity_index <- which(paths == "identity.txt") + 1L
    inventory[[identity_index]][["Size"]] <- as.character(file.info(identity_path)$size)
    inventory[[identity_index]][["SHA256"]] <- distribution_sha256(identity_path)
    new_distribution_id <- distribution_sha256(identity_path)
    inventory[[1L]][["Distribution-ID"]] <- new_distribution_id
  }
  if (!is.null(mutate_inventory)) inventory <- mutate_inventory(inventory)
  inventory[[1L]][["File-Count"]] <- as.character(length(inventory) - 1L)
  distribution_write_dcf(inventory, inventory_path)
  manifest_path <- file.path(root, "manifest.dcf")
  manifest <- distribution_read_dcf(manifest_path)
  if (!is.null(new_distribution_id)) {
    manifest[[1L]][["Distribution-ID"]] <- new_distribution_id
  }
  manifest[[1L]][["Inventory-Digest"]] <- distribution_sha256(inventory_path)
  distribution_write_dcf(manifest, manifest_path)
}

run_builder <- function(
  output,
  repository = Sys.getenv(
    "RRP_CRAN_REPOSITORY", unset = "https://cloud.r-project.org"
  ),
  provenance = Sys.getenv("RRP_DEPENDENCY_PROVENANCE", unset = ""),
  source_root = repository_root,
  candidate_family = NULL
) {
  arguments <- c(
    "--vanilla", file.path(source_root, "tools", "build-distribution.R")
  )
  if (!is.null(candidate_family)) arguments <- c(
    arguments, "--qualification-candidate", candidate_family
  )
  arguments <- c(arguments, output)
  result <- suppressWarnings(system2(
    file.path(R.home("bin"), "Rscript"),
    arguments,
    stdout = TRUE, stderr = TRUE,
    env = c(paste0("RRP_CRAN_REPOSITORY=", repository),
            paste0("RRP_DEPENDENCY_PROVENANCE=", provenance),
            "R_PROFILE_USER=", "R_ENVIRON_USER=")
  ))
  list(output = result, status = if (is.null(attr(result, "status"))) 0L else attr(result, "status"))
}

validate_distribution <- function() {
  work <- tempfile("rrp-distribution-validation-")
  dir.create(work)
  on.exit(unlink(work, recursive = TRUE, force = TRUE), add = TRUE)
  first_archive <- file.path(work, "first.tar")
  second_archive <- file.path(work, "second.tar")

  authority <- distribution_source_authority(repository_root)
  resources <- distribution_resource_authority(repository_root)
  require_true(length(authority$packages) == 2L && length(resources$entries) == 76L,
               "Positive source/resource authorities are incomplete.")
  cat("PASS positive source inclusion and 76-resource closure\n")

  source_fixture <- file.path(work, "source-fixture")
  dir.create(source_fixture)
  fixture_paths <- unique(c(authority$source_paths, "distribution/source-inclusion.dcf"))
  for (path in fixture_paths) {
    distribution_copy(file.path(repository_root, path), file.path(source_fixture, path))
  }
  distribution_source_authority(source_fixture)
  undeclared <- copy_tree(source_fixture, work, "source-undeclared")
  writeLines("undeclared <- TRUE", file.path(undeclared, "packages/rrpruntime/R/undeclared.R"))
  expect_failure("undeclared package source", distribution_source_authority(undeclared),
                 "Declared package source differs")
  excluded <- copy_tree(source_fixture, work, "source-excluded-test")
  dir.create(file.path(excluded, "packages/rrpruntime/tests"))
  writeLines("development only", file.path(excluded, "packages/rrpruntime/tests/new.R"))
  distribution_source_authority(excluded)
  absent <- copy_tree(source_fixture, work, "source-absent")
  unlink(file.path(absent, "packages/rrpruntime/R/history.R"))
  expect_failure("missing package source", distribution_source_authority(absent),
                 "Declared package source differs")
  unsafe_authority <- copy_tree(source_fixture, work, "source-unsafe-authority")
  authority_path <- file.path(unsafe_authority, "distribution/source-inclusion.dcf")
  lines <- readLines(authority_path, warn = FALSE)
  lines[which(lines == "Destination-Path: LICENSE")[[1L]]] <- "Destination-Path: ../LICENSE"
  writeLines(lines, authority_path)
  expect_failure("unsafe source destination", distribution_source_authority(unsafe_authority),
                 "Direct payload record is invalid")
  duplicate_authority <- copy_tree(source_fixture, work, "source-duplicate-authority")
  authority_path <- file.path(duplicate_authority, "distribution/source-inclusion.dcf")
  lines <- readLines(authority_path, warn = FALSE)
  lines[which(lines == "Destination-Path: NOTICE")[[1L]]] <- "Destination-Path: LICENSE"
  writeLines(lines, authority_path)
  expect_failure("duplicate source destination", distribution_source_authority(duplicate_authority),
                 "destinations conflict")
  cat("PASS missing/undeclared/excluded/unsafe/duplicate source-authority evidence\n")

  target <- c(
    "Target-R-Version" = as.character(getRversion()),
    "Target-Platform" = R.version$platform,
    "Target-Architecture" = R.version$arch
  )
  development_artifact <- distribution_artifact_record(
    "development", "development-local", target,
    list(revision = "unavailable", state = "unavailable")
  )
  distribution_validate_artifact_record(development_artifact)
  expect_failure(
    "reserved official release state",
    distribution_artifact_record(
      "official_release", "", target,
      list(revision = paste(rep("a", 40L), collapse = ""), state = "clean")
    ),
    "Artifact state is unsupported"
  )
  families <- distribution_candidate_families()
  host_family <- names(families)[vapply(families, function(value) {
    identical(
      unname(target[c("Target-Platform", "Target-Architecture")]),
      unname(value)
    )
  }, logical(1L))]
  require_true(length(host_family) == 1L,
    "Distribution validation host is outside the accepted candidate families.")

  clean_source <- file.path(work, "clean-candidate-source")
  dir.create(clean_source)
  source_entries <- list.files(
    repository_root, all.files = TRUE, full.names = TRUE, no.. = TRUE
  )
  source_entries <- source_entries[basename(source_entries) != ".git"]
  require_true(all(file.copy(
    source_entries, clean_source, recursive = TRUE,
    copy.mode = TRUE, copy.date = FALSE
  )), "Could not construct clean candidate-source fixture.")
  git_run <- function(arguments) {
    result <- suppressWarnings(system2(
      "git", c("-C", clean_source, arguments), stdout = TRUE, stderr = TRUE
    ))
    status <- attr(result, "status")
    require_true(is.null(status) || status == 0L, paste(result, collapse = "\n"))
    result
  }
  git_run(c("init", "-q"))
  git_run(c("add", "--all"))
  git_run(c(
    "-c", "user.name=RRP-Validation", "-c",
    "user.email=validation@example.invalid", "commit", "-q", "-m",
    "candidate-contract-fixture"
  ))
  candidate_directory <- file.path(work, "candidate-output")
  dir.create(candidate_directory)
  candidate_name <- paste0(
    "rrp-1.0.0-candidate-", host_family, ".tar"
  )
  candidate_archive <- file.path(candidate_directory, candidate_name)
  candidate_build <- run_builder(
    candidate_archive, source_root = clean_source,
    candidate_family = host_family
  )
  require_true(
    candidate_build$status == 0L, paste(candidate_build$output, collapse = "\n")
  )
  candidate_evidence_path <- paste0(candidate_archive, ".evidence.dcf")
  require_true(file.exists(candidate_evidence_path),
    "Qualification candidate evidence sidecar is absent.")
  candidate_extract <- file.path(work, "candidate-extract")
  dir.create(candidate_extract)
  utils::untar(candidate_archive, exdir = candidate_extract)
  candidate_root <- file.path(
    candidate_extract, sub("[.]tar$", "", candidate_name)
  )
  candidate_verified <- rrp_verify_distribution(candidate_root)
  candidate_evidence <- distribution_read_dcf(candidate_evidence_path)[[1L]]
  require_true(
    identical(candidate_verified$artifact[["Artifact-State"]],
      "qualification_candidate") &&
      identical(candidate_verified$artifact[["Target-Family"]], host_family) &&
      identical(candidate_verified$artifact[["Qualification-Status"]],
        "pending_external_evidence") &&
      identical(candidate_evidence[["Archive-SHA256"]],
        distribution_sha256(candidate_archive)) &&
      identical(candidate_evidence[["Distribution-ID"]],
        candidate_verified$manifest[["Distribution-ID"]]),
    "Qualification candidate identity or archive evidence is inconsistent."
  )
  other_family <- setdiff(names(families), host_family)
  other_evidence <- candidate_evidence
  other_base <- paste0("rrp-1.0.0-candidate-", other_family)
  other_evidence[["Target-Family"]] <- other_family
  other_evidence[["Archive-Name"]] <- paste0(other_base, ".tar")
  other_evidence[["Extraction-Root"]] <- other_base
  other_evidence[["Archive-SHA256"]] <- paste(rep("b", 64L), collapse = "")
  other_evidence[["Distribution-ID"]] <- paste(rep("c", 64L), collapse = "")
  other_evidence[["Build-ID"]] <- paste(rep("d", 64L), collapse = "")
  other_evidence[["Dependency-Specification-ID"]] <-
    paste(rep("e", 64L), collapse = "")
  other_evidence[["Target-Platform"]] <- families[[other_family]][["platform"]]
  other_evidence[["Target-Architecture"]] <-
    families[[other_family]][["architecture"]]
  candidate_set <- distribution_candidate_set_evidence(list(
    candidate_evidence, other_evidence
  ))
  require_true(
    length(candidate_set) == 3L &&
      identical(candidate_set[[1L]][["Artifact-Count"]], "2") &&
      identical(candidate_set[[1L]][["Qualification-Status"]],
        "pending_external_evidence"),
    "Cross-target candidate-set evidence is invalid."
  )
  mismatched_set <- list(candidate_evidence, other_evidence)
  mismatched_set[[2L]][["Source-Revision"]] <- paste(rep("f", 40L), collapse = "")
  expect_failure(
    "candidate-set source mismatch",
    distribution_candidate_set_evidence(mismatched_set),
    "do not form one source-consistent"
  )
  mismatched_target <- list(candidate_evidence, other_evidence)
  mismatched_target[[2L]][["Target-Platform"]] <- "wrong-platform"
  expect_failure(
    "candidate-set target mismatch",
    distribution_candidate_set_evidence(mismatched_target),
    "do not form one source-consistent"
  )
  mismatched_name <- list(candidate_evidence, other_evidence)
  mismatched_name[[2L]][["Archive-Name"]] <- "wrong-candidate.tar"
  expect_failure(
    "candidate-set archive-name mismatch",
    distribution_candidate_set_evidence(mismatched_name),
    "do not form one source-consistent"
  )
  mismatched_identity <- list(candidate_evidence, other_evidence)
  for (i in seq_along(mismatched_identity)) {
    mismatched_identity[[i]][["Candidate-Set-ID"]] <-
      paste(rep("9", 64L), collapse = "")
  }
  expect_failure(
    "candidate-set derived identity mismatch",
    distribution_candidate_set_evidence(mismatched_identity),
    "do not form one source-consistent"
  )
  write("dirty", file.path(clean_source, "README.md"), append = TRUE)
  dirty_directory <- file.path(work, "dirty-candidate-output")
  dir.create(dirty_directory)
  dirty_archive <- file.path(dirty_directory, candidate_name)
  dirty_build <- run_builder(
    dirty_archive, source_root = clean_source,
    candidate_family = host_family
  )
  require_true(
    dirty_build$status != 0L && !file.exists(dirty_archive) &&
      !file.exists(paste0(dirty_archive, ".evidence.dcf")) &&
      grepl("candidate_source_state", paste(dirty_build$output, collapse = " ")),
    "Dirty candidate source did not fail closed before output."
  )
  cat(paste0(
    "PASS clean unpublished candidate build, exact family/root/name, archive ",
    "evidence, cross-target set contract, reserved release state, and dirty-source rejection\n"
  ))

  first <- run_builder(first_archive)
  second <- run_builder(second_archive)
  require_true(first$status == 0L, paste(first$output, collapse = "\n"))
  require_true(second$status == 0L, paste(second$output, collapse = "\n"))
  extract_first <- file.path(work, "extract-first")
  extract_second <- file.path(work, "extract-second")
  dir.create(extract_first); dir.create(extract_second)
  utils::untar(first_archive, exdir = extract_first)
  utils::untar(second_archive, exdir = extract_second)
  root <- file.path(extract_first, "rrp-1.0.0-dev")
  root_second <- file.path(extract_second, "rrp-1.0.0-dev")
  verified <- rrp_verify_distribution(root)
  verified_second <- rrp_verify_distribution(root_second)

  substituted_resource <- copy_tree(root, work, "substituted-resource")
  catalog_path <- file.path(substituted_resource, "resources", "resource-catalog.dcf")
  catalog <- distribution_read_dcf(catalog_path)
  resource_index <- which(vapply(
    catalog,
    function(record) identical(
      record[["Resource-ID"]], "rrp.application.portable-core"
    ),
    logical(1L)
  ))
  require_true(length(resource_index) == 1L,
               "Portable application resource fixture is incomplete.")
  catalog[[resource_index]][["Resource-ID"]] <- "rrp.application.unexpected"
  distribution_write_dcf(catalog, catalog_path)
  rewrite_payload(substituted_resource, mutate_inventory = function(records) {
    paths <- vapply(records[-1L], `[[`, character(1L), "Path")
    index <- which(paths == "resources/resource-catalog.dcf") + 1L
    records[[index]][["Size"]] <- as.character(file.info(catalog_path)$size)
    records[[index]][["SHA256"]] <- distribution_sha256(catalog_path)
    records
  })
  expect_failure(
    "substituted portable application resource",
    rrp_verify_distribution(substituted_resource),
    "Required portable application resources are absent or relocated"
  )

  dependency <- distribution_read_dcf(file.path(root, "dependencies", "dependencies.dcf"))
  dependency_header <- dependency[[1L]]
  dependency_packages <- dependency[-1L]
  provenance_snapshot <- list(
    target = vapply(
      dependency_header[c(
        "Target-R-Version", "Target-Platform", "Target-Architecture"
      )],
      `[[`, character(1L), 1L
    ),
    package_records = lapply(dependency_packages, function(record) {
      record[setdiff(names(record), "Repository")]
    }),
    installed_repository = setNames(
      rep("", length(dependency_packages)),
      vapply(dependency_packages, `[[`, character(1L), "Package")
    )
  )
  repository <- dependency_packages[[1L]][["Repository"]]
  receipt <- file.path(work, "controlled-provenance.dcf")
  distribution_write_dcf(
    distribution_dependency_provenance_records(provenance_snapshot, repository),
    receipt
  )
  require_true(
    identical(
      distribution_validate_dependency_provenance(
        provenance_snapshot, repository, receipt
      ),
      "controlled-provisioning-receipt"
    ),
    "Controlled provisioning receipt did not establish closure provenance."
  )
  canonical_repository <- "https://cloud.r-project.org"
  expect_failure(
    "missing provenance for unannotated installed package",
    distribution_validate_dependency_provenance(
      provenance_snapshot, canonical_repository, ""
    ),
    "no accepted installed-package provenance"
  )
  rspm_snapshot <- provenance_snapshot
  rspm_snapshot$installed_repository[] <- "RSPM"
  expect_failure(
    "untrusted installed repository label",
    distribution_validate_dependency_provenance(
      rspm_snapshot, canonical_repository, ""
    ),
    "no accepted installed-package provenance"
  )
  cran_snapshot <- provenance_snapshot
  cran_snapshot$installed_repository[] <- "CRAN"
  expect_failure(
    "unproven configured repository",
    distribution_validate_dependency_provenance(
      cran_snapshot, "https://packages.example.invalid", ""
    ),
    "requires a controlled provisioning receipt"
  )
  expect_failure(
    "missing configured provenance receipt",
    distribution_validate_dependency_provenance(
      provenance_snapshot, repository,
      file.path(work, "absent-provenance-receipt.dcf")
    ),
    "missing, linked, or nonregular"
  )
  malformed_receipt <- file.path(work, "malformed-provenance-receipt.dcf")
  writeLines("this is not DCF", malformed_receipt, useBytes = TRUE)
  expect_failure(
    "malformed configured provenance receipt",
    distribution_validate_dependency_provenance(
      provenance_snapshot, repository, malformed_receipt
    ),
    "Cannot parse"
  )
  mutate_receipt <- function(name, mutate) {
    path <- file.path(work, paste0(name, ".dcf"))
    records <- distribution_dependency_provenance_records(
      provenance_snapshot, repository
    )
    distribution_write_dcf(mutate(records), path)
    path
  }
  wrong_repository <- mutate_receipt("wrong-provenance-repository", function(records) {
    records[[1L]][["Repository"]] <- "https://untrusted.example.invalid"
    records
  })
  expect_failure(
    "provenance repository mismatch",
    distribution_validate_dependency_provenance(
      provenance_snapshot, repository, wrong_repository
    ),
    "header, target, or repository disagrees"
  )
  wrong_target <- mutate_receipt("wrong-provenance-target", function(records) {
    records[[1L]][["Target-Platform"]] <- "wrong-platform"
    records
  })
  expect_failure(
    "provenance target mismatch",
    distribution_validate_dependency_provenance(
      provenance_snapshot, repository, wrong_target
    ),
    "header, target, or repository disagrees"
  )
  wrong_version <- mutate_receipt("wrong-provenance-version", function(records) {
    records[[2L]][["Version"]] <- "0.0.0"
    records
  })
  expect_failure(
    "provenance version mismatch",
    distribution_validate_dependency_provenance(
      provenance_snapshot, repository, wrong_version
    ),
    "Provisioning receipt disagrees"
  )
  wrong_integrity <- mutate_receipt("wrong-provenance-integrity", function(records) {
    records[[2L]][["Integrity"]] <- paste0("renv:", paste(rep("0", 32L), collapse = ""))
    records
  })
  expect_failure(
    "provenance integrity mismatch",
    distribution_validate_dependency_provenance(
      provenance_snapshot, repository, wrong_integrity
    ),
    "Provisioning receipt disagrees"
  )
  missing_package <- mutate_receipt("missing-provenance-package", function(records) {
    records[-length(records)]
  })
  expect_failure(
    "provenance closure mismatch",
    distribution_validate_dependency_provenance(
      provenance_snapshot, repository, missing_package
    ),
    "records or count disagree"
  )
  cat("PASS installed-metadata/controlled-receipt provenance and adversarial evidence\n")

  reversed_authority <- authority
  reversed_authority$source_paths <- rev(reversed_authority$source_paths)
  reversed_resources <- resources
  reversed_resources$source_paths <- rev(reversed_resources$source_paths)
  reordered_identity <- distribution_source_identity(
    reversed_authority, reversed_resources, repository_root,
    file.path(root, "dependencies", "dependencies.dcf"),
    file.path(root, "artifact.dcf")
  )$id
  require_true(identical(verified$manifest[["Distribution-ID"]],
                         verified_second$manifest[["Distribution-ID"]]),
               "Equivalent builds changed logical distribution identity.")
  require_true(identical(verified$manifest[["Distribution-ID"]], reordered_identity),
               "Input traversal order changed logical distribution identity.")
  require_true(!identical(verified$manifest[["Build-ID"]],
                          verified_second$manifest[["Build-ID"]]),
               "Build occurrence identity did not change.")
  cat("PASS deterministic logical identity across independent builds and traversal orders\n")

  unrelated <- tempfile("rrp-unrelated-")
  dir.create(unrelated)
  on.exit(unlink(unrelated, recursive = TRUE, force = TRUE), add = TRUE)
  copied <- copy_tree(root, unrelated, "copied-distribution")
  command <- system2(
    file.path(R.home("bin"), "Rscript"),
    c("--vanilla", file.path(copied, "verify-distribution.R"), copied),
    stdout = TRUE, stderr = TRUE,
    env = c("R_LIBS_USER=", "R_LIBS_SITE=", "R_PROFILE_USER=", "R_ENVIRON_USER=")
  )
  require_true(is.null(attr(command, "status")), paste(command, collapse = "\n"))
  cat("PASS copied standalone verification without checkout or ambient library\n")

  mutation <- function(name) copy_tree(root, work, name)
  altered <- mutation("altered")
  write("altered", file.path(altered, "NOTICE"), append = TRUE)
  expect_failure("altered file", rrp_verify_distribution(altered), "Integrity failed")
  incorrect_digest <- mutation("incorrect-digest")
  rewrite_payload(incorrect_digest, mutate_inventory = function(records) {
    paths <- vapply(records[-1L], `[[`, character(1L), "Path")
    records[[which(paths == "NOTICE") + 1L]][["SHA256"]] <- paste(rep("0", 64L), collapse = "")
    records
  })
  expect_failure("incorrect digest", rrp_verify_distribution(incorrect_digest),
                 "Integrity failed")
  legal <- mutation("legal")
  writeLines("not the declared license", file.path(legal, "LICENSE"))
  rewrite_payload(legal, mutate_inventory = function(records) {
    paths <- vapply(records[-1L], `[[`, character(1L), "Path")
    index <- which(paths == "LICENSE") + 1L
    records[[index]][["Size"]] <- as.character(file.info(file.path(legal, "LICENSE"))$size)
    records[[index]][["SHA256"]] <- distribution_sha256(file.path(legal, "LICENSE"))
    records
  })
  expect_failure("license drift", rrp_verify_distribution(legal), "Legal or product-version")
  identity_drift <- mutation("identity-drift")
  write("source:invented=0000000000000000000000000000000000000000000000000000000000000000",
        file.path(identity_drift, "identity.txt"), append = TRUE)
  rewrite_payload(identity_drift, mutate_inventory = function(records) {
    paths <- vapply(records[-1L], `[[`, character(1L), "Path")
    index <- which(paths == "identity.txt") + 1L
    records[[index]][["Size"]] <- as.character(file.info(file.path(identity_drift, "identity.txt"))$size)
    records[[index]][["SHA256"]] <- distribution_sha256(file.path(identity_drift, "identity.txt"))
    records
  })
  expect_failure("identity drift", rrp_verify_distribution(identity_drift),
                 "Normalized distribution identity")
  missing <- mutation("missing")
  unlink(file.path(missing, "NOTICE"))
  expect_failure("missing file", rrp_verify_distribution(missing), "missing or unexpected")
  extra <- mutation("extra")
  writeLines("extra", file.path(extra, "EXTRA"))
  expect_failure("extra file", rrp_verify_distribution(extra), "missing or unexpected")
  extra_directory <- mutation("extra-directory")
  dir.create(file.path(extra_directory, "unexpected-empty-directory"))
  expect_failure("extra directory", rrp_verify_distribution(extra_directory),
                 "unexpected directory structure")
  linked <- mutation("linked")
  require_true(file.symlink(file.path(linked, "NOTICE"), file.path(linked, "linked-notice")),
               "Could not create symlink evidence.")
  expect_failure("linked file", rrp_verify_distribution(linked), "symbolic link")
  case_conflict <- mutation("case-conflict")
  rewrite_payload(case_conflict, mutate_inventory = function(records) {
    paths <- vapply(records[-1L], `[[`, character(1L), "Path")
    record <- records[[which(paths == "README.md") + 1L]]
    record[["Path"]] <- "readme.md"
    c(records, list(record))
  })
  expect_failure("case conflict", rrp_verify_distribution(case_conflict), "not closed and canonical")

  role <- mutation("role")
  rewrite_payload(role, mutate_inventory = function(records) {
    paths <- vapply(records[-1L], `[[`, character(1L), "Path")
    records[[which(paths == "bin/rrp") + 1L]][["Role"]] <- "documentation"
    records
  })
  expect_failure("missing role", rrp_verify_distribution(role), "Incorrect role count")
  unsafe <- mutation("unsafe")
  rewrite_payload(unsafe, mutate_inventory = function(records) {
    records[[2L]][["Path"]] <- "../escape"
    records
  })
  expect_failure("unsafe path", rrp_verify_distribution(unsafe), "invalid")
  duplicate <- mutation("duplicate")
  rewrite_payload(duplicate, mutate_inventory = function(records) c(records, list(records[[2L]])))
  expect_failure("duplicate path", rrp_verify_distribution(duplicate), "not closed and canonical")
  integrity <- mutation("dependency-integrity")
  rewrite_payload(integrity, mutate_dependency = function(records) {
    records[[2L]][["Integrity"]] <- "missing"
    records
  })
  expect_failure("missing dependency integrity", rrp_verify_distribution(integrity), "lacks provenance or integrity")
  provenance <- mutation("dependency-provenance")
  rewrite_payload(provenance, mutate_dependency = function(records) {
    records[[2L]][["Repository"]] <- "local"
    records
  })
  expect_failure("missing dependency provenance", rrp_verify_distribution(provenance), "lacks provenance or integrity")
  closure <- mutation("dependency-closure")
  rewrite_payload(closure, mutate_dependency = function(records) {
    index <- which(vapply(records, function(x) identical(x[["Package"]], "DBI"), logical(1L)))
    records <- records[-index]
    records[[1L]][["Package-Count"]] <- as.character(length(records) - 1L)
    records
  })
  expect_failure("dependency closure drift", rrp_verify_distribution(closure), "Package Imports disagree")
  target <- mutation("target")
  rewrite_payload(target, mutate_dependency = function(records) {
    records[[1L]][["Target-R-Version"]] <- "0.0.0"
    records
  })
  expect_failure("target mismatch", rrp_verify_distribution(target), "disagrees with manifest")
  cat("PASS missing/extra/altered/digest/role/path/link/case/dependency adversarial evidence\n")

  conflict <- file.path(work, "existing.tar")
  writeLines("preserve", conflict)
  before <- readBin(conflict, "raw", n = file.info(conflict)$size)
  result <- run_builder(conflict)
  require_true(result$status != 0L && identical(before, readBin(conflict, "raw", n = file.info(conflict)$size)),
               "Output conflict did not preserve existing output.")
  stages_before <- list.files(work, pattern = "^[.]rrp-distribution-stage-")
  failed_output <- file.path(work, "failed.tar")
  result <- run_builder(failed_output, "http://invalid.example")
  stages_after <- list.files(work, pattern = "^[.]rrp-distribution-stage-")
  require_true(result$status != 0L && !file.exists(failed_output) && identical(stages_before, stages_after),
               "Failed build left output or staging state.")
  cat("PASS output-conflict preservation and failed-build cleanup\n")

  cat("Result: PASS (closed RRP distribution foundation)\n")
  invisible(TRUE)
}

passed <- tryCatch({ validate_distribution(); TRUE }, error = function(e) {
  cat("Result: FAIL\n", conditionMessage(e), "\n", file = stderr())
  FALSE
})
if (!passed) quit(save = "no", status = 1L, runLast = FALSE)
