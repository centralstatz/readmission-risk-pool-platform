\name{rrp_resource_path}
\alias{rrp_resource_path}
\title{Resolve an Installed RRP Resource}
\usage{
rrp_resource_path(catalog, resource_id)
}
\arguments{
\item{catalog}{A validated object returned by
\code{rrp_open_resource_catalog()}.}
\item{resource_id}{One exact stable logical resource identity.}
}
\value{
The normalized contained path to the declared regular resource file.
}
\description{
Resolves one logical ID through an installed resource catalog. The installed
boundary is reopened before lookup so deletion, link substitution, catalog or
schema replacement, and other covered state changes fail closed.
}
\section{Failures}{
Malformed catalog objects or identities, unknown identities, and invalidated
installed state raise \code{rrp_resource_error} with a stable safe code and
bounded message.
}
\seealso{\code{\link{rrp_open_resource_catalog}}}
\keyword{internal}
