# utility to view rendered .html file stored in a github repo

utility to view rendered .html file stored in a github repo

## Usage

``` r
url_github_preview(
  ghurl = NULL,
  repo = EJAM::url_package("code", get_full_url = TRUE),
  ver = "main",
  fold = "inst/testdata/examples_of_output",
  file = "testoutput_ejam2report_10pts_1miles.html",
  launch_browser = TRUE
)
```

## Arguments

- ghurl:

  URL of HTML file in a github repository, inferred by default from
  parameters repo, ver, fold, and file

- repo:

  URL of github repository

- ver:

  name of branch or tag of a released version

- fold:

  x

- file:

  x

- launch_browser:

  set FALSE to get URL but not launch a browser

## Value

URL

## Examples

``` r
url_github_preview(fold = "docs",
  launch_browser = F, file = "index.html")
url_github_preview(fold = "docs/reference",
  launch_browser = F, file = "ejam2excel.html")

if (FALSE) { # \dontrun{
#   Compare versions of the HTML summary report:

myfile = "testoutput_ejam2report_100pts_1miles.html"

# in latest main branch on GH (but map does not render using this tool)
url_github_preview(file = myfile)

# from a specific prior release on GH (but map does not render using this tool)
url_github_preview(file = myfile,
  ver = "v2.32.5", fold = "inst/testdata/examples_of_output")

# local installed version
browseURL(testdata(myfile, quiet = T))
browseURL( system.file(file.path("testdata/examples_of_output", myfile), package="EJAM") )

# local source package version in checked out branch
browseURL(testdata(myfile, quiet = T, installed = F))
browseURL( file.path(testdatafolder(installed = F), "examples_of_output", myfile) )
} # }
```
