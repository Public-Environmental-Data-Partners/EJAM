
################################################################################ #
## DOWNLOAD LATEST FRS info AND UPDATE/CREATE & SAVE LOCAL FILES for frs-related datasets
## including both .arrow and .rda files
################################################################################ #

# relies on  frs_update_datasets() for .arrow files
# and this sources other datacreate_ scripts to update the package .rda files

## Note that there was overlapping code in these two files, likely obsolete:
###"data-raw/datacreate_frs_by_mact.R", ## obsolete notes ? need to clarify
###"data-raw/datacreate_frs_by_sic.R",  ## obsolete notes ? need to clarify

################################################################################## #

# Note: key FRS tables are no longer stored as .rda package data in EJAM/data/.
# They are saved as .arrow files and published through the data repository.
# EJAM downloads/loads them with dataload_dynamic().

# Note: compare frsprogramcodes, epa_programs, epa_programs_defined, etc.

# Note: EPA ECHO database info on how often it gets updated with new FRS data:
# https://echo.epa.gov/resources/echo-data/about-the-data#sources
################################################################################## #
if (!file.exists(file.path(getwd(), "DESCRIPTION")) || desc::desc_get(file = "DESCRIPTION", keys = "Package") != "EJAM") {stop('do this from EJAM source package folder')}
library(data.table) # sourced datacreate scripts use setDT(), setDF(), and .N
# if (basename(getwd()) != "EJAM") {stop('do this from EJAM source package folder')} # fails if you put the source in a worktree like one named after a branch

folder_save_as_arrow <- Sys.getenv(
  "EJAM_FRS_ARROW_OUTPUT", "./data-raw/pipeline_outputs/frs"
) # keep the new files separate from installed/cached release assets
refresh_frs_arrows <- tolower(Sys.getenv("EJAM_REFRESH_FRS_ARROWS", "TRUE")) %in% c("true", "t", "1", "yes", "y")

open_package_datasets_scripts = FALSE # set TRUE to open each datacreate_ script for editing

update_package_datasets = TRUE   # set TRUE to source each datacreate_ script that
# updates each .rda package dataset that depends on frs/naics/mact/sic,
# plus the sample input files.

if (!dir.exists(folder_save_as_arrow)) {dir.create(folder_save_as_arrow, recursive = TRUE)}
################################################################################ #

# 1) SAVE .arrow FILES LOCALLY ####

## >> frs_update_datasets() << ####

expected_frs_arrow_files <- file.path(
  folder_save_as_arrow,
  paste0(c("frs", "frs_by_programid", "frs_by_mact", "frs_by_naics", "frs_by_sic"), ".arrow")
)
if (isTRUE(refresh_frs_arrows) || !all(file.exists(expected_frs_arrow_files))) {
  cat("Starting frs_update_datasets(), which invisibly returns frs data.table and
all related .arrow files are saved too \n")

  x = EJAM:::frs_update_datasets(

    folder = tempdir(),
    downloaded_and_unzipped_already = FALSE,
    folder_save_as_arrow = folder_save_as_arrow,

    save_as_arrow_frs              = TRUE,
    save_as_arrow_frs_by_programid = TRUE,
    save_as_arrow_frs_by_mact      = TRUE,
    save_as_arrow_frs_by_naics     = TRUE,
    save_as_arrow_frs_by_sic       = TRUE,
    save_as_data_frs              = FALSE,
    save_as_data_frs_by_mact      = FALSE,
    save_as_data_frs_by_naics     = FALSE,
    save_as_data_frs_by_programid = FALSE,
    save_as_data_frs_by_sic       = FALSE
  )
  # dir(folder_save_as_arrow)
  message("Finished saving .arrow files locally in", folder_save_as_arrow, "via frs_update_datasets() \n")
} else {
  message("Skipping FRS download because EJAM_REFRESH_FRS_ARROWS is FALSE and expected .arrow files already exist in ", folder_save_as_arrow, ".")
}
################################################################################ #

## to later reload datasets  (if NOT kept in memory) ####
#
fold <- folder_save_as_arrow
frs_vars <- c('frs', 'frs_by_programid', 'frs_by_naics', "frs_by_sic", "frs_by_mact")
metadata_fields <- c(
  "download_date", "released", "ejam_package_version", "ejscreen_version",
  "ejscreen_releasedate", "acs_releasedate", "acs_version",
  "census_version", "date_saved_in_package"
)
for (varname in frs_vars) {
  fname <- paste0(varname, ".arrow")
  assign(varname, value = arrow::read_ipc_file(file = file.path(fold, fname)))
  missing_metadata <- metadata_fields[vapply(
    metadata_fields, function(field) is.null(attr(get(varname), field)), logical(1)
  )]
  if (length(missing_metadata)) {
    stop(varname, ".arrow is missing metadata: ", paste(missing_metadata, collapse = ", "))
  }
}
for (field in metadata_fields) {
  values <- lapply(frs_vars, function(varname) attr(get(varname), field))
  if (!all(vapply(values[-1], identical, logical(1), values[[1]]))) {
    stop("FRS Arrow files disagree on metadata field: ", field)
  }
}
description_fields <- c(
  ejam_package_version = "Version",
  ejscreen_version = "VersionEJSCREEN",
  ejscreen_releasedate = "ReleaseDateEJSCREEN",
  acs_releasedate = "ReleaseDateACS",
  acs_version = "VersionACS",
  census_version = "VersionCensus"
)
for (field in names(description_fields)) {
  if (!identical(
    unname(as.character(attr(frs, field))),
    as.character(desc::desc_get(description_fields[[field]]))
  )) {
    stop("FRS Arrow metadata does not match DESCRIPTION: ", field)
  }
}

# mact_table is package data, not a dynamic ejamdata release asset.
load(file.path(folder_save_as_arrow, "mact_table.rda"))
usethis::use_data(mact_table, overwrite = TRUE)
################################################################################ #
## Move .arrow files to new release on ejamdata repo or elsewhere ####

cat("NOTE: You may now publish updated FRS .arrow files to an ejamdata release.\n")
cat("This script does NOT publish them automatically. Use dry_run = TRUE first.\n")
## also see run_arrow_publish_v2.5.0.R or could be done via pipeline
# frs_arrow_files <- file.path(folder_save_as_arrow, paste0(frs_vars, ".arrow"))
# EJAM:::datasets_arrow_publish(
#   files = frs_arrow_files,
#   tag = EJAM:::ejamdata_required_tag(),
#   release_date = Sys.Date(),
#   dry_run = TRUE,
#   overwrite = FALSE,
#   mark_latest = FALSE
# )

################################################################################ #
## Documentation ####
cat("
NOW, UPDATE THE DOCUMENTATION MANUALLY in relevant files like data_frs.R,
since dataset_documenter() only works well for simple documentation and these are complicated to explain.
REMEMBER TO USE a NULL AT THE END of the .R file that documents each.
FRS tables are documented like datasets but are not .rda package data;
they are .arrow files loaded with dataload_dynamic().\n")
if (rstudioapi::isAvailable()) {
  for (myvar in frs_vars) {
    rstudioapi::documentOpen(paste0('./R/data_', myvar, '.R'))
  }
}
################################################################################ #
################################################################################ #

# 2) UPDATE/SAVE RELATED .rda files, in-package DATASETS  ####

## datacreate_scripts_to_source ####

datacreate_scripts_to_source <- c(

  ########################## ########################### #
  #
  ## For FRS (facilities) updates,
  ## NOT for annual update of blockgroup data
  ##
  ## This is EPA-derived information,
  ## not necessarily linked to annual blockgroup data update,
  ## for whenever ready to obtain snapshot of the latest frs info -
  ##  frs has constantly changing regulated facility ids, locations, or naics/sic/mact/program info
  ## Note some of these are .arrow format datasets, namely:
  ##   "frs",  "frs_by_mact", "frs_by_programid", "frs_by_naics", "frs_by_sic"
  ######################### ########################### #

  # >> FRS-based datasets ####

  ## do these in this order, after the frs .arrow updates above,
  ## to update the .rda files used by the package, that are related to the frs dataset

  "data-raw/datacreate_frsprogramcodes.R", ## a few codes useful for testing

  "data-raw/datacreate_epa_programs_defined.R", # a download;  might be outdated; unused except to create epa_programs
  "data-raw/datacreate_epa_programs.R",  # created from frs_by_programid and # also needs epa_programs_defined

  "data-raw/datacreate_testdata_frs.R", #  ## just random samples of frs ids in .csv and .xlsx files for inst/testdata
  "data-raw/datacreate_testdata_frs_programid.R", # current FRS program-ID upload examples
  "data-raw/datacreate_testdata_frs_example.R", # drop retired IDs from historical ECHO example
  "data-raw/datacreate_testinput_program_name.R",   # do after any EPA frs update
  "data-raw/datacreate_testinput_program_sys_id.R", # do after any EPA frs update
  "data-raw/datacreate_testinput_registry_id.R",    # do after any EPA frs update. used in tests.
  "data-raw/datacreate_testinput_mact.R",  ## just one code, for testing

  ## do these if updating the frs dataset, or if the naics universe of all codes changes

  "data-raw/datacreate_naics_counts.R",   # do after any EPA frs update  (OR if NAICS code universe) is updated, and note NAICS codes change every 5 years but NAICS info in EPA frs dataset is not be updated on same schedule!

  ## do these if updating the frs dataset, or if SIC universe ever changes (unlikely)

  "data-raw/datacreate_sic_counts.R",  ## refreshes FRS counts/labels in SIC using the existing code universe and sictable
  "data-raw/datacreate_testinput_sic.R" # verify saved SIC example against new FRS

)
# If the NAICS or SIC *code universe* changed, separately review and run
# datacreate_NAICS.R -> datacreate_naicstable.R -> datacreate_testinput_naics.R,
# or datacreate_sictable.R before rebuilding the FRS-derived counts above.
###################################################### #
if (open_package_datasets_scripts) {
  ## open and check the scripts ####

  for (fpath in datacreate_scripts_to_source) {
    cat(paste0("rstudioapi::documentOpen('", fpath,"')"), '\n')
  }
}
###################################################### #
if (update_package_datasets) {
  ## run scripts, create/update .rda pkg datasets ####

  for (fpath in datacreate_scripts_to_source) {
    cat("sourcing the script in", fpath, "...\n")
    source(fpath)
    cat("--------------------------------------------------------\n")
  }
  ######################################### ########################################## #
}
