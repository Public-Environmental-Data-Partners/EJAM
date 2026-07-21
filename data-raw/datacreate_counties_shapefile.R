# obtain shapefile of County boundaries, to be built into the package
# so that mapping a County does not require downloading boundaries at render time.

  # help("counties_shapefile")

# stop("must be in local source package EJAM/data-raw folder when running this script")
# setwd("~/../../R/mysource/EJAM/data-raw")

td = tempdir()
td = file.path(td, "countyshp")
if (!dir.exists(td)) {dir.create(td)}
if (!dir.exists(td)) {stop('failed to create temp subfolder /countyshp')}

# browseURL("https://www2.census.gov/geo/tiger/Directory_Contents_ReadMe.pdf")

## based on what is probably in the EJScreen package:
# yr = acs_endyear(guess_always = T); print(yr)
## or latest published:
yr = acs_endyear(guess_census_has_published = T); print(yr)

cat("CONFIRM YEAR SHOULD BE ", yr, '\n')

# See notes in datacreate_states_shapefile.R about which vintage of Census
# geography goes with which ACS release -- the same rule applies here:
# for ACS 5-year estimates, use the last year of the estimate period.

## WHY THE CARTOGRAPHIC (cb_) FILE AND NOT TIGER/Line:
##
## shapes_counties_from_countyfips() defaults to myservice = 'cartographic',
## which reaches tidycensus/tigris with cb = TRUE, and tigris defaults to the
## 500k resolution for counties. So cb_YYYY_us_county_500k is the same source
## and resolution the download path already returns -- baking it in changes
## where the boundaries come from, not which boundaries they are.
##
## It is also far smaller than TIGER/Line: ~11 MB zipped / ~9 MB as .rda,
## versus hundreds of MB for full-resolution TIGER/Line counties.

baseurl = paste0("https://www2.census.gov/geo/tiger/GENZ", yr, "/shp/cb_", yr, "_us_county_500k.zip")

zname = basename(baseurl)

curl::curl_download(
  url = baseurl,
  destfile = file.path(td, zname),
  quiet = FALSE
)

if (!file.exists(file.path(td, zname))) {stop('tried to download but cannot find ', file.path(td, zname))}

################################################################### #

fnames = unzip(
  zipfile = file.path(td, zname),
  exdir = td, list = TRUE
)$Name
shpname = paste0(unique(gsub("\\..*$", "", fnames)), ".shp")
if (length(shpname) > 1) {stop("unclear which shapefile to import")}

unzip(
  zipfile = file.path(td, zname),
  exdir = td
)

counties_shapefile <- sf::st_read(td)

################################################################### #
## sanity checks

cat("rows (counties or county equivalents):", NROW(counties_shapefile), "\n")
cat("distinct state/territory FIPS:", length(unique(counties_shapefile$STATEFP)), "\n")
cat("CRS:", sf::st_crs(counties_shapefile)$input, "\n")

if (NROW(counties_shapefile) < 3000) {stop("expected at least 3000 counties/county-equivalents")}
if (!all(c("GEOID", "NAME", "geometry") %in% names(counties_shapefile))) {
  stop("expected GEOID, NAME, and geometry columns")
}
if (any(duplicated(counties_shapefile$GEOID))) {stop("GEOID should uniquely identify each row")}
if (!all(nchar(counties_shapefile$GEOID) == 5)) {stop("county GEOID should be 5 characters")}

### compare to previously-installed one, if any:
if (exists("counties_shapefile", where = asNamespace("EJAM"), inherits = FALSE)) {
  dim(EJAM::counties_shapefile); dim(counties_shapefile)
  setdiff(names(EJAM::counties_shapefile), names(counties_shapefile))
  setdiff(names(counties_shapefile), names(EJAM::counties_shapefile))
}
################################################################### #

# add the dataset to this package as a dataset to be installed with the package and lazy loaded when needed
cat("updating metadata \n")

attr(counties_shapefile, "source_url")          <- baseurl
attr(counties_shapefile, "date_downloaded")     <- as.character(Sys.Date())
attr(counties_shapefile, "date_saved_in_package") <- as.character(Sys.Date())
print(EJAM:::attributes2(counties_shapefile))
cat("saving in package in data folder\n")
# usethis::use_data(counties_shapefile, overwrite = TRUE)
EJAM:::metadata_add_and_use_this("counties_shapefile")

cat("updating the documentation \n")

EJAM:::dataset_documenter(
  "counties_shapefile",
  title = "Boundaries of US Counties (and county equivalents), built into the package for mapping.",
  seealso = "seealso [shapes_from_fips()] [states_shapefile]",
  description = "Boundaries of US Counties (and county equivalents), built into the package for mapping.",
  details = paste0("This is used by [shapes_from_fips()] (via its internal helper
#'   shapes_counties_from_countyfips()) to get the boundary of a County without
#'   having to download it at the time a map or report is created.
#'
#'   Before this dataset existed, every County map or report required a live
#'   download from the Census Bureau (via the tidycensus/tigris packages) or from
#'   an ArcGIS feature service, which was both a source of latency and a point of
#'   failure. Downloading is still used as a fallback for any FIPS not found here.
#'
#'   These are the Census Bureau *cartographic boundary* files at 1:500,000
#'   resolution -- the same source and resolution that the download path returns
#'   by default (tidycensus/tigris with cb = TRUE) -- so baking them in changes
#'   where the boundaries come from, not which boundaries they are.
#'   They are generalized for mapping and are not intended for area calculations.
#'
#'   It includes counties and county equivalents in the 50 states, DC, PR, and
#'   the island areas.
#'
#'   It is created by the package via a script at EJAM/data-raw/datacreate_counties_shapefile.R
#'   which downloads the data from the Census Bureau.
#'
#'   Source: ", baseurl, "                   "))
################################################################### #
