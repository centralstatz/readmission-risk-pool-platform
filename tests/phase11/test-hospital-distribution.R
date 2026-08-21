phase11_copy_tree <- function(source, destination) {
  tree <- rrp_hospital_scan_tree(source, allow_local_state = FALSE)
  dir.create(destination, recursive = TRUE, showWarnings = FALSE)
  for (relative in tree$files) rrp_hospital_copy_regular_file(
    file.path(source, relative), destination, relative
  )
  destination
}

phase11_copy_baseline <- function(proof, suite_root, label) {
  destination <- file.path(suite_root, paste0("copy-", label))
  phase11_copy_tree(proof$primary$distribution_path, destination)
}

phase11_write_manifest_checksum <- function(root, manifest) {
  path <- file.path(root, "HOSPITAL-DISTRIBUTION.yml")
  rrp_hospital_write_yaml(manifest, path)
  writeLines(
    rrp_hospital_sha256_file(path),
    file.path(root, "HOSPITAL-DISTRIBUTION.sha256"), useBytes = TRUE
  )
}

phase11_reseal <- function(root, transform = identity) {
  manifest <- rrp_hospital_read_yaml(file.path(root, "HOSPITAL-DISTRIBUTION.yml"))
  manifest <- transform(manifest)
  files <- setdiff(
    rrp_hospital_scan_tree(root, allow_local_state = FALSE)$files,
    c("HOSPITAL-DISTRIBUTION.yml", "HOSPITAL-DISTRIBUTION.sha256")
  )
  manifest$inventory <- rrp_hospital_inventory(
    root, files, rrp_hospital_distribution_role
  )
  manifest$required_files <- as.list(sort(files, method = "radix"))
  archive <- files[grepl("^platform/.*[.]tar$", files)]
  declared <- file.path(root, "platform", manifest$platform_candidate$archive_filename)
  if (length(archive) >= 1L && file.exists(declared)) {
    manifest$platform_candidate$archive_byte_size <- as.numeric(file.info(declared)$size)
    manifest$platform_candidate$archive_sha256 <- rrp_hospital_sha256_file(declared)
  }
  manifest$distribution_instance_id <- rrp_hospital_distribution_instance_id(manifest)
  manifest$distribution_build_id <- rrp_hospital_distribution_build_id(
    manifest$distribution_instance_id, manifest$built_at
  )
  phase11_write_manifest_checksum(root, manifest)
  invisible(manifest)
}

phase11_modify_tar_header <- function(path, modification) {
  connection <- file(path, "rb")
  value <- readBin(connection, "raw", n = as.integer(file.info(path)$size))
  close(connection)
  header <- value[1:512]
  header <- modification(header)
  header[149:156] <- charToRaw("        ")
  header[149:156] <- c(
    charToRaw(sprintf("%06o", sum(as.integer(header)))), as.raw(0L), charToRaw(" ")
  )
  value[1:512] <- header
  connection <- file(path, "wb")
  writeBin(value, connection, useBytes = TRUE)
  close(connection)
}

phase11_archive_path <- function(root) {
  manifest <- rrp_hospital_read_yaml(file.path(root, "HOSPITAL-DISTRIBUTION.yml"))
  file.path(root, "platform", manifest$platform_candidate$archive_filename)
}

phase11_process <- function(root, relative, arguments = character()) {
  rrp_hospital_run_process(file.path(root, relative), arguments, root)
}

phase11_issue <- function(result, code) phase0_assert_true(
  code %in% result$issues$issue_code,
  paste0("Expected `", code, "`; found: ", paste(result$issues$issue_code, collapse = ", "))
)

phase11_distribution_proof <- local({
  cached <- NULL
  function(repository_root, suite_root) {
    if (!is.null(cached)) return(cached)
    store_a <- file.path(suite_root, "store-a")
    store_b <- file.path(suite_root, "store-b")
    primary <- rrp_build_hospital_distribution(
      repository_root, store_a, "2026-08-20T16:00:00Z"
    )
    repeated <- rrp_build_hospital_distribution(
      repository_root, store_a, "2026-08-20T16:00:00Z"
    )
    later <- rrp_build_hospital_distribution(
      repository_root, store_b, "2026-08-20T16:01:00Z"
    )
    external <- file.path(suite_root, "recipient", "hospital-implementation")
    phase11_copy_tree(primary$distribution_path, external)
    standalone <- phase11_process(external, "validate-distribution.R")
    initialized <- rrp_initialize_hospital_distribution(external)
    initialized_again <- rrp_initialize_hospital_distribution(external)
    reference <- phase11_process(
      external, "operations/run-reference-acceptance.R"
    )
    adopter <- phase11_process(
      external, "operations/run-fictional-adopter-proof.R"
    )
    scaffold <- phase11_process(external, "operations/validate-producer.R")
    cached <<- list(
      primary = primary, repeated = repeated, later = later, external = external,
      standalone = standalone, initialized = initialized,
      initialized_again = initialized_again, reference = reference,
      adopter = adopter, scaffold = scaffold
    )
    cached
  }
})

phase11_copy_git_tree <- function(source, destination) {
  dir.create(destination, recursive = TRUE, showWarnings = FALSE)
  children <- list.files(
    source, all.files = TRUE, no.. = TRUE, full.names = TRUE
  )
  copied <- file.copy(
    children, destination, recursive = TRUE, copy.mode = TRUE, copy.date = TRUE
  )
  if (!all(copied)) stop("Could not copy temporary Git realization.", call. = FALSE)
  destination
}

phase11_git_issue <- function(result, code) phase0_assert_true(
  code %in% result$issues$issue_code,
  paste0("Expected `", code, "`; found: ",
         paste(result$issues$issue_code, collapse = ", "))
)

phase11_git_stage <- function(root) {
  result <- rrp_hospital_git_run(root, c("add", "--all"))
  phase0_assert_true(identical(result$status, 0L))
  invisible(root)
}

phase11_write_git_manifest_checksum <- function(root, manifest) {
  path <- file.path(root, "HOSPITAL-GIT-REALIZATION.yml")
  rrp_hospital_write_yaml(manifest, path)
  writeLines(
    rrp_hospital_sha256_file(path),
    file.path(root, "HOSPITAL-GIT-REALIZATION.sha256"), useBytes = TRUE
  )
  phase11_git_stage(root)
}

phase11_git_proof <- local({
  cached <- NULL
  function(repository_root, suite_root) {
    if (!is.null(cached)) return(cached)
    distribution <- phase11_distribution_proof(repository_root, suite_root)$primary
    first_destination <- file.path(suite_root, "git-realization-a")
    second_destination <- file.path(suite_root, "alternate-name")
    first <- rrp_build_hospital_git_realization(
      repository_root, distribution$distribution_path, first_destination,
      "2026-08-20T17:00:00Z"
    )
    repeated <- rrp_build_hospital_git_realization(
      repository_root, distribution$distribution_path, first_destination,
      "2026-08-20T17:01:00Z"
    )
    alternate <- rrp_build_hospital_git_realization(
      repository_root, distribution$distribution_path, second_destination,
      "2026-08-20T17:02:00Z"
    )
    cached <<- list(
      distribution = distribution, first = first, repeated = repeated,
      alternate = alternate, first_destination = first_destination,
      second_destination = second_destination
    )
    cached
  }
})

phase11_test_cases <- function(repository_root, suite_root) list(
  "Hospital distribution contract has a valid exact envelope" = function() {
    parsed <- rrp_parse_yaml_specification(file.path(
      repository_root, "contracts", "distribution",
      "hospital-implementation-distribution.yml"
    ))
    phase0_assert_true(is.null(parsed$parse_error))
    phase0_assert_true(rrp_conforms(rrp_validate_specification_envelope(parsed$document)))
    phase0_assert_true(identical(
      parsed$document[c("specification_kind", "specification_id", "specification_version")],
      rrp_hospital_distribution_specification()
    ))
  },

  "maintained Hospital source map is exact regular and safe" = function() {
    map <- rrp_hospital_distribution_source_map(repository_root)
    phase0_assert_true(length(map) > 20L)
    phase0_assert_true(!anyDuplicated(names(map)))
    phase0_assert_true(all(vapply(names(map), rrp_hospital_safe_relative_path, logical(1))))
    phase0_assert_true(all(file.exists(map)))
    phase0_assert_true(!any(vapply(map, function(path) {
      dir.exists(path) || nzchar(Sys.readlink(path))
    }, logical(1))))
  },

  "maintained documentation validation excludes generated build artifacts" = function() {
    markdown <- rrp_markdown_files(repository_root)
    relative <- substring(markdown, nchar(normalizePath(repository_root)) + 2L)
    phase0_assert_false(any(startsWith(relative, "build/")))
  },

  "Platform proof candidate archive is valid and explicitly unpublished" = function() {
    proof <- phase11_distribution_proof(repository_root, suite_root)
    result <- rrp_hospital_validate_platform_candidate_archive(
      phase11_archive_path(proof$primary$distribution_path)
    )
    phase0_assert_true(nrow(result$issues) == 0L)
    phase0_assert_true(identical(
      result$manifest$candidate_status, "proof_only_not_published_not_v0.1.0"
    ))
  },

  "distribution build and promoted baseline validate" = function() {
    proof <- phase11_distribution_proof(repository_root, suite_root)
    phase0_assert_true(identical(proof$primary$overall_status, "succeeded"))
    phase0_assert_true(identical(
      rrp_validate_hospital_distribution(
        proof$primary$distribution_path, allow_local_state = FALSE
      )$overall_status, "pass"
    ))
  },

  "logical identity is deterministic while build time has its own identity" = function() {
    proof <- phase11_distribution_proof(repository_root, suite_root)
    phase0_assert_true(identical(
      proof$primary$distribution_instance_id, proof$later$distribution_instance_id
    ))
    phase0_assert_false(identical(
      proof$primary$distribution_build_id, proof$later$distribution_build_id
    ))
  },

  "repeated immutable build is idempotent" = function() {
    proof <- phase11_distribution_proof(repository_root, suite_root)
    phase0_assert_true(proof$repeated$idempotent)
    phase0_assert_true(identical(
      proof$primary$distribution_build_id, proof$repeated$distribution_build_id
    ))
  },

  "output location and Git location are not logical identity" = function() {
    proof <- phase11_distribution_proof(repository_root, suite_root)
    phase0_assert_false(identical(
      dirname(proof$primary$distribution_path), dirname(proof$later$distribution_path)
    ))
    phase0_assert_true(identical(
      proof$primary$distribution_instance_id, proof$later$distribution_instance_id
    ))
    manifest <- rrp_hospital_read_yaml(file.path(
      proof$primary$distribution_path, "HOSPITAL-DISTRIBUTION.yml"
    ))
    phase0_assert_true(!"git" %in% names(manifest))
  },

  "maintained and Platform content participate in logical identity" = function() {
    proof <- phase11_distribution_proof(repository_root, suite_root)
    manifest <- rrp_hospital_read_yaml(file.path(
      proof$primary$distribution_path, "HOSPITAL-DISTRIBUTION.yml"
    ))
    changed_member <- manifest
    changed_member$inventory[[1L]]$checksum$value <- paste0(
      "0", substring(changed_member$inventory[[1L]]$checksum$value, 2L)
    )
    changed_platform <- manifest
    changed_platform$platform_candidate$archive_sha256 <- paste0(
      "0", substring(changed_platform$platform_candidate$archive_sha256, 2L)
    )
    phase0_assert_false(identical(
      rrp_hospital_distribution_instance_id(manifest),
      rrp_hospital_distribution_instance_id(changed_member)
    ))
    phase0_assert_false(identical(
      rrp_hospital_distribution_instance_id(manifest),
      rrp_hospital_distribution_instance_id(changed_platform)
    ))
  },

  "embedded Platform archive digest and size are verified" = function() {
    proof <- phase11_distribution_proof(repository_root, suite_root)
    root <- proof$primary$distribution_path
    manifest <- rrp_hospital_read_yaml(file.path(root, "HOSPITAL-DISTRIBUTION.yml"))
    archive <- phase11_archive_path(root)
    phase0_assert_true(identical(
      rrp_hospital_sha256_file(archive), manifest$platform_candidate$archive_sha256
    ))
    phase0_assert_true(identical(
      as.numeric(file.info(archive)$size),
      as.numeric(manifest$platform_candidate$archive_byte_size)
    ))
  },

  "safe managed extraction is exact and idempotent" = function() {
    proof <- phase11_distribution_proof(repository_root, suite_root)
    phase0_assert_false(proof$initialized$idempotent)
    phase0_assert_true(proof$initialized_again$idempotent)
    phase0_assert_true(startsWith(
      proof$initialized$managed_platform,
      file.path(proof$external, ".rrp", "platform")
    ))
  },

  "one top-level lock is exact and nested activation is bypassed" = function() {
    proof <- phase11_distribution_proof(repository_root, suite_root)
    root <- proof$primary$distribution_path
    manifest <- rrp_hospital_read_yaml(file.path(root, "HOSPITAL-DISTRIBUTION.yml"))
    phase0_assert_true(identical(
      manifest$environment$source_platform_lock_sha256,
      manifest$environment$top_level_lock_sha256
    ))
    phase0_assert_true(length(manifest$environment$maintained_dependency_additions) == 0L)
    runtime <- paste(readLines(file.path(
      root, "R", "distribution-runtime.R"
    ), warn = FALSE), collapse = "\n")
    phase0_assert_true(grepl('c("--vanilla"', runtime, fixed = TRUE))
  },

  "callable Platform cycle seam is shared by Platform human scripts" = function() {
    seam <- paste(readLines(file.path(
      repository_root, "operations", "lib", "platform-cycle-operation.R"
    ), warn = FALSE), collapse = "\n")
    phase0_assert_true(grepl("rrp_run_selected_platform_cycle <- function", seam, fixed = TRUE))
    for (script in c("run-platform.R", "validate-producer.R")) {
      text <- paste(readLines(file.path(repository_root, "operations", script),
                              warn = FALSE), collapse = "\n")
      phase0_assert_true(grepl("platform-cycle-operation.R", text, fixed = TRUE))
    }
  },

  "hospital wrappers remain thin delegates" = function() {
    wrappers <- list.files(file.path(
      repository_root, "distribution", "hospital", "operations"
    ), full.names = TRUE)
    text <- paste(unlist(lapply(wrappers, readLines, warn = FALSE)), collapse = "\n")
    phase0_assert_false(grepl("new_episode_state <- function", text, fixed = TRUE))
    phase0_assert_false(grepl("rrp_build_priority", text, fixed = TRUE))
    phase0_assert_true(grepl("rrp_hospital_delegate_platform", text, fixed = TRUE))
  },

  "copied distribution validates without the authoritative tree" = function() {
    proof <- phase11_distribution_proof(repository_root, suite_root)
    phase0_assert_true(identical(proof$standalone$status, 0L))
    phase0_assert_true(any(grepl(
      "Status: succeeded", proof$standalone$output, fixed = TRUE
    )))
    phase0_assert_true(any(grepl(
      "extracted_platform_validation: passed", proof$standalone$output,
      fixed = TRUE
    )))
    phase0_assert_false(startsWith(proof$external, repository_root))
  },

  "synthetic reference acceptance completes unchanged downstream layers" = function() {
    proof <- phase11_distribution_proof(repository_root, suite_root)
    phase0_assert_true(identical(proof$reference$status, 0L))
    phase0_assert_true(any(grepl(
      "Operation: hospital.run-reference-acceptance", proof$reference$output, fixed = TRUE
    )))
    phase0_assert_true(any(grepl("reduced_artifact: validated", proof$reference$output,
                                fixed = TRUE)))
  },

  "fictional adopter passes the exact trusted producer seam and downstream layers" = function() {
    proof <- phase11_distribution_proof(repository_root, suite_root)
    phase0_assert_true(identical(proof$adopter$status, 0L))
    phase0_assert_true(any(grepl(
      "Operation: hospital.run-fictional-adopter-proof", proof$adopter$output,
      fixed = TRUE
    )))
    phase0_assert_true(any(grepl("reduced_artifact: validated", proof$adopter$output,
                                fixed = TRUE)))
  },

  "generated fictional adopter source-local failure short circuits before admission" = function() {
    proof <- phase11_distribution_proof(repository_root, suite_root)
    managed <- proof$initialized$managed_platform
    rrp_hospital_source_platform_cycle(managed, .GlobalEnv)
    sys.source(file.path(
      proof$external, "examples", "fictional-adopter", "R", "composition.R"
    ), envir = .GlobalEnv)
    rrp_source_hospital_fictional_adopter(proof$external)
    invalid <- rrp_adopter_fixture_source()
    invalid$case_extract$case_ref[[2L]] <- invalid$case_extract$case_ref[[1L]]
    composition <- rrp_hospital_fictional_adopter_composition(
      proof$external, managed, invalid
    )
    result <- rrp_execute_canonical_producer(
      composition$registry, composition$selection$producer_id,
      composition$selection$producer_version,
      list(
        producer_execution_id = "producer_hospital_invalid_source_001",
        canonical_as_of_time = NULL,
        producer_configuration = list(scenario_id = "fictional_export_case_v1")
      ), managed
    )
    phase0_assert_true(identical(result$overall_status, "failed"))
    phase0_assert_true(is.null(result$canonical_bundle))
    phase0_assert_true(identical(
      result$stage_statuses,
      c(
        producer_configuration = "succeeded", source_local_validation = "failed",
        mapping = "not_run", canonical_admission = "not_run"
      )
    ))
    codes <- unlist(lapply(result$conformance_results, function(value) {
      value$issues$issue_code
    }), use.names = FALSE)
    phase0_assert_true("duplicate_or_missing_adopter_source_id" %in% codes)
  },

  "reference and adopter retain isolated DuckDB product and artifact state" = function() {
    proof <- phase11_distribution_proof(repository_root, suite_root)
    reference <- file.path(proof$external, "build", "reference")
    adopter <- file.path(proof$external, "build", "fictional-adopter")
    phase0_assert_true(all(file.exists(c(
      file.path(reference, "history.duckdb"), file.path(adopter, "history.duckdb")
    ))))
    phase0_assert_false(identical(
      rrp_hospital_sha256_file(file.path(reference, "history.duckdb")),
      rrp_hospital_sha256_file(file.path(adopter, "history.duckdb"))
    ))
    phase0_assert_true(file.exists(file.path(reference, "products", "CURRENT.yml")))
    phase0_assert_true(file.exists(file.path(adopter, "products", "CURRENT.yml")))
    phase0_assert_true(file.exists(file.path(
      reference, "application-artifacts", "CURRENT.yml"
    )))
    phase0_assert_true(file.exists(file.path(
      adopter, "application-artifacts", "CURRENT.yml"
    )))
  },

  "editable scaffold fails producer conformance clearly" = function() {
    proof <- phase11_distribution_proof(repository_root, suite_root)
    phase0_assert_true(proof$scaffold$status != 0L)
    phase0_assert_true(any(grepl(
      "Implement the trusted callable", proof$scaffold$output, fixed = TRUE
    )))
  },

  "missing Platform archive fails closed" = function() {
    proof <- phase11_distribution_proof(repository_root, suite_root)
    root <- phase11_copy_baseline(proof, suite_root, "missing-archive")
    unlink(phase11_archive_path(root))
    phase11_issue(rrp_validate_hospital_distribution(root, FALSE),
                  "distribution_inventory_mismatch")
  },

  "changed Platform archive bytes fail digest validation" = function() {
    proof <- phase11_distribution_proof(repository_root, suite_root)
    root <- phase11_copy_baseline(proof, suite_root, "archive-bytes")
    connection <- file(phase11_archive_path(root), "ab")
    writeBin(charToRaw("tamper"), connection)
    close(connection)
    phase11_issue(rrp_validate_hospital_distribution(root, FALSE),
                  "platform_archive_digest_mismatch")
  },

  "incorrect declared Platform SHA fails closed" = function() {
    proof <- phase11_distribution_proof(repository_root, suite_root)
    root <- phase11_copy_baseline(proof, suite_root, "archive-sha")
    manifest <- rrp_hospital_read_yaml(file.path(root, "HOSPITAL-DISTRIBUTION.yml"))
    manifest$platform_candidate$archive_sha256 <- strrep("0", 64L)
    manifest$distribution_instance_id <- rrp_hospital_distribution_instance_id(manifest)
    manifest$distribution_build_id <- rrp_hospital_distribution_build_id(
      manifest$distribution_instance_id, manifest$built_at
    )
    phase11_write_manifest_checksum(root, manifest)
    phase11_issue(rrp_validate_hospital_distribution(root, FALSE),
                  "platform_archive_digest_mismatch")
  },

  "wrong Platform candidate identity and version fail compatibility" = function() {
    proof <- phase11_distribution_proof(repository_root, suite_root)
    root <- phase11_copy_baseline(proof, suite_root, "candidate-identity")
    phase11_reseal(root, function(manifest) {
      manifest$platform_candidate$platform_version <- "9.9.9"
      manifest$platform_candidate$candidate_instance_id <- paste0(
        "platform_release_candidate::", strrep("a", 64L)
      )
      manifest
    })
    result <- rrp_validate_hospital_distribution(root, FALSE)
    phase11_issue(result, "platform_candidate_reference_mismatch")
  },

  "extra undeclared Platform archive fails exact count" = function() {
    proof <- phase11_distribution_proof(repository_root, suite_root)
    root <- phase11_copy_baseline(proof, suite_root, "extra-archive")
    file.copy(phase11_archive_path(root), file.path(root, "platform", "extra.tar"))
    phase11_reseal(root)
    phase11_issue(rrp_validate_hospital_distribution(root, FALSE),
                  "platform_archive_count_mismatch")
  },

  "archive path traversal fails safe reader" = function() {
    proof <- phase11_distribution_proof(repository_root, suite_root)
    root <- phase11_copy_baseline(proof, suite_root, "traversal")
    phase11_modify_tar_header(phase11_archive_path(root), function(header) {
      header[1:100] <- rep(as.raw(0L), 100L)
      header[1:nchar("../escape")] <- charToRaw("../escape")
      header
    })
    phase11_reseal(root)
    phase11_issue(rrp_validate_hospital_distribution(root, FALSE),
                  "unsafe_or_invalid_platform_archive")
  },

  "archive symbolic-link member fails safe reader" = function() {
    proof <- phase11_distribution_proof(repository_root, suite_root)
    root <- phase11_copy_baseline(proof, suite_root, "archive-link")
    phase11_modify_tar_header(phase11_archive_path(root), function(header) {
      header[157L] <- charToRaw("2")
      header
    })
    phase11_reseal(root)
    phase11_issue(rrp_validate_hospital_distribution(root, FALSE),
                  "unsafe_or_invalid_platform_archive")
  },

  "missing required and extra unexpected files fail closed inventory" = function() {
    proof <- phase11_distribution_proof(repository_root, suite_root)
    missing <- phase11_copy_baseline(proof, suite_root, "missing-required")
    unlink(file.path(missing, "operations", "doctor.R"))
    phase11_issue(rrp_validate_hospital_distribution(missing, FALSE),
                  "distribution_inventory_mismatch")
    extra <- phase11_copy_baseline(proof, suite_root, "extra-file")
    writeLines("unexpected", file.path(extra, "unexpected.txt"))
    phase11_issue(rrp_validate_hospital_distribution(extra, FALSE),
                  "distribution_inventory_mismatch")
  },

  "changed manifest member fails manifest checksum" = function() {
    proof <- phase11_distribution_proof(repository_root, suite_root)
    root <- phase11_copy_baseline(proof, suite_root, "manifest")
    write("# changed", file = file.path(root, "HOSPITAL-DISTRIBUTION.yml"), append = TRUE)
    phase11_issue(rrp_validate_hospital_distribution(root, FALSE),
                  "distribution_manifest_checksum_mismatch")
  },

  "modified extracted managed Platform baseline is preserved and rejected" = function() {
    proof <- phase11_distribution_proof(repository_root, suite_root)
    path <- file.path(proof$initialized$managed_platform, "README.md")
    original <- readLines(path, warn = FALSE)
    on.exit(writeLines(original, path, useBytes = TRUE), add = TRUE)
    write("drift", file = path, append = TRUE)
    phase0_assert_error(
      rrp_initialize_hospital_distribution(proof$external),
      "Managed Platform baseline differs"
    )
  },

  "incompatible Hospital Platform declaration fails closed" = function() {
    proof <- phase11_distribution_proof(repository_root, suite_root)
    root <- phase11_copy_baseline(proof, suite_root, "compatibility")
    manifest <- rrp_hospital_read_yaml(file.path(root, "HOSPITAL-DISTRIBUTION.yml"))
    manifest$compatibility$platform_inclusion <- "latest"
    phase11_write_manifest_checksum(root, manifest)
    phase11_issue(rrp_validate_hospital_distribution(root, FALSE),
                  "incompatible_hospital_platform_declaration")
  },

  "top-level lock drift and maintained dependency conflict fail closed" = function() {
    proof <- phase11_distribution_proof(repository_root, suite_root)
    root <- phase11_copy_baseline(proof, suite_root, "lock")
    write(" ", file = file.path(root, "renv.lock"), append = TRUE)
    phase11_reseal(root)
    phase11_issue(rrp_validate_hospital_distribution(root, FALSE),
                  "hospital_environment_mismatch")
    phase0_assert_error(rrp_hospital_validate_lock_baseline(
      file.path(repository_root, "renv.lock"), file.path(repository_root, "renv.lock"),
      list(example = "1.0.0")
    ), "declares no maintained dependency additions")
  },

  "unknown producer and declaration callable mismatch fail trust boundary" = function() {
    registry <- rrp_new_canonical_producer_registry()
    phase0_assert_error(rrp_validate_selected_canonical_producer(
      repository_root, registry,
      list(producer_id = "unknown.producer", producer_version = "1.0.0"), list()
    ), "not registered")
    declaration <- rrp_parse_yaml_specification(file.path(
      repository_root, "implementations", "synthetic-reference", "producer.yml"
    ))$document
    contract <- rrp_read_canonical_producer_contract(repository_root)
    mismatch <- function(invocation) rrp_new_canonical_producer_adapter_result(
      status = "succeeded",
      producer_execution_id = invocation$producer_execution_id,
      implementation_identity = list(
        implementation_id = "mismatch.implementation",
        implementation_version = "1.0.0"
      ),
      mapping_identity = declaration$mapping_identity,
      canonical_profile = NULL,
      canonical_as_of_time = "2026-08-20T16:00:00Z",
      capabilities = declaration$capabilities,
      stage_statuses = c(
        producer_configuration = "succeeded",
        source_local_validation = "succeeded", mapping = "succeeded"
      ),
      candidate_bundle = list()
    )
    rrp_register_canonical_producer(registry, declaration, mismatch, contract)
    result <- rrp_execute_canonical_producer(
      registry, declaration$producer_id, declaration$producer_version,
      list(producer_execution_id = "producer_mismatch_001"), repository_root
    )
    phase0_assert_true(identical(result$overall_status, "failed"))
    phase0_assert_true(any(vapply(result$conformance_results, function(value) {
      "producer_result_identity_mismatch" %in% value$issues$issue_code
    }, logical(1))))
  },

  "failed delegated Platform operation propagates nonzero status" = function() {
    proof <- phase11_distribution_proof(repository_root, suite_root)
    fresh <- phase11_copy_baseline(proof, suite_root, "delegate-failure")
    result <- phase11_process(fresh, "operations/build-products.R")
    phase0_assert_true(result$status != 0L)
    phase0_assert_true(any(grepl("failed", result$output, ignore.case = TRUE)))
  },

  "prohibited generated or sensitive-shaped content is rejected" = function() {
    proof <- phase11_distribution_proof(repository_root, suite_root)
    root <- phase11_copy_baseline(proof, suite_root, "prohibited")
    writeLines("not-a-secret", file.path(root, ".env"))
    phase11_reseal(root)
    phase11_issue(rrp_validate_hospital_distribution(root, FALSE),
                  "prohibited_distribution_content")
  },

  "artifact contains no authoritative or sibling machine-path dependency" = function() {
    proof <- phase11_distribution_proof(repository_root, suite_root)
    root <- proof$primary$distribution_path
    manifest <- rrp_hospital_read_yaml(file.path(root, "HOSPITAL-DISTRIBUTION.yml"))
    archive <- rrp_hospital_validate_platform_candidate_archive(phase11_archive_path(root))
    payload <- setdiff(vapply(manifest$inventory, `[[`, character(1), "path"),
                       paste0("platform/", manifest$platform_candidate$archive_filename))
    text <- c(unlist(lapply(payload, function(relative) {
      readLines(file.path(root, relative), warn = FALSE)
    })), unlist(lapply(archive$entries, function(entry) rawToChar(entry$content))))
    joined <- paste(text, collapse = "\n")
    phase0_assert_false(grepl(normalizePath(repository_root), joined, fixed = TRUE))
    phase0_assert_false(grepl(
      paste0("..", "/readmission-risk-pool"), joined, fixed = TRUE
    ))
    phase0_assert_false(grepl(paste0("/", "Users", "/"), joined, fixed = TRUE))
  },

  "Hospital Git realization contract has a valid exact envelope" = function() {
    parsed <- rrp_parse_yaml_specification(file.path(
      repository_root, "contracts", "distribution",
      "hospital-implementation-git-realization.yml"
    ))
    phase0_assert_true(is.null(parsed$parse_error))
    phase0_assert_true(rrp_conforms(rrp_validate_specification_envelope(parsed$document)))
    phase0_assert_true(identical(
      parsed$document[c("specification_kind", "specification_id", "specification_version")],
      rrp_hospital_git_specification()
    ))
  },

  "validated distribution realizes as staged uncommitted remote-free main" = function() {
    proof <- phase11_git_proof(repository_root, suite_root)
    result <- rrp_validate_hospital_git_realization(
      proof$first_destination, check_git = TRUE, run_distribution_validator = FALSE
    )
    phase0_assert_true(identical(result$overall_status, "pass"))
    phase0_assert_true(identical(
      result$manifest$repository_semantics$initial_branch, "main"
    ))
    phase0_assert_true(identical(
      result$manifest$source_distribution$distribution_build_id,
      proof$distribution$distribution_build_id
    ))
    phase0_assert_true(identical(
      rrp_hospital_git_run(proof$first_destination, "remote")$output,
      character()
    ))
    phase0_assert_true(rrp_hospital_git_run(
      proof$first_destination, c("rev-parse", "--verify", "HEAD")
    )$status != 0L)
  },

  "Git realization is independently valid and preserves artifact validation" = function() {
    proof <- phase11_git_proof(repository_root, suite_root)
    standalone <- rrp_validate_completed_hospital_git_realization(
      proof$first_destination
    )
    distribution <- phase11_process(
      proof$first_destination, "validate-distribution.R"
    )
    phase0_assert_true(identical(standalone$overall_status, "pass"))
    phase0_assert_true(identical(distribution$status, 0L))
  },

  "realization identity excludes destination and time and regeneration is idempotent" = function() {
    proof <- phase11_git_proof(repository_root, suite_root)
    phase0_assert_true(proof$repeated$idempotent)
    phase0_assert_false(proof$repeated$replaced)
    phase0_assert_true(identical(
      proof$first$realization_instance_id,
      proof$alternate$realization_instance_id
    ))
    first_manifest <- rrp_hospital_read_yaml(file.path(
      proof$first_destination, "HOSPITAL-GIT-REALIZATION.yml"
    ))
    second_manifest <- rrp_hospital_read_yaml(file.path(
      proof$second_destination, "HOSPITAL-GIT-REALIZATION.yml"
    ))
    phase0_assert_false(identical(first_manifest$realized_at, second_manifest$realized_at))
    phase0_assert_false("destination" %in% names(first_manifest))
  },

  "different distribution and Platform provenance participate in identity" = function() {
    proof <- phase11_git_proof(repository_root, suite_root)
    manifest <- rrp_hospital_read_yaml(file.path(
      proof$first_destination, "HOSPITAL-GIT-REALIZATION.yml"
    ))
    changed_distribution <- manifest
    changed_distribution$source_distribution$distribution_instance_id <- paste0(
      "hospital_implementation_distribution::", paste(rep("0", 64L), collapse = "")
    )
    changed_platform <- manifest
    changed_platform$included_platform$archive_sha256 <- paste(
      rep("f", 64L), collapse = ""
    )
    phase0_assert_false(identical(
      rrp_hospital_git_realization_id(manifest),
      rrp_hospital_git_realization_id(changed_distribution)
    ))
    phase0_assert_false(identical(
      rrp_hospital_git_realization_id(manifest),
      rrp_hospital_git_realization_id(changed_platform)
    ))
  },

  "pristine realization may be replaced by a changed validated distribution" = function() {
    proof <- phase11_git_proof(repository_root, suite_root)
    destination <- phase11_copy_git_tree(
      proof$first_destination, file.path(suite_root, "git-replacement")
    )
    changed_source <- phase11_copy_baseline(
      phase11_distribution_proof(repository_root, suite_root),
      suite_root, "changed-realization-source"
    )
    write("A changed proof distribution.\n", file.path(changed_source, "README.md"),
          append = TRUE)
    phase11_reseal(changed_source)
    changed_validation <- rrp_validate_hospital_distribution(
      changed_source, allow_local_state = FALSE
    )
    phase0_assert_true(identical(changed_validation$overall_status, "pass"))
    replacement <- rrp_build_hospital_git_realization(
      repository_root, changed_source, destination, "2026-08-20T17:03:00Z"
    )
    phase0_assert_true(replacement$replaced)
    phase0_assert_false(replacement$idempotent)
    phase0_assert_false(identical(
      replacement$realization_instance_id, proof$first$realization_instance_id
    ))
  },

  "realized repository runs acquisition doctor reference and adopter baselines" = function() {
    proof <- phase11_git_proof(repository_root, suite_root)
    destination <- file.path(suite_root, "git-acquisition")
    built <- rrp_build_hospital_git_realization(
      repository_root, proof$distribution$distribution_path, destination,
      "2026-08-20T17:04:00Z"
    )
    validated <- rrp_validate_completed_hospital_git_realization(destination)
    initialized <- phase11_process(destination, "operations/initialize.R")
    doctor <- phase11_process(destination, "operations/doctor.R")
    reference <- phase11_process(
      destination, "operations/run-reference-acceptance.R"
    )
    adopter <- phase11_process(
      destination, "operations/run-fictional-adopter-proof.R"
    )
    phase0_assert_true(identical(built$overall_status, "succeeded"))
    phase0_assert_true(identical(validated$overall_status, "pass"))
    phase0_assert_true(all(c(
      initialized$status, doctor$status, reference$status, adopter$status
    ) == 0L))
  },

  "missing invalid and tampered source distributions fail before realization" = function() {
    proof <- phase11_git_proof(repository_root, suite_root)
    phase0_assert_error(rrp_build_hospital_git_realization(
      repository_root, file.path(suite_root, "missing-distribution"),
      file.path(suite_root, "missing-output"), "2026-08-20T17:05:00Z"
    ), "does not exist")
    invalid <- file.path(suite_root, "invalid-distribution")
    dir.create(invalid)
    phase0_assert_error(rrp_build_hospital_git_realization(
      repository_root, invalid, file.path(suite_root, "invalid-output"),
      "2026-08-20T17:05:00Z"
    ), "CURRENT.yml")
    tampered <- phase11_copy_baseline(
      phase11_distribution_proof(repository_root, suite_root),
      suite_root, "tampered-git-source"
    )
    write("tampered\n", file.path(tampered, "README.md"), append = TRUE)
    phase0_assert_error(rrp_build_hospital_git_realization(
      repository_root, tampered, file.path(suite_root, "tampered-output"),
      "2026-08-20T17:05:00Z"
    ), "independently valid")
  },

  "unrelated and symbolic-link destinations are refused" = function() {
    proof <- phase11_git_proof(repository_root, suite_root)
    unrelated <- file.path(suite_root, "unrelated-destination")
    dir.create(unrelated)
    writeLines("recipient work", file.path(unrelated, "notes.txt"))
    phase0_assert_error(rrp_build_hospital_git_realization(
      repository_root, proof$distribution$distribution_path, unrelated,
      "2026-08-20T17:06:00Z"
    ), "outside pristine generator ownership")
    target <- file.path(suite_root, "link-target")
    dir.create(target)
    linked <- file.path(suite_root, "linked-destination")
    phase0_assert_true(file.symlink(target, linked))
    phase0_assert_error(rrp_build_hospital_git_realization(
      repository_root, proof$distribution$distribution_path, linked,
      "2026-08-20T17:06:00Z"
    ), "non-linked path")
  },

  "modified generated destination is never overwritten" = function() {
    proof <- phase11_git_proof(repository_root, suite_root)
    destination <- phase11_copy_git_tree(
      proof$first_destination, file.path(suite_root, "modified-destination")
    )
    write("recipient change\n", file.path(destination, "README.md"), append = TRUE)
    phase0_assert_error(rrp_build_hospital_git_realization(
      repository_root, proof$distribution$distribution_path, destination,
      "2026-08-20T17:07:00Z"
    ), "outside pristine generator ownership")
  },

  "committed generated destination is never overwritten" = function() {
    proof <- phase11_git_proof(repository_root, suite_root)
    destination <- phase11_copy_git_tree(
      proof$first_destination, file.path(suite_root, "committed-destination")
    )
    committed <- rrp_hospital_git_run(destination, c(
      "-c", "user.name=Phase11Test", "-c", "user.email=test@example.invalid",
      "commit", "-m", "temporary-test-commit"
    ))
    phase0_assert_true(identical(committed$status, 0L))
    result <- rrp_validate_hospital_git_realization(
      destination, check_git = TRUE, run_distribution_validator = FALSE
    )
    phase11_git_issue(result, "generated_repository_has_commit")
    phase0_assert_error(rrp_build_hospital_git_realization(
      repository_root, proof$distribution$distribution_path, destination,
      "2026-08-20T17:08:00Z"
    ), "outside pristine generator ownership")
  },

  "remote-configured generated destination is never overwritten" = function() {
    proof <- phase11_git_proof(repository_root, suite_root)
    destination <- phase11_copy_git_tree(
      proof$first_destination, file.path(suite_root, "remote-destination")
    )
    remote <- rrp_hospital_git_run(destination, c(
      "remote", "add", "origin", "https://example.invalid/hospital.git"
    ))
    phase0_assert_true(identical(remote$status, 0L))
    result <- rrp_validate_hospital_git_realization(
      destination, check_git = TRUE, run_distribution_validator = FALSE
    )
    phase11_git_issue(result, "configured_git_remote")
    phase0_assert_error(rrp_build_hospital_git_realization(
      repository_root, proof$distribution$distribution_path, destination,
      "2026-08-20T17:09:00Z"
    ), "outside pristine generator ownership")
  },

  "nested and suspicious Git state fails closed" = function() {
    proof <- phase11_git_proof(repository_root, suite_root)
    suspicious <- phase11_copy_git_tree(
      proof$first_destination, file.path(suite_root, "suspicious-git")
    )
    dir.create(file.path(suspicious, ".git", "objects", "info"),
               recursive = TRUE, showWarnings = FALSE)
    writeLines("/tmp/not-used", file.path(
      suspicious, ".git", "objects", "info", "alternates"
    ))
    result <- rrp_validate_hospital_git_realization(
      suspicious, check_git = TRUE, run_distribution_validator = FALSE
    )
    phase11_git_issue(result, "suspicious_git_metadata")
    nested <- phase11_copy_git_tree(
      proof$first_destination, file.path(suite_root, "nested-git")
    )
    dir.create(file.path(nested, "implementation", ".git"))
    writeLines("ref: refs/heads/main", file.path(
      nested, "implementation", ".git", "HEAD"
    ))
    nested_result <- rrp_validate_hospital_git_realization(
      nested, check_git = TRUE, run_distribution_validator = FALSE
    )
    phase11_git_issue(nested_result, "nested_git_state")
  },

  "tampered missing and extra realization members fail closed" = function() {
    proof <- phase11_git_proof(repository_root, suite_root)
    tampered <- phase11_copy_git_tree(
      proof$first_destination, file.path(suite_root, "git-member-tampered")
    )
    write("tampered\n", file.path(tampered, "README.md"), append = TRUE)
    phase11_git_issue(rrp_validate_hospital_git_realization(
      tampered, TRUE, FALSE
    ), "git_realization_member_mismatch")
    missing <- phase11_copy_git_tree(
      proof$first_destination, file.path(suite_root, "git-member-missing")
    )
    unlink(file.path(missing, "implementation", "producer.yml"))
    phase11_git_issue(rrp_validate_hospital_git_realization(
      missing, TRUE, FALSE
    ), "git_realization_inventory_mismatch")
    extra <- phase11_copy_git_tree(
      proof$first_destination, file.path(suite_root, "git-member-extra")
    )
    writeLines("unexpected", file.path(extra, "unexpected.txt"))
    phase11_git_issue(rrp_validate_hospital_git_realization(
      extra, TRUE, FALSE
    ), "git_realization_inventory_mismatch")
  },

  "realization metadata and embedded Platform mismatches fail closed" = function() {
    proof <- phase11_git_proof(repository_root, suite_root)
    metadata <- phase11_copy_git_tree(
      proof$first_destination, file.path(suite_root, "git-metadata-mismatch")
    )
    manifest <- rrp_hospital_read_yaml(file.path(
      metadata, "HOSPITAL-GIT-REALIZATION.yml"
    ))
    manifest$source_distribution$distribution_instance_id <- paste0(
      "hospital_implementation_distribution::", paste(rep("0", 64L), collapse = "")
    )
    phase11_write_git_manifest_checksum(metadata, manifest)
    phase11_git_issue(rrp_validate_hospital_git_realization(
      metadata, TRUE, FALSE
    ), "git_realization_provenance_mismatch")
    platform <- phase11_copy_git_tree(
      proof$first_destination, file.path(suite_root, "git-platform-mismatch")
    )
    platform_manifest <- rrp_hospital_read_yaml(file.path(
      platform, "HOSPITAL-GIT-REALIZATION.yml"
    ))
    platform_manifest$included_platform$archive_sha256 <- paste(
      rep("0", 64L), collapse = ""
    )
    phase11_write_git_manifest_checksum(platform, platform_manifest)
    phase11_git_issue(rrp_validate_hospital_git_realization(
      platform, TRUE, FALSE
    ), "git_realization_provenance_mismatch")
  },

  "branch mismatch and unstaged modification fail Git baseline" = function() {
    proof <- phase11_git_proof(repository_root, suite_root)
    branch <- phase11_copy_git_tree(
      proof$first_destination, file.path(suite_root, "git-wrong-branch")
    )
    renamed <- rrp_hospital_git_run(branch, c("branch", "-m", "other"))
    phase0_assert_true(identical(renamed$status, 0L))
    phase11_git_issue(rrp_validate_hospital_git_realization(
      branch, TRUE, FALSE
    ), "unexpected_initial_branch")
    unstaged <- phase11_copy_git_tree(
      proof$first_destination, file.path(suite_root, "git-unstaged")
    )
    write("unstaged\n", file.path(unstaged, "README.md"), append = TRUE)
    phase11_git_issue(rrp_validate_hospital_git_realization(
      unstaged, TRUE, FALSE
    ), "unstaged_realization_change")
  },

  "ignored unexpected state fails the pristine Git baseline" = function() {
    proof <- phase11_git_proof(repository_root, suite_root)
    ignored <- phase11_copy_git_tree(
      proof$first_destination, file.path(suite_root, "git-ignored-state")
    )
    dir.create(file.path(ignored, "build"))
    writeLines("unexpected ignored state", file.path(ignored, "build", "state.txt"))
    result <- rrp_validate_hospital_git_realization(
      ignored, check_git = TRUE, run_distribution_validator = FALSE
    )
    phase11_git_issue(result, "unexpected_ignored_git_state")
    phase11_git_issue(result, "git_realization_inventory_mismatch")
  },

  "machine paths and hidden sibling dependencies are diagnosed" = function() {
    proof <- phase11_git_proof(repository_root, suite_root)
    machine <- phase11_copy_git_tree(
      proof$first_destination, file.path(suite_root, "git-machine-path")
    )
    write(paste0("/", "Users", "/developer/private/source\n"),
          file.path(machine, "README.md"), append = TRUE)
    phase11_git_issue(rrp_validate_hospital_git_realization(
      machine, TRUE, FALSE
    ), "nonportable_sensitive_or_sibling_content")
    sibling <- phase11_copy_git_tree(
      proof$first_destination, file.path(suite_root, "git-sibling-path")
    )
    write(paste0("..", "/readmission-risk-pool/private.R\n"),
          file.path(sibling, "README.md"), append = TRUE)
    phase11_git_issue(rrp_validate_hospital_git_realization(
      sibling, TRUE, FALSE
    ), "nonportable_sensitive_or_sibling_content")
  },

  "realization contains no CentralStatz distribution builder or source path" = function() {
    proof <- phase11_git_proof(repository_root, suite_root)
    tree <- rrp_hospital_git_scan_tree(proof$first_destination)
    phase0_assert_false(any(tree$files %in% c(
      "operations/build-hospital-distribution.R",
      "operations/build-hospital-git-realization.R",
      "operations/validate-hospital-git-realization.R"
    )))
    manifest <- rrp_hospital_read_yaml(file.path(
      proof$first_destination, "HOSPITAL-GIT-REALIZATION.yml"
    ))
    phase0_assert_false(any(grepl(
      normalizePath(repository_root), unlist(manifest), fixed = TRUE
    )))
    phase0_assert_true(identical(manifest$provenance$authoritative_source_lookup, FALSE))
  }
)
