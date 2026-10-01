\name{rrp_materialize_product_set}
\alias{rrp_materialize_product_set}
\title{Materialize One Coherent Logical Product Set}
\usage{
rrp_materialize_product_set(software_catalog, project_root, product_set)
}
\arguments{
\item{software_catalog}{A validated explicit-root RRP software resource catalog.}
\item{project_root}{One explicit initialized independent-project root.}
\item{product_set}{One conforming Stage 9 logical product set.}
}
\value{
A common \code{rrp_operation_result}. Success contains bounded logical and
materialization identities; failure contains privacy-safe diagnostics.
}
\description{
Validates and publishes one complete product set through the supplied staged
DCF/CSV adapter. Immutable sets are promoted before the replaceable current
pointer, and an existing identical realization is reused without mutation.
}
