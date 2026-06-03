#' @name quaddata
#' @docType data
#' @title quaddata (DATA) data.table used to create index of all US block point locations
#' @aliases localtree
#' @details
#'    quaddata is a table in [data.table](https://r-datatable.com) format.
#'
#'    8,174,955 rows when non-populated blocks are kept.
#'    5,806,512 rows (71%) have Census 2020 population (and blockwt) > 0.
#'    This is the largest file used by the package, and is 168 MB as a file, for 2020 Census.
#'      - blockid
#'      - BLOCK_X, BLOCK_Y, BLOCK_Z  (not lat, lon)
#'
#'     `indexblocks()` creates a quadtree index from `quaddata` and stores it
#'     in the package cache. The index is a QuadTree object from the SearchTrees
#'     package, not a data.table.
#'
#' @seealso [indexblocks()] [EJAM]
NULL
