# `rrpplatform`

`rrpplatform` is the main internal implementation package within RRP software.
Its package version is `0.1.0.9000`, independently of `rrpruntime` version
`0.3.0.9000` and the RRP product development identity `1.0.0-dev`.

The package imports `rrpruntime` to retain the accepted one-way internal-package
dependency. It owns strict validation of the cataloged `rrp.project@0.3.0`
manifest and `rrp.project-registration@0.3.0` registration-result structures,
the installed canonical specification family, the five singular runtime
authorities, semantic provider declarations, one explicit project-loading
boundary, and transactional minimal-project initialization from cataloged
software-owned templates. Contract parsers, registration evaluation,
rendering, staging, path checks, composition, resolution, producer request and
result validation, provider-authority agreement, and error construction remain
internal. Provider execution remains explicit and in memory.

Its current callable interfaces are:

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
  project_version)` creates exactly the manifest and registration file in a
  previously absent destination, validates staged and promoted output through
  the loader, and returns one common operation result;
- `rrp_validate_project(software_catalog, project_root)` reuses the loader and
  returns one bounded structural success/failure result, including declared
  extension-library and state status and a fixed warning when state is absent;
- `rrp_resource_path(catalog, resource_id)` resolves one declared logical ID
  after reopening and revalidating the installed resource boundary;
- `rrp_validate_software_resources(software_root)` returns one common
  structured success/failure result for that same explicit-root boundary; and
- `rrp_operation_succeeded(result)` validates a common result and returns its
  scalar machine-readable success state.

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

Initialization is create-only and uses a unique sibling staging directory.
It never overwrites, merges with, repairs, or adopts existing content; cleanup
is limited to filesystem objects owned by the current attempt. Its registered
producer returns the controlled `producer_unavailable` result when later
invoked with a request; initialization and validation do not invoke it. The
provider is a semantically conforming unavailable placeholder. The declared
`extensions/library` and `state` locations remain absent.

The returned project context is a validated in-process snapshot, not a mutable
or serialized project session. It validates all five runtime authorities
against canonical contracts and assembles exact closed contexts consumed by
runtime state/provider behavior. The package does not provide root selection,
an ordinary operator command, dependency restoration, persistent state,
runtime history, products, applications, installation, or deployment. It
normalizes installed canonical authority into
the exact context accepted by `rrpruntime` and invokes its admission export
only after one selected project producer returns a conforming result.
Producer and risk execution perform no retry, scheduling, state initialization,
persistence, or retention.
The result/diagnostic foundation is deliberately
in-memory and contains no run identity, event lifecycle, arbitrary context,
sink, logging, metrics, persistence, or audit behavior.

The package is not the RRP product, installer, command-line interface, public
project API, or a separately marketed package.
