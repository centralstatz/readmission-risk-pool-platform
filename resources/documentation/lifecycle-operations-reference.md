# RRP lifecycle operations reference

This installed reference describes the stable package operations realized in
RRP 1.0 Increment 11.A. They receive an explicit validated software catalog and
an explicit project root. They do not select installed software, discover a
project, parse command-line input, or implement installation and activation.

## Read project lifecycle status

Call `rrpplatform::rrp_project_status(catalog, project_root)` for bounded,
read-only evidence about project compatibility, state/history readiness,
logical products, and supplied-application readiness. A fresh valid project may
successfully report uninitialized state or absent products with warnings.

Supply both `expected_operation_run_id` and `history_cutoff` to compare the
current materialized product with one explicit analytical context. Omitting
both reports `not_evaluated` for an existing product. Supplying only one is an
error. The operation does not invoke producer/provider code, test source
connectivity, infer a latest analytical context, initialize or repair state, or
refresh products.

## Build and materialize products

Call
`rrpplatform::rrp_build_and_materialize_products(catalog, project_root,
operation_run_id, history_cutoff)` to compose the existing logical-product
builder and atomic materializer. The operation retains explicit scope identity
through `operation_run_id`, an explicit cutoff, deterministic product identity,
and existing immutable-realization/current-pointer behavior. It does not run
analytics or launch the application.

## Prepare the fictional source

After `rrp_initialize_fictional_project()`, call
`rrpplatform::rrp_prepare_fictional_source(catalog, project_root)`. The
operation executes the cataloged installed deterministic generator and accepts
only the exact supplied fictional reference-project identity. An identical
existing realization is reused; conflicting content fails without overwrite.
This intentionally narrow operation is not a general hospital ingestion API.

## Authorities and later lifecycle work

The installed catalog also carries exact authorities for distribution,
dependency specification, installation, activation, installed diagnosis,
project lifecycle results, and versioned CLI JSON results. These authorities
keep product version, development version, distribution content, build
occurrence, installation, activation, package/API, project, and state identities
distinct. The realized distribution builder, version launcher/CLI, and shared
installer consume those authorities. Active-version selection, installed
verify/doctor, and transition/uninstall behavior remain later lifecycle work.

Distribution/build/installation evidence remains software lifecycle evidence.
It is not added to durable analytical history, whose existing product,
development, API, and component attribution remains unchanged.
