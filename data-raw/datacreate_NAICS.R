
# This script can check for a newer version of NAICS data
# only relevant every 5 years, such as in 2027 expected changes in naics codes
# but vintage of codes must match what is used in FRS data as used in package

cat("NAICS and FRS-related datasets must be updated in an integrated way. \n")
cat("Must check which version of NAICS codes are recorded in EPA FRS data \n ")
cat("As of 10/2025, the 2017 NAICS codes were being used in EJAM because
the copy of EPA FRS being used by EJAM is somewhat outdated but the NAICS codes in it
were clearly be 2017-style NAICS not 2022-style codes.\n")

cat("Maybe update FRS-related datasets\n")
cat("See data-raw/datacreate_0_UPDATE_ALL_DATASETS.R \n")

cat("Maybe update to newer version of NAICS definitions \n")
cat("See ?naics_download() \n")
cat("See data-raw/datacreate_0_UPDATE_ALL_DATASETS.R \n")
cat("See data-raw/datacreate_NAICS.R \n")
cat("See data-raw/datacreate_naicstable.R etc. \n")

 # # compare versions of naics codes and version stored in the package
 #
 # naics22 = naics_download(year = 2022)
 #
 # naics17 = naics_download(year = 2017)
 #
 # naics_v6 = EJAM::NAICS
 #
 # all.equal( naics_v6, naics17, check.attributes = F)
 #
 # length(naics22); length(naics17)
 #
 # # see which version of naics codes seems to have been used by the FRS data
 #
 # dataload_dynamic("frs_by_naics")
 #
 # table(frs_by_naics$NAICS %in% naics22)
 #
 # table(frs_by_naics$NAICS %in% naics17)


cat("See ?naics_download() for examples of comparing versions \n")


NAICS <- naics_download()

metadata_add_and_use_this(NAICS)

dataset_documenter(varname = "NAICS",
                   title = "NAICS (DATA) named vector of all NAICS code numbers and industry name for each",
                   description = "A named vector of more than 2,000 NAICS code numbers and industry name for each",
                   details = "This is a named set of numeric codes, where a name has the code and title,
like '22132 - Sewage Treatment Facilities' or '22 - Utilities'
Revised codes have been published every five years, such as in 2017 and 2022.

The version used should match the version used in assigning codes to the EPA FRS facilities.
As of 10/2025, the 2017 NAICS codes were being used in EJAM because
the copy of EPA FRS being used by EJAM is somewhat outdated but the NAICS codes in it
were clearly be 2017-style NAICS not 2022-style codes.

For more info, see [naics_download()] and (https://naics.com)

and [2022 codes](https://www.census.gov/naics/?58967?yearbck=2022)

and [2017 codes](https://www.census.gov/naics/?58967?yearbck=2017)
                   ",
                   seealso = " [naics_download()] [naicstable] [naics_from_any()] [naics_categories()] [NAICS]")
