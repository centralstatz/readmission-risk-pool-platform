# This ordinary standard-authoring function validates and maps project-owned
# fictional source. It returns only the two governed canonical domains; native
# identity, crosswalk, source vocabulary, availability controls, and the
# provider-only signal remain private to this project.
rrp_produce_canonical <- function(project_root, as_of_time) {
  fail <- function(code) rrpplatform::rrp_authoring_failure(code)
  scalar <- function(value) {
    is.character(value) && length(value) == 1L && !is.na(value) && nzchar(value)
  }
  time_number <- function(value) {
    if (!scalar(value) || !grepl(
      paste0(
        "^[0-9]{4}-[0-9]{2}-[0-9]{2}T",
        "(?:[01][0-9]|2[0-3]):[0-5][0-9]:[0-5][0-9]Z$"
      ), value, perl = TRUE
    )) return(NA_real_)
    parsed <- suppressWarnings(strptime(
      value, format = "%Y-%m-%dT%H:%M:%SZ", tz = "UTC"
    ))
    if (length(parsed) != 1L || is.na(parsed)) NA_real_ else {
      as.numeric(as.POSIXct(parsed, tz = "UTC"))
    }
  }
  generated <- file.path(project_root, "source", "generated")
  expected_files <- c(
    "events.csv", "identity-crosswalk.csv", "source.dcf", "stays.csv"
  )
  linked <- function(path) {
    target <- Sys.readlink(path)
    !is.na(target) && nzchar(target)
  }
  if (!dir.exists(generated) || linked(generated) || !identical(
    sort(list.files(
      generated, all.files = TRUE, no.. = TRUE, recursive = TRUE,
      include.dirs = FALSE
    ), method = "radix"), expected_files
  )) return(fail("producer_source_failed"))
  paths <- file.path(generated, expected_files)
  if (any(!file.exists(paths)) || any(dir.exists(paths)) ||
      any(vapply(paths, linked, logical(1L)))) {
    return(fail("producer_source_failed"))
  }
  provenance <- tryCatch(
    base::read.dcf(file.path(generated, "source.dcf"), all = TRUE),
    error = function(condition) NULL
  )
  expected_provenance <- c(
    "Record-Type" = "fictional-source",
    "Generator-ID" = "fictional.reference.generator",
    "Generator-Version" = "1.0.0",
    "Dataset-ID" = "fictional.reference.source",
    "Dataset-Version" = "1.0.0",
    "Reference-Time" = "2026-01-20T12:00:00Z",
    "Classification" = "fictional_nonclinical",
    "Tables" = "stays.csv,events.csv,identity-crosswalk.csv",
    "Stay-Rows" = "4", "Event-Rows" = "3", "Crosswalk-Rows" = "12"
  )
  if (is.null(provenance) || nrow(provenance) != 1L ||
      !identical(colnames(provenance), names(expected_provenance)) ||
      !identical(as.character(provenance[1L, ]), unname(expected_provenance))) {
    return(fail("producer_source_failed"))
  }
  read_table <- function(name, fields) {
    value <- tryCatch(utils::read.csv(
      file.path(generated, name), colClasses = "character",
      na.strings = character(), check.names = FALSE,
      stringsAsFactors = FALSE
    ), error = function(condition) NULL)
    if (is.null(value) || !identical(names(value), fields) ||
        anyNA(value) || any(vapply(value, function(column) {
          any(!nzchar(column))
        }, logical(1L)))) NULL else value
  }
  stays <- read_table("stays.csv", c(
    "native_stay_id", "native_person_id", "native_encounter_id",
    "admitted_at", "discharged_at", "provider_signal",
    "provider_signal_available_at"
  ))
  events <- read_table("events.csv", c(
    "native_event_id", "native_stay_id", "event_code", "occurred_at",
    "available_at"
  ))
  crosswalk <- read_table("identity-crosswalk.csv", c(
    "identity_type", "native_id", "canonical_id"
  ))
  if (is.null(stays) || is.null(events) || is.null(crosswalk) ||
      nrow(stays) != 4L || nrow(events) != 3L || nrow(crosswalk) != 12L ||
      anyDuplicated(stays$native_stay_id) ||
      anyDuplicated(stays$native_person_id) ||
      anyDuplicated(stays$native_encounter_id) ||
      anyDuplicated(events$native_event_id) ||
      any(!events$native_stay_id %in% stays$native_stay_id) ||
      any(!events$event_code %in% c("LOCAL_READMIT", "LOCAL_DEATH")) ||
      any(!crosswalk$identity_type %in% c("episode", "patient", "encounter")) ||
      anyDuplicated(paste(crosswalk$identity_type, crosswalk$native_id)) ||
      anyDuplicated(crosswalk$canonical_id)) {
    return(fail("producer_source_failed"))
  }
  identity_pattern <- "^[a-z][a-z0-9]*(?:[.-][a-z0-9]+)*$"
  if (any(!grepl(identity_pattern, crosswalk$canonical_id, perl = TRUE)) ||
      any(nchar(crosswalk$canonical_id, type = "bytes") > 96L)) {
    return(fail("producer_mapping_failed"))
  }
  required_native <- c(
    paste("episode", stays$native_stay_id),
    paste("patient", stays$native_person_id),
    paste("encounter", stays$native_encounter_id)
  )
  if (!setequal(
    paste(crosswalk$identity_type, crosswalk$native_id), required_native
  )) return(fail("producer_mapping_failed"))
  stay_times <- lapply(c(
    stays$admitted_at, stays$discharged_at,
    stays$provider_signal_available_at
  ), time_number)
  stay_times <- unlist(stay_times, use.names = FALSE)
  event_times <- unlist(lapply(
    c(events$occurred_at, events$available_at), time_number
  ), use.names = FALSE)
  cutoff <- time_number(as_of_time)
  if (is.na(cutoff) || anyNA(stay_times) || anyNA(event_times)) {
    return(fail("producer_source_failed"))
  }
  admitted <- vapply(stays$admitted_at, time_number, numeric(1L))
  discharged <- vapply(stays$discharged_at, time_number, numeric(1L))
  signal_available <- vapply(
    stays$provider_signal_available_at, time_number, numeric(1L)
  )
  occurred <- vapply(events$occurred_at, time_number, numeric(1L))
  available <- vapply(events$available_at, time_number, numeric(1L))
  event_stay <- match(events$native_stay_id, stays$native_stay_id)
  signals <- suppressWarnings(as.numeric(stays$provider_signal))
  if (any(admitted >= discharged) || any(signal_available < admitted) ||
      anyNA(signals) || any(!is.finite(signals)) ||
      any(signals < 0 | signals > 1) ||
      any(occurred <= discharged[event_stay]) ||
      any(occurred > discharged[event_stay] + 2592000) ||
      any(available < occurred)) return(fail("producer_source_failed"))
  lookup <- function(kind, native) {
    matched <- crosswalk$identity_type == kind & crosswalk$native_id == native
    if (sum(matched) != 1L) return(NA_character_)
    crosswalk$canonical_id[matched]
  }
  keep_stays <- discharged <= cutoff
  selected_stays <- stays[keep_stays, , drop = FALSE]
  selected_discharge <- discharged[keep_stays]
  discharge_episode <- data.frame(
    episode_id = vapply(
      selected_stays$native_stay_id, function(value) lookup("episode", value),
      character(1L)
    ),
    patient_id = vapply(
      selected_stays$native_person_id, function(value) lookup("patient", value),
      character(1L)
    ),
    index_encounter_id = vapply(
      selected_stays$native_encounter_id,
      function(value) lookup("encounter", value), character(1L)
    ),
    admission_time = selected_stays$admitted_at,
    discharge_time = selected_stays$discharged_at,
    followup_window_end = vapply(selected_discharge + 2592000, function(value) {
      format(
        as.POSIXct(value, origin = "1970-01-01", tz = "UTC"),
        "%Y-%m-%dT%H:%M:%SZ", tz = "UTC"
      )
    }, character(1L)),
    stringsAsFactors = FALSE
  )
  rownames(discharge_episode) <- NULL
  if (anyNA(discharge_episode[1:3])) return(fail("producer_mapping_failed"))
  keep_events <- occurred <= cutoff & available <= cutoff
  selected_events <- events[keep_events, , drop = FALSE]
  event_types <- c(LOCAL_READMIT = "readmission", LOCAL_DEATH = "death")
  terminal_event <- data.frame(
    terminal_event_id = sprintf("fictional.event.%03d", which(keep_events)),
    episode_id = vapply(
      selected_events$native_stay_id,
      function(value) lookup("episode", value), character(1L)
    ),
    event_type = unname(event_types[selected_events$event_code]),
    occurred_at = selected_events$occurred_at,
    available_at = selected_events$available_at,
    stringsAsFactors = FALSE
  )
  rownames(terminal_event) <- NULL
  if (anyNA(terminal_event)) return(fail("producer_mapping_failed"))
  list(discharge_episode = discharge_episode, terminal_event = terminal_event)
}
