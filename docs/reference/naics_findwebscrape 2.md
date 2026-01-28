# for query term, show list of roughly matching NAICS, scraped from web

This finds more than just
[`naics_from_any()`](https://ejanalysis.github.io/EJAM/reference/naics_from_any.md)
does, since that needs an exact match but this looks at naics.com
website which lists various aliases for a sector.

## Usage

``` r
naics_findwebscrape(query)
```

## Arguments

- query:

  text like "gasoline" or "copper smelting"

## Value

data.frame of info on what was found, naics and title

## See also

[`naics_from_any()`](https://ejanalysis.github.io/EJAM/reference/naics_from_any.md)
[`url_naics.com()`](https://ejanalysis.github.io/EJAM/reference/url_naics.com.md)

## Examples

``` r
 # naics_from_any("copper smelting")
 # naics_from_any("copper smelting", website_scrape=TRUE)
 # browseURL(naics_from_any("copper smelting", website_url=TRUE) )

  url_naics.com("copper smelting")
  # \donttest{
  naics_findwebscrape("copper smelting")
  browseURL(url_naics.com("copper smelting"))
  browseURL(naics_url_of_code(326))
  # }
```
