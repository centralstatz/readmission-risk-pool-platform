\name{rrp_history_records}
\alias{rrp_history_membership_fingerprint}
\alias{rrp_new_operational_scope}
\alias{rrp_new_episode_disposition}
\alias{rrp_new_history_action}
\title{Construct Storage-Neutral Operational-History Records}
\usage{
rrp_history_membership_fingerprint(episode_ids)

rrp_new_operational_scope(values, episode_ids)

rrp_new_episode_disposition(scope, values)

rrp_new_history_action(values)
}
\arguments{
  \item{episode_ids}{A character vector of unique opaque admitted episode
  identities.}
  \item{values}{A plain named list containing exactly the governed fields in
  the applicable contract order.}
  \item{scope}{A validated \code{rrp_operational_scope}.}
}
\value{
\code{rrp_history_membership_fingerprint()} returns one deterministic
fingerprint. The constructors return detached immutable logical records with
classes \code{rrp_operational_scope}, \code{rrp_episode_disposition}, or
\code{rrp_history_action}.
}
\description{
Construct the closed record families and deterministic identities used by the
dependency-light operational-history contract. The fingerprint uses sorted,
unique, length-prefixed UTF-8 episode identities. These functions do not open
or write project state. Scope creation and disposition terminal times may equal
but cannot precede their authoritative analytical time.
}
