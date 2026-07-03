
#' @name blockpoints
#' @title blockpoints (DATA) Census blocks locations
#' @details
#'   There is [archived documentation on EJSCREEN ](https://web.archive.org/web/20250118193121/https://www.epa.gov/ejscreen)
#'
#'   blockpoints is a table of all census blocks, with the lat, lon
#'   providing the latitude and longitude of the Census Bureau-defined
#'   internal point, like a centroid, of each block.
#'
#'   It also has a column
#'   called blockid that can join it to other block datasets.
#'
#'   For EJAM v3, AS/GU/MP/VI can appear in [blockgroupstats], EJSCREEN
#'   export files, and map-facing blockgroup datasets, but this block helper
#'   file intentionally does not include Island Area blocks. Point-buffer/radius
#'   or block-weighted polygon analysis for AS/GU/MP/VI should return no-data
#'   results rather than block-weighted estimates.
#'
#'     `dataload_dynamic('blockpoints')`
#'
#'     `names(blockpoints)`
#'     `dim(blockpoints)`
#'
NULL
