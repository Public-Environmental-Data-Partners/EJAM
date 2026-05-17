# helper function to change elements of namesnow from an oldtype to a newtype of names

helps convert between original variable names and plain-English short or
long versions of variable names

## Usage

``` r
fixnames_to_type(
  namesnow,
  oldtype = "ejscreen_apinames_old",
  newtype = "rname",
  mapping_for_names
)
```

## Arguments

- namesnow:

  vector of strings, such as from colnames(x)

- oldtype:

  designation of the type of variables in namesnow: "long" or
  "shortlabel" or "original", or "csv" or "r" (aka "rname") or "api" or
  "longname" or "shortname" etc. (colnames of map_headernames, or
  aliases per helper
  [`fixmapheadernamescolname()`](https://public-environmental-data-partners.github.io/EJAM/reference/fixmapheadernamescolname.md))

- newtype:

  the type to rename to (or column to query for metadata) – see similar
  oldtype parameter

- mapping_for_names:

  data.frame passed to
  [`fixnames()`](https://public-environmental-data-partners.github.io/EJAM/reference/fixnames.md)
  to do the work with colnames that are referred to by oldtype and
  newtype

## Value

Vector or new column names same length as input

## Details

YOU NEED TO SPECIFY NAMES OF COLUMNS IN MAP_HEADERNAMES, like
"ejscreen_apinames_old" or "rname", UNLIKE IN fixnames() or
fixcolnames() where you specify a type like "long" or "api" Using lookup
table mapping_for_names, finds each namesnow in the column specified by
oldtype and replaces it with the corresponding string in the column
specified by newtype

## See also

[`varinfo()`](https://public-environmental-data-partners.github.io/EJAM/reference/varinfo.md)
[`fixcolnames()`](https://public-environmental-data-partners.github.io/EJAM/reference/fixcolnames.md)
[`fixnames()`](https://public-environmental-data-partners.github.io/EJAM/reference/fixnames.md)
