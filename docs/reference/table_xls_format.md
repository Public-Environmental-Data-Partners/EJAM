# Format EJAM tabular outputs for saving as Excel spreadsheet

Used by table_xls_from_ejam(), and see ejam2excel()

## Usage

``` r
table_xls_format(
  overall,
  eachsite,
  longnames = NULL,
  formatted = NULL,
  bybg = NULL,
  sitetype = NULL,
  plot_distance_by_group = FALSE,
  summary_plot = NULL,
  plotlatest = FALSE,
  plotfilename = NULL,
  ok2plot = TRUE,
  mapadd = FALSE,
  report_map = NULL,
  community_reportadd = FALSE,
  community_html = NULL,
  analysis_title = "EJAM analysis",
  radius_or_buffer_in_miles = NULL,
  radius_or_buffer_description =
    "Miles radius of circular buffer (or distance used if buffering around polygons)",
  buffer_desc = "Selected Locations",
  notes = NULL,
  custom_tab = NULL,
  custom_tab_name = "other",
  heatmap_colnames = NULL,
  heatmap_cuts = c(80, 90, 95),
  heatmap_colors = c("yellow", "orange", "red"),
  heatmap2_colnames = NULL,
  heatmap2_cuts = c(1.009, 2, 3),
  heatmap2_colors = c("yellow", "orange", "red"),
  reports = EJAM:::global_or_param("default_reports"),
  graycolnames = NULL,
  narrowcolnames = NULL,
  graycolor = "gray",
  narrow6 = 6,
  testing = FALSE,
  updateProgress = NULL,
  launchexcel = FALSE,
  saveas = NULL,
  ejscreen_ejam_caveat = NULL,
  ...
)
```

## Arguments

- overall:

  table to save in one tab, from ejamit()\$results_overall, EJAM
  analysis of indicators overall (one row), but if entire output of
  ejamit() is passed as if it were overall, function figures out
  eachsite, etc.

- eachsite:

  table to save in one tab, from ejamit()\$results_bysite, EJAM analysis
  site by site (one row per site)

- longnames:

  vector of indicator names to display in Excel table

- formatted:

  optional table to save in one tab, from ejamit()\$results_overall,
  EJAM analysis overall in different format

- bybg:

  Optional large table of details of each blockgroup that is only needed
  to analyze distances by group.

- sitetype:

  normally would be like ejamit()\$sitetype

- plot_distance_by_group:

  logical, whether to try to add a plot of mean distance by group. This
  requires that bybg be provided as a parameter input to this function.

- summary_plot:

  optional plot object passed from EJAM shiny app to save in 'Plot'
  sheet of Excel table

- plotlatest:

  optional logical. If TRUE, the most recently displayed plot (prior to
  this function being called) will be inserted into a tab called plot2

- plotfilename:

  the full path including name of .png file to insert

- ok2plot:

  can set to FALSE to prevent plots from being attempted, while
  debugging

- mapadd:

  logical optional - try to include a map of the points

- report_map:

  leaflet map object passed from Shiny app to display in 'Map' sheet

- community_reportadd:

  logical provided by shiny app to specify whether to include community
  report image

- community_html:

  HTML file of community report provided by shiny app to include in
  spreadsheet

- analysis_title:

  optional title passed from Shiny app to 'Notes' sheet

- radius_or_buffer_in_miles:

  If provided, miles buffer distance (from polygon or from point if
  circular buffers)

- radius_or_buffer_description:

  optional text saying if distance is radius or polygon buffer, passed
  to 'Notes' sheet

- buffer_desc:

  optional description of buffer used in analysis, passed to 'Notes'
  sheet

- notes:

  Text of additional notes to put in the notes tab, optional vector of
  character elements pasted in as one line each.

- custom_tab:

  optional table to put in an extra tab

- custom_tab_name:

  optional name of optional custom_tab

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

- reports:

  info about which columns to treat as URLs that should be hyperlinks -
  see
  [url_columns_bysite](https://ejanalysis.github.io/EJAM/reference/url_columns_bysite.md)

- graycolnames:

  which columns to de-emphasize

- narrowcolnames:

  which column numbers to make narrow

- graycolor:

  color used to de-emphasize some columns

- narrow6:

  how narrow

- testing:

  optional for testing only

- updateProgress:

  optional Shiny progress bar to update during formatting

- launchexcel:

  Set to TRUE to have this function launch Excel immediately, showing
  the final workbook created here.

- saveas:

  If not NULL, and a valid path with filename.xlsx is provided, the
  workbook will be saved locally at that path and name. Warning: it will
  overwrite an existing file.

- ejscreen_ejam_caveat:

  optional text if you want to change this in the notes tab

- ...:

  other params passed along to
  [`openxlsx::writeData()`](https://rdrr.io/pkg/openxlsx/man/writeData.html)

## Value

a workbook, ready to be saved in spreadsheet format, with tabs like
"Overall" and "Each Site"

## See also

[`ejam2excel()`](https://ejanalysis.github.io/EJAM/reference/ejam2excel.md)
and related functions like
[`table_xls_from_ejam()`](https://ejanalysis.github.io/EJAM/reference/table_xls_from_ejam.md)

## Examples

``` r
# \donttest{
  EJAM:::table_xls_format(
    testoutput_ejamit_100pts_1miles$results_overall,
    testoutput_ejamit_100pts_1miles$results_bysite,
    saveas =  "out1.xlsx")
 # can just pass the whole results of ejamit(), for convenience
 wb <- EJAM:::table_xls_format(testoutput_ejamit_100pts_1miles)
 openxlsx::saveWorkbook(wb, file = "out2.xlsx", overwrite = T)
# }
```
