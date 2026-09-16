\name{rrp_operation_succeeded}
\alias{rrp_operation_succeeded}
\title{Test Whether an RRP Operation Succeeded}
\usage{
rrp_operation_succeeded(result)
}
\arguments{
\item{result}{One valid common RRP operation result.}
}
\value{
One non-missing scalar logical value.
}
\description{
Validates an object against the exact common operation-result contract and
returns its machine-readable success state. The function never infers success
from diagnostic prose.
}
\section{Failures}{
Malformed result-like objects are rejected rather than treated as failed
operations.
}
\seealso{\code{\link{rrp_validate_software_resources}}}
\keyword{internal}
