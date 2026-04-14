# utility to convert aliases to proper colnames of map_headernames used by varinfo() and fixcolnames()

utility to convert aliases to proper colnames of map_headernames used by
varinfo() and fixcolnames()

## Usage

``` r
fixmapheadernamescolname(
  x,
  alias_list = list(rname = c("r", "rnames"), longname = c("long", "longnames", "full",
    "description"), shortlabel = c("short", "shortname", "shortnames", "shortlabels",
    "labels", "label"), acsname = c("acs", "acsnames"), apiname = c("api", "apinames"),
    csvname = c("csv", "csvnames"), oldname = c("original", "old", "oldnames"))
)
```

## Arguments

- x:

  character vector of colnames of map_headernames, or aliases like
  "long" (ignores case)

- alias_list:

  optional named list where canonical names (colnames in
  map_headernames) are the names of vectors of alternative names

## Value

vector where aliases are replaced with actual colnames and unmatched
ones left as-is

## See also

[`fixnames_aliases()`](https://public-environmental-data-partners.github.io/EJAM/reference/fixnames_aliases.md)
[`fixcolnames()`](https://public-environmental-data-partners.github.io/EJAM/reference/fixcolnames.md)
[`varinfo()`](https://public-environmental-data-partners.github.io/EJAM/reference/varinfo.md)

## Examples

``` r
  EJAM:::fixmapheadernamescolname(c('long', 'csv', 'api', 'r'))
```
