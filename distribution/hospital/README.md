# Readmission Risk Pool Hospital Implementation

This is a generated, fictional/nonclinical implementation baseline produced by
the Readmission Risk Pool Platform repository. It contains one exact Platform
release-candidate archive for the Iteration 11.4 proof, one top-level `renv`
environment, thin human operations, an editable producer scaffold, and a
separate complete fictional adopter example.

This distribution is not a published release, clinical system, security
boundary, hospital integration, deployment, or substitute for local validation
and governance. No public license is installed by this proof.

## Start here

From the generated distribution root:

```sh
Rscript -e 'renv::restore()'
Rscript validate-distribution.R
Rscript operations/initialize.R
Rscript operations/doctor.R
Rscript operations/run-reference-acceptance.R
```

Reference acceptance uses only the embedded Platform's unchanged fictional
synthetic implementation and isolated `build/reference/` state. It runs source,
runtime/provider, DuckDB history, logical products, materialization, Shiny
construction, and the reduced application artifact without publication.

The editable `implementation/` scaffold demonstrates the supported Phase 10
trust pattern. Its callable deliberately fails until a recipient implements and
conforms local source mapping. YAML selects an exact registered producer but
never identifies executable code.

The complete `examples/fictional-adopter/` implementation is separate
fictional evidence. Run:

```sh
Rscript operations/run-fictional-adopter-proof.R
```

It uses a materially different denormalized source shape and isolated
`build/fictional-adopter/` state. It is an example, not a required hospital
source schema or a second reference implementation.

Generated Platform source is extracted under `.rrp/platform/` after exact
archive validation. It remains inspectable. The top-level environment is the
only routinely active `renv` project; delegated Platform processes use that
library with `Rscript --vanilla` and never activate the embedded project.

Recipient changes are allowed only under the license eventually supplied by an
authorized release and may move the local tree outside CentralStatz's validated
baseline. Iteration 11.4 provides no automatic updater, migration, remote Git
repository, commit, push, publication, deployment, production support claim,
or clinical authorization.
