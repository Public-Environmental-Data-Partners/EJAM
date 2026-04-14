# Fast way to find nearby points - For each frompoint, it finds distances to all nearby topoints (within radius)

Given a set of frompoints (e.g., facilities or blocks) and a specified
radius in miles, this function quickly finds all the topoints (e.g.,
blocks or facilities) near each point. If from and to are facilities and
census blocks, respectively, this can be used to aggregate over
blockgroups near a facility for an EJAM analysis. But if it is used to
define from as blocks and to as facilities, it finds all facilities near
each block, which is how proxistat works to create proximity indicators.

## Usage

``` r
getpointsnearbyviaQuadTree(
  frompoints,
  radius = 3,
  maxradius = 31.07,
  avoidorphans = FALSE,
  min_distance = 100/1760,
  retain_unadjusted_distance = TRUE,
  report_progress_every_n = 500,
  quiet = FALSE,
  quadtree,
  quaddatatable,
  updateProgress = NULL
)
```

## Arguments

- frompoints:

  data.table with columns lat, lon giving point locations of sites or
  facilities or blocks around which are circular buffers defined by
  radius.

  - pointid will be the indexed topoints id.

  - ejam_uniq_id is the frompoints id

- radius:

  in miles, defining circular buffer around a frompoint

- maxradius:

  miles distance (max distance to check if not even 1 topoint is within
  radius)

- avoidorphans:

  logical If TRUE, then where not even 1 topoint is within radius of a
  frompoint, it keeps looking past radius, up to maxradius, to find
  nearest 1 topoint

  Note that if creating a proximity score, by contrast, you instead want
  to find nearest 1 SITE if none within radius of this BLOCK.

- min_distance:

  miles minimum distance to use for cases where from and to points are
  identical or almost the same location.

- retain_unadjusted_distance:

  set to FALSE to drop it and save memory/storage. If TRUE, the
  distance_unadjusted column will save the actual distance of site to
  the topoint, which might be zero. adjusted distance uses a lower
  limit, min_distance

- report_progress_every_n:

  Reports progress to console after every n points

- quiet:

  Optional.

- quadtree:

  (actually a pointer to a large quadtree object) created using
  [`indexpoints()`](https://public-environmental-data-partners.github.io/EJAM/reference/indexpoints.md)
  which uses the SearchTree package. Helps find the "topoints"

- quaddatatable:

  table in [data.table](https://r-datatable.com) format like
  [quaddata](https://public-environmental-data-partners.github.io/EJAM/reference/quaddata.md)
  passed to function

  - the data.table used to create quadtree, such as
    [blockpoints](https://public-environmental-data-partners.github.io/EJAM/reference/blockpoints.md)
    or
    [frs](https://public-environmental-data-partners.github.io/EJAM/reference/frs.md).
    Helps find the "topoints"

- updateProgress, :

  optional function to update Shiny progress bar

## Value

see details

## Details

The explanation below is assuming frompoints are "sites" such as
facilities and topoints are Census blocks, but they can be reversed as
long as the index passed is an index of the topoints.

For each point, this function uses the specified search radius and finds
the distance to every topoint within the circle defined by the radius.
Each topoint is defined by its latitude and longitude.

Results are the sites2points table that would be used by doaggregate(),
with distance in miles as one output column of table in
[data.table](https://r-datatable.com) format

## See also

[`getpointsnearby()`](https://public-environmental-data-partners.github.io/EJAM/reference/getpointsnearby.md)
