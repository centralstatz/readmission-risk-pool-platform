# Logical products

This directory owns backend-neutral product builders, conformance, coherent
product-set composition, and the logical read boundary used by application
consumers. The authoritative contracts are under
`contracts/products/` and the design is documented in
`docs/architecture/logical-product-foundation.md`.

The builders accept an `rrpruntime` persistence port or normalized records
already returned by that port. They never query source implementations, invoke
providers, rerun eligibility, or use DuckDB, DBI, SQL, Shiny, filenames, or a
physical product format.

Iteration 6.1 keeps this generic layer in memory. Iteration 6.2 realizes its
unchanged access shape through `implementations/products/yaml/` and injects
that access into `app/`. Physical code and Shiny remain outside this directory.
Phase 7 keeps product refresh a distinct human operation downstream of a
platform run; rebuilding products never creates estimates or history.

Iteration 8.1 splits the YAML adapter's read-only access realization from its
writer so a reduced application artifact can carry validation/access without
materialization behavior. Logical product and adapter semantics are unchanged.
