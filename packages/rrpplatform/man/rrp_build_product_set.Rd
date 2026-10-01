\name{rrp_build_product_set}
\alias{rrp_build_product_set}
\title{Build One Coherent Logical Product Set}
\usage{
rrp_build_product_set(
  software_catalog,
  project_root,
  operation_run_id,
  history_cutoff
)
}
\arguments{
\item{software_catalog}{A validated explicit-root RRP software resource catalog.}
\item{project_root}{One explicit initialized independent-project root.}
\item{operation_run_id}{One exact governed operation-run identity.}
\item{history_cutoff}{One explicit RFC 3339 UTC history cutoff.}
}
\value{
A common \code{rrp_operation_result}. On success, \code{value} is one
detached, conforming \code{rrp_logical_product_set} containing current
remaining risk, actual remaining-risk trajectory, and one operational-scope
summary. On failure, \code{value} is \code{NULL} and diagnostics use the
bounded logical-product failure vocabulary.
}
\description{
Builds one all-required logical product set solely through the governed
storage-neutral history interface. Source scope and history cutoff are always
explicit. The operation does not discover a latest scope, invoke a producer or
provider, recompute risk, or create physical product storage.
}
