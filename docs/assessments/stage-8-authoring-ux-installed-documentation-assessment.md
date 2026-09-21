# Stage 8 Authoring UX and Installed Product Documentation Assessment

**Status:** Assessment only; not an accepted architecture, implementation-plan
revision, or implementation decision.

**Authority:** Platform True North, Platform Architecture, and the accepted
Platform Implementation Plan remain authoritative unless and until they are
separately revised and accepted.

This document evaluates bounded questions that arose before Stage 8
implementation. It does not authorize Stage 8, change any existing contract,
or alter the current Stage 8 plan.

## 1. Executive conclusion

No Stage 5, Stage 6, or Stage 7 contract deficiency was found. The current
provider request is sufficient for the planned normal provider callable. The
missing capability is discoverability: an ordinary hospital author cannot yet
learn the request's exact R structure, field meanings, output alternative, and
responsibility boundary from an initialized project and installed product
documentation.

The current canonical identity boundary is also sufficient. A provider gets
the canonical `episode_id` and authoritative analytical time. Its separately
supplied `project_root` can support hospital-owned resolution from that
canonical identity to source- or model-specific data. RRP should not persist a
source-ID crosswalk, add arbitrary predictors to the canonical bundle, or
become a feature store. RRP governs the analytical question and cutoff; the
hospital provider remains responsible for ensuring that its model-specific
inputs are legitimate for that cutoff.

The fictional project should make this boundary visible rather than using an
identity transformation that a reader might mistake for the platform design.
Its source should contain native keys that are deliberately invalid as RRP
canonical identities, an explicit project-owned crosswalk, and one small
source-only predictor with an availability time. The producer should use the
crosswalk to create canonical identities and discard the predictor from the
canonical domains. The provider should resolve the request's canonical
`episode_id` through the same hospital-owned crosswalk and retrieve the
predictor. RRP should never inspect or persist that crosswalk.

Stage 8 should also establish the first version-matched installed product
documentation. The existing catalog already recognizes a `documentation`
resource class and exposes resources through `rrpplatform`; its controlled
formats currently allow only `dcf` and `r`, so admitting Markdown requires a
narrow catalog-schema and validator update during Stage 8. The smallest useful
set is a project-authoring guide, an exact provider-request reference, and a
fictional-reference walkthrough. Project-local comments and `README.md` should
orient and link to those resources; the fictional project should be their
executable companion.

These additions fit the existing three increments. No Increment 8.D or
architecture redesign is warranted:

- **8.A** should own the installed authoring documentation, exact scaffold
  comments, and documentation-resource admission alongside the standard
  authoring boundary.
- **8.B** should own the explicit fictional crosswalk and bounded
  provider-only predictor proof.
- **8.C** should prove that all three teaching surfaces work from installed
  RRP outside the development repository.

## 2. Current implementation facts

### 2.1 Current provider request

The Stage 6 provider request is not an informal list. It is a detached S3
object with exact class:

```r
c("rrp_risk_request", "list")
```

It is one flat named list with exactly these 19 fields in this order:

| Field | R value | Meaning |
|---|---|---|
| `request_contract_id` | scalar character | Exact request contract; currently `rrp.risk-request`. |
| `request_contract_version` | scalar character | Exact request-contract version; currently `0.1.0`. |
| `request_id` | scalar character | Deterministic request identity with `rrp.request.` prefix. |
| `target_id` | scalar character | Singular remaining-readmission-risk target identity. |
| `target_version` | scalar character | Exact target version. |
| `state_contract_id` | scalar character | Episode-state contract identity. |
| `state_contract_version` | scalar character | Exact state-contract version. |
| `state_id` | scalar character | Deterministic identity of the eligible immutable episode state. |
| `bundle_instance_id` | scalar character | Identity of the admitted canonical bundle supplying the state. |
| `project_id` | scalar character | Selected independent project's identity. |
| `project_version` | scalar character | Selected independent project's version. |
| `episode_id` | scalar character | Canonical episode identity selected from the admitted bundle. |
| `as_of_time` | scalar character | Authoritative analytical cutoff `t`, normalized to RFC 3339 UTC. |
| `discharge_time` | scalar character | Canonical discharge instant, normalized to RFC 3339 UTC. |
| `target_interval_start` | scalar character | Start of the requested interval; exactly `as_of_time`. |
| `target_interval_end` | scalar character | Fixed day-30 endpoint, normalized to RFC 3339 UTC. |
| `target_interval_boundary` | scalar character | Exact boundary `(start,end]`. |
| `elapsed_seconds_since_discharge` | scalar unclassed double | Elapsed seconds from discharge through `t`. |
| `remaining_seconds_through_w30` | scalar unclassed double | Remaining seconds from `t` through the day-30 endpoint. |

The request has no nested records. String values are plain scalars; the two
duration values are finite base-R doubles. Unknown fields and reference-bearing
values are prohibited. RRP constructs `request_id` using the versioned
`dual_modular_hash_v1` algorithm over every other request field. A detached
copy is supplied to the provider exactly once after compatibility succeeds.

The request is constructed only for an eligible episode. Consequently,
`discharge_time <= as_of_time < target_interval_end`, the two elapsed values
are nonnegative/positive as appropriate, and together describe the fixed
2,592,000-second target horizon. Eligibility has already excluded a canonical
readmission or competing death available through `t`.

For a normal hospital model author, the most directly useful values are:

- `episode_id`, to resolve project-owned model inputs;
- `as_of_time`, to enforce the model-input availability cutoff;
- `discharge_time`, the interval bounds, and the elapsed/remaining seconds,
  to construct target-compatible model inputs; and
- target, project, bundle, state, and request identities when the hospital's
  model adapter needs exact compatibility or provenance checks.

Several values that an author might initially expect are deliberately absent:

- canonical `patient_id` and `index_encounter_id`;
- admission time, terminal-event rows, and the canonical bundle/domains;
- source-native identifiers or a source-to-canonical crosswalk;
- diagnoses, labs, medications, utilization, external scores, arbitrary
  features, or model configuration;
- project paths, credentials, connections, callbacks, or callables;
- provider/model identity, because the request is provider-neutral; and
- prior estimates, decisions, products, or operational-history records.

The proposed Stage 8 normal callable receives `project_root` separately. That
does not widen the raw request: the standard adapter can capture the explicit
root while presenting the unchanged one-argument callable to Stage 6.

### 2.2 Current provider result boundary

The existing raw provider returns exactly four fields:

```r
list(
  request_id = request$request_id,
  status = "success" | "failure",
  estimate_value = <unclassed double in [0, 1]> | NULL,
  failure_code = NULL | <one admitted provider failure code>
)
```

Stage 6 validates request identity, status-dependent presence, probability
type/cardinality/bounds, and controlled failure codes before constructing the
accepted estimate with provider and optional model attribution. The accepted
Stage 8 standard-authoring plan removes this envelope ceremony from ordinary
hospital code: `rrp_calculate_risk(project_root, request)` returns either one
finite unclassed base-R double probability in `[0,1]` or the planned
authoring-failure value. RRP builds the raw result envelope.

### 2.3 Canonical identity behavior

The admitted `discharge_episode` domain contains `episode_id`, `patient_id`,
and `index_encounter_id`. Every value in all three columns must be a nonempty,
trimmed, attribute-free character scalar of at most 96 UTF-8 bytes matching:

```text
^[a-z][a-z0-9]*(?:[.-][a-z0-9]+)*$
```

Thus identities begin with a lowercase letter and contain lowercase letters,
digits, and nonempty dot- or hyphen-separated segments. Uppercase letters,
spaces, underscores, slashes, and punctuation outside that grammar are not
accepted. `episode_id` is the discharge-domain primary key and must be unique;
multiple episodes per canonical patient are allowed. Terminal events refer to
the canonical `episode_id`.

The provider request contains only `episode_id` from those three domain
identities. It also carries project, bundle, state, and request identities, but
none is a substitute for a hospital source key.

A native hospital identifier may be used directly when it satisfies the
canonical syntax, cardinality, relationship, stability, and local privacy/
governance requirements. Lexical validity alone does not make a native medical
record or encounter identifier appropriate to retain. When a native identifier
does not satisfy the contract—or should not be exposed as the canonical
identifier—the hospital mapping must assign a valid, stable canonical identity
and own any resolution needed back to local data.

### 2.4 Current history behavior relevant to the question

Stage 7 records canonical `episode_id` and `patient_id`, governed state,
request, provider, estimate, and terminal outcome evidence in each applicable
episode disposition. It does not retain `index_encounter_id`, a native source
identifier, a source crosswalk, arbitrary model predictors, or the full
canonical bundle. Raw history remains append-only; current history is an
interpretation over complete valid scopes, explicit actions, and analytical/
history cutoffs.

This history is evidence of what RRP evaluated and accepted. It is not a
feature warehouse and cannot help a provider resolve inputs before the
provider call. The absence of a crosswalk from Stage 7 is intentional and does
not block project-owned provider resolution.

### 2.5 Current installed-resource and project behavior

The source catalog is a closed inventory whose entries project byte-for-byte
to an installed `resources/` tree. `rrpplatform::rrp_open_resource_catalog()`
opens one explicit installed root, and `rrpplatform::rrp_resource_path()`
resolves one exact logical resource identity. The catalog schema already
allows the resource class `documentation`, but its format allowlist currently
contains only `dcf` and `r`; no documentation entry exists among the current 25
resources.

The current initializer creates only `rrp-project.dcf` and `R/register.R`.
That registration file contains complete raw unavailable producer/provider
declarations. It is a correct lower-level skeleton, not yet the planned Stage 8
normal authoring experience.

## 3. Provider request discoverability assessment

### Finding

The request contract is sufficient; discoverability is not. The flat request
already conveys the episode, analytical cutoff, target interval, and exact
provenance needed by the proposed project-root-aware callable. Adding
patient/source identifiers, features, a canonical-domain payload, a database
handle, or model configuration would conflate provider-specific inputs with
the provider-neutral analytical question.

No change to `rrp.risk-request@0.1.0`, `rrp.provider-api@0.1.0`, episode state,
or accepted-estimate semantics is recommended for Stage 8.

### Required Stage 8 UX

The future generated `R/calculate-risk.R` should include an accurate compact
contract comment that states:

- the exact request class and flat-list nature;
- all 19 names, with the two doubles distinguished from scalar strings;
- the UTC timestamp and `(start,end]` interval semantics;
- that `episode_id` is canonical and is the only domain identifier supplied;
- that the object is detached, exact, and must not be mutated as a means of
  communicating with RRP; and
- the normal success and controlled-failure return alternatives.

That comment should answer “what object reaches this function?” without
requiring package-source inspection. It should link, by stable installed
resource identity and a runnable lookup example, to the complete installed
request reference. The installed reference should own the deeper field
semantics, identities, invariants, examples, and raw/normal distinction so the
template does not become an unmaintainable duplicate manual.

Package Rd pages and internal DCF authorities remain useful technical
evidence, but they are not a sufficient ordinary hospital authoring surface.

## 4. Canonical identity and predictor-resolution assessment

### Recommended responsibility boundary

The clean 1.0 boundary is:

```text
RRP canonical episode identity + analytical question at t
        ↓
hospital provider under one explicit project root
        ↓
hospital-owned canonical-to-local resolution
        ↓
hospital-owned predictor acquisition and feature engineering valid for t
        ↓
one governed remaining-risk probability
```

This is compatible with the current contracts. The accepted Stage 8 callable
has both facts needed to implement it: `request$episode_id` and
`request$as_of_time`, plus its separate explicit `project_root`. A project may
resolve data through files, SQL/DBI, Parquet, DuckDB, an API, an internal
package, a model engine, or another locally governed mechanism without making
that mechanism part of RRP's canonical contract.

RRP governs:

- the canonical episode identity delivered to the provider;
- eligibility, target meaning, interval, and authoritative analytical cutoff;
- provider selection and semantic compatibility;
- isolated invocation, result validation, and accepted-estimate construction;
  and
- the provider/model/software attribution retained by operational history.

The hospital owns:

- source identity meaning and canonical identity assignment;
- any canonical-to-native crosswalk and its access controls;
- model-specific predictor retrieval and feature engineering;
- ensuring those inputs are available and legitimate for `request$as_of_time`;
- truthful mapping, provider-implementation, and optional model versions when
  those realizations change; and
- local model governance, clinical validation, and production authorization.

The architecture's prohibition on a provider broadening the information set
should be read semantically: a provider cannot use future information,
redefine the cohort/target, or bypass the governed analytical context. It does
not require every model-specific predictor to become an RRP canonical field.
Stage 8 documentation should make this split explicit and avoid claiming that
RRP validates temporal provenance inside an opaque hospital model adapter.
RRP enforces `t` for the state and request; the hospital enforces it for its
private predictors.

If required predictor data is unavailable, the normal authoring adapter can
surface the existing `provider_input_unavailable` controlled failure. No new
failure vocabulary is needed.

### Why RRP should not retain the crosswalk

Adding a source-ID field or crosswalk store to RRP would:

- couple the provider-neutral request to one hospital's source topology;
- turn minimal canonical identity into a growing source integration schema;
- duplicate hospital-owned identity governance and access controls;
- increase sensitive-data retention in runtime/history;
- couple producer revisions to provider storage conventions; and
- create migration, correction, privacy, and lifecycle obligations unrelated
  to the singular risk target.

No current invariant requires those costs. The project is already the common
ownership boundary for producer and provider code. Their shared local
crosswalk is a legitimate project implementation detail so long as both sides
honor the same canonical identity and truthful versions.

### Contract practicality

No existing contract accidentally makes this boundary impractical:

- canonical admission validates the hospital-assigned identity;
- state and request preserve it exactly;
- the provider receives it before invocation;
- Stage 8's adapter can close over the explicit project root while preserving
  the raw one-argument provider contract;
- declared project extension packages can support hospital-specific access;
  and
- Stage 7 retains the governed request/estimate attribution without needing
  source data.

The boundary deliberately does not provide `patient_id` or
`index_encounter_id` to the provider. A hospital provider that requires them
must resolve them under project ownership from canonical `episode_id`, just as
it resolves any other local model input.

## 5. Fictional reference-project assessment

### Finding

A nontrivial identity-resolution example is compatible with Stage 5/6 and
would materially strengthen Stage 8. The current planned two-table example
constructs canonical IDs and uses only request timing in its provider. That
proves the adapter mechanics but does not prove the intended separation
between minimal canonical data and hospital-specific model inputs.

### Smallest useful source design

Retain the planned small `stays.csv` and `events.csv`, but make their native
stay/person keys visibly fictional and deliberately invalid under the
canonical identity grammar—for example by using uppercase letters and spaces.
Add one small generated project-owned crosswalk that maps each native stay key
to its valid canonical `episode_id`. Keep canonical patient and encounter
identity mapping explicit there or beside the same bounded mapping evidence
when needed by the producer.

Add one obviously fictional, nonclinical model input and its availability
timestamp to the stay-side source facts. No separate wide feature table is
needed merely for scale. The mapping should:

1. join the native rows to the explicit crosswalk;
2. produce valid canonical episode/patient/encounter identities;
3. perform the already planned event-code and availability mapping; and
4. discard the model-only value and all source keys from the canonical
   domains.

The project provider should:

1. receive the real Stage 6 request;
2. resolve `request$episode_id` through the project-owned crosswalk;
3. retrieve the source-only model input by native stay key;
4. require that the input is available through `request$as_of_time`; and
5. use it in one simple deterministic, inspectable, visibly nonclinical
   calculation that returns the governed probability.

An explicit crosswalk is preferable to a reversible string transformation.
The latter teaches that canonical identity is merely an encoding of a source
key, encourages provider duplication of producer logic, and does not exercise
real resolution failure. A tiny crosswalk makes identity ownership and the
join observable without requiring an identity service.

The exact fictional labels, numeric formula, and row values can remain plan/
implementation details. The important acceptance facts are that at least one
native identity cannot be used canonically as-is, at least one provider input
is absent from the canonical domains, the provider resolves both entirely
inside the project, and the example remains deterministic and human-
inspectable.

This improves the non-privilege proof: generic producer, runtime, provider,
and history code still knows no fictional identifier, crosswalk path, source
column, or predictor. Replacing the fictional files and callables with hospital
implementations leaves every RRP boundary unchanged.

## 6. Installed product-documentation assessment

### Three distinct documentation classes

Stage 8 should preserve this division:

1. **Development documentation** explains product purpose, architecture,
   construction order, implementation history, and contributor practice. It
   remains repository/maintainer material and is not assumed to ship.
2. **Installed product documentation** is version-matched hospital-user
   guidance cataloged in the installed product. It explains exact supported
   contracts, responsibilities, and operations without requiring Git.
3. **Project-local guidance** consists of the generated `README.md` and focused
   template comments. It tells the adopter what to edit in that project and
   points to the installed authority for complete detail.

The intended hierarchy is sound:

```text
generated project scaffold
        ↓ what do I edit and what reaches this callable?
installed product documentation
        ↓ what is the complete contract and who owns each responsibility?
fictional reference project
        ↓ show the same architecture working end to end
```

All three are needed in Stage 8. None can substitute for another: comments are
too small for complete semantics, standalone prose cannot prove executability,
and example code does not define a general contract.

### Ownership and installed-resource realization

`rrpplatform` should own installed product-documentation access because it
already owns the resource catalog, project operations, initialization, and the
normal authoring boundary. `rrpruntime` should continue to own semantic
contracts, not user-document discovery or project guidance.

The current resource machinery is structurally sufficient:

- the schema already defines a `documentation` resource class;
- the source-to-installed catalog projection is closed and byte-preserving;
- logical resource IDs avoid dependence on installed filesystem layout; and
- `rrp_resource_path()` already provides explicit installed access.

One narrow extension is needed: admit Markdown as a controlled resource format
and validate/catalog the new closed files. Because source resources are
currently required beneath `resources/`, the smallest nonduplicative source
location is a documentation subtree under that existing resource root. Using
a separate `docs/user/` source tree would require broadening the source-catalog
closure or maintaining duplicate authoritative copies; neither is justified
for Stage 8. The architecture's `docs/user/` wording is prospective rather
than a fixed physical contract.

No documentation-specific access API is required in Stage 8. Exact resource
IDs plus `rrp_resource_path()` are sufficient until Stage 11 supplies the
ordinary installation/CLI discovery experience.

### Minimum Stage 8 installed set

Three concise single-source Markdown resources are sufficient:

1. **Project authoring guide.** Explain the standard scaffold, trusted project
   code, normal edit surfaces, canonical mapping and identity responsibility,
   provider/model responsibility, dependency declaration, controlled
   failures, and the direct-raw escape hatch.
2. **Provider request reference.** Define the exact 19-field request structure,
   field types and meanings, interval and identity invariants, deliberate
   omissions, normal output/failure alternatives, and hospital responsibility
   for model-specific data and temporal validity.
3. **Fictional reference walkthrough.** Give the complete supported package-
   level sequence for initialization, source generation, inspection,
   validation, state initialization, durable execution/repeat, history
   inspection, and copy/reopen outside the source repository.

Canonical domain field details can be linked from the project-authoring guide
to installed contract resources; they do not require a fourth narrative file
unless the planning revision finds the guide unreadable without one. The
generated project `README.md` should summarize its four project-owned surfaces
and contain runnable installed-resource lookup examples. The two callable
files should include exact local interface comments and point to the relevant
resource ID. They should not duplicate rationale, lifecycle guidance, or the
whole walkthrough.

The fictional project is executable companion material. Its README may add
fictional file/column explanations, but general authoring rules belong in the
installed product docs and exact semantic authority remains in the installed
contracts.

### Documentation progression

Stage 8 should begin a cross-roadmap product-documentation track without
creating a separate roadmap stage or a documentation framework. Later stages
should append or revise the same versioned source set only when their capability
exists:

- Stage 9: logical product definitions and use;
- Stage 10: supplied application use;
- Stage 11: installation, CLI, upgrade, and ordinary documentation discovery;
- Stage 12: deployment and target realization;
- Stage 13: clean-system/adopter acceptance and troubleshooting; and
- Stage 14: release-quality assembly and generated publication formats.

Stage 8 should not add PDF generation, a documentation site, deployment/
application manuals, or release packaging. Maintaining structured Markdown as
the single installed source leaves later User Guide, Operations Guide, HTML,
or PDF generation possible without parallel hand-maintained prose.

## 7. Comparison against the current Stage 8 plan

### Increment 8.A — Supported standard project authoring boundary

**Remain unchanged:** the `rrpplatform` authoring owner, one installed
authoring authority, two narrow hospital callables, explicit root, declarative
metadata/dependency inventory, generated thin `R/register.R`, raw-contract
adaptation, unchanged Stage 4–7 contracts, six-file initialized scaffold,
controlled failures, direct-raw escape hatch, and existing evidence strategy.

**Add:** cataloged installed authoring and provider-request documentation;
Markdown resource-format admission; exact request/output comments in
`R/calculate-risk.R`; focused producer return comments in
`R/produce-canonical.R`; generated README links and lookup examples; tests that
the installed documents resolve outside Git and that scaffold descriptions
agree with the closed authoring/request contracts.

**Clarify:** a standard provider may use `project_root` and canonical
`request$episode_id` to resolve arbitrary project-owned model inputs, but must
honor `request$as_of_time`; those predictors do not become canonical fields or
RRP history. RRP validates the analytical context and output, not opaque
predictor provenance.

**Move/remove:** nothing. The documentation belongs with the authoring
capability it explains, not in a later proof-only increment.

### Increment 8.B — Fictional project, meaningful mapping, and project provider

**Remain unchanged:** an ordinary installed-template-backed independent
project, explicit deterministic generation, source-local validation,
meaningful source/canonical separation, availability filtering, project-owned
provider, empty extension inventory, copied-project proof, and no fictional
branch in generic code.

**Add:** native stay keys that fail the canonical identity grammar; an explicit
small project-owned crosswalk; a provider-only fictional predictor with an
availability time; producer proof that those fields do not leak into canonical
domains; provider proof that canonical-to-native resolution and predictor
retrieval happen under project ownership; controlled missing/late predictor
evidence.

**Clarify:** the crosswalk is fictional project data, not an RRP resource,
canonical field, state table, or history record. Its exact path is known only
to project code.

**Revise:** the planned two-CSV generated inventory should admit the one small
crosswalk artifact, and the provider should use the project-only predictor
rather than merely reproduce the installed transparent timing-only formula.
The calculation should stay simple, deterministic, inspectable, and
nonclinical. This is a teaching-proof correction, not a new provider contract.

**Move/remove:** remove only the requirement that the fictional provider use
the exact installed transparent relationship. Retain the installed transparent
provider as separate regression evidence.

### Increment 8.C — Installed end-to-end reference proof and human runbook

**Remain unchanged:** complete installed non-Git execution, durable history,
repeat/copy/reopen behavior, raw escape-hatch regression, human inspection,
hosted evidence, and no CLI/general reference runner.

**Add:** prove the three installed documents resolve and are usable from the
installed catalog; prove the project README and callable comments identify the
normal edit surfaces and installed references; execute the documented
canonical-identity/crosswalk/predictor path; inspect all links/resource IDs;
and ensure the human runbook is the cataloged fictional-reference document,
not an implementation-record-only narrative.

**Clarify:** 8.C validates and reconciles documentation delivered by 8.A/8.B;
it should not defer authoring documentation creation until after the
interfaces are implemented.

**Move/remove:** no increment boundary change. No separate documentation
increment is justified.

## 8. Recommended Stage 8 revisions

A subsequent planning-only pass should revise Stage 8 once to:

1. state explicitly that `rrp.risk-request@0.1.0` remains unchanged and the
   provider issue is discoverability, not input redesign;
2. require exact request structure/output guidance in the standard scaffold;
3. establish cataloged, version-matched, `rrpplatform`-owned installed Markdown
   product documentation, using the existing explicit resource access;
4. allocate the project-authoring and provider-request resources to 8.A, the
   fictional walkthrough content to 8.B, and complete installed usability
   proof to 8.C;
5. clarify hospital responsibility for canonical-to-local resolution,
   arbitrary predictor construction, and predictor temporal validity;
6. prohibit RRP-owned source-ID/crosswalk retention and arbitrary feature
   persistence as part of the normal authoring capability;
7. revise the fictional source inventory to include an explicit small
   project-owned identity crosswalk and at least one source-only, time-aware
   predictor;
8. require the fictional provider to resolve that predictor from canonical
   `episode_id` and use it in its nonclinical calculation; and
9. retain the three-increment structure and every existing raw-contract,
   non-privilege, installed-path, and durable-history boundary.

## 9. Items explicitly deferred beyond Stage 8

The assessment does not justify any Stage 8 implementation of:

- a universal predictor or feature schema;
- a feature store, source-ID registry, or RRP-owned crosswalk;
- RRP inspection or temporal validation of arbitrary hospital predictors;
- model training, approval, packaging, registry, monitoring, or lifecycle
  systems;
- additional provider transports or model-engine-specific adapters;
- dependency acquisition, solving, project lockfiles, or source digests;
- a CLI or ordinary installed-documentation browser;
- product/application, deployment, troubleshooting, or release manuals before
  their capabilities exist;
- a documentation website, PDF generator, or other publication pipeline; or
- any Stage 9+ product, application, distribution, deployment, or release
  behavior.

## 10. Open questions

No architectural decision blocks a coherent Stage 8 plan revision. The exact
documentation resource IDs/file names, fictional native labels, predictor
name/value, crosswalk filename, and simple probability formula should be fixed
in that revision only to the degree required for closed inventories and
acceptance evidence. They do not require a new contract family or increment.

The repository plan/record currently describe the detailed Stage 8 plan as
ready for review rather than implemented. This assessment does not alter that
lifecycle status; the subsequent planning pass should reconcile its revised
plan and acceptance wording before 8.A implementation begins.

## 11. Files inspected

The assessment inspected the current governing and development authorities:

- `docs/platform-true-north.md`;
- `docs/platform-architecture.md`;
- `docs/platform-implementation-plan.md`;
- `docs/platform-implementation-record.md`;
- `docs/implementation-guidance.md`; and
- `AGENTS.md`.

Current implementation evidence included:

- `resources/contracts/canonical/domains/discharge-episode.dcf`;
- `resources/contracts/runtime/episode-state.dcf`;
- `resources/contracts/runtime/risk-request.dcf`;
- `resources/contracts/runtime/risk-provider.dcf`;
- `resources/contracts/runtime/risk-estimate.dcf`;
- `resources/contracts/history/operational-scope.dcf`;
- `resources/contracts/history/episode-disposition.dcf`;
- `resources/contracts/history/history-action.dcf`;
- `packages/rrpruntime/R/canonical-admission.R`;
- `packages/rrpruntime/R/episode-state.R`;
- `packages/rrpruntime/R/risk-provider.R`;
- `packages/rrpruntime/R/history.R`;
- `packages/rrpruntime/tests/risk-provider.R`;
- `packages/rrpplatform/R/producer-execution.R`;
- `packages/rrpplatform/R/risk-execution.R`;
- `packages/rrpplatform/R/durable-history.R`;
- `packages/rrpplatform/R/project-loader.R`;
- `packages/rrpplatform/R/project-initializer.R`;
- `packages/rrpplatform/R/resource-catalog.R`;
- `packages/rrpplatform/tests/risk-execution.R`;
- `packages/rrpplatform/tests/durable-history.R`;
- `resources/templates/project/rrp-project.dcf`;
- `resources/templates/project/R/register.R`;
- `resources/resource-catalog-schema.dcf`;
- `resources/source-catalog.dcf`;
- `tools/validate-repository.R`; and
- `tools/validate-packages.R`.

The current accepted 1.0 implementation provided sufficient evidence; no
historical checkout was needed to answer these questions.

## 12. Validation performed

After this assessment was added to the explicit repository inventory, the
following proportionate checks were run:

```sh
Rscript --vanilla tools/validate-repository.R
Rscript --vanilla tools/validate-packages.R
git diff --check
```

All three checks passed. Repository validation reported eight passing checks
with zero issues, including `foundational_files`. Package/resource validation
completed the package, project, canonical, runtime, and history foundation
matrix successfully. The final diff has no whitespace errors. No generated
validation artifact remained in the repository.
