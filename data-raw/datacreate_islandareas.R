
## This is a script to create the dataset called islandareas which provides bounding boxes around the island areas.
# 1) read datafile_islandareas.csv
# 2) save it as a dataset in the R package with metadata, and
# 3) document the dataset

islandareas_from_here <- structure(list(

  lat = c(12.951558,   13.7783567,
          14.0129859,  15.39699,
          17.611087,   18.45958,
          -15.811126,  -9.74635292),
  lon = c(144.21516,  145.05135,
          145.067686, 145.9186,
          -65.0974,   -64.52,
          -173.4898, -168),
  ST    = c("GU",  "GU",
            "MP",  "MP",
            "VI",  "VI",
            "AS",  "AS"),
  limit = c("min", "max",
            "min", "max",
            "min", "max",
            "min", "max"),
  corner = c("SW", "NE",
             "SW",  "NE",
             "SW",  "NE",
             "SW",  "NE")
),
class = "data.frame",
row.names = c(NA, -8L))

# > islandareas_from_here
# lat       lon ST limit corner
# 1  12.951558  144.2152 GU   min     SW
# 2  13.778357  145.0514 GU   max     NE
# 3  14.012986  145.0677 MP   min     SW
# 4  15.396990  145.9186 MP   max     NE
# 5  17.611087  -65.0974 VI   min     SW
# 6  18.459580  -64.5200 VI   max     NE
# 7 -15.811126 -173.4898 AS   min     SW
# 8  -9.746353 -168.0000 AS   max     NE

fname <- "data-raw/datafile_islandareas.csv"
if (!file.exists(fname)) {
  message("did not find file '", fname, "'")
  ok <- TRUE # just use data from here
} else {
  # compare numbers from file vs from here, assuming file is found
  islandareas_from_csv <- as.data.frame(readr::read_csv(fname))
  if (isTRUE(all.equal(islandareas_from_csv, islandareas_from_here, tolerance = 0.000001))) {
    ## but note "Component “lat”: Mean relative difference: 1.834309e-07"
    ok <- TRUE
  } else {
    ok <- FALSE
    stop("csv file info does not match what is in datacreate_ file")
  }
}

if (ok) {
  islandareas <- islandareas_from_here

  ## could save the file but do not really need to anymore
  # write.csv(islandareas, file = fname)
  # writexl::write_xlsx(islandareas, gsub("csv", "xlsx", fname))

  metadata_add_and_use_this("islandareas")
  # usethis::use_data(islandareas, overwrite = TRUE)

  dataset_documenter("islandareas",
                     "islandareas (DATA) table, bounding boxes lat lon for US Island Areas",
                     seealso = "[is.island()] ",
                     description = "data.frame of info on approximate lat lon bounding boxes around
#'
#'   - American Samoa (AS)
#'   - Guam (GU)
#'   - the Commonwealth of the Northern Mariana Islands (Northern Mariana Islands) (MP)
#'   - the United States Virgin Islands (VI)
#'   - Note the U.S. Minor Outlying Islands (UM) are also Island Areas, but are not included in EJScreen/EJAM. They are widely dispersed, and include Midway Islands, for example.
#'
#'   See [stateinfo2] and see info on these areas via `stateinfo2[stateinfo2$is.island.areas, ]`
#'
#'   Puerto Rico is included in both Census 2020 and ACS survey data.
#'
#'   The 2020 Census did include information on AS,GU,MP,VI, but the ACS does not include Island Areas.
#'   See https://www.census.gov/programs-surveys/decennial-census/decade/2020/planning-management/release/2020-island-areas-data-products.html
#'
#'   See [Census documentation](https://www.census.gov/programs-surveys/geography.html)
#'
#'   See source package files datacreate_islandareas.R or EJAM/data-raw/datafile_islandareas.csv
#'
#'   ")

}
