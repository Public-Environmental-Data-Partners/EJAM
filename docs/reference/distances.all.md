# Find all distances between two sets of points (based on lat/lon) USED ONLY FOR distance_near_eachother()

Find all distances between two sets of points (based on lat/lon) USED
ONLY FOR distance_near_eachother()

## Usage

``` r
distances.all(
  frompoints,
  topoints,
  units = "miles",
  return.crosstab = FALSE,
  return.rownums = TRUE,
  return.latlons = TRUE,
  as.df = TRUE
)
```

## Arguments

- frompoints:

  A matrix or data.frame with two cols, 'lat' and 'lon' with datum=WGS84
  assumed.

- topoints:

  A matrix or data.frame with two cols, 'lat' and 'lon' with datum=WGS84
  assumed.

- units:

  A string that is 'miles' by default, or 'km' for kilometers,
  specifying units for distances returned.

- return.crosstab:

  Logical value, FALSE by default. If TRUE, value returned is a matrix
  of the distances, with a row per frompoint and col per topoint.

- return.rownums:

  Logical value, TRUE by default. If TRUE, value returned also includes
  two extra columns: a col of index numbers starting at 1 specifying the
  frompoint and a similar col specifying the topoint. If crosstab=TRUE,
  ignores return.rownums and return.latlons

- return.latlons:

  Logical value, TRUE by default. If TRUE, value returned also includes
  four extra columns, showing fromlat, fromlon, tolat, tolon. If
  crosstab=TRUE, ignores return.rownums and return.latlons

- as.df:

  Logical, default is TRUE, in which case returns a data.frame (unless
  vector), otherwise a matrix (unless vector).

## Value

By default, returns a dataframe that has 3 columns: fromrow, torow,
distance (where fromrow or torow is the row number of the corresponding
input, starting at 1). If return.crosstab=FALSE, which is default, and
return.rownums and/or return.latlons is TRUE, returns a row per from-to
pair, and columns depending on parameters, sorted first cycling through
all topoints for first frompoint, and so on. If return.crosstab=FALSE
and return.rownums and return.latlons are FALSE, returns a vector of
distances in same order as rows described above. If
return.crosstab=TRUE, returns a matrix of distances, with one row per
frompoint and one column per topoint.

## Details

Returns all the distances from one set of geographic points to another
set of points. Can return a matrix of distances (m x n points) or vector
or data.frame with one row per pair. Lets you specify units and whether
you need lat/lon etc, but essentially just a wrapper for the
[sf](https://r-spatial.github.io/sf/) package for the
[sf::st_distance](https://r-spatial.github.io/sf/reference/geos_measures.html)
and
[sf::st_as_sf](https://r-spatial.github.io/sf/reference/st_as_sf.html)
functions.

      *** Probably slower than it needs to be partly by using data.frame
       instead of matrix class? Maybe 10-20 percent faster if as.df=FALSE than if TRUE
      Just using distances.all is reasonably fast?
      When it was still using sp and not sf package, it was
        (30-40 seconds for
        100 million distances, but slow working with results so large),
     Sys.time(); x=distances.all(testpoints_n(1e5), testpoints_n(1000),
       return.crosstab=TRUE); Sys.time()

           IF NO PROCESSING OTHER THAN CROSSTAB
     Sys.time(); x=distances.all(testpoints_n(1e6), testpoints_n(100),
        return.crosstab=TRUE); Sys.time()

           (1m x 100, or 100k x 1000)
     Sys.time(); x=distances.all(testpoints_n(1e6), testpoints_n(300),
       return.crosstab=TRUE); Sys.time()
        seconds for 300 million pairs.
      plus_____ seconds or so for x[x>100] <- Inf
           # so 11m blocks to 1k points could take >xxx minutes!
           (you would want to more quickly remove the ones outside some radius)

               About xxx seconds per site for 11m blocks?

        Sys.time(); x=distances.all(testpoints_n(1e5), testpoints_n(1000),
          units='miles',return.rownums=TRUE); Sys.time()
      xxx SECONDS IF DATA.FRAME ETC. DONE
          TO FORMAT RESULTS AND GET ROWNUMS
       Sys.time(); x=distances.all(testpoints_n(1e5), testpoints_n(1000),
         units='miles',return.rownums=TRUE)$d; Sys.time()
       xxx SECONDS IF DATA.FRAME ETC. DONE
          TO FORMAT RESULTS AND GET ROWNUMS IN distances.all
        

## See also

[`latlon_infer()`](https://ejanalysis.github.io/EJAM/reference/latlon_infer.md)
get.distances() which allows you to specify a search radius and get
distances only within that radius which can be faster,
get.distances.prepaired() for finding distances when data are already
formatted as pairs of points, get.nearest() which finds the distance to
the single nearest point within a specified search radius instead of all
topoints, and proxistat or proxistat2 which will which create a
proximity score for each spatial unit based on distances to nearby
points.
