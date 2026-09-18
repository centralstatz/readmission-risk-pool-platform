\name{rrpruntime-package}
\alias{rrpruntime}
\alias{rrpruntime-package}
\docType{package}
\title{Dependency-Light Readmission Runtime Foundation}
\description{
Provides dependency-light implementation-neutral Readmission Risk Pool runtime
behavior. Its current responsibilities are pure canonical bundle admission and
singular-target episode eligibility/state preparation.
}
\details{
The package uses only base R package machinery and exports exactly
\code{rrp_admit_canonical_bundle()} and
\code{rrp_prepare_episode_state()}. It has no project, installed-resource,
producer/provider execution, risk-request, estimate, history, product, or
persistence responsibility. Later responsibilities require their own accepted
increments and evidence.
}
\author{RRP maintainers}
\keyword{internal}
