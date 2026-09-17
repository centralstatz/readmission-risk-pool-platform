# `rrpplatform`

`rrpplatform` is the main internal implementation package within RRP software.
Its package version is `0.1.0.9000`, independently of `rrpruntime` version
`0.3.0.9000` and the RRP product development identity `1.0.0-dev`.

The package imports `rrpruntime` to retain the accepted one-way internal-package
dependency. It owns strict validation of the cataloged `rrp.project@0.2.0`
manifest and `rrp.project-registration@0.2.0` registration-result structures,
the installed canonical specification family, one explicit project-loading
boundary, and transactional minimal-project initialization from cataloged
software-owned templates. Contract parsers, registration evaluation,
rendering, staging, path checks, composition, resolution, and error
construction remain internal.

Its current callable interfaces are:

- `rrp_open_resource_catalog(software_root)` validates the fixed installed DCF
  schema, catalog, and closed declared resource set beneath exactly the supplied
  root; and
- `rrp_load_project(software_catalog, project_root)` revalidates the required
  software resources and canonical authorities, validates exactly the supplied
  project, executes its fixed trusted `R/register.R` boundary once, and returns
  one closed `rrp_project_context` after exact producer/provider selection;
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
providers retain their Stage 4 structural shape.

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
provider remains a non-executable structural placeholder. The declared
`extensions/library` and `state` locations remain absent.

The returned project context is a validated in-process snapshot, not a mutable
or serialized project session. The package does not yet provide root selection,
an ordinary operator command, dependency restoration, state creation,
producer execution, runtime orchestration, products, applications,
installation, or deployment. It can internally normalize the installed
canonical authority into the exact context accepted by `rrpruntime`, whose one
export can admit a directly supplied candidate; no supported project operation
invokes that primitive yet.
The result/diagnostic foundation is deliberately
in-memory and contains no run identity, event lifecycle, arbitrary context,
sink, logging, metrics, persistence, or audit behavior.

The package is not the RRP product, installer, command-line interface, public
project API, or a separately marketed package.
