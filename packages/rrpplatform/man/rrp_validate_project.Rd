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
and provider identities plus
\code{available} or \code{not_initialized} extension-library and state
statuses. An absent state adds one
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
discovery, creates no extension or state directory, inspects no directory
contents beyond the loader's existing structural rules, and returns no paths,
callables, registration source, arbitrary metadata, or project context.

An absent declared extension library is a valid optional condition and does
not produce a warning. An absent declared state directory is also structurally
valid at this stage, but produces one fixed warning because state has not yet
been initialized. Existing directories are reported as \code{available};
their contents are not validated by this operation.

Expected \code{rrp_project_error} conditions become failed operation results.
Invalid software-resource context retains its \code{rrp_resource_error} owner,
and unexpected programming errors propagate. Structural validity does not
establish source mapping, canonical admission, clinical semantics, producer
or provider execution,
dependency completeness, security, production readiness, or risk validity.
}
