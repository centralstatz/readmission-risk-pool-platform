\name{rrp_open_resource_catalog}
\alias{rrp_open_resource_catalog}
\title{Open an Installed RRP Resource Catalog}
\usage{
rrp_open_resource_catalog(explicit_distribution_root)
}
\arguments{
\item{explicit_distribution_root}{One explicit distribution-shaped root.}
}
\value{A validated catalog object for use with \code{rrp_resource_path()}.}
\description{
Validates the complete installed resource boundary beneath a caller-supplied
distribution root. It does not discover or select an installed RRP version.
}
\keyword{internal}
