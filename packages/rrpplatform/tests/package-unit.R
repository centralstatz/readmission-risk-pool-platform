library(rrpplatform)

stopifnot(
  identical(as.character(utils::packageVersion("rrpplatform")), "0.1.0.9000"),
  identical(as.character(utils::packageVersion("rrpruntime")), "0.3.0")
)

imports <- getNamespaceImports("rrpplatform")
stopifnot(
  "rrpruntime" %in% names(imports),
  "yaml" %in% names(imports),
  identical(imports$rrpruntime[["runtime_conforms"]], "runtime_conforms"),
  identical(imports$yaml[["read_yaml"]], "read_yaml"),
  is.function(rrp_open_resource_catalog),
  is.function(rrp_resource_path)
)

conforming <- structure(
  list(overall_status = "pass"),
  class = "rrp_runtime_conformance_result"
)
stopifnot(isTRUE(get("runtime_conforms", asNamespace("rrpplatform"))(conforming)))
