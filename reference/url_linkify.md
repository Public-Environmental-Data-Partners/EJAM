# utility to make html link from URL

Convert URL to HTML link that opens in new tab

## Usage

``` r
url_linkify(url, text, newtab = TRUE, encode = TRUE, reserved = FALSE)
```

## Arguments

- url:

  string that is URL

- text:

  string that is label

- newtab:

  unless set to FALSE, link opens in a new browser tab

- encode:

  unless set to FALSE, it uses
  [`utils::URLencode()`](https://rdrr.io/r/utils/URLencode.html) first

- reserved:

  if encode=T, this parameter is passed to
  [`utils::URLencode()`](https://rdrr.io/r/utils/URLencode.html)

## Value

url_linkify('epa.gov','EPA') returns
`"<a href=\"epa.gov\", target=\"_blank\">EPA</a>"`

## Details

Consider also the golem utility enurl() as modified in this pkg, except
that enurl()

1.  does not make a link that would open in new tab,

2.  skips [`utils::URLencode()`](https://rdrr.io/r/utils/URLencode.html)
    and

3.  returns "shiny.tag" class

4.  now sets text=url, while url_linkify() uses a shorter text

`enurl("https://google.com", "click here")`
`url_linkify("https://google.com")`

`enurl("https://google.com")`

`url_linkify("https://google.com", "click here")`

## See also

[`enurl()`](https://public-environmental-data-partners.github.io/EJAM/reference/enurl.md)
