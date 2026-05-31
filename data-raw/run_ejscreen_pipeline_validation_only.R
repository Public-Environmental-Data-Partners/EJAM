# Run the annual EJScreen pipeline in validation-only mode.
#
# This is a thin wrapper around the package pipeline runner. It applies a
# validated config recipe first, then runs without package-data replacement or
# pre/post datacreate scripts.

if (requireNamespace("pkgload", quietly = TRUE) && file.exists(file.path(getwd(), "DESCRIPTION"))) {
  pkgload::load_all(export_all = TRUE)
} else {
  library(EJAM)
}

EJAM:::ejscreen_pipeline_run_recipe(EJAM:::pipeline_config_validation_only)
