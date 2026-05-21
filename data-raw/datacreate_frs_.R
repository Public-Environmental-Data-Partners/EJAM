################################################################################## #
# SCRIPT TO READ AND CLEAN LATEST FRS (and FRS BY SIC) DATASETS
################################################################################## #

# Note: key FRS tables are no longer stored as .rda package data in EJAM/data/.
# They are saved as .arrow files and published through the data repository.
# EJAM downloads/loads them with dataload_dynamic().

# Note: compare frsprogramcodes, epa_programs, epa_programs_defined, etc.

################################################################################ #
## DOWNLOAD FRS info AND UPDATE/CREATE & SAVE LOCAL FILES for frs-related datasets
################################################################################ #

if (!exists("mydir") && interactive()) {
  mydir <- choose.dir(".", "Select where to save large files being downloaded and modified/prepared")
# mydir <- "~/../Downloads/EJAMbigfiles" #   where you want to save them locally
}
if (!dir.exists(mydir)) {dir.create(mydir)}
if (!exists("alreadygot")) {
  alreadygot <- FALSE
  mytemp <- tempdir()
}
cat("Starting frs_update_datasets(), which invisibly returns frs data.table and related tables are saved too \n")
# This function frs_update_datasets() used to be in a separate pkg but now in EJAM pkg

x = EJAM:::frs_update_datasets(folder = mytemp, # default would use a tempdir() but not return its name
                    downloaded_and_unzipped_already = alreadygot,
                    folder_save_as_arrow = mydir,
                    save_as_arrow_frs              = TRUE,
                    save_as_arrow_frs_by_programid = TRUE,
                    save_as_arrow_frs_by_mact      = TRUE,
                    save_as_arrow_frs_by_naics     = TRUE,
                    save_as_arrow_frs_by_sic       = TRUE,
                    save_as_data_frs              = FALSE,
                    save_as_data_frs_by_mact      = FALSE,
                    save_as_data_frs_by_naics     = FALSE,
                    save_as_data_frs_by_programid = FALSE,
                    save_as_data_frs_by_sic       = FALSE)
alreadygot <- TRUE
# dir(folder_save_as_arrow)
cat("Finished frs_update_datasets() \n")
##################################### #
# frsprogramcodes.rda
#
cat("
See EJAM/data-raw/datacreate_frsprogramcodes.R
May need to manually save updated frsprogramcodes.rda
May need to update counts too!
")
################################################################################ #
##  LOAD dataset FILES INTO MEMORY (If saved as .arrow locally but not kept in memory)
################################################################################ #
#
fold <- mydir # folder_save_as_arrow
frs_vars <- c('frs', 'frs_by_programid', 'frs_by_naics', "frs_by_sic", "frs_by_mact")
for (varname in frs_vars) {
  fname <- paste0(varname, ".arrow")
  assign(varname, value = arrow::read_ipc_file(file = file.path(fold, fname)))
}

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
