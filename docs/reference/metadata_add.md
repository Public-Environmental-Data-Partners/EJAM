# helper function for package to set metadata attributes of a dataset, used by scripts in /data-raw/

Together with the metadata_mapping script, this can be used annually to
update the metadata for datasets in a package. It just makes it easier
to set a few metadata attributes similarly for a number of data
elements, for example, to add new or update existing attributes.

## Usage

``` r
metadata_add(
  x,
  metadata = NULL,
  update_date_saved_in_package = TRUE,
  update_ejam_package_version = TRUE
)
```

## Arguments

- x:

  dataset (or any object) whose metadata (stored as attributes) you want
  to update or create EJAM, EJSCREEN, and other dataset versions and
  release dates are tracked in DESCRIPTION

- metadata:

  optional - when omitted, it checks metadata_mapping using
  get_metadata_mapping(). Can provide a list of key=value attributes to
  add

- update_date_saved_in_package:

  can set to FALSE to avoid changing this attribute

- update_ejam_package_version:

  can set to FALSE to avoid changing this attribute

## Value

returns x but with new or altered attributes

## Details

to update only the ejam_package_version attribute of every data item:

[`metadata_update_attr()`](https://public-environmental-data-partners.github.io/EJAM/reference/metadata_update_attr.md)

This utility would be used in scripts in EJAM/data-raw/ to add metadata
to objects like x before use_data(x, overwrite=T)

Note that by adding attributes, this function changes a vector so that
is.vector() will no longer be true!

## See also

[`metadata_check_print()`](https://public-environmental-data-partners.github.io/EJAM/reference/metadata_check_print.md)
[`metadata_check()`](https://public-environmental-data-partners.github.io/EJAM/reference/metadata_check.md)
`metadata_add()`
[`metadata_update_attr()`](https://public-environmental-data-partners.github.io/EJAM/reference/metadata_update_attr.md)
[`metadata_add_and_use_this()`](https://public-environmental-data-partners.github.io/EJAM/reference/metadata_add_and_use_this.md)
[`dataset_documenter()`](https://public-environmental-data-partners.github.io/EJAM/reference/dataset_documenter.md)

## Examples

``` r
  # EJAM:::metadata_check() # internal function
  x <- data.frame(a=1:10,b=1001:1010)
  # x <- EJAM:::metadata_add(x) # internal function
  attributes(x)
```
