
# # checking parameter combinations via argument_combos()
### but note the fault where unlike if using checkit() below,
## using argument_combos() means if any of the radii tried here are character, they all get made character
## and it assumes you did so to provide your own units, so it fails to say "miles" !!

# x = EJAM:::argument_combos(FUN = EJAM:::report_residents_within_xyz, list(radius=c(1,3.1), nsites=c(1,100) , sitetype=c('latlon')), quiet = F)
# x = EJAM:::argument_combos(FUN = EJAM:::report_residents_within_xyz, list(   sitetype=c( "fips","shp")), quiet = F) #
# x = EJAM:::argument_combos(FUN = EJAM:::report_residents_within_xyz, list(radius=0, sitetype=c( "fips","shp")), quiet = F)
# x = EJAM:::argument_combos(FUN = EJAM:::report_residents_within_xyz, list( radius=0.25,  sitetype=c( "fips","shp")), quiet = F)
#
# test1_arglist <- list(
#   sitetype = c('latlon', "shp"),
#   radius = "3",  # if any of the radii tried here are character, they all get made character and it assumes you did so to provide your own units, so it fails to say "miles" !!
#   nsites = c(1, "six")
# )
#
# x = EJAM:::argument_combos(FUN = EJAM:::report_residents_within_xyz, test1_arglist, quiet = F)
#
# test1_arglist <- list(
#   sitetype = c("farm", "Georgia site"),
#   radius = c('9.9 kilometers', "close proximity to"),
#   nsites = c(1, "seven")
# )
# #  expand.grid(test1_arglist, stringsAsFactors = FALSE)
# x = EJAM:::argument_combos(FUN = EJAM:::report_residents_within_xyz, test1_arglist, quiet = F)
# ############################## #
#
# test_that("report_residents_within_xyz ALL combos ok", {
#   # if trying ALL combinations via argument_combos()
# test1_arglist <- list(
#   sitetype = c('latlon', "fips", "shp", "farm", "Georgia location", "study location, Type X site"),
#   radius = c(3, 1,  '99 miles',  '9.9 kilometers', "close proximity to"),
#   nsites = c(1, 100, "seven", "several")
# )
#   # expand.grid(test1_arglist, stringsAsFactors = FALSE)
# expect_no_error({
  # x = argument_combos(FUN = report_residents_within_xyz, test1_arglist, quiet = TRUE)
# })
# })

############################## #
# older way to check combos was this function called checkit()
# (and it avoids a fault in argument_combos() where checking character string as the radius parameter
# makes all radius options text not numeric which makes it stop using "miles" even for the originally numeric options)

checkit <- function(mytest) {

  params <- rbindlist(mytest)
  if (NCOL(params) == 3) {

    names(params) <- c('sitetype', 'radius', 'nsites'
                       #, 'ejam_uniq_id'
    )
    x = data.frame(params,
               text = sapply(mytest, function(z) {

                 report_residents_within_xyz(

                   sitetype = z[[1]],
                   radius = z[[2]], # gets rounded in this function (if it can be interpreted as a number)
                   nsites = z[[3]]
                   #, ejam_uniq_id = z[[4]]
                 )
               })
    )

  }
  if (NCOL(params) == 4) {

    names(params) <- c('sitetype', 'radius', 'nsites'
                       , 'ejam_uniq_id'
    )
    x = data.frame(params,
               text = sapply(mytest, function(z) {

                 report_residents_within_xyz(

                   sitetype = z[[1]],
                   radius = z[[2]], # gets rounded in this function (if it can be interpreted as a number)
                   nsites = z[[3]]
                   , ejam_uniq_id = z[[4]]
                 )
               })
    )

  }
  x
}
############################## #   ############################## #

test_that("report_residents_within_xyz normal cases", {

  test1 <- list(

    # list('latlon', 0, 1), # cannot occur - zero radius with latlon type
    # list('latlon', 0, 100), # cannot occur - zero radius with latlon type
    list('latlon', 3, 1),
    list('latlon', 3, 100),

    list('fips', 0, 1),
    list('fips', 0, 100),
    # list('fips', 3, 1), # cannot occur - nonzero radius with fips type
    # list('fips', 3, 100), # cannot occur - nonzero radius with fips type
    # list( NA, '99 miles', 'seven sites'),  # fails if NA

    list('shp', 0, 1),
    list('shp', 0, 100),
    list('shp', 3, 1),
    list('shp', 3, 100),

    list('farm',              '99 miles',          'seven'),
    list( "Georgia location", '9.9 kilometers',    "several"),
    list('study location',    "close proximity to",  100),

    list('Type X site', 3, 100)   # ok singular / plural
  )
  ############## #

  expect_no_error({
    x = checkit(test1)
  }
  # , label = "test1"
  )

  # > checkit(test1)
  #            sitetype             radius  nsites                                                                                         text
  # 1            latlon                  3       1             Residents within 3 miles of this specified point <br>Area in Square Miles: 28.27
  # 2            latlon                  3     100 Residents within 3 miles of any of the 100 specified points<br>Area in Square Miles: 2827.43
  # 3              fips                  0       1                                                 Residents within this specified Census unit
  # 4              fips                  0     100                                       Residents within any of the 100 specified Census units
  # 5               shp                  0       1                                                     Residents within this specified polygon
  # 6               shp                  0     100                                           Residents within any of the 100 specified polygons
  # 7               shp                  3       1                                          Residents within 3 miles of this specified polygon
  # 8               shp                  3     100                                Residents within 3 miles of any of the 100 specified polygons
  # 9              farm           99 miles   seven                                             Residents within 99 miles any of the seven farms
  # 10 Georgia location     9.9 kilometers several                         Residents within 9.9 kilometers any of the several Georgia locations
  # 11   study location close proximity to     100                           Residents within close proximity to any of the 100 study locations
  # 12      Type X site                  3     100                                      Residents within 3 miles of any of the 100 Type X sites
})
############################## #   ############################## #

test_that("ejam_uniq_id ok", {

  test1_with_id <- list(
    ## now with IDs

    # list('latlon', 0, 1, ejam_uniq_id = 73), # cannot occur - zero radius with latlon type
    # list('latlon', 0, 100), # cannot occur - zero radius with latlon type
    list('latlon', 3, 1, ejam_uniq_id = 73),
    list('latlon', 3, 100, ejam_uniq_id = 100),

    list('fips', 0, 1, ejam_uniq_id = 73),
    list('fips', 0, 100, ejam_uniq_id = 100),
    # list('fips', 3, 1), # cannot occur - nonzero radius with fips type
    # list('fips', 3, 100), # cannot occur - nonzero radius with fips type
    # list( NA, '99 miles', 'seven sites'),  # fails if NA

    list('shp', 0, 1, ejam_uniq_id = 73),
    list('shp', 0, 100, ejam_uniq_id = 100),
    list('shp', 3, 1, ejam_uniq_id = 73),
    list('shp', 3, 100, ejam_uniq_id = 100),

    list('farm',              '99 miles',          'seven', ejam_uniq_id = 7),
    list( "Georgia location", '9.9 kilometers',    "several", ejam_uniq_id = 3),
    list('study location',    "close proximity to",  100, ejam_uniq_id = 100),

    list('Type X site', 3, 100, ejam_uniq_id =  100)   # ok singular / plural
  )

  expect_no_error({
    x = checkit(test1_with_id)
  })

  # > x
  #            sitetype             radius  nsites ejam_uniq_id                                                                                              text
  # 1            latlon                  3       1           73 Residents within 3 miles of this specified point (ejam_uniq_id 73)<br>Area in Square Miles: 28.27
  # 2            latlon                  3     100          100      Residents within 3 miles of any of the 100 specified points<br>Area in Square Miles: 2827.43
  # 3              fips                  0       1           73                                             Residents within this specified Census unit (FIPS 73)
  # 4              fips                  0     100          100                                            Residents within any of the 100 specified Census units
  # 5               shp                  0       1           73                                         Residents within this specified polygon (ejam_uniq_id 73)
  # 6               shp                  0     100          100                                                Residents within any of the 100 specified polygons
  # 7               shp                  3       1           73                              Residents within 3 miles of this specified polygon (ejam_uniq_id 73)
  # 8               shp                  3     100          100                                     Residents within 3 miles of any of the 100 specified polygons
  # 9              farm           99 miles   seven            7                                                  Residents within 99 miles any of the seven farms
  # 10 Georgia location     9.9 kilometers several            3                              Residents within 9.9 kilometers any of the several Georgia locations
  # 11   study location close proximity to     100          100                                Residents within close proximity to any of the 100 study locations
  # 12      Type X site                  3     100          100                                           Residents within 3 miles of any of the 100 Type X sites
  #
  expect_equal(
    x$text[3],
    "Residents within this specified Census unit (FIPS 73)"
  )
  expect_equal(
    x$text[5],
    "Residents within this specified polygon (ejam_uniq_id 73)"
  )

})
############################## #   ############################## #

test_that("pluralize, 'within', empty param cases", {

  test2 <- list(

    # fix/note singular/plural

    list('Type X facility', 3, 100),
    list('Type X facilities', 3, 100),

    # fix "within"

    list('study location', "at", 100),       # within at
    list('Delaware Counties', "within", 3),  # within 'within'

    # fix "" cases

    list( "Georgia location", '9.9 kilometers', ""),
    list( "", '9.9 kilometers', "several"),
    list( "Georgia location", '', "several"),
    list('', '', '')
  )
  ############################## #
  expect_no_error({

    x = checkit(test2)
  })
})
############################## #   ############################## #

test_that("NA params ok", {

  test3 <- list(

    #   na values
    list(     NA,   3, 100),
    list('latlon', NA, 100),
    list('latlon',  3, NA)
  )
  ############################## #

  expect_no_error({

    x = checkit(test3)

    # ## but not useful results if NA
    # sitetype radius nsites                                                    text
    # 1     <NA>      3    100       Residents within 3 miles of any of the 100 places
    # 2   latlon     NA    100         Residents within any of the 100 selected points
    # 3   latlon      3     NA Residents within 3 miles of any of the  selected points
  })

})
########################################################################### #
########################################################################### #

test_that("warn if NULL params", {

  test4 <- list(
    # NULL values
    list(NULL, 3, 100),
    list('latlon', NULL, 100),
    list('latlon', 3, NULL)
  )
  ############################## #
  expect_no_error({
    suppressWarnings({
      x = checkit(test4)
    })
  })
  expect_warning({
    x = checkit(test4)
  } )

})
########################################################################### #

rm(checkit)

