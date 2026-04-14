# identify the State each site is in, for doaggregate()

identify the State each site is in, for doaggregate()

## Usage

``` r
state_per_site_for_doaggregate(s2b, s2st)
```

## Arguments

- s2b:

  like testoutput_getblocksnearby_100pts_1miles, or output of
  getblocksnearby()

- s2st:

  like testpoints_10, like input to ejamit() or to getblocksnearby()

## Value

data.table

## Examples

``` r
# \donttest{

 # cannot quickly id ST if a site spans 2+ states
 # not this is an unexported function:
 tail(EJAM:::state_from_s2b_bysite(testoutput_getblocksnearby_100pts_1miles))

 # using the closest block can id the wrong state:
 tail(EJAM:::state_from_nearest_block_bysite(testoutput_getblocksnearby_100pts_1miles))

 # getting the true state is slow if some sites span 2+ states:
 tail(
   EJAM:::state_per_site_for_doaggregate(
     testoutput_getblocksnearby_100pts_1miles,
     testpoints_100
   ))
# }
```
