######################################################################################################## #
# The "global_defaults_*.R" files define most default settings.
#
# This file was intended to define
# just those settings that differ depending on whether the version is "Public" or "Private"
# "Public" here meant a more basic version intended for general public use,
# with fewer complicated or narrow-purpose/uncommonly-used tools and options,
# rather than more advanced/specialized/niche/expert/analyst use.
# "Private" here used to refer to a version hosted only internally for staff analysts, e.g.,
# but also referred to any version of the app run (or package used) locally by analysts.
#
# if (ejamapp(isPublic = TRUE))  it is "Public"
#
# This is sourced by ejamapp() and by .onAttach
# This next line is necessary because while most toggled items are UI/specific to the application,
# a few are variables used also by the package, like the report titles
# so we need to default the isPublic parameter
# but if the user specified in ejamapp(), then take what they specified
######################################################################################################## #
########## #
# isPublic ####
# if user (or app.R) did specify isPublic like by calling ejamapp(isPublic = TRUE), use that setting
if (exists("isPublic")) {
  #isPublic <- isPublic
} else {
  # if user didn't specify isPublic, default to FALSE so RStudio user gets more features without having to say isPublic=FALSE
  isPublic <- FALSE
}
########## #
# use_fipspicker ####
use_fipspicker <- TRUE  # defined here to use in list below in more than 1 place
######################################################################################################## #
# ~ ####
# Create a list called global_defaults_shiny_public ####

global_defaults_shiny_public <- list(

  ## GENERAL OPTIONS & Testing ####
  ### ------------------------ Tabs shown ####

  # About tab
  default_hide_about_tab = FALSE, # now can always show About tab but turn off just that tab's buttons giving users access to advanced tab

  # Advanced tab (NOT ideal for public-facing version)
  #   is the tab hidden initially?
  default_show_advanced_settings = ifelse(isPublic,
                                          FALSE,  # if hosted public app, and app.R  sets isPublic=T, this hides the Adv. tab
                                          FALSE  # initially, at least, we hide it even if isPublic=FALSE (but can override this via ejamapp(default_show_advanced_settings=T))
  ),
  #   is user able to unhide the tab? (via buttons)
  default_can_show_advanced_settings = !isTRUE(isPublic),

  # Histograms tab
  default_hide_plot_histo_tab = isTRUE(isPublic),  # hidden because complicated and public may not want it anyway
  # EJScreen API tab
  default_hide_ejscreenapi_tab = isTRUE(isPublic),  # not used by UI unless ejscreenapi module/tab is re-enabled

  ############################################################################## #

  ## SITE SELECTION  ####

  # 'by Census place name (Cities, Counties, States)' = 'FIPS_PLACE',  # but NOT all fips of one category (unlike for NAICS etc.)

  ### ------------------------ default_choices_for_type_of_site_category  #####

  ## default_choices_for_type_of_site_category defines the range of options
  ## If you want all the options available but want the app to default to NAICS, in ejamapp() use these params:
  # ejamapp(
  #   default_upload_dropdown = "dropdown",
  #   default_choices_for_type_of_site_category = c(
  #     'by Industry (NAICS) Code' = 'NAICS',
  #     'by Census place name (Cities, Counties, States)' = 'FIPS_PLACE',
  #     'by Industry (SIC) Code'   = 'SIC',
  #     'by EPA Program'           = 'EPA_PROGRAM',
  #     'by MACT subpart'          = 'MACT'
  #   )
  # )

  default_choices_for_type_of_site_category = if (isTRUE(isPublic)) {
    c(
      'by Census place name (Cities, Counties, States)' = ifelse(use_fipspicker, 'FIPS_PLACE', NULL),
      'by Industry (NAICS) Code' = 'NAICS'
    )
  } else {
    c(
      'by Census place name (Cities, Counties, States)' = ifelse(use_fipspicker, 'FIPS_PLACE', NULL),
      'by Industry (NAICS) Code' = 'NAICS',
      'by Industry (SIC) Code'   = 'SIC',
      'by EPA Program'           = 'EPA_PROGRAM',
      'by MACT subpart'          = 'MACT'
    )
  },
  default_selected_type_of_site_category = if (isTRUE(isPublic)) {
    # NULL means the initially selected is the 1st on the list above, such as "FIPS_PLACE"
     NULL  # but could be "NAICS" or another of the choices above
  } else {
     NULL  # but could be "NAICS" or another of the choices above
  },


  ### ------------------------ default_choices_for_type_of_site_upload  #####

  ## default_choices_for_type_of_site_upload defines the range of options but also
  ## the initial/default selection will be whatever is first on the list. - see ?ejamapp()
  ## If you want all the options available but want the app to default to polygons, in ejamapp() use these params:
  #
  # ejamapp(
  #   default_upload_dropdown = "upload",
  #   default_choices_for_type_of_site_upload = c(
  #     'Shapefile of polygons file upload'              = 'SHP',
  #     'Latitude/Longitude file upload'                 = 'latlon',
  #     'EPA Facility ID (FRS Identifiers) file upload'  = 'FRS',
  #     'EPA Program IDs file upload'                    = 'EPA_PROGRAM',
  #     'Census place FIPS Codes file upload'            = 'FIPS'
  #   )
  # )

  default_choices_for_type_of_site_upload = if (isTRUE(isPublic)) {
    c(
      'Latitude/Longitude file upload'                = 'latlon',
      'EPA Facility IDs (FRS Identifiers)'            = 'FRS',
      'Shapefile of polygons'                         = 'SHP'
    )
  } else {
    c(
      'Latitude/Longitude file upload'                 = 'latlon',
      'EPA Facility ID (FRS Identifiers) file upload'  = 'FRS',
      'EPA Program IDs file upload'                    = 'EPA_PROGRAM', # <---
      'Shapefile of polygons file upload'              = 'SHP',
      'Census place FIPS Codes file upload'            = 'FIPS'         # <---
    )
  },
  default_selected_type_of_site_upload = NULL, # NULL means initially selected is 1st on list of choices above

  ############################################################################## #

  # RESULTS VIEWS ####

  ## ------------------------ Short report options ####

  default_show_ratios_in_report = !isTRUE(isPublic), # used by app_ui to affect input$show_ratios_in_report which server uses in ejam2report(), etc.
  default_extratable_show_ratios_in_report = !isTRUE(isPublic) # same
)
######################################################################################################## #

print("isPublic is"); print(isPublic)
rm(use_fipspicker)
rm(isPublic) # ok?
