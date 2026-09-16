# `rrpplatform`

`rrpplatform` is the main internal implementation package within RRP software.
Its package version is `0.1.0.9000`, independently of `rrpruntime` version
`0.3.0.9000` and the RRP product development identity `1.0.0-dev`.

At Stage 2 Increment 2.B, the package is deliberately behavior-free. It imports
the `rrpruntime` namespace to establish the accepted one-way internal-package
dependency and exports no callable API. It does not yet own installed resources,
operations, projects, clinical contracts, orchestration, products, applications,
installation, or deployment.

The package is not the RRP product, installer, command-line interface, public
project API, or a separately marketed package.
