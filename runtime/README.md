# `rrpruntime`

`rrpruntime` is the focused internal R package for implementation-neutral
computation after canonical admission. Iteration 4.1 owns only:

- the normalized admitted-canonical input interface;
- runtime-contract support checks;
- temporal eligibility;
- availability-filtered minimal episode state; and
- provider-neutral estimand requests.

It does not discover the repository root or read files under `contracts/`.
Operations load language-neutral specifications explicitly and inject them.
The package does not contain source generation/mapping, a provider, an estimate
record, persistence, products, application code, deployment, Git behavior, or
observability.

The first estimand asks what should be estimated; no risk is estimated yet.
