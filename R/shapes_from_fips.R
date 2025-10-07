
############################################################################# #
#  shapes_from_fips  ####
############################################################################# #


#' Download shapefiles based on FIPS codes of States, Counties, Cities/CDPs, Tracts, or Blockgroups (not blocks)
#'
#' @param fips vector of one or more Census FIPS codes such as from [name2fips()]
#'
#' @param myservice_blockgroup URL of feature service to get shapes from,
#'   or "cartographic" or "tiger" to use approx or slow/accurate bounds from tidycensus and tigris packages.
#' @param myservice_tract URL of feature service to get shapes from,
#'   or "cartographic" or "tiger" to use approx or slow/accurate bounds from tidycensus and tigris packages.
#' @param myservice_place only "tiger" is implemented
#' @param myservice_county URL of feature service to get shapes from,
#'   or "cartographic" or "tiger" to use approx or slow/accurate bounds from tidycensus and tigris packages.
#'   Note State bounds are built into this package as data so do not need to be downloaded from a service.
#' @param allow_multiple_fips_types if enabled, set TRUE to allow mix of blockgroup, tract, city, county, state fips
#' @param year passed to [tigris::places()] for bounds or city/town type of fips
#' @details
#'  The functions this relies on should return results in the same order as the input fips,
#'  but will exclude rows for invalid fips, and will also exclude output rows that would
#'  correspond to fips for which boundaries could not be obtained for some reason.
#'  So the output table might not have the same number of rows as the input fips vector.
#'
#' When using tigris package ("tiger" as service-related parameter here),
#' it uses the year that is the default in the version of the tigris package that is installed.
#' You can use options(tigris_year = 2022) for example to specify it explicitly.
#'
#'  Blocks are not implemented yet here. For info on blocks bounds, see  [tigris::block_groups()]
#'  Also note the [blockwts] dataset had a placeholder column block_radius_miles that as of
#'  v2.32.5 was just zero values, but see notes in EJAM/data-raw/datacreate_blockwts.R on how it could be obtained.
#'  If it were used, it could be a way to quickly get the area of each block,
#'  using the formula  area = pi * (block_radius_miles^2)
#'
#'  For zip code boundaries, see the [EJAM documentation](ejanalysis.org/ejamdocs) article on zipcodes.
#'
#' @return spatial data.frame with one row per fips (assuming any fips are valid)
#' @examples
#'  # shp2 = shapes_from_fips("10001", "10005") # Counties not zip codes!
#'
#'  fipslist = list(
#'   statefips = name2fips(c('DE', 'RI')),
#'   countyfips = fips_counties_from_state_abbrev(c('DE')),
#'   cityfips = name2fips(c('chelsea,MA', 'st. john the baptist parish, LA')),
#'   tractfips = substr(blockgroupstats$bgfips[300:301], 1, 12),
#'   bgfips = blockgroupstats$bgfips[300:301]
#'   )
#'   shp <- list()
#'   \donttest{
#'    for (i in seq_along(fipslist)) {
#'     shp[[i]] <- shapes_from_fips(fipslist[[i]])
#'     print(shp[[i]])
#'     # mapfast(shp[[i]])
#'    }
#'   }
#'
#'
#' @export
#'
shapes_from_fips <- function(fips,
                             myservice_blockgroup = "https://services.arcgis.com/P3ePLMYs2RVChkJx/ArcGIS/rest/services/USA_Boundaries_2022/FeatureServer/5/query",
                             myservice_tract      = "https://services.arcgis.com/P3ePLMYs2RVChkJx/ArcGIS/rest/services/USA_Boundaries_2022/FeatureServer/4/query",
                             myservice_place  = 'tiger',
                             myservice_county = 'cartographic',
                             #  myservice_county = "https://services.arcgis.com/P3ePLMYs2RVChkJx/ArcGIS/rest/services/USA_Boundaries_2022/FeatureServer/2/query" # an alternative
                             # myservice_state is built into the package as dataset
                             allow_multiple_fips_types = TRUE,
                             year = 2024
) {

  # preserve original input SORT order ####
  fips <- fips_lead_zero(fips) # or else merge with this will fail later
  original_order <- data.frame(n = seq_along(fips), fips = fips)

  if (offline_cat()) {
    stop("Cannot download boundaries - No internet connection seems to be available.")
    # return(NULL)
  }
  ########################## #
  # validation of input fips types ####

  oktypes <- c("blockgroup", "tract", "city", "county", "state") # NOT block - but maybe we should return at least lat,lon of blocks?

  # in shapes_from_fips() try to either get block bounds via API or substitute a point/circle using blockpoints lat,lon info for block fips ***
  # or else ensure other functions like map_ejam_plus_shp() can handle an empty geometry row better

  suppressWarnings({
    ftype <- fipstype(fips) # NULL or NA or one of oktypes or "block"
  })
  if (is.null(ftype)) {  # this happens if fips is null or length 0 or not vector, e.g.
    if (shiny::isRunning()) {
      shiny::validate("Cannot obtain boundaries of Census units because no fips provided.")
      return(NULL)
    } else {
      warning("Cannot obtain boundaries of Census units because no fips provided.")
      return(NULL)
    }
  }
  ## now confirm they are valid fips -- fipstype() initially just checked if nchar is plausible
  #
  ftype[!fips_valid(fips)] <- NA # say the type is NA now, so "99" which fipstype() reported as ftype <- "state" is now just ftype <- NA

  if (!any( ftype[!is.na(ftype)] %in% oktypes)) {
    if (shiny::isRunning()) {
      shiny::validate("Cannot obtain boundaries of Census units because no valid fips provided or no fips of a valid type.")
      return(NULL) # I think shiny app needs NULL, not empty table
    } else {
      warning("Cannot obtain boundaries of Census units because no valid fips provided or no fips of a valid type.")
      return(shapes_empty_table(fips)) # return one row per fips even though they are all invalid
    }
  }
  if (any(!(ftype[!is.na(ftype)] %in% oktypes))) { # probably only possible if some appear to be blocks
  # if (any(ftype[!is.na(ftype)] %in% 'block')) {
      if (shiny::isRunning()) {
      shiny::validate("Cannot obtain boundaries of some Census units because they are not a supported type.")
        shp_combined <- NULL # but valid types will get appended
    } else {
      warning("Cannot obtain boundaries of some Census units because they are not a supported type.")
      shp_combined <- NULL # but valid types will get appended
    }
  }
  if (allow_multiple_fips_types && length(unique(ftype)) > 1) {
    shp_combined <- NULL
  } else {
    shp_combined <- NULL
    allow_multiple_fips_types <- FALSE
  }
  ########################## #

  options(tigris_use_cache = TRUE) # done in .onAttach() now
  # options(tigris_year = 2022) # uses default of the tigris package version installed

  error_downloading <- function(shp) {
    if (inherits(shp, "try-error")) {
      if (shiny::isRunning()) {
        shiny::validate("unable to obtain Census unit boundaries to map the requested fips codes")
        return(NULL)
      } else {
        # stop("Error in downloading shapefile from API. Check your internet connection and the API URL.")
        warning("Error in downloading some shapefile data from API. Check your internet connection and the API URL.")
        return(TRUE)
      }
    } else {
      return(FALSE)
    }
  }
  ########################### #
  ##                                                  blockgroup ####
  expectedtype <- 'blockgroup'
  if (allow_multiple_fips_types) {
    oktype <- ftype %in% expectedtype & !is.na(ftype)
    if (any(oktype)) {
      x <- try(shapes_blockgroups_from_bgfips(fips[oktype], myservice = myservice_blockgroup), silent = TRUE)
      errx <- error_downloading(x)
      if (is.null(errx)) {return(NULL)} # NULL means it is in a shiny app, which expects this to abort and return NULL if there is any problem
      if (errx) {shp_this <- shapes_empty_table(fips[oktype])} else {shp_this <- x} # if errx, provide NA rows of empty polygon
      shp_combined <- data.table::rbindlist(list(shp_combined, shp_this), fill = TRUE,
                                            ignore.attr = TRUE) # combines with any other types found so far, even if colnames and class (MULTIPOLYGON vs POLYGON) differ
    }
  } else {
    if (all(ftype[!is.na(ftype)] %in% 'blockgroup')) {
      shp_combined <- try(shapes_blockgroups_from_bgfips(fips, myservice = myservice_blockgroup), silent = TRUE)
    }
  }
  ##                                                  tract ####
  expectedtype <- 'tract'
  if (allow_multiple_fips_types) {
    oktype <- ftype %in% expectedtype & !is.na(ftype)
    if (any(oktype)) {
      x <- try(shapes_tract_from_tractfips(fips[oktype], myservice = myservice_tract), silent = TRUE)
      errx <- error_downloading(x)
      if (is.null(errx)) {return(NULL)} # NULL means it is in a shiny app, which expects this to abort and return NULL if there is any problem
      if (errx) {shp_this <- shapes_empty_table(fips[oktype])} else {shp_this <- x} # if errx, provide NA rows of empty polygon
      shp_combined <- data.table::rbindlist(list(shp_combined, shp_this), fill = TRUE,
                                            ignore.attr = TRUE) # combines with any other types found so far, even if colnames and class (MULTIPOLYGON vs POLYGON) differ
    }
  } else {
    if (all(ftype[!is.na(ftype)] %in% 'tract')) {
      shp_combined <- try(shapes_tract_from_tractfips(fips, myservice = myservice_tract), silent = TRUE)
    }
  }
  ##                                                  city ####
  expectedtype <- 'city'
  if (allow_multiple_fips_types) {
    oktype <- ftype %in% expectedtype & !is.na(ftype)
    if (any(oktype)) {
      x <- try(shapes_places_from_placefips(fips[oktype], myservice = myservice_place, year = year), silent = TRUE)
      errx <- error_downloading(x)
      if (is.null(errx)) {return(NULL)} # NULL means it is in a shiny app, which expects this to abort and return NULL if there is any problem
      if (errx) {shp_this <- shapes_empty_table(fips[oktype])} else {shp_this <- x} # if errx, provide NA rows of empty polygon
      shp_combined <- data.table::rbindlist(list(shp_combined, shp_this), fill = TRUE,
                                            ignore.attr = TRUE) # combines with any other types found so far, even if colnames and class (MULTIPOLYGON vs POLYGON) differ
    }
  } else {
    if (all(ftype[!is.na(ftype)] %in% 'city')) {
      shp_combined <- try(shapes_places_from_placefips(fips, myservice = myservice_place, year = year), silent = TRUE)
    }
  }
  ##                                                  county ####
  expectedtype <- 'county'
  if (allow_multiple_fips_types) {
    oktype <- ftype %in% expectedtype & !is.na(ftype)
    if (any(oktype)) {
      x <- try(shapes_counties_from_countyfips(fips[oktype], myservice = myservice_county), silent = TRUE)
      errx <- error_downloading(x)
      if (is.null(errx)) {return(NULL)} # NULL means it is in a shiny app, which expects this to abort and return NULL if there is any problem
      if (errx) {shp_this <- shapes_empty_table(fips[oktype])} else {shp_this <- x} # if errx, provide NA rows of empty polygon
      shp_combined <- data.table::rbindlist(list(shp_combined, shp_this), fill = TRUE,
                                            ignore.attr = TRUE) # combines with any other types found so far, even if colnames and class (MULTIPOLYGON vs POLYGON) differ
    }
  } else {
    if (all(ftype %in% 'county')) {
      shp_combined <- try(shapes_counties_from_countyfips(fips, myservice = myservice_county), silent = TRUE)
    }
  }
  ##                                                  state ####
  expectedtype <- 'state'
  if (allow_multiple_fips_types) {
    oktype <- ftype %in% expectedtype & !is.na(ftype)
    if (any(oktype)) {
      x <- try(shapes_state_from_statefips(fips[oktype]),  silent = TRUE)
      errx <- error_downloading(x)
      if (is.null(errx)) {return(NULL)} # NULL means it is in a shiny app, which expects this to abort and return NULL if there is any problem
      if (errx) {shp_this <- shapes_empty_table(fips[oktype])} else {shp_this <- x} # if errx, provide NA rows of empty polygon
      shp_combined <- data.table::rbindlist(list(shp_combined, shp_this), fill = TRUE,
                                            ignore.attr = TRUE) # combines with any other types found so far, even if colnames and class (MULTIPOLYGON vs POLYGON) differ
    }
  } else {
    if (all(ftype[!is.na(ftype)] %in% 'state')) {
      shp_combined <- try(shapes_state_from_statefips(fips), silent = TRUE)
    }
  }

  ####################### #
  if (!allow_multiple_fips_types) {
    if (length(intersect(ftype, oktypes)) > 1) {
      if (shiny::isRunning()) {
        shiny::validate("This dataset contains more than one type of FIPS code. Analysis can only be run on datasets with one type of FIPS codes.")
        shp_combined <- NULL
      } else {
        stop("This dataset contains more than one type of FIPS code. Analysis can only be run on datasets with one type of FIPS codes.")
      }
    }
    if (length(intersect(ftype, oktypes)) == 0) {
      if (shiny::isRunning()) {
        shiny::validate(paste0("This dataset contains no FIPS codes that are an allowed type. Analysis can only be run on datasets with these types of FIPS codes:",
                        paste0(oktypes, collapse = ",")))
        shp_combined <- NULL
      } else {
        # maybe return an empty table
        warning(paste0("This dataset contains no FIPS codes that are an allowed type. Analysis can only be run on datasets with these types of FIPS codes:",
                       paste0(oktypes, collapse = ",")))
        shp_combined <- shapes_empty_table(fips)
      }
    }
    if (length(intersect(ftype, oktypes)) == 1) {
      errshp <- error_downloading(shp_combined)
      if (is.null(errshp)) {return(NULL)} # NULL means it is in a shiny app, which expects this to abort and return NULL if there is any problem
      if (errshp) {shp_combined <- shapes_empty_table(fips)} else { } # else shp_combined is ok
    }
  }
  ####################### #

  # convert it back into an sf object, since it has been made a non-sf data.table via rbindlist() above
  shp_combined <- sf::st_as_sf(data.table::setDF(shp_combined))
  shp_combined$geometry <- sf::st_cast(shp_combined$geometry) # since some were POLYGON and some MULTIPOLYGON
  ####################### #

  ## restore original input SORT order ####
  ##   original_order <- data.frame(n = seq_along(fips), fips = fips)
  #
  #  note this handles NA fips, duplicated fips in inputs, and fips missing from shp_combined:
  z <- merge(shp_combined, original_order, by.x = "FIPS", by.y = "fips", all.y = TRUE, all.x = FALSE)
  z <- unique(z)
  z <- z[order(z$n), ]
  rownames(z) <- NULL
  return(z)

  # warn if output shp_combined$FIPS do not match input original_order$fips??

  # shp_combined <- shp_combined[1:NROW(shp_combined), ] # see note below
  #
  # NOTE: # somehow that 1:NROW() seemed to help avoid an error msg:
  # x = c(testinput_fips_blockgroups[1:2], testinput_fips_cities)
  # x = shapes_from_fips(x)
  # #sf::st_area(x) # ERROR MSG: Error in CPL_write_wkb(x, EWKB) : Not compatible with requested type: [type=list; target=double].
  # x = x[1:NROW(x), ]
  # sf::st_area(x) # NO ERROR MSG.
}
# .------------------------------------ ####
########################### # ########################### # ########################### # ########################### #

#                                                   states ####

#' Get boundaries of State(s) for mapping
#'
#' @param fips vector of one or more State FIPS codes
#' @seealso [shapes_from_fips()]
#' @return spatial data.frame of boundaries
#'
#' @keywords internal
#'
shapes_state_from_statefips <- function(fips) {

  expectedtype = 'state'

  ftype = fipstype(fips)
  if (all(is.na(ftype))) {
    warning('no valid fips')
    return(NULL)
  }
  if (!all(ftype[!is.na(ftype)] %in% expectedtype)) {
    stop("expected all valid fips to be for", expectedtype)
  }
  fips = fips_lead_zero(fips)
  fips = fips[fips_valid(fips)]
  if (length(fips) == 0) {stop('no valid fips')}

  ## ensure original rows ####
  # original sort order, and ensure NROW(shp) output is same as length(fips) input
  # retain only 1 row per input fips (even if invalid FIPS or valid FIPS lacking downloaded boundaries)
  shp <- states_shapefile[match(fips, states_shapefile$GEOID), ]
  shp$FIPS <- shp$GEOID

  shp <- shapefile_dropcols(shp)
  shp <- shapefile_addcols(shp)
  shp <- shapefile_sortcols(shp)
  return(shp)
}
########################### # ########################### # ########################### # ########################### #

#                                                  counties ####

#' Get Counties boundaries via API, to map them
#'
#' @details Used [sf::read_sf()], which is an alias for [sf::st_read()]
#'   but with some modified default arguments.
#'   read_sf is quiet by default/ does not print info about data source, and
#'   read_sf returns an sf-tibble rather than an sf-data.frame
#'
#'   But note the tidycensus and tigris R packages can more quickly get county boundaries for mapping.
#'
#' @seealso [shapes_from_fips()]
#' @param countyfips FIPS codes as 5-character strings (or numbers) in a vector
#'   as from fips_counties_from_state_abbrev("DE")
#' @param outFields can be "*" for all, or can be
#'   just some variables like SQMI, POPULATION_2020, etc., or none
#' @param myservice URL of feature service to get shapes from
#'   or "cartographic" or "tiger" to use approx or slow/accurate bounds from tidycensus and tigris packages.
#'
#' @return spatial object via [sf::st_read()]
#'
#' @keywords internal
#'
shapes_counties_from_countyfips <- function(countyfips = '10001', outFields = c("NAME", "FIPS", "STATE_ABBR", "STATE_NAME"), # "",
                                            myservice = c(
                                              "https://services.arcgis.com/P3ePLMYs2RVChkJx/ArcGIS/rest/services/USA_Boundaries_2022/FeatureServer/2/query",
                                              "https://services.arcgis.com/P3ePLMYs2RVChkJx/ArcGIS/rest/services/USA_Counties_and_States_with_PR/FeatureServer/0/query",
                                              'cartographic', 'tiger'
                                            )[3]
) {

  acsendyear_carto_tiger = acsendyear()

  # for a vector of  FIPS,
  # was using looped/batched arcgis API to obtain map boundaries of just those census units
  # but faster to use tigris and tidycensus packages

  fips = countyfips

  expectedtype = 'county'

  ftype = fipstype(fips)
  if (all(is.na(ftype))) {
    warning('no valid fips')
    return(NULL)
  }

  if (!all(ftype[!is.na(ftype)] %in% expectedtype)) {
    stop("expected all valid fips to be for", expectedtype)
  }
  fips = fips_lead_zero(fips)
  fips = fips[fips_valid(fips)]
  if (length(fips) == 0) {stop('no valid fips')}

  tidycensus_ok <- TRUE
  if (nchar(Sys.getenv("CENSUS_API_KEY")) == 0) {
    tidycensus_ok <- FALSE
  }
  if (myservice[1] %in% c("cartographic", "tiger") && tidycensus_ok) {
    ## > tidycensus ok ####

    # use tidycensus pkg
    # library(tidycensus)
    # library(tidyverse)

    if (myservice[1] == 'cartographic') {usecb = TRUE}
    if (myservice[1] == 'tiger') {usecb = FALSE}

    options(tigris_use_cache = TRUE) # done in .onAttach() now

    # get_acs() can get all counties for a list of states, or selected counties from 1 state,
    #  but is not able to get just selected counties from more than 1 state in a single function call,
    #  probably since the parameters expect a vector of 3-digit county fips that do not include 2 state digits (or county names without )
    # so we have to
    # a) loop over States here, get just selected counties from 1 state at a time (no)
    # or
    # b) do 1 call to get ALL counties in specified states and then drop unrequested counties (yes)
    #
    # Get ALL counties in each relevant state, then drop unrequested ones

    mystates <- unique(fips2state_fips(fips))
    if ('72' %in% mystates) {warning("cannot map PR")}
    mystates <- setdiff(mystates, "72")

    ## e.g., testing
    # x[ x$label %in% "Estimate!!Total:" & x$geography  %in% "block group",]
    # shp <- get_acs(
    #   geography = "county",
    #   variables = "B01001_001", # B01001_001 is the correct total population estimate.
    #   state = c("44", "10"),
    #   geometry = TRUE,
    #   year = 2022,
    #   show_call = TRUE
    # )

    shp <- tidycensus::get_acs(
      geography = "county",
      variables = "B01001_001", # we do not actually need it here since blockgroupstats has it
      cb = usecb, ## TRUE MEANS FASTER DOWNLOAD BUT LESS ACCURATE
      state = mystates,
      # county =  substr(unique(fips), 3,5), # this function expects county fips to be only the county portion without the 2 state digits
      geometry = TRUE,
      year = as.numeric(acsendyear_carto_tiger),
      survey = 'acs5',
      # key = , # API key would go here
      show_call = TRUE
    )

    # now drop unrequested counties
    shp <- shp[shp$GEOID %in% fips, ] # GEOID is the 5-digit county fips here
    names(shp) <- gsub("GEOID", "FIPS", names(shp))
    drop_comma_statename <- function(countyname_state) {gsub(", .*$", "", countyname_state)}
    shp$NAME <-  drop_comma_statename(fips2countyname(shp$FIPS)) # also done later by fips2name() but ok to leave it like this

    ## STATE_ABBR, STATE_NAME, sqmi, POP_SQMI, pop, etc. all now added by shapefile_addcols()
    ##
    ##  can get these pop variables later:
    ##  now leaving out these 2 columns since pop is just like blockgroupstats data and MOE for county is trivial/NA
    ##  popvarname, 'pop_moe',
    ##  popvarname likely but not necessarily the same as pop from fips2pop() which is ACS 5yr from blockgroupstats
    ##  and pop gets added by shapefile_addcols() now via fips2pop()
    #
    # popvarname = paste0("pop_est_acs5_", substr(acsendyear_carto_tiger, 3, 4))
    # popvarname = "pop_est" # simpler
    # names(shp) <- gsub("estimate", popvarname, names(shp))
    # cat("Population estimate", popvarname, "is from B01001_001 in American Community Survey 5yr survey ending", acsendyear_carto_tiger, " \n")
    # names(shp) <- gsub("moe", "pop_moe", names(shp))

    shp <- shp[ , c('NAME', 'FIPS', 'geometry')]

    # fips was input, shp$FIPS is output column but need to make the sort order like input order
    if (any(sort(shp$FIPS) != sort(fips))) {warning("fips codes found in shapefile of boundaries are not all the same as fips requested")}
    ## ensure original rows ####
    # original sort order, and ensure NROW(shp) output is same as length(fips) input
    # retain only 1 row per input fips (even if invalid FIPS or valid FIPS lacking downloaded boundaries)
    shp <- shp[match(fips, shp$FIPS), ]
    shp$FIPS <- fips # now include the original fips in output even for rows that came back NA / empty polygon

    shp <- shapefile_dropcols(shp)
    shp <- shapefile_addcols(shp)
    shp <- shapefile_sortcols(shp)
    return(shp)

    ################## # ################## # ################## #

    ## NOTES ON NEWER FASTER WAY TO GET COUNTY BOUNDS FOR MAPPING

    ## EJAM:::shapes_counties_from_countyfips
    ## using the API at services.arcgis.com in a loop of 50 counties at a time
    ## was far too slow if you need >50 counties like all US counties.
    ##   e.g.,Might be 5-10 minutes for whole USA???
    ##   API in loop using batches of 50 took 30 seconds to download just 110 counties, as for system.time({shp = EJAM:::shapes_counties_from_countyfips(cfips) })
    ## so now using tidycensus pkg which relies on tigris pkg
    ## which takes about 4 seconds to get all US counties as approximate boundaries.
    ## and maybe 10-30 seconds to get more accurate TIGER/Line shapefiles the first time before cached.
    # https://walker-data.com/tidycensus/articles/spatial-data.html
    # geometry list-column describing the geometry of each feature, using the geographic coordinate system NAD 1983 (EPSG: 4269) which is the default for Census shapefiles.
    ## tidycensus uses the Census cartographic boundary shapefiles for faster processing;
    ## if you prefer the TIGER/Line shapefiles, set cb = FALSE in the function call.

    ################## #
    #            ## using tidycensus pkg
    # library(tidycensus)
    # library(tidyverse)
    # mystates = stateinfo$ST # 50+DC+PR
    # ## checked speeds:
    ## About 1-4 seconds for all counties faster cartographic bounds
    # system.time({
    #   mystates = stateinfo$ST
    #   shp <- get_acs(
    #     cb = TRUE, ## FASTER DOWNLOAD BUT LESS ACCURATE
    #     state = mystates,
    #     #    county =  substr(fips_counties_from_state_abbrev(mystates), 3,5),
    #     geography = "county",
    #     variables = "B01001_001",
    #     geometry = TRUE,
    #     year = 2022
    #   )
    # })
    #
    # ## About 14-25 seconds to DOWNLOAD more accurate TIGER/Line shapefiles the 1st time
    # ## (but once cached, just 3 seconds or sometimes up to 7 seconds)
    # system.time({
    #   mystates = stateinfo$ST
    #   shp_tiger <- get_acs(
    #     cb = FALSE, # more accurate but slower download
    #     state = mystates,
    #     #    county =  substr(fips_counties_from_state_abbrev(mystates), 3,5),
    #     geography = "county",
    #     variables = "B01001_001",
    #     geometry = TRUE,
    #     year = 2022
    #   )
    # })
    ################## # ################## # ################## #

  } else {
    # else:
    ## > tidycensus NOT ok ####
    if (myservice[1] %in% c("cartographic", "tiger") && !tidycensus_ok) {
      # those were requested but failed due to problem with api key or tidycensus package
      warning(paste0("need tidycensus package and census API key to use myservice = '", myservice[1], "', so using default service instead"))
      myservice <- "https://services.arcgis.com/P3ePLMYs2RVChkJx/ArcGIS/rest/services/USA_Boundaries_2022/FeatureServer/2/query"
    }

    if (length(outFields) > 1) {
      outFields <- paste0(outFields, collapse = ",")
    }
    # outFields values:
    # from   https://services.arcgis.com/P3ePLMYs2RVChkJx/ArcGIS/rest/services/USA_Boundaries_2022/FeatureServer/2
    # OBJECTID (type: esriFieldTypeOID, alias: OBJECTID, SQL Type: sqlTypeOther, length: 0, nullable: false, editable: false)
    # NAME (type: esriFieldTypeString, alias: County Name, SQL Type: sqlTypeOther, length: 50, nullable: true, editable: true)
    # STATE_NAME (type: esriFieldTypeString, alias: State Name, SQL Type: sqlTypeOther, length: 20, nullable: true, editable: true)
    # STATE_ABBR (type: esriFieldTypeString, alias: State Abbreviation, SQL Type: sqlTypeOther, length: 2, nullable: true, editable: true)
    # STATE_FIPS (type: esriFieldTypeString, alias: State FIPS, SQL Type: sqlTypeOther, length: 2, nullable: true, editable: true)
    # COUNTY_FIPS (type: esriFieldTypeString, alias: County FIPS, SQL Type: sqlTypeOther, length: 3, nullable: true, editable: true)
    # FIPS (type: esriFieldTypeString, alias: FIPS Code, SQL Type: sqlTypeOther, length: 5, nullable: true, editable: true)
    # POPULATION (type: esriFieldTypeInteger, alias: 2022 Total Population, SQL Type: sqlTypeOther, nullable: true, editable: true)
    # POP_SQMI (type: esriFieldTypeDouble, alias: 2022 Population per square mile, SQL Type: sqlTypeOther, nullable: true, editable: true)
    # SQMI (type: esriFieldTypeDouble, alias: Area in square miles, SQL Type: sqlTypeOther, nullable: true, editable: true)
    # POPULATION_2020 (type: esriFieldTypeInteger, alias: 2020 Total Population, SQL Type: sqlTypeOther, nullable: true, editable: true)
    # POP20_SQMI (type: esriFieldTypeDouble, alias: 2020 Population per square mile, SQL Type: sqlTypeOther, nullable: true, editable: true)
    # Shape__Area (type: esriFieldTypeDouble, alias: Shape__Area, SQL Type: sqlTypeDouble, nullable: true, editable: false)
    # Shape__Length (type: esriFieldTypeDouble, alias: Shape__Length, SQL Type: sqlTypeDouble, nullable: true, editable: false)

    if (length(fips) > 50) {
      ## (loop if over 50 fips) ####
      # The API does let you get >50 at once but instead of figuring out that syntax, this function works well enough
      batchsize <- 50
      batches <- 1 + (length(fips) %/% batchsize)
      # ***  add code here to handle 50 at a time and assemble them
      out <- list()
      for (i in 1:batches) {
        first <- 1 + ((i - 1) * batchsize)
        last <- min(first + batchsize - 1, length(fips))

        out[[i]] <- shapes_counties_from_countyfips(fips[first:last], outFields = outFields, myservice = myservice)

      }
      out <- do.call(rbind, out)
      return(out)
    }

    # > ejscreen service ####
    if (grepl("ejscreen", myservice, ignore.case = TRUE)) {FIPSVARNAME <- "ID"} else {FIPSVARNAME <- "FIPS"}
    myurl <- httr2::url_parse(myservice)
    myurl$query <- list(
      where = paste0(paste0(FIPSVARNAME, "='", fips, "'"), collapse = " OR "),  ########################### #
      outFields = outFields,
      returnGeometry = "true",
      f = "geojson")
    request <- httr2::url_build(myurl)
    shp <- sf::st_read(request) # st_read returns data.frame, read_sf returns tibble

    ### ensure original rows ####
    # original sort order, and ensure NROW(shp) output is same as length(fips) input
    # retain only 1 row per input fips (even if invalid FIPS or valid FIPS lacking downloaded boundaries)
    shp <- shp[match(fips, shp$FIPS), ]
    shp$FIPS <- fips # now include the original fips in output even for rows that came back NA / empty polygon

    shp <- shapefile_dropcols(shp)
    shp <- shapefile_addcols(shp)
    shp <- shapefile_sortcols(shp)
    return(shp)
  }
}
########################### # ########################### # ########################### # ########################### #

#                                                  tracts  ####

#' Get tract boundaries, via API, to map them
#'
#' @details This is useful mostly for small numbers of tracts.
#'   The EJSCREEN map services provide other ways to map tracts and see EJSCREEN data.
#' @param fips one or more FIPS codes as 11-character strings in a vector
#' @param outFields can be "*" for all, or can be
#'   just a vector of variables that particular service provides, like FIPS, SQMI, POPULATION_2020, etc.
#' @param myservice URL of feature service to get shapes from,
#'   (or, but not yet implemented, "cartographic" or "tiger" to use approx or slow/accurate bounds from tidycensus and tigris packages).
#' @seealso [shapes_from_fips()]
#' @return spatial object via [sf::st_read()] # sf-data.frame, not sf-tibble like [sf::read_sf()]
#'
#' @keywords internal
#'
shapes_tract_from_tractfips <- function(fips, outFields = c("FIPS", "STATE_ABBR", "SQMI"),
                                        myservice = c("https://services.arcgis.com/P3ePLMYs2RVChkJx/ArcGIS/rest/services/USA_Boundaries_2022/FeatureServer/4/query",
                                                      "cartographic", "tigris")[1]) {

  if (myservice[1] %in% c("cartographic", "tiger")) {

    # see code in shapes_counties_from_countyfips() to possibly add those options

    warning("only arcgis service supported here for tracts currently, so using that")
    myservice <- "https://services.arcgis.com/P3ePLMYs2RVChkJx/ArcGIS/rest/services/USA_Boundaries_2022/FeatureServer/4/query"
  }

  outFields <- paste0(outFields, collapse = ',')

  if (is.null(myservice)) {
    myservice <- "https://services.arcgis.com/P3ePLMYs2RVChkJx/ArcGIS/rest/services/USA_Boundaries_2022/FeatureServer/4/query"
  }
  expectedtype = 'tract'

  ftype = fipstype(fips)
  if (all(is.na(ftype))) {
    warning('no valid fips')
    return(NULL)
  }
  if (!all(ftype[!is.na(ftype)] %in% expectedtype)) {
    stop("expected all valid fips to be for", expectedtype)
  }
  fips = fips_lead_zero(fips)
  fips = fips[fips_valid(fips)]
  if (length(fips) == 0) {stop('no valid fips')}

  if (length(fips) > 50) {
    ## (loop if over 50 fips) ####
    # The API does let you get >50 at once but instead of figuring out that syntax, this function works well enough
    batchsize <- 50
    batches <- 1 + (length(fips) %/% batchsize)
    # ***  add code here to handle 50 at a time and assemble them
    out <- list()
    for (i in 1:batches) {
      first <- 1 + ((i - 1) * batchsize)
      last <- min(first + batchsize - 1, length(fips))
      out[[i]] <- shapes_tract_from_tractfips(fips[first:last], outFields = outFields, myservice = myservice)
    }
    out <- do.call(rbind, out)
    return(out)
    # warning("Cannot get so many blockgroup shapes in one query, via this API, as coded! Using first 50 only.")
    # fips <- fips[1:50]
  }

  if (grepl("ejscreen", myservice, ignore.case = TRUE)) {FIPSVARNAME <- "ID"} else {FIPSVARNAME <- "FIPS"}
  myurl <- httr2::url_parse(myservice)
  myurl$query <- list(
    where = paste0(paste0(FIPSVARNAME, "='", fips, "'"), collapse = " OR "),  ########################### #
    outFields = outFields,
    returnGeometry = "true",
    f = "geojson")
  request <- httr2::url_build(myurl)
  shp <- sf::st_read(request) # data.frame not tibble

  ## ensure original rows ####
  # original sort order, and ensure NROW(shp) output is same as length(fips) input
  # retain only 1 row per input fips (even if invalid FIPS or valid FIPS lacking downloaded boundaries)
  shp <- shp[match(fips, shp$FIPS), ]
  shp$FIPS <- fips # now include the original fips in output even for rows that came back NA / empty polygon

  shp <- shapefile_dropcols(shp)
  shp <- shapefile_addcols(shp)
  shp <- shapefile_sortcols(shp)
  return(shp)
}
########################### # ########################### # ########################### # ########################### #

#                                                  blockgroups ####

#' Get blockgroups boundaries, via API, to map them
#'
#' @details This is useful mostly for small numbers of blockgroups.
#'   The EJSCREEN map services provide other ways to map blockgroups and see EJSCREEN data.
#' @param bgfips one or more blockgroup FIPS codes as 12-character strings in a vector
#' @param outFields can be "*" for all, or can be
#'   just a vector of variables that particular service provides, like FIPS, SQMI, POPULATION_2020, etc.
#' @param myservice URL of feature service to get shapes from.
#'
#'   "https://services.arcgis.com/cJ9YHowT8TU7DUyn/ArcGIS/rest/services/
#'   EJScreen_2_21_US_Percentiles_Block_Groups/FeatureServer/0/query"
#'
#'   for example provides EJSCREEN indicator values, NPL_CNT, TSDF_CNT, EXCEED_COUNT_90, etc.
#' @seealso [shapes_from_fips()]
#' @return spatial object via [sf::st_read()] # sf-data.frame, not sf-tibble like [sf::read_sf()]
#'
#' @keywords internal
#'
shapes_blockgroups_from_bgfips <- function(bgfips = '010890029222', outFields = c("FIPS", "STATE_ABBR", "SQMI"),
                                           myservice = c(
                                             "https://services.arcgis.com/P3ePLMYs2RVChkJx/ArcGIS/rest/services/USA_Boundaries_2022/FeatureServer/5/query",
                                             "https://services.arcgis.com/P3ePLMYs2RVChkJx/ArcGIS/rest/services/USA_Block_Groups/FeatureServer/0/query", # token required?
                                             "cartographic", "tiger")[1]
) {

  if (myservice[1] %in% c("cartographic", "tiger")) {

    # see code in shapes_counties_from_countyfips()

    warning("only arcgis service supported currently, so using that")
    myservice <- "https://services.arcgis.com/P3ePLMYs2RVChkJx/ArcGIS/rest/services/USA_Boundaries_2022/FeatureServer/5/query"
    # example, all blockgroups in 1 county:
    # "https://services.arcgis.com/P3ePLMYs2RVChkJx/ArcGIS/rest/services/USA_Boundaries_2022/FeatureServer/5/query?where=STCOFIPS%3D10001&objectIds=&geometry=&geometryType=esriGeometryEnvelope&inSR=&spatialRel=esriSpatialRelIntersects&resultType=none&distance=0.0&units=esriSRUnit_Meter&relationParam=&returnGeodetic=false&outFields=*&returnGeometry=false&returnCentroid=false&returnEnvelope=false&featureEncoding=esriDefault&multipatchOption=xyFootprint&maxAllowableOffset=&geometryPrecision=&outSR=&defaultSR=&datumTransformation=&applyVCSProjection=false&returnIdsOnly=false&returnUniqueIdsOnly=false&returnCountOnly=false&returnExtentOnly=false&returnQueryGeometry=false&returnDistinctValues=false&cacheHint=false&collation=&orderByFields=&groupByFieldsForStatistics=&outStatistics=&having=&resultOffset=&resultRecordCount=&returnZ=false&returnM=false&returnTrueCurves=false&returnExceededLimitFeatures=true&quantizationParameters=&sqlFormat=none&f=html&token="
    # "https://services.arcgis.com/P3ePLMYs2RVChkJx/ArcGIS/rest/services/USA_Boundaries_2022/FeatureServer/5/query?where=STCOFIPS%3D10001&outFields=*&returnGeodetic=false"
  }

  outFields <- paste0(outFields, collapse = ',')

  # for a vector of blockgroup FIPS, use arcgis API to obtain map boundaries of just those blockgroups

  fips = bgfips

  expectedtype = 'blockgroup'

  ftype = fipstype(fips)
  if (all(is.na(ftype))) {
    warning('no valid fips')
    # return an empty table? ***
    return(NULL)
  }

  if (!all(ftype[!is.na(ftype)] %in% expectedtype)) {
    stop("expected all valid fips to be for", expectedtype)
  }
  fips = fips_lead_zero(fips)
  fips = fips[fips_valid(fips)]
  if (length(fips) == 0) {warning('no valid fips')} # just warn now?

  if (length(fips) > 50) {
    ## (loop if over 50 fips) ####
    # The API does let you get >50 at once but instead of figuring out that syntax, this function works well enough
    batchsize <- 50
    batches <- 1 + (length(fips) %/% batchsize)
    # ***  add code here to handle 50 at a time and assemble them
    out <- list()
    for (i in 1:batches) {
      first <- 1 + ((i - 1) * batchsize)
      last <- min(first + batchsize - 1, length(fips))
      out[[i]] <- shapes_blockgroups_from_bgfips(fips[first:last], outFields = outFields, myservice = myservice)
    }
    out <- do.call(rbind, out)
    return(out)
    # warning("Cannot get so many blockgroup shapes in one query, via this API, as coded! Using first 50 only.")
    # fips <- fips[1:50]
  }

  if (grepl("ejscreen", myservice, ignore.case = TRUE)) {FIPSVARNAME <- "ID"} else {FIPSVARNAME <- "FIPS"}
  myurl <- httr2::url_parse(myservice)
  myurl$query <- list(
    where = paste0(paste0(FIPSVARNAME, "='", fips, "'"), collapse = " OR "),  ########################### #
    outFields = outFields,
    returnGeometry = "true",
    f = "geojson")
  request <- httr2::url_build(myurl)
  shp <- sf::st_read(request) # data.frame not tibble

  # # ensure all via shapes_from_fips() have a FIPS colname
  if ("GEOID" %in% names(shp) && !("FIPS" %in% names(shp))) {
    shp$FIPS <- shp$GEOID
  }

  ## ensure original rows ####
  # original sort order, and ensure NROW(shp) output is same as length(fips) input
  # retain only 1 row per input fips (even if invalid FIPS or valid FIPS lacking downloaded boundaries)
  shp <- shp[match(fips, shp$FIPS), ]
  shp$FIPS <- fips # now include the original fips in output even for rows that came back NA / empty polygon

  shp <- shapefile_dropcols(shp)
  shp <- shapefile_addcols(shp)
  shp <- shapefile_sortcols(shp)
  return(shp)
}
########################### # ########################### # ########################### # ########################### #


#                                                  places/ cities ####


####################################################### #
## examples
#
# place_st = c("Port Chester, NY", "White Plains, NY", "New Rochelle, NY")
# shp = shapes_places_from_placenames(place_st)
#
# out <- ejamit(shapefile = shp)
# map_shapes_leaflet(shapes = shp,
#                    popup = popup_from_ejscreen(out$results_bysite))
# ejam2excel(out, save_now = F, launchexcel = T)

#   fips = fips_place_from_placename("Port Chester, NY")
# seealso [shapes_places_from_placefips()] [shapes_places_from_placenames()]
#   [fips_place2placename()] [fips_place_from_placename()] [censusplaces]

# also see
#  https://www2.census.gov/geo/pdfs/reference/GARM/Ch9GARM.pdf
#  https://www2.census.gov/geo/pdfs/maps-data/data/tiger/tgrshp2023/TGRSHP2023_TechDoc_Ch3.pdf
#  https://github.com/walkerke/tigris?tab=readme-ov-file#readme
#  https://walker-data.com/census-r/census-geographic-data-and-applications-in-r.html#tigris-workflows
#
# For residential population data (optionally pre-joined to tigris geometries), see the tidycensus package.
# NAD 1983 is what the tigris pkg uses -- it only returns feature geometries for US Census data that default to NAD 1983 (EPSG: 4269) coordinate reference system (CRS).
#   For help deciding on appropriate CRS, see the crsuggest package.

## used by name2fips or fips_from_name
# see https://www2.census.gov/geo/pdfs/reference/GARM/Ch9GARM.pdf
####################################################### #

#' Get shapefiles/ boundaries of census places like cities
#'
#' @param fips vector of 7-digit City/town/CDP codes as in the fips column of the [censusplaces] dataset
#' @param myservice only 'tiger' is implemented as source of boundaries, using the tigris package
#' @param year for [tigris::places()]
#' @seealso [shapes_from_fips()]
#' @return spatial data.frame for mapping
#'
#' @keywords internal
#'
shapes_places_from_placefips <- function(fips, myservice = 'tiger', year = 2024) {

  expectedtype <- 'city'

  # handle invalid fips ####
  suppressWarnings({
    fips <- fips_lead_zero(fips)        # we want this even though it gets done again within fipstype() and fips_valid()
    ftype <- fipstype(fips)             # we want this even though it does fips_lead_zero() again
    ok <- fips_valid(fips)
    validfips <- fips[ok] # we want this even though it does fips_lead_zero() and fipstype() again
  })
  # if ALL fips are invalid
  if (all(!ok) || length(validfips) == 0 || length(fips) == 0) { # valid is stricter than is.na(fipstype(fips)), since those NA fipstype are always called invalid.
    warning('no valid fips')
    return(shapes_empty_table(fips[!ok]))
  }
  # if at least some are valid, but valid ones are not all of this 1 expected type like "city"
  #
  if (!all(ftype[fips %in% validfips] %in% expectedtype)) {
    # if any are an unexpected type, like not "city" when expecting "city",
    # maybe want to return all rows but only fill in the ones of expected type?
    stop("expected all valid fips to be for ", expectedtype)
  }

  ST <- unique(fips2state_abbrev(fips[ok])) # added later by shapefile_addcols() but needed here to download right states



  # >>> should check if census api key available, if needed for tiger *** ####



  # Downloads ALL places in relevant STATES...  and last step will drop unrequested places
  if (myservice[1] == 'tiger') {
    shp <- tigris::places(na.omit(ST), year = year)
  } else {
    warning('other sources of boundaries not implemented, so using default')
    shp <- tigris::places(na.omit(ST), year = year)
  }

  # # ensure all via shapes_from_fips() have a FIPS colname
  if ("GEOID" %in% names(shp) && !("FIPS" %in% names(shp))) {
    shp$FIPS <- shp$GEOID
  }
  ## ensure original rows ####
  # original sort order, and ensure NROW(shp) output is same as length(fips) input
  # retain only 1 row per input fips (even if invalid FIPS or valid FIPS lacking downloaded boundaries)
  shp <- shp[match(fips, shp$FIPS), ]
  shp$FIPS <- fips # now include the original fips in output even for rows that came back NA / empty polygon

  shp <- shapefile_dropcols(shp)
  shp <- shapefile_addcols(shp)
  shp <- shapefile_sortcols(shp)
  rownames(shp) <- NULL
  return(shp)
}
####################################################### #

## NOT USED

shapes_places_from_placenames <- function(place_st, year = 2024) {

  # name2fips()  uses fips_place_from_placename()

  ## input here is in the format of place_st as is created from the censusplaces table
  ##   columns  placename  and ST field
  ##   so it has lower case "city" for example like "Denver city" or "Funny River CDP"
  ## which is sometimes slightly different than found in TIGRIS places table
  ##  column NAMELSAD   and stateabbrev ST would be based on STATEFP field
  ## and "NAMELSAD' differs from the "NAME" column (e.g., Hoboken vs Hoboken city)

  # place_st = c('denver city, co',  "new york city, ny" )

  fips = fips_place_from_placename(place_st)  # get FIPS of each place

  ftype = fipstype(fips)
  if (all(is.na(ftype))) {
    warning('no valid fips')
    return(NULL)
  }
  fips = fips_lead_zero(fips)
  fips = fips[fips_valid(fips)]
  if (length(fips) == 0) {stop('no valid fips')}

  st = censusplaces$ST[match(as.integer(fips), censusplaces$fips)]
  # as.numeric since not stored with leading zeroes there !

  tp = tigris::places(unique(st), year = year)  # DOWNLOAD THE BOUNDARIES of all places in an ENTIRE STATE, for EACH STATE REQUIRED HERE
  shp = tp[match(fips, tp$GEOID), ] # use FIPS of each place to get boundaries

  shp <- shapefile_dropcols(shp)
  shp <- shapefile_addcols(shp)
  shp <- shapefile_sortcols(shp)
  return(shp)
}
####################################################### #
# .------
# empty table if all fips invalid ####

# helper to return spatial data.frame of empty polygons, 1 per input fips,
# same shape as one possible output of shapes_from_fips() and its helpers like shapes_tract_from_tractfips()
# based on structure of normal output of shapes_places_from_placefips() specifically,
# as is done for anytime 1 or some or all rows are invalid fips

shapes_empty_table <- function(fips) {

  empty_polygon_template <-structure(list(
    STATEFP = NA_character_, PLACEFP = NA_character_, PLACENS = NA_character_, GEOID = NA_character_, GEOIDFQ = NA_character_,
    NAME = NA_character_, NAMELSAD = NA_character_, LSAD = NA_character_, CLASSFP = NA_character_, PCICBSA = NA_character_, MTFCC = NA_character_,
    FUNCSTAT = NA_character_, ALAND = NA_real_, AWATER = NA_real_, INTPTLAT = NA_character_, INTPTLON = NA_character_,
    geometry = structure(
      list(structure(list(), class = c("XY", "MULTIPOLYGON", "sfg"))),
      class = c("sfc_MULTIPOLYGON", "sfc"), precision = 0,
      bbox = structure(c(xmin = NA_real_, ymin = NA_real_, xmax = NA_real_, ymax = NA_real_), class = "bbox"),
      crs = structure(list(
        input = "NAD83",
        wkt = "GEOGCRS[\"NAD83\",\n    DATUM[\"North American Datum 1983\",\n        ELLIPSOID[\"GRS 1980\",6378137,298.257222101,\n            LENGTHUNIT[\"metre\",1]]],\n    PRIMEM[\"Greenwich\",0,\n        ANGLEUNIT[\"degree\",0.0174532925199433]],\n    CS[ellipsoidal,2],\n        AXIS[\"latitude\",north,\n            ORDER[1],\n            ANGLEUNIT[\"degree\",0.0174532925199433]],\n        AXIS[\"longitude\",east,\n            ORDER[2],\n            ANGLEUNIT[\"degree\",0.0174532925199433]],\n    ID[\"EPSG\",4269]]"),
        class = "crs"), n_empty = 1L),
    FIPS = NA_character_
  ), sf_column = "geometry",
  agr = structure(
    c(STATEFP = NA_integer_, PLACEFP = NA_integer_, PLACENS = NA_integer_,
      GEOID = NA_integer_, GEOIDFQ = NA_integer_, NAME = NA_integer_, NAMELSAD = NA_integer_,
      LSAD = NA_integer_, CLASSFP = NA_integer_, PCICBSA = NA_integer_, MTFCC = NA_integer_, FUNCSTAT = NA_integer_,
      ALAND = NA_integer_, AWATER = NA_integer_, INTPTLAT = NA_integer_, INTPTLON = NA_integer_,
      FIPS = NA_integer_),
    levels = c("constant", "aggregate", "identity"), class = "factor"),
  tigris = "place", row.names = "NA", class = c("sf", "data.frame"))
  # create an output table where NROW() is length of fips vector, but entries are NA values except the FIPS column
  empty_polygons_table <- empty_polygon_template[1:length(fips), ]
  empty_polygons_table$FIPS <- fips

  empty_polygons_table <- shapefile_dropcols(empty_polygons_table)
  empty_polygons_table <- cbind(empty_polygons_table, STATE_ABBR = NA, STATE_NAME = NA, SQMI = NA, POP_SQMI = NA)
  # empty_polygons_table <- shapefile_addcols(empty_polygons_table)  #   would try to calculate and add STATE_ABBR, STATE_NAME, SQMI, POP_SQMI
  empty_polygons_table <- shapefile_sortcols(empty_polygons_table)
  return(empty_polygons_table)
}
####################################################### #
# add, drop, reorder columns of sf ####
################## # ################## # ################## #


# utility to drop some less useful columns from spatial data.frame

# eg,
# shp <- shapefile_dropcols(shp)
# shp <- shapefile_addcols(shp)
# shp <- shapefile_sortcols(shp)

shapefile_dropcols <- function(shp,
                               dropthese = c('STATEFP', 'PLACEFP', 'PLACENS', 'GEOID', 'GEOIDFQ',
                                             'REGION' ,'DIVISION' , 'STATENS', 'STUSPS' ,
                                             'LSAD', 'CLASSFP', 'PCICBSA', 'MTFCC', 'FUNCSTAT',
                                             'ALAND', 'AWATER', 'INTPTLAT', 'INTPTLON')
) {
  # drop less useful columns
  shp[, setdiff(colnames(shp), dropthese)]
}
################## # ################## # ################## #

# utility to add some useful columns to spatial data.frame

# eg,
# shp <- shapefile_dropcols(shp)
# shp <- shapefile_addcols(shp)
# shp <- shapefile_sortcols(shp)

shapefile_addcols <- function(shp, addthese = c('fipstype', 'pop', 'NAME', 'STATE_ABBR', 'STATE_NAME', 'SQMI', 'POP_SQMI'),
                              fipscolname = "FIPS", popcolname = "pop", overwrite = FALSE) {
  if (!overwrite) {
    # could warn that user asked to add one that is already there but overwrite is FALSE so it will not get recalculated
    if (length(intersect(addthese, colnames(shp))) > 0) {
      ## not really useful msg
      # message("These already exist and will not be overwritten since overwrite=FALSE: ", paste0(intersect(addthese, colnames(shp)), collapse=", "))
    }
    addthese <- setdiff(addthese, colnames(shp))
  }

  # figure out the FIPS column, get it as a vector
  if (fipscolname %in% colnames(shp)) {
    fipsvector <- as.vector(sf::st_drop_geometry(shp)[, fipscolname]) # fipscolname was found
  } else {
    if ("fips" %in% fipscolname) {
      fipsvector <- as.vector(sf::st_drop_geometry(shp)[, 'fips']) # use "fips" lowercase since cant find fipscolname
    } else {
      if ("fips" %in% fixnames_aliases(colnames(shp))) {  # use 1st column that is an alias for fips
        warning(fipscolname, "is not a column name in shp, so using a column that seems to be an alias for FIPS")
        fipsvector <- as.vector(sf::st_drop_geometry(shp)[, which(fixnames_aliases(colnames(shp)) == "fips")[1]])
      } else {
        warning("cannnot find a column that can be identified as the FIPS, so using NA for columns like STATE_ABBR or STATE_NAME")
        fipsvector <- rep(NA, nrow(shp)) # NA for all rows
      }
    }
  }
  suppressWarnings({
    ftype <- fipstype(fipsvector)
  })
  if ('fipstype' %in% addthese) {
    suppressWarnings({
      shp$fipstype <- fipstype(fipsvector) # NA if fips is NA
    })
  }
  if ('NAME' %in% addthese) {
    suppressWarnings({
      shp$NAME <- fips2name(fipsvector) # NA if fips is NA
    })
  }
  if ('STATE_ABBR' %in% addthese) {
    suppressWarnings({
      shp$STATE_ABBR <- fips2state_abbrev(fipsvector) # NA if fips is NA
    })
  }
  if ('STATE_NAME' %in% addthese) {
    suppressWarnings({
      shp$STATE_NAME <- fips2statename(fipsvector) # NA if fips is NA
    })
  }
  if ('pop' %in% addthese) {
    suppressWarnings({
      shp$pop <- fips2pop(fipsvector) # NA for city type
    })
  }
  if ('SQMI' %in% addthese) {
    shp$SQMI <- area_sqmi_from_fips(fipsvector, download_city_fips_bounds = FALSE, download_noncity_fips_bounds = FALSE)
    shp$SQMI[ftype %in% "city" & !is.na(ftype)] <- area_sqmi_from_shp(shp[ftype %in% "city" & !is.na(ftype), ]) # *** check the numbers
    shp$SQMI <- round(shp$SQMI, 2)
  }

  if ('POP_SQMI' %in% addthese) {
    if ('SQMI' %in% colnames(shp)) {
      sqmi = shp$SQMI
    } else {
      sqmi = area_sqmi_from_shp(shp)
    }
    if (popcolname %in% colnames(shp)) {
      pop = as.vector(sf::st_drop_geometry(shp)[, popcolname])
      shp$POP_SQMI <- ifelse(sqmi == 0, NA, pop / sqmi)
      shp$POP_SQMI <- round(shp$POP_SQMI, 2)
    } else {
      warning("Cannot find a column that can be identified as the population, so using NA for POP_SQMI")
      shp$POP_SQMI <- NA
    }
  }

  return(shp)
}
################## # ################## # ################## #

# eg,
# shp <- shapefile_dropcols(shp)
# shp <- shapefile_addcols(shp)
# shp <- shapefile_sortcols(shp)


shapefile_sortcols <- function(x,
                               putfirst = c("FIPS", "fipstype", "NAME", "ST", "STATE_ABBR", "STATE_NAME", "pop", "pop_est", "pop_moe", "SQMI", "POP_SQMI"),
                               putlast = c("geometry")) {

  x <- relocate(x, intersect(putfirst, names(x)), .before = 1)
  x <- relocate(x, intersect(putlast, names(x)), .after = last_col())
  return(x)
}
################## # ################## # ################## #

shapefile_sortcols2 = function(x,
                               putfirst = c("FIPS", "fipstype", "NAME", "ST", "STATE_ABBR", "STATE_NAME", "pop", "pop_est", "pop_moe", "SQMI", "POP_SQMI"),
                               putlast = c("geometry")) {

  x[, c(intersect(putfirst, names(x)), setdiff(names(x), c(putfirst, putlast)), intersect(putlast, names(x)))]
}
