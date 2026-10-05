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
