\name{rrp_validate_project}
\alias{rrp_validate_project}
\title{Validate an Explicit Independent RRP Project}
\usage{
rrp_validate_project(software_catalog, project_root)
}
\arguments{
\item{software_catalog}{A validated \code{rrp_resource_catalog} returned by
\code{rrp_open_resource_catalog()}.}

\item{project_root}{One explicit existing independent project directory.}
}
\value{
One validated \code{rrp_operation_result}. A valid project returns the exact
project, contract, API, canonical-profile, producer implementation/mapping,
and provider identities plus extension-library status and either
\code{compatible} or \code{not_initialized} state status. An absent state adds one
\code{project_state_not_initialized} warning. Expected project failures retain
their stable code and use the fixed message
\code{RRP project validation failed.}
}
\description{
Load one explicit project through the authoritative project loader and
translate its validated identity and declared location status into a bounded
operation result. This operation executes the trusted registration boundary
but never invokes the selected producer or provider.
}
\details{
The operation ID is \code{rrp.validate-project}. The function performs no root
discovery and creates no extension or state directory. When state exists it
reuses the project-state compatibility inspection without returning paths,
connections, SQL details, callables, registration source, arbitrary metadata,
or project context.

An absent declared extension library is a valid optional condition and does
not produce a warning. An absent declared state directory is also structurally
valid, but produces one fixed warning because state has not yet been
initialized. Existing state must pass its exact inventory, metadata, and
physical-schema compatibility checks and is reported as \code{compatible}.

Expected \code{rrp_project_error} and \code{rrp_state_error} conditions become
failed operation results.
Invalid software-resource context retains its \code{rrp_resource_error} owner,
and unexpected programming errors propagate. Structural validity does not
establish source mapping, canonical admission, clinical semantics, producer
or provider execution,
dependency completeness, security, production readiness, or risk validity.
}
