# convert colnames to standardized names, via aliases, but change only best match for each standard name Used by address_from_table()

convert colnames to standardized names, via aliases, but change only
best match for each standard name Used by address_from_table()

## Usage

``` r
fixcolnames_infer(
  currentnames,
  alias_list = list(lat = lat_alias, lon = lon_alias, address = c("address"), street =
    c("street", "street address", "address1", "address 1"), city = c("city", "cityname",
    "city name"), state = c("state", "mystate", "statename", "ST"), zip = c("zip",
    "zipcode", "zip code")),
  ignore.case = TRUE,
  verbose = FALSE
)
```

## Arguments

- currentnames:

  vector of colnames that may include aliases

- alias_list:

  optional named list where names are standard colnames like "street"
  and each named element in list is a vector of aliases for that
  standard name

- ignore.case:

  whether to ignore case in matching to aliases

- verbose:

  set to TRUE for testing/ to check what this function does

## Value

vector like currentnames but some renamed to a standard name if alias
found, ignoring case.

## Details

`fixcolnames_infer()` and
[`fixnames_aliases()`](https://public-environmental-data-partners.github.io/EJAM/reference/fixnames_aliases.md)
are very similar. and latlon_infer() is also very similar.

- `fixcolnames_infer()` is designed to figure out for a data.frame which
  one column is the best guess (top pick) for which should be used as
  the "lat" column, for example, so when several colnames are matches to
  one preferred name, based on the alias_list, this function picks only
  one of them to rename to the preferred or canonical name, leaving
  others as-is.

- In contrast to that,
  [`fixnames_aliases()`](https://public-environmental-data-partners.github.io/EJAM/reference/fixnames_aliases.md)
  is more general and every input element that can be matched with a
  canonical name gets changed to that preferred version, so even if
  multiple input names are different aliases of "lat", for example, they
  all get changed to "lat."

## See also

[`latlon_infer()`](https://public-environmental-data-partners.github.io/EJAM/reference/latlon_infer.md)
[`fixnames_aliases()`](https://public-environmental-data-partners.github.io/EJAM/reference/fixnames_aliases.md)
that is almost the same
