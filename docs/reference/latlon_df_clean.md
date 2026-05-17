# Get lat lon columns (or create them from geocoding addresses), and clean up those columns in a data.frame

Utility to identify lat and lon columns (or addresses), renaming and
cleaning them up.

## Usage

``` r
latlon_df_clean(df, invalid_msg_table = FALSE, set_invalid_to_na = TRUE)
```

## Arguments

- df:

  data.frame With columns lat and lon or names that can be interpreted
  as such, or addresses that can be geocoding to create lat lon columns

- invalid_msg_table:

  Set to TRUE to add columns "valid" and "invalid_msg" to output

- set_invalid_to_na:

  if not set FALSE, it replaces invalid lat or lon with NA values

## Value

Returns the same data.frame but with relevant colnames changed to lat
and lon, or lat,lon added based on addresses, and invalid lat or lon
values cleaned up if possible or else replaced with NA, and optional
columns "valid" and "invalid_msg"

## Details

Tries to figure out which columns seem to have lat lon values, or
addresses that can be converted to lat lon columns, renames those in the
data.frame. Cleans up lat and lon values (removes extra characters,
makes numeric)

## See also

Used by
[`latlon_from_anything()`](https://public-environmental-data-partners.github.io/EJAM/reference/latlon_from_anything.md).
Uses
[`latlon_infer()`](https://public-environmental-data-partners.github.io/EJAM/reference/latlon_infer.md)
[`latlon_is.valid()`](https://public-environmental-data-partners.github.io/EJAM/reference/latlon_is.valid.md)
[`latlon_as.numeric()`](https://public-environmental-data-partners.github.io/EJAM/reference/latlon_as.numeric.md)

## Examples

``` r
  #  x <- EJAM:::latlon_df_clean(x)
 EJAM:::latlon_df_clean(testpoints_bad, set_invalid_to_na = FALSE, invalid_msg_table = TRUE)
```
