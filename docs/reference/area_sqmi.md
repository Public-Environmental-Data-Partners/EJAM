# utility to get areas of places (points with radius at each, or polygons, or census units by FIPS)

utility to get areas of places (points with radius at each, or polygons,
or census units by FIPS)

## Usage

``` r
area_sqmi(
  df = NULL,
  radius.miles = NULL,
  shp = NULL,
  fips = NULL,
  download_city_fips_bounds = TRUE,
  download_noncity_fips_bounds = FALSE,
  includewater = FALSE
)
```

## Arguments

- df:

  optional data.frame, one place per row - This function tries to infer
  sitetype by seeing if df is 1) a spatial data.frame of class "sf",
  or 2) has a column that can be interpreted as an alias for fips, or as
  last resort, 3) a column that is an alias for radius.miles

- radius.miles:

  optional vector of distances from points defining circular buffers

- shp:

  optional spatial data.frame sf class object like from
  [`shapefile_from_any()`](https://public-environmental-data-partners.github.io/EJAM/reference/shapefile_from_any.md)

- fips:

  optional vector of character Census FIPS codes, with leading zeroes, 2
  digits for State, 5 for county, etc. If you already have the
  boundaries then provide that as shp instead of this parameter (much
  faster that way).

- download_city_fips_bounds:

  if TRUE, fips that are "city" are handled by trying to download
  shapefile boundaries to calculate area. otherwise they are returned as
  NA.

- download_noncity_fips_bounds:

  if set to TRUE, fips that are state, county, tract, or blockgroup
  types have their area estimate come from the column
  blockgroupstats\$arealand. If FALSE, it more slowly downloads boundary
  shapefiles and then uses sf::sf_area to calculate areas. These two
  methods give roughly the same answer.

- includewater:

  whether to add blockgroupstats\$areawater not just \$arealand.
  includewater only matters when download_noncity_fips_bounds = FALSE,
  and only for state, county, tract, blockgroup FIPS, not "city" types
  of fips as identified by
  [`fipstype()`](https://public-environmental-data-partners.github.io/EJAM/reference/fipstype.md)

## Value

vector of numbers same length as length(radius.miles) or length(fips) or
NROW(shp)

## Details

Only one of the parameters can be specified at a time, and others must
be NULL. If you provide a data.frame it tries to infer which info is in
the table – radius.miles, shp, or fips.

Note this is slow for fips since it has to download boundaries. If you
already have the shapefile of boundaries, provide that as the shp
parameter instead of using fips.

Note: if you provide a single number for radius (a vector of length 1),
this returns a single value for area. If you provide a vector of radius
values, even if they are all the same number, this returns a vector as
long as the input radius.miles or as long as NROW(df).
