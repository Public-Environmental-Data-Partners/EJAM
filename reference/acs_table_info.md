# utility to download and print some info about each variable in each ACS 5yr table

utility to download and print some info about each variable in each ACS
5yr table

## Usage

``` r
acs_table_info(yr, tables_acs, dataset = "acs5")
```

## Arguments

- yr:

  end year of 5-year ACS dataset, guesses if not specified

- tables_acs:

  optional, vector of table names like "B01001" or default,
  [tables_ejscreen_acs](https://ejanalysis.github.io/EJAM/reference/tables_ejscreen_acs.md)

- dataset:

  optional, tested for "acs5" but see
  [`tidycensus::load_variables()`](https://walker-data.com/tidycensus/reference/load_variables.html)

## Value

invisibly returns data.table of all variables in specified tables, and
also prints to console the first variable of each table

## See also

[`url_acs_table_info()`](https://ejanalysis.github.io/EJAM/reference/url_acs_table_info.md)
