# Use EPA Program ID to see FRS Facility Registry Service data on those EPA-regulated sites

Use EPA Program ID to see FRS Facility Registry Service data on those
EPA-regulated sites

## Usage

``` r
frs_from_programid(programname, programid)
```

## Arguments

- programname:

  name of EPA program that the programid is from: "RCRAINFO" is the
  programname and "XJW000000174" is the programid if the full record was
  RCRAINFO:XJW000000174

- programid:

  like "XJW000000174" "RCRAINFO" is the programname and "XJW000000174"
  is the programid if the full record was RCRAINFO:XJW000000174

## Value

relevant rows of the table in [data.table](https://r-datatable.com)
format called [frs](https://ejanalysis.github.io/EJAM/reference/frs.md),
which has column names that are "lat" "lon" "REGISTRY_ID" "PRIMARY_NAME"
"NAICS" "PGM_SYS_ACRNMS"

## Examples

``` r
 test <- data.frame(programname = c('STATE','FIS','FIS'),
                    programid = c('#5005','0-0000-01097','0-0000-01103'))
 x = frs_from_programid(test$programname, test$programid)
 x
 mapfast(x)
```
