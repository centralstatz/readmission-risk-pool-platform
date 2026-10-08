# `rrpplatform`

`rrpplatform` is the main internal implementation package within RRP software.
Its package version is `0.1.0.9000`, independently of `rrpruntime` version
`0.4.0.9000` and the RRP product development identity `1.0.0-dev`.

The package imports `rrpruntime`, `DBI`, `duckdb`, `shiny`, `bslib`, `plotly`,
`reactable`, and `brand.yml` while retaining the
accepted one-way internal-package dependency. It owns strict validation of the
cataloged `rrp.project@0.3.0`
manifest and `rrp.project-registration@0.3.0` registration-result structures,
the installed canonical specification family, the five singular runtime
authorities, semantic provider declarations, one explicit project-loading
boundary, the installed `rrp.project-authoring@0.1.0` authority and raw-contract
adapter, transactional six-path standard-project initialization plus two
bounded declarative branding resources from cataloged software-owned
templates, transactional seven-path fictional-project realization with the
same branding resources and separate explicit project-owned source generation,
explicit
project-state lifecycle operations, and the
private DuckDB realization of the runtime-owned logical history port. Contract
parsers, registration evaluation,
rendering, staging, path checks, composition, resolution, producer request and
result validation, provider-authority agreement, and error construction remain
internal. Provider execution remains explicit and in memory.

It also owns four installed logical-product authorities and a storage-neutral
builder that derives one all-required detached set—current accepted remaining
risk, actual accepted remaining-risk trajectory, and effective scope summary—
from one explicit complete history scope and history cutoff. One installed
materialization authority governs staged immutable DCF/CSV publication under
project state, replaceable current selection, exact validation, contextual
freshness, and detached logical access. The cataloged Logical Products Guide
documents the supported human sequence, semantics, valid-empty behavior,
freshness, backup exclusion, and rebuild path without adding another API.

It also owns the installed `rrp.application.supplied@0.1.0` and
`rrp.project-brand@0.1.0` authorities. The application boundary reads the exact
three validated products once, converts optional project-root `_brand.yml`
through the upstream parser into a closed detached presentation model, creates
pure component-ready view models, and launches one generic Shiny application
on loopback without analytical execution or mutation.
The useful installed experience provides the Current Risk Pool and Overview,
deterministic Reactable filtering/paging/selection, truthful actual-observation
sparklines, one Plotly trajectory detail with an exact observation table,
direct descriptive scope summaries, and explicit freshness/empty states. The
primary brand color affects identity and composition only; the continuous risk
bar retains a fixed RRP-owned neutral analytical scale.
The cataloged Supplied Application Guide documents the installed package-level
launch, product-state, branding, read-only, loopback, and later-deployment
boundaries without requiring repository source.

Increment 11.A adds seven dependency-light installed lifecycle/result
authorities and three stable package operations. Increment 11.B adds the thin
version-specific launcher and package dispatcher for help, version, and
read-only project status. Exact host-R, private-library, package, and installed-
resource preflight happens before command delegation. No active-version
selection, distribution builder, installer, dependency restoration, or project
mutation is implemented.

Its current callable interfaces are:

- `rrp_cli_dispatch(...)` validates one explicitly supplied installed software
  context, parses the bounded noun grammar, delegates the implemented read-only
  commands, and renders the same common result as human text or versioned JSON;
- `rrp_register_authored_project(project_root)` validates one standard-authored
  project under the authoritative loader context and compiles its two narrow
  hospital callables into the unchanged raw registration contract;
- `rrp_authoring_failure(code)` constructs one closed intentional producer or
  provider failure token whose applicability is rechecked by its adapter;
- `rrp_execute_producer(software_catalog, project_root, as_of_time)` loads one
  explicit project, invokes exactly its selected producer once through the
  closed request/result contract, and delegates its candidate to runtime
  admission;
- `rrp_execute_risk(software_catalog, project_root, admitted_bundle,
  episode_id, as_of_time)` loads that project, prepares one immutable eligible
  episode state, and invokes exactly its selected compatible provider once;
- `rrp_open_resource_catalog(software_root)` validates the fixed installed DCF
  schema, catalog, and closed declared resource set beneath exactly the supplied
  root; and
- `rrp_load_project(software_catalog, project_root)` revalidates the required
  software resources and canonical/runtime authorities, validates exactly the
  supplied project, executes its fixed trusted `R/register.R` boundary once, and returns
  one closed `rrp_project_context` after exact semantic producer/provider
  validation and selection;
- `rrp_initialize_project(software_catalog, project_root, project_id,
  project_version)` creates exactly the six standard authoring paths plus
  `_brand.yml` and its contained logo in a previously absent destination,
  validates staged and promoted output through the loader, and returns one
  common operation result;
- `rrp_initialize_fictional_project(software_catalog, project_root)` creates
  the supplied ordinary fictional teaching project at an absent destination;
  its project-owned source generator remains a separate explicit action;
- `rrp_prepare_fictional_source(software_catalog, project_root)` resolves the
  installed generator and realizes or reuses deterministic source only for the
  exact supplied fictional project identity;
- `rrp_initialize_project_state(software_catalog, project_root)` creates and
  validates exactly `state.dcf` and `history.duckdb` beneath the manifest-owned
  state path, or validates an existing compatible state without mutation;
- `rrp_inspect_project_state(software_catalog, project_root)` reports absent or
  compatible state and fails boundedly for invalid/incompatible state without
  exposing a database connection or physical schema;
- `rrp_validate_project(software_catalog, project_root)` reuses the loader and
  returns one bounded structural success/failure result, including declared
  extension-library and state status and a fixed warning when state is absent;
- `rrp_project_status(software_catalog, project_root, ...)` composes bounded
  read-only project, state/history, product, freshness, and application
  readiness without invoking selected components or mutating the project;
- `rrp_resource_path(catalog, resource_id)` resolves one declared logical ID
  after reopening and revalidating the installed resource boundary;
- `rrp_validate_software_resources(software_root)` returns one common
  structured success/failure result for that same explicit-root boundary; and
- `rrp_operation_succeeded(result)` validates a common result and returns its
  scalar machine-readable success state; and
- `rrp_build_product_set(software_catalog, project_root, operation_run_id,
  history_cutoff)` returns one coherent detached logical set or one bounded
  structured product-construction failure;
- `rrp_build_and_materialize_products(software_catalog, project_root,
  operation_run_id, history_cutoff)` performs the same accepted build and
  atomic publication sequence behind one package-owned operator intention;
- `rrp_materialize_product_set(software_catalog, project_root, product_set)`
  validates and publishes one complete logical set through the supplied
  materializer;
- `rrp_open_product_access(software_catalog, project_root, ...)` validates and
  reopens the selected current set, optionally comparing it with one explicit
  history scope and cutoff;
- `rrp_list_products(product_access)` returns the exact bounded three-member
  inventory; and
- `rrp_read_product(product_access, product_id, product_version, ...)` returns
  one detached logical product or bounded metadata without exposing physical
  storage; and
- `rrp_launch_app(software_catalog, project_root, ...)` validates existing
  products and bounded standard branding, constructs the installed supplied
  application, and runs it on loopback until the local session exits.

The low-level resource functions fail with a typed `rrp_resource_error`
carrying a stable `code` and bounded safe message. They do not discover a root
from the working directory, Git, environment variables, package installation,
sibling paths, or repository source. The catalog object is a validated software
context, not a general configuration object.

Expected low-level project failures inherit from `rrp_project_error` and carry
one stable safe code. Project loading validates the declarative manifest and
filesystem boundaries before trusted code. Registration is evaluated in a
fresh environment whose parent is the base environment, with RRP-owned package
libraries first, an existing declared project extension library second, and
ambient user libraries excluded. This reduces accidental coupling but is not a
security sandbox: `R/register.R` is trusted local code. The loader validates and
resolves the returned callable objects but never invokes the selected producer
or provider. Producer records declare exact producer API, canonical bundle and
profile, implementation, mapping, and available-capability identities;
providers declare exact target, state, request, estimate, implementation, and
nullable model compatibility.

Producer execution validates the authoritative as-of time before project code,
reuses the loader and its software-first extension-library policy, and passes
only closed contract and identity facts. It does not pass paths, source
configuration, credentials, provider/state handles, callbacks, or arbitrary
options. Expected project, producer-result, and canonical-admission failures
become bounded common results. Arbitrary producer error text is discarded;
unexpected defects in RRP code remain visible. Success returns the admitted
in-memory canonical bundle, which can contain sensitive analytical data and
must not be logged or rendered as diagnostic output.

Risk execution validates the episode and authoritative as-of time before
project code, reuses the loader and its controlled library policy, requires the
bundle and project canonical profile identities to agree, delegates state and
provider semantics to `rrpruntime`, and returns one accepted in-memory estimate.
Expected project, target, runtime, and provider-result failures become bounded
common results; unexpected implementation defects and resource-owner errors
remain visible. The installed protected transparent provider is available only
through explicit project selection and returns the nonclinical deterministic
reference value `0.20 * remaining_to_target_seconds / 2592000`. It is neither a
default nor a fallback, and project-owned compatible providers use the same
generic operation.

Opening may report root codes `invalid_software_root`,
`missing_software_root`, or `linked_software_root`; catalog/schema state codes
such as `missing_catalog`, `linked_catalog`, `nonregular_catalog`,
`malformed_catalog`, `invalid_catalog_fields`, `unsupported_catalog`, and their
schema equivalents; or resource-contract codes for invalid fields,
classification, identity, path uniqueness/collision, required schema mapping,
file state, containment, and closed inventory. Lookup additionally reports
`invalid_catalog_object`, `catalog_root_mismatch`, `invalid_resource_id`,
`unknown_resource_id`, or `catalog_changed`, and can return any reopening error
when installed state changed. Codes are machine-readable; messages are bounded
maintainer text and do not echo arbitrary paths, parser text, IDs, or content.

Project initialization is create-only and uses a unique sibling staging
directory. Its normal scaffold exposes only source-to-canonical mapping and
risk calculation as hospital customization points; thin registration, raw
protocol envelopes, fixed capabilities, deterministic bundle identity, and
canonical admission remain RRP-owned. Advanced projects may still replace the
thin registration with the supported raw `0.3.0` contract.
It never overwrites, merges with, repairs, or adopts existing content; cleanup
is limited to filesystem objects owned by the current attempt. Its registered
producer returns the controlled `producer_unavailable` result when later
invoked with a request; initialization and validation do not invoke it. The
provider is a semantically conforming unavailable placeholder. The declared
`extensions/library` and `state` locations remain absent until their distinct
owners initialize them.

State initialization is separately create-only, uses owned staging and atomic
promotion, and admits no overwrite, force, repair, or migration mode. The
closed metadata and DuckDB schema identify their exact logical-history,
adapter, physical-schema, and serialize-v3/XDR/hex payload versions. Every
adapter operation opens and reliably closes a private bounded DBI session;
callers receive only the storage-neutral `rrp_history_port`. Identical writes
are idempotent, conflicting identities fail, restatements are atomic, and raw
reads remain bounded by an operation or episode/target relationship closure.

`rrp_execute_durable_bundle()` connects the existing selected producer,
canonical admission, episode-state, and provider semantics to that port. One
successful admission creates or matches one bundle scope; each missing episode
receives one independently committed terminal disposition, and continuation
skips every committed initial result, including failures. Supported operations
also expose bounded raw/current history, explicit failed-attempt retry, and
append-only invalidation or atomic restatement. These operations add no stored
bundle, loop cursor, automatic retry, or second scope authority.

`rrp_backup_project_state()` checkpoints one compatible quiescent state and
creates a closed two-file backup artifact at an absent destination.
`rrp_restore_project_state()` validates that artifact against an independently
loaded compatible project and atomically promotes the recovered state only
when its declared state path is absent. Restore uses ordinary state reopening
and 7.C continuation; it adds no overwrite, merge, migration, repair, scheduled
backup, or alternate recovery engine.
The optional product store is derived state: backup excludes it, restore leaves
it absent, and authoritative history can rebuild it.
The project doctor remains inspection-only: it reports absent, compatible, or
invalid state and never initializes, backs up, restores, or repairs it.

Product materialization creates the optional `state/products` store only when
needed. It writes a complete set in same-filesystem staging, validates it,
promotes an immutable materialization-identity directory, and then replaces the
small current pointer. Identical realizations are reused; conflicting or
corrupt content fails closed. Opening revalidates inventory, sizes, MD5
corruption evidence, DCF/CSV encoding, logical contracts, identities, and set
coherence before returning detached access. Freshness compares an explicitly
requested governed scope's current effective-history fingerprint; a stale but
otherwise valid set remains readable.

The returned project context is a validated in-process snapshot, not a mutable
or serialized project session. It validates all five runtime authorities
against canonical contracts and assembles exact closed contexts consumed by
runtime state/provider behavior. The package does not provide active-version
selection, dependency restoration, installation, or deployment. Its bounded
version-specific command dispatcher does not broaden those lifecycle claims. It
normalizes installed canonical authority into
the exact context accepted by `rrpruntime` and invokes its admission export
only after one selected project producer returns a conforming result.
The standalone producer and risk primitives still perform no retry, scheduling,
state initialization, persistence, or retention.
The result/diagnostic foundation is deliberately
in-memory and contains no run identity, event lifecycle, arbitrary context,
sink, logging, metrics, persistence, or audit behavior.

The package is not a separately installed RRP product, installer, shared
active-version selector, public project API, or separately marketed package.
