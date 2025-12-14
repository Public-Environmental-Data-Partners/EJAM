# Build HTML header for community report

Build HTML header for community report

## Usage

``` r
generate_html_header(
  analysis_title,
  totalpop,
  locationstr,
  in_shiny = FALSE,
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

- report_title:

  generic name of this type of report, to be shown at top, like "EJAM
  Multisite Report"

- logo_path:

  optional relative path to a logo for the upper right of the overall
  header. Ignored if logo_html is specified and not NULL, but otherwise
  uses default or param set in ejamapp(), but NULL means default and ""
  means omit logo entirely.

- logo_html:

  optional HTML for img of logo for the upper right of the overall
  header. If specified, it overrides logo_path. If omitted, gets created
  based on logo_path.

## See also

used by
[`build_community_report()`](https://ejanalysis.github.io/EJAM/reference/build_community_report.md)
