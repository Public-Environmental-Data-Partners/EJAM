
#' Histogram of single indicator from EJAM output

#' @param ejamitout output of an EJAM analysis, like from [ejamit()], or just the $results_bysite part of that
#'
#' @param varname indicator name that is a column name in ejamitout$results_bysite (or in ejamitout), such as 'Demog.Index' or 'pctlowinc'
#' @param pctile.varname name of percentile version of varname
#' @param popvarname name of column with population counts (default is "pop")
#' @param distn_type group to show distribution across, either 'Sites' or 'People'
#' @param data_type type of values to show for the indicator, either 'raw' or 'pctile'
#'
#' @param n_bins number of bins
#' @param sitetype what type of sites were analyzed, like latlon, fips/FIPS, shp/SHP
#'
#' @param title_people_raw title above plot for this type of plot
#' @param title_people_pctile title above plot for this type of plot
#' @param title_sites_raw title above plot for this type of plot
#' @param title_sites_pctile title above plot for this type of plot
#' @param ylab_sites label on y axis for this type of plot
#' @param ylab_people label on y axis for this type of plot
#'
#' @examples
#' ejam2histogram(testoutput_ejamit_1000pts_1miles, 'Demog.Index',
#'   distn_type = 'Sites', data_type = 'raw')
#'
#' @export
#'
ejam2histogram <- function(ejamitout, varname = "Demog.Index", pctile.varname = paste0("pctile.", varname), popvarname = "pop",
                           distn_type = 'Sites', data_type = 'raw',
                           n_bins = 30, sitetype = NULL,
                           title_people_raw = 'Population Weighted Histogram of Raw Indicator Values',
                           title_people_pctile = 'Population Weighted Histogram of US Percentile Values',
                           title_sites_raw =  'Histogram of Raw Indicator Values Across Sites',
                           title_sites_pctile =  'Histogram of US Percentile Indicator Values Across Sites',
                           ylab_sites = 'Number of sites',
                           ylab_people = 'Weighted Density'
) {

  if ("results_bysite" %in% names(ejamitout)) {
    if (is.null(sitetype)) {
      sitetype <- ejamitout$sitetype
    }
    bysite <- as.data.frame(ejamitout$results_bysite)[, c(varname, pctile.varname, popvarname)]
  } else {
    if (is.data.frame(ejamitout) && varname %in% colnames(ejamitout)) {
      if (is.null(sitetype)) {
        sitetype <- sitetype_from_dt(ejamitout)
      }
      bysite <- as.data.frame(ejamitout)[, c(varname, pctile.varname, popvarname)]
    } else {
      stop("cannot find data in table for histogram")
    }
  }

  ## set font sizes
  ggplot_theme_hist <- ggplot2::theme(
    plot.title = ggplot2::element_text(size = 18, hjust = 0.5),
    axis.text  = ggplot2::element_text(size = 16),
    axis.title = ggplot2::element_text(size = 16)
  )

  ## future settings: bin sizes, reference lines

  if (distn_type == 'Sites') {
    if (data_type == 'raw') {

      ## subset doaggregate results_bysite to selected indicator
      if (tolower(sitetype) == 'shp') {
        hist_input <- as.data.frame(bysite[, varname, drop=FALSE])#input$summ_hist_ind])

      } else {
        hist_input <- bysite[, varname, drop=FALSE]#input$summ_hist_ind, with = F]

      }
      names(hist_input)[1] <- 'indicator'

      ## plot histogram
      ggplot2::ggplot(hist_input) +
        ggplot2::geom_histogram(ggplot2::aes(x = indicator), fill = '#005ea2',
                       bins = n_bins) +
        ## set y axis limits to (0, max value) but allow 5% higher on upper end
        ggplot2::scale_y_continuous(limits = c(0, NA), expand = ggplot2::expansion(mult = c(0, 0.05))) +
        ggplot2::labs(
          x = '',
          y = ylab_sites,
          title = title_sites_raw
        ) +
        ggplot2::theme_bw() +
        ggplot_theme_hist

    } else if (data_type == 'pctile') {

      ## subset doaggregate results_bysite to selected indicator
      if (tolower(sitetype) == 'shp') {

        hist_input <- as.data.frame(bysite[, pctile.varname, drop=FALSE])#input$summ_hist_ind])

      } else {
        hist_input <- bysite[, pctile.varname, drop=FALSE]#input$summ_hist_ind, with = F]

      }
      names(hist_input)[1] <- 'indicator'

      ggplot2::ggplot(hist_input) +
        ggplot2::geom_histogram(ggplot2::aes(x = indicator), fill = '#005ea2',
                       #bins = n_bins,
                       breaks = seq(0,100, length.out = n_bins+1)
        ) +
        ggplot2::labs(
          x = '',
          y = ylab_sites,
          title = title_sites_pctile
        ) +
        ggplot2::theme_bw() +
        ggplot_theme_hist
    }
  } else if (distn_type == 'People') {
    if (data_type == 'raw') {

      ## subset doaggregate results_bysite to selected indicator
      if (tolower(sitetype) == 'shp') {

        hist_input <- as.data.frame(bysite[, c(popvarname,varname)])

      } else {
        hist_input <- bysite[, c(popvarname,varname)]

      }
      names(hist_input)[2] <- 'indicator'

      ## plot population weighted histogram
      ggplot2::ggplot(hist_input) +
        ggplot2::geom_histogram(ggplot2::aes(x = indicator, y = ggplot2::after_stat(density), weight = pop), fill = '#005ea2',
                       bins = n_bins) +
        ## set y axis limits to (0, max value) but allow 5% higher on upper end
        ggplot2::scale_y_continuous(limits = c(0, NA), expand = ggplot2::expansion(mult = c(0, 0.05))) +
        ggplot2::labs(
          x = '',
          y = ylab_people,
          title = title_people_raw
        ) +
        ggplot2::theme_bw() +
        ggplot_theme_hist

    } else if (data_type == 'pctile') {

      ## subset doaggregate results_bysite to selected indicator
      if (tolower(sitetype) == 'shp') {

        hist_input <- as.data.frame(bysite[, c(popvarname, pctile.varname)])

      } else {
        hist_input <- bysite[, c(popvarname, pctile.varname)]

      }
      names(hist_input)[2] <- 'indicator'

      ## plot population weighted histogram
      ggplot2::ggplot(hist_input) +
        ggplot2::geom_histogram(ggplot2::aes(x = indicator, y = ggplot2::after_stat(density), weight = pop), fill = '#005ea2',
                       #bins = n_bins,
                       breaks = seq(0,100, length.out = n_bins+1)
        ) +
        ## set y axis limits to (0, max value) but allow 5% higher on upper end
        ggplot2::scale_y_continuous(limits = c(0, NA), expand = ggplot2::expansion(mult = c(0, 0.05))) +
        ggplot2::labs(
          x = '',
          y = ylab_people,
          title = title_people_pctile
        ) +
        ggplot2::theme_bw() +
        ggplot_theme_hist
    }
  }

}
