library(rrpruntime)

description <- utils::packageDescription("rrpruntime")

stopifnot(
  identical(description[["Package"]], "rrpruntime"),
  identical(as.character(utils::packageVersion("rrpruntime")), "0.4.0.9000"),
  identical(description[["Depends"]], "R (>= 4.4.0)"),
  is.null(description[["Imports"]]),
  is.null(description[["Suggests"]]),
  is.null(description[["LinkingTo"]]),
  identical(
    sort(getNamespaceExports("rrpruntime")),
    c(
      "rrp_admit_canonical_bundle", "rrp_execute_risk_provider",
      "rrp_history_append_disposition", "rrp_history_append_invalidation",
      "rrp_history_append_restatement", "rrp_history_append_scope",
      "rrp_history_membership_fingerprint", "rrp_history_read_current",
      "rrp_history_read_episode", "rrp_history_read_scope",
      "rrp_new_episode_disposition", "rrp_new_history_action",
      "rrp_new_history_port", "rrp_new_operational_scope",
      "rrp_prepare_episode_state"
    )
  ),
  is.function(rrp_admit_canonical_bundle),
  is.function(rrp_execute_risk_provider),
  is.function(rrp_new_history_port),
  is.function(rrp_history_read_current),
  is.function(rrp_prepare_episode_state)
)
