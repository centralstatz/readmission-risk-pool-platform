\name{rrp_execute_durable_bundle}
\alias{rrp_execute_durable_bundle}
\title{Execute One Admitted Bundle into Durable Terminal History}
\usage{
rrp_execute_durable_bundle(
  software_catalog,
  project_root,
  analytical_time,
  operation_key
)
}
\arguments{
\item{software_catalog}{A validated RRP software resource catalog.}
\item{project_root}{One explicit independent project directory.}
\item{analytical_time}{One explicit-offset RFC 3339 analytical instant.}
\item{operation_key}{One caller-owned idempotency key.}
}
\value{A common operation result containing bounded scope progress.}
\description{
Preflight initialized project state, execute and admit the selected producer
once, create or match one admitted-bundle scope, and append one terminal
disposition for every missing episode. Committed initial dispositions are not
automatically retried.
}
