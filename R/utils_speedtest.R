

#   SPEEDTEST   #########################################################################



#' Run EJAM analysis for several radii and numbers of sitepoints, recording how long each step takes
#'
#' @details
#'   This is essentially a test script that times each step of EJAM for a large dataset
#'    - pick a sample size (n) (or enter sitepoints, or set n=0 to interactively pick file of points in RStudio)
#'    - pick n random points
#'    - pick a few different radii for circular buffering
#'    - analyze indicators in circular buffers and overall (find blocks nearby and then calc indicators)
#'    - get stats that summarize those indicators
#'    - compare times between steps and radii and other approaches or tools
#'
#' @param n optional, vector of 1 or more counts of how many random points to test, or
#'   set to 0 to interactively pick file of points in RStudio (n is ignored if sitepoints provided)
#' @param sitepoints optional,  (use if you do not want random points) data.frame of points or
#'   path/file with points, where columns are lat and lon in decimal degrees
#' @param fips optional vector of FIPS codes to time FIPS-based analysis instead
#'   of point-buffer analysis. If provided, `speedtest()` times whole
#'   [ejamit()] runs rather than the point-specific substeps.
#' @param shapefile optional shapefile path or object to time polygon-based
#'   analysis instead of point-buffer analysis. If provided, `speedtest()`
#'   times whole [ejamit()] runs rather than the point-specific substeps.
#' @param analysis_type optional label for the kind of analysis being timed.
#'   Usually inferred as `"points"`, `"fips"`, or `"shapefile"`.
#' @param analysis_subtype optional label for the subtype being timed. Usually
#'   inferred as `"point_buffer"`, `"polygon"`, or the FIPS type such as
#'   `"city"` or `"county"`.
#' @param weighting optional, if using random points, how to weight them,
#'   such as facilities, people, or blockgroups. see [testpoints_n()]
#' @param radii optional, one or more radius values in miles
#'   to use in creating circular buffers when findings residents nearby each of sitepoints.
#'   The default list includes one that is 5km (approx 3.1 miles)
#' @param test_getblocksnearby whether to include this function in timing - not used because always done
#' @param test_doaggregate  whether to include this function in timing
#' @param test_batch.summarize  whether to include this function in timing
#' @param test_ejamit whether to test only ejamit()
#'   instead of its subcomponents like getblocksnearby(), doaggregate(), etc
#' @param logging logical optional, whether to save log file with timings of steps.
#'   NOTE this slows it down though.
#' @param logfolder optional, name of folder for log file
#' @param logfilename optional, name of log file to go in folder
#' @param honk_when_ready optional, self-explanatory
#' @param saveoutput but this slows it down if set to TRUE to save each run as .rda file
#' @param collect_detailed if `TRUE`, also collect a per-run timing table in the
#'   schema used by legacy `Analysis_timing_results.csv` files
#' @param detail_point_counts when `collect_detailed = TRUE`, ensure runs for
#'   these counts are also included when possible. For random-point runs, these
#'   values are added to `n` if they are less than or equal to `max(n)`. For
#'   explicit `sitepoints`, `fips`, or `shapefile` inputs, the first `k` rows or
#'   codes are used for each requested `k` that is less than or equal to the
#'   input size.
#' @param detailed_csv optional path to a `.csv` file where that detailed timing
#'   table should be written. If provided, `collect_detailed` is forced to `TRUE`.
#' @param plot whether to create plot of results
#' @param avoidorphans see [getblocksnearby()] or [ejamit()] regarding this param
#' @param getblocks_diagnostics_shown set TRUE to see more details on block counts etc.
#' @param ... passed to plotting function
#' @examples \dontrun{
#'   speedseen_few <- EJAM:::speedtest(c(50,500), radii=c(1, 3.106856), logging=FALSE, honk=FALSE)
#'
#'   speedseen_nearer_to1k <- EJAM:::speedtest(n = c(1e2,1e3,1e4 ), radii=c(1, 3.106856,5 ),
#'     logging=TRUE, honk=FALSE)
#'   save( speedseen_nearer_to1k, file = "~/../Downloads/speedseen_nearer_to1k.rda")
#'   rstudioapi::savePlotAsImage(        "~/../Downloads/speedseen_nearer_to1k.png")
#'
#'   speedseen_all <- EJAM:::speedtest(
#'     n = c(1e2,1e3,1e4),
#'     radii=c(1, 3.106856, 5, 10, 31.06856),
#'     logging=TRUE, honk=TRUE
#'   )
#'
#'   EJAM:::speedtest(
#'     n = c(100, 1000),
#'     radii = c(1, 3.106856),
#'     collect_detailed = TRUE,
#'     detail_point_counts = c(1, 2, 10),
#'     detailed_csv = "data-raw/Analysis_timing_results_new.csv",
#'     logging = FALSE,
#'     honk_when_ready = FALSE,
#'     plot = FALSE
#'   )
#'
#'   EJAM:::speedtest(
#'     fips = EJAM::fips_counties_from_state_abbrev("DE"),
#'     collect_detailed = TRUE,
#'     detail_point_counts = c(1, 3),
#'     detailed_csv = "data-raw/Analysis_timing_results_fips.csv",
#'     plot = FALSE,
#'     honk_when_ready = FALSE
#'   )
#'
#'   EJAM:::speedtest(
#'     shapefile = system.file(
#'       "testdata/shapes/portland_folder_shp/Neighborhoods_regions.shp",
#'       package = "EJAM"
#'     ),
#'     collect_detailed = TRUE,
#'     detail_point_counts = c(1, 3, 25),
#'     detailed_csv = "data-raw/Analysis_timing_results_shapefile.csv",
#'     plot = FALSE,
#'     honk_when_ready = FALSE
#'   )
#'  }
#' @return A summary timing table with one row per `(points, radius)` run. If
#'   `collect_detailed = TRUE`, the returned table also has an attribute called
#'   `"detailed_results"` containing a per-run timing table in the legacy
#'   `Analysis_timing_results.csv` schema.
#' @seealso [speedtest_plot()]
#'
#' @keywords internal
#'
speedtest <- function(n=10, sitepoints=NULL, fips=NULL, shapefile=NULL, analysis_type=NULL, analysis_subtype=NULL, weighting='frs',
                      radii=c(1, 3.106856, 5, 10, 31.06856)[1:3], avoidorphans=FALSE,
                      test_ejamit = FALSE, test_getblocksnearby=TRUE, test_doaggregate=TRUE, test_batch.summarize=FALSE,
                      logging=FALSE, logfolder='.', logfilename="log_n_datetime.txt", honk_when_ready=TRUE,
                      saveoutput=FALSE, collect_detailed=FALSE, detail_point_counts=c(1L, 2L, 10L), detailed_csv=NULL,
                      plot=TRUE, getblocks_diagnostics_shown=FALSE, ...) {

  n_was_missing <- missing(n)
  radii_was_missing <- missing(radii)
  input_provided <- c(
    points = !is.null(sitepoints),
    fips = !is.null(fips),
    shapefile = !is.null(shapefile)
  )
  if (sum(input_provided) > 1) {
    stop("Provide only one of sitepoints, fips, or shapefile")
  }
  if (is.null(analysis_type)) {
    analysis_type <- if (input_provided[["fips"]]) {
      "fips"
    } else if (input_provided[["shapefile"]]) {
      "shapefile"
    } else {
      "points"
    }
  }
  analysis_type <- match.arg(
    analysis_type,
    c("points", "latlon", "fips", "shapefile", "shp")
  )
  if (analysis_type == "latlon") {
    analysis_type <- "points"
  }
  if (analysis_type == "shp") {
    analysis_type <- "shapefile"
  }
  if (is.null(analysis_subtype)) {
    analysis_subtype <- switch(
      analysis_type,
      points = "point_buffer",
      fips = "unknown",
      shapefile = "polygon"
    )
  }
  if (analysis_type %in% c("fips", "shapefile")) {
    if (!n_was_missing) {
      warning("n ignored because fips or shapefile was provided")
    }
    test_ejamit <- TRUE
    test_getblocksnearby <- FALSE
    test_doaggregate <- FALSE
    test_batch.summarize <- FALSE
    if (analysis_type == "fips" || radii_was_missing) {
      radii <- 0
    }
  }
  n <- sort(n, decreasing = TRUE) # just to keep organized
  radii <- sort(radii, decreasing = TRUE) # IT WILL REPORT WRONG NUMBERS / WRONG ORDER OTHERWISE.
  rtextfile <- paste(radii, collapse = "-")
  ntextfile <- paste(n, collapse = "-")
  if (!is.null(detailed_csv)) {
    collect_detailed <- TRUE
  }
  detail_point_counts <- sort(unique(as.integer(stats::na.omit(detail_point_counts))), decreasing = TRUE)
  detail_point_counts <- detail_point_counts[detail_point_counts > 0]

  if (test_ejamit) {
    if (any(test_getblocksnearby, test_doaggregate, test_batch.summarize)) {
      warning("test_ejamit=TRUE, so ignoring test_getblocksnearby, test_doaggregate, test_batch.summarize")
    }
    test_getblocksnearby = FALSE; test_doaggregate = FALSE; test_batch.summarize = FALSE
  }
  if (test_batch.summarize && !test_doaggregate) {
    warning("cannot test batch.summarize without doing doaggregate")
    return(NULL)
  }
  cat('\nsee profvis::profvis({}) for viewing where the bottlenecks are \n\n')

  # Test script that times each step of EJAM for a large dataset

  # - pick a sample size (n) (or enter sitepoints, or set n=0 to interactively pick file of points in RStudio)
  # - pick n random points
  # - pick a few different radii for circular buffering
  # - analyze indicators in circular buffers and overall (find blocks nearby and then calc indicators)
  # - get stats that summarize those indicators
  # - compare times between steps and radii and other approaches or tools

  ######################### #

  if (n[1] == 0 && is.null(sitepoints)) {
    if (interactive()) {sitepoints <- rstudioapi::selectFile("Select xlsx or csv file with lat,lon coordinates", path = ".", existing = FALSE)
    }
  }

  if (logging ||  !missing(logfolder) || !missing(logfilename))  {
    # PREP LOG FILE
    logfilename <- paste0("logfile_", ntextfile, "_pts_", rtextfile, "_miles_", Sys.time_txt(), ".txt")  # file.path(logfolder, fname)
    logto = file.path( logfolder, logfilename)
    # START LOGGING
    sink(file = logto, split = TRUE)
    on.exit(sink())
    cat("Started log "); print(Sys.time()); cat("\n")
  }

  fips_inputs <- NULL
  shapefile_inputs <- NULL

  if (analysis_type == "fips") {
    if (is.null(fips)) {
      stop("fips must be provided when analysis_type = 'fips'")
    }
    if (!missing(weighting)) {
      warning("weighting ignored because fips provided")
    }
    fips_full <- fips_lead_zero(fips)
    analysis_subtype <- speed_fips_analysis_subtype(fips_full)
    n_full <- length(fips_full)
    n <- if (collect_detailed && length(detail_point_counts) > 0) {
      sort(unique(c(n_full, detail_point_counts[detail_point_counts <= n_full])), decreasing = TRUE)
    } else {
      n_full
    }
    fips_inputs <- lapply(n, function(k) {
      fips_full[seq_len(k)]
    })
  } else if (analysis_type == "shapefile") {
    if (is.null(shapefile)) {
      stop("shapefile must be provided when analysis_type = 'shapefile'")
    }
    if (!missing(weighting)) {
      warning("weighting ignored because shapefile provided")
    }
    shapefile_full <- shapefile_from_any(shapefile, cleanit = FALSE, silentinteractive = TRUE)
    n_full <- NROW(shapefile_full)
    n <- if (collect_detailed && length(detail_point_counts) > 0) {
      sort(unique(c(n_full, detail_point_counts[detail_point_counts <= n_full])), decreasing = TRUE)
    } else {
      n_full
    }
    shapefile_inputs <- lapply(n, function(k) {
      shapefile_full[seq_len(k), , drop = FALSE]
    })
  } else if (is.null(sitepoints)) {
    if (collect_detailed && length(detail_point_counts) > 0) {
      n <- sort(unique(c(n, detail_point_counts[detail_point_counts <= max(n)])), decreasing = TRUE)
    }
    # PICK TEST DATASET(s) OF FACILITY POINTS
    cat("Picking random points for testing.\n")
    # Also see test files in EJAM/inst/testdata/latlon/
    sitepoints <- list()
    # we can have the smaller sets of points be a random subset of the next larger, to make it more apples to apples
    nsorted <- sort(n,decreasing = TRUE)
    for (i in 1:length(n)) {
      if (i == 1) {sitepoints[[1]] <- testpoints_n(n = nsorted[1], weighting = weighting)} else {
        # *** Only the overall largest set uses weighted probabilities this way - subsets are uniform likelihood of each from large set
        # otherwise cannot easily take subsets without essentially rewriting testpoints_n() code
        sitepoints[[i]] <- sitepoints[[i - 1]][sample(1:nrow(sitepoints[[1]]), size = nsorted[i] ), ]
      }
    }
    cat("Finished picking random points for testing.\n\n")
  } else {
    sitepoints_full <- latlon_from_anything(sitepoints)
    if (!missing(n)) {warning("n ignored because sitepoints provided")}
    if (!missing(weighting)) {warning("weighting ignored because sitepoints provided")}
    n_full <- NROW(sitepoints_full)
    if (collect_detailed && length(detail_point_counts) > 0) {
      n <- sort(unique(c(n_full, detail_point_counts[detail_point_counts <= n_full])), decreasing = TRUE)
      sitepoints <- lapply(n, function(k) {
        sitepoints_full[seq_len(k), , drop = FALSE]
      })
    } else {
      n <- n_full
      sitepoints <- list(sitepoints_full)
    }
  }

  # PICK SOME OPTIONS FOR RADIUS
  if (length(radii) > 10 || any(radii < 0)) {stop("Did you intend to provide more than 10 radius values? Cannot try more than 10 radius values in one run.")}
  # radii <- c(1, 3.106856, 5, 10, 20)
  # 3.1 miles IS 5 KM ... 5*1000/ meters_per_mile

  # MAKE SURE localtree INDEX OF ALL US BLOCKS IS AVAILABLE FROM EJAM PACKAGE
  if (analysis_type == "points" && !exists("localtree")) {
    step0 <- system.time({
      cat("Creating national index of block locations (localtree) since it was not found.\n")
      indexblocks()
      quadtree <- localtree
      cat("Finished createTree()\n")

      #time to create quadtree 1.116 seconds
    })
    print(step0)
  }
  ####################### #


  # START RUNNING ANALYSIS  ------------------------------------------------------------------ -


  ntext <- paste(paste0(n,     " sites"), collapse = ", ")
  rtext <- paste(paste0(radii, " miles"), collapse = ", ")
  cat("Analysis type       = ", analysis_type, "\n")
  cat("Size(s) of list(s) of points = ", ntext, '\n')
  cat("Radius choice(s)     = ", rtext, '\n')

  cat("test_ejamit = ", test_ejamit, "\n")
  if (!test_ejamit) {
    cat("test_getblocksnearby = ", test_getblocksnearby, "\n")
    cat("test_doaggregate     = ", test_doaggregate, "\n")
    cat("test_batch.summarize = ", test_batch.summarize, "\n")
  }
  cat("saveoutput = ", saveoutput, "\n")
  cat("collect_detailed = ", collect_detailed, "\n")

  nlist = n
  combonumber <- 0
  speedtable <- list()
  detailed_results <- list()

  overall_start_time <- Sys.time()

  cat("Starting analysis "); print(Sys.time()); cat("\n")

  for (i in seq_along(nlist)) {

    n <- nlist[[i]]
    cat("\n--------------------------------------------------------------------\n")
    cat("\nAnalyzing", n, "facilities:")


    for (radius in radii) {


      combonumber <- combonumber + 1
      cat("\n  Radius of", radius, "miles (Radius #", which(radius == radii), "of the", length(radii), 'being tested).\n')

      start_time <- Sys.time()
      time_getblocksnearby <- 0
      time_doaggregate <- 0
      time_batch_summarize <- 0
      time_ejamit <- 0
      nrows_blocks <- 0L
      nrows_results_bysite <- 0L

      if (!test_ejamit) {

        mysites2blocks = NA
        step1 <- system.time({
          mysites2blocks <-  getblocksnearby(
            sitepoints = sitepoints[[i]],
            radius = radius, maxradius = 31.07,
            avoidorphans = avoidorphans)
        })
        time_getblocksnearby <- unname(step1[["elapsed"]])
        nrows_blocks <- if (is.data.frame(mysites2blocks)) NROW(mysites2blocks) else 0L
        out <- NA
        if (test_doaggregate) {
          cat('\nStarted doaggregate() to calculate each indicator for each site, and overall.\n')
          step2 <- system.time({
            out <-  doaggregate(sites2blocks = mysites2blocks, silentinteractive = TRUE)
          })
          time_doaggregate <- unname(step2[["elapsed"]])
          if (is.list(out) && ("results_bysite" %in% names(out)) && is.data.frame(out$results_bysite)) {
            nrows_results_bysite <- NROW(out$results_bysite)
          }
        }
        if (test_batch.summarize ) {
          step3 <- system.time({
            out2 <- batch.summarize(
              sitestats = out$results_bysite,
              popstats  = out$results_bybg_people, # provides a way to get stats on all UNIQUE people with no double-counting
              overall   = out$results_overall
              ## user-selected quantiles to use
              #probs = as.numeric(input$an_list_pctiles),
              # thresholds = list(95) # compare variables to 95th %ile
            )
          })
          time_batch_summarize <- unname(step3[["elapsed"]])
        }
      } else {
        # doing ejamit() because test_ejamit == TRUE
        cat('\nStarted ejamit() to calculate each indicator for each site, and overall.\n')
        ejamit_args <- list(
          radius = radius,
          avoidorphans = avoidorphans,
          silentinteractive = TRUE
        )
        if (analysis_type == "points") {
          ejamit_args$sitepoints <- sitepoints[[i]]
        }
        if (analysis_type == "fips") {
          ejamit_args$fips <- fips_inputs[[i]]
        }
        if (analysis_type == "shapefile") {
          ejamit_args$shapefile <- shapefile_inputs[[i]]
        }

        step_ejamit <- system.time({
          out <- do.call(ejamit, ejamit_args)
        })
        time_ejamit <- unname(step_ejamit[["elapsed"]])
        if (is.list(out) && ("results_bysite" %in% names(out)) && is.data.frame(out$results_bysite)) {
          nrows_results_bysite <- NROW(out$results_bysite)
        }

      }


      # cat(paste0("\nSpeed report for ", n, " points at ", radius, " miles: "))
      # cat("----------------------------------\n")
      #write time elapsed to csv?
      # write.csv(t(data.matrix(elapsed)),file=paste0("./inst/time_radius_",myradius,"_100k.csv"))
      perhour <- speedreport(start_time, Sys.time(), n)
      analysis_subtype_i <- analysis_subtype
      if (analysis_type == "fips") {
        analysis_subtype_i <- speed_fips_analysis_subtype(fips_inputs[[i]])
      }
      speedtable[[combonumber]] <- list(
        analysis_type = analysis_type,
        analysis_subtype = analysis_subtype_i,
        points = n,
        miles = radius,
        perhr = perhour
      )
      if (collect_detailed) {
        detailed_results[[combonumber]] <- data.frame(
          analysis_type = analysis_type,
          analysis_subtype = analysis_subtype_i,
          input_number = n,
          radius = radius,
          time_getblocksnearby = time_getblocksnearby,
          time_doaggregate = time_doaggregate,
          time_batch_summarize = time_batch_summarize,
          nrows_blocks = nrows_blocks,
          nrows_results_bysite = nrows_results_bysite,
          time_ejamit = time_ejamit,
          stringsAsFactors = FALSE
        )
      }

      #  show diagnostics here like how many blocks were found nearby? this slows it down
      if (test_getblocksnearby && getblocks_diagnostics_shown) {
        getblocks_diagnostics(mysites2blocks)
      }

    } # NEXT RADIUS
    # cat("\nFinished analyzing all radius values for this set of", prettyNum(n, big.mark = ","),"points or sites.\n")
    if (saveoutput) { # slows it down so just for diagnostics or saving batches of results
      save(out, file = file.path(logfolder, paste0( "out n", n, "_rad", paste(radii,collapse = "-"), ".rda")))
      # save(out2, file= "out2.rda")
      x <- as.data.frame(data.table::rbindlist(speedtable, fill = TRUE))

      save(x, file = file.path(logfolder, paste0("speedtable_", n,"_rad", paste(radii,collapse = "-"), ".rda")))
    }

  } # NEXT LIST OF POINTS (facility list) ----------------------------------------------------------------- -

  endtime <- Sys.time()
  cat('Stopped timing.\n')

  cat("--------------------------------------------------------------------\n")

  CIRCLESDONE <- sum(nlist) * length(radii)
  cat("Finished with all sets of sites,", length(radii),"radius values, each for a total of",
      prettyNum(sum(nlist), big.mark = ",") ,"sites =", prettyNum(CIRCLESDONE, big.mark = ","), "circles total.\n")
  speedreport(overall_start_time, endtime, CIRCLESDONE)

  speedtable <- as.data.frame(data.table::rbindlist(speedtable, fill = TRUE))

  speedtable <- speedtable_expand(speedtable)
  print(speedtable_summarize(speedtable))

  total_points_run <- sum(speedtable$points)
  total_hours <- sum(speedtable$points / speedtable$perhr)
  avg_perhr <- round(total_points_run / total_hours, 0)
  cat("\nAverage points/hour  =", prettyNum( avg_perhr,big.mark = ","), "\n")

  cat("Size(s) of list(s) of points =", ntext, '\n')
  cat("Radius choice(s)     =", rtext, '\n')
  cat("test_ejamit =", test_ejamit, "\n")
  if (!test_ejamit) {
    cat("test_getblocksnearby =", test_getblocksnearby, "\n")
    cat("test_doaggregate     =", test_doaggregate, "\n")
    cat("test_batch.summarize =", test_batch.summarize, "\n")
  }
  if (logging) {sink(NULL)} # stop logging to file.
  if (plot) {speedtest_plot(speedtable, ...)}
  if (collect_detailed) {
    detailed_results <- as.data.frame(data.table::rbindlist(detailed_results, fill = TRUE))
    rownames(detailed_results) <- NULL
    attr(speedtable, "detailed_results") <- detailed_results
    if (!is.null(detailed_csv)) {
      utils::write.csv(detailed_results, file = detailed_csv, row.names = FALSE)
      cat("Detailed timing results written to ", detailed_csv, "\n", sep = "")
    }
  }
  print(speedtable)

  if (interactive() && honk_when_ready && length(try(find.package("beepr", quiet = T), silent = TRUE)) != 0) {
    # using beepr::beep() since utils::alarm() may not work
    # using :: might create a dependency but prefer that pkg be only in Suggests in DESCRIPTION
    beepr::beep(8)
  }
  # if (interactive()) {
  #   rstudioapi::showDialog("", "FINISHED")
  # }
  return(speedtable)
}
######################################################################### #


#' utility to plot output of speedtest(), rate of points analyzed per hour
#'
#' @param x table from [speedtest()], or one element of output of [speedtest_runtime_scenarios()]
#' @param ltype optional type of line for plot
#' @param plotfile optional path and filename of .png image file to save
#' @return side effect is a plot. returns x but with seconds column added to it
#' @seealso [speedtest()]
#'
#' @keywords internal
#'
speedtest_plot = function(x, ltype="b", plotfile=NULL, secondsperthousand=FALSE) {

  radii <- unique(x$miles)
  nlist  <- unique(x$points)
  mycolors <- runif(length(radii), 1, 600)
  if (secondsperthousand) {
    yvals = x$secondsper1000
    ylab = "Seconds per 1,000 sites"
  } else {
    yvals <- x$perhr/1000
    ylab = "Thousands of sites per hour"
  }
  yl <-  c(0,max(yvals)) # range(x$perhr)
  xl <- c(0,max(x$miles)) # range(x$miles)
  x$seconds <- x$points / x$perhr * 3600
  atmost = aggregate(x$seconds, by = list(n = x$points), FUN = max )
  maxseconds = atmost$x[match(nlist, atmost$n)]
  if (!is.null(plotfile)) {
    png(filename = plotfile )
    on.exit(  dev.off())
  }

  plot(
    x$miles[x$points == nlist[1]],
    yvals[x$points == nlist[1]] ,
    type = ltype, col = mycolors[1],
    xlim = xl, ylim = yl, ylab = ylab, xlab = "miles radius",
    main = "Speed of this analysis")
  if (length(nlist) > 1) {
    for (i in 2:length(nlist)) {
      points(
        x$miles[x$points == nlist[i]],
        yvals[x$points == nlist[i]]  ,
        type = ltype, col = mycolors[i])
    }
    legwhere = ifelse(secondsperthousand, "topleft", "bottomleft")
    legend(legwhere,
           legend = rev(paste0(prettyNum(nlist, big.mark = ","), " points take up to ",  round(maxseconds, 0), " seconds")),
           fill = rev(  mycolors[1:length(nlist)]))
  }
  return(x)
}
######################################################################### #


#' utility used by speedtest()
#'
#' @param speedtable from speedtest(), with columns named points and perhr
#' @seealso [speedtest()]
#'
#' @keywords internal
#'
speedtable_summarize <- function(speedtable) {

  # used by speedtest()
  runs <- sum(speedtable$points)
  total_hours <- sum(speedtable$points / speedtable$perhr)
  perhr <-  round(runs / total_hours ,0)
  mysummary <- data.frame(points = runs, miles = NA, perhr = perhr)
  return(speedtable_expand(mysummary))
}
######################################################################### #


#' Utility used by speedtest() and speedtable_summarize()
#'
#' @param speedtable must have columns called  points, miles, and perhr
#'
#' @keywords internal
#'
speedtable_expand <- function(speedtable) {
  # used by speedtest() and by speedtable_summarize()
  # input param speedtable must have columns called  points, miles, and perhr
  speedtable$perminute <- round(speedtable$perhr /   60, 0)
  speedtable$persecond <- round(speedtable$perhr / 3600, 0)
  speedtable$minutes   <- round(speedtable$points / (speedtable$perhr / 60), 0)
  speedtable$seconds   <- round(speedtable$points / (speedtable$perhr / 3600), 0)
  speedtable$secondsper1000 <- round((1000/speedtable$points) * speedtable$points / (speedtable$perhr / 3600), 0)
  return(speedtable)
}
######################################################################### #

#' Classify FIPS inputs for runtime prediction
#'
#' @param fips vector of FIPS codes.
#' @return A single subtype string such as `"city"`, `"county"`, `"mixed"`, or
#'   `"unknown"`.
#'
#' @keywords internal
#'
speed_fips_analysis_subtype <- function(fips) {
  if (length(fips) == 0) {
    return("unknown")
  }
  ftype <- suppressWarnings(fipstype(fips, quiet = TRUE))
  ftype <- unique(stats::na.omit(ftype))
  if (length(ftype) == 0) {
    return("unknown")
  }
  if (length(ftype) == 1) {
    return(ftype)
  }
  "mixed"
}
######################################################################### #

#' Build a runtime model lookup key
#'
#' @param analysis_type input mode such as `"points"`, `"fips"`, or
#'   `"shapefile"`.
#' @param analysis_subtype optional subtype such as `"city"` or `"county"`.
#' @return Runtime model lookup key.
#'
#' @keywords internal
#'
speed_runtime_model_key <- function(analysis_type, analysis_subtype = NULL) {
  analysis_type <- match.arg(
    analysis_type,
    c("points", "latlon", "fips", "shapefile", "shp")
  )
  if (analysis_type == "latlon") {
    analysis_type <- "points"
  }
  if (analysis_type == "shp") {
    analysis_type <- "shapefile"
  }
  if (is.null(analysis_subtype) || is.na(analysis_subtype) || analysis_subtype == "") {
    return(analysis_type)
  }
  if (analysis_type == "fips") {
    return(paste0("fips_", analysis_subtype))
  }
  analysis_type
}
######################################################################### #

#' Format predicted runtime in compact human-readable text
#'
#' @param seconds predicted seconds.
#' @return Character string.
#'
#' @keywords internal
#'
speed_format_seconds <- function(seconds) {
  seconds <- as.numeric(seconds)
  if (length(seconds) == 0) {
    return(character(0))
  }
  vapply(seconds, function(x) {
    if (is.na(x)) {
      return("unknown")
    }
    x <- max(0, x)
    if (x < 90) {
      return(paste0(round(x), " seconds"))
    }
    if (x < 3600) {
      return(paste0(round(x / 60, 1), " minutes"))
    }
    paste0(round(x / 3600, 1), " hours")
  }, character(1))
}
######################################################################### #

#' Create a short runtime estimate message
#'
#' @param rows number of locations to analyze.
#' @param radius buffer radius in miles.
#' @param analysis_type input mode.
#' @param analysis_subtype optional subtype.
#' @return List with prediction table and message.
#'
#' @keywords internal
#'
speed_ejamit_runtime_estimate <- function(rows, radius = 0, analysis_type = c("points", "latlon", "fips", "shapefile", "shp"), analysis_subtype = NULL) {

  prediction <- speed_predict_ejamit_runtime(
    rows = rows,
    radius = radius,
    analysis_type = analysis_type,
    analysis_subtype = analysis_subtype
  )
  seconds_fit <- as.numeric(prediction[, "fit"])
  seconds_upper <- as.numeric(prediction[, "upr"])
  label_type <- match.arg(analysis_type)
  if (label_type == "latlon") {
    label_type <- "points"
  }
  if (label_type == "shp") {
    label_type <- "shapefile"
  }
  label <- switch(
    label_type,
    points = "point-buffer",
    shapefile = "polygon",
    fips = if (!is.null(analysis_subtype) && !is.na(analysis_subtype) && analysis_subtype != "") {
      paste("FIPS", analysis_subtype)
    } else {
      "FIPS"
    }
  )
  list(
    prediction = prediction,
    seconds_fit = seconds_fit,
    seconds_upper = seconds_upper,
    message = paste0(
      "Estimated analysis time: about ",
      speed_format_seconds(seconds_fit),
      " for ",
      prettyNum(rows, big.mark = ","),
      " ",
      label,
      " location",
      ifelse(rows == 1, "", "s"),
      " (upper estimate ",
      speed_format_seconds(seconds_upper),
      ")."
    )
  )
}
######################################################################### #

#' Run timing tests for the main EJAM analysis input types
#'
#' @param detailed_csv optional output path for the combined detailed timing
#'   table.
#' @param point_counts counts of random point-buffer analyses to time.
#' @param point_radii radii, in miles, for point-buffer analyses.
#' @param fips optional custom FIPS vector. If provided, it is timed as one
#'   additional FIPS scenario.
#' @param fips_counties optional county FIPS vector. By default, uses
#'  a preselected random sample from the counties in [blockgroupstats].
#'
#' @param fips_cities optional city/place FIPS vector. By default, uses
#'   a preselected random sample from [censusplaces].
#'
#' @param fips_counts FIPS counts to time, used to pick subsets of fips_cities or fips_counties.
#' @param shapefile optional shapefile path or object. By default, the Portland
#'   example shapefile in `inst/testdata` is used.
#' @param shapefile_counts polygon counts to time when enough polygons exist.
#' @param run_points,run_fips,run_fips_counties,run_fips_cities,run_shapefile
#'   logical flags indicating which analysis types to run.
#'   run_fips is for the optional custom fips.
#' @param ... passed to [speedtest()].
#' @return A list with one speed table per analysis type. The combined detailed
#'   timing rows are also attached as attribute `"detailed_results"`.
#' @seealso [speedtest()]
#'
#' @keywords internal
#'
speedtest_runtime_scenarios <- function(
    detailed_csv = file.path("data-raw", "Analysis_timing_results_runtime_scenarios.csv"),
    point_counts = c(1L, 10L, 100L, 1000L, 3000L, 10000L),
    point_radii = c(1, 3.106856, 5),
    fips = NULL,
    fips_counties = NULL,
    fips_cities = NULL,
    fips_counts = c(1L, 10L, 50L, 100L),
    shapefile = NULL,
    shapefile_counts = c(1L, 3L, 25L),
    run_points = TRUE,
    run_fips = !is.null(fips),
    run_fips_counties = TRUE,
    run_fips_cities = TRUE,
    run_shapefile = TRUE,
    ...) {

  results <- list()

  if (run_points) {
    results$points <- speedtest(
      n = point_counts,
      radii = point_radii,
      analysis_type = "points",
      collect_detailed = TRUE,
      detail_point_counts = point_counts,
      plot = FALSE,
      honk_when_ready = FALSE,
      ...
    )
  }

  if (run_fips) {
    if (is.null(fips)) {
      stop("fips must be provided when run_fips = TRUE")
    }
    fips <- fips[seq_len(min(length(fips), max(fips_counts)))]
    results$fips <- speedtest(
      fips = fips,
      analysis_type = "fips",
      collect_detailed = TRUE,
      detail_point_counts = fips_counts,
      plot = FALSE,
      honk_when_ready = FALSE,
      ...
    )
  }

  if (run_fips_counties) {
    if (is.null(fips_counties)) {
      # put all counties in random order
      set.seed(999)
      countyfipsall = unique(substr(blockgroupstats$bgfips,1,5))
      countyfipsall = sample(countyfipsall, length(countyfipsall), replace = F)
      fips_counties <- countyfipsall
    }
    fips_counties <- fips_counties[seq_len(min(length(fips_counties), max(fips_counts)))]
    results$fips_counties <- speedtest(
      fips = fips_counties,
      analysis_type = "fips",
      analysis_subtype = "county",
      collect_detailed = TRUE,
      detail_point_counts = fips_counts,
      plot = FALSE,
      honk_when_ready = FALSE,
      ...
    )
  }

  if (run_fips_cities) {
    if (is.null(fips_cities)) {
      # put all cities in random order
      set.seed(999)
      cityfipsall = unique(fips_lead_zero(censusplaces$fips))
      cityfipsall = sample(cityfipsall, length(cityfipsall), replace = F)
      fips_cities <- cityfipsall
    }
    fips_cities <- fips_cities[seq_len(min(length(fips_cities), max(fips_counts)))]
    results$fips_cities <- speedtest(
      fips = fips_cities,
      analysis_type = "fips",
      analysis_subtype = "city",
      collect_detailed = TRUE,
      detail_point_counts = fips_counts,
      plot = FALSE,
      honk_when_ready = FALSE,
      ...
    )
  }

  if (run_shapefile) {
    if (is.null(shapefile)) {
      shapefile <- system.file("testdata/shapes/portland.json", package = "EJAM")
    }
    results$shapefile <- speedtest(
      shapefile = shapefile,
      analysis_type = "shapefile",
      collect_detailed = TRUE,
      detail_point_counts = shapefile_counts,
      plot = FALSE,
      honk_when_ready = FALSE,
      ...
    )
  }

  detailed_results <- data.table::rbindlist(
    lapply(results, function(x) attr(x, "detailed_results")),
    fill = TRUE
  )
  detailed_results <- as.data.frame(detailed_results)
  attr(results, "detailed_results") <- detailed_results

  if (!is.null(detailed_csv)) {
    utils::write.csv(detailed_results, file = detailed_csv, row.names = FALSE)
    cat("Combined scenario timing results written to ", detailed_csv, "\n", sep = "")
  }

  results
}
######################################################################### #

#' Utility used in app_server to predict ejamit or doaggregate runtime
#'
#' @param rows number of locations to be analyzed
#' @param radius buffer radius distance, in miles
#' @param analysis_type kind of input being analyzed. Use `"points"` for
#'   point-buffer analyses, `"fips"` for Census unit analyses, or
#'   `"shapefile"` for polygon analyses.
#' @param analysis_subtype optional subtype. For FIPS analysis, this is usually
#'   from [fipstype()], such as `"city"` or `"county"`.
#'
#' @keywords internal
#'
speed_predict_ejamit_runtime <- function(rows, radius = 0, analysis_type = c("points", "latlon", "fips", "shapefile", "shp"), analysis_subtype = NULL) {

  analysis_type <- match.arg(analysis_type)
  if (analysis_type == "latlon") {
    analysis_type <- "points"
  }
  if (analysis_type == "shp") {
    analysis_type <- "shapefile"
  }
  runtime_model_key <- speed_runtime_model_key(analysis_type, analysis_subtype)

  runtime_model <- NULL
  if (exists("modelEjamitByAnalysisType", inherits = TRUE)) {
    runtime_models <- get("modelEjamitByAnalysisType", inherits = TRUE)
    if (is.list(runtime_models) && runtime_model_key %in% names(runtime_models)) {
      runtime_model <- runtime_models[[runtime_model_key]]
    }
    if (is.null(runtime_model) && is.list(runtime_models) && analysis_type %in% names(runtime_models)) {
      runtime_model <- runtime_models[[analysis_type]]
    }
  }
  if (is.null(runtime_model) && analysis_type == "points" && exists("modelEjamit", inherits = TRUE)) {
    runtime_model <- get("modelEjamit", inherits = TRUE)
  }
  if (is.null(runtime_model) && exists("modelEjamit", inherits = TRUE)) {
    runtime_model <- get("modelEjamit", inherits = TRUE)
  }
  if (is.null(runtime_model)) {
    stop("No ejamit runtime model is available")
  }

  ejamit_model_data <- data.frame(input_number = rows, radius = radius)

  predicted_runtime <- suppressWarnings(
    predict(runtime_model,
            newdata = ejamit_model_data,
            interval = "prediction",
            level = 0.95)
  )
  return(predicted_runtime)
}
######################################################################### #

#' Utility used in app_server to predict ejamit or doaggregate runtime
#'
#' @param nrows_blocks_value count of blocks (not block groups) to be aggregated in the analysis
#'
#' @keywords internal
#'
speed_predict_doaggregate_runtime <- function(nrows_blocks_value) {

  doaggregate_model_data <- data.frame(nrows_blocks = nrows_blocks_value)

  predicted_doaggregate_runtime <- suppressWarnings(
    predict(modelDoaggregate,
            newdata = doaggregate_model_data,
            interval = "prediction",
            level = 0.95)
  )
  return(predicted_doaggregate_runtime)
}
############################################################################### #
# older manual TESTING JUST getblocksnearby() not including doaggregate()

# olddir=getwd()
# setwd("~/../Downloads")
# t1_1000=system.time({  x1=getblocksnearby(testpoints_1000,1);  save(x1,file = 'x1_1000.rda');rm(x1)})
# t3_1000=system.time({  x3=getblocksnearby(testpoints_1000,3);  save(x3,file = 'x3_1000.rda');rm(x3)})
# t6_1000=system.time({  x6=getblocksnearby(testpoints_1000,6);  save(x6,file = 'x6_1000.rda');rm(x6)})
#
# testpoints_10k <- testpoints_n(10000, weighting = "frs")
#
# t1_10k=system.time({  x1=getblocksnearby(testpoints_10k,1);  save(x1,file = 'x1_10k.rda');rm(x1)})
# t3_10k=system.time({  x3=getblocksnearby(testpoints_10k,3);  save(x3,file = 'x3_10k.rda');rm(x3)})
# t6_10k=system.time({  x6=getblocksnearby(testpoints_10k,6);  save(x6,file = 'x6_10k.rda');rm(x6)})
# rm(testpoints_10k)
# setwd(olddir)
#
# # points per hour:
#
# prettyNum(round(3600*1000/t1_1000[3],0),big.mark = ",")
# prettyNum(round(3600*1000/t3_1000[3],0),big.mark = ",")
# prettyNum(round(3600*1000/t6_1000[3],0),big.mark = ",")
#
# prettyNum(round(3600*10000/t1_10k[3],0),big.mark = ",")
# prettyNum(round(3600*10000/t3_10k[3],0),big.mark = ",")
# prettyNum(round(3600*10000/t6_10k[3],0),big.mark = ",")
############################################################################### #
