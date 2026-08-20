# Trusted adapter for the independent adopter fixture. Raw source objects stay
# inside this closure and never appear in the generic producer result.

rrp_read_adopter_fixture_declaration <- function(repository_root) {
  rrp_adopter_fixture_read_yaml(repository_root, "producer.yml")
}

rrp_adopter_fixture_summary <- function(source, mapped, configuration) {
  as_of <- rrp_timestamp_number(configuration$canonical_as_of_time)
  future_activity <- sum(
    rrp_adopter_local_time_number(source$activity_feed$loaded_local) > as_of
  )
  future_terminal <- sum(
    !is.na(source$case_extract$terminal_loaded_local) &
      rrp_adopter_local_time_number(source$case_extract$terminal_loaded_local) > as_of
  )
  list(
    source_object_count = length(source),
    source_row_count = sum(vapply(source, nrow, integer(1))),
    discharge_episodes = length(mapped$discharge_episodes %||% list()),
    baseline_records = 0L,
    event_records = length(mapped$episode_events %||% list()),
    future_source_records_excluded = as.integer(future_activity + future_terminal)
  )
}

rrp_adopter_fixture_adapter <- function(repository_root, source_override = NULL) {
  force(repository_root)
  force(source_override)
  function(invocation) {
    declaration <- rrp_read_adopter_fixture_declaration(repository_root)
    configuration <- rrp_adopter_fixture_read_yaml(
      repository_root, "source-configuration.yml"
    )
    requested_scenario <- invocation$producer_configuration$scenario_id %||%
      configuration$scenario_id
    configuration$scenario_id <- requested_scenario
    if (!is.null(invocation$canonical_as_of_time)) {
      configuration$canonical_as_of_time <- invocation$canonical_as_of_time
    }
    configuration_result <- rrp_validate_adopter_configuration(configuration)
    base_stages <- c(
      producer_configuration = if (rrp_conforms(configuration_result)) "succeeded" else "failed",
      source_local_validation = "not_run", mapping = "not_run"
    )
    if (!rrp_conforms(configuration_result)) return(
      rrp_new_canonical_producer_adapter_result(
        "failed", invocation$producer_execution_id,
        declaration$implementation_identity, declaration$mapping_identity,
        NULL, configuration$canonical_as_of_time, declaration$capabilities,
        base_stages, conformance_results = list(configuration = configuration_result)
      )
    )

    source <- source_override %||% rrp_adopter_fixture_source()
    schema <- rrp_adopter_fixture_read_yaml(repository_root, "source-schema.yml")
    source_result <- rrp_validate_adopter_source(source, schema)
    base_stages[["source_local_validation"]] <- if (rrp_conforms(source_result)) {
      "succeeded"
    } else {
      "failed"
    }
    if (!rrp_conforms(source_result)) return(
      rrp_new_canonical_producer_adapter_result(
        "failed", invocation$producer_execution_id,
        declaration$implementation_identity, declaration$mapping_identity,
        NULL, configuration$canonical_as_of_time, declaration$capabilities,
        base_stages,
        conformance_results = list(
          configuration = configuration_result,
          source_local_validation = source_result
        ),
        summary = list(
          source_object_count = length(source),
          source_row_count = sum(vapply(source, nrow, integer(1)))
        )
      )
    )

    mapped <- rrp_map_adopter_source_to_canonical(source, configuration)
    base_stages[["mapping"]] <- if (rrp_conforms(mapped$conformance)) {
      "succeeded"
    } else {
      "failed"
    }
    succeeded <- rrp_conforms(mapped$conformance)
    rrp_new_canonical_producer_adapter_result(
      if (succeeded) "succeeded" else "failed",
      invocation$producer_execution_id,
      declaration$implementation_identity,
      declaration$mapping_identity,
      if (succeeded) mapped$candidate_bundle$profile_specification else NULL,
      configuration$canonical_as_of_time,
      declaration$capabilities,
      base_stages,
      conformance_results = list(
        configuration = configuration_result,
        source_local_validation = source_result,
        mapping = mapped$conformance
      ),
      provenance_references = if (succeeded) {
        mapped$candidate_bundle$provenance_references
      } else {
        list()
      },
      candidate_bundle = if (succeeded) mapped$candidate_bundle else NULL,
      summary = rrp_adopter_fixture_summary(source, mapped, configuration)
    )
  }
}
