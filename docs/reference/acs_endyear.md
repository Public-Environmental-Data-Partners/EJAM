# check which ACS 5-year survey is available from Census Bureau or in EJAM/EJSCREEN

check which ACS 5-year survey is available from Census Bureau or in
EJAM/EJSCREEN

## Usage

``` r
acs_endyear(
  guess_as_of = Sys.Date(),
  guess_always = FALSE,
  guess_census_has_published = FALSE,
  lag_yrs_endyr_to_census_publishes = 0.95,
  lag_yrs_endyr_to_ejscreen = 1.6
)
```

## Arguments

- guess_as_of:

  optional alternative date to use if guessing what is available as of
  this date, e.g., "2025-01-01" – Date class like Sys.Date()

- guess_always:

  optional, set TRUE to ignore metadata and just guess at year. But
  guess_always = FALSE is ignored if guess_census_has_published = TRUE

- guess_census_has_published:

  optional, set to TRUE to guess what is the latest end year of 5yr ACS
  data that Census Bureau has published on their summary file site,
  rather than guessing what the EJAM package has already incorporated
  from there. Setting this TRUE will return an earlier year than if
  FALSE, usually, given the lag from Census Bureau publishing to EJAM
  incorporating. If this is set TRUE, then the guess_always parameter is
  ignored.

- lag_yrs_endyr_to_census_publishes:

  years to assume lag between end of endyear and when Census Bureau
  releases ACS dataset for 5yr summary file

- lag_yrs_endyr_to_ejscreen:

  years to assume lag between end of endyear and when ejscreen gets
  updated with ACS data

## Value

a single year like "2022", meaning ACS5 survey data covering 2018-2022,
released by Census Bureau 12/2023, updated in EJSCREEN in mid/late 2024.

## Details

This function can report what the package metadata says is the version
of ACS data in the package, or it can guess what version is published by
Census Bureau or is incorporated into EJAM/EJSCREEN, based on actual
recent release dates or typical lags from survey to release by Census or
in EJSCREEN.

Census Bureau provides yearly release schedules for ACS data:

- The [2020-2024 ACS
  data](https://www.census.gov/programs-surveys/acs/news/data-releases/2024/release-schedule.html)
  normally would be released by Census Bureau 12/11/2025, but release
  was delayed until January 29, 2026.

- The [2019-2023 ACS
  data](https://www.census.gov/programs-surveys/acs/news/data-releases/2023/release-schedule.html)
  were published by Census Bureau 12/12/2024.

- The [2018-2022 ACS
  data](https://www.census.gov/programs-surveys/acs/news/data-releases/2022/release-schedule.html)
  were published by Census Bureau 12/7/2023.

EJSCREEN has incorporated ACS data in new releases of EJSCREEN on a more
complicated schedule since 2024. See
[ejanalysis.com/status](https://ejanalysis.com/status)

- The 2020-2024 ACS data may be in non-EPA versions of EJAM / EJSCREEN
  starting around mid 2026.

- The 2019-2023 ACS data were never used in EJSCREEN / EJAM, because in
  2025 EPA stopped updating the tool and data.

- The 2018-2022 ACS data were used in EJSCREEN / EJAM starting in
  mid/late 2024.
