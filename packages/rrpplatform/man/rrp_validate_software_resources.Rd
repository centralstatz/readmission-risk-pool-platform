\name{rrp_validate_software_resources}
\alias{rrp_validate_software_resources}
\title{Validate Installed RRP Software Resources}
\usage{
rrp_validate_software_resources(software_root)
}
\arguments{
\item{software_root}{One explicit distribution-shaped software root.}
}
\value{
A list with exact class \code{c("rrp_operation_result", "list")} and fields
\code{operation_id}, \code{status}, \code{value}, and \code{diagnostics}.
A successful value contains only catalog identity, version, and resource count.
A failed result has a \code{NULL} value and at least one privacy-safe error
diagnostic.
}
\description{
Uses the installed resource-catalog boundary beneath exactly the supplied root
and returns one common structured operation result. It does not discover or
select a software root.
}
\section{Failures}{
Expected \code{rrp_resource_error} conditions are translated narrowly into
failed operation results. The stable resource error code is retained, while
arbitrary condition, parser, content, identity, and path detail is not copied
into the diagnostic message. Unexpected internal errors are not generalized
into diagnostics.
}
\seealso{\code{\link{rrp_operation_succeeded}},
\code{\link{rrp_open_resource_catalog}}}
\keyword{internal}
