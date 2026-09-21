\name{rrp_project_state_backup}
\alias{rrp_backup_project_state}
\alias{rrp_restore_project_state}
\title{Back Up and Restore Project-Owned RRP State}
\usage{
rrp_backup_project_state(software_catalog, project_root, backup_path)

rrp_restore_project_state(software_catalog, project_root, backup_path)
}
\arguments{
\item{software_catalog}{A validated RRP software resource catalog.}
\item{project_root}{One explicit independent project directory.}
\item{backup_path}{For backup, one explicit absent artifact destination; for restore, one existing validated artifact.}
}
\value{
A common operation result containing bounded backup or restored-state evidence.
}
\description{
Backup checkpoints one compatible quiescent project state and creates a closed,
validated artifact without overwriting its destination. Restore validates that
artifact against an independently loaded compatible project and promotes its
state only when the project's state destination is absent.
}
\details{
The artifact contains one RRP backup manifest and one checkpointed DuckDB
database. Restore reconstructs the state metadata file from the exact metadata
already embedded in that validated database; it does not replace the project
manifest, registration code, source inputs, or installed software. It
does not overwrite, merge, migrate, repair, decrypt, schedule, or transport
state. The manifest and database validation detect bounded structural,
compatibility, inventory, and reopenability failures; they are not
authentication or protection against a malicious actor.
}
