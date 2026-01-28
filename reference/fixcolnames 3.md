# helper function to rename variables that are colnames of data.frame

Changes variable names like colnames to long plain-English headers or
short labels for plots

## Usage

``` r
fixcolnames(namesnow, oldtype = "csvname", newtype = "r", mapping_for_names)
```

## Arguments

- namesnow:

  vector of colnames to be renamed

- oldtype:

  designation of the type of variables in namesnow: "long" or
  "shortlabel" or "original", or "csv" or "r" (aka "rname") or "api" or
  "longname" or "shortname" etc. (colnames of map_headernames, or
  aliases per helper
  [`fixmapheadernamescolname()`](https://ejanalysis.github.io/EJAM/reference/fixmapheadernamescolname.md))

- newtype:

  the type to rename to (or column to query for metadata) – see similar
  oldtype parameter

- mapping_for_names:

  default is a dataset already in the package.

## Value

Vector or new column names same length as input

## Details

You specify an alias of a type like "api", "r", "long", or "short", or
one of `colnames(map_headernames)` like "rname", "vartype", "decimals",
"varlist", etc.

Also, you can use this to extract any info from `map_headernames` (which
here is called mapping_for_names).

NOTE: if you ask to rename your words to a known type like rname or
apiname, and the namesnow is not found among the oldtype, then it is not
renamed, and those are returned as unchanged. BUT, if you specify as
newtype some column that is not a known type of name, like "varcategory"
then it will instead return an empty string for those in namesnow that
are not found among the oldtype. That way if you are really seeking a
new name, but it cannot rename, it keeps the old name while if you are
really seeking metadata like what category it is in, it returns a blank
if the old name is not found at all.

These are some key column names in the
[map_headernames](https://ejanalysis.github.io/EJAM/reference/map_headernames.md)
table:

- "shortname" (aka "short", for plot labels, etc.)

- "longname" (aka "long", for full explanatory headers to use on a
  table)

- "rname" (aka "r", the R variable names as used in the EJAM code)

- "apiname" (aka "api", as returned by EJSCREEN API)

- "csvname" (aka "csv", as found in the CSV files of just the key
  residential population and environmental indicators, found on the
  EJSCREEN FTP site)

- "acsname" (aka "acs", as found in a ACS data file internally used by
  EJSCREEN, containing all the extra residential population groups and
  other indicators not stored in the CSV files on the EJSCREEN FTP site)

- "DEJ" (whether the indicator is residential population, environmental,
  etc.)

- "varlist" (which group of names is this variable in, such as
  "names_d", "names_d_subgroups", "names_d_state_pctile", etc.)

- "calculation_type" (how it should be aggregated over blockgroups, such
  as "wtdmean", "sum of counts", etc.)

- "denominator" (the weight to use in aggregating as a wtdmean, normally
  a count variable that is the universe for a percentage, such as "pop",
  "hhlds", etc.)

## See also

[`varinfo()`](https://ejanalysis.github.io/EJAM/reference/varinfo.md)

## Examples

``` r
 # see package tests

 names_d
 namesbyvarlist('names_d')
 x = varinfo("pctlowinc")
 x = varinfo("pcthisp")


 # see the different names for the same variable,
 # and see it is not in the csv tables on the FTP site
 varinfo("pcthisp", c("csvname", "acsname", "apiname"))

 # EJAM:::names_whichlist("RAW_D_INCOME")
 fixcolnames(c("RAW_D_INCOME", "S_D_LIFEEXP"), 'api')
 fixcolnames('LOWINCPCT', 'csv')
 fixcolnames(c("PCT_HISP", "HISP"), 'acs')
 fixcolnames(c("RAW_D_INCOME", "S_D_LIFEEXP"), newtype = "longname")

 addmargins(table(map_headernames$vartype, map_headernames$DEJ))

  # the columns "newsort" and "reportsort" provide useful sort orders
  x <- map_headernames$rname[map_headernames$varlist == "names_d"]
  # same as

  print("original order"); print(x)
  x <-  sample(x, length(x), replace = FALSE)
  print("out of order"); print(x)
  print("fixed order")
  x[ order(fixcolnames(x, oldtype = "r", newtype = "newsort")) ]
```
