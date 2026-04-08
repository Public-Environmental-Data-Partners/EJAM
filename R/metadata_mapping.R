#################################################### #

# default_metadata from DESCRIPTION file ####

## This should be the  INSTALLED version...
## If you attached via library() or require(), after having installed the pkg,
## and did not use load_all(), this variable stores the INSTALLED pkg version, (since this code was sourced while the package was being attached),
## not necessarily the latest SOURCE version.
## But if you just use desc::description$new("DESCRIPTION") in the console, it looks in the current working directory which might be the source pkg dir, and might contain a newer version of the file not yet installed!
# compare to
# description_file <- desc::description$new(file = system.file("DESCRIPTION", package = "EJAM"))

## Also, note url_package() relies on the DESCRIPTION file without using this global variable "description_file"

description_file <- desc::description$new("DESCRIPTION")

#################################################### #

# default_metadata for this version ####

default_metadata <- list(

  ###note this field in DESCRIPTION file cant have text.
  #   "2.32.0" ok, but not "2.32.0-ejscreen2.32"
  ejam_package_version          = description_file$get("Version"),

  ejscreen_version      = description_file$get("VersionEJSCREEN"),
  ejscreen_releasedate  = description_file$get("ReleaseDateEJSCREEN"),
  acs_releasedate       = description_file$get("ReleaseDateACS"),
  acs_version           = description_file$get("VersionACS"),
  census_version        = description_file$get("VersionCensus")
)

##    ## "https://www.census.gov/programs-surveys/acs/news/data-releases/2024/release-schedule.html"
##    ## "https://www.census.gov/programs-surveys/acs/news/data-releases/2023/release-schedule.html"

# > dput(default_metadata)

#################################################### #

# metadata_mapping ####

# x = pkg_data("EJAM")
# # Not included here yet:
# cbind(sort(setdiff(x$Item, cbind(names(metadata_mapping)))))

metadata_mapping <- list(

  # datacreate_bg_cenpop2020.R
  bg_cenpop2020 =	list(
    source = "https://www2.census.gov/geo/docs/reference/cenpop2020/blkgrp/CenPop2020_Mean_BG.txt",
    census_version = description_file$get("VersionCensus")
  ),

  # datacreate_blockgroupstats....
  # rstudioapi::documentOpen("./data-raw/datacreate_blockgroupstats_acs.R")
  blockgroupstats =	default_metadata,

  # datacreate_usastats2.32.R  and others
  avg.in.us       =	default_metadata,
  statestats      = default_metadata,
  usastats        = default_metadata,
  high_pctiles_tied_with_min =	default_metadata, ##  NO LONGER USING high_pctiles_tied_with_min ***

  # datacreate_bgpts.R
  bgpts =	default_metadata,

  # datacreate_map_headernames.R
  map_headernames = list(
    ejscreen_version      = description_file$get("VersionEJSCREEN"),
    ejscreen_releasedate  = description_file$get("ReleaseDateEJSCREEN")
  ),

  # datacreate_tables_ejscreen_acs.R etc.
  tables_ejscreen_acs = default_metadata,
  formulas_ejscreen_demog_index = default_metadata,
  formulas_ejscreen_acs_disability = default_metadata,
  formulas_all = default_metadata,
  formulas_d   = default_metadata,

  # datacreate_frs_by_mact.R
  mact_table = list(), ##########  just the date it was updated is what matters for this
  frs_by_mact =	list(), ##########  just the date it was updated is what matters for this
  epa_programs = list(), ##########  just the date it was updated is what matters for this
  epa_programs_defined = list(),

  frsprogramcodes  = list(), ##########  just the date it was updated is what matters for this

  NAICS = list(), ##########  just the date it was updated is what matters for this
  naics_counts = list(), ##########  just the date it was updated is what matters for this
  naicstable = list(), ##########  just the date it was updated is what matters for this
  SIC = list(), ##########  just the date it was updated is what matters for this
  sictable = list(), ##########  just the date it was updated is what matters for this

  # datacreate_censusplaces.R
  censusplaces = list(), ##########  just the date it was updated is what matters for this

  # datacreate_stateinfo.R
  # datacreate_stateinfo2.R
  stateinfo  =	list(), ##########  just the date it was updated is what matters for this
  stateinfo2 =  list(), ##########  just the date it was updated is what matters for this

  # TEST DATA SETS

  # datacreate_testpoints_testoutputs.R

  ## see   cbind(data.in.package  = sort(grep("test", pkg_data()$Item, value = T)))

  ## etc. inputs ####

  testshapes_2 = list(),

  testpoints_10 =	list(),
  testpoints_100 =	list(),
  testpoints_100_dt =	list(),
  testpoints_1000 =	list(),
  testpoints_10000 =	list(),
  testpoints_5 =	list(),
  testpoints_50 =	list(),
  testpoints_500 =	list(),
  testpoints_bad =	list(),
  testpoints_overlap3 =	list(),

  # datacreate_testinput_address_table.R
  testinput_address_table = list(), ######### #
  testinput_address_table_goodnames = list(),
  testinput_address_table_withfull = list(),

  # datacreate_testinput_program_sys_id.R
  # testinput_program_sys_id = list(), ##########  just the date it was updated is what matters for this, but omitting metadata so it can remain a vector per is.vector()

  # datacreate_testinput_registry_id.R
  # testinput_registry_id = list(), ##########  just the date it was updated is what matters for this, but omitting metadata so it can remain a vector per is.vector()
  # testinput_regid = list(), # , but omitting metadata so it can remain a vector per is.vector()

  ## etc. outputs ####

  # [4,] "testoutput_ejamit_1000pts_1miles"
  # [5,] "testoutput_ejamit_100pts_1miles"
  # [6,] "testoutput_ejamit_10pts_1miles"

  # [13,] "testoutput_getblocksnearby_1000pts_1miles"
  # [14,] "testoutput_getblocksnearby_100pts_1miles"
  # [15,] "testoutput_getblocksnearby_10pts_1miles"

  # [1,] "testoutput_doaggregate_1000pts_1miles"
  # [2,] "testoutput_doaggregate_100pts_1miles"
  # [3,] "testoutput_doaggregate_10pts_1miles"

  testoutput_ejamit_10pts_1miles = default_metadata,
  testoutput_ejamit_100pts_1miles = default_metadata,
  testoutput_ejamit_1000pts_1miles = default_metadata,

  # skip most of them

  test_metadata_custom = list(
    custominfo = 0,
    moreinfo = "oldvalue",
    unchangedinfo = 9
  ),

  test_metadata_custom2 = list(
    custominfo = 123,
    moreinfo = "abc",
    unchangedinfo = 9
  ),

  default = default_metadata
)
#################################################### #

# get_metadata_mapping ####

get_metadata_mapping <- function(dsname) {
  if (missing(dsname)) {return(default_metadata)}
  return(metadata_mapping[[dsname]])
}
#################################################### #
