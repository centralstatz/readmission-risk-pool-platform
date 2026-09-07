# Support

Community support is best effort through the authoritative repository's GitHub
issues and discussions. Please provide reproducible, privacy-safe diagnostics;
never include PHI, credentials, private mappings, or connection strings.

There is no support or response-time SLA. The software is provided without
warranty as stated in the Apache License 2.0. CentralStatz professional services
are separate and optional; use of the software creates no consulting, support,
or service entitlement.

## v0.1.0 support evidence

- Tested locally: R 4.4.1 on `aarch64-apple-darwin20` / Darwin 25.5.0.
- Declared release line: R 4.4.x, restored from the shipped `renv.lock` with
  `renv::restore()`.
- Tested by the release-commit and tag workflows: R 4.4.x on the current
  GitHub-hosted Ubuntu runner. Both publication-triggered runs completed
  successfully: [run 34065771044](https://github.com/centralstatz/readmission-risk-pool-platform/actions/runs/34065771044)
  and [run 34065766370](https://github.com/centralstatz/readmission-risk-pool-platform/actions/runs/34065766370).
- Not tested for v0.1.0: Windows and other R minor lines.

First-time restoration may require network access and system libraries needed
to build or install locked R packages. Release archives do not bundle those
third-party packages.
