# helper function in updating the package metadata, used by scripts in /data-raw/

Quick and dirty helper during development, to check all the attributes
of all the data files in relevant packages. It loads unloaded packages
as needed, which you might not want it to do, but it is not coded to be
able to check attributes without doing that.

## Usage

``` r
metadata_check(
  packages = EJAM::ejampackages,
  datasets = "all",
  which = c("ejam_package_version", "date_saved_in_package", "date_downloaded",
    "ejscreen_version", "ejscreen_releasedate", "acs_releasedate", "acs_version",
    "census_version"),
  grepdatasets = FALSE,
  loadifnotloaded = TRUE
)
```

## Arguments

- packages:

  Optional. e.g. 'EJAMejscreendata', or can be a vector of character
  strings, and if not specified, default is to report on
  EJAM::ejampackages. If set to NULL, it only reports on objects already
  attached.

- datasets:

  optional, "all" means all data objects exported. Can be a vector of
  character names of the ones to check like c("bgpts", "blockpoints")

- which:

  Optional vector (not list) of strings, the attributes. Default is some
  typical ones used in EJAM-related packages currently.

- grepdatasets:

  optional, if set to TRUE, datasets should be a query to use via grep
  to identify which datasets to check. It always uses ignore.case=TRUE
  for this.

- loadifnotloaded:

  Optional to control if func should temporarily attach packages not
  already loaded.

## See also

[`metadata_check_print()`](https://ejanalysis.github.io/EJAM/reference/metadata_check_print.md)
`metadata_check()`
[`metadata_add()`](https://ejanalysis.github.io/EJAM/reference/metadata_add.md)
[`metadata_update_attr()`](https://ejanalysis.github.io/EJAM/reference/metadata_update_attr.md)
[`metadata_add_and_use_this()`](https://ejanalysis.github.io/EJAM/reference/metadata_add_and_use_this.md)
[`dataset_documenter()`](https://ejanalysis.github.io/EJAM/reference/dataset_documenter.md)
[`pkg_functions_and_data()`](https://ejanalysis.github.io/EJAM/reference/pkg_functions_and_data.md)

## Examples

``` r
x = EJAM:::metadata_check( which = "ejam_package_version")
x[!x$ejam_package_version %in% "2.32.7", ]

  # tail(EJAM:::metadata_check( ))
  EJAM:::metadata_check(packages = NULL)

  x <- EJAM:::metadata_check_print("EJAM")
  x[x$has_metadata == TRUE, ]
  table(x$has_metadata)
```
