# Run the annual EJScreen pipeline in exports-only mode.
#
# This is a thin wrapper around data-raw/run_ejscreen_dataset_pipeline.R.
# It applies a validated config recipe first, then delegates to the existing
# runner. It should reuse existing stages and regenerate EJScreen-facing exports.

if (requireNamespace("pkgload", quietly = TRUE) && file.exists(file.path(getwd(), "DESCRIPTION"))) {
  pkgload::load_all(export_all = TRUE)
} else {
  library(EJAM)
}

pipeline_yr <- as.integer(Sys.getenv(
  "EJAM_PIPELINE_YR",
  unset = EJAM:::acs_endyear(guess_census_has_published = TRUE, guess_always = TRUE)
))
pipeline_root <- Sys.getenv("EJAM_PIPELINE_ROOT", unset = "")
pipeline_dir <- Sys.getenv("EJAM_PIPELINE_DIR", unset = "")

cfg <- EJAM:::pipeline_config_exports_only(
  yr = pipeline_yr,
  pipeline_root = if (nzchar(pipeline_root)) pipeline_root else NULL,
  pipeline_dir = if (nzchar(pipeline_dir)) pipeline_dir else NULL,
  pipeline_storage = Sys.getenv("EJAM_PIPELINE_STORAGE", unset = "s3"),
  stage_format = Sys.getenv("EJAM_STAGE_FORMAT", unset = "csv"),
  stage_formats = Sys.getenv("EJAM_STAGE_FORMATS", unset = "csv,rda")
)

EJAM:::ejscreen_pipeline_run_script(cfg)
