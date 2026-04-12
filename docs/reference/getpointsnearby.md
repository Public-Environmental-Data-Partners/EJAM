# Find IDs of and distances to all nearby points (e.g., schools, or EPA-regulated facilities, etc.)

Given a table of frompoints (lat lon coordinates), find IDs of and
distances to all nearby points that could represent e.g., schools,
parks, or EPA-regulated facilities with locations in Facility Registry
Services (FRS). Like
[`getblocksnearby()`](https://public-environmental-data-partners.github.io/EJAM/reference/getblocksnearby.md)
but for nearby points of any type.

## Usage

``` r
getpointsnearby(
  frompoints,
  topoints,
  radius = 3,
  maxradius = 31.07,
  avoidorphans = FALSE,
  retain_unadjusted_distance = TRUE,
  quadtree = NULL,
  quaddatatable = NULL,
  quiet = FALSE,
  updateProgress = FALSE,
  report_progress_every_n = 1000,
  ...
)
```

## Arguments

- frompoints:

  used as the sitepoints param of
  [`getblocksnearby()`](https://public-environmental-data-partners.github.io/EJAM/reference/getblocksnearby.md).
  Can be for example Census blocks (based on internal point of each
  block).

- topoints:

  table of lat lon coordinates of points that may be nearby. These could
  be schools, parks, facilities, or any other set of points.

- radius:

  passed to
  [`getpointsnearbyviaQuadTree()`](https://public-environmental-data-partners.github.io/EJAM/reference/getpointsnearbyviaQuadTree.md)

- maxradius:

  passed to
  [`getpointsnearbyviaQuadTree()`](https://public-environmental-data-partners.github.io/EJAM/reference/getpointsnearbyviaQuadTree.md)

- avoidorphans:

  passed to
  [`getpointsnearbyviaQuadTree()`](https://public-environmental-data-partners.github.io/EJAM/reference/getpointsnearbyviaQuadTree.md)

- retain_unadjusted_distance:

  passed to
  [`getpointsnearbyviaQuadTree()`](https://public-environmental-data-partners.github.io/EJAM/reference/getpointsnearbyviaQuadTree.md)

- quadtree:

  optional index of topoints

  - if not provided, created by indexpoints()

- quaddatatable:

  optional table of topoints (in format provided by internal helper
  function create_quaddata() as needed).

- quiet:

  passed to
  [`getpointsnearbyviaQuadTree()`](https://public-environmental-data-partners.github.io/EJAM/reference/getpointsnearbyviaQuadTree.md)

- updateProgress:

  progress bar object, passed to
  [`getpointsnearbyviaQuadTree()`](https://public-environmental-data-partners.github.io/EJAM/reference/getpointsnearbyviaQuadTree.md)

- report_progress_every_n:

  passed to
  [`getpointsnearbyviaQuadTree()`](https://public-environmental-data-partners.github.io/EJAM/reference/getpointsnearbyviaQuadTree.md)

- ...:

  passed to
  [`getpointsnearbyviaQuadTree()`](https://public-environmental-data-partners.github.io/EJAM/reference/getpointsnearbyviaQuadTree.md)

## Value

sites2points [data.table](https://r-datatable.com) one row per pair of
frompoint and nearby topoint, like output of
[`getpointsnearbyviaQuadTree()`](https://public-environmental-data-partners.github.io/EJAM/reference/getpointsnearbyviaQuadTree.md)

## Details

Later steps can aggregate at each frompoint to summarize

- count schools or facilities, etc., near each frompoint

- max/min distance for each frompoint, like proximity of nearest, etc.

- a proximity score for each frompoint (e.g., block) and then each
  blockgroup
