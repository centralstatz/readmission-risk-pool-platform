# Adapter from the implementation-private synthetic result to the generic
# trusted canonical-producer callable boundary.

rrp_read_synthetic_producer_declaration <- function(repository_root) {
  rrp_synthetic_read_yaml(file.path(
    rrp_synthetic_implementation_root(repository_root), "producer.yml"
  ))
}

rrp_synthetic_canonical_producer_adapter <- function(repository_root) {
  force(repository_root)
  function(invocation) {
    scale <- invocation$producer_configuration$scale %||% "test"
    configuration <- rrp_read_synthetic_configuration(repository_root, scale)
    if (!is.null(invocation$canonical_as_of_time)) {
      configuration$simulation_as_of_time <- invocation$canonical_as_of_time
      configuration$canonical_as_of_time <- invocation$canonical_as_of_time
    }
    produced <- rrp_run_synthetic_reference(
      repository_root, scale, configuration,
      perform_canonical_admission = FALSE
    )
    succeeded <- identical(produced$overall_status, "succeeded")
    owned_stages <- produced$stage_statuses[c(
      "configuration", "source_local_validation", "mapping"
    )]
    names(owned_stages) <- c(
      "producer_configuration", "source_local_validation", "mapping"
    )
    rrp_new_canonical_producer_adapter_result(
      status = if (succeeded) "succeeded" else "failed",
      producer_execution_id = invocation$producer_execution_id,
      implementation_identity = produced$implementation_identity,
      mapping_identity = produced$mapping_identity,
      canonical_profile = if (succeeded) {
        produced$candidate_bundle$profile_specification
      } else {
        NULL
      },
      canonical_as_of_time = configuration$canonical_as_of_time,
      capabilities = as.list(c(
        "platform.discharge-episode" = "available",
        "platform.baseline-risk-input" = "available",
        "platform.episode-event-history" = "available"
      )),
      stage_statuses = owned_stages,
      conformance_results = Filter(Negate(is.null), list(
        configuration = produced$configuration_conformance,
        source_local_validation = produced$source_local_conformance,
        mapping = produced$mapping_conformance
      )),
      provenance_references = produced$provenance_references,
      candidate_bundle = if (succeeded) produced$candidate_bundle else NULL,
      summary = produced$summary
    )
  }
}
