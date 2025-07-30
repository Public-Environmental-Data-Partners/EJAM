
#' Make boxplot of ratios to US averages
#' @details
#'  IMPORTANT:
#'   NOTE this uses the ratio at each site
#'   USING THE AVERAGE RESIDENT AT THAT SITE,
#'   SO A BOXPLOT SHOWS ONE DOT PER SITE AND THE BOXPLOT IS NOT POP WTD
#'   MEANING IT SHOWS THE MEDIAN AND 75TH PERCENTILE SITE NOT RESIDENT, ETC.
#'
#' @param ejamitout output from an EJAM analysis, like from [ejamit()]
#' @param radius buffer radius used for an analysis
#' @param varnames currently only works with names_d and names_d_subgroups
#' @param main can specify a main title to use instead of default
#' @param maxratio largest ratio to plot in case of outliers, so plot looks better
#'
#' @returns ggplot object
#'
#' @examples ejam2boxplot_ratios(testoutput_ejamit_1000pts_1miles, radius=1)
#'
#' out <- testoutput_ejamit_100pts_1miles
#' ejam2boxplot_ratios(out, radius=1)
#' ejam2boxplot_ratios(out)
#' ## not ## ejam2boxplot_ratios(out$results_bysite)
#'
#' @export
#'
ejam2boxplot_ratios <- function(ejamitout, radius, varnames = c(names_d, names_d_subgroups),
                                main = NULL, maxratio = 5) {

  ## *** much of this is plotting code is based on plot_boxplot_ratios() - should consolidate

  if (missing(radius)) {radius <- ejamitout$results_bysite$radius.miles[1]}

  rationames <- paste0('ratio.to.avg.', varnames)
  if (is.data.table(ejamitout$results_bysite)) {
    ratio.to.us.d.bysite <- ejamitout$results_bysite[ ,  c(..rationames)]
  } else {
    ratio.to.us.d.bysite <- ejamitout$results_bysite[ , rationames]
  }

  # ratio for average person overall
  ratio.to.us.d    <- unlist(
    ejamitout$results_overall[ , c(rationames )])

  ## assign column names (could use left_join like elsewhere)
  names(ratio.to.us.d.bysite) <-  fixcolnames(varnames, 'r', 'short') # is this right?

  ## pivot data from wide to long - now one row per indicator
  ratio.to.us.d.bysite <- ratio.to.us.d.bysite %>%
    tidyr::pivot_longer(cols = dplyr::everything(), names_to = 'indicator') %>%
    ## replace Infs with NAs - these happen when indicator at a site is equal to zero
    dplyr::mutate(value = dplyr::na_if(.data$value, Inf)) #%>%

  # NOTE NOW ratio.to.us.d.bysite IS A tibble, not data.frame, and is in LONG format now. !!!

  ## find max of ratios ####
  #
  max.ratio.d.bysite <- max(ratio.to.us.d.bysite$value, na.rm = TRUE)
  max.name.d.bysite <- ratio.to.us.d.bysite$indicator[which.max(ratio.to.us.d.bysite$value)]
  #
  # ## now using simpler way, just use a maxratio parameter to do this.
  # ## old way was using max_limit, etc.:
  # ## specify  upper bound for ratios (will drop values above this from graphic)
  # # perhaps want a consistent y limits to ease comparisons across multiple reports the user might run.
  # #  If the max value of any ratio is say 2.6, we might want ylim to be up to 3.0,
  # #  if the max ratio is 1.01, do we still want ylim to be up to 3.0??
  # #  if the max ratio or even max of 95th pctiles is >10, don't show it, but
  # #  what if the 75th pctile value of some indicator is >10? expand the scale to always include all 75ths.
  #
  # q75.maxof75s <- max(quantile(ratio.to.us.d.bysite$value, 0.75, na.rm = TRUE),na.rm = TRUE)
  # ylimit <- ceiling(q75.maxof75s) # max of 75th pctiles rounded up to nearest 1.0x?
  # max_limit <- max(maxratio, ylimit, na.rm = TRUE) #
  ## find 75th %ile of sites, ratios for the indicator with the max ratio
  # q75.ratio.d.bysite <- quantile(ratio.to.us.d.bysite$value[ratio.to.us.d.bysite$indicator == max.name.d.bysite], 0.75, na.rm = TRUE)

  ## paste subtitle for boxplot
  subtitle <- paste0('Within ', radius,' miles of one site, ',
                     max.name.d.bysite, ' is ', round(max.ratio.d.bysite,1), 'x the US average\n' #,
                     # 'and 1 in 4 sites is at least ', round(q75.ratio.d.bysite, 2), 'x the US average' # old way
  )

  ## specify # of characters to wrap indicator labels
  n_chars_wrap <- 13
  towhat_nicename <- "US Average"
  if (is.null(main) || missing(main) || '' %in% main) {
    mymaintext <- paste0("Ratios to ", towhat_nicename, ", as distributed across these sites")
  } else {
    mymaintext <- main
  }

  ##################################################################################### #
  # to use for dot showing the mean ratio of each indicator *** NOT USED?
  # meanratios <- data.frame(
  #   indicator = fixcolnames(varnames, 'r', 'short'),      # is this right?
  #   value = unlist(ratio.to.us.d[rationames])
  # )

  ## much of this is plotting code is based on plot_boxplot_ratios() - should consolidate

  ggplot2::ggplot(
    ratio.to.us.d.bysite,
    # mydata,
    ggplot2::aes(x = indicator, y = value )
  ) + #, fill = indicator)) +
    ## draw boxplots
    ggplot2::geom_boxplot() +

    #  show average PERSON's ratio to US,  for each boxplot column (probably need to debug)
    # geom_point(
    #   data =  meanratios,
    #   aes(x = reorder(indicator, meanratios), y = value), colour = "orange", size = 2
    # ) +

    #  show average SITE's ratio to US,  for each boxplot column  ?
    stat_summary(fun.y = mean, geom = "point",
                 shape = 20, size = 5, color = "gray", fill = "gray") +

    ## wrap indicator labels on x axis
    ggplot2::scale_x_discrete(labels = function(x) stringr::str_wrap(x, n_chars_wrap)) +

    ## set limits for ratio on y axis - use hard limit at 0, make upper limit 5% higher than  maxratio
    ggplot2::scale_y_continuous(limits = c(0, maxratio), expand = ggplot2::expansion(mult = c(0, 0.05))) +

    ## alternate/old version that clipped top and bottom axes exactly at (0, max_limit)
    # ggplot2::scale_y_continuous(limits = c(0, max_limit), expand = c(0, 0)) +

    ## add horizontal line at 1
    ggplot2::geom_hline(ggplot2::aes(yintercept = 1)) +
    ## set plot axis labels and titles
    ggplot2::labs(x = "",
                  y = "Ratio of Indicator values in selected locations\n vs. US average value",
                  subtitle = subtitle,
                  title = mymaintext ) +

    ## draw individual dot per site? at least for small datasets?/few facilities - removed as they cover up boxplots with large datasets
    #geom_jitter(color = 'black', size = 0.4, alpha = 0.9, ) +

    ## set color scheme ?
    # actually do not need each a color, for boxplot.
    # scale_fill_brewer(palette = 'Dark2') +

    ggplot2::theme_bw() +
    ggplot2::theme(
      ## set font size of text
      text = ggplot2::element_text(size = 14),
      #axis.text  = ggplot2::element_text(size = 16),
      ## set font size of axis titles
      axis.title = ggplot2::element_text(size = 16),
      ## center and resize plot title
      plot.title = ggplot2::element_text(size = 22, hjust = 0.5),
      ## center subtitle
      plot.subtitle = ggplot2::element_text(hjust = 0.5),
      ## hide legend
      legend.position = 'none'
    )  # end of ggplot section
}
