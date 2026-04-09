# General way to search for industry names and NAICS codes

Find industry names and codes by searching for queried code(s) or text

## Usage

``` r
sic_from_any(
  query,
  children = FALSE,
  ignore.case = TRUE,
  fixed = FALSE,
  website_scrape = FALSE,
  website_url = FALSE
)
```

## Arguments

- query:

  query string(s) and/or number(s), vector of NAICS codes or industry
  names or any regular expression or partial words

- children:

  logical, if TRUE, also return all the subcategories - where NAICS
  starts with the same digits

- ignore.case:

  see [`grepl()`](https://rdrr.io/r/base/grep.html)

- fixed:

  should it be an exact match? see
  [`grepl()`](https://rdrr.io/r/base/grep.html)

- website_scrape:

  whether to scrape info from the NAICS website to return a table of
  codes and names that match (web query uses synonyms so gets more hits)

- website_url:

  whether to return the URL of the webpage with info on the NAICS (web
  query uses synonyms so gets more hits)

## Value

a subset of the
[sictable](https://public-environmental-data-partners.github.io/EJAM/reference/sictable.md)
table in [data.table](https://r-datatable.com) format (not just the
codes column)

## See also

[`sic_subcodes_from_code()`](https://public-environmental-data-partners.github.io/EJAM/reference/sic_subcodes_from_code.md)
[`sic_from_code()`](https://public-environmental-data-partners.github.io/EJAM/reference/sic_from_code.md)
[`sic_from_name()`](https://public-environmental-data-partners.github.io/EJAM/reference/sic_from_name.md)
`sic_from_any()`
