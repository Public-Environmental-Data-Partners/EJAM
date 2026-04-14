# Find all EPA-regulated facilities nearby each specified point and distances

Given a table of frompoints (lat lon coordinates), find IDs of and
distances to all nearby points that represent EPA-regulated facilities
with locations in Facility Registry Services (FRS). Like
[`getblocksnearby()`](https://public-environmental-data-partners.github.io/EJAM/reference/getblocksnearby.md)
but for regulated facilities in US EPA FRS

## Usage

``` r
getfrsnearby(
  frompoints,
  radius = 3,
  maxradius = 31.07,
  avoidorphans = FALSE,
  quadtree = NULL,
  quaddatatable = NULL,
  quiet = FALSE,
  ...
)
```

## Arguments

- frompoints:

  used as the sitepoints param of
  [`getblocksnearby()`](https://public-environmental-data-partners.github.io/EJAM/reference/getblocksnearby.md)

- radius:

  passed to
  [`getblocksnearby()`](https://public-environmental-data-partners.github.io/EJAM/reference/getblocksnearby.md)

- maxradius:

  passed to
  [`getblocksnearby()`](https://public-environmental-data-partners.github.io/EJAM/reference/getblocksnearby.md)

- avoidorphans:

  passed to
  [`getblocksnearby()`](https://public-environmental-data-partners.github.io/EJAM/reference/getblocksnearby.md)

- quadtree:

  index that should be created by indexpoints

- quaddatatable:

  optional table of topoints (in format provided by internal helper
  function create_quaddata() as needed).

- quiet:

  passed to
  [`getblocksnearby()`](https://public-environmental-data-partners.github.io/EJAM/reference/getblocksnearby.md)

- ...:

  passed to
  [`getblocksnearby()`](https://public-environmental-data-partners.github.io/EJAM/reference/getblocksnearby.md)

## Value

sites2points [data.table](https://r-datatable.com) one row per pair of
frompoint and nearby frs point, like output of
[`getblocksnearby()`](https://public-environmental-data-partners.github.io/EJAM/reference/getblocksnearby.md)

## Details

Later steps can aggregate at each frompoint to summarize

- count facilities near each frompoint

- max/min distance for each frompoint, like proximity of nearest, etc.

- a proximity score for each block and then each blockgroup
