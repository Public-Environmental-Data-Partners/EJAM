# helper function in updating the package metadata, used by scripts in /data-raw/ prints to console info about some missing metadata

helper function in updating the package metadata, used by scripts in
/data-raw/ prints to console info about some missing metadata

## Usage

``` r
metadata_check_print(...)
```

## Value

same as
[`metadata_check()`](https://ejanalysis.github.io/EJAM/reference/metadata_check.md),
invisibly

## See also

`metadata_check_print()`
[`metadata_check()`](https://ejanalysis.github.io/EJAM/reference/metadata_check.md)
[`metadata_add()`](https://ejanalysis.github.io/EJAM/reference/metadata_add.md)
[`metadata_update_attr()`](https://ejanalysis.github.io/EJAM/reference/metadata_update_attr.md)
[`metadata_add_and_use_this()`](https://ejanalysis.github.io/EJAM/reference/metadata_add_and_use_this.md)
[`dataset_documenter()`](https://ejanalysis.github.io/EJAM/reference/dataset_documenter.md)

## Examples

``` r
# x = EJAM:::metadata_check( which = "ejam_package_version")
# x[!x$ejam_package_version %in% "2.32.6", ]
```
