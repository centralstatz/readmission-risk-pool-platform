\name{rrpruntime-package}
\alias{rrpruntime}
\alias{rrpruntime-package}
\docType{package}
\title{Dependency-Light Readmission Runtime Foundation}
\description{
Provides dependency-light implementation-neutral Readmission Risk Pool runtime
behavior. Its current responsibility is pure canonical bundle admission.
}
\details{
The package uses only base R package machinery and exports exactly
\code{rrp_admit_canonical_bundle()}. It has no project, installed-resource,
producer/provider execution, eligibility, risk, state, history, product, or
persistence responsibility. Later responsibilities require their own accepted
increments and evidence.
}
\author{RRP maintainers}
\keyword{internal}
