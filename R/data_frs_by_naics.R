#' @name frs_by_naics
#' @title frs_by_naics (DATA) data.table of NAICS code(s) for each EPA-regulated site in Facility Registry Service
#' @seealso [frs] [frs_from_naics()] [naics_categories()] [frs_by_programid] and see naics_from_any in EJAM pkg.
#' @description
#'    Table in [data.table](https://r-datatable.com) format.
#'    This is the format with one row per site-NAICS pair,
#'    so multiple rows for one site if it is in multiple NAICS.
#'  @details
#'   This file is not stored in the package, but is obtained via [dataload_dynamic()].
#'
#'  The EPA also provides a [FRS Facility Industrial Classification Search tool](https://www.epa.gov/frs/frs-query#industrial)
#'  where you can find facilities based on NAICS or SIC.
#'
#'
#'  Many FRS facilities lack NAICS information. Use `nrow(frs_by_naics)`,
#'  `data.table::uniqueN(frs_by_naics$REGISTRY_ID)`, and
#'  `data.table::uniqueN(frs_by_naics$NAICS)` for the installed snapshot.
#' @examples
#'  dataload_dynamic("frs")
#'  dataload_dynamic("frs_by_naics")
#'  library(data.table)
#'  # Compare coverage for the installed snapshot.
#'  frs[ NAICS == "", .N] / frs[,.N]
#'  frs[ NAICS != "", .N]
#'  frs_by_naics[, uniqueN(REGISTRY_ID)]
#'
#'  dim(frs_by_naics)
#'  # Some registry IDs appear more than once because they have multiple NAICS codes.
#'
#'  frs_by_naics[,  uniqueN(NAICS)]
#'  frs_by_naics[, .(sum(.N > 1)), by=NAICS][,sum(V1)]
#'   frs_by_naics[, .(sum(.N == 1)), by=NAICS][,sum(V1)]
#'
#'  # Which 2-digit NAICS are found here most often?
#'  frs_by_naics[ , .N, keyby=substr(NAICS,1,2)]
#'  frs_by_naics[ , .N,   by=substr(NAICS,1,2)][order(N),] # Most common are 33 and 81
#'  # Top 10 most common 3-digit NAICS here:
#'  x = tail(frs_by_naics[ , .N,   by=.(n3 = substr(NAICS,1,3))][order(N), ],10)
#'  cbind(x, industry = rownames(naics_categories(3))[match(x$n3, naics_categories(3))])
NULL
