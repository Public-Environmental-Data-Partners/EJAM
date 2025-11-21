
# test cases
test_that("distances.all ok" , {
  expect_no_error({
    set.seed(999)
    t1=testpoints_500[1,c("lon", "lat")]
    t10=testpoints_500[1:10,c("lon", "lat")]
    t100=testpoints_500[1:100,c("lon", "lat")]
    t1k=rbind(testpoints_500, testpoints_500)

    x = distances.all(t1, t1)
    expect_true(
      all.equal(as.vector(unlist(x[, c("fromlon", "fromlat")])), as.vector(unlist(t1)))
    )
  })
})

# distances.all(t1, t10[2, , drop = FALSE])
# x=distances.all(t10, t100[1:20 , ], units = 'km')
# plot(x$tolon, x$tolat,pch='.')
# points(x$fromlon, x$fromlat)
# with(x, segments(fromlon, fromlat, tolon, tolat ))
# with(x[x$d < 500, ], segments(fromlon, fromlat, tolon, tolat ,col='red'))
#
# test.from <- structure(list(fromlat = c(38.9567309094, 45),
#                             fromlon = c(-77.0896572305, -100)), .Names = c("lat", "lon"),
#                        row.names = c("1", "2"), class = "data.frame")
#
# test.to <- structure(list(tolat = c(38.9575019287, 38.9507043428, 45),
#                           tolon = c(-77.0892818598, -77.2, -90)),
#                      .Names = c("lat", "lon"), class = "data.frame",
#                      row.names = c("1", "2", "3"))
# test.to.NA = rbind(c(NA,NA), test.to[2:3,])
# test.from.NA = rbind(test.from[1,], c(NA,NA))
#
# distances.all(test.from, test.to)
# distances.all(test.from, test.to, return.crosstab=TRUE)
# distances.all(test.from, test.to, return.rownums=FALSE)
# distances.all(test.from, test.to, return.latlons=FALSE)
# distances.all(test.from, test.to, return.latlons=FALSE,
#               return.rownums=FALSE)

# distances.all(test.from,    test.to.NA)
# distances.all(test.from.NA, test.to)
# distances.all(test.from.NA, test.to.NA)
# distances.all(test.from[1,],test.to[1,],return.rownums=F,
# return.latlons=F)
# distances.all(test.from[1,],test.to[1,],return.rownums=FALSE,
# return.latlons=TRUE)
# distances.all(test.from[1,],test.to[1,],return.rownums=TRUE,
# return.latlons=FALSE)
# distances.all(test.from[1,],test.to[1,],return.rownums=TRUE,
# return.latlons=TRUE)
#
# distances.all(test.from[1,],test.to[1:3,],return.rownums=F,
# return.latlons=F)
# distances.all(test.from[1,],test.to[1:3,],return.rownums=FALSE,
# return.latlons=TRUE)
# distances.all(test.from[1,],test.to[1:3,],return.rownums=TRUE,
# return.latlons=FALSE)
# distances.all(test.from[1,],test.to[1:3,],return.rownums=TRUE,
# return.latlons=TRUE)
#
# distances.all(test.from[1:2,],test.to[1,],return.rownums=F,
# return.latlons=F)
# distances.all(test.from[1:2,],test.to[1,],return.rownums=FALSE,
# return.latlons=TRUE)
# distances.all(test.from[1:2,],test.to[1,],return.rownums=TRUE,
# return.latlons=FALSE)
# distances.all(test.from[1:2,],test.to[1,],return.rownums=TRUE,
# return.latlons=TRUE)
#
# round(distances.all(test.from[1:2,],test.to[1:3,],return.rownums=F,
# return.latlons=F),1)
# distances.all(test.from[1:2,],test.to[1:3,],return.rownums=FALSE,
# return.latlons=T)
# distances.all(test.from[1:2,],test.to[1:3,],return.rownums=TRUE,
# return.latlons=F)
# distances.all(test.from[1:2,],test.to[1:3,],return.rownums=TRUE,
# return.latlons=TRUE)
# distances.all(test.from[1:2,],test.to[1:3,], return.rownums=TRUE,
#   return.latlons=TRUE, units='km')
# distances.all(test.from[1:2,],test.to[1:3,], return.rownums=TRUE,
#   return.latlons=TRUE, units='miles')
#
# distances.all(test.from[1,],test.to[1:3, ], return.crosstab=TRUE)
# distances.all(test.from[1:2,],test.to[1, ], return.crosstab=TRUE)
# round(distances.all(test.from[1:2,],test.to[1:3, ],
# return.crosstab=TRUE, units='miles'),2)
# round(distances.all(test.from[1:2,],test.to[1:3, ],
# return.crosstab=TRUE, units='km'),2)
#
