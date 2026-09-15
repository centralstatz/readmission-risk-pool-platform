library(rrpruntime)

stopifnot(identical(
  runtime_conforms(validate_runtime_contracts(list())),
  FALSE
))

input <- new_admitted_canonical_input(
  bundle_instance_id = "fictional_bundle",
  bundle_as_of_time = "2026-01-04T12:00:00Z",
  canonical_run_id = "fictional_canonical_run",
  profile_specification = list(
    specification_id = "platform.readmission-initial-profile",
    specification_version = "0.1.0"
  ),
  capabilities = list(list(
    capability_id = "platform.discharge-episode", status = "available"
  )),
  discharge_episodes = list(list(
    episode_id = "fictional_episode",
    discharge_time = "2026-01-03T12:00:00Z",
    followup_window_end = "2026-02-02T12:00:00Z"
  )),
  admission_reference = list(overall_status = "pass")
)
stopifnot(runtime_conforms(validate_runtime_input(input)))
