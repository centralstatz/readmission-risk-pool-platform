# Synthetic reference source implementation

This directory is the first complete source implementation beneath the public
canonical boundary. Everything here is deterministic, wholly fictional,
nonclinical, and intended only for software teaching and conformance.
Generated scores are simulation artifacts, not validated predictions.

```text
fictional source tables
        ↓
source-local validation
        ↓
implementation-owned mapping
================================ canonical boundary
three-domain canonical bundle
        ↓
generic canonical conformance
```

Everything beneath this directory may understand the fictional source design.
Generic canonical code may not import these files, inspect these source tables,
or branch on the synthetic implementation identity.

## Source domains

The generator creates six related data frames:

- `patients` — fictional local patient registry and source-only demographics;
- `encounters` — index and readmission inpatient encounters;
- `discharges` — local discharge registry with observation-window policy;
- `risk_scores` — local score feed with assessment and receipt time;
- `activity_events` — local post-discharge activity codes and dual time; and
- `outcomes` — readmission/death notifications with receipt time.

They are not renamed canonical domains. Mapping must join encounters and
discharges, construct canonical episode IDs, translate source codes, filter by
availability, and discard source-only fields.

## Identities and configuration

[`implementation.yml`](implementation.yml) keeps implementation, mapping,
generator, and source-schema identities separate. [`source-schema.yml`](source-schema.yml)
governs source-local fields, relationships, codes, and time rules.

Two deterministic configurations are supplied:

- [`config/test.yml`](config/test.yml) — 4 patients and 6 discharge episodes;
- [`config/reference.yml`](config/reference.yml) — 24 patients and 36 discharge
  episodes for the human teaching path.

Each declares a seed, simulation reference time, canonical as-of time, scale,
and version references. The current reference operation deliberately uses the
simulation reference time as the canonical cutoff, but keeps both fields
explicit. Generation includes some source facts received after that cutoff;
mapping excludes them rather than erasing their availability semantics.

## What a hospital replaces

An adopter replaces this directory with approved source queries/extracts,
source-local rules, code translations, identifier construction, and mapping
provenance. Its producer must emit the same public bundle/profile and pass the
same generic canonical validator. The adopter does not replace generic
canonical contracts or make platform code understand its table names.

## Generated data policy

Generation code and configuration are authoritative. The operation keeps
source and canonical objects in memory and writes nothing. Tests generate
temporary deterministic objects. No rich generated dataset is committed; the
small readable Phase 2 canonical fixture remains the immediate static example.

Run the documented human operation in
[Generate the synthetic reference](../../docs/operations/generate-reference.md).

