\name{rrpplatform-package}
\alias{rrpplatform}
\alias{rrpplatform-package}
\docType{package}
\title{Internal Readmission Risk Pool Implementation}
\description{
Establishes the main internal implementation package within RRP software and
its one-way dependency on the focused runtime package. It provides explicit-
root installed-resource catalog opening and logical resource resolution.
}
\details{
The package imports the \pkg{rrpruntime} namespace and exports only
\code{rrp_open_resource_catalog()} and \code{rrp_resource_path()}. It does not
discover or select a software root. Later product responsibilities require
their own accepted increments and evidence.
}
\author{RRP maintainers}
\keyword{internal}
