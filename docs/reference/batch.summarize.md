# Calculate more summary stats across all sites and all people

Calculate more summary stats across all sites and all people

## Usage

``` r
batch.summarize(
  ejamitout,
  sitestats,
  popstats,
  overall,
  wtscolname = "pop",
  probs = c(0, 0.25, 0.5, 0.75, 0.8, 0.9, 0.95, 0.99, 1),
  thresholds = list(90),
  threshnames = list(names(which(sapply(sitestats, class) != "character"))),
  threshgroups = list("variables"),
  na.rm = TRUE,
  rowfun.picked = "all",
  colfun.picked = "all",
  quiet = FALSE,
  testing = FALSE
)
```

## Arguments

- ejamitout:

  Not typically used. If it is provided, then parameters sitestats,
  popstats, and overall are ignored. A list that is the output of
  [`ejamit()`](https://public-environmental-data-partners.github.io/EJAM/reference/ejamit.md)
  – the list of tables including results_bysite, results_bybg_people,
  results_overall. ejamit() actually already does batch.summarize(), but
  this param might be useful interactively if you want to redo just the
  batch.summarize() step with new params like thresholds or probs.

- sitestats:

  A data.frame or data.table like ejamit()\$results_bysite, with one row
  per site and one column per indicator. Ignored if ejamitout is
  provided.

- popstats:

  A data.frame or [data.table](https://r-datatable.com) like
  ejamit()\$results_bybg_people, with one row per blockgroup at least
  partly in/at one or more of the sites, and one column per indicator.
  It provides blockgroup indicators, including total counts even for the
  blockgroups that are not entirely in/at a site. This is used to get
  stats on the distribution of each indicator across all unique
  individuals (regardless of how many sites a resident is at). Ignored
  if ejamitout is provided.

- overall:

  A data.frame or [data.table](https://r-datatable.com) like
  ejamit()\$results_bysite, with one column per indicator, and just one
  data row that has the overall average, sum, or other summary stat for
  the indicator across all sites. Ignored if ejamitout is provided.

- wtscolname:

  Name of the column that contains the relevant weights to be used
  (e.g., "pop")

- probs:

  Vector of numeric values, fractions, to use as probabilities used in
  finding quantiles.

- thresholds:

  list of vectors each with 1+ thresholds (cutpoints) used to count find
  sites where 1+ of given set of indicators are at/above the threshold &
  how many of the indicators are. If an element of the list is a single
  number, that is used for the whole group (all the threshnames in that
  nth list element). Otherwise/in general, each vector is recycled over
  the threshnames in corresponding list element, so each threshname can
  have its own threshold like some field-specific benchmark, or they can
  all use the same threshold like 50.

- threshnames:

  list of vectors of character colnames defining fields in x that get
  compared to threshold, or to thresholds

- threshgroups:

  of 1+ character strings naming the elements of threshnames list, such
  as "EJ US pctiles"

- na.rm:

  Logical TRUE by default, specifying if na.rm should be used for sum(),
  mean(), and other functions.

- rowfun.picked:

  logical vector specifying which of the pre-defined functions (like
  at/above threshold) are needed and will be applied

- colfun.picked:

  logical vector specifying which of the pre-defined functions (like
  colSums) are needed and will be applied

- quiet:

  optional logical, set to TRUE to stop printing results to console in
  RStudio.

- testing:

  optional, default is FALSE. prints some debugging info if TRUE.

## Value

output is a list with two named elements, rows and cols, where each is a
matrix of summary stats.

cols: Each element in a summary col summarizes 1 row (site) across all
the RELEVANT cols of batch data (e.g., all US Summary Index
percentiles). This type of info is also saved in a tab of the output of
[`ejam2excel()`](https://public-environmental-data-partners.github.io/EJAM/reference/ejam2excel.md)

rows: Each element in a summary row summarizes 1 column (field) across
all the rows of batch data. A subset of this is \$keyindicators

keystats: Key subset of the summary stats (for all indicators), for
convenience. See
[`ejam2table_tall()`](https://public-environmental-data-partners.github.io/EJAM/reference/ejam2table_tall.md)
to view this.

keyindicators: Key subset of the indicators from \$row results (for
stats characterizing the distribution of each across people or sites,
like avg, mean, and percentiles), for convenience

flagged_areas: table of percentages of people or sites, here (people at
analyzed sites) and nationwide, who reside in blockgroups that overlap
at all with key types of areas like [nonattainment for air
standards](https://www.epa.gov/criteria-air-pollutants/process-determine-whether-areas-meet-naaqs-designations-process),
and who have at least one school / hospital / church in their
blockgroup, and with no broadband, and with no health insurance. This
can be viewed using
[`ejam2areafeatures()`](https://public-environmental-data-partners.github.io/EJAM/reference/ejam2areafeatures.md)

In the flagged_areas table, summary stats mean the following:

- The "flag" or "yesno" indicators here are population weighted sums, so
  they show how many people from the analysis live in blockgroups that
  overlap with the given special type of area, such as non-attainment
  areas under the Clean Air Act.

- The "number" indicators are counts for each site in the
  `ejamit()$results_overall` table, but here are summarized as what
  percent of residents overall in the analysis have AT LEAST ONE OR MORE
  of that type of site in the blockgroup they live in.

- The "pctno" or % indicators are summarized as what % of the residents
  analyzed lack the critical service.

## Details

This is the function that takes the
[`doaggregate()`](https://public-environmental-data-partners.github.io/EJAM/reference/doaggregate.md)
results and calculates even more summary statistics, notably to
characterize the distribution of indicator values across people and
across sites, as percentile of analyzed people and percentile of
analyzed sites, etc.

It can be expanded to provide other summary stats by adding those other
formulas to this code.

Note it can provide population-weighted summary stats only for the
indicators found in popstats, which is fewer than those in sitestats,
since
[`doaggregate()`](https://public-environmental-data-partners.github.io/EJAM/reference/doaggregate.md)
or
[`ejamit()`](https://public-environmental-data-partners.github.io/EJAM/reference/ejamit.md)
did not provide various extra indicators in the very large
results_bybg_people table. The parameter sitestats but not popstats has
the ratios and pctiles (and US/State averages) of indicators, plus
"bgid" "bgwt" and "valid" "invalid_msg" So this function cannot show,
e.g., the median analyzed person's ratio of local score to US average,
and cannot say the Demog. Index US percentile was at least X% of people
nationwide among the top 10% of people analyzed.

## See also

[`ejam2areafeatures()`](https://public-environmental-data-partners.github.io/EJAM/reference/ejam2areafeatures.md)
[`ejamit()`](https://public-environmental-data-partners.github.io/EJAM/reference/ejamit.md)
