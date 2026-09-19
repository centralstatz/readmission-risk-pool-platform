\name{rrp_execute_risk}
\alias{rrp_execute_risk}
\title{Execute the Risk Provider Selected by an Explicit RRP Project}
\usage{
rrp_execute_risk(
  software_catalog,
  project_root,
  admitted_bundle,
  episode_id,
  as_of_time
)
}
\arguments{
  \item{software_catalog}{A validated \code{rrp_resource_catalog} returned by
  \code{rrp_open_resource_catalog()}.}
  \item{project_root}{One explicit existing independent project directory.}
  \item{admitted_bundle}{One already admitted
  \code{rrp_admitted_canonical_bundle}.}
  \item{episode_id}{One exact admitted episode identity.}
  \item{as_of_time}{One RFC 3339 timestamp with an explicit offset. It must
  denote the same instant as the admitted bundle's authoritative cutoff.}
}
\value{
One validated \code{rrp_operation_result}. On success its value is the
accepted detached \code{rrp_risk_estimate}. Expected project, target,
provider, and estimate failures return one bounded error diagnostic.
}
\description{
Loads the explicit project through the authoritative project loader, prepares
one eligible detached episode state, and delegates request construction,
provider execution, provider-result validation, and accepted-estimate
construction to \code{rrpruntime}. Exactly the provider already selected by
the project is invoked; there is no discovery, fallback, retry, or
provider-identity branch.
}
\details{
The protected installed provider
\code{rrp.provider.transparent@0.1.0} is available only when selected exactly
by the project manifest. It is a deterministic, fictional, nonclinical
conformance example using
\code{0.20 * remaining_to_target_seconds / 2592000}; it is not a default,
recommendation, clinically validated model, or production approval.

The operation begins from an already admitted bundle. It does not execute a
producer, initialize or write project state, persist requests or estimates,
append history, create a cache or log, retry, or invoke an alternate provider.
The successful value is sensitive analytical data and must not be rendered as
diagnostic output.
}
