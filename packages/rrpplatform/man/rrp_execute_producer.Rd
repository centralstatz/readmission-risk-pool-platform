\name{rrp_execute_producer}
\alias{rrp_execute_producer}
\title{Execute the Producer Selected by an Explicit RRP Project}
\usage{
rrp_execute_producer(software_catalog, project_root, as_of_time)
}
\arguments{
  \item{software_catalog}{A validated \code{rrp_resource_catalog} returned by
  \code{rrp_open_resource_catalog()}.}
  \item{project_root}{One explicit existing independent project directory.}
  \item{as_of_time}{One RFC 3339 timestamp with an explicit offset.}
}
\value{
One validated \code{rrp_operation_result}. On success, \code{value} is a
detached \code{rrp_admitted_canonical_bundle}. Expected project, producer,
producer-result, and canonical-admission failures contain no value and one
bounded privacy-safe diagnostic.
}
\description{
Loads the project through \code{rrp_load_project()}, constructs the exact
closed producer request, invokes only the selected producer once under the
project extension-library policy, validates its closed result, and delegates
the successful candidate to \code{rrpruntime::rrp_admit_canonical_bundle()}.
}
\details{
The producer request contains only producer API, project, selected producer,
canonical bundle, canonical profile, and authoritative as-of facts. It contains
no software or project root, provider, state path, source configuration,
connection, credential, persistence handle, callback, or arbitrary options.

The trusted project producer may use source behavior captured from the explicit
project root during registration. Project extension code is trusted local code,
not a security sandbox. Producer errors are contained without exposing their
messages, and caller library paths and working directory are restored after
invocation. The selected provider is not invoked. The operation does not create
state, retain the admitted value, retry, or persist output.

The admitted value can contain sensitive canonical data and must not be logged
or rendered as ordinary diagnostic output. Successful execution proves software
contract conformance only, not source truth, clinical validity, production
approval, or fitness for care decisions.
}
