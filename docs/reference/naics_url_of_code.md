# NAICS - Get URL for page with info about industry sector(s) by NAICS

See (https://naics.com) for more information on NAICS codes

## Usage

``` r
naics_url_of_code(naics)
```

## Arguments

- naics:

  vector of one or more NAICS codes, like 11,"31-33",325

## Value

vector of URLs as strings like
https://www.naics.com/six-digit-naics/?v=2017&code=22

## See also

[`naics_from_any()`](https://public-environmental-data-partners.github.io/EJAM/reference/naics_from_any.md)
[`naics_findwebscrape()`](https://public-environmental-data-partners.github.io/EJAM/reference/naics_findwebscrape.md)
