# utility for pkg devs to update or create documentation of datasets in the package

utility for pkg devs to update or create documentation of datasets in
the package

## Usage

``` r
dataset_documenter(
  varname,
  title = "(varname) dataset",
  description = "",
  details = "",
  seealso = "",
  saveinpackage = TRUE
)
```

## Arguments

- varname:

  character string text of name of object, like "blockgroupstats"

- title:

  same as the roxygen2 tag

- description:

  same as the roxygen2 tag

- details:

  same as the roxygen2 tag

- seealso:

  same as the roxygen2 tag

- saveinpackage:

  if TRUE, puts quoted dataset name at end of file, and otherwise puts
  NULL at end of file

## Value

name of .R file where documentation was written

## Details

see [article on updating
datasets](https://ejanalysis.github.io/EJAM/articles/dev-update-datasets.html)
