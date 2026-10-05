# RRP Project Authoring Guide

This document describes the supported standard authoring boundary in
`rrp.project-authoring@0.1.0`. An RRP project is hospital-owned trusted code and
nonsecret configuration selected through one explicit project root. It is not
RRP source, an installation, or project state.

## Standard project

A normally initialized project contains exactly six authoring paths:
`rrp-project.dcf`, `rrp-authoring.dcf`, `R/register.R`,
`R/produce-canonical.R`, `R/calculate-risk.R`, and `README.md`. Normal hospital
authors edit the manifest and authoring metadata when their declared identities
or paths change, and put executable hospital logic only in the producer and
provider files. The generated registration file is thin RRP wiring and normally
does not change.

It also contains two declarative presentation resources: `_brand.yml` and
`assets/project-logo.png`. The installed supplied application supports only a
bounded standard subset: display identity, one primary color, and one
contained PNG/JPEG logo. These resources do not add hospital application code,
change analytical behavior, or alter the six authoring paths. Valid projects
may remove `_brand.yml` to use RRP defaults; any referenced logo must remain a
safe project-relative regular file.

`rrp-project.dcf` owns project identity and version, the exact selected producer
and provider identities, the canonical profile, extension-library path, and
state path. `rrp-authoring.dcf` owns producer implementation, mapping, provider
implementation, optional model identity, and the exact installed extension
package/version inventory. The optional model ID and version must either both
be absent or both be present. `Extension-Packages: none` declares a base-R-only
project; otherwise use comma-separated `Package@version` entries.

Project R code is trusted local executable code, not a security sandbox. RRP
evaluates only the fixed files in isolated environments, requires their exact
bindings and signatures, validates declared dependencies before either callable
is invoked, and keeps RRP libraries ahead of the project extension library.
RRP does not acquire, solve, or install project packages.

## Producer responsibility

`rrp_produce_canonical(project_root, as_of_time)` obtains approved hospital
source data through any suitable local mechanism and interprets identifiers,
codes, timestamps, and availability into the installed canonical profile. On
success it returns exactly a named list containing `discharge_episode` and
`terminal_event` data frames in the field order defined by resources
`rrp.domain.discharge-episode` and `rrp.domain.terminal-event`.

The hospital owns source access, source-local validation, canonical identity
assignment, source-to-canonical mapping, time interpretation, and truthful
implementation/mapping versions. RRP owns the raw producer request/result,
fixed capabilities, candidate bundle, deterministic content-sensitive bundle
identity, and canonical admission. Source-native identities and private fields
must not be added to canonical domains unless the canonical authority defines
them.

## Provider responsibility

`rrp_calculate_risk(project_root, request)` receives the detached governed
Stage 6 request. The hospital owns canonical-to-local identity resolution,
private predictor acquisition and feature engineering, model or engine loading,
and ensuring all private inputs are legitimate at `request$as_of_time`. RRP
does not persist a hospital crosswalk or arbitrary predictors and does not
validate temporal provenance inside opaque hospital logic.

On success the provider returns one finite unclassed base-R double probability
in `[0,1]` for the singular RRP remaining-readmission-risk target. The complete
request is documented by resource
`rrp.documentation.provider-request-reference`. RRP owns selection,
compatibility, the provider-neutral request, the raw four-field result,
execution containment, validation, accepted-estimate construction, and history.

## Controlled failure and raw escape hatch

Either normal callable may return `rrpplatform::rrp_authoring_failure(code)`
with an existing applicable raw failure code. It carries no arbitrary text.
Invalid returns and thrown errors remain distinct detected failures with
privacy-safe diagnostics. The adapter never treats `NULL` or `NA` as an
intentional unavailable result.

An advanced project may replace `R/register.R` and implement the unchanged raw
`rrp.project-registration@0.3.0` producer/provider contracts directly. That is
the flexible lower-level extension boundary; the standard layer is only a
ceremony-reducing adapter over it.

RRP conformance does not establish clinical validity, calibration, fairness,
production authorization, or local governance approval.
