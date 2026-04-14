# Convert units of distance or area

`convert_units` converts distance or area from specified units to other
specified units.

## Usage

``` r
convert_units(x, from = "km", towhat = "mi")
```

## Arguments

- x:

  A number or vector of numbers to be converted.

- from:

  A string specifying original units of input parameter. Default is 'km'
  which is kilometers. Note all must be in the same units. Units can be
  specified as any of the aliases found in the code for
  [`fixnames_aliases()`](https://public-environmental-data-partners.github.io/EJAM/reference/fixnames_aliases.md)

  Note that m2 is for square meters not square miles.

- towhat:

  A string specifying new units to convert to. Default is 'mi' which is
  miles.

## Value

Returns a number or vector of numbers then length of the input x, with
each element corresponding to an input element converted to new units.

## Details

This function takes a number, or vector of numbers, representing
distance/length or area in one type of specified units, such as miles,
and returns the corresponding number(s) converted to some other units,
such as kilometers. Units can be specified in various ways. All inputs
must be in the same units. All outputs must be in a single set of units
as well.

NOTE: For some purposes, Census Bureau does this:

"The ANSI standard for converting square kilometers into square miles
was used ( 1 square mile = 2.58998811 square kilometers)." see
<https://www.census.gov/geo/reference/state-area.html> but the
conversions in this function use 2.5899881034 not 2.58998811 sqkm/sqmi.
The difference is only 6.6 per billion (roughly 1 in 152 million), which
is less than one tenth of a square kilometer out the entire USA.

## Examples

``` r
convert_units(1, 'mi', 'km')
convert_units(c(1e6, 1), 'sqm', 'sqkm')
```
