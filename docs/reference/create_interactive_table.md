# creates interactive html version of site by site table in app

Builds site by site table after an analysis in EJAM app. Pulls in
uploaded and analyzed data to create table

## Usage

``` r
create_interactive_table(
  out,
  reports = EJAM:::global_or_param("default_reports"),
  sitereport_download_buttons_colname = "Download EJAM Report",
  sitereport_download_buttons_show = TRUE,
  columns_used = NULL
)
```

## Arguments

- out:

  list of tables like data_processed in app_server, similar to output of
  ejamit()

- reports:

  ignored for now - info about which URLs/links/reports columns to
  include among those already in out

- sitereport_download_buttons_colname:

  header for column to create with buttons to download 1-site reports in
  shiny app

- sitereport_download_buttons_show:

  if TRUE, add column near first with buttons to allow download of
  1-site html summary report

- columns_used:

  if specified in server based on defaults or inputs, these are a subset
  of colnames from ejamit()\$results_bysite to show in site-by-site
  interactive table

## See also

[`ejam2tableviewer()`](https://ejanalysis.github.io/EJAM/reference/ejam2tableviewer.md)
