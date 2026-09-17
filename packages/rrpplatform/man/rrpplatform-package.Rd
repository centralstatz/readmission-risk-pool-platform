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
also owns strict project-manifest and trusted-registration validation, one
explicit project-loading boundary, and transactional minimal-project
initialization plus a bounded structured project doctor.
}
\details{
The package imports the \pkg{rrpruntime} namespace and exports exactly
\code{rrp_initialize_project()}, \code{rrp_load_project()},
\code{rrp_open_resource_catalog()},
\code{rrp_operation_succeeded()}, \code{rrp_resource_path()},
\code{rrp_validate_project()}, and
\code{rrp_validate_software_resources()}. It does not discover or select a
software or project root. The loader evaluates trusted project registration in
a controlled environment that is not a security sandbox and never invokes the
selected producer or provider. Initialization is create-only, uses the loader
as its acceptance gate, and creates no state or dependency directories. No
source admission, component execution, risk calculation, or state behavior
exists yet.
}
\author{RRP maintainers}
\keyword{internal}
