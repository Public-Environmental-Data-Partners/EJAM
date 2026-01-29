# bgpts (DATA) lat lon of popwtd center of blockgroup, and count of blocks per blockgroup

This is just a list of US blockgroups and how many blocks are in each.
It also has the lat and lon roughly of each blockgroup

## Usage

``` r
bgpts
```

## Format

An object of class `data.table` (inherits from `data.frame`) with 242355
rows and 5 columns.

## Details

The point used for each blockgroup. is the Census 2020 population
weighted mean of the internal points of the blocks in the blockgroup. It
gives an approximation of where people live and where each bg is, which
is useful for some situations. Has all US States, DC, PR, but not "AS"
"GU" "MP" "VI" (and not U.S. Minor Outlying Islands FIPS 74 UM)
