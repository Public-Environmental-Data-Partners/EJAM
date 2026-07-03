# datacreate_testinput_naics.R

# no folder in testdata for this type
# since cannot upload table of that type to app and they cannot be direct inputs to ejamit()
#  but may want testdata objects to try out relevant functions that turn these into latlon
# Update/check this in case NAICS code universe changes (every 3 years?)

testinput_naics <- c(3366, 33661, 336611)

## Do not use metadata_add() now since the output is no longer a vector per is.vector()
## and it is not essential to note version of this test data as metadata / attribute
#testinput_naics <- metadata_add(testinput_naics)

# latlon_from_naics(testinput_naics)
usethis::use_data(testinput_naics, overwrite = TRUE)
dataset_documenter(
  "testinput_naics",
  description = "NAICS codes vector as example of input, e.g., latlon_from_naics(testinput_naics)"
)

# latlon_from_naics(testinput_naics)
