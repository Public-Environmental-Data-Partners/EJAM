
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
#'    radius_default=3.1,
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
#'  ## using parameters called `sitepoints` and `shapefile` as in `ejamit()`
#'
#'  #  data.frame with latitude, longitude
#'  ejamapp(sitepoints = testpoints_10[1:2,], radius_default = 3.1,
#'          default_upload_dropdown = "upload", default_selected_type_of_site_upload = "latlon")
#'
#'  #  file with latitude, longitude
#'  ejamapp(sitepoints = system.file("testdata/latlon/testpoints_10.xlsx", package="EJAM"),
#'          default_upload_dropdown = "upload", default_selected_type_of_site_upload = "latlon")
#'  
#'  #  spatial data.frame with polygons
#'  ejamapp(shapefile = testshapes_2,
#'          default_upload_dropdown = "upload", default_selected_type_of_site_upload = "SHP")
#'
#'  # file with polygons
#'  ejamapp(shapefile = system.file("testdata/shapes/testinput_shapes_2.zip", package="EJAM"),
#'          default_upload_dropdown = "upload", default_selected_type_of_site_upload = "SHP")
#'
#'  # a vector or file with fips codes will be allowed also
#'  ejamapp(fips = testinput_fips_counties,
#'          default_upload_dropdown = "dropdown", default_selected_type_of_site_upload = "FIPS") # vs FIPS_PLACE ?***
#'
#'  ## Use preferred settings, for your set of analyses:
#'
#' ejamapp(
#'   default_standard_analysis_title = "PREFERRED REPORT TITLE FOR THESE ANALYSES",
#'   radius_default = 3.1, # PREFERRED RADIUS
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
#'   default_standard_analysis_title="Custom NAICS Analysis",
#'   default_upload_dropdown="dropdown",
#'   default_selected_type_of_site_category="NAICS",
#'   default_naics_digits_shown="detailed", # if default_naics is >3 digits, this has to be "detailed" not "basic"
#'   default_naics="562211",
#'   radius_default=3.1,
#'   default_show_advanced_settings=TRUE
#' )
#'
#'   ## Cities dropdown list as default shown at launch:
#'
#' ejamapp(
#'   default_upload_dropdown = "dropdown",
#'   default_selected_type_of_site_category = "FIPS_PLACE",
#'   fipspicker_fips_type2pick_default = "Cities or Places"
#' )
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
#'  # To make a hosted app default to the full set of features
#'  # edit app.R to override/change its default,
#'  #  and to disable and hide Advanced tab (even though isPublic=FALSE)
#'  #  and perhaps hide histograms since they are complicated,
#'  #  note these settings:
#'
#'  ejamapp(
#'   isPublic = FALSE,
#'   default_show_advanced_settings = FALSE, # hides Advanced tab when app launches
#'   default_can_show_advanced_settings = FALSE, # removes user's ability to show Advanced tab
#'   default_hide_plot_histo_tab = TRUE
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
#' @seealso [ejamapp()], [run_app()], and [app_run_EJAM()] are synonymous
#' @aliases app_run_EJAM run_app
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

  global_defaults_or_user_options <- get_global_defaults_or_user_options(
    user_specified_options = list(...),
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

  global_defaults_or_user_options <- get_global_defaults_or_user_options(
    user_specified_options = list(...),
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

  global_defaults_or_user_options <- get_global_defaults_or_user_options(
    user_specified_options = list(...),
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
