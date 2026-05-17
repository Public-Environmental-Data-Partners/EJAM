# utility to show path to testdata folders see folder that has samples of input files to try in EJAM, and output examples from EJAM functions

utility to show path to testdata folders see folder that has samples of
input files to try in EJAM, and output examples from EJAM functions

## Usage

``` r
testdatafolder(pattern = NULL, installed = TRUE, quiet = FALSE)
```

## Arguments

- pattern:

  optional query regular expression, used as filter using when getting
  dirnames. If NULL, returns only root testdata folder, otherwise
  matching subfolder(s)

- installed:

  If you are a developer who has the local source package, you can set
  this parameter to FALSE if you want to work with the local source
  package version of the testdata folders rather than the locally
  installed version.

- quiet:

  whether to print info, but always TRUE if pattern is provided

## Value

path(s) to local testdata folder(s) from the EJAM package

## Examples

``` r
x = testdatafolder("shape" )
x
x["testdata" == basename(dirname(x))]

#   Compare versions of the HTML summary report:

fname = "examples_of_output/testoutput_ejam2report_10pts_1miles.html"
repo = url_package("code", get_full_url = TRUE)
if (FALSE) { # \dontrun{
# in latest main branch on GH (but map does not render using this tool)
url_github_preview(file.path(repo, "blob/main/inst/testdata", fname))

# local installed version
browseURL( system.file(file.path("testdata", fname), package="EJAM") )

# local source package version in checked out branch
browseURL( file.path(testdatafolder(installed = FALSE), fname) )
} # }
```
