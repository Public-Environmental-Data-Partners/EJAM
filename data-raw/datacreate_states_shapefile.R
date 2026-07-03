# obtain shapefile to be used to see Which state contains each site

  # help("states_shapefile")

# stop("must be in local source package EJAM/data-raw folder when running this script")
# setwd("~/../../R/mysource/EJAM/data-raw")

td = tempdir()
td = file.path(td, "shp")
if (!dir.exists(td)) {dir.create(td)}
if (!dir.exists(td)) {stop('failed to create temp subfolder /shp')}

# browseURL("https://www2.census.gov/geo/tiger/Directory_Contents_ReadMe.pdf")

## based on what is probably in the EJScreen package:
# yr = acs_endyear(guess_always = T); print(yr)
## or latest published:
yr = acs_endyear(guess_census_has_published = T); print(yr)

cat("CONFIRM YEAR SHOULD BE ", yr, '\n')

# Which vintage of TIGER data is the one ACS uses?
#
# For ACS YEARx 5-year, use the YEARx ACS geography vintage, meaning it aligns with YEARx ACS 1-year geography.
# For TIGER/Line shapefiles, that generally means using YEARx TIGER/Line files for matching -YEARx ACS geographic identifiers/boundaries.
# Census states the rule directly:
# for ACS 5-year estimates, use the last year of the estimate period to determine geographic vintage.
#
# So for EJAM v2.5.0 (ACS 2020-2024), the right default is TIGER/Line 2024, e.g. tl_2024_*_bg.zip for block groups.
#
# Caveat: some geography types have special vintage rules, such as
# Congressional Districts, PUMAs, CBSAs, etc.
# But for block groups, tracts, counties, places, and the normal ACS/EJScreen blockgroup pipeline work, use YEARx geography.
#
# Sources: Census ACS Geography Boundaries by Year, xxxx TIGER/Line Shapefiles.

# baseurl = "https://www2.census.gov/geo/tiger/TIGER2020/STATE/tl_2020_us_state.zip"
# baseurl = "https://www2.census.gov/geo/tiger/TIGER2022/STATE/tl_2022_us_state.zip"
baseurl = paste0("https://www2.census.gov/geo/tiger/TIGER",yr,"/STATE/tl_",yr,"_us_state.zip")

zname = basename(baseurl)

curl::curl_download(
  url = baseurl,
  destfile = file.path(td, zname),
  quiet = FALSE
)
# download.file(
#   url = baseurl,
#   destfile = file.path(td, zname),
# )

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
if (!file.exists(file.path(td, zname))) {stop('tried to download but cannot find ', file.path(td, zname))}

states_shapefile <- sf::st_read(td)
################################################################### #
### compare to previously-installed one:
all.equal(EJAM::states_shapefile, states_shapefile, check.attributes=FALSE)
dim(EJAM::states_shapefile); dim(states_shapefile)
# [1] 56 15
# [1] 56 16
setdiff(names(EJAM::states_shapefile), names(states_shapefile))
# character(0)
setdiff( names(states_shapefile), names(EJAM::states_shapefile))
# [1] "GEOIDFQ"
shared <- intersect(names(states_shapefile), names(EJAM::states_shapefile))
all.equal(EJAM::states_shapefile[, shared], states_shapefile[, shared], check.attributes=FALSE)
# [1] "Component “ALAND”: Mean relative difference: 7.03784e-05"
# [2] "Component “AWATER”: Mean relative difference: 0.001074937"
# [3] "Component “INTPTLAT”: 3 string mismatches"
# [4] "Component “INTPTLON”: 3 string mismatches"
# [5] "Component “geometry”: Component 1: Component 1: Component 1: Numeric: lengths (70480, 70484) differ"
## etc. etc.
################################################################### #

# add the dataset to this package as a dataset to be installed with the package and lazy loaded when needed
cat("updating metadata \n")

attr(states_shapefile, "source_url")       <- baseurl
attr(states_shapefile, "date_downloaded")       <- as.character(Sys.Date())
attr(states_shapefile, "date_saved_in_package") <- as.character(Sys.Date())
print(attributes(states_shapefile))
cat("saving in package in data folder\n")
# usethis::use_data(states_shapefile, overwrite = TRUE)
 EJAM:::metadata_add_and_use_this("states_shapefile")

 cat("updating the documentation \n")

 EJAM:::dataset_documenter("states_shapefile",
                   title = "This is used to figure out which state contains each point (facility/site).",
                   seealso = "seealso [state_from_latlon()] [get_blockpoints_in_shape()]",
                   description = "This is used to figure out which state contains each point (facility/site).",
                   details = paste0("This is used by [state_from_latlon()] to find which state is associated with each point
#'   that the user wants to analyze. That is needed to report indicators in
#'   the form of State-specific percentiles
#'   (e.g., a score that is at the 80th percentile within Texas).
#'   It is created by the package via a script at EJAM/data-raw/datacreate_states_shapefile.R
#'   which downloads the data from Census Bureau.
#'
#'   It includes 50 states, DC, PR, and 4 island areas (GU, MP, VI, AS).
#'
#'   Source: ", baseurl, "                   "))

################################################################### #
## alternative way, from EJSCREENbatch   (format differs)
# library # ( # tigris)
# library(sf)
# states_shapefile2 <- tigris # :: # states() %>% sf::st_as_sf() %>%
#   sf::st_transform(crs ="ESRI:102005") %>%
#   dplyr::select('NAME') %>%
#   dplyr::rename(facility_state = NAME)
# #    facility_buff =  Polygons representing buffered areas of interest

################################################################### #
#  methods for downloading other
# TIGER/Line Shapefiles
# from the U.S. Census Bureau.

# ** Website Interface
# https://www.census.gov/cgi-bin/geo/shapefiles/index.php
# allows download of only 1 state at a time if block resolution
# •	For detailed instructions, please see the educational brochure on Downloading TIGER/Line Shapefiles.
# https://www2.census.gov/geo/pdfs/education/tiger/Downloading_TIGERLine_Shp.pdf
# •	Note: Not all versions of TIGER/Line Shapefiles are available through the web interface.

# ** Direct from FTP site (or via FTP client) to access the full set of files.
# ftp://ftp2.census.gov/geo/tiger/

# ** Direct from Data.gov
# Census haf not yet added the ability download Shapefiles directly on data.census.gov, (as of 5/2023)
