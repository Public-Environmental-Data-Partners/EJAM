# Get maximum of each column of data.frame

Get maximum of each column of data.frame

## Usage

``` r
colMaxs2(df, na.rm = TRUE)
```

## Arguments

- df:

  data.frame or matrix. Can include numbers stored as character or as
  factors.

- na.rm:

  default is TRUE. not tested for FALSE

## Value

named vector of numbers

## See also

[`colMins2()`](https://public-environmental-data-partners.github.io/EJAM/reference/colMins2.md)

## Examples

``` r
df <- rbind(NA, data.frame(
  n1 = c(0, 0:8), n2 = c(0.1 + (0:9)), n3 = c(1:10),
  allnas = c(rep(NA, 10)),
  logic = TRUE,
  factortxt = factor('factor'),
  txt = 'words',
  numberlike = as.character(6:15),
  numberlikefact = factor(as.character(6:15)),
  stringsAsFactors = FALSE))

df
EJAM:::colMaxs2(df)
```
