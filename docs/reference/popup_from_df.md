# Map popups - Simple map popup from a data.frame, one point per row MAY DEPRECATE - See popup_from_any() for newer more general replacement for this.

Map popups - Simple map popup from a data.frame, one point per row MAY
DEPRECATE - See popup_from_any() for newer more general replacement for
this.

## Usage

``` r
popup_from_df(x, column_names = names(x), labels = column_names, n = "all")
```

## Arguments

- x:

  data.frame with info to be shown in map popups

- column_names:

  default is all, or a vector of column names from x to use

- labels:

  default is colnames(x) - vector used to label the elements in the
  popup. Must be same length as column_names

- n:

  Show the first n columns of mypoints, in popup. "all" means all of
  them.

## Value

A vector of strings, one per row or map point, with a line break
separating column elements

## Details

Each popup is made from one row of the data.frame. Each popup has one
row of text per column of the data.frame

## Examples

``` r
 df <- structure(list(
   RegistryId = c("110071102551", "110015787683"),
   FacilityName = c("USDOI FWS AK MARITIME NWR etc", "ADAK POWER PLANT"),
   LocationAddress=c("65 MI W. OF ADAK NAVAL FACILITY","100 HILLSIDE BLVD"),
   CityName = c("ADAK", "ADAK"),
   CountyName = c("ALEUTIAN ISLANDS", "ALEUTIANS WEST"),
   StateAbbr = c("AK", "AK"),
   ZipCode = c("99546", "99546"),
   FIPSCode = c("02010", "02016"),
   lat = c(51.671389,51.8703), lon = c(-178.051111, -176.659),
   SupplementalLocation = c(NA_character_,NA_character_)),
   row.names = 1:2, class = "data.frame")
 leaflet::leaflet(df) |> leaflet::addTiles() |>
   leaflet::addPopups(popup = popup_from_df(df))
```
