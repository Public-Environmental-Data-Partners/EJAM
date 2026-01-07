# plot_demogshare_by_distance - work in progress

plot_demogshare_by_distance - work in progress

## Usage

``` r
plot_demogshare_by_distance(
  results_bybg_people,
  demogvarname = names_d[1],
  myids = unique(results_bybg_people$ejam_uniq_id),
  show.lowess = F,
  show.lm = TRUE,
  show.line = TRUE,
  ...
)
```

## Arguments

- results_bybg_people:

  table as from ejamit()\$results_results_bybg_people, like
  testoutput_ejamit_10pts_1miles\$results_bybg_people

- demogvarname:

  one of the column names of results_bybg_people, such as one of names_d
  like "Demog.Index.Supp"

- myids:

  optional vector of ejam_uniq_id values

- show.lowess:

  whether to show curve fitted via graphics::lines(stats::lowess(x,y))
  using [`stats::lowess()`](https://rdrr.io/r/stats/lowess.html)

- show.lm:

  whether to show straight line fitted via
  [`stats::lm()`](https://rdrr.io/r/stats/lm.html)

- show.line:

  whether to show straight line fitted via stats::coef(line(x,y)) using
  [`stats::coef()`](https://rdrr.io/r/stats/coef.html) and
  [`stats::line()`](https://rdrr.io/r/stats/line.html)

- ...:

  passed to
  [`plot()`](https://r-spatial.github.io/sf/reference/plot.html)

## Value

just used to create plot as side effect

## Details

Could also consider plotting something like boxplot(demogvar ~
round(distance, 1))

See notes on plots at
[`plot_barplot_ratios()`](https://ejanalysis.github.io/EJAM/reference/plot_barplot_ratios.md)
