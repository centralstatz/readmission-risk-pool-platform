\name{rrp_resource_path}
\alias{rrp_resource_path}
\title{Resolve an Installed RRP Resource}
\usage{
rrp_resource_path(validated_catalog, resource_id)
}
\arguments{
\item{validated_catalog}{An object returned by
\code{rrp_open_resource_catalog()}.}
\item{resource_id}{One exact stable logical resource ID.}
}
\value{The normalized concrete path beneath the explicit distribution root.}
\description{
Resolves one exact logical resource ID within an already validated catalog.
The boundary is revalidated before lookup to detect plausible changes made
after the catalog was opened.
}
\keyword{internal}
