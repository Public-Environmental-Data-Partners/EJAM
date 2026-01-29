# utility to convert between statename and ST abbreviation

utility to convert between statename and ST abbreviation

## Usage

``` r
statename2st(statename)
```

## Arguments

- statename:

  vector of state names (but can include state abbreviations)

## Value

returns vector of ST abbreviations as long as statename vector, with NA
for elements that are neither statename nor ST

## Examples

``` r
 EJAM:::statename2st(c("TX", 'dc', "Illinois"))
```
