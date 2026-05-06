# utility to see which objects in a loaded/attached package are functions or datasets, exported or not (internal)

utility to see which objects in a loaded/attached package are functions
or datasets, exported or not (internal)

## Usage

``` r
pkg_functions_and_data(
  pkg = "EJAM",
  alphasort_table = FALSE,
  internal_included = TRUE,
  exportedfuncs_included = TRUE,
  functions_included = TRUE,
  data_included = TRUE,
  vectoronly = FALSE
)
```

## Arguments

- pkg:

  name of package as character like "EJAM"

- alphasort_table:

  default is FALSE, to show internal first as a group, then exported
  funcs, then datasets

- internal_included:

  default TRUE includes internal (unexported) objects in the list

- exportedfuncs_included:

  default TRUE includes exported functions (non-datasets, actually) in
  the list (unless functions_included=F)

- functions_included:

  default TRUE includes functions in the output

- data_included:

  default TRUE includes datasets in the output, as would be seen via
  data(package=pkg)

- vectoronly:

  set to TRUE to just get a character vector of object names instead of
  the data.frame table output

## Value

table in [data.table](https://r-datatable.com) format with colnames
object, exported, data where exported and data are 1 or 0 for T/F,
unless vectoronly = TRUE in which case it returns a character vector

## Details

See
[`pkg_dupeRfiles()`](https://public-environmental-data-partners.github.io/EJAM/reference/pkg_dupeRfiles.md)
for files supporting a shiny app that is not a package, e.g.

See
[`pkg_dupenames()`](https://public-environmental-data-partners.github.io/EJAM/reference/pkg_dupenames.md)
for objects that are in R packages.

See `pkg_functions_and_data()`, pkg_functions_and_sourcefiles(),

See
[`pkg_data()`](https://public-environmental-data-partners.github.io/EJAM/reference/pkg_data.md)

## See also

[`ls()`](https://rdrr.io/r/base/ls.html)
[`getNamespace()`](https://rdrr.io/r/base/ns-reflect.html)
[`getNamespaceExports()`](https://rdrr.io/r/base/ns-reflect.html)
[`loadedNamespaces()`](https://rdrr.io/r/base/ns-load.html)

## Examples

``` r
 # some way to see what functions are in the package:

 x1 <- EJAM:::pkg_functions_and_data(data_included=F, vectoronly=T)
 x2 <- EJAM:::pkg_functions_and_sourcefiles()
 info3 <- capture.output({ x3 <- EJAM:::pkg_functions_by_roxygen_tag() })
 info4 <- capture.output({ x4 <- EJAM:::pkg_functions_found_in_files() })
 ## x5 <- EJAM:::pkg_functions_preceding_lines() # may need to be debugged

 # See function names that use certain words - Useful view!

 extra <- capture.output({
   y <- EJAM:::pkg_functions_found_in_files()
 }); rm(extra)
 terms <- c("name",  "var", "fix",  "meta", "calc", "ejscreen", "report", "make")
 # also try   "^get", "^block", "^bg"
 sapply(terms, function(term) {cbind(grep(term, y, value=T))})

 # See filenames that use certain words - Useful view!

 # list.files(recursive = T, pattern = "^datacreate")
 list.files(recursive = T, pattern = "^util.*R$")
 sapply(setdiff(terms, 'name'), function(term) {
   list.files(recursive = T, pattern = paste0(term, ".*R$"))
 })


 # some ways to to see what datasets are in the EJAM package:

  yo <- EJAM:::pkg_functions_and_data(functions_included = F, vectoronly = T)
  x  <- EJAM:::pkg_data("EJAM", simple = F)
  setequal(x$Item, yo)

 # Plot showing that just a couple of large datasets
 # account for most of the total:

  biggest = x$Item[which.max(x$sizen)]
  bigp = round(100 * x$sizen[which.max(x$sizen)] / sum(x$sizen), 0)
  plot(cumsum(  sort(x$sizen,decreasing = T )) / sum(x$sizen),
       ylim=c(0,1), ylab="Share of total size", xlab="datasets sorted large to small", type = 'b',
            main= paste0(biggest, " alone is ", bigp,"% of total"))
            abline(v=0);abline(h=0);abline(h=1);abline(v=length(x$sizen))

  subset(x, x$size >= 0.1) # at least 100 KB
  xo <- x$Item
  grep("names_", xo, value = T, ignore.case = T, invert = T) # most were like names_d, etc.
  ls()
  data("avg.in.us", package="EJAM") # lazy load an object into memory and make it visible to user
  ls()


 # another way to see just a vector of the data object names
 data(package = "EJAM")$results[, 'Item']

 # not actually sorted within each pkg by default
 head(EJAM:::pkg_data())
 # not actually sorted by default
 head(EJAM:::pkg_data("EJAM")$Item)
 ## EJAM:::pkg_data("MASS", simple=T)

 # sorted by size if simple=F
 ## EJAM:::pkg_data("datasets", simple=F)
 x <- EJAM:::pkg_data(simple = F)
 # sorted by size already, to see largest ones among all these pkgs:
 tail(x[, 1:3], 20)

 # sorted alphabetically within each pkg
 head(
   x[order(x$Package, x$Item), 1:2]
 )
 # sorted alphabetically across all the pkgs
 head(
   x[order(x$Item), 1:2]
 )

# datasets as lazyloaded objects vs. files installed with package

topic = "fips"  # or "shape" or "latlon" or "naics" or "address" etc.

# datasets / R objects
cbind(data.in.package  = sort(grep(topic, EJAM:::pkg_data()$Item, value = T)))

# files
cbind(files.in.package = sort(basename(testdata(topic, quiet = T))))
```
