# NAICS - General way to search for industry names and NAICS codes

Find industry names and codes by searching for queried code(s) or text

## Usage

``` r
naics_from_any(
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
[naicstable](https://ejanalysis.github.io/EJAM/reference/naicstable.md)
data.table (not just the codes column)

## Details

Finding the right NAICS/SIC and finding all the right sites is
complicated. See discussion of
[`latlon_from_naics()`](https://ejanalysis.github.io/EJAM/reference/latlon_from_naics.md).

## See also

[`latlon_from_naics()`](https://ejanalysis.github.io/EJAM/reference/latlon_from_naics.md)
[`frs_from_naics()`](https://ejanalysis.github.io/EJAM/reference/frs_from_naics.md)
[`naics_subcodes_from_code()`](https://ejanalysis.github.io/EJAM/reference/naics_subcodes_from_code.md)
[`naics_from_code()`](https://ejanalysis.github.io/EJAM/reference/naics_from_code.md)
[`naics_from_name()`](https://ejanalysis.github.io/EJAM/reference/naics_from_name.md)

## Examples

``` r
# Also see vignettes for many more examples, and discussion.
  naics_categories()

  naics_from_any("textile mills", children = FALSE)
  naics_from_any("textile mills", children = TRUE)

  frs_from_naics("textile mills", children = FALSE)
  frs_from_naics("textile mills", children = TRUE)

  if (FALSE) { # \dontrun{
  naics_from_any(naics_categories(3))[order(name),.(name,code)][1:10,]
  naics_from_any(naics_categories(3))[order(code),.(code,name)][1:10,]
  naics_from_code(211)
  naicstable[code==211,]
  naics_subcodes_from_code(211)
  naics_from_code(211,  children = TRUE)
  naicstable[n3==211,]
  NAICS[211][1:3] # wrong
  NAICS[NAICS == 211]
  NAICS["211 - Oil and Gas Extraction"]

 naics_from_any("plastics and rubber")[,.(name,code)]
 naics_from_any(326)
 naics_from_any(326, children = T)[,.(code,name)]
 naics_from_any("plastics", children=T)[,unique(n3)]
 naics_from_any("pig")
 naics_from_any("pig ") # space after g

 # naics_from_any("copper smelting")
 # naics_from_any("copper smelting", website_scrape=TRUE)
 # browseURL(naics_from_any("copper smelting", website_url=TRUE) )

 a = naics_from_any("plastics")
 b = naics_from_any("rubber")
 fintersect(a,b)[,.(name,code)] #  a AND b
 funion(a,b)[,.(name,code)]     #  a OR  b
 naics_subcodes_from_code(funion(a,b)[,code])[,.(name,code)]   #  plus children
 naics_from_any(funion(a,b)[,code], children=T)[,.(name,code)] #  same

 NROW(naics_from_any(325))
#[1] 1
 NROW(naics_from_any(325, children = T))
#[1] 54
 NROW(naics_from_any("chem"))
#[1] 20
 NROW(naics_from_any("chem", children = T))
#[1] 104
} # }
```
