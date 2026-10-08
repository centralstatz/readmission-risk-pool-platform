\name{rrp_project_status}
\alias{rrp_project_status}
\title{Diagnose One Explicit Project's Lifecycle State}
\usage{
rrp_project_status(
  software_catalog,
  project_root,
  expected_operation_run_id = NULL,
  history_cutoff = NULL
)
}
\arguments{
\item{software_catalog}{A validated explicit-root software resource catalog.}
\item{project_root}{One explicit existing independent-project root.}
\item{expected_operation_run_id}{Optional exact source operation identity.}
\item{history_cutoff}{Optional paired RFC 3339 UTC history cutoff.}
}
\value{A common RRP operation result with privacy-safe lifecycle evidence.}
\description{
Composes existing project, state, history, product, and application evidence
into bounded read-only status. Producer and provider callables are not invoked.
Freshness is evaluated only when both comparison inputs are supplied.
}
