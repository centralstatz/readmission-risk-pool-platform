phase10_cached <- local({
  value <- NULL
  function(repository_root) {
    if (is.null(value)) value <<- rrp_installed_canonical_producer_composition(repository_root)
    value
  }
})

phase10_invocation <- function(id = "producer_conformance_test_001") list(
  producer_execution_id = id,
  canonical_as_of_time = NULL,
  producer_configuration = list(scale = "test")
)

phase10_execute <- function(repository_root, registry = NULL, id = NULL, version = NULL) {
  composition <- phase10_cached(repository_root)
  selection <- composition$selection
  rrp_execute_canonical_producer(
    registry %||% composition$registry,
    id %||% selection$producer_id,
    version %||% selection$producer_version,
    phase10_invocation(), repository_root
  )
}

phase10_test_cases <- function(repository_root) {
  list(
    "canonical producer contract and shipped declaration conform" = function() {
      composition <- phase10_cached(repository_root)
      entry <- rrp_resolve_canonical_producer(
        composition$registry, composition$selection$producer_id,
        composition$selection$producer_version
      )
      result <- rrp_validate_canonical_producer_declaration(
        entry$declaration, composition$contract
      )
      phase0_assert_true(rrp_conforms(result))
      phase0_assert_true(identical(
        composition$contract$specification_id, "platform.canonical-producer"
      ))
    },

    "invalid producer declaration reports structured failure" = function() {
      composition <- phase10_cached(repository_root)
      entry <- rrp_resolve_canonical_producer(
        composition$registry, composition$selection$producer_id,
        composition$selection$producer_version
      )
      invalid <- entry$declaration
      invalid$mapping_identity <- invalid$implementation_identity
      result <- rrp_validate_canonical_producer_declaration(invalid, composition$contract)
      phase0_assert_true(!rrp_conforms(result))
      phase0_assert_true("invalid_mapping_identity" %in% result$issues$issue_code)
    },

    "declaration cannot execute without trusted registration" = function() {
      composition <- phase10_cached(repository_root)
      empty <- rrp_new_canonical_producer_registry()
      phase0_assert_error(
        rrp_resolve_canonical_producer(
          empty, composition$selection$producer_id,
          composition$selection$producer_version
        ), "unknown_registered_producer"
      )
      phase0_assert_true(!any(names(composition$configuration) %in% c(
        "path", "function", "package", "script", "executable"
      )))
    },

    "duplicate trusted registration is rejected" = function() {
      composition <- phase10_cached(repository_root)
      entry <- rrp_resolve_canonical_producer(
        composition$registry, composition$selection$producer_id,
        composition$selection$producer_version
      )
      registry <- rrp_new_canonical_producer_registry()
      rrp_register_canonical_producer(
        registry, entry$declaration, entry$adapter, composition$contract
      )
      phase0_assert_error(
        rrp_register_canonical_producer(
          registry, entry$declaration, entry$adapter, composition$contract
        ), "duplicate_registered_producer"
      )
    },

    "selection resolves exact producer ID and version" = function() {
      composition <- phase10_cached(repository_root)
      selected <- composition$selection
      entry <- rrp_resolve_canonical_producer(
        composition$registry, selected$producer_id, selected$producer_version
      )
      phase0_assert_true(identical(entry$declaration$producer_id, selected$producer_id))
      phase0_assert_error(
        rrp_resolve_canonical_producer(
          composition$registry, selected$producer_id, "0.1.1"
        ), "unknown_registered_producer"
      )
    },

    "generic producer result succeeds with admitted canonical output" = function() {
      result <- phase10_execute(repository_root)
      phase0_assert_true(identical(result$overall_status, "succeeded"))
      phase0_assert_true(!is.null(result$canonical_bundle))
      phase0_assert_true(rrp_conforms(rrp_validate_canonical_producer_result(result)))
      phase0_assert_true(identical(result$stage_statuses[["canonical_admission"]], "succeeded"))
    },

    "producer failure has no canonical output and short circuits admission" = function() {
      composition <- phase10_cached(repository_root)
      entry <- rrp_resolve_canonical_producer(
        composition$registry, composition$selection$producer_id,
        composition$selection$producer_version
      )
      failing <- function(invocation) rrp_new_canonical_producer_adapter_result(
        "failed", invocation$producer_execution_id,
        entry$declaration$implementation_identity,
        entry$declaration$mapping_identity, NULL, "2026-08-01T12:00:00Z",
        entry$declaration$capabilities,
        c(producer_configuration = "succeeded", source_local_validation = "failed", mapping = "not_run")
      )
      registry <- rrp_new_canonical_producer_registry()
      rrp_register_canonical_producer(
        registry, entry$declaration, failing, composition$contract
      )
      result <- phase10_execute(repository_root, registry)
      phase0_assert_true(identical(result$overall_status, "failed"))
      phase0_assert_true(is.null(result$canonical_bundle))
      phase0_assert_true(identical(result$stage_statuses[["canonical_admission"]], "not_run"))
    },

    "invalid candidate never becomes canonical output" = function() {
      composition <- phase10_cached(repository_root)
      entry <- rrp_resolve_canonical_producer(
        composition$registry, composition$selection$producer_id,
        composition$selection$producer_version
      )
      invalid_adapter <- function(invocation) {
        value <- entry$adapter(invocation)
        value$candidate_bundle$bundle_instance_id <- "bad id"
        value
      }
      registry <- rrp_new_canonical_producer_registry()
      rrp_register_canonical_producer(
        registry, entry$declaration, invalid_adapter, composition$contract
      )
      result <- phase10_execute(repository_root, registry)
      phase0_assert_true(identical(result$overall_status, "failed"))
      phase0_assert_true(is.null(result$canonical_bundle))
      phase0_assert_true(identical(result$stage_statuses[["canonical_admission"]], "failed"))
    },

    "shipped producer passes reusable conformance" = function() {
      composition <- phase10_cached(repository_root)
      result <- rrp_conform_registered_canonical_producer(
        composition$registry, composition$selection$producer_id,
        composition$selection$producer_version,
        phase10_invocation(), repository_root
      )
      phase0_assert_true(rrp_conforms(result))
    },

    "implementation mapping and other adapter identities remain distinct" = function() {
      result <- phase10_execute(repository_root)
      phase0_assert_true(!identical(
        result$implementation_identity$implementation_id,
        result$mapping_identity$mapping_id
      ))
      unrelated <- c(
        "reference.transparent-readmission-hazard",
        "reference.duckdb-persistence", "reference.yaml-product-bundle"
      )
      phase0_assert_true(!result$producer_reference$producer_id %in% unrelated)
    },

    "canonical as-of profile capabilities and provenance are preserved" = function() {
      result <- phase10_execute(repository_root)
      bundle <- result$canonical_bundle
      phase0_assert_true(identical(result$canonical_as_of_time, bundle$run_context$as_of_time))
      phase0_assert_true(identical(
        result$canonical_profile$specification_id,
        "platform.readmission-initial-profile"
      ))
      phase0_assert_true(identical(
        rrp_ordered_capabilities(result$capabilities),
        rrp_bundle_capabilities(bundle)
      ))
      phase0_assert_true(length(result$provenance_references) > 0L)
    },

    "final generic result exposes no source representation" = function() {
      result <- phase10_execute(repository_root)
      prohibited <- c("source", "source_tables", "configuration", "credentials", "connection")
      phase0_assert_true(!any(names(result) %in% prohibited))
      phase0_assert_true(!any(names(result$canonical_bundle) %in% prohibited))
    },

    "platform run invokes installed producer without source orchestration" = function() {
      text <- paste(readLines(
        file.path(repository_root, "operations", "run-platform.R"), warn = FALSE
      ), collapse = "\n")
      phase0_assert_true(grepl("rrp_run_reference_history", text, fixed = TRUE))
      phase0_assert_true(!grepl("synthetic-reference|rrp_run_synthetic|generate-source|map-to-canonical", text))
      history <- paste(readLines(file.path(
        repository_root, "operations", "lib", "reference-history-operation.R"
      ), warn = FALSE), collapse = "\n")
      phase0_assert_true(grepl("rrp_run_installed_canonical_producer", history, fixed = TRUE))
      phase0_assert_true(!grepl("rrp_run_synthetic_reference", history, fixed = TRUE))
    },

    "runtime persistence products and app remain source independent" = function() {
      files <- c(
        list.files(file.path(repository_root, "runtime", "R"), full.names = TRUE),
        list.files(file.path(repository_root, "products"), pattern = "[.]R$", recursive = TRUE, full.names = TRUE),
        list.files(file.path(repository_root, "app"), pattern = "[.]R$", recursive = TRUE, full.names = TRUE),
        list.files(file.path(repository_root, "implementations", "persistence"), pattern = "[.]R$", recursive = TRUE, full.names = TRUE)
      )
      text <- paste(unlist(lapply(files, readLines, warn = FALSE)), collapse = "\n")
      phase0_assert_true(!grepl(
        "synthetic-reference|patient_registry|risk_scores|activity_events|terminal_outcomes",
        text
      ))
    },

    "platform instance selects one producer without tenancy semantics" = function() {
      configuration <- phase10_cached(repository_root)$configuration
      phase0_assert_true(identical(configuration$health_system_scope, "one"))
      phase0_assert_true(identical(configuration$multi_tenant, FALSE))
      phase0_assert_true(identical(length(configuration$selected_canonical_producer), 2L))
      phase0_assert_true(is.null(configuration$available_hospitals))
    }
  )
}
