# utility to show dir_tree of available files in testdata folders See list of samples of input files to try in EJAM, and output examples from EJAM functions

utility to show dir_tree of available files in testdata folders See list
of samples of input files to try in EJAM, and output examples from EJAM
functions

## Usage

``` r
testdata(pattern = NULL, installed = TRUE, quiet = FALSE, folder_only = FALSE)
```

## Arguments

- pattern:

  optional query regular expression, used as filter using when getting
  filenames

- installed:

  If you are a developer who has the local source package, you can set
  this parameter to FALSE if you want to work with the local source
  package version of the testdata folders rather than the locally
  installed version.

- quiet:

  set TRUE if you want to just get the path without seeing all the info
  in console and without browsing to the folder

- folder_only:

  set TRUE to get only directories, no files

## Value

path to local testdata folder comes with the EJAM package

## See also

[`pkg_functions_and_data()`](https://public-environmental-data-partners.github.io/EJAM/reference/pkg_functions_and_data.md)

## Examples

``` r
testdata('shape', quiet = TRUE)
testdata('shape', quiet = T, folder_only=T)

testdata("id", quiet = T)
testdata("id", quiet = T, folder_only=T)

testdata('fips', quiet = T)
testdata('registryid', quiet = T)
testdata("address", quiet = T)

# datasets as lazyloaded objects vs. files installed with package

topic = "fips"  # or "shape" or "latlon" or "naics" or "address" etc.

# datasets / R objects
cbind(data.in.package  = sort(grep(topic, EJAM:::pkg_data()$Item, value = T)))

# files
cbind(files.in.package = sort(basename(testdata(topic, quiet = T))))
```
