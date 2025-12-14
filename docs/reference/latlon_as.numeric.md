# Strip non-numeric characters from a vector

Remove all characters other than minus signs, decimal points, and
numeric digits

## Usage

``` r
latlon_as.numeric(x)
```

## Arguments

- x:

  vector of something that is supposed to be numbers like latitude or
  longitude and may be a character vector because there were some other
  characters like tab or space or percent sign or dollar sign

## Value

numeric vector same length as x

## Details

Useful if latitude or longitude vector has spaces, tabs, etc. CAUTION -
Assumes stripping those out and making it numeric will fix whatever
problem there was and end result is a valid set of numbers. Inf etc. are
turned into NA values. Empty zero length string is turned into NA
without warning. NA is left as NA. If anything other than empty or NA
could not be interpreted as a number, it returns NA for those and offers
a warning.

## See also

latlon_df_clean() latlon_infer() latlon_is.valid() latlon_as.numeric()

## Examples

``` r
  EJAM:::latlon_as.numeric(c("-97.179167000000007", " -94.0533", "-95.152083000000005"))
  EJAM:::latlon_as.numeric(-3:3)
  EJAM:::latlon_as.numeric(c(1:3, NA))
  EJAM:::latlon_as.numeric(c(1, 'asdf'))
  EJAM:::latlon_as.numeric(c(1, ''))
  EJAM:::latlon_as.numeric(c(1, '', NA))
  EJAM:::latlon_as.numeric(c('aword', '$b'))
  EJAM:::latlon_as.numeric(c('-10.5%', '<5', '$100'))
  EJAM:::latlon_as.numeric(c(Inf, 1))
```
