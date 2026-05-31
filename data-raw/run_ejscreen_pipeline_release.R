# Run the annual EJScreen pipeline with the release config recipe.
#
# This is a thin wrapper around data-raw/run_ejscreen_dataset_pipeline.R.
# It keeps package-data replacement opt-in; set EJAM_REPLACE_PACKAGE_DATA=TRUE
# explicitly when the reviewed outputs should replace package .rda objects.

if (requireNamespace("pkgload", quietly = TRUE) && file.exists(file.path(getwd(), "DESCRIPTION"))) {
  pkgload::load_all(export_all = TRUE)
} else {
  library(EJAM)
}

EJAM:::ejscreen_pipeline_run_recipe_script(EJAM:::pipeline_config_release)
