# update ALL metadata attributes for JUST 1 pkg dataset AND save in EJAM/data/

update ALL metadata attributes for JUST 1 pkg dataset AND save in
EJAM/data/

## Usage

``` r
metadata_add_and_use_this(
  objectname,
  metadata = NULL,
  update_date_saved_in_package = TRUE,
  update_ejam_package_version = TRUE
)
```

## Arguments

- objectname:

  text/character string of object name (ie quoted), not the unquoted
  object itself

- metadata:

  passed to
  [`metadata_add()`](https://ejanalysis.github.io/EJAM/reference/metadata_add.md).
  optional - when omitted, it checks metadata_mapping using
  get_metadata_mapping(). Can provide a list of key=value attributes to
  add

- update_date_saved_in_package:

  passed to
  [`metadata_add()`](https://ejanalysis.github.io/EJAM/reference/metadata_add.md).
  can set to FALSE to avoid changing this attribute

- update_ejam_package_version:

  passed to
  [`metadata_add()`](https://ejanalysis.github.io/EJAM/reference/metadata_add.md).
  can set to FALSE to avoid changing this attribute

## Value

just for side effects (unlike
[`metadata_add()`](https://ejanalysis.github.io/EJAM/reference/metadata_add.md)
which returns the updated object)

## Details

used in data-raw/datacreate\_\*.R functions while updating/making
datasets

## See also

[`metadata_check_print()`](https://ejanalysis.github.io/EJAM/reference/metadata_check_print.md)
[`metadata_check()`](https://ejanalysis.github.io/EJAM/reference/metadata_check.md)
[`metadata_add()`](https://ejanalysis.github.io/EJAM/reference/metadata_add.md)
[`metadata_update_attr()`](https://ejanalysis.github.io/EJAM/reference/metadata_update_attr.md)
`metadata_add_and_use_this()`
[`dataset_documenter()`](https://ejanalysis.github.io/EJAM/reference/dataset_documenter.md)
