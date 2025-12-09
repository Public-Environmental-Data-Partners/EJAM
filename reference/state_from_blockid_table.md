# given data.table with blockid column, get state abbreviation of each (function might not be used)

given data.table with blockid column, get state abbreviation of each
(function might not be used)

## Usage

``` r
state_from_blockid_table(dt_with_blockid)
```

## Arguments

- dt_with_blockid:

  (or any table in [data.table](https://r-datatable.com) format with
  either blockid or bgid column)

## Value

vector of ST info like AK, CA, DE, etc.

## Examples

``` r
x = sample(blockpoints$blockid, 3)
EJAM:::state_from_blockid_table(blockpoints[blockid %in% x, ])[]
mapfast(blockpoints[blockid %in% x, ])

table(EJAM:::state_from_blockid_table(testoutput_getblocksnearby_10pts_1miles))
# unique(EJAM:::state_from_latlon(testpoints_10)$ST) # slow

all.equal(EJAM:::state_from_blockid(x), EJAM:::state_from_blockid_table(blockpoints[blockid %in% x, ]))
```
