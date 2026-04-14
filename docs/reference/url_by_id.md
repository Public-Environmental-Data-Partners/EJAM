# Get the URLs to use to query FRS API via GET, to find EPA facilities by ID as xml format info

Get the URLs to use to query FRS API via GET, to find EPA facilities by
ID as xml format info

## Usage

``` r
url_by_id(idx, type = "frs", ...)
```

## Arguments

- idx:

  vector of one or more character strings with pgm_sys_id or registry_id
  values (all need to be the same type, as defined by type parameter).
  Program ids are like "VA0088986" and frs ids are like "110015787683"

- type:

  one word, applies to all. default is frs but can be program or the
  word other.

- ...:

  appended to the end of the URL as-is, useful if type is other, for
  example

## Value

vector of URLs as strings, same length as id parameter

## Details

url_by_id() is a helper used by locate_by_id()

see
[`latlon_from_programid()`](https://public-environmental-data-partners.github.io/EJAM/reference/latlon_from_programid.md)
and
[`latlon_from_regid()`](https://public-environmental-data-partners.github.io/EJAM/reference/latlon_from_regid.md)
in contrast to this.

This function helps use an API to get latest info that is online, unlike
latlon_from_regid() that looks in the last snapshot of FRS info that the
installed EJAM package has, which might be out of date.

This URL is to be used to get xml info back, while
latlon_from_programid() etc. would return a data.frame. See examples

This provides street address too, which latlon_from_regid() does not.

This can use a registry ID or the EPA program ID.

For details on FRS API, see https://www.epa.gov/frs/frs-rest-services
and examples at https://www.epa.gov/frs/frs-rest-services#ex1 and more
at https://www.epa.gov/frs/frs-rest-services#appendixa For example:
https://frs-public.epa.gov/ords/frs_public2/frs_rest_services.get_facilities?pgm_sys_id=VA0088986
https://frs-public.epa.gov/ords/frs_public2/frs_rest_services.get_facilities?registry_id=110010912496

## See also

?latlon_from_programid() and ?latlon_from_regid() and the obsolete
locate_by_id()

## Examples

``` r
EJAM:::url_by_id(testinput_regid)
# \donttest{
browseURL(EJAM:::url_by_id(testinput_regid)[1])

urlx = EJAM:::url_by_id(testinput_regid[1])
x = xml2::read_xml(urlx)
x = xml2::as_list(x)
cbind( unlist(x$Results$FRSFacility))
# }
```
