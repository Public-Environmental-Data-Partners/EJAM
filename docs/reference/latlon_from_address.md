# geocode, but only if AOI package is installed and attached and what it imports like tidygeocoder etc.

geocode, but only if AOI package is installed and attached and what it
imports like tidygeocoder etc.

## Usage

``` r
latlon_from_address(
  address,
  xy = FALSE,
  pt = FALSE,
  aoimap = FALSE,
  batchsize = 25,
  ...
)
```

## Arguments

- address:

  vector of addresses

- xy:

  set it to TRUE if you want only x,y returned, see help for AOI pkg

- pt:

  see help for AOI pkg, return geometry if set to TRUE, allowing map.
  param as provided is ignored and set to TRUE if aoimap=TRUE

- aoimap:

  see help for AOI pkg, create map if set to TRUE

- batchsize:

  how many to request per geocode query, done in batches if necessary

- ...:

  passed to geocode() see
  [`help(geocode, package = "AOI")`](https://rdrr.io/pkg/AOI/man/geoCode.html)

## Value

returns NULL if you have not installed and attached the AOI package. If
AOI is attached via library() or require() or package imports, this
returns a tibble table of x,y or lat,lon values or geometries. see the
AOI package.

## Details

slow? about 100 per minute?

## Examples

``` r
  # only works if AOI package installed already and attached too
  # #eg <- c("1200 Pennsylvania Ave, NW Washington DC", "Research Triangle Park")
  # #x <- geocode(eg)
  # out <- ejamit(x, radius = 3)
  # fname = system.file("testdata/address/testinput_address_table_9.xlsx", package="EJAM")
  ## or testdata('address_table_9', quiet = T)

#x1 <- read_csv_or_xl(fname)
#x2 <- latlon_from_anything(fname)
#names(x1)
#names(x2)
```
