# UTILITY - DRAFT - See names and size of data sets in installed package(s) - internal utility function

Wrapper for data() and can get memory size of objects

## Usage

``` r
pkg_data(pkg = "EJAM", len = 30, sortbysize = TRUE, simple = TRUE)
```

## Arguments

- pkg:

  a character vector giving the package(s) to look in for data sets

- len:

  Only affects what is printed to console - specifies the number of
  characters to limit Title to, making it easier to see in the console.

- sortbysize:

  if TRUE (and simple=F), sort by increasing size of object, within each
  package, not alpha.

- simple:

  FALSE to get object sizes, etc., or TRUE to just get names in each
  package, like `data(package = "EJAM")$results[, c("Package", 'Item')]`

## Value

If simple = TRUE, data.frame with colnames Package and Item. If simple =
FALSE, data.frame with colnames Package, Item, size, Title.Short

## Details

do not rely on this much - it was a quick utility. It may create and
leave objects in global envt - not careful about that.

Also see functions like pkg_functions_and_data() and pkg_functions_xyz

## Examples

``` r
 # some way to see what functions are in the package:

 x1 <- EJAM:::pkg_functions_and_data(data_included=F, vectoronly=T)
 x2 <- EJAM:::pkg_functions_and_sourcefiles()
 info3 <- capture.output({ x3 <- EJAM:::pkg_functions_by_roxygen_tag() })
 info4 <- capture.output({ x4 <- EJAM:::pkg_functions_found_in_files() })
 ## x5 <- EJAM:::pkg_functions_preceding_lines() # may need to be debugged

 # Which functions, files, or data objects are named with certain terms?

 terms <- c("name",  "var", "fix",  "meta", "calc", "ejscreen", "report", "make")
 # also try   "^get", "^block", "^bg"

 # See FUNCTION names that use certain words - Useful view

 extra <- capture.output({
   funcs <- EJAM:::pkg_functions_found_in_files()
 }); rm(extra)
 sapply(terms, function(term) {cbind(grep(term, funcs, value=T))})

 # See FILE names that use certain words - Useful view

 # list.files(recursive = T, pattern = "^datacreate")
 list.files(recursive = T, pattern = "^util.*R$")
 sapply(setdiff(terms, 'name'), function(term) {
   list.files(recursive = T, pattern = paste0(term, ".*R$"))
 })

 # See DATASET names that use certain words - Useful view

 dat <- EJAM:::pkg_functions_and_data(functions_included = F, vectoronly = T)
 terms1 = "formula"
 cat("DATA OBJECTS \n"); grep(terms1, dat, value=T)
 cat("FUNCTIONS \n"); paste0(grep(terms1, funcs, value=T), "()")

 terms1="calc"
 cat("DATA OBJECTS \n"); grep(terms1, dat, value=T)
 cat("FUNCTIONS \n"); paste0(grep(terms1, funcs, value=T), "()")

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
