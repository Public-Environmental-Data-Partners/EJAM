# Convert terms to standardized terms based on synonyms

Convert terms to standardized terms based on synonyms

## Usage

``` r
fixnames_aliases(
  x,
  na_if_no_match = FALSE,
  alias_list = NULL,
  ignore.case = TRUE
)
```

## Arguments

- x:

  vector of terms, such as colnames(testpoints_10), etc.

- na_if_no_match:

  optional, set to TRUE if you want it to return NA for each element of
  x not found in the alias_list info

- alias_list:

  built-in already in source code (but can replace using this optional
  parameter), a list of named vectors where names are standard,
  preferred, canonical versions of terms, and each vector is a set of
  aliases for that term.

- ignore.case:

  optional set to FALSE if you want to not ignore case

## Value

character vector like x but where some or all may be replaced by
standardized versions of the elements of x, or NA if appropriate

## Details

[`fixcolnames_infer()`](https://ejanalysis.github.io/EJAM/reference/fixcolnames_infer.md)
and `fixnames_aliases()` are very similar.

- [`fixcolnames_infer()`](https://ejanalysis.github.io/EJAM/reference/fixcolnames_infer.md)
  is designed to figure out for a data.frame which one column is the
  best guess (top pick) for which should be used as the "lat" column,
  for example, so when several colnames are matches based on the
  alias_list, this function picks only one of them to rename to the
  preferred or canonical name, leaving others as-is.

- In contrast to that, `fixnames_aliases()` is more general and every
  input element that can be matched with a canonical name gets changed
  to that preferred version, so even if multiple input names are
  different aliases of "lat", for example, they all get changed to
  "lat."

The alias_list could be for example this:

     alias_list <- list(
      sqkm = c('km2', 'kilometer2','kilometers2', 'sq kilometers', 'sq kilometer',
       'sqkilometers', 'sqkilometer',  'squarekilometers', 'squarekilometer',
       'square kilometers', 'square kilometer'),
      sqm = c('m2', 'meter2','meters2', 'sq meters', 'sq meter','sqmeters', 'sqmeter',
      'squaremeters', 'squaremeter', 'square meters', 'square meter'),
      mi = c('mile', 'miles'),

      lat = lat_alias,
      #[1]"lat" "latitude83" "latitude" "latitudes"  "faclat" "lats" "y"
      lon = lon_alias,
      #[1]"lon" "longitude83" "longitude" "longitudes" "faclong" "lons" "long" "longs" "lng" "x"

    )

## See also

[`fixcolnames_infer()`](https://ejanalysis.github.io/EJAM/reference/fixcolnames_infer.md)
[`latlon_infer()`](https://ejanalysis.github.io/EJAM/reference/latlon_infer.md)
[`fixcolnames()`](https://ejanalysis.github.io/EJAM/reference/fixcolnames.md)

## Examples

``` r
fixnames_aliases(c("km", "kilometer", "miles", "statename", 'X', "y"))
fixnames_aliases("LATITUDE")
fixnames_aliases("LATITUDE", ignore.case = F)
fixnames_aliases("LATITUDE", na_if_no_match = T)
fixnames_aliases("LATITUDE", na_if_no_match = T, ignore.case = F)
fixnames_aliases(c(NA, 1, "typo", 1:2))

fixnames_aliases(c(1:4, "na", "tbd"),
  alias_list = list(upto1 = 0:1, company = 2, crowd = 3:10, other = c("na", "tbd")))
```
