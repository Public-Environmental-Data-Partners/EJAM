if (!exists("askquestions")) {askquestions <- FALSE}
if (!exists("rawdir")) {rawdir <- './data-raw'}

#createorupdatethetablethatmapsfromoneversionof
#variablenames(e.g.,long,clearerones)
#toanother(e.g.,shortereasierforanalysisorprogramminginR,etc.)

datacreate_map_headernames <- function(rawdir = "./data-raw",
                                       fname = NULL,
                                       save_csv = TRUE) {

  if (missing(fname) || is.null(fname)) {
    fname <- "map_headernames.csv"
  }

  fpath <- if (identical(dirname(fname), ".")) {
    file.path(rawdir, fname)
  } else {
    fname
  }
  if (!file.exists(fpath)) {stop("did not find (but this requires) ", fpath)}

  if (!grepl("[.]csv$", fpath, ignore.case = TRUE)) {
    stop("datacreate_map_headernames() now reads map_headernames.csv only, not the legacy .xlsx workbook")
  }

  map_headernames <- data.table::fread(
    fpath,
    colClasses = "character",
    data.table = FALSE,
    na.strings = "NA"
  )

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

  upsert_related_row <- function(source_rname, prefix, varlist, zone, vartype,
                                 raw_pctile_avg, jsondoc_vartype,
                                 jsondoc_shortvartype, calculation_type,
                                 long_prefix, short_prefix,
                                 ratio.to = "0", state. = "0", pctile. = "0",
                                 avg. = "0", decimals = NULL, sigfigs = NULL) {
    source_row <- which(map_headernames$rname == source_rname)[1]
    if (is.na(source_row)) {
      warning("cannot add related map_headernames row because source rname was not found: ", source_rname)
      return(invisible(NULL))
    }

    rname <- paste0(prefix, source_rname)
    row <- match(rname, map_headernames$rname)
    if (is.na(row)) {
      newrow <- map_headernames[source_row, , drop = FALSE]
      newrow[] <- ""
      map_headernames <<- rbind(map_headernames, newrow)
      row <- nrow(map_headernames)
    }

    source_long <- map_headernames$longname[source_row]
    source_short <- map_headernames$shortlabel[source_row]
    if (!nzchar(source_short)) {
      source_short <- source_long
    }
    if (is.null(decimals)) {
      decimals <- map_headernames$decimals[source_row]
    }
    if (is.null(sigfigs)) {
      sigfigs <- map_headernames$sigfigs[source_row]
    }

    map_headernames$rname[row] <<- rname
    map_headernames$oldname[row] <<- ""
    map_headernames$oldname_is_what[row] <<- ""
    map_headernames$api_synonym[row] <<- ""
    map_headernames$acsname[row] <<- ""
    map_headernames$csvname[row] <<- ""
    map_headernames$varlist[row] <<- varlist
    map_headernames$topic_root_term[row] <<- source_rname
    map_headernames$basevarname[row] <<- source_rname
    map_headernames[["ratio.to"]][row] <<- ratio.to
    map_headernames[["state."]][row] <<- state.
    map_headernames[["pctile."]][row] <<- pctile.
    map_headernames[["text."]][row] <<- "0"
    map_headernames[["avg."]][row] <<- avg.
    map_headernames[["bin."]][row] <<- "0"
    map_headernames$zone[row] <<- zone
    map_headernames$jsondoc_shortzone[row] <<- if (identical(zone, "State")) "state" else "us"
    map_headernames$jsondoc_sort_zone[row] <<- if (identical(zone, "State")) "2" else "1"
    map_headernames$vartype[row] <<- vartype
    map_headernames$raw_pctile_avg[row] <<- raw_pctile_avg
    map_headernames$agree[row] <<- "TRUE"
    map_headernames$jsondoc_vartype[row] <<- jsondoc_vartype
    map_headernames$jsondoc_shortvartype[row] <<- jsondoc_shortvartype
    map_headernames$denominator[row] <<- ""
    map_headernames$calculation_type[row] <<- calculation_type
    map_headernames$sigfigs[row] <<- sigfigs
    map_headernames$decimals[row] <<- decimals
    map_headernames$pct_as_fraction_ejscreenit[row] <<- "FALSE"
    map_headernames$pct_as_fraction_ejamit[row] <<- "FALSE"
    map_headernames$pct_as_fraction_blockgroupstats[row] <<- "FALSE"
    map_headernames$longname[row] <<- paste0(long_prefix, source_long)
    map_headernames$shortlabel[row] <<- paste0(short_prefix, source_short)
    map_headernames$names_friendly[row] <<- map_headernames$longname[row]
    map_headernames$ejscreen_ftp_names[row] <<- ""
    map_headernames$ejscreen_apinames_old[row] <<- ""
    map_headernames$ejam_apinames[row] <<- rname
    map_headernames$ejscreen_indicator[row] <<- ""
    invisible(NULL)
  }

  add_related_rows_for <- function(varlist, source_rnames,
                                   add_avg = TRUE,
                                   add_pctile = TRUE,
                                   add_ratio = TRUE) {
    source_rnames <- source_rnames[
      source_rnames %in% map_headernames$rname
    ]
    for (source_rname in source_rnames) {
      if (add_avg) {
        upsert_related_row(
          source_rname = source_rname,
          prefix = "avg.",
          varlist = paste0(varlist, "_avg"),
          zone = "Nation",
          vartype = "usavg",
          raw_pctile_avg = "avg",
          jsondoc_vartype = "average",
          jsondoc_shortvartype = "avg",
          calculation_type = "constant",
          long_prefix = "US Average for ",
          short_prefix = "US avg "
        )
        upsert_related_row(
          source_rname = source_rname,
          prefix = "state.avg.",
          varlist = paste0(varlist, "_state_avg"),
          zone = "State",
          vartype = "stateavg",
          raw_pctile_avg = "avg",
          jsondoc_vartype = "average",
          jsondoc_shortvartype = "avg",
          calculation_type = "constant",
          long_prefix = "State Average for ",
          short_prefix = "State avg "
        )
      }
      if (add_pctile) {
        upsert_related_row(
          source_rname = source_rname,
          prefix = "pctile.",
          varlist = paste0(varlist, "_pctile"),
          zone = "Nation",
          vartype = "uspctile",
          raw_pctile_avg = "pctile",
          jsondoc_vartype = "percentile",
          jsondoc_shortvartype = "pctile",
          calculation_type = "lookedup",
          long_prefix = "US percentile for ",
          short_prefix = "US%ile ",
          pctile. = "1",
          decimals = "0",
          sigfigs = "2"
        )
        upsert_related_row(
          source_rname = source_rname,
          prefix = "state.pctile.",
          varlist = paste0(varlist, "_state_pctile"),
          zone = "State",
          vartype = "statepctile",
          raw_pctile_avg = "pctile",
          jsondoc_vartype = "percentile",
          jsondoc_shortvartype = "pctile",
          calculation_type = "lookedup",
          long_prefix = "State percentile for ",
          short_prefix = "State%ile ",
          state. = "1",
          pctile. = "1",
          decimals = "0",
          sigfigs = "2"
        )
      }
      if (add_ratio) {
        upsert_related_row(
          source_rname = source_rname,
          prefix = "ratio.to.avg.",
          varlist = paste0(varlist, "_ratio_to_avg"),
          zone = "Nation",
          vartype = "usratio",
          raw_pctile_avg = "ratio",
          jsondoc_vartype = "ratio",
          jsondoc_shortvartype = "ratio",
          calculation_type = "ratio to avg",
          long_prefix = "Ratio to US avg ",
          short_prefix = "Ratio to US avg ",
          ratio.to = "1",
          avg. = "1",
          decimals = "1",
          sigfigs = "2"
        )
        upsert_related_row(
          source_rname = source_rname,
          prefix = "ratio.to.state.avg.",
          varlist = paste0(varlist, "_ratio_to_state_avg"),
          zone = "State",
          vartype = "stateratio",
          raw_pctile_avg = "ratio",
          jsondoc_vartype = "ratio",
          jsondoc_shortvartype = "ratio",
          calculation_type = "ratio to avg",
          long_prefix = "Ratio to State avg ",
          short_prefix = "Ratio to State avg ",
          ratio.to = "1",
          state. = "1",
          avg. = "1",
          decimals = "1",
          sigfigs = "2"
        )
      }
    }
    invisible(NULL)
  }

  report_ratio_source_rnames <- function(varlist, exclude = character()) {
    rows <- map_headernames[map_headernames$varlist == varlist, , drop = FALSE]
    rows <- rows[rows$calculation_type %in% "wtdmean", , drop = FALSE]
    setdiff(rows$rname, exclude)
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

  upsert_row("lan_other", "Number speaking Arabic, Other, and unspecified languages at home", "names_d_language_count", "", "LAN_OTHER")
  upsert_row("pctlan_other", "% speaking Arabic, Other, and unspecified languages at home", "names_d_language", "lan_universe", "PCT_LAN_OTHER")
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

  add_related_rows_for(
    "names_health",
    c("pctdisability", "lowlifex", "rateheartdisease", "rateasthma", "ratecancer"),
    add_avg = FALSE,
    add_pctile = FALSE,
    add_ratio = TRUE
  )
  add_related_rows_for(
    "names_climate",
    report_ratio_source_rnames("names_climate"),
    add_avg = FALSE,
    add_pctile = FALSE,
    add_ratio = TRUE
  )
  add_related_rows_for(
    "names_criticalservice",
    report_ratio_source_rnames("names_criticalservice"),
    add_avg = FALSE,
    add_pctile = FALSE,
    add_ratio = TRUE
  )
  add_related_rows_for(
    "names_d_language",
    report_ratio_source_rnames("names_d_language")
  )
  add_related_rows_for(
    "names_d_languageli",
    report_ratio_source_rnames("names_d_languageli")
  )
  add_related_rows_for(
    "names_age",
    report_ratio_source_rnames("names_age")
  )
  add_related_rows_for(
    "names_d_extra",
    report_ratio_source_rnames("names_d_extra")
  )
  add_related_rows_for(
    "names_community",
    report_ratio_source_rnames("names_community", exclude = "occupiedunits")
  )

  map_headernames <- EJAM:::augment_map_headernames_ejscreen_names(map_headernames)

  if (isTRUE(save_csv)) {
    data.table::fwrite(
      map_headernames,
      file.path(rawdir, "map_headernames.csv"),
      quote = TRUE,
      na = ""
    )
  }

  cat('must redo sample dataset outputs in EJAM/inst/testdata/  via
  EJAM/data-raw/datacreate_testpoints_testoutputs.R
      \n')

  # cbind(names(map_headernames))
  invisible(map_headernames)
}
################################################################################# #

# Regenerate map_headernames from the canonical CSV source only.
if (!exists("fpath")) {
  map_headernames <- datacreate_map_headernames()
} else {
  map_headernames <- datacreate_map_headernames(
    rawdir = dirname(fpath),
    fname = basename(fpath)
  )
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
