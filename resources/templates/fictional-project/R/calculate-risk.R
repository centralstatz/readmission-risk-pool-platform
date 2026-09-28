# This ordinary standard-authoring provider receives the unchanged detached
# 19-field RRP request. It resolves the canonical episode through project-owned
# data and returns only one explicitly nonclinical probability.
rrp_calculate_risk <- function(project_root, request) {
  unavailable <- function() {
    rrpplatform::rrp_authoring_failure("provider_input_unavailable")
  }
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
  crosswalk <- tryCatch(utils::read.csv(
    file.path(generated, "identity-crosswalk.csv"),
    colClasses = "character", na.strings = character(), check.names = FALSE,
    stringsAsFactors = FALSE
  ), error = function(condition) NULL)
  stays <- tryCatch(utils::read.csv(
    file.path(generated, "stays.csv"), colClasses = "character",
    na.strings = character(), check.names = FALSE, stringsAsFactors = FALSE
  ), error = function(condition) NULL)
  if (is.null(crosswalk) || is.null(stays) || !identical(names(crosswalk), c(
    "identity_type", "native_id", "canonical_id"
  )) || !identical(names(stays), c(
    "native_stay_id", "native_person_id", "native_encounter_id",
    "admitted_at", "discharged_at", "provider_signal",
    "provider_signal_available_at"
  )) || anyNA(crosswalk) || anyNA(stays) ||
      anyDuplicated(paste(crosswalk$identity_type, crosswalk$native_id)) ||
      anyDuplicated(crosswalk$canonical_id) ||
      anyDuplicated(stays$native_stay_id)) return(unavailable())
  matched_crosswalk <- crosswalk$identity_type == "episode" &
    crosswalk$canonical_id == request$episode_id
  if (sum(matched_crosswalk) != 1L) return(unavailable())
  native_stay_id <- crosswalk$native_id[matched_crosswalk]
  matched_stay <- stays$native_stay_id == native_stay_id
  if (sum(matched_stay) != 1L) return(unavailable())
  signal_text <- stays$provider_signal[matched_stay]
  signal <- suppressWarnings(as.numeric(signal_text))
  available_at <- time_number(stays$provider_signal_available_at[matched_stay])
  cutoff <- time_number(request$as_of_time)
  canonical_signal <- grepl(
    "^(?:0(?:[.][0-9]+)?|1(?:[.]0+)?)$", signal_text, perl = TRUE
  ) && !is.na(signal) && is.finite(signal)
  if (!canonical_signal || signal < 0 || signal > 1 || is.na(available_at) ||
      is.na(cutoff) || available_at > cutoff) return(unavailable())
  remaining_fraction <- request$remaining_seconds_through_w30 / 2592000
  probability <- 0.05 + 0.50 * signal + 0.20 * remaining_fraction
  as.numeric(min(0.95, max(0.01, probability)))
}
