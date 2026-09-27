\name{rrp_project_authoring}
\alias{rrp_register_authored_project}
\alias{rrp_authoring_failure}
\title{Standard RRP Project Authoring Boundary}
\usage{
rrp_register_authored_project(project_root)

rrp_authoring_failure(code)
}
\arguments{
  \item{project_root}{One explicit existing independent project root.}
  \item{code}{One existing producer- or provider-declared failure code.}
}
\value{
\code{rrp_register_authored_project()} returns one closed
\code{rrp.project-registration@0.3.0} value when called through the trusted
project loader. \code{rrp_authoring_failure()} returns one closed intentional
failure token.
}
\description{
The standard authoring adapter validates the installed
\code{rrp.project-authoring@0.1.0} authority, fixed authoring files, metadata,
and declared extension-package closure, then compiles two narrow hospital
callables into the unchanged raw producer and provider contracts. It does not
invoke either callable during registration. The generated
\file{R/register.R} is the sole trusted registration entry point and calls this
adapter under the authoritative loader's explicit software and project
context.
}
\details{
An authoring failure contains only a controlled code and no message or arbitrary
details. Applicability is checked again by the producer or provider adapter.
Thrown hospital conditions and invalid returns remain distinct detected
failures whose arbitrary text is not exposed.
}
