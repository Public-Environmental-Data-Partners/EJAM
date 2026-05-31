# Run the annual EJScreen pipeline with the standard annual config recipe.
#
# This is a thin wrapper around the package pipeline runner. It applies a
# validated annual config first, then delegates to run_ejscreen_pipeline().

if (requireNamespace("pkgload", quietly = TRUE) && file.exists(file.path(getwd(), "DESCRIPTION"))) {
  pkgload::load_all(export_all = TRUE)
} else {
  library(EJAM)
}

EJAM:::ejscreen_pipeline_run_recipe(EJAM:::pipeline_config_annual)
