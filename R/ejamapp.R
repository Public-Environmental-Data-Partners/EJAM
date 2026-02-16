
#' Launch EJAM as Shiny web app (e.g. to run it locally in RStudio)
#' @description Launch the web app
#'
#' @param ... Special arguments allowing experienced analysts to
#'  customize how the web app works. For example, one can change
#'  default settings for the radius, the type of sites to analyze,
#'  name of the analysis, etc., or to override caps such as limits on
#'  file upload size or number of points.
#'
#'  For example:
#'  ```
#'  ejamapp(
#'    radius=3.1,
#'    default_max_miles=31,
#'    default_max_mb_upload=100
#'  )
#'  ```
#'  See details and examples.
#'
#' @param enableBookmarking see [shiny::shinyApp]
#' This parameter lets a user click the [shiny::bookmarkButton()] in the app
#' to save the state of all  input$  settings.
#'
#' - If enableBookmarking="url" those input$ values are saved in the form
#' of a URL that can be bookmarked or shared with others.
#'
#' - If enableBookmarking="server" that is all saved on the server,
#' and it also can save any uploaded files.
#'
#' - If enableBookmarking="disable", bookmarking is disabled.
#'
#' See [shiny::shinyApp()] [shiny::bookmarkButton()] [shiny::onBookmark()] [shiny::onBookmarked()] [shiny::onRestore()] [shiny::onRestored()]
#' or (https://mastering-shiny.org/action-bookmark.html)
#'
#' @param options see [shiny::shinyApp()], e.g. options = list(launch.browser=TRUE) makes RStudio launch the app in a browser not the built-in viewer pane.
#' @param onStart see [shiny::shinyApp()]
#' @param uiPattern see [shiny::shinyApp()] Do not use
#'
#' @details
#' The custom parameters are "advanced" features for knowledgeable users,
#' and not all the possible changes to these have been tested,
#' so anyone using them should be careful to understand the details
#' of how this work and confirm it is doing what is expected.
#'
#' Many defaults are defined in files like global_defaults_*.R.
#' They can be changed there, but also can be passed here
#' to override those settings for the duration of the app.
#' Some of them can also be adjusted in the web app's Advanced tab, and
#' some (the ones that are inputs in the ui / server)
#' can be bookmarked (saved in a URL) for later use.
#'
#' For more details, see the article on "Defaults and Custom Settings for the Web App"
#'
#' **Examples of custom parameters that you could pass to ejamapp() are shown below.**
#'
#' More about how the app launches:
#'
#' Typically R Shiny apps are not distributed as R packages and
#' launching a shiny app will just [source()] all .R files found in /R/ folder,
#' and then run what is found in `app.R` (assuming it is a one-file Shiny app).
#'
#' This R Shiny app, however, is shared as an R package,
#' via the [golem package](https://thinkr-open.github.io/golem/) approach,
#' which provides the useful features of a package and
#' useful features that the golem package enables.
#'
#' There is a file `app.R` in the package root,
#' used when the shiny app
#' is started locally via RStudio's Run button or on posit connect server.
#'
#' There is a file called `_disable_autoload.R` in the source package /R folder
#' used when the shiny app is started,
#' to tell the server to NOT source all the .R files,
#' since they are already loaded as part of the EJAM package when someone does `require(EJAM)`,
#' i.e., via [require()] or [library()].
#'
#' @examples
#' \dontrun{
#'  # Note some of these settings/ parameters may get renamed to harmonize and simplify names.
#'
#'  ## Provide input sites to app (skip the web app upload clicks),
#'  ## using parameters called `sitepoints` and `shapefile` and `fips` as in [ejamit()]
#'
#'  #  data.frame with latitude, longitude
#'  ejamapp(sitepoints = testpoints_10[1:2,], radius = 3.1)
#'
#'  #  file with latitude, longitude ("pts" is an alias for "sitepoints")
#'  ejamapp(pts = system.file("testdata/latlon/testpoints_10.xlsx", package="EJAM"))
#'
#'  #  spatial data.frame with polygons
#'  ejamapp(shapefile = testshapes_2)
#'
#'  # file with polygons ("shp" is an alias for "shapefile")
#'  ejamapp(shp = system.file("testdata/shapes/testinput_shapes_2.zip", package="EJAM"))
#'
#'
#'  # a vector or file with fips codes
#'  ejamapp(fips = testinput_fips_counties)
#'  ejamapp(fips = testinput_fips_cities)
#'
#'  # all Counties in one State
#' ejamapp(fips = fips_counties_from_state_abbrev("RI"),
#'         analysis_title = "Rhode Island Counties",
#'         report_title = "Overall Summary Report")
#'
#'  # FIPS based on names, but note matching by name is imperfect
#'  # see [name2fips()] for details
#' ejamapp(fips = name2fips(c("akutan,ak", "syracuse city,ny")))
#'
#'
#'  ## More options for settings:
#'
#' ejamapp(
#'   default_show_advanced_settings=TRUE, # to make advanced tab visible at start
#'   analysis_title = "PREFERRED REPORT TITLE FOR THESE ANALYSES",
#'   radius = 3.1, # PREFERRED RADIUS
#'   default_max_miles = 31,      # to raise the radius cap
#'   default_max_mb_upload = 100, # to raise the file upload size cap
#'   radius_default_shapefile = 0.1 # preferred distance from polygons
#' )
#'
#'   ## NAICS as the default:
#'
#'   ## default_selected_type_of_site_upload
#'   ##   defines the initially selected default
#'   ##   If you want to control the options available,
#'   ## default_choices_for_type_of_site_category
#'   ##   defines the range of options
#'
#' ejamapp(
#'   analysis_title="Custom NAICS Analysis",
#'   naics="562211", # or default_naics="562211"
#' )
#'
#'   ## SIC as the default:
#'  sic_from_any(3585)
#'  ejamapp(sic="3585")
#'
#'   ## MACT as the default:
#'  mact_table$dropdown_label
#'  ejamapp(mact="OOOO")
#'
#'   ## Cities dropdown list as default shown at launch:
#'
#' ejamapp(
#'   default_upload_dropdown = "dropdown",
#'   default_selected_type_of_site_category = "FIPS_PLACE",
#'   fipspicker_fips_type2pick_default = "Cities or Places"
#' )
#'
#'   ## Specific cities are preselected at launch
#'
#'   ejamapp(
#'   default_upload_dropdown = "dropdown",
#'   default_selected_type_of_site_category = "FIPS_PLACE",
#'   fipspicker_fips_type2pick_default = "Cities or Places",
#'   default_cities_picked = name2fips(c("akutan,ak", "syracuse city,ny") )
#'   )
#'  ## compare to this which is easier to write,
#'  ## but acts as if they were uploaded so
#'  ## this does not show a dropdown menu where one could revise selections:
#'  ejamapp(fips = name2fips(c("akutan,ak", "syracuse city,ny")))
#'
#'   #default_choices_for_type_of_site_category = c(
#'   #  'by Census place name (Cities, Counties, States)' = 'FIPS_PLACE',
#'   #  'by Industry (NAICS) Code' = 'NAICS',
#'   #  'by Industry (SIC) Code'   = 'SIC',
#'   #  'by EPA Program'           = 'EPA_PROGRAM',
#'   #  'by MACT subpart'          = 'MACT'
#'   #)
#'
#'   ## Polygons upload as the default shown at launch:
#'
#' ejamapp(
#'   default_upload_dropdown = "upload",
#'   default_selected_type_of_site_upload = "SHP"
#' )
#'   #default_choices_for_type_of_site_upload = c(
#'   #  'Shapefile of polygons file upload'              = 'SHP',
#'   #  'Latitude/Longitude file upload'                 = 'latlon',
#'   #  'EPA Facility ID (FRS Identifiers) file upload'  = 'FRS',
#'   #  'EPA Program IDs file upload'                    = 'EPA_PROGRAM',
#'   #  'Census place FIPS Codes file upload'            = 'FIPS'
#'   #)
#'
#'  ## Count how many of some indicator are >= some cutoff
#'
#' ejamapp(
#'   #  Envt indicators, count US or ST 80th+, and count US or ST 95th+
#'   default.an_threshgroup1 = "Envt-US-or-ST-pctile", # among US and ST pctiles
#'   default.an_threshgroup2 = "Envt-US-or-ST-pctile", # same
#'   default.an_threshnames1 = c(EJAM::names_e_pctile, EJAM::names_e_state_pctile),
#'   default.an_threshnames2 = c(EJAM::names_e_pctile, EJAM::names_e_state_pctile),
#'   default.an_thresh_comp1 = 80,   #  how many are >=80th
#'   default.an_thresh_comp2 = 95   #  how many are >=95th
#' )
#'
#' ejamapp(
#'   #  Envt indicators, count US 80th+, and count ST 80th+
#'   default.an_threshgroup1 = "Envt-US-pctile",
#'   default.an_threshgroup2 = "Envt-ST-pctile",
#'   default.an_threshnames1 = EJAM::names_e_pctile,
#'   default.an_threshnames2 = EJAM::names_e_state_pctile,
#'   default.an_thresh_comp1 = 80,   #  how many are >=80th
#'   default.an_thresh_comp2 = 80    #  same
#' )
#'
#'  ## Public hosted app vs full-featured app:
#'
#'  ejamapp( isPublic = TRUE )
#'  # will launch a simpler version of the web app
#'  # (e.g., for more general public use rather than the full set of complicated
#'  # features that are used less often).
#'
#'  # To make a hosted app default to the full set of features
#'  # edit app.R to override/change its default,
#'  #  and to still disable and hide Advanced tab
#'  #  and perhaps hide histograms since they are complicated,
#'  #  try these settings:
#'
#'  ejamapp(
#'   isPublic = FALSE, # to allow full set of features (menus)
#'   default_can_show_advanced_settings = FALSE, # removes user's ability to show Advanced tab
#'   default_show_advanced_settings = FALSE, # just confirms default -- hiding Advanced tab when app launches
#'   default_hide_plot_histo_tab = TRUE # to hide just this feature
#'   )
#'
#'  ## Other options:
#'
#'   ## to show a shorter, reorganized list of extra indicators on report:
#'   default_extratable_list_of_sections = list(
#'     Health = c("pctdisability", "lowlifex",
#'       "rateheartdisease", "rateasthma", "ratecancer", "lifexyears"),
#'     Poverty_Income = c("pctpoor",  "percapincome"),
#'     `Feature Counts` = c("count.NPL", "count.TSDF",
#'       "num_waterdis", "num_airpoll", "num_brownfield", "num_tri",
#'       "num_school", "num_hospital", "num_church")
#'   )
#'
#'   shiny.testmode=TRUE
#'   # aka  default_shiny.testmode=TRUE
#'   # aka  options=list(test.mode=TRUE)
#'   default_testing=TRUE
#' }
#' @return An object that represents the app. Printing the object or
#'   passing it to [runApp()] will run the app, as would just typing
#'   [run_app()] or [ejamapp()] in the console.
#'
#'
#' @export
#'
###################################### ###################################### #

ejamapp <- function(
    ...,
    enableBookmarking = 'url',
    options = list(),  # options specifically for shinyApp(options=xyz). see ?shinyApp
    onStart = NULL,
    uiPattern = "/"
) {

  options(shiny.autoload.r=FALSE) # instead of using the file _disable_autoload.R
  on.exit(options(shiny.autoload.r=FALSE)) # restore normal behavior for rest of R session once app halts

  ################### #
  # handle some key convenient aliases as parameters that are special cases, not inputs and not defaults:

  dots = rlang::list2(...)

  if ("fips" %in% names(dots)) {
    # dots$fips will be used
    if (!('default_upload_dropdown' %in% names(dots))) {
      dots$default_upload_dropdown <- "upload"
    }
    if (!('default_selected_type_of_site_upload' %in% names(dots))) {
      dots$default_selected_type_of_site_upload <- "FIPS"
    }
  }

  if ("shp" %in% names(dots) && !("shapefile" %in% names(dots))) {
    # dots$shp will be used
    dots$shapefile <- dots$shp # convenient alias
    dots$default_upload_dropdown = "upload"
    dots$default_selected_type_of_site_upload = "SHP"
  }
  if ("shapefile" %in% names(dots)) {
    # dots$shapefile will be used
    dots$default_upload_dropdown = "upload"
    dots$default_selected_type_of_site_upload = "SHP"
  }

  if ("pts" %in% names(dots) && !("sitepoints" %in% names(dots))) {
    dots$sitepoints <- dots$pts # convenient alias
  }
  if ("lat" %in% names(dots) && "lon" %in% names(dots) && !("sitepoints" %in% names(dots))) {
    dots$sitepoints = data.frame(lat=dots$lat, lon = dots$lon)
  }
  if ("sitepoints" %in% names(dots)) {
    dots$default_upload_dropdown = "upload"
    dots$default_selected_type_of_site_upload = "latlon"
  }

  if ("naics" %in% names(dots)) {dots$default_naics <- dots$naics}
  if ("default_naics" %in% names(dots)) {
    dots$default_upload_dropdown   <- "dropdown"
    dots$default_selected_type_of_site_category <- "NAICS"
    dots$default_naics_digits_shown <- "detailed"  # if default_naics is >3 digits, this has to be "detailed" not "basic"
  }
  if ("sic" %in% names(dots)) {dots$default_sic <- dots$sic}
  if ("default_sic" %in% names(dots)) {
    dots$default_upload_dropdown   <- "dropdown"
    dots$default_selected_type_of_site_category <- "SIC"
  }
  if ("mact" %in% names(dots)) {dots$default_mact <- dots$mact}
  if ("default_mact" %in% names(dots)) {
    dots$default_upload_dropdown   <- "dropdown"
    dots$default_selected_type_of_site_category <- "MACT"
  }

  if ("default_radius" %in% names(dots)) {
    dots$radius_default <- dots$default_radius
  }
  if ("radius" %in% names(dots)) {
    dots$radius_default <- dots$radius
  }

  # more aliases
  if ("default_report_title_multisite" %in% names(dots) && !("report_title_multisite" %in% names(dots))) {
    dots$report_title_multisite <- dots$default_report_title_multisite
  }
  if ("default_report_title" %in% names(dots) && !("report_title_multisite" %in% names(dots))) {
    dots$report_title_multisite <- dots$default_report_title
  }
  if ("report_title" %in% names(dots) && !("report_title_multisite" %in% names(dots))) {
    # assume they intended to use that for multisite version (also)
    dots$report_title_multisite <- dots$report_title
    #
  }

  if ("default_analysis_title" %in% names(dots)) {
    dots$default_standard_analysis_title <- dots$default_analysis_title
  }
  if ("analysis_title" %in% names(dots)) {
    dots$default_standard_analysis_title <- dots$analysis_title # it is also an input but this allows it to work
  }
  ################### #

  global_defaults_or_user_options <- get_global_defaults_or_user_options(
    user_specified_options = dots, # list(...),
    bookmarking_allowed = enableBookmarking
  )

  golem::with_golem_options(
    app = shiny::shinyApp(
      ui = app_ui,
      server = app_server,
      enableBookmarking = enableBookmarking,
      onStart = onStart,
      options = options,
      uiPattern = uiPattern
    ),
    golem_opts = global_defaults_or_user_options
  )
}
###################################### ###################################### #

#' @inherit ejamapp
#'
#' @export
#' @keywords internal
#'
run_app <- function(
    ...,
    enableBookmarking = 'url',
    options = list(),  # options specifically for shinyApp(options=xyz). see ?shinyApp
    onStart = NULL,
    uiPattern = "/"
) {
  ejamapp(... = ..., enableBookmarking = enableBookmarking, options = options, onStart = onStart, uiPattern = uiPattern)
}
###################################### ###################################### #

#' @inherit ejamapp
#'
#' @export
#' @keywords internal
#'
app_run_EJAM <- function(
    ...,
    enableBookmarking = 'url',
    options = list(),  # options specifically for shinyApp(options=xyz). see ?shinyApp
    onStart = NULL,
    uiPattern = "/"
) {
  ejamapp(... = ..., enableBookmarking = enableBookmarking, options = options, onStart = onStart, uiPattern = uiPattern)
}
###################################### ###################################### #
