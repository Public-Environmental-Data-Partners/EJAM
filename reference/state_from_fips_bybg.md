# Get FIPS of ALL BLOCKGROUPS in the States or Counties specified

Get the State abbreviations of ALL blockgroups WITHIN the input FIPS

## Usage

``` r
state_from_fips_bybg(fips, uniqueonly = FALSE)
```

## Arguments

- fips:

  Census FIPS codes vector, numeric or char, 2-digit, 5-digit, etc. OK

- uniqueonly:

  If set to TRUE, returns only unique results. This parameter is here
  mostly to remind user that default is not uniques only.

## Value

vector of 2-character state abbreviations like CA,CA,CA,MD,MD,TX

## Details

Unlike
[`fips2stateabbrev()`](https://public-environmental-data-partners.github.io/EJAM/reference/fips2stateabbrev.md),
this returns a vector of 2-letter State abbreviations that is one per
blockgroup that matches the input FIPS, not necessarily a vector as long
as the input vector of FIPS codes!, and not just a short list of unique
states!

## See also

[`fips2stateabbrev()`](https://public-environmental-data-partners.github.io/EJAM/reference/fips2stateabbrev.md)
to get just one state per FIPS
