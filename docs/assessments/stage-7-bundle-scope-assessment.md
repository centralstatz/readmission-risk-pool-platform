# Stage 7 Bundle-Scope Assessment

**Status:** Assessment only; not an accepted architecture or implementation
decision.

**Authority:** Platform True North, Platform Architecture, and the accepted
Platform Implementation Plan remain authoritative unless and until they are
separately revised and accepted.

This document evaluates a possible revision before Stage 7 implementation. It
does not change the accepted Stage 7 plan, reopen accepted Stage 6 behavior, or
authorize implementation.

## 1. Executive conclusion

**Recommendation: yes, with a narrow qualification.** Stage 7 should own a
bundle-scoped durable operation once a producer result has passed canonical
admission. That operation should account for every admitted discharge episode,
while the analytical unit, provider invocation, and atomic persistence boundary
remain one episode. An interrupted invocation may temporarily be incomplete;
the durable guarantee is that omission is visible and deterministic resumption
can finish the admitted scope, not that one process can guarantee uninterrupted
completion.

The smallest coherent design is an immutable operational-scope record plus one
terminal disposition record per admitted episode and the already planned
history-action record. The scope records the expected cardinality and a
deterministic, versioned fingerprint of episode membership. Completeness is
derived by comparing that evidence with the episode dispositions; it does not
require storing the canonical bundle, adding a completion record family, or
using one transaction for all episodes.

This interpretation better matches the architecture's full invocation flow,
append-oriented attributable history, and prohibition on hidden partial
history. It also removes a future ambiguity that no later product, CLI, or
scheduler can repair reliably: whether an admitted episode is absent because
it was intentionally out of scope, accidentally skipped, or never attempted.

## 2. Question being assessed

The decision is whether the durable Stage 7 operation should cover one selected
episode or all discharge episodes in one successfully admitted canonical
bundle at authoritative analytical time `t`.

The relevant boundaries are distinct:

- **Operational scope:** one admitted bundle produced for an explicit project
  invocation at `t`.
- **Analytical unit:** one episode, one governed target, and `t`.
- **Provider execution:** at most one call to the selected provider for one
  eligible episode evaluation.
- **Persistence atomicity:** one terminal episode disposition per transaction.

Bundle scope therefore does not imply vectorized inference, parallelism, one
large transaction, or a batch-processing framework. It determines which
episodes RRP is accountable for; it does not change the unit in which risk is
defined or calculated.

## 3. Current-system evidence

### Platform True North

`docs/platform-true-north.md` defines operational history as part of the
product, places it after canonical mapping and governed runtime/provider
execution in the reference flow, and requires RRP to preserve what it actually
knew and produced at the declared as-of time. It also requires retries,
duplicates, and corrections to be explicit rather than silently rewriting
prior truth. Those principles favor an accountable boundary around the
population admitted during an invocation.

### Platform Architecture

`docs/platform-architecture.md` describes each explicit project/as-of
invocation as loading the project, invoking the selected producer and provider,
admitting canonical data, evaluating eligibility and state, constructing a
request, validating the provider result, and appending attributable terminal
history. It rejects hidden fallback and partial history, distinguishes the
operation run from analytical and provider execution identities, and makes raw
and current history distinct. This describes a higher invocation scope without
making the analytical question anything other than episode-scoped.

The architecture also assigns storage-neutral computation and history meaning
to `rrpruntime`, while `rrpplatform` owns project orchestration, project state,
and concrete storage adapters. Bundle accountability can respect that split.

### Accepted implementation plan

The accepted Stage 7 section of `docs/platform-implementation-plan.md`
currently defines one known episode, admitted bundle, target, and `t` as one
analytical run. It then defines a terminal batch as one terminal run header and
one episode execution, makes the durable operation select one episode, and
defers bulk selection and iteration. Increments 7.A–7.D consequently prove an
in-memory logical model, a DuckDB adapter, one-episode durable orchestration,
and recovery around that scope.

The same plan describes a complete project operational-history capability, not
merely a hypothetical persistence primitive. That intended exit state creates
tension with leaving admitted-episode selection to an unspecified later layer.

### Realized Stage 5

Stage 5 admits a canonical bundle containing zero or more discharge episodes.
`packages/rrpplatform/R/producer-execution.R` invokes the selected producer and
hands its returned bundle to canonical admission. The bundle is already the
trusted boundary after which RRP can know the complete admitted membership for
that invocation.

### Realized Stage 6

`packages/rrpplatform/R/risk-execution.R` exposes the accepted one-episode risk
operation: admitted bundle plus `episode_id`, target, and `t`. The episode-state
implementation in `packages/rrpruntime/R/episode-state.R` and the focused tests
in `packages/rrpplatform/tests/risk-execution.R`,
`packages/rrpruntime/tests/episode-state.R`, and
`packages/rrpruntime/tests/risk-provider.R` confirm that eligibility, governed
request construction, provider execution, and accepted estimate/failure
behavior are episode-scoped. Stage 6 deliberately has no durable state or
history side effect.

These are suitable composable semantics. They do not establish that a future
durable caller should require a human or external system to enumerate episode
IDs.

### Current Stage 7 assumption

The current Stage 7 plan carries the Stage 6 call shape into the durable public
operation and aligns a terminal history batch with that single call. No current
code or test requires this to be the final operational cardinality. Stage 7
implementation has not begun, so changing the plan before implementation would
not require compatibility behavior or data migration.

## 4. Why Stage 7 currently says "one episode"

The evidence supports a combination of causes rather than a separate
architectural requirement:

1. Stage 6 intentionally proved the hardest semantic primitive one episode at
   a time. Stage 7 reused that already accepted boundary.
2. One episode makes atomic append, idempotency, failure handling, and the
   initial in-memory/DuckDB equivalence proof smaller.
3. The clean-forward method favors the smallest progressive increment, and the
   plan explicitly deferred selection and iteration.
4. The current three-record-family design was simplified around one terminal
   analytical result rather than recovered wholesale from v0.1.0.

It was not inherited from historical execution: v0.1.0 iterated over all
admitted episodes. Nor do True North or Platform Architecture state that an
external caller should choose an arbitrary subset of admitted episodes. The
one-episode durable scope is therefore best understood as a progressive
implementation simplification carried forward from Stage 6, reinforced by
transaction and retry simplicity—not as a governing product invariant.

## 5. Alternative operational model

The proposed model is:

1. One **producer invocation** obtains hospital-owned source data for a project
   and authoritative `t`.
2. Successful canonical admission returns one **admitted bundle**, whose
   discharge-episode membership is closed for this invocation.
3. RRP creates or matches one immutable **operational scope** for that admitted
   bundle and intended risk operation.
4. RRP walks the admitted episode IDs in a deterministic order. For each ID it
   performs one **analytical run**: episode + target + `t`.
5. The analytical run has one terminal **episode execution/disposition**.
6. An eligible analytical run performs at most one **provider execution**. An
   ineligible run performs none.
7. Each terminal episode disposition is appended in its own **history
   transaction**.

The operation-run identity becomes bundle-scoped. Analytical-run, episode
execution, state, request, and provider-execution identities remain
episode-scoped. A producer invocation need not become a separate history family
if its identity and governed provenance are captured in the operational scope.
Likewise, transaction identity is an adapter concern unless it has independent
domain meaning.

For a zero-episode admitted bundle, the operational scope is complete as soon
as its scope record is durably present: expected and dispositioned cardinality
are both zero.

## 6. Completeness and accountability

"All admitted episodes accounted for" means that every discharge episode in
the successfully admitted bundle has exactly one terminal disposition for the
initial analytical attempt in that operational scope. It does not mean every
episode has a risk estimate.

Episode history should represent:

- target ineligibility, without a provider call;
- eligible execution with an accepted estimate;
- provider incompatibility detected for that episode;
- a provider-declared failure;
- a bounded provider execution error;
- an invalid provider result or estimate; and
- any other governed terminal Stage 6 outcome that occurs after the episode is
  selected from an admitted bundle.

The minimum durable scope evidence is:

- the bundle-scoped operation-run identity and caller operation key;
- project, profile, producer/mapping, bundle, target, and `t` provenance needed
  to prevent a different invocation from matching the scope;
- expected discharge-episode count `N`;
- a versioned deterministic membership fingerprint computed from the sorted,
  uniquely admitted episode IDs; and
- one unique disposition keyed to each episode-scoped analytical identity.

Completeness can then be derived only when:

1. the number of distinct terminal disposition episode IDs is `N`;
2. the same versioned fingerprint computed over those IDs equals the scope
   fingerprint; and
3. every disposition has matching immutable operation provenance.

The fingerprint proves equality with the declared scope for integrity and
restart purposes; it is not an authentication mechanism. The version and
canonical encoding used to compute it must be governed. Count alone is
insufficient because a duplicate or substituted episode could still total
`N`. Persisting the complete canonical bundle is unnecessary.

Absence from raw history then has only two interpretations: the episode was not
in the admitted scope, or the visible operational scope is incomplete and the
episode has not yet received a disposition. Ineligibility and bounded failure
are explicit records, not absence.

Failures before a bundle is successfully admitted—invalid project input,
producer failure, and canonical admission failure—remain nonhistorical
operation failures because no trusted admitted population exists to enumerate.
They should return the established privacy-safe operation result. An impossible
post-admission membership/invariant defect should fail closed and leave the
scope visibly incomplete rather than inventing an episode disposition.

## 7. Processing and transaction semantics

Initial processing should be sequential and deterministic. For each admitted
episode, RRP reuses the accepted Stage 6 semantics and appends that episode's
terminal disposition atomically. A database failure rolls back only that
episode append.

An all-or-none `N`-episode transaction is not recommended. It would keep a
potentially long provider loop inside a database transaction, discard hundreds
of valid completed evaluations after a late failure, make restart expensive,
and couple external execution latency to storage locking. It would also repeat
the most burdensome historical v0.1.0 mechanism without being required for
analytical correctness.

Independent atomic episode commits plus explicit scope completeness provide
the desired semantics: raw history faithfully shows partial progress, while
current/effective history can exclude incomplete scopes until their membership
is fully dispositioned. This is a logical completeness barrier rather than one
large physical transaction.

## 8. Interruption and restart

If a 500-episode operation terminates after episode 347 commits, raw history
should show:

- one immutable operational scope with expected count 500 and its membership
  fingerprint;
- 347 terminal episode dispositions; and
- derived state `incomplete`, with 153 dispositions outstanding.

The scope need not persist an explicit list of the missing IDs. The admitted
bundle is reproducible only if the same producer operation at the exact
authoritative `t` returns the same admitted identity and membership evidence.
On reinvocation with the same caller operation key, RRP should:

1. invoke the producer and canonical admission again at the exact same `t`;
2. require the immutable scope provenance, expected count, and membership
   fingerprint to match;
3. deterministically re-walk all admitted episode IDs;
4. skip an episode whose derived analytical identity already has a matching
   terminal disposition; and
5. process and atomically append only missing dispositions.

A mismatch is an idempotency conflict, not a new interpretation of the old
operation. No provider is recalled for an already committed episode. A
producer/admission failure during resumption leaves the existing scope
incomplete and returns a nonhistorical operation failure.

This is deterministic continuation, not a queue. RRP does not promise that a
crashed operation completes without being invoked again; it promises that
partial work is attributable, detectable, and safely resumable without silent
omission.

## 9. Identity and idempotency

The minimum identity model is:

- **Operation-run identity:** bundle-scoped, derived or supplied under the
  governed caller operation key and immutable scope provenance.
- **Analytical-run identity:** episode-scoped and deterministically related to
  operation run + episode ID + target + `t`.
- **Episode execution:** the terminal record for that analytical run; it does
  not need another independent public operation identity.
- **Provider-execution identity:** episode-scoped and present only when the
  provider is called; one analytical attempt cannot conceal multiple calls.
- **State/request identities:** retain the accepted Stage 6 meanings and their
  relationship to the analytical run.
- **History-action identity:** independent append-only identity for a later
  correction action.

No additional batch ID, episode operation ID, attempt counter, persisted loop
sequence, or storage-generated domain identity is justified. Deterministic
episode processing order may aid reproducibility but is not historical
identity. Physical transaction IDs remain private to an adapter.

The operation key protects reinvocation of the whole admitted scope. The
derived analytical identity protects the one initial disposition per episode.
Their different cardinalities should remain explicit.

## 10. Retry

Bundle continuation and provider retry are different operations:

- **Continuation/resumption** uses the same operation key and scope identity.
  It skips committed analytical runs and fills only missing dispositions. It
  does not create another provider attempt for a committed episode, whether
  that disposition was success or failure.
- **Provider retry** is an explicit new episode-scoped analytical attempt
  related to a prior failed attempt. It receives a new analytical and provider
  execution identity, preserves the prior disposition, and never occurs
  implicitly inside the initial operation.

The minimum Stage 7 model needs deterministic continuation and the logical
ability to represent a later explicit retry. It need not add automated retry
policy, backoff, attempt counters, fallback providers, or a bulk retry command.

## 11. Correction semantics

Append-only invalidation and restatement should normally target one
episode-scoped analytical result. A corrected analytical fact is a new run or
action; the old record remains raw historical truth.

An entire operational scope should be targetable only when the defect concerns
shared scope provenance or admission—for example, the wrong admitted bundle or
authoritative time—not merely because one episode estimate was wrong. A scope
action can make all of its episode dispositions ineffective without deleting
them. A subsequent corrected operation creates a new scope and new analytical
runs.

The planned history-action family can support both narrow target kinds. Bundle
scope does not justify a new correction family or coarse cascading as the
default.

## 12. Logical history model

The three planned record families remain sufficient, but the first requires a
clearer meaning:

1. **Operational scope** (currently called the terminal run header): immutable,
   bundle-scoped provenance, operation key, expected cardinality, and versioned
   membership fingerprint.
2. **Episode execution/disposition:** one episode-scoped terminal analytical
   record containing eligibility/outcome, governed evidence, provider
   attribution where applicable, and accepted estimate where successful.
3. **History action:** append-only invalidation/restatement relationship
   targeting an episode result or, narrowly, an operational scope.

The current "terminal run header" is effectively episode-adjacent because the
current terminal batch contains exactly one episode. Under bundle scope it
should be renamed or redefined as an operational-scope record. It is not itself
terminal while episodes remain outstanding.

No completion record family is needed. `complete` is a derived assertion from
immutable scope evidence and terminal episode dispositions. An implementation
may calculate and expose progress, but a mutable status flag must not be the
sole proof of completeness.

Raw history exposes scope and all committed dispositions, including incomplete
progress. Current/effective history remains keyed by episode + target + `t`,
but should admit records from a bundle-scoped operation only after the scope is
complete and not invalidated. Thus bundle membership gates population
completeness without redefining the analytical question.

## 13. Storage-neutral port and DuckDB

At the storage-neutral level, `rrpruntime` needs only operations capable of:

- validating and appending an immutable operational scope;
- validating and atomically appending one episode disposition against that
  scope;
- reading raw scope progress and deriving completeness; and
- resolving effective/current episode history with the completeness and
  history-action rules applied.

The in-memory adapter can prove the same contract before persistence. These
operations must use domain records and result objects, with no DuckDB, SQL,
connections, table names, paths, or schema vocabulary.

The `rrpplatform` DuckDB adapter needs storage for the additional scope
metadata and a relationship from each episode disposition to its scope. Each
episode append is one transaction that atomically writes the complete terminal
episode record. Creating/matching the scope is a separate short transaction.
The physical table arrangement is private and need not mirror the three
logical families one-for-one.

Bundle scope therefore changes logical cardinality and adds completeness
metadata; it does not require materially different database technology or an
all-episode transaction.

## 14. Privacy and persisted content

Completeness should not be proved by retaining the source data, canonical
bundle, encounter rows, terminal-event rows, hospital vocabulary, arbitrary
patient attributes, model content, credentials, connection information, or
source-system configuration.

The scope should retain only governed provenance, `N`, and the versioned
membership fingerprint. Episode disposition records may retain the already
planned minimum project-owned `episode_id` and `patient_id` attribution needed
for later operational products, plus governed state/request/outcome/estimate
evidence. They should not copy source rows.

A membership fingerprint does reveal stable equality relationships and should
be treated as project-owned operational metadata, but it is preferable to a
second persisted episode manifest. If the disposition records already contain
episode IDs, completeness can recompute the fingerprint from them without
duplicating those identifiers in the scope record.

## 15. Stage 6 impact

Accepted Stage 6 remains correct and should not change. Its one-episode
operation is exactly the analytical primitive Stage 7 should compose for each
admitted episode. Its single-provider-call rule, failure taxonomy, governed
state/request/estimate evidence, and no-persistence boundary remain intact.

Stage 7 orchestration may call internal Stage 6-owned semantics repeatedly; it
does not need vectorization or a change to the accepted one-episode API merely
to own the enclosing admitted population.

## 16. Stage 7 increment impact

The accepted four-increment sequence can remain. If this recommendation is
adopted later, the minimum revisions are:

- **7.A — logical contracts, port, and in-memory proof:** redefine the run
  header as bundle-scoped operational scope; add expected count, versioned
  membership fingerprint, scope-to-episode relationships, derived completeness,
  and the incomplete-scope current-history gate. Preserve episode-level
  terminal semantics and three record families.
- **7.B — explicit project state and DuckDB adapter:** persist the scope, allow
  independent atomic episode commits, and prove raw progress, completeness,
  idempotency conflicts, reopen, and in-memory/DuckDB equivalence. No queue or
  large transaction is added.
- **7.C — durable execution and history interpretation:** replace the public
  one-selected-episode durable operation with bundle-scoped sequential
  orchestration over all admitted episode IDs. Add interruption/resume and
  skip-already-committed behavior while composing unchanged Stage 6 semantics.
- **7.D — backup, recovery, and installed proof:** include a partially processed
  scope in backup/reopen/recovery evidence and prove that deterministic resume
  reaches the same complete history as uninterrupted processing.

No increment needs to be added, removed, or reordered. The package ownership
split and installed proof remain unchanged.

## 17. Downstream implications

### Stage 8

A fictional reference hospital can run one natural governed operation after
its selected producer admits a bundle, rather than supplying an episode loop
outside RRP. This reinforces the forward authoring preference already recorded
for Stage 8: hospital-owned code supplies data mapping and model/engine logic,
while RRP owns protocol, registration, canonical handoff, and governed
execution. The raw producer and provider contracts remain flexible lower-level
extensions. This assessment does not choose the future convenience interface.

### Stage 9

Products can distinguish an ineligible episode, an episode with a bounded
failure, and an operational scope that has not finished. Complete-scope gating
makes current risk-pool and executive metrics reproducible and prevents a
partial run from silently looking like a smaller eligible population. It also
provides direct provenance for explaining why an admitted episode is absent
from the active risk pool.

### CLI, scheduling, and application layers

"Process every episode admitted in this governed invocation" is core platform
meaning and belongs in Stage 7. "Decide when the hospital should invoke RRP" is
a later CLI, scheduler, deployment, or application concern. Those layers should
invoke the platform operation rather than reimplement its population loop.

### Future performance

Because the scope and episode transaction boundaries are explicit, a later
implementation may vectorize, partition, or parallelize episode work while
preserving the same identities and completeness proof. Stage 7 should not
implement those optimizations or production multiwriter coordination.

## 18. Historical v0.1.0 evidence

Immutable `v0.1.0` history confirms that the prior reference operation was
bundle-scoped in execution:

- `operations/lib/runtime-operation.R` evaluated eligibility across all
  `input$discharge_episodes` and created states/requests for the eligible
  subset.
- `runtime/R/eligibility.R` produced eligibility results by iterating all
  admitted discharge episodes.
- `operations/lib/provider-operation.R` invoked the provider for each eligible
  request.
- `operations/lib/reference-history-operation.R` used one bundle-level runtime
  run, performed producer/runtime/provider work for the population, and then
  appended one completed batch.

Classification of that evidence:

- **Reusable substantially as-is:** none of the old source layout or public
  operations; the clean 1.0 ownership and contracts differ.
- **Conceptually reusable but simplify:** invoke the producer once, enumerate
  the admitted population, evaluate eligibility per episode, call a provider
  only for eligible requests, retain bundle/run provenance, and use explicit
  idempotency and raw/current interpretation.
- **Reject as obsolete:** the giant transaction covering all episode results,
  started/failed lifecycle machinery, historical record-family proliferation,
  repository-root/generated-operation assumptions, daily-hazard semantics,
  hidden or multi-attempt provider behavior, and any dependence on historical
  physical schemas.
- **Defer:** performance optimizations, concurrency, scheduling, product
  materialization, and automated retry.

The old implementation also exposes a defect to avoid: detailed history did
not preserve an explicit terminal disposition for every ineligible admitted
episode, so summary counts could not by themselves provide full episode-level
accountability. Historical interruption behavior depended on the giant final
append and did not offer the recommended durable partial-progress resume model.

Nothing in v0.1.0 is evidence that the current one-episode durable Stage 7
scope is preferable. It is evidence for full-population orchestration, while
also showing why that concept should be realized with smaller transactions and
stronger completeness evidence in 1.0.

## 19. Complexity introduced

Necessary new complexity is limited to:

1. a bundle-scoped operation identity and immutable scope provenance;
2. a governed canonical encoding and versioned fingerprint for admitted
   episode membership;
3. expected cardinality and derived progress/completeness rules;
4. an operation-scope relationship on each episode disposition;
5. deterministic enumeration and resume/skip behavior;
6. idempotency conflict detection when a reinvocation does not reproduce the
   same admitted scope;
7. current/effective-history gating for incomplete scopes; and
8. narrowly scoped correction rules for a defective operation scope.

This is more complex than persisting one independently selected episode, but
the complexity represents product truth that otherwise moves, undocumented,
into every caller and later product. It is materially smaller than a job
system: there are no task leases, mutable queues, workers, schedules,
heartbeats, checkpoints per loop position, dependency graphs, or concurrency
protocols.

Optional and presently unjustified complexity includes storing a full episode
manifest, a mutable completion event as a fourth family, persisted sequence
numbers, automated retries, chunking, parallel workers, and multiwriter
coordination.

## 20. Recommendation and proposed plan revisions

**Direct answer to the architectural test:** yes. If a hospital producer
successfully admits `N` discharge episodes at `t`, the Stage 7 durable operation
should own propagation of all `N` through the governed episode-risk path and
leave enough durable evidence to account for all `N`. It should guarantee an
attempt under uninterrupted execution and deterministic, visible continuation
after interruption—not claim that an external process can never terminate.

If the recommendation is accepted in a separate planning action, revise only
the Stage 7 concepts that currently:

- define the durable invocation and operation-run as one selected episode;
- define the terminal run header/batch as one header plus one episode;
- defer admitted-episode selection and iteration outside Stage 7;
- describe idempotency and interruption solely for an episode operation;
- allow current history without a complete admitted scope; and
- state the 7.C and Stage 7 exit condition in one-episode terms.

Add the minimum semantics described here: an immutable bundle-scoped
operational record, count plus versioned membership fingerprint, deterministic
episode analytical identities, independent terminal episode commits, derived
completeness, deterministic resume, and incomplete-scope gating.

Do **not** change True North, reopen Stage 6, change the canonical bundle or
provider contracts, add record families, alter package ownership, require a
large transaction, or broaden Stage 7 into scheduling or products. The four
increment boundaries can remain with the focused adjustments in section 16.

The resulting Stage 7 plain-language exit should be:

> A hospital project can produce and admit zero or more discharge episodes at
> an authoritative time. RRP owns the admitted scope, processes every admitted
> episode through the governed risk path sequentially if necessary, and
> atomically records either its accepted estimate or governed terminal
> disposition. After interruption or reopening, the project can determine
> whether that scope is complete, safely resume missing work, and account for
> what happened to the admitted population.

## 21. Deliberate deferrals

This recommendation does not include:

- vectorized or batch provider inference;
- parallel episode processing or production concurrency;
- a scheduler, queue, worker, lease, or workflow engine;
- automated or implicit provider retry/fallback;
- performance tuning, partitioning, or chunking;
- cohort selection outside the admitted bundle;
- product or materialized-view construction;
- retrospective rescoring or changed-model migration;
- CLI or application design;
- the Stage 8 hospital authoring interface;
- Stage 9 product semantics beyond the noted consequences;
- a full canonical-bundle snapshot or source-data archive; or
- general deployment, release, or backup policy beyond planned Stage 7 proof.

## 22. Final decision table

| Question | Current Stage 7 | Proposed alternative | Recommendation | Reason |
|---|---|---|---|---|
| Durable operational scope | One selected episode | One admitted canonical bundle at `t` | Bundle-scoped | Prevent silent omission and place population accountability inside RRP |
| Analytical unit | Episode + target + `t` | Unchanged | Keep episode-scoped | Risk meaning and current-history key are episode-specific |
| Producer invocation | Available bundle supplied to episode operation | Once per initial operation or deterministic resume | Bundle-scoped provenance | Admission establishes the trusted membership boundary |
| Provider execution | At most one call for selected episode | At most one call per eligible episode analytical attempt | Keep episode-scoped | Preserves Stage 6 transparency and failure semantics |
| Processing | One caller-selected episode | Deterministic sequential walk of all admitted episodes | Sequential initially | Simplest complete behavior; optimization is unnecessary |
| Transaction | One episode terminal batch | One atomic terminal disposition per episode | Keep episode atomicity | Supports bounded rollback and restart without a long transaction |
| Scope evidence | Episode-oriented run header | Immutable operation scope with `N` and membership fingerprint | Redefine first family | Minimum proof of the admitted population without storing the bundle |
| Completion | One episode implies terminal run | Derived `N`/fingerprint equality across dispositions | Derive, do not add a family | Proves no omission without mutable completion truth |
| Interruption | Caller retries one episode operation | Incomplete scope remains raw; reinvocation re-walks and fills missing records | Add deterministic resume | Makes partial progress visible and avoids repeated provider calls |
| Operation-run identity | Episode-adjacent | Bundle-scoped | Change cardinality | One operation key identifies one admitted scope |
| Analytical-run identity | Episode-scoped | Episode-scoped within operation scope | Keep | No need for an extra episode operation ID |
| Retry | Explicit episode retry principles | Bundle continuation separate from explicit provider retry | Distinguish | Resumption must not conceal a second provider call |
| Correction | Episode analytical action | Episode action normally; scope action for shared provenance defects | Support both narrowly | Bundle operation must not force coarse correction |
| Raw history | Terminal episode batches | Scope plus all committed episode dispositions, including partial progress | Expand interpretation | Raw truth should show interruption |
| Current history | Episode + target + `t` | Same key, gated by completed valid scope | Retain key; add gate | Bundle membership is provenance, not analytical meaning |
| Record families | Run header, episode execution, history action | Operational scope, episode disposition, history action | Keep three | Completeness is derived; a fourth family is unnecessary |
| `rrpruntime` port | One-episode terminal append and interpretation | Scope append, episode append, progress/completeness, gated current resolution | Extend logically | Keeps history meaning storage-neutral |
| DuckDB | One-episode durable batch | Scope metadata plus independently committed episode records | Adapt privately | Only modest metadata and relationship changes are needed |
| Project state | Episode history | Incomplete or complete operational scopes plus episode history | Treat partial scope as durable state | Required for reopen, inspection, and resume |
| Privacy | Minimal episode/history evidence | Add count and fingerprint, not bundle or source data | Minimize persisted scope | Accountability does not justify copying canonical/source records |
| Stage 6 | Accepted one-episode primitive | Repeated unchanged by Stage 7 | No change | It is the correct analytical building block |
| Stage 7 increments | 7.C proves durable one-episode operation | 7.C orchestrates admitted scope; other increments add minimal scope proof | Adjust, do not restructure | Existing ownership and progression remain sound |
| Stage 8+ | Later layer must enumerate episodes | Later layers invoke one accountable platform operation | Prefer bundle scope in core | CLI/schedulers decide when to run, not which admitted episodes count |
