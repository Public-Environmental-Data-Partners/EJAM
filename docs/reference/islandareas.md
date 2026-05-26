# islandareas (DATA) table, bounding boxes lat lon for US Island Areas

data.frame of info on approximate lat lon bounding boxes around

- American Samoa (AS)

- Guam (GU)

- the Commonwealth of the Northern Mariana Islands (Northern Mariana
  Islands) (MP)

- the United States Virgin Islands (VI)

- Note the U.S. Minor Outlying Islands (UM) are also Island Areas, but
  are not included in EJScreen/EJAM. They are widely dispersed, and
  include Midway Islands, for example.

See
[stateinfo2](https://public-environmental-data-partners.github.io/EJAM/reference/stateinfo2.md)
and see info on these areas via
`stateinfo2[stateinfo2$is.island.areas, ]`

Puerto Rico is included in both Census 2020 and ACS survey data.

The 2020 Census (Island Areas Census) did include information on
AS,GU,MP,VI, but the ACS does not include Island Areas. See
https://www.census.gov/programs-surveys/decennial-census/decade/2020/planning-management/release/2020-island-areas-data-products.html

See [Census
documentation](https://www.census.gov/programs-surveys/geography.html)

See source package files datacreate_islandareas.R or
EJAM/data-raw/datafile_islandareas.csv

## Usage

``` r
islandareas
```

## Format

An object of class `data.frame` with 8 rows and 5 columns.

## See also

[`is.island()`](https://public-environmental-data-partners.github.io/EJAM/reference/is.island.md)
