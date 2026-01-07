# Basics - Quick Start Guide

## A Brief Intro to Using EJAM in RStudio

This document is about analysts or coders using the EJAM R package in
RStudio. After you [install the EJAM R
package](https://ejanalysis.github.io/EJAM/articles/installing.md), this
document explains how you can run an EJAM analysis and view results
right away using R.

This document is not about [using EJAM as a web
application](https://ejanalysis.github.io/EJAM/articles/webapp.md), but
you can launch a local web app after installing the EJAM R package.

### Load EJAM

To start using EJAM in RStudio/R, you first attach/load the R package
using [`library()`](https://rdrr.io/r/base/library.html) or
[`require()`](https://rdrr.io/r/base/library.html).

``` r
library(EJAM)
```

### Analyze Places with `ejamit()`

To quickly try EJAM in RStudio:

``` r
# EJAM analysis of 100 places, for everyone within 3 miles
out <- ejamit(testpoints_100, radius = 3)

pts <- sitepoints_from_any(c("30.97740, -83.36900", "32.51581, -86.37732"))
out2 <- ejamit(pts, radius = 2)
```

To quickly try EJAM with an example input file (spreadsheet with
latitude and longitude of each point)

``` r
myfile <- system.file("testdata/latlon/testpoints_10.xlsx", package = "EJAM")

out <- ejamit(myfile, radius = 3)
```

If you already have your own spreadsheet of point locations to analyze,
then in RStudio you can just use the
[`ejamit()`](https://ejanalysis.github.io/EJAM/reference/ejamit.md)
function without specifying the locations or radius – EJAM will prompt
you to select the file and a radius.

``` r
out <- ejamit()
```

Note: The file should be an Excel file or .csv file and the first sheet
(tab) needs to be just a table of one header row (with at least two
columns named lat and lon), and one row per site (point). No extra rows,
no merged cells, etc.

If you need examples of spreadsheets (and other input files you can
try), you can find the ones installed with the EJAM package in your
local folder, like this in the RStudio console:

``` r
## See where the folder is and see what files are there:
testdata()

# or see just the latlon files:
testdata("latlon", quiet=T)
# dir(system.file("testdata/latlon", package = "EJAM"))
```

### Pick a Radius

You can specify the radius in miles. EJAM will analyze all residents
within that many miles of each point (site).

``` r
radius <- 3 # radius (in miles).  5 km = 3.106856 miles, 10 km = 6.2 miles
```

Converting between miles and kilometers – If you know you want to
analyze for 5 kilometers, for example, you can turn it into miles.

``` r
5000 / meters_per_mile
#> [1] 3.106856
convert_units(5, 'km', 'miles')
#> [1] 3.106856
```

### Map your sites before analyzing them

This creates an interactive map. Click a point on the map to see a popup
with details about that point.

``` r
# input to EJAM
pts <- testpoints_100
mapfast(pts)
```

### Map results with `ejam2map()`

This also creates an interactive map. Click a point on the map to see a
popup with details about people near that point.

``` r
out <- testoutput_ejamit_100pts_1miles 
ejam2map(out) 
#> Warning in validateCoords(lng, lat, funcName): Data contains 1 rows with either
#> missing or invalid lat/lon values and will be ignored
#> /private/var/folders/w4/0j7n916n37q7gjt7m2vqqwk40000gn/T/RtmpvITUjz/mapfast_d23a64451f76.html
```

### Report via `ejam2report()` (interactive html file)

``` r

out <- testoutput_ejamit_100pts_1miles

ejam2report(out)

## OR for one site:
#
# y <- ejam2report(out, sitenumber = 1, analysis_title = "Site #1")
```

### Table of Results in RStudio console

As an alternative to the report provided by
[`ejam2report()`](https://ejanalysis.github.io/EJAM/reference/ejam2report.md),
this gives you a quick, simple list of results for all the indicators:

``` r
ejam2table_tall(out)
ejam2table_tall(out, sitenumber = 1)
```

### Barplot

``` r
out <- testoutput_ejamit_100pts_1miles

# Check long list of indicators for any that are elevated

ejam2barplot(out,
             varnames = names_these_ratio_to_avg,
             main = "Envt & Demog Indicators at Selected Sites Compared to State Averages")

ejam2barplot(out,
             varnames = names_these_ratio_to_state_avg,
             main = "Envt & Demog Indicators at Selected Sites Compared to State Averages")


# residential population data only

# vs nationwide avg
ejam2barplot(testoutput_ejamit_100pts_1miles)

# vs statewide avg
ejam2barplot(testoutput_ejamit_1000pts_1miles,
             varnames = c(names_d_ratio_to_state_avg, names_d_subgroups_ratio_to_state_avg),
             main = "Residential population group percentages at Selected Sites Compared to State Averages")


# Environmental only

ejam2barplot(testoutput_ejamit_100pts_1miles,
             varnames = c(names_e_ratio_to_avg),  # , names_e_ratio_to_state_avg),
             main = "Environmental Indicators at Selected Sites Compared to Averages")
```

``` r
# see more examples at ?ejam2barplot
```

### View Results Spreadsheet via `ejam2excel()` (to Launch Excel)

``` r
out <- testoutput_ejamit_100pts_1miles
ejam2excel(out, launchexcel = T, save_now = F)
```

#### Save Results as a Spreadsheet file

``` r
ejam2excel(out, save_now = T)
```

------------------------------------------------------------------------

### More about points

#### Use one point

``` r
pts <- data.frame(lon = -92.380556, lat = 31.316944)
```

#### Use a few points

``` r
pts <- sitepoints_from_any(c(
  "34.8799123, -92.1",
  "30.2906971, -91.8",
  "30,         -95"
))
## or
pts  <- data.frame(
  lon = c(-92.1,      -91.8), 
  lat = c(34.8799123, 30.2906971)
)

pts
#>     lon      lat
#> 1 -92.1 34.87991
#> 2 -91.8 30.29070
```

#### Create a random sample of points representative of the average facility, average resident, or average area

You can create a set of random points with function
[`testpoints_n()`](https://ejanalysis.github.io/EJAM/reference/testpoints_n.md)
that can be weighted to represent the average resident, average
regulated facility, average point on a map weighted by square meters,
etc. See more details in the documentation of the function
[`testpoints_n()`](https://ejanalysis.github.io/EJAM/reference/testpoints_n.md).

Create random test data points in States of LA and TX

``` r
# p1k <- testpoints_n(1000)
# mapfast(p1k)

mapfast(testpoints_n(300, ST = c('LA','TX'), weighting = 'bg'), radius = 0.1) 
#> Including only these States:
#>   REGION ST statename
#> 1      6 LA Louisiana
#> 2      6 TX     Texas
```

``` r
# weighting = "frs" better represents regulated facilities,
# but requires loading the (large) frs dataset
```

## Documentation of Functions and Data

- [README](https://ejanalysis.github.io/EJAM/index.md)
- [Function Reference
  Document](https://ejanalysis.github.io/EJAM/reference/index.md)
- In RStudio, see
  [`?EJAM`](https://ejanalysis.github.io/EJAM/reference/EJAM.md)

``` r
?EJAM
# or 
help("EJAM", package='EJAM')

?ejamit()
```
