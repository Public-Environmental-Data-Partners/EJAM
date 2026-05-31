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

EJAM:::ejscreen_pipeline_run_recipe_script(EJAM:::pipeline_config_annual)
