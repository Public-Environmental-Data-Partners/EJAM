

#' helper to pick text phrase to use in excel report notes tab, for Locations analyzed: _____
#'
#' @param sitetype character string, one of "shp", "latlon", "fips"
#'
#' @param site_method string used in filename for saved report and to describe locations
#'   site_method can be SHP, latlon, FIPS, NAICS, FRS, EPA_PROGRAM, SIC, or MACT
#'
#' @seealso [report_residents_within_xyz_from_ejamit()] and [report_residents_within_xyz()]
#'
#' @returns text string, phrase to use in excel notes tab
#'
#' @keywords internal
#'
buffer_desc_from_sitetype <- function(sitetype, site_method) {

  # see also the closely related functions report_residents_within_xyz() and sitetype2text()

  ######### #

  site_method2text <- function(site_method) {

    if (missing(site_method) || is.null(site_method)) {
      return("")
    }
    if (site_method == "SHP") {
      return("shapefile")
    }
    if (site_method == "latlon") {
      return("coordinates")
    }
    if (site_method == "FIPS") {
      return("FIPS codes")
    }
    if (site_method == "FIPS_PLACES") {
      return("names of places")
    }
    if (site_method == "NAICS") {
      return("EPA-regulated facilities by NAICS code (industry type)")
    }
    if (site_method == "FRS") {
      return("EPA-regulated facilities by Registry ID")
    }
    if (site_method == "EPA_PROGRAM") {
      return("EPA-regulated Facilities by EPA program")
    }
    if (site_method == "SIC") {
      return("EPA-regulated facilities by SIC code (industry type)")
    }
    if (site_method == "MACT") {
      return("EPA-regulated facilities by MACT category (air toxics emissions source type)")
    }
    return("")
  }
  ######### #

  if (missing(sitetype) || is.null(sitetype)) {
    buffer_desc <- "Selected Locations"
  } else {
    if (sitetype == "shp") {
      buffer_desc <- "Polygons defined by shapefile"
    } else {
      if (sitetype == 'latlon') {
        buffer_desc <- "Locations defined by latitude, longitude and radius"
      } else {
        if (sitetype == "fips") {
          buffer_desc <- 'Census Units defined by FIPS code'
        } else {
          buffer_desc <- "Selected locations"
        }}}}
  if (buffer_desc == "") {
    buffer_desc <- paste0(buffer_desc, ", based on ", site_method2text(site_method))
  }
  return(buffer_desc)
}
##################################################################################### #


#' Format the results of ejamit() for excel and optionally save .xlsx file
#'
#' Almost identical to [ejam2excel()]
#'
#' @inheritParams ejam2excel
#'
#' @examples \donttest{
#'   EJAM:::table_xls_from_ejam(testoutput_ejamit_10pts_1miles, fname = tempfile(fileext = ".xlsx"))
#'   }
#' @return returns a workbook object for use by openxlsx::saveWorkbook(wb_out, pathname)
#'   or returns just the full path/file name of where it was saved if save_now = TRUE
#'
#' @keywords internal
#'
table_xls_from_ejam <- function(ejamitout,

                                fname = NULL, # full path and name, or just name of .xlsx file
                                save_now = TRUE,
                                overwrite = TRUE,
                                launchexcel = FALSE,
                                interactive_console = TRUE,
                                in.testing = FALSE,
                                updateProgress = NULL,

                                in.analysis_title =  "EJAM analysis",
                                site_method = "",

                                radius_or_buffer_in_miles = NULL,  #  input$radius_now
                                radius_or_buffer_description = NULL, # like header of reports, or # e.g., 'Miles radius of circular buffer (or distance used if buffering around polygons)',
                                #    "Distance from each site (radius of each circular buffer around a point)",
                                buffer_desc = "Selected Locations",

                                # specify columns with URLs/links to 1-site reports, etc.
                                reports = EJAM:::global_or_param("default_reports"),

                                # plot
                                ok2plot = TRUE,
                                react.v1_summary_plot = NULL,
                                plot_distance_by_group = FALSE,
                                plotlatest = FALSE,
                                plotfilename = NULL,

                                # map
                                mapadd = FALSE,
                                report_map = NULL,

                                # polygons
                                shp = NULL,

                                # html summary report to paste into a tab as static snapshot image
                                community_reportadd = TRUE,
                                community_html = NULL,

                                # column formatting
                                heatmap_colnames = NULL,   heatmap_cuts = c(80, 90, 95),  heatmap_colors  = c("yellow", "orange", "red"), # percentiles
                                heatmap2_colnames = NULL, heatmap2_cuts = c(1.009, 2, 3), heatmap2_colors = c("yellow", "orange", "red"), # ratios
                                graycolnames = NULL, graycolor = 'gray',
                                narrowcolnames = NULL, narrow6 = 6,

                                # notes tab, etc.
                                notes = NULL,
                                custom_tab = NULL,         # but default in ejam2excel is  ejamitout$results_summarized$cols
                                custom_tab_name = "other", # but default in ejam2excel is  "thresholds"
                                ejscreen_ejam_caveat = NULL,
                                ...
) {

  npts <- NROW(ejamitout$results_bysite)

  if (missing(radius_or_buffer_in_miles) || is.null(radius_or_buffer_in_miles)) {
    radius_or_buffer_in_miles  <- ejamitout$results_overall$radius.miles
  }

  #   Note `ejamitout$sitetype` is not quite the same as the `site_method` parameter used in building reports.
  #   sitetype    can be shp, latlon, fips
  #   site_method can be SHP, latlon, FIPS, NAICS, FRS, EPA_PROGRAM, SIC, or MACT
  if (!("sitetype" %in% names(ejamitout))) {
    sitetype <- ejamit_sitetype_from_output(ejamitout)
  } else {
    sitetype <- ejamitout$sitetype
  }
  if (missing(site_method) || is.null(site_method)) {
    site_method <- sitetype
    if (site_method == 'shp' ) site_method <- 'SHP'
    if (site_method == 'fips') site_method <- 'FIPS'
  }

  ## try to sort out what to say and do in these cases:
  ## when shp param is essential  (sitetype == "shp" AND want report or map) but shp missing/null,
  #  when shp param is irrelevant (sitetype == "latlon" OR need neither report nor map) but shp provided,
  #  when shp param is redundant (sitetype == "shp" AND want report or map BUT ALREADY PROVIDED report/map) but shp provided,
  ## when shp param is nonessential but useful (sitetype == "fips" AND want report or map) to avoid a redundant download of FIPS bounds
#
  ### TO BE CONTINUED?
  #
  # if (!is.null(shp) && !community_reportadd && !mapadd) {
  #   message("ignoring shp since mapadd and community_reportadd are both FALSE")
  #   shp <- NULL
  # }
  # if (!is.null(shp) && community_reportadd && !is.null(community_html)) {
  #   message("ignoring shp for community report map since community_html was provided")
  # }
  # # if (sitetype %in% c("shp") && !is.null(shp) && mapadd && !is.null(report_map)) {
  # #   message("using shp for community report map even though report_map was provided")
  # # }
  # if (sitetype %in% c("shp") && mapadd && is.null(report_map) && is.null(shp)) {
  #   warning("cannot add map tab - requires either shp or report_map parameter if sitetype is shp")
  #   mapadd <- FALSE
  # }
  # if (sitetype %in% c("shp") && community_reportadd && is.null(community_html) && is.null(shp)) {
  #   warning("cannot add map in summary report tab - requires either shp or report_map parameter if sitetype is shp")
  # }
  # shp_for_report <- shp
  #
# create report if requested but not provided (and that includes the map within the report)

  if (community_reportadd && is.null(community_html)) {
    # not provided so try to create it here, noting ejam2report() still requires shp to have FIPS or polygon map in report.
    community_html <- ejam2report(
      ejamitout = ejamitout,
      return_html = FALSE,
      launch_browser = FALSE,
      shp = shp, # that will try to download if shp is null and type is fips or shp
      fileextension = ".html",
      submitted_upload_method = site_method

### may need to pass more params here to build report just like server would have?
### ***
   # but the excel version of the summary report is just a snapshot image without working map popups,
  # so we do not have to pass a "reports" parameter, for example that normally would build links to reports.


      )
  }

  # for the notes tab of spreadsheet
  if (missing(buffer_desc) || is.null(buffer_desc)) {
    buffer_desc <- buffer_desc_from_sitetype(sitetype = sitetype, site_method = site_method)
  }

  ## for the notes tab of spreadsheet
  if (missing(radius_or_buffer_description) || is.null(radius_or_buffer_description)) {

    radius_or_buffer_description <- report_residents_within_xyz_from_ejamit(ejamitout = ejamitout, linefeed = ". ")

    # radius_or_buffer_description <- report_residents_within_xyz(radius = radius_or_buffer_in_miles, # gets rounded in this function (if it can be interpreted as a number)
    #                                                             nsites = npts,
    #                                                             sitetype = sitetype)
  }

  # generate filename path
  default_pathname <- create_filename(file_desc = "results_table",
                                      title = in.analysis_title,
                                      buffer_dist = radius_or_buffer_in_miles,
                                      site_method = site_method,
                                      with_datetime = TRUE,
                                      ext = ".xlsx")
  if (is.null(fname)) {
    fname_was_provided <- FALSE
    pathname <- default_pathname
  } else {
    fname_was_provided <- TRUE
    pathname <- fname
  }

  # uses table_xls_format  ####

  # also see the defaults in ejamit() and in table_xls_format()

  # also see the params as used in app_server.R code

  wb_out <- table_xls_format(

    overall   = ejamitout$results_overall, #  1 row with overall results aggregated across sites
    formatted = ejamitout$formatted,
    eachsite  = ejamitout$results_bysite,  #  1 row per site
    bybg      = ejamitout$results_bybg_people, # not entirely sure should provide bybg tab? it is huge and only for expert users but enables a plot
    longnames = ejamitout$longnames,       #  1 row, but full plain English column names

    # fname &
    # save_now &
    # overwrite are handled here by openxlsx::saveWorkbook()], not in table_xls_format() function's saveas and overwrite parameters etc.
    #   saveas = pathname, # could do it this way but then need to condition it on save_now and cannot offer interactive picking of pathname in RStudio
    launchexcel = launchexcel,
    # interactive_console   # handled here not in table_xls_format()
    testing = in.testing, # param name changes here
    updateProgress = updateProgress,

    analysis_title = in.analysis_title, # param name changes here
    sitetype = sitetype, # param here is not quite the same as  site_method param of ejam2excel()

    radius_or_buffer_in_miles    = radius_or_buffer_in_miles,
    radius_or_buffer_description = radius_or_buffer_description,
    buffer_desc = buffer_desc,

    # specify columns with URLs/links to 1-site reports, etc.
    reports = reports,

    # plot
    ok2plot = ok2plot,
    summary_plot   = react.v1_summary_plot, # param name change # NULL is fine
    plot_distance_by_group = plot_distance_by_group,
    plotlatest = plotlatest,
    plotfilename = plotfilename,

    # map
    mapadd = mapadd,
    report_map = report_map,

    # shp is not needed since now report already is here and has map, and hyperlinks are already in eachsite table.

    # html summary report to paste into a tab as static snapshot image
    community_reportadd = community_reportadd,
    community_html = community_html,

    # column formatting
    heatmap_colnames = heatmap_colnames,   heatmap_cuts = heatmap_cuts,  heatmap_colors  = heatmap_colors, # percentiles
    heatmap2_colnames = heatmap2_colnames, heatmap2_cuts = heatmap2_cuts, heatmap2_colors = heatmap2_colors, # ratios
    graycolnames = graycolnames, graycolor = graycolor,
    narrowcolnames = narrowcolnames, narrow6 = narrow6,

    # notes tab, etc.
    notes = notes,
    custom_tab = custom_tab,
    custom_tab_name = custom_tab_name,
    ejscreen_ejam_caveat = ejscreen_ejam_caveat,
    ...
  )

  if (save_now) {
    if (interactive_console && interactive()) {
      if (!fname_was_provided) {
        repeat {
          pathname <- rstudioapi::showPrompt(
            "Save spreadsheet file",
            "Confirm folder and name of file to save",
            default = pathname
          )

          if (is.null(pathname) || pathname ==  "") {
            cat('Invalid path/file, please provide a valid path.\n')
            next
          }
          if (grepl("[<>:\"/\\?*]", pathname)) {
            stop("Filename contains invalid characters: <>:\"/\\|?*. Please provide a valid name. \n")
            next
          }
          break
        }
      }
    }
    # if (is.null(pathname) || pathname == "" || grepl("[<>:\"/\\?*]", pathname)) { #perform a more robust check of the pathname here.
    if (is.null(pathname) || pathname == "" || !dir.exists(dirname(pathname))) { #perform a more robust check of the pathname here.

      cat('Invalid path/file,', pathname, ', so using default instead: ', default_pathname, '\n')
      pathname <- default_pathname
    }

    cat("Saving as ", pathname, "\n")
    ## save file and return for downloading - or do this within table_xls_format( , saveas=fname) ?
    openxlsx::saveWorkbook(wb_out, pathname, overwrite = overwrite)
    return(pathname)
  } else {
    invisible(wb_out)
  }
}
