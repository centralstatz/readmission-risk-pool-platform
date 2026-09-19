\name{rrpruntime-package}
\alias{rrpruntime}
\alias{rrpruntime-package}
\docType{package}
\title{Dependency-Light Readmission Runtime Foundation}
\description{
Provides dependency-light implementation-neutral Readmission Risk Pool runtime
behavior. Its current responsibilities are pure canonical bundle admission,
singular-target episode eligibility/state preparation, standard risk-request
construction, compatible provider invocation, and accepted-estimate creation.
}
\details{
The package uses only base R package machinery and exports exactly
\code{rrp_admit_canonical_bundle()},
\code{rrp_prepare_episode_state()}, and
\code{rrp_execute_risk_provider()}. It has no project, installed-resource,
producer execution, provider selection, controlled project-library, history,
product, or persistence responsibility. Later responsibilities require their
own accepted increments and evidence.
}
\author{RRP maintainers}
\keyword{internal}
