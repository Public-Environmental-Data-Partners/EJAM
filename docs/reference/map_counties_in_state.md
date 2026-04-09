# Basic map of county outlines within specified state(s) Not used by shiny app

Basic map of county outlines within specified state(s) Not used by shiny
app

## Usage

``` r
map_counties_in_state(
  ST = "DE",
  colorcolumn = c("pop", "NAME", "POP_SQMI", "STATE_NAME")[1],
  type = c("leaflet", "mapview")[1]
)
```

## Arguments

- ST:

  a vector of one or more state abbreviations, like

  ST = "ME" or ST = c("de", "RI"), or

  `ST = fips2stateabbrev(fips_state_from_statename(c("Rhode Island", "district of columbia")))`

  or e.g., all counties in EPA Region 1:

  `ST = stateinfo$ST[stateinfo$REGION == 1]`

- colorcolumn:

  name of column to use in setting colors of counties on map, but must
  be one returned by
  [`shapes_counties_from_countyfips()`](https://public-environmental-data-partners.github.io/EJAM/reference/shapes_counties_from_countyfips.md)
  like "STATE_NAME"

- type:

  must be "leaflet" or can be "mapview" if installed and loaded

## Value

a map

## Examples

``` r
# \donttest{
map_counties_in_state(ST = c('id', 'mt'))
map_counties_in_state(ST = c('id', 'mt'),
  colorcolumn = "STATE_NAME")

map_counties_in_state(ST = c('id', 'mt'), type = "mapview")
map_counties_in_state(ST = c('id', 'mt'), type = "mapview",
  colorcolumn = "STATE_NAME")

 map_counties_in_state(
  ST = c( 'md', 'pa'),
   type = "mapview", colorcolumn = "POP_SQMI")
# }
```
