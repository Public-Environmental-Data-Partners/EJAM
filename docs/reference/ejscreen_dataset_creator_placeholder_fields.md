# Fields that are commonly placeholders in EJScreen dataset-creator input

Fields that are commonly placeholders in EJScreen dataset-creator input

## Usage

``` r
ejscreen_dataset_creator_placeholder_fields()
```

## Value

character vector of field names.

## Details

`EXCEED_COUNT_80` and `EXCEED_COUNT_80_SUP` are naturally derived after
EJ indexes and percentiles exist, but the EPA dataset-creator default
`extra_cols` list includes them as input columns. This helper names
those fields so
[`calc_ejscreen_dataset_creator_input()`](https://public-environmental-data-partners.github.io/EJAM/reference/calc_ejscreen_dataset_creator_input.md)
can include explicit `NA` placeholders and report them.
