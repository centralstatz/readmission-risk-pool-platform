# Contributing

Use a GitHub issue or discussion for proposals and questions. Security-
sensitive reports must follow [SECURITY.md](SECURITY.md), not a public issue.

Before proposing a change, read the active authority in order:

1. [Platform True North](docs/platform-true-north.md);
2. [Platform Architecture](docs/platform-architecture.md);
3. [Implementation Plan](docs/platform-implementation-plan.md); and
4. [Implementation Record](docs/platform-implementation-record.md).

Contributions should be focused, explain the user or architectural need, stay
within the currently accepted increment, update documentation and evidence with
behavior, and avoid speculative source or directory scaffolding. Historical
implementation may inform current work but does not override the active
authority or justify restoring obsolete repository structure.

No repository validator exists yet. Until the planned minimal repository
validation is implemented, contributors should review links, identity and
licensing consistency, unintended generated or sensitive content, and the
working-tree diff directly. Do not claim package, runtime, clinical,
installation, deployment, or release validation from these checks.

Contributions use Developer Certificate of Origin 1.1 certification. Sign every
commit with:

```text
Signed-off-by: Name <email>
```

The usual workflow is `git commit -s`. By signing off, you certify that you have
the right to submit the contribution under the project's license according to
the [Developer Certificate of Origin 1.1](https://developercertificate.org/).
No contributor license agreement is currently required.
