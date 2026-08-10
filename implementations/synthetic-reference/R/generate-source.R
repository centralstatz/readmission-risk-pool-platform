# Deterministic fictional source generation. These tables intentionally use
# local names and codes so mapping remains a real boundary.

rrp_synthetic_id <- function(prefix, index) {
  paste0("synthetic_", prefix, "_", sprintf("%06d", as.integer(index)))
}

rrp_synthetic_parse_time <- function(value) {
  as.POSIXct(rrp_timestamp_number(value), origin = "1970-01-01", tz = "UTC")
}

rrp_synthetic_format_time <- function(value) {
  format(as.POSIXct(value, origin = "1970-01-01", tz = "UTC"),
         "%Y-%m-%dT%H:%M:%SZ", tz = "UTC")
}

rrp_synthetic_with_seed <- function(seed, expression) {
  had_seed <- exists(".Random.seed", envir = .GlobalEnv, inherits = FALSE)
  if (had_seed) previous_seed <- get(".Random.seed", envir = .GlobalEnv)
  on.exit({
    if (had_seed) {
      assign(".Random.seed", previous_seed, envir = .GlobalEnv)
    } else if (exists(".Random.seed", envir = .GlobalEnv, inherits = FALSE)) {
      rm(".Random.seed", envir = .GlobalEnv)
    }
  }, add = TRUE)
  set.seed(as.integer(seed), kind = "Mersenne-Twister", normal.kind = "Inversion")
  force(expression)
}

rrp_synthetic_empty_table <- function(columns) {
  values <- lapply(columns, function(type) {
    switch(
      type,
      character = character(),
      integer = integer(),
      numeric = numeric(),
      logical = logical(),
      character()
    )
  })
  names(values) <- names(columns)
  as.data.frame(values, stringsAsFactors = FALSE)
}

rrp_generate_synthetic_source <- function(config) {
  rrp_synthetic_with_seed(config$seed, {
    patient_count <- as.integer(config$patient_count)
    episode_count <- as.integer(config$episode_count)
    followup_days <- as.integer(config$followup_window_days)
    as_of <- rrp_synthetic_parse_time(config$simulation_as_of_time)

    patients <- data.frame(
      patient_key = vapply(seq_len(patient_count), function(index) {
        rrp_synthetic_id("patient", index)
      }, character(1)),
      fictional_birth_year = as.integer(
        1935L + ((seq_len(patient_count) * 17L + as.integer(config$seed)) %% 68L)
      ),
      fictional_region_code = paste0(
        "fictional_region_", letters[((seq_len(patient_count) - 1L) %% 4L) + 1L]
      ),
      stringsAsFactors = FALSE
    )

    episode_indices <- seq_len(episode_count)
    patient_indices <- ((episode_indices - 1L) %% patient_count) + 1L
    discharge_offsets <- (episode_count - episode_indices) * 2L +
      sample.int(2L, episode_count, replace = TRUE)
    discharge_times <- as_of - discharge_offsets * 86400 -
      sample(0:5, episode_count, replace = TRUE) * 3600
    stay_days <- sample(2:6, episode_count, replace = TRUE)
    admission_times <- discharge_times - stay_days * 86400
    index_encounter_ids <- vapply(episode_indices, function(index) {
      rrp_synthetic_id("encounter", index)
    }, character(1))
    discharge_ids <- vapply(episode_indices, function(index) {
      rrp_synthetic_id("discharge", index)
    }, character(1))

    encounters <- data.frame(
      encounter_key = index_encounter_ids,
      patient_key = patients$patient_key[patient_indices],
      encounter_class = "index_inpatient",
      admitted_at = vapply(admission_times, rrp_synthetic_format_time, character(1)),
      discharged_at = vapply(discharge_times, rrp_synthetic_format_time, character(1)),
      stringsAsFactors = FALSE
    )
    discharges <- data.frame(
      discharge_key = discharge_ids,
      encounter_key = index_encounter_ids,
      followup_days = rep.int(followup_days, episode_count),
      source_episode_label = paste0("fictional_local_case_", (episode_indices %% 5L) + 1L),
      stringsAsFactors = FALSE
    )

    risk_indices <- episode_indices[episode_indices %% 4L != 0L]
    if (length(risk_indices) == 0L) {
      risk_scores <- rrp_synthetic_empty_table(c(
        score_key = "character", discharge_key = "character", score_code = "character",
        score_version = "character", assessed_at = "character", received_at = "character",
        score_probability = "numeric", source_queue_label = "character"
      ))
    } else {
      assessed <- discharge_times[risk_indices] - 2 * 3600
      delays <- ifelse(risk_indices %% 6L == 0L, 8 * 3600, 30 * 60)
      probabilities <- pmin(
        0.82,
        pmax(0.03, 0.08 + ((risk_indices * 13L + as.integer(config$seed)) %% 55L) / 100)
      )
      risk_scores <- data.frame(
        score_key = vapply(risk_indices, function(index) rrp_synthetic_id("score", index), character(1)),
        discharge_key = discharge_ids[risk_indices],
        score_code = "local_readmit_probability",
        score_version = "1.0.0",
        assessed_at = vapply(assessed, rrp_synthetic_format_time, character(1)),
        received_at = vapply(assessed + delays, rrp_synthetic_format_time, character(1)),
        score_probability = as.numeric(probabilities),
        source_queue_label = ifelse(probabilities >= 0.35, "local_review", "routine"),
        stringsAsFactors = FALSE
      )
    }

    activity_rows <- list()
    activity_index <- 0L
    source_codes <- c(
      "transition_call_complete", "ambulatory_followup",
      "emergency_visit", "medication_barrier"
    )
    for (episode_index in episode_indices) {
      event_count <- (episode_index + as.integer(config$seed)) %% 3L
      if (event_count == 0L) next
      for (event_number in seq_len(event_count)) {
        activity_index <- activity_index + 1L
        occurred <- discharge_times[[episode_index]] +
          (2L + (event_number - 1L) * 4L) * 86400 + event_number * 1800
        received <- occurred + (event_number * 2L + episode_index %% 4L) * 3600
        if (episode_index %% 9L == 0L) {
          received <- max(received, as_of + 6 * 3600)
        }
        activity_rows[[activity_index]] <- data.frame(
          event_key = rrp_synthetic_id("activity", activity_index),
          discharge_key = discharge_ids[[episode_index]],
          event_code = source_codes[[
            ((episode_index + event_number + as.integer(config$seed)) %% length(source_codes)) + 1L
          ]],
          occurred_at = rrp_synthetic_format_time(occurred),
          received_at = rrp_synthetic_format_time(received),
          source_note_class = paste0("fictional_note_class_", event_number),
          stringsAsFactors = FALSE
        )
      }
    }
    activity_events <- if (length(activity_rows) == 0L) {
      rrp_synthetic_empty_table(c(
        event_key = "character", discharge_key = "character", event_code = "character",
        occurred_at = "character", received_at = "character", source_note_class = "character"
      ))
    } else {
      do.call(rbind, activity_rows)
    }
    rownames(activity_events) <- NULL

    outcome_rows <- list()
    readmission_encounters <- list()
    outcome_index <- 0L
    readmission_index <- 0L
    for (episode_index in episode_indices) {
      outcome_code <- if (episode_index %% 7L == 0L) {
        "death"
      } else if (episode_index %% 5L == 0L) {
        "readmission"
      } else {
        NA_character_
      }
      if (is.na(outcome_code)) next
      outcome_index <- outcome_index + 1L
      occurred <- discharge_times[[episode_index]] +
        if (identical(outcome_code, "readmission")) 10 * 86400 else 14 * 86400
      received <- occurred + if (episode_index %% 10L == 0L) 16 * 3600 else 2 * 3600
      related_encounter <- NA_character_
      if (identical(outcome_code, "readmission")) {
        readmission_index <- readmission_index + 1L
        related_encounter <- rrp_synthetic_id(
          "encounter", episode_count + readmission_index
        )
        readmission_encounters[[readmission_index]] <- data.frame(
          encounter_key = related_encounter,
          patient_key = patients$patient_key[[patient_indices[[episode_index]]]],
          encounter_class = "readmission_inpatient",
          admitted_at = rrp_synthetic_format_time(occurred),
          discharged_at = rrp_synthetic_format_time(occurred + 2 * 86400),
          stringsAsFactors = FALSE
        )
      }
      outcome_rows[[outcome_index]] <- data.frame(
        outcome_key = rrp_synthetic_id("outcome", outcome_index),
        discharge_key = discharge_ids[[episode_index]],
        outcome_code = outcome_code,
        occurred_at = rrp_synthetic_format_time(occurred),
        received_at = rrp_synthetic_format_time(received),
        related_encounter_key = related_encounter,
        stringsAsFactors = FALSE
      )
    }
    if (length(readmission_encounters) > 0L) {
      encounters <- rbind(encounters, do.call(rbind, readmission_encounters))
      rownames(encounters) <- NULL
    }
    outcomes <- if (length(outcome_rows) == 0L) {
      rrp_synthetic_empty_table(c(
        outcome_key = "character", discharge_key = "character", outcome_code = "character",
        occurred_at = "character", received_at = "character",
        related_encounter_key = "character"
      ))
    } else {
      do.call(rbind, outcome_rows)
    }
    rownames(outcomes) <- NULL

    list(
      patients = patients,
      encounters = encounters,
      discharges = discharges,
      risk_scores = risk_scores,
      activity_events = activity_events,
      outcomes = outcomes
    )
  })
}

