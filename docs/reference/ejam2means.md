# ejam2means - quick look at averages, via ejamit() results

ejam2means - quick look at averages, via ejamit() results

## Usage

``` r
ejam2means(ejamitout, vars = names_these)
```

## Arguments

- ejamitout:

  as from ejamit()

- vars:

  all or some of colnames in ejamitout\$results_overall

## Value

means in a useful format

## Examples

``` r
out <- testoutput_ejamit_100pts_1miles
ejam2means(out, vars = names_e_ratio_to_state_avg)

#' # these should tell you the same thing:
out$results_summarized$keystats[
  rownames(out$results_summarized$keystats) %in% names_e_ratio_to_state_avg,
]
ejam2means(out, vars = names_e_ratio_to_state_avg)
```
