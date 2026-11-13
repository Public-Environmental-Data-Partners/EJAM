
#' Create reference tables of averages and percentiles for user-defined indicators
#'
#' @description
#' From a table of user-defined indicators by blockgroup, creates the tables
#' used to report each site's value as a percentile, and to compare it to an
#' average, in the same layout as [usastats] and [statestats]. It does for a
#' user's data what [calc_ejscreen_stats()] does for the data built into EJAM.
#'
#' @details
#' Averages and percentiles are across blockgroups, with each blockgroup
#' counting equally, which is how [usastats] and [statestats] are defined.
#' Percentiles are among blockgroups, including for values that originally
#' came from tract data.
#'
#' Reference values are provided only where the data cover enough of the
#' population, counting only blockgroups that have a usable value for that
#' indicator:
#'
#' - US values, only if at least `coverage_needed` (99 percent by default) of
#'   the US population is covered
#' - State values, for each State where at least that share of the State's
#'   population is covered. So data for just one State still get State
#'   averages and percentiles for that State.
#' - Values for the area the data cover, always. These are in the
#'   `mydata_areastats` element, with `REGION` set to `"area"`.
#'
#' Where coverage is not enough, the values are NA, and the reason is in the
#' `coverage` element of the result.
#'
#' Only indicators marked as getting comparisons in the metadata are included.
#' By default that leaves out counts, because the total count at a site is not
#' comparable to the count in an average blockgroup.
#'
#' @param mydata table of user-defined indicators with one row per blockgroup,
#'   or the result of [mydata_validate()]
#' @param mydata_map_headernames metadata from [mydata_metadata()]. Not needed
#'   if `mydata` is the result of [mydata_validate()].
#' @param coverage_needed share of population that has to be covered for US or
#'   State values to be provided. Default is 0.99.
#' @param quiet FALSE (default) to print a short summary
#'
#' @return a list:
#'
#'   - `mydata_usastats`: data.frame like [usastats], with columns `REGION`
#'     (`"USA"`), `PCTILE` (`"0"` to `"100"` and `"mean"`), and one column per indicator
#'   - `mydata_statestats`: data.frame like [statestats], with `REGION` a State abbreviation
#'   - `mydata_areastats`: the same, for all the blockgroups provided, with `REGION` `"area"`
#'   - `coverage`: data.frame with one row per indicator and zone, the share of
#'     population covered, whether reference values were provided, and why not if not
#'
#'   Each of the three reference tables has an attribute `mydata_stats_info`
#'   that records the area covered, the data year, how averages were
#'   weighted, and how many blockgroups were used for each indicator.
#'
#' @seealso [mydata_doaggregate()] [mydata_validate()] [pctiles_lookup_create()]
#'
#' @examples
#' \dontrun{
#' # a score for every blockgroup in Delaware
#' x <- data.frame(bgfips = blockgroupstats$bgfips[blockgroupstats$ST == "DE"])
#' x$myscore <- seq_len(nrow(x))
#' stats <- mydata_calc_stats(x, mydata_metadata("myscore"))
#' stats$coverage
#' out <- mydata_ejamit(data.frame(lat = 39.16, lon = -75.52), radius = 3, mydata = x,
#'                      mydata_usastats = stats)
#' out$results_bysite
#' }
#'
#' @export
#'
mydata_calc_stats <- function(mydata,
                              mydata_map_headernames = NULL,
                              coverage_needed = 0.99,
                              quiet = FALSE) {

  already_checked <- is.list(mydata) && !is.data.frame(mydata) &&
    all(c("mydata", "mydata_map_headernames", "columns_needed", "formulas_needed", "ok") %in% names(mydata))
  checked <- if (already_checked) {
    mydata
  } else {
    mydata_validate(mydata, mydata_map_headernames, coverage_needed = coverage_needed, quiet = TRUE)
  }
  if (!isTRUE(checked$ok)) {
    stop("mydata has problems that prevent analysis. See mydata_validate().")
  }
  md <- checked$mydata_map_headernames
  ind <- md[md$vartype %in% "raw" & md$comparisons %in% TRUE, , drop = FALSE]
  if (nrow(ind) == 0) {
    stop("None of the indicators is marked as getting averages, percentiles and ratios. ",
         "By default counts do not get them. See the comparisons parameter of mydata_metadata().")
  }
  vars <- ind$rname
  needs <- checked$columns_needed
  formulas_needed <- checked$formulas_needed

  # value of each indicator in each blockgroup ####
  dat <- checked$mydata
  here <- match(dat$bgid, blockgroupstats$bgid)
  ST <- blockgroupstats$ST[here]
  inputs <- unique(unlist(needs[vars]))
  bgdata <- lapply(inputs, function(nm) {
    if (nm %in% names(dat)) {dat[[nm]]} else {blockgroupstats[[nm]][here]}
  })
  names(bgdata) <- inputs
  bgvalues <- lapply(vars, function(nm) {
    usable <- rep(TRUE, nrow(dat))
    for (col in needs[[nm]]) {usable <- usable & !is.na(bgdata[[col]])}
    if (length(formulas_needed[[nm]]) > 0) {
      calculated <- calc_ejam(data.table::as.data.table(bgdata[needs[[nm]]]), formulas = formulas_needed[[nm]],
                              keep.old = needs[[nm]][1], keep.new = nm, quiet = TRUE)
      val <- as.numeric(calculated[[nm]])
    } else {
      val <- as.numeric(bgdata[[nm]])
    }
    val[!usable | is.nan(val) | is.infinite(val)] <- NA_real_
    val
  })
  names(bgvalues) <- vars
  bgvalues <- as.data.frame(bgvalues)

  # the reference tables, by the same method as usastats and statestats ####
  us <- pctiles_lookup_create(bgvalues)
  st <- pctiles_lookup_create(bgvalues, zone.vector = ST)
  area <- pctiles_lookup_create(bgvalues)
  area$REGION <- "area"

  # keep US and State values only where enough of the population is covered ####
  # Coverage is counted from the values just calculated, so a blockgroup where a formula
  # gave no valid result (such as 0 / 0) does not count as covered.
  pop <- blockgroupstats$pop[here]
  pop[is.na(pop)] <- 0
  zone_pop <- tapply(blockgroupstats$pop, blockgroupstats$ST, sum, na.rm = TRUE)
  us_pop <- sum(blockgroupstats$pop, na.rm = TRUE)
  cov <- do.call(rbind, lapply(vars, function(nm) {
    ok <- !is.na(bgvalues[[nm]]) & !is.na(ST)
    covered <- tapply(pop[ok], ST[ok], sum)
    counted <- tapply(pop[ok], ST[ok], length)
    zones <- sort(names(covered))
    data.frame(indicator = nm, zone = c("USA", zones),
               n_blockgroups = c(sum(ok), as.numeric(counted[zones])),
               pop_covered = c(sum(pop[ok]), as.numeric(covered[zones])),
               pop_zone = c(us_pop, as.numeric(zone_pop[zones])))
  }))
  cov$coverage <- ifelse(cov$pop_zone > 0, cov$pop_covered / cov$pop_zone, NA_real_)
  cov$provided <- !is.na(cov$coverage) & cov$coverage >= coverage_needed
  cov$reason <- ifelse(cov$provided, "",
                       paste0("data cover ", format(round(100 * cov$coverage, 1), nsmall = 1, trim = TRUE), "% of ",
                              ifelse(cov$zone == "USA", "US", cov$zone), " population, less than the ",
                              100 * coverage_needed, "% needed"))
  for (nm in vars) {
    this <- cov[cov$indicator == nm, ]
    if (!isTRUE(this$provided[this$zone == "USA"])) {
      us[[nm]] <- NA_real_
    }
    st[!(st$REGION %in% this$zone[this$zone != "USA" & this$provided]), nm] <- NA_real_
  }
  rownames(cov) <- NULL

  info <- function(what) {
    list(area = what,
         data_year = unique(stats::na.omit(ind$data_year)),
         weighting = "each blockgroup counts equally, as in usastats and statestats",
         percentiles_are_among = "blockgroups",
         blockgroups_used = vapply(bgvalues, function(x) {sum(!is.na(x))}, numeric(1)),
         coverage_needed = coverage_needed,
         created = as.character(Sys.Date()))
  }
  attr(us, "mydata_stats_info") <- info("USA")
  attr(st, "mydata_stats_info") <- info(paste0("States: ", paste0(sort(unique(stats::na.omit(ST))), collapse = ", ")))
  attr(area, "mydata_stats_info") <- info("the blockgroups provided")

  if (!quiet) {
    for (nm in vars) {
      this <- cov[cov$indicator == nm, ]
      states <- this$zone[this$zone != "USA" & this$provided]
      message(nm, ": US averages and percentiles ",
              if (isTRUE(this$provided[this$zone == "USA"])) {"provided"} else {paste0("not provided (", this$reason[this$zone == "USA"], ")")},
              "; State averages and percentiles provided for ", length(states), " State(s)",
              if (length(states) > 0 && length(states) <= 10) {paste0(": ", paste0(states, collapse = ", "))} else {""}, ".")
    }
    message("Percentiles are among blockgroups, and each blockgroup counts equally in an average.")
  }

  return(list(mydata_usastats = us, mydata_statestats = st, mydata_areastats = area, coverage = cov))
}
