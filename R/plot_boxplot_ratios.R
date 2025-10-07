#' For the outputs of ejscreenit(), get boxplots of Residential Population Percentages across sites as ratios to US means
#'
#' @description boxplots show range of scores here vs range in US overall
#' @md
#' @details
#' See [ejam2boxplot_ratios()] now for ratios plots.
#'
#' See [plot_boxplot_pctiles()] now espec. for percentiles.
#'
#' IMPORTANTLY,
#'   NOTE this uses the ratio at each site
#'   USING THE AVERAGE RESIDENT AT THAT SITE,
#'   SO A BOXPLOT SHOWS ONE DOT PER SITE AND THE BOXPLOT IS NOT POP WTD
#'   MEANING IT SHOWS THE MEDIAN AND 75TH PERCENTILE SITE NOT RESIDENT, ETC.
#'
#' This function originally was used for [ejscreenit()] output, and
#' was just a quick interim solution that could be replaced.
#' It assumed colnames were not r variable names.
#'
#'  To communicate whether this is skewed to the right
#'  (more high scores than might expect) also could say that
#'  X% OF SITES OR PEOPLE have scores in top Y% of US range, >= 100-Y percentile.
#'  e.g., 20% of these sites have scores at least in the top 5% of US scores
#'  (which is more/less than one might expect
#'    - leaving aside statistical significance
#'  ie whether this could be by chance if sites were randomly picked
#'  from US blockgroups or people's bg scores)
#'
#' @param x ratios derived from
#'   a data.frame that is the output of ejscreen analysis, for example:
#'   ```
#'   df <- ejscreenit(testpoints_5)$table
#'   df <- testoutput_ejscreenapi_plus_5
#'   x <- calc_ratios_to_avg(df)$ratios_d
#'
#'   ```
#' @param selected_dvar_colname  default is the first column name of x, such as "Demog.Index"
#'   if given a table with just ratios that are named as regular indicators,
#'   as with output of calc_ratios_to_avg()$ratios_d,
#'   but it tries to figure out if ratios are available and what the base name is
#'   in case output of ejamit() was provided.
#' @param selected_dvar_nicename default is the "short" name of selected_dvar_colname
#'   as converted using [fixcolnames()]
#' @param towhat_nicename default is "US average"
#' @param wheretext Use in plot subtitle. Default is "Near" but could be "Within 5km of" for example.
#'   If it is a number, n, it will set wheretext to "Within n miles of"
#' @param maxratio largest ratio to plot in case of outliers, so plot looks better
#'
#' @return same format as output of [ggplot2::ggplot()]
#'
#' @examples
#'   # x <- testoutput_ejscreenit_50$table # or
#'   x <- testoutput_ejscreenapi_plus_5
#'   myradius <- x$radius.miles[1]
#'   plot_boxplot_ratios(calc_ratios_to_avg(x)$ratios_d, wheretext = myradius)
#'   #plot_boxplot_ratios(calc_ratios_to_avg(x)$ratios_e, wheretext = myradius)
#'
#' @export
#'
plot_boxplot_ratios <- function(x, selected_dvar_colname=varlist2names('names_d')[1], selected_dvar_nicename=selected_dvar_colname, towhat_nicename='US average',
                            maxratio = 5, wheretext="Near") {

  if (is.list(x) && "results_bysite" %in% names(x)) {
    x <- x$results_bysite
    if (selected_dvar_colname)
    x <- as.data.frame(x)[, selected_dvar_colname]
  } # for convenience, in case x was output of ejamit()
  if (is.data.table(x)) {x <- as.data.frame(x)}
  if (is.list(x) && is.data.frame(x[[1]]) && "ratios_d" %in% names(x)) {x <- x$ratios_d } # for convenience, in case you said  plot_boxplot_ratios(calc_ratios_to_avg(out))



  if (!(selected_dvar_colname %in% names(x))) {
    message(paste0(selected_dvar_colname, ' not found in x - using the one with max ratio'))

    # which indicator has the highest ratio among all sites?
    maxvar <- names(which.max(sapply(x, max)))
    selected_dvar_colname  <- maxvar
  }
  # now just use semi-long aka friendly varnames for all the rest of the function
  names(x)              <- fixnames_to_type(names(x),                oldtype = "rname", newtype = "shortlabel")
  selected_dvar_colname <- fixnames_to_type((selected_dvar_colname), oldtype = "rname", newtype = "shortlabel")
  if (missing(selected_dvar_nicename)) {selected_dvar_nicename <- selected_dvar_colname}

  DemogRatio75th <- round(stats::quantile(x[ , selected_dvar_colname], 0.75, na.rm = TRUE), 2) #NEED TO LOOK AT
  #DemogRatio50th <- round(stats::quantile(x[ , selected_dvar_colname], 0.50, na.rm = TRUE), 2)
  mymaintext <- paste0("Ratios to ", towhat_nicename, ", as distributed across these sites")
  if (length(wheretext) != 1) {warning('wheretext must be length 1. replacing with At'); wheretext <- "At"}
  if (is.numeric(wheretext)) {
    wheretext <- paste0("Within ", wheretext," miles of")
  }
  mysubtext <- paste0(
    wheretext,
    ' at least one site, ', selected_dvar_nicename, ' is ',
    round(max(x[ , selected_dvar_colname], na.rm = TRUE), table_rounding_info(selected_dvar_colname)), 'x the ', towhat_nicename, '\n', #NEED TO LOOK AT
    # 'Near most of these ', NROW(x),' sites, ', selected_dvar_nicename,
    # ' is at least ', DemogRatio50th, 'x the ', towhat_nicename, '\n',
    'and at 1 in 4 it is at least ', DemogRatio75th, 'x the ', towhat_nicename
  )
  # note on using ggplot() inside your own function:
  # If your wrapper has a more specific interface with named arguments,
  # you need "enquote and unquote":
  # scatter_by <- function(data, x, y) {
  #   x <- enquo(x)
  #   y <- enquo(y)
  #   ggplot(data) + geom_point(aes(!!x, !!y))
  # }
  # scatter_by(mtcars, disp, drat)

  x %>%
    tidyr::pivot_longer(cols = dplyr::everything()) %>%
    ggplot2::ggplot() +
    ggplot2::geom_boxplot() +

    ## set limits for ratio on y axis - use hard limit at 0, make upper limit 5% higher than max limit
    scale_y_continuous(limits = c(0, maxratio), expand = expansion(mult = c(0, 0.05))) +
    # ylim(c(0, maxratio)) +  # simpler way

    ggplot2::aes(x = name, y = value, fill = name) +
    ggplot2::ggtitle(mymaintext, subtitle = mysubtext) +
    ggplot2::theme(text       = ggplot2::element_text(size = 12))     +
    ggplot2::theme(axis.text.x  = ggplot2::element_text(size = 12,
                                                      angle = 45, vjust = 1, hjust = 1))  +
    ggplot2::theme(axis.title = ggplot2::element_text(size = 12))  +
    ggplot2::theme(plot.title = ggplot2::element_text(size = 24))  +
    ggplot2::theme(plot.title = ggplot2::element_text(size = 24), legend.position = "none") +
    ggplot2::scale_fill_viridis_d(alpha = 0.6) +
    ggplot2::geom_jitter(color = "black", size = 0.4, alpha = 0.9) +
    ggplot2::theme_bw() +
    #   theme_ipsum() +  # that func was from the hrbrthemes pkg, not imported here, now unused - will not rely on that pkg. it was to ensure narrow font in plot
    #    NOTE: Either Arial Narrow or Roboto Condensed fonts are required to use hrbrthemes themes.
    #    Would need to use  hrbrthemes function import_roboto_condensed() to install Roboto Condensed and if Arial Narrow is not on your system (but that was unlikely). see https://bit.ly/arialnarrow
    ggplot2::xlab("") +
    ggplot2::geom_abline(slope = 0, intercept = 1)
}
########################################################################## #
