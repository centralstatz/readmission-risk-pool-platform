# Logical product foundation

## Purpose and maturity

Iteration 6.1 defines the first product boundary over the completed Phase 5
[operational-history port](operational-history-foundation.md), following the
[Platform Implementation Plan](platform-implementation-plan.md). The
machine-readable suite begins at
[`platform.initial-risk-product-set@0.1.0`](../../contracts/products/initial-risk-product-set.yml),
and its supported command is documented in
[Build and inspect reference logical products](../operations/logical-products.md).
Its logical responsibility stops at:

```text
valid operational-history reads
        ↓
backend-neutral product builders
        ↓
conforming logical product objects
        ↓
logical in-memory access boundary
```

The product layer is rebuildable consumer projection, not historical
authority. Iteration 6.2 realizes the unchanged seam through the replaceable
[YAML reference materialization](reference-product-materialization.md) and
[minimal product-only application](reference-application.md). Priority/decision
policy, replay, deployment, and observability remain absent. The contracts and
implementation are pre-1.0 software interfaces and make no clinical-validity
or production claim.

## Initial core suite

`platform.initial-risk-product-set@0.1.0` requires exactly three products.

| Logical member | Contract | Grain and row key |
|---|---|---|
| `current_episode_risk` | `platform.current-episode-risk@0.1.0` | One current valid accepted estimate per episode and estimand; episode ID + estimand ID/version |
| `episode_risk_history` | `platform.episode-risk-history@0.1.0` | One valid persisted accepted estimate; estimate ID |
| `operational_run_summary` | `platform.operational-run-summary@0.1.0` | One valid completed operational run; runtime run ID |

This deliberately narrow suite exposes what the platform has actually retained:
accepted probabilities, their historical attribution, and terminal run facts.
It contains no queue, priority band, recommendation, task, intervention,
executive penalty metric, measure attribution, or geography.

### Current accepted risk

The current product includes one row for each episode/estimand pair with a
current valid accepted estimate at the explicit product cutoff. The builder
calls `read_current_estimate()` and therefore inherits the persistence port's
validity, completed-run, greatest-as-of, terminal-time tie-break, and ambiguity
semantics. It does not reevaluate eligibility or infer that an episode remains
clinically active beyond what the accepted record establishes.

Each row keeps estimate, state, run, estimand, provider, optional model, target
interval, and probability identity. Patient lineage is not present because the
initial persisted state does not own that field. Adding it later requires a
compatible persisted upstream meaning and a deliberate product-contract
change. Risk category and priority labels are prohibited.

### Persisted risk history

The history product contains only accepted estimates returned by valid run
history reads. It never reruns a provider over old cutoffs. Provider A rows
therefore remain Provider A when Provider B becomes active. An invalidated
estimate is absent from the valid product; a restatement is the new accepted
estimate under its new run, with the run's `restates`/`supersedes` provenance
references retained when supplied.

### Operational run summary

The summary product reports application-facing terminal facts, not telemetry.
It preserves run/as-of/status time, `completed` versus
`completed_with_failures`, provider and estimand references, implementation and
mapping identity, run provenance, and exact persisted family/failure counts.
The builder checks those counts against the terminal status summary before
constructing a row.

## Source selection and closure

The generic builder receives a validated persistence port, one or more
explicit source runtime-run IDs, an explicit cutoff, and parsed product
contracts. Every selected run must expose exactly one valid `completed` or
`completed_with_failures` terminal status. The caller asserts that these sorted
IDs form the complete selected history scope at the cutoff. If a port's
current read returns an estimate outside that scope, the build fails rather
than silently mixing product histories.

The Phase 5 port intentionally has no backend-wide run-discovery method.
Iteration 6.1 does not widen it merely for the reference operation. The human
reference command uses the deterministic run ID for the selected scale unless
the operator supplies one or more `--run-id` arguments. Broader deployment run
catalog/selection is a future operation or logical query concern.

## Logical product and product-set identity

Every product object contains:

- its exact product specification reference and deterministic instance ID;
- shared product-set ID;
- `available` status and row count;
- sorted source run IDs and latest represented valid run;
- source cutoff and source as-of time;
- product generation time;
- ordered logical rows; and
- source-run provenance references.

The deterministic product-set ID includes the set specification, exact member
specifications, `platform.logical-risk-product-builder@0.1.0`, sorted source
run IDs, and source cutoff. Product instance IDs add the product specification.
Row IDs add the declared row key. Length-prefixed semantic components avoid
delimiter ambiguity.

Generation time, storage adapter, connection/path, file name, serialization,
Git revision, and content hash are excluded from logical identity. Rebuilding
the same semantic set later retains its IDs while recording a later
`product_generated_at`. Integrity hashes may be added by a future physical
adapter without becoming product meaning.

## Freshness and coherence

Three times/identities remain distinct:

- `source_cutoff_time` is the explicit upper bound used for current selection;
- `source_as_of_time` is the greatest represented valid operational-run
  information cutoff; and
- `product_generated_at` is when the in-memory product object was built.

`latest_source_runtime_run_id` identifies the unique represented run selected
by greatest as-of and then greatest terminal status time. A remaining tie is
ambiguous and fails. Source as-of cannot exceed the selected cutoff or product
generation time.

All core products must share the product-set ID, exact member versions, cutoff,
source as-of, source run list, latest represented run, and generation time.
Mixed sets fail conformance.

## Compatibility

The initial set explicitly supports these pre-1.0 minor lines:

- operational run `platform.operational-run-status@0.1.x`;
- state `platform.readmission-episode-state@0.1.x`;
- request `platform.readmission-estimand-request@0.1.x`;
- execution result `platform.provider-execution-result@0.2.x`;
- estimate `platform.readmission-risk-estimate@0.1.x`; and
- estimand `platform.readmission-next-day-conditional-hazard@0.1.x`.

Exposed provider and optional model references require explicit stable IDs and
versions, but the suite does not privilege one provider. A new provider is a
row-level transition, not a product-version change. A new estimand may coexist
only when the declared supported line covers it; changed quantity semantics
require explicit product support.

Changing DuckDB tables, its payload encoding, or replacing DuckDB with another
conforming adapter does not change a product contract when logical records are
unchanged. Any upstream identity/type/time/key/requiredness change outside the
declared range fails compatibility until the product contract and builder are
deliberately advanced.

## Availability, empty results, and failure

The shared foundation vocabulary applies:

- `available` means a supported product built and conformed; it may have zero
  rows;
- `unavailable` means the supported product cannot be supplied in the active
  context;
- `unsupported` means the suite/version does not implement it; and
- `failed_conformance` means supplied output violated its contract.

The initial three products are all required core members. A source read,
availability, compatibility, builder, product-conformance, or set-coherence
failure returns a structured failed build with a failure stage and no
consumable product collection. There is no partial-success core set. A
completed-with-failures run with no accepted estimates succeeds with available
zero-row current/history products and one run-summary row; failure is never
represented as an empty table.

## Builder and conformance boundaries

Generic code under `products/R/` uses base R and only the exported logical
`rrpruntime` read methods. It contains no DuckDB, DBI, SQL, source
implementation, mapping, provider callable, Shiny, or repository-path
discovery. A normalized-history entry point permits the same semantics to be
tested independently of any adapter.

Conformance is independent of builder ownership and collects multiple issues.
It validates metadata identity/version, required row fields and types,
controlled values, declared grain/key uniqueness, deterministic row identity
and order, upstream state/estimate/run references, valid-only status,
freshness, source scope, exact members, and set coherence.

## Logical access boundary

`new_logical_product_access()` supplies the first in-memory realization of the
future application seam:

```text
list_products()
read_product(product_id, product_version, product_set_id)
read_product_metadata(product_id, product_version, product_set_id)
```

It accepts only a successful complete product build, returns copies, and
requires exact product/set identity. It is not a physical product adapter. The
supplied app depends on this logical shape through a conforming replacement, not
on builders, persistence ports, DuckDB, source data, or providers.

## Migration and retention implications

- A product specification or supported upstream semantic change creates a new
  version and a new attributable build; existing product objects are never
  silently rewritten.
- A physical schema migration that preserves logical history has no product
  semantic effect.
- Provider transitions remain rows under their original identities.
- Estimand transitions remain explicit and require declared compatibility.
- Operational-history retention is operator/persistence policy. Product
  materializations are rebuildable and may be retained for less time.
- Deleting a product materialization must never delete operational history.
- Rebuilding from retained compatible history is projection, not provider
  replay. If required compatible history has been removed, the product is
  unavailable or the build fails; it is not reconstructed from current code.

The YAML reference implements safe replacement and retains prior immutable
bundles, but no production retention duration, cleanup automation, or history
migration is implied.

## Reference evidence classification

The clean suite, identity, freshness, builder, and access design preceded the
required read-only sibling review. The review retained coherent-set identity,
explicit generation-input attribution, row-count/order checks, validation
before consumption, and a storage-neutral access concept as principles.

The old fixed eight-product manifest, tracked CSVs, Git/checksum identity,
hard-coded paths, reconstructed weekly trajectories, synthetic metadata,
priority/queue fields, executive/measure/geography products, and app-specific
field assumptions were rejected or deferred. No sibling code, specification,
identifier, data, or configuration was copied.

## Realized downstream boundary

Iteration 6.2 adds a YAML bundle adapter and minimal Shiny consumer without
changing these contracts or builders. Decision products and broader history
migration/retention work require separate evidence and approval.
