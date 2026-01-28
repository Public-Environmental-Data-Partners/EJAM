
# grepn() is essentially tested via grepns() below

########################################################################### #

testthat::test_that("grepls works as expected", {

  testthat::expect_equal(
    grepls(c("hi", "other", 'x'), c("said hi ther hi hi hi e", 'hi', 'another', 'none'),
           rowperx = T),
    as.matrix(data.frame(hi = c(TRUE, TRUE, FALSE, FALSE),
                         other = c(FALSE, FALSE, TRUE, FALSE),
                         x = c(FALSE, FALSE, FALSE, FALSE)))
  )

  testthat::expect_equal(
    grepls(c("hi", "other", 'x'), c("said hi ther hi hi hi e", 'hi', 'another', 'none'),
           rowperx = F),
    c(hi = TRUE, other = TRUE, x = FALSE)
  )

})
########################################################################### #

testthat::test_that("grepns works as expected", {

  x = matrix(c(1,0,0,
               1,0,0,
               0,1,0,
               0,0,0), nrow=4, byrow=TRUE)
  colnames(x) <- c('hi', 'other', 'x')

  testthat::expect_equal(
    grepns(c("hi", "other", 'x'), c("said hi ther hi hi hi e", 'hi', 'another', 'none'),
           rowperx = T, count1perx=T),
    x
  )

  testthat::expect_equal(
    grepns(c("hi", "other", 'x'), c("said hi ther hi hi hi e", 'hi', 'another', 'none'),
           rowperx = F, count1perx=T),
    c(hi=2, other=1, x=0)
  )

  x = matrix(c(4,0,0,
               1,0,0,
               0,1,0,
               0,0,0), nrow=4, byrow=TRUE)
  colnames(x) <- c('hi', 'other', 'x')

  testthat::expect_equal(
    grepns(c("hi", "other", 'x'), c("said hi ther hi hi hi e", 'hi', 'another', 'none'),
           rowperx = T, count1perx=F),
    x
  )

  testthat::expect_equal(
    grepns(c("hi", "other", 'x'), c("said hi ther hi hi hi e", 'hi', 'another', 'none'),
           rowperx = F, count1perx=F),
    c(hi=5, other=1, x=0)
  )

})
########################################################################### #
