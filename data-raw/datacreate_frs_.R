
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

if (!(basename(getwd()) %in% "EJAM")) {stop("must do this script within the root of source package")}

folder_save_as_arrow = "./data-raw/pipeline_outputs/frs" # "./data"  # where to save the new .arrow files of frs-related info
refresh_frs_arrows <- tolower(Sys.getenv("EJAM_REFRESH_FRS_ARROWS", "TRUE")) %in% c("true", "t", "1", "yes", "y")

open_package_datasets_scripts = FALSE # set TRUE to open each datacreate_ script for editing

update_package_datasets = TRUE   # set TRUE to source each datacreate_ script that
# updates each .rda package dataset that depends on frs/naics/mact/sic,
# and a couple misc ones too.

if (!exists("folder_save_as_arrow") && interactive()) {
  folder_save_as_arrow <- choose.dir(".", "Select where to save large files being downloaded and modified/prepared")
  # folder_save_as_arrow <- "~/../Downloads/EJAMbigfiles" #   where you want to save them locally
}
if (!dir.exists(folder_save_as_arrow)) {dir.create(folder_save_as_arrow, recursive = TRUE)}
if (!exists("alreadygot")) {
  alreadygot <- FALSE
  mytemp <- tempdir()
}
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

    folder = mytemp, # default would use a tempdir() but not return its name
    downloaded_and_unzipped_already = alreadygot,
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
  alreadygot <- TRUE
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
for (varname in frs_vars) {
  fname <- paste0(varname, ".arrow")
  assign(varname, value = arrow::read_ipc_file(file = file.path(fold, fname)))
}
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
  "data-raw/datacreate_testinput_program_name.R",   # do after any EPA frs update
  "data-raw/datacreate_testinput_program_sys_id.R", # do after any EPA frs update
  "data-raw/datacreate_testinput_registry_id.R",    # do after any EPA frs update. used in tests.
  "data-raw/datacreate_testinput_mact.R",  ## just one code, for testing

  ## do these if updating the frs dataset, or if the naics universe of all codes changes

  "data-raw/datacreate_NAICS.R",       # in 2027, expect changes in naics codes (every 5 years, and one update was 2022). Do this after those code changes.
  "data-raw/datacreate_naicstable.R",     # after NAICS changes
  "data-raw/datacreate_testinput_naics.R", # do this when allowable NAICS code universe changes (every 5 years)
  "data-raw/datacreate_naics_counts.R",   # do after any EPA frs update  (OR if NAICS code universe) is updated, and note NAICS codes change every 5 years but NAICS info in EPA frs dataset is not be updated on same schedule!

  ## do these if updating the frs dataset, or if SIC universe ever changes (unlikely)

  "data-raw/datacreate_SIC.R",      # unlikely to ever change since transitioning from SIC to NAICS
  "data-raw/datacreate_sictable.R",  # after SIC is updated (if it ever is)
  "data-raw/datacreate_sic_counts.R",  ## must do AFTER EPA-based frs_by_sic is updated,  uses SIC and sictable and latest updated frs to update SIC
  "data-raw/datacreate_testinput_sic.R", # do if/after SIC is updated, in case SIC code universe changes

  ######################### ########################### #

  # NOT related to FRS.  Do optionally but can skip

  "data-raw/datacreate_testpoints_5_50_500.R",    # unlikely to ever change, but could rerun as a way to update metadata
  "data-raw/datacreate_testinput_address_table.R",# unlikely to ever change, but could rerun as a way to update metadata
  "data-raw/datacreate_testinput_shapes_2.R",     # unlikely to ever change, but could rerun as a way to update metadata
  "data-raw/datacreate_ejampackages.R",            # not important, somewhat obsolete, but could rerun as a way to update metadata
  #### "data-raw/datacreate_1_metadata_update.R",  # not used, not tested
  ########################## ########################### #
  "data-raw/datacreate_meters_per_mile.R"  # will not change, but could rerun as a way to update metadata

)
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


