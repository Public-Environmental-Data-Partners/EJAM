# URL functions - Compile URLs in columns, for EJAM

URL functions - Compile URLs in columns, for EJAM

## Usage

``` r
url_columns_bysite(
  sitepoints = NULL,
  lat = NULL,
  lon = NULL,
  shapefile = NULL,
  fips = NULL,
  wherestr = "",
  regid = NULL,
  radius = NULL,
  reports = EJAM:::global_or_param("default_reports"),
  sitetype = NULL,
  as_html = TRUE,
  validate_regids = FALSE,
  ...
)
```

## Arguments

- sitepoints:

  data.frame or table in [data.table](https://r-datatable.com) format
  with lat and lon columns (and should have ejam_uniq_id column or
  assume 1 output row per input row, same order)

- lat, lon:

  if sitepoints NULL/missing, vectors of latitudes and longitudes
  (assumes ejam_uniq_id is not available and treats output as 1 per
  input same order)

- shapefile:

  spatial data.frame, class sf, see ejamit() parameter of same name.
  (and should have ejam_uniq_id column or assume 1 output row per input
  row, same order)

- fips:

  vector of FIPS codes if relevant (instead of sitepoints or shapefile
  input) Note that nearly half of all county fips codes are impossible
  to distinguish from 5-digit zipcodes because the same numbers are used
  for both purposes.

- wherestr:

  optional because inferred from fips if provided. Passed to
  [`url_ejscreenmap()`](https://ejanalysis.github.io/EJAM/reference/url_ejscreenmap.md)
  and can be name of city, county, state like from fips2name(201090), or
  "new rochelle, ny" or "AK" or even a zip code, but NOT a fips code!
  (for FIPS, use the fips parameter instead). Note that nearly half of
  all county fips codes are impossible to distinguish from 5-digit
  zipcodes because the same numbers are used for both purposes.

- regid:

  optional vector of FRS registry IDs if available to use to create
  links to detailed ECHO facility reports

- radius:

  vector of values for radius in miles

- reports:

  optional list of lists specifying which report types to include – see
  the file "global_defaults_package.R" or source code for this function
  for how this is defined.

- sitetype:

  optional "latlon" or "shp" or "fips" but can be inferred from other
  params

- as_html:

  Whether to return as just the urls or as html hyperlinks to use in a
  DT::datatable() for example passed to
  [`url_ejamapi()`](https://ejanalysis.github.io/EJAM/reference/url_ejamapi.md),
  [`url_ejscreenmap()`](https://ejanalysis.github.io/EJAM/reference/url_ejscreenmap.md),
  or other url_xyz report functions.

- validate_regids:

  if set TRUE, returns NA where a regid is not found in the FRS dataset
  that is currently being used by this package (which might not be the
  very latest from EPA). If set FALSE, faster since avoids checking but
  some links might not work and not warn about bad regid values.

- ...:

  passed to each function, and can be any parameter that any of them
  uses

## Value

list of data.frames to append to the list of data.frames created by
[`ejamit()`](https://ejanalysis.github.io/EJAM/reference/ejamit.md) or
[`doaggregate()`](https://ejanalysis.github.io/EJAM/reference/doaggregate.md)

## Details

used in
[`table_xls_format()`](https://ejanalysis.github.io/EJAM/reference/table_xls_format.md),
and server, to create hyperlinks to reports or webpages, one per site

## See also

[`url_ejamapi()`](https://ejanalysis.github.io/EJAM/reference/url_ejamapi.md)
[`url_ejscreenmap()`](https://ejanalysis.github.io/EJAM/reference/url_ejscreenmap.md)
[`url_echo_facility()`](https://ejanalysis.github.io/EJAM/reference/url_echo_facility.md)

## Examples

``` r
x =  EJAM:::url_columns_bysite(testpoints_10[1:2,], radius = 1)

x =  EJAM:::url_columns_bysite(
  data.frame(lat=1:2, lon=101:102), radius = 1,
  INFO_FOR_SITE2 = c(NA, "site2"),
  Place1info = c("North", ""),
  keylist_bysite = list(newkey_all_sites = "YES",
                        site_name = c("NRO", "CRS"))
  )
EJAM:::unlinkify(x[[2]])
x = x[[1]]
x = x[, "EJAM Report"]
EJAM:::unlinkify(x)
```
