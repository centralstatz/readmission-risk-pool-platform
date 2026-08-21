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
  }
)
