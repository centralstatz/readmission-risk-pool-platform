# RRP software resource boundary

`resource-catalog.yml` is the maintainer/source authority for current non-code
resources intended for the future RRP software distribution. Its schema and
focused validator require stable logical IDs and exact repository-source to
future distribution-output mappings. Directory entries, globs, discovery
rules, and ignore-list subtraction do not add resources.

Status is `development_unpublished`. This catalog does not constitute an
installed or supported distribution, a clinical deployment, a hospital
project, or the final RRP 1.0 release payload. It provides no installation,
activation, project, launcher, or resource-resolution operation.

Current daily-hazard contracts and dependent product resources retain their
existing identities and are explicitly transitional until Stage 5. Synthetic
entries are fictional, nonclinical reference material; they are not a real
hospital project or the Stage 4 project template.

The schema also declares the deterministic installed-catalog projection. That
projection omits maintainer-only source paths and is placed with the schema at
their declared `resources/` locations in a distribution-shaped root. Given
that explicit caller-supplied root, `rrpplatform::rrp_open_resource_catalog()`
validates the complete governed inventory and `rrpplatform::rrp_resource_path()`
resolves one exact logical resource ID. Neither function discovers a root,
selects an installed version, consults Git or the working directory, or falls
back to source paths.

This remains a `development_unpublished` access boundary, not an installed
software distribution. Stage 3 owns installed-root/version selection, Stage 4
owns independent project context, and 2.C/2.D own migration of current source
consumers. Increment 2.E owns the source manifest, actual closed distribution
builder, `DISTRIBUTION.yml`, SHA-256/content inventory, dependency closure, and
target realization.
