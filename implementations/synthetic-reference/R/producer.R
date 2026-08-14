# One implementation-owned source-to-canonical producer composition.

rrp_synthetic_stage_failure <- function(
  stage,
  issue_code,
  message,
  specification = rrp_synthetic_implementation_specification_identity()
) {
  rrp_synthetic_result(
    list(),
    list(rrp_synthetic_issue(
      paste0("synthetic.", stage), issue_code, message,
      paste0("$.", stage), specification = specification
    )),
    specification
  )
}

rrp_synthetic_reference_summary <- function(producer_result) {
  source <- producer_result$source
  bundle <- producer_result$candidate_bundle
  empty <- list(
    patients = 0L, encounters = 0L, discharge_episodes = 0L,
    baseline_records = 0L, event_records = 0L, readmissions = 0L,
    deaths = 0L, active_episodes = 0L, future_source_records_excluded = 0L
  )
  if (is.null(source) || is.null(bundle)) return(empty)

  payloads <- bundle$reference_test_realization$domain_payloads
  records_for <- function(domain_id) {
    domain <- rrp_clinical_registration(bundle, "domains", domain_id)
    index <- match(
      domain$domain_instance_id,
      vapply(payloads, `[[`, character(1), "domain_instance_id")
    )
    payloads[[index]]$records
  }
  episodes <- records_for("discharge_episode")
  baselines <- records_for("baseline_risk")
  events <- records_for("episode_event")
  as_of <- rrp_timestamp_number(bundle$run_context$as_of_time)
  active <- vapply(episodes, function(record) {
    is.null(record$readmission_time) && is.null(record$death_time) &&
      rrp_timestamp_number(record$followup_window_end) > as_of
  }, logical(1))
  available_by_as_of <- function(table, field) {
    if (nrow(table) == 0L) return(logical())
    rrp_timestamp_number(table[[field]]) <= as_of
  }
  future_excluded <- sum(!available_by_as_of(source$risk_scores, "received_at")) +
    sum(!available_by_as_of(source$activity_events, "received_at")) +
    sum(!available_by_as_of(source$outcomes, "received_at"))

  list(
    patients = nrow(source$patients),
    encounters = nrow(source$encounters),
    discharge_episodes = length(episodes),
    baseline_records = length(baselines),
    event_records = length(events),
    readmissions = sum(vapply(episodes, function(record) {
      !is.null(record$readmission_time)
    }, logical(1))),
    deaths = sum(vapply(episodes, function(record) {
      !is.null(record$death_time)
    }, logical(1))),
    active_episodes = sum(active),
    future_source_records_excluded = future_excluded
  )
}

rrp_produce_synthetic_from_source <- function(
  source,
  config,
  implementation,
  source_schema,
  repository_root,
  configuration_conformance = NULL,
  location = NA_character_,
  perform_canonical_admission = TRUE
) {
  stages <- c(
    configuration = "succeeded",
    generation = "succeeded",
    source_local_validation = "not_run",
    mapping = "not_run",
    canonical_conformance = "not_run"
  )
  source_result <- rrp_validate_synthetic_source(source, source_schema, location)
  stages[["source_local_validation"]] <- if (rrp_conforms(source_result)) {
    "succeeded"
  } else {
    "failed"
  }
  if (!rrp_conforms(source_result)) {
    result <- structure(list(
      overall_status = "failed",
      stage_statuses = stages,
      configuration_conformance = configuration_conformance,
      generation_conformance = NULL,
      source = source,
      source_local_conformance = source_result,
      mapping_conformance = NULL,
      candidate_bundle = NULL,
      canonical_conformance = NULL,
      implementation_identity = implementation$implementation_identity,
      mapping_identity = implementation$mapping_identity,
      generator_identity = implementation$generator_identity,
      source_schema_identity = implementation$source_schema_identity,
      provenance_references = list()
    ), class = "rrp_synthetic_producer_result")
    result$summary <- rrp_synthetic_reference_summary(result)
    return(result)
  }

  mapping <- tryCatch(
    rrp_map_synthetic_source_to_canonical(
      source, config, implementation, location
    ),
    error = function(condition) list(
      candidate_bundle = NULL,
      domain_records = list(),
      conformance = rrp_synthetic_stage_failure(
        "mapping", "mapping_failed", conditionMessage(condition),
        rrp_synthetic_mapping_specification_identity()
      )
    )
  )
  stages[["mapping"]] <- if (rrp_conforms(mapping$conformance)) {
    "succeeded"
  } else {
    "failed"
  }
  if (!rrp_conforms(mapping$conformance)) {
    result <- structure(list(
      overall_status = "failed",
      stage_statuses = stages,
      configuration_conformance = configuration_conformance,
      generation_conformance = NULL,
      source = source,
      source_local_conformance = source_result,
      mapping_conformance = mapping$conformance,
      candidate_bundle = NULL,
      canonical_conformance = NULL,
      implementation_identity = implementation$implementation_identity,
      mapping_identity = implementation$mapping_identity,
      generator_identity = implementation$generator_identity,
      source_schema_identity = implementation$source_schema_identity,
      provenance_references = list()
    ), class = "rrp_synthetic_producer_result")
    result$summary <- rrp_synthetic_reference_summary(result)
    return(result)
  }

  canonical_result <- if (isTRUE(perform_canonical_admission)) {
    rrp_validate_clinical_bundle_instance(
      mapping$candidate_bundle, repository_root, location
    )
  } else {
    NULL
  }
  stages[["canonical_conformance"]] <- if (rrp_conforms(canonical_result)) {
    "succeeded"
  } else if (is.null(canonical_result)) {
    "not_run"
  } else {
    "failed"
  }
  success <- is.null(canonical_result) || rrp_conforms(canonical_result)
  result <- structure(list(
    overall_status = if (success) "succeeded" else "failed",
    stage_statuses = stages,
    configuration_conformance = configuration_conformance,
    generation_conformance = NULL,
    source = source,
    source_local_conformance = source_result,
    mapping_conformance = mapping$conformance,
    candidate_bundle = mapping$candidate_bundle,
    canonical_conformance = canonical_result,
    implementation_identity = implementation$implementation_identity,
    mapping_identity = implementation$mapping_identity,
    generator_identity = implementation$generator_identity,
    source_schema_identity = implementation$source_schema_identity,
    provenance_references = mapping$candidate_bundle$provenance_references
  ), class = "rrp_synthetic_producer_result")
  result$summary <- rrp_synthetic_reference_summary(result)
  result
}

rrp_run_synthetic_reference <- function(
  repository_root,
  scale = "reference",
  configuration = NULL,
  perform_canonical_admission = TRUE
) {
  implementation <- rrp_read_synthetic_implementation_specification(repository_root)
  source_schema <- rrp_read_synthetic_source_schema(repository_root)
  config <- if (is.null(configuration)) {
    rrp_read_synthetic_configuration(repository_root, scale)
  } else {
    configuration
  }
  config_result <- rrp_validate_synthetic_configuration(
    config, implementation, paste0("config/", scale, ".yml")
  )
  if (!rrp_conforms(config_result)) {
    stages <- c(
      configuration = "failed",
      generation = "not_run",
      source_local_validation = "not_run",
      mapping = "not_run",
      canonical_conformance = "not_run"
    )
    result <- structure(list(
      overall_status = "failed",
      stage_statuses = stages,
      configuration_conformance = config_result,
      generation_conformance = NULL,
      source = NULL,
      source_local_conformance = NULL,
      mapping_conformance = NULL,
      candidate_bundle = NULL,
      canonical_conformance = NULL,
      implementation_identity = implementation$implementation_identity,
      mapping_identity = implementation$mapping_identity,
      generator_identity = implementation$generator_identity,
      source_schema_identity = implementation$source_schema_identity,
      provenance_references = list(),
      summary = rrp_synthetic_reference_summary(list())
    ), class = "rrp_synthetic_producer_result")
    return(result)
  }

  generation <- tryCatch(
    list(source = rrp_generate_synthetic_source(config), conformance = NULL),
    error = function(condition) list(
      source = NULL,
      conformance = rrp_synthetic_stage_failure(
        "generation", "generation_failed", conditionMessage(condition)
      )
    )
  )
  if (!is.null(generation$conformance)) {
    stages <- c(
      configuration = "succeeded",
      generation = "failed",
      source_local_validation = "not_run",
      mapping = "not_run",
      canonical_conformance = "not_run"
    )
    result <- structure(list(
      overall_status = "failed",
      stage_statuses = stages,
      configuration_conformance = config_result,
      generation_conformance = generation$conformance,
      source = NULL,
      source_local_conformance = NULL,
      mapping_conformance = NULL,
      candidate_bundle = NULL,
      canonical_conformance = NULL,
      implementation_identity = implementation$implementation_identity,
      mapping_identity = implementation$mapping_identity,
      generator_identity = implementation$generator_identity,
      source_schema_identity = implementation$source_schema_identity,
      provenance_references = list(),
      summary = rrp_synthetic_reference_summary(list())
    ), class = "rrp_synthetic_producer_result")
    return(result)
  }
  rrp_produce_synthetic_from_source(
    generation$source,
    config,
    implementation,
    source_schema,
    repository_root,
    config_result,
    paste0("synthetic:", scale),
    perform_canonical_admission
  )
}

print.rrp_synthetic_producer_result <- function(x, ...) {
  cat("Synthetic reference producer: ", x$overall_status, "\n", sep = "")
  for (stage in names(x$stage_statuses)) {
    cat("  ", stage, ": ", x$stage_statuses[[stage]], "\n", sep = "")
  }
  if (identical(x$overall_status, "succeeded")) {
    for (name in names(x$summary)) {
      cat("  ", name, ": ", x$summary[[name]], "\n", sep = "")
    }
  }
  invisible(x)
}
