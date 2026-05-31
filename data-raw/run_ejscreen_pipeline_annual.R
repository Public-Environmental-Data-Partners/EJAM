# Run the annual EJScreen pipeline with the standard annual config recipe.
#
# This is a thin wrapper around data-raw/run_ejscreen_dataset_pipeline.R.
# It applies a validated annual config first, then delegates to the existing
# runner.

if (requireNamespace("pkgload", quietly = TRUE) && file.exists(file.path(getwd(), "DESCRIPTION"))) {
  pkgload::load_all(export_all = TRUE)
} else {
  library(EJAM)
}

cfg <- EJAM:::ejscreen_pipeline_config_recipe_from_env(EJAM:::pipeline_config_annual)

EJAM:::ejscreen_pipeline_run_script(cfg)
