# Generate Single-site or Multi-site Summary Report (e.g., .html)

Creates a short summary report with tables, map, and plot of indicators

## Usage

``` r
build_community_report(
  output_df,
  analysis_title = "Report",
  totalpop,
  locationstr,
  include_ejindexes = FALSE,
  show_ratios_in_report = FALSE,
  extratable_show_ratios_in_report = FALSE,
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
  in_shiny = FALSE,
  filename = NULL,
  report_title = NULL,
  logo_path = NULL,
  logo_html = NULL
)
```

## Arguments

- output_df:

  single row of results table from doaggregate - either results_overall
  or one row of bysite

- analysis_title:

  title to use in header of report

- totalpop:

  total population included in location(s) analyzed

- locationstr:

  description of the location(s) analyzed

- include_ejindexes:

  whether to build tables for summary indexes and supp. summary indexes

- show_ratios_in_report:

  logical, whether to add columns with ratios to US and State overall
  values, in main table of envt/demog. info.

- extratable_show_ratios_in_report:

  logical, whether to add columns with ratios to US and State overall
  values, in an extra info table

- extratable_title:

  Text of overall title ABOVE the extra info table

- extratable_title_top_row:

  Text INSIDE the extra info table, top left cell

- extratable_list_of_sections:

  This defines what extra indicators are shown. It is a named list of
  vectors, where each name is text phrase that is title of a section of
  the table, and each vector is the vector of colnames of output_df that
  are indicators to show in that section, in extra table of demog.
  subgroups, etc.

- extratable_hide_missing_rows_for:

  only for the indicators named in this vector, leave out rows in table
  where raw value is NA, as with many of names_d_language, in extra
  table of demog. subgroups, etc.'

- in_shiny:

  whether the function is being called in or outside of shiny - affects
  location of header

- filename:

  path to file to save HTML content to; if null, returns as string (used
  in Shiny app)

- report_title:

  generic name of this type of report, to be shown at top, like "EJAM
  Multisite Report"

- logo_path:

  optional relative path to a logo for the upper right of the overall
  header. Ignored if logo_html is specified and not NULL, otherwise uses
  default or param set in
  [`ejamapp()`](https://ejanalysis.github.io/EJAM/reference/ejamapp.md),
  except NULL means default logo, "" means omit logo entirely.

- logo_html:

  optional HTML for img of logo for the upper right of the overall
  header. If specified, it overrides logo_path. If omitted, gets created
  based on logo_path.

## Details

This is used by the shiny app server. For use in RStudio, see
[`ejam2report()`](https://ejanalysis.github.io/EJAM/reference/ejam2report.md)
(which relies on this).

This function gets called by app_server but also by
[`ejam2report()`](https://ejanalysis.github.io/EJAM/reference/ejam2report.md),
and also is used by the community_report_template.Rmd used to generate a
report

It uses functions in community_report_helper_funs.R, etc.

## See also

[`ejam2report()`](https://ejanalysis.github.io/EJAM/reference/ejam2report.md)
