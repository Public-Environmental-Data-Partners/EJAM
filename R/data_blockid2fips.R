
#' @name blockid2fips
#' @title blockid2fips (DATA) Census FIPS codes of blocks
#' @details
#'   This is a VERY large file, used only when essential.
#'   For documentation on EJSCREEN, see [EJSCREEN documentation](https://web.archive.org/web/20250118193121/https://www.epa.gov/ejscreen)
#'
#'   blockid2fips is a table of all census blocks, with the FIPS codes.
#'
#'   It also has a column
#'   called `blockid` that can join it to other block datasets.
#'
#'   For EJAM v3, AS/GU/MP/VI can appear in [blockgroupstats], EJSCREEN
#'   export files, and map-facing blockgroup datasets, but this block helper
#'   file intentionally does not include Island Area blocks. Point-buffer/radius
#'   or block-weighted polygon analysis for AS/GU/MP/VI should return no-data
#'   results rather than block-weighted estimates.
#'   ```
#'     dataload_dynamic('blockid2fips')
#'
#'     names(blockid2fips)
#'     dim(blockid2fips)
#'   ```
NULL
