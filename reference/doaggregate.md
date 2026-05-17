# Summarize environmental and residential population indicators at each location and overall

Used by ejamit() and the shiny app to summarize blockgroups scores at
each site and overall, as a key intermediate step in the overall
analysis provided by ejamit().

## Usage

``` r
doaggregate(
  sites2blocks,
  sites2states_or_latlon = NA,
  radius = NULL,
  countcols = NULL,
  wtdmeancols = NULL,
  calculatedcols = NULL,
  calctype_maxbg = NULL,
  calctype_minbg = NULL,
  subgroups_type = "nh",
  include_ejindexes = FALSE,
  calculate_ratios = TRUE,
  extra_demog = TRUE,
  need_proximityscore = FALSE,
  infer_sitepoints = FALSE,
  called_by_ejamit = FALSE,
  updateProgress = NULL,
  silentinteractive = TRUE,
  testing = FALSE,
  showdrinkingwater = TRUE,
  showpctowned = TRUE,
  ...
)
```

## Arguments

- sites2blocks:

  table in [data.table](https://r-datatable.com) format, of distances in
  miles between all sites (facilities) and nearby Census block internal
  points, with columns ejam_uniq_id, blockid, distance, blockwt, bgid,
  and sometimes others, created by functions that find blocks in or near
  specified sites, such as these examples:

      s2b_latlon <- getblocksnearby(testpoints_10, radius=1) # same as [testoutput_getblocksnearby_10pts_1miles]
      s2b_fips   <- getblocksnearby_from_fips(testinput_fips_counties)
      s2b_shp    <- get_blockpoints_in_shape(testshapes_2)$pts # notice the $pts here

- sites2states_or_latlon:

  data.table or just data.frame, with columns ejam_uniq_id (each unique
  one in sites2blocks) and ST (2-character State abbreviation) or lat
  and lon

- radius:

  Optional radius in miles to limit analysis to. By default this
  function uses all the distances that were provided in the output of
  getblocksnearby(), and reports radius estimated as rounded max of
  distance values in inputs to doaggregate. But there may be cases where
  you want to run getblocksnearby() once for 10 miles, say, on a very
  long list of sites (1,000 or more, say), and then get summary results
  for 1, 3, 5, and 10 miles without having to redo the getblocksnearby()
  part for each radius. This lets you just run getblocksnearby() once
  for the largest radius, and then query those results to get
  doaggregate() to summarize at any distance that is less than or equal
  to the original radius analyzed by getblocksnearby().

- countcols:

  character vector of names of variables to aggregate within a buffer
  using a sum of counts, like, for example, the number of people for
  whom a poverty ratio is known, the count of which is the exact
  denominator needed to correctly calculate percent low income.

- wtdmeancols:

  character vector of names of variables to aggregate within a buffer
  using a population weighted mean or other type of weighted mean.

- calculatedcols:

  character vector of names of variables to aggregate within a buffer
  using formulas that have to be specified. currently calculatedcols is
  not used at all.

- calctype_maxbg:

  character vector of names of variables to aggregate within a buffer
  using max() of all blockgroup-level values.

- calctype_minbg:

  character vector of names of variables to aggregate within a buffer
  using min() of all blockgroup-level values.

- subgroups_type:

  Optional (uses default). Set this to "nh" for non-hispanic race
  subgroups as in Non-Hispanic White Alone, nhwa and others in
  names_d_subgroups_nh; "alone" for EJSCREEN v2.2 style race subgroups
  as in White Alone, wa and others in names_d_subgroups_alone; "both"
  for both versions. Possibly another option is "original" or "default"
  but work in progress.

- include_ejindexes:

  whether to calculate Summary Indexes and return that information

- calculate_ratios:

  whether to calculate and return ratio of each indicator to its US and
  State overall mean

- extra_demog:

  if should include extra indicators from EJSCREEN report, on language,
  more age groups, sex, percent with disability, poverty, etc.

- need_proximityscore:

  whether to calculate proximity scores (may not be implemented yet)

- infer_sitepoints:

  set to TRUE to try to infer the lat,lon of each site around which the
  blocks in sites2blocks were found. lat,lon of each site will be
  approximated as average of nearby blocks, although a more accurate
  slower way would be to use reported distance of each of 3 of the
  furthest block points and triangulate

- called_by_ejamit:

  Set to TRUE by ejamit() to suppress some outputs even if
  ejamit(silentinteractive = FALSE)

- updateProgress:

  progress bar function used for shiny app

- silentinteractive:

  Set to TRUE to see results in RStudio console. Set to FALSE to prevent
  long output showing in console in RStudio when in interactive mode

- testing:

  used while testing this function

- showdrinkingwater:

  T/F whether to include drinking water indicator values or display as
  NA. Defaults to TRUE.

- showpctowned:

  T/f whether to include percent owner-occupied units indicator values
  or display as NA. Defaults to TRUE.

- ...:

  more to pass to another function (may not be implemented yet)

## Value

list with named elements:

- **`results_overall`** one row table in
  [data.table](https://r-datatable.com) format, like results_bysite, but
  just one row with aggregated results for all unique residents.

- **`results_bysite`** results for individual sites (buffers) - a table
  in [data.table](https://r-datatable.com) format, of results, one row
  per ejam_uniq_id, one column per indicator

- **results_bybg_people** results for each blockgroup, to allow for
  showing the distribution of each indicator across everyone within each
  residential population group. table in
  [data.table](https://r-datatable.com) format.

- **longnames** descriptive long names for the indicators in the above
  outputs

- **count_of_blocks_near_multiple_sites** additional detail

Also see outputs of
[`ejamit()`](https://public-environmental-data-partners.github.io/EJAM/reference/ejamit.md)
which are similar but provide additional info.

## Details

[`getblocksnearby()`](https://public-environmental-data-partners.github.io/EJAM/reference/getblocksnearby.md)
(or related functions for fips or shapefiles) and `doaggregate()` are
the two key functions that run
[`ejamit()`](https://public-environmental-data-partners.github.io/EJAM/reference/ejamit.md).

`doaggregate()` takes a set of sites like facilities and the set of
blocks that are near each, combines those with indicator scores for
blockgroups, and aggregates the numbers within each place and across all
overall.

Also see
[`getblocksnearbyviaQuadTree()`](https://public-environmental-data-partners.github.io/EJAM/reference/getblocksnearbyviaQuadTree.md)

`doaggregate()` is the code run after
[`getblocksnearby()`](https://public-environmental-data-partners.github.io/EJAM/reference/getblocksnearby.md)
(or a related function for polygons or FIPS Census units) has identified
which blocks are nearby.

`doaggregate()` aggregates the blockgroup scores to create a summary of
each indicator, as a raw score and US percentile and State percentile,
in each buffer (i.e., near each facility):

- **SUMS OF COUNTS**: for population count, or number of households or
  Hispanics, etc.

- **POPULATION-WEIGHTED MEANS**: for Environmental indicators, but also
  any percentage indicator for which the universe (denominator) is
  population count (rather than households, persons age 25up, etc.)

  ***Summary Indexes**:* The pop wtd mean of Summary Index raw scores.

- **CALCULATED BY FORMULA**: Buffer or overall score calculated as
  weighted mean of percentages, where the weights are the correct
  denominator like count of those for whom the poverty ratio is known.

- **LOOKED UP**: Aggregated scores are converted into percentile terms
  via lookup tables (US or State version).

This function requires the following datasets:

- [blockwts](https://public-environmental-data-partners.github.io/EJAM/reference/blockwts.md):
  table in [data.table](https://r-datatable.com) format with these
  columns: blockid , bgid, blockwt

- [quaddata](https://public-environmental-data-partners.github.io/EJAM/reference/quaddata.md)
  table in [data.table](https://r-datatable.com) format used to create
  localtree, a quad tree index of block points (and localtree that is
  created when package is loaded)

- [blockgroupstats](https://public-environmental-data-partners.github.io/EJAM/reference/blockgroupstats.md) -
  A table in [data.table](https://r-datatable.com) format (such as
  EJSCREEN residential population and environmental data by blockgroup)

## **Identification of nearby residents – methodology:**

EJAM uses the same approach as EJSCREEN does to identify the count and
residential population of nearby residents, so EJSCREEN technical
documentation should be consulted on the approach, at [EJSCREEN
Technical
Info](http://htmlpreview.github.io/?https://github.com/ejanalysis/EJAM/blob/development/data-raw/EJSCREEN_archived_pages/technical-information-and-data-downloads.md)
or [as
archived](https://web.archive.org/web/20250118072723/https://www.epa.gov/ejscreen/technical-information-and-data-downloads).
EJAM implements that approach using faster code and data formats, but it
still uses the same high-resolution approach as described in EJSCREEN
documentation and summarized below.

The identification of nearby residents is currently done in a way that
includes all 2020 Census blocks whose "internal point" (a lat/lon
provided by the Census Bureau) is within the specified distance of the
facility point. This is taken from the EJSCREEN block weights file, but
can also be independently calculated.

The summary or aggregation or "rollup" within the buffer is done by
calculating the population-weighted average blockgroup score among all
the people residing in the buffer. The weighting is by population count
for variables that are fractions of population, but other denominators
and weights (e.g., households count) are used as appropriate, as
explained in EJSCREEN technical documentation on the formulas, and
replicated by formulas used in EJAM functions such as doaggregate().

Since the blockgroup population counts are from American Community
Survey (ACS) estimates, but the block population counts are from a
decennial census, the totals for a blockgroup differ. The amount each
partial blockgroup contributes to the buffer's overall score is based on
the estimated number of residents from that blockgroup who are in the
buffer. This is based on the fraction of the blockgroup population that
is estimated to be in the buffer, and that fraction is calculated as the
fraction of the blockgroup's decennial census block population that is
in the census blocks inside the buffer.

A given block is considered entirely inside or entirely outside the
buffer, and those are used to more accurately estimate what fraction of
a given blockgroup's population is inside the buffer. This is more
accurate and faster than areal apportionment of blockgroups. Census
blocks are generally so small relative to typical buffers that this is
very accurate - it is least accurate if a very small buffer distance is
specified in an extremely low density rural area where a block can be
geographically large. Although it is rarely if ever a significant issue
(for reasonable, useful buffer sizes), an even more accurate approach in
those cases might be either areal apportionment of blocks, which is very
slow and assumes residents are evenly spread out across the full block's
area, or else an approach that uses higher resolution estimates of
residential locations than even the Decennial census blocks can provide,
such as a dasymetric map approach.

## See also

[ejamit](https://public-environmental-data-partners.github.io/EJAM/reference/ejamit.md)
[`getblocksnearby()`](https://public-environmental-data-partners.github.io/EJAM/reference/getblocksnearby.md)

## Examples

``` r
EJAM:::structure.of.output.list(testoutput_doaggregate_10pts_1miles)

x = testoutput_doaggregate_10pts_1miles
names(x)
ejam2barplot(x)
```
