# like fixcolnames(), a helper function to rename variables that are colnames of data.frame

Changes column names to R variable names from original API names in FTP
site file

## Usage

``` r
fixnames(namesnow, oldtype = "api", newtype = "r", mapping_for_names)
```

## Arguments

- namesnow:

  vector of colnames (but can be a data.frame or data.table too)

- oldtype:

  designation of the type of variables in namesnow: "long" or
  "original", or "csv" or "r" or "api" (colnames of map_headernames, or
  aliases per helper
  [`fixmapheadernamescolname()`](https://public-environmental-data-partners.github.io/EJAM/reference/fixmapheadernamescolname.md))

- newtype:

  the type to rename to – see similar oldtype parameter

- mapping_for_names:

  data.frame passed to `fixnames()` to do the work.

## Value

Vector or new column names same length as input. The function does NOT
return an entire renamed df or dt. Just the new colnames are returned.

## Details

YOU CAN SPECIFY A TYPE USING AN ALIAS LIKE "api" or "long" UNLIKE IN
[`fixnames_to_type()`](https://public-environmental-data-partners.github.io/EJAM/reference/fixnames_to_type.md)
where you had to specify the actual colnames of map_headernames, like
"apiname"

NOTE: If you happen to pass the entire data.frame or data.table to this
function, instead of passing just the colnames, this function will see
that and still return just a vector of new colnames

## See also

[`varinfo()`](https://public-environmental-data-partners.github.io/EJAM/reference/varinfo.md)
[`fixnames_to_type()`](https://public-environmental-data-partners.github.io/EJAM/reference/fixnames_to_type.md)
[`fixcolnames()`](https://public-environmental-data-partners.github.io/EJAM/reference/fixcolnames.md)
`fixnames()`
