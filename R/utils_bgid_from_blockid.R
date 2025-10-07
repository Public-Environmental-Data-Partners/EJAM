
#' utility - get table with bgid for each blockid, or just unique bgid values vector
#'
#' @param blockids vector of blockid values as in [blockwts] table or in [testoutput_getblocksnearby_10pts_1miles]
#' @param asdt set to TRUE if you want it to return a data.table with colnames bgid, blockid,
#'   one row per input blockid, so it may have duplicates in the bgid column.
#'   set to FALSE if you want it to return a vector of bgid values (integer class)
#' @returns depends on asdt parameter value
#' @examples
#'
#' rad = 0.658
#' pts = data.frame(lat=39.4347105, lon=-74.7203421)
#' s2b = getblocksnearby(sitepoints=pts, radius = rad)
#' bgid_from_blockid(s2b$blockid) # vector of unique ids
#' bgid_from_blockid(s2b$blockid, asdt = TRUE) # data.table
#'
#'  # plotblocksnearby(pts, radius = rad, overlay_blockgroups = T)
#'
#' @keywords internal
#'
bgid_from_blockid <- function(blockids, asdt = FALSE) {

  if (asdt) {
    #   asdt=T means return data.table with 1 row per input blockid, colnames bgid,blockid
    blockwts[blockid %in% blockids,.(bgid, blockid)  ]
  } else {
    #   asdt=F means return integer vector of unique bgid values
    blockwts[blockid %in% blockids, unique(bgid)  ]
  }
}
