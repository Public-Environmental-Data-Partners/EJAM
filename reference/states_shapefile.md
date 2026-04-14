# This is used to figure out which state contains each point (facility/site).

This is used to figure out which state contains each point
(facility/site).

## Usage

``` r
states_shapefile
```

## Format

An object of class `sf` (inherits from `data.frame`) with 56 rows and 15
columns.

## Details

This is used by
[`state_from_latlon()`](https://public-environmental-data-partners.github.io/EJAM/reference/state_from_latlon.md)
to find which state is associated with each point that the user wants to
analyze. That is needed to report indicators in the form of
State-specific percentiles (e.g., a score that is at the 80th percentile
within Texas). It is created by the package via a script at
EJAM/data-raw/datacreate_states_shapefile.R which downloads the data
from Census Bureau.

## See also

seealso
[`state_from_latlon()`](https://public-environmental-data-partners.github.io/EJAM/reference/state_from_latlon.md)
[`get_blockpoints_in_shape()`](https://public-environmental-data-partners.github.io/EJAM/reference/get_blockpoints_in_shape.md)
