# NAICS - Script to download/read NAICS file that provides industry code and name of sector

NAICS - Script to download/read NAICS file that provides industry code
and name of sector

## Usage

``` r
naics_download(
  year = NULL,
  urlpattern = "https://www.census.gov/naics/YYYYNAICS/2-6%20digit_YYYY_Codes.xlsx",
  destfile = NULL
)
```

## Arguments

- year:

  optional, tries to figure out what might be latest available - which
  vintage of NAICS codes to use, such as 2022 or 2027 (confirmed it
  worked for 2012,2017,2022 releases of new codes)

- urlpattern:

  optional full url of xlsx file to use, but with YYYY instead of year

- destfile:

  optional full path and name of file to save as locally - uses
  tempdir() and yyyyNAICS.xlsx by default

## Value

names list with year as an attribute

## Details

See data-raw/datacreate_NAICS.R for more information.

Can be used to update the NAICS codes list every 5 years, for use in the
EJAM package, by EJAM/data-raw/datacreate_NAICS.R script via
EJAM/data-raw/datacreate_0_UPDATE_ALL_DATASETS.R Essentially a way to
get a version/release (2017 or 2022 or maybe 2027 etc.) of codes and
names. See <https://www.census.gov/naics/?48967>

## compare versions of naics codes and version stored in the package

naics22 = naics_download(year = 2022)

naics17 = naics_download(year = 2017)

naics_v6 = EJAM::NAICS

all.equal( naics_v6, naics17, check.attributes = FALSE)

length(naics22); length(naics17)

## see which version of naics codes seems to have been used by the FRS data

dataload_dynamic("frs_by_naics")

table(frs_by_naics\$NAICS %in% naics22)

table(frs_by_naics\$NAICS %in% naics17)
