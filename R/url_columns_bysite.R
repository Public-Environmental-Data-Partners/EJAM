
#' URL functions - Compile URLs in columns, for EJAM
#'
#' @details used in [table_xls_format()], and server, to create hyperlinks to reports or webpages, one per site
#'
#' @param sitepoints data.frame or data.table with lat and lon columns
#'   (and should have ejam_uniq_id column or assume 1 output row per input row, same order)
#' @param lat,lon if sitepoints NULL/missing, vectors of latitudes and longitudes
#'   (assumes ejam_uniq_id is not available and treats output as 1 per input same order)
#'
#' @param shapefile spatial data.frame, class sf, see ejamit() parameter of same name.
#'   (and should have ejam_uniq_id column or assume 1 output row per input row, same order)
#'
#' @param fips vector of FIPS codes if relevant  (instead of sitepoints or shapefile input)
#'   Note that nearly half of all county fips codes are impossible to distinguish from
#'   5-digit zipcodes because the same numbers are used for both purposes.
#'
#' @param wherestr optional because inferred from fips if provided.
#'   Passed to [url_ejscreenmap()] and can be name of city, county, state like
#'   from fips2name(201090), or "new rochelle, ny" or "AK"
#'   or even a zip code, but NOT a fips code! (for FIPS, use the fips parameter instead).
#'   Note that nearly half of all county fips codes are impossible to distinguish from
#'   5-digit zipcodes because the same numbers are used for both purposes.
#'
#' @param regid optional vector of FRS registry IDs if available to use to create links
#'   to detailed ECHO facility reports
#'
#' @param radius vector of values for radius in miles
#'
#' @param reports optional list of lists specifying which report types to include --
#'   see the file "global_defaults_package.R" or source code for this function for how this is defined.
#'
#' @param sitetype optional "latlon" or "shp" or "fips" but can be inferred from other params
#'
#' @param as_html Whether to return as just the urls or as html hyperlinks to use in a DT::datatable() for example
#'   passed to [url_ejamapi()], [url_ejscreenmap()], or other url_xyz report functions.
#'
#' @param validate_regids if set TRUE, returns NA where a regid is not found in the FRS dataset that is
#'   currently being used by this package (which might not be the very latest from EPA).
#'   If set FALSE, faster since avoids checking but some links might not work and not warn about bad regid values.
#'
#' @param ... passed to each function, and can be any parameter that any of them uses
#'
#' @examples
#' x =  EJAM:::url_columns_bysite(testpoints_10[1:2,], radius = 1)
#'
#' x =  EJAM:::url_columns_bysite(
#'   data.frame(lat=1:2, lon=101:102), radius = 1,
#'   INFO_FOR_SITE2 = c(NA, "site2"),
#'   Place1info = c("North", ""),
#'   keylist_bysite = list(newkey_all_sites = "YES",
#'                         site_name = c("NRO", "CRS"))
#'   )
#' EJAM:::unlinkify(x[[2]])
#' x = x[[1]]
#' x = x[, "EJAM Report"]
#' EJAM:::unlinkify(x)
#'
#' @seealso  [url_ejamapi()] [url_ejscreenmap()] [url_echo_facility()]
#' @return list of data.frames to append to the list of data.frames created by
#'   [ejamit()] or [doaggregate()]
#'
#' @keywords internal
#'
url_columns_bysite <- function(sitepoints = NULL, lat = NULL, lon = NULL,
                               shapefile = NULL,
                               fips = NULL, wherestr = "",
                               regid = NULL, # see details
                               radius = NULL,

                               reports = EJAM:::global_or_param("default_reports"),

                               sitetype = NULL,
                               as_html = TRUE,
                               validate_regids = FALSE,
                               ...) {

  # Note that various settings passed to ejamit() are so far ignored by EJAM-API (and old ejscreen api), so results of API will often differ from actual results!!
  # message("API providing links to EJSCREEN/EJAM reports so far ignore most parameters that ejamit() does allow (and allow only blockgroup fips), so the link-based html report may differ from the actual ejamit() results_bysite table info!!")

  # clean/check inputs and sitetype

  if (is.null(lat) && is.null(lon) && is.null(shapefile) && is.null(fips) && !("" %in% wherestr) && !is.null(wherestr)) {
    fips <- fips_from_name(wherestr) # old ejscreen api used wherestr not fips so this is in case that is the only thing provided here
  }

  sites <- sites_from_input(sitepoints = sitepoints, lat = lat, lon = lon, shapefile = shapefile, fips = fips)
  sitepoints <- sites$sitepoints
  sitetype <- sites$sitetype

  # get regid
  #    -  uses regid in some functions but I don't think only regid would ever  be the sole input
  if (!missing(regid) && !is.null(regid)) {
    # regid <- regid
  } else {
    if ("REGISTRY_ID" %in% names(sitepoints)) {
      regid <- sitepoints$REGISTRY_ID
    } else {
      regid <- NULL
    }
  }

  if (is.null(sitetype)
      # && is.null(regid)
  ) {
    warning("cannot infer sitetype, must be one of 'latlon', 'fips', or 'shp'")
    # return all NA values?   but unclear how many rows worth.  # return(NA)   ***
    return(list(
      results_bysite  = NA, # this may not work, actually but should not arise ***
      results_overall = NA # this may not work, actually but should not arise ***
    ))
  }

  ######################################################################################### #
  # handle any list of functions that provide report URLs from this set of input params
  ######################################################################################### #

  # I don't think only regid would ever  be the sole input
  if ("fips" %in% sitetype)   {rowcount <- NROW(fips)}
  if ("shp" %in% sitetype)    {rowcount <- NROW(shapefile)}
  if ("latlon" %in% sitetype) {rowcount <- NROW(sitepoints)}

  # reports <- EJAM:::global_or_param("default_reports") # list of reports, each a named lists of info like header, text, & FUN.
  if (is.null(reports)) {
    reports <-  list(
      list(header = "EJAM Report",     text = "Report",   FUN = url_ejamapi)      # EJAM summary report (HTML via API)
      , list(header = "EJSCREEN Map",  text =  "EJSCREEN", FUN = url_ejscreenmap) # EJSCREEN site, zoomed to the location
      # , list(header = "ECHO Report",         text = "ECHO",         FUN = url_echo_facility) # if regid provided
      # , list(header = "FRS Report",          text =  "FRS",         FUN = url_frs_facility)            # if regid provided
      # , list(header = "EnviroMapper Report", text = "EnviroMapper", FUN = url_enviromapper)          # if lat,lon provided
      # , list(header = "County Health Report",       text = "County",       FUN = url_county_health)  # if fips provided
      # , list(header = "State Health Report",       text = "State",       FUN = url_state_health)  # if fips provided
    )
  }
  links <- data.frame(matrix(NA, nrow = rowcount, ncol = length(reports)))
  url_functions <- lapply(reports, function(x) (x$FUN))
  ## The input parameter defaults of url_columns_bysite() ensure all possible parameter names listed below exist and can be passed from here, and are NULL if not specified by the analysis calling url_columns_bysite().
  ## The ... parameter(s) in every report-generating FUN ensures any params not needed by a given FUN can be passed to it from here and just get ignored for that type of report.

  for (i in seq_along(reports)) {
    links[, i] <- url_functions[[i]](

      sitetype   = sitetype,
      radius = radius,
      sitepoints = sitepoints, # and if lat,lon had been specified above, they already got turned into sitepoints.
      shapefile = shapefile,
      fips = fips,
      wherestr = wherestr, # maybe not needed
      regid = regid,
      as_html = as_html, linktext = reports[[i]]$text,
      validate_regids = validate_regids,
      ... = ...
    )
  }
  colnames(links) <- sapply(reports, function(x) (x$header))

  results_overall <- links[1, , drop=FALSE]
  if (NROW(links) == 1) {
    # ok, it was for one site so leave overall the same as that one site instead of providing the generic URLs?
  } else {

    for (i in seq_along(reports)) {
      results_overall[, i] <- url_functions[[i]](

        ## use NULL or NA values here to get all the url_xyz() functions to return their ifna values, generic URLs for each service/report type.

        sitetype   = sitetype[1],
        radius = radius[1],
        sitepoints = NULL,
        shapefile = NULL,
        fips = NULL,
        regid = NULL,
        # wherestr = wherestr, # maybe not needed
        as_html = as_html,
        linktext = reports[[i]]$text,
        validate_regids = FALSE)
    }
    # results_overall[1, 1] <-  NA #  once API supports this, we could create link  to summary report overall, at least for that 1 column ***
  }

  return(list(
    results_bysite  = links,
    results_overall = results_overall
  ))

}
################################################ #  ################################################ #
################################################ #  ################################################ #
