# Check if lat lon are OK – validate latitudes and longitudes

Check each latitude and longitude value to see if they are valid.

## Usage

``` r
latlon_is.valid(
  lat,
  lon,
  quiet = TRUE,
  invalid_msg_table = FALSE,
  exact_but_slow_islandareas = FALSE
)
```

## Arguments

- lat:

  vector of latitudes (or data.frame with colnames lat and lon, in which
  case lon param must be missing)

- lon:

  vector of longitudes

- quiet:

  optional logical, if TRUE, show list of bad values in console

- invalid_msg_table:

  set TRUE if you want a data.frame with colnames "valid" and
  "invalid_msg"

- exact_but_slow_islandareas:

  see
  [`latlon_is.islandareas()`](https://public-environmental-data-partners.github.io/EJAM/reference/latlon_is.islandareas.md)

## Value

logical vector, one element per lat lon pair (location)

## Details

NA or outside expected numeric ranges

(based on approx ranges of lat lon seen among block internal points
dataset)

But note Guam, American Samoa, Northern Mariana Islands, and U.S. Virgin
Islands ranges are approximated! EJSCREEN has not had residential
population data in those locations anyway, but can map sites there. see
latlon_is.islandareas() and note details at
https://www.britannica.com/place/Trust-Territory-of-the-Pacific-Islands
on areas no longer part of the US but still with some sites in FRS, ids
"110009291462" "110013804678" "110067353429" "110067377430"
"110070929074" e.g.,
https://echo.epa.gov/detailed-facility-report?fid=110067353429 or
https://echo.epa.gov/detailed-facility-report?fid=110013804678

lat must be between 17.5 and 71.5, and

lon must be ( between -180 and -64) OR (between 172 and 180)

## See also

[`latlon_is.usa()`](https://public-environmental-data-partners.github.io/EJAM/reference/latlon_is.usa.md)
[`latlon_is.islandareas()`](https://public-environmental-data-partners.github.io/EJAM/reference/latlon_is.islandareas.md)
[`latlon_is.available()`](https://public-environmental-data-partners.github.io/EJAM/reference/latlon_is.available.md)
[`latlon_is.possible()`](https://public-environmental-data-partners.github.io/EJAM/reference/latlon_is.possible.md)
[`latlon_df_clean()`](https://public-environmental-data-partners.github.io/EJAM/reference/latlon_df_clean.md)
[`latlon_infer()`](https://public-environmental-data-partners.github.io/EJAM/reference/latlon_infer.md)
`latlon_is.valid()`
[`latlon_as.numeric()`](https://public-environmental-data-partners.github.io/EJAM/reference/latlon_as.numeric.md)

## Examples

``` r
 # \donttest{
 # this would only work using the EJAM package datasets frs and blockpoints:
   if (!exists("frs")) dataload_dynamic("frs")
 table(EJAM:::latlon_is.valid(lat =  frs$lat, lon =  frs$lon))
 # blockpoints may need to be downloaded using dataload_dynamic()
 table(EJAM:::latlon_is.valid(lat =  blockpoints$lat, lon =  blockpoints$lon))
  # }
```
