\name{rrp_build_and_materialize_products}
\alias{rrp_build_and_materialize_products}
\title{Build and Atomically Materialize One Logical Product Set}
\usage{
rrp_build_and_materialize_products(
  software_catalog,
  project_root,
  operation_run_id,
  history_cutoff
)
}
\arguments{
\item{software_catalog}{A validated explicit-root software resource catalog.}
\item{project_root}{One explicit initialized independent-project root.}
\item{operation_run_id}{One exact complete governed source operation.}
\item{history_cutoff}{One explicit RFC 3339 UTC history cutoff.}
}
\value{A common RRP operation result with bounded publication evidence.}
\description{
Composes the accepted logical builder and materializer while retaining the same
explicit source operation, cutoff, product identity, and atomic publication
semantics as the individual APIs.
}
