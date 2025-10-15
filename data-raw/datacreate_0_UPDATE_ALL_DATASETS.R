############################################################### #
## Scripts to update / create latest versions of datasets
# - ANNUAL blockgroup data from ACS and EJSCREEN
# - NON-ANNUAL (frequent, episodic, etc.) other datasets
# also see EJAM pkg github issues about this.
############################################################### #

######################################### ########################################## #
######################################### ########################################## #

# SETUP ####

rm(list = ls())

## folders ####

localfolder  <- "~/Downloads/EJAMbigfiles"
if (!dir.exists(localfolder)) {localfolder <- "~"}
if (interactive()) {localfolder <- rstudioapi::selectDirectory(
  "Confirm where to archive .arrow and other files locally",
  path = localfolder) }
if (!dir.exists(localfolder)) {stop(paste0("need valid localfolder - ", localfolder, " was not found"))}

if (!exists("td")) {td <- tempdir() }
if (!exists("rawdir")) {rawdir <- './data-raw'}
if (!dir.exists(rawdir)) {stop("need to do this from source package folder, from where it can find a folder at ", rawdir)}
######################################### #

## helper functions ####

if (!exists("askquestions")) {askquestions <- FALSE}
if (interactive()) {
  askquestions <- askYesNo("Do you want to answer questions interactively like this about what to save where, etc.?
                           (vs running all scripts without pauses)",
                           default = askquestions)
  if (is.na("askquestions")) {stop("halted")}
} # leave blank line below this so sourcing it will use default

######################################### #
consoleclear <- EJAM:::consoleclear()
######################################### #
loadall <- function() {
  cat("\nReloading from source so that the updated datasets will get lazyloaded instead of previously loaded or installed versions...\n\n")
  devtools::load_all()}
######################################### #
rmost2 <- function(notremove = c(
  c("askquestions", "localfolder", "td", "rawdir",
    "source_maybe", "consoleclear" ,  "reload", "rmost2", "loadall"),
  .arrow_ds_names
)) {rmost(notremove = notremove)}
######################################### #
source_maybe <- function(scriptname = NULL,
                         DOIT = TRUE,
                         question = paste0("Do ", scriptname, "?"),
                         folder = NULL) {
  if (is.null(scriptname)) {stop("requires scriptname")}
  if (missing(folder)) {
    if ( exists("rawdir")) {folder <- rawdir}
    if (!exists("rawdir")) {folder <- "./data-raw"}
  }
  if (!exists('askquestions')) {askquestions <- TRUE}
  if (askquestions && interactive()) {
    DOIT <- utils::askYesNo(question)
    if (!is.na(DOIT) && DOIT) {DOIT <- TRUE}
  }
  if (DOIT) {
    spath <- file.path(folder, scriptname)
    if (!file.exists(spath)) {stop(paste0("requires valid folder and scriptname. Tried: ", spath))}
    cat(paste0("Doing ", scriptname, " \n"))
    source(spath)
  } else {
    cat("Skipping ", scriptname, "\n")
  }
}
######################################### ########################################## #
######################################### ########################################## #


## DESCRIPTION ####

desc::desc_print()
cat('Version metadata as found in DESCRIPTION file and global_defaults_*.R files \n')
print(desc::desc_get_version())
if (askquestions && interactive()) {
  y <- askYesNo("Do you first need to update metadata (version, etc.), which is in DESCRIPTION file? ",
                default = FALSE)
} else {y <- FALSE}
if (y) {
  usethis::edit_file('DESCRIPTION')
}
######################################### ########################################## #
## metadata notes ####
#
#   metadata_mapping() uses DESCRIPTION info and gets done via devtools::load_all() or library(EJAM)
# see also EJAM:::metadata_update_attr()

## use simple metadata for data not related to EJSCREEN or Census, like just frs-related, naics-related, etc.
# attr(x, "date_downloaded")       <- as.character(Sys.Date()) # if relevant
# attr(x, "date_saved_in_package") <- as.character(Sys.Date())

## use full metadata if related to ejscreen or census/acs
# x <- metadata_add(x)
######################################### #
# As of 2024-08-29

#                name                                        title  type file_size             created ejscreen_version varnames

# 1               frs              frs data from EJScreen for EJAM arrow   146.01M 2024-08-05 14:42:49             2.32     TRUE
# 2       frs_by_mact      frs_by_mact data from EJScreen for EJAM arrow     4.63M 2024-08-05 14:43:17             2.32     TRUE
# 3        frs_by_sic       frs_by_sic data from EJScreen for EJAM arrow    20.25M 2024-08-05 14:43:21             2.32     TRUE
# 4      frs_by_naics     frs_by_naics data from EJScreen for EJAM arrow    14.68M 2024-08-05 14:43:28             2.32     TRUE
# 5  frs_by_programid frs_by_programid data from EJScreen for EJAM arrow    154.7M 2024-08-05 14:43:33             2.32     TRUE
# 6         bgid2fips                      bgid2fips data for EJAM arrow     2.98M 2024-08-22 18:34:28             2.32     TRUE
# 7      blockid2fips                   blockid2fips data for EJAM arrow    98.17M 2024-08-22 18:34:34             2.32     TRUE
# 8       blockpoints                    blockpoints data for EJAM arrow   155.97M 2024-08-22 18:34:56             2.32     TRUE
# 9          blockwts         blockwts data from EJ Screen for EJAM arrow    68.64M 2024-08-22 18:35:34             2.32     TRUE
# 10         quaddata                       quaddata data for EJAM arrow   218.36M 2024-08-22 18:35:52             2.32     TRUE
# 11             bgej             bgej data from EJ Screen for EJAM arrow    84.94M 2024-08-22 18:54:56             2.32     TRUE

########################################## #

## > loadall, require ####

# Get latest source functions and data:
# from  EJAM/R/*.R and EJAM/data/*.rda
# Attaches exported + internal functions & data
# like metadata_add(), newly saved .rda files, etc.
#  Otherwise internal functions don't work in scripts, and it would use installed not new source versions.

golem::detach_all_attached()

require(devtools)
require(rstudioapi)

loadall()

######################################### ########################################## #
#
## List of datacreate_ files ####
## & when to use each
# fnames <- dir(rawdir, pattern = 'datacreate_')
# cat("\n \n\n", "To open & edit one of the datacreate_ files,
#     you can source a line below\n\n",
#     paste0(paste0(
#       "\t documentOpen('", rawdir, "/", fnames, "')"), collapse = "\n"))
if (0 == 1) {  # collapsable list
  ####   THESE ARE SORTED INTO GROUPS THAT GO TOGETHER :
  x <- c("datacreate_0_UPDATE_ALL_DATASETS.R", "datacreate_0_UPDATE_ALL_DOCUMENTATION_pkgdown.R",

         "datacreate_map_headernames.R", "datacreate_names_of_indicators.R", "datacreate_names_pct_as_fraction.R",
         "datacreate_1_metadata_update.R", "datacreate_runtime_models.R",

         # Census/ACS/geo-related datasets etc.
         "datacreate_blockwts.R", "datacreate_bg_cenpop2020.R", "datacreate_bgpts.R", "datacreate_states_shapefile.R", "datacreate_stateinfo.R", "datacreate_stateinfo2.R", "datacreate_islandareas.R", "datacreate_censusplaces.R",

         "datacreate_blockgroupstats2.32.R", "datacreate_blockgroupstats2.32_add_d_acs22columns.R",  "datacreate_blockgroupstats2.32_recalc_language.R", "datacreate_blockgroupstats_extra_api_vars.R",
         "datacreate_usastats2.32.R", "datacreate_usastats2.32_add_dsubgroups.R", "datacreate_avg.in.us.R", "datacreate_high_pctiles_tied_with_min.R", "datacreate_formulas.R",

         # testdata nonstandard names, not testinput_ or testoutput_
         "datacreate_testpoints_testoutputs.R",  "datacreate_testpoints_5_50_500.R",
         "datacreate_testdata_frs.R",  "datacreate_testinput_shapes_2.R",
         # testdata standard names, testinput_ or testoutput_
         "datacreate_testinput_address_table.R", "datacreate_testinput_fips.R", "datacreate_testinput_mact.R", "datacreate_testinput_naics.R", "datacreate_testinput_program_name.R", "datacreate_testinput_sic.R",
         "datacreate_ejscreenRESTbroker2table_na_filler.R", "datacreate_default_points_shown_at_startup.R", "datacreate_testoutput_ejscreenit_or_ejscreenapi_plus_50.R",
         "datacreate_testinput_program_sys_id.R", "datacreate_testinput_registry_id.R",
         "datacreate_testoutput_ejamit_fips_.R", "datacreate_testoutput_ejamit_shapes_2.R",

         # facility-related datasets etc.
         "datacreate_frs_.R", "datacreate_frs_by_mact.R", "datacreate_frs_by_sic.R", "datacreate_frsprogramcodes.R", "datacreate_epa_programs.R",
         "datacreate_epa_programs_defined.R", "datacreate_naics_counts.R", "datacreate_naicstable.R", "datacreate_SIC.R", "datacreate_sic_counts.R", "datacreate_sictable.R",
         "datacreate_lat_alias.R", "datacreate_ejampackages.R", "datacreate_meters_per_mile.R"
  )
  setdiff(x, dir(rawdir, pattern = 'datacreate_') )   # confirm the organized list x is completely reflecting current actual files
  setdiff( dir(rawdir, pattern = 'datacreate_'), x )
  cat("\n \n\n", "To open & edit one of the datacreate_ files,
    you can source a line below\n\n",
      paste0(paste0(
        "\t documentOpen('", rawdir, "/", x, "')"), collapse = "\n"))
  # cbind(x)
  rm(x)
  ####################################### #
  {  # overall
    documentOpen('./data-raw/datacreate_0_UPDATE_ALL_DATASETS.R')
    # documentOpen('./data-raw/datacreate_0_UPDATE_ALL_DOCUMENTATION_pkgdown.R')

    # with annual census fips codes or boundaries changes (when EJSCREEN incorporates those)
    #
    # To create and save the datasets from within the EJAM source package root folder,
    #
    ##  new indicators, variable names
    documentOpen('./data-raw/datacreate_map_headernames.R')       # ok
    documentOpen('./data-raw/datacreate_names_of_indicators.R')   # ok
    documentOpen('./data-raw/datacreate_names_pct_as_fraction.R') # ok

    documentOpen('./data-raw/datacreate_1_metadata_update.R')
    documentOpen('./data-raw/datacreate_runtime_models.R')

    #   blocks
    documentOpen('./data-raw/datacreate_blockwts.R')           # needs Island Areas added
    #    and be sure to obtain correct version either from census or directly from ejscreen team

    #   blockgroups
    documentOpen('./data-raw/datacreate_bg_cenpop2020.R')      # confirm if changed since 2020
    documentOpen('./data-raw/datacreate_bgpts.R')              # redundant w bg_cenpop2020, pick one to use
    #   states
    documentOpen('./data-raw/datacreate_states_shapefile.R')   # check if want 2020 or 2022+ file
    documentOpen('./data-raw/datacreate_stateinfo.R')          # ok (missing Island Areas)
    documentOpen('./data-raw/datacreate_stateinfo2.R')         # ok (has Island Areas)
    #   other geo
    documentOpen('./data-raw/datacreate_islandareas.R')        # ok
    documentOpen('./data-raw/datacreate_censusplaces.R')       # not used yet

    # with annual ejscreen data updates
    #
    ##  ejscreen demog and envt data on every blockgroup
    ##  + pctile and avg lookup tables

    documentOpen('./data-raw/datacreate_blockgroupstats2.32.R') # and bgej      # ok
    documentOpen('./data-raw/datacreate_blockgroupstats2.32_add_d_acs22columns.R')   # ok
    documentOpen("./data-raw/datacreate_blockgroupstats2.32_recalc_language.R")
    documentOpen('./data-raw/datacreate_blockgroupstats_extra_api_vars.R')

    documentOpen('./data-raw/datacreate_usastats2.32.R')                 # ok
    documentOpen('./data-raw/datacreate_usastats2.32_add_dsubgroups.R')  # ok
    documentOpen('./data-raw/datacreate_avg.in.us.R')                   # ok
    documentOpen('./data-raw/datacreate_high_pctiles_tied_with_min.R')  # ok
    ##  calculations and examples of outputs
    documentOpen('./data-raw/datacreate_formulas.R')                    # was in progress; maybe not used yet

    documentOpen('./data-raw/datacreate_testpoints_testoutputs.R')
    documentOpen('./data-raw/datacreate_testpoints_5_50_500.R')
    documentOpen('./data-raw/datacreate_testdata_frs.R')
    documentOpen('./data-raw/datacreate_testinput_shapes_2.R')
    documentOpen('./data-raw/datacreate_testinput_address_table.R')
    documentOpen('./data-raw/datacreate_testinput_fips.R')
    documentOpen('./data-raw/datacreate_testinput_mact.R')
    documentOpen('./data-raw/datacreate_testinput_naics.R')
    documentOpen('./data-raw/datacreate_testinput_program_name.R')
    documentOpen('./data-raw/datacreate_testinput_sic.R')
    documentOpen('./data-raw/datacreate_ejscreenRESTbroker2table_na_filler.R')
    documentOpen('./data-raw/datacreate_default_points_shown_at_startup.R')
    documentOpen('./data-raw/datacreate_testoutput_ejscreenit_or_ejscreenapi_plus_50.R')
    documentOpen('./data-raw/datacreate_testinput_program_sys_id.R')
    documentOpen('./data-raw/datacreate_testinput_registry_id.R')
    documentOpen('./data-raw/datacreate_testoutput_ejamit_fips_.R')
    documentOpen('./data-raw/datacreate_testoutput_ejamit_shapes_2.R')
  }
  # when frs info is updated

  documentOpen('./data-raw/datacreate_frs_.R')            #  BUT SEE IF THIS HAS BEEN REVISED/ REPLACED  ***
  documentOpen('./data-raw/datacreate_frs_by_mact.R')     #  BUT SEE IF THIS HAS BEEN REPLACED  ***
  documentOpen('./data-raw/datacreate_frs_by_sic.R')      #  BUT SEE IF THIS HAS BEEN REPLACED  ***

  documentOpen('./data-raw/datacreate_frsprogramcodes.R') #
  documentOpen('./data-raw/datacreate_epa_programs.R')    #
  documentOpen('./data-raw/datacreate_epa_programs_defined.R')
  # NAICS/SIC
  documentOpen('./data-raw/datacreate_naics_counts.R')    # script
  documentOpen('./data-raw/datacreate_naicstable.R')      # script. does date_saved_in_package & use_data
  documentOpen('./data-raw/datacreate_SIC.R')
  documentOpen('./data-raw/datacreate_sic_counts.R')
  documentOpen('./data-raw/datacreate_sictable.R')

  # misc
  documentOpen('./data-raw/datacreate_lat_alias.R')
  documentOpen('./data-raw/datacreate_ejampackages.R')
  documentOpen('./data-raw/datacreate_meters_per_mile.R')

  ### and then SAVE TO ejamdata REPO or wherever, if those datasets were updated.

} # outline/list of datacreate_ files

######################################### ########################################## #
######################################### ########################################## #
# ~------------------------------------------- ####

# ** NAMES OF INDICATORS/ VARIABLES etc. ANNUAL UPDATES ####
######################################### #
### datacreate_map_headernames.R ####
# rstudioapi::documentOpen("./data-raw/datacreate_map_headernames.R")
source_maybe("datacreate_map_headernames.R", DOIT = TRUE)
######################################### #
### datacreate_names_of_indicators.R ####
# rstudioapi::documentOpen("./data-raw/datacreate_names_of_indicators.R")
source_maybe("datacreate_names_of_indicators.R")   # NOTE THAT   THIS TAKES A LONG TIME, ACTUALLY

### that will create but also assign metadata to and save for pkg via use_data()
### It is a script that mostly uses a function so that
### all the variables created do not show up in the global environment - they get saved in pkg ready for lazy-loading if/when needed
### BUT any subsequent scripts that depend on those will not use the correct new versions unless we do load.all() anyway...
### metadata is assigned inside these
### use_data is done inside these
######################################### ########################################## #
## > loadall ####
consoleclear()
ls()
loadall()

######################################### ########################################## #

######################################### #
### datacreate_names_pct_as_fraction.R ####
# rstudioapi::documentOpen("./data-raw/datacreate_names_pct_as_fraction.R")
source_maybe("datacreate_names_pct_as_fraction.R")

######################################### #
### datacreate_1_metadata_update.R ####
# documentOpen('./data-raw/datacreate_1_metadata_update.R')
### source_maybe("datacreate_1_metadata_update.R")

# to update only the ejam_package_version attribute for ALL dataset objects in /data/
# (other than the .txt and .arrow files there)
# use this:
stop('confirm you want to do this next step - it is inconvenient for some dataset objects like meters_per_mile to have attributes like ejam_package_version')

#     metadata_update_attr()

cat("Note you also may want to update the package version info in the .arrow files ! \n")


######################################### ##
### datacreate_runtime_models.R ####
# documentOpen('./data-raw/datacreate_runtime_models.R')
source_maybe("datacreate_runtime_models.R")
### TRIES TO READ Analysis_timing_results_100.csv etc.

######################################### ########################################## #
## > loadall ####
### Must use load_all() or build/install, to make available those new variable name lists
#  (the source package as just updated, not the version installed)
#  and so all functions will use the new source version

rmost2()
loadall()

######################################### ########################################## #
# ~------------------------------------------- ####
# ** FIPS CODES/ Census Boundaries - ANNUAL UPDATES (if EJSCREEN incorporates those) ####
# . ####
######################################### #
## * BLOCKS  ####
# documentOpen('./data-raw/datacreate_blockwts.R')           # needs Island Areas added

######################################### #
### datacreate_blockwts.R ####
# rstudioapi::documentOpen("./data-raw/datacreate_blockwts.R")
### this requires package called ejanalysis/census2020download, which is not on CRAN!

# THIS TAKES A VERY LONG TIME:

dataload_dynamic('bgid2fips')

source_maybe('datacreate_blockwts.R', DOIT = FALSE) # script that can include metadata_add() and use_data()
#    and be sure to obtain correct version either from census or directly from ejscreen team
# Creates mylistoftables, a list that includes tables blockwts, blockpoints, bgid2fips, etc.,
#   gets updated when FIPS codes or boundaries change for blocks or blockgroups
#  such as in Connecticut for v2.2 change to v2.32 !
#  and then write to ejamdata repository if those datasets were updated.
# bgej  is not ready yet here... it is made when blockgroupstats is made.
# note that 'bg_cenpop2020' and 'bgpts' are in EJAM/data/

# take a look/ check
length(unique(substr(blockid2fips$blockfips,1,2)))
nacounts(bgid2fips, showall = T)
nacounts(blockwts, showall = T)
nacounts(blockpoints, showall = T)
nacounts(quaddata, showall = T)
nacounts(blockid2fips, showall = T)
## check blockid values in all these datasets
stopifnot(
  all(
    setequal(blockid2fips$blockid, blockpoints$blockid),
    setequal(blockid2fips$blockid, quaddata$blockid),
    setequal(blockid2fips$blockid, blockwts$blockid)
  ),
  all(
    !anyDuplicated(blockid2fips$blockid),
    !anyDuplicated(blockwts$blockid),
    !anyDuplicated(blockpoints$blockid),
    !anyDuplicated(quaddata$blockid)
  ),
  all(
    !anyNA(blockid2fips),
    !anyNA(blockwts),
    !anyNA(blockpoints),
    !anyNA(quaddata)
  )
)
# blockid2fips : blockid, blockfips
# blockpoints :  blockid,             lat, lon
# blockwts :     blockid, bgid, blockwt, block_radius_miles
# quaddata :      blockid   and      BLOCK_X, BLOCK_Z, BLOCK_Y

### save ? ####

these <- c("bgid2fips",   "blockid2fips", "blockpoints", "blockwts", 'quaddata')
datawrite_to_local(these) # maybe obsolete

# ONE COULD LOAD FROM LOCAL or ejamdata repo THE EXISTING VERSIONS OF THESE DATASETS IF available INSTEAD OF UPDATING THEM
# via   dataload_dynamic()
######################################### #
## * BLOCKGROUP POINTS ####
# documentOpen('./data-raw/datacreate_bgpts.R')              # USED BY datacreate_blockgroupstats2.32.R !! otherwise redundant w bg_cenpop2020
# documentOpen('./data-raw/datacreate_bg_cenpop2020.R')      # confirm if changed since 2020

######################################### #
### datacreate_bgpts.R ####
# rstudioapi::documentOpen("./data-raw/datacreate_bgpts.R")

cat( "Is it loaded/attached already? "); cat("bgpts" %in% ls(), '\n');
cat("Is it a dataset in installed EJAM pkg? "); junk <- capture.output({XYZ <- pkg_data("EJAM")$Item}); cat("bgpts" %in% XYZ, '\n');
cat('Is it loadable and/or attached already, per "exists()" ? ', exists("bgpts"), '\n'); rm(junk, XYZ)
# dataload_dynamic("bgpts", justchecking = TRUE)# bgpts is in EJAM/data/
#  attributes2(bgpts)

source_maybe("datacreate_bgpts.R", DOIT = FALSE, folder = rawdir)
nacounts(bgpts)
# it gets saved with package as data

### datacreate_bg_cenpop2020.R ####
# rstudioapi::documentOpen("./data-raw/datacreate_bg_cenpop2020.R")       IS IT USED AT ALL BY EJAM THOUGH??
source_maybe("datacreate_bg_cenpop2020.R", DOIT = FALSE, folder = rawdir)


######################################### #
## * STATES ####
# documentOpen('./data-raw/datacreate_states_shapefile.R')   # check if want 2020 or 2022+ file
# documentOpen('./data-raw/datacreate_stateinfo.R')          # ok (missing Island Areas)
# documentOpen('./data-raw/datacreate_stateinfo2.R')         # ok (has Island Areas)

### datacreate_states_shapefile.R ####
# documentOpen('./data-raw/datacreate_states_shapefile.R')   # check if want 2020 or 2022+ file
source_maybe("datacreate_states_shapefile.R", DOIT = FALSE, folder = rawdir)
######################################### #
### datacreate_stateinfo.R ####
### datacreate_stateinfo2.R ####
# documentOpen('./data-raw/datacreate_stateinfo.R')          # ok (missing Island Areas)
# documentOpen('./data-raw/datacreate_stateinfo2.R')         # ok (has Island Areas)
## ok to update metadata whenever - these should never really change but want to note version 2.32 etc.
source_maybe('datacreate_stateinfo.R', DOIT = FALSE, folder = rawdir)
source_maybe('datacreate_stateinfo2.R', DOIT = FALSE, folder = rawdir)
######################################### #

## * CITIES & Island Areas ####

# documentOpen('./data-raw/datacreate_islandareas.R')        # ok

# documentOpen('./data-raw/datacreate_censusplaces.R')       # used for city/CDP data, in fipspicker etc.

### datacreate_islandareas.R ####
# documentOpen('./data-raw/datacreate_islandareas.R')        # ok
source_maybe("datacreate_islandareas.R", DOIT = FALSE, folder = rawdir)
######################################### #
### datacreate_censusplaces.R ####
# documentOpen('./data-raw/datacreate_censusplaces.R')       # not used yet
source_maybe("datacreate_censusplaces.R", DOIT = FALSE, folder = rawdir)

######################################### ########################################## #
## > loadall ####

## updated block-related datasets should be on local disk now but not yet in ejamdata repo,
## and updated names_xyz and map_headernames should be in globalenv and in /data/ but not in installed pkg yet.
## so maybe best to rm(list = ls()) and load_all() again to get all new versions of everything

rmost2()
cat("Running load_all() but you may want to rebuild/install now \n")
loadall()


# ~------------------------------------------- ####
# ** EJSCREEN BLOCKGROUP DATA - ANNUAL UPDATES ####

## Demog + Envt data on blockgroups ####
## + pctile & avg lookup tables (usastats, statestats) ####

######################################### #



######################################### #
### datacreate_blockgroupstats2.32.R (also starts making usastats,statestats!!) ####
### ACS22 via datacreate_blockgroupstats2.32_add_d_acs22columns ####
# rstudioapi::documentOpen("./data-raw/datacreate_blockgroupstats2.32.R")
if (askquestions && interactive()) {
  y = askYesNo("Did you already update bgpts via new block weights and fips dataset? (required before updating blockgroupstats)")
  if (is.na(y) || !y) {
    rm(y)
    stop("Need to update bgpts via new block weights and fips dataset before updating blockgroupstats")
  }
}

source_maybe("datacreate_blockgroupstats2.32.R") # (also starts making usastats,statestats!!)
# created bgej (with metadata and documentation, and saved it locally but not to ejamdata repo yet)
### bgej to ejamdatarepo ####
######################################### #
if (askquestions && interactive()) {
  writebgej = askYesNo("write to bgej file in ejamdata repo? ")
  if (!is.na(writebgej) && writebgej) {
    ## do not save via  usethis::use_data(bgej, overwrite = TRUE) - it is a large file
    ## Save bgej to ejamdata repo as .arrow file
    ### WRITE  bgej  TO THE ejamdata REPOSITORY NOW   ####
    cat("WRITE  bgej  TO THE ejamdata REPOSITORY NOW
  THIS is done by copying the bgej.arrow file into the data folder of the ejamdata repository and pushing the changes.
   See notes in https://ejanalysis.github.io/EJAM/articles/dev-update-datasets.html

   and note any testoutput files and objects have to be recreated if numbers in bgej etc. changed...
\n")
  }}
# created blockgroupstats_new as interim object   and bgej
# created usastats, statestats but not final versions yet

################################################################################ #
if (interactive() && askquestions) {
  SAVEIMAGE = askYesNo("Save globalenv() as an .rda file now?")
  if (is.na(SAVEIMAGE)) {SAVEIMAGE <- FALSE}
}
if (SAVEIMAGE) { # ARCHIVE as IMAGE?
  cat("\n SAVING IMAGE OF WORK IN PROGRESS... \n\n")
  save.image(file = file.path(localfolder, "save.image work on NEW blockgroupstats usastats statestats.rda"))
}
################################################################################ #

# not sure about the right sequence of these next 3:

######################################### #
# rstudioapi::documentOpen("./data-raw/datacreate_blockgroupstats2.32_add_d_acs22columns.R")
# reads ACS22 extra file of demographics not on ftp site
source_maybe("datacreate_blockgroupstats2.32_add_d_acs22columns.R")  # reads ACS22 extra file of demographics not on ftp site
######################################### #
# rstudioapi::documentOpen("./data-raw/datacreate_blockgroupstats2.32_recalc_language.R")
source_maybe("datacreate_blockgroupstats2.32_recalc_language.R", DOIT = TRUE) # this just creates a function that was later used to fix language data
######################################### #
### datacreate_blockgroupstats_extra_api_vars.R ####
# documentOpen('./data-raw/datacreate_blockgroupstats_extra_api_vars.R')
source_maybe("datacreate_blockgroupstats_extra_api_vars.R")

################################################################################ #

# created blockgroupstats (now with demog subgroups from ACS22 extra file of demographics not on ftp site)


################ ################# ################# ################# #
################ ################# ################# ################# ################# #
## check bgid values in all these datasets
# blockgroupstats :  bgfips, bgid, statename, ST, etc.
# bgej :                     bgid,   bgfips,  ST, etc.
# bgid2fips :                bgid,   bgfips
# bgpts                      bgid, + bgfips, etc.
# bg_cenpop2020              bgid (not bgfips) ST, etc.

# + blockwts :      blockid, bgid, etc.

# data.table(blockgroupstats)[is.na(bgfips), table(ST)]
# AS  GU  MP  - had been this but now zero since those were dropped
# 77  58 135
# data.table(blockgroupstats)[is.na(bgid), table(ST)]
# - had been this but now zero since those were dropped
# AS   CT   GU   MP   VI
# 77 2717   58  135  416

# nacounts(blockgroupstats[, .(bgfips,bgid,pop)])
# exists("bgid2fips")


stopifnot(
  all(
    !anyDuplicated(blockgroupstats$bgid),
    # !anyDuplicated(bgej$bgid),
    !anyDuplicated(quaddata$bgid),
    !anyDuplicated(bgid2fips$bgid),
    !anyDuplicated(bgpts),
    !anyDuplicated(blockwts)
  )
)

stopifnot(
  all(
    !anyNA(blockgroupstats$bgid),
    !anyNA(bgej$bgid),
    !anyNA(quaddata$bgid),
    !anyNA(bgid2fips$bgid),
    !anyNA(bgpts),
    !anyNA(blockwts)
  )
)

stopifnot(
  all(
    setequal(blockgroupstats$bgid, bgej$bgid),    # ok
    setequal(blockgroupstats$bgid, quaddata$bgid)   , # false due to CT 19 as of 8/14/24
    setequal(blockgroupstats$bgid, bgid2fips$bgid)  , # false
    setequal(blockgroupstats$bgid, bgpts$bgid)      , # false
    setequal(blockgroupstats$bgid, bg_cenpop2020$bgid)  , # false
    setequal(blockgroupstats$bgid, blockwts$bgid)         # false
  )
)
################ ################# ################# ################# #
################ ################# ################# ################# #

######################################### #
### datacreate_usastats2.32.R ####
# rstudioapi::documentOpen("./data-raw/datacreate_usastats2.32.R")
source_maybe("datacreate_usastats2.32.R")
# now usastats and statestats exist
######################################### #
### datacreate_usastats2.32_add_dsubgroups.R ####
# rstudioapi::documentOpen("./data-raw/datacreate_usastats2.32_add_dsubgroups.R")
source_maybe("datacreate_usastats2.32_add_dsubgroups.R")
print(nacounts(usastats))
print(nacounts(statestats))

######################################### #
### datacreate_avg.in.us.R ####
# rstudioapi::documentOpen("./data-raw/datacreate_avg.in.us.R")
### this creates "avg.in.us" national averages of key indicators, for convenience, but also avgs are in usastats, statestats
source_maybe("datacreate_avg.in.us.R")
######################################### #
### datacreate_high_pctiles_tied_with_min.R ####
# rstudioapi::documentOpen("./data-raw/datacreate_high_pctiles_tied_with_min.R")
source_maybe("datacreate_high_pctiles_tied_with_min.R")
######################################### #
### datacreate_formulas.R ####
# rstudioapi::documentOpen("./data-raw/datacreate_formulas.R")
source_maybe("datacreate_formulas.R")
######################################### #
# ~------------------------------------------- ####
## ** TESTDATA & TESTOUTPUTS_ - UPDATE IF RESULTS CHANGE (sample inputs & outputs) ####

# # to see lists of
# #  datasets as lazyloaded objects vs. files installed with package
#
# topic = "fips"  # or "shape" or "latlon" or "naics" or "address" etc.
#
# # datasets / R objects
# cbind(data.in.package  = sort(grep(topic, EJAM:::pkg_data()$Item, value = T)))
#
# # files
# cbind(files.in.package = sort(basename(testdata(topic, quiet = T))))

######################################### #
### datacreate_testpoints_testoutputs.R ####
# rstudioapi::documentOpen("./data-raw/datacreate_testpoints_testoutputs.R")
## This includes
##                 devtools::load_all()
## within it:
# sources and then uses pkg_update_testpoints_testoutputs()

source_maybe("datacreate_testpoints_testoutputs.R")

######################################### #

# create several small testinput objects

### datacreate_testdata_frs.R ####
# documentOpen('./data-raw/datacreate_testdata_frs.R')
source_maybe("datacreate_testdata_frs.R")

### datacreate_testinput_shapes_2.R ####
# rstudioapi::documentOpen("./data-raw/datacreate_testinput_shapes_2.R")
source_maybe("datacreate_testinput_shapes_2.R")

### datacreate_testinput_address_table.R ####
# rstudioapi::documentOpen('./data-raw/datacreate_testinput_address_table.R')
source_maybe("datacreate_testinput_address_table.R")
# creates several objects

### datacreate_testinput_fips.R ####
# rstudioapi::documentOpen("./data-raw/datacreate_testinput_fips.R")
source_maybe("datacreate_testinput_fips.R")

### datacreate_testinput_mact.R ####
# rstudioapi::documentOpen("./data-raw/datacreate_testinput_mact.R")
source_maybe("datacreate_testinput_mact.R")

### datacreate_testinput_naics.R ####
# rstudioapi::documentOpen("./data-raw/datacreate_testinput_naics.R")
source_maybe("datacreate_testinput_naics.R")

### datacreate_testinput_sic.R ####
# rstudioapi::documentOpen("./data-raw/datacreate_testinput_sic.R")
source_maybe("datacreate_testinput_sic.R")

### datacreate_testinput_program_name.R ####
# rstudioapi::documentOpen("./data-raw/datacreate_testinput_program_name.R")
source_maybe("datacreate_testinput_program_name.R")

### datacreate_testinput_program_sys_id.R ####
# documentOpen('./data-raw/datacreate_testinput_program_sys_id.R')  #
source_maybe('datacreate_testinput_program_sys_id.R')

### datacreate_testinput_registry_id.R ####
# documentOpen('./data-raw/datacreate_testinput_registry_id.R')     #
source_maybe('datacreate_testinput_registry_id.R')

################ # more outputs

### datacreate_testoutput_ejamit_shapes_2.R ####
# documentOpen('./data-raw/datacreate_testoutput_ejamit_shapes_2.R')     #
source_maybe('datacreate_testoutput_ejamit_shapes_2.R')

### datacreate_testoutput_ejamit_fips_.R ####
# documentOpen("./data-raw/datacreate_testoutput_ejamit_fips_.R")     #
source_maybe("datacreate_testoutput_ejamit_fips_.R")

# ~------------------------------------------- ####
## Old / related to ejscreenapi  ####
######################################### #

### datacreate_default_points_shown_at_startup.R ####
source_maybe('datacreate_default_points_shown_at_startup.R')
### datacreate_testpoints_5_50_500.R ####
# rstudioapi::documentOpen("./data-raw/datacreate_testpoints_5_50_500.R")
source_maybe('datacreate_testpoints_5_50_500.R')

### datacreate_ejscreenRESTbroker2table_na_filler.R ####
# rstudioapi::documentOpen("./data-raw/datacreate_ejscreenRESTbroker2table_na_filler.R")
source_maybe('datacreate_ejscreenRESTbroker2table_na_filler.R')

### datacreate_testoutput_ejscreenit_or_ejscreenapi_plus_50.R  ####
# rstudioapi::documentOpen("./data-raw/datacreate_testoutput_ejscreenit_or_ejscreenapi_plus_50.R")
source_maybe('datacreate_testoutput_ejscreenit_or_ejscreenapi_plus_50.R')


######################################### ########################################## #
###############################          pause here
######################################### ########################################## #

# save.image(file.path(localfolder, "work in progress.rda"))

# Rebuild/ reinstall the package here,
# or at least load_all()  ?

# system.time({
#   #  installing  TAKES  ~4 MINUTES  EVEN IF .onAttach() changed to say
#   # asap_aws   <- FALSE  # download large datasets now?           Set to FALSE while Testing/Building often
#   # asap_index <- FALSE
#   # asap_bg    <- FALSE
#   # and install(  reload = TRUE, upgrade = "never" , quick = TRUE
#
#   devtools::install(reload = TRUE, upgrade = "never", quick = TRUE)
# })

# system.time({
#   #  THIS TAKES < 30 seconds   if reset = FALSE and not loading block datasets on attach
#   devtools::load_all(reset = FALSE)
#
# })

system.time({
  #  THIS TAKES 20 seconds even though supposed to be slower if reset = T  and not loading block datasets on attach
  devtools::load_all(reset = TRUE)
})


# devtools::check()


# devtools::test()

# rstudioapi::navigateToFile("./R/test_ejam.R")
# system.time({
#   #    ABOUT 10-20 MINUTES TO RUN all TESTS (if large datasets had not yet been loaded)
# source("./R/test_ejam.R") # answering Yes to running ALL tests
biglist <- EJAM:::test_ejam(ask = askquestions)
## but should do AFTER updating test data
# })
############################## #


document()

devtools::install(quick = TRUE)



######################################### ########################################## #


# ~------------------------------------------- ####
# ** FRS (EPA-REGULATED FACILITIES) FREQUENT UPDATES (incl. NAICS/SIC) ####

########################################## #
#

## >>> frs functions need cleanup here <<< ####
cat(                                        "frs functions need cleanup here  \n")
warning("frs functions need cleanup here")




## > loadall ####

#                            TO BE CHECKED/ REVISED HERE

rmost() # ??

loadall() # needed to enable frs functions below that need



## frs_by_ (lat,lon, regid,program,mact) ####

### ? datacreate_frs_.R ####
# rstudioapi::documentOpen('./data-raw/datacreate_frs_.R')            #  BUT SEE IF THIS HAS BEEN REVISED/ REPLACED  ***
# THAT SCRIPT USES EJAM:::frs_update_datasets() to download data, create datasets for pkg,
# and save them locally, and read them into memory.
# That creates frs, frs_by_programid, frs_by_naics, frs_by_sic, frs_by_mact

source_maybe("datacreate_frs_.R", DOIT = FALSE, folder = rawdir)


### ? datacreate_frs_by_sic.R - is it redundant with frs_update_datasets() ?  SEE IF THIS HAS BEEN REPLACED ? ####
# documentOpen('./data-raw/datacreate_frs_by_sic.R')      #

### ? datacreate_frs_by_mact.R - is it redundant with frs_update_datasets() ?  SEE IF THIS HAS BEEN REPLACED ? ####
# documentOpen('./data-raw/datacreate_frs_by_mact.R')   #  BUT SEE IF THIS HAS BEEN REPLACED  ***
# Manually also need to save updated frsp .... [TRUNCATED]
# Error in eval(ei, envir) : object 'folder_save_as_arrow' not found
# In addition: Warning messages:
#   1: Expected 2 pieces. Missing pieces filled with `NA` in 941 rows [30455, 30457, 30496, 30497, 30527, 30561, 30607, 30669, 30682, 30696, 30777, 30806, 30833, 30848, 30855, 30870, 30981,
#                                                                      31035, 31036, 31038, ...].
# 2: In frs_make_naics_lookup(x = frs) : NAs introduced by coercion
# 3: One or more parsing issues, call `problems()` on your data frame for details, e.g.:
#   dat <- vroom(...)
# problems(dat)

### datacreate_frsprogramcodes.R ####
# documentOpen('./data-raw/datacreate_frsprogramcodes.R') #
## needs loaded metadata_add)() etc.
source_maybe('datacreate_frsprogramcodes.R')

### datacreate_epa_programs.R ####
# documentOpen('./data-raw/datacreate_epa_programs.R')    #
source_maybe('datacreate_epa_programs.R')

### datacreate_epa_programs_defined.R ####
# documentOpen('./data-raw/datacreate_epa_programs_defined.R')    #
source_maybe('datacreate_epa_programs_defined.R')

######################################### ########################################## #

# ** NAICS & SIC (INDUSTRY) Counts from FRS, etc. ####

## . ####

cat('\n-------------------------\n These scripts on naics/sic may need work...-------------\n\n')

# THESE BELOW JUST DO COUNTS BY CODE - they dont actually update the NAICS/SIC info from the FRS data
# (and note the names of industries by NAICS code have been changing every 5 yrs, such as in 2017 and 2022)

stop("See datacreate_NAICS.R before using these scripts!
    Must check which version of NAICS codes are recorded in EPA FRS data ")

  ### every five yrs e.g. 2027:
### datacreate_NAICS.R ####
# documentOpen('./data-raw/datacreate_NAICS.R')
source_maybe('datacreate_NAICS.R')

  ### when frs or NAICS changes:
### datacreate_naics_counts.R ####
# documentOpen('./data-raw/datacreate_naics_counts.R')    # bad script
source_maybe('datacreate_naics_counts.R')

### datacreate_naicstable.R ####
# documentOpen('./data-raw/datacreate_naicstable.R')      #  #ok script. does date_saved_in_package & use_data
source_maybe('datacreate_naicstable.R')


### datacreate_SIC.R ####
# documentOpen('./data-raw/datacreate_SIC.R')
source_maybe('datacreate_SIC.R')

### datacreate_sic_counts.R ####
# documentOpen('./data-raw/datacreate_sic_counts.R')
source_maybe('datacreate_sic_counts.R')

### datacreate_sictable.R ####
# documentOpen('./data-raw/datacreate_sictable.R')
source_maybe('datacreate_sictable.R')

######################################### ########################################## #

# misc ####
# probably do not need to update these often or ever, but ok to do so
######################################### #
### datacreate_lat_alias.R ####
source_maybe('datacreate_lat_alias.R')
######################################### #
### datacreate_ejampackages.R ####
source_maybe('datacreate_ejampackages.R')
######################################### #
### datacreate_meters_per_mile.R ####
# documentOpen('./data-raw/datacreate_meters_per_mile.R')
source_maybe("datacreate_meters_per_mile.R")
######################################### #

# ~------------------------------------------- ####
# ~ ####
# CLEANUP - Remove most objects ####

## > loadall ####

rmost2()
cat("Running load_all() but you may want to rebuild/install now \n")
loadall()


######################################### #
# ~------------------------------------------- ####
# ~ ####

# DOCUMENTATION WEBSITE UPDATE ####

cat("\n\n You may want to use EJAM:::pkgdown_update() from EJAM/R/utils_pkgdown_update.R
    formerly stored in 'datacreate_0_UPDATE_ALL_DOCUMENTATION_pkgdown.R'   \n\n")
#  rstudioapi::documentOpen("./data-raw/datacreate_0_UPDATE_ALL_DOCUMENTATION_pkgdown.R")
#  rstudioapi::documentOpen("./R/utils_pkgdown_update.R")

## > loadall ####

## note this is an internal not exported function:

# EJAM:::
 pkgdown_update(
  doask              = TRUE,
  dotests            = FALSE,
  testinteractively  = FALSE, ## maybe we want to do this interactively even if ask=F ?
  doyamlcheck        = TRUE, ## dataset_pkgdown_yaml_check() does siterep but also check internal v exported, listed in pkgdown reference TOC etc.
  dodocument         = TRUE,  ## in case we just edited help, exports, or func names,
  ##   since doinstall=T via this script omits document()
  doinstall          = FALSE,  ## but skips document() and vignettes
  doloadall_not_library = TRUE, ## (happens after install, if that is being done here)
  dobuild_site      = TRUE     ## use build_site() to create new pkgdown site html files in /docs/ (or stop?)
)
########################################## ######################################### #
