# helper - make date/version footer for summary report

helper - make date/version footer for summary report

## Usage

``` r
generate_report_footer(
  footer_version_number = NULL,
  footer_date = NULL,
  footer_text = NULL,
  footer_html = NULL
)
```

## Arguments

- footer_version_number:

  optional, default is read from the package, in format like "2.x.x"

- footer_date:

  optional, default is today's date. Should be in format like "April 1,
  2026". If footer_date not specified, it is based on date right now in
  local user timezone, based on wherever the server happens to be

- footer_text:

  optional, e.g., "Report created by EJAM version (version_number) on
  (date_created)". If specified, it overrides date and version
  parameters.

- footer_html:

  optional full HTML for footer. If specified, it overrides all other
  parameters.

  For example,

      footer_html = shiny::HTML(paste0('
        <div style="background-color: #edeff0; color: black; width: 100%; padding: 10px 20px; text-align: right; margin: 10px 0;">
          <p style="margin-bottom: 0;">', 'Report created by EJAM version 2.X.X on April 1, 2026', '</p>
        </div>
      '))

## Details

used by app_server.R and .Rmd report templates. Passing a parameter as
NULL is the same as omitting it/not specifying it. To make footer blank
(no text), pass "" for footer_text or footer_html.
