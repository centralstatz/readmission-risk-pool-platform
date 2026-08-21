# Editable trusted callable scaffold. It fails explicitly and produces no
# canonical output until a recipient replaces this function with conforming
# source validation and mapping.

rrp_local_hospital_producer_adapter <- function(distribution_root, declaration) {
  force(distribution_root)
  force(declaration)
  function(invocation) {
    rrp_new_canonical_producer_adapter_result(
      status = "failed",
      producer_execution_id = invocation$producer_execution_id,
      implementation_identity = declaration$implementation_identity,
      mapping_identity = declaration$mapping_identity,
      canonical_profile = NULL,
      canonical_as_of_time = invocation$canonical_as_of_time %||% NA_character_,
      capabilities = declaration$capabilities,
      stage_statuses = c(
        producer_configuration = "failed",
        source_local_validation = "not_run",
        mapping = "not_run"
      ),
      summary = list(configuration_status = "not_implemented")
    )
  }
}
