\name{rrp_product_access}
\alias{rrp_list_products}
\alias{rrp_read_product}
\title{List and Read Validated Logical Products}
\usage{
rrp_list_products(product_access)

rrp_read_product(
  product_access,
  product_id,
  product_version,
  metadata_only = FALSE
)
}
\arguments{
\item{product_access}{One validated detached \code{rrp_product_access}.}
\item{product_id}{One exact logical product identity.}
\item{product_version}{One exact logical product version.}
\item{metadata_only}{Return bounded logical metadata rather than product rows.}
}
\value{
\code{rrp_list_products()} returns the exact three-member bounded inventory.
\code{rrp_read_product()} returns one detached logical product or its bounded
metadata. Misuse raises a typed, privacy-safe product-access error.
}
\description{
These pure accessors operate only over an already validated detached access
object. They do not expose or rediscover DCF, CSV, project-state paths, or a
mutable storage connection.
}
