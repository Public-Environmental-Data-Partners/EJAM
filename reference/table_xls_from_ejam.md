# Format the results of ejamit() for excel and optionally save .xlsx file

Almost identical to
[`ejam2excel()`](https://ejanalysis.github.io/EJAM/reference/ejam2excel.md)

## Usage

``` r
table_xls_from_ejam(
  ejamitout,
  fname = NULL,
  save_now = TRUE,
  overwrite = TRUE,
  launchexcel = FALSE,
  interactive_console = TRUE,
  ok2plot = TRUE,
  in.testing = FALSE,
  in.analysis_title = "EJAM analysis",
  react.v1_summary_plot = NULL,
  radius_or_buffer_in_miles = NULL,
  buffer_desc = "Selected Locations",
  radius_or_buffer_description = NULL,
  reports = EJAM:::global_or_param("default_reports"),
  site_method = "",
  mapadd = FALSE,
  report_map = NULL,
  community_reportadd = TRUE,
  community_html = NULL,
  shp = NULL,
  ...
)
```

## Arguments

- ejamitout:

  output of
  [`ejamit()`](https://ejanalysis.github.io/EJAM/reference/ejamit.md)

- fname:

  optional name or full path and name of file to save locally, like
  "out.xlsx"

- save_now:

  optional logical, whether to save as a .xlsx file locally or just
  return workbook object that can later be written to .xlsx file using
  [`openxlsx::saveWorkbook()`](https://rdrr.io/pkg/openxlsx/man/saveWorkbook.html)

- overwrite:

  optional logical, passed to
  [`openxlsx::saveWorkbook()`](https://rdrr.io/pkg/openxlsx/man/saveWorkbook.html)

- launchexcel:

  optional logical, passed to
  [`table_xls_format()`](https://ejanalysis.github.io/EJAM/reference/table_xls_format.md),
  whether to launch browser to see spreadsheet immediately

- interactive_console:

  optional - should set to FALSE when used in code or server. If TRUE,
  prompts RStudio user interactively asking where to save the downloaded
  file

- ok2plot:

  optional logical, passed to
  [`table_xls_format()`](https://ejanalysis.github.io/EJAM/reference/table_xls_format.md),
  whether safe to try and plot or set FALSE if debugging plot problems

- in.testing:

  optional logical

- in.analysis_title:

  optional title as character string

- react.v1_summary_plot:

  optional - a plot object

- radius_or_buffer_in_miles:

  optional radius in miles

- buffer_desc:

  description of location to use in labels, like "Selected Locations"

- radius_or_buffer_description:

  optional text phrase describing places analyzed

- reports:

  info about which columns to treat as URLs that should be hyperlinks -
  see
  [`url_columns_bysite()`](https://ejanalysis.github.io/EJAM/reference/url_columns_bysite.md)

- site_method:

  site selection method, such as SHP, latlon, FIPS, NAICS, FRS,
  EPA_PROGRAM, SIC, MACT optional site method parameter used to create a
  more specific title with create_filename. Note `ejamitout$sitetype` is
  not quite the same as the `site_method` parameter used in building
  reports. sitetype can be latlon, fips, or shp site_method can be one
  of these: SHP, latlon, FIPS, NAICS, FRS, EPA_PROGRAM, SIC, MACT

- mapadd:

  Logical, whether to add a tab with a map of the sites. If report tab
  is added, though, standalone static map in excel tab is redundant.

- report_map:

  the map to use if mapadd = TRUE (re-created if this is omitted/NULL
  but mapadd is TRUE)

- community_reportadd:

  Logical, whether to add a tab with a static copy of the summary report
  (tables, map, barplot).

- community_html:

  the HTML of the summary/community report if available (re-created if
  this is omitted/NULL but community_reportadd is TRUE)

- shp:

  shapefile to create map if not providing it via report_map or
  community_html parameters

- ...:

  optional additional parameters passed to
  [`table_xls_format()`](https://ejanalysis.github.io/EJAM/reference/table_xls_format.md),
  such as heatmap_colnames, heatmap_cuts, heatmap_colors, etc.

## Value

returns a workbook object for use by openxlsx::saveWorkbook(wb_out,
pathname) or returns just the full path/file name of where it was saved
if save_now = TRUE

## Examples

``` r
# \donttest{
  EJAM:::table_xls_from_ejam(testoutput_ejamit_10pts_1miles, fname = tempfile(fileext = ".xlsx"))
  # }
```
