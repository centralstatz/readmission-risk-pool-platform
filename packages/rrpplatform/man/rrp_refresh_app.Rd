\name{rrp_refresh_app}
\alias{rrp_refresh_app}
\title{Refresh a Standalone Application's Managed Products}
\usage{
rrp_refresh_app(
  software_catalog,
  project_root,
  scope_id,
  history_cutoff,
  app_path = NULL
)
}
\arguments{
\item{software_catalog}{A validated explicit-root software resource catalog.}
\item{project_root}{One explicit initialized independent-project root.}
\item{scope_id}{The exact source operation-run identity.}
\item{history_cutoff}{The exact RFC 3339 UTC history cutoff.}
\item{app_path}{An optional existing standalone application path. The default is \code{app} in the project root.}
}
\value{A common RRP operation result with bounded current-product identity and lineage evidence.}
\description{
Stages and validates one already-materialized compatible product set, then
atomically replaces the small current-set record. The operation writes only
inside the application's reserved \code{rrp-data} directory and does not
execute hospital application source or analytical components.
}
