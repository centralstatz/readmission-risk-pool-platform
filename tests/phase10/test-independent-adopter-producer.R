phase10_adopter_payload_records <- function(bundle, domain_id) {
  registration <- Filter(function(value) identical(value$domain_id, domain_id), bundle$domains)
  if (length(registration) != 1L || is.null(registration[[1L]]$domain_instance_id)) {
    return(list())
  }
  instance_id <- registration[[1L]]$domain_instance_id
  payload <- Filter(function(value) {
    identical(value$domain_instance_id, instance_id)
  }, bundle$reference_test_realization$domain_payloads)
  if (length(payload) == 0L) list() else payload[[1L]]$records
}

phase10_adopter_invocation <- function(
  as_of_time = NULL,
  execution_id = "producer_adopter_shared_conformance_001"
) list(
  producer_execution_id = execution_id,
  canonical_as_of_time = as_of_time,
  producer_configuration = list(scenario_id = "fictional_export_case_v1")
)

phase10_read_valid_history <- function(repository_root, database, run_id) {
  contracts <- rrp_read_history_contracts(repository_root)
  session <- rrp_open_duckdb_persistence(database, contracts, read_only = TRUE)
  on.exit(rrp_close_duckdb_persistence(session), add = TRUE)
  rrpruntime::read_run_history(rrp_duckdb_persistence_port(session), run_id, "valid")
}

phase10_composition_proof <- local({
  cached <- NULL
  function(repository_root, suite_root) {
    if (!is.null(cached)) return(cached)
    reference_database <- file.path(suite_root, "reference-history.duckdb")
    adopter_database <- file.path(suite_root, "adopter-history.duckdb")
    reference_products <- file.path(suite_root, "reference-products")
    adopter_products <- file.path(suite_root, "adopter-products")
    adopter_artifacts <- file.path(suite_root, "adopter-artifacts")

    reference_producer <- rrp_run_installed_canonical_producer(
      repository_root, "test", producer_execution_id = "producer_reference_composition_a_001"
    )
    reference_history <- rrp_run_reference_history(
      repository_root, "test", reference_database,
      runtime_run_id = "runtime_reference_composition_a_001",
      producer_result = reference_producer
    )
    reference_build <- rrp_build_reference_products(
      repository_root, reference_database, reference_history$runtime_run_id,
      product_generated_at = "2026-08-20T14:00:00Z"
    )
    rrp_materialize_reference_products(
      reference_build, repository_root, reference_products, "2026-08-20T14:10:00Z"
    )
    reference_access <- rrp_open_reference_product_access(
      repository_root, reference_products
    )
    reference_app <- rrp_initialize_reference_app(reference_access$access)

    adopter_producer <- rrp_run_adopter_fixture_producer(
      repository_root, producer_execution_id = "producer_adopter_composition_b_001"
    )
    adopter_history <- rrp_run_reference_history(
      repository_root, "test", adopter_database,
      runtime_run_id = "runtime_adopter_composition_b_001",
      producer_result = adopter_producer
    )
    adopter_build <- rrp_build_reference_products(
      repository_root, adopter_database, adopter_history$runtime_run_id,
      product_generated_at = "2026-08-20T15:00:00Z"
    )
    rrp_materialize_reference_products(
      adopter_build, repository_root, adopter_products, "2026-08-20T15:10:00Z"
    )
    adopter_access <- rrp_open_reference_product_access(repository_root, adopter_products)
    adopter_app <- rrp_initialize_reference_app(adopter_access$access)
    artifact <- rrp_build_reference_application_artifact(
      repository_root, adopter_products, adopter_artifacts, "2026-08-20T15:20:00Z"
    )
    artifact_validation <- rrp_validate_application_artifact(artifact$artifact_path)

    cached <<- list(
      reference = list(
        producer = reference_producer, history = reference_history,
        retained = phase10_read_valid_history(
          repository_root, reference_database, reference_history$runtime_run_id
        ),
        build = reference_build, access = reference_access, app = reference_app,
        database = reference_database, products = reference_products
      ),
      adopter = list(
        producer = adopter_producer, history = adopter_history,
        retained = phase10_read_valid_history(
          repository_root, adopter_database, adopter_history$runtime_run_id
        ),
        build = adopter_build, access = adopter_access, app = adopter_app,
        artifact = artifact, artifact_validation = artifact_validation,
        database = adopter_database, products = adopter_products
      )
    )
    cached
  }
})

phase10_test_cases <- function(repository_root, suite_root) list(
  "adopter fixture is materially different test-only source evidence" = function() {
    source <- rrp_adopter_fixture_source()
    phase0_assert_true(identical(names(source), c("case_extract", "activity_feed")))
    phase0_assert_true(!any(names(source) %in% c(
      "patients", "encounters", "discharges", "risk_scores",
      "activity_events", "outcomes"
    )))
    phase0_assert_true(all(c(
      "case_ref", "subject_token", "closure_code", "terminal_loaded_local"
    ) %in% names(source$case_extract)))
    readme <- paste(readLines(file.path(
      rrp_adopter_fixture_root(repository_root), "README.md"
    ), warn = FALSE), collapse = "\n")
    phase0_assert_true(grepl("test evidence, not a second shipped", readme, fixed = TRUE))
  },

  "adopter declaration and isolated exact selection conform" = function() {
    composition <- rrp_adopter_fixture_composition(repository_root)
    selection <- composition$selection
    declaration <- rrp_resolve_canonical_producer(
      composition$registry, selection$producer_id, selection$producer_version
    )$declaration
    phase0_assert_true(rrp_conforms(rrp_validate_canonical_producer_declaration(
      declaration, composition$contract
    )))
    phase0_assert_true(identical(length(composition$registry$entries), 1L))
    phase0_assert_true(identical(composition$configuration$health_system_scope, "one"))
    phase0_assert_true(identical(composition$configuration$multi_tenant, FALSE))
    phase0_assert_true(identical(
      declaration$capabilities[["platform.baseline-risk-input"]], "unsupported"
    ))
  },

  "shared producer conformance passes unchanged for both peers" = function() {
    reference <- rrp_installed_canonical_producer_composition(repository_root)
    reference_result <- rrp_conform_registered_canonical_producer(
      reference$registry, reference$selection$producer_id,
      reference$selection$producer_version,
      list(
        producer_execution_id = "producer_reference_shared_conformance_001",
        canonical_as_of_time = NULL,
        producer_configuration = list(scale = "test")
      ),
      repository_root
    )
    adopter <- rrp_adopter_fixture_composition(repository_root)
    adopter_result <- rrp_conform_registered_canonical_producer(
      adopter$registry, adopter$selection$producer_id,
      adopter$selection$producer_version, phase10_adopter_invocation(), repository_root
    )
    phase0_assert_true(rrp_conforms(reference_result))
    phase0_assert_true(rrp_conforms(adopter_result))
  },

  "adopter source validation accumulates issues and short circuits" = function() {
    invalid <- rrp_adopter_fixture_source()
    invalid$case_extract$case_ref[[2L]] <- invalid$case_extract$case_ref[[1L]]
    invalid$activity_feed$case_ref[[2L]] <- "UNKNOWN|CASE"
    invalid$activity_feed$fact_code[[1L]] <- "UNMAPPED_LOCAL_CODE"
    result <- rrp_run_adopter_fixture_producer(
      repository_root,
      producer_execution_id = "producer_adopter_invalid_source_001",
      source_override = invalid
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
    source_result <- result$conformance_results$source_local_validation
    phase0_assert_true(nrow(source_result$issues) >= 3L)
    phase0_assert_true(all(c(
      "duplicate_or_missing_adopter_source_id",
      "unresolved_adopter_case_reference", "invalid_adopter_source_code"
    ) %in% source_result$issues$issue_code))
  },

  "adopter dual-time filtering preserves late source facts until available" = function() {
    early <- rrp_run_adopter_fixture_producer(
      repository_root, "2026-08-10T17:00:00Z", "producer_adopter_early_001"
    )
    later <- rrp_run_adopter_fixture_producer(
      repository_root, "2026-08-12T17:00:00Z", "producer_adopter_later_001"
    )
    phase0_assert_true(identical(early$overall_status, "succeeded"))
    phase0_assert_true(identical(later$overall_status, "succeeded"))
    early_events <- phase10_adopter_payload_records(early$canonical_bundle, "episode_event")
    later_events <- phase10_adopter_payload_records(later$canonical_bundle, "episode_event")
    early_ids <- vapply(early_events, `[[`, character(1), "event_id")
    later_ids <- vapply(later_events, `[[`, character(1), "event_id")
    delayed_id <- "adopter_event_feed_205"
    phase0_assert_false(delayed_id %in% early_ids)
    phase0_assert_true(delayed_id %in% later_ids)
    phase0_assert_true(identical(early$summary$future_source_records_excluded, 1L))
    phase0_assert_true(identical(later$summary$future_source_records_excluded, 0L))
    phase0_assert_true(identical(
      later$canonical_as_of_time, later$canonical_bundle$run_context$as_of_time
    ))
  },

  "adopter identities provenance and unsupported capability stay explicit" = function() {
    result <- rrp_run_adopter_fixture_producer(repository_root)
    identities <- rrp_adopter_fixture_identities()
    phase0_assert_true(identical(result$implementation_identity, identities$implementation))
    phase0_assert_true(identical(result$mapping_identity, identities$mapping))
    phase0_assert_false(identical(
      result$producer_reference$producer_id,
      "reference.synthetic-canonical-producer"
    ))
    phase0_assert_true(identical(
      result$capabilities[["platform.baseline-risk-input"]], "unsupported"
    ))
    phase0_assert_true(length(
      phase10_adopter_payload_records(result$canonical_bundle, "baseline_risk")
    ) == 0L)
    provenance_ids <- vapply(
      result$provenance_references, `[[`, character(1), "provenance_id"
    )
    phase0_assert_true(identities$source_schema$source_schema_id %in% provenance_ids)
    phase0_assert_true(identities$mapping$mapping_id %in% provenance_ids)
  },

  "adopter producer lifecycle diagnostics use the existing safe contract" = function() {
    context <- rrp_new_operation_context(
      "platform.validate-producer", "operation-run::adopter-observability",
      started_at = "2026-08-20T12:00:00Z"
    )
    emitter <- rrp_new_event_emitter(context)
    rrp_emit_operational_event(
      emitter, "operations", "operation", "info", "operation_started",
      "operation.started", "Operation started."
    )
    result <- rrp_run_adopter_fixture_producer(
      repository_root, producer_execution_id = "producer_adopter_observed_001",
      event_emitter = emitter
    )
    phase0_assert_true(identical(result$overall_status, "succeeded"))
    events <- rrp_emitted_events(emitter)
    stages <- vapply(events, `[[`, character(1), "stage")
    phase0_assert_true(all(c(
      "producer_resolution", "producer_execution", "canonical_admission"
    ) %in% stages))
    serialized <- paste(vapply(events, function(event) {
      paste(capture.output(str(event)), collapse = " ")
    }, character(1)), collapse = " ")
    phase0_assert_false(grepl(
      "case_ref|activity_feed|SUBJECT/|ZONE-[AB]|FEED-20", serialized
    ))
  },

  "both isolated compositions reach the same unchanged downstream stack" = function() {
    proof <- phase10_composition_proof(repository_root, suite_root)
    phase0_assert_false(identical(
      normalizePath(proof$reference$database), normalizePath(proof$adopter$database)
    ))
    phase0_assert_true(identical(
      proof$reference$producer$canonical_profile,
      proof$adopter$producer$canonical_profile
    ))
    phase0_assert_true(identical(
      proof$reference$history$adapter, proof$adopter$history$adapter
    ))
    phase0_assert_true(length(proof$adopter$retained$estimate) > 0L)
    phase0_assert_true(all(vapply(
      proof$adopter$retained$estimate,
      function(value) identical(
        value$provider_reference$provider_id,
        "reference.transparent-readmission-hazard"
      ), logical(1)
    )))
    reference_products <- vapply(
      proof$reference$build$products,
      function(value) value$product_specification$specification_id,
      character(1)
    )
    adopter_products <- vapply(
      proof$adopter$build$products,
      function(value) value$product_specification$specification_id,
      character(1)
    )
    phase0_assert_true(identical(reference_products, adopter_products))
    phase0_assert_true(identical(proof$reference$app$overall_status, "succeeded"))
    phase0_assert_true(identical(proof$adopter$app$overall_status, "succeeded"))
  },

  "adopter-derived reduced artifact validates without source integration content" = function() {
    proof <- phase10_composition_proof(repository_root, suite_root)$adopter
    phase0_assert_true(identical(proof$artifact$overall_status, "succeeded"))
    phase0_assert_true(identical(proof$artifact_validation$overall_status, "pass"))
    paths <- list.files(
      proof$artifact$artifact_path, recursive = TRUE, all.files = TRUE, no.. = TRUE
    )
    text_files <- paths[grepl("[.](R|yml|json|md)$", paths)]
    text <- paste(unlist(lapply(file.path(
      proof$artifact$artifact_path, text_files
    ), readLines, warn = FALSE)), collapse = "\n")
    phase0_assert_false(grepl(
      "case_extract|activity_feed|case_ref|fact_code|adopter-extract-canonical-producer",
      paste(c(paths, text), collapse = "\n")
    ))
    phase0_assert_false(any(grepl("duckdb|source-schema|mapping[.]R", paths)))
  },

  "generic downstream code has no source-specific branches" = function() {
    roots <- c(
      "runtime", "products", "app", "deploy",
      "implementations/persistence", "contracts/observability"
    )
    files <- c(unlist(lapply(roots, function(root) list.files(
      file.path(repository_root, root), recursive = TRUE, full.names = TRUE
    ))), file.path(
      repository_root, "operations", "lib",
      c(
        "canonical-bundle-validation.R", "canonical-clinical-validation.R",
        "canonical-producer-operation.R"
      )
    ))
    files <- files[file.info(files)$isdir %in% FALSE]
    text <- paste(unlist(lapply(files, readLines, warn = FALSE)), collapse = "\n")
    prohibited <- paste(c(
      "case_extract", "activity_feed", "case_ref", "closure_code",
      "fact_code", "risk_scores", "activity_events", "source_episode_label",
      "source_queue_label", "source_note_class", "CALL_OK", "RETURN_NOTICE",
      "adopter-producer",
      "conformance.adopter-extract-canonical-producer"
    ), collapse = "|")
    phase0_assert_false(grepl(prohibited, text))
  },

  "default installation remains the single shipped reference producer" = function() {
    reference <- rrp_installed_canonical_producer_composition(repository_root)
    phase0_assert_true(identical(
      reference$selection$producer_id, "reference.synthetic-canonical-producer"
    ))
    phase0_assert_true(identical(length(reference$registry$entries), 1L))
    configuration <- reference$configuration
    phase0_assert_true(is.null(configuration$available_hospitals))
    phase0_assert_true(is.null(configuration$producer_selector))
    phase0_assert_true(identical(configuration$health_system_scope, "one"))
  }
)
