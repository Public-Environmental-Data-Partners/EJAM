
# The "global_defaults_*.R" files define most default settings.

# This one sets
# shiny app defaults, options, and variables needed in the global environment,
# (mostly for the shiny app to work rather than for the RStudio-focused functions like ejamit() etc.)

# Note: Do not set defaults specific to a shiny module UNTIL INSIDE THE MODULE, typically, (though fipspicker options may get set here).

################################################################### #
################################################################### #
library(shiny)
EJAM::indexblocks()

################################################################## #
# ------------------------ ____ SET APP DEFAULTS / OPTIONS ------------------------  ####
# (global_defaults_shiny) ####
# ~ ####
# NOTE DEFAULTS HERE ARE UNRELATED TO DEFAULTS IN API module that has its own namespace and is kept separate, like default radius, etc.
# * Note each time a user session is started, the application-level option set is duplicated, for that session.
# * If the options are set from inside the server function, then they will be scoped to the session.
#     LET ADVANCED USERS ADJUST THESE, as INPUTS ON ADVANCED SETTINGS TAB

######################################################################################################## #
#  code-folding brackets for global_defaults_shiny list:
{
# GENERAL OPTIONS & Testing ####

use_shapefile_from_any <- TRUE # used below in list in more than one place so set it here. handles more file formats if TRUE.
######################################################################################################## #

  global_defaults_shiny <- list(

    ## tab shown at launch ####
    # if they are visible, can be "About" or "Advanced Settings" instead of 'Site Selection'
    tabshown_default = 'Site Selection',

    default_testing        = FALSE,
    default_shiny.testmode = FALSE,  # If TRUE, then various features for testing Shiny applications are enabled.
    default_print_uploaded_points_to_log = TRUE,

    ######################################################################################################## #

    # ~ ####

    # SITE SELECTION: CAPS ON UPLOADS, PTS, RADIUS, etc.   ####

    ## ------------------------ Limits on # of points etc. ####

    ## Options in file upload size max
    minmax_mb_upload = 5, # MB
    default_max_mb_upload = 50, # MB (note shiny default is only 5 MB)
    maxmax_mb_upload = 350, # MB

    # input$max_pts_upload
    default_max_pts_upload  =   10 * 1000,
    maxmax_pts_upload  =  35 * 1000, #   cap uploaded points

    # input$max_pts_select
    default_max_pts_select  =   10 * 1000,
    maxmax_pts_select  =  35 * 1000, #   cap selected points

    # input$max_pts_map uses these as its starting value and max allowed value
    default_max_pts_map   = 5 * 1000,
    maxmax_pts_map       = 15 * 1000, # max we will show on map

    marker_cluster_cutoff  = 1 * 1000,  # max before showing points as clusters, for leaflet markerClusters

    # input$max_pts_run uses these as its starting value and max allowed value
    default_max_pts_run  = 10 * 1000, # initial cap but can adjust in advanced tab
    maxmax_pts_run       = 35 * 1000, # absolute max you can analyze here, even with advanced tab

    # input$max_pts_showtable uses these as its starting value and max allowed value
    default_max_pts_showtable = 1000, # max to show in interactive viewer. It drops the rest.
    maxmax_pts_showtable  = 5 * 1000, # 10k is extremely slow. check server side vs client side

    # input$max_shapes_map uses these as its starting value and max allowed value
    default_max_shapes_map = 159, # TX has 254 counties, but no other state exceeds 159. EJAM::blockgroupstats[ , data.table::uniqueN(substr(bgfips, 1,5)), by = ST][order(V1), ]
    maxmax_shapes_map      = 254, # TX has 254 counties

    use_shapefile_from_any = use_shapefile_from_any, # *** newer code - handles more spatial formats like .json etc.

    default_shp_oktypes_1 = if (use_shapefile_from_any) {
      c("zip", "gdb", "geojson", "json", "kml", "shp", "dbf", "sbn", "sbx", "shx", "prj", "cpg")
    } else {
      c("zip",        "geojson", "json",        "shp", "dbf", "sbn", "sbx", "shx", "prj")
    },

    ## ------------------------ Radius options  #####

    #   radius miles for slider input where user specifies radius. Note 5 km is 3.1 miles, 10 km is 6.2 miles ; and 10 miles is 16 kilometers (10 * meters_per_mile/1000). 50 km is too much/ too slow.

  # input$minradius   # bottom end of slider right now
  minradius  = 0.50, # miles -- significant uncertainty as radius shrinks, at least if blockgroups are small such as if # of blockgroups in circle << 30.
  minradius_shapefile = 0,

  stepradius = 0.05, # miles.  0.25 allows quarter miles. 0.10 allows tenths. 0.05 is awkwardly small but allows both quarter mile and tenth of mile.

  # input$radius_default   # initial value of slider
  radius_default = 1,      # and can override this with ejamapp(radius_default=3.1) or ejamapp(radius=3.1) and also see effects of bookmarked advanced settings
  radius_default_shapefile = 0,

  # input$max_miles        # current cap, top end of slider right now
  # These 3 names are tricky - They are the "normal cap" (10 miles)  vs  "absolute cap on slider range" (31 miles) vs  "abs cap on initial value" (31 miles)
  default_max_miles  = 10, # default cap/top end of slider initially #  ** normal cap on slider for current radius (normal top of slider)
  maxmax_miles = 50 * 1000 / EJAM::meters_per_mile, # 50 km.       # ** absolute cap on slider for current radius (max you can make top of slider, in adv tab)
  max_radius_default = 50 * 1000 / EJAM::meters_per_mile, # 50 km. # ** absolute cap on default/initial radius (max starting radius, even using advanced tab)

  ## ------------------------ Site Selection options  #####

  # upload or dropdown method of site selection
  default_upload_dropdown = "upload",
  # global_default or ejamapp() parameter: default_upload_dropdown, which is initial selected value of
  # input in advanced tab: input$default_ss_choose_method, which is initial selected value of
  # input in server:              input$ss_choose_method

  # NAICS
  default_naics = "313", # 313 is about 900 textile mills and subcategories of that #  initial value of ss_select_naics
  default_naics_digits_shown = "basic", # if default_naics is >3 digits, this has to be "detailed" not "basic"
  default_add_naics_subcategories = TRUE,
  # SIC
  default_sic = "2015", # poultry

  # EPA Programs (to limit NAICS/ facilities query)
  # used by inputId 'ss_limit_fac1' and 'ss_limit_fac2'
  default_epa_program_selected = "CAMDBS", # has only about 739 sites # ss_select_program
  # cbind(epa_programs)
  # sort(unique(frs_by_programid$program)) # similar  # EJAM :: frs_by_programid

  # MACT
  default_mact = "AA",
  ##################################################################################### #

  ## ------------------------ fipspicker module ####

  # *** but perhaps these should be set only inside the module, just to avoid clutter, unneeded settings if module unused, and possible namespace conflicts.
  default_cities_picked = "",
  default_counties_picked = "",
  default_states_picked = "",
  fipspicker_fips_type2pick_default = "Counties",  #"Cities or Places",
  fipspicker_fips_type2pick_choices_default = c(
    # `EPA Regions` = "EPA Regions", # if we wanted to allow user to pick an entire EPA Region or two to compare. More useful for filtering mode, like if picking all states within Region 2.
    States = "States",
    Counties = "Counties",
    `Cities/Places` = "Cities or Places"
  ),
  # Limits height of pulldown list of possible choices, but does NOT limit the number of selections shown in selectize box!
  fipspicker_maxOptions_default_states_picked   = 255,
  fipspicker_maxOptions_default_counties_picked = 255,
  fipspicker_maxOptions_default_cities_picked   = 255,

  fipspicker_all_regions_button_defaultchecked  = TRUE,
  fipspicker_all_states_button_defaultchecked   = TRUE,
  fipspicker_all_counties_button_defaultchecked = FALSE,

  fipspicker_all_regions_button_defaultshow  = FALSE,
  fipspicker_all_states_button_defaultshow   = FALSE,
  fipspicker_all_counties_button_defaultshow = FALSE,
  ##################################################################################### #

  ######################################################################################################## #


  # ~ ####
  # CALCULATIONS & what stats to return ####

  default_include_averages = TRUE,         # not implemented and is not a param of a function
  default_include_extraindicators = TRUE,  # not implemented and is not a param of a function


  ## ------------------------ ejamit() params ####


  ### params whose defaults could be included here and in advanced tab:

  # > cbind(formals(ejamit)) or EJAM:::args2()
  #
  # sitepoints               NULL         na
  # radius                   3         for getblocksnearby(), shiny default is set in global
  # radius_donut_lower_edge  0         na
  # maxradius                31.07     for getblocksnearby(), shiny default is set in global
  # avoidorphans             FALSE     for getblocksnearby(), shiny default is set in global
  # quadtree                 NULL      na
  # fips                     NULL      na
  # shapefile                NULL      na
  # countcols                NULL      for doaggregate() ** shiny default NOT specified here
  # popmeancols              NULL      for doaggregate() ** shiny default NOT specified here
  # calculatedcols           NULL      for doaggregate() ** shiny default NOT specified here
  # calctype_maxbg           NULL      for doaggregate() ** shiny default NOT specified here
  # calctype_minbg           NULL      for doaggregate() ** shiny default NOT specified here
  # subgroups_type           "nh"      for doaggregate(), shiny default is set in global
  # include_ejindexes        TRUE      for doaggregate(), shiny default is set in global
  # calculate_ratios         TRUE      for doaggregate(), shiny default is set in global
  # extra_demog              TRUE      for doaggregate(), shiny default is set in global
  # need_proximityscore      FALSE     for doaggregate(), shiny default is set in global
  # infer_sitepoints         FALSE     for doaggregate() ** shiny default NOT specified here
  # need_blockwt             TRUE      for getblocksnearby_from_fips(), shiny default not specified here, but by function defaults
  # thresholds               expression  for batch.summarize() , shiny default is set in global but name may differ
  # threshnames              expression  for batch.summarize(), shiny default is set in global but name may differ
  # threshgroups             expression  for batch.summarize(), shiny default is set in global but name may differ
  # updateProgress           NULL      ** shiny default NOT specified here
  # updateProgress_getblocks NULL      ** shiny default NOT specified here
  # in_shiny                 FALSE     for ejamit(), build_community_report(), and related functions
  # quiet                    TRUE      for getblocksnearby() and batch.summarize(), na

  # silentinteractive        FALSE    for doaggregate() etc. na
  # called_by_ejamit         TRUE     for doaggregate(), na
  # testing                  FALSE    for doaggregate(), shiny default is set in global
  # showdrinkingwater        TRUE     for doaggregate(), na
  # showpctowned             TRUE     for doaggregate(), na
  #   download_fips_bounds_to_calc_areas FALSE
  # ...                      ?         for getblocksnearby(), like use_unadjusted_distance ** shiny default NOT specified here


  ## ------------------------ getblocksnearby() params ####

  # > cbind(formals(getblocksnearby)) or EJAM:::args2()
  #
  # sitepoints              ?       na
  # radius                  3       shiny default is set in global
  # maxradius               31.07   shiny default is set in global
  # radius_donut_lower_edge 0       na
  # avoidorphans            FALSE   shiny default is set in global
  # quadtree                NULL    na
  # quaddatatable           NULL
  # quiet                   FALSE
  # parallel                FALSE
  # use_unadjusted_distance TRUE    ** shiny default NOT specified here
  # ...                     ?

  # > cbind( formals(getblocksnearbyviaQuadTree)[setdiff(names(formals(getblocksnearbyviaQuadTree)), names(formals(getblocksnearby))) ])
  # or EJAM:::args2()
  # report_progress_every_n    500    ** shiny default NOT specified here
  # retain_unadjusted_distance TRUE   ** shiny default NOT specified here
  # updateProgress             NULL   ** shiny default NOT specified here

  default_avoidorphans        = FALSE, # seems like EJSCREEN itself essentially uses FALSE? not quite clear
  default_maxradius =  31.06856,  # max search dist if no block within radius # 50000 / meters_per_mile #, # 31.06856 miles !!
  # also used as the maxmax allowed

  ## ------------------------ doaggregate() params ####

  default_download_city_fips_bounds = TRUE, # if FALSE, area in sq miles would be NA for any city/CDP types of FIPS
  default_download_noncity_fips_bounds = FALSE, # if false, area_sqmi() uses arealand column from blockgroupstats

  # > cbind(formals(doaggregate)) or EJAM:::args2()
  #
  # sites2blocks           ?       na
  # sites2states_or_latlon NA      na
  # radius                 NULL    shiny default is set in global
  # countcols              NULL  ** shiny default NOT specified here
  # wtdmeancols            NULL  ** shiny default NOT specified here
  # calculatedcols         NULL  ** shiny default NOT specified here
  # calctype_maxbg         NULL
  # calctype_minbg         NULL
  # subgroups_type         "nh"     shiny default is set in global
  # include_ejindexes      FALSE    shiny default is set in global
  # calculate_ratios       TRUE     shiny default is set in global
  # extra_demog            TRUE     shiny default is set in global
  # need_proximityscore    FALSE    shiny default is set in global
  # infer_sitepoints       FALSE ** shiny default NOT specified here
  # called_by_ejamit       FALSE    na
  # updateProgress         NULL  ** shiny default NOT specified here
  # silentinteractive      TRUE     na
  # testing                FALSE    shiny default is set in global
  # showdrinkingwater      TRUE     na
  # showpctowned           TRUE     na
  # ...                    ?

  default_include_ejindexes = TRUE, # include_ejindexes is a param in doaggregate() or ejamit()
  default_calculate_ratios = TRUE,   # and see default_show_ratios_in_report;  probably need to calculate even if not shown in excel download, since plots and short summary report rely on them/
  default_extra_demog = TRUE, # extra_demog is a param in  doaggregate() or ejamit(),
  # label = "Need extra indicators, on language, age groups, sex, percent with disability, poverty, etc.",
  default_need_proximityscore = FALSE, # need_proximityscore is a param in doaggregate() or ejamit()

  default_subgroups_type = 'nh',
  # this sets the default in the web app only, not in functions doaggregate() and ejamit() and plot_distance_mean_by_group() etc.,
  # if used outside web app app_server and app_ui code, as in using datacreate_testpoints_testoutputs.R
  # "nh" for non-hispanic race subgroups as in Non-Hispanic White Alone, nhwa and others in names_d_subgroups_nh;
  # "alone" for EJSCREEN v2.2 style race subgroups as in    White Alone, wa and others in names_d_subgroups_alone;
  # "both" for both versions.


  ## ------------------------ batch.summarize() params, Threshold comparisons etc ####

  # > cbind(formals(batch.summarize))
  #
  # sitestats     ?            na
  # popstats      ?            na
  # cols          "all"        ** shiny default NOT specified here
  # wtscolname    "pop"        see doaggregate()
  # probs         expression   ** shiny default NOT specified here. probs = c(0, 0.25, 0.5, 0.75, 0.8, 0.9, 0.95, 0.99, 1)
  # thresholds    expression   shiny default is set in global
  # threshnames   expressions  shiny default is set in global
  # threshgroups  expression   shiny default is set in global
  # na.rm         TRUE         na
  # rowfun.picked "all"     ** shiny default NOT specified here
  # colfun.picked "all"     ** shiny default NOT specified here
  # quiet         FALSE        na
  # testing       FALSE        shiny default is set in global

  ### ---------- threshold comparisons ----------- ####

  # stats summarizing EJ percentiles to count how many are at/above threshold percentile(s)

  # label for each group of indicators

  default.an_threshgroup1 = "EJ-US-or-ST",
  default.an_threshgroup2 = "Supp-US-or-ST",
  ### threshgroups = list("EJ-US-or-ST", "Supp-US-or-ST"), # list(c("EJ US", "EJ State", "Suppl EJ US", "Suppl EJ State")), # list("EJ US", "EJ State", "Suppl EJ US", "Suppl EJ State"), # list("variables"),
  ### threshgroups = list(input$an_threshgroup1, input$an_threshgroup2),

  # variable names of indicators compared to threshold

  default.an_threshnames1 = c(EJAM::names_ej_pctile, EJAM::names_ej_state_pctile), # regular in US or ST
  default.an_threshnames2 = c(EJAM::names_ej_supp_pctile, EJAM::names_ej_supp_state_pctile), # supplemental in US or ST
  ### threshnames = list(input$an_threshnames1, input$an_threshnames2)
  ### threshnames = list(c(names_ej_pctile, names_ej_state_pctile), c(names_ej_supp_pctile, names_ej_supp_state_pctile)), # list(c(names_ej_pctile, names_ej_state_pctile, names_ej_supp_pctile, names_ej_supp_state_pctile)),  #list(names_ej_pctile, names_ej_state_pctile, names_ej_supp_pctile, names_ej_supp_state_pctile),  # list(names(which(sapply(sitestats, class) != "character")))

  # what threshold to compare to

  default.an_thresh_comp1 = 80, # regular
  default.an_thresh_comp2 = 80, # supplemental
  ### thresholds   = list(input$an_thresh_comp1, input$an_thresh_comp2)
  ### thresholds   = list(90, 90) # percentile threshold(s) to compare to like to 90th

  ### ---------- quantiles (probs) ----------- ####
  #
  # unused, but could be used by batch.summarize( probs = as.numeric(input$an_list_pctiles) )
  #
  # probs.default.selected <- c(   0.25,            0.80,     0.95)
  # probs.default.values   <- c(0, 0.25, 0.5, 0.75, 0.8, 0.9, 0.95, 0.99, 1)
  # probs.default.names <- formatC(probs.default.values, digits = 2, format = 'f', zero.print = '0')

  ######################################################################################################## #


  # ~ ####
  # RESULTS VIEWS ####

  ## ------------------------ Interactive plots options ####

  default_allow_median_in_barplot_indicators = FALSE,

  ## ------------------------ Map formatting options ####


  ##  Map colors, weights, opacity

  ### not used (yet)
  default_circleweight = 4,

    ## ------------------------ by-site interactive web table ####

    sitereport_download_buttons_show = FALSE, # whether to use server code and buttons to click in table of sites to get 1-site report (as opposed to a hyperlink that gets it via API)
    sitereport_download_buttons_colname = "Download EJAM Report",

    default_bysite_webtable_colnames = c('ejam_uniq_id',
                                         # sitereport_download_buttons_colname will go here
                                         sapply(EJAM:::global_or_param("default_reports"), function(x) x$header), # vector of colnames of reports
                                         'lon', 'lat', "statename", 'invalid_msg',
                                         'pop',
                                         names_d_state_pctile,
                                         names_d_subgroups_state_pctile,
                                         names_e_state_pctile,
                                         names_ej_state_pctile,

                                         # names_d, names_d_subgroups, names_e,  # basic indicators but not percentiles, not ratios, not extra indicators, etc. !

                                         "blockcount_near_site"
    ),

    ## ------------------------ Excel formatting options ####


    # > (cbind(formals(table_xls_format))) and see ejam2excel()
    #
    # overall                      ?          na
    # eachsite                     ?          na
    # longnames                    NULL       na
    # formatted                    NULL       na
    # bybg                         NULL       na
    # plot_distance_by_group       FALSE      na
    # report_plot                 NULL       na
    # plotlatest                   FALSE      na
    # plotfilename                 NULL       na
    # mapadd                       FALSE      ***
    # community_reportadd          FALSE      ***
    # report_map                   NULL       ***
    # community_image              NULL       na
    # ok2plot                      TRUE       ***
    # analysis_title               "EJAM analysis"       na
    # buffer_desc                  "Selected Locations"  ***
    # radius_or_buffer_in_miles    NULL        na
    # radius_or_buffer_description "Miles radius of circular buffer (or distance used if buffering around polygons)" ***
    # notes                        NULL        ***
    # custom_tab                   NULL        ***
    # custom_tab_name              "other"     ***
    # heatmap_colnames             NULL            ***
    # heatmap_cuts                 expression      ***
    # heatmap_colors               expression      ***
    # heatmap2_colnames            NULL            ***
    # heatmap2_cuts                expression      ***
    # heatmap2_colors              expression      ***
    # reports # not hyperlink_colnames           expression   ***
    # graycolnames                 NULL
    # narrowcolnames               NULL
    # graycolor                    "gray"
    # narrow6                      6
    # testing                      FALSE
    # updateProgress               NULL
    # launchexcel                  FALSE
    # saveas                       NULL
    # ejscreen_ejam_caveat         NULL           ***
    # ...                          ?


    # heatmap column names - defaults could be set here and made flexible in advanced tab


    # heatmap cutoffs for bins - defaults could be set here and made flexible in advanced tab


    # heatmap colors for bins - defaults could be set here and made flexible in advanced tab


    default_ok2plot = TRUE, # the plots to put in excel tabs via table_xls_from_ejam() and table_xls_format() and the plot functions


    ## ------------------------ Short report options ####

    ## TO TURN OFF THE LOGO in the REPORT HEADER, set these to empty ""
    # report_logo = "", report_html = "",
    ## but to  use the logo, should be left as-set in global_defaults_package.R

    # default_standard_analysis_title is now in global_defaults_package.R. # Default title to show on each short report
    default_plotkind_1pager = "bar",  #    Bar = "bar", Box = "box", Ridgeline = "ridgeline"

    default_extratable_title = '', # above the table, not in the upper left cell

    default_extratable_title_top_row = "ADDITIONAL INFORMATION", # upper left cell
    # default_extratable_title was 'Additional Indicators' above the table, but its redundant if
    # extratable_title_top_row is "ADDITIONAL INFORMATION" in upper left cell.

    ## ------------------------ default_show_full_header_footer (EPA header) ####

    ## constant to show/hide EPA HTML header and footer in app UI
    ## for public branch, want to hide so it can be legible when embedded as an iframe
    default_show_full_header_footer = FALSE, # THIS NOW MUST BE FALSE -- TRUE option has been removed since it had been EPA-specific

    # Advanced settings #   defined in global_defaults_shiny_public.R
    # default_show_advanced_settings = FALSE,           # this controls if the adv tab is visible initially
    # default_can_show_advanced_settings = TRUE, # this controls if user has ability to show the adv tab (via the show/hide adv tab buttons)

    # Written Report
    default_hide_written_report = TRUE,

    # Barplots - Plot Average Scores
    default_hide_plot_barplot_tab = FALSE

  )  # global_defaults_shiny list







# default_show_ratios_in_report <- FALSE # and see default_calculate_ratios, calculate_ratios
# if (!default_calculate_ratios) {default_show_ratios_in_report <- FALSE}  # or let it show NA values

#            default_show_ratios_in_report  is defined in manage-public-private
# default_extratable_show_ratios_in_report  is defined in manage-public-private

######################################################## #
### for a UI report builder it may be useful to have a named list of
#  Quoted R expressions!! but be careful since "names_d" can get evaluated and turned into a vector of colnames
#  using eval(parse(text = "names_d"))
#  but eval(parse(text = c("pcthisp", "pctnhba") ))  would fail.

## nice format for UI:
# default_extratable_list_of_sections_usinglists = list(
#   `Breakdown by Race/Ethnicity` = list("`Various population groups` = names_d_subgroups"),
#### etc

list_unattributed = function(mylist) {
  for (i in seq_along(mylist)) {attributes(mylist[[i]]) <- NULL}
  return(mylist)
}

default_extratable_list_of_sections_ui = list(

  # see ejam2report defaults and build_community_report defaults

  `Extra Indicators` = list(  # just a heading for UI
    "`Breakdown by Population Group` = names_d_subgroups", # note here this is a whole quoted line, not a vector of colnames, and names_d_subgroups is not quoted since it is a vector of colnames
    "`Language Spoken at Home` = names_d_language",
    "`Language in Limited English Speaking Households` = names_d_languageli",
    "`Breakdown by Sex` = c('pctmale','pctfemale')", # individual colnames each do get quoted, unlike a variable that is a vector of colnames
    "`Health`  = names_health",
    "`Age` = c('pctunder5', 'pctunder18', 'pctover64')",
    "`Community` = names_community[!(names_community %in% c( 'pctmale', 'pctfemale', 'pctownedunits_dupe'))]",
    "`Poverty` = names_d_extra",
    "`Features and Location Information` = c(
    names_e_other,
    names_sitesinarea,
    names_featuresinarea ,
    names_flag
  )",
    "`Climate` = names_climate",
    "`Critical Services` = names_criticalservice"
  ),
  `Other` = list(  # just a heading for UI
    "`Other` = names_d_other_count"
    # , "`Count above threshold` = names_countabove"  # need to fix map_headernames longname and calctype and weight and drop 2 of the 6
  )
)

result_as_code <- paste("list(\n",
                        paste0(as.vector(unlist(default_extratable_list_of_sections_ui)), collapse = ",\n "), "\n)")
result_as_code <- eval(parse(text = result_as_code))
default_extratable_list_of_sections <- list_unattributed(result_as_code)
# cleanup
rm(result_as_code, default_extratable_list_of_sections_ui)

### for a UI report builder it is useful to have them as above, quoted R expressions
### but now need it converted from quoted R expressions into evaluated results...
##  each element of list is now a vector of strings that are colnames:

# Get rid of the distracting attributes that got created
# extratable_stuff is used by get_global_defaults_or_user_options()
# default_extratable_list_of_sections is used in app_ui.R see shiny::selectizeInput(inputId = "extratable_list_of_sections",
extratable_stuff <- list(
  default_extratable_list_of_sections = default_extratable_list_of_sections,

  ## this is unquoted vector of colnames (e.g., all of the indicators in default_extratable_list_of_sections)
  ## see also defaults in ejam2report() and build_...
  default_extratable_hide_missing_rows_for = as.vector(unlist(default_extratable_list_of_sections)) # c(names_d_language, names_health)
)
######################################################## #
##  get_global_defaults_or_user_options() will add those settings to the overall list, global_defaults_shiny

######################################################## #

################################# #
if (interactive()) {cat("Running shiny app in interactive() mode \n")}
if (FALSE) {
  ## These are just notes, to check this default is same as defaults in functions:
  ##   build_community_report() defaults, ejam2report() defaults, and the global_defaults_*.R  defaults
  ## drafted helper funcs to get default value of an argument from a function:
  ##   fun should be unquoted, arg param should be quoted:
  arg1 <- function(fun,arg) {formals(fun)[[arg]]}
  arg_as_code <- function(myarg) {
    if (class(myarg) == "call") {
      myarg <- paste0(capture.output(myarg), collapse = " ")
      eval(parse(text = myarg))
    } else {
      eval(parse(text = quote(myarg)))
    }
  }
  argdefault <- function(fun,arg) {
    cat(arg, "= ")
    print(arg1(fun,arg))
    arg_as_code(arg1(fun,arg))
  }
  # dput(default_extratable_list_of_sections) # messier view

  v1 = list_unattributed(default_extratable_list_of_sections)
  v2 = list_unattributed(argdefault(ejam2report,            "extratable_list_of_sections"))
  v3 = list_unattributed(argdefault(build_community_report, "extratable_list_of_sections"))
  if (!all.equal(v1, v2)) {warning("default_extratable_list_of_sections in global_defaults_*.R and ejam2report() defaults do not match")}
  if (!all.equal(v1, v3)) {warning("default_extratable_list_of_sections in global_defaults_*.R and build_community_report() defaults do not match")}

  rm(v1,v2,v3,arg1,arg_as_code,argdefault)
}
rm(list_unattributed)
######################################################## #


## ------------------------ Long report options ####

# to be continued...
# relocate any here from the Full Report tab?? - defaults could be set here and made flexible elsewhere ***

## now add those settings to the overall list, global_defaults_shiny


} # end code-folding brackets for global_defaults_shiny
######################################################################################################## #
# ~  ####

######################################################## #
# ------------------------ ____ SHINY OPTIONS ------------------------  ####
# ~  ####
## ------------------------ shiny.autoload.r ####
# this option is equivalent to saving a file here: EJAM/R/_disable_autoload.R
options(shiny.autoload.r = FALSE)

## ------------------------ shiny.sanitize.errors ####
# show generalized errors in the UI
options(shiny.sanitize.errors = TRUE)

## ------------------------ spinner.color, spinner.type ####
## note: was set at type = 1, but this caused screen to "bounce"
options(spinner.color = "#005ea2", spinner.type = 4)
## ------------------------ shiny.maxRequestSize ####
options(shiny.maxRequestSize = global_defaults_shiny$default_max_mb_upload * 1024^2)
######################################################## #



################################################################# #
# END OF DEFAULTS / OPTIONS / SETUP
################################################################# #

# ------------------------ ____   _______ ####
# ~ ####
# sanitize_functions is used by get_global_defaults_or_user_options()
sanitize_functions <- list(
  # sanitize_functions ####
   sanitize_text = function(text) {
    gsub("[^a-zA-Z0-9 .-]", "", text)
  },

  sanitize_numeric = function(text) {
    cleaned_text <- gsub("[^0-9.-]", "", as.character(text))

    # Ensure only one decimal point
    cleaned_text <- sub("([0-9]*[.][0-9]*).*", "\\1", cleaned_text)

    cleaned_text <- sub("(.)-(.)", "\\1\\2", cleaned_text)
    cleaned_text <- sub("^(-?).*?(-?.*)$", "\\1\\2", cleaned_text)

    numeric_value <- as.numeric(cleaned_text)

    if (is.na(numeric_value)) {
      return(NA)
    } else {
      return(numeric_value)
    }
  },

  escape_html = function(text) {
    text <- gsub("&", "&amp;", text)
    text <- gsub("<", "&lt;", text)
    text <- gsub(">", "&gt;", text)
    text <- gsub("\"", "&quot;", text)
    text <- gsub("'", "&#39;", text)
    return(text)
  }
)
######################################################## #
######################################################## #

# ~ ####
# ------------------------ ____ ABOUTPAGE & HELP TEXT ------------------------  ####
# ~ ####
# (aboutpage_texts & help_texts) ####

######################################## ######################################### #
## HTML for "About EJAM" tab ####

docs_url            <- EJAM:::repo_from_desc("github.io",  get_full_url = TRUE)
testdata_repo_url   <- EJAM:::repo_from_desc("github.com", get_full_url = TRUE)
testdata_owner_repo <- EJAM:::repo_from_desc("github.com", get_full_url = FALSE)
testdata_repo <-  gsub(".*/", "", testdata_owner_repo)

# aboutpage_texts is used by get_global_defaults_or_user_options()
aboutpage_texts <- list(

  aboutpage_text = tagList(

    # tags$p("For more information about EJAM:"),
    h2( a(href = paste0(docs_url, "/", "articles/whatis.html"), "What is EJAM?",
          target = "_blank", rel = "noreferrer noopener") ),

    p('EJAM is what provides community reports for ',
      a(href = "https://pedp-ejscreen.azurewebsites.net/index.html", "EJSCREEN",
         target = "_blank", rel = "noreferrer noopener"),
      ', and is also known as "EJSCREEN\'s multisite tool."'),
    p("EJAM is a tool that makes it easy to see residential population and environmental information summarized in and across any list of places in the nation. Using this tool is like getting EJSCREEN reports for hundreds or thousands of places, all at the same time."),
    p("This provides interactive results and a formatted, ready-to-share report with tables, graphics, and a map. The report can provide information about communities near any of the industrial facilities on a list, for example."),

    p(paste0('This version of the ', EJAM:::global_or_param("app_title"),
             ' (EJAM) is not associated with the United States Environmental Protection Agency (US EPA), but has its roots in open source code that was originally developed at EPA.')),

    h4("For more information about ",
       a(href = "https://www.ejanalysis.org/status", "the evolving status of EJSCREEN & EJAM since early 2025",
         target = "_blank", rel = "noreferrer noopener"),
       ", see ",
       a(href = "https://www.ejanalysis.org", "ejanalysis.org",
         target = "_blank", rel = "noreferrer noopener")
    ),
    br(),
    br()
  )
)

######################################## ######################################### #
## HTML for Help buttons for uploading ####
# help_texts is used by get_global_defaults_or_user_options()
help_texts <- list(

  # --------------------------------------------------------- #
  ### help text for upload: latlon_help_msg

  latlon_help_msg = paste0('
<div class="row">
  <div class="col-sm-12">
  <div class="well">
  <div id="selectFrom1" class="form-group shiny-input-radiogroup shiny-input-container shiny-input-container-inline">
  <label class="control-label" for="selectFrom1">

  <p>You may upload a list of location coordinates (latitudes and longitudes).</p>',

                           # example file

                           tags$a(href = paste0("https://github.com/",
                                                testdata_owner_repo,
                                                "/blob/master/inst/testdata/latlon/testpoints_10.xlsx?raw=true"), target = "_blank",
                                  "Example of lat lon file"),
                           '
<p>Allowed filetypes: .csv, .xls, or .xlsx</p>
<p>Required column names in first row as header: lat, lon (or aliases)</p>

  <p>It also will work with some alternative names (and case insensitive) like
  Latitude, Lat, latitude, long, longitude, Longitude, Long, LONG, LAT, etc.
  but to avoid any mixup of names it is suggested that the file use lat and lon. </p>

  <p>The file could be formatted as follows, for example: </p>
  </label>
  <br>
  ID,lat,lon<br>
  1,36.26333,-98.48083<br>
  2,41.01778,-80.36194<br>
  3,43.43772,-91.90365<br>
  4,29.69083,-91.34333<br>
  5,40.11389,-75.34806<br>
  6,35.97889,-78.88056<br>
  7,32.82556,-89.53472<br>
  8,30.11275,-83.59778<br>
  9,30.11667,-83.58333<br>
  10,38.06861,-88.75361<br><br>
  </div>
  </div>
  </div>
  </div>'
  ),
  # --------------------------------------------------------- #
  ### help text for upload: shp_help_msg

  shp_help_msg = paste0('
<div class="row">
  <div class="col-sm-12">
  <div class="well">
  <div id="selectFrom1" class="form-group shiny-input-radiogroup shiny-input-container shiny-input-container-inline">
  <label class="control-label" for="selectFrom1">

  <p>You may upload a set polygons in a shapefile.</p>',

                        # example file

                        tags$a(href = paste0("https://github.com/",
                                             testdata_owner_repo,
                                             "/blob/master/inst/testdata/shapes/portland.gdb.zip?raw=true"), target = "_blank", "Example of Shapefile"),
                        '
  <p>The file can be in one of the following formats:</p>
  <p>', paste0(global_defaults_shiny$default_shp_oktypes_1, collapse = ", "), '</p>',
                        '
</div>
  </div>
  </div>
  </div>'
  ),
  # --------------------------------------------------------- #
  ### help text for upload: frs_help_msg

  frs_help_msg = paste0('  <div class="row">
    <div class="col-sm-12">
      <div class="well">
        <div id="selectFrom1" class="form-group shiny-input-radiogroup shiny-input-container shiny-input-container-inline">
          <label class="control-label" for="selectFrom1">

            <p>You may upload a list of FRS IDs. The FRS ID should be in the second column. It should be unique (no duplicates), and it should be titled REGISTRY_ID.</p>
',

                        # example file

                        tags$a(href = paste0("https://github.com/",
                                             testdata_owner_repo,
                                             "/blob/master/inst/testdata/registryid/frs_test_regid_8.xlsx?raw=true"), target = "_blank",
                               "Example of Registry IDs file"),

                        '
<p>Allowed filetypes: .csv, .xls, or .xlsx</p>
<p>Required column names in first row as header: REGISTRY_ID (or alias)</p>

            <h5>The file should be formatted as follows: </h5>
          </label>
					<br>num,REGISTRY_ID<br>
		      1,110000308006<br>
		      2,110000308015<br>
      		3,110000308024<br>
		      4,110000308202<br>
      		5,110000308211<br>
		      <br>
        </div>
      </div>
    </div>
  </div>'),
  # --------------------------------------------------------- #
  ### help text for upload: epa_program_help_msg

  epa_program_help_msg = paste0('
<div class="row">
  <div class="col-sm-12">
  <div class="well">
  <div id="selectFrom1" class="form-group shiny-input-radiogroup shiny-input-container shiny-input-container-inline">
  <label class="control-label" for="selectFrom1">

  <p>You may upload a list of EPA Programs and Program IDs.</p>',

                                # example file

                                tags$a(href = paste0("https://github.com/",
                                                     testdata_owner_repo,
                                                     "/blob/master/inst/testdata/programid/program_test_data_10.xlsx?raw=true"), target =  "_blank" ,
                                       "Example of EPA program ID file"),

                                '  <p>Allowed filetypes: .csv, .xls, or .xlsx</p>
  <p>Required column names in first row as header:  program, pgm_sys_id (or aliases)</p>

  <p>The file should contain at least these two column names in the first row: program and pgm_sys_id.</p>
  <p>It also will work with additional optional columns such as Facility Registry ID (REGISTRY_ID), latitude (lat), and longitude (lon). </p>
  <p>The file could be formatted as follows, for example: </p>
  </label>
  <br>
  program,	pgm_sys_id<br>
NC-FITS,	28122<br>
AIR,	NY0000004432800019<br>
NPDES,	GAR38F1E2<br>
TRIS,	7495WCRHMR59SMC<br>
MN-TEMPO,	17295<br>
HWTS-DATAMART,	CAR000018374<br>
IN-FRS,	330015781585<br>
TX-TCEQ ACR,	RN104404751<br>
NJ-NJEMS,	353065<br>
AIR,	IL000031012ACJ<br>
  </div>
  </div>
  </div>
  </div>'
  ),
  # --------------------------------------------------------- #
  ### help text for upload: fips_help_msg

  fips_help_msg = paste0('
<div class="row">
  <div class="col-sm-12">
  <div class="well">
  <div id="selectFrom1" class="form-group shiny-input-radiogroup shiny-input-container shiny-input-container-inline">
  <label class="control-label" for="selectFrom1">
  ',
                         '<p>You may upload a list of FIPS codes specified at the State (2-digit), County (5-digit),',
                         ' Census Designated Place (CDP) like city or township (6-digit or 7-digit),',
                         ' Tract (11-digit), or blockgroup (12 digit), or even block (15-digit fips).</p>',

                         # example file

                         tags$a(href = paste0("https://github.com/",
                                              testdata_owner_repo,
                                              "/blob/master/inst/testdata/fips/counties_in_Delaware.xlsx?raw=true"), target = "_blank",
                                "Example of FIPS codes file"),

                         '
<p>Allowed filetypes: .csv, .xls, or .xlsx</p>
<p>Required column names in first row as header: FIPS (or alias)</p>

  <p>It will also work with the following aliases: ',
                         'fips, fips_code, fipscode, Fips, statefips, countyfips, ST_FIPS, st_fips
  ',
                         '</p>
  <p>The file could be formatted as follows, for example: </p>
  </label>
  <br>
 FIPS<br>
36001014002<br>
26163594300<br>
36029008600<br>
36061006100<br>
15003005300<br>
<br>
  </div>
  </div>
  </div>
  </div>'
  )

) # end of help_texts list

#################################################################################################################### #
# ~ ####
# ------------------------ ____ TEMPLATE ONE EPA SHINY APP WEBPAGE _______ ####
# (html_fmts) ####
# ~ ####
{ #          code-folding starting point for UI template -------------------------  #
  # html_fmts is used by get_global_defaults_or_user_options()
  html_fmts <- list(
    html_header_fmt = tagList(

      #################################################################################################################### #
      # original starting point of this template was
      #  github.com/USEPA/webcms/blob/main/utilities/r/OneEPA_template.R
      # but also see
      # https://www.epa.gov/themes/epa_theme/pattern-lab/patterns/pages-standalone-template/pages-standalone-template.rendered.html
      # original starting point of SHINY APP WEB UI TEMPLATE to insert within an app's UI/fluid page
      #################################################################################################################### #

      tags$html(class = "no-js", lang = "en"),

      # head ####
      ## Google tag manager unused? ####
      tags$head(
        HTML(
          "<!-- Google Tag Manager

  		  <script>(function(w,d,s,l,i){w[l]=w[l]||[];w[l].push({'gtm.start':
  		new Date().getTime(),event:'gtm.js'});var f=d.getElementsByTagName(s)[0],
  		j=d.createElement(s),dl=l!='dataLayer'?'&l='+l:'';j.async=true;j.src=
  		'https://www.googletagmanager.com/gtm.js?id='+i+dl;f.parentNode.insertBefore(j,f);
  		})(window,document,'script','dataLayer','GTM-L8ZB');</script>

      End Google Tag Manager -->"
        ),

        ## meta tags ####

        tags$meta(charset="utf-8"),

        tags$link(rel="stylesheet", type = "text/css", href = "https://cdnjs.cloudflare.com/ajax/libs/uswds/3.0.0-beta.3/css/uswds.min.css", integrity="sha512-ZKvR1/R8Sgyx96aq5htbFKX84hN+zNXN73sG1dEHQTASpNA8Pc53vTbPsEKTXTZn9J4G7R5Il012VNsDEReqCA==", crossorigin="anonymous", referrerpolicy="no-referrer"),

        ### old EPA-specific tags removed here ####


        tags$meta(name="MobileOptimized", content="width"),
        tags$meta(name="HandheldFriendly", content="true"),
        tags$meta(name="viewport", content="width=device-width, initial-scale=1.0"),
        tags$meta(`http-equiv`="x-ua-compatible", content="ie=edge"),

        ## >> app_title ####

        # and see golem_add_external_resources() in app_ui.R
        # and below in THIN HEADER ROW
        ## but not done this way:   tags$title('EJAM | US EPA'),

        tags$meta(name = "application-name", content = EJAM:::global_or_param("app_title")),

        ### some old EPA-specific tags removed here ####
        ##    these commented out lines were failing to load resource  404
        # tags$link(rel="stylesheet", media="all", href="https://www.epa.gov/core/themes/stable/css/system/components/ajax-progress.module.css?r6lsex"),
        # tags$link(rel="stylesheet", media="all", href="https://www.epa.gov/core/themes/stable/css/system/components/autocomplete-loading.module.css?r6lsex" ),
        # tags$link(rel="stylesheet", media="all", href="https://www.epa.gov/core/themes/stable/css/system/components/js.module.css?r6lsex"),
        # tags$link(rel="stylesheet", media="all", href="https://www.epa.gov/core/themes/stable/css/system/components/sticky-header.module.css?r6lsex"),
        # tags$link(rel="stylesheet", media="all", href="https://www.epa.gov/core/themes/stable/css/system/components/system-status-counter.css?r6lsex"),
        # tags$link(rel="stylesheet", media="all", href="https://www.epa.gov/core/themes/stable/css/system/components/system-status-report-counters.css?r6lsex"),
        # tags$link(rel="stylesheet", media="all", href="https://www.epa.gov/core/themes/stable/css/system/components/system-status-report-general-info.css?r6lsex"),
        # tags$link(rel="stylesheet", media="all", href="https://www.epa.gov/core/themes/stable/css/system/components/tabledrag.module.css?r6lsex"),
        # tags$link(rel="stylesheet", media="all", href="https://www.epa.gov/core/themes/stable/css/system/components/tablesort.module.css?r6lsex"),
        # tags$link(rel="stylesheet", media="all", href="https://www.epa.gov/core/themes/stable/css/system/components/tree-child.module.css?r6lsex"),

        ## some of these provide margins at left of text on About page and in general:
        #
        tags$link(rel="stylesheet", media="all", href="https://www.epa.gov/themes/epa_theme/css/styles.css?r6lsex"),
        tags$link(rel="stylesheet", media="all", href="https://www.epa.gov/themes/epa_theme/css-lib/colorbox.min.css?r6lsex"),
        tags$meta(name="msapplication-TileColor", content="#FFFFFF"),

        ## cloudflare script and container-fluid ####
        tags$script(src = 'https://cdnjs.cloudflare.com/ajax/libs/uswds/3.0.0-beta.3/js/uswds-init.min.js'),

        #fix container-fluid that boostrap RShiny uses
        tags$style(HTML(
          '.container-fluid {
              padding-right: 0;
              padding-left: 0;
              padding-bottom: 0;
              padding-top: 0;
              margin-right: 0;
              margin-left: 0;
              margin-bottom: 0;
              margin-top: 0
              }
          .tab-content {
              margin-right: 30px;
              margin-left: 30px;
          }'
        ))
      ),  # end of head
      ######################################################################## #

      # body ####

      ### cloudflare script ####

      tags$body(
        class = "path-themes not-front has-wide-template", id = "top",
        tags$script(src = 'https://cdnjs.cloudflare.com/ajax/libs/uswds/3.0.0-beta.3/js/uswds.min.js')
      ),
      ######################################################################## #
      ## THIN HEADER ROW ####

      if (!global_defaults_shiny$default_show_full_header_footer) {

        HTML(paste0('
     <div class="container-fluid" style="border-spacing: 0; margin: 0; padding-bottom: 0; border: 0;
     border-right-width: 0px; font-size:24px; ";>

  <div id="ejamheader" style="padding-right: 32px;">

    <table width="100%" style="margin-bottom: 0px; margin-top: 0px";><tbody>
      <tr style="font-size:24px margin-bottom: 0px; margin-top: 0px"; padding-right: 32px;>

        <td  valign="top" style=
          "border-bottom-color: #ffffff; border-top-color: #ffffff; border-left-color: #ffffff; border-right-color: #ffffff;
          margin-bottom: 0px; margin-top: 0px; margin-left: 0px; margin-right: 0px;
          line-height:34px;
          padding-bottom: 0px; padding-top: 0px; padding-left: 30px">

',
                    ### >> app_logo_html ####

                    app_logo_HTML_global_or_param()  #  # built from app_logo unless set in call to ejamapp()
                    ,
        #             '
        # </td>
        #
        # <td valign="bottom" align="left" style="line-height:34px; padding: 0px;
        #   border-bottom-color: #ffffff; border-top-color: #ffffff; border-left-color: #ffffff; border-right-color: #ffffff";
        #   vertical-align: bottom;>',
          '
                <span style="font-size: 15pt; font-weight:700; font-family:Arial";>',   # larger font for app title

                    ### >> app_title  ####

                    EJAM:::global_or_param("app_title"),

                    '</span>',

                    '<span style="font-size: 10pt; font-weight:700; font-family:Arial";>',  # smaller font for version info

                    ### >> app_version_header_text  ####

                    EJAM:::global_or_param("app_version_header_text"),

                    '</span>',
                    '
        </td>',

                    ### >> links (glossary, help, contact) ####
                    # could adjust which of the links here get shown in the header, depending on  isTRUE(golem_opts$isPublic)
                    '
        <td valign="bottom" align="right";  style="line-height:34px; padding: 0px;
                border-bottom-color: #ffffff; border-top-color: #ffffff; border-left-color: #ffffff; border-right-color: #ffffff";>
          <span id="homelinks">

<!--      <a href="https://web.archive.org/web/20250118193121/https://www.epa.gov/ejscreen/overview-socioeconomic-indicators-ejscreen" alt="Go to glossary page" title="Go to EJSCREEN glossary page" target="_blank">Glossary</a> | -->
<!--     <a href="www/user-guide-2025-02.pdf" alt="Go to help document" title="Go to help document" target="_blank">Help</a> | -->

<!--     https://ejanalysis.github.io/EJAM/articles/ejscreen.html would be a more direct link than https://ejanalysis.github.io/EJAM/articles/index.html -->
<a href="https://ejanalysis.github.io/EJAM/articles/index.html" target="_blank" rel="noreferrer">EJSCREEN/EJAM Help</a>

<!--     <a href="https://ejanalysis.github.io/EJAM/articles/index.html" alt="EJSCREEN help" title="EJSCREEN documentation pages" target="_blank">EJSCREEN/EJAM Help</a> | -->
<!--     <a href="mailto:ejam@ejanalysis.com?subject=EJAM%20Multisite%20Tool%20Question" id="emailLink" alt="Contact Us" title="Contact Us">Contact Us</a> | -->

</span>&nbsp;&nbsp;
        </td>
 ',
                    '
      </tr>
    </tbody></table>

  </div>

</div>
     ',
                    ########################################################################## #

                    #HTML(
                    '<div class="l-page  has-footer" style="padding-top:0">
        <div class="l-constrain">

 '
        ))
        ########################################################################## #
        ########################################################################## #

      } else {
        # has been removed since it had been EPA-specific

      } #  end of old EPA-specific html, if  global_defaults_shiny$default_show_full_header_footer
    ), # end of header tag list
    # footer ####
    html_footer_fmt = tagList(
      if (!global_defaults_shiny$default_show_full_header_footer) {
        ## SMALL/NO FOOTER ####
        #
        HTML(
          '
      </div>

      <div class="l-page__footer" style="background-color: #FFFFFF; margin-right: 5px; margin-top:5px; margin-bottom:5px; padding-top:1px; padding-bottom:1px; padding-right: 32px;">


<div class="cejst-btn-wrap" align="right">
  <a
    class="cejst-style-btn"
    href="https://docs.google.com/forms/d/1fY-KLXKt1eeIuGd0GJUYLr3XXwp85_WTLoSUAq5IpEg/viewform"
    target="_blank"
    rel="noopener noreferrer"
  >
    Share data feedback
    <img
      class="cejst-launch-icon"
      src="data:image/svg+xml,%3Csvg xmlns=\'http://www.w3.org/2000/svg\' height=\'24\' viewBox=\'0 0 24 24\' width=\'24\'%3E%3Cpath d=\'M0 0h24v24H0z\' fill=\'none\'/%3E%3Cpath d=\'M19 19H5V5h7V3H5c-1.11 0-2 .9-2 2v14c0 1.1.89 2 2 2h14c1.1 0 2-.9 2-2v-7h-2v7zM14 3v2h3.59l-9.83 9.83 1.41 1.41L19 6.41V10h2V3h-7z\' fill=\'%230050d8\'/%3E%3C/svg%3E"
      alt=""
      aria-hidden="true"
    />
  </a>


  <a
    class="cejst-style-btn"
    href="https://docs.google.com/forms/d/e/1FAIpQLSeQI4Dh3P2mR5crbYsx46Kcn9yaPxhIcIG3qAYNI5xfTojbVA/viewform?usp=dialog"
    target="_blank"
    rel="noopener noreferrer"
  >
    Help improve the tool
    <img
      class="cejst-launch-icon"
      src="data:image/svg+xml,%3Csvg xmlns=\'http://www.w3.org/2000/svg\' height=\'24\' viewBox=\'0 0 24 24\' width=\'24\'%3E%3Cpath d=\'M0 0h24v24H0z\' fill=\'none\'/%3E%3Cpath d=\'M19 19H5V5h7V3H5c-1.11 0-2 .9-2 2v14c0 1.1.89 2 2 2h14c1.1 0 2-.9 2-2v-7h-2v7zM14 3v2h3.59l-9.83 9.83 1.41 1.41L19 6.41V10h2V3h-7z\' fill=\'%230050d8\'/%3E%3C/svg%3E"
      alt=""
      aria-hidden="true"
    />
  </a>
</div>


      </div>

    </div>'
        )
      } else {
        # was EPA-specific footer here
      } # end of if  global_defaults_shiny$default_show_full_header_footer
    )# end of footer tag list
  )
} #         # code folding ending point for UI template
