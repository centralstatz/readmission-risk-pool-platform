# Independent adopter-producer conformance fixture

This directory is test evidence, not a second shipped reference health system
and not a template to copy literally. It simulates implementation-owned code
that an adopter supplies to one isolated platform installation.

The fictional source has two objects unlike the shipped synthetic ecosystem:

- `case_extract` is a denormalized discharge export containing local composite
  case IDs, encounter timing, follow-up bounds, and locally recorded terminal
  facts;
- `activity_feed` is a longitudinal feed joined by the local case ID, with
  local codes and separate occurrence and load times.

The fixture owns its source validation, identifier normalization, vocabulary
translation, timestamp normalization, configuration, declaration, and mapping.
Trusted test composition explicitly pairs its declaration and callable and
selects it as the only producer. Generic execution, canonical admission,
runtime, provider, DuckDB history, products, app, and artifact code remain the
same code used by the shipped reference composition.

All records are deterministic, fictional, nonclinical, and safe to commit.
They do not mimic a vendor or real organization. The fixture is not production
guidance, clinical validation, a packaging decision, or permission to place
private source mappings in the public core repository.
