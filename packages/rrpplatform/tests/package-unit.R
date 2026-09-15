library(rrpplatform)

stopifnot(
  identical(as.character(utils::packageVersion("rrpplatform")), "0.1.0.9000"),
  identical(as.character(utils::packageVersion("rrpruntime")), "0.3.0")
)

imports <- getNamespaceImports("rrpplatform")
stopifnot(
  "rrpruntime" %in% names(imports),
  identical(imports$rrpruntime[["runtime_conforms"]], "runtime_conforms")
)

conforming <- structure(
  list(overall_status = "pass"),
  class = "rrp_runtime_conformance_result"
)
stopifnot(isTRUE(get("runtime_conforms", asNamespace("rrpplatform"))(conforming)))
