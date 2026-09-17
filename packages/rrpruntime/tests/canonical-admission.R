library(rrpruntime)

rrp_runtime_test_capabilities <- function() {
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

rrp_runtime_test_context <- function() {
  list(
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
    capabilities = rrp_runtime_test_capabilities(),
    as_of_time = "2026-02-15T12:00:00-06:00"
  )
}

rrp_runtime_test_candidate <- function() {
  list(
    bundle_contract_id = "rrp.canonical-bundle",
    bundle_contract_version = "0.1.0",
    bundle_instance_id = "fictional.bundle-001",
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
    as_of_time = "2026-02-15T18:00:00Z",
    capabilities = rrp_runtime_test_capabilities(),
    domains = list(
      discharge_episode = data.frame(
        episode_id = c("episode-001", "episode-002"),
        patient_id = c("patient-001", "patient-001"),
        index_encounter_id = c("encounter-001", "encounter-002"),
        admission_time = c(
          "2026-01-01T20:00:00-06:00", "2026-01-09T08:30:00-01:00"
        ),
        discharge_time = c(
          "2026-01-02T08:00:00-06:00", "2026-01-10T09:30:00Z"
        ),
        followup_window_end = c(
          "2026-02-01T14:00:00Z", "2026-02-09T10:30:00+01:00"
        ),
        stringsAsFactors = FALSE
      ),
      terminal_event = data.frame(
        terminal_event_id = c("event-001", "event-002", "event-003"),
        episode_id = c("episode-001", "episode-001", "episode-002"),
        event_type = c("readmission", "death", "death"),
        occurred_at = c(
          "2026-01-20T12:00:00-06:00",
          "2026-01-20T18:00:00Z",
          "2026-02-09T09:30:00Z"
        ),
        available_at = c(
          "2026-01-21T02:00:00+07:00",
          "2026-01-20T13:00:00-05:00",
          "2026-02-10T04:30:00-05:00"
        ),
        stringsAsFactors = FALSE
      )
    )
  )
}

rrp_runtime_test_empty_domain <- function(fields) {
  values <- rep(list(character()), length(fields))
  names(values) <- fields
  as.data.frame(values, stringsAsFactors = FALSE, optional = TRUE)
}

rrp_runtime_test_expect_code <- function(candidate, code, context = rrp_runtime_test_context()) {
  condition <- tryCatch({
    rrp_admit_canonical_bundle(candidate, context)
    NULL
  }, error = identity)
  stopifnot(
    inherits(condition, "rrp_canonical_error"),
    identical(condition$code, code),
    identical(condition$call, NULL),
    is.character(condition$message), length(condition$message) == 1L,
    nchar(condition$message, type = "bytes") <= 160L,
    !grepl("episode-001|patient-001|event-001", condition$message)
  )
  invisible(condition)
}

candidate <- rrp_runtime_test_candidate()
before <- candidate
admitted <- rrp_admit_canonical_bundle(candidate, rrp_runtime_test_context())
stopifnot(
  identical(candidate, before),
  identical(class(admitted), c("rrp_admitted_canonical_bundle", "list")),
  identical(unclass(admitted), candidate),
  nrow(admitted$domains$discharge_episode) == 2L,
  identical(
    admitted$domains$discharge_episode$patient_id,
    c("patient-001", "patient-001")
  ),
  nrow(admitted$domains$terminal_event) == 3L
)

candidate$project_id <- "changed-project"
candidate$domains$discharge_episode$episode_id[[1L]] <- "changed-episode"
candidate$domains$terminal_event$event_type[[1L]] <- "changed-event"
stopifnot(
  identical(admitted$project_id, "fictional-health-system"),
  identical(admitted$domains$discharge_episode$episode_id[[1L]], "episode-001"),
  identical(admitted$domains$terminal_event$event_type[[1L]], "readmission")
)

empty <- rrp_runtime_test_candidate()
empty$domains$discharge_episode <- rrp_runtime_test_empty_domain(c(
  "episode_id", "patient_id", "index_encounter_id", "admission_time",
  "discharge_time", "followup_window_end"
))
empty$domains$terminal_event <- rrp_runtime_test_empty_domain(c(
  "terminal_event_id", "episode_id", "event_type", "occurred_at", "available_at"
))
empty_admitted <- rrp_admit_canonical_bundle(empty, rrp_runtime_test_context())
stopifnot(
  nrow(empty_admitted$domains$discharge_episode) == 0L,
  nrow(empty_admitted$domains$terminal_event) == 0L,
  identical(empty_admitted$capabilities, rrp_runtime_test_capabilities())
)

dst_context <- rrp_runtime_test_context()
dst_context$as_of_time <- "2026-04-05T12:00:00-05:00"
dst_candidate <- rrp_runtime_test_candidate()
dst_candidate$as_of_time <- "2026-04-05T17:00:00Z"
dst_candidate$domains$discharge_episode <- data.frame(
  episode_id = "episode-dst",
  patient_id = "patient-dst",
  index_encounter_id = "encounter-dst",
  admission_time = "2026-02-28T10:00:00-06:00",
  discharge_time = "2026-03-01T10:00:00-06:00",
  followup_window_end = "2026-03-31T11:00:00-05:00",
  stringsAsFactors = FALSE
)
dst_candidate$domains$terminal_event <- rrp_runtime_test_empty_domain(c(
  "terminal_event_id", "episode_id", "event_type", "occurred_at", "available_at"
))
dst_admitted <- rrp_admit_canonical_bundle(dst_candidate, dst_context)
stopifnot(
  identical(
    dst_admitted$domains$discharge_episode$followup_window_end,
    "2026-03-31T11:00:00-05:00"
  )
)

modified <- rrp_runtime_test_candidate()
modified$unknown <- "not-allowed"
rrp_runtime_test_expect_code(modified, "unknown_bundle_field")

modified <- rrp_runtime_test_candidate()
modified <- modified[names(modified) != "mapping_id"]
rrp_runtime_test_expect_code(modified, "missing_bundle_field")

modified <- rrp_runtime_test_candidate()
modified$domains$unknown <- modified$domains$terminal_event
rrp_runtime_test_expect_code(modified, "unknown_domain")

modified <- rrp_runtime_test_candidate()
modified$domains <- modified$domains[names(modified$domains) != "terminal_event"]
rrp_runtime_test_expect_code(modified, "missing_domain")

modified <- rrp_runtime_test_candidate()
modified$domains$discharge_episode$unknown <- "not-allowed"
rrp_runtime_test_expect_code(modified, "invalid_discharge_episode_fields")

modified <- rrp_runtime_test_candidate()
modified$domains$terminal_event <- modified$domains$terminal_event[
  names(modified$domains$terminal_event) != "available_at"
]
rrp_runtime_test_expect_code(modified, "invalid_terminal_event_fields")

modified <- rrp_runtime_test_candidate()
modified$domains$discharge_episode$episode_id <- c(1L, 2L)
rrp_runtime_test_expect_code(modified, "invalid_domain_column_type")

modified <- rrp_runtime_test_candidate()
class(modified$domains$terminal_event) <- c("custom_table", "data.frame")
rrp_runtime_test_expect_code(modified, "invalid_terminal_event")

modified <- rrp_runtime_test_candidate()
attr(modified$domains$discharge_episode, "source") <- "unsafe"
rrp_runtime_test_expect_code(modified, "invalid_discharge_episode")

modified <- rrp_runtime_test_candidate()
modified$domains$terminal_event$event_type <- I(modified$domains$terminal_event$event_type)
rrp_runtime_test_expect_code(modified, "invalid_domain_column_type")

modified <- rrp_runtime_test_candidate()
modified$unknown <- function() NULL
rrp_runtime_test_expect_code(modified, "unsafe_candidate_value")

modified <- rrp_runtime_test_candidate()
modified$unknown <- new.env(parent = emptyenv())
rrp_runtime_test_expect_code(modified, "unsafe_candidate_value")

connection <- textConnection("private material")
modified <- rrp_runtime_test_candidate()
modified$unknown <- connection
rrp_runtime_test_expect_code(modified, "unsafe_candidate_value")
close(connection)

modified <- rrp_runtime_test_candidate()
modified$domains$discharge_episode$episode_id[[1L]] <- "unsafe patient 778899"
condition <- rrp_runtime_test_expect_code(modified, "invalid_domain_value")
stopifnot(!grepl("778899", conditionMessage(condition), fixed = TRUE))

modified <- rrp_runtime_test_candidate()
modified$domains$discharge_episode$episode_id[[2L]] <- "episode-001"
rrp_runtime_test_expect_code(modified, "duplicate_episode_id")

modified <- rrp_runtime_test_candidate()
modified$domains$terminal_event$terminal_event_id[[2L]] <- "event-001"
rrp_runtime_test_expect_code(modified, "duplicate_terminal_event_id")

modified <- rrp_runtime_test_candidate()
modified$domains$terminal_event$episode_id[[1L]] <- "episode-999"
rrp_runtime_test_expect_code(modified, "orphan_terminal_event")

modified <- rrp_runtime_test_candidate()
modified$domains$terminal_event$event_type[[1L]] <- "transfer"
rrp_runtime_test_expect_code(modified, "unsupported_event_type")

modified <- rrp_runtime_test_candidate()
extra <- modified$domains$terminal_event[1L, , drop = FALSE]
extra$terminal_event_id <- "event-004"
modified$domains$terminal_event <- rbind(modified$domains$terminal_event, extra)
row.names(modified$domains$terminal_event) <- NULL
rrp_runtime_test_expect_code(modified, "multiple_readmissions")

modified <- rrp_runtime_test_candidate()
extra <- modified$domains$terminal_event[2L, , drop = FALSE]
extra$terminal_event_id <- "event-004"
modified$domains$terminal_event <- rbind(modified$domains$terminal_event, extra)
row.names(modified$domains$terminal_event) <- NULL
rrp_runtime_test_expect_code(modified, "multiple_deaths")

modified <- rrp_runtime_test_candidate()
modified$domains$discharge_episode$admission_time[[1L]] <-
  modified$domains$discharge_episode$discharge_time[[1L]]
rrp_runtime_test_expect_code(modified, "admission_not_before_discharge")

modified <- rrp_runtime_test_candidate()
modified$domains$discharge_episode$discharge_time[[1L]] <- "2026-02-16T00:00:00Z"
modified$domains$discharge_episode$followup_window_end[[1L]] <- "2026-03-18T00:00:00Z"
rrp_runtime_test_expect_code(modified, "discharge_after_as_of")

modified <- rrp_runtime_test_candidate()
modified$domains$discharge_episode$followup_window_end[[1L]] <-
  "2026-02-01T13:59:59Z"
rrp_runtime_test_expect_code(modified, "invalid_followup_window")

modified <- rrp_runtime_test_candidate()
modified$domains$discharge_episode$followup_window_end[[1L]] <-
  "2026-02-01T14:00:01Z"
rrp_runtime_test_expect_code(modified, "invalid_followup_window")

modified <- rrp_runtime_test_candidate()
modified$domains$terminal_event$occurred_at[[1L]] <-
  modified$domains$discharge_episode$discharge_time[[1L]]
rrp_runtime_test_expect_code(modified, "terminal_event_not_after_discharge")

modified <- rrp_runtime_test_candidate()
modified$domains$terminal_event$occurred_at[[3L]] <- "2026-02-09T09:30:01Z"
rrp_runtime_test_expect_code(modified, "terminal_event_after_followup")

modified <- rrp_runtime_test_candidate()
modified$domains$terminal_event$available_at[[1L]] <- "2026-01-20T17:59:59Z"
rrp_runtime_test_expect_code(modified, "occurrence_after_availability")

modified <- rrp_runtime_test_candidate()
modified$domains$terminal_event$available_at[[1L]] <- "2026-02-15T18:00:01Z"
rrp_runtime_test_expect_code(modified, "availability_after_as_of")

future_context <- rrp_runtime_test_context()
future_context$as_of_time <- "2026-01-15T12:00:00Z"
modified <- rrp_runtime_test_candidate()
modified$as_of_time <- "2026-01-15T07:00:00-05:00"
modified$domains$terminal_event <- modified$domains$terminal_event[1L, , drop = FALSE]
row.names(modified$domains$terminal_event) <- NULL
modified$domains$terminal_event$occurred_at <- "2026-01-16T12:00:00Z"
modified$domains$terminal_event$available_at <- "2026-01-16T13:00:00Z"
rrp_runtime_test_expect_code(modified, "availability_after_as_of", future_context)

modified <- rrp_runtime_test_candidate()
modified$domains$terminal_event$occurred_at[[2L]] <- "2026-01-19T18:00:00Z"
modified$domains$terminal_event$available_at[[2L]] <- "2026-01-19T18:00:00Z"
rrp_runtime_test_expect_code(modified, "death_before_readmission")

modified <- rrp_runtime_test_candidate()
modified$domains$discharge_episode$discharge_time[[1L]] <- "not-a-time"
rrp_runtime_test_expect_code(modified, "invalid_timestamp")

identity_cases <- list(
  project_id = "project_identity_mismatch",
  producer_id = "producer_identity_mismatch",
  implementation_id = "implementation_identity_mismatch",
  mapping_id = "mapping_identity_mismatch"
)
for (field in names(identity_cases)) {
  modified <- rrp_runtime_test_candidate()
  modified[[field]] <- "different.identity"
  rrp_runtime_test_expect_code(modified, identity_cases[[field]])
}

modified <- rrp_runtime_test_candidate()
modified$bundle_contract_id <- "rrp.other-bundle"
rrp_runtime_test_expect_code(modified, "unsupported_bundle_contract")

modified <- rrp_runtime_test_candidate()
modified$bundle_contract_version <- "0.2.0"
rrp_runtime_test_expect_code(modified, "unsupported_bundle_contract")

modified <- rrp_runtime_test_candidate()
modified$canonical_profile_id <- "rrp.canonical-profile.other"
rrp_runtime_test_expect_code(modified, "unsupported_canonical_profile")

modified <- rrp_runtime_test_candidate()
modified$canonical_profile_version <- "0.2.0"
rrp_runtime_test_expect_code(modified, "unsupported_canonical_profile")

modified <- rrp_runtime_test_candidate()
modified$project_version <- "draft"
rrp_runtime_test_expect_code(modified, "invalid_version")

modified <- rrp_runtime_test_candidate()
modified$as_of_time <- "2026-02-15T18:00:01Z"
rrp_runtime_test_expect_code(modified, "as_of_time_mismatch")

modified <- rrp_runtime_test_candidate()
modified$capabilities <- modified$capabilities[-2L]
rrp_runtime_test_expect_code(modified, "missing_capability")

modified <- rrp_runtime_test_candidate()
modified$capabilities[[2L]] <- modified$capabilities[[1L]]
rrp_runtime_test_expect_code(modified, "duplicate_capability")

modified <- rrp_runtime_test_candidate()
modified$capabilities[[2L]]$capability_id <- "rrp.capability.other"
rrp_runtime_test_expect_code(modified, "unsupported_capability")

modified <- rrp_runtime_test_candidate()
modified$capabilities[[2L]]$status <- "unavailable"
rrp_runtime_test_expect_code(modified, "unavailable_capability")

context <- rrp_runtime_test_context()
context$producer_id <- "different.producer"
rrp_runtime_test_expect_code(
  rrp_runtime_test_candidate(), "producer_identity_mismatch", context
)

context <- rrp_runtime_test_context()
context$bundle_contract_version <- "9.9.9"
rrp_runtime_test_expect_code(
  rrp_runtime_test_candidate(), "unsupported_bundle_contract", context
)

context <- rrp_runtime_test_context()
context$canonical_profile_version <- "9.9.9"
rrp_runtime_test_expect_code(
  rrp_runtime_test_candidate(), "unsupported_canonical_profile", context
)

cat("rrpruntime canonical-admission tests passed\n")
