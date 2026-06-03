
#' @name bgid2fips
#' @title bgid2fips (DATA) Census FIPS codes of blockgroups
#' @details
#'   For documentation on EJSCREEN, see [EJSCREEN documentation](https://web.archive.org/web/20250118193121/https://www.epa.gov/ejscreen)
#'
#'   bgid2fips is a table of all census blockgroups, with their FIPS codes.
#'
#'   It also has a column
#'   called `blockid` that can join it to other block datasets.
#'
#'   For EJAM v3, AS/GU/MP/VI can appear in [blockgroupstats], EJSCREEN
#'   export files, and map-facing blockgroup datasets, but this blockgroup
#'   helper file intentionally does not include Island Area blockgroups used by
#'   the block helper universe. Point-buffer/radius or block-weighted polygon
#'   analysis for AS/GU/MP/VI should return no-data results rather than
#'   block-weighted estimates.
#'   ```
#'     dataload_dynamic('bgid2fips')
#'
#'     names(bgid2fips)
#'     dim(bgid2fips)
#'   ```
NULL
