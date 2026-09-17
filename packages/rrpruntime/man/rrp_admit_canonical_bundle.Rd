\name{rrp_admit_canonical_bundle}
\alias{rrp_admit_canonical_bundle}
\title{Admit a Canonical Bundle Candidate}
\usage{
rrp_admit_canonical_bundle(candidate, expected_context)
}
\arguments{
\item{candidate}{A closed plain named list containing the exact canonical
bundle fields and the \code{discharge_episode} and \code{terminal_event}
data frames.}
\item{expected_context}{A closed plain named list containing the exact bundle,
project, producer, implementation, mapping, profile, capability, and
authoritative as-of facts expected by the caller.}
}
\value{
A detached object with class
\code{c("rrp_admitted_canonical_bundle", "list")}.
}
\description{
Validates one source-independent canonical candidate against an exact expected
context and returns a detached admitted bundle.
}
\details{
The accepted in-memory adapter uses plain character values, unnamed capability
records, and exact base \code{data.frame} domain realizations. Timestamps are
RFC 3339 strings with explicit offsets and are normalized only for instant and
elapsed-time comparison. The function performs no project loading, producer or
provider invocation, source access, persistence, eligibility, or risk work.

Expected failures inherit from \code{rrp_canonical_error} and expose only a
stable \code{code} plus a bounded maintainer-authored message. Candidate values
and identifiers are never rendered in the failure.
}
\author{RRP maintainers}
\keyword{internal}
