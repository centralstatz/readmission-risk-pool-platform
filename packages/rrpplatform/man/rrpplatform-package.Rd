\name{rrpplatform-package}
\alias{rrpplatform}
\alias{rrpplatform-package}
\docType{package}
\title{Internal Readmission Risk Pool Implementation}
\description{
Establishes the main internal implementation package within RRP software and
its one-way dependency on the focused runtime package. It provides explicit-
root installed-resource catalog opening, logical resource resolution, and a
minimal common operation-result boundary with privacy-safe diagnostics. It
also owns strict project-manifest and trusted-registration validation plus one
explicit project-loading boundary.
}
\details{
The package imports the \pkg{rrpruntime} namespace and exports exactly
\code{rrp_load_project()}, \code{rrp_open_resource_catalog()},
\code{rrp_operation_succeeded()}, \code{rrp_resource_path()}, and
\code{rrp_validate_software_resources()}. It does not discover or select a
software or project root. The loader evaluates trusted project registration in
a controlled environment that is not a security sandbox and never invokes the
selected producer or provider. No initializer or project doctor exists yet.
}
\author{RRP maintainers}
\keyword{internal}
