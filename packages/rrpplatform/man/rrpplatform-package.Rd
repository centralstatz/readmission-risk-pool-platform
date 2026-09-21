\name{rrpplatform-package}
\alias{rrpplatform}
\alias{rrpplatform-package}
\docType{package}
\title{Internal Readmission Risk Pool Implementation}
\description{
Establishes the main internal implementation package within RRP software and
its one-way dependency on the focused runtime package. It provides explicit-
root installed-resource catalog opening, logical resource resolution, and a
minimal common operation-result boundary with privacy-safe diagnostics. It
also owns strict project-manifest and trusted-registration validation, one
exact installed canonical specification authority, all five singular runtime
authorities, semantic provider declarations, an explicit project-loading boundary, and
transactional minimal-project initialization plus a bounded structured project
doctor. It can normalize installed authority into the exact contexts consumed
by runtime admission, episode-state preparation, and direct runtime provider
execution and orchestrate one selected project producer through the canonical
boundary and one selected project provider through the risk boundary. It also
owns explicit project-state initialization/inspection and the private DuckDB
adapter behind the runtime-owned logical history port, plus bundle-scoped
durable execution and supported history interpretation/correction.
}
\details{
The package imports the \pkg{rrpruntime} namespace and exports exactly 18
technical interfaces: \code{rrp_execute_durable_bundle()},
\code{rrp_execute_producer()}, \code{rrp_execute_risk()},
\code{rrp_initialize_project()}, \code{rrp_initialize_project_state()},
\code{rrp_inspect_current_history()}, \code{rrp_inspect_episode_history()},
\code{rrp_inspect_project_state()}, \code{rrp_inspect_scope_history()},
\code{rrp_invalidate_history()},
\code{rrp_load_project()},
\code{rrp_open_resource_catalog()},
\code{rrp_operation_succeeded()}, \code{rrp_resource_path()},
\code{rrp_restate_history()}, \code{rrp_retry_episode()},
\code{rrp_validate_project()}, and
\code{rrp_validate_software_resources()}. It does not discover or select a
software or project root. The loader evaluates trusted project registration in
a controlled environment that is not a security sandbox and never invokes a
component. Initialization is create-only, uses the loader as its acceptance
gate, and creates no state or dependency directories. Producer execution
invokes exactly the selected producer once with a closed request, validates its
closed result, and delegates its candidate to the imported runtime admission
primitive. Risk execution prepares one immutable episode state and invokes
exactly the explicitly selected compatible provider once through the imported
runtime primitive. Neither standalone computation operation retries,
initializes state, or persists output. Durable bundle execution is explicit,
requires initialized state, and independently commits terminal episode
dispositions; continuation skips committed initial dispositions. State
initialization is a distinct create-only operation;
the physical adapter remains protected and opens DBI/DuckDB only for bounded
work. The installed transparent provider is a protected,
nonclinical deterministic reference that must be selected explicitly; it is
not a default or fallback.
}
\author{RRP maintainers}
\keyword{internal}
