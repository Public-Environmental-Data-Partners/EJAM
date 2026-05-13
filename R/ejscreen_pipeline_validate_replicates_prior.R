
#' utility to compare two data.frames or data.tables
#'
#' @param new_dt generally should be the new bg_acsdata, bg_usastats, bg_statestats, or new blockgroupstats that we are comparing to a prior year version or versus a previously-available copy of data for the same year if trying to use a new pipeline to replicate/reproduce a particular dataset such as the 2022 data previously published
#' @param old_dt generally should a previously created version of this dataset, such as the same object for a prior year, or the same or comparable object for the same year -- e.g. the ACS parts of the old blockgroupstats from ACS2022, or maybe old_dt = data.table::copy(EJAM::blockgroupstats) -- if trying to use a new pipeline to replicate a particular dataset such as the 2022 data previously published
#'
#' @returns NULL
#'
#' @keywords internal
#'
ejscreen_pipeline_validate_vs_prior <- function(new_dt, old_dt) {

  ###################################################### #
  ## Try to replicate the 2022 blockgroupstats
  ## while this pkg still has the old blockgroupstats based on 2018-2022 ACS,
  ## then bg_acsdata should be the same as the one used to create that, so can check that here:
  # e.g., if new_dt is bg_acsdata for 2022, and old_dt is blockgroupstats from 2022,
  # then should replicate all shared columns and recreate expected ones.
  # check that the new bg_acsdata replicates the old blockgroupstats, which was based on the same bg_acsdata,
  # before it was updated to use the new bg_acsdata with more recent ACS data. if it does not replicate,
  # then that is a problem with the pipeline code that creates blockgroupstats from bg_acsdata,
  # and should be fixed before update the bg_acsdata to use more recent ACS data.
  ###################################################### #

  # not missing
  if (missing(new_dt)) {
    stop("must provide new_dt -- should be the new bg_acsdata, bg_usastats, bg_statestats, or new blockgroupstats that we are comparing to a prior year version or versus a previously-available copy of data for the same year if trying to use a new pipeline to replicate/reproduce a particular dataset such as the 2022 data previously published")
    # new_dt <- data.table::copy(bg_acsdata)
  }
  if (missing(old_dt)) {
    stop("must provide old_dt -- should a previously created version of this dataset, such as the same object for a prior year, or the same or comparable object for the same year -- e.g. the ACS parts of the old blockgroupstats from ACS2022, or maybe old_dt = data.table::copy(EJAM::blockgroupstats) -- if trying to use a new pipeline to replicate a particular dataset such as the 2022 data previously published")
    # old_dt =  data.table::copy(EJAM::blockgroupstats)
  }

  # not NULL
  if (is.null(new_dt)) {stop("new_dt is NULL")}
  if (is.null(old_dt)) {stop("old_dt is NULL")}
  # both are data.frame at least, and optionally data.table too
  if (!("data.frame" %in% class(new_dt)) || !("data.frame" %in% class(new_dt)) ) {
    stop("both must be at least data.frame class (and optionally can be data.table as well)")
  }

  # same class
  if (!all.equal(class(new_dt), class(old_dt))) {
    warning("class(new_dt) and class(old_dt) are not the same: ",
            "new_dt is ", paste0(class(new_dt), collapse = ", "),
            " and ",
            "old_dt is ", paste0(class(new_dt), collapse = ", ")
    )
  }

  # make them both data.table format
  if (!is.data.table(new_dt)) {new_dt <- data.table::as.data.table(new_dt)}
  if (!is.data.table(old_dt)) {old_dt <- data.table::as.data.table(old_dt)}

  # same row counts
  if (NROW(old_dt) != NROW(new_dt)) {
    cat("Row counts differ: new_dt has ", NROW(new_dt), " and old_dt has ", NROW(old_dt), '\n')
    warning("Row counts differ: new_dt has ", NROW(new_dt), " and old_dt has ", NROW(old_dt))
  } else {
    cat("Row counts match, both have ", NROW(new_dt), '\n')
  }

  # same column counts
  if (NCOL(old_dt) != NCOL(new_dt)) {
    cat("Column counts differ: new_dt has ", NCOL(new_dt), " and old_dt has ", NCOL(old_dt), "\n")
    warning("Column counts differ: new_dt has ", NCOL(new_dt), " and old_dt has ", NCOL(old_dt))
  } else {
    cat("Column counts match, both have ", NCOL(new_dt), '\n')
  }

  ######################## #
  # COLUMN NAMES
  ######################## #

  # overlaps in column names
  newnames = colnames(new_dt)
  oldnames = colnames(old_dt)
  sharednames = intersect(newnames, oldnames)
  uniquely_new = setdiff(newnames, oldnames)
  uniquely_old = setdiff(oldnames, newnames)
  if (length(sharednames) == 0) {
    cat('zero column names are shared between new and old \n')
    warning('zero column names are shared between new and old')
  } else {
    cat(length(sharednames), "column names are shared by both \n")
    cat(length(uniquely_old), "are unique to old")
    if (length(uniquely_old) > 0 ) {
      cat(": ", paste0(uniquely_old, collapse = ", "), "\n")
    } else {
      cat("\n")
    }
    cat(length(uniquely_new), " are unique to new")
    if (length(uniquely_new) > 0 ) {
      cat(": ", paste0(uniquely_new, collapse = ", "), "\n")
    } else {
      cat("\n")
    }
  }

  ######################## #
  ## check that all the columns in new_dt are in map_headernames, the metadata source about variables.

  if (!exists("map_headernames")) {
    warning("need map_headernames from EJAM package to be able to examine column names and check their metadata")
  } else {

    nn = names(new_dt)
    not_in_mh = nn[!(nn %in% map_headernames$rname)]
    if (length(not_in_mh) > 0) {
      warning("some columns in new_dt not found in map_headernames")
      cat(
        paste0("Columns in new_dt not found in map_headernames, so may need to add there, with metadata: ",
               paste0(not_in_mh, collapse = ", "))
      )
      cat("\n")
      # cat("Columns in new_dt not found in map_headernames, so may need to add there, with metadata: \n")
      # print(cbind(not_in_mh))
      # not_in_mh
      # [1,] "lingisospanish"
      # [2,] "lingisoeuro"
      # [3,] "lingisoasian"
      # [4,] "lingisoother"
      # [5,] "bgid"
      # [6,] "healthinsurance_universe"
    }
    x = data.frame(colnames=nn, varlist = varinfo(nn)$varlist)
    missing_varlist = x$colnames[is.na(x$varlist)]
    if (length(missing_varlist) > 0) {
      warning("Some columns in new_dt that are not part of a varlist according to map_headernames")
      cat(
        paste0("Columns in new_dt that are not part of a varlist according to map_headernames, so may need to add there, with metadata: ",
               paste0(missing_varlist, collapse = ", "))
      )
      cat("\n")
    }
    # cat("Columns in new_dt that are not part of a varlist according to map_headernames: \n")
    # print(cbind(missing_varlist))
  }

  ######################## #
  # COMPARISONS BASED ON bgfips -- HAVE SAME ROWS AND SAME SORT ORDER IN BOTH
  ######################## #

  # have "bgfips" ?
  if ("bgfips" %in% names(new_dt) && "bgfips" %in% names(old_dt)) {
    cat("bgfips column found in each")

    # same bgfips maybe not same order?
    ok <- setequal(old_dt$bgfips, new_dt$bgfips)
    cat("Are bgfips identical ignoring sort order? ")
    cat(ok)
    cat("\n")
    if (!ok) {
      warning("different set of bgfips values in one vs other -- fix that before further comparisons")
      return(NULL)
    }

    # same bgfips same order?
    ok <- all.equal(old_dt$bgfips, new_dt$bgfips)
    cat("Are bgfips identical and in same order? ")
    cat(ok)
    cat("\n")
    if (!ok) {
      warning("bgfips are not identical in same sort order in old_dt and new_dt, so cannot compare values -- fix that before further comparisons")
      return(NULL)
    }
  } else {
    cat("UNCLEAR IF CAN do most comparisons without both having a 'bgfips' column to confirm sort orders are the same -- may want to fix that before further comparisons \n")
    warning("UNCLEAR IF CAN do most comparisons without both having a 'bgfips' column to confirm sort orders are the same -- may want to fix that before further comparisons")
    # return(NULL)
  }

  ## identical data for the SHARED columns?
  ok <- all.equal(old_dt[, ..sharednames], new_dt[, ..sharednames], check.attributes = F )
  cat("Are the data identical in at least the shared column names? ")
  cat( ok )
  cat("\n")
  if (!ok) {warning("data are not identical even for the shared column names")}

  ############# #
  ## failed to create these expected/previously available variables at all ?

  # uniquely_old
  notmade = setdiff(names(old_dt), names(new_dt))
  if (!exists("varinfo")) {
    warning("cannot use varinfo() to check metadata in map_headernames")
    vlistinfo = NA
  }  else {
    junk = capture.output({
      vlistinfo = varinfo(notmade)$varlist
    })
  }
  notmade = data.frame(rname = notmade, varlist = vlistinfo)


  #### HARD-CODED SET OF MISSING BUT EXPECTED NEW COLUMNS INCLUDED THESE :

  notmade$should = grepl("names_d|names_countabove", notmade$varlist)


  notmade = notmade[notmade$should, ]
  notmade = notmade[order(notmade$varlist, notmade$rname),  ]
  if (exists("formulas_ejscreen_acs")) {
    notmade$hasformula = notmade$rname %in% formulas_ejscreen_acs$rname
  }
  if (NROW(notmade) > 0) {
    warning("Some specific expected columns are in old_dt but are not in new_dt")
    cat(
      paste0("Expected columns in old_dt that are not in new_dt, so may need to add to pipeline code that creates new_dt: ",
             paste0(notmade$rname, collapse = ", "))
    )
    cat("\n")
    # cat("FAILED TO CREATE EXPECTED COLUMNS: \n")
    # print(notmade)
  }

  # calc_formulas_from_varname("lingiso" )


  ## failed to replicate values of these variables:

  ## check each column, to see which are not replicated by pipeline

  ok = sapply(sharednames, function(namex) {all.equal(new_dt[, ..namex], old_dt[, ..namex], check.attributes=FALSE)})
  info = data.frame(rname = sharednames, ok = as.vector(ok))
  table( info$ok != "TRUE" ) # about one third of the approx 100 columns fail to exactly replicate.
  notreplicated = info[info$ok != "TRUE", ]
  junk = capture.output({
    notreplicated$varlist = varinfo(notreplicated$rname)$varlist
  })
  notreplicated = notreplicated[order(notreplicated$varlist, notreplicated$rname),  ]
  notreplicated = data.frame(varlist = notreplicated$varlist, rname = notreplicated$rname, problem = notreplicated$ok)
  if (NROW(notreplicated) > 0) {
    warning("Some columns in old_dt do not exactly replicate in new_dt")
    cat(
      paste0("Columns in old_dt that do not exactly replicate in new_dt, so may need to confirm that is ok for these variables: ",
             paste0(notreplicated$rname, collapse = ", "))
    )
    cat('\n')
    # cat("FAILED TO REPLICATE THESE VALUES: \n")
    # print(notreplicated )
    ## "current" means old blockgroupstats or old_dt, "target" means new bg_acsdata or new_dt
    # e.g.,
    # sum(is.na(old_dt$pctlan_english))
    # sum(is.na(new_dt$pctlan_english))
  }

  cat( "
  ### WILL ADD STATISTICAL COMPARISONS CODE HERE LATER FROM ejscreen_vs FUNCTIONS
")

  cat("
      Comparison via waldo::compare()
      ")
  print(
    {x <-  waldo::compare(old_dt, new_dt)}
  )
  invisible(x)
}
###################################################### #
