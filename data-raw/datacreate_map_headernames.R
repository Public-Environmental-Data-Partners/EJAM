if (!exists("askquestions")) {askquestions <- FALSE}
if (!exists("rawdir")) {rawdir <- './data-raw'}

#createorupdatethetablethatmapsfromoneversionof
#variablenames(e.g.,long,clearerones)
#toanother(e.g.,shortereasierforanalysisorprogramminginR,etc.)

datacreate_map_headernames <- function(rawdir = "./data-raw",
                                       fname = NULL,
                                       sheet = "map_headernames") {

  if (missing(fname) || is.null(fname)) {
    fname <- paste0('map_headernames_', as.vector(desc::desc(package = "EJAM")$get("Version")), '.xlsx')
  }

  fpath <- file.path(rawdir, fname)
  if (!file.exists(fpath)) {stop("did not find (but this requires) ", fpath)}

  map_headernames <- as.data.frame(readxl::read_xlsx(fpath, sheet = sheet))

  map_headernames[is.na(map_headernames)] <- ''  #changeNAvaluestoemptycell,soitiseasiertosubsetetc.

  upsert_row <- function(rname, longname, varlist, denominator = "", acsname = "") {
    row <- match(rname, map_headernames$rname)
    if (is.na(row)) {
      newrow <- map_headernames[NA, ][1, ]
      newrow[] <- ""
      newrow$rname <- rname
      newrow$longname <- longname
      newrow$varlist <- varlist
      newrow$denominator <- denominator
      newrow$acsname <- acsname
      map_headernames <<- rbind(map_headernames, newrow)
    } else {
      map_headernames$longname[row] <<- longname
      map_headernames$varlist[row] <<- varlist
      map_headernames$denominator[row] <<- denominator
      map_headernames$acsname[row] <<- acsname
    }
  }

  upsert_row("lan_english", "Number speaking only English at home", "names_d_language_count", "", "LAN_ENGLISH")
  upsert_row("lan_french", "Number speaking French, Haitian, or Cajun at home", "names_d_language_count", "", "LAN_FRENCH")
  upsert_row("lan_german", "Number speaking German or other West Germanic languages at home", "names_d_language_count", "", "LAN_GERMAN")
  upsert_row("lan_rus_pol_slav", "Number speaking Russian, Polish, or other Slavic languages at home", "names_d_language_count", "", "LAN_RUS_POL_SLAV")
  upsert_row("lan_other_ie", "Number speaking Other Indo-European languages at home", "names_d_language_count", "", "LAN_OTHER_IE")
  upsert_row("lan_korean", "Number speaking Korean at home", "names_d_language_count", "", "LAN_KOREAN")
  upsert_row("lan_chinese", "Number speaking Chinese (including Mandarin, Cantonese) at home", "names_d_language_count", "", "LAN_CHINESE")
  upsert_row("lan_vietnamese", "Number speaking Vietnamese at home", "names_d_language_count", "", "LAN_VIETNAMESE")
  upsert_row("lan_tagalog", "Number speaking Tagalog (including Filipino) at home", "names_d_language_count", "", "LAN_TAGALOG")
  upsert_row("lan_other_asian", "Number speaking Other Asian and Pacific Island languages at home", "names_d_language_count", "", "LAN_OTHER_ASIAN")
  upsert_row("lan_arabic", "Number speaking Arabic at home", "names_d_language_count", "", "LAN_ARABIC")
  upsert_row("lan_other_and_unspecified", "Number speaking Other and unspecified languages at home", "names_d_language_count", "", "LAN_OTHER_AND_UNSPECIFIED")

  upsert_row("pctlan_german", "% speaking German or other West Germanic languages at home", "names_d_language", "lan_universe", "PCT_LAN_GERMAN")
  upsert_row("pctlan_other_ie", "% speaking Other Indo-European languages at home", "names_d_language", "lan_universe", "PCT_LAN_OTHER_IE")
  upsert_row("pctlan_tagalog", "% speaking Tagalog (including Filipino) at home", "names_d_language", "lan_universe", "PCT_LAN_TAGALOG")
  upsert_row("pctlan_other_and_unspecified", "% speaking Other and unspecified languages at home", "names_d_language", "lan_universe", "PCT_LAN_OTHER_AND_UNSPECIFIED")

  upsert_row("poverty_household_universe", "Households for whom poverty status is determined", "names_d_extra_count", "", "ACSIPOVHHBAS")
  upsert_row("poor", "Households below Poverty Level", "names_d_extra_count", "", "POV")
  upsert_row("pctpoor", "% Households below Poverty Level", "names_d_extra", "poverty_household_universe", "PCT_POV")

  upsert_row("unemployedbase", "Population 16 years and over", "names_d_other_count", "", "ACSUNEMPBAS") # careful about names for variables related to pctunemployed - only the correct denominator should be referred to as the base
  upsert_row("laborforce_universe", "Civilian labor force", "names_d_other_count", "", "ACSLABORFORCE") # careful about names for variables related to pctunemployed - only the correct denominator should be referred to as the base
  upsert_row("unemployed", "Unemployed resident count", "names_d_count", "", "UNEMPLOYED")
  upsert_row("pctunemployed", "% Unemployed (among civilian labor force)", "names_d", "laborforce_universe", "UNEMPPCT")

  upsert_row("pctownedunits", "% Owner-occupied housing units", "names_community", "occupiedunits", "PCT_OWNERS")

  upsert_row("broadband_universe", "Count of Households in B28002 Internet Subscription Universe", "names_d_other_count", "", "")

  upsert_row("healthinsurance_universe", "Civilian noninstitutionalized population for health insurance coverage status", "names_criticalservice_count", "", "")
  upsert_row("nohealthinsurance", "People without health insurance coverage", "names_criticalservice_count", "", "")
  upsert_row("pctnohealthinsurance", "% People without Health Insurance", "names_criticalservice", "healthinsurance_universe", "PCT_NO_HEALTH_INSURANCE")


  map_headernames <- EJAM:::augment_map_headernames_ejscreen_names(map_headernames)

  cat('must redo sample dataset outputs in EJAM/inst/testdata/  via
  EJAM/data-raw/datacreate_testpoints_testoutputs.R
      \n')

  # cbind(names(map_headernames))
  invisible(map_headernames)
}
################################################################################# #

#  UPDATE map_headernames_xyz.xlsx MANUALLY,
#  then read .xlsx and save as dataset for package
if (askquestions && interactive()) {
  y <- askYesNo("Want to open .xlsx to edit it now?")
  if (!is.na(y) && y) {
    fpath = rstudioapi::selectFile(path = rawdir, filter = "xlsx")
    browseURL(normalizePath(fpath))
    y <- askYesNo("Y if done editing and ready to go on, N to abort/stop")
    if (is.na(y) || !y) {stop("stopping script")}
  }
  rm(y)
}
if (!exists("fpath")) {
  map_headernames <- datacreate_map_headernames()
} else {
  map_headernames <- datacreate_map_headernames(fpath)
}
## metadata ####
# map_headernames <- metadata_add(map_headernames)
# usethis::use_data(map_headernames, overwrite = TRUE)
EJAM:::metadata_add_and_use_this("map_headernames")

rm(datacreate_map_headernames)

cat("FINISHED A SCRIPT\n")
cat("\n In globalenv() so far: \n\n")
print(ls())
################################################################################# #

# # which sources provide which variables or indicators?

some = unique(map_headernames$rname[map_headernames$varlist != "" & map_headernames$varlist != "x_anyother"])
info = varinfo(some, info = c('api', 'csv', 'acs', 'varlist'))
x = info[nchar(paste0(info$api, info$csv, info$acs)) > 0, ]
cat("\nSee a table of which source (api, csv, etc.) uses which variable names\n\n")
cat(
"some = unique(map_headernames$rname[map_headernames$varlist != '' & map_headernames$varlist != 'x_anyother']) \n",
"info = varinfo(some, info = c('api', 'csv', 'acs', 'varlist'))\n",
"x = info[nchar(paste0(info$api, info$csv, info$acs)) > 0, ]",
"head(x)",
"\n\n")
head(x)
