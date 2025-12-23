
#' Save EJAM results in a spreadsheet
#'
#' @description ejam2excel() takes the output of something like ejamit() and
#' creates a spreadsheet with an overall summary tab, a site by site table tab,
#' as well as other tabs such as map, plot, notes, etc.
#'
#' @return returns a workbook object for use by openxlsx::saveWorkbook(wb_out, pathname)
#'   or returns just the full path/file name of where it was saved if save_now = TRUE
#'
#' @param ejamitout output of [ejamit()]
#'
#' @param fname optional name or full path and name of file to save locally, like "out.xlsx"
#' @param save_now optional logical, whether to save as a .xlsx file locally or just return workbook object
#'   that can later be written to .xlsx file using [openxlsx::saveWorkbook()]
#' @param overwrite optional logical, passed to [openxlsx::saveWorkbook()]
#' @param launchexcel optional logical, passed to [table_xls_format()], whether to launch browser to see spreadsheet immediately
#' @param interactive_console optional - should set to FALSE when used in code or server. If TRUE,
#'   prompts RStudio user interactively asking where to save the downloaded file
#' @param in.testing optional logical
#' @param updateProgress optional function used by shiny app to track progress of slow operation
#'
#' @param in.analysis_title optional title as character string, used only in 'Notes' sheet
#'   (and to create a default filename if fname not specified). Not used in the copy of the report.
#' @param site_method site selection method, such as SHP, latlon, FIPS, NAICS, FRS, EPA_PROGRAM, SIC, MACT
#'   optional site method parameter used to create a more specific title with create_filename.
#'   Note `ejamitout$sitetype` is not quite the same as the `site_method` parameter used in building reports.
#'   sitetype can be latlon, fips, or shp
#'   site_method can be one of these: SHP, latlon, FIPS, NAICS, FRS, EPA_PROGRAM, SIC, MACT
#'
#' @param radius_or_buffer_in_miles optional radius in miles
#' @param radius_or_buffer_description optional text phrase describing places analyzed, like in report headers
#' @param buffer_desc description of location to use in labels, like "Selected Locations"
#'
#' @param reports info about which columns to treat as URLs that should be hyperlinks -
#'   see [url_columns_bysite()]
#'
#' @param ok2plot optional logical, passed to  [table_xls_format()], whether safe to try and plot or set FALSE if debugging plot problems
#' @param react.v1_summary_plot optional - a plot object
#' @param plot_distance_by_group optional logical, whether to try to add a plot of mean distance by group.
#'   This requires that bybg be provided as a parameter input to this function.
#' @param plotlatest optional logical. If TRUE, the most recently displayed plot (prior to this function being called) will be inserted into a tab called plot2
#' @param plotfilename optional the full path including name of a .png file to insert
#'
#' @param mapadd optional logical, whether to add a tab with a map of the sites.
#'   If report tab is added, though, standalone static map in excel tab is redundant.
#' @param report_map the leaflet map to display in 'Map' sheet if mapadd is TRUE (re-created if this is omitted/NULL but mapadd is TRUE)
#'
#' @param shp optional shapefile used to create map if not providing it via report_map or community_html parameters
#'
#' @param community_reportadd Logical, whether to add a tab with a static copy of the summary report (tables, map, barplot).
#' @param community_html the HTML file of the summary/community report if available (re-created if this is omitted/NULL but community_reportadd is TRUE)
#'
#' @param heatmap_colnames optional vector of colnames to apply heatmap colors, defaults to percentiles
#' @param heatmap_cuts vector of values to separate heatmap colors, between 0-100 for percentiles
#' @param heatmap_colors vector of color names for heatmap bins, same length as
#'   heatmap_cuts, where first color is for those >= 1st cutpoint, but <2d,
#'   second color is for those >=2d cutpoint but <3d, etc.
#'
#' @param heatmap2_colnames like heatmap_colnames but for ratios by default
#' @param heatmap2_cuts  like heatmap_cuts but for ratios by default
#' @param heatmap2_colors like heatmap_colors but for ratios
#'
#' @param graycolnames which columns to de-emphasize
#' @param graycolor color used to de-emphasize some columns
#' @param narrowcolnames which column numbers to make narrow
#' @param narrow6 how narrow
#'
#' @param notes Text of additional notes to put in the notes tab, optional vector of character elements pasted in as one line each.
#' @param custom_tab optional table to put in an extra tab
#' @param custom_tab_name optional name of optional custom_tab
#' @param ejscreen_ejam_caveat optional text if you want to change this in the notes tab
#'
#' @param ... optional additional parameters passed to [table_xls_format()], currently unused
#'
#'
#' @examples
#' \donttest{
#' # Add purple to flag indicators at 99th percentile
#' ejam2excel(testoutput_ejamit_10pts_1miles,
#'   # View spreadsheet 1st without saving it as a file
#'   launchexcel = T, save_now = F,
#'   heatmap_cuts = c(80, 90, 95, 99),
#'   heatmap_colors  = c("yellow", "orange", "red", "purple"),
#'   # Apply heatmap to only a few of the ratio columns
#'   heatmap2_colnames = names_d_ratio_to_state_avg)
#' }
#'
#' @export
#'
ejam2excel <- function(ejamitout,

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
                       radius_or_buffer_description = NULL, # e.g.,  'Miles radius of circular buffer (or distance used if buffering around polygons)',
                       # radius_or_buffer_description =   "Distance from each site (radius of each circular buffer around a point)",
                       buffer_desc = "Selected Locations",

                       # specify columns with URLs/links to 1-site reports, etc.
                       reports = EJAM:::global_or_param("default_reports"), # defines which hyperlink colnames and text to use

                       # plot
                       ok2plot = TRUE,
                       react.v1_summary_plot = NULL,
                       plot_distance_by_group = FALSE,
                       plotlatest = FALSE,
                       plotfilename = NULL,

                       # map
                       mapadd = FALSE, # if report is added, map is redundant
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
                       custom_tab = ejamitout$results_summarized$cols,
                       custom_tab_name = "thresholds",
                       ejscreen_ejam_caveat = NULL,
                       ...
) {

  # server already handles it, but for nonshiny we can handle adding a missing shapefile for MAP + shapefile for map for REPORT in lower-level function table_xls_format()
  # if report is added, map is redundant
  # if (mapadd == T && is.null(report_map)) {
  #   report_map <- ejam2map(ejamitout)
  # }

  # server already handles it, but for nonshiny we can handle adding a missing shapefile for MAP + shapefile for map for REPORT in lower-level function table_xls_format()
  # if (community_reportadd && is.null(community_html)) {
  #   community_html <- ejam2report(ejamitout = ejamitout, )
  # }

  x <-  table_xls_from_ejam(

    ejamitout = ejamitout,

    fname = fname,
    save_now = save_now,
    overwrite = overwrite,
    launchexcel = launchexcel,
    interactive_console = interactive_console,
    in.testing = in.testing,
    updateProgress = updateProgress,

    in.analysis_title = in.analysis_title,
    site_method = site_method,

    radius_or_buffer_in_miles = radius_or_buffer_in_miles,
    radius_or_buffer_description = radius_or_buffer_description,
    buffer_desc = buffer_desc,

    # specify columns with URLs/links to 1-site reports, etc.
    reports = reports,

    # plot
    ok2plot = ok2plot,
    react.v1_summary_plot = react.v1_summary_plot,
    plot_distance_by_group = plot_distance_by_group,
    plotlatest = plotlatest,
    plotfilename = plotfilename,

    # map
    mapadd = mapadd,
    report_map = report_map,

    # polygons
    shp = shp,

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
    ... = ...
  )
  # tips on how to see the file are printed to console by helpers already

  invisible(x)
}
