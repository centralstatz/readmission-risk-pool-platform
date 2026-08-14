# Synthetic reference source and canonical producer

## Status and scope

**Status:** authoritative Phase 3 reference implementation boundary

This document applies [Platform True North](../vision/platform-true-north.md),
the [Platform Architecture](platform-architecture.md), and the approved
[Initial Canonical Clinical Profile](canonical-clinical-profile.md). The
implementation is a teaching realization beneath the public handoff, not a new
canonical contract or a privileged generic mode.

## Complete reference flow

```text
six fictional relational source feeds
        ↓
implementation-local schema and conformance
        ↓
deterministic source-to-canonical mapping
        ↓
candidate platform.readmission-initial-profile@0.1.0 bundle
        ↓
platform.canonical-producer@0.1.0 adapter/result
        ↓
existing generic canonical admission
```

The implementation-private result retains configuration, generation,
source-local, and mapping status separately. Its trusted adapter removes source
representation and returns the generic candidate result. Generic producer
execution alone exposes a successful bundle after canonical admission. A
failure stops before later stages and returns no canonical output.

## Identity

The reference uses independent `0.1.0` identities:

| Responsibility | Logical identity |
|---|---|
| implementation | `reference.synthetic-health-system` |
| generator | `reference.synthetic-health-system-generator` |
| source schema | `reference.synthetic-health-system-source-schema` |
| mapping | `reference.synthetic-to-readmission-canonical` |

Git, a local path, and wall-clock time are not required logical identity.
Configuration separately declares the seed, scale, simulation reference time,
canonical as-of time, and profile selection.

## Source and mapping ownership

The source includes patient registry, encounters, discharge registry, risk
feed, activity feed, and terminal-outcome feed. Source-local validation owns
their columns, primary/foreign keys, codes, encounter/window timing, receipt
ordering, score range, and readmission encounter integrity.

Mapping owns canonical episode construction; patient and encounter lineage;
window construction; terminal timestamps; source-model identity; probability
representation; source activity/outcome translation; occurrence/availability;
as-of filtering; and mapping provenance. Source-only region, labels, local
codes, and note classes are discarded.

All three capabilities are `available` in standard configurations. Some
episodes have no baseline or events. Domain capability describes
implementation support and supplied domain instance, not one row per episode.

## Time behavior

The generator creates a complete fictional source history that includes facts
whose `received_at` is later than the configured platform cutoff. Source-local
validation permits these valid source facts. Mapping admits only scores,
events, and outcomes available by canonical `as_of_time`. Occurrence remains
separate from receipt, and wall-clock execution is irrelevant.

## Scales and retention

The test scale exercises the full path with 4 patients and 6 episodes. The
reference scale has 24 patients, 36 episodes, repeated patients, incomplete
baseline coverage, zero-event episodes, delayed availability, readmission and
death outcomes, active episodes, and post-cutoff source information.

Generation code/configuration are authoritative. Generated objects remain
in-memory or temporary; no rich generated source/canonical dataset is
committed. This keeps regeneration reviewable and avoids treating frozen rows
as public compatibility promises.

## Replacement boundary

A hospital implementation replaces source extraction, source schema/rules,
configuration, mapping, and producer provenance. It supplies a declaration and
trusted callable conforming to
[`platform.canonical-producer@0.1.0`](../../contracts/canonical/canonical-producer.yml),
passes reusable producer conformance, and becomes the exact single installation
selection. Generic validation, runtime/provider behavior, persistence,
products, application, and deployment remain unchanged and must never inspect
this implementation's identity or source tables. The independent adopter proof
and final packaging remain Iteration 10.2/later work.

The executable human procedure is
[Generate and validate the synthetic reference](../operations/generate-reference.md).
