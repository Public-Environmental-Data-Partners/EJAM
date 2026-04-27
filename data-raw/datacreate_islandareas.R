
## This is a script to create the dataset called islandareas which provides bounding boxes around the island areas.
# 1) read datafile_islandareas.csv
# 2) save it as a dataset in the R package with metadata, and
# 3) document the dataset

# x <-
# "lat,lon,ST,limit,corner
# 12.9515582,144.21516,GU,min,SW
# 13.7783567,145.05135,GU,max,NE
# 14.0129859,145.067686,MP,min,SW
# 15.396985,145.9186,MP,max,NE
# 17.611087,-65.0974,VI,min,SW
# 18.45958,-64.52,VI,max,NE
# -15.811126,-173.48980,AS,min,SW
# -9.74635292,-168,AS,max,NE
# "

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

getwd()

islandareas_from_csv <- as.data.frame(readr::read_csv("data-raw/datafile_islandareas.csv"))

if(all.equal(islandareas_from_csv, islandareas_from_here)) {
  ok = TRUE
} else {
  ok = FALSE
}
if (!ok) {
  cat("Check csv info vs what is in datacreate file \n")
} else {
  islandareas <- islandareas_from_here

  writexl::write_xlsx(islandareas,    "./data-raw/datafile_islandareas.xlsx")

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
#'   See [Census documentation](https://www.census.gov/programs-surveys/geography.html)
#'
#'   See source package files datacreate_islandareas.R or EJAM/data-raw/datafile_islandareas.csv
#'
#'   ")

}
