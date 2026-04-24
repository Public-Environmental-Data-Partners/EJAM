
############################## #   ############################## #
# in functions that use output of ejamit() or a whole table,
# params can specify how many sites were analyzed, or were valid; and which row or valid row to report on.
# but in this function, we do not use that list or table, so..

# does nsites here really mean how many rows in a table or valid rows or just a label to use in text? ***

# does sitenumber here really mean which row, or which valid row, or just a label to use in text? ***

############################## #   ############################## #
############################## #   ############################## #
# helper function to check combos of parameters:

checkit <- function(params) {

  txt = vector("character", nrow(params))
  for (i in seq_along(txt)) {
    txt[i] <- do.call(report_residents_within_xyz, as.list(params[i,]))
  }
  ## This did not quite work:
  # txt <- apply(params,
  #       MARGIN = 1,
  #       FUN = function(z) {
  #         do.call(report_residents_within_xyz, as.list(z))
  #         })

  x = data.frame(params,
                 text = txt
  )
  return(x)
}
############################## #   ############################## #
############################## #   ############################## #

testthat::test_that("report_residents_within_xyz handles latlon", {

  pnames = c('sitetype', 'radius', 'nsite'
             , 'lat', 'lon')
  test <- test0 <- list(

    list('latlon', 3, 100, 35, -90), # latlon are PROVIDED
    list('latlon', 3, 1, NULL, NULL), ## latlon are MISSING BUT EXPECTED

    list('fips', 0, 1, 35, -90),   ## latlon are NOT EXPECTED but PROVIDED

    list('latlon', 3, 100, 35, -999)  # latlon are PROVIDED but invalid
  )
  suppressWarnings({
    test <-   data.table::rbindlist(test, fill = TRUE, use.names=FALSE)
  })
  colnames(test) <- pnames
  ############## #

  expect_no_error({
    x = checkit(test)
  })
})
############################## #   ############################## #

test_that("report_residents_within_xyz normal cases", {

  pnames = c('sitetype', 'radius', 'nsites')

  test <- test1 <- list(

    ### list('latlon', 0, 1), # cannot occur - zero radius with latlon type
    ### list('latlon', 0, 100), # cannot occur - zero radius with latlon type
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

  test <-   data.table::rbindlist(test, fill = TRUE, use.names=FALSE)
  colnames(test) <- pnames
  ############## #

  expect_no_error({
    x = checkit(test)
  }
  # , label = "test1"
  )
})
# > checkit(test)

############################## #   ############################## #

test_that("ejam_uniq_id ok", {

  pnames   <- c('sitetype', 'radius', 'nsites'
                , 'ejam_uniq_id'
                , 'linefeed'
                # , 'lat', 'lon'
  )
  test <- test1_with_id <- list(
    ## now with IDs

    # list('latlon', 0, 1, ejam_uniq_id = 73, linefeed=". "), # cannot occur - zero radius with latlon type
    # list('latlon', 0, 100), # cannot occur - zero radius with latlon type
    list('latlon', 3, 1, ejam_uniq_id = 73, linefeed=". "),
    list('latlon', 3, 100, ejam_uniq_id = 100, linefeed=". "),

    list('fips', 0, 1, ejam_uniq_id = 1, linefeed=". "),
    list('fips', 0, 100, ejam_uniq_id = 10001, linefeed=". "),
    # list('fips', 3, 1), # cannot occur - nonzero radius with fips type
    # list('fips', 3, 100), # cannot occur - nonzero radius with fips type
    # list( NA, '99 miles', 'seven sites'),  # fails if NA

    list('shp', 0, 1, ejam_uniq_id = 73, linefeed=". "),
    list('shp', 0, 100, ejam_uniq_id = 100, linefeed=". "),
    list('shp', 3, 1, ejam_uniq_id = 73, linefeed=". "),
    list('shp', 3, 100, ejam_uniq_id = 100, linefeed=". "),

    list('farm',              '99 miles',          'seven', ejam_uniq_id = 7, linefeed=". "),    ## *** it fails to know how to pluralize user-provided custom term
    list( "Georgia location", '9.9 kilometers',    "several", ejam_uniq_id = 3, linefeed=". "),  ## *** it fails to know how to pluralize user-provided custom term, "location" here
    list('study area',    "close proximity to",  100, ejam_uniq_id = 100, linefeed=". "),    ## *** it fails to know how to pluralize user-provided custom term, "location" here

    list('Type X sitea', 3, 100, ejam_uniq_id =  100, linefeed=". ")
  )

  test <- data.table::rbindlist(test, fill = TRUE, use.names=FALSE)
  colnames(test) <- pnames

  expect_no_error({
    suppressWarnings({
      x = checkit(test)
    })
  })

  #  x


  expect_equal(
    x$text[3],
    "Residents within this specified state. (Alabama, FIPS 1)"
  )
  expect_equal(
    x$text[5],
    "Residents within this specified polygon. (ejam_uniq_id 73)"
  )

})
############################## #   ############################## #

### PROBLEM CASES

test_that("pluralize, 'within', empty sitetype or nsites", {

  pnames   <- c('sitetype', 'radius', 'nsites'
                # , 'ejam_uniq_id'
                # , 'lat', 'lon'
  )

  test <- test2 <- list(

    # fix/note singular/plural

    list('Type X facility', 3, 100),   # facilitys
    list('Type X facilities', 3, 100), # facilitiess

    # fix "within"

    list('study location', "at", 100),       # within at mile of
    list('Delaware Counties', "within", 3),  # within within mile of

    # fix "" cases

    list( "Georgia location", '9.9 kilometers', ""), # within 9.9 kilometers mile of any of the georgia location
    list( "", '9.9 kilometers', "several") # within 9.9 kilometers mile of any of the several s

  )

  test <- data.table::rbindlist(test, fill = TRUE, use.names=FALSE)
  colnames(test) <- pnames

  ############################## #
  expect_no_error({
    expect_no_warning({
      x = checkit(test)
    })
  })
})
############################## #   ############################## #

### PROBLEM CASES

test_that("warns if radius is empty", {

  pnames   <- c('sitetype', 'radius', 'nsites'
                # , 'ejam_uniq_id'
                # , 'lat', 'lon'
  )

  test <- test2 <- list(

    ### cause warnings because radius is ''
    list( "Georgia location", '', "several"), # within any of the several georgia locations
    list('', '', '')  # Residents within any of the
  )

  test <- data.table::rbindlist(test, fill = TRUE, use.names=FALSE)
  colnames(test) <- pnames

  ############################## #
  expect_no_error({
    expect_warning({
      x = checkit(test[1,])
    }, regexp = '.*radius should not be NA.*')
  })
  expect_no_error({
    expect_warning({
      x = checkit(test[2,])
    }, regexp = '.*radius should not be NA.*')
  })

})
############################## #   ############################## #


test_that("NA params ok", {

  pnames   <- c('sitetype', 'radius', 'nsites'
                # , 'ejam_uniq_id'
                # , 'lat', 'lon'
  )
  test <- test3 <- list(

    #   na values
    list(     NA,   3, 100),
    list('latlon', NA, 100),
    list('latlon',  3, NA)
  )

  test <- data.table::rbindlist(test, fill = TRUE, use.names=FALSE)
  colnames(test) <- pnames

  ############################## #
  # ## but not useful results if NA
  # sitetype radius nsites                                                    text
  # 1     <NA>      3    100       Residents within 3 miles of any of the 100 places
  # 2   latlon     NA    100         Residents within any of the 100 selected points
  # 3   latlon      3     NA Residents within 3 miles of any of the  selected points

  expect_no_error({
    expect_warning({
      x = checkit(test[1,])
    }, regexp = '.*sitetype should not be NA.*')
  })

  expect_no_error({
    expect_warning({
      x = checkit(test[2,])
    }, regexp = '.*radius should not be NA.*')
  })

  expect_no_error({
    expect_warning({
      x = checkit(test[3,])
    }, regexp = '.*nsites should not be NA.*')
  })

})
########################################################################### #
########################################################################### #

test_that("ok if missing sitetype or radius or nsites", {

  expect_no_error({
    report_residents_within_xyz(
      # omit sitetype
      radius = 3,
      nsites=100)
  })

  expect_no_error({
    report_residents_within_xyz(
      sitetype = 'latlon',
      #  omit radius
      nsites=100)
  })

  expect_no_error({
    report_residents_within_xyz(
      sitetype = 'latlon',
      radius = 3
      # omit nsites
    )
  })

})
########################################################################### #

test_that("OK if zero radius", {

  expect_no_error({
    report_residents_within_xyz(
      sitetype = 'latlon',
      radius = 0,
      nsites=100)
  })
})
########################################################################### #
########################################################################### #

## note treatment of NULL values is not consistent here across parameters:  ***


########################################################################### #

test_that("no error, no warn, if NULL radius", {

  expect_no_error({
    report_residents_within_xyz(
      sitetype = 'latlon',
      radius = NULL,
      nsites=100)
  })
})
########################################################################### #

test_that("warn but not error, if NULL nsites", {

  expect_no_error({
    expect_warning({
      report_residents_within_xyz(
        sitetype = 'latlon',
        radius = 3,
        nsites = NULL
      )
    }, regexp = 'nsites can be >1 but must be a single number not a vector or empty')
  })
})
########################################################################### #

test_that("ERROR, if NULL sitetype", {

  ## SETTING IT TO NULL CAUSES AN ERROR ACTUALLY

  expect_error({
    report_residents_within_xyz(
      sitetype = NULL,
      radius = 3,
      nsites=100)
  })

})
########################################################################### #
########################################################################### #

rm(checkit)

############################## #   ############################## #

##  FIPS cases :

# report_residents_within_xyz(sitetype = 'fips') # ok
#
# report_residents_within_xyz(sitetype = 'fips',             sitenumber = 1) # ok
# report_residents_within_xyz(sitetype = 'fips', nsites = 1, sitenumber = 3) # ok, but *** if nsites really is how many rows, and if sitenumber tells which row, should s>n be an error or warning maybe? ***
# report_residents_within_xyz(sitetype = 'fips', nsites = 3) # ok, at any of the 3
# report_residents_within_xyz(sitetype = 'fips', nsites = 3, sitenumber = 1) # ignores sitenumber if nsites>1! should it warn its unclear? or say, "site 1 of 3"? ***
# report_residents_within_xyz(sitetype = 'fips', nsites = 3, sitenumber = 2) # ignores sitenumber if nsites>1! should it warn its unclear? or say, "site 2 of 3"? ***
#
# report_residents_within_xyz(sitetype = 'fips', ejam_uniq_id = 10001)
# report_residents_within_xyz(sitetype = 'fips', ejam_uniq_id = 10001, nsites = 1)
# report_residents_within_xyz(sitetype = 'fips', ejam_uniq_id = 10001, nsites = 1, sitenumber = 1)  # ok
# report_residents_within_xyz(sitetype = 'fips', ejam_uniq_id = 10001, nsites = 3, sitenumber = 2)  ## ignores sitenumber if nsites>1! should it warn its unclear? or say, "site 2 of 3"? ***
#
# report_residents_within_xyz(sitetype = 'fips', ejam_uniq_id = 10001, sitenumber = 1)     # ok
# report_residents_within_xyz(sitetype = 'fips', ejam_uniq_id = 10001, sitenumber = 3)     # ok

test_that("fips identified as counties", {
  expect_equal(
    report_residents_within_xyz(sitetype = 'fips', ejam_uniq_id = 10001, nsites = 3),         # ok
    "Residents within any of the 3 specified counties"
  )
  expect_equal(
    report_residents_within_xyz(sitetype = 'fips', ejam_uniq_id = 10001),
    "Residents within this specified county<br>(Kent County, DE, FIPS 10001)"
  )
})

# report_residents_within_xyz(sitetype = 'fips', ejam_uniq_id = 10001, nsites = 3, census_unit_type = "County")  # ignores census_unit_type = 'counties' but 'County' is OK

## if bad FIPS, and didnt use quiet=T inside report_residents_within_xyz, get warning: NA returned for 1 values that failed to match
# report_residents_within_xyz(sitetype = 'fips', ejam_uniq_id = 73, sitenumber = 1) # ok

############################## #   ############################## #

## handling NA values is OK:
test_that("NA values warn", {

  expect_warning({
    report_residents_within_xyz(sitetype = NA)
  })
  expect_warning({
    report_residents_within_xyz(radius   = NA)
  })
  expect_warning({
    report_residents_within_xyz(nsites   = NA)
  })
  expect_warning(expect_warning(expect_warning({ # 1 warning for each NA value here
    report_residents_within_xyz(sitetype = NA, radius = NA, nsites = NA)
  })))
  expect_warning({
    report_residents_within_xyz(sitetype = NA, radius = 3, nsites = 100)
  })
  expect_warning({
    report_residents_within_xyz(sitetype = 'latlon', radius = NA, nsites = 2)
  })
  expect_warning({
    report_residents_within_xyz(sitetype = 'latlon', radius = 3, nsites = NA)
  })
})
############################## #   ############################## #

########################################################################### #
## check the function  report_residents_within_xyz_from_ejamit()
########################################################################### #
if (FALSE) {

  library(EJAM)

  x = function(out){
    print(report_residents_within_xyz_from_ejamit(out))
    print(report_residents_within_xyz_from_ejamit(out, linefeed = ". "))
    print(report_residents_within_xyz_from_ejamit(out, sitenumber = 1))
    print(report_residents_within_xyz_from_ejamit(out, sitenumber = 2))
    print(report_residents_within_xyz_from_ejamit(out, sitenumber = 2, addlatlon=F))
    print(report_residents_within_xyz_from_ejamit(out,                 ejam_uniq_id=999)) # ignored since multisite report
    print(report_residents_within_xyz_from_ejamit(out, sitenumber = 2, ejam_uniq_id=999))
    print(report_residents_within_xyz_from_ejamit(out, sitenumber = 2, ejam_uniq_id = "Jones Mill Site"))
    print(report_residents_within_xyz_from_ejamit(out, nsites = "approx. 500", linefeed = ". "))
    print(report_residents_within_xyz_from_ejamit(out, text1 = "REPORT ON SITES WITHIN ", linefeed = ". "))
    print(report_residents_within_xyz_from_ejamit(out, sitenumber = 2, show_fips_name = TRUE))
    print(report_residents_within_xyz_from_ejamit(out, sitenumber = 2, show_fips_name = TRUE, ejam_uniq_id = "THIS PLACE"))
    print(report_residents_within_xyz_from_ejamit(out, sitenumber = 2, show_fips_name = TRUE, ejam_uniq_id = 999))
  }
  x(testoutput_ejamit_100pts_1miles)
  x(testoutput_ejamit_fips_cities)


  out = testoutput_ejamit_100pts_1miles
  # out = testoutput_ejamit_fips_cities

  ejam2report(out, sitenumber = 6)
  # report_residents_within_xyz_from_ejamit(out, sitenumber = "THIS ONE SITE")  # error - must be numeric
  ejam2report(out, sitenumber = "asdfasd;flkjaf") # warnings about latlon invalid point but no warning about bad sitenumber. just ignores it.

  ## shows how report title and analysis title depend on if 1-site or multisite and if FIPS or not:
  ejam2report(testoutput_ejamit_10pts_1miles )
  ejam2report(testoutput_ejamit_10pts_1miles, sitenumber = 2)
  ejam2report(testoutput_ejamit_fips_cities )
  ejam2report(testoutput_ejamit_fips_cities, sitenumber = 2)


  ejamapp(sitepoints = testpoints_10, radius = 3.14, analysis_title = "Custom Analysis")

  ejamapp(fips = testinput_fips_counties)


}
