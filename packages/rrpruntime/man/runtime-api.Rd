\name{runtime-api}
\alias{new_admitted_canonical_input}
\alias{validate_runtime_input}
\alias{validate_runtime_contracts}
\alias{runtime_conforms}
\alias{evaluate_episode_eligibility}
\alias{build_episode_states}
\alias{build_estimand_requests}
\title{Provider-independent readmission runtime API}
\description{
Construct and validate an admitted canonical input, evaluate episode
eligibility, build minimal as-of state, and construct provider-neutral
estimand requests.
}
\usage{
new_admitted_canonical_input(
  bundle_instance_id,
  bundle_as_of_time,
  canonical_run_id,
  profile_specification,
  capabilities,
  discharge_episodes,
  baseline_risk = list(),
  episode_events = list(),
  provenance_references = list(),
  admission_reference
)

validate_runtime_input(input)

validate_runtime_contracts(contracts)

runtime_conforms(result)

evaluate_episode_eligibility(input, runtime_context, contracts)

build_episode_states(input, eligibility, runtime_context, contracts)

build_estimand_requests(states, eligibility, runtime_context, contracts)
}
\arguments{
  \item{bundle_instance_id}{Identity of the admitted canonical bundle.}
  \item{bundle_as_of_time}{Explicit-offset bundle cutoff timestamp.}
  \item{canonical_run_id}{Identity of the canonical production run.}
  \item{profile_specification}{Canonical profile identity and version.}
  \item{capabilities}{Canonical capability status records.}
  \item{discharge_episodes}{Admitted discharge-episode records.}
  \item{baseline_risk}{Optional admitted baseline-risk records.}
  \item{episode_events}{Optional admitted episode-event records.}
  \item{provenance_references}{Canonical provenance references.}
  \item{admission_reference}{Passing canonical admission reference.}
  \item{input}{An admitted canonical runtime input.}
  \item{contracts}{Named, explicitly injected runtime specifications.}
  \item{result}{A runtime conformance result.}
  \item{runtime_context}{Runtime run identity and as-of timestamp.}
  \item{eligibility}{Episode eligibility results.}
  \item{states}{Eligible episode-state records.}
}
\value{
The constructor returns an admitted runtime input; validation functions return
conformance results; \code{runtime_conforms()} returns one logical value; and
the three builders return versioned eligibility, state, or request record sets.
}
\details{
The package accepts only already-admitted canonical information. It does not
discover repository files, execute providers, estimate risk, choose durable
storage, or construct application products.
}
