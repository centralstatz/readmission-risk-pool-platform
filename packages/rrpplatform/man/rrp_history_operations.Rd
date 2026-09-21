\name{rrp_history_operations}
\alias{rrp_inspect_scope_history}
\alias{rrp_inspect_episode_history}
\alias{rrp_inspect_current_history}
\alias{rrp_retry_episode}
\alias{rrp_invalidate_history}
\alias{rrp_restate_history}
\title{Inspect and Correct Durable Operational History}
\usage{
rrp_inspect_scope_history(software_catalog, project_root, operation_run_id)

rrp_inspect_episode_history(
  software_catalog, project_root, episode_id, target_id, history_cutoff
)

rrp_inspect_current_history(
  software_catalog, project_root, episode_id, target_id,
  analytical_cutoff, history_cutoff
)

rrp_retry_episode(
  software_catalog, project_root, operation_run_id, analytical_run_id,
  retry_key
)

rrp_invalidate_history(
  software_catalog, project_root, target_kind, target_operation_run_id,
  target_id, effective_time, reason_code, actor_category
)

rrp_restate_history(
  software_catalog, project_root, target_kind, target_operation_run_id,
  target_id, replacement, effective_time, reason_code, actor_category
)
}
\arguments{
\item{software_catalog}{A validated RRP software resource catalog.}
\item{project_root}{One explicit independent project directory.}
\item{operation_run_id}{One exact durable operation-run identity.}
\item{episode_id}{One exact episode identity.}
\item{target_id}{One exact target identity, or the target record identity for a correction.}
\item{history_cutoff}{One explicit history-time cutoff.}
\item{analytical_cutoff}{One explicit analytical-time cutoff.}
\item{analytical_run_id}{One failed provider analytical-run identity.}
\item{retry_key}{One caller-owned retry identity key.}
\item{target_kind}{Either \code{analytical_run} or \code{operational_scope}.}
\item{target_operation_run_id}{The target record's operation-run identity.}
\item{effective_time}{One explicit history effective time.}
\item{reason_code}{One bounded governed reason code.}
\item{actor_category}{Either \code{maintainer} or \code{operator}.}
\item{replacement}{A validated replacement disposition or operational scope.}
}
\value{A common operation result containing detached bounded history evidence.}
\description{
These operations expose the accepted storage-neutral raw/current history views,
one explicit failed-attempt retry, and append-only invalidation or atomic
restatement through the project-owned durable history port.
}
