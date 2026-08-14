# Generate and validate the synthetic reference

## Purpose

This operation answers one bounded question:

> Does the deterministic fictional source implementation currently produce a
> canonical bundle conforming to `platform.readmission-initial-profile@0.1.0`?

It runs configuration validation, fictional source generation, source-local
conformance, source-to-canonical mapping, generic producer-result validation,
and existing canonical admission in that order through the same installed
producer seam used by the stable platform run. It does not run a provider,
construct state, persist records, build
products, launch an application, or deploy anything.

## Prerequisites

- Run from the repository root with `Rscript` available.
- Restore the locked environment with `Rscript -e 'renv::restore()'` if needed.
- Treat every result as fictional, nonclinical software evidence.

## Commands

Generate and validate the richer reference scale:

```sh
Rscript operations/generate-reference.R
```

Run the small test scale through the same complete path:

```sh
Rscript operations/generate-reference.R --scale test
```

The default reference configuration declares seed `31001`, 24 patients, 36
discharge episodes, and cutoff `2026-08-01T12:00:00Z`. The test configuration
declares its own identity and seed; it is not a shortcut around source mapping.

## Output and side effects

Success prints each stage and stable high-level counts. The operation keeps all
generated data in memory and writes no source, canonical, product, manifest, or
log file. It does not modify Git or either sibling repository.

Generator identity/version plus the complete configuration and seed determine
the output. The two explicit time fields currently match by contract:
`simulation_as_of_time` selects the fictional reference snapshot, and
`canonical_as_of_time` is the platform availability cutoff. Wall-clock
execution time is neither value.

## Failure meaning

- **configuration failed** — identity, classification, scale, counts, or time
  declarations are invalid; generation does not run;
- **generation failed** — the implementation could not construct source
  objects;
- **source-local validation failed** — source keys, relationships, codes, or
  times violate the implementation-owned schema; mapping does not run;
- **mapping failed** — valid source meaning has no approved translation or the
  mapping operation failed; canonical admission does not run;
- **canonical conformance failed** — mapping produced a candidate, but the
  generic Phase 2 profile validator rejected it.

The producer's local claims are evidence, not platform admission authority.
Only the existing canonical validator determines canonical conformance.

## Recovery and troubleshooting

Rerun with `--scale test` to reproduce a smaller failure. Correct the owning
layer: configuration under `implementations/synthetic-reference/config/`,
source generation/validation below the implementation boundary, mapping in
the implementation mapper, or public contract usage where canonical
conformance identifies an issue. Do not weaken generic validation or add a
synthetic identity branch to make the reference pass.

Run `Rscript tests/run-phase3-tests.R` for implementation-focused failure
scenarios and `Rscript operations/validate-producer.R` for reusable producer
conformance, then run
the repository validation documented in [Validation](validation.md).
