# check which ACS 5-year survey is available, per EJAM metadata or guessed via published or typical schedules

check which ACS 5-year survey is available, per EJAM metadata or guessed
via published or typical schedules

## Usage

``` r
acsendyear(
  guess_as_of = Sys.Date(),
  guess_always = FALSE,
  guess_census_has_published = FALSE,
  lag_yrs_endyr_to_census_publishes = 0.9452055,
  lag_yrs_endyr_to_ejscreen = 1.6
)
```

## Arguments

- guess_as_of:

  optional alternative date to use if guessing what is available as of
  this date, e.g., "2025-01-01" – Date class like Sys.Date()

- guess_always:

  optional, set TRUE to ignore metadata and just guess at year. But
  guess_always=F is ignored if guess_census_has_published=T

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

- The 2020-2024 data should be released by Census Bureau 12/11/2025.

- The 2019-2023 data were published by Census Bureau 12/12/2024, but
  were not yet in EJSCREEN as of late 2025.

- The 2018-2022 data were published by Census Bureau 12/7/2023, in
  EJSCREEN mid/late 2024.

See schedules such as
<https://www.census.gov/programs-surveys/acs/news/data-releases/2024/release-schedule.html>
