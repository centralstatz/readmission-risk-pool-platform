# Fictional RRP hospital project

This independent project is a deterministic, visibly fictional, nonclinical
teaching implementation. Its data and probabilities must never be interpreted
as patient facts, clinical evidence, a validated model, or production advice.

The project uses the ordinary standard-authoring boundary. Hospital-owned logic
lives in `R/produce-canonical.R` and `R/calculate-risk.R`; `R/register.R` is thin
generated wiring and is not normally edited. `rrp-project.dcf` selects the
project producer/provider, and `rrp-authoring.dcf` records implementation and
mapping identities with an explicitly empty extension-package inventory.

`_brand.yml` and `assets/project-logo.png` provide the fictional hospital's
bounded visual identity to the same installed RRP application used by every
project. They contain no Shiny application, CSS, JavaScript, or analytical
configuration.

`R/generate-source.R` is an extra project-owned teaching surface. Explicitly
source it and call its one function before producer execution:

```r
generator <- new.env(parent = baseenv())
sys.source(file.path(project_root, "R", "generate-source.R"), generator)
generator$rrp_generate_fictional_source(project_root)
```

The generator creates `source/generated` only when absent, or accepts the exact
byte-identical realization. Inspect the four generated files. The fact tables
use native fictional identifiers and local event codes; the explicit
crosswalk assigns canonical episode, patient, and encounter identities. One
native stay ID intentionally violates canonical grammar. The stays table also
contains a fictional provider-only signal and its availability timestamp.

The producer validates source structure, keys, relationships, codes, times,
crosswalk completeness, and signal availability metadata before mapping. It
filters facts by the requested analytical cutoff and returns only the exact
canonical `discharge_episode` and `terminal_event` domains. Native IDs, local
codes, the crosswalk, source availability controls, and provider signal do not
enter canonical output.

The provider receives the unchanged 19-field RRP request, resolves its canonical
`episode_id` back to the native stay through the private crosswalk, requires the
signal to be available through `request$as_of_time`, and applies a small
deterministic nonclinical formula. Missing or late input returns the supported
`provider_input_unavailable` failure.

Detailed installed resources are:

- `rrp.documentation.project-authoring-guide`;
- `rrp.documentation.provider-request-reference`; and
- `rrp.documentation.fictional-reference-walkthrough`.

Resolve them from an explicit installed software catalog with
`rrpplatform::rrp_resource_path()`. The project contains no credentials,
network access, database connection, Git dependency, clinical model, or real
patient data.
