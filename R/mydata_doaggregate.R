
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
#' @param mydata_usastats,mydata_statestats optional reference tables of
#'   averages and percentiles for the US and for States, from
#'   [mydata_calc_stats()] or in the same layout as [usastats] and
#'   [statestats]. The whole result of [mydata_calc_stats()] can be given as
#'   `mydata_usastats`. If provided, each indicator that gets comparisons also
#'   gets its US and State average, its US and State percentile, and its ratio
#'   to each average, in columns named like those of [ejamit()] results
#'   (`avg.`, `state.avg.`, `pctile.`, `state.pctile.`, `ratio.to.avg.`,
#'   `ratio.to.state.avg.`). A value that cannot be provided is NA. Overall
#'   State averages and State percentiles are population-weighted means of the
#'   sites' values, as in [doaggregate()].
#' @param quiet FALSE (default) to print a short summary
#'
#' @return a list, with element names like those of [ejamit()] results where they apply:
#'
#'   - `results_bysite`: data.table with one row per site: `ejam_uniq_id`, `ST`
#'     (the State of the site, as given in `sites2states_or_latlon`, or else
#'     the State where most of the site's population lives), `pop`
#'     (EJAM's population estimate at the site), and one column per indicator
#'   - `results_overall`: the same, as one row for all sites combined
#'   - `coverage_bysite`, `coverage_overall`: share (0 to 1) of the population at
#'     the site, or overall, in blockgroups that had usable data, per indicator
#'   - `results_bybg_people`: data.table of `ejam_uniq_id`, `bgid`, `bgwt`
#'   - `mydata_map_headernames`: the metadata
#'   - `longnames`: full label of each column of `results_bysite`
#'   - `sitetype`: NA here; set by [mydata_ejamit()]
#'   - `settings`: the radius, the site ids, and the version of the EJAM data used
#'   - `notes`: what to keep in mind when reading the results
#'
#' @seealso [mydata_ejamit()] [mydata_calc_stats()] [mydata_validate()] [mydata_metadata()] [doaggregate()]
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
  if (is.list(mydata_usastats) && !is.data.frame(mydata_usastats) && "mydata_usastats" %in% names(mydata_usastats)) {
    # the whole result of mydata_calc_stats() was provided
    if (is.null(mydata_statestats)) {mydata_statestats <- mydata_usastats$mydata_statestats}
    mydata_usastats <- mydata_usastats$mydata_usastats
  }
  for (ref in list(mydata_usastats, mydata_statestats)) {
    if (!is.null(ref) && (!is.data.frame(ref) || !all(c("REGION", "PCTILE") %in% names(ref)))) {
      stop("mydata_usastats and mydata_statestats must be tables with columns REGION and PCTILE, like usastats and statestats, such as the output of mydata_calc_stats()")
    }
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

  # State of each site: as given, or else the State where most of the site's population lives ####
  ST <- rep(NA_character_, length(ids))
  if (!is.null(sites2states_or_latlon) && all(c("ejam_uniq_id", "ST") %in% names(sites2states_or_latlon))) {
    ST <- as.character(sites2states_or_latlon$ST[match(as.character(ids), as.character(sites2states_or_latlon$ejam_uniq_id))])
  }
  if (anyNA(ST)) {
    row <- match(bgwts_bysite$bgid, bgids)
    bystate <- rowsum(bgwts_bysite$bgwt * bgpop[row],
                      paste(match(bgwts_bysite$ejam_uniq_id, ids), blockgroupstats$ST[from_ejam][row]), reorder = FALSE)
    bystate <- data.frame(site = as.integer(sub(" .*$", "", rownames(bystate))), ST = sub("^.* ", "", rownames(bystate)), pop = bystate[, 1])
    bystate <- bystate[order(bystate$site, -bystate$pop), ]
    bystate <- bystate[!duplicated(bystate$site) & bystate$ST != "NA", ]
    main_state <- rep(NA_character_, length(ids))
    main_state[bystate$site] <- bystate$ST
    ST[is.na(ST)] <- main_state[is.na(ST)]
  }
  data.table::set(results_bysite, j = "ST", value = ST)
  data.table::setcolorder(results_bysite, c("ejam_uniq_id", "ST"))

  # averages, percentiles and ratios, where reference tables were provided ####
  notes <- character(0)
  if (!is.null(mydata_usastats) || !is.null(mydata_statestats)) {
    for (ref in list(mydata_usastats, mydata_statestats)) {
      if (!is.null(ref) && is.null(attr(ref, "mydata_stats_info"))) {
        warning("A reference table does not say what area, data year and weighting it is based on, ",
                "so check that it is comparable to these results. Tables from mydata_calc_stats() record that.", call. = FALSE)
        break
      }
    }
    compared <- mydata_doaggregate_comparisons(results_bysite, results_overall,
                                               vars = ind$rname[ind$comparisons %in% TRUE],
                                               mydata_usastats = mydata_usastats,
                                               mydata_statestats = mydata_statestats)
    results_bysite <- compared$results_bysite
    results_overall <- compared$results_overall
    notes <- c(notes, compared$notes)
  }

  # tell the user what happened ####
  counts <- ind$rname[ind$calculation_type == "sum of counts"]
  partial <- function(cov) {any(cov < 1 & cov > 0, na.rm = TRUE)}
  undercounted <- counts[vapply(counts, function(nm) {
    # a site can be partly covered, or the overall total can be when some sites have data and others have none
    partial(bysite$coverage[[nm]]) || partial(overall$coverage[[nm]])
  }, logical(1))]
  if (length(undercounted) > 0) {
    warning("Some totals are undercounts, because data were missing for part of the population, at some sites or overall: ",
            paste0(undercounted, collapse = ", "), ". See coverage_bysite and coverage_overall in the results.", call. = FALSE)
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
                    acs_version = attr(blockgroupstats, "acs_version")),
    notes = c(notes,
              if (length(counts) > 0) {paste0("Totals (", paste0(counts, collapse = ", "), ") are estimates where a site includes only part of a blockgroup: they are split in proportion to population.")},
              if (any(ind$source_geography %in% "tract")) {"Some values came from tract data, with each tract's value used for all of its blockgroups."})
  ))
}
############################################################################## #


# Add averages, percentiles and ratios to the results of mydata_doaggregate(),
# using the same helpers that work for the indicators built into EJAM.
# Returns new tables. The tables passed in are not changed.

mydata_doaggregate_comparisons <- function(results_bysite, results_overall, vars,
                                           mydata_usastats = NULL, mydata_statestats = NULL) {

  bysite <- data.table::copy(results_bysite)
  overall <- data.table::copy(results_overall)
  notes <- "Percentiles are among blockgroups, and each blockgroup counts equally in a US or State average."
  vars <- intersect(vars, names(bysite))
  vars_us <- if (is.null(mydata_usastats)) {character(0)} else {intersect(vars, names(mydata_usastats))}
  vars_st <- if (is.null(mydata_statestats)) {character(0)} else {intersect(vars, names(mydata_statestats))}
  vars <- union(vars_us, vars_st)
  if (length(vars) == 0) {
    return(list(results_bysite = bysite, results_overall = overall, notes = notes))
  }
  n <- nrow(bysite)
  pop <- bysite$pop
  popwtd <- function(x) {
    ok <- !is.na(x) & !is.na(pop) & pop > 0
    if (any(ok)) {sum(x[ok] * pop[ok]) / sum(pop[ok])} else {NA_real_}
  }
  newcols <- c(paste0("avg.", vars), paste0("state.avg.", vars), paste0("pctile.", vars), paste0("state.pctile.", vars))
  bysite[, (newcols) := NA_real_]
  overall[, (newcols) := NA_real_]

  # US averages and percentiles ####
  if (length(vars_us) > 0) {
    avg <- calc_avg_columns(vars_us, zones = "USA", lookup = mydata_usastats)
    for (nm in vars_us) {
      thisavg <- as.numeric(avg[[paste0("avg.", nm)]])[1]
      data.table::set(bysite, j = paste0("avg.", nm), value = rep(thisavg, n))
      data.table::set(overall, j = paste0("avg.", nm), value = thisavg)
    }
    suppressMessages({
      pct_bysite <- calc_pctile_columns(bysite[, vars_us, with = FALSE], varnames = vars_us, zones = "USA", lookup = mydata_usastats, quiet = TRUE)
      pct_overall <- calc_pctile_columns(overall[, vars_us, with = FALSE], varnames = vars_us, zones = "USA", lookup = mydata_usastats, quiet = TRUE)
    })
    for (nm in vars_us) {
      data.table::set(bysite, j = paste0("pctile.", nm), value = as.numeric(pct_bysite[[paste0("pctile.", nm)]]))
      data.table::set(overall, j = paste0("pctile.", nm), value = as.numeric(pct_overall[[paste0("pctile.", nm)]]))
    }
    notavailable <- vars_us[vapply(vars_us, function(nm) {all(is.na(mydata_usastats[[nm]]))}, logical(1))]
    if (length(notavailable) > 0) {
      notes <- c(notes, paste0("US averages, percentiles and ratios are not available for: ", paste0(notavailable, collapse = ", "),
                               ", because the data do not cover enough of the US."))
    }
  }

  # State averages and percentiles, for each site whose State is in the reference table ####
  if (length(vars_st) > 0) {
    known <- !is.na(bysite$ST) & bysite$ST %in% mydata_statestats$REGION
    if (any(known)) {
      avg <- calc_avg_columns(vars_st, zones = bysite$ST[known], lookup = mydata_statestats)
      suppressMessages(suppressWarnings({
        pct <- calc_pctile_columns(bysite[known, vars_st, with = FALSE], varnames = vars_st, zones = bysite$ST[known], lookup = mydata_statestats, quiet = TRUE)
      }))
      for (nm in vars_st) {
        data.table::set(bysite, i = which(known), j = paste0("state.avg.", nm), value = as.numeric(unlist(avg[[paste0("state.avg.", nm)]])))
        data.table::set(bysite, i = which(known), j = paste0("state.pctile.", nm), value = as.numeric(pct[[paste0("state.pctile.", nm)]]))
      }
    }
    if (any(!known)) {
      notes <- c(notes, paste0("State averages, percentiles and ratios are not available for ", sum(!known), " of ", n,
                               " sites, because the reference table has nothing for the State of the site."))
    }
    # overall: population-weighted mean of the sites' State values, as in doaggregate()
    for (nm in vars_st) {
      data.table::set(overall, j = paste0("state.avg.", nm), value = popwtd(bysite[[paste0("state.avg.", nm)]]))
      data.table::set(overall, j = paste0("state.pctile.", nm), value = popwtd(bysite[[paste0("state.pctile.", nm)]]))
    }
  }

  # ratios to the averages ####
  ratios_bysite <- calc_ratio_columns(bysite, varnames = vars)
  ratios_overall <- calc_ratio_columns(overall, varnames = vars)
  for (nm in names(ratios_bysite)) {
    data.table::set(bysite, j = nm, value = as.numeric(ratios_bysite[[nm]]))
    data.table::set(overall, j = nm, value = as.numeric(ratios_overall[[nm]]))
  }
  list(results_bysite = bysite, results_overall = overall, notes = notes)
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
#' @param mydata_usastats,mydata_statestats optional reference tables of
#'   averages and percentiles from [mydata_calc_stats()], passed to
#'   [mydata_doaggregate()], which then also reports averages, percentiles and ratios
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
                          mydata_usastats = NULL,
                          mydata_statestats = NULL,
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
    # use the same form of each code (leading zeroes restored) to find blocks and to list the sites
    fips_fixed <- suppressWarnings(fips_lead_zero(fips, quiet = TRUE))
    fips <- ifelse(is.na(fips_fixed), as.character(fips), fips_fixed)
    sites2blocks <- getblocksnearby_from_fips(fips = fips, need_blockwt = TRUE, return_shp = has_buffer,
                                              radius = radius, compact = TRUE)
    if (has_buffer) {sites2blocks <- sites2blocks$pts}
    # As in ejamit(), the FIPS code is used as the site id. This table was just created by
    # getblocksnearby_from_fips() and nothing else refers to it, so it is changed in place, with no copy.
    data.table::set(sites2blocks, j = "ejam_uniq_id", value = as.character(sites2blocks$fips))
    allsites <- data.table::data.table(ejam_uniq_id = as.character(fips), ST = fips2stateabbrev(fips))

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
                            mydata_usastats = mydata_usastats,
                            mydata_statestats = mydata_statestats,
                            quiet = quiet)
  out$sitetype <- sitetype
  return(out)
}
