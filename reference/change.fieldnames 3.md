# change.fieldnames one way to convert variable names (colnames) to friendlier versions

change.fieldnames one way to convert variable names (colnames) to
friendlier versions

## Usage

``` r
change.fieldnames(allnames, oldnames, newnames, file = NA, sort = FALSE)
```

## Arguments

- allnames:

  a vector of all the original fieldnames,

- oldnames:

  a vector of just the fieldnames to be changed, and

- newnames:

  a vector of what those should be change to

- file:

  path to a csv file with two columns: oldnames, newnames (instead of
  passing them to the function as parameters)

- sort:

  a logical (default is FALSE). If FALSE, return new fieldnames. If
  sort=TRUE, return vector of indexes giving new position of given
  field, based on sort order of oldnames.

## Value

new versions of names as vector
