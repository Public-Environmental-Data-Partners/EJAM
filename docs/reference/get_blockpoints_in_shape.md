# Find all Census blocks in a polygon, using internal point of block

Like
[`getblocksnearby()`](https://public-environmental-data-partners.github.io/EJAM/reference/getblocksnearby.md),
but for blocks in each polygon rather than blocks near each facility.
For analyzing all residents in certain zones such as places at elevated
risk, redlined areas, watersheds, etc.

## Usage

``` r
get_blockpoints_in_shape(
  polys,
  addedbuffermiles = 0,
  blocksnearby = NULL,
  dissolved = FALSE,
  safety_margin_ratio = 1.1,
  crs = 4269,
  updateProgress = NULL,
  oldway = TRUE
)
```

## Arguments

- polys:

  Spatial data as from
  [`sf::st_as_sf()`](https://r-spatial.github.io/sf/reference/st_as_sf.html),
  with points as from
  [`shapefile_from_sitepoints()`](https://public-environmental-data-partners.github.io/EJAM/reference/shapefile_from_sitepoints.md),
  or a table of points with lat,lon columns that will first be converted
  here using that function, or polygons

- addedbuffermiles:

  width of optional buffering to add to the points (or edges), in miles

- blocksnearby:

  optional table of blocks with blockid, etc (from which lat,lon can be
  looked up in blockpoints dt)

- dissolved:

  If TRUE, use
  [`sf::st_union()`](https://r-spatial.github.io/sf/reference/geos_combine.html)
  to find unique blocks inside any one or more of polys

- safety_margin_ratio:

  multiplied by addedbuffermiles, how far to search for blocks nearby
  using
  [`getblocksnearby()`](https://public-environmental-data-partners.github.io/EJAM/reference/getblocksnearby.md),
  before using those found to do the intersection via sf::

- crs:

  used in
  [`sf::st_as_sf()`](https://r-spatial.github.io/sf/reference/st_as_sf.html)
  and
  [`sf::st_transform()`](https://r-spatial.github.io/sf/reference/st_transform.html)
  and
  [`shape_buffered_from_shapefile_points()`](https://public-environmental-data-partners.github.io/EJAM/reference/shape_buffered_from_shapefile_points.md),
  crs = 4269 or Geodetic CRS NAD83

- updateProgress:

  optional Shiny progress bar to update

- oldway:

  whether to use older method that works but may be slower vs
  newer/draft

## Value

Block points table for those blocks whose internal point is inside the
buffer which is just a circular buffer of specified radius if polys are
just points. This is like the output of
[`getblocksnearby()`](https://public-environmental-data-partners.github.io/EJAM/reference/getblocksnearby.md),
or
[`getblocksnearby_from_fips()`](https://public-environmental-data-partners.github.io/EJAM/reference/getblocksnearby_from_fips.md)
if return_shp=F.

The ejam_uniq_id represents which of the input sites is being referred
to, and the table will only have the ids of the sites where blocks were
found. If 10 sites were input but only sites 5 and 8 were valid and had
blocks identified, then the data.table here will only include
ejam_uniq_id values of 5 and 8.

## Details

This uses
[`getblocksnearby()`](https://public-environmental-data-partners.github.io/EJAM/reference/getblocksnearby.md)
to get a very fast rough/good estimate of which US block points are
nearby (with a safety margin - see param below), before then using sf::
to carefully identify which of those candidate blocks are actually
inside each polygon (e.g., circle) according to sf:: methods.

For circular buffers, just using
[`getblocksnearby()`](https://public-environmental-data-partners.github.io/EJAM/reference/getblocksnearby.md)
should work and not need this function.

For non-circular polygons, buffered or not, this function will provide a
way to very quickly filter down to which of the millions of US blocks
should be examined by the sf:: join / intersect, since otherwise it
takes forever for sf:: to check all US blocks.

## See also

[`getblocksnearby()`](https://public-environmental-data-partners.github.io/EJAM/reference/getblocksnearby.md)
[`getblocksnearby_from_fips()`](https://public-environmental-data-partners.github.io/EJAM/reference/getblocksnearby_from_fips.md)
[`shapefile_from_sitepoints()`](https://public-environmental-data-partners.github.io/EJAM/reference/shapefile_from_sitepoints.md)
[`shape_buffered_from_shapefile_points()`](https://public-environmental-data-partners.github.io/EJAM/reference/shape_buffered_from_shapefile_points.md)

## Examples

``` r
  # y <- get_blockpoints_in_shape()

  # x = shapefile_from_sitepoints(testpoints_n(2))
  # y = get_blockpoints_in_shape(x, 1)  # very very slow
```
