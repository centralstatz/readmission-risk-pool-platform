\name{rrp_initialize_fictional_project}
\alias{rrp_initialize_fictional_project}
\title{Initialize the Supplied Fictional RRP Project}
\usage{
rrp_initialize_fictional_project(software_catalog, project_root)
}
\arguments{
  \item{software_catalog}{A validated \code{rrp_resource_catalog} returned by
  \code{rrp_open_resource_catalog()}.}
  \item{project_root}{One explicit absent project destination whose parent
  already exists as an ordinary directory.}
}
\value{
One validated \code{rrp_operation_result}. Success identifies the fixed
fictional project, its selected producer/provider and implementation/mapping
identities, its empty extension-package inventory, and the nine created
relative file paths.
}
\description{
Transactionally realizes the deterministic, visibly fictional, nonclinical
reference project from cataloged installed templates and validates it through
the same standard-authoring loader used for ordinary independent projects.
}
\details{
Initialization is create-only and leaves source generation explicit. The
result contains the normal six-path standard-authoring scaffold, bounded
\file{_brand.yml} and \file{assets/project-logo.png} presentation resources,
plus \file{R/generate-source.R}; it contains no generated source, extension
library, state, database, Git metadata, or application source. Run the
project-owned generator described in
its README before producer execution. This initializer adds no privileged
fictional registration, producer, provider, runtime, or history branch.
}
