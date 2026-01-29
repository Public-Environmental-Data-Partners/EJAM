# Get State each site is entirely within, quickly, from table of blocks nearby/at/in each site (via blockid, by ejam_uniq_id)

Find the 2-character State abbreviation (ST), but only for sites
entirely in 1 state.

## Usage

``` r
state_from_s2b_bysite(sites2blocks)
```

## Arguments

- sites2blocks:

  data.table or data.frame, like
  [testoutput_getblocksnearby_10pts_1miles](https://ejanalysis.github.io/EJAM/reference/testoutput_getblocksnearby_10pts_1miles.md),
  from
  [`getblocksnearby()`](https://ejanalysis.github.io/EJAM/reference/getblocksnearby.md)
  that has columns ejam_uniq_id and blockid and distance

## Value

table in [data.table](https://r-datatable.com) format with columns
ejam_uniq_id, ST

## Details

This function is for when you need to quickly find out the state each
site is in, to be able to report state percentiles, This can identify
the State each site is located in, based on the states of the nearby
blocks (and parent blockgroups). In many analyses, all the sites will be
single-state sites, and this function will be sufficient.

- This function only identifies the State for each site that is entirely
  in 1 state (whose included block internal points are all in the same
  state).

- For each multistate site, this returns NA as the ST.

  - For a multistate site defined by radius and latlon (a circular
    buffer), need lat/lon of site and that is slower, and handled
    elsewhere. (And for the rare edge case where you did not save the
    lat,lon of sites you analyzed, you would need to approximate those
    from the lat/lon of the blocks and their distances, via
    [`latlon_from_s2b()`](https://ejanalysis.github.io/EJAM/reference/latlon_from_s2b.md),
    separately).

  - For a multistate site defined by a polygon, it is not entirely clear
    which state to pick for purposes of reporting state percentiles, but
    that is handled elsewhere.

Note this is an unexported function.

Note that the two functions
[`state_from_blockid_table()`](https://ejanalysis.github.io/EJAM/reference/state_from_blockid_table.md)
and `state_from_s2b_bysite()` differ – one gets the state info for each
unique SITE, and the other gets the state abbreviation of each unique
BLOCK:

    xx = state_from_s2b_bysite(testoutput_getblocksnearby_10pts_1miles)[]
    NROW(xx)
    # 10
    length(unique(testoutput_getblocksnearby_10pts_1miles$ejam_uniq_id))
    # 10

    length(EJAM:::state_from_blockid_table(testoutput_getblocksnearby_10pts_1miles))
    # 1914
    NROW(testoutput_getblocksnearby_10pts_1miles)
    # 1914

## See also

[`state_from_blockid_table()`](https://ejanalysis.github.io/EJAM/reference/state_from_blockid_table.md)
[`state_per_site_for_doaggregate()`](https://ejanalysis.github.io/EJAM/reference/state_per_site_for_doaggregate.md)

## Examples

``` r
# \donttest{
# unexported function, so use load_all() or :::
table(EJAM:::state_from_blockid_table(testoutput_getblocksnearby_10pts_1miles))
EJAM:::state_from_s2b_bysite(testoutput_getblocksnearby_10pts_1miles)[]
 pts = testpoints_10
  x = getblocksnearby(pts, radius = 30)
  y = EJAM:::state_from_s2b_bysite(x)
  table(y$in_how_many_states)
  y

  fname = testdata("testpoints_100_sites_", quiet = T)
  x = EJAM:::state_from_s2b_bysite(
    getblocksnearby( latlon_from_anything(fname), quadtree = localtree))
  y = read_csv_or_xl(fname)
  x$ST == y$FacState
  # }
  EJAM:::state_from_s2b_bysite(testoutput_getblocksnearby_10pts_1miles)
```
