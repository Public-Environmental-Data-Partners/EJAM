# Get indicator names within a varlist like names_d

Get indicator names within a varlist like names_d

## Usage

``` r
namesbyvarlist(
  varlist,
  nametype = c("rname", "longname", "ejscreen_apinames_old")[1],
  mapping = map_headernames,
  include = NULL,
  exclude = NULL,
  available_vars = NULL
)
```

## Arguments

- varlist:

  one character string like "names_d", or a vector of them

- nametype:

  vector of 1 or more names of columns in map_headernames, or a shortcut
  type that can be api, csv, r, original, long, shortlabel

- mapping:

  data.frame with at least `varlist` and requested `nametype` columns.
  Defaults to
  [map_headernames](https://public-environmental-data-partners.github.io/EJAM/reference/map_headernames.md).

- include:

  optional vector of names to keep.

- exclude:

  optional vector of names to drop.

- available_vars:

  optional vector of names available in a target dataset. Rows whose
  `rname` is not available are dropped.

## Value

a data.frame one row per indicator, one col per nametype and a column
identifying the varlist

## Details

varlist2names() aka namesbyvarlist() is a way to just get a vector of
variable names even if the varlist is not stored as a separate data
object and is only found in the map_headernames\$varlist column:

varlist2names(c('names_d', 'names_d_subgroups'))

c(names_d, names_d_subgroups)

## See also

`varlist2names()`
[`varin_map_headernames()`](https://public-environmental-data-partners.github.io/EJAM/reference/varin_map_headernames.md)
[`varinfo()`](https://public-environmental-data-partners.github.io/EJAM/reference/varinfo.md)
[`names_whichlist_multi_key()`](https://public-environmental-data-partners.github.io/EJAM/reference/names_whichlist_multi_key.md)

## Examples

``` r
 unique(map_headernames$varlist)

 namesbyvarlist('names_e_avg', 'rname')
 namesbyvarlist('names_d')
 namesbyvarlist('names_d', 'r')
 namesbyvarlist('names_d', 'long')
 namesbyvarlist('names_d', 'shortlabel')

 namesbyvarlist( 'names_e_pctile', c('r', 'longname'))
 namesbyvarlist(c('names_e_pctile', 'names_e_state_pctile'),
   c('varlist', 'rname', 'ejscreen_apinames_old', 'csvname', 'shortlabel', 'longname'))
```
