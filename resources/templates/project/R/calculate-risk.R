# RRP calls this trusted hospital function with the explicit project root and a
# detached request of exact class c("rrp_risk_request", "list"). The request is
# one flat list, in order: request_contract_id, request_contract_version,
# request_id, target_id, target_version, state_contract_id,
# state_contract_version, state_id, bundle_instance_id, project_id,
# project_version, episode_id, as_of_time, discharge_time,
# target_interval_start, target_interval_end, target_interval_boundary,
# elapsed_seconds_since_discharge, remaining_seconds_through_w30. The final two
# fields are finite unclassed doubles; all others are scalar character. Times
# are RFC 3339 UTC and target_interval_boundary is exactly (start,end].
# episode_id is the only canonical domain identifier; as_of_time is authoritative.
# RRP has already established admission, eligibility, state, provider selection,
# and compatibility. No source IDs, predictors, paths, connections, or credentials
# are in the request. Resolve private model data beneath project_root and ensure
# it is legitimate for request$as_of_time. Return one finite unclassed double in
# [0,1], or rrpplatform::rrp_authoring_failure() for a controlled failure.
# Complete reference: resource `rrp.documentation.provider-request-reference`,
# resolved with rrpplatform::rrp_resource_path() from an installed catalog.
rrp_calculate_risk <- function(project_root, request) {
  rrpplatform::rrp_authoring_failure("provider_unavailable")
}
