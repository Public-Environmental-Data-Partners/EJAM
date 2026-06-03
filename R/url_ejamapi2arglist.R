
url_ejamapi2arglist = function(xurl, add_others = FALSE) {

  # convert URL-encoded API call to a list of arguments that could used by ejamit(), e.g.
  #
  # extracts ejamit() or similar-style parameters from the url-encoded API call
  # converts any csv-format keyvalue into a argument that is a vector, like for lat or lon.
  # returns a named list of arguments:
  #
  # radius (aka buffer)
  # shapefile (aka shape)
  # fips
  # lat, lon
  # sitepoints (based on lat,lon if available)
  #
  # OTHERS ?

  param_info = list(
    lat = "lat",
    lon = "lon",
    # sitepoints = "sitepoints",
    # shapefile = "shape",
    fips = "fips",
    radius = "buffer",
    version = "version"

  )
  params = list() # alist(names(param_info))
  ###################### #
  if (missing(xurl)) {
    cat("using example url \n")
    xurl2 =  "https://ejamapi-84652557241.us-central1.run.app/report?shape={%22type%22:%22FeatureCollection%22,%22features%22:[{%22type%22:%22Feature%22,%22properties%22:{},%22geometry%22:{%22coordinates%22:[[[-75.819743,38.977676],[-75.792277,38.979811],[-75.791591,38.955253],[-75.827983,38.956321],[-75.819743,38.977676]]],%22type%22:%22Polygon%22}}]}&buffer=0"
    xurl = url_ejamapi(testpoints_10[1:2,], radius=3.14, sitenumber = "overall")
  }
  ###################### #
  csv2vector <- function(csv) {
    v = unlist(strsplit(csv, ","))
    v = trimws(v)
    return(v)
  }
  getp = function(pname, keyname = pname, q) {
    if (keyname %in% names(q)) {
      return(csv2vector(q[[keyname]]))
    } else {
      return(NULL) # does not work  ***  #  maybe return key ones as NULL if not provided: ??? ***
    }
  }
  ###################### #
  req_info = httr2::url_parse(xurl)
  q = req_info$query

  for (i in seq_along(param_info)) {
    params[[names(param_info)[i]]] <- getp(names(param_info)[i], param_info[[i]], q = q)
  }
  ###################### #
  # special parsing beyond just csv text

  # assumes lat,lon but not sitepoints were keys in URL
  if (!is.null(params$lat)) {
    params$sitepoints = data.frame(lat = params$lat, lon = params$lon)
  } else {
    params$sitepoints = NULL
  }

  # assumes any polygons were encoded as text string geojson
  if ("shape" %in% names(q)) {
    params$shapefile = shapefile_from_geojson_text(q$shape  )
  } else {
    if ("shapefile" %in% names(q)) {
      params$shapefile = shapefile_from_geojson_text(q$shape  )
    } else {
      params$shapefile <- NULL
    }
  }

  ###################### #
  if (add_others) {
  otherkeynames = setdiff(names(q), as.vector(unlist(param_info)))
  OTHERS = q[[otherkeynames]]
  params = c(params, OTHERS)
  }
  return(params)
}
