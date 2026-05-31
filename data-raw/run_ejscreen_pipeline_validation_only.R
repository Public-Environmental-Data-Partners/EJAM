# Run the annual EJScreen pipeline in validation-only mode.
#
# This is a thin wrapper around data-raw/run_ejscreen_dataset_pipeline.R.
# It applies a validated config recipe first, then delegates to the existing
# runner. It should not update package data or run pre/post datacreate scripts.

if (requireNamespace("pkgload", quietly = TRUE) && file.exists(file.path(getwd(), "DESCRIPTION"))) {
  pkgload::load_all(export_all = TRUE)
} else {
  library(EJAM)
}

cfg <- EJAM:::ejscreen_pipeline_config_recipe_from_env(EJAM:::pipeline_config_validation_only)

EJAM:::ejscreen_pipeline_run_script(cfg)
