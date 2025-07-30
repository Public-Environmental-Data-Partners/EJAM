
#' Barplot of ratios of residential population (or other) scores to averages - simpler syntax
#'
#' @aliases plot_barplot_ratios_ez
#' @param ejamitout like from [ejamit()]
#' @param sitenumber default is all sites from ejamitout$results_overall, and
#'   if an integer, it is the row number to show from ejamitout$results_bysite.
#'   Important: note this is the row number which is
#'   NOT necessarily the same as the ejamitout$results_bysite$ejam_uniq_id
#'   notably if FIPS codes were being analyzed.
#' @param varnames vector of indicator names that are ratios to avg, like
#'   c(names_d_ratio_to_avg , names_d_subgroups_ratio_to_avg)
#'   but could be c(names_d_ratio_to_state_avg , names_d_subgroups_ratio_to_state_avg).
#'   Should not be a mix of State and US ratios, however.
#' @param main title of plot - must change to note it vs. State if not comparing to US avg.
#' @param ... passed to [plot_barplot_ratios_ez()]
#' @examples
#'
#' # Check a long list of indicators for any that are elevated
#'
#' out <- testoutput_ejamit_100pts_1miles
#'
#' ejam2barplot(out,
#'   varnames = names_these_ratio_to_avg,
#'   main = "Envt & Demog Indicators at Selected Sites Compared to State Averages")
#'
#' ejam2barplot(out,
#'   varnames = names_these_ratio_to_state_avg,
#'   main = "Envt & Demog Indicators at Selected Sites Compared to State Averages")
#'
#' # Residential population percentages only
#'
#' # vs nationwide avg
#' ejam2barplot(out)
#'
#' # vs statewide avg
#' ejam2barplot(out,
#'   varnames = c(names_d_ratio_to_state_avg, names_d_subgroups_ratio_to_state_avg),
#'   main = "Residential Populations at Selected Sites Compared to State Averages")
#'
#' # Environmental only
#'
#' ejam2barplot(out,
#'   varnames = c(names_e_ratio_to_avg, names_e_ratio_to_state_avg),
#'   main = "Environmental Indicators at Selected Sites Compared to Averages")
#'
#'  ## select your own ratio-type indicators that are available
#'  ## -- and you could see the range of available ratio indicators like this:
#'  \dontrun{
#'  varinfo(
#'    grep("ratio",
#'         names(testoutput_ejamit_10pts_1miles$results_overall),
#'         value = TRUE),
#'    info = c("varlist", "shortname")
#'  )
#'    }
#'
#'  # helper functions related to ejam2barplot()
#'
#'   plot_barplot_ratios_ez(
#'     out,
#'     varnames = c(names_d_ratio_to_avg , names_d_subgroups_ratio_to_avg)
#'   )
#'
#'   # same plot but with function that would need more work to format inputs:
#'   plot_barplot_ratios(
#'       unlist(out$results_overall[ ,
#'       c(..names_d_ratio_to_avg , ..names_d_subgroups_ratio_to_avg) ])
#'       )
#'
#' @return ggplot
#'
#' @export
#'
ejam2barplot = function(ejamitout, varnames = c(names_d_ratio_to_avg , names_d_subgroups_ratio_to_avg),
                        sitenumber = NULL,
                        main = "Residential Populations at the Analyzed Locations Compared to US Overall",
                        ...) {

  if (is.null(sitenumber)) {
    # ejamitout <- ejamitout$results_overall
    single_location <- FALSE
    row_index <- NULL
  } else {
    # ejamitout <- ejamitout$results_bysite # [sitenumber, ] gets done by plot_barplot_ratios_ez()
    single_location <- TRUE
    row_index <- sitenumber
  }

  plot_barplot_ratios_ez(out = ejamitout,
                         varnames = varnames,
                         single_location = single_location, row_index = row_index,
                         main =  main,
                         ... = ...)
}
############################################################################################# #
