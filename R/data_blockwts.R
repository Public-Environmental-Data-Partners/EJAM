#' @name blockwts
#' @title blockwts (DATA) population weights of Census blocks
#' @details
#'   For documentation on EJSCREEN, see [EJSCREEN documentation](https://web.archive.org/web/20250118193121/https://www.epa.gov/ejscreen)
#'
#'   blockwts is a table of all census blocks, with the weights reflecting
#'   what fraction of the parent blockgroup census 2020 population lived in
#'   that block.  The weights are used to aggregate block-level data to blockgroup,
#'   for cases where only some of the blockgroup is in a circular buffer or polygon.
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
#'     dataload_dynamic('blockwts')
#'
#'     names(blockwts)
#'     dim(blockwts)
#'   ```
NULL
