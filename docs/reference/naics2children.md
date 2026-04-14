# NAICS - query NAICS codes and also see all children (subcategories) of any of those

NAICS - query NAICS codes and also see all children (subcategories) of
any of those

## Usage

``` r
naics2children(codes, allcodes = EJAM::NAICS, quiet = FALSE)
```

## Arguments

- codes:

  vector of numerical or character

- allcodes:

  Optional (already loaded with package) - dataset with all the codes

- quiet:

  whether to avoid printing results to console

## Value

vector of codes and their names

## Details

- Starts with shortest (highest level) codes. Since tied for nchar,
  these branches have zero overlap, so do each.

- For each of those, get its `children = all` rows where
  `parentcode == substr(allcodes, 1, nchar(parentcode))`

- Put together list of all codes we want to include so far.

- For the next longest set of codes in original list of codes, do same
  thing.

- continue until done for 5-digit ones to get 6-digit children.

- Take the `unique(allthat)`

`table(nchar(as.character(NAICS)))`

` 2 3 4 5 6`

` 17 99 311 709 1057`

## See also

[`naics_from_code()`](https://public-environmental-data-partners.github.io/EJAM/reference/naics_from_code.md)
[NAICS](https://public-environmental-data-partners.github.io/EJAM/reference/NAICS.md)

## Examples

``` r
  naics2children(211)
  EJAM:::naics_from_code(211)
  EJAM:::naics_from_code(211, children = TRUE)
  NAICS[211][1:3] # wrong
  NAICS[NAICS == 211]
  NAICS["211 - Oil and Gas Extraction"]
```
