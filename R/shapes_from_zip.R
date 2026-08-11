
#' Get boundaries of zip codes (ZCTA polygons), to analyze or map zip codes
#'
#' @description Downloads Census ZIP Code Tabulation Area (ZCTA) boundaries
#'   for the specified zip code(s), returning polygons that can be analyzed
#'   like any other shapefile, as with `ejamit(zipcode = 10605)` which uses
#'   this function. See the Zipcodes article/vignette for more background.
#'
#' @details Census uses ZIP Code Tabulation Areas (ZCTAs), which are
#'   generalized areal representations of United States Postal Service (USPS)
#'   ZIP Code service areas -- see `help("zctas", package = "tigris")`.
#'   Some zip codes (e.g., ones used only for PO boxes or single buildings)
#'   have no ZCTA polygon, and this function warns about and drops those.
#'
#'   Note the first use can be slow, since [tigris::zctas()] downloads a large
#'   national file, but it is cached locally (see [tigris::tigris_cache_dir()])
#'   so later calls are fast.
#' @param zipcode vector of one or more 5-digit zip codes, as numbers or text
#'   (leading zeroes are restored if missing, so 1001 means zip code 01001,
#'   and a ZIP+4 like "10605-1234" is truncated to its first 5 digits)
#' @param year optional year of ZCTA vintage, passed to [tigris::zctas()].
#'   If NULL (default), the tigris package default is used.
#' @param ... passed to [tigris::zctas()]
#' @return A spatial data.frame ([sf::sf]) with one row per zip code found
#'   (in the same order as the requested zip codes), including a `zip` column.
#' @examples \dontrun{
#'   shp <- shapes_from_zip(c("10012", "10506"))
#'   mapfast(shp)
#'   out <- ejamit(shapefile = shp) # same as out <- ejamit(zipcode = c("10012", "10506"))
#'   }
#' @seealso [ejamit()] [shapes_from_fips()] [shapefile_from_any()]
#'
#' @export
#'
shapes_from_zip <- function(zipcode, year = NULL, ...) {

  if (missing(zipcode) || is.null(zipcode) || length(zipcode) == 0) {
    stop("zipcode must be one or more 5-digit zip codes")
  }
  # normalize: drop any +4 suffix, restore leading zeroes lost if read as a number
  zipcode <- trimws(as.character(zipcode))
  zipcode <- gsub("[^0-9]", "", sub("-.*$", "", zipcode))
  zipcode[nchar(zipcode) == 9] <- substr(zipcode[nchar(zipcode) == 9], 1, 5) # ZIP+4 without dash
  ok <- !is.na(zipcode) & nchar(zipcode) >= 3 & nchar(zipcode) <= 5
  zipcode[ok] <- sprintf("%05d", as.integer(zipcode[ok]))
  ok <- ok & grepl("^[0-9]{5}$", zipcode)
  if (any(!ok)) {
    warning("Dropping invalid zip code(s): ", paste(unique(zipcode[!ok]), collapse = ", "))
    zipcode <- zipcode[ok]
  }
  if (length(zipcode) == 0) {stop("No valid 5-digit zip codes provided")}
  if (anyDuplicated(zipcode)) {
    warning("Dropping duplicate zip code(s)")
    zipcode <- unique(zipcode)
  }

  message("Getting ZCTA boundaries of zip codes via tigris package (first download is slow but is cached locally)...")
  ## set here, not only in .onAttach(), which does not run for EJAM::shapes_from_zip()
  ## or EJAM::ejamit() - without it tigris re-downloads the national file every call
  ## and the local caching promised in @details would not actually happen.
  ## Only when the caller has expressed no preference, though: an explicit
  ## options(tigris_use_cache = FALSE) is theirs to make and is left alone.
  if (is.null(getOption("tigris_use_cache"))) {
    options(tigris_use_cache = TRUE)
  }
  shp <- tigris::zctas(starts_with = zipcode, year = year, ...)

  # column name varies by vintage, e.g., ZCTA5CE20 / GEOID20 -- but NOT GEOIDFQ20,
  # which is the fully qualified id ("8600000US10012") and would match no zip code,
  # making every lookup fail. Prefer ZCTA5CE*, then a plain GEOID*.
  idcol <- c(grep("^ZCTA5", names(shp), value = TRUE),
             grep("^GEOID(?!FQ)", names(shp), value = TRUE, perl = TRUE))[1]
  if (is.na(idcol)) {stop("Cannot find zip code (ZCTA id) column in downloaded boundaries")}
  found <- as.character(shp[[idcol]])
  zips_missing <- setdiff(zipcode, found)
  if (length(zips_missing) > 0) {
    warning("No ZCTA boundaries found for zip code(s) (possibly not a ZCTA, e.g., PO box-only zips): ",
            paste(zips_missing, collapse = ", "))
  }
  zipcode <- zipcode[zipcode %in% found]
  if (length(zipcode) == 0) {stop("No ZCTA boundaries found for any of the zip codes provided")}
  shp <- shp[match(zipcode, found), ] # exact matches only, in same order as requested
  shp$zip <- zipcode
  return(shp)
}
