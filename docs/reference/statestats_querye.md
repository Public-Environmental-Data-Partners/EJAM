# statestats_querye - convenient way to see mean, pctiles of ENVIRONMENTAL indicators from lookup table

statestats_querye - convenient way to see mean, pctiles of ENVIRONMENTAL
indicators from lookup table

## Usage

``` r
statestats_querye(
  ST = sort(unique(EJAM::statestats$REGION)),
  varnames = EJAM::names_e,
  PCTILES = NULL,
  dig = 4
)
```

## Arguments

- ST:

  vector of state abbreviations, or USA

- varnames:

  names of columns in lookup table, like "proximity.rmp"

- PCTILES:

  vector of percentiles 0-100 and/or "mean"

- dig:

  digits to round to

## See also

[`calc_avg_columns()`](https://public-environmental-data-partners.github.io/EJAM/reference/calc_avg_columns.md)

## Examples

``` r
# \donttest{

usastats_querye()
#  data.frame where names_e are the names(),
#  means plus other percentiles, and there are other cols REGION PCTILE

avg.in.us                # This is a data.frame, 1 row, where colnames are indicators
avg.in.us[names_e]          # subset is a data.frame!
unlist(avg.in.us[names_e])  # to make it a vector

usastats_means()        # This is a matrix, with 1 col, and indicator names are rownames
usastats_means(names_e)     # subset is a matrix        and indicator names are rownames
usastats_means()[names_e, ] # subset is a named vector  and indicator names are  names

usastats_means()
statestats_query()

statestats_query()[,names_d]
statestats_query(varnames = names_d)

statestats_query()[,names_e]
statestats_query(varnames = names_e)

statestats_query(varnames = names_d_subgroups)

## in USA overall, see mean and key percentiles
# for all demog and envt indicators
usastats_query() # or statestats_query('us')
# can say us or US or USA or usa etc.
usastats_query(PCTILES = 'mean')
usastats_means() # same but nicer looking format in console
usastats_means(dig=4)

# long list of variables:
x = intersect(EJAM::names_all_r,  names(EJAM::usastats))
x=setdiff(x,"REGION")
usastats_means(x)

usastats[!(usastats$PCTILE < 50), c("PCTILE", names_d)]
usastats[!(usastats$PCTILE < 50), c("PCTILE", names_e)]

## in 1 state, see mean and key percentiles for all demog and envt indicators
statestats_query('MD')

## in 1 state, see mean and key percentiles for just demog indicators
statestats_queryd('MD')

## 1 indicator in 1 state, see a few key percentiles and mean
statestats_query('MD','proximity.tsdf')

## mean of 1 indicator for each state
statestats_query(varnames = 'proximity.tsdf')

## using full blockgroup dataset, not lookup tables of percentiles,
blockgroupstats[, lapply(.SD, function(x) mean(x, na.rm=T)),
   .SDcols= c(names_d, names_e)]

##   see all total counts (not just US means),
##   residential populations including subgroups,
##   but not environmental indicators.
t(blockgroupstats[, lapply(.SD, function(x) mean(x, na.rm=T)),
    .SDcols= c(names_e, names_d)])

# }
```
