# Logical products

This directory owns backend-neutral product builders, conformance, coherent
product-set composition, and the logical read boundary intended for future
application consumers. The authoritative contracts are under
`contracts/products/` and the design is documented in
`docs/architecture/logical-product-foundation.md`.

The builders accept an `rrpruntime` persistence port or normalized records
already returned by that port. They never query source implementations, invoke
providers, rerun eligibility, or use DuckDB, DBI, SQL, Shiny, filenames, or a
physical product format.

Iteration 6.1 keeps products in memory. Materialization and a minimal
application remain Iteration 6.2 work.
