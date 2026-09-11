# Hospital Implementation v0.1.0 clean-room adoption assessment

## Status and authority

**Status:** retained external acceptance evidence. Its forward implications are
synthesized in the current
[Platform Architecture](../architecture/platform-architecture.md).

## Overall verdict

**FAIL — the released Hospital Implementation does not provide a viable
external adoption path as released.**

The embedded Platform, fictional acceptance flows, canonical producer
contract, low-level provider registry, products, app, and reduced application
artifact are technically sound. The failure is at the hospital product
boundary: the release validates only while its editable implementation scaffold
is unchanged. Any hospital implementation edit invalidates the closed
distribution inventory before the hospital-owned producer can run. The
hospital operations also fix execution to the reference provider, and the
runtime accepts only the one Platform estimand.

This assessment did not alter v0.1.0 history or implementation, or the
maintained Hospital repository. All adopter data, code, restored dependencies,
and generated state were isolated under a temporary directory. Only this
assessment document and its index entry were added to the current Platform
development branch.

## Release and test posture

The public Hospital repository was cloned at exact annotated tag `v0.1.0`:

- repository: `centralstatz/readmission-risk-pool-hospital-implementation`;
- commit: `62d374292f51c69a6c97cf247b64ec49c05ba858`;
- declared distribution:
  `hospital_implementation_distribution::7b8aae7f0cbb0a68f45fe215a0d77466ded7074142a7340a3dddf73f43112f66`;
- embedded Platform candidate:
  `platform_release_candidate::6037e0117bd920d7fd4e951e96ba14ba01f159c7f99c99bf0989eab28237736f`;
- embedded archive SHA-256:
  `01eb816252ac181385b5b658bdd528e35481fa7ab4176646047bbd9029a7bb27`.

The assessment used R 4.4.1 on arm64 macOS. An initial CRAN failure was caused
by the assessment sandbox's network restriction; retrying with network access
restored the exact lock successfully and that environmental event is excluded
from the product verdict. A later concurrent diagnostic invocation contended
for an `renv` startup lock and was stopped; only uncontended terminal results
below are treated as evidence.

## Tested lifecycle

1. Cloned the exact public tag into an unrelated temporary root and confirmed
   its commit and tag.
2. Followed the released README's setup and validation commands.
3. Restored the top-level `renv` lock.
4. Exercised distribution validation, initialization, doctor, reference
   acceptance, and the shipped fictional-adopter proof.
5. Created two new fictional hospital CSV extracts: an encounter export and a
   separately shaped vendor-risk feed with local identifiers, names, percent
   values, and timestamps unlike the canonical tables and shipped example.
6. Replaced only the advertised `implementation/` scaffold with local source
   validation, identifier normalization, probability conversion, canonical
   episode/baseline mapping, producer declaration, and trusted composition.
7. Added a deterministic custom provider and a seven-day cumulative-risk
   estimand declaration under the disposable implementation tree.
8. Ran the released hospital producer, platform, product, and artifact
   operations.
9. Where those operations failed before loading adopter code, used a labeled
   diagnostic bypass against the already validated extracted Platform to test
   the underlying contracts without changing Platform source.

The bypass admitted three mapped episodes and three baseline-risk rows, built
three states and requests, and registered/executed the custom provider for
three conforming estimates (`0.306`, `0.194`, and `0.41`). It then persisted the
custom-source run through the fixed reference provider, materialized three
product rows, constructed the app, and produced a valid reduced application
artifact. The artifact truthfully recorded
`reference.transparent-readmission-hazard@0.1.0`, not the custom provider.

## Results by capability

| Capability | Result | Evidence |
|---|---|---|
| Release acquisition | Partial | Exact tag/commit acquisition works, but the release README provides no exact clone/tag command and describes the public release as unpublished. |
| Hospital workspace/setup | Fail | `renv::restore()` succeeds, but creates local `renv` state that the released closed-inventory validators reject. |
| Custom source-data mapping | Fail at product boundary | The mapping passes generic producer/canonical admission through a diagnostic bypass; the supported hospital operation rejects the modified scaffold before executing it. |
| Canonical-model validation | Pass underneath | Three independent episode and baseline records passed unchanged Platform admission. This required bypassing the Hospital distribution gate. |
| Custom model provider | Partial | Public `rrpruntime` registration/execution accepts the custom provider, but no hospital configuration/composition path supplies it to the operational cycle. |
| Custom estimand | Fail | Runtime validation rejects the new identity and semantics with `unsupported_runtime_contract` and `unsupported_estimand_semantics`. |
| Implementation validation | Fail | `operations/validate-producer.R` stops on `distribution_inventory_mismatch`/`distribution_member_mismatch` after intended recipient edits. |
| Deploy artifact build | Fail through hospital interface | Hospital product/artifact wrappers stop at the same inventory gate. Direct embedded-Platform operations produced and validated an artifact only as an insider diagnostic. |
| Runtime/smoke test | Partial | Reference and shipped fictional-adopter flows pass. Custom source reaches products/app/artifact only through internal operations and only with the reference provider/fixed estimand. |

## Findings

### 1. Machinery defects

1. **Immutable inventory conflicts with the editable scaffold.** The
   distribution manifest checksums `implementation/` and requires the closed
   generated inventory on every call to `rrp_hospital_managed_platform()`.
   Editing the provided producer files or adding source/provider files causes
   every supported hospital operation to stop before trusted composition.
2. **Published-clone Git validation uses the pre-publication contract.**
   `validate-git-realization.R` requires zero commits, zero remotes, a fully
   staged initial addition, and no shallow metadata. Those invariants cannot
   hold in a normal clone of the published repository.
3. **Setup creates state rejected by validation.** On a clean clone,
   `.Rprofile` bootstraps `renv`; the documented restore creates
   `renv/.gitignore`, the project library, symlinks, and transient staging.
   `validate-git-realization.R` reports these as unexpected/linked content, and
   `validate-distribution.R` rejects at least `renv/.gitignore` as outside its
   closed inventory.

### 2. Missing or weak extension interfaces

1. The provider registry is a usable low-level API, but the hospital cycle
   calls `rrp_run_reference_history()`, which constructs and selects the
   transparent reference provider internally. There is no hospital-owned
   provider declaration, selection configuration, trusted registration seam,
   or operation that carries the custom provider into history/products.
2. The runtime contract set and implementation hard-code
   `platform.readmission-next-day-conditional-hazard@0.1.0`. A second estimand
   cannot be registered or selected; changing identity or quantity semantics is
   rejected by design.

### 3. Release/package issues

The released README, changelog, distribution manifest, and embedded Platform
content retain candidate-era language such as `not_published`,
`release_candidate_not_published`, “Iteration 11.4 proof,” and “zero commits,
zero remotes.” The embedded archive is also named `0.1.0-candidate`. These
statements are provenance from the immutable candidate, but they are presented
as current adopter instructions and contradict the actual public release.

### 4. Documentation and discoverability issues

- There is no single hospital implementation guide from clone through local
  source mapping, provider selection, validation, products, and deployment
  artifact.
- The README points to a very short fictional example and an intentionally
  failing scaffold but does not explain the canonical record shapes, callable
  result construction, trusted registration edits, or how to test local source
  failures.
- Provider replacement is described architecturally, not as an executable
  Hospital Implementation procedure.
- Custom estimands are not documented as unsupported; the architecture's
  general language suggests a broader extension surface than v0.1.0 implements.
- Doctor recovery messages name embedded Platform reference commands instead
  of the top-level hospital wrappers.

### 5. Internal-development language exposed to adopters

The public Hospital product prominently exposes Phase/Iteration numbers,
candidate/proof status, maintainer Git-realization invariants, sibling-
repository history, internal reference-operation names, and release-preparation
boundaries. None is needed to carry out a hospital implementation, and several
items actively misdescribe the published checkout.

### 6. Optional usability improvements

- Give dependency restoration and validation explicit stage/progress output
  and concise summaries rather than repeated per-symlink diagnostics.
- Provide a tiny, complete hospital-owned example alongside a blank scaffold,
  with expected outputs and deliberate failure exercises.
- Make product and artifact commands accept a named local run/configuration
  instead of fixed IDs embedded in thin wrappers.

## Insider-knowledge dependencies

The following steps were not reasonably discoverable as a new hospital user
from the Hospital README alone and are not counted as passing product behavior:

- suppressing project profile activation and injecting an already-restored
  library with `R_PROFILE_USER`/`R_LIBS` to separate package validation from
  locally generated `renv` state;
- locating the identity-derived `.rrp/platform/<digest>` extraction directly;
- reading embedded Platform architecture, contracts, package documentation,
  tests, and operation source to construct the producer result;
- invoking `rrp_execute_canonical_producer()`,
  `rrp_run_selected_platform_cycle()`, and direct embedded Platform product/app
  scripts instead of the hospital operations;
- manually creating a provider registry and calling
  `rrpruntime::execute_provider()` outside the operational pipeline; and
- replacing the injected runtime estimand document solely to prove the hard
  rejection behavior.

Phase/Iteration history known from Platform development was deliberately not
used to choose the adopter path; where the release itself forced that language
on the reader, it is recorded above as a finding.

## Recommended 0.2.0 implications

The smallest coherent 0.2.0 productization increment is:

1. Separate immutable CentralStatz release verification from mutable
   recipient implementation validation. Preserve exact embedded Platform
   verification, but exclude or explicitly re-baseline hospital-owned
   `implementation/` and ordinary ignored runtime/environment state.
2. Replace or re-scope the pristine Git-realization validator in the published
   product with a validator that understands a committed clone with an origin;
   retain the zero-commit/zero-remote validator only in maintainer generation.
3. Add one release-native hospital guide and first-run command sequence,
   including exact tag acquisition, supported R/OS scope, restore,
   initialization, editable boundaries, validation, run, product, artifact,
   recovery, and expected outputs. Remove candidate-era claims from generated
   recipient-facing text while retaining provenance in manifests where needed.
4. Add a trusted hospital provider composition seam: declaration, callable,
   exact selection, conformance operation, and injection into the same
   persistence/product cycle. Do not use dynamic loading.
5. Make an explicit product decision for estimands. Either scope 0.2.0 clearly
   to the one fixed estimand, or add a versioned estimand registry/selection and
   generalized request construction before claiming custom-estimand support.
6. Add a clean-room acceptance test that starts from the generated public form,
   restores dependencies, edits only documented hospital-owned files, runs a
   non-packaged source mapping and selected provider, and builds/validates the
   final application artifact without source-repository knowledge.

The underlying interfaces do not need wholesale redesign. Canonical admission,
provider execution, persistence, products, app construction, and artifact
validation all worked when reached. The priority is to make the Hospital
Implementation's mutable ownership boundary and operational composition match
those interfaces truthfully.
