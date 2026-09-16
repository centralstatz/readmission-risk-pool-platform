library(rrpplatform)

description <- utils::packageDescription("rrpplatform")
namespace_imports <- getNamespaceImports("rrpplatform")

stopifnot(
  identical(description[["Package"]], "rrpplatform"),
  identical(as.character(utils::packageVersion("rrpplatform")), "0.1.0.9000"),
  identical(description[["Depends"]], "R (>= 4.4.0)"),
  identical(description[["Imports"]], "rrpruntime"),
  is.null(description[["Suggests"]]),
  is.null(description[["LinkingTo"]]),
  "rrpruntime" %in% names(namespace_imports),
  identical(as.character(utils::packageVersion("rrpruntime")), "0.3.0.9000"),
  length(getNamespaceExports("rrpplatform")) == 0L
)
