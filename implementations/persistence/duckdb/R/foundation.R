# Physical identities and exact logical-record encoding owned by this adapter.

rrp_duckdb_identity <- function() list(
  adapter_id = "reference.duckdb-persistence",
  adapter_version = "0.1.0",
  schema_version = "0.1.0",
  payload_encoding = "r-serialize-v3-hex@0.1.0"
)

rrp_duckdb_contract_reference <- function() list(
  specification_kind = "persistence_contract",
  specification_id = "platform.persistence-adapter",
  specification_version = "0.1.0"
)

rrp_duckdb_family_definitions <- function() list(
  operational_run = list(
    table = "operational_run_statuses", id = "run_status_record_id",
    columns = c(
      "runtime_run_id", "status_sequence", "run_status", "status_time",
      "as_of_time"
    )
  ),
  episode_state = list(
    table = "episode_states", id = "state_id",
    columns = c("runtime_run_id", "episode_id", "as_of_time")
  ),
  estimand_request = list(
    table = "estimand_requests", id = "request_id",
    columns = c(
      "runtime_run_id", "episode_id", "state_id", "estimand_id", "as_of_time"
    )
  ),
  provider_execution_result = list(
    table = "provider_execution_results", id = "execution_result_id",
    columns = c(
      "runtime_run_id", "provider_execution_run_id", "request_id", "state_id",
      "episode_id", "provider_id", "provider_version", "attempt_number",
      "execution_status"
    )
  ),
  estimate = list(
    table = "estimates", id = "estimate_id",
    columns = c(
      "runtime_run_id", "provider_execution_run_id", "request_id", "state_id",
      "episode_id", "estimand_id", "estimand_version", "provider_id",
      "provider_version", "as_of_time", "target_interval_start",
      "target_interval_end"
    )
  ),
  invalidation = list(
    table = "history_invalidations", id = "invalidation_id",
    columns = c(
      "target_record_family", "target_record_id", "target_runtime_run_id",
      "invalidated_at", "replacement_runtime_run_id"
    )
  )
)

rrp_duckdb_record_columns <- function(record, family) {
  switch(family,
    operational_run = list(
      runtime_run_id = record$runtime_run_id,
      status_sequence = as.integer(record$status_sequence),
      run_status = record$run_status,
      status_time = record$status_time,
      as_of_time = record$as_of_time
    ),
    episode_state = list(
      runtime_run_id = record$runtime_run_id,
      episode_id = record$episode_id,
      as_of_time = record$as_of_time
    ),
    estimand_request = list(
      runtime_run_id = record$runtime_run_id,
      episode_id = record$episode_id,
      state_id = record$state_reference$state_id,
      estimand_id = record$estimand_specification$specification_id,
      as_of_time = record$as_of_time
    ),
    provider_execution_result = list(
      runtime_run_id = record$runtime_run_id,
      provider_execution_run_id = record$provider_execution_run_id,
      request_id = record$request_id,
      state_id = record$state_id,
      episode_id = record$episode_id,
      provider_id = record$provider_reference$provider_id,
      provider_version = record$provider_reference$provider_version,
      attempt_number = as.integer(record$attempt_number),
      execution_status = record$execution_status
    ),
    estimate = list(
      runtime_run_id = record$runtime_run_id,
      provider_execution_run_id = record$provider_execution_run_id,
      request_id = record$request_id,
      state_id = record$state_reference$state_id,
      episode_id = record$episode_id,
      estimand_id = record$estimand_specification$specification_id,
      estimand_version = record$estimand_specification$specification_version,
      provider_id = record$provider_reference$provider_id,
      provider_version = record$provider_reference$provider_version,
      as_of_time = record$as_of_time,
      target_interval_start = record$target_interval_start,
      target_interval_end = record$target_interval_end
    ),
    invalidation = list(
      target_record_family = record$target_record_family,
      target_record_id = record$target_record_id,
      target_runtime_run_id = record$target_runtime_run_id,
      invalidated_at = record$invalidated_at,
      replacement_runtime_run_id = if (is.null(record$replacement_runtime_run_id)) {
        NA_character_
      } else record$replacement_runtime_run_id
    ),
    stop("Unknown DuckDB history family: ", family, call. = FALSE)
  )
}

rrp_duckdb_encode_record <- function(record) {
  bytes <- serialize(record, NULL, version = 3L)
  paste(sprintf("%02x", as.integer(bytes)), collapse = "")
}

rrp_duckdb_decode_record <- function(payload) {
  if (!is.character(payload) || length(payload) != 1L ||
      nchar(payload) %% 2L != 0L || grepl("[^0-9a-f]", payload)) {
    stop("DuckDB history contains an invalid encoded payload.", call. = FALSE)
  }
  positions <- seq.int(1L, nchar(payload), by = 2L)
  bytes <- as.raw(strtoi(substring(payload, positions, positions + 1L), 16L))
  unserialize(bytes)
}

rrp_duckdb_time_number <- function(value) {
  normalized <- sub("Z$", "+0000", value)
  normalized <- sub("([+-][0-9]{2}):([0-9]{2})$", "\\1\\2", normalized)
  as.numeric(as.POSIXct(
    normalized, format = "%Y-%m-%dT%H:%M:%OS%z", tz = "UTC"
  ))
}
