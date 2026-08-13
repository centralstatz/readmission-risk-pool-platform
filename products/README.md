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
