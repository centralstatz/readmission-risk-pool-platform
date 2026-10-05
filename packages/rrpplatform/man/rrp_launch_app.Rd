\name{rrp_launch_app}
\alias{rrp_launch_app}
\title{Launch the installed supplied application}
\usage{
rrp_launch_app(
  software_catalog,
  project_root,
  expected_operation_run_id = NULL,
  history_cutoff = NULL,
  launch_browser = interactive(),
  port = NULL
)
}
\arguments{
\item{software_catalog}{A validated explicit-root software resource catalog.}
\item{project_root}{One explicit initialized independent-project root.}
\item{expected_operation_run_id}{Optional explicit governed source operation.}
\item{history_cutoff}{Optional paired RFC 3339 UTC history cutoff.}
\item{launch_browser}{Whether Shiny should open a local browser.}
\item{port}{Optional nonprivileged local TCP port.}
}
\value{One validated \code{rrp_operation_result}.}
\description{
Validates an existing product realization and optional standard project
branding, constructs a closed detached application model, and runs the
installed supplied application on the loopback interface. The operation
returns after the application session exits.
}
\details{
The application has two top-level views. Current Risk Pool provides
deterministic episode search, exact provider/model filtering, presentation-only
sorting, bounded paging, row/episode selection, exact accepted probabilities,
actual-observation sparklines, and contextual Plotly trajectory detail with an
exact observation table. Overview provides direct current-risk descriptive
statistics and exact selected-scope counts. Freshness and valid-empty states
remain explicit.

The operation reads only the validated materialized products supplied at
startup. It does not execute analytical components, refresh or materialize
products, or give project branding control over analytical meaning or
application behavior.
}
