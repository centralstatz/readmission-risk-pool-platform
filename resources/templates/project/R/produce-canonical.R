# RRP calls this trusted hospital function with the explicit project root and
# authoritative analytical time. Obtain and interpret hospital-owned source
# data here, returning exactly discharge_episode and terminal_event data frames
# in installed canonical field order. RRP constructs protocol envelopes,
# deterministic bundle identity, and performs canonical admission. Return
# rrpplatform::rrp_authoring_failure() for an intentional controlled failure.
# Complete guidance: resource `rrp.documentation.project-authoring-guide`,
# resolved with rrpplatform::rrp_resource_path() from an installed catalog.
rrp_produce_canonical <- function(project_root, as_of_time) {
  rrpplatform::rrp_authoring_failure("producer_unavailable")
}
