# Use EPA Program acronym like TRIS to see FRS Facility Registry Service data on those EPA-regulated sites

Get data.table based on given FRS Program System CATEGORY. Find all FRS
sites in a program like RCRAINFO, TRIS, or others.

## Usage

``` r
frs_from_program(program)
```

## Arguments

- program:

  vector of one or more EPA Program names used by FRS

## Value

relevant rows of the table in [data.table](https://r-datatable.com)
format called [frs](https://ejanalysis.github.io/EJAM/reference/frs.md),
which has column names that are "lat" "lon" "REGISTRY_ID" "PRIMARY_NAME"
"NAICS" "PGM_SYS_ACRNMS"

## Details

Also see [EPA documentation describing each program
code](https://www.epa.gov/frs/frs-data-sources) aka data source.
