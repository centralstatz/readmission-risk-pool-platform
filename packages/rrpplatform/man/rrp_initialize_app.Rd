\name{rrp_initialize_app}
\alias{rrp_initialize_app}
\title{Initialize a Create-Only Standalone RRP Application}
\usage{
rrp_initialize_app(
  software_catalog,
  project_root,
  scope_id,
  history_cutoff,
  output_path = NULL
)
}
\arguments{
\item{software_catalog}{A validated explicit-root software resource catalog.}
\item{project_root}{One explicit initialized independent-project root.}
\item{scope_id}{The exact source operation-run identity.}
\item{history_cutoff}{The exact RFC 3339 UTC history cutoff.}
\item{output_path}{An optional absent destination. The default is \code{app} in the project root.}
}
\value{A common RRP operation result with bounded application identity and lineage evidence.}
\description{
Creates one standalone product-only application through a sibling staging
directory and promotes it only into an absent destination. Project registration
code is not evaluated. Existing destinations are never overwritten.
}
