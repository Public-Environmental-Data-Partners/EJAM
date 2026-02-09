
#################### #

#' helper - given filename, figure out type and return list of input params for ejamit()
#' Do not actually read file but get list of sitepoints, fips, shapefile args to pass to ejamit()
#'
#' @param file a file name (with path) to look at
#'
#' @return named list, with sitepoints, fips, shapefile as names
#' @seealso [sites_from_input()]
#'
#' @keywords internal
#'
sites_from_file <- function(file) {

  selected_pathfile <- file
  # infer type
  filetype <- sitetype_from_filepath(selected_pathfile)

  # sitepoints = NULL # actually should be missing if not applicable
  fips = NULL
  if (filetype == "latlon") {
    sitepoints <- selected_pathfile
    shapefile = NULL
    fips = NULL
  }
  if (filetype == "shp") {
    sitepoints = NULL
    shapefile <- selected_pathfile
    fips = NULL
  }
  if (filetype == "fips") {
    sitepoints = NULL
    shapefile = NULL
    fipstable <- read_csv_or_xl(fname = basename(selected_pathfile), path = dirname(selected_pathfile))
    fips <- fips_from_table(fips_table = fipstable)
  }

  return(list(sitepoints = sitepoints, fips = fips, shapefile = shapefile))

  ## if we had to omit sitepoints instead of it being null
  # if (is.null(sitepoints)) {
  #   return(list(fips = fips, shapefile = shapefile))
  # } else {
  #   return(list(sitepoints = sitepoints, fips = fips, shapefile = shapefile))
  # }
}
#################### #

# helper for sites_from_file()

sitetype_from_filepath <- function(filepath) {

  # helper utility - what kind of file is it? (latlon, fips, shp)
  # try to infer the type of data provided by the file as a valid input to ejamit() parameters sitepoint or fips or shp
  ext <- tools::file_ext(filepath)
  if (ext %in% c("xlsx", "xls", "csv")) {
    # either fips or latlon...

    # must read it to know if fips or latlon!?
    # sitepoints_from_any() using  latlon_from_anything() should be able to obtain lat lon directly or via addresses geocoded

    mytable = read_csv_or_xl(filepath)
    # fips <- fips_from_table()
    seems_like_fips <- FALSE


    if (seems_like_fips) {
      return("fips")
    } else {
      return("latlon")
    }
  } else if (ext %in% c("zip", "gdb", "geojson", "json", "kml", "shp")) {
    # not shx dbf prj cpg
    return("shp")
  } else {
    stop(paste0("File type not recognized: ", ext))
  }
}
#################### #
