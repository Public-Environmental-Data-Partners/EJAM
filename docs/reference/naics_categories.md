# NAICS - See the names of industrial categories and their NAICS code

Easy way to list the 2-digit NAICS (17 categories), or other level

## Usage

``` r
naics_categories(digits = 2, dataset = EJAM::NAICS)
```

## Arguments

- digits:

  default is 2, for 2-digits NAICS, the top level, but could be up to 6.

- dataset:

  Should default to the dataset called NAICS, installed with this
  package. see
  [NAICS](https://public-environmental-data-partners.github.io/EJAM/reference/NAICS.md)
  Check attr(NAICS, 'year')

## Value

matrix with 1 column of 2-digit codes and rownames that look like "22 -
Utilities" etc.

## Details

Also see <https://www.naics.com/search/>

There are this many NAICS codes roughly by number of digits in the code:

table(nchar(NAICS))

2 3 4 5 6

17 99 311 709 1057

See <https://www.census.gov/naics/>

## See also

[naics_from_any](https://public-environmental-data-partners.github.io/EJAM/reference/naics_from_any.md)
[NAICS](https://public-environmental-data-partners.github.io/EJAM/reference/NAICS.md)

## Examples

``` r
 naics_categories()
```
