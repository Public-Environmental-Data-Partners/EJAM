

#' Get URL(s) of HTML summary reports for use with EJAM-API
#' @details
#' - Work in progress - initial draft relied on API from
#'   https://github.com/edgi-govdata-archiving/EJAM-API
#'
#'   (see parameter `baseurl` that used the /report endpoint)
#'
#' - Another option in the future might be to construct a URL that is a link to the live EJAM
#'   app but has url-encoded parameters that are app settings, such as sitepoints, radius_default, etc.
#'
#' - Will try to use the same input parameters as [ejamit()] does.
#'
#' @param sitepoints see [ejamit()]
#' @param lat,lon can be provided as vectors of coordinates instead of providing sitepoints table
#' @param radius  see [ejamit()], default is 0 if fips or shapefile specified
#'
#' @param fips  see [ejamit()] but this initial version only works for a blockgroup FIPS!
#'
#' @param shapefile  see [ejamit()], but each polygon is encoded as geojson string
#'   which might get too long for encoding in a URL for the API using GET
#' @param dTolerance number of meters tolerance to use in [sf::st_simplify()] to simplify polygons to fit as url-encoded text geojson
#'
#' @param as_html Whether to return as just the urls or as html hyperlinks to use in a DT::datatable() for example
#' @param linktext used as text for hyperlinks, if supplied and as_html=TRUE
#' @param ifna URL shown for missing, NA, NULL, bad input values
#' @param baseurl do not change unless endpoint actually changed
#'
#' @param sitenumber
#'
#'  - "each" (or -1) means return each site's URL
#'
#'  - "overall" (or 0) means return one URL, combining all sites
#'
#'  - N (a number > 0) means return just the Nth site's URL
#'
#'  Like with other url_xyz functions, the default is to output
#'   a vector of URLs, one per site. The default value for sitenumber is
#'   "each" or -1 which means we want one url for each site.
#'   Note there is no comparable value of sitenumber in the ejam2report() or ejam2map() or similar functions,
#'   which never return a vector of reports, maps, etc. Getting a vector of 1 per site is useful mainly for
#'   the url_xyz functions like url_ejamapi().
#'
#'   Like the sitenumber parameter in [ejam2report()],
#'   a value of NULL or 0 or "" or "overall" in url_ejamapi() means
#'   a single URL is returned that requests one
#'   overall summary report (assuming >1 sites were provided).
#'
#'   Specifying sitenumber as a number like 3 means a report based on the third site
#'   found in the inputs (third point or third fips or third polygon).
#'
#' @param ... a named list of other query parameters passed to the API,
#'   to allow for expansion of allowed parameters
#'
#' @returns vector of character string URLs -- see details on sitenumber parameter
#'
#' @examples
#'
#'  pts = data.frame(lat=37.64122, lon=-122.41065)
#'  pts2 = data.frame(lat = c(37.64122, 43.92249), lon = c(-122.41065, -72.663705))
#'  pts10 = testpoints_10
#'  pts_fname = system.file("testdata/latlon/testpoints_10.xlsx", package="EJAM")
#'
#'   # vector of 1-site report URLs
#'  x = url_ejamapi(pts_fname)
#'  x = url_ejamapi(sitepoints = pts2)
#'  x_bysite = url_ejamapi(pts10, radius = 3.1, sitenumber = "each")
#'
#'  ## 1 summary report URL - may not be implemented yet
#'  # x_overall = url_ejamapi(pts10, radius = 3.1, sitenumber = "overall")
#'
#'  # FIPS Census units
#'  y = url_ejamapi(fips = c("050014801001", "050014802001"))
#'  ## blockgroups may not be implemented yet
#'  # y = url_ejamapi(fips = testinput_fips_mix)
#'
#'  # Polygons
#'  shp = testinput_shapes_2[2, c("geometry", "FIPS", "NAME")]
#'  z = url_ejamapi(shapefile = shp)
#'
#'  \dontrun{
#'  browseURL("https://ejamapi-84652557241.us-central1.run.app/report?lat=33&lon=-112&buffer=4")
#'
#'  browseURL(x[1])
#'  browseURL(y[1])
#'  browseURL(z[1])
#' }
#'
#'
#' @export
#'
url_ejamapi = function(

  sitepoints = NULL, lat = NULL, lon = NULL,
  radius = 3,

  ## unused so far:
  # radius_donut_lower_edge = 0,
  # maxradius = 31.07,
  # avoidorphans = FALSE,
  # quadtree = NULL, # not relevant

  fips = NULL,
  shapefile = NULL,
  dTolerance = 100, # 100 meters tolerance to simplify polygons to fit as url-encoded text geojson

  ## unused so far:
  # countcols = NULL,
  # wtdmeancols = NULL,
  # calculatedcols = NULL,
  # calctype_maxbg = NULL,
  # calctype_minbg = NULL,
  # subgroups_type = "nh",
  # include_ejindexes = TRUE,
  # calculate_ratios = TRUE,
  # extra_demog = TRUE,
  # need_proximityscore = FALSE,
  # infer_sitepoints = FALSE,
  # need_blockwt = TRUE,

  # thresholds = list(80, 80),
  # threshnames = list(c(names_ej_pctile, names_ej_state_pctile), c(names_ej_supp_pctile, names_ej_supp_state_pctile)),
  # threshgroups = list("EJ-US-or-ST", "Supp-US-or-ST"),

  # updateProgress = NULL,
  # updateProgress_getblocks = NULL,
  # progress_all = NULL,
  # in_shiny = FALSE,
  # quiet = TRUE,
  # silentinteractive = FALSE,
  # called_by_ejamit = TRUE,
  # testing = FALSE,
  # showdrinkingwater = TRUE,
  # showpctowned = TRUE,
  # download_city_fips_bounds = TRUE,
  # download_noncity_fips_bounds = FALSE,

  linktext = "Report",
  as_html = FALSE,
  ifna = "https://ejanalysis.com",
  baseurl = "https://ejamapi-84652557241.us-central1.run.app/report?",

  sitenumber = "each",

  ...
) {

  ## unused so far:
  {
    xxx = "
  @param radius_donut_lower_edge
  @param maxradius
  @param avoidorphans
  @param quadtree

  @param countcols
  @param wtdmeancols
  @param calculatedcols
  @param calctype_maxbg
  @param calctype_minbg
  @param subgroups_type
  @param include_ejindexes
  @param calculate_ratios
  @param extra_demog
  @param need_proximityscore
  @param infer_sitepoints
  @param need_blockwt
  @param thresholds
  @param threshnames
  @param threshgroups
  @param updateProgress
  @param updateProgress_getblocks
  @param progress_all
  @param in_shiny
  @param quiet
  @param silentinteractive
  @param called_by_ejamit
  @param testing
  @param showdrinkingwater
  @param showpctowned
  @param download_city_fips_bounds
  @param download_noncity_fips_bounds
  "
  }
  if (is.null(linktext)) {linktext <- paste0("Report")}
  # print( rlang::list2(...) )
  ###################### #
  #   ... args  ####
  and_other_query_terms = urls_from_keylists(keylist_bysite = ..., baseurl = "")
  if (length(and_other_query_terms) > 0 && !(all(and_other_query_terms %in% ""))) {and_other_query_terms <- paste0("&", and_other_query_terms)}
  ################################################## #  ################################################## #
  if (is.null(baseurl)) {
    baseurl <- "https://ejamapi-84652557241.us-central1.run.app/report?"
  }
  if (is.null(ifna)) {
    ifna <- "https://ejanalysis.com"
  }
  # see https://github.com/edgi-govdata-archiving/EJAM-API/tree/main
  # baseurl = "https://ejamapi-84652557241.us-central1.run.app/report?"
  # e.g.,
  # https://ejamapi-84652557241.us-central1.run.app/report?lat=33&lon=-112&buffer=4
  ################################################## #  ################################################## #

  ################################################## #  sitetype  --------------------- -
  # sitetype ####
  # and convert any lat,lon to sitepoints
  sites <- sites_from_input(sitepoints = sitepoints, lat = lat, lon = lon, fips = fips, shapefile = shapefile)
  sitepoints <- sites$sitepoints
  shapefile <- sites$shapefile
  fips <- sites$fips
  sitetype <- sites$sitetype

  # regid_from_input ####
  # handle case where only regid is provided, not the actual sitepoints,
  # so use regid as a last resort way to get latlon
  ## latlon_from_regid ####
  if (is.null(sites$sitetype)) {
    dotsargs = rlang::list2(...)
    if ("regid" %in% names(dotsargs)) {regid <- dotsargs$regid} else {regid = NULL}
    if  ("sitepoints" %in% names(dotsargs)) {sitepoints <- dotsargs$sitepoints} else {sitepoints = NULL}
    regid <- regid_from_input(regid=regid, sitepoints=sitepoints) # here we only want it as a way to get lat,lon not to use the regid as in echo or frs report
    if (!is.null(regid)) {
      sites <- list(
        sitepoints =  latlon_from_regid(regid),
        sitetype = "latlon"
      )
      sitetype <- "latlon"
    }
  }
  ################################################## #  sitenumber --------------------- -

  # sitenumber (overall vs 1-site) ####

  # N  means Nth site report
  # -1 means "overall" report
  # 0  means "each" site report, in a vector of URLs

  if (length(sitenumber) > 1) {stop("invalid value for sitenumber")}
  if (is.null(sitenumber) || all(is.na(sitenumber)) || length(sitenumber) == 0 || all(sitenumber %in% "") || sitenumber %in% c(0, "0", "overall")) {
    sitenumber <- 0  # "overall"
    # provide all the sites in one URL, and pass sitenumber=0 to the API

  } else {
    if (sitenumber %in% c("each", -1)) {
      # provide vector of urls, 1 site in each, and do not pass any sitenumber parameter to the API (since saying sitenumber=1 for each would be confusing)
      sitenumber <- -1  # each site (vector of URLs)
    } else {
      # return only 1 URL, 1 of the sites, and do not pass any sitenumber parameter to the API (since we only send site N to the API so it would be confusing to pass site 3 and have to tell the API it is site 1 of what was passed)
      sitenumber <- as.numeric(sitenumber)  # Nth site
    }
  }
  ###################################### #  shapefile  ###################################### #
  # > shapefile ####
  if ("shp" %in% sitetype) {

    if (missing(radius) || is.null(radius) || all(radius %in% c(0, "", NA))) {radius <- 0}
    # geojson format
    # %7B"type"%3A"FeatureCollection"%2C"features"%3A%5B%7B"type"%3A"Feature"%2C"properties"%3A%7B%7D%2C"geometry"%3A%7B"coordinates"%3A%5B%5B%5B-112.01991856401462%2C33.51124624304089%5D%2C%5B-112.01991856401462%2C33.47010908826502%5D%2C%5B-111.95488826248605%2C33.47010908826502%5D%2C%5B-111.95488826248605%2C33.51124624304089%5D%2C%5B-112.01991856401462%2C33.51124624304089%5D%5D%5D%2C"type"%3A"Polygon"%7D%7D%5D%7D

    if (NROW(shapefile) ==  1) {sitenumber <- 1} # treat like a single site report, using results_bysite[1, ]

    if ("shp" %in% sitetype) {
      # if (!is.null(shapefile)) {
      bad <-  (sf::st_is_empty(shapefile))

      if (sitenumber == 0) {
        # overall 1 URL: provide all the sites in one URL, and pass sitenumber=0 to the API
        # remove empty geography rows first
        if (any(!bad)) {
        geotxt <- shape2geojson(
          sf::st_simplify(shapefile[!bad,], dTolerance = dTolerance), # SIMPLIFY POLYGONS to fit as url-encoded text
          combine_in_one_string = TRUE) # overall summary multisite report
        } else {
          geotxt <- NA
        }
      }
      if (sitenumber > 0) {
        # 1 site's URL:  return only 1 URL, 1 of the sites, and do not pass any sitenumber parameter to the API (since we only send site N to the API so it would be confusing to pass site 3 and have to tell the API it is site 1 of what was passed)
        if (bad[sitenumber]) {
          geotxt <- NA
        } else {
          geotxt <- shape2geojson(
            sf::st_simplify(shapefile[sitenumber, ], dTolerance = dTolerance), # SIMPLIFY POLYGONS to fit as url-encoded text
            combine_in_one_string = FALSE) # 1-site report
        }
        sitenumber <- "" # now omit this from the URL used in API
      }
      if (!is.null(sitenumber) && -1 %in% sitenumber) {
        # "each" site's URL: provide vector of urls, 1 site in each, and do not pass any sitenumber parameter to the API (since saying sitenumber=1 for each would be confusing)
        geotxt <- shape2geojson(
          sf::st_simplify(shapefile, dTolerance = dTolerance), # SIMPLIFY POLYGONS to fit as url-encoded text
          combine_in_one_string = FALSE) # 1-site reports as a vector
        if (any(bad)) {
        geotxt[bad] <- NA
        }
        sitenumber <- NULL # now omit this from the URL used in API
      }

      url_of_report <- paste0(
        urls_from_keylists(
          baseurl = baseurl,
          keylist_bysite = list(shape=geotxt, buffer=radius, sitenumber=sitenumber)
        ), and_other_query_terms
      )
      # url_of_report <- paste0(
      #   baseurl,
      #   "shape=", geotxt, "&",
      #   "buffer=", radius, "&",
      #   "sitenumber=", sitenumber, #
      #   and_other_query_terms
      # )
      url_of_report[is.na(geotxt)] <- NA # later will convert to ifna
    } else {
      url_of_report <- NA # later will convert to ifna
    }
  } else {
    ###################################### # fips  ###################################### #
    # > fips #####
    if ("fips" %in% sitetype) {
      if (missing(radius) || is.null(radius) || all(radius %in% c(0, "", NA))) {radius <- 0}

      # suppressWarnings({
      #   ftype <- fipstype(fips)
      # })
      # if (!all(ftype %in% "blockgroup")) {
      #   # warning("fips other than blockgroup may be work in progress")
      # }
      if (!is.null(fips)) {

        if (NROW(fips) == 1) {sitenumber <- 1} # treat like a single site report, using results_bysite[1, ]

        if (sitenumber == 0) {
          # overall 1 URL: provide all the sites in one URL, and pass sitenumber=0 to the API
          fips <- paste0(fips, collapse = ",") ## *** check this is the expected format in the API
        }
        if (sitenumber > 0) {
          # 1 site's URL:  return only 1 URL, 1 of the sites, and do not pass any sitenumber parameter to the API (since we only send site N to the API so it would be confusing to pass site 3 and have to tell the API it is site 1 of what was passed)
          fips <- fips[sitenumber]  # 1-site report
          sitenumber <- "" # now omit this from the URL used in API
        }
        if (1 %in% sitenumber) {
          # "each" site's URL: provide vector of urls, 1 site in each, and do not pass any sitenumber parameter to the API (since saying sitenumber=1 for each would be confusing)
          # 1-site reports as a vector
          sitenumber <- "" # now omit this from the URL used in API
        }

        url_of_report <- paste0(
          urls_from_keylists(
            baseurl = baseurl,
            keylist_bysite = list(fips=fips, buffer=radius, sitenumber=sitenumber)
          ), and_other_query_terms
        )
        # url_of_report <- paste0(
        #   baseurl,
        #   "fips=", fips, "&",
        #   "buffer=", radius, "&",
        #   "sitenumber=", sitenumber,
        #   and_other_query_terms
        # )
        #
        url_of_report[is.na(fips)] <- NA # later will convert to ifna
        # url_of_report[!(ftype %in% "blockgroup")] <- NA
      } else {
        url_of_report <- NA # later will convert to ifna
      }
    } else {
      ###################################### # sitepoints  ###################################### #
      # > sitepoints ####
      if ("latlon" %in% sitetype) {

        if (NROW(sitepoints) == 1) {sitenumber <- 1} # treat like a single site report, using results_bysite[1, ]

        if (sitenumber == 0) {
          # overall 1 URL: provide all the sites in one URL, and pass sitenumber=0 to the API
          x <- sitepoints
          # x <- latlon_from_anything(sitepoints, interactiveprompt = F) # do we want this actually ?? see notes in sites_from_input() and related
          lat <- x$lat
          lon <- x$lon
          lat <- paste0(lat, collapse = ",")
          lon <- paste0(lon, collapse = ",")
        }
        if (sitenumber > 0) {
          # 1 site's URL:  return only 1 URL, 1 of the sites, and do not pass any sitenumber parameter to the API (since we only send site N to the API so it would be confusing to pass site 3 and have to tell the API it is site 1 of what was passed)
          x <- sitepoints[sitenumber, , drop = FALSE]  # 1-site report
          sitenumber <- "" # now omit this from the URL used in API
          lat <- x$lat
          lon <- x$lon
        }
        if (sitenumber == -1) {
          # "each" site's URL: provide vector of urls, 1 site in each, and do not pass any sitenumber parameter to the API (since saying sitenumber=1 for each would be confusing)
          # 1-site reports as a vector
          x <- sitepoints
          sitenumber <- "" # now omit this from the URL used in API
          lat <- x$lat
          lon <- x$lon
        }

        if (!is.null(lat) && !is.null(lon)) {
          url_of_report <- paste0(
            urls_from_keylists(
              baseurl = baseurl,
              keylist_bysite = list(lat=lat, lon=lon, buffer=radius, sitenumber=sitenumber)
            ), and_other_query_terms
            )
          # url_of_report <- paste0(
          #   baseurl,
          #   "lat=", lat, "&",
          #   "lon=", lon, "&",
          #   "buffer=", radius, "&",
          #   "sitenumber=", sitenumber,
          #   and_other_query_terms
          # )
          url_of_report[is.na(lat) | is.na(lon)] <- NA # later will convert to ifna
        } else {
          url_of_report <- NA # later will convert to ifna
        }
      } else {
        ###################################### # none of the above  ###################################### #
        url_of_report <- NA # later will convert to ifna
      }
    }
  }
  ###################### #

  urlx <- url_of_report
  ok <- !(is.na(urlx)) # so !ok means bad/NA
  # urlx[ok] <- paste0(urlx[ok], and_other_query_terms) # "&", other_query_terms)   # already done now

  ###################### #
  # default URL if bad ####
  # use a default URL if bad input, and only linkify when not NA

  urlx[!ok] <- ifna  # possibly user set ifna to NA or else it is a default url
  ok <- !is.na(urlx)  # now ok means it was a good  input or bad input, except if ifna was set to NA, that is not ok so we can avoid urlencoding that type of NA !

  if (as_html) {
    urlx[ok] <- URLencode(urlx[ok]) # consider if we want  reserved = TRUE ***
    urlx[ok] <- url_linkify(urlx[ok], text = linktext)
  }
  urlx[!ok] <- ifna # only use non-linkified ifna for the ones where user set ifna=NA and it had to use ifna

  return(urlx)
}
################################################### #################################################### #
