# Guess which columns have lat and lon based on aliases like latitude, FacLat, etc.

Guess which columns have lat and lon based on aliases like latitude,
FacLat, etc.

## Usage

``` r
latlon_infer(mycolnames)
```

## Arguments

- mycolnames:

  e.g., colnames(x) where x is a data.frame from read.csv

## Value

returns all of mycolnames except replacing the best candidates with lat
and lon

## See also

latlon_df_clean() latlon_is.valid()
latlon_as.numeric()[`fixnames_aliases()`](https://public-environmental-data-partners.github.io/EJAM/reference/fixnames_aliases.md)
[`fixcolnames_infer()`](https://public-environmental-data-partners.github.io/EJAM/reference/fixcolnames_infer.md)

## Examples

``` r
  EJAM:::latlon_infer(c('trilat', 'belong', 'belong')) # warns if no alias found,
    #  but doesnt warn of dupes in other terms, just preferred term.
  EJAM:::latlon_infer(c('a', 'LONG', 'Longitude', 'lat')) # only the best alias is converted/used
  EJAM:::latlon_infer(c('a', 'LONGITUDE', 'Long', 'Lat')) # only the best alias is converted/used
  EJAM:::latlon_infer(c('a', 'longing', 'Lat', 'lat', 'LAT')) # case variants of preferred are
      # left alone only if lowercase one is found
  EJAM:::latlon_infer(c('LONG', 'long', 'lat')) # case variants of a single alias are
      # converted to preferred word (if pref not found), creating dupes!  warn!
  EJAM:::latlon_infer(c('LONG', 'LONG')) # dupes of an alias are renamed and still are dupes! warn!
  EJAM:::latlon_infer(c('lat', 'lat', 'Lon')) # dupes left as dupes but warn!
```
