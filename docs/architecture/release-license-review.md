# v0.1.0 Apache-2.0 compatibility review

## Scope and conclusion

This is the bounded engineering review required before the first source release;
it is not legal advice. The reviewed release unit is the tracked Platform source
tree and the generated Hospital Implementation that embeds an exact Platform
candidate archive.

No concrete incompatibility preventing release of repository-authored source
under Apache License 2.0 was found. The standard Apache-2.0 text is installed in
`LICENSE`, and `NOTICE` records CentralStatz stewardship and copyright.

## Evidence reviewed

- `renv.lock` declares 41 restored R dependencies. Installed DESCRIPTION
  metadata was inspected for the locked versions.
- Direct executable dependencies are YAML, DBI, DuckDB, jsonlite, Shiny, and
  rsconnect. Their package licenses remain their own: BSD-3-Clause, LGPL-2.1-or-
  later, MIT, MIT, GPL-3, and GPL-2 respectively.
- Transitive metadata includes MIT, BSD-2-Clause, LGPL, GPL-2, GPL-3, and
  GPL-2-or-later packages. These packages are acquired by `renv::restore()`;
  their source or binaries are not copied into either release archive.
- `rrpruntime` is repository-authored, depends only on R >= 4.1.0, and now
  declares Apache License (>= 2).
- The tracked source tree contains no bundled image, font, compiled binary,
  vendored dependency tree, or third-party template asset. The Hospital
  `.gitignore` template is repository-authored text.
- The sibling reference repository supplied architectural evidence only. The
  implementation record and reconciliation document record clean rewrites and
  principle-level adaptation; no sibling source is shipped or required.
- Generated manifests, checksums, fictional fixtures, and the fictional adopter
  example are repository-authored. Generated releases preserve `LICENSE`,
  `NOTICE`, and this dependency distinction.

Dependency use is not copied/bundled third-party material. Restoring and using a
dependency does not relicense this repository's source; recipients remain
responsible for each dependency's terms. If a future release vendors code or
assets, changes dependency delivery, or adds material with separate attribution,
this review must be updated before release.

## Result

`PASS` for Apache-2.0 release preparation based on the inspected repository and
available installed package metadata. No license is changed for third-party
dependencies, and no claim of legal certainty is made beyond this evidence.
