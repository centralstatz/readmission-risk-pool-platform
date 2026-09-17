\name{rrp_load_project}
\alias{rrp_load_project}
\title{Load an Explicit Independent RRP Project}
\usage{
rrp_load_project(software_catalog, project_root)
}
\arguments{
  \item{software_catalog}{A validated \code{rrp_resource_catalog} returned by
  \code{rrp_open_resource_catalog()}.}
  \item{project_root}{One explicit existing independent project directory.}
}
\value{
One closed \code{rrp_project_context} list containing the validated software
catalog, normalized project root, manifest, registration result, exact selected
canonical-profile identity, semantic producer and structural provider records
with origin, and normalized intended extension-library and state locations.
}
\description{
Validates one caller-supplied project against an explicit software-resource
context, validates the installed canonical contract family, executes only
\file{R/register.R}, and resolves exact semantic producer and structural
provider selections without invoking their callables.
}
\details{
The manifest and real project paths are validated before project code executes.
The registration file is evaluated once in a fresh environment whose parent is
the base environment, and its one \code{rrp_register_project(project_root)}
function is invoked once. The registration file is trusted local R code;
controlled evaluation limits accidental global coupling but is not a security
sandbox.

RRP-owned package libraries precede an existing declared project extension
library, ambient user libraries are excluded during registration, and the
caller's library paths are restored on success or failure. The function does
not discover roots, install dependencies, create state, execute selected
components, initialize a project, or return a structured doctor result.

Expected project failures inherit from \code{rrp_project_error} and expose a
stable machine-readable \code{code} with a fixed privacy-safe message. The
returned context is an in-process validated snapshot; callers should load a new
context for a later operation rather than mutate or serialize it.
}
\examples{
\dontrun{
catalog <- rrp_open_resource_catalog("/explicit/installed-rrp")
context <- rrp_load_project(catalog, "/explicit/hospital-project")
}
}
