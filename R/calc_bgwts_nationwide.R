###################################################### #

# internal

calc_bgwts_nationwide <- function() {

  # helper function used by calc_blockgroupstats_from_tract_data()
  # using a census API key already set in renviron or wherever,
  # - get tract and bg census 2000 pop counts, and with them create a table that is each bg with tractfips, bgfips and bgwt, where bgwt is the Census 2000 pop as fraction of tractwide Census 2000 pop.
  cat("Now need to use Census API key in tidycensus::get_decennial() \n")
  c2k <- list()
  for (i in 1:length(EJAM::stateinfo$ST)) {
    c2k[[i]] <- tidycensus::get_decennial(state = EJAM::stateinfo$ST[i],
                                          geography = "block group",
                                          variables = 'P1_001N',
                                          geometry = FALSE,
                                          year = 2020)
  }
  c2k2 <- data.table::rbindlist(c2k)
  bgwts = c2k2[, .(bgfips = GEOID, pop = value)]
  bgwts[, tractfips := substr(bgfips, 1, 11)]
  bgwts[ , tractpop := sum(pop), by = "tractfips"]
  bgwts[, bgwt := ifelse(tractpop == 0, 0, pop / tractpop)]
  bgwts[, pop := NULL]
  bgwts[, tractpop := NULL]
  return(bgwts)
}
###################################################### #
