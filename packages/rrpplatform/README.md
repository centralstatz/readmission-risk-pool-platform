# `rrpplatform`

`rrpplatform` is the main internal implementation package within RRP software.
It is versioned independently from the RRP product. It owns the narrow
installed-resource pair `rrp_open_resource_catalog(explicit_distribution_root)`
and `rrp_resource_path(validated_catalog, resource_id)`, plus its one-way
dependency on `rrpruntime`.

The package is not an installation mechanism, operator interface, project API,
or generic analytical framework. The caller supplies the distribution root;
the package never discovers or selects one and never consults CWD, Git,
environment variables, a source checkout, or repository paths. Stage 3 owns
installed-root/version selection, Stage 4 owns project context, 2.C/2.D own
consumer migration, and 2.E owns construction and integrity of the actual
closed distribution. Current status remains `development_unpublished`.
