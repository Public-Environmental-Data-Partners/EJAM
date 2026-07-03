
# helper in preparing to publish newly updated .arrow files

datasets_arrow_s3_download <- function(

  yr = EJAM:::acs_endyear(guess_census_has_published = TRUE), # e.g., "2024"
  files = paste0(EJAM:::.arrow_ds_names, ".arrow"),  # e.g.,  bgej.arrow
  s3_root = "s3://pedp-data-preserved/ejscreen-data-processing/pipeline",
  local_root = file.path(getwd(), "data-raw", "pipeline_outputs"),
  aws_profile = Sys.getenv("AWS_PROFILE", unset = "")
) {
  s3_dir <- file.path(s3_root, paste0("ejscreen_acs_", yr))
  local_dir <- file.path(local_root, paste0("ejscreen_acs_", yr))
  dir.create(local_dir, recursive = TRUE, showWarnings = FALSE)

  for (fname in files) {
    src  <- file.path(s3_dir, fname)
    dest <- file.path(local_dir, fname)
    args <- c("s3", "cp", src, dest)
    env <- character(0)
    if (nzchar(aws_profile)) {
      env <- paste0("AWS_PROFILE=", aws_profile)
    }
    message("Downloading ", src, " -> ", dest)
    status <- system2("aws", args = args, env = env)
    if (!identical(status, 0L)) {
      stop("Failed downloading ", src, call. = FALSE)
    }
  }
  out <- file.path(local_dir, files)
  stopifnot(all(file.exists(out)))
  return(out)
}
############################################################### #
