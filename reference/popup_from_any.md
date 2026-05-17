# Map popups - Simple map popup from a table in [data.table](https://r-datatable.com) format or data.frame, one point per row

Creates popup vector
[`leaflet::addCircles()`](https://rstudio.github.io/leaflet/reference/map-layers.html)
or
[`leaflet::addPopups()`](https://rstudio.github.io/leaflet/reference/map-layers.html)
can use.

## Usage

``` r
popup_from_any(
  x,
  column_names = names(x),
  labels = column_names,
  n = "all",
  testing = FALSE
)
```

## Arguments

- x, :

  a table in [data.table](https://r-datatable.com) format table or data
  frame. If `x` is another object type, it is coerced via
  [`as.data.frame()`](https://rdrr.io/r/base/as.data.frame.html).

- column_names:

  default is all, or a vector of column names from x to use. If some of
  column_names requested are not found in names(x), a warning is given
  and NA values returned for those names not in x. If some of names(x)
  not requested by column_names, they are left out.

- labels:

  default is column_names - vector used to label the elements in the
  popup. Must be same length as column_names

- n:

  Show the first n columns of mypoints, in popup. "all" means all of
  them.

- testing:

  can set to TRUE while testing function

## Value

A vector of strings, one per row or map point, with a line break
separating column elements

## Details

Each popup is made from one row of the data.frame. Each popup has one
row of text per column of the data.frame

## Examples

``` r
 dat <- data.table::data.table(
   RegistryId = c("110071102551", "110015787683"),
   FacilityName = c("USDOI FWS AK MARITIME NWR etc", "ADAK POWER PLANT"),
   LocationAddress = c("65 MI W. OF ADAK NAVAL FACILITY", "100 HILLSIDE BLVD"),
   CityName = c("ADAK", "ADAK"),
   CountyName = c("ALEUTIAN ISLANDS", "ALEUTIANS WEST"),
   StateAbbr = c("AK", "AK"),
   ZipCode = c("99546", "99546"),
   FIPSCode = c("02010", "02016"),
   lat = c(51.671389,51.8703), lon = c(-178.051111, -176.659),
   SupplementalLocation = c(NA_character_,NA_character_))

 ## add popups only
 leaflet::leaflet(dat) |> leaflet::addTiles() |> leaflet::addPopups(popup = popup_from_any(dat))

 ## add circles with clickable popups
 leaflet::leaflet(dat) |> leaflet::addTiles() |> leaflet::addCircles(popup = popup_from_any(dat))

 ## convert to data frame, works the same way
 dat_df <- as.data.frame(dat)
 leaflet::leaflet(dat) |> leaflet::addTiles() |> leaflet::addCircles(popup = popup_from_any(dat))
```
