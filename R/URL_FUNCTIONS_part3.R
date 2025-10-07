
# This file has draft or archived functions,
# especially obsolete functions related to ejscreen and other EPA APIs that may be gone as of 1/2025.
# All should be internal, noRd, or could be commented out or deleted if there are no useful code snippets left here.

#   also see URL_*.R and url_*.R

################################################### #################################################### #

#' URL functions - API WENT DOWN? Get URLs of EJSCREEN reports
#'
#' Old function for pre-2025 EPA EJSCREEN report (see newer url_ejamapi() now)
#'
#' @details
#'  If old EJSCREEN api is down, tries to use newer [url_ejamapi()]
#'
#'  For info on the old EJSCREEN API pre-Feb-2025,
#'  see [ejscreenRESTbroker()] and [ejscreenapi1()]
#'
#'   and [archived EJAPIinstructions.pdf](https://web.archive.org/web/20250201025755/https://ejscreen.epa.gov/mapper/EJAPIinstructions.pdf)
#'
#'   and [archived ejscreenapi1 page](https://web.archive.org/web/20250119121857/https://ejscreen.epa.gov/mapper/ejscreenapi1.html)
#'
#' @param sitepoints data.frame with colnames lat, lon (or lat, lon parameters can be provided separately)
#' @param lat one or more latitudes (or a table with lat, lon columns, or filepath with that, or omit to interactively select file)
#' @param lon one or more longitudes (or omitted -- see lat parameter details)
#' @param radius miles radius
#' @param as_html Whether to return as just the urls or as html hyperlinks to use in a DT::datatable() for example
#' @param linktext used as text for hyperlinks, if supplied and as_html=TRUE
#' @param mobile If TRUE, provides URL for the mobile browser version, not desktop version
#' @param areatype passed as areatype= in API, inferred if not provided but areaid is provided
#' @param areaid fips codes if used,  passed as areaid=  in API, can be FIPS for blockgroups, tracts, counties.
#'   Not zip code! For example, "10001" will report on that county, not that zip code.
#'   Note that nearly half of all county fips codes are impossible to distinguish from
#'   5-digit zipcodes because the same numbers are used for both purposes.
#'
#'   For county FIPS 10001, use `url_ejscreen_report(areaid =  '10001')`
#'
#'   For zipcode 10001, you cannot use `url_ejscreen_report()` for zip codes
#'    since the API does not support zip codes.
#'   You can still at least try `url_ejscreenmap(wherestr =  '10001')`
#'
#' @param namestr The character string text to show on the report as the name of the place
#' @param shapefile not implemented for old EJSCREEN API, should work for newer EJAM-API
#' @param fips  not implemented for old EJSCREEN API, should work for newer EJAM-API
#' @param wkid default is 4326 -WGS84 - World Geodetic System 1984, used in GPS - see (https://epsg.io/4326)
#' @param unit default is 9035 which means miles; for kilometers use 9036
#' @param f can be "report" or "pjson" or "json"
#' @param interactiveprompt passed to [sitepoints_from_any()]
#' @seealso  [url_ejscreen_report()]  [url_ejscreenmap()]
#'   [url_echo_facility()] [url_frs_facility()]  [url_enviromapper()]
#' @return URL(s)
#'
#' @keywords internal
#'
url_ejscreen_report <- function(sitepoints = NULL, lat='', lon='', radius='', mobile = FALSE,
                                areatype="", areaid = "", namestr = "",
                                shapefile = NULL,
                                fips = NULL,
                                # would require POST not just a simple url-encoded GET API call?
                                wkid = 4326, unit = 9035, f = "report",
                                interactiveprompt = FALSE,

                                as_html = FALSE,
                                linktext = "Report",
                                ifna = "https://ejanalysis.com",
                                baseurl = NULL,
                                ...) {

  message("note this is the old EJSCREEN function - it does redirect to using url_ejamapi() but consider using url_ejamapi() or url_ejscreenmap() directly")

  if (!is.null(sitepoints)) {
    lat = sitepoints$lat
    lon = sitepoints$lon
  }
  ############################################################################################################################################### #

  ################################################ #

  # THE NEWER EJAM API REPORT (POST-JANUARY-2025)

  ################################################ #

  # disable ejscreen report links while the old api site is down, but
  # if ejscreen api is down, try to use ejam-api
  # but params differed a bit

  if (EJAM:::global_or_param("ejscreen_is_down")) {
    if (EJAM:::global_or_param("ejamapi_is_down")) {
      url <- rep(NA, length(url))
      return(url)
    } else {
      ################################################ #
      if (is.null(fips) && (!any(areaid == "") && !any(is.null(areaid)))) {
        # called with old params that ejscreen api used to use here, so convert to what ejamapi expects
        fips <- areaid # ignore areatype and namestr in this case
      }

      url <- url_ejamapi(
        sitepoints = data.frame(lat = lat, lon = lon),
        radius = ifelse(all.equal(radius, ""), NULL, radius),
        fips = fips,
        shapefile = shapefile,
        as_html = as_html,
        linktext = linktext,
        ifna = ifna,
        baseurl = baseurl,
        ...
      )

      return(url)
    }
  } else {
    ############################################################################################################################################### #

    ################################################ #

    # THE OLDER EJSCREEN API REPORT (PRE JANUARY 2025)

    ################################################ #

    if (!missing(fips) && !is.null(fips)) {
      # try to add flexibility by allowing fips to be used instead of areaid/areatype/namestr now
      areatype <- fipstype(fips)
      areaid <- fips
      if (is.null(namestr)) {namestr <- ''}
    }

    if (!any(areaid == "") && !any(is.null(areaid))) {

      fips <- areaid
      if (missing(areatype)) {
        areatype <- fipstype(fips)
      }
      if (!(all(areatype %in% c("blockgroup", "tract", "city", "county", 'state')))) {warning("FIPS must be one of 'blockgroup', 'tract', 'city', 'county', 'state' for the EJSCREEN API")}
      if (!(length(areatype) %in% c(1, length(areaid)))) {warning("must provide either 1 areatype value for all or exactly one per areaid")}

      # namestr <- fips   # user could specify something else here
      if (is.null(namestr)) {namestr <- ''}
      # The FIPS can be displayed as the name of the place on the EJSCREEN report since it already looks up and displays the actual name of a county or city
      # namestr <- rep("", length(areatype))
      # namestr[namestr %in% "county"] <- fips2countyname(fips[namestr %in% "county"])
      # # namestr[namestr %in% "state"] <- fips2statename(fips[namestr %in% "state"])

    } else {

      # Flexibly allow for user to provide latlon as 1 table or as 2 vectors or 1 filename or 1 interactively selected file
      if (!(!missing(lat) && all(is.na(lat)))) {
        latlon_table <- sitepoints_from_anything(lat, lon, interactiveprompt = interactiveprompt)[ , c("lat","lon")]
        lat <- latlon_table$lat
        lon <- latlon_table$lon
      }
      # error checking lat lon radius

      latlon_radius_validate_lengths <- function(lat, lon, radius) {
        if (!is.numeric(radius) || !is.numeric(lat) || !is.numeric(lon)) {warning("lat or lon or radius is not numeric")}
        #
        if (length(radius) == 0 || length(lat) == 0 || length(lon) == 0) {warning("lat or lon or radius missing entirely (length of a vector is zero")}
        if (is.null(radius)     || is.null(lat)     || is.null(lon))     {warning("lat or lon or radius is NULL")}
        if (anyNA(radius)       || anyNA(lat)       || anyNA(lon))       {warning("lat or lon or radius contain NA value(s)")}
        if (length(lat)  != length(lon)) {warning("did not find exactly one lat for each lon value (lengths of vectors differ)")}
        if (!(length(radius) %in% c(1, length(lat), length(lon)))) {warning("must provide either 1 radius value for all sites or exactly one per site")}
        if (!( "" %in% lat || "" %in% lon ) && (any(is.na(radius)) || "" %in% radius)) {warning('radius is missing but needed when lat/lon specified')} # ??
      }
      latlon_radius_validate_lengths(lat = lat, lon = lon, radius = radius)
    }
    if (( "" %in% lat || "" %in% lon ) && ("" %in% areaid)) {
      warning('at least some of lat or lon are empty and at least one areaid is empty as well - must use one or the other')
    }

    # ejscreenRESTbroker works only for one url at a time:
    #  ejscreenRESTbroker(lon = lon, lat = lat, radius = radius, f = "report" )
    # 'https://ejscreen.epa.gov/mapper/EJscreen_SOE_report.aspx?namestr=&geometry={"spatialReference":{"wkid":4326},"x":-100.11715256086383,"y":36.65046624822855}&distance=1&unit=9035&areatype=&areaid=&f=report'
    if (mobile) {
      baseurl <- "https://ejscreen.epa.gov/mapper/mobile/EJSCREEN_mobile.aspx?"   # ok 7/23/23
    } else {
      baseurl <- 'https://ejscreen.epa.gov/mapper/EJscreen_SOE_report.aspx?'  # ok 7/23/23
    }

    xytext <- paste0('"x":', lon, ',"y":', lat, '}')
    # f = "report"
    # wkid = 4326
    # unit = 9035
    url <-  paste0(baseurl,
                   '&geometry={"spatialReference":{"wkid":',wkid,'},',
                   # '"x":', lon, ',"y":', lat, '}',
                   xytext,
                   '&distance=', radius,
                   '&unit=', unit,
                   "&areatype=", areatype,
                   "&areaid=", areaid,
                   "&namestr=", namestr,

                   '&f=', f
    )

  if (as_html) {
    if (missing(linktext)) {linktext <- paste0("EJSCREEN Report")}
    url <- url_linkify(url, text = linktext)
  }

  return(url)
  }
}
############################################################################################################################################### #

################################################### #################################################### #


#  #' URL functions - API WENT DOWN? Get URLs of EJSCREEN ACS reports - OBSOLETE
#  #'
#  #' Get URL(s) for EJSCREEN ACS report on residents near given point(s)
#  #'
#  #' @details  NOT USED BY APP NOW THAT COMMUNITY REPORT EXISTS and API went down
#  #'
#  #' @param lon one or more longitudes
#  #' @param lat one or more latitudes
#  #' @param radius miles radius
#  #' @param as_html Whether to return as just the urls or as html hyperlinks to use in a DT::datatable() for example
#  #' @param linktext used as text for hyperlinks, if supplied and as_html=TRUE
#  #' @seealso  [url_ejscreen_report()]  [url_ejscreenmap()]
#  #'   [url_echo_facility()] [url_frs_facility()]  [url_enviromapper()]
#  #' @return URL(s)
#  #'
#  #' @noRd
#  #' @keywords internal
#  #'
#
# url_ejscreen_acs_report <- function(lon, lat, radius, as_html=FALSE, linktext = "ACS report") {
#
#   baseurl <- "https://ejscreen.epa.gov/mapper/demogreportpdf.aspx?feattype=point&radius="
#   part2 <- "&coords="
#   url <- paste0(baseurl, radius, part2, paste(lon,lat,sep = ",")) # it has to be lon then lat in this URL
#   if (as_html) {
#     url = URLencode(url)
#     url <- url_linkify(url, text = linktext)
#   }
#   return(url)
#   # "https://ejscreen.epa.gov/mapper/demogreportpdf.aspx?feattype=point&radius=3.1&coords=-81.978358,30.296344"
#   #  dd=3.1; lon=-81.978358; lat=30.296344
#   # url_ejscreen_acs_report(lat=lat, lon = lon, radius = dd)
#   # browseURL(url_ejscreen_acs_report(lat = testpoints_50$lat, lon = testpoints_50$lon, radius = 3.1)[1])
# }
################################################### #################################################### #




######################################################################### #

#' URL functions - API WENT DOWN? url_get_via_url - helper function work in progress: GET json via url of ejscreen ejquery map services
#'
#' @param url the url for an EJSCREEN ejquery request
#'
#' @return json
#'
#' @noRd
#' @keywords internal
#'
url_get_via_url <- function(url) {

  # Could check if site or API is available?

  # function to GET json via url of ejscreen ejquery map services ### #

  x <- httr::GET(url)
  if (x$status_code == 400) {
    warning('Query failed with status code 400: ', url)
  }
  if (x$status_code == 404) {
    warning('Query failed with status code 404, possibly requesting too many locations at once: ', url)
  }
  x <- try(rawToChar(x$content))
  x <- try(jsonlite::fromJSON(x))
  alldata <- x$features$attributes
  # print(str(x)) # nothing else useful except possible x$features$geometry data.frame
  return(alldata)
}
######################################################################### #

#' URL functions - API WENT DOWN? url_get_eparest_chunked_by_id - experimental/ work in progress: in chunks, get ACS data or Block weights nearby via EPA API
#'
#' @param objectIds see API
#' @param chunksize see API
#' @param ... passed to url_getacs_epaquery()
#'
#' @return a table
#'
#' @noRd
#' @keywords internal
#'
url_get_eparest_chunked_by_id <- function(objectIds, chunksize=200, ...) {

  # Could check if site or API is available?

  #  to get ACS data or Block weights nearby from EPA server via API  ###   #

  ############################################################## #
  # generic function to break request into chunks ####
  ############################################################## #

  if (missing(objectIds)) {
    warning('this only works for objectIds so far, breaking up into groups of 200 or so objectIds.')
    return(NULL)
    # could write it to check if >1000 would be returned and then request in chunks in that case.
  }
  x <- list()
  n <- length(objectIds)
  extrachunk <- ifelse((n %/% chunksize) * chunksize == n, 0, 1)

  for (chunk in 1:(extrachunk + (n %/% chunksize))) {
    istart <- 1 + (chunk - 1) * chunksize
    iend <- chunksize + istart - 1
    iend <- min(iend, n)
    idchunk <- objectIds[istart:iend]

    x[[chunk]] <- url_getacs_epaquery(objectIds = idchunk,  ...)
  }
  return(do.call(rbind, x))
}
############################################################## #  ############################################################## #

#' URL functions - API WENT DOWN? url_getacs_epaquery_chunked - experimental/ work in progress: in chunks, get ACS data via EPA API
#'
#' @param servicenumber see API
#' @param objectIds see API
#' @param outFields see API
#' @param returnGeometry  see API
#' @param justurl  see API
#' @param chunksize eg 200 for chunks of 200 each request
#' @param ... passed to url_getacs_epaquery()
#'
#' @return table
#'
#' @noRd
#' @keywords internal
#'
#' @examples \donttest{
#'  # x <- list() # chunked chunks. best not to ask for all these:
#'  # x[[1]] <- url_getacs_epaquery_chunked(   1:1000, chunksize = 100)
#'  # x[[2]] <- url_getacs_epaquery_chunked(1001:5000, chunksize = 100)
#'  # xall <- do.call(rbind, x)
#'  }
url_getacs_epaquery_chunked <- function(objectIds=1:3,
                                        servicenumber=7,
                                        outFields=NULL,
                                        returnGeometry=FALSE,
                                        justurl=FALSE,
                                        chunksize=200, ...) {

  # Could check if site or API is available?

  ############################################################## #
  # generic function to break request into chunks
  ############################################################## #

  if (missing(objectIds)) {
    warning('this only works for objectIds so far, breaking up into groups of 200 or so objectIds.')
    return(NULL)
    # could write it to check if >1000 would be returned and then request in chunks in that case.
  }

  # warning('check if still has a bug to fix where it duplicates the last row of each chunk')
  x <- list()
  n <- length(objectIds)
  extrachunk <- ifelse((n %/% chunksize) * chunksize == n, 0, 1)

  for (chunk in 1:(extrachunk + (n %/% chunksize))) {
    istart <- 1 + (chunk - 1) * chunksize
    iend <- chunksize + istart - 1
    iend <- min(iend, n)
    idchunk <- objectIds[istart:iend]
    # # TESTING:
    #   x[[chunk]] <- data.frame(id=idchunk, dat=NA)
    #   print(idchunk); print(x) # cumulative so far

    x[[chunk]] <- url_getacs_epaquery(objectIds = idchunk, outFields = outFields, servicenumber = servicenumber, ...)
  }
  return(do.call(rbind, x))
}
############################################################## ############################################################### #

#' URL functions - DRAFT - API WENT DOWN? url_getacs_epaquery - experimental/ work in progress: get ACS data via EPA API (for <200 places)
#'
#' @description  uses ACS2019 rest services ejscreen ejquery MapServer 7
#'
#'   Documentation of format and examples of input parameters:
#'
#'   <https://geopub.epa.gov/arcgis/sdk/rest/index.html#/Query_Map_Service_Layer/02ss0000000r000000/>
#'
#' @param objectIds see API
#' @param servicenumber see API
#' @param outFields see API. eg "STCNTRBG","TOTALPOP","PCT_HISP",
#' @param returnGeometry see API
#' @param justurl if TRUE, returns url instead of default making API request
#' @param ... passed to url_getacs_epaquery_chunked()
#' @examples  url_getacs_epaquery(justurl=TRUE)
#'
#' @return table
#'
#' @keywords internal
#' @noRd
#'
url_getacs_epaquery <- function(objectIds=1:3,
                                servicenumber=7,
                                outFields=NULL,
                                returnGeometry=FALSE,
                                justurl=FALSE,
                                ...) {

  # Could check if site or API is available?

  # Documentation of format and examples of input parameters:
  # https://geopub.epa.gov/arcgis/sdk/rest/index.html#/Query_Map_Service_Layer/02ss0000000r000000/

  print('this uses ACS2019 rest services ejscreen ejquery MapServer 7')


  # if (length(objectIds) < 1 | !all(is.numeric(objectIds))) {stop('no objectIds specified or some are not numbers')}
  if (any(objectIds == '*')) {
    warning('Trying to specify all objectIds will not work')
    return(NULL)
  }
  if (length(objectIds) > 200) {
    warning('seems to crash if more than about 211 requested per query - chunked version not yet tested')

    # return(url_get_eparest_chunked_by_id(objectIds=objectIds,
    #                                   servicenumber=servicenumber,
    #                                   outFields=outFields,
    #                                   returnGeometry=returnGeometry,
    #                                   justurl=justurl,
    #                                   ...))
    return(url_getacs_epaquery_chunked(objectIds = objectIds,
                                       servicenumber = servicenumber,
                                       outFields = outFields,
                                       returnGeometry = returnGeometry,
                                       justurl = justurl,
                                       ...))
  }

  # use bestvars default outFields if unspecified ### #
  if (is.null(outFields)) {
    bestvars <- c( ## bestvars ### #
      # outFields
      "OBJECTID",  # unique id 1 onwards
      "STCNTRBG",  # blockgroup fips
      "AREALAND", "AREAWATER",

      "TOTALPOP",   # population count

      "LOWINC", "POV_UNIVERSE_FRT", "PCT_LOWINC",

      "HH_BPOV", "HSHOLDS", "PCT_HH_BPOV",

      "EDU_LTHS", "EDU_UNIVERSE", "PCT_EDU_LTHS",

      "LINGISO", "PCT_LINGISO",

      "EMP_STAT_UNEMPLOYED",
      "EMP_STAT_UNIVERSE",
      "PCT_EMP_STAT_UNEMPLOYED",

      "AGE_LT5",      "PCT_AGE_LT5",
      "AGE_GT64",     "PCT_AGE_GT64",

      "NUM_MINORITY", "PCT_MINORITY",

      "WHITE",        "PCT_WHITE",
      "BLACK",        "PCT_BLACK",
      "HISP" ,        "PCT_HISP",
      "ASIAN",        "PCT_ASIAN",
      "AMERIND",      "PCT_AMERIND",
      "HAWPAC",       "PCT_HAWPAC",
      "OTHER_RACE",   "PCT_OTHER_RACE",
      "TWOMORE",      "PCT_TWOMORE",
      "NHWHITE",      "PCT_NHWHITE",
      "NHBLACK",      "PCT_NHBLACK",
      "NHASIAN",      "PCT_NHASIAN",
      "NHAMERIND",    "PCT_NHAMERIND",
      "NHHAWPAC",     "PCT_NHHAWPAC",
      "NHOTHER_RACE", "PCT_NHOTHER_RACE",
      "NHTWOMORE",    "PCT_NHTWOMORE",

      "HOME_PRE60", "HSUNITS", "PCT_HOME_PRE60"
    )
    outFields <- bestvars
  } # use default fields if none specified
  # reformat the parameters - now done by url_... function
  # outFields <- paste(outFields, collapse = ',') # if a vector of values was provided, collapse them into one comma-separated string
  # objectIds <- paste(objectIds, collapse = ',') # if a vector of values was provided, collapse them into one comma-separated string

  ################################################################### #
  # assemble URL
  # url_to_get_ACS2019_rest_services_ejscreen_ejquery_MapServer_7()
  url_to_use <- url_to_get_ACS2019_rest_services_ejscreen_ejquery_MapServer_7(
    # servicenumber=servicenumber,
    objectIds = objectIds,
    returnGeometry = returnGeometry,
    outFields = outFields,         # make same name?
    ...)
  ################################################################### #

  # call GET function (submit the query

  if (justurl) {return(url_to_use)}
  return(url_get_via_url(url_to_use))
}
############################################################## #  ############################################################## #

#' URL functions - DRAFT - API WENT DOWN? FRAGMENTS OF CODE - url_to_any_rest_services_ejscreen_ejquery
#'
#' @details
#'  # generic function wrapping ejscreen/ejquery API calls ####
#'
#'  Disadvantage of this generic approach is it does not help you by showing
#'   a list of parameters, since those are specific to the service like 7 vs 71.
#'
#'  see links to documentation on using APIs here:
#'
#'  EJAM/dev/intersect-distance/arcgis/ArcGIS REST API basics.txt
#'
#' @param servicenumber na
#'
#' @return tbd
#' @examples # na
#'
#' @noRd
#' @keywords internal
#'
url_to_any_rest_services_ejscreen_ejquery <- function(servicenumber=7) {

  # Could check if site or API is available?

  ####################################### #
  ## notes - examples
  if (1 == 0) {
    url_getacs_epaquery(  objectIds = 1:4,                 outFields = 'STCNTRBG', justurl = TRUE)
    t(url_getacs_epaquery(objectIds = sample(1:220000,2),  outFields = '*'))
    t(url_getacs_epaquery(objectIds = sample(1:220000,2)))
    url_getacs_epaquery(  objectIds = sample(1:220000,10), outFields = c('STCNTRBG', 'STATE', 'COUNTY', 'TRACT', 'BLKGRP'), justurl = FALSE)
    y <- url_get_via_url(url_to_any_rest_services_ejscreen_ejquery(         servicenumber = 71))
    x <- url_get_via_url(url_to_get_nearby_blocks_rest_services_ejscreen_ejquery_MapServer_71(lat = 30.494982, lon = -91.132107, miles = 1))
    z <- url_get_via_url(url_to_get_ACS2019_rest_services_ejscreen_ejquery_MapServer_7())
  }
  ####################################### #

  params_with_NULL   <- c(as.list(environment()))
  params_with_NULL <- subset(params_with_NULL, names(params_with_NULL) != 'servicenumber')
  params_with_NULL <- lapply(params_with_NULL, function(x) paste(x, collapse = ','))
  params_text_with_NULL <- paste(paste0(names(params_with_NULL), '=', params_with_NULL), collapse = '&')

  baseurl <- paste0(
    'https://geopub.epa.gov/arcgis/rest/services/ejscreen/ejquery/MapServer/',
    servicenumber,  # 7 is ACS 2019 blockgroups
    '/query?'
  )
  queryurl <- paste0(
    baseurl,
    params_text_with_NULL
  )
  return(queryurl)
}
################################################################################# #

#' URL functions - DRAFT - API WENT DOWN? FRAGMENTS OF AN URL FUNCTION url_to_get_ACS2019_rest_services_ejscreen_ejquery_MapServer_7
#'
#' @param objectIds na
#' @param sqlFormat na
#' @param text na
#' @param where na
#' @param havingClause na
#' @param outFields na
#' @param orderByFields na
#' @param groupByFieldsForStatistics na
#' @param outStatistics na
#' @param f na
#' @param returnGeometry na
#' @param returnIdsOnly na
#' @param returnCountOnly na
#' @param returnExtentOnly na
#' @param returnDistinctValues na
#' @param returnTrueCurves na
#' @param returnZ na
#' @param returnM na
#' @param geometry na
#' @param geometryType na
#' @param featureEncoding na
#' @param spatialRel na
#' @param units na
#' @param distance na
#' @param inSR na
#' @param outSR na
#' @param relationParam na
#' @param geometryPrecision na
#' @param gdbVersion na
#' @param datumTransformation na
#' @param parameterValues na
#' @param rangeValues na
#' @param quantizationParameters na
#' @param maxAllowableOffset na
#' @param resultOffset na
#' @param resultRecordCount na
#' @param historicMoment na
#' @param time na
#' @param timeRelation na
#'
#' @examples #tbd
#'
#' @return tbd
#'
#' @noRd
#' @keywords internal
#'
url_to_get_ACS2019_rest_services_ejscreen_ejquery_MapServer_7 <- function(

  objectIds=NULL,
  sqlFormat='none',
  text=NULL,
  where=NULL,
  havingClause=NULL,

  # select what stats

  outFields=NULL,
  orderByFields=NULL,
  groupByFieldsForStatistics=NULL,
  outStatistics=NULL,
  f='pjson',
  returnGeometry='true',
  returnIdsOnly='false',
  returnCountOnly='false',
  returnExtentOnly='false',
  returnDistinctValues='false',
  returnTrueCurves='false',
  returnZ='false',
  returnM='false',

  # geoprocessing like buffer/intersect, etc.

  geometry=NULL,
  geometryType='esriGeometryEnvelope',
  featureEncoding='esriDefault',
  spatialRel='esriSpatialRelIntersects',
  units='esriSRUnit_Foot',
  distance=NULL,
  inSR=NULL,
  outSR=NULL,
  relationParam=NULL,
  geometryPrecision=NULL,
  gdbVersion=NULL,
  datumTransformation=NULL,
  parameterValues=NULL,
  rangeValues=NULL,
  quantizationParameters=NULL,
  maxAllowableOffset=NULL,
  resultOffset=NULL,
  resultRecordCount=NULL,
  historicMoment=NULL,
  time=NULL,
  timeRelation='esriTimeRelationOverlaps'
) {

  # Could check if site or API is available?

  ## notes - examples
  if (1 == 0) {
    url_getacs_epaquery(  objectIds = 1:4,                 outFields = 'STCNTRBG', justurl = TRUE)
    t(url_getacs_epaquery(objectIds = sample(1:220000,2),  outFields = '*'))
    t(url_getacs_epaquery(objectIds = sample(1:220000,2)))
    url_getacs_epaquery(  objectIds = sample(1:220000,10), outFields = c('STCNTRBG', 'STATE', 'COUNTY', 'TRACT', 'BLKGRP'), justurl = FALSE)
    y <- url_get_via_url(url_to_any_rest_services_ejscreen_ejquery(         servicenumber = 71))
    x <- url_get_via_url(url_to_get_nearby_blocks_rest_services_ejscreen_ejquery_MapServer_71(lat = 30.494982, lon = -91.132107, miles = 1))
    z <- url_get_via_url(url_to_get_ACS2019_rest_services_ejscreen_ejquery_MapServer_7())
  }

  # Documentation of format and examples of input parameters:
  # https://geopub.epa.gov/arcgis/sdk/rest/index.html#/Query_Map_Service_Layer/02ss0000000r000000/

  # list of useful map services to query ####

  #https://geopub.epa.gov/arcgis/sdk/rest/index.html#/Query_Map_Service_Layer/02ss0000000r000000/
  # https://geopub.epa.gov/arcgis/sdk/rest/index.html#/Query_Map_Service_Layer/02ss0000000r000000/
  # https://geopub.epa.gov/arcgis/sdk/rest/index.html#/Map_Service/02ss0000006v000000/
  # 'https://geopub.epa.gov/arcgis/rest/services/ejscreen/ejquery/MapServer/'
  # MaxRecordCount: 1000
  # https://geopub.epa.gov/arcgis/rest/services/ejscreen/ejquery/MapServer/7/2?f=pjson


  # ASSEMBLE URL BY PUTTING ALL THE PARAMETERS INTO ONE LONG STRING IN CORRECT FORMAT:
  # params_with_NULL <- c(as.list(environment()), list(...))  # if ... was among function parameter options
  params_with_NULL   <- c(as.list(environment()))
  params_with_NULL <- lapply(params_with_NULL, function(x) paste(x, collapse = ','))
  params_text_with_NULL <- paste(paste0(names(params_with_NULL), '=', params_with_NULL), collapse = '&')

  baseurl <- paste0(
    'https://geopub.epa.gov/arcgis/rest/services/ejscreen/ejquery/MapServer/',
    7,  # servicenumber 7 is ACS 2019 blockgroups
    '/query?'
  )
  queryurl <- paste0(
    baseurl,
    params_text_with_NULL
  )
  return(queryurl)
}
############################################################## #  ############################################################## #

#' URL functions - DRAFT FRAGMENTS OF CODE - url_to_get_nearby_blocks_rest_services_ejscreen_ejquery_MapServer_71
#'
#' @param lat na
#' @param lon na
#' @param miles na
#' @param outFields na
#' @param returnCountOnly na
#' @examples #na
#' @return na
#'
#' @noRd
#' @keywords internal
#'
url_to_get_nearby_blocks_rest_services_ejscreen_ejquery_MapServer_71 <- function(
    lat, lon, miles,
    outFields='GEOID10,OBJECTID,POP_WEIGHT', returnCountOnly='false') {

  # Could check if site or API is available?


  # function for service 71, nearby blockweights
  ## notes - examples
  if (1 == 0) {
    url_getacs_epaquery(  objectIds = 1:4,                 outFields = 'STCNTRBG', justurl = TRUE)
    t(url_getacs_epaquery(objectIds = sample(1:220000,2),  outFields = '*'))
    t(url_getacs_epaquery(objectIds = sample(1:220000,2)))
    url_getacs_epaquery(  objectIds = sample(1:220000,10), outFields = c('STCNTRBG', 'STATE', 'COUNTY', 'TRACT', 'BLKGRP'), justurl = FALSE)
    y <- url_get_via_url(url_to_any_rest_services_ejscreen_ejquery(         servicenumber = 71))
    x <- url_get_via_url(url_to_get_nearby_blocks_rest_services_ejscreen_ejquery_MapServer_71(lat = 30.494982, lon = -91.132107, miles = 1))
    z <- url_get_via_url(url_to_get_ACS2019_rest_services_ejscreen_ejquery_MapServer_7())
  }
  # Documentation of format and examples of input parameters:
  # https://geopub.epa.gov/arcgis/sdk/rest/index.html#/Query_Map_Service_Layer/02ss0000000r000000/



  baseurl <- "https://geopub.epa.gov/arcgis/rest/services/ejscreen/ejquery/MapServer/71/query?"
  params <- paste0(
    'outFields=', outFields,
    '&geometry=', lon, '%2C', lat, #  -91.0211604%2C30.4848044',
    '&distance=', miles,
    '&returnCountOnly=', returnCountOnly,
    '&where=',
    '&text=',
    '&objectIds=',
    '&time=',
    '&timeRelation=esriTimeRelationOverlaps',
    '&geometryType=esriGeometryPoint',
    '&inSR=',
    '&spatialRel=esriSpatialRelContains',
    '&units=esriSRUnit_StatuteMile',
    '&relationParam=',
    '&returnGeometry=false',
    '&returnTrueCurves=false',
    '&maxAllowableOffset=',
    '&geometryPrecision=',
    '&outSR=',
    '&havingClause=',
    '&returnIdsOnly=false',
    '&orderByFields=',
    '&groupByFieldsForStatistics=',
    '&outStatistics=',
    '&returnZ=false',
    '&returnM=false',
    '&gdbVersion=',
    '&historicMoment=',
    '&returnDistinctValues=false',
    '&resultOffset=',
    '&resultRecordCount=',
    '&returnExtentOnly=false',
    '&sqlFormat=none&datumTransformation=',
    '&parameterValues=',
    '&rangeValues=',
    '&quantizationParameters=',
    '&featureEncoding=esriDefault',
    '&f=pjson')
  url <- paste0(baseurl, params)
  return(url)
}
############################################################## #  ############################################################## #

#' URL functions - DRAFT FRAGMENTS OF CODE - url_bookmark_save
#'
#' save bookmarked EJSCREEN session (map location and indicator)
#' @details
#' WORK IN PROGRESS - NOT USED AS OF EARLY 2023.
#' You can use this function to create and save a json file that is a bookmark
#' for a specific place/ map view/ data layer in EJSCREEN.
#' You can later pull up that exact map in EJSCREEN by launching EJSCREEN,
#' clicking Tools, Save Session, Load from File.
#'
#' ***Units are not lat lon: "spatialReference":{"latestWkid":3857,"wkid":102100}
#'
#' Note:
#' (1) The number of sessions that can be saved depends on the browser cache size.
#' (2) Session files, if saved, are available from the default Downloads folder on your computer.
#' (3) Users should exercise caution when saving sessions that may contain sensitive or confidential data.
#'
#' @param ... passed to  url_bookmark_text()
#' @param file path and name of .json file you want to save locally
#'
#' @return URL for 1 bookmarked EJSCREEN map location and variable displayed on map
#'
#' @noRd
#' @keywords internal
#'
url_bookmark_save <- function(..., file="ejscreenbookmark.json") {

  # Could check if site or API is available?


  mytext <- url_bookmark_text(...)
  write(mytext, file = file)
  return(mytext)

  # example, at EJAM/inst/testdata/Sessions_Traffic in LA area.json
  # [{"extent":{"spatialReference":{"latestWkid":3857,"wkid":102100},"xmin":-13232599.178424664,"ymin":3970069.245971938,"xmax":-13085305.024919074,"ymax":4067373.5829790044},"basemap":"Streets","layers":[{"id":"digitizelayer","type":"graphics","title":"digitize graphics","visible":true,"graphics":[]},{"id":"ejindex_map","title":"Pollution and Sources","isDynamic":true,"layerType":"ejscreen","pctlevel":"nation","renderField":"B_PTRAF","renderIndex":4,"type":"map-image","url":"https://geopub.epa.gov/arcgis/rest/services/ejscreen/ejscreen_v2022_with_AS_CNMI_GU_VI/MapServer","visible":true,"opacity":0.5}],"graphics":[],"name":"Traffic in LA area"}]
  #
  # [{
  #   "extent":{"spatialReference":{"latestWkid":3857,"wkid":102100},"xmin":-13232599.178424664,"ymin":3970069.245971938,"xmax":-13085305.024919074,"ymax":4067373.5829790044},
  #   "basemap":"Streets",
  #   "layers":[
  #     {"id":"digitizelayer","type":"graphics","title":"digitize graphics","visible":true,"graphics":[]},
  #     {"id":"ejindex_map",
  #       "title":"Pollution and Sources",
  #       "isDynamic":true,
  #       "layerType":"ejscreen",
  #       "pctlevel":"nation",
  #       "renderField":"B_PTRAF",
  #       "renderIndex":4,
  #       "type":"map-image",
  #       "url":"https://geopub.epa.gov/arcgis/rest/services/ejscreen/ejscreen_v2022_with_AS_CNMI_GU_VI/MapServer",
  #       "visible":true,
  #       "opacity":0.5
  #     }
  #   ],
  #   "graphics":[],
  #   "name":"Traffic in LA area"
  # }]

}
############################################################## #  ############################################################## #

#' URL functions - DRAFT FRAGMENTS OF CODE - url_bookmark_text
#'
#' URL for 1 bookmarked EJSCREEN session (map location and indicator)
#' @details
#' WORK IN PROGRESS - NOT USED AS OF EARLY 2023.
#' You can use this function to create and save a json file that is a bookmark
#' for a specific place/ map view/ data layer in EJSCREEN.
#' You can later pull up that exact map in EJSCREEN by launching EJSCREEN,
#' clicking Tools, Save Session, Load from File.
#'
#' Note:
#' (1) The number of sessions that can be saved depends on the browser cache size.
#' (2) Session files, if saved, are available from the default Downloads folder on your computer.
#' (3) Users should exercise caution when saving sessions that may contain sensitive or confidential data.
#'
#' @param x vector of approx topleft, bottomright longitudes in some units EJSCREEN uses?
#'    Units are not lat lon: "spatialReference":{"latestWkid":3857,"wkid":102100}
#' @param y vector of approx topleft, bottomright latitudes in some units EJSCREEN uses?
#'    Units are not lat lon: "spatialReference":{"latestWkid":3857,"wkid":102100}
#' @param name Your name for the map bookmark
#' @param title Your name for the map like Socioeconomic Indicators  or  Pollution and Sources
#' @param renderField name of variable shown on map, like B_UNEMPPCT for map color bins of percent unemployed
#'   or B_PTRAF for traffic indicator
#' @param pctlevel nation or state
#' @param xmin  calculated bounding box for map view
#' @param xmax  calculated bounding box for map view
#' @param ymin  calculated bounding box for map view
#' @param ymax  calculated bounding box for map view
#' @param urlrest Just use the default but it changes each year
#' @return URL for 1 bookmarked EJSCREEN map location and variable displayed on map
#'
#' @examples \donttest{
#'   url_bookmark_text()
#'   url_bookmark_save(
#'     x=c(-10173158.179197036, -10128824.702791695),
#'     y=c(3548990.034736070,3579297.316451102),
#'     file="./mysavedejscreensession1.json")
#'   }
#'
#' @noRd
#' @keywords internal
#'
url_bookmark_text <- function(

  x=c(-13232599.178424664, -13085305.024919074),
  y=c(3970069.245971938, 4067373.5829790044),
  # x=c(-172.305626, -59.454062),  # if longitude, zoomed way out to corners of USA plus some
  # y=c(63.774548, 16.955558), # if latitude, zoomed way out to corners of USA plus some
  name="Bookmarked_EJSCREEN_view",
  title="Socioeconomic Indicators", # Pollution and Sources
  renderField="B_UNEMPPCT",   # B_PTRAF
  pctlevel="nation",
  xmin=1.1*min(x), # >1 because it is negative longitude in USA
  xmax=0.9*min(x), # <1 because it is negative longitude in USA
  ymin=0.9*min(y),
  ymax=1.1*min(y),
  urlrest=paste0("https://geopub.epa.gov/arcgis/rest/services",
                 "/ejscreen/ejscreen_v2022_with_AS_CNMI_GU_VI/MapServer")
) {

  # Could check if site or API is available?


  yrinurl <- gsub(".*v20(..).*", "20\\1", urlrest)
  yrnow <- substr(Sys.time(),1,4)
  if (yrnow > yrinurl + 1) {warning("Check that URL in url_bookmark_text() is updated to the latest dataset of EJSCREEN.")}
  # example, at EJAM/inst/testdata/Sessions_Traffic in LA area.json
  # [{"extent":{"spatialReference":{"latestWkid":3857,"wkid":102100},"xmin":-13232599.178424664,"ymin":3970069.245971938,"xmax":-13085305.024919074,"ymax":4067373.5829790044},"basemap":"Streets","layers":[{"id":"digitizelayer","type":"graphics","title":"digitize graphics","visible":true,"graphics":[]},{"id":"ejindex_map","title":"Pollution and Sources","isDynamic":true,"layerType":"ejscreen","pctlevel":"nation","renderField":"B_PTRAF","renderIndex":4,"type":"map-image","url":"https://geopub.epa.gov/arcgis/rest/services/ejscreen/ejscreen_v2022_with_AS_CNMI_GU_VI/MapServer","visible":true,"opacity":0.5}],"graphics":[],"name":"Traffic in LA area"}]
  #
  # [{
  #   "extent":{"spatialReference":{"latestWkid":3857,"wkid":102100},"xmin":-13232599.178424664,"ymin":3970069.245971938,"xmax":-13085305.024919074,"ymax":4067373.5829790044},
  #   "basemap":"Streets",
  #   "layers":[
  #     {"id":"digitizelayer","type":"graphics","title":"digitize graphics","visible":true,"graphics":[]},
  #     {"id":"ejindex_map",
  #       "title":"Pollution and Sources",
  #       "isDynamic":true,
  #       "layerType":"ejscreen",
  #       "pctlevel":"nation",
  #       "renderField":"B_PTRAF",
  #       "renderIndex":4,
  #       "type":"map-image",
  #       "url":"https://geopub.epa.gov/arcgis/rest/services/ejscreen/ejscreen_v2022_with_AS_CNMI_GU_VI/MapServer",
  #       "visible":true,
  #       "opacity":0.5
  #     }
  #   ],
  #   "graphics":[],
  #   "name":"Traffic in LA area"
  # }]

  # old urlrest was         "https://v18ovhrtay722.aa.ad.epa.gov/arcgis/rest/services/ejscreen/ejscreen_v2021/MapServer"



  urltext <- paste0(
    '[{"extent":{"spatialReference":{"latestWkid":3857,"wkid":102100},',

    '"xmin":',
    xmin,                   ###########   PARAMETER ################ #### #-10173158.179197036, ##################### #
    ',"ymin":',
    ymin,                   ###########   PARAMETER ################ ##### #3548990.0347360703, ##################### #
    ',"xmax":',
    xmax,                   ###########   PARAMETER ################ ##### #-10128824.702791695, ##################### #
    ',"ymax":',
    ymax,                   ###########   PARAMETER ################ ##### #3579297.316451102, ##################### #

    '},"basemap":"Streets","layers":[{"id":"digitizelayer","type":"graphics","title":"digitize graphics","visible":true,"graphics":[]},{"id":',
    '"',
    'ejindex_map',  ###########  ????????????
    '",',
    '"title":"',
    title,                     ###########   PARAMETER ################ #
    '",',
    '"isDynamic":true,"layerType":',
    '"',
    'ejscreen',
    '",',
    '"pctlevel":"',
    pctlevel,                      ###########   PARAMETER ################ #
    '",',
    '"renderField":"',
    renderField,                  ###########   PARAMETER ################ #
    '",',
    '"renderIndex":4,"type":"map-image",',
    '"url":"',
    urlrest,                    ###########   PARAMETER ################ #
    '",',
    '"visible":true,"opacity":0.5}],"graphics":[],',
    '"name":"',
    name,
    '"',
    '}]'
  )
  return(urltext)
}
############################################################## #  ############################################################## #

