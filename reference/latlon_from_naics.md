# Find EPA-regulated facilities in FRS by NAICS code (industrial category)

Get lat lon, Registry ID, given NAICS industry code(s) Find all EPA
Facility Registry Service (FRS) sites with this/these NAICS code(s)

## Usage

``` r
latlon_from_naics(naics, children = TRUE, id_only = FALSE, ...)
```

## Arguments

- naics:

  a vector of naics codes or query of titles of NAICS, or a data.table
  with column named code, as with output of
  [`naics_from_any()`](https://public-environmental-data-partners.github.io/EJAM/reference/naics_from_any.md)

- children:

  optional logical. set to FALSE to get only exact matches rather than
  all facilities whose NAICS starts with provided naics (or naics based
  on provided title). Many facilities have only a longer more specific
  NAICS code listed in the FRS, such as a 6-digit code, so if the
  category (e.g., 4-digit) is queried then without children = TRUE one
  would not find all the sites within that overall category.

- id_only:

  optional logical. Must set TRUE to get only regid instead of table

- ...:

  passed to
  [`naics_from_any()`](https://public-environmental-data-partners.github.io/EJAM/reference/naics_from_any.md)

## Value

A table in [data.table](https://r-datatable.com) format (not just
data.frame) with columns called lat, lon, REGISTRY_ID, NAICS,
naics_found, naics_query (unless id_only parameter set TRUE).
naics_query is the input parameter that was used (that had been provided
to this function as naics). naics_found and NAICS are identical
(redundant), and are the code found that was listed in the
[frs_by_naics](https://public-environmental-data-partners.github.io/EJAM/reference/frs_by_naics.md)
table, so it might be a subcategory (child) of the naics_query term. For
example, naics_query might be 33611 (5 digits) and for one facility the
NAICS and naics_found might be 336111 (a 6-digit code) and for another
facility they might be 336112.

## Details

Important notes:

- Finding the right NAICS and finding all the right sites by NAICS is
  complicated, and requires understanding the NAICS codes system, the
  FRS data, and the EJAM functions. See the discussion in the "Advanced"
  or other vignettes/articles.

- Many FRS sites lack NAICS code!

- Note the difference between children = TRUE and children = FALSE

- The NAICS in the returned table may be a child NAICS not the NAICS
  used in the query! This may cause confusion if you are querying
  multiple parent NAICS and you want to analyze results by NAICS!

The functions like
[`regid_from_naics()`](https://public-environmental-data-partners.github.io/EJAM/reference/regid_from_naics.md),
`latlon_from_naics()`, and
[`frs_from_naics()`](https://public-environmental-data-partners.github.io/EJAM/reference/frs_from_naics.md)
try to find EPA FRS sites based on naics codes or titles.

EPA also provides a [FRS Facility Industrial Classification Search
tool](https://www.epa.gov/frs/frs-query#industrial) where you can find
facilities based on NAICS or SIC.

See more about NAICS industry codes at <https://www.naics.com/search>

## See also

[`frs_from_naics()`](https://public-environmental-data-partners.github.io/EJAM/reference/frs_from_naics.md)
[`frs_from_sic()`](https://public-environmental-data-partners.github.io/EJAM/reference/frs_from_sic.md)
[`latlon_from_sic()`](https://public-environmental-data-partners.github.io/EJAM/reference/latlon_from_sic.md)
[`regid_from_naics()`](https://public-environmental-data-partners.github.io/EJAM/reference/regid_from_naics.md)
[`naics_from_any()`](https://public-environmental-data-partners.github.io/EJAM/reference/naics_from_any.md)

## Examples

``` r
# \donttest{
  regid_from_naics(321114)
  latlon_from_naics(321114)
  # latlon_from_naics(naics_from_any("cheese")[,code] )
  latlon_from_naics("cheese")
  head(latlon_from_naics(c(3366, 33661, 336611), id_only=TRUE))
  head(regid_from_naics(c(3366, 33661, 336611)))
  head(regid_from_naics(3366, children = TRUE))
  # mapfast(frs_from_naics(336611)) # simple map

  # get name from one code
  EJAM:::naics_from_code(336)$name
  # get the name from each code
  mycode = c(33611, 336111, 336112)
  EJAM:::naics_from_code(mycode)$name
  # see counts of facilities by code (parent) and subcategories (children)
  naics_counts[NAICS %in% mycode, ]
  # see parent codes that contain each code
  naicstable[code %in% mycode, ]

  # how many were found via each naics code?
  found = latlon_from_naics(c(211,331))
  x = table( found$naics_found, found$naics_query)
  x = x[order(x[, 1],decreasing = TRUE),]
  x
  # }
```
