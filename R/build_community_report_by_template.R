#
#
# report_setup_temp_files <- function(Rmd_name = 'community_report_template.Rmd',
#                                     # or Rmd_name = 'barplot_report_template.Rmd' for single site barplot report
#                                     Rmd_folder = 'report/community_report/') {
#
#   if (!dir.exists(app_sys(Rmd_folder))) {
#     if (dir.exists(app_sys(paste0("inst/", Rmd_folder)))) {
#     Rmd_folder <- paste0("inst/", Rmd_folder)
#     } else {
#         stop("Cannot find the folder with necessary files at", app_sys(Rmd_folder), "or", app_sys(paste0("inst/", Rmd_folder)))
#       }
#   }
#   tempReport <- file.path(tempdir( ), Rmd_name)
#   if (!file.exists(app_sys(paste0(Rmd_folder, Rmd_name))) ||
#       !file.exists(app_sys(paste0(Rmd_folder, 'communityreport.css'))) ||
#       !file.exists(app_sys(file.path(Rmd_folder, 'main.css'))) ||
#       !file.exists(app_sys(file.path(Rmd_folder, basename(EJAM:::global_or_param("report_logo")))))
#
#       ## does not check for or handle logo .png
#   ) {
#     warning(paste0("Necessary files missing from ", app_sys(Rmd_folder)))
#   }
#   # ------------------------------------  maybe it still needs the logo file?
#   if (file.exists(app_sys(paste0(Rmd_folder, EJAM:::global_or_param("report_logo_file"))))) {
#   file.copy(
#     # from = EJAM:::global_or_param("report_logo"),
#     from = app_sys(paste0(Rmd_folder, EJAM:::global_or_param("report_logo_file"))),
#     to = tempReport, overwrite = TRUE)
#   } else {
#   if (file.exists(app_sys(EJAM:::global_or_param("report_logo")))) {
#   file.copy(
#     from = EJAM:::global_or_param("report_logo"),
#     # from = app_sys(paste0(Rmd_folder, EJAM:::global_or_param("report_logo_file"))),
#     to = tempReport, overwrite = TRUE)
#   }}
#   # ------------------------------------ .Rmd template file ----------------------------------------- -
#   file.copy(from = app_sys(paste0(Rmd_folder, Rmd_name)),
#             to = tempReport, overwrite = TRUE)
#   # ------------------------------------ css  ----------------------------------------- -
#   if (!('main.css' %in% list.files(tempdir()))) {
#     file.copy(from = app_sys(file.path(Rmd_folder, 'main.css')),
#               to = file.path(tempdir(), 'main.css'), overwrite = TRUE)
#   }
#   if (!file.exists(file.path(tempdir( ),        'communityreport.css'))) {
#     file.copy(from = app_sys(paste0(Rmd_folder, 'communityreport.css')), # app_sys() is unexported by EJAM pkg
#               to = file.path(tempdir( ),        'communityreport.css'), overwrite = TRUE)
#   }
#   return(tempReport)
# }
########################################################### ############################################################ #
########################################################### ############################################################ #


#' Generate Single-site or Multi-site Summary Report (e.g., .html) USING HTML TEMPLATE
#'
#' Creates a short summary report with tables, map, and plot of indicators that looks like the original 2024 EJSCREEN Community Report
#'
#' @details Can be used by the shiny app server. For use in RStudio,
#' see [ejam2report()] (which relies on this).
#'
#' This function gets called by
#'  app_server but also by [ejam2report()],
#'  and also is used by the community_report_template.Rmd used to generate a report
#'
#'  It uses functions in community_report_helper_funs.R, etc.
#'
#' @param output_df single row of results table from doaggregate - either results_overall or one row of bysite
#' @param analysis_title title to use in header of report
#' @param totalpop total population included in location(s) analyzed
#' @param locationstr description of the location(s) analyzed
#'
#' @param include_ejindexes whether to build tables for summary indexes and supp. summary indexes
#' @param show_ratios_in_report logical, whether to add columns with ratios to US and State overall values, in main table of envt/demog. info.
#'
#' @param extratable_show_ratios_in_report logical, whether to add columns with ratios to US and State overall values, in an extra info table
#' @param extratable_title Text of overall title ABOVE the extra info table
#' @param extratable_title_top_row Text INSIDE the extra info table, top left cell
#' @param extratable_list_of_sections This defines what extra indicators are shown.
#'   It is a named list of vectors,
#'   where each name is text phrase that is title of a section of the table,
#'   and each vector is the vector of colnames of output_df that are indicators
#'   to show in that section, in extra table of demog. subgroups, etc.
#' @param extratable_hide_missing_rows_for only for the indicators named in this vector,
#'   leave out rows in table where raw value is NA,
#'   as with many of names_d_language, in extra table of demog. subgroups, etc.'
#'
#' @param in_shiny whether the function is being called in or outside of shiny - affects location of header
#' @param filename path to file to save HTML content to; if null, returns as string (used in Shiny app)
#' @param report_title generic name of this type of report, to be shown at top, like "EJAM Multisite Report"
#' @param logo_path optional relative path to a logo for the upper right of the overall header.
#'   Ignored if logo_html is specified and not NULL, otherwise uses default or param set in [ejamapp()],
#'  except NULL means default logo, "" means omit logo entirely.
#' @param logo_html optional HTML for img of logo for the upper right of the overall header.
#'   If specified, it overrides logo_path. If omitted, gets created based on logo_path.
#' @param template_path optional path to the .html template file
#' @seealso [ejam2report()]
#'
#' @keywords internal
#' @export
#'
build_community_report_by_template <- function(output_df = testoutput_ejamit_10pts_1miles$results_overall,
                                               analysis_title = "Report", totalpop, locationstr,
                                               include_ejindexes = FALSE,
                                               show_ratios_in_report = FALSE,
                                               extratable_show_ratios_in_report = FALSE,
                                               extratable_title = '',   # 'Additional Information', # above the table
                                               extratable_title_top_row = 'ADDITIONAL INFORMATION', # inside the table, top left cell
                                               extratable_list_of_sections = list(
                                                 # see ejam2report defaults and see global_defaults_*.R
                                                 `Breakdown by Population Group` = names_d_subgroups,
                                                 `Language Spoken at Home` = names_d_language,
                                                 `Language in Limited English Speaking Households` = names_d_languageli,
                                                 `Breakdown by Sex` = c('pctmale','pctfemale'),
                                                 `Health` = names_health,
                                                 `Age` = c('pctunder5', 'pctunder18', 'pctover64'),
                                                 `Community` = names_community[!(names_community %in% c( 'pctmale', 'pctfemale', 'pctownedunits_dupe'))],
                                                 `Poverty` = names_d_extra,
                                                 `Features and Location Information` = c(
                                                   names_e_other,
                                                   names_sitesinarea,
                                                   names_featuresinarea,
                                                   names_flag
                                                 ),
                                                 `Climate` = names_climate,
                                                 `Critical Services` = names_criticalservice,
                                                 `Other` = names_d_other_count
                                                 # , `Count above threshold` = names_countabove # need to fix map_headernames longname and calctype and weight and drop 2 of the 6
                                               ),
                                               ## all the indicators that are in extratable_list_of_sections:
                                               extratable_hide_missing_rows_for = as.vector(unlist(extratable_list_of_sections)),

                                               in_shiny = FALSE,
                                               filename = NULL,
                                               report_title = NULL,
                                               logo_path = NULL, # NULL means default logo, "" means omit logo
                                               logo_html = NULL,
                                               template_path = NULL
) {
  ## if testing:
  # get_global_defaults_or_user_options()
  ################### #####  ################### #### #
  if (missing(template_path) || is.null(template_path)) {
    template_path <- system.file("report/community_report/ejscreen_soe_template.html", package = "EJAM")
    if (!file.exists(template_path)) {
      template_path <- system.file("inst/report/community_report/ejscreen_soe_template.html", package = "EJAM")
    }
    if (!file.exists(template_path)) {
      template_path <- file.path(EJAM:::global_or_param("report_logo_dir"), "ejscreen_soe_template.html")
    }
    if (!file.exists(template_path)) {
      stop("cannot find template .html file")
    }
  }
  ################### #####  ################### #### #
  ## check that analysis was run with EJ columns; if not, don't add them
  if (include_ejindexes) {
    ejcols <- c(names_ej,      names_ej_state,
                names_ej_supp, names_ej_supp_state)
    if (!(all(ejcols %in% names(output_df)))) {
      include_ejindexes <- FALSE
    }
  }

  output_df_rounded <- as.data.frame(output_df)
  output_df_rounded <- format_ejamit_columns(output_df_rounded, names(output_df_rounded)) # adds comma to and makes character the pop column
  if (missing(locationstr)) {
    # warning('locationstr parameter missing')
    locationstr <- ""
  }
  if (missing(totalpop)) {
    if ("pop" %in% names(output_df_rounded)) {
      totalpop <- output_df_rounded$pop # prettyNum(round(output_df_rounded$pop, 0), big.mark = ',')
    } else {
      warning('totalpop parameter or output_df_rounded$pop is required')
      totalpop <- "NA"
    }
  }
  ################### #####  ################### #### #
  varnames_from_template = function(fpath) {
    if (missing(fpath)) {
      fpath = system.file("report/community_report/ejscreen_soe_template.html", package = "EJAM")
    }
    x = readLines(fpath)
    y = grep("\\{\\{.*\\}\\}", x, value = T)
    z = gsub("^.*\\{\\{(.*)\\}\\}.*$", "\\1", y)
    z = trimws(z)
    # length(z)
    # rm(x,y)
    z = unique(z) # 181 unique
    return(z)
  }
  if ("testing" == "no") {

    template_path <- system.file("report/community_report/ejscreen_soe_template.html", package = "EJAM")
  if (!file.exists(template_path)) {
    template_path <- system.file("inst/report/community_report/ejscreen_soe_template.html", package = "EJAM")
  }
  if (!file.exists(template_path)) {
    template_path <- file.path(EJAM:::global_or_param("report_logo_dir"), "ejscreen_soe_template.html")
  }
  template_names_found <- varnames_from_template(template_path)
  paramlist = as.list(rep(9, length(template_names_found)))
  names(paramlist) <- template_names_found
  ht = shiny::htmlTemplate(template_path, ... = paramlist)

    }
  ################### #####  ################### #### #

  more_synonyms = data.frame(
    template_name = c(
      "inputAreaMiles",
        "TOTALPOP", # parameter here
      "LOCATIONSTR",
      "REPORTDATE",
      ## "P_DISABILITY", "RAW_D_DISABLED", "S_D_DISABLED", "S_D_DISABLED_PER", "N_D_DISABLED", "N_D_DISABLED_PER",
      "P_DISABILITY",  # in radial gauge?
      "RAW_D_DISABLED",# synonym? in table?
      "S_D_DISABLED",
      "S_D_DISABLED_PER",
      "N_D_DISABLED",
      "N_D_DISABLED_PER",
      "P_GERMAN", "P_TAGALOG",
          # "P_KOREAN", "P_CHINESE", # ok via fixcolnames_anyoldtype()

      "S_D_DEMOGIDX2", "S_D_DEMOGIDX2_PER", "S_D_DEMOGIDX5", "S_D_DEMOGIDX5_PER",
      "N_D_DEMOGIDX2ST", "N_D_DEMOGIDX2ST_PER", "N_D_DEMOGIDX5ST", "N_D_DEMOGIDX5ST_PER"

      # "RAW_HI_LIFEEXPPCT", "S_HI_LIFEEXPPCT_AVG", "N_HI_LIFEEXPPCT_AVG", "N_HI_LIFEEXPPCT_PCTILE",   "S_HI_LIFEEXPPCT_PCTILE",  # ok via fixcolnames_anyoldtype()
    ),
    rname = c(
      "area_sqmi",
        "totalpop", # parameter here
      "locationstr",
      "REPORTDATE",
      "pctdisability",  #   percent
      "pctdisability", # synonym?  percent
      "state.avg.pctdisability",
      "state.pctile.pctdisability",
      "avg.pctdisability",
      "state.avg.pctdisability",
      "pctlan_german", "pctlan_tagalog",
      # "pctlan_korean", "pctlan_chinese",  # ok via fixcolnames_anyoldtype()

      "state.avg.Demog.Index", "state.pctile.Demog.Index", "state.avg.Demog.Index.Supp", "state.pctile.Demog.Index.Supp",
      "avg.Demog.Index", "pctile.Demog.Index", "avg.Demog.Index.Supp", "pctile.Demog.Index.Supp"
      # lowlifex etc  # ok via fixcolnames_anyoldtype()
    ),
    stringsAsFactors = FALSE
  )

  ################### #####  ################### #### #
  ## see what variables are in the .html template,
  ## and convert each to an rname alias
  template_names_found <- varnames_from_template(template_path)
  template_names_r_style <- template_names_found
  # first convert special cases that were not in map_headernames
  template_names_r_style[template_names_r_style %in% more_synonyms$template_name] <-
    more_synonyms$rname[ match(  template_names_r_style[template_names_r_style %in% more_synonyms$template_name], more_synonyms$template_name) ]
  # now convert all others possible
  template_names_r_style =  fixcolnames_anyoldtype( template_names_r_style, oldtypes = c( 'csvname', 'api_synonym',  'apiname', 'acsname', 'oldname'))

  ################### #####  ################### #### #
  ## now we have the r-style names of the parameters needed from output_df,
  ## so rename names of paramlist from r-style to the template-style names
  r2template_synonyms = data.frame(
    rname = template_names_r_style,
    template_name = template_names_found,
    stringsAsFactors = FALSE
  )

  paramlist =  as.list(output_df)
  param_names_r = names(paramlist)
  # first convert special cases
  param_names_template_style = param_names_r
  param_names_template_style[param_names_template_style %in% more_synonyms$rname] <-
    more_synonyms$template_name[match( param_names_template_style[param_names_template_style %in% more_synonyms$rname], more_synonyms$rname )]

  # now convert all others possible, but using the alias found in the template, specifically
  param_names_template_style[param_names_template_style %in% r2template_synonyms$rname] <-
    r2template_synonyms$template_name[ match( param_names_template_style[param_names_template_style %in% r2template_synonyms$rname], r2template_synonyms$rname) ]
  # now use those new versions of names for the parameters passed to use the html template
  names(paramlist) <- param_names_template_style

  # special parameters, not from the output data.frame from ejamit()
  paramlist$REPORTDATE <- Sys.Date()
  paramlist$TOTALPOP <- totalpop
  paramlist$LOCATIONSTR <- locationstr
  # paramlist$REPORT_TITLE  <- analysis_title # "EJScreen Community Report"
  paramlist$`headContent()` <- NULL
  ################### #####  ################### #### #
  # check / report what is missing in that renaming
  template_needs_but_not_among_params = setdiff(template_names_found, c(names(paramlist), "headContent()" ))
  params_cannot_rename_to_template_term = setdiff(names(paramlist) , template_names_found)
  cat("\n template_needs_but_not_among_params: \n\n", paste0(template_needs_but_not_among_params, collapse = ", "), "\n")
  cat("\n params_cannot_rename_to_template_term: \n\n", paste0(params_cannot_rename_to_template_term, collapse = ", "), "\n")

  # put in the missing params as NA values:
  for (nm in template_needs_but_not_among_params) {
    paramlist[[nm]] <- NA
  }
  # drop the ones not used by template?
  paramlist = paramlist[names(paramlist) %in% template_names_found]
  ################### #####  ################### #### #

  ## pass all the indicators as params here

  ht = htmlTemplate(template_path,
                    ... = paramlist
  )
  # htmlTemplate(  "report/community_report/ejscreen_soe_template.html",
  #              button = actionButton("action", "Action"),
  #              slider = sliderInput("x", "X", 1, 100, 50)
  # )
  # htmltools::html_print(ht)


  ## pass the map and plots too?


  return(ht)
  #   ############################################################# #


  # full_page <- paste0(
  #
  #   ############################################################# #
  #
  #   # 1. Report / analysis overall header ####
  #
  #   generate_html_header(analysis_title = analysis_title,
  #                        totalpop = totalpop, locationstr = locationstr,
  #                        in_shiny = in_shiny,
  #                        report_title = report_title,
  #                        logo_path = logo_path,
  #                        logo_html = logo_html
  #   ),
  #
  #   ############################################################# #
  #
  #   # 2. Envt & Demog table ####
  #
  #   generate_env_demog_header(),
  #
  #   fill_tbl_full(output_df = output_df_rounded,
  #                 show_ratios_in_report = show_ratios_in_report
  #   ),
  #   collapse = ''
  # )
  #
  # ############################################################# #
  #
  # # 3. "Summary Index" table ####
  #
  # ## add Summary index and Supp Summary index tables
  # ## only if those columns are available
  # if (include_ejindexes) {
  #   full_page <- paste0(full_page,
  #                       generate_ej_header(),
  #                       fill_tbl_full_ej(output_df_rounded),
  #                       #generate_ej_supp_header(),
  #                       #fill_tbl_full_ej_supp(output_df_rounded),
  #                       collapse = '')
  # }
  # ############################################################# #
  #
  # # 4. Subgroups and Additional info table ####
  #
  # full_page <- paste0(
  #   full_page,
  #   fill_tbl_full_subgroups(output_df = output_df_rounded,
  #                           extratable_title         = extratable_title,         # above table
  #                           extratable_title_top_row = extratable_title_top_row, # inside table, e.g.,  'Additional Information' or 'Additional Indicators'
  #                           extratable_show_ratios_in_report = extratable_show_ratios_in_report,
  #                           list_of_sections      = extratable_list_of_sections,
  #                           hide_missing_rows_for = extratable_hide_missing_rows_for
  #   ),
  #   ############################################################# #
  #
  #   # 5. footnote ####
  #
  #   generate_report_footnotes(
  #     # ejscreen_versus_ejam_caveat = "Note: Some numbers as shown on the EJSCREEN report for a single location will in some cases appear very slightly different than in EJSCREEN's multisite reports. All numbers shown in both types of reports are estimates, and any differences are well within the range of uncertainty inherent in the American Community Survey data as used in EJSCREEN. Slight differences are inherent in very quickly calculating results for multiple locations.",
  #     diesel_caveat = paste0("Note: Diesel particulate matter index is from the EPA's Air Toxics Data Update, which is the Agency's ongoing, comprehensive evaluation of air toxics in the United States. This effort aims to prioritize air toxics, emission sources, and locations of interest for further study. It is important to remember that the air toxics data presented here provide broad estimates of health risks over geographic areas of the country, not definitive risks to specific individuals or locations. More information on the Air Toxics Data Update can be found at: ",
  #                            url_linkify("https://www.epa.gov/haps/air-toxics-data-update", "https://www.epa.gov/haps/air-toxics-data-update"))
  #   ),
  #   collapse = ''
  # )
  # ############################################################# #
  # if (is.null(filename)) {
  #   return(HTML(full_page))
  # } else {
  #   junk <- capture.output({
  #     cat(HTML(full_page))
  #   })
  #   # DO WE NEED TO RENDER  HERE? ***
  #   # OR CAN WE WRITE junk TO A .html FILE - WILL THAT WORK?
  # }


  # was in ui but may need to pass to template here

  # ############################## #
  # ###               > TABLES       ####
  # uiOutput('comm_report_html'),
  # br(),
  # ############################## #
  # ###                > MAP    ####
  # #### quick_view_map (results, in summary report) ### #
  # shinycssloaders::withSpinner(
  #   leaflet::leafletOutput('quick_view_map')#, width = '1170px', height = '627px')
  # ),
  # br(),
  # ############################## #
  # ###                > BARPLOT    ####
  # fluidRow(
  #   column(
  #     12, align = 'center',
  #     br(),br(),
  #     shinycssloaders::withSpinner(
  #       plotOutput(outputId = 'view1_summary_plot', width = '100%', height = '400px')  # {{ demog_plot }} goes in .html template
  #     )
  #   )
  # ),
  # ############################## #
  # ###              > FOOTER  (version, date)    ####
  # div(
  #   style = "background-color: #edeff0; color: black; width: 100%; padding: 10px 20px; text-align: right; margin: 10px 0;",
  #   uiOutput("report_version_date")
  # ),

}
#   ############################################################# #
