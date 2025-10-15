################################################### #################################################### #

# This file has functions that generate URLs that are links to useful info like reports via API
# or at a webpage (usually via "deep-linking" like a specific place on a map or page with a report on one site or county).

# Check for which API is available within each url_xyz function?

# LIST OF FUNCTIONS HERE ####
#
#   see outline via ctrl-shift-O
#   also see URL_*.R and url_*.R

## site-specific reports ####
################################################### #################################################### #
## NOTES ON URL LINKS/ SITES / REPORTS:

# > reportinfo = EJAM:::global_or_param("default_reports")
# data.frame(header = sapply(reportinfo, function(x) x$header), text = sapply(reportinfo, function(x) x$text))
#                header         text
# 1         EJAM Report       Report
# 2        EJSCREEN Map     EJSCREEN
# 3         ECHO Report         ECHO
# 4          FRS Report          FRS
# 5 EnviroMapper Report EnviroMapper
# 6       County Health Report       County
# 7       State Health Report       State

# > rm(reportinfo)

# ECHO reports on facilities:
# [url_echo_facility()]
# <https://echo.epa.gov/tools/web-services>
# browseURL("https://echo.epa.gov/tools/web-services")
# browseURL("https://echo.epa.gov/detailed-facility-report?fid=110068700043#")
# paste0("https://echo.epa.gov/detailed-facility-report?fid=", regid, "#")

# FRS reports on facilities:
# [url_frs_facility()]
# see also  https://www.epa.gov/frs/frs-rest-services  or https://www.epa.gov/frs
# browseURL("https://www.epa.gov/frs/frs-physical-data-model")
# browseURL("https://frs-public.epa.gov/ords/frs_public2/fii_query_detail.disp_program_facility?p_registry_id=110035807259")
# browseURL("https://www.epa.gov/frs/frs-query#industrial naics")

# EnviroMapper app webpage:
# [url_enviromapper()]

# Envirofacts API, data on facilities:
# browseURL("https://www.epa.gov/enviro/web-services")
# browseURL("https://www.epa.gov/enviro/envirofacts-data-service-api")
# <https://www.epa.gov/enviro/web-services> and
# <https://www.epa.gov/enviro/envirofacts-data-service-api>

################################################### #################################################### #
# . ---------------------------------------------------- ####
# functions using facility registry ID ####
# . ####

#' Get URLs of ECHO reports
#'
#' Get URL(s) for EPA ECHO webpage with facility information
#'
#' @details
#' Additional details...
#'
#' @param regid EPA FRS Registry ID
#' @param validate_regids if set TRUE, returns NA where a regid is not found in the FRS dataset that is
#'   currently being used by this package (which might not be the very latest from EPA).
#'   If set FALSE, faster since avoids checking but some links might not work and not warn about bad regid values.
#'
#' @param as_html Whether to return as just the urls or as html hyperlinks to use in a DT::datatable() for example
#' @param linktext used as text for hyperlinks, if supplied and as_html=TRUE
#' @param ifna URL shown for missing, NA, NULL, bad input values
#' @param baseurl do not change unless endpoint actually changed
#' @param ... unused - allows it to ignore things like lat, lon, if called from [url_columns_bysite()]
#'
#' @seealso  [url_ejamapi()]  [url_ejscreenmap()]
#'   [url_echo_facility()] [url_frs_facility()]  [url_enviromapper()]
#'
#' @seealso  [url_ejamapi()]  [url_ejscreenmap()]
#'   [url_echo_facility()] [url_frs_facility()]  [url_enviromapper()]
#' @return URL(s)
#' @examples  \donttest{
#'  browseURL(url_echo_facility(110070874073))
#'  }
#'
#' @export
#'
url_echo_facility <- function(regid = NULL,
                              validate_regids = TRUE,
                              as_html = FALSE,
                              linktext = "ECHO", # regid,
                              ifna = "https://echo.epa.gov",
                              baseurl = "https://echo.epa.gov/detailed-facility-report?fid=",
                              ...) {
  if (is.null(linktext)) {linktext <- paste0("ECHO")}

  ## regid ####
  if (is.null(regid) || length(regid) == 0) {
    urlx <- ifna
    return(urlx) # length is 0
  }
  if (!is.vector(regid)) {
    warning("regid should be a vector")
    urlx <- rep(ifna, NROW(regid))
  } else {
    ok <- regids_seem_ok(regid)
    urlx <- rep(ifna, NROW(regid))

    ## MAKE URL ### #

    urlx[ok] <- paste0(baseurl, regid[ok])
  }
  ok <- !is.na(regid)

  if (validate_regids) {
    bad_id <- !regids_valid(regid) # warns if any bad
    urlx[bad_id] <- ifna
  }

  urlx[!ok] <- ifna
  ok <- !is.na(urlx)  # now !ok mean it was a bad input and also  ifna=NA
  if (as_html) {
    urlx[ok] <- URLencode(urlx[ok]) # consider if we want  reserved = TRUE
    urlx[ok] <- url_linkify(urlx[ok], text = linktext)
  }
  urlx[!ok] <- ifna # only use non-linkified ifna for the ones where user set ifna=NA and it had to use ifna
  return(urlx)
}
################################################### #################################################### #
# . ####


#' Get URLs of FRS reports
#'
#' Get URL(s) for reports on facilities from EPA FRS (facility registry service)
#'
#' @param regid one or more EPA FRS Registry IDs.
#' @param validate_regids if set TRUE, returns NA where a regid is not found in the FRS dataset that is
#'   currently being used by this package (which might not be the very latest from EPA).
#'   If set FALSE, faster since avoids checking but some links might not work and not warn about bad regid values.
#'
#' @param as_html Whether to return as just the urls or as html hyperlinks to use in a DT::datatable() for example
#' @param linktext used as text for hyperlinks, if supplied and as_html=TRUE
#' @param ifna URL shown for missing, NA, NULL, bad input values
#' @param baseurl do not change unless endpoint actually changed
#' @param ... unused
#'
#' @seealso  [url_ejamapi()]  [url_ejscreenmap()]
#'   [url_echo_facility()] [url_frs_facility()]  [url_enviromapper()]
#'
#' @return URL(s)
#' @examples
#' x = url_frs_facility(testinput_regid)
#' \donttest{
#' browseURL(x[1])
#' }
#' url_frs_facility(testinput_registry_id)
#'
#' @export
#'
url_frs_facility <- function(regid = NULL,
                             validate_regids = FALSE,
                             as_html = FALSE,
                             linktext = "FRS",
                             ifna = "https://www.epa.gov/frs",
                             baseurl = "https://frs-public.epa.gov/ords/frs_public2/fii_query_detail.disp_program_facility?p_registry_id=",
                             ...) {
  if (is.null(linktext)) {linktext <- paste0("FRS")}

  # both of these URLs seem to work:
  #baseurl <- "https://ofmpub.epa.gov/frs_public2/fii_query_detail.disp_program_facility?p_registry_id="
  # baseurl = "https://frs-public.epa.gov/ords/frs_public2/fii_query_detail.disp_program_facility?p_registry_id="

  ## regid ####
  if (is.null(regid) || length(regid) == 0) {
    urlx <- ifna
    return(urlx) # length is 0
  }
  if (!is.vector(regid)) {
    warning("regid should be a vector")
    urlx <- rep(ifna, NROW(regid))
  } else {
    ok <- regids_seem_ok(regid)
    urlx <- rep(ifna, NROW(regid))
    urlx[ok] <- paste0(baseurl, regid[ok])
  }
  ok <- !is.na(regid)

  if (validate_regids) {
    bad_id <- !regids_valid(regid) # warns if any bad
    urlx[bad_id] <- ifna
  }

  urlx[!ok] <- ifna
  ok <- !is.na(urlx)  # now !ok mean it was a bad input and also  ifna=NA
  if (as_html) {
    urlx[ok] <- URLencode(urlx[ok]) # consider if we want  reserved = TRUE
    urlx[ok] <- url_linkify(urlx[ok], text = linktext)
  }
  urlx[!ok] <- ifna # only use non-linkified ifna for the ones where user set ifna=NA and it had to use ifna
  return(urlx)
}
################################################### #################################################### #
# . ---------------------------------------------------- ####
# functions using lat,lon (sometimes from regid) ####
# . ####

#' Get URL(s) for (new) EJSCREEN app with map centered at given point(s)
#'
#' @param sitepoints data.frame with colnames lat, lon (or lat, lon parameters can be provided separately)
#' @param lat,lon vectors of coordinates, ignored if sitepoints provided, can be used otherwise, if shapefile and fips not used
#' @param fips The FIPS code of a place to center map on (blockgroup, tract, city/cdp, county, state FIPS).
#'   It gets translated into the right wherestr parameter if fips is provided.
#'
#' @param wherestr If fips and sitepoints (or lat and lon) are not provided,
#'   wherestr should be the street address, zip code, or place name (not FIPS code!).
#'
#'   Note that nearly half of all county fips codes are impossible to distinguish from
#'   5-digit zipcodes because the same numbers are used for both purposes.
#'
#'   For zipcode 10001, use url_ejscreenmap(wherestr =  '10001')
#'
#'   For County FIPS code 10001, use url_ejscreenmap(fips = "10001")
#'
#'   This parameter is passed to the API as wherestr= , if point and fips are not specified.
#'
#'   Can be State abbrev like "NY" or full state name,
#'   or city like "New Rochelle, NY" as from fips2name() -- using fips2name()
#'   works for state, county, or city FIPS code converted to name,
#'   but using the fips parameter is probably a better idea.
#'
#' @param shapefile shows URL of a EJSCREEN app map centered on the centroid of a given polygon,
#'   but does not actually show the polygon.
#' @param as_html Whether to return as just the urls or as html hyperlinks to use in a DT::datatable() for example
#' @param linktext used as text for hyperlinks, if supplied and as_html=TRUE
#' @param ifna URL shown for missing, NA, NULL, bad input values
#' @param baseurl do not change unless endpoint actually changed
#' @param ... unused
#'
#' @return URL(s)
#' @seealso  [url_ejamapi()]  [url_ejscreenmap()]
#'   [url_echo_facility()] [url_frs_facility()]  [url_enviromapper()]
#' @examples
#' # browseURL(url_ejscreenmap(fips = '10001'))
#' # browseURL(url_ejscreenmap(sitepoints = testpoints_10[1,]))
#' # shp = shapefile_from_any(  testdata("portland.*zip")[1])[1, ]
#' shp = testinput_shapes_2[1,]
#'  url_ejscreenmap(shapefile = shp)
#'
#'
#' @export
#'
url_ejscreenmap <- function(sitepoints = NULL, lat = NULL, lon = NULL,
                            shapefile = NULL,
                            fips = NULL, wherestr = NULL,
                            as_html = FALSE,
                            linktext = "EJSCREEN",
                            ifna = "https://pedp-ejscreen.azurewebsites.net/index.html",
                            baseurl = "https://pedp-ejscreen.azurewebsites.net/index.html",
                            ...) {

  if (is.null(linktext)) {linktext <- paste0("EJSCREEN")}

  ##   linktext could also} be numbered:
  # linktext = paste0("EJSCREEN Map ", 1:NROW(sitepoints))

  ######################## #  ######################## #  ######################## #
  ######################## #  ######################## #  ######################## #

  # GET SITEPOINTS OR APPROX SITEPOINTS FROM FIPS/SHAPEFILE/SITEPOINTS/LAT,LON
  ## sites_from_input ####
  sites <- sites_from_input(sitepoints = sitepoints, lon = lon, lat = lat, shapefile = shapefile, fips = fips)
  sitetype <- sites$sitetype

  # regid_from_input ####
  # handle case where only regid is provided, not the actual sitepoints,
  # so use regid as a last resort way to get latlon
  if (is.null(sites$sitepoints)) {
    dotsargs = rlang::list2(...)
    if ("regid" %in% names(dotsargs)) {regid <- dotsargs$regid} else {regid = NULL}
    if  ("sitepoints" %in% names(dotsargs)) {sitepoints <- dotsargs$sitepoints} else {sitepoints = NULL}
    regid <- regid_from_input(regid=regid, sitepoints=sitepoints) # here we only want it as a way to get lat,lon not to use the regid as in echo or frs report
    # latlon_from_regid ####
    if (!is.null(regid)) {
      sites <- list(
        sitepoints =  latlon_from_regid(regid),
        sitetype = "latlon"
      )
      sitetype <- sites$sitetype
    }
  }

  # GET lat,lon at EACH SITE ### #

  if ("fips" %in% sitetype) {
    ##  latlon_from_fips ####
    sitepoints <- latlon_from_fips(sites$fips) # draft
  }
  if ("shp" %in% sitetype) {
    ## latlon_from_shapefile_centroids ####
    # at least get points that are coordinates of centroids of polygons if cannnot open ejscreen app showing the actual polygon
    sitepoints = latlon_from_shapefile_centroids(sites$shapefile)
  }
  if ("latlon" %in% sitetype) {
    ## points ####
    sitepoints <- sites$sitepoints
  }
  lat = sitepoints$lat
  lon = sitepoints$lon

  if (is.null(lat) || is.null(lon) || length(lat) == 0 || length(lon) == 0) {
    ## handle NA or length 0 ####
    urlx <- ifna
    return(urlx) # length is 0   # or # return(NULL)  ??
  }
  ######################## #  ######################## #  ######################## #
  ######################## #  ######################## #  ######################## #

  ## if both APIs are down, return NAs ### #
  if (EJAM:::global_or_param("ejscreen_is_down")) {
    if (EJAM:::global_or_param("ejamapi_is_down")) {
      urlx <- rep('https://ejanalysis.org', length(urlx))
      if (as_html) {
        urlx <- URLencode(urlx)
        urlx <- url_linkify(urlx, text = linktext)
      }
      return(urlx)
    }
  }
  ######################## #  ######################## #  ######################## #
  ######################## #  ######################## #  ######################## #

  ## > MAKE URL ####

  baseurl_query <- paste0(baseurl, "?wherestr=")
  whereq <- ""
  if (!is.null(lat)) {
    whereq <- paste( lat,  lon, sep = ',') # points (or centroids of polygons)
    whereq[is.na(lat) | is.na(lon)] <- NA
  }
  if (!is.null(fips) && is.null(wherestr)) {
    wherestr <- fips2name(fips) # fips-based
    wherestr[is.na(fips)] <- NA
  }
  if (!is.null(wherestr) && is.null(lat)) {
    whereq <- wherestr # name-based not latlon-based
  }
  urlx <- paste0(baseurl_query, whereq)

  ######################## #
  ### NAs ####
  ok <- !is.na(whereq)
  ######################## #
  urlx[!ok] <- ifna
  ok <- !is.na(urlx)  # now !ok mean it was a bad input and also  ifna=NA
  ######################## #

  ### as_html ####
  if (as_html) {
    urlx[ok] <- URLencode(urlx[ok]) # consider if we want  reserved = TRUE
    urlx[ok] <- url_linkify(urlx[ok], text = linktext)
  }
  ## use generic URL if site is NA, ifna  again in case linkified an NA
  urlx[!ok] <- ifna # only use non-linkified ifna for the ones where user set ifna=NA and it had to use ifna
  return(urlx)
}
################################################### #################################################### #
################################################### #################################################### #
# . ####

#' Get URLs of EnviroMapper reports
#'
#' Get URL(s) for EnviroMapper web-based tool, to open map at specified point location(s)
#'
#' @details EnviroMapper lets you view EPA-regulated facilities and other information on a map, given the lat,lon
#'
#' @param sitepoints data.frame with colnames lat, lon (or lat, lon parameters can be provided separately)
#' @param lat,lon ignored if sitepoints provided, can be used otherwise, if shapefile and fips not used
#' @param shapefile if provided function uses centroids of polygons for lat lon
#' @param fips ignored
#' @param zoom initial map zoom extent
#' @param as_html Whether to return as just the urls or as html hyperlinks to use in a DT::datatable() for example
#' @param linktext used as text for hyperlinks, if supplied and as_html=TRUE
#' @param ifna URL shown for missing, NA, NULL, bad input values
#' @param baseurl do not change unless endpoint actually changed
#' @param ... unused
#'
#' @seealso  [url_ejamapi()]  [url_ejscreenmap()]
#'   [url_echo_facility()] [url_frs_facility()]  [url_enviromapper()]
#'
#' @return URL of one webpage (that launches the mapping tool)
#' @examples
#' x = url_enviromapper(testpoints_10[1,])
#' \dontrun{
#'  browseURL(x)
#'  browseURL(url_enviromapper(lat = 38.895237, lon = -77.029145, zoom = 17))
#' }
#'
#' @export
#'
url_enviromapper <- function(sitepoints = NULL, lon = NULL, lat = NULL, shapefile = NULL, fips = NULL,
                             zoom = 13,
                             as_html = FALSE,
                             linktext = "EnviroMapper",
                             ifna = "https://geopub.epa.gov/myem/efmap/",
                             baseurl = "https://geopub.epa.gov/myem/efmap/index.html?ve=",
                             ...) {

  if (is.null(linktext)) {linktext <- paste0("EnviroMapper")}

  # "https://geopub.epa.gov/myem/efmap/index.html?ve=13,38.895237,-77.029145"

  # see url_ejscreenmap() too

  ######################## #  ######################## #  ######################## #
  ######################## #  ######################## #  ######################## # #  this chunk is copied from url_ejscreenmap()

  # GET SITEPOINTS OR APPROX SITEPOINTS FROM FIPS/SHAPEFILE/SITEPOINTS/LAT,LON
  ## sites_from_input ####
  sites <- sites_from_input(sitepoints = sitepoints, lon = lon, lat = lat, shapefile = shapefile, fips = fips)
  sitetype <- sites$sitetype

  # regid_from_input ####
  # handle case where only regid is provided, not the actual sitepoints,
  # so use regid as a last resort way to get latlon
  if (is.null(sites$sitepoints)) {
    dotsargs = rlang::list2(...)
    if ("regid" %in% names(dotsargs)) {regid <- dotsargs$regid} else {regid = NULL}
    if  ("sitepoints" %in% names(dotsargs)) {sitepoints <- dotsargs$sitepoints} else {sitepoints = NULL}
    regid <- regid_from_input(regid=regid, sitepoints=sitepoints) # here we only want it as a way to get lat,lon not to use the regid as in echo or frs report
    # latlon_from_regid ####
    if (!is.null(regid)) {
      sites <- list(
        sitepoints =  latlon_from_regid(regid),
        sitetype = "latlon"
      )
      sitetype <- sites$sitetype
    }
  }

  # GET lat,lon at EACH SITE ### #

  if ("fips" %in% sitetype) {
    ##  latlon_from_fips ####
    sitepoints <- latlon_from_fips(sites$fips) # draft
  }
  if ("shp" %in% sitetype) {
    ## latlon_from_shapefile_centroids ####
    # at least get points that are coordinates of centroids of polygons if cannnot open ejscreen app showing the actual polygon
    sitepoints = latlon_from_shapefile_centroids(sites$shapefile)
  }
  if ("latlon" %in% sitetype) {
    ## points ####
    sitepoints <- sites$sitepoints
  }
  lat = sitepoints$lat
  lon = sitepoints$lon

  if (is.null(lat) || is.null(lon) || length(lat) == 0 || length(lon) == 0) {
    ## handle NA or length 0 ####
    urlx <- ifna
    return(urlx) # length is 0   # or # return(NULL)  ??
  }
  ######################## #  ######################## #  ######################## #
  ######################## #  ######################## #  ######################## #

  ## > MAKE URL ####

  urlx <- paste0(baseurl, zoom, ",", lat, ",", lon)

  ######################## #
  ### NAs ####
  ok <- !(is.na(lat) | is.na(lon))
  ######################## #
  urlx[!ok] <- ifna
  ok <- !is.na(urlx)  # now !ok mean it was a bad input and also  ifna=NA
  ######################## #

  ### as_html ####
  if (as_html) {
    urlx[ok] <- URLencode(urlx[ok]) # consider if we want  reserved = TRUE
    urlx[ok] <- url_linkify(urlx[ok], text = linktext)
  }
  ## use generic URL if site is NA, ifna  again in case linkified an NA
  urlx[!ok] <- ifna # only use non-linkified ifna for the ones where user set ifna=NA and it had to use ifna
  return(urlx)
}
################################################### #################################################### #
################################################### #################################################### #
# . ---------------------------------------------------- ####
# functions using FIPS (sometimes from shp or latlon) ####
# . ####

#' URL functions - Get URLs of useful report(s) on Counties containing the given fips, from countyhealthrankings.org
#'
#' @param fips vector of fips codes
#' @param year e.g., 2025
#' @param sitepoints if provided and fips is NULL, gets county fips from lat,lon columns of sitepoints
#' @param lat,lon ignored if sitepoints provided, can be used otherwise, if shapefile and fips not used
#' @param shapefile if provided and fips is NULL, gets county fips from lat,lon of polygon centroid
#' @param as_html Whether to return as just the urls or as html hyperlinks to use in a DT::datatable() for example
#' @param linktext used as text for hyperlinks, if supplied and as_html=TRUE
#' @param ifna URL shown for missing, NA, NULL, bad input values
#' @param baseurl do not change unless endpoint actually changed
#'
#' @param statereport can be passed here by [url_state_health()]
#'   if FALSE, returns NA when given a State fips, otherwise return report on enclosing county.
#'   if TRUE, gets report on enclosing State/DC/PR (not county).
#' @param ... unused
#'
#' @return vector of URLs to reports on enclosing counties (or generic link if necessary, like when input was a state fips)
#' @examples
#'  url_county_health(fips_counties_from_state_abbrev("DE"))
#'  # browseURL(url_county_health(fips_counties_from_state_abbrev("DE"))[1])
#'
#' @export
#'
url_county_health <- function(fips = NULL, year = 2025,
                              sitepoints = NULL, lat = NULL, lon = NULL,
                              shapefile = NULL,
                              as_html = FALSE,
                              linktext = "County",   # "County Health Report",
                              ifna = "https://www.countyhealthrankings.org",
                              baseurl = "https://www.countyhealthrankings.org/health-data/",
                              statereport = FALSE,
                              ...) {
  if (is.null(linktext)) {linktext <- paste0("County")}
  # at least get points that are coordinates of centroids of polygons if cannnot open ejscreen app showing the actual polygon

  ################ #
  ## convert each fips, polygon, or point
  ## into  a statefips or countyfips or NA

  ######################## #  ######################## #  ######################## #
  ######################## #  ######################## #  ######################## # #

  # GET SITES FROM FIPS/SHAPEFILE/SITEPOINTS/LAT,LON
  ## sites_from_input ####

  sites <- sites_from_input(sitepoints = sitepoints, lon = lon, lat = lat, shapefile = shapefile, fips = fips)
  sitetype <- sites$sitetype

  ######################## #  ######################## #  ######################## #
  ######################## #  ######################## #  ######################## #

  # GET FIPS at EACH SITE ### #

  # polygons
  if ("shp" %in% sitetype) {
    ## latlon_from_shapefile_centroids ####
    ## then get fips from latlon ####
    sitepoints = latlon_from_shapefile_centroids(sites$shapefile)
    if (statereport) {
      fips = fips_state_from_latlon(sitepoints = sitepoints)
    } else {
      fips = fips_county_from_latlon(sitepoints = sitepoints)
    }
  }
  # points
  if ("latlon" %in% sitetype) {
    sitepoints = sites$sitepoints
    if (statereport) {
      fips = fips_state_from_latlon(sitepoints = sitepoints)
    } else {
      fips = fips_county_from_latlon(sitepoints = sitepoints)
    }
  }
  # fips
  # (as input or now have it from latlon or shp - redundant if latlon or shp but ok)
  if (statereport) {
    # all will be state fips (or NA)
    fips <- fips2state_fips(fips)
  } else {
    ## want only enclosing county report, so where state was submitted, we want to return NA
    ## this will return NA if input fips was a state fips:
    # all will be county fips (or NA)
    fips <- fips2countyfips(fips)
    # but it is already the county if !statereport
  }
  # now all should be state (or NA); or else all are county (or NA)
  #    county fips (or NA if state was input), if want county report
  #    state fips (or NA if invalid ), if want state report
  # is.state <- fipstype(fips) %in% "state" # not needed actually since they are all one or other depending on statereport param

  ######################## #  ######################## #  ######################## #
  ######################## #  ######################## #  ######################## #

  if (is.null(fips) || length(fips) == 0) {
    ## handle NA or length 0 ####
    urlx <- ifna
    return(urlx) # length is 0   # or # return(NULL)  ??
  }
  ####### #
  if (missing(year) && year != as.numeric(substr(Sys.Date(), 1, 4))) {
    warning("default year is ", year, " but newer data might be available")
  }

  ## > MAKE URL ####

  ################ #
  url_ch_county_in_county_out <- function(fips, year = 2025, as_html = FALSE,
                                          baseurl = "https://www.countyhealthrankings.org/health-data/") {
    if (is.null(fips) || length(fips) == 0) {return(NA)}
    statename  <- tolower(fips2statename( fips))
    suppressWarnings({
      countyname <- tolower(fips2countyname(fips, includestate = ""))
    })
    countyname <- trimws(gsub(" county", "", countyname))
    countyname <- gsub(" ", "-", countyname)
    # https://www.countyhealthrankings.org/health-data/maryland/montgomery?year=2023
    urlx <- paste0(baseurl, statename, "/", countyname, "?year=", year)
    urlx[is.na(fips) | is.na(countyname)] <- NA
    return(urlx)
  }
  ################ #
  url_ch_state_in_state_out <- function(fips, year = 2025, as_html = FALSE,
                                        baseurl = "https://www.countyhealthrankings.org/health-data/") {
    if (is.null(fips) || length(fips) == 0) {return(NA)}
    statename <- tolower(fips2statename(fips))
    statename <- gsub(" ", "-", statename)
    urlx <- paste0(baseurl, statename, "?year=", year)
    urlx[is.na(statename)] <- NA
    return(urlx)
  }
  ################ #

  urlx <- rep(ifna, length(fips))
  if (statereport) {
    urlx <- url_ch_state_in_state_out(fips, year = year, as_html = as_html, baseurl = baseurl)
  } else {
    urlx  <- url_ch_county_in_county_out(fips, year = year, as_html = as_html, baseurl = baseurl)
  }
  ### NAs ####
  ok <- !is.na(fips)
  urlx[!ok] <- ifna
  ok <- !is.na(urlx)  # now !ok mean it was a bad input and also  ifna=NA
  ### as_html ####
  if (as_html) {
    urlx[ok] <- URLencode(urlx[ok]) # consider if we want  reserved = TRUE
    urlx[ok] <- url_linkify(urlx[ok], text = linktext)
  }
  urlx[!ok] <- ifna # only use non-linkified ifna for the ones where user set ifna=NA and it had to use ifna
  return(urlx)
}
######################################################################### #

#' URL functions - Get URLs of useful report(s) on STATES containing the given fips, from countyhealthrankings.org
#'
#' @inheritParams url_county_health
#' @param statereport Do not use directly here. passed here by [url_county_health()]
#' @return vector of URLs to reports on enclosing states (or generic link if fips invalid)
#' @examples
#' x = url_state_health(fips_state_from_state_abbrev(c("DE", "GA", "MS")))
#' url_state_health(testinput_fips_mix)
#' \dontrun{
#' browseURL(x)
#' }
#'
#' @export
#'
url_state_health = function(fips = NULL, year = 2025,
                            sitepoints = NULL, lat = NULL, lon = NULL,
                            shapefile = NULL,
                            as_html = FALSE,
                            linktext = "County", # "County Health Report",
                            ifna = "https://www.countyhealthrankings.org",
                            baseurl = "https://www.countyhealthrankings.org/health-data/",
                            statereport = TRUE,
                            ...) {

  url_county_health(
    fips = fips, year = year,
    sitepoints = sitepoints, lat = lat, lon = lon,
    shapefile = shapefile,
    as_html = as_html,
    linktext = linktext,
    ifna = ifna,
    baseurl = baseurl,
    statereport = statereport,
    ...)
}
######################################################################### #
######################################################################### #
# . -------------------  ####

# national equity atlas - county report fips 42003
# "https://nationalequityatlas.org/research/data_summary?geo=04000000000042003"
# "https://nationalequityatlas.org/research/data_summary?geo=02000000000042000"


#' URL functions - Get URLs of useful report(s) on County containing the given fips, from countyhealthrankings.org
#'
#' @param fips vector of fips codes
#' @param sitepoints if provided and fips is NULL, gets county fips from lat,lon columns of sitepoints
#' @param lat,lon ignored if sitepoints provided, can be used otherwise, if shapefile and fips not used
#' @param shapefile if provided and fips is NULL, gets county fips from lat,lon of polygon centroid
#' @param as_html Whether to return as just the urls or as html hyperlinks to use in a DT::datatable() for example
#' @param linktext used as text for hyperlinks, if supplied and as_html=TRUE
#' @param ifna URL shown for missing, NA, NULL, bad input values
#' @param baseurl do not change unless endpoint actually changed
#'
#' @param statereport Do not use directly. Used by [url_state_equityatlas()].
#'   if TRUE, gets report on enclosing State/DC/PR, not county.
#'   if FALSE, returns NA when given a State fips, otherwise return report on enclosing county.
#'
#' @param ... unused
#'
#' @return vector of URLs to reports on enclosing counties (or generic link if necessary, like when input was a state fips)
#' @examples
#'  url_county_equityatlas(fips_counties_from_state_abbrev("DE"))
#'  # browseURL(url_county_equityatlas(fips_counties_from_state_abbrev("DE"))[1])
#'
#' @export
#'
url_county_equityatlas <- function(fips = NULL, # year = 2025,
                                   sitepoints = NULL, lat = NULL, lon = NULL,
                                   shapefile = NULL,
                                   as_html = FALSE,
                                   linktext = "County (Equity Atlas)",
                                   ifna    = "https://nationalequityatlas.org",
                                   baseurl = "https://nationalequityatlas.org/research/data_summary",
                                   statereport = FALSE,
                                   ...) {
  if (is.null(linktext)) {linktext <- paste0("County (Equity Atlas)")}

  ######################## #  ######################## #  ######################## #
  ######################## #  ######################## #  ######################## # #

  # GET SITES FROM FIPS/SHAPEFILE/SITEPOINTS/LAT,LON
  ## sites_from_input ####

  sites <- sites_from_input(sitepoints = sitepoints, lon = lon, lat = lat, shapefile = shapefile, fips = fips)
  sitetype <- sites$sitetype

  ######################## #  ######################## #  ######################## #
  ######################## #  ######################## #  ######################## #

  # GET FIPS at EACH SITE ### #
  ## convert each fips, polygon, or point
  ## into  a statefips or countyfips or NA

  # polygons
  if ("shp" %in% sitetype) {
    ## latlon_from_shapefile_centroids ####
    ## then get fips from latlon ####
    sitepoints = latlon_from_shapefile_centroids(sites$shapefile)
    if (statereport) {
      fips = fips_state_from_latlon(sitepoints = sitepoints)
    } else {
      fips = fips_county_from_latlon(sitepoints = sitepoints)
    }
  }
  # points
  if ("latlon" %in% sitetype) {
    sitepoints = sites$sitepoints
    if (statereport) {
      fips = fips_state_from_latlon(sitepoints = sitepoints)
    } else {
      fips = fips_county_from_latlon(sitepoints = sitepoints)
    }
  }
  # fips
  # (as input or now have it from latlon or shp - redundant if latlon or shp but ok)
  if (statereport) {
    # all will be state fips (or NA)
    fips <- fips2state_fips(fips)
  } else {
    ## want only enclosing county report, so where state was submitted, we want to return NA
    ## this will return NA if input fips was a state fips:
    # all will be county fips (or NA)
    fips <- fips2countyfips(fips)
  }
  # now all should be state (or NA); or else all are county (or NA)
  #    county fips (or NA if state was input), if want county report
  #    state fips (or NA if invalid ), if want state report
  # is.state <- fipstype(fips) %in% "state" # not needed actually since they are all one or other depending on statereport param

  ######################## #  ######################## #  ######################## #
  ######################## #  ######################## #  ######################## #

  if (is.null(fips) || length(fips) == 0) {
    ## handle NA or length 0 ####
    urlx <- ifna
    return(urlx) # length is 0   # or # return(NULL)  ??
  }
  ################ #

  if (  is.null(fips) || length(fips) == 0) {
    return(ifna)
    # return(NULL)
  }
  # Could check if site or API is available?

  # if (missing(year) && year != as.numeric(substr(Sys.Date(), 1, 4))) {
  #   warning("default year is ", year, " but newer data might be available")
  # }
  ######################## #  ######################## #

  ## > MAKE URL ####

  url_eq_county_in_county_out = function(fips,  as_html) {
    if (is.null(fips) || length(fips) == 0) {return(NA)}

    #statename  <- tolower(fips2statename( fips))
    #countyname <- tolower(fips2countyname(fips, includestate = ""))
    # countyname <- trimws(gsub(" county", "", countyname))
    #  countyname <- gsub(" ", "-", countyname)

    urlx <- paste0(baseurl, "/?geo=040000000000", fips) #, "?year=", year)
    urlx[is.na(fips)  ] <- NA
    return(urlx)
  }
  ################ #
  url_eq_state_in_state_out <- function(fips, as_html) {
    if (is.null(fips) || length(fips) == 0) {return(NA)}
    #statename <- tolower(fips2statename(fips))
    # statename <- gsub(" ", "-", statename)

    urlx <- paste0(baseurl, "/?geo=040000000000", fips, "000") #, "?year=", year)
    urlx[is.na(fips)] <- NA
    return(urlx)
  }
  ################ #

  urlx <- rep(ifna, length(fips))
  # now all should be state (or NA); or else all are county (or NA)

  if (statereport) {
    urlx <- url_eq_state_in_state_out(fips, as_html = as_html)
  } else {
    urlx <- url_eq_county_in_county_out(fips, as_html = as_html)
  }
  ######################## #  ######################## #

  ### NAs ####
  ok <- !is.na(fips)
  urlx[!ok] <- ifna
  ok <- !is.na(urlx)  # now !ok mean it was a bad input and also  ifna=NA
  ### as_html ####
  if (as_html) {
    urlx[ok] <- URLencode(urlx[ok]) # consider if we want  reserved = TRUE
    urlx[ok] <- url_linkify(urlx[ok], text = linktext)
  }
  urlx[!ok] <- ifna # only use non-linkified ifna for the ones where user set ifna=NA and it had to use ifna
  return(urlx)
}
######################################################################### #


#' URL functions - Get URLs of useful report(s) on STATE containing the given fips, from equity atlas
#'
#' @inheritParams url_county_equityatlas
#' @param statereport Do not use directly. passed to [url_county_equityatlas()].
#'
#' @param ... unused
#'
#' @return vector of URLs to reports on enclosing states (or generic link if fips invalid)
#' @examples
#'  url_county_equityatlas(fips_counties_from_state_abbrev("DE"))
#'  # browseURL(url_county_equityatlas(fips_counties_from_state_abbrev("DE"))[1])
#'
#' @export
#'
url_state_equityatlas <- function(fips = NULL,
                                  sitepoints = NULL, lat = NULL, lon = NULL,
                                  shapefile = NULL,
                                  as_html = FALSE,
                                  linktext = "State (Equity Atlas)",
                                  ifna    = "https://nationalequityatlas.org",
                                  baseurl = "https://nationalequityatlas.org/research/data_summary",

                                  statereport = TRUE,
                                  ...) {
  url_county_equityatlas(
    fips = fips,
    sitepoints = sitepoints, lat = lat, lon = lon,
    shapefile = shapefile,
    as_html =  as_html,
    linktext = linktext,
    ifna    = ifna,
    baseurl = baseurl,

    statereport = statereport,
    ...)
}
################################################################################################################################################# #

# . ---------------------------------------------------- ####


######################################################################### #
## not site-specific ####
######################################################################### #


#' URL functions - url_naics.com - Get URL for page with info about industry sectors by text query term
#' @details
#' See (https://naics.com) for more information on NAICS codes.
#'
#' Unlike url_xyz() functions, which provide a unique link for each site,
#' this url_ function provides just a link for a whole industry or set of industries based on a query,
#' so it is not meant to be used in a column of site by site results the way the other url_xyz() functions are.
#'
#' @param query string query term like "gasoline" or "copper smelting"
#'
#' @param as_html Whether to return as just the urls or as html hyperlinks to use in a DT::datatable() for example
#' @param linktext used as text for hyperlinks, if supplied and as_html=TRUE
#' @param ifna URL shown for missing, NA, NULL, bad input values
#' @param baseurl do not change unless endpoint actually changed
#' @param ... unused
#'
#' @return URL as string
#'
#' @export
#'
url_naics.com <- function(query = "",
                          as_html = FALSE,
                          linktext = query, # "NAICS.com",
                          ifna = "https://www.naics.com",
                          baseurl = "https://www.naics.com/code-search/?trms=",
                          ...) {

  if (is.null(query) || length(query) == 0) {return(ifna)}

  # Could check if site or API is available?

  query <- gsub(" ", "+", query)
  urlx = paste0(baseurl, query, "&v=2017&styp=naics")

  if (as_html) {
    if (is.null(linktext)) {linktext <- query}
    urlx <- url_linkify(urlx, text = linktext)
  }
  urlx[query %in% "" | is.na(query)] <- ifna
  return(urlx)
}
######################################################################### #


#' utility to view rendered .html file stored in a github repo
#'
#' @param ghurl URL of HTML file in a github repository
#' @param launch_browser set FALSE to get URL but not launch a browser
#'
#' @returns URL
#' @examples
#' url_github_preview(fold = "docs", file = "index.html", launch_browser = F)
#' url_github_preview(fold = "docs/reference", file = "ejam2excel.html", launch_browser = F)
#'
#' #   Compare versions of the HTML summary report:
#'
#' myfile = "testoutput_ejam2report_100pts_1miles.html"
#' \dontrun{
#' # in latest main branch on GH (but map does not render using this tool)
#' url_github_preview(file = myfile)
#'
#' # from a specific release on GH (but map does not render using this tool)
#' url_github_preview(ver = "v2.32.5", fold = "inst/testdata/examples_of_output", file = myfile)
#'
#' # local installed version
#' browseURL( system.file(file.path("testdata/examples_of_output", myfile), package="EJAM") )
#'
#' # local source package version in checked out branch
#' browseURL( file.path(testdatafolder(installed = F), "examples_of_output", myfile) )
#' }
#'
#' @keywords internal
#' @export
#'
url_github_preview = function(ghurl = NULL,
                              repo = "https://github.com/ejanalysis/EJAM",
                              blob = "blob",
                              ver = "main", # or "v2.32.5"
                              fold = "inst/testdata/examples_of_output", # or "docs/reference"
                              file = "testoutput_ejam2report_10pts_1miles.html",
                              launch_browser = TRUE
) {

  if (is.null(ghurl)) {
    # repo = "https://github.com/ejanalysis/EJAM"
    # blob = "blob"
    # ver = "main" # or "v2.32.5"
    # fold = "inst/testdata/examples_of_output" # or "docs/reference"
    # file = "testoutput_ejam2report_10pts_1miles.html"

    ghurl <- file.path(repo, blob, ver, fold, file)
  }
  urlx <- paste0("http://htmlpreview.github.io/?", ghurl)

  if (launch_browser) {browseURL(urlx[1])}
  return(urlx)

}
######################################################################### #
