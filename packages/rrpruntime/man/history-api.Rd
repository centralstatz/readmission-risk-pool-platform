\name{history-api}
\alias{validate_history_contracts}
\alias{new_operational_run_status}
\alias{validate_operational_run_status}
\alias{new_history_invalidation}
\alias{validate_history_invalidation}
\alias{validate_completed_run_batch}
\alias{validate_persistence_adapter}
\alias{new_persistence_port}
\alias{append_run_status}
\alias{append_completed_run}
\alias{append_history_invalidations}
\alias{read_history_record}
\alias{read_run_history}
\alias{read_episode_estimate_history}
\alias{read_current_estimate}
\title{Backend-independent operational history records and persistence ports}
\description{
Construct and validate append-oriented run and invalidation records, validate
atomic completed-run batches and adapter capabilities, and delegate governed
append/read behavior through an explicitly injected persistence adapter.
}
\usage{
validate_history_contracts(contracts)

new_operational_run_status(
  runtime_run_id, run_status, status_time, as_of_time, bundle_instance_id,
  canonical_run_id, implementation_reference, mapping_reference, contract,
  previous_run_status_record_id = NULL, status_summary = NULL,
  provenance_references = list()
)

validate_operational_run_status(record, contract)

new_history_invalidation(
  target_record_family, target_record_id, target_runtime_run_id,
  invalidated_at, reason_code, reason, contract,
  replacement_runtime_run_id = NULL, provenance_references = list()
)

validate_history_invalidation(record, contract)

validate_completed_run_batch(
  run_status, episode_states, estimand_requests,
  provider_execution_results, estimates, history_contracts
)

validate_persistence_adapter(adapter, contract)

new_persistence_port(adapter, history_contracts)

append_run_status(port, run_status)

append_completed_run(
  port, run_status, episode_states, estimand_requests,
  provider_execution_results, estimates
)

append_history_invalidations(port, invalidations)

read_history_record(port, record_family, record_id, view = c("valid", "raw"))

read_run_history(port, runtime_run_id, view = c("valid", "raw"))

read_episode_estimate_history(
  port, episode_id, estimand_id = NULL, view = c("valid", "raw")
)

read_current_estimate(port, episode_id, estimand_id, as_of_time)
}
\arguments{
  \item{contracts, history_contracts}{Named, explicitly injected history contracts.}
  \item{record}{An operational run status or invalidation record.}
  \item{runtime_run_id}{Stable identity of one platform runtime run.}
  \item{status_time, as_of_time, invalidated_at}{Explicit-offset timestamps.}
  \item{run_status}{Started, completed, completed-with-failures, or failed status.}
  \item{bundle_instance_id, canonical_run_id}{Admitted canonical context.}
  \item{implementation_reference, mapping_reference}{Versioned producer context.}
  \item{contract}{The relevant injected language-neutral contract.}
  \item{previous_run_status_record_id}{Started status referenced by a terminal status.}
  \item{status_summary}{Exact terminal batch counts.}
  \item{provenance_references}{Attribution records.}
  \item{target_record_family, target_record_id, target_runtime_run_id}{Invalidation target.}
  \item{reason_code, reason}{Machine-readable and human-readable correction reason.}
  \item{replacement_runtime_run_id}{Optional restatement run identity.}
  \item{episode_states, estimand_requests, provider_execution_results, estimates}{Atomic terminal batch families.}
  \item{adapter}{A declared adapter with the required callable methods and capabilities.}
  \item{port}{A validated persistence port.}
  \item{invalidations}{Invalidation record collection.}
  \item{record_family, record_id}{Exact record lookup identity.}
  \item{episode_id, estimand_id}{Episode and optional or required estimand filters.}
  \item{view}{Currently valid or retained raw history.}
}
\value{
Validators return conformance results; constructors return immutable semantic
records; the port constructor returns a validated port; append functions return
adapter acknowledgements; and read functions return records or null.
}
\details{
The API defines logical history only. It does not choose or implement durable
storage, products, replay, decision policy, deployment, or observability.
}
