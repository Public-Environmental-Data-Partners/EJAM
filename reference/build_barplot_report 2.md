# Generate HTML Page for Summary Barplot Report in shiny app

Creates header and footer of 1 page report to include a barplot on
results for one site (to supplement the EJSCREEN Community Report)

## Usage

``` r
build_barplot_report(
  analysis_title,
  totalpop,
  locationstr,
  in_shiny = FALSE,
  filename = NULL,
  report_title = NULL,
  logo_path = NULL,
  logo_html = NULL
)
```

## Arguments

- analysis_title, :

  title to use in header of report

- totalpop, :

  total population included in location(s) analyzed

- locationstr, :

  description of the location(s) analyzed

- in_shiny, :

  whether the function is being called in or outside of shiny - affects
  location of header

- filename, :

  path to file to save HTML content to; if null, returns as string (used
  in Shiny app)

- report_title:

  generic name of this type of report, to be shown at top, like "EJAM
  Multisite Report"

- logo_path:

  optional relative path to a logo for the upper right of the overall
  header. Ignored if logo_html is specified and not NULL, but otherwise
  uses default or param set in ejamapp()

- logo_html:

  optional HTML for img of logo for the upper right of the overall
  header. If specified, it overrides logo_path. If omitted, gets created
  based on logo_path.

## Value

can return HTML if filename not specified, but otherwise NULL

## Details

For a related function for use in RStudio, see
[`ejam2report()`](https://ejanalysis.github.io/EJAM/reference/ejam2report.md)
which relies on
[`build_community_report()`](https://ejanalysis.github.io/EJAM/reference/build_community_report.md)
