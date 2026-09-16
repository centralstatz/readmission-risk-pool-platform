# Contributing

Use a GitHub issue or discussion for proposals and questions. Security-
sensitive reports must follow [SECURITY.md](SECURITY.md), not a public issue.

## Before contributing

Read the active authority and actual implementation state in the order shown in
the [README](README.md#governing-documents). Then follow the
[RRP 1.0 implementation guidance](docs/implementation-guidance.md), which documents
the progressive working method, historical-reuse process, current source
ownership, implementation conventions, dependency boundaries, privacy rules,
and proportionate evidence expectations.

Contributions should be focused, explain the user or architectural need, stay
within the currently accepted increment, and update documentation and evidence
with behavior. Do not create later-stage or empty directory scaffolding.

Before submitting a change, run the local repository-foundation validator from
the repository root:

```sh
Rscript --vanilla tools/validate-repository.R
```

Its human-readable result and process exit status cover only the current
repository-structure and static-policy claims documented by the implementation
guide. Passing does not establish package, runtime, clinical, installation,
deployment, or release validity, and automated screening does not replace
privacy review.

For the current two-package foundation, also run:

```sh
Rscript --vanilla tools/validate-packages.R
```

This package operation owns metadata, dependency/API boundary, build, isolated
install/load, and package-native check evidence. It does not establish product
runtime or installed-distribution behavior.

## Sign off contributions

Contributions use Developer Certificate of Origin 1.1 certification. Sign every
commit with:

```text
Signed-off-by: Name <email>
```

The usual workflow is `git commit -s`. By signing off, you certify that you have
the right to submit the contribution under the project's license according to
the [Developer Certificate of Origin 1.1](https://developercertificate.org/).
No contributor license agreement is currently required.
