# Run the annual EJScreen pipeline in exports-only mode.
#
# This is a thin wrapper around the package pipeline runner. It applies a
# validated config recipe first, then reuses existing stages and regenerates
# EJScreen-facing exports.

if (requireNamespace("pkgload", quietly = TRUE) && file.exists(file.path(getwd(), "DESCRIPTION"))) {
  pkgload::load_all(export_all = TRUE)
} else {
  library(EJAM)
}

EJAM:::ejscreen_pipeline_run_recipe(EJAM:::pipeline_config_exports_only)
