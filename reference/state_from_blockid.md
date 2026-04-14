# given vector of blockids, get state abbreviation of each unused. Not needed if you have sites2blocks table that includes a bgid column

given vector of blockids, get state abbreviation of each unused. Not
needed if you have sites2blocks table that includes a bgid column

## Usage

``` r
state_from_blockid(blockid)
```

## Arguments

- blockid:

  vector of blockid values as from EJAM in a table called blockpoints

## Value

vector of ST info like AK, CA, DE, etc.

## See also

unexported state_from_blockid_table()

## Examples

``` r
x = sample(blockpoints$blockid, 3)
EJAM:::state_from_blockid(x)[]
mapfast(blockpoints[blockid %in% x, ])

all.equal(EJAM:::state_from_blockid(x), EJAM:::state_from_blockid_table(blockpoints[blockid %in% x, ]))
```
