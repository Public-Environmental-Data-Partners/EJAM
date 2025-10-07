

#' utility to add each block's lat and lon as new columns in data.table by reference, joining on blockid
#'
#' get expanded version of data.table, such as sites2blocks,
#' with new lat,lon columns
#'
#' @param s2b data.table like [testoutput_getblocksnearby_10pts_1miles],
#' output of [getblocksnearby()],
#' with column called blockid
#'
#' @return returns the input data.table but with lat,lon columns added as block coordinates
#' @examples
#'  s2b = copy(testoutput_getblocksnearby_10pts_1miles)
#'  latlon_join_on_blockid(s2b)
#'
#' @keywords internal
#'
latlon_join_on_blockid = function(s2b) {

  if (missing(s2b)) {
    warning('No value provided for argument "s2b".')
    return(NULL)
  }
  else if (all(is.na(s2b)) || is.null(s2b)) {
      warning('NULL or NA "s2b" passed as inputs.')
      return(NULL)
  }
  if (all(c('lat','lon') %in% names(s2b))) {message('already has lat,lon'); return(s2b)}
  return(
    # merge(s2b, blockpoints , on = "blockid")
    # better via a join, though right? could modify param by reference without even explicitly returning anything then
    s2b[blockpoints, `:=`(lat = lat, lon = lon), on = "blockid"]
  )
}
########################################################################################### #

## notes on lat lon of sites versus lat lon of block points
#
# pts = copy(testpoints_10[1:2,])
# # add ejam_uniq_id column
# pts = sitepoints_from_any(pts)
#
# # find blocks
# s2b = getblocksnearby(pts)
#
# # to add latlon of the SITES (pts), not the blocks
# s2b[pts, c('sitelat', 'sitelon') := .(lat,lon), on = "ejam_uniq_id"]
#
# # to add latlon of the BLOCKS, not the sites
# latlon_join_on_blockid(s2b)
# s2b
# # can map blocks lat,lon easily if colnames are lat,lon
# mapfast(s2b[ejam_uniq_id == 1,], radius = 0.01)
# # to rename block lat,lon for clarity
# setnames(s2b,"lat","blocklat"); setnames(s2b,"lon","blocklon")
# s2b

## Key: <blockid>
##   Index: <ejam_uniq_id>
##
##    ejam_uniq_id blockid distance     blockwt   bgid distance_unadjusted  sitelat   sitelon blocklat   blocklon
##           <int>   <int>    <num>       <num>  <int>               <num>    <num>     <num>    <num>      <num>
## 1:            1  917799 2.958068 0.068843778  32583            2.958068 37.64122 -122.4107 37.68371 -122.40401
## 2:            1  917800 2.911103 0.049426302  32583            2.911103 37.64122 -122.4107 37.68305 -122.40427
## ---
## 1241:        2 7481954 1.944805 0.007616975 221738            1.944805 43.92249  -72.6637 43.90287  -72.69172
## 1242:        2 7481955 1.743321 0.000000000 221738            1.743321 43.92249  -72.6637 43.89891  -72.67618
