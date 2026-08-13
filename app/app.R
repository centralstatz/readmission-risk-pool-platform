# Deployment-neutral application entry point. A launcher or later deployment
# adapter must inject an already validated product-access object.

application_root <- normalizePath(dirname(sys.frame(1L)$ofile), mustWork = TRUE)
for (file in c("app-init.R", "view-models.R", "app.R")) {
  sys.source(file.path(application_root, "R", file), envir = environment())
}
if (!exists("rrp_application_product_access", inherits = TRUE)) stop(
  "Inject `rrp_application_product_access` before loading app/app.R.",
  call. = FALSE
)
rrp_create_reference_app(get("rrp_application_product_access", inherits = TRUE))
