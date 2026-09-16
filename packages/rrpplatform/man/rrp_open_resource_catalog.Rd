\name{rrp_open_resource_catalog}
\alias{rrp_open_resource_catalog}
\title{Open an Installed RRP Resource Catalog}
\usage{
rrp_open_resource_catalog(software_root)
}
\arguments{
\item{software_root}{One explicit distribution-shaped software root.}
}
\value{
A list with exact class \code{c("rrp_resource_catalog", "list")} containing
the normalized software root, fixed catalog and schema paths, and validated
installed catalog records. Installed records contain no repository source path.
}
\description{
Validates the fixed installed DCF schema, catalog, and closed resource inventory
beneath exactly the supplied software root. The function does not discover or
select a root.
}
\section{Failures}{
Failures inherit from \code{rrp_resource_error} and contain a stable \code{code}
and bounded maintainer-authored message. Messages do not copy parser detail,
caller paths, resource content, or arbitrary input.
}
\seealso{\code{\link{rrp_resource_path}}}
\keyword{internal}
