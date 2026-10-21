app_root <- normalizePath(".", winslash = "/", mustWork = TRUE)
for (file in c(
  "application-core.R", "product-loader.R", "application-ui.R",
  "application-server.R", "managed-loader.R"
)) {
  sys.source(file.path(app_root, "R", file), envir = environment(), chdir = FALSE)
}
model <- rrp_standalone_application_model(app_root)
rrp_application_shiny(model)
