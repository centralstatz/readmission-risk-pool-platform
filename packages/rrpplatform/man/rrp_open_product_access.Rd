\name{rrp_open_product_access}
\alias{rrp_open_product_access}
\title{Open Validated Logical Product Access}
\usage{
rrp_open_product_access(
  software_catalog,
  project_root,
  expected_operation_run_id = NULL,
  history_cutoff = NULL
)
}
\arguments{
\item{software_catalog}{A validated explicit-root RRP software resource catalog.}
\item{project_root}{One explicit initialized independent-project root.}
\item{expected_operation_run_id}{An optional exact governed source operation identity.}
\item{history_cutoff}{An optional paired RFC 3339 UTC history cutoff.}
}
\value{
A common \code{rrp_operation_result}. Success contains detached validated
\code{rrp_product_access}; failure contains no access object.
}
\description{
Validates the current pointer, immutable set inventory, sizes, MD5 digests,
physical parsing, logical contracts, identities, and coherence before exposing
storage-neutral access. Expected source arguments are both absent or both
present. Freshness is then not evaluated, fresh, or stale; staleness does not
make an otherwise valid set unreadable.
}
