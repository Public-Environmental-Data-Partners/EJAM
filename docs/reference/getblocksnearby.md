# Very fast way to distances to all nearby Census blocks

Get distance from each site (e.g., facility) to each Census block
centroid within some radius

Given a set of points and a specified radius, this function quickly
finds all the US Census blocks near each point. For each point, it uses
the specified radius distance and finds the distance to every block
within the circle defined by the radius. Each block is defined by its
Census-provided internal point, by latitude and longitude.

Each point can be the location of a regulated facility or other type of
site, and the blocks are a high-resolution source of information about
where residents live.

Finding which blocks have their internal points in a circle provides a
way to quickly estimate what fraction of a blockgroup is inside the
circular buffer more accurately and more quickly than areal
apportionment of blockgroups would provide.

## Usage

``` r
getblocksnearby(
  sitepoints,
  radius = 3,
  maxradius = 31.07,
  radius_donut_lower_edge = 0,
  avoidorphans = FALSE,
  quadtree = NULL,
  quaddatatable = NULL,
  quiet = FALSE,
  parallel = FALSE,
  use_unadjusted_distance = TRUE,
  ...
)
```

## Arguments

- sitepoints:

  table in [data.table](https://r-datatable.com) format with columns
  lat, lon giving point locations of sites or facilities around which
  are circular buffers

- radius:

  in miles, defining circular buffer around a site point

- maxradius:

  miles distance (max distance to check if not even 1 block point is
  within radius)

- radius_donut_lower_edge:

  radius of lower edge of ring if analyzing ring not full circle

- avoidorphans:

  MAY BE OBSOLETE/UNUSED NOW. logical If TRUE, then where not even 1
  BLOCK internal point is within radius of a SITE, it keeps looking past
  radius, up to maxradius, to find nearest 1 BLOCK. What EJSCREEN does
  in that case is report NA, right? So, does EJAM really need to report
  stats on residents presumed to be within radius, if no block centroid
  is within radius? Best estimate might be to report indicators from
  nearest block centroid which is probably almost always the one your
  site is sitting inside of, but ideally would adjust total count to be
  a fraction of blockwt based on what is area of circular buffer as
  fraction of area of block it is apparently inside of. Setting this to
  TRUE can produce unexpected results, which will not match EJSCREEN
  numbers.

  Note that if creating a proximity score, by contrast, you instead want
  to find nearest 1 SITE if none within radius of this BLOCK.

- quadtree:

  (a pointer to the large quadtree object) created using indexblocks()
  which uses the SearchTree package. Takes about 2-5 seconds to create
  this each time it is needed. It can be automatically created when the
  package is attached via the .onAttach() function

- quaddatatable:

  Not currently used

- quiet:

  Optional. set to TRUE to avoid message about using
  getblock_diagnostics(), which is relevant only if a user saved the
  output of this function.

- parallel:

  Not implemented

- use_unadjusted_distance:

  logical, whether to find points within unadjusted distance

- ...:

  passed to
  [`getblocksnearbyviaQuadTree()`](https://public-environmental-data-partners.github.io/EJAM/reference/getblocksnearbyviaQuadTree.md)
  or other such functions

## Value

table in [data.table](https://r-datatable.com) format like
testoutput_getblocksnearby_10pts_1miles, with columns named
"ejam_uniq_id", "blockid", "distance", etc. The ejam_uniq_id represents
which of the input sites is being referred to, and the table will only
have the ids of the sites where blocks were found. If 10 sites were
input but only sites 5 and 8 were valid and had blocks identified, then
the data.table here will only include ejam_uniq_id values of 5 and 8.
This is like the output of
[`get_blockpoints_in_shape()`](https://public-environmental-data-partners.github.io/EJAM/reference/get_blockpoints_in_shape.md),
or
[`getblocksnearby_from_fips()`](https://public-environmental-data-partners.github.io/EJAM/reference/getblocksnearby_from_fips.md)
if return_shp=F.

## Details

See
[`ejamit()`](https://public-environmental-data-partners.github.io/EJAM/reference/ejamit.md)
for examples.

getblocksnearby() is a wrapper redirecting to the right version, like
[`getblocksnearbyviaQuadTree()`](https://public-environmental-data-partners.github.io/EJAM/reference/getblocksnearbyviaQuadTree.md)
Census block "internal points" (defined by Census Bureau) are actually
what it looks for, and they are like centroids. The blocks are
pre-indexed for the whole USA, via the data object quadtree aka
localtree

## See also

[`ejamit()`](https://public-environmental-data-partners.github.io/EJAM/reference/ejamit.md)
[`getblocksnearby_from_fips()`](https://public-environmental-data-partners.github.io/EJAM/reference/getblocksnearby_from_fips.md)
[`get_blockpoints_in_shape()`](https://public-environmental-data-partners.github.io/EJAM/reference/get_blockpoints_in_shape.md)
