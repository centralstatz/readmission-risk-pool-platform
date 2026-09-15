# RRP 1.0.0 implementation record

## Status

This record begins with the clean RRP 1.0 implementation baseline. The active
tree intentionally began with only the accepted Platform True North and
Platform Architecture; no RRP 1.0 software was implemented at that point.

The published `v0.1.0` implementation and the superseded pre-reset 1.0
development line remain preserved in Git history and are not reproduced here.
They may be inspected for selective reuse, but they are not current authority.

## Clean implementation baseline

- **Target generation:** RRP 1.0.0
- **Clean-reset revision:** `815fcc2`
- **Why authority:** [Platform True North](platform-true-north.md)
- **What authority:** [Platform Architecture](platform-architecture.md)
- **Construction authority:** [Implementation Plan](platform-implementation-plan.md)
- **Historical reference release:** immutable tag `v0.1.0`
- **Development strategy:** clean-forward construction with selective,
  stage-local reuse of proven historical implementation and tests
- **Initial capability:** documentation authority only; no installed software,
  project, runtime, history, product, app, CLI, or deployment exists

## Planning foundation — 2026-09-15

The two surviving authorities were read in full and minimally corrected for
the post-reset time: nonexistent current plans, records, assessments,
transition state, old source, development-version metadata, and obsolete
documentation paths are no longer implied to exist. Their substantive RRP 1.0
product and architecture decisions were preserved.

Bounded Git reconnaissance inspected the `v0.1.0` tree and the later pre-reset
package/resource work. It confirmed credible reuse candidates in canonical
validation, provider execution, temporal runtime primitives, operational
history and DuckDB, structured results, products/YAML, the Shiny app,
artifact/integrity machinery, the fictional source, and invariant-focused
tests. It also confirmed that repository-root execution, Phase chronology,
Hospital-repository delivery, temporary runtime installation, daily-hazard
public semantics, and coexistence-only compatibility machinery do not belong
in the clean design.

The high-level roadmap was created from the cleaned authorities. Only Stage 1
was decomposed. No historical source was restored and no Stage 1 functionality,
package, test, validation operation, CI, dependency environment, CLI, project,
resource catalog, application, or deployment machinery was created.

Review before Stage 1 implementation simplified its sequence to three
increments. Stage 1 validation is now a small local repository check; hosted CI
is deferred until Stage 2 has executable package build/check/test behavior.
Stage acceptance and reconciliation remain the normal progressive-planning
lifecycle after Increment 1.C rather than a separate implementation increment.

## Stage 1 — Repository and development foundation

### Increment 1.A — Product identity and public repository essentials (complete, 2026-09-15)

Increment 1.A established `RRP.yml` as the single machine-readable product-
development identity: `readmission-risk-pool-platform` at `1.0.0-dev`, with
status `not_released`. The new README describes the intended product, current
documentation-only capability, authority order, historical boundary, safety
limits, contribution path, and Apache-2.0 license without advertising an
installation or released 1.0 product.

The standard Apache-2.0 `LICENSE`, CentralStatz `NOTICE`, and small
`.editorconfig` were reused byte-for-byte from `v0.1.0` after reviewing the
historical license assessment, repository origin, authorship history, current
year, and absence of new bundled third-party material. `SECURITY.md`,
`SUPPORT.md`, and `CONTRIBUTING.md` were adapted to the unreleased,
non-executable clean line. The old release-specific README, support matrix,
validation commands, broad ignore rules, `RELEASE.yml`, `LICENSE-STATUS.md`,
and changelog were rejected as temporally false or premature. The manually
added `.gitignore` retains only `.DS_Store`; its missing final newline was
normalized without adding speculative rules.

Static review confirmed the exact three-field YAML identity, byte-identical
license and notice reuse, complete local Markdown links, the intended 13-file
tree, no tracked symbolic links, text-format hygiene, and a clean
`git diff --check`. Public documentation consistently states that 1.0 is
unreleased and no package or operational validation is claimed.

**Current implementation state:** Increment 1.A complete; Stage 1 in progress.
There is still no installable software, package, project, clinical contract,
runtime, history, product, application, CLI, validator, CI, dependency
environment, or deployment capability.

**Next task:** implement only Increment 1.B — Human development and ownership
rules.
