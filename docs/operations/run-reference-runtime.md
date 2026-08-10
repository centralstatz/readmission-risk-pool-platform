# Run the reference runtime

## Purpose

This operation demonstrates:

```text
canonical admission → eligibility → episode state → estimand request
```

It installs `rrpruntime` into a temporary library, loads the maintained runtime
contracts explicitly, admits one canonical input, and runs the small package
APIs. It does not invoke a provider, estimate risk, persist data, build a
product, or perform deployment work.

## Commands

Run the source-independent Phase 2 fixture:

```sh
Rscript operations/run-reference-runtime.R --input independent
```

Run the Phase 3 synthetic test-scale producer and pass only its admitted bundle
to runtime:

```sh
Rscript operations/run-reference-runtime.R --input synthetic --scale test
```

The synthetic reference scale is also supported with `--scale reference`.

## Output and side effects

Success prints the runtime/state/estimand identities, bundle cutoff, episodes
evaluated, states and requests created, and eligibility-reason counts. No
patient-level rows or risk values are printed.

The temporary package library and installer output are removed before exit.
The operation writes no state, request, estimate, product, manifest, or log and
does not modify Git or a sibling repository.

## Failure and recovery

- **Canonical admission failed:** fix the owning canonical producer or fixture;
  runtime is not invoked.
- **Package installation failed:** restore the repository R environment and
  inspect `runtime/DESCRIPTION`, `NAMESPACE`, and package source.
- **Runtime contract failed:** restore the supported `0.1.0` documents or make
  an explicit compatibility change.
- **Runtime input failed:** correct the representation adapter; do not add a
  source-specific branch to the package.
- **As-of mismatch:** rebuild/admit the bundle for the desired cutoff. Iteration
  4.1 deliberately does not replay an earlier time from a later bundle.

Run `Rscript tests/run-phase4-tests.R`, then the validation operation described
in [Validation](validation.md).
