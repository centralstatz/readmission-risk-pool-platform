# Fictional Reference Walkthrough

This walkthrough covers the deterministic fictional, nonclinical Stage 8
project. It uses supported package operations and explicit roots. It does not
require the development repository, Git, a working-directory convention,
network access, credentials, or an installed reference provider.

## Initialize and inspect

Open the installed resource catalog and initialize the supplied project at an
absent destination:

```r
library(rrpplatform)
catalog <- rrp_open_resource_catalog(software_root)
result <- rrp_initialize_fictional_project(catalog, project_root)
stopifnot(rrp_operation_succeeded(result))
rrp_validate_project(catalog, project_root)
```

Read the project README, `rrp-project.dcf`, `rrp-authoring.dcf`,
`R/produce-canonical.R`, and `R/calculate-risk.R`. The two callable files are
the ordinary hospital mapping and provider edit surfaces. `R/register.R` is the
same thin standard-authoring adapter used by every normal initialized project.

## Generate project-owned source

The generator is trusted project code and must be called explicitly:

```r
generator <- new.env(parent = baseenv())
sys.source(file.path(project_root, "R", "generate-source.R"), generator)
generator$rrp_generate_fictional_source(project_root)
```

Inspect `source/generated/source.dcf`, `stays.csv`, `events.csv`, and
`identity-crosswalk.csv`. The fixed reference time is
`2026-01-20T12:00:00Z`. The native IDs and local event codes differ from the
canonical vocabulary. The explicit project crosswalk assigns canonical
identities, while the stays table retains one provider-only fictional signal
and its availability time. Repeating generation accepts only the exact
byte-identical realization and never overwrites changed content.

## Exercise producer and provider boundaries

Produce and admit canonical data at the fixed reference time:

```r
as_of_time <- "2026-01-20T12:00:00Z"
produced <- rrp_execute_producer(catalog, project_root, as_of_time)
stopifnot(rrp_operation_succeeded(produced))
bundle <- produced$value
```

The admitted domains contain only governed canonical fields. Native IDs, the
crosswalk, local event codes, predictor values, and source availability
metadata are not part of the canonical bundle.

The active fictional episode demonstrates the ordinary project provider:

```r
estimated <- rrp_execute_risk(
  catalog, project_root, bundle, "fictional.episode.001", as_of_time
)
stopifnot(rrp_operation_succeeded(estimated))
estimated$value
```

RRP constructs the unchanged provider-neutral request. Project code resolves
the canonical episode back to private source identity, retrieves the signal,
checks its availability through the analytical cutoff, and returns one
deterministic nonclinical probability. RRP performs provider-result validation
and constructs the accepted estimate.

## Current boundary

This Increment 8.B walkthrough proves initialization, explicit generation,
mapping, admission, and project-provider execution. Durable initialization,
bundle execution, repeat/idempotency, and history inspection form the separate
Increment 8.C installed end-to-end proof. No source is generated implicitly,
and no product, application, CLI, deployment, or clinical claim exists.
