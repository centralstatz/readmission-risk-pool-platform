# `rrpplatform`

`rrpplatform` is the main internal implementation package within RRP software.
Its package version is `0.1.0.9000`, independently of `rrpruntime` version
`0.3.0.9000` and the RRP product development identity `1.0.0-dev`.

The package imports `rrpruntime` to retain the accepted one-way internal-package
dependency. Increment 3.B adds its first two callable interfaces:

- `rrp_open_resource_catalog(software_root)` validates the fixed installed DCF
  schema, catalog, and closed declared resource set beneath exactly the supplied
  root; and
- `rrp_resource_path(catalog, resource_id)` resolves one declared logical ID
  after reopening and revalidating the installed resource boundary.

Both functions fail with a typed `rrp_resource_error` carrying a stable `code`
and bounded safe message. They do not discover a root from the working
directory, Git, environment variables, package installation, sibling paths, or
repository source. The catalog object is a validated software context, not a
general configuration object.

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

The package does not yet provide root selection, an ordinary operator command,
operation results, diagnostics, projects, clinical contracts, runtime
orchestration, products, applications, installation, or deployment.

The package is not the RRP product, installer, command-line interface, public
project API, or a separately marketed package.
