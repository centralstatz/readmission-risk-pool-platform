# RRP software distribution guide

An RRP software distribution is a closed, version-specific payload assembled
from positively declared RRP source. It contains the two internal package
archives, the version-specific `rrp` launcher, the exact installed-resource
projection, license and product information, a target-keyed third-party
dependency specification, a manifest, a SHA-256 inventory, and its own
normalized identity evidence and standalone verifier.

After extracting an archive, verify it before any later installation work:

```sh
Rscript --vanilla verify-distribution.R .
```

Verification checks exact file closure, roles and SHA-256 digests, package and
resource identities, dependency metadata, safe paths, and required legal and
human documentation. It requires R 4.4 or later and either `sha256sum` or
`shasum`; it does not install, repair, or fetch anything.

Third-party packages are deliberately not bundled. Installation uses the exact
dependency specification with the matching explicitly supplied HTTPS package
repository and a network connection. Offline installation is not promised.
After verification, follow the installed-catalog Installation Guide or run:

```sh
Rscript --vanilla install.R --repository HTTPS_URL
```

The bootstrap and `rrp software install PATH --repository HTTPS_URL` share one
installation engine. Both create an immutable per-user version with its own
private library and do not activate it.

The distribution contains no Git metadata, development tests or maintainer
scripts, hospital project, patient data, project state, products, deployment
artifact, or transitive third-party package archive.
