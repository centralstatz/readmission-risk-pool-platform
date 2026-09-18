library(rrpruntime)

description <- utils::packageDescription("rrpruntime")

stopifnot(
  identical(description[["Package"]], "rrpruntime"),
  identical(as.character(utils::packageVersion("rrpruntime")), "0.3.0.9000"),
  identical(description[["Depends"]], "R (>= 4.4.0)"),
  is.null(description[["Imports"]]),
  is.null(description[["Suggests"]]),
  is.null(description[["LinkingTo"]]),
  identical(
    sort(getNamespaceExports("rrpruntime")),
    c("rrp_admit_canonical_bundle", "rrp_prepare_episode_state")
  ),
  is.function(rrp_admit_canonical_bundle),
  is.function(rrp_prepare_episode_state)
)
