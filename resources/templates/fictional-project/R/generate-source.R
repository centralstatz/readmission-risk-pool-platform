# Explicitly generate the small, deterministic, nonclinical fictional source.
# The operation is create-only: an identical existing realization is accepted,
# while different or additional content is never overwritten.
rrp_generate_fictional_source <- function(project_root) {
  if (!is.character(project_root) || length(project_root) != 1L ||
      is.na(project_root) || !nzchar(project_root)) {
    stop("Fictional project root is invalid.", call. = FALSE)
  }
  root <- normalizePath(project_root, winslash = "/", mustWork = TRUE)
  if (!file.exists(file.path(root, "rrp-project.dcf"))) {
    stop("Fictional project root is invalid.", call. = FALSE)
  }
  source_root <- file.path(root, "source")
  generated_root <- file.path(source_root, "generated")
  expected <- list(
    "source.dcf" = c(
      "Record-Type: fictional-source",
      "Generator-ID: fictional.reference.generator",
      "Generator-Version: 1.0.0",
      "Dataset-ID: fictional.reference.source",
      "Dataset-Version: 1.0.0",
      "Reference-Time: 2026-01-20T12:00:00Z",
      "Classification: fictional_nonclinical",
      "Tables: stays.csv,events.csv,identity-crosswalk.csv",
      "Stay-Rows: 4",
      "Event-Rows: 3",
      "Crosswalk-Rows: 12"
    ),
    "stays.csv" = c(
      paste(c(
        "native_stay_id", "native_person_id", "native_encounter_id",
        "admitted_at", "discharged_at", "provider_signal",
        "provider_signal_available_at"
      ), collapse = ","),
      "FIC STAY/001,FIC PERSON/001,FIC ENCOUNTER/001,2026-01-08T12:00:00Z,2026-01-10T12:00:00Z,0.40,2026-01-10T13:00:00Z",
      "FIC-STAY-002,FIC-PERSON-002,FIC-ENCOUNTER-002,2026-01-02T12:00:00Z,2026-01-05T12:00:00Z,0.65,2026-01-05T14:00:00Z",
      "FIC-STAY-003,FIC-PERSON-003,FIC-ENCOUNTER-003,2026-01-01T12:00:00Z,2026-01-04T12:00:00Z,0.25,2026-01-04T13:00:00Z",
      "FIC-STAY-004,FIC-PERSON-004,FIC-ENCOUNTER-004,2025-12-18T12:00:00Z,2025-12-20T12:00:00Z,0.80,2025-12-20T13:00:00Z"
    ),
    "events.csv" = c(
      paste(c(
        "native_event_id", "native_stay_id", "event_code", "occurred_at",
        "available_at"
      ), collapse = ","),
      "FIC-EVENT-001,FIC-STAY-002,LOCAL_READMIT,2026-01-15T08:00:00Z,2026-01-15T09:00:00Z",
      "FIC-EVENT-002,FIC-STAY-003,LOCAL_DEATH,2026-01-12T10:00:00Z,2026-01-12T11:00:00Z",
      "FIC-EVENT-003,FIC STAY/001,LOCAL_DEATH,2026-01-19T10:00:00Z,2026-01-21T09:00:00Z"
    ),
    "identity-crosswalk.csv" = c(
      "identity_type,native_id,canonical_id",
      "episode,FIC STAY/001,fictional.episode.001",
      "patient,FIC PERSON/001,fictional.patient.001",
      "encounter,FIC ENCOUNTER/001,fictional.encounter.001",
      "episode,FIC-STAY-002,fictional.episode.002",
      "patient,FIC-PERSON-002,fictional.patient.002",
      "encounter,FIC-ENCOUNTER-002,fictional.encounter.002",
      "episode,FIC-STAY-003,fictional.episode.003",
      "patient,FIC-PERSON-003,fictional.patient.003",
      "encounter,FIC-ENCOUNTER-003,fictional.encounter.003",
      "episode,FIC-STAY-004,fictional.episode.004",
      "patient,FIC-PERSON-004,fictional.patient.004",
      "encounter,FIC-ENCOUNTER-004,fictional.encounter.004"
    )
  )
  bytes <- lapply(expected, function(lines) {
    charToRaw(paste0(paste(lines, collapse = "\n"), "\n"))
  })
  path_exists <- function(path) {
    target <- Sys.readlink(path)
    file.exists(path) || dir.exists(path) || (!is.na(target) && nzchar(target))
  }
  identical_realization <- function() {
    target <- Sys.readlink(generated_root)
    if (!dir.exists(generated_root) || (!is.na(target) && nzchar(target))) {
      return(FALSE)
    }
    files <- sort(list.files(
      generated_root, all.files = TRUE, no.. = TRUE,
      recursive = TRUE, include.dirs = FALSE
    ), method = "radix")
    directories <- list.dirs(generated_root, recursive = TRUE, full.names = FALSE)
    if (!identical(files, sort(names(bytes), method = "radix")) ||
        length(directories[nzchar(directories)]) != 0L) return(FALSE)
    all(vapply(names(bytes), function(name) {
      path <- file.path(generated_root, name)
      link <- Sys.readlink(path)
      regular <- file.exists(path) && !dir.exists(path) &&
        (is.na(link) || !nzchar(link))
      regular && identical(
        readBin(path, what = "raw", n = file.info(path)$size), bytes[[name]]
      )
    }, logical(1L)))
  }
  if (path_exists(generated_root)) {
    if (identical_realization()) return(invisible(names(expected)))
    stop("Generated fictional source already exists and differs.", call. = FALSE)
  }
  source_created <- FALSE
  if (!dir.exists(source_root)) {
    if (path_exists(source_root) || !dir.create(source_root, showWarnings = FALSE)) {
      stop("Fictional source destination is invalid.", call. = FALSE)
    }
    source_created <- TRUE
  } else {
    source_link <- Sys.readlink(source_root)
    if (!is.na(source_link) && nzchar(source_link)) {
      stop("Fictional source destination is invalid.", call. = FALSE)
    }
  }
  staging <- tempfile(".generated.rrp-staging-", tmpdir = source_root)
  completed <- FALSE
  on.exit({
    if (!completed && dir.exists(staging)) {
      unlink(staging, recursive = TRUE, force = TRUE)
    }
    if (!completed && source_created && dir.exists(source_root) &&
        length(list.files(source_root, all.files = TRUE, no.. = TRUE)) == 0L) {
      unlink(source_root, recursive = TRUE, force = TRUE)
    }
  }, add = TRUE)
  if (!dir.create(staging, showWarnings = FALSE)) {
    stop("Fictional source staging failed.", call. = FALSE)
  }
  for (name in names(bytes)) {
    writeBin(bytes[[name]], file.path(staging, name))
  }
  if (path_exists(generated_root) || !file.rename(staging, generated_root)) {
    stop("Fictional source promotion failed.", call. = FALSE)
  }
  completed <- TRUE
  invisible(names(expected))
}
