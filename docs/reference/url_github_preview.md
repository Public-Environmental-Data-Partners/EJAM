# utility to view rendered .html file stored in a github repo

utility to view rendered .html file stored in a github repo

## Usage

``` r
url_github_preview(
  ghurl = NULL,
  repo = "https://github.com/ejanalysis/EJAM",
  blob = "blob",
  ver = "main",
  fold = "inst/testdata/examples_of_output",
  file = "testoutput_ejam2report_10pts_1miles.html",
  launch_browser = TRUE
)
```

## Arguments

- ghurl:

  URL of HTML file in a github repository

- repo:

  e.g., "https://github.com/ejanalysis/EJAM"

- blob:

  should leave as default "blob"

- ver:

  e.g., "main" or "v2.4.0"

- fold:

  folder, e.g., "docs/reference"

- file:

  filename including .html extension

- launch_browser:

  set FALSE to get URL but not launch a browser

## Value

URL

## Examples
