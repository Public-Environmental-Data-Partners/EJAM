# geodesic distance between two points, obtained via an API

geodesic distance between two points, obtained via an API

## Usage

``` r
distance_epa_api(
  lat1,
  lon1,
  lat2,
  lon2,
  pts = NULL,
  unit = "miles",
  crs = 4269
)
```

## Arguments

- lat1, lon1:

  latitude and longitude of point 1

- lat2, lon2:

  latitude and longitude of point 2

- pts:

  Alternative way to specify the two points, as a data.frame of two rows
  and columns named "lat" and "lon"

- unit:

  can be "miles", the default, or else "meters" to get distance in
  meters. unit is called distanceUnit in the API: For planar distance,
  if distanceUnit is not specified, the distance is in the units of the
  given spatial reference. If distanceUnit is specified, the unit must
  be compatible with the given spatial reference. That is, if sr is a
  PCS, distanceUnit must be linear. If sr is a GCS, distanceUnit must be
  angular. For geodesic distance, If distanceUnit is not specified, the
  distance is measured in meters. If distanceUnit is specified, the unit
  must be linear.

- crs:

  default spatial reference is 4269 aka Geodetic CRS NAD83. crs, called
  sr in the API, specifies the well-known ID (WKID) or a spatial
  reference JSON object for input geometries. The spatial reference can
  be either a projected coordinate system (PCS) or a geographic
  coordinate system (GCS). For a list of valid WKID values, see [Using
  spatial
  references](https://geopub.epa.gov/arcgis/help/en/rest/services-reference/enterprise/using-spatial-references/)

## Value

a single number, the distance

## Details

[Documentation of
API](https://geopub.epa.gov/arcgis/help/en/rest/services-reference/enterprise/distance/)

## See also

[`distances.all()`](https://public-environmental-data-partners.github.io/EJAM/reference/distances.all.md)

## Examples

``` r
pts <- testpoints_10[c(3,10),]
distances.all(pts[1,],pts[2,])
d <- distance_epa_api(pts = pts)
print(d)
mapfast(pts, radius = d/2)
```
