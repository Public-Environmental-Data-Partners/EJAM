# utility to convert between statename and ST abbreviation

utility to convert between statename and ST abbreviation

## Usage

``` r
st2statename(ST)
```

## Arguments

- ST:

  vector of state abbreviations like "GA" (but can include state names)

## Value

returns vector of state names as long as ST vector, with NA for elements
that are neither statename nor ST

## Examples

``` r
EJAM:::st2statename(c("TX", 'dc', "Illinois"))
```
