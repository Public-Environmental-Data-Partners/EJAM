
# These are just notes for manually publishing updated .arrow files to ejamdata repo
# for 2026 especially (v2.5.0)

############################################################### #
#   DOWNLOAD just-updated .arrow files if not already saved locally
#   PUBLISH just-updated .arrow files to ejamdata repo with tag etc.
############################################################### #

# DOWNLOAD OR FIND LOCALLY ####

frs_file = paste0( c("frs", "frs_by_programid", "frs_by_naics", "frs_by_sic",  "frs_by_mact"), ".arrow")
block_file = paste0( c("blockwts", "blockpoints", "quaddata", "bgid2fips", "blockid2fips"), ".arrow")
bgej_file = "bgej.arrow"
stopifnot(setequal(paste0(EJAM:::.arrow_ds_names, ".arrow"), c(frs_file, block_file, bgej_file)))
# note some code assumed that mact_table.arrow would also be saved like those, but it is a .rda file in data folder already

## if have local already (as for v2.5.0 update)
frs_path   = file.path("data-raw/pipeline_outputs/frs", frs_file)
block_path = file.path("data", block_file)
bgej_path  = file.path("data", bgej_file)

## if getting from s3:
# frs_path   = datasets_arrow_s3_download(files = frs_file)
# block_path = datasets_arrow_s3_download(files = block_file)
# bgej_path  = datasets_arrow_s3_download(files = bgej_file)

## SPECIFY IF ONLY FRS FILES OR ALL THESE WILL BE UPDATED THIS TIME:
files_to_publish <- c(frs_path, block_path, bgej_path)

############################################################### #

# PUBLISH ####

EJAM:::datasets_arrow_publish(
  files = files_to_publish,
  tag = "v2.5.0",
  dry_run     = F,  #   FALSE # if ready after reviewing the dry run
  overwrite   = T, # FALSE, #   TRUE # if ready after reviewing the dry run
  mark_latest = FALSE
)
############################################################### #

# see  EJAM/vignettes/dev-update-datasets.Rmd also
# browseURL(paste0(EJAM:::url_package("data", get_full_url = T), "/releases"))
