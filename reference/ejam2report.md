# View HTML Report on EJAM Results (Overall or at 1 Site)

Get URL for and view in browser a summary report (similar to used to be
called the EJSCREEN Community Report)

## Usage

``` r
ejam2report(
  ejamitout = testoutput_ejamit_10pts_1miles,
  sitenumber = NULL,
  analysis_title = NULL,
  submitted_upload_method = c("latlon", "SHP", "FIPS")[1],
  shp = NULL,
  return_html = FALSE,
  fileextension = c("html", "pdf")[1],
  filename = NULL,
  launch_browser = TRUE,
  show_ratios_in_report = TRUE,
  extratable_show_ratios_in_report = TRUE,
  extratable_title = "",
  extratable_title_top_row = "ADDITIONAL INFORMATION",
  extratable_list_of_sections = list(`Breakdown by Population Group` = names_d_subgroups,
    `Language Spoken at Home` = names_d_language,
    `Language in Limited English Speaking Households` = names_d_languageli,
    `Breakdown by Sex` = c("pctmale", "pctfemale"), Health = names_health, Age =
    c("pctunder5", "pctunder18", "pctover64"), Community =
    names_community[!(names_community %in% c("pctmale", "pctfemale",
    "pctownedunits_dupe"))], Poverty = names_d_extra, `Features and Location Information`
    = c(names_e_other, names_sitesinarea, names_featuresinarea, 
     names_flag),
    Climate = names_climate, `Critical Services` = names_criticalservice, Other =
    names_d_other_count),
  extratable_hide_missing_rows_for = as.vector(unlist(extratable_list_of_sections)),
  report_title = NULL,
  logo_path = EJAM:::global_or_param("report_logo"),
  logo_html = NULL,
  footer_version_number = NULL,
  footer_date = NULL,
  footer_text = NULL,
  footer_html = NULL,
  addlatlon = TRUE
)
```

## Arguments

- ejamitout:

  output as from
  [`ejamit()`](https://ejanalysis.github.io/EJAM/reference/ejamit.md),
  list with a table in [data.table](https://r-datatable.com) format
  called `results_bysite` if sitenumber parameter is used, or a table in
  [data.table](https://r-datatable.com) format called `results_overall`
  otherwise

- sitenumber:

  If a number is provided, the report is about
  `ejamitout$results_bysite[sitenumber, ]` and if no number is provided
  (param is NULL or "") then the report is about
  `ejamitout$results_overall`

- analysis_title:

  optional title of analysis

- submitted_upload_method:

  something like "latlon", "SHP", "FIPS", etc. (just used as-is as part
  of the filename)

- shp:

  provide the sf spatial data.frame of polygons that were analyzed so
  you can map them since they are not in ejamitout

- return_html:

  set TRUE to have function return HTML object instead of URL of local
  file

- fileextension:

  html or .html or pdf or .pdf (assuming pdf option has been
  implemented). Creating PDF output from R Markdown requires that LaTeX
  be installed.

- filename:

  optional path and name for report file, used by web app

- launch_browser:

  set TRUE to have it launch browser and show report.

- show_ratios_in_report:

  logical, whether to add columns with ratios to US and State overall
  values, in main table of envt/demog. info.

- extratable_show_ratios_in_report:

  logical, whether to add columns with ratios to US and State overall
  values, in extra table

- extratable_title:

  Text of overall title ABOVE the extra table

- extratable_title_top_row:

  Text INSIDE top left cell of extra table

- extratable_list_of_sections:

  This defines what extra indicators are shown. It is a named list of
  vectors, where each name is text phrase that is title of a section of
  the table, and each vector is the vector of colnames of output_df that
  are indicators to show in that section, in extra table of demog.
  subgroups, etc.

- extratable_hide_missing_rows_for:

  only for the indicators named in this vector, leave out rows in table
  where raw value is NA, as with many of names_d_language, in extra
  table of demog. subgroups, etc.

- report_title:

  optional generic name of this type of report, to be shown at top, like
  "EJAM Multisite Report"

- logo_path:

  optional relative path to a logo for the upper right of the overall
  header. Ignored if logo_html is specified and not NULL, but otherwise
  uses default or param set in
  [`ejamapp()`](https://ejanalysis.github.io/EJAM/reference/ejamapp.md)

- logo_html:

  optional HTML for img of logo for the upper right of the overall
  header. If specified, it overrides logo_path. If omitted, gets created
  based on logo_path.

- footer_version_number, footer_date, footer_text, footer_html:

  to customize the report footer - see
  [`generate_report_footer()`](https://ejanalysis.github.io/EJAM/reference/generate_report_footer.md)

- addlatlon:

  optional, whether to include lat,lon coordinates in header (for latlon
  sitetype)

## Value

URL of temp file or object depending on return_html, and has side effect
of launching browser to view it depending on return_html

## Details

This relies on
[`build_community_report()`](https://ejanalysis.github.io/EJAM/reference/build_community_report.md)
as used in web app for viewing report on 1 site from a list of sites (or
overall). You can customize the report somewhat by using parameters like
extratable_list_of_sections

## Examples

``` r
#out <- ejamit(testpoints_10, radius = 3, include_ejindexes = T)
out <- testoutput_ejamit_10pts_1miles

ejam2report(out)
ejam2table_tall(out$results_overall)
if (interactive()) {
 x <- ejam2report(out, sitenumber = 1, launch_browser = T)
 table_gt_from_ejamit_overall(out$results_overall)
 table_gt_from_ejamit_1site(out$results_bysite[1, ])
}
```
