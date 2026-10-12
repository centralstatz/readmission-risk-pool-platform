\name{rrp_cli_dispatch}
\alias{rrp_cli_dispatch}
\title{Dispatch one version-specific RRP command}
\usage{
rrp_cli_dispatch(
  arguments,
  software_root,
  private_library,
  host_r_executable,
  installation_root = NULL,
  selected_selector = NULL,
  selection_mode = "explicit_version_context",
  stable_shim = "",
  working_directory = ".",
  output = stdout(),
  error = stderr()
)
}
\arguments{
  \item{arguments}{Character command arguments excluding the executable name.}
  \item{software_root}{Explicit installed software-resource root.}
  \item{private_library}{Explicit version-private R package library.}
  \item{host_r_executable}{Explicit host R executable used for this process.}
  \item{installation_root}{Optional explicit per-user installation root.}
  \item{selected_selector}{Optional exact selected software realization.}
  \item{selection_mode}{Explicit active, override, activation, transport, or version-context selection mode.}
  \item{stable_shim}{Optional explicit stable-launcher path.}
  \item{working_directory}{Exact working directory used when project context is omitted.}
  \item{output}{Connection for normal command output.}
  \item{error}{Connection for usage and failure output.}
}
\value{Invisibly, one integer process exit status.}
\description{
Validates one explicitly supplied installed software context, parses the
bounded command grammar, delegates to package-owned operations, and renders
human or versioned JSON output. Existing-project commands use an explicit
project path or exactly the current directory; creation requires an explicit
destination. Restore and history-correction commands use controlled
confirmation. The dispatcher receives explicit active or override selection
context from the stable launcher and never discovers projects. Its bounded
software operations enumerate, verify, diagnose, or atomically activate only
installed software. Software installation delegates one explicit local
distribution to the distribution-owned shared installation engine.
}
