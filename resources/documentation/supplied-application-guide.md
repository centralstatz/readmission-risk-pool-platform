# Supplied Application Guide

The Readmission Risk Pool (RRP) supplied application is an installed, generic
local Shiny application for examining one already materialized RRP logical
product set. It presents the Current Risk Pool, an episode's actual accepted
risk trajectory, and direct descriptive and operational-scope summaries. It is
not a clinical priority list, care-management queue, product builder, data
editor, deployment artifact, or hospital-authored application.

This guide accompanies `rrp.application.supplied@0.1.0` and its bounded
`rrp.project-brand@0.1.0` interpretation in the same installed software
resource catalog.

## Prerequisites

Use installed `rrpplatform` and `rrpruntime` packages and an explicit installed
software root containing the matching RRP resource catalog. The project must be
a conforming initialized project with compatible current products already
built and materialized through the ordinary RRP workflow. A fictional project
created by `rrp_initialize_fictional_project()` is an ordinary reference
consumer of this same application; it is not a special application mode.

Project initialization, source acquisition, durable analytical execution,
product construction, and materialization are separate operations. Complete
those operations before application launch. The installed Logical Products
Guide, resolved as `rrp.documentation.logical-products-guide`, describes the
product lifecycle.

## Launch the local application

Open the explicit installed catalog, then launch against one explicit project:

```r
library(rrpplatform)

software_root <- "/installed/rrp/software"
project_root <- "/hospital/rrp-project"
catalog <- rrp_open_resource_catalog(software_root)

result <- rrp_launch_app(
  catalog,
  project_root,
  launch_browser = TRUE
)
```

The application binds only to the loopback interface. The call returns after
the local Shiny session stops. Close the browser tab and stop the R operation
with the usual interrupt for the R environment (typically Ctrl+C in a
terminal). Stage 10 supplies this package-level local application boundary;
installation, operator commands, authentication, remote hosting, deployment,
and product-only artifacts belong to later work.

To ask whether the current realization represents an expected governed source
operation and history cutoff, provide both values:

```r
result <- rrp_launch_app(
  catalog,
  project_root,
  expected_operation_run_id = "rrp.operation-run.example",
  history_cutoff = "2026-01-20T12:00:00Z",
  launch_browser = TRUE
)
```

The pair changes only the displayed freshness assessment. It does not refresh,
rebuild, or replace products.

## What startup reads

Before starting Shiny, RRP validates the supplied application authority,
required packages, the project root, optional bounded `_brand.yml` content and
contained logo, and the current product realization. It then reads exactly the
three validated detached products:

- current remaining risk;
- actual remaining-risk trajectory; and
- operational scope summary.

Missing, corrupt, or incompatible products fail before a server starts and
return a bounded operation diagnostic. A valid stale realization remains
readable with a visible warning. With no expected source context, freshness is
shown neutrally as not evaluated. A valid empty realization opens the normal
shell, states that no current accepted risk estimates exist, retains coherent
zero-count Overview facts, and fabricates no trajectory.

The application does not read raw hospital source tables, canonical producer
input, the history database, provider or producer executable source, or
credentials. It does not invoke a producer or provider, retry or correct
history, build or materialize products, refresh in the background, or mutate
project analytical state. To display a newer realization, complete the normal
analytical and product workflow outside the application, stop the current
session, and relaunch.

## Reading the application

Current Risk Pool shows accepted current remaining readmission-risk estimates.
Rows retain canonical episode identity, exact probability text, analytical
as-of and remaining-follow-up context, and provider/model attribution. Search,
exact provider/model filters, explicit sorting, bounded paging, and one-row
selection affect presentation only. A row sparkline contains only that
episode's actual governed trajectory observations. Its restrained connector is
visual continuity between observed points, not interpolation or an estimate at
an unobserved time.

The episode selector and selected table row stay synchronized. Episodes that
have retained trajectory observations but no current estimate remain
selectable and are clearly labeled; they do not become current rows. Episode
Risk Trajectory shows the selected episode's actual observations on a fixed
probability scale, with exact tooltips and an exact observation table. One
observation remains one marker, and no observations produce an explicit
unavailable state. No smoothing, carry-forward, baseline value, daily series,
threshold, or risk category is inferred.

Overview reports only direct current-risk summaries (count, minimum,
quartiles, median, and maximum) and exact operational-scope reconciliation.
It does not calculate readmission rates, business KPIs, intervention results,
clinical priorities, recommendations, or outcome claims.

## Bounded standard branding

If `_brand.yml` is absent, immutable RRP defaults supply the display name and
primary composition color. A standard initialized project may supply a display
identity, one primary color, and one safe project-contained PNG or JPEG logo
with alternative text. These declarative values affect bounded identity and
composition only; they cannot change product values, risk encoding, filtering,
freshness, or analytical behavior.

Valid standard-brand fields outside the supported subset are ignored. An
invalid supported value, malformed branding file, remote logo, absolute logo
path, escaping path, linked asset, unsupported image bytes, or oversized logo
fails with the bounded application-brand diagnostic. Hospital projects cannot
supply executable CSS, JavaScript, HTML, Shiny modules, component definitions,
or application configuration. Executable application composition and RRP CSS
remain installed RRP-owned software.

## Keep the boundary explicit

`rrp_launch_app()` is a blocking local operation over existing validated
products. Inspect its returned operation result after the session exits:

```r
if (!rrp_operation_succeeded(result)) {
  result$diagnostics
}
```

Do not place patient data, credentials, private mappings, or connection strings
in application diagnostics, project branding, or shared examples. This guide
describes the Stage 10 local supplied application. It makes no deployment,
multi-user, accessibility-certification, performance, support, clinical, or
production-readiness claim.
