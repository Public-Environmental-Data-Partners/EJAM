############################################################################################ #

testthat::test_that("acs_endyear ok", {

  testthat::expect_no_error({
    junk = capture.output({
      suppressMessages({

        acs_endyear()

        x = acs_endyear(as.Date("2026-02-01"), guess_always = TRUE)
        expect_equal(x, "2022") # still used only acs2022 as of start of 2026

        x = acs_endyear("2026-02-02", guess_census_has_published = TRUE, guess_always = FALSE)
        expect_equal(x, "2024") # census published acs2024 by then

        x1 = acs_endyear("2024-10-01", guess_census_has_published = TRUE, guess_always = FALSE)
        x2 = acs_endyear("2024-10-01", guess_census_has_published = FALSE, guess_always = TRUE)
        expect_equal(x1, x2)

        acs_endyear(guess_always = TRUE)
        # acs_endyear(Sys.Date(), guess_always = TRUE)


        acs_endyear(as.Date("2021-01-01")) # reports what pkg metadata says, and IGNORES the asof date provided
        acs_endyear(as.Date("2021-01-01"), guess_always = TRUE) # different answer
        acs_endyear("2021-01-01")
        acs_endyear("2021-01-01", guess_always = TRUE)

      })
    })
  })

  suppressMessages({
    # can just specify year not date for the "as of" date
    acs_endyear("2021") # no warning if not guessing date since as of date is ignored
    expect_warning({
      x1 =  acs_endyear("2021", guess_always = TRUE)
    })
    expect_no_warning({
      x2 = acs_endyear(as.Date("2021-01-01"), guess_always = TRUE)
    })
    expect_equal(x1, x2) # specifying as of year or as of date as Jan 1 means same thing

    # acs_endyear(as.Date("2027-01-01"), guess_always = TRUE)

    expect_warning({
      # bad year
      acs_endyear(as.Date("2099-01-01"), guess_always = TRUE)
    })
  })

})
############################################################################################ #

testthat::test_that("acs_clean_date good dates ok", {

  testthat::expect_no_error({
    ## good dates ----------------------------------- -

    y = acs_clean_date(as.Date("2025-01-23"))
    # print(paste0(as.Date("2025-01-23"), " --> ", y))

    for (yr in c(  2000,2050 )) {
      expect_warning({
        x = acs_clean_date(yr)
      })
      # print(paste0(yr, " as number --> ", x))
      expect_warning({
        x = acs_clean_date(as.character(yr))
      })
      # print(paste0(as.character(yr), " as text   --> ", x  ))
    }

    for (x in c("2025-01-23", "1/20/2019", "01/6/2025", "1/15/23")) {
      y = acs_clean_date(x)
      # print(paste0(x, " --> ", y))
    }

  })

})
############################################################################################ #

testthat::test_that("acs_clean_date bad dates ok", {

  ## bad dates ----------------------------------- -

  for (yr in c(1999,   2051)) {

    testthat::expect_warning({
      x = acs_clean_date(yr)
    })
    # print(paste0(yr, " as number --> ", x))
    testthat::expect_warning({
      x = acs_clean_date(as.character(yr))
    })
    testthat::expect_equal(
      x,
      Sys.Date()
    )

    # print(paste0(as.character(yr), " as text   --> ", x))
  }

  for (x in c("2021-99-00", "1999-01-01", "9/99/2010",  "5/2026")) {
    testthat::expect_warning({
      y = acs_clean_date(x)
    })
    # print(paste0(x, " --> ", y))
    testthat::expect_equal(
      y,
      Sys.Date()
    )
  }

  for (x in c( NA, "", "xyz", 3)) {
    testthat::expect_warning({
      y = acs_clean_date(x)
    })
    # print(paste0(x, " --> ", y))
  }
  testthat::expect_warning({
    y =  acs_clean_date(NULL)
  })
  # print(paste0("a NULL input", " --> ", y))

})
############################################################################################ #
############################################################################################ #



# check  acs_clean_date()

if (FALSE) {
  ## good dates ----------------------------------- -

  print(paste0(as.Date("2025-01-23"), " --> ", acs_clean_date(as.Date("2025-01-23"))))

  for (yr in c(  2000,2050 )) {
    print(paste0(yr, " as number --> ", acs_clean_date(yr)))
    print(paste0(as.character(yr), " as text   --> ", acs_clean_date(as.character(yr))))
  }

  for (x in c("2025-01-23", "1/20/2019", "01/6/2025", "1/15/23")) {
    print(paste0(x, " --> ", acs_clean_date(x)))
  }

  ## bad dates ----------------------------------- -

  for (yr in c(1999,   2051)) {
    print(paste0(yr, " as number --> ", acs_clean_date(yr)))
    print(paste0(as.character(yr), " as text   --> ", acs_clean_date(as.character(yr))))
  }

  for (x in c("2021-99-00", "1999-01-01", "9/99/2010",  "5/2026")) {
    print(paste0(x, " --> ", acs_clean_date(x)))
  }

  for (x in c( NA, "", "xyz", 3)) {
    print(paste0(x, " --> ", acs_clean_date(x)))
  }

  print(paste0("a NULL input", " --> ", acs_clean_date(NULL)))

}
############################################################################################ #

##   CHECK IF acs_endyear() IS REPORTING THE CORRECT ACS VERSION BASED ON PUBLICATION DATE

if (FALSE) {
  check_acs_endyear = function(fromdate = "2020-01-01", todate = "2026-12-01", quiet = TRUE) {

    out = list()
    i = 0
    for (asof in seq(as.Date(fromdate), as.Date(todate), by = "1 month")) {
      i = i + 1
      asof = as.Date(asof)
      if (quiet) {
        captured <- capture.output({
          suppressMessages({
            endyr_PUBLISHED   <- acs_endyear(asof, guess_always = TRUE, guess_census_has_published=TRUE)
          })
        })
        captured2 <- capture.output({
          suppressMessages({
            endyr_in_ejscreen <- acs_endyear(asof, guess_always = TRUE, guess_census_has_published=FALSE)
          })
        })
      } else {
        captured <- capture.output({
          endyr_PUBLISHED   <- acs_endyear(asof, guess_always = TRUE, guess_census_has_published=TRUE)
        })
        captured2 <- capture.output({
          suppressMessages({ # because it is redundant
            endyr_in_ejscreen <- acs_endyear(asof, guess_always = TRUE, guess_census_has_published=FALSE)
          })
        })

      }
      cat(paste0("As of ", as.character(asof), " latest published by Census is ACS ", endyr_PUBLISHED, ". EJSCREEN probably has ACS ", endyr_in_ejscreen, "."),  "\n")
      if (!quiet) {
        cat("------------------------- ", captured, "\n")
        # cat(" ", captured2, "\n")
      } else {
        captured <- captured2 <- NULL
      }
      out[[i]] = data.frame(asof=asof, published_acs_endyr = endyr_PUBLISHED, ejscreen_has_acs_endyr= endyr_in_ejscreen)
    }
    out = do.call(rbind, out)
    # print(out)
    return(out)
  }

  ############################################################################################ #

  #      out = check_acs_endyear()

  out <- check_acs_endyear(fromdate = "2023-01-01", todate = "2026-12-01")
  cbind(out, EJSCREEN_has_latest_available_from_Census = ifelse(
    out$published_acs_endyr == out$ejscreen_has_acs_endyr, "yes",
    paste0("No, lags behind Census Bureau by ",
           as.numeric(out$published_acs_endyr) - as.numeric(out$ejscreen_has_acs_endyr),
           " years")))
}
#          asof published_acs_endyr ejscreen_has_acs_endyr EJSCREEN_has_latest_available_from_Census

# 1  2023-01-01                2021                   2020  No, lags behind Census Bureau by 1 years
# 2  2023-02-01                2021                   2020  No, lags behind Census Bureau by 1 years
# 3  2023-03-01                2021                   2020  No, lags behind Census Bureau by 1 years
# 4  2023-04-01                2021                   2020  No, lags behind Census Bureau by 1 years
# 5  2023-05-01                2021                   2020  No, lags behind Census Bureau by 1 years
# 6  2023-06-01                2021                   2020  No, lags behind Census Bureau by 1 years
# 7  2023-07-01                2021                   2020  No, lags behind Census Bureau by 1 years
# 8  2023-08-01                2021                   2020  No, lags behind Census Bureau by 1 years

# 9  2023-09-01                2021                   2021                                       yes
# 10 2023-10-01                2021                   2021                                       yes
# 11 2023-11-01                2021                   2021                                       yes
# 12 2023-12-01                2021                   2021                                       yes

# 13 2024-01-01                2022                   2021  No, lags behind Census Bureau by 1 years
# 14 2024-02-01                2022                   2021  No, lags behind Census Bureau by 1 years
# 15 2024-03-01                2022                   2021  No, lags behind Census Bureau by 1 years
# 16 2024-04-01                2022                   2021  No, lags behind Census Bureau by 1 years
# 17 2024-05-01                2022                   2021  No, lags behind Census Bureau by 1 years
# 18 2024-06-01                2022                   2021  No, lags behind Census Bureau by 1 years
# 19 2024-07-01                2022                   2021  No, lags behind Census Bureau by 1 years

# 20 2024-08-01                2022                   2022                                       yes
# 21 2024-09-01                2022                   2022                                       yes
# 22 2024-10-01                2022                   2022                                       yes
# 23 2024-11-01                2022                   2022                                       yes
# 24 2024-12-01                2022                   2022                                       yes

# 25 2025-01-01                2023                   2022  No, lags behind Census Bureau by 1 years
# 26 2025-02-01                2023                   2022  No, lags behind Census Bureau by 1 years
# 27 2025-03-01                2023                   2022  No, lags behind Census Bureau by 1 years
# 28 2025-04-01                2023                   2022  No, lags behind Census Bureau by 1 years
# 29 2025-05-01                2023                   2022  No, lags behind Census Bureau by 1 years
# 30 2025-06-01                2023                   2022  No, lags behind Census Bureau by 1 years
# 31 2025-07-01                2023                   2022  No, lags behind Census Bureau by 1 years
# 32 2025-08-01                2023                   2022  No, lags behind Census Bureau by 1 years
# 33 2025-09-01                2023                   2022  No, lags behind Census Bureau by 1 years
# 34 2025-10-01                2023                   2022  No, lags behind Census Bureau by 1 years
# 35 2025-11-01                2023                   2022  No, lags behind Census Bureau by 1 years
# 36 2025-12-01                2023                   2022  No, lags behind Census Bureau by 1 years
# 37 2026-01-01                2023                   2022  No, lags behind Census Bureau by 1 years

# 38 2026-02-01                2024                   2022  No, lags behind Census Bureau by 2 years
# 39 2026-03-01                2024                   2022  No, lags behind Census Bureau by 2 years
# 40 2026-04-01                2024                   2022  No, lags behind Census Bureau by 2 years
# 41 2026-05-01                2024                   2022  No, lags behind Census Bureau by 2 years


############################################################################################ #
## other  checks
if (FALSE) {


  acs_endyear(as.Date("2026-01-01"), guess_always = TRUE)

  acs_endyear()
  acs_endyear(guess_always = TRUE)
  acs_endyear(Sys.Date(), guess_always = TRUE)

  acs_endyear(as.Date("2021-01-01"))
  acs_endyear(as.Date("2021-01-01"), guess_always = TRUE)

  acs_endyear("2021-01-01")
  acs_endyear("2021-01-01", guess_always = TRUE)

  acs_endyear("2021")
  acs_endyear("2021", guess_always = TRUE)

  acs_endyear(as.Date("2027-01-01"), guess_always = TRUE)
  acs_endyear(as.Date("2099-01-01"), guess_always = TRUE)


}
############################################################################################ #
