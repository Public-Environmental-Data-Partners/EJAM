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

- launch_browser:

  set FALSE to get URL but not launch a browser

## Value

URL

## Examples

``` r
url_github_preview(fold = "docs", file = "index.html", launch_browser = F)
url_github_preview(fold = "docs/reference", file = "ejam2excel.html", launch_browser = F)

#   Compare versions of the HTML summary report:

myfile = "testoutput_ejam2report_100pts_1miles.html"
if (FALSE) { # \dontrun{
# in latest main branch on GH (but map does not render using this tool)
url_github_preview(file = myfile)

# from a specific release on GH (but map does not render using this tool)
url_github_preview(ver = "v2.32.5", fold = "inst/testdata/examples_of_output", file = myfile)

# local installed version
browseURL( system.file(file.path("testdata/examples_of_output", myfile), package="EJAM") )

# local source package version in checked out branch
browseURL( file.path(testdatafolder(installed = F), "examples_of_output", myfile) )
} # }
```
