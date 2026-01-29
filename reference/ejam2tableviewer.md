# See ejamit()\$results_bysite in interactive table in RStudio viewer pane

See ejamit()\$results_bysite in interactive table in RStudio viewer pane

## Usage

``` r
ejam2tableviewer(
  out,
  filename = "automatic",
  maxrows = 1000,
  launch_browser = TRUE,
  ...
)
```

## Arguments

- out:

  output of ejamit(), or one table like `ejamit()$results_overall`, or
  subset like `ejamit()$results_bysite[7,]`

- filename:

  optional. path and name of the html file to save the table to, or it
  uses tempdir() if not specified. Set it to NULL to prevent saving a
  file.

- maxrows:

  only load/ try to show this many rows max.

- launch_browser:

  set TRUE to have it launch browser and show report. Ignored if not
  interactive() or if filename is set to NULL.

- ...:

  passed to
  [`DT::datatable()`](https://rdrr.io/pkg/DT/man/datatable.html)

## Value

a datatable object using
[`DT::datatable()`](https://rdrr.io/pkg/DT/man/datatable.html) that can
be printed to the console or shown in the RStudio viewer pane

## Examples

``` r
ejam2tableviewer(testoutput_ejamit_10pts_1miles)
```
