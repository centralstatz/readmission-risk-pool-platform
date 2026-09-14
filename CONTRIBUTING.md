# Contributing

Use a GitHub issue or discussion for proposals and questions. Security-sensitive
reports must follow [SECURITY.md](SECURITY.md), not a public issue.

Pull requests should be focused, explain the user or architectural need, update
tests and documentation with behavior, and pass the proportional validation
owned by the change. Changes must conform to [True North](docs/vision/platform-true-north.md),
the current [Platform Architecture](docs/architecture/platform-architecture.md),
and the [RRP 1.0.0 Implementation Plan](docs/architecture/platform-implementation-plan.md).
[Validation Governance](docs/development/validation-governance.md) selects
current evidence; the [Transition Ledger](docs/development/transition-ledger.md)
controls coexistence and retirement. Maintainers decide whether and when a
contribution is accepted.

Contributions use Developer Certificate of Origin 1.1 certification. Sign every
commit with:

```text
Signed-off-by: Name <email>
```

The usual workflow is `git commit -s`. By signing off, you certify that you have
the right to submit the contribution under the project's license according to
the [Developer Certificate of Origin 1.1](https://developercertificate.org/).
No contributor license agreement is currently required.

For ordinary work, run before requesting review:

```sh
Rscript operations/validate.R --profile source-changed
```

Use `source-fast`, a direct eligible validator, or `ci-active` when that is the
intended claim. Run broader lifecycle or explicit legacy evidence only when the
changed boundary or an accepted gate requires it; the old `--mode` commands are
deprecated compatibility aliases, not the forward contribution workflow. See
the [validation operation](docs/operations/validation.md) for exact commands
and recovery.
