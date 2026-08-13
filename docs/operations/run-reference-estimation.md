# Run reference estimation

## Purpose

This operation proves the completed Phase 4 path using the current clean
temporary package
installation:

```text
admitted canonical bundle
  → eligibility
  → episode state
  → provider-neutral estimand request
  → exact registered reference provider
  → execution result
  → accepted estimate
```

It is a deterministic software-conformance demonstration. It does not persist
estimates, rank episodes, apply decision policy, construct products, or claim
clinical validity.

## Prerequisites

- R available through `Rscript`;
- a local checkout of this repository; and
- the locked environment restored with `Rscript -e 'renv::restore()'`.

Run commands from the repository root.

## Inputs and commands

Use the source-independent fictional canonical fixture:

```sh
Rscript operations/run-reference-estimation.R --input independent
```

Use the deterministic synthetic producer at test scale:

```sh
Rscript operations/run-reference-estimation.R --input synthetic --scale test
```

The synthetic input also supports `--scale reference`. Defaults are
`--input synthetic --scale test`. The scale argument is validated for either
input but affects only synthetic generation.

## Output and side effects

Success prints the input and scale, runtime/estimand/provider/estimate
identities, eligible episode count, request count, successful estimate count,
and nonzero execution-status counts. It exits with status `0`. Invalid
arguments or a failed producer, runtime, registration, compatibility, adapter,
or conformance step produce a message and nonzero status.

The operation installs `rrpruntime` into a temporary library and unloads it at
exit. It reads maintained contracts and fixtures and holds source, canonical,
runtime, provider, result, and estimate objects in memory. It does not write a
dataset, registry, estimate, product, configuration, model, or operational
history. Ordinary console output is not a provenance, audit, or metrics store.

## Validation

A successful run must report the exact provider
`reference.transparent-readmission-hazard@0.1.0`, estimate contract
`platform.readmission-risk-estimate@0.1.0`, and equal request and successful
estimate counts. Run the current completed Phase 6 checkpoint separately:

```sh
Rscript operations/validate.R --mode checkpoint
```

## Recovery and troubleshooting

- **Unsupported or missing provider:** restore the maintained provider
  declaration and trusted registration pairing. Do not load a path or choose a
  latest version implicitly.
- **Unsupported request or missing input:** inspect the provider declaration,
  estimand/state identities, target interval, capability statuses, and state
  required fields. Do not invoke the provider to bypass compatibility.
- **Execution failure:** fix the approved adapter. A failed call must remain a
  structured failure and must not become an `NA` estimate.
- **Invalid output:** correct provider identity, request/state/episode linkage,
  interval, cardinality, provenance, or finite probability bounds. Do not
  weaken platform conformance for one provider.
- **Synthetic producer failure:** run
  `Rscript operations/generate-reference.R` and correct the source or canonical
  stage before retrying estimation.
- **Package installation failure:** restore the locked environment and rerun
  validation. Do not source package implementation files as a substitute for
  the supported operation.

After correction, rerun the same command. No estimate recovery or rollback is
needed because this operation has no durable side effects.
