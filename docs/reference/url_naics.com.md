# URL functions - url_naics.com - Get URL for page with info about industry sectors by text query term

URL functions - url_naics.com - Get URL for page with info about
industry sectors by text query term

## Usage

``` r
url_naics.com(
  query = "",
  as_html = FALSE,
  linktext = query,
  ifna = "https://www.naics.com",
  baseurl = "https://www.naics.com/code-search/?trms=",
  ...
)
```

## Arguments

- query:

  string query term like "gasoline" or "copper smelting"

- as_html:

  Whether to return as just the urls or as html hyperlinks to use in a
  DT::datatable() for example

- linktext:

  used as text for hyperlinks, if supplied and as_html=TRUE

- ifna:

  URL shown for missing, NA, NULL, bad input values

- baseurl:

  do not change unless endpoint actually changed

- ...:

  unused

## Value

URL as string

## Details

See (https://naics.com) for more information on NAICS codes.

Unlike url_xyz() functions, which provide a unique link for each site,
this url\_ function provides just a link for a whole industry or set of
industries based on a query, so it is not meant to be used in a column
of site by site results the way the other url_xyz() functions are.
