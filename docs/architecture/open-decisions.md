# Open decisions

## Purpose

This list records maintainer decisions that affect product or architecture.
They should be resolved when the named phase needs them. They do not block
earlier work unless stated.

| Decision | Why it matters | Needed by | Current direction |
|---|---|---:|---|
| Open-source license and content/asset licensing | Determines permission to distribute and reuse source/assets | Public release; preferably start in Phase 0 | Human/legal decision; Phase 0 explicitly authorizes no public release and supplies no license |
| Initial schema/specification format | Affects readable and machine-validated contracts | Resolved in Phase 1 | YAML is the human-authored source; executable R validation uses the independently locked `yaml` dependency |
| Pre-1.0 compatibility policy | Determines when draft interfaces may change and how migrations are stated | Resolved in Phase 1 | Patch changes are narrowly compatible; semantic or requiredness changes increment the minor line and require explicit consumer support |
| Generic canonical bundle, registration, and dependency model | Prevents representation and status mechanics from being invented by individual domains | Resolved in Phase 2.1 | One bundle instance registers independently versioned domains/capabilities with required, conditional, or optional classes and simple acyclic typed dependencies |
| First canonical clinical-domain capability profile | Determines actual required, conditional, optional, and unavailable clinical inputs | Resolved in Phase 2.2 | Required discharge episode plus optional baseline risk and optional episode event; available optional domains may have zero rows, while unavailable/unsupported domains have no instance |
| Initial canonical controlled vocabularies | Prevents local baseline/event values from silently changing portable meaning | Resolved in Phase 2.2 | Three exclusive baseline value types and six bounded event types; new platform values require a new minor line and mapping/conformance evidence |
| Canonical additional-field and extension policy | Determines portability versus local flexibility at the public handoff | Resolved in Phase 2.2 | Initial clinical records reject unknown fields; source-specific columns remain implementation-owned and a formal extension mechanism is deferred until justified |
| Canonical occurrence/availability declarations | Establishes future-information conformance without forcing universal field names | Resolved in Phase 2.1 | Each domain identifies its occurrence/effective and availability/recorded roles and may prohibit availability before occurrence |
| Partial synthetic/local composition | Affects progressive source replacement and cross-domain coherence | Phase 2 or later evidence | Do not support silently; complete conforming implementations remain the safe default |
| Distribution of prebuilt synthetic inputs/products | Affects time-to-first-use and repository size | Phase 3/5 | Generation must be reproducible; a small prebuilt slice may complement it |
| First default estimand(s) | Own horizon, event, terminal, output, and coherence semantics | Phase 4 | Remaining-window and near-term risk are candidates, not approved specifications |
| Provider trust and registration boundary | Controls arbitrary code execution and local extensions | Phase 4 | Start controlled and explicit; support shipped and governed local providers only as approved |
| First provider runtime | Affects package/API scope | Phase 4 | R first is likely; keep conceptual contract language-neutral |
| Reference local persistence technology | Realizes ports and the first working slice | Phase 5 | Choose the simplest adapter satisfying append/idempotency tests; not a production mandate |
| Idempotency, correction, invalidation, and restatement semantics | Determines operational truth | Initial form Phase 5; complete Phase 6 | Append by default; never silently overwrite history |
| Default logical product suite | Determines supplied app and compatibility surface | Phase 5 provisional; Phase 6 stable | Start narrow; old eight-product suite is evidence, not a requirement |
| Retained decision and lineage records | Determines what has independent historical meaning | Phase 6 | Persist only records that need operational/governance attribution |
| Product materialization versus query | Affects product adapters and freshness semantics | Phase 6 | Keep logical contracts independent of either approach |
| Role of `readmit` and a CLI | Determines optional control surfaces | After Phase 7 operations stabilize | Optional only; must invoke tested operations |
| Connect deployment ownership and publication destination | Governs safe replacement, markers, commit, and push | Phase 8 | Fully generated is safest for the reference; explicit approval required |
| Observability event schema, default verbosity, routing, and retention | Affects privacy and operations | Vocabulary Phase 1; realization Phase 9 | Safe structured events, bounded local defaults, deployment-owned sinks |
| Extension repository strategy | Determines where advanced providers and integrations live | Phase 10/11 | Core, companion, adopter-local, and private research are all possible |
| CentralStatz branding and stewardship policy | Affects public docs and assets without gating core operation | Phase 11 | Visible stewardship is compatible with authentic open source |
| Supported R/OS matrix and release cadence | Defines support commitment and release validation | Phase 11 | Decide from tested environments, not aspiration |
| Contribution, support, security, and disclosure policies | Required for governed public collaboration | Phase 11 | Human decisions informed by stabilized operations and maintainer capacity |

## Decision-record expectation

When a decision becomes material, record its context, chosen option,
alternatives, consequences, and affected contracts or phases in the
[implementation record](platform-implementation-record.md) or a linked decision
record. Update this list rather than leaving a resolved question open.
