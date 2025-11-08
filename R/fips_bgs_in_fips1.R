

#' @keywords internal
#'
fips_bgs_in_fips1 <- function(fips, na.rm = TRUE) {

  # SLOWER THAN fips_bgs_in_fips() ALONE BUT FASTER WHEN IN sapply( )  ???
  suppressWarnings({
  x <- fips_lead_zero(fips)
  })
  if (na.rm) {
  fips <- x[!is.na(x)]
  } else {
    if (anyNA(x)) {
      howmanyna = sum(is.na(x))
      warning("NA returned for ", howmanyna," values that failed to match")
    }
}
  # if smaller than bg (i.e., >12 digits, i.e. block fips), return just the (parent) bgs (12 digits fips)
  fips <- unique(substr(fips,1,12))
  len <- nchar(fips)

  # if exactly 12 digits now, return as bgfips
  bgfips <- fips[len == 12 & !is.na(len)]

  # if larger geographic area than bg (<12 digits), return all the child bgs, and call those the nonbg-related fips
  #   if nchar==2, state, so get all bg starting with that
  #   if nchar is N, get all bg starting with those N characters
  nonbg <- fips[len !=  12 & !is.na(len)]


  ## seems inefficient - could avoid full copy by using a join to blockgroupstats here? ***
  all_us_bgfips <- blockgroupstats$bgfips
  extrabgs <- sapply(nonbg, FUN = function(z) all_us_bgfips[startsWith(all_us_bgfips, z)])


  # if fips was invalid but not NA, still want extrabgs to be NULL here, not a named list with element of length 0
  extrabgs <- extrabgs[sapply(extrabgs, length) != 0]

  ## note: should standardize output ***
  # in all blockgroups case, extrabgs is now an empty list(), while bgfips is just a vector, so union is a list() until unlist()
  # in all tracts case, extrabgs is now a "matrix" "array"  with colnames, while bgfips is character(0) length zero
  # in all counties case, extrabgs is a list() of vectors with names that are the input countyfips, while bgfips is character(0) length zero
  #     union() removes the names from the list

  return(unlist(union(bgfips, extrabgs)))
}
############################################################################# #
