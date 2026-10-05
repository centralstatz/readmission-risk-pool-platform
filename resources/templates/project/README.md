# RRP hospital project

This is a trusted, editable independent RRP project. RRP executes project R
code; review and govern it as executable hospital code.

The six standard files are:

- `rrp-project.dcf` — project identity, selected producer/provider, extension
  library, and state paths;
- `rrp-authoring.dcf` — implementation, mapping, optional model, and exact
  extension-package/version metadata;
- `R/produce-canonical.R` — normal hospital source access and canonical mapping;
- `R/calculate-risk.R` — normal hospital model or engine invocation;
- `R/register.R` — generated thin RRP wiring, normally left unchanged; and
- `README.md` — this orientation.

The initializer also supplies `_brand.yml` and the contained
`assets/project-logo.png`. They are declarative presentation resources for the
installed RRP application, not additional authoring callables or application
source. Edit the standard display name, primary color, and logo deliberately;
removing `_brand.yml` makes the application use RRP defaults.

Normally, hospital logic changes only the two callable files. Declare every
installed project extension package and exact version in `rrp-authoring.dcf`;
RRP does not install dependencies. Advanced projects may deliberately replace
`R/register.R` and own the complete raw registration contracts.

Detailed version-matched guidance is installed as resources. Given the
explicit installed software root:

```r
catalog <- rrpplatform::rrp_open_resource_catalog("/absolute/path/to/rrp")
rrpplatform::rrp_resource_path(
  catalog, "rrp.documentation.project-authoring-guide"
)
rrpplatform::rrp_resource_path(
  catalog, "rrp.documentation.provider-request-reference"
)
```

The project contains no credentials or patient data by default.
