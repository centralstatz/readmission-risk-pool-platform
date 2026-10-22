\name{rrp_validate_app}
\alias{rrp_validate_app}
\title{Validate Standalone Application Managed Content}
\usage{
rrp_validate_app(software_catalog, app_path)
}
\arguments{
\item{software_catalog}{A validated explicit-root software resource catalog.}
\item{app_path}{One explicit existing standalone application path.}
}
\value{A common RRP operation result with managed-content and informational initial-baseline status.}
\description{
Validates the active frozen product set, managed presentation, pointer, and
SHA-256 inventory without accessing an originating project or executing
hospital application source. Initial source-baseline evidence is informational
and independent from managed-content validity.
}
