# Zipcodes

## How to use EJAM to analyze zip codes

EJAM can analyze various kinds of Census-defined areas, including
States, Counties, Tracts, Blockgroups, and Cities/CDPs/etc.

However, you may need to analyze zip codes.

Census uses ZIP Code Tabulation Areas (ZCTAs), which are generalized
areal representations of United States Postal Service (USPS) ZIP Code
service areas. See
[`help("zctas", package="tigris")`](https://rdrr.io/pkg/tigris/man/zctas.html)

Note a zip can be the same as a county fips in many cases, as with
10001!

![many county fips are also a
zipcode](images/many_county_fips_are_also_a_zipcode.png)

many county fips are also a zipcode

The original (pre-2025) EJSCREEN API did not handle zip codes. It can
show where the center of the zip code is but will not map its bounds or
provide a report easily via the API.

``` r
# Just see where the zipcode is, not its boundaries
browseURL(url_ejscreenmap(wherestr =  '10001'))
```

**To map and analyze zip codes you can download shapefiles for them and
analyze or map them in EJAM as shown below.**

### downloading zcta polygons

Takes time to download!

``` r
library(tigris)
# options(tigris_use_cache=TRUE) # done by EJAM load/attach
options(tigris_refresh=FALSE)
#zcta_DE <- zctas(starts_with = fips_from_name('DE'), keep_zipped_shapefile = T) # all in the state
#zcta1 <- zctas(starts_with = c("10001"))  # one zip
zcta2 <- zctas(starts_with = c("10012", "10506"))  # two zipcodes

z = shapefile_from_any(zcta2)
```

### mapping zcta polygons

``` r
mapfast(z)
```

### Another source of zip code polygons (esri service)

``` r

# Download spatial bounds for all zipcodes in Delaware
ST1 <- "DE"
url1 <- paste0("https://services.arcgis.com/P3ePLMYs2RVChkJx/ArcGIS/rest/services/USA_Boundaries_2022/FeatureServer/3/query?",
  "where=STATE%3D%27", ST1, "%27",
  "&geometryType=esriGeometryEnvelope&inSR=&spatialRel=esriSpatialRelIntersects&resultType=none&distance=0.0&units=esriSRUnit_Meter&relationParam=&returnGeodetic=false",
  "&outFields=*",
  "&returnGeometry=true",
  "&f=json")
require(httr2); require(sf); require(mapview)
response1 <- httr2::req_perform(httr2::request(url1))
text1 <- httr2::resp_body_string(response1)
shp1 <- sf::st_read(text1)
mapview::mapview(shp1)
```

### see EJSCREEN map at a zip code

browseURL(url_ejscreenmap(wherestr = ‘20019’))

### analyzing zip codes in EJAM

You can analyze zip codes in EJAM like this:

``` r
out = ejamit(shapefile = z, radius = 0)
```

### summary report on zipcodes

``` r
ejam2report(out, 
            analysis_title = "Zip codes",
            site_method = 'SHP', 
            shp = z)
```

### compare sites

``` r
# put zip code in the x axis labels!
ejam2barplot_sites(out, names.arg = z$GEOID20, sortby = FALSE) # zcta2$GEOID20

# This table view works, but the links to reports do not work with zipcodes
ejam2tableviewer(out)
```

### map of detailed results

``` r

out_plus_shape = sf::st_as_sf(
  data.frame(out$results_bysite, z)
  )
# put zip code in the map popups!
out_plus_shape$ejam_uniq_id = paste0(out_plus_shape$ejam_uniq_id, " (zip ", z$GEOID20, ")")
mapfastej(out_plus_shape)
```

Note that
[`ejam2map()`](https://ejanalysis.github.io/EJAM/reference/ejam2map.md)
will not work for zipcodes!
