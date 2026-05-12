
#' Find all blocks within each of the FIPS codes provided
#'
#' Allows EJAM to analyze and compare Counties, for example
#'
#' @param fips vector of FIPS codes identifying blockgroups, tracts, counties, or states.
#'   This is useful if -- instead of getting stats on and comparing circular buffers or polygons --
#'    one will be getting stats on one or more tracts,
#'   or analyzing and comparing blockgroups in a county,
#'   or comparing whole counties to each other, within a State.
#' @param in_shiny used by shiny app server code to handle errors via [shiny::validate()] instead of [stop()]
#' @param need_blockwt set to FALSE to speed it up if you do not need blockwt
#' @param return_shp set to TRUE to get a named list, pts and polys, that are
#'   a sites2blocks table in [data.table](https://r-datatable.com) format and a spatial data.frame, respectively,
#'   or FALSE to get the pts table in [data.table](https://r-datatable.com) format
#'   much like output of [getblocksnearby()] or  [get_blockpoints_in_shape()]
#' @param allow_multiple_fips_types if enabled, set TRUE to allow mix of blockgroup, tract, city, county, state fips
#'
#' @param radius CURRENTLY NOT IMPLEMENTED - NO BUFFER IS ADDED
#'
#' @return
#' - if return_shp = FALSE, returns just a sites2blocks table in [data.table](https://r-datatable.com) format with colnames ejam_uniq_id, blockid, distance, blockwt, bgid, fips.
#'  This is like the [getblocksnearby()] and [get_blockpoints_in_shape()] outputs.
#'
#' - if return_shp = TRUE, returns a named list where pts is the table in [data.table](https://r-datatable.com) format of sites2blocks,
#'   and polys is the spatial data.frame with one row per input fips (including invalid ones).
#'
#'   The ejam_uniq_id represents which of the input sites is being referred to, and the table
#'   will only have the ids of the sites where blocks were found. If 10 sites were input but only sites 5 and 8
#'   were valid and had blocks identified, then the data.table here will only include ejam_uniq_id values of 5 and 8.
#'
#' @examples
#'   x <- getblocksnearby_from_fips(fips_counties_from_state_abbrev("DE"))
#'   y <- doaggregate(x)
#'   z <- ejamit(fips = fips_counties_from_statename("Delaware"))
#'
#'   # x2 <- getblocksnearby_from_fips("482011000011") # one blockgroup only
#'   # y2 <- doaggregate(x2)
#' @seealso [getblocksnearby()] [fips_bgs_in_fips()] [fips_lead_zero()] [getblocksnearby_from_fips()] [fips_from_table()]
#'
#' @export
#'
getblocksnearby_from_fips <- function(fips, in_shiny = FALSE, need_blockwt = TRUE,
                                      return_shp = FALSE, allow_multiple_fips_types = TRUE,
                                      radius = 0) {

  if (!is.null(radius) && radius > 0 && radius != 999) {
    warning("adding buffer around fips is not yet implemented")
  }
  ## NOTE       getblocksnearby_from_fips()           was using fips as the output ejam_uniq_id but now will use 1:NROW() like other getblock... functions do
  ## AND NOW,   getblocksnearby_from_fips_noncity()   same
  ## AND NOW,   getblocksnearby_from_fips_cityshape() same

  suppressWarnings({
    fips <- fips_lead_zero(fips)  # adds leading zeroes and returns as character, 5 characters if seems like countyfips, etc.
  })
  ##  > SORT order of input fips is saved including invalid fips input ####
  # create an overall ejam id, and note the ejam_uniq_id in each of the helpers will be a different count of 1:A and 1:B for the cityshape and noncity cases!
  original_order <- data.table(ejam_uniq_id = seq_along(fips), fips = fips)
  suppressWarnings({
    ok <- fips_valid(fips)
    original_order$ok <- ok
  })
  suppressWarnings({
    # If some fips are city and others not, use approp method for each, then combine and re-sort
    ftype <- fipstype(fips)
  })
  ftype_city <- ftype %in% "city"
  ftype_city[is.na(ftype) & ok] <- FALSE               ## -------------- Drop  invalids from the city type list
  ftype_noncity <- !ftype_city #  & !is.na(ftype) & ok ## -------------- pass invalid ones as noncity so that getblocksnearby_from_fips_noncity() can include invalids as rows in the polys shp table.

  # what if none valid at all? ***
  if (any((ftype_city))) {
    # these need shapefile download - pass all incl invalid to get back $polys table with rows for invalids
    output_city <- getblocksnearby_from_fips_cityshape(fips = fips[ftype_city ],
                                                       return_shp = return_shp)
    # NULL IF NONE RETURNED AT ALL
  } else {
    output_city <- NULL
  }
  if (any((ftype_noncity))) {
    # these do not need shapefile download unless return_shp=T,
    # else just using FIPS code since blockgroups aggregate into tracts then counties then states
    output_noncity <- getblocksnearby_from_fips_noncity(fips[ftype_noncity ],
                                                        return_shp = return_shp,
                                                        in_shiny = in_shiny,
                                                        need_blockwt = need_blockwt,
                                                        allow_multiple_fips_types = allow_multiple_fips_types)
    # NULL IF NONE RETURNED AT ALL
  } else {
    output_noncity <- NULL
  }

  # Combine city/noncity, and SORT AGAIN in same order as original input fips, in case it was a mix of city and noncity fips
  ## each part of s2b table (city and noncity) is already in correct sort order at this point, but need to sort overall now,
  # using  fips[ftype_city] and fips[!ftype_city] and original_order

  original_order[             , ftype_city := ftype_city]
  original_order[   ftype_city, id_among_subset := .I] # 1:N just among the city subset
  original_order[ftype_noncity, id_among_subset := .I] # 1:N just among the non-city subset
  original_order[             , id_overall := ejam_uniq_id]

  ####################################### #
  # ~ ####
  # return_shp = TRUE ####
  if (return_shp) {

    ###  1a. use id_overall as new ejam_uniq_id value for s2b ####

    if (!is.null(output_city)) {
      output_city$pts[, id_among_subset := ejam_uniq_id]
      output_city$pts[original_order[ ftype_city, ], ejam_uniq_id := id_overall, on = "id_among_subset"]
      output_city$pts[, id_among_subset := NULL]
    }
    if (!is.null(output_noncity)) {
      output_noncity$pts[, id_among_subset := ejam_uniq_id]
      output_noncity$pts[original_order[!ftype_city, ], ejam_uniq_id := id_overall, on = "id_among_subset"]
      output_noncity$pts[, id_among_subset := NULL]
    }

    ##  1b. use id_overall for spatial data.frame ####
    #     in output_city$polys, output_noncity$polys
    if (!is.null(output_city)) {
      output_city$polys$ejam_uniq_id    <- original_order$ejam_uniq_id[ ftype_city]
    }
    if (!is.null(output_noncity)) {
      output_noncity$polys$ejam_uniq_id <- original_order$ejam_uniq_id[!ftype_city]
    }

    ##  2. combine city & noncity ####
    if (is.null(output_city) && is.null(output_noncity)) {
      pts = data.table(ejam_uniq_id = integer(0), blockid = character(0),
                       distance = numeric(0), blockwt = numeric(0), bgid = character(0), fips = character(0))
      polys = sf::st_as_sf(data.frame(FIPS = original_order$fips, fipstype=fipstype(original_order$fips),
                                      NAME=NA, STATE_ABBR=NA, STATE_NAME=NA,  pop= NA,   SQMI=NA, POP_SQMI=NA, n = 1:length(original_order$fips),
                                      ejam_uniq_id = original_order$ejam_uniq_id,
                                      geometry = sf::st_sfc(NA)))
      # c('FIPS', 'fipstype', 'NAME', 'STATE_ABBR' ,'STATE_NAME' , 'pop'  , 'SQMI', 'POP_SQMI' ,'n' ,'ejam_uniq_id', 'geometry')
      output <- list(polys = polys, pts = pts)
    } else {
      output <- list()
      ##    use rbindlist() to combine spatial data.frames that do not all have the same columns:
      output$polys <- data.table::rbindlist(list(output_city$polys, output_noncity$polys), fill = TRUE,
                                            ignore.attr=TRUE) # no longer "sf" class after rbindlist()
      output$polys <- sf::st_as_sf(data.table::setDF(output$polys)) # convert back to sf class
      output$pts   <- rbind(output_city$pts,   output_noncity$pts)

      ##  3a. sort s2b ####
      ## sort pts data.table using data.table syntax, in same order as original inputs were:
      # now that overall ejam_uniq_id is here, sort on that, since it was just 1:N
      setorder(output$pts, ejam_uniq_id, blockid)

      ##  3b. sort spatial data.frame ####
      # sort  ejam_uniq_id which now is original overall  1:NROW
      output$polys <- output$polys[order(output$polys$ejam_uniq_id), ]
    }
  }
  ####################################### #
  # ~ ####
  # return_shp = FALSE ####

  if (!return_shp) {

    # each is just a data.table of s2b like pts

    ###  1. use id_overall as new ejam_uniq_id value for s2b ####

    if (!is.null(output_city)) {
      output_city[, id_among_subset := ejam_uniq_id]
      output_city[original_order[ ftype_city, ], ejam_uniq_id := id_overall, on = "id_among_subset"]
      output_city[, id_among_subset := NULL]
    }
    if (!is.null(output_noncity)) {
      output_noncity[, id_among_subset := ejam_uniq_id]
      output_noncity[original_order[!ftype_city, ], ejam_uniq_id := id_overall, on = "id_among_subset"]
      output_noncity[, id_among_subset := NULL]
    }

    ##  2. combine city & noncity ####
    if (is.null(output_city) && is.null(output_noncity)) {
      output <- data.table(ejam_uniq_id = integer(0), blockid = character(0),
                           distance = numeric(0), blockwt = numeric(0), bgid = character(0), fips = character(0))
    } else {
      ##    use rbindlist() to combine spatial data.frames that do not all have the same columns:
      output <- data.table::rbindlist(list(output_city, output_noncity), fill = TRUE,
                                      ignore.attr=TRUE)
      ##  3. sort s2b ####
      # sort data.table using data.table syntax, in same order as original inputs were:
      # now that overall ejam_uniq_id is here, sort on that, since it was just 1:N
      setorder(output, ejam_uniq_id)
    }
  }
  return(output)
}
######################################## #  ######################################## #
# ~ ####
# helper used by getblocksnearby_from_fips()

getblocksnearby_from_fips_cityshape <- function(fips, return_shp = FALSE) {

  ##  > SORT order of input fips is saved including invalid fips input ####
  #   $poly spatial data.frame needs a row for every input fips (or would need to get filled back in)

  original_order <- data.table(fips = fips, n = seq_along(fips))

  ## > DONT DROP INVALID FIPS  ####

  suppressWarnings({
    ok <- fips_valid(fips)
    original_order$ok <- ok
    fips <- fips_lead_zero( fips)  # adds leading zeroes and returns as character, 5 characters if seems like countyfips, etc.
    ##  if none valid at all, shapes_places_from_placefips() crashes if given character(0)
    # fips <- fips[ok]  # # ----------------------------------- ***
  })
  ## Get POLYGONS of city fips ####
  # this returns a row for each input fips, even if no shape available:# preserves exact order -  and includes NAs in output if NAs in input
  suppressWarnings({
    polys <- shapes_places_from_placefips(fips)
  })
  ## Get BLOCKS in each polygon ####
  suppressWarnings({
    s2b_pts_polys <- get_blockpoints_in_shape(polys = polys) #   Sorted by 1:N ejam_uniq_id, with multiple rows each
  })
  ## s2b_pts_polys$polys is a spatial df with FIPS character like fips, and ejam_uniq_id is 1:nrow integer class (since the input is polygons not fips codes)
  ## s2b_pts_polys$pts is a data.table with no fips field, and   ejam_uniq_id is integer class but will omit rows with no blocks

  # > in s2b, DROP FIPS IF NO BLOCKS FOUND ####
  s2b_pts_polys$pts <- s2b_pts_polys$pts[!is.na(blockid), ] # redundant?

  ## > ALREADY SORTED output s2b ####
  ### setorder(s2b_pts_polys$pts, ejam_uniq_id, blockid) # or use original_order ?
  # table of block points is already sorted, and has many rows (blocks) per fips
  # table of polygons is also already sorted, and has 1 row per fips

  s2b_pts_polys$pts[s2b_pts_polys$polys, fips := FIPS, on = "ejam_uniq_id"]
  s2b_pts_polys$pts[, lat := NULL]
  s2b_pts_polys$pts[, lon := NULL]

  if (return_shp) {
    return(s2b_pts_polys) # named list with pts and polys tables
  } else {
    return(s2b_pts_polys$pts) # multiple rows per fips, but the order of fips was preserved, with no row for fips with no bounds avail.
  }
  ## example/test
  # fips = c(4975360, 4262056, 4958070) # 1 of those 3 has no bounds avail.
  # mapview::mapview( shapes_from_fips(fips))
}
######################################## #  ######################################## #
# ~ ####

# helper used by getblocksnearby_from_fips()

getblocksnearby_from_fips_noncity <- function(fips, return_shp = FALSE, in_shiny = FALSE, need_blockwt = TRUE, allow_multiple_fips_types = TRUE) {

  if (!exists('blockid2fips')) {dataload_dynamic(varnames = 'blockid2fips')} # *** will drop need for this
  if (!exists('bgid2fips')) {dataload_dynamic(varnames = 'bgid2fips')}

  ##  > SORT order of input fips is saved including invalid fips input ####
  original_order <- data.table(fips = fips, n = seq_along(fips))

  ## > DROP INVALID FIPS? ####

  suppressWarnings({
    ok <- fips_valid(fips)
    original_order$ok <- ok
    fips <- fips[ok]# # ----------------------------------- ***
    # what if none valid at all? ***
    fips <- fips_lead_zero( fips)  # adds leading zeroes and returns as character, 5 characters if seems like countyfips, etc.
  })
  ######################################## #
  # unlike getblocksnearby_from_fips(), for now this function needs all fips to be the same type, like all "county", not a mix of county and city
  #
  if (!allow_multiple_fips_types) {
    suppressWarnings({ftypes <- fipstype(fips)})
    if (length(unique(ftypes)) != 1) {
      if (in_shiny) {
        validate('noncity fips must all be same number of characters, like all are 5-digit county fips with leading zeroes counted')
      } else {
        stop('noncity fips must all be same number of characters, like all are 5-digit county fips with leading zeroes counted')
      }}
    #  see   fipstype() function.
  }
  fips_vec <- fips
  names(fips_vec) <- fips
  ######################################## #  ######################################## #

  ## Get BLOCKGROUPS in each fips ####

  ######################################## #
  ### Get bgfips:

  suppressWarnings({
    ######################################## #
    ## create two-column dataframe with bgs (values. bgfips or just bgid) and original fips (ind)

    # notes:
    #   fips_bgs_in_fips1() returns all blockgroup fips codes contained within each fips provided
    #   fips_bgs_in_fips() replaces fips_bgs_in_fips1() ? which is faster?
    #   all_bgs <- stack(sapply(fips_vec, fips_bgs_in_fips)) # newer - fast alone but slow in sapply?
    ######################################## #
    # SLOW -- e.g. 1.4 seconds for all counties in region 6
    # *** It would be more efficient to avoid fips_bgs_in_fips1()
    #     to use a new func to provide bgid_from_anyfips()
    #     instead of 1st getting bgfips and then needing to look up bgid by bgfips.
    # We should switch to doing it all this way:
    #      use fips_bgs_in_fips() to get all bgfips values in each of the bg/tract/county/state fips codes analyzed (which does fips_lead_zero() and fipstype() and uses blockgroupstats)
    #      use join to blockgroupstats on bgfips, to get all bgid values
    #  OR use a variation on
    #      use join to blockwts on bgid, to get all the blockid values.
    ######################################## #

    all_bgs <- lapply(fips_vec, fips_bgs_in_fips1)  ## we could replace this with a new
    oknow <- !sapply(all_bgs, is.null)
    all_bgs   <- all_bgs[oknow]   # drop input fips that had no bgs found
    fips_vec <- fips_vec[oknow] # ditto
    if (all(sapply(all_bgs, is.null))) {
      # every element of named list is NULL meaning no bgs found for any input fips, so cannot do stack()
      all_bgs <- data.frame(bgfips = character(0), fips = character(0), stringsAsFactors = FALSE)
    } else {
      names(all_bgs) <- fips_vec
      all_bgs <- stack(all_bgs)      # *** Note stack() drops all NA fips.  stack() seems slow here
    }
  })
  names(all_bgs) <- c('bgfips', 'fips')
  ##### get ejam_uniq_id taking into account any invalid fips removed
  setDT(all_bgs)
  all_bgs[original_order, ejam_uniq_id := n, on = "fips"]
  all_bgs$fips <- as.character(all_bgs$fips) # because stack() always creates a factor column. data.table might have a faster reshaping approach? ***

  ######################################## #
  ### Get bgid:

  all_bgs[bgid2fips, bgid := bgid, on = "bgfips"]  # we can just convert fips to bgid via blockgroupstats and avoid using bgid2fips?

  if (NROW(all_bgs) == 0) {
    if (in_shiny) {
      shiny::validate('No blockgroups found for noncity (or invalid) FIP codes.')
      return(NULL)
    } else {
      cat('No blockgroups found for noncity (or invalid) FIP codes.\n') # maybe  give a warning so that mix of valid city and no valid noncity can continue
      return(NULL)
    }
  } else {
    ######################################## #  ######################################## #

    ## Get BLOCKS in each blockgroup ####

    suppressMessages({
      setDF(all_bgs)
      fips_blockpoints <- dplyr::left_join(all_bgs,
                                           ## create 12-digit column inline (original table not altered)
                                           ## do not actually need blockfips here except to join on its first 12 chars *** try to remove need for large blockid2fips file (and/or store fips as integer?)
                                           blockid2fips[, .(blockid, blockfips, blockfips12 = substr(blockfips,1,12))],
                                           by = c('bgfips' = 'blockfips12'), multiple = 'all') |>
        dplyr::left_join(blockpoints) |>
        dplyr::mutate(distance = 0) |>     # or do I want distance to be null, or missing or NA or 0.001, or what? note approximated block_radius_miles is sometimes zero, in blockwts
        data.table::as.data.table()        # makes it a data.table
    })
    if (need_blockwt) {
      # provide blockwt to be consistent with getblocksnearby() and doaggregate() understands it if you want to use it after this.
      # fips_blockpoints[, blockwt := 1] # since doaggregate() uses blockwt even though we know the resulting bgwt will be 1 in every case if used FIPS codes bigger than blocks (blockgroups, tracts, counties, states, whatever)
      fips_blockpoints <- merge(fips_blockpoints, blockwts[, .(blockid, blockwt)], by = "blockid") # may not be needed for noncity case (all blocks of bg are always there)
    }
    # Emulate the normal output of  getblocksnearby() which is a data.table with
    #   ejam_uniq_id, blockid, distance, blockwt, bgid
    #   but do not really need to return bgfips, blockfips, lat, lon here.
    setcolorder(fips_blockpoints, c('ejam_uniq_id', 'blockid', 'distance', 'blockwt', 'bgid'))
    fips_blockpoints[ , bgfips := NULL]
    fips_blockpoints[ , blockfips := NULL]
    fips_blockpoints[ , lat := NULL]
    fips_blockpoints[ , lon := NULL]
    ######################################## #  ######################################## #

    ## > in s2b, DROP FIPS IF NO BLOCKS FOUND ####
    fips_blockpoints <- fips_blockpoints[!is.na(blockid), ]

    ## > ALREADY SORTED output s2b ####
    setorder(fips_blockpoints, ejam_uniq_id, blockid)

    ## return_shp = TRUE ####
    ## Get POLYGONS ####
    if (return_shp) {
      # do not need to do what getblocksnearby_from_fips_cityshape() since the pts part we can get from FIPS. just need the shapefile polygons part.
      s2b_pts_polys <- list()
      s2b_pts_polys$pts <- fips_blockpoints
      ## get bounds for ALL originally input fips (as recorded in original_order$fips), not just fips (the filtered ok ones).
      polys <- shapes_from_fips(original_order$fips, allow_multiple_fips_types = allow_multiple_fips_types) # preserves exact order,
      # and includes NAs in output if NAs in input
      s2b_pts_polys$polys <- polys

      return(s2b_pts_polys)
    } else {
      return(fips_blockpoints)
    }
  }
}
######################################## #
