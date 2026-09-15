library(rrpruntime)

description <- utils::packageDescription("rrpruntime")

stopifnot(
  identical(description[["Package"]], "rrpruntime"),
  identical(as.character(utils::packageVersion("rrpruntime")), "0.3.0.9000"),
  identical(description[["Depends"]], "R (>= 4.4.0)"),
  is.null(description[["Imports"]]),
  is.null(description[["Suggests"]]),
  is.null(description[["LinkingTo"]]),
  length(getNamespaceExports("rrpruntime")) == 0L
)
