

#' Generate HTML Page for Summary Barplot Report in shiny app
#'
#' Creates header and footer of 1 page report to include a barplot on results for one site (to supplement the EJSCREEN Community Report)
#'
#' @details For a related function for use in RStudio,
#' see [ejam2report()] which relies on [build_community_report()]
#'
#'
#' @param analysis_title, title to use in header of report
#' @param totalpop, total population included in location(s) analyzed
#' @param locationstr, description of the location(s) analyzed
#'
#' @param in_shiny, whether the function is being called in or outside of shiny - affects location of header
#' @param filename, optional path to an .html file; if provided, the HTML content
#'   is also written to that file. The HTML is returned either way.
#' @param report_title generic name of this type of report, to be shown at top, like "EJAM Multisite Report"
#' @param logo_path optional relative path to a logo for the upper right of the overall header.
#'   Ignored if logo_html is specified and not NULL, but otherwise uses default or param set in ejamapp()
#' @param logo_html optional HTML for img of logo for the upper right of the overall header.
#'   If specified, it overrides logo_path. If omitted, gets created based on logo_path.
#' @return HTML content of the report header as an [htmltools::HTML()] object,
#'   whether or not `filename` was provided.
#'
#' @keywords internal
#'
build_barplot_report <- function(analysis_title, totalpop, locationstr,
                                   in_shiny = FALSE, filename = NULL,
                                 report_title = NULL,
                                 logo_path = NULL,
                                 logo_html = NULL
) {

  full_page <- paste0(
    generate_html_header(analysis_title = analysis_title,
                         totalpop = totalpop, locationstr = locationstr,
                         in_shiny = in_shiny,
                         report_title = report_title,
                         logo_path = logo_path,
                         logo_html = logo_html),
    collapse = ''
  )
  if (!is.null(filename)) {
    if (!dir.exists(dirname(filename))) {
      stop("Cannot save the report HTML because the folder does not exist: ", dirname(filename))
    }
    writeLines(as.character(full_page), con = filename)
  }
  # Return visibly in both cases - barplot_report_template.Rmd relies on this
  # value auto-printing from its chunk, even when a filename is provided.
  return(HTML(full_page))
}
