# `rrpruntime`

`rrpruntime` is the focused internal R package for implementation-neutral
computation after canonical admission. Phases 4 and 5.1 currently own:

- the normalized admitted-canonical input interface;
- runtime-contract support checks;
- temporal eligibility;
- availability-filtered minimal episode state; and
- provider-neutral estimand requests;
- language-neutral provider-contract conformance;
- controlled in-memory registration and exact selection;
- compatibility evaluation and isolated trusted-adapter execution;
- structured execution results; and
- standardized accepted estimate records;
- immutable operational run and invalidation records;
- atomic completed-run batch conformance; and
- backend-independent append/read persistence ports.

It does not discover the repository root or read files under `contracts/`.
Operations load language-neutral specifications explicitly and inject them.
The package contains the shipped transparent deterministic provider adapter as
a visibly nonclinical software-conformance realization. Operations inject its
declaration and explicitly register the trusted adapter. Ordinary data
configuration cannot load code or paths, and generic runtime does not depend
on the reference provider identity.

The package does not contain source generation/mapping, a durable storage
adapter, retry scheduling, replay, priority/decision logic, products,
application code, deployment, Git behavior, or observability. The test-only
in-memory adapter is not package code or a supported operation. An accepted
estimate is a methodological result; it becomes operational history only when
accepted in an atomic terminal run batch.
