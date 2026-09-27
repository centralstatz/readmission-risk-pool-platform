\name{rrp_initialize_project}
\alias{rrp_initialize_project}
\title{Initialize a Standard-Authored Independent RRP Project}
\usage{
rrp_initialize_project(
  software_catalog,
  project_root,
  project_id,
  project_version
)
}
\arguments{
  \item{software_catalog}{A validated \code{rrp_resource_catalog} returned by
  \code{rrp_open_resource_catalog()}.}
  \item{project_root}{One explicit absent project destination whose parent
  already exists as an ordinary directory.}
  \item{project_id}{One project identity accepted by the current project
  manifest and registration contracts.}
  \item{project_version}{One project version accepted by the current project
  manifest and registration contracts.}
}
\value{
One validated \code{rrp_operation_result}. Success contains project, producer,
producer-implementation, mapping, canonical-profile, provider,
provider-implementation, optional-model, and extension-inventory facts plus the
six created relative file paths. Expected resource, project, authoring, and
initialization failures return one privacy-safe error diagnostic.
}
\description{
Renders the six installed software-owned project templates into a uniquely
owned sibling staging directory, validates the staged project with
\code{rrp_load_project()}, atomically promotes it to the still-absent requested
destination, and loads it again at its final physical location.
}
\details{
Initialization is create-only. It never overwrites, merges, repairs, or adopts
an existing filesystem object. Failure removes only staging or final content
created by the current operation. The resulting project contains exactly
\file{rrp-project.dcf}, \file{rrp-authoring.dcf}, \file{R/register.R},
\file{R/produce-canonical.R}, \file{R/calculate-risk.R}, and \file{README.md};
declared extension-library and state directories remain absent.

The thin registration delegates to the standard authoring adapter. Its
producer and provider declarations remain the unchanged raw 0.1.0 contracts;
the initialized normal callables explicitly return controlled unavailable
authoring failures when later invoked.
Initialization and loading execute neither
callable. This technical API does not discover roots, create Git or dependency
state, initialize persistence, execute a producer/provider, or replace the
separate \code{rrp_validate_project()} doctor operation.
}
