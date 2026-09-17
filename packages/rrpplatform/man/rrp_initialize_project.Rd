\name{rrp_initialize_project}
\alias{rrp_initialize_project}
\title{Initialize a Minimal Independent RRP Project}
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
One validated \code{rrp_operation_result}. Success contains only the project
and selected structural component identities, versions, and the two created
relative file paths. Expected resource, project, and initialization failures
return one privacy-safe error diagnostic.
}
\description{
Renders the two installed software-owned project templates into a uniquely
owned sibling staging directory, validates the staged project with
\code{rrp_load_project()}, atomically promotes it to the still-absent requested
destination, and loads it again at its final physical location.
}
\details{
Initialization is create-only. It never overwrites, merges, repairs, or adopts
an existing filesystem object. Failure removes only staging or final content
created by the current operation. The resulting project contains exactly
\file{rrp-project.dcf} and \file{R/register.R}; declared extension-library and
state directories remain absent.

The registered producer and provider callables are structural placeholders
that fail safely if invoked. Initialization and loading never execute them.
This technical API does not discover roots, create Git or dependency state,
initialize persistence, validate producer/provider semantics, or provide the
future project doctor.
}
