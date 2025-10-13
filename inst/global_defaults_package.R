
# The "global_defaults_*.R" files define most default settings.
#
# This one defines some key things, espec those needed even when the shiny app is not being used.
# app_title
# report_title
# app_logo
# report_logo
# reports as URLs to include in bysite tables.

#  . app _ title was renamed as app _ title
#  . community _ report _ title was renamed as report _ title
#  . community _ report _ logo _ path  was renamed  as   report _ logo
# etc
############################### ################################ ################################ #

# APP VERSION info ####

# app_version <- desc::desc_get("Version") # should be same as this:
app_version <- EJAM:::description_file$get("Version")  # based on Version field in DESCRIPTION file, description_file is an object created in EJAM namespace by metadata_mapping.R when loaded/attached
app_version_header_text <- paste0("  (Version ", app_version, ")")
app_version_short <- substr(app_version, start = 1, stop = gregexpr('\\.', app_version)[[1]][2] - 1) ## trim version number to Major.Minor

global_defaults_package <- list(
  app_version             = app_version,
  app_version_header_text = app_version_header_text,
  app_version_short       = app_version_short
)
# clean up
rm(app_version,
   app_version_header_text,
   app_version_short)
############################### #

# APP TITLE ####

# app_title is used in shiny app headers, documentation pages, etc., e.g.
#   "Environmental Justice Analysis Multisite tool"  or    "Environmental and Residential Population Analysis Multisite tool"

# global_defaults_package$app_title = as.vector(desc::desc_get("Title"))
global_defaults_package$app_title = as.vector(desc::desc_get("Title", file = system.file("DESCRIPTION", package = "EJAM")))
# REPORT TITLE ####

# report_title is used in header of summary /community report page.
# "Summary Report"  or  "EJAM Multisite Report" is not right in case it is a single site (or barplots version via build_barplot_report.R)

global_defaults_package$report_title = "EJAM Summary Report"

############################### #

# APP LOGO ####

# app_logo is used in header at top of app webpage
# app_logo_aboutpage is used in the About tab

# report_logo etc. is used in top part of 1page summary report,
#   used by generate_html_header(), as called from  build_barplot_report()
#   or   build_community_report() as called from server and .Rmd template and ejam2report()

app_logo <- "www/favicon.png"  # (small wordless hex)

# REPORT LOGO ####

############################### ################################ #
### DEBUGGING ISSUES IN USING system.file() to find logo path after devtools::load_all() is used:
## see .onAttach() code trying to find paths before the pkg is installed or even attached.

report_logo <- system.file('report/community_report/ejamhex4.png', package = "EJAM")

# notloaded_and_notinstalled <- inherits(try( find.package("EJAM") , silent = TRUE), "try-error")
# if (notloaded_and_notinstalled) {
#   report_logo <- "www/ejamhex4.png" # "./inst/report/community_report/ejamhex4.png" # path like www/ is the format that works for downloaded and webpage versions
#   if (!file.exists(report_logo)) {
#     report_logo <- ""
#     cat("Cannot find report_logo from within global_defaults_package.R \n")
#   }
# } else {
#   report_logo <- system.file('report/community_report/ejamhex4.png', package = "EJAM")  #  'www/EPA_logo_white_2.png'  #  was used in the EPA version until 1/2025
#   if ("" %in% report_logo) {
#     warning("report_logo file location could not be set as expected in global_defaults_package.R")
#     possible_logo <- file.path(EJAM:::pkg_dir_loaded_from(), "inst/report/community_report/ejamhex4.png")
#     if (file.exists(possible_logo)) {
#       report_logo <- possible_logo
#     } else {
#       possible_logo <- file.path(EJAM:::pkg_dir_installed(), "report/community_report/ejamhex4.png")
#       if (file.exists(possible_logo)) {
#         report_logo <- possible_logo
#       } else {
#         warning("report_logo file location could not be set as expected in global_defaults_package.R")
#         report_logo <- ""
#       }
#     }
#     rm(possible_logo)
#   }
# }
# rm(notloaded_and_notinstalled)
## later, report_logo is used to create default html like this:
##  logo_html <- paste0('<img src=\"', logo_path, '\" alt=\"logo\" width=\"220\" height=\"70\">')
############################### ################################ #

global_defaults_package <- c(
  global_defaults_package,

  report_logo = report_logo,
  report_logo_file = basename(report_logo),
  report_logo_dir   = dirname(report_logo),

  app_logo_aboutpage = "www/ejamhex4.png", # (large, with words, hex) # width and height are defined in app_ui.R not here, in this case.
  # could also say probably  'report/community_report/ejamhex4.png'

  app_logo = app_logo,
  app_logo_html = "" # later, html logo gets calculated as app starts, based on app_logo (that is here or was passed to ejamapp)
# setting it here would override any app_logo_html parameter passed to ejamapp()
)
# clean up
rm(report_logo, app_logo)
############################### #

# API AVAILABILITY ####

# e.g., to add URL links to single-site reports in popups, excel table, etc.

global_defaults_package <- c(
  global_defaults_package,

  ejscreen_is_down = TRUE,  #
  ejamapi_is_down = FALSE
)
############################### #

# LINKS / URLs to show in bysite tables columns ####

global_defaults_package$default_reports =  list(

  list(header = "EJAM Report",     text = "EJAM Site Report",   FUN = url_ejamapi)   # EJAM summary report (HTML via API)

  , list(header = "EJSCREEN Map",  text =  "EJSCREEN", FUN = url_ejscreenmap)        # EJSCREEN site, zoomed to the location

  # , list(header = "ECHO Report",          text = "ECHO",          FUN = url_echo_facility) # if regid provided # e.g., browseURL(url_echo_facility(regid = 110070874073))
  # , list(header = "FRS Report",           text =  "FRS",          FUN = url_frs_facility)  # if regid provided # e.g., browseURL(url_frs_facility(regid = testinput_registry_id[1]))
  #
  # , list(header = "EnviroMapper Report",  text = "EnviroMapper", FUN = url_enviromapper)   # if lat,lon provided or can be approximated # e.g., browseURL(url_enviromapper(lat = 38.895237, lon = -77.029145, zoom = 17))
  #
  # , list(header = "County Health Report", text = "County",       FUN = url_county_health)  # if fips provided
  # , list(header = "State Health Report",  text = "State",        FUN = url_state_health)   # if fips provided
  #
  # , list(header = "County Equity Atlas Report", text = "County (Equity Atlas)", FUN = url_county_equityatlas)
  # , list(header = "State Equity Atlas Report",  text = "State (Equity Atlas)", FUN = url_state_equityatlas)

)

# should not be needed, but just in case while shifting to this method:
global_defaults_package$default_hyperlink_colnames <- sapply(global_defaults_package$default_reports, function(x) x$header)

############################### #

## to see the headers, text, and parameters of functions:
#
# reports <- global_defaults_package$default_reports
# cbind(header = sapply(reports, function(x) x$header), text = sapply(reports, function(x) x$text), params= sapply(reports, function(x) paste0(names(formals(x$FUN))  , collapse=",")))
# rm(reports)
#
##      header                text           params
## [1,] "EJAM Report"         "Report"       "sitepoints,radius,fips,shapefile,baseurl,linktext,as_html,..."
## [2,] "EJSCREEN Map"        "EJSCREEN"     "sitepoints,lat,lon,as_html,linktext,wherestr,fips,shapefile,baseurl,..."
## [3,] "ECHO Report"         "ECHO"         "regid,as_html,linktext,validate_regids,..."
## [4,] "FRS Report"          "FRS"          "regid,as_html,linktext,validate_regids,..."
## [5,] "EnviroMapper Report" "EnviroMapper" "sitepoints,lon,lat,as_html,linktext,shapefile,fips,zoom,..."
## [6,] "County Report"       "County"       "fips,year,as_html,..."

## etc.
############################### #
# width = 10, height = 50 # in table_xls_format() controls size of excel snapshot of summary report; must adjust if rows/cols changed.
