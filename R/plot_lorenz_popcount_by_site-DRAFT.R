
# Could show share of total population across sites, e.g.,
# or any other cumulative distribution
######################################################################################################## #

#' lorenz plot bysite (cumulative share of x vs cum share of y) - DRAFT/EXPERIMENTAL
#' COMPARES TWO subsets OF SITES (or people??)
#' @param bysite from ejamit()$results_bysite
#' @param radius miles distance from site to include in the population count (e.g., 1 mile, 3 miles, 5 miles)
#'
#' @return NULL while in dev, but will return a ggplot
#'
#' @keywords internal
#' @noRd
#'
plot_lorenz_popcount_by_site <- function(bysite = NULL, radius = NULL) {

  return(NULL) # DRAFT - not yet implemented

  # pkg_available("gglorenz", if_not_loaded = "stop")
  #
  # bysite$`Demog Index State Percentile` <- ifelse(bysite$state.pctile.pctlowinc >= 80,
  #                                                 "High Demog.Index (at least 80th pctile in State)",
  #                                                 "All Other Sites")
  #
  # bysite |>
  #   filter("Demog Index State Percentile" %in% c("High Demog.Index (at least 80th pctile in State)",
  #                                                "All Other Sites")) |>
  #   # ggplot(aes(pop)) +
  #   ggplot2::ggplot(ggplot2::aes(x = pop, colour = "Demog Index State Percentile")) +
  #
  #   gglorenz::stat_lorenz(desc = TRUE) +  # gglorenz is in Suggests; these draft plots are not exported
  #   ggplot2::coord_fixed() +
  #   ggplot2::geom_abline(linetype = "dashed") +
  #   ggplot2::theme_minimal() +
  #   ggplot2::scale_x_continuous(labels = scales::label_percent(scale=1)) +
  #   ggplot2::scale_y_continuous(labels = scales::label_percent(scale=1)) +
  #   ggplot2::theme_bw() +
  #   ggplot2::labs(x = "Cumulative Percentage of the Sites (Facilities)",
  #                 y = "Cumulative Percentage of Total Population Near All Sites Overall",
  #                 title = "Differences in Size of Population Living Near Site",
  #                 caption = paste0("Total number of sites analyzed: ", NROW(bysite), " "))
}
######################################################################################################## #

#' lorenz plot bybg_people (cumulative share of x vs cum share of y) - DRAFT/EXPERIMENTAL
#' COUNT OF SITES (or PEOPLE?) BY BIN
#'
#' @param bybg_people from ejamit()$results_bybg_people
#' @param varname the variable name to plot (e.g., "distance_min_avgperson")
#'
#' @return NULL while in dev, but will return a ggplot once implemented
#'
#' @keywords internal
#' @noRd
#'
plot_lorenz_distance_by_dcount <- function(bybg_people = NULL, varname = NULL) {

  return(NULL) # DRAFT - not yet implemented

  # pkg_available("gglorenz", if_not_loaded = "stop")
  #
  # bysite |>
  #   ggplot2::ggplot(ggplot2::aes(x = distance_min_avgperson, n = pop * pctnhaa)) +
  #
  #   gglorenz::stat_lorenz(desc = TRUE) +    # gglorenz is in Suggests; these draft plots are not exported
  #   ggplot2::coord_fixed() +
  #   ggplot2::geom_abline(linetype = "dashed") +
  #   ggplot2::theme_minimal() +
  #   ggplot2::scale_x_continuous(labels = scales::label_percent(scale=1))+
  #   ggplot2::scale_y_continuous(labels = scales::label_percent(scale=1))+
  #   ggplot2::theme_bw() +
  #   ggplot2::labs(x = "Cumulative Share of the Distances",
  #                 y = "Cumulative Percentage of Total Low Income Residents",
  #                 title = "Distance distribution in one group",
  #                 caption = paste0("Total number of sites analyzed: ", NROW(bysite), " "))
}
######################################################################################################## #
