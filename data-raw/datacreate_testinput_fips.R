# datacreate_testinput_fips.R

# cannot do until AFTER have updated censusplaces, blockgroupstats, etc.

################################## #

# 2 states

testinput_fips_states <- fips_state_from_state_abbrev(c("DE", "RI")) # relies on stateinfo2

## DO NOT ADD METADATA SINCE IT WILL NO LONGER BE A VECTOR PER is.vector() and
## shapes_from_fips() wil not work if we used metadata_add() !
# testinput_fips_states <- metadata_add(testinput_fips_states)

# confirm it works in key functions
x <- testinput_fips_states
stopifnot(is.vector(x))
stopifnot(all(fips_valid(x)))
y = getblocksnearby_from_fips(x)
mapfast({shp <- shapes_from_fips(x)})
dim(shp)
# 2 10

usethis::use_data(testinput_fips_states, overwrite = TRUE)
dataset_documenter(
  "testinput_fips_states",
  description = "Census FIPS codes vector as example of input, e.g., ejamit(fips = testinput_fips_states)"
)
################################## #

# 2 cities/towns

testinput_fips_cities <- c("2743000", "2743306")
# 2743000 # minneapolis city
# Minnetrista city     MN        Hennepin County 2743306

## DO NOT ADD METADATA SINCE IT WILL NO LONGER BE A VECTOR PER is.vector() and
## shapes_from_fips() wil not work if we used metadata_add() !
## testinput_fips_cities <- metadata_add(testinput_fips_cities)

# confirm it works in key functions
x <- testinput_fips_cities
stopifnot(all(x %in%   censusplaces$fips))
stopifnot(is.vector(x))
stopifnot(all(fips_valid(x)))
y = getblocksnearby_from_fips(x)
mapfast({shp <- shapes_from_fips(x)})
dim(shp)
# 2 11

usethis::use_data(testinput_fips_cities, overwrite = TRUE)
dataset_documenter(
  "testinput_fips_cities",
  description = "Census FIPS codes vector as example of input, e.g., ejamit(fips = testinput_fips_cities)"
)
################################## #

# all counties in one state

testinput_fips_counties <- fips_counties_from_state_abbrev("DE")
## same as this:
# testinput_fips_counties <- read_csv_or_xl(testdata("counties_in_Delaware.xlsx", quiet = T))
# testinput_fips_counties <- testinput_fips_counties$countyfips

## DO NOT ADD METADATA SINCE IT WILL NO LONGER BE A VECTOR PER is.vector() and
## shapes_from_fips() wil not work if we used metadata_add() !
# testinput_fips_counties <- metadata_add(testinput_fips_counties)

# confirm it works in key functions
x = testinput_fips_counties
stopifnot(is.vector(x))
stopifnot(all(fips_valid(x)))
y = getblocksnearby_from_fips(x)
mapfast({shp <- shapes_from_fips(x)})
dim(shp)
# 3  10

usethis::use_data(testinput_fips_counties, overwrite = TRUE)
dataset_documenter(
  "testinput_fips_counties",
  description = "Census FIPS codes vector as example of input, e.g., ejamit(fips = testinput_fips_counties)"
)
# ejamit(fips = testinput_fips_counties)
################################## #

# all tracts in one county

testinput_fips_tracts = unique(substr(
  fips_bgs_in_fips(
    fips_counties_from_state_abbrev("AR")[1]
  ), 1, 11))

## DO NOT ADD METADATA SINCE IT WILL NO LONGER BE A VECTOR PER is.vector() and
## shapes_from_fips() wil not work if we used metadata_add() !
# testinput_fips_tracts <- metadata_add(testinput_fips_tracts)

# confirm it works in key functions
x = testinput_fips_tracts
stopifnot(is.vector(x))
stopifnot(all(fips_valid(x)))
y = getblocksnearby_from_fips(x)
mapfast({shp <- shapes_from_fips(x)})
dim(shp)
# 8 10

usethis::use_data(testinput_fips_tracts, overwrite = TRUE)
dataset_documenter(
  "testinput_fips_tracts",
  description = "Census FIPS codes vector as example of input, e.g., ejamit(fips = testinput_fips_tracts)"
)
################################## #

# all blockgroups in one county

testinput_fips_blockgroups <- unique(fips_bgs_in_fips(testinput_fips_tracts))

## DO NOT ADD METADATA SINCE IT WILL NO LONGER BE A VECTOR PER is.vector() and
## shapes_from_fips() wil not work if we used metadata_add() !
# testinput_fips_blockgroups <- metadata_add(testinput_fips_blockgroups)

# confirm it works in key functions
x = testinput_fips_blockgroups
stopifnot(is.vector(x))
stopifnot(all(fips_valid(x)))
y = getblocksnearby_from_fips(x)
mapfast({shp <- shapes_from_fips(x)})
dim(shp)
# 14 10

usethis::use_data(testinput_fips_blockgroups, overwrite = TRUE)
dataset_documenter(
  "testinput_fips_blockgroups",
  description = "Census FIPS codes vector as example of input, e.g., ejamit(fips = testinput_fips_blockgroups)"
)
################################## #

testinput_fips_mix =  c(
  "091701844002024", # block
  testinput_fips_blockgroups[1],
  testinput_fips_tracts[2],
  "4748000", ## Memphis  # testinput_fips_cities[1],
  testinput_fips_counties[1],
  testinput_fips_states[2]
)

# confirm it works in key functions
x = testinput_fips_mix
stopifnot(is.vector(x))
stopifnot(all(fips_valid(x)))
y = getblocksnearby_from_fips(x)
shp <- shapes_from_fips(x)
mapfast(shp )
dim(shp)
# 6 11

usethis::use_data(testinput_fips_mix, overwrite = TRUE)
dataset_documenter(
  "testinput_fips_mix",
  description = "Census FIPS codes vector as example, e.g., mapfast(shapes_from_fips(testinput_fips_mix))"
)
################################## #
