# Map - points - ggplot2 map of points in the USA - very basic map

Map - points - ggplot2 map of points in the USA - very basic map

## Usage

``` r
mapfast_gg(
  mydf = data.frame(lat = 40, lon = -100)[0, ],
  dotsize = 1,
  ptcolor = "black",
  xlab = "Longitude",
  ylab = "Latitude",
  ...
)
```

## Arguments

- mydf:

  data.frame with columns named lat and lon

- dotsize:

  optional, size of dot representing a point

- ptcolor:

  optional, color of dot

- xlab:

  optional, text for x label

- ylab:

  optional, text for y label

- ...:

  optional, passed to
  [`ggplot2::labs()`](https://ggplot2.tidyverse.org/reference/labs.html)

## Value

a ggplot() object

## Examples

``` r
# \donttest{
  mapfast_gg(testpoints_10)

  pts <- read.table(textConnection(
  "lat lon
  39.5624775 -119.7410994
  42.38748056 -94.61803333"
  ),
  header = TRUE,
  as.is = TRUE
  )
  mapfast_gg(pts)
  # str(pts) # lon, not long
  # }
```
