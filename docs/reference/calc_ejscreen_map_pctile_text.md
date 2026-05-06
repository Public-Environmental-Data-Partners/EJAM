# Calculate EJSCREEN percentile popup text

Calculate EJSCREEN percentile popup text

## Usage

``` r
calc_ejscreen_map_pctile_text(x)
```

## Arguments

- x:

  numeric vector of percentiles on a 0-100 scale.

## Value

character vector.

## Details

Percentiles are expected on EJSCREEN's 0-100 scale. The returned strings
follow the current EJSCREEN app service style, such as `"95 %ile"`.
Missing or out-of-range percentiles return `NA_character_`.
