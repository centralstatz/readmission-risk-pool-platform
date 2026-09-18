\name{rrp_prepare_episode_state}
\alias{rrp_prepare_episode_state}
\title{Prepare Immutable State for One Admitted Episode}
\usage{
rrp_prepare_episode_state(
  admitted_bundle,
  episode_id,
  as_of_time,
  expected_context
)
}
\arguments{
\item{admitted_bundle}{One value returned by
\code{rrp_admit_canonical_bundle()}. The value is revalidated and detached at
the state boundary.}
\item{episode_id}{One exact admitted episode identity.}
\item{as_of_time}{One explicit-offset RFC 3339 analytical instant denoting the
same instant as the admitted bundle's authoritative cutoff.}
\item{expected_context}{The closed target, state, canonical, and software
  context assembled by the calling orchestration boundary.}
}
\description{
Enforce the singular remaining day-30 readmission-risk target's analytical
cutoff and eligibility rules and construct one detached minimal episode state.
}
\details{
Eligibility includes the exact discharge instant and excludes the exact or
later day-30 endpoint. A known readmission or death at or before the analytical
instant prevents state construction; equal-time readmission and death are
classified as readmission. The operation performs no source lookup,
retrospective reconstruction, provider invocation, risk calculation, or
persistent write.

Expected failures inherit from \code{rrp_runtime_error} and carry a stable
\code{code}, a bounded fixed message, and a null call. Returned state contains
only governed identity and target-timing facts. It excludes patient and
encounter identifiers, terminal rows, source/mapping/provider content,
features, paths, callbacks, and persistence identity.
}
\value{
A detached object with class \code{c("rrp_episode_state", "list")} and the
exact installed episode-state contract fields.
}
\keyword{internal}
