\name{rrp_history_reads}
\alias{rrp_history_read_scope}
\alias{rrp_history_read_episode}
\alias{rrp_history_read_current}
\title{Read Raw and Effective Operational History}
\usage{
rrp_history_read_scope(port, operation_run_id)

rrp_history_read_episode(port, episode_id, target_id, history_cutoff)

rrp_history_read_current(
  port,
  episode_id,
  target_id,
  analytical_cutoff,
  history_cutoff
)
}
\arguments{
  \item{port}{A validated \code{rrp_history_port}.}
  \item{operation_run_id}{One exact bundle-scoped operation-run identity.}
  \item{episode_id}{One opaque project-owned episode identity.}
  \item{target_id}{One exact governed target identity.}
  \item{history_cutoff}{An explicit-offset RFC 3339 history-time cutoff.}
  \item{analytical_cutoff}{An explicit-offset RFC 3339 analytical-time cutoff.}
}
\value{
\code{rrp_history_read_scope()} returns the immutable scope, derived progress,
and retained related records. \code{rrp_history_read_episode()} returns
detached raw episode history. \code{rrp_history_read_current()} returns one
effective terminal disposition or \code{NULL}; unrelated same-time candidates
fail as ambiguous.
}
\description{
Validate detached adapter results and keep immutable raw history distinct from
effective interpretation. Completeness is derived from initial-disposition
cardinality and membership evidence. Current interpretation applies explicit
history actions, excludes incomplete or invalidated scopes, resolves retry and
restatement lineage, and uses only explicit analytical and history cutoffs.
}
