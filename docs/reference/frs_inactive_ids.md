# Download national file and find which IDs are the INACTIVE sites in the FRS

Download national file and find which IDs are the INACTIVE sites in the
FRS

## Usage

``` r
frs_inactive_ids(active = FALSE, ...)
```

## Arguments

- active:

  If FALSE, default, returns the registry IDs of sites that seem to be
  inactive, based on closecodes.

- ...:

  passed to frs_active_ids()

## Value

vector of FRS IDs that are the clearly inactive sites – or all other
sites – depending on value of active

@keywords internal

## See also

[`frs_active_ids()`](https://public-environmental-data-partners.github.io/EJAM/reference/frs_active_ids.md)
[`frs_update_datasets()`](https://public-environmental-data-partners.github.io/EJAM/reference/frs_update_datasets.md)
