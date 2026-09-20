\name{rrp_inspect_project_state}
\alias{rrp_inspect_project_state}
\title{Inspect Explicit Project-Owned RRP State}
\usage{
rrp_inspect_project_state(software_catalog, project_root)
}
\arguments{
\item{software_catalog}{A validated \code{rrp_resource_catalog} returned by
\code{rrp_open_resource_catalog()}.}

\item{project_root}{One explicit existing independent project directory.}
}
\value{
One validated \code{rrp_operation_result}. An absent state is a successful
\code{not_initialized} inspection with one fixed warning. Compatible state
returns its bounded identity and compatibility summary. Invalid or
incompatible state returns failure without physical paths or database details.
}
\description{
Validate the declared project state inventory, closed metadata, DuckDB schema,
and matching embedded metadata without creating, repairing, or migrating
state.
}
\details{
The operation ID is \code{rrp.inspect-project-state}. Inspection uses a private
bounded read-only database session. It returns no DBI connection, SQL schema,
table name, payload, history record, project callable, or filesystem path.
Project version at initialization is provenance rather than an equality gate;
project identity and all governed state, target, history, adapter, schema, and
encoding versions must remain compatible.
}
