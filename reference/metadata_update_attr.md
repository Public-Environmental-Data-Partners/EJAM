# helper func to update 1 metadata attribute (e.g. "ejam_package_version") in all pkg datasets updates EJAM/data/\*.rda (BUT NOT ARROW & NOT TXT FILES)

helper func to update 1 metadata attribute (e.g. "ejam_package_version")
in all pkg datasets updates EJAM/data/\*.rda (BUT NOT ARROW & NOT TXT
FILES)

## Usage

``` r
metadata_update_attr(
  x,
  attr_name = "ejam_package_version",
  newvalue = desc::desc_get("Version"),
  exclude_atomic_vectors = TRUE,
  only_update_if_had_been_set = FALSE
)
```

## Arguments

- x:

  if missing, defaults to all items found in EJAM pkg; otherwise, a
  vector of 1+ quoted names of data object(s), like "testpoints_10"

- attr_name:

  e.g. "ejam_package_version"

- newvalue:

  the new value of that attribute

- exclude_atomic_vectors:

  if TRUE, avoids updating attributes on atomic vectors like names_e,
  since it is distracting when printing them to console

- only_update_if_had_been_set:

  set to TRUE to only update this attribute for data objects where that
  object already had a value set for this attribute, to update only but
  not create/add attribute.

## See also

[`metadata_check_print()`](https://public-environmental-data-partners.github.io/EJAM/reference/metadata_check_print.md)
[`metadata_check()`](https://public-environmental-data-partners.github.io/EJAM/reference/metadata_check.md)
[`metadata_add()`](https://public-environmental-data-partners.github.io/EJAM/reference/metadata_add.md)
`metadata_update_attr()`
[`metadata_add_and_use_this()`](https://public-environmental-data-partners.github.io/EJAM/reference/metadata_add_and_use_this.md)
[`dataset_documenter()`](https://public-environmental-data-partners.github.io/EJAM/reference/dataset_documenter.md)
