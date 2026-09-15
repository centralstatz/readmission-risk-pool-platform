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

No repository validator exists yet. Use the documentary review described by
the implementation guide until Increment 1.C supplies the local check. These
checks do not establish package, runtime, clinical, installation, deployment,
or release validity.

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
