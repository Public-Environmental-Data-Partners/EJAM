# Format the results of ejamit() for excel and optionally save .xlsx file

Almost identical to
[`ejam2excel()`](https://public-environmental-data-partners.github.io/EJAM/reference/ejam2excel.md)

## Usage

``` r
table_xls_from_ejam(
  ejamitout,
  fname = NULL,
  save_now = TRUE,
  overwrite = TRUE,
  launchexcel = FALSE,
  interactive_console = TRUE,
  in.testing = FALSE,
  updateProgress = NULL,
  analysis_title = "EJAM analysis",
  site_method = "",
  radius_or_buffer_in_miles = NULL,
  radius_or_buffer_description = NULL,
  buffer_desc = "Selected Locations",
  reports = EJAM:::global_or_param("default_reports"),
  ok2plot = TRUE,
  report_plot = NULL,
  plot_distance_by_group = FALSE,
  plotlatest = FALSE,
  plotfilename = NULL,
  mapadd = FALSE,
  report_map = NULL,
  shp = NULL,
  community_reportadd = TRUE,
  community_html = NULL,
  heatmap_colnames = NULL,
  heatmap_cuts = c(80, 90, 95),
  heatmap_colors = c("yellow", "orange", "red"),
  heatmap2_colnames = NULL,
  heatmap2_cuts = c(1.009, 2, 3),
  heatmap2_colors = c("yellow", "orange", "red"),
  graycolnames = NULL,
  graycolor = "gray",
  narrowcolnames = NULL,
  narrow6 = 6,
  notes = NULL,
  custom_tab = NULL,
  custom_tab_name = "other",
  ejscreen_ejam_caveat = NULL,
  ...
)
```

## Arguments

- ejamitout:

  output of
  [`ejamit()`](https://public-environmental-data-partners.github.io/EJAM/reference/ejamit.md)

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
  [`table_xls_format()`](https://public-environmental-data-partners.github.io/EJAM/reference/table_xls_format.md),
  whether to launch browser to see spreadsheet immediately

- interactive_console:

  optional - should set to FALSE when used in code or server. If TRUE,
  prompts RStudio user interactively asking where to save the downloaded
  file

- in.testing:

  optional logical

- updateProgress:

  optional function used by shiny app to track progress of slow
  operation

- analysis_title:

  optional title as character string, used only in 'Notes' sheet (and to
  create a default filename if fname not specified). Not used in the
  copy of the report.

- site_method:

  optional word or phrase about the sites or how they were selected.

  The `site_method` parameter can be used as-is by
  [`create_filename()`](https://public-environmental-data-partners.github.io/EJAM/reference/create_filename.md)
  to be part of the saved file name. It can also be used by the shiny
  app to add informational text in the header of a report, via
  [`ejam2report()`](https://public-environmental-data-partners.github.io/EJAM/reference/ejam2report.md)
  and related helper functions like
  [`report_residents_within_xyz()`](https://public-environmental-data-partners.github.io/EJAM/reference/report_residents_within_xyz.md)
  or via
  [`ejam2excel()`](https://public-environmental-data-partners.github.io/EJAM/reference/ejam2excel.md)
  and related helper functions.

  The `site_method` parameter provides more detailed info about how
  sites were specified in the web app, beyond what `sitetype` provides
  (e.g., from `ejamit()$sitetype` or `ejamitout$sitetype`):

  - sitetype can be "latlon", "fips", or "shp"

  - site_method can be one of these: "latlon", "SHP", "FIPS",
    "FIPS_PLACE", "FRS", "NAICS", "SIC", "EPA_PROGRAM", "MACT"

  The shiny app server provides `site_method` from the reactive called
  submitted_upload_method() which is much like the one called
  current_upload_method().

- radius_or_buffer_in_miles:

  optional radius in miles

- radius_or_buffer_description:

  optional text phrase describing places analyzed, like in report
  headers

- buffer_desc:

  description of location to use in labels, like "Selected Locations"

- reports:

  info about which columns to treat as URLs that should be hyperlinks -
  see
  [`url_columns_bysite()`](https://public-environmental-data-partners.github.io/EJAM/reference/url_columns_bysite.md)

- ok2plot:

  optional logical, passed to
  [`table_xls_format()`](https://public-environmental-data-partners.github.io/EJAM/reference/table_xls_format.md),
  whether safe to try and plot or set FALSE if debugging plot problems

- report_plot:

  optional - a plot object

- plot_distance_by_group:

  optional logical, whether to try to add a plot of mean distance by
  group. This requires that bybg be provided as a parameter input to
  this function.

- plotlatest:

  optional logical. If TRUE, the most recently displayed plot (prior to
  this function being called) will be inserted into a tab called plot2

- plotfilename:

  optional the full path including name of a .png file to insert

- mapadd:

  optional logical, whether to add a tab with a map of the sites. If
  report tab is added, though, standalone static map in excel tab is
  redundant.

- report_map:

  the leaflet map to display in 'Map' sheet if mapadd is TRUE
  (re-created if this is omitted/NULL but mapadd is TRUE)

- shp:

  optional shapefile used to create map if not providing it via
  report_map or community_html parameters

- community_reportadd:

  Logical, whether to add a tab with a static copy of the summary report
  (tables, map, barplot).

- community_html:

  the HTML file of the summary/community report if available (re-created
  if this is omitted/NULL but community_reportadd is TRUE)

- heatmap_colnames:

  optional vector of colnames to apply heatmap colors, defaults to
  percentiles

- heatmap_cuts:

  vector of values to separate heatmap colors, between 0-100 for
  percentiles

- heatmap_colors:

  vector of color names for heatmap bins, same length as heatmap_cuts,
  where first color is for those \>= 1st cutpoint, but \<2d, second
  color is for those \>=2d cutpoint but \<3d, etc.

- heatmap2_colnames:

  like heatmap_colnames but for ratios by default

- heatmap2_cuts:

  like heatmap_cuts but for ratios by default

- heatmap2_colors:

  like heatmap_colors but for ratios

- graycolnames:

  which columns to de-emphasize

- graycolor:

  color used to de-emphasize some columns

- narrowcolnames:

  which column numbers to make narrow

- narrow6:

  how narrow

- notes:

  Text of additional notes to put in the notes tab, optional vector of
  character elements pasted in as one line each.

- custom_tab:

  optional table to put in an extra tab

- custom_tab_name:

  optional name of optional custom_tab

- ejscreen_ejam_caveat:

  optional text if you want to change this in the notes tab

- ...:

  optional additional parameters passed to
  [`table_xls_format()`](https://public-environmental-data-partners.github.io/EJAM/reference/table_xls_format.md),
  currently unused

## Value

returns a workbook object for use by openxlsx::saveWorkbook(wb_out,
pathname) or returns just the full path/file name of where it was saved
if save_now = TRUE

## Examples

``` r
if (FALSE) { # \dontrun{
  EJAM:::table_xls_from_ejam(testoutput_ejamit_10pts_1miles, fname = tempfile(fileext = ".xlsx"))
  } # }
```
