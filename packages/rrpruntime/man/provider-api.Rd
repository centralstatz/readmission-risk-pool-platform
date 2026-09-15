\name{provider-api}
\alias{validate_provider_contracts}
\alias{validate_provider_specification}
\alias{new_provider_registry}
\alias{register_provider}
\alias{list_registered_providers}
\alias{resolve_provider}
\alias{validate_provider_compatibility}
\alias{execute_provider}
\alias{reference_provider_adapter}
\alias{validate_estimate_record}
\title{Governed provider registration, execution, and estimate conformance}
\description{
Validate provider declarations, explicitly register trusted adapters, evaluate
compatibility, execute one provider-neutral request, and accept only a
conforming standardized estimate.
}
\usage{
validate_provider_contracts(contracts)

validate_provider_specification(specification, provider_contract)

new_provider_registry()

register_provider(registry, specification, adapter, provider_contract)

list_registered_providers(registry)

resolve_provider(registry, provider_id, provider_version)

validate_provider_compatibility(provider, request, state, runtime_contracts)

execute_provider(
  registry,
  provider_id,
  provider_version,
  request,
  state,
  provider_execution_run_id,
  runtime_contracts,
  provider_contracts,
  attempt_number = 1L,
  retry_of_execution_result_id = NULL
)

reference_provider_adapter(request, state, provider_specification)

validate_estimate_record(
  estimate,
  request,
  state,
  provider,
  estimate_contract
)
}
\arguments{
  \item{contracts}{Named, explicitly injected provider contracts.}
  \item{specification}{A language-neutral provider declaration.}
  \item{provider_contract}{The injected provider-specification contract.}
  \item{registry}{A controlled registry created by
  \code{new_provider_registry()}.}
  \item{adapter}{A trusted callable adapter registered by platform or adopter
  code, never loaded from ordinary configuration.}
  \item{provider_id}{Exact registered provider identity.}
  \item{provider_version}{Exact registered provider version.}
  \item{provider}{A validated provider declaration.}
  \item{request}{One accepted provider-neutral estimand request.}
  \item{state}{The matching immutable episode state.}
  \item{runtime_contracts}{Injected eligibility/state/estimand/request
  contracts.}
  \item{provider_execution_run_id}{Identity for the provider execution run.}
  \item{provider_contracts}{Injected declaration, adapter, execution-result,
  and estimate contracts.}
  \item{attempt_number}{Positive attempt sequence for the request/provider pair.}
  \item{retry_of_execution_result_id}{Null for attempt 1; otherwise the
  immediately preceding execution-result identity.}
  \item{provider_specification}{The registered declaration supplied to an
  adapter.}
  \item{estimate}{One standardized estimate candidate.}
  \item{estimate_contract}{The injected standardized estimate contract.}
}
\value{
Validation functions return conformance results. Registry creation and
registration return the controlled registry, listing returns a data frame,
resolution returns a registered entry, execution returns a structured provider
execution result, and the reference adapter returns one raw provider output.
}
\details{
The semantic contracts remain language-neutral. The current registry pairs
approved declarations with in-process R functions, while future controlled
adapters may bridge packages or services without changing request, estimate,
or conformance meaning. Failure results never masquerade as estimates.
}
