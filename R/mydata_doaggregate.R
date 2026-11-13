
#' Summarize user-defined indicators at each site and overall
#'
#' @description
#' Like [doaggregate()], but for indicators a user provides (or calculates by
#' formula) for blockgroups, instead of the indicators built into EJAM. Given
#' the blocks at each site and a table of user-defined indicators by
#' blockgroup, it returns the value of each indicator at each site and for all
#' the sites overall. It does not need or run a full [ejamit()] analysis.
#'
#' @details
#' Each indicator is aggregated in the way its metadata says:
#'
#' - `"sum of counts"`: the total across blockgroups
#' - `"wtdmean"`: the average weighted by the indicator's weight (population
#'   by default), which is the value for the average resident
#' - `"formula"`: the columns the formula uses are totaled first, and the
#'   formula is applied to those totals
#'
#' Where a site includes only part of a blockgroup, the blockgroup counts for
#' that share, based on the population of its blocks at the site, as in
#' [doaggregate()]. For a count this assumes the thing counted is spread within
#' the blockgroup the way residents are, so such counts are estimates.
#'
#' Overall values count each block, and so each resident, only once, even if it
#' is near more than one site.
#'
#' Data can be incomplete. For each indicator, a blockgroup is used only if
#' every column that indicator needs has a value there (for a formula, all of
#' its inputs). A missing value is never treated as zero. A site with no usable
#' blockgroups for an indicator gets NA for it. Coverage is reported for each
#' site and indicator: the share of the site's population that lives in the
#' blockgroups that were used. A total where coverage is less than 1 is an
#' undercount and is reported with a warning.
#'
#' Nothing passed to this function is changed.
#'
#' @param sites2blocks data.table of the blocks at each site, as returned by
#'   [getblocksnearby()], [getblocksnearby_from_fips()], or
#'   `get_blockpoints_in_shape()$pts`, with columns `ejam_uniq_id`, `blockid`,
#'   `blockwt`, and `bgid`
#' @param mydata table of user-defined indicators with one row per blockgroup,
#'   or the result of [mydata_validate()]
#' @param mydata_map_headernames metadata from [mydata_metadata()]. Not needed
#'   if `mydata` is the result of [mydata_validate()].
#' @param sites2states_or_latlon optional data.frame with a column
#'   `ejam_uniq_id` listing every site, in the order wanted for the results, so
#'   that sites with no blocks still get a row. As in [doaggregate()].
#' @param radius optional, the radius in miles that was used, to record in the results
#' @param mydata_usastats,mydata_statestats reserved for reference tables of
#'   averages and percentiles. Not used yet.
#' @param quiet FALSE (default) to print a short summary
#'
#' @return a list, with element names like those of [ejamit()] results where they apply:
#'
#'   - `results_bysite`: data.table with one row per site: `ejam_uniq_id`, `pop`
#'     (EJAM's population estimate at the site), and one column per indicator
#'   - `results_overall`: the same, as one row for all sites combined
#'   - `coverage_bysite`, `coverage_overall`: share (0 to 1) of the population at
#'     the site, or overall, in blockgroups that had usable data, per indicator
#'   - `results_bybg_people`: data.table of `ejam_uniq_id`, `bgid`, `bgwt`
#'   - `mydata_map_headernames`: the metadata
#'   - `longnames`: full label of each column of `results_bysite`
#'   - `sitetype`: NA here; set by [mydata_ejamit()]
#'   - `settings`: the radius, the site ids, and the version of the EJAM data used
#'
#' @seealso [mydata_ejamit()] [mydata_validate()] [mydata_metadata()] [doaggregate()]
#'
#' @examples
#' \dontrun{
#' # a score for every blockgroup in one county, analyzed within 3 miles of a point there
#' x <- data.frame(bgfips = blockgroupstats$bgfips[substr(blockgroupstats$bgfips, 1, 5) == "10001"])
#' x$myscore <- seq_len(nrow(x))
#' pts <- data.frame(lat = 39.16, lon = -75.52)
#' s2b <- getblocksnearby(pts, radius = 3)
#' out <- mydata_doaggregate(s2b, x, mydata_metadata("myscore", longname = "My score"))
#' out$results_bysite
#' out$coverage_bysite
#' }
#'
#' @export
#'
mydata_doaggregate <- function(sites2blocks,
                               mydata,
                               mydata_map_headernames = NULL,
                               sites2states_or_latlon = NULL,
                               radius = NULL,
                               mydata_usastats = NULL,
                               mydata_statestats = NULL,
                               quiet = FALSE) {

  # check inputs ####
  if (!is.data.frame(sites2blocks) || !all(c("ejam_uniq_id", "blockid", "blockwt", "bgid") %in% names(sites2blocks))) {
    stop("sites2blocks must be a table with columns ejam_uniq_id, blockid, blockwt, and bgid, like the output of getblocksnearby()")
  }
  if (!data.table::is.data.table(sites2blocks)) {
    sites2blocks <- data.table::as.data.table(sites2blocks) # a copy, only when it was not already a data.table
  }
  if (!is.null(mydata_usastats) || !is.null(mydata_statestats)) {
    message("mydata_usastats and mydata_statestats are not used yet, so averages, percentiles and ratios are not included.")
  }
  already_checked <- is.list(mydata) && !is.data.frame(mydata) &&
    all(c("mydata", "mydata_map_headernames", "columns_needed", "formulas_needed", "ok") %in% names(mydata))
  checked <- if (already_checked) {
    mydata
  } else {
    mydata_validate(mydata, mydata_map_headernames, quiet = TRUE)
  }
  if (!isTRUE(checked$ok)) {
    stop("mydata has problems that prevent analysis. See mydata_validate().")
  }
  md <- checked$mydata_map_headernames
  ind <- md[md$vartype %in% "raw", , drop = FALSE]
  needs <- checked$columns_needed
  formulas_needed <- checked$formulas_needed

  # the sites ####
  ids_found <- unique(sites2blocks$ejam_uniq_id)
  if (!is.null(sites2states_or_latlon) && "ejam_uniq_id" %in% names(sites2states_or_latlon)) {
    ids <- unique(sites2states_or_latlon$ejam_uniq_id)
    notlisted <- ids_found[!(as.character(ids_found) %in% as.character(ids))]
    if (length(notlisted) > 0) {ids <- c(ids, notlisted)}
  } else {
    ids <- ids_found
  }

  # blockgroup weights: by site, and overall with each block counted once ####
  bgwts_bysite <- calc_bgwts_bysite(sites2blocks)
  bgwts_overall <- calc_bgwts_overall(sites2blocks)

  # data for just the blockgroups involved ####
  # columns come from the user's table where it has them, otherwise from blockgroupstats
  bgids <- bgwts_overall$bgid
  from_mine <- match(bgids, checked$mydata$bgid)
  from_ejam <- match(bgids, blockgroupstats$bgid)
  allneeded <- unique(unlist(needs))
  bgdata <- lapply(allneeded, function(nm) {
    if (nm %in% names(checked$mydata)) {
      checked$mydata[[nm]][from_mine]
    } else {
      blockgroupstats[[nm]][from_ejam]
    }
  })
  names(bgdata) <- allneeded
  bgpop <- blockgroupstats$pop[from_ejam]
  bgpop[is.na(bgpop)] <- 0
  # for each indicator, which blockgroups have a value in every column it needs
  usable <- lapply(needs, function(cols) {
    ok <- rep(TRUE, length(bgids))
    for (nm in cols) {ok <- ok & !is.na(bgdata[[nm]])}
    ok
  })

  # aggregate over one set of blockgroup weights (by site, or overall) ####
  aggregate_groups <- function(wts, groups, ngroups) {
    row <- match(wts$bgid, bgids)
    bgwt <- wts$bgwt
    total <- function(x, ok) {
      out <- rep(0, ngroups)
      if (any(ok)) {
        sums <- rowsum(x[ok], groups[ok], reorder = FALSE)
        out[as.integer(rownames(sums))] <- sums[, 1]
      }
      out
    }
    everyrow <- rep(TRUE, length(row))
    pop <- total(bgwt * bgpop[row], everyrow)
    values <- coverage <- vector("list", nrow(ind))
    names(values) <- names(coverage) <- ind$rname
    # all the weighted means at once, each with its own weight
    is_wtdmean <- ind$calculation_type == "wtdmean" & lengths(formulas_needed[ind$rname]) == 0
    if (any(is_wtdmean)) {
      cols <- unique(c(ind$rname[is_wtdmean], ind$denominator[is_wtdmean]))
      dt <- c(list(.group = groups, .bgwt = bgwt), lapply(stats::setNames(cols, cols), function(nm) {bgdata[[nm]][row]}))
      means <- calc_wtdmeans(data.table::as.data.table(dt),
                             score_colnames = ind$rname[is_wtdmean],
                             wts_bg_colname = ".bgwt",
                             wts_denom_colnames = ind$denominator[is_wtdmean],
                             by_colname = ".group")
    }
    for (i in seq_len(nrow(ind))) {
      nm <- ind$rname[i]
      ok <- usable[[nm]][row]
      n_used <- total(as.numeric(ok), everyrow)
      coverage[[nm]] <- ifelse(pop > 0, total(bgwt * bgpop[row], ok) / pop, NA_real_)
      has_formula <- length(formulas_needed[[nm]]) > 0
      if (is_wtdmean[i]) {
        val <- rep(NA_real_, ngroups)
        val[means$.group] <- means[[nm]]
      } else if (!has_formula) {
        val <- total(bgwt * bgdata[[nm]][row], ok)
      } else {
        # total each input over the same blockgroups, then apply the formula(s) to the totals
        sums <- lapply(needs[[nm]], function(col) {total(bgwt * bgdata[[col]][row], ok)})
        names(sums) <- needs[[nm]]
        sums <- data.table::as.data.table(sums)
        calculated <- calc_ejam(sums, formulas = formulas_needed[[nm]], keep.old = needs[[nm]][1], keep.new = nm, quiet = TRUE)
        val <- as.numeric(calculated[[nm]])
        val[is.nan(val) | is.infinite(val)] <- NA_real_
      }
      val[n_used == 0] <- NA_real_ # no usable blockgroups means not available, never zero
      values[[nm]] <- val
    }
    list(pop = pop, values = values, coverage = coverage)
  }

  bysite <- aggregate_groups(bgwts_bysite, match(bgwts_bysite$ejam_uniq_id, ids), length(ids))
  overall <- aggregate_groups(bgwts_overall, rep(1L, nrow(bgwts_overall)), 1L)

  results_bysite <- data.table::as.data.table(c(list(ejam_uniq_id = ids, pop = bysite$pop), bysite$values))
  results_overall <- data.table::as.data.table(c(list(pop = overall$pop), overall$values))
  coverage_bysite <- data.table::as.data.table(c(list(ejam_uniq_id = ids), bysite$coverage))
  coverage_overall <- data.table::as.data.table(overall$coverage)
  nosuchsite <- !(ids %in% ids_found)
  if (any(nosuchsite)) {
    data.table::set(results_bysite, i = which(nosuchsite), j = "pop", value = NA_real_)
  }

  # tell the user what happened ####
  counts <- ind$rname[ind$calculation_type == "sum of counts"]
  undercounted <- counts[vapply(counts, function(nm) {
    any(bysite$coverage[[nm]] < 1 & bysite$coverage[[nm]] > 0, na.rm = TRUE)
  }, logical(1))]
  if (length(undercounted) > 0) {
    warning("Some totals are undercounts, because data were missing for part of the population at some sites: ",
            paste0(undercounted, collapse = ", "), ". See coverage_bysite in the results.", call. = FALSE)
  }
  if (!quiet) {
    for (nm in ind$rname) {
      cov <- bysite$coverage[[nm]]
      message(nm, ": of ", length(ids), " sites, ", sum(cov >= 1 - 1e-9, na.rm = TRUE), " had data for all of the population, ",
              sum(cov > 0 & cov < 1 - 1e-9, na.rm = TRUE), " for part, and ",
              sum(is.na(cov) | cov == 0), " for none.")
    }
    if (length(counts) > 0) {
      message("Totals (", paste0(counts, collapse = ", "), ") are estimates where a site includes only part of a blockgroup: ",
              "they are split in proportion to population.")
    }
  }

  return(list(
    results_overall = results_overall,
    results_bysite = results_bysite,
    coverage_overall = coverage_overall,
    coverage_bysite = coverage_bysite,
    results_bybg_people = bgwts_bysite,
    mydata_map_headernames = md,
    longnames = fixcolnames(names(results_bysite), "r", "long", mapping_for_names = mydata_metadata_combine(md)),
    sitetype = NA,
    settings = list(radius = radius,
                    ejam_uniq_id = ids,
                    ejam_package_version = attr(blockgroupstats, "ejam_package_version"),
                    acs_version = attr(blockgroupstats, "acs_version"))
  ))
}
############################################################################## #


#' Analyze user-defined indicators at a set of sites, without a full ejamit() analysis
#'
#' @description
#' Like [ejamit()], but for indicators a user provides (or calculates by
#' formula) for blockgroups. Specify sites the way [ejamit()] accepts them, as
#' points with a radius, as FIPS codes, or as polygons. It finds the blocks at
#' each site and uses [mydata_doaggregate()] to report each indicator at each
#' site and overall.
#'
#' @param sitepoints data.frame with columns lat and lon, one row per site, as for [ejamit()]
#' @param radius miles. For points, the distance from each point (default 3).
#'   For FIPS codes or polygons, an optional buffer to add (default none).
#' @param fips vector of FIPS codes of Census units to use as the sites, as for [ejamit()]
#' @param shapefile polygons to use as the sites, as for [ejamit()]
#' @param mydata table of user-defined indicators with one row per blockgroup,
#'   or the result of [mydata_validate()]
#' @param mydata_map_headernames metadata from [mydata_metadata()]. Not needed
#'   if `mydata` is the result of [mydata_validate()].
#' @param quiet TRUE to print less
#' @param ... passed to [getblocksnearby()] when sites are points
#'
#' @return the list that [mydata_doaggregate()] returns, with `sitetype` set to
#'   "latlon", "fips", or "shp"
#'
#' @seealso [mydata_doaggregate()] [mydata_validate()] [mydata_metadata()] [ejamit()]
#'
#' @examples
#' \dontrun{
#' x <- data.frame(bgfips = blockgroupstats$bgfips[substr(blockgroupstats$bgfips, 1, 5) == "10001"])
#' x$myscore <- seq_len(nrow(x))
#' out <- mydata_ejamit(data.frame(lat = 39.16, lon = -75.52), radius = 3, mydata = x)
#' out$results_bysite
#' out2 <- mydata_ejamit(fips = "10001", mydata = x)
#' }
#'
#' @export
#'
mydata_ejamit <- function(sitepoints = NULL,
                          radius = NULL,
                          fips = NULL,
                          shapefile = NULL,
                          mydata,
                          mydata_map_headernames = NULL,
                          quiet = FALSE,
                          ...) {

  if (missing(mydata)) {
    stop("mydata is required: a table of user-defined indicators with one row per blockgroup")
  }
  # check the data first, so a problem with it is reported before any time is spent finding blocks
  already_checked <- is.list(mydata) && !is.data.frame(mydata) && all(c("mydata", "columns_needed", "ok") %in% names(mydata))
  checked <- if (already_checked) {mydata} else {mydata_validate(mydata, mydata_map_headernames, quiet = quiet)}

  sitetype <- ejamit_sitetype_from_input(sitepoints = sitepoints, fips = fips, shapefile = shapefile)

  if (sitetype == "latlon") {

    sitepoints <- sitepoints_from_anything(anything = sitepoints, invalid_msg_table = TRUE, set_invalid_to_na = FALSE)
    allsites <- data.table::data.table(ejam_uniq_id = sitepoints$ejam_uniq_id)
    if (is.null(radius)) {
      radius <- 3
      warning("Using default radius of 3 miles because not provided as parameter.")
    }
    sites2blocks <- getblocksnearby(sitepoints = sitepoints[sitepoints$valid, ], radius = radius, quiet = TRUE, ...)

  } else if (sitetype == "fips") {

    if (is.null(radius)) {radius <- 0}
    has_buffer <- isTRUE(radius > 0)
    sites2blocks <- getblocksnearby_from_fips(fips = fips, need_blockwt = TRUE, return_shp = has_buffer,
                                              radius = radius, compact = TRUE)
    if (has_buffer) {sites2blocks <- sites2blocks$pts}
    # As in ejamit(), the FIPS code is used as the site id. This table was just created by
    # getblocksnearby_from_fips() and nothing else refers to it, so it is changed in place, with no copy.
    data.table::set(sites2blocks, j = "ejam_uniq_id", value = as.character(sites2blocks$fips))
    allsites <- data.table::data.table(ejam_uniq_id = as.character(fips))

  } else if (sitetype == "shp") {

    if (is.null(radius)) {radius <- 0}
    shp <- shapefile_from_any(shapefile, cleanit = FALSE, silentinteractive = TRUE)
    shp <- shapefile_clean(shp)
    if (is.null(shp)) {stop("No valid shapes found in shapefile")}
    allsites <- data.table::data.table(ejam_uniq_id = shp$ejam_uniq_id)
    shp <- shp[!(!sf::st_is_valid(shp) | sf::st_is_empty(shp)), ]
    if (isTRUE(radius > 0)) {
      shp <- shape_buffered_from_shapefile(shapefile = shp, radius.miles = radius)
    }
    sites2blocks <- get_blockpoints_in_shape(shp)$pts

  } else {
    stop("sites must be specified as sitepoints, fips, or shapefile")
  }

  out <- mydata_doaggregate(sites2blocks = sites2blocks,
                            mydata = checked,
                            sites2states_or_latlon = allsites,
                            radius = radius,
                            quiet = quiet)
  out$sitetype <- sitetype
  return(out)
}
