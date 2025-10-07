
#' convert spatial data.frame to a vector of geojson text strings
#' @details helper for [url_ejamapi()]
#' Note it removes all spaces in the string.
#'
#' @param shp spatial data.frame to be written via [sf::st_write()]
#' @param file optional file path and name, useful if txt=F
#' @param txt optional logical, set to FALSE to just get the path to a temp .geojson file
#' @returns if txt=T, returns geojson text string(s) for the input spatial data.frame
#'   if txt=F, returns file path/name(s) of .geojson file(s).
#' @param combine_in_one_string  set to TRUE to get back only 1 geojson txt string.
#'   If FALSE, output is a vector of strings.
#' @param combine_in_one_file  set to TRUE to get back only 1 file (1 row per polygon, not union/dissolved).
#'   If FALSE, output is a vector of filenames (saves each row of input shp as a separate file).
#' @details
#'   Note that trying to use txt=T and combine_in_one_string = T for large polygons or many polygons
#'   would create a very long string that might exceed URL length limits for GET requests,
#'   if that is what you're using the text for.
#' @seealso [shapefile_from_any()] [shapefile_from_geojson_text()]
#' @examples
#' shp =  testinput_shapes_2[2, c("geometry", "FIPS")]
#' x = shape2geojson(shp)
#' nchar(x)
#'
#' @export
#'
shape2geojson = function(shp, file = file.path(tempdir(), "shp.geojson"),
                         txt = TRUE,
                         combine_in_one_string = FALSE,
                         combine_in_one_file = TRUE) {

  # If this is used mostly to convert shp into text usable in the current EJAM-API that needs text geojson, the idea of dissolving/union might be
  # a bad idea since the more important limitation is GET API URL length is capped and we can't use that API for large sets of large polygons anyway
  # at least as of how it was designed as of 8/2025 or so.

  # If we actually do want options to dissolve/union/etc. consider what exactly we want/need:
  # for the file (or geojson string) created, we might want all polygons from input saved in
  # - 1 file each (and 1 string each) - a vector is the output
  # - 1 file with 1 row each (and 1 string with all the polys/rows stored one by one in it,)
  # - 1 file with 1 dissolved/union row (1 string with 1 dissolved/union object represented). i.e. we might just want sf::st_union() in that case.

  # see https://github.com/r-spatial/sf/issues/2422 to clarify what we might need and how to do various kinds of "dissolve"-like actions

  stopifnot( length(txt) == 1, is.logical(txt),
             is.logical(combine_in_one_string), is.logical(combine_in_one_file),
             is.data.frame(shp), inherits(shp, "sf"),
             all(grepl("\\.geojson$", file))
  )
  ############################################# #
  # treat entire input shp as a single object saved in a single geojson file and read back as a single geojson txt string
  s2g1 = function(shp, file = file.path(tempdir(), "shp.geojson"), txt = TRUE) {

    stopifnot(length(file) == 1, length(txt) == 1, is.logical(txt), inherits(shp, "sf"),
              # NROW(shp) == 1,
              grepl("\\.geojson$", file))
    suppressMessages({
      junk = capture.output({
        sf::st_write(shp, dsn = file, delete_dsn = TRUE)
      })
    })

    if (txt) {
      geotxt = readLines(file)
      geotxt = paste0(geotxt, collapse = "") # not relevant if given only 1 polygon. combines lines of geojson file (Q: is that the same as 1 line per 1 row of shp input?)
      geotxt = gsub(" ", "", geotxt) # is it ok to remove all spaces?
      # cat("use URLencode() to encode this string for use in a URL \n")

      return(geotxt) # 1 text string
    } else {
      return(file)   # 1 file path
    }
  }
  ############################################# #

  if (NROW(shp) == 1) {
    geoj <- s2g1(shp, file = file, txt = txt)
  } else {

    if (combine_in_one_string && combine_in_one_file) {
      # check this works!! see notes above on "dissolve"
      geoj <- s2g1(shp, file = file, txt = txt)
    }

    if (combine_in_one_string && !combine_in_one_file) {
      # multifile, but single string
      if (txt) {
        # ignore multifile since just want 1 string
        geoj <- s2g1(shp, file = file, txt = txt)
      } else {
        # multifile vector of filepaths
        geoj <- vector()
        if (missing(file) || length(file) != NROW(shp)) {
          # create unique name for each file
          files = paste0(gsub("\\.geojson$", "", file), "_", 1:NROW(shp), ".geojson")
        }
        # multifile returned
        for (i in 1:NROW(shp)) {geoj[i] <- s2g1(shp[i, ], file = files[i], txt = txt)}
      }
    }

    if (!combine_in_one_string && combine_in_one_file) {
      if (!txt) {
        # just need 1 file path.
        geoj <- s2g1(shp, file = file, txt = txt)
      } else {
        # param said 1 file, but ignore that and do multifiles to create multistring since txt==T
        geoj <- vector()
        if (missing(file) || length(file) != NROW(shp)) {
          # create unique name for each file
          files = paste0(gsub("\\.geojson$", "", file), "_", 1:NROW(shp), ".geojson")
        }
        # multifile to allow multi string vector
        for (i in 1:NROW(shp)) {geoj[i] <- s2g1(shp[i, ], file = files[i], txt = txt)}
      }
    }
    # sf::st_write(EJAM::testinput_shapes_2[2,], file.path(tempdir(), "junk1.geojson"))
  }
  return(geoj)
}
##################################################################### #
