
#' Launch EJAM as Shiny web app (e.g. to run it locally in RStudio)
#' @description Launch the web app
#' @param ... arguments to pass to golem_opts.
#'   Note that many defaults are defined in files like global_defaults_*.R.
#'   They can be changed there, but also
#'   can be passed here to override those defaults for the duration of the app.
#'   See details for examples.
#'
#' @details
#' Parameters for how the EJAM app works are given via `...` and are passed to [golem::with_golem_options()].
#' Examples of these parameters that you could pass to run_app() are shown below,
#' but these are not all fully tested:
#'
#'  ```
#'  ## Provide input sites to app (skip the web app upload clicks)
#'
#'  run_app(sitepoints = testpoints_10[1:2,], default_default_miles = 3.1,
#'          default_upload_dropdown = "upload", default_selected_type_of_site_upload = "latlon")
#'
#'  run_app(sitepoints = system.file("testdata/latlon/testpoints_10.xlsx", package="EJAM"),
#'          default_upload_dropdown = "upload", default_selected_type_of_site_upload = "latlon")
#'
#'  run_app(shapefile = testshapes_2,
#'          default_upload_dropdown = "upload", default_selected_type_of_site_upload = "SHP")
#'
#'  run_app(shapefile = system.file("testdata/shapes/testinput_shapes_2.zip", package="EJAM"),
#'          default_upload_dropdown = "upload", default_selected_type_of_site_upload = "SHP")
#'
#'  ## To use preferred settings for your set of analyses:
#'
#' run_app(
#'   default_standard_analysis_title = "PREFERRED REPORT TITLE FOR THESE ANALYSES",
#'
#'   default_default_miles = 3.1, # PREFERRED RADIUS
#'   default_max_miles = 31,      # to raise the radius cap
#'   default_max_mb_upload = 100, # to raise the file upload size cap
#'   default_default_miles_shapefile = 0.1 # preferred distance from polygons
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
#' run_app(
#'   default_upload_dropdown = "dropdown",
#'   default_selected_type_of_site_category = 'NAICS',
#'   default_naics = "562211",  #  initial value of ss_select_naics
#'   default_naics_digits_shown = "detailed", # if default_naics is >3 digits, this has to be "detailed" not "basic"
#'   default_add_naics_subcategories = TRUE
#' )
#'
#'   ## Cities as the default:
#'
#' run_app(
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
#'   ## Polygons as the default:
#'
#' run_app(
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
#' run_app(
#'   #  Envt indicators, count US or ST 80th+, and count US or ST 95th+
#'   default.an_threshgroup1 = "Envt-US-or-ST-pctile", # among US and ST pctiles
#'   default.an_threshgroup2 = "Envt-US-or-ST-pctile", # same
#'   default.an_threshnames1 = c(EJAM::names_e_pctile, EJAM::names_e_state_pctile),
#'   default.an_threshnames2 = c(EJAM::names_e_pctile, EJAM::names_e_state_pctile),
#'   default.an_thresh_comp1 = 80,   #  how many are >=80th
#'   default.an_thresh_comp2 = 95   #  how many are >=95th
#' )
#'
#' run_app(
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
#'  run_app( isPublic = TRUE )
#'  # will launch a simpler version of the web app
#'  # (e.g., for more general public use rather than the full set of complicated
#'  # features that are used less often).
#'  # To make a hosted app default to the full set of features
#'  # edit app.R to override/change its default,
#'  #  and to disable and hide Advanced tab (even though isPublic=FALSE)
#'  #  and perhaps hide histograms since they are complicated,
#'  #  note these settings:
#'
#'  run_app(
#'   isPublic = FALSE,
#'   default_hide_advanced_settings = TRUE, # hides Advanced tab when app launches
#'   default_can_showhide_advanced_settings = FALSE, # removes user's ability to show Advanced tab
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
#'
#'   # untested possible future option:
#'   sitepoints = testpoints_10 # or 'latlondata.xlsx'
#' ```
#'
#' The `enableBookmarking` param lets a user, via the [shiny::bookmarkButton()] in ui,
#' save any uploaded files plus state of all  input$  settings.
#' if enableBookmarking="url" that is all saved on the server.
#' See [shiny::shinyApp()] [shiny::onBookmark()] [shiny::onBookmarked()] [shiny::onRestore()] [shiny::onRestored()]
#' See (https://mastering-shiny.org/action-bookmark.html)
#' or (https://rdrr.io/cran/shiny/man/bookmarkButton.html)
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
#' There is a file called `_disable_autoload.R` in the /R/ folder
#' used when the shiny app is started,
#' to tell the server to NOT source all the .R files,
#' since they are already being loaded from the package by [run_app()]
#'
#' @inheritParams shiny::shinyApp
#' @return An object that represents the app. Printing the object or
#'   passing it to [runApp()] will run the app.
#' @seealso [app_run_EJAM()] and [run_app()] are synonymous
#' @aliases app_run_EJAM
#'
#' @export
#'
run_app <- function(
    onStart = NULL,
    options = list(),  # options specifically for shinyApp(options=xyz). Named options that should be passed to the runApp call (these can be any of the following: "port", "launch.browser", "host", "quiet", "display.mode" and "test.mode"). You can also specify width and height parameters which provide a hint to the embedding environment about the ideal height/width for the app.
    enableBookmarking = 'url',
    uiPattern = "/",
    ...
) {

  global_defaults_or_user_options <- get_global_defaults_or_user_options(
    user_specified_options = list(...),
    bookmarking_allowed = enableBookmarking
  )

  golem::with_golem_options(
    app = shinyApp(
      ui = app_ui,
      server = app_server,
      onStart = onStart,
      options = options,
      enableBookmarking = enableBookmarking,
      uiPattern = uiPattern
    ),
    golem_opts = global_defaults_or_user_options
  )
}
