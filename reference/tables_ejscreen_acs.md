# tables_ejscreen_acs dataset

tables_ejscreen_acs dataset

## Usage

``` r
tables_ejscreen_acs
```

## Format

An object of class `character` of length 15.

## Details

See

    yr = 2024
    urls = paste0('https://data.census.gov/table/ACSDT5Y', yr, '.', tables_ejscreen_acs)
    sapply(urls, browseURL)
    acsinfo <- tidycensus::load_variables(acs_endyear(guess_census_has_published = TRUE), 'acs5')

Notes:

- B25034 pre1960, for lead paint indicator (environmental not
  demographic per se)

- B01001 sex and age / basic population counts

- B03002 race with hispanic ethnicity

- B02001 race without hispanic ethnicity

- B15002 education

- B23025 unemployed

- C17002 low income, poor, etc.

- B19301 per capita income

- B25032 owned units vs rented units (occupied housing units, same
  universe as B25003)

- B28003 no broadband

- B27010 no health insurance

- C16002 (language category and) % of households limited English
  speaking (lingiso) <https://data.census.gov/table/ACSDT5Y2024.C16002>

- B16004 (language category and) % of residents (not hhlds) speak no
  English at all <https://data.census.gov/table/ACSDT5Y2024.B16004>

TRACT ONLY, but also used by EJSCREEN:

- C16001 languages detailed list: % of residents (not hhlds) IN TRACT
  speak Chinese, etc. <https://data.census.gov/table/ACSDT5Y2024.C16001>

- B18101 disability

## See also

[formulas_ejscreen_acs](https://public-environmental-data-partners.github.io/EJAM/reference/formulas_ejscreen_acs.md)
