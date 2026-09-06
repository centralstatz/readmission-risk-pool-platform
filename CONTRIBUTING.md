# Contributing

Use a GitHub issue or discussion for proposals and questions. Security-sensitive
reports must follow [SECURITY.md](SECURITY.md), not a public issue.

Pull requests should be focused, explain the user or architectural need, update
tests and documentation with behavior, and pass the documented development and
checkpoint validation. Changes must remain compatible with True North and the
established contracts; maintainers decide whether and when a contribution is
accepted.

Contributions use Developer Certificate of Origin 1.1 certification. Sign every
commit with:

```text
Signed-off-by: Name <email>
```

The usual workflow is `git commit -s`. By signing off, you certify that you have
the right to submit the contribution under the project's license according to
the [Developer Certificate of Origin 1.1](https://developercertificate.org/).
No contributor license agreement is currently required.

Run before requesting review:

```sh
Rscript operations/validate-documentation.R
Rscript operations/validate.R --mode development
Rscript operations/validate.R --mode checkpoint
```
