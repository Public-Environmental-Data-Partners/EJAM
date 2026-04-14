# get lat,lon from table that contains USPS addresses

get lat,lon from table that contains USPS addresses

## Usage

``` r
latlon_from_address_table(x)
```

## Arguments

- x:

  data.frame or can be missing if interactive

## Value

same as output of
[`latlon_from_address()`](https://public-environmental-data-partners.github.io/EJAM/reference/latlon_from_address.md)

## Examples

``` r
address_from_table(testinput_address_table)

## see available test data objects and files:

# cbind(data.in.package  = sort(grep("address", pkg_data()$Item, value = T)))
# cbind(files.in.package = sort(basename(testdata('address', quiet = T))))

# \donttest{

# This requires first attaching the AOI package.

pts <- latlon_from_address(testinput_address_9[1:2])
## out <- ejamit(pts, radius = 1)
## ejam2report(out)

latlon_from_address_table(testinput_address_table)
latlon_from_address_table(testinput_address_table_withfull)
## *** NOTE IT FAILS IF A COLUMN WITH STREET NAME ONLY IS CALLED "address"
##   instead of that storing the full address.
# }
fixcolnames_infer(currentnames = testinput_address_parts)
fixcolnames_infer(currentnames = names(testinput_address_table))
```
