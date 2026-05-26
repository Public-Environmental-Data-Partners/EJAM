# Create localtree (a quadtree index of all US block centroids) in package cache

Create localtree (a quadtree index of all US block centroids) in package
cache

## Usage

``` r
indexblocks()
```

## Value

Returns the quadtree index invisibly. Side effect is it creates the
index in the package cache.

## Details

Note this is duplicated code in .onAttach() and also in
global_defaults\_\*.R

.onAttach() can be edited to create this when the package loads, but
then it takes time each time a developer rebuilds/installs the package
or others that load EJAM.

It also has to happen in global_defaults\_\*.R if it has not already.
