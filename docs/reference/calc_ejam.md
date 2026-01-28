# DRAFT utility to use formulas provided as text, to calculate indicators

DRAFT utility to use formulas provided as text, to calculate indicators

DRAFT utility to use formulas provided as text, to calculate indicators

## Usage

``` r
calc_ejam(
  bg,
  keep.old = c("bgid", "pop"),
  keep.new = "all",
  formulas,
  quiet = TRUE
)

calc_ejam(
  bg,
  keep.old = c("bgid", "pop"),
  keep.new = "all",
  formulas,
  quiet = TRUE
)
```

## Arguments

- bg:

  data.frame//table of indicators or variables to use

- keep.old:

  names of columns (variables) to retain from among those provided in bg

- keep.new:

  names of calculated variables to retain in output

- formulas:

  text strings of formulas

- quiet:

  if FALSE, prints to console success/failure of each formula

## Value

data.frame of calculated variables one row per bg row

data.frame of calculated variables one row per bg row

## Details

- [`custom_doaggregate()`](https://ejanalysis.github.io/EJAM/reference/custom_doaggregate.md)
  may use `calc_ejam()`

- `calc_ejam()` uses
  [`calc_byformula()`](https://ejanalysis.github.io/EJAM/reference/calc_byformula.md)

- [`calc_byformula()`](https://ejanalysis.github.io/EJAM/reference/calc_byformula.md)
  uses
  [`calc_varname_from_formula()`](https://ejanalysis.github.io/EJAM/reference/calc_varname_from_formula.md)
  and maybe source_this_codetext()

&nbsp;

- [`custom_doaggregate()`](https://ejanalysis.github.io/EJAM/reference/custom_doaggregate.md)
  may use `calc_ejam()`

- `calc_ejam()` uses
  [`calc_byformula()`](https://ejanalysis.github.io/EJAM/reference/calc_byformula.md)

- [`calc_byformula()`](https://ejanalysis.github.io/EJAM/reference/calc_byformula.md)
  uses
  [`formula_varname()`](https://ejanalysis.github.io/EJAM/reference/formula_varname.md)
  and maybe source_this_codetext()

## Examples

``` r
if (FALSE) { # \dontrun{
### example using just 10 blockgroups from 1 county in Delaware

 c1 <- fips2countyname(fips_counties_from_state_abbrev('DE'), includestate = FALSE)[1]
 bgdf = data.frame(EJAM::blockgroupstats[ST == "DE" & countyname == c1, ])[1:10, ]

 newdf <- calc_ejam(bgdf, keep.old = "",
   formulas = c(
     "my_custom_recalc_demog <- (pctlowinc + pctmin)/2",
     "mystat2  = 100 * pctlowinc"))
cbind(Demog.Index = bgdf$Demog.Index, newdf, pctlowinc = bgdf$pctlowinc)

newdf <- calc_ejam(bgdf, formulas = formulas_d)
newdf


##  example of entire US
#
newdf1  <- calc_ejam(as.data.frame(bgdf), formulas = formulas_d)
  t(summary(newdf1))

bgdf <- data.frame(blockgroupstats)
newdf <- calc_ejam(bgdf,
                   keep.old = c('bgid', 'pop', 'hisp'),
                   keep.new = "all",
                   formulas = formulas_d
)
round(t(newdf[1001:1002, ]), 3)
cbind(
  newdf[1001:1031, c('hisp', 'pop', 'pcthisp')],
  check = (newdf$hisp[1001:1031] / newdf$pop[1001:1031])
  )
## note the 0-100 percentages in blockgroupstats versus the 0-1 calculated percentages
cbind(round(sapply(newdf, max, na.rm=TRUE),2),
names(newdf) %in% names_pct_as_fraction_blockgroupstats)

EJAM:::calc_varname_from_formula(formulas_d)

rm(bgdf)
} # }
if (FALSE) { # \dontrun{
### example using just 10 blockgroups from 1 county in Delaware

 c1 <- fips2countyname(fips_counties_from_state_abbrev('DE'), includestate = FALSE)[1]
 bgdf = data.frame(EJAM::blockgroupstats[ST == "DE" & countyname == c1, ])[1:10, ]

 newdf <- calc_ejam(bgdf, keep.old = "",
   formulas = c(
     "my_custom_recalc_demog <- (pctlowinc + pctmin)/2",
     "mystat2  = 100 * pctlowinc"))
cbind(Demog.Index = bgdf$Demog.Index, newdf, pctlowinc = bgdf$pctlowinc)

newdf <- calc_ejam(bgdf, formulas = formulas_d)
newdf


##  example of entire US
#
newdf1  <- calc_ejam(as.data.frame(bgdf), formulas = formulas_d)
  t(summary(newdf1))

bgdf <- data.frame(blockgroupstats)
newdf <- calc_ejam(bgdf,
                   keep.old = c('bgid', 'pop', 'hisp'),
                   keep.new = "all",
                   formulas = formulas_d
)
round(t(newdf[1001:1002, ]), 3)
cbind(
  newdf[1001:1031, c('hisp', 'pop', 'pcthisp')],
  check = (newdf$hisp[1001:1031] / newdf$pop[1001:1031])
  )
## note the 0-100 percentages in blockgroupstats versus the 0-1 calculated percentages
cbind(round(sapply(newdf, max, na.rm=TRUE),2),
names(newdf) %in% names_pct_as_fraction_blockgroupstats)

EJAM:::formula_varname(formulas_d)

rm(bgdf)
} # }
```
