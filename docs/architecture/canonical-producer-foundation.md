# Canonical producer and adopter handoff foundation

## Status and scope

**Status:** authoritative Iteration 10.1 producer seam; Phase 10 remains in progress

This document defines the supported seam through which one configured source
implementation supplies canonical data to one platform installation. It does
not prove an independently developed hospital-like producer; Iteration 10.2
owns that proof.

## Five distinct responsibilities

```text
declaration → trusted registration → installation selection → execution
                                                            ↓
                                                canonical admission
                                                            ↓
                                                unchanged downstream
```

- A **declaration** identifies the producer, implementation, mapping, exact
  canonical profiles, capabilities, execution behavior, and ownership rules.
- **Trusted registration** pairs that declaration with a callable in maintained
  platform composition code. YAML never loads code.
- **Selection** in `config/platform-instance.yml` names exactly one registered
  producer ID and version for this installation.
- **Execution** passes producer-owned configuration to that callable and
  receives a structured result. Failed stages short-circuit.
- **Admission** checks identity/capability/as-of consistency and applies the
  existing canonical profile conformance. Only then can the bundle enter the
  runtime.

The language-neutral contract is
`platform.canonical-producer@0.1.0`; successful and failed execution use
`platform.canonical-producer-result@0.1.0` semantics. The executable R
realization lives in the operations layer because it composes a pre-runtime
implementation boundary; `rrpruntime` remains post-canonical and base-R-only.

## Identity and result semantics

Producer identity selects a trusted executable component. Implementation
identity attributes the health-system/source context. Mapping identity
attributes the interpretation that produced canonical meaning. These remain
separate from canonical run/bundle, analytical runtime run, provider,
persistence, product, operation-run, artifact, and deployment identities.

A successful final result contains:

- exact producer, implementation, and mapping identity/version;
- one producer execution ID;
- exact canonical profile and as-of context;
- explicit declared capabilities;
- ordered producer-configuration, source-validation, mapping, and canonical-
  admission statuses;
- structured conformance results and provenance references; and
- one admitted canonical bundle.

A failed result contains no canonical bundle. It may preserve safe structured
conformance/provenance evidence, but source rows and configuration do not cross
the generic result boundary. Invalid candidate output is not repaired or
coerced.

## Trusted callable and installation composition

`operations/compositions/installed-producers.R` is maintained trusted code for
this installed source composition. It explicitly registers the shipped
synthetic adapter. `config/platform-instance.yml` contains only the exact
selection and one-health-system scope; it contains no executable path,
function, package, credentials, or connection details.

A future adopter producer must provide a conforming declaration and callable,
be explicitly registered in trusted installation composition, pass the same
conformance suite, and then become the single selected producer. Automatic
directory discovery, dynamic plugins, remote loading, and arbitrary YAML code
execution are unsupported. Final packaging of adopter-owned code—inside an
installed source tree, a private package, or a companion repository—remains an
open Phase 10/11 decision because Iteration 10.1 does not need to choose it.

## Shipped reference peer

`reference.synthetic-canonical-producer@0.1.0` wraps the existing deterministic
source generation, source-local validation, and mapping. The adapter returns a
candidate only after producer-owned stages succeed. Generic producer execution
then performs canonical admission and returns the only bundle supplied to
runtime/history composition. The stable run does not source synthetic files or
branch on its identity.

The `--profile reference` command switch has been removed. It previously mixed
installation composition with per-run input. Producer choice now comes from
the installation configuration. The shipped `--scale` option remains a narrow
reference-producer configuration input; it does not select a health system.

## Configuration, secrets, and storage ownership

Producer-specific extraction, source object names, vocabulary mappings, and
connections belong below the producer boundary. Secrets are environment-owned
and never committed or placed in declarations, platform-instance selection,
canonical contracts, diagnostics, or ordinary conformance output.

Source and operational-history storage are independent. A producer may read a
warehouse or API while the unchanged platform writes DuckDB history; replacing
the source does not select or alter persistence. The producer cannot write
history, products, or app data directly.

## Conformance and human operation

Run the configured producer conformance scenario without downstream execution:

```sh
Rscript operations/validate-producer.R
```

The reusable machinery validates declaration identity, trusted registration,
exact selection, result/failure semantics, deterministic output when declared,
profile/capability/as-of/provenance agreement, and canonical admission. It is
software conformance, not clinical validation, production authorization,
privacy approval, or proof of a hospital integration.

Producer boundaries emit privacy-safe operation events for resolution,
execution, and admission. Allowed identities and aggregate counts exclude
source rows, patient/episode identifiers, SQL, paths, credentials, connection
strings, and raw configuration. The console retains nothing by default.

## Iteration boundary

Iteration 10.1 establishes the seam and moves the shipped producer onto it.
Iteration 10.2 must independently implement a materially different fictional
adopter producer, register/select it through the same mechanism, pass the same
suite, and prove unchanged downstream behavior. Until then, turnkey hospital
onboarding and the final extension-distribution model are not complete.

