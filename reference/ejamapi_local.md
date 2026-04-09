# Run API in background to test/develop it

Run API in background to test/develop it

## Usage

``` r
ejamapi_local(
  fname = system.file("plumber/plumber.R", package = "EJAM"),
  host = "127.0.0.1",
  port = 3035,
  quiet = FALSE
)
```

## Arguments

- fname:

  file with API definition using plumber package

- host:

  optional, localhost IP

- port:

  optional, a port number

- quiet:

  optional, set to TRUE To reduce info printed to console

## Value

NA

## See also

[`ejamapi()`](https://public-environmental-data-partners.github.io/EJAM/reference/ejamapi.md)
and
[`url_ejamapi()`](https://public-environmental-data-partners.github.io/EJAM/reference/url_ejamapi.md)

## Examples

``` r
if (FALSE) { # \dontrun{
 # launch and try it in R console
 ejamapi_local()

 urlx <- "http://127.0.0.1:3035/getblocksnearby?lat=33&lon=-99&radius=2"
 reqx <- httr2::request(urlx)
 httr2::req_dry_run(reqx)
 outx <- httr2::req_perform(reqx)

 s2b <- data.table::rbindlist(httr2::resp_body_json(outx))
 s2b

 urlx <- "http://ejamapi-84652557241.us-central1.run.app/report?lat=33&lon=-99&radius=2"
 reqx <- httr2::request(urlx)
 httr2::req_dry_run(reqx)
 outx <- httr2::req_perform(reqx)

 x <- httr2::resp_body_html(outx)
 fname <- tempfile("report", fileext = ".html")
 xml2::write_html(x, file = fname)
 browseURL(fname)
} # }
```
