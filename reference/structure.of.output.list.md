# Utility to print summary info about the output of ejamit() or doaggregate()

Utility to print summary info about the output of ejamit() or
doaggregate()

## Usage

``` r
structure.of.output.list(x, maxshown = 10, objectname = NULL)
```

## Arguments

- x:

  the output of
  [`ejamit()`](https://public-environmental-data-partners.github.io/EJAM/reference/ejamit.md)
  or of
  [`doaggregate()`](https://public-environmental-data-partners.github.io/EJAM/reference/doaggregate.md),
  a list of objects holding results of analysis

- maxshown:

  shows only first 10 elements of list by default

- objectname:

  name to use in printing summary, e.g., "Output of ejamit()" or default
  is to use the name of the object passed to this function.

## Value

data.frame summarizing names of list, whether each element is a
data.table, data.frame, or vector, and rows/cols/length info

## Examples

``` r
  EJAM:::structure.of.output.list(testpoints_10)
  EJAM:::structure.of.output.list(testoutput_getblocksnearby_10pts_1miles)
  EJAM:::structure.of.output.list(testoutput_doaggregate_10pts_1miles)
  EJAM:::structure.of.output.list(testoutput_ejamit_10pts_1miles)
```
