#!/usr/bin/env Rscript

file_argument <- grep("^--file=", commandArgs(trailingOnly = FALSE), value = TRUE)
script_path <- normalizePath(sub("^--file=", "", file_argument[[1L]]), mustWork = TRUE)
repository_root <- normalizePath(file.path(dirname(script_path), ".."), mustWork = TRUE)
for (file in c(
  "validation-result.R", "conformance-result.R", "specification-validation.R",
  "product-operation.R", "product-materialization-operation.R"
)) source(file.path(repository_root, "operations", "lib", file))
rrp_load_product_layer(repository_root)
rrp_load_yaml_product_adapter(repository_root)
rrp_load_reference_app(repository_root)

arguments <- commandArgs(trailingOnly = TRUE)
store_path <- file.path(repository_root, "build", "reference-products")
validate_only <- FALSE
host <- "127.0.0.1"
port <- 3838L
while (length(arguments) > 0L) {
  if (length(arguments) >= 2L && identical(arguments[[1L]], "--products")) {
    store_path <- arguments[[2L]]
    arguments <- arguments[-c(1L, 2L)]
  } else if (identical(arguments[[1L]], "--validate-only")) {
    validate_only <- TRUE
    arguments <- arguments[-1L]
  } else if (length(arguments) >= 2L && identical(arguments[[1L]], "--host")) {
    host <- arguments[[2L]]
    arguments <- arguments[-c(1L, 2L)]
  } else if (length(arguments) >= 2L && identical(arguments[[1L]], "--port")) {
    port <- suppressWarnings(as.integer(arguments[[2L]]))
    arguments <- arguments[-c(1L, 2L)]
  } else {
    message(paste(
      "Usage: Rscript operations/launch-reference-app.R",
      "[--products PATH] [--validate-only] [--host HOST] [--port PORT]"
    ))
    quit(save = "no", status = 2L, runLast = FALSE)
  }
}
if (!grepl("^(/|[A-Za-z]:[/\\\\])", store_path)) {
  store_path <- file.path(repository_root, store_path)
}
if (is.na(port) || port < 1L || port > 65535L) {
  message("Port must be an integer from 1 through 65535.")
  quit(save = "no", status = 2L, runLast = FALSE)
}
opened <- rrp_open_reference_product_access(repository_root, store_path)
if (!identical(opened$overall_status, "succeeded")) {
  message(opened$message)
  for (index in seq_len(nrow(opened$validation$issues))) message(
    "  [", opened$validation$issues$category[[index]], "/",
    opened$validation$issues$issue_code[[index]], "] ",
    opened$validation$issues$message[[index]]
  )
  quit(save = "no", status = 1L, runLast = FALSE)
}
initialized <- rrp_initialize_reference_app(opened$access)
if (!identical(initialized$overall_status, "succeeded")) {
  message("Reference app initialization failed: ", initialized$message)
  quit(save = "no", status = 1L, runLast = FALSE)
}
cat("Operation: reference.launch-app\n")
cat("Status: ", if (validate_only) "validated" else "launching", "\n", sep = "")
cat("  data_classification: fictional_nonclinical\n")
cat("  product_set_id: ", initialized$products[[1L]]$product_set_id, "\n", sep = "")
cat("  source_as_of_time: ", initialized$freshness$source_as_of_time, "\n", sep = "")
cat("  product_generated_at: ", initialized$freshness$product_generated_at, "\n", sep = "")
cat("  latest_source_runtime_run_id: ",
  initialized$freshness$latest_source_runtime_run_id, "\n", sep = ""
)
application <- rrp_create_reference_app(opened$access)
if (validate_only) {
  cat("Next: Rscript operations/launch-reference-app.R\n")
  quit(save = "no", status = 0L, runLast = FALSE)
}
shiny::runApp(application, host = host, port = port, launch.browser = interactive())
