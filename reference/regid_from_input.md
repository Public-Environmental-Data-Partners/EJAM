# utility to flexibly figure out registry id from the parameters passed to a function

utility to flexibly figure out registry id from the parameters passed to
a function

## Usage

``` r
regid_from_input(regid = NULL, sitepoints = NULL)
```

## Arguments

- regid:

  optional vector of EPA FRS registry IDs

- sitepoints:

  optional data.frame with a column named regid or REGISTRY_ID

## Value

NULL or vector of ids

## See also

[`sites_from_input()`](https://public-environmental-data-partners.github.io/EJAM/reference/sites_from_input.md)
[`frs_from_regid()`](https://public-environmental-data-partners.github.io/EJAM/reference/latlon_from_regid.md)
regids_valid()
