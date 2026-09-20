\name{rrp_initialize_project_state}
\alias{rrp_initialize_project_state}
\title{Initialize Explicit Project-Owned RRP State}
\usage{
rrp_initialize_project_state(software_catalog, project_root)
}
\arguments{
\item{software_catalog}{A validated \code{rrp_resource_catalog} returned by
\code{rrp_open_resource_catalog()}.}

\item{project_root}{One explicit existing independent project directory.}
}
\value{
One validated \code{rrp_operation_result}. Success reports the compatible
state, adapter, physical-schema, and payload-encoding identities plus whether
this call created the state root. Failures contain one bounded diagnostic and
no path or database detail.
}
\description{
Create the complete initial state beneath the validated project's declared
\code{State-Path} through a sibling staging directory, validate it, and promote
it atomically. An existing fully compatible state is validated without
mutation and returns success with \code{created = FALSE}.
}
\details{
The operation ID is \code{rrp.initialize-project-state}. A new state contains
exactly \code{state.dcf} and \code{history.duckdb}. The operation is create-only:
it does not overwrite, merge, repair, migrate, or adopt partial, unknown,
linked, incompatible, or differently owned content. Project initialization
remains separate and does not initialize state.

The DuckDB file begins with empty logical history. This operation invokes no
producer or provider and performs no analytical computation, backup, restore,
or migration.
}
