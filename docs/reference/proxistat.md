# DRAFT - Create a custom proximity score for every blockgroup, representing count and proximity of specified points Indicator of proximity of residents in each US blockgroup to a custom set of facilities or sites

DRAFT - Create a custom proximity score for every blockgroup,
representing count and proximity of specified points Indicator of
proximity of residents in each US blockgroup to a custom set of
facilities or sites

## Usage

``` r
proxistat(
  topoints,
  bpoints = NULL,
  blocks_per_batch = 1000,
  countradius = 3.106856,
  maxradius = 621.3712,
  avoidorphans = TRUE,
  quadtree = NULL,
  quaddatatable = NULL
)
```

## Arguments

- topoints:

  Representing nearby amenities or hazards counted by the proximity
  scores – such as Superfund NPL sites used for a NPL proximity score –
  a [data.table](https://r-datatable.com) of lat lon, all points
  representing some amenity or hazard that the proximity score indicates
  proximity to. It could be a subset of the
  [frs](https://public-environmental-data-partners.github.io/EJAM/reference/frs.md)
  table, e.g.

- bpoints:

  Representing places to be assigned proximity scores – such as
  [blockpoints](https://public-environmental-data-partners.github.io/EJAM/reference/blockpoints.md),
  the centroid/internal point of every block in the USA – a
  [data.table](https://r-datatable.com) of Census block points lat lon,
  representing where residents are, for the entire US (or at least a
  whole State, for example – it should be all blocks for which you need
  a proximity score). The score is calculated for a given block based on
  all topoints near the block, and then summarized over all blocks in a
  given blockgroup to create a score for that blockgroup.

- blocks_per_batch:

  number of blocks to process in each batch, defaults to 1000

- countradius:

  distance within in which nearby sites are counted to create proximity
  score. In miles, and default is 5 km (5000 / meters_per_mile =
  3.106856 miles) which is the EJSCREEN zone for proximity scores based
  on counts.

- maxradius:

  max distance in miles to search for nearest single facility, if none
  found within countradius. EJSCREEN seems to use 1,000 km as the max to
  search, since the lowest scores for proximity scores of RMP, TSDF, or
  NPL are ROUGHLY 0.001, (exactly 0.000747782) meaning approx. 1/1000 km
  and km_per_mile = 1.609344 = meters_per_mile / 1000 so 1000 km is 1000
  / 1.609344 = 621.3712 miles. However, the exact min value implies
  1337.288 kilometers, or 830.9523 miles?

- avoidorphans:

  (as in getblocksnearby() but may not be implemented or working yet)

- quadtree:

  Index of sites such as facilities that will be the basis for the
  proximity scores. Optional, because it can be created here on the fly
  based on pts parameter, but can pass it if already exists - an index
  of block locations, built during use of EJAM package.
  create_quaddata()

- quaddatatable:

  optional, created from pts if not passed, created by create_quaddata()
  utility, and used to create quadtree

## Value

[data.table](https://r-datatable.com) of blockgroups, with
proximityscore, bgfips, lat, lon, etc.

## Details

Tries to use getpointsnearby() for one batch of blocks at a time,
finding user-specified sites nearby those blocks (for each block, get
distance FROM a block TO any nearby user-specified SITE points). The
inverse approach compared to
[`proxistat_via_getblocks()`](https://public-environmental-data-partners.github.io/EJAM/reference/proxistat_via_getblocks.md)

A "facility" proximity score for the residents in one place is an
indicator of how far away those facilities are, and how many there are
nearby - it accounts for the number of facilities within 5 kilometers
(facility density) and the distance of each (proximity). If there are
more points nearby, and/or the points are closer to the average resident
in a blockgroup, that blockgroup gets a higher proximity score.

The formula for this proximity score is the sum of (1/d) where each d is
distance of a given site in kilometers, summed over all sites that are
within 5 km (or the single closest site if none are within 5 km), just
as in EJSCREEN proximity scores like the TSDF or RMP scores.

Any custom user-provided set of points can be turned into a proximity
score, such as locations of all industrial sites of a certain type, or
all grocery stores, or all schools. A proximity score can be created for
all blocks and blockgroups in the US (or just one State or Region). Then
the proximity scores can be analyzed in a tool like EJAM, just as the
existing pre-calculated proximity scores are analyzed to represent the
number of nearby hazardous waste treatment storage and disposal
facilities, weighted by how far away each one is, as provided in the
EJSCREEN proximity score for TSDFs.

A custom user-specified proximity score might focus on schools, for
example. The schools proximity score could be analyzed in EJAM for one
or more communities, or areas near regulated facilities, or any set of
analyzed places. That would provide statistics demonstrating which
places have more schools closer to them (or inside the areas defined by
polygons or FIPS codes, for example).

To create the proximity score, EJAM uses the same method EJSCREEN used
to create proximity scores. The specified points first get indexed by a
utility function called indexpoints() and are searched for and counted
near every block and blockgroup in the US via a function called
getpointsnearby().

## Examples

``` r
 ### see test data in test-proxistat.R

 # pts <- testpoints_1000
 # x <- proxistat(topoints = pts)
 #
 # summary(x$proximityscore)
 # # analyze.stuff   pctiles(x$proximityscore)
 #
 # plot(x = x$lon, y = x$lat)
 # tops = x$proximityscore > 500 & !is.infinite(x$proximityscore) & !is.na(x$proximityscore)
 # points(x = x$lon[tops], y = x$lat[tops], col="red")
```
