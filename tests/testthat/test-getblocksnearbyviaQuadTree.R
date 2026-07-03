
# if radius = 0 was requested,
# adjusted distance is always less than unadjusted,
# except when they both are 0.

testthat::test_that("distance gets adjusted up if radius zero", {
  if (!exists("blockpoints")) {dataload_dynamic("blockpoints") }
  set.seed(999)
  samp <- sample(1:NROW(blockpoints), 1000)
  pts <- data.frame(lat = blockpoints$lat[samp],
                    lon = blockpoints$lon[samp])
  # zero radius so distance always has to get adjusted
  radius <- 0
  x <- getblocksnearbyviaQuadTree(sitepoints = pts, radius = radius,
                                  quadtree = EJAM:::localtree_get(), quiet = T, report_progress_every_n = 2000)
  testthat::expect_true(all(x$distance >= x$distance_unadjusted, na.rm = TRUE))
  testthat::expect_true(all(x$distance > x$distance_unadjusted | x$distance == 0, na.rm = TRUE))
  testthat::expect_true(all(x$distance_unadjusted <= x$radius, na.rm = TRUE))
})
######################################################################################################## #


# cat(  "work in progress ! needs to be continued...\n\n")


####                            TESTS TO ADD HERE:  ***


# test for cases like these:
#
# sitepoints is
# - ok: pts <- data.frame(testpoints_10[1:2,])
# - aliases: pts <- data.table(latitute=testpoints_10$lat, longitude=testpoints_10$lon)
# - pts 0 rows, valid but just 1 row valid, valid but 2 rows
# - pts some NA some valid:
# - pts some invalid latlon some valid: pts <- data.table(lat=c(40,NA), lon=c(-100,NA))
# - pts all NA: pts <- data.table(lat=c(NA,NA) lon=c(NA,NA))
# - pts all invalid
# - wrong colnames: pts <- data.table(latt=1, logn=2))
# - bad pts: pts <- NULL, pts <- NA, pts <- list()
#
# radius requested is
#    - radius too big, radius negative, radius NA, radius NULL
#
# localtree is
#   - missing, NULL, invalid, not all the sitepoints were indexed
#
# # expect things like these:
# #
# expect_no_condition({
#   x <- getblocksnearbyviaQuadTree(sitepoints = testpoints_10, radius = 1, quiet = T)
# })
# expect_true("data.table" %in% class(x))
# correctcolnames <- c("ejam_uniq_id", "blockid", "distance", "blockwt", "bgid", "distance_unadjusted",
#                      "lat", "lon")
# expect_equal(colnames(x), correctcolnames)
#
#    etc.    etc.



######################################################################################################## #

### typical distance, so original unadj distance <= dist,
### and distance (adj or unadj) always <= radius
# test_that("unadjusted distance <= distance adjusted, and unadj d < radius", {
#
# radius <- 1
# suppressWarnings( {
# x <- getblocksnearbyviaQuadTree(sitepoints = pts, radius = radius,
# quadtree = localtree, quiet = T, report_progress_every_n = 2000,
# avoidorphans = FALSE)})
# testthat::expect_true(all(x$distance_unadjusted <= radius)) # TRUE since avoidorphans FALSE
# testthat::expect_true(all(x$distance_unadjusted <= x$distance)) # *** false why?? strange shape to block can mean even if distunadj < effectrad,  somehow... distunadj > 0.9*effectiveradius ???
# testthat::expect_true(all(x$distance <= radius) ) # ?? it can get adjusted to be >radius, ***but then still may want to filter out to report 0 within radius?
#})
######################################################################################################## #

# testthat::test_that("avoidorphans does as expected", {
### avoidorphans  TRUE
###
# suppressWarnings( {
#   x <- getblocksnearbyviaQuadTree(sitepoints = pts, radius = radius,
#   avoidorphans = TRUE,
#   quadtree = localtree, quiet = T, report_progress_every_n = 2000)})
# testthat::expect_true(  ?   all(x$distance_unadjusted <= radius))  # Should it sometimes be FALSE ??
# testthat::expect_true( ? all(x$distance_unadjusted <= x$distance))  # FALSE
# testthat::expect_true( ? all(x$distance <= radius))
# }
######################################################################################################## #

### 1 point, invalid

pts <- testpoints_10[1,]
# radius <- 3
# x <- getblocksnearbyviaQuadTree(pts, radius = radius,
# quadtree = localtree, quiet = T, report_progress_every_n = 2000)
# NROW(x) == 0   # *** but why not  1 row of NA values??
######################################################################################################## #

### >1 point, all invalid

######################################################################################################## #

### >1 point, some invalid

######################################################################################################## #
