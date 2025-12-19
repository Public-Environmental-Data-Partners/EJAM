# Create localtree (a quadtree index of all US block centroids) in global environment

Create localtree (a quadtree index of all US block centroids) in global
environment

## Usage

``` r
indexblocks()
```

## Value

Returns TRUE when done. Side effect is it creates the index in memory.

## Details

Note this is duplicated code in .onAttach() and also in
global_defaults\_\*.R

.onAttach() can be edited to create this when the package loads, but
then it takes time each time a developer rebuilds/installs the package
or others that load EJAM.

It also has to happen in global_defaults\_\*.R if it has not already.
