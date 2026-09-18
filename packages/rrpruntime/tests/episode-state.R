library(rrpruntime)

rrp_state_test_context <- function() {
  list(
    product_id = "readmission-risk-pool-platform",
    development_version = "1.0.0-dev",
    target_id = "rrp.risk-target.readmission-remaining-30-day",
    target_version = "0.1.0",
    state_contract_id = "rrp.episode-state",
    state_contract_version = "0.1.0",
    bundle_contract_id = "rrp.canonical-bundle",
    bundle_contract_version = "0.1.0",
    canonical_profile_id = "rrp.canonical-profile.readmission",
    canonical_profile_version = "0.1.0",
    target_event = "first_canonical_readmission",
    conditioning = "alive_and_readmission_free_through_t",
    endpoint_elapsed_seconds = 2592000,
    eligible_as_of_start = "inclusive",
    eligible_as_of_end = "exclusive",
    target_interval = "(t,W30]",
    information_cutoff = "occurred_and_available_through_t",
    competing_event = "death",
    equal_time_precedence = "readmission",
    target_selection = "prohibited",
    terminal_status = "none_available_through_as_of"
  )
}

rrp_state_test_capabilities <- function() {
  list(
    list(
      capability_id = "rrp.capability.discharge-episode",
      status = "available"
    ),
    list(
      capability_id = "rrp.capability.terminal-event",
      status = "available"
    )
  )
}

rrp_state_test_empty_events <- function() {
  data.frame(
    terminal_event_id = character(), episode_id = character(),
    event_type = character(), occurred_at = character(),
    available_at = character(), stringsAsFactors = FALSE
  )
}

rrp_state_test_episodes <- function() {
  data.frame(
    episode_id = c("episode-001", "episode-002"),
    patient_id = c("patient-001", "patient-001"),
    index_encounter_id = c("encounter-001", "encounter-002"),
    admission_time = c(
      "2026-01-09T12:00:00Z", "2026-01-04T12:00:00Z"
    ),
    discharge_time = c(
      "2026-01-10T12:00:00Z", "2026-01-05T12:00:00Z"
    ),
    followup_window_end = c(
      "2026-02-09T12:00:00Z", "2026-02-04T12:00:00Z"
    ),
    stringsAsFactors = FALSE
  )
}

rrp_state_test_admitted <- function(
  as_of_time,
  events = rrp_state_test_empty_events(),
  episodes = rrp_state_test_episodes(),
  bundle_instance_id = "fictional.bundle-state"
) {
  canonical_context <- list(
    bundle_contract_id = "rrp.canonical-bundle",
    bundle_contract_version = "0.1.0",
    project_id = "fictional-health-system",
    project_version = "1.0.0",
    producer_id = "fictional.producer",
    producer_version = "1.0.0",
    implementation_id = "fictional.implementation",
    implementation_version = "1.0.0",
    mapping_id = "fictional.mapping",
    mapping_version = "1.0.0",
    canonical_profile_id = "rrp.canonical-profile.readmission",
    canonical_profile_version = "0.1.0",
    as_of_time = as_of_time,
    capabilities = rrp_state_test_capabilities()
  )
  candidate <- c(
    canonical_context[c("bundle_contract_id", "bundle_contract_version")],
    list(bundle_instance_id = bundle_instance_id),
    canonical_context[c(
      "project_id", "project_version", "producer_id", "producer_version",
      "implementation_id", "implementation_version", "mapping_id",
      "mapping_version", "canonical_profile_id", "canonical_profile_version"
    )],
    list(
      as_of_time = as_of_time,
      capabilities = canonical_context$capabilities,
      domains = list(
        discharge_episode = episodes,
        terminal_event = events
      )
    )
  )
  rrp_admit_canonical_bundle(candidate, canonical_context)
}

rrp_state_test_expect_code <- function(
  admitted_bundle,
  code,
  episode_id = "episode-001",
  as_of_time = admitted_bundle$as_of_time,
  expected_context = rrp_state_test_context()
) {
  condition <- tryCatch({
    rrp_prepare_episode_state(
      admitted_bundle, episode_id, as_of_time, expected_context
    )
    NULL
  }, error = identity)
  stopifnot(
    inherits(condition, "rrp_runtime_error"),
    identical(condition$code, code),
    identical(condition$call, NULL),
    is.character(condition$message), length(condition$message) == 1L,
    nchar(condition$message, type = "bytes") <= 160L,
    !grepl(
      "episode-001|patient-001|encounter-001|2026-", condition$message
    )
  )
  invisible(condition)
}

rrp_state_test_has_reference <- function(value) {
  if (is.function(value) || is.environment(value) || inherits(value, "connection") ||
      typeof(value) %in% c("externalptr", "weakref", "language", "symbol")) {
    return(TRUE)
  }
  is.list(value) && any(vapply(value, rrp_state_test_has_reference, logical(1L)))
}

at_discharge <- rrp_state_test_admitted("2026-01-10T12:00:00Z")
before <- at_discharge
state <- rrp_prepare_episode_state(
  at_discharge,
  "episode-001",
  "2026-01-10T06:00:00-06:00",
  rrp_state_test_context()
)
expected_fields <- c(
  "state_contract_id", "state_contract_version", "state_id", "target_id",
  "target_version", "bundle_contract_id", "bundle_contract_version",
  "bundle_instance_id", "project_id", "project_version",
  "canonical_profile_id", "canonical_profile_version", "episode_id",
  "as_of_time", "discharge_time", "target_window_end",
  "elapsed_seconds_since_discharge", "remaining_seconds_through_w30",
  "terminal_status"
)
stopifnot(
  identical(at_discharge, before),
  identical(class(state), c("rrp_episode_state", "list")),
  identical(names(attributes(state)), c("names", "class")),
  identical(names(state), expected_fields),
  identical(state$state_contract_id, "rrp.episode-state"),
  identical(state$state_contract_version, "0.1.0"),
  grepl("^rrp[.]state[.][0-9a-f]{16}$", state$state_id),
  identical(
    state$target_id, "rrp.risk-target.readmission-remaining-30-day"
  ),
  identical(state$target_version, "0.1.0"),
  identical(state$bundle_instance_id, "fictional.bundle-state"),
  identical(state$project_id, "fictional-health-system"),
  identical(state$episode_id, "episode-001"),
  identical(state$as_of_time, "2026-01-10T12:00:00Z"),
  identical(state$discharge_time, "2026-01-10T12:00:00Z"),
  identical(state$target_window_end, "2026-02-09T12:00:00Z"),
  identical(state$elapsed_seconds_since_discharge, 0),
  identical(state$remaining_seconds_through_w30, 2592000),
  identical(state$terminal_status, "none_available_through_as_of"),
  !rrp_state_test_has_reference(state),
  !any(c(
    "patient_id", "index_encounter_id", "terminal_event", "producer_id",
    "implementation_id", "mapping_id", "provider_id", "run_id",
    "history_id", "source", "features"
  ) %in% names(state))
)

same_state <- rrp_prepare_episode_state(
  at_discharge, "episode-001", at_discharge$as_of_time,
  rrp_state_test_context()
)
stopifnot(identical(state, same_state), identical(state$state_id, same_state$state_id))

at_discharge$project_id <- "changed-project"
at_discharge$domains$discharge_episode$episode_id[[1L]] <- "changed-episode"
stopifnot(
  identical(state$project_id, "fictional-health-system"),
  identical(state$episode_id, "episode-001")
)

just_before_end <- rrp_state_test_admitted("2026-02-09T11:59:59Z")
end_state <- rrp_prepare_episode_state(
  just_before_end, "episode-001", just_before_end$as_of_time,
  rrp_state_test_context()
)
stopifnot(
  identical(end_state$elapsed_seconds_since_discharge, 2591999),
  identical(end_state$remaining_seconds_through_w30, 1)
)

at_end <- rrp_state_test_admitted("2026-02-09T12:00:00Z")
rrp_state_test_expect_code(at_end, "target_horizon_exhausted")
after_end <- rrp_state_test_admitted("2026-02-10T12:00:00Z")
rrp_state_test_expect_code(after_end, "target_horizon_exhausted")

eligibility <- getFromNamespace(
  "rrp_runtime_eligibility_failure", "rrpruntime"
)
stopifnot(identical(
  eligibility(
    10, 11, 20, rrp_state_test_empty_events(), "episode-001"
  ),
  "episode_before_discharge"
))

rrp_state_test_terminal <- function(type, occurred_at, available_at = occurred_at) {
  data.frame(
    terminal_event_id = paste0("event-", type),
    episode_id = "episode-001", event_type = type,
    occurred_at = occurred_at, available_at = available_at,
    stringsAsFactors = FALSE
  )
}

readmitted <- rrp_state_test_admitted(
  "2026-01-20T12:00:00Z",
  rrp_state_test_terminal("readmission", "2026-01-19T12:00:00Z")
)
rrp_state_test_expect_code(readmitted, "episode_already_readmitted")
readmitted_at_t <- rrp_state_test_admitted(
  "2026-01-20T12:00:00Z",
  rrp_state_test_terminal("readmission", "2026-01-20T12:00:00Z")
)
rrp_state_test_expect_code(readmitted_at_t, "episode_already_readmitted")
dead <- rrp_state_test_admitted(
  "2026-01-20T12:00:00Z",
  rrp_state_test_terminal("death", "2026-01-19T12:00:00Z")
)
rrp_state_test_expect_code(dead, "episode_already_dead")
dead_at_t <- rrp_state_test_admitted(
  "2026-01-20T12:00:00Z",
  rrp_state_test_terminal("death", "2026-01-20T12:00:00Z")
)
rrp_state_test_expect_code(dead_at_t, "episode_already_dead")

tie <- rbind(
  rrp_state_test_terminal("readmission", "2026-01-20T12:00:00Z"),
  rrp_state_test_terminal("death", "2026-01-20T12:00:00Z")
)
row.names(tie) <- NULL
tie$terminal_event_id <- c("event-readmission", "event-death")
tie_bundle <- rrp_state_test_admitted("2026-01-20T12:00:00Z", tie)
rrp_state_test_expect_code(tie_bundle, "episode_already_readmitted")

other_episode_event <- data.frame(
  terminal_event_id = "event-other-death", episode_id = "episode-002",
  event_type = "death", occurred_at = "2026-01-15T12:00:00Z",
  available_at = "2026-01-15T12:00:00Z", stringsAsFactors = FALSE
)
multi <- rrp_state_test_admitted("2026-01-20T12:00:00Z", other_episode_event)
selected <- rrp_prepare_episode_state(
  multi, "episode-001", multi$as_of_time, rrp_state_test_context()
)
stopifnot(identical(selected$episode_id, "episode-001"))
rrp_state_test_expect_code(
  multi, "episode_already_dead", episode_id = "episode-002"
)
rrp_state_test_expect_code(multi, "unknown_episode", episode_id = "episode-999")

early <- rrp_state_test_admitted("2026-01-15T12:00:00Z")
early_state <- rrp_prepare_episode_state(
  early, "episode-001", early$as_of_time, rrp_state_test_context()
)
late_event <- rrp_state_test_terminal(
  "readmission", "2026-01-14T12:00:00Z", "2026-01-16T12:00:00Z"
)
late <- rrp_state_test_admitted("2026-01-16T12:00:00Z", late_event)
stopifnot(identical(
  early_state$terminal_status, "none_available_through_as_of"
))
rrp_state_test_expect_code(late, "episode_already_readmitted")

mismatch <- rrp_state_test_admitted("2026-01-20T12:00:00Z")
rrp_state_test_expect_code(
  mismatch, "analytical_as_of_mismatch",
  as_of_time = "2026-01-20T11:59:59Z"
)
rrp_state_test_expect_code(
  mismatch, "analytical_as_of_mismatch",
  as_of_time = "2026-01-20T12:00:01Z"
)
for (invalid_time in c(
  "2026-01-20T12:00:00", "2026-01-20", "not-a-time"
)) {
  rrp_state_test_expect_code(
    mismatch, "invalid_analytical_as_of", as_of_time = invalid_time
  )
}
attributed_time <- "2026-01-20T06:00:00-06:00"
attr(attributed_time, "source") <- "not-allowed"
rrp_state_test_expect_code(
  mismatch, "invalid_analytical_as_of", as_of_time = attributed_time
)

invalid_context <- rrp_state_test_context()
invalid_context$target_interval <- "(t,t+1day]"
rrp_state_test_expect_code(
  mismatch, "invalid_expected_context", expected_context = invalid_context
)
invalid_context <- rrp_state_test_context()
class(invalid_context) <- "unsafe_context"
rrp_state_test_expect_code(
  mismatch, "invalid_expected_context", expected_context = invalid_context
)

unsafe_bundle <- mismatch
unsafe_bundle$unsafe <- new.env(parent = emptyenv())
rrp_state_test_expect_code(unsafe_bundle, "invalid_admitted_bundle")
attributed_bundle <- mismatch
attr(attributed_bundle$domains$discharge_episode, "source") <- "not-allowed"
rrp_state_test_expect_code(attributed_bundle, "invalid_admitted_bundle")

cat("rrpruntime episode-state tests passed\n")
