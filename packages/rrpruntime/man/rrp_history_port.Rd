\name{rrp_history_port}
\alias{rrp_new_history_port}
\alias{rrp_history_append_scope}
\alias{rrp_history_append_disposition}
\alias{rrp_history_append_invalidation}
\alias{rrp_history_append_restatement}
\title{Use the Storage-Neutral Operational-History Port}
\usage{
rrp_new_history_port(adapter)

rrp_history_append_scope(port, scope)

rrp_history_append_disposition(port, disposition)

rrp_history_append_invalidation(port, action)

rrp_history_append_restatement(port, replacement, action)
}
\arguments{
  \item{adapter}{A closed adapter declaration implementing the logical methods
  and affirming the required process-independent semantic capabilities.}
  \item{port}{A validated \code{rrp_history_port}.}
  \item{scope}{A validated operational-scope record.}
  \item{disposition}{A validated terminal episode-disposition record.}
  \item{action}{A validated append-only invalidation or matching restatement
  action, as applicable.}
  \item{replacement}{A replacement episode disposition or operational scope.}
}
\value{
\code{rrp_new_history_port()} returns a validated logical port. Append
operations invisibly return detached copies of the accepted record or record
pair.
}
\description{
Validate immutable history and its relationships before delegating to a small
storage-neutral port. Exact repeated content is idempotent; conflicting
content or invalid relationships fail with a bounded \code{rrp_history_error}.
Restatement appends its replacement and action through one atomic adapter
method. No physical persistence, close/reopen, file, SQL, or project-path
behavior is supplied by these interfaces.
}
