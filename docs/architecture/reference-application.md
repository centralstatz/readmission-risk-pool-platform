# Minimal product-only reference application

## Boundary and dependency

The Iteration 6.2 Shiny app receives one already validated logical
product-access object. It cannot discover paths, parse YAML, connect to DuckDB,
read operational history, invoke runtime/provider/source code, rebuild
products, or write platform state. The launcher composes the physical adapter
and injects access. The app is stateless with respect to platform history.

`shiny` is the only direct app dependency. Base graphics and Shiny's standard
page, table, select, plot, and tab components are sufficient; no dashboard or
styling framework is directly required. Shiny's transitive packages are locked
by `renv`.

## Views

- **Current episode risk** shows episode, exact probability, estimand,
  provider, state as-of, and source run. Descending probability is presentation
  sorting, not priority, recommendation, task, or decision policy.
- **Episode risk history** selects an episode and shows actual persisted
  estimate-as-of points plus a table. Points are not connected or interpolated.
  Provider IDs/versions remain visible across transitions.
- **Platform / run status** shows represented terminal runs, status,
  successful/failed counts, providers, and global freshness facts.

The freshness banner distinguishes source as-of and cutoff from product
generation and physical publication, and shows the latest represented run.

## Empty and failure behavior

An available zero-row product is valid and renders a plain empty-state message.
Initialization defensively checks exact product IDs/versions, availability, row
counts, and shared set metadata. A failed access object produces a safe
actionable page without a stack trace. The supported launcher fails before
starting when physical integrity, compatibility, or coherence fails.

This is a fictional, nonclinical reference interface. Final UX, access control,
deployment packaging, priority policy, scheduling, replay, and observability
remain future work.

Phase 7 keeps app validation and launch as distinct read-only human operations.
Neither operation runs the platform, opens DuckDB, or rebuilds products.

Iteration 8.1 packages the unchanged app behind
`platform.reduced-application-artifact@0.1.0`. The artifact supplies validated
read-only YAML product access before injection; the application modules remain
unaware of YAML, artifact paths, deployment targets, and hosting configuration.
