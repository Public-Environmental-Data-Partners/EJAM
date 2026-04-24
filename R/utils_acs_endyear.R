
##################### #
# utility to show ACS 5-year survey as range of years like "2020-2024"
acs_yr_range <- function(end.year, parens = FALSE) {
  txt <- paste0(as.character(as.numeric(end.year) - 4), "-", end.year)
  if (parens) {
    txt <- paste0("(", txt, ")")
  }
  return(txt)
}
##################### #
# helper function

acs_endyr_estimation <- function(guess_as_of, endyrs, lag_yrs_endyr_to_available) {

  guess_as_of <- acs_clean_date(guess_as_of)
  enddays <- as.Date(paste0(endyrs, "-12-31"))
  approx_publish_dates <- enddays  + 365 * lag_yrs_endyr_to_available
  # use latest ACS period that has publish day that already happened before guess_as_of day
  if (sum(approx_publish_dates < guess_as_of) == 0) {
    likely_already_published_yr <- NA
    stop("cannot estimate any already published ACS data because guess_as_of is before the first publish date of any ACS 5-year survey data recognized by this function")
  } else {
    lastendday <- max(enddays[approx_publish_dates < guess_as_of])
    likely_already_published_yr <- substr(lastendday, 1, 4)
    if (likely_already_published_yr == max(endyrs)) {
      warning("cannot estimate any ACS end year later than ", max(endyrs), " using this function")
    }
  }
  return(likely_already_published_yr)
}
##################### #
# what is the latest ACS published (as of now, or some specified asof date)?
# returns the end year of the 5 year summary file that was most recently published by Census Bureau

acs_endyr_latest_published_by_census = function(guess_as_of = Sys.Date(), lag_yrs_endyr_to_available = 0.95) {

  endyrs <- 2010:2040

  # lag_yrs_endyr_to_available is the number of years from the last day of the survey period to the day that
  #  ACS as published by Census Bureua gets updated with that data.
  # 0.945 yrs was typical lag for ACS, 0.945 = 1- 20/365 was lag in yrs, ie had been 365 days minus about 20 days, ie December 11 or so.
  # 1.08 yrs was lag for 2020-2024 ACS, though. Based on actual release of 2020-2024 data in 1/29/2026, lag was more like 365+29=394 days or 1.08 yrs

  likely_already_published_yr <- acs_endyr_estimation(guess_as_of = guess_as_of, endyrs = endyrs, lag_yrs_endyr_to_available = lag_yrs_endyr_to_available)

  # regardless of typical lags, based on published schedules and actual release at end of 2024, we know the 2019-2023 data are the ACS data available during almost all of 2025:
  if (guess_as_of >= "2023-12-07") {likely_already_published_yr <- "2022"}  #  https://www.census.gov/programs-surveys/acs/news/data-releases/2022/release-schedule.html
  if (guess_as_of >= "2024-12-12") {likely_already_published_yr <- "2023"}  #  "https://www.census.gov/programs-surveys/acs/news/data-releases/2023/release-schedule.html"
  if (guess_as_of >= "2026-01-29") {likely_already_published_yr <- "2024"}  # delayed. See "https://www.census.gov/programs-surveys/acs/news/data-releases/2024/release-schedule.html"
  #  if (guess_as_of >= "2026-12-12") {likely_already_published_yr <- "2025"}  # See https://www.census.gov/programs-surveys/acs/news/data-releases.html

  # we could even validate that guess by checking the website. see ACSdownload pkg function validate.end.year() ***
  message(paste0("As of ", guess_as_of,", ", acs_yr_range(likely_already_published_yr, parens = FALSE),
                 " ACS data is likely to have been released by Census Bureau (in December ", as.numeric(likely_already_published_yr) + 1,")."))
  return(likely_already_published_yr)
}
##################### #
# what is the latest ACS that has been included in EJAM/EJSCREEN (as of now, or some specified date)?
# returns the end year of the 5 year summary file that was most recently used by EJAM/EJSCREEN

acs_endyr_latest_published_by_ejscreen = function(guess_as_of = Sys.Date(), lag_yrs_endyr_to_available = 1.6) {

  endyrs <- 2015:2040

  # lag_yrs_endyr_to_available is the number of years from the last day of the survey period to the day that
  #   EJSCREEN/EJAM gets updated with that data.
  # 1.6 yrs was typical lag for EJSCREEN. Lag to census publishing was around 1 yr, and EJSCREEN was using that by June-August after that, lag was roughly 1.6 to 1.7 yrs

  likely_already_published_yr <- acs_endyr_estimation(guess_as_of = guess_as_of, endyrs = endyrs, lag_yrs_endyr_to_available = lag_yrs_endyr_to_available)

  # regardless of typical lags, all of 2025 will have used the 2022 acs since no update to 2023 was done in mid or even late 2025, at least as of November 2025.
  if (guess_as_of >= "2024-08-01") {likely_already_published_yr <- "2022"}  # ejscreen released in july and updated in august 2024 used acs2022
  # if (guess_as_of == "2026-05-31") {likely_already_published_yr <- "2023"} # skipped this release, so not really used, but that version of ACS could be made available by EJAM also
  if (guess_as_of >= "2026-06-01") {likely_already_published_yr <- "2024"}    ## ASSUMES RELEASE OF EJAM/EJSCREEN circa that date  ***
  if (guess_as_of >= "2027-03-01") {likely_already_published_yr <- "2025"}  # ASSUMING AN UPDATE IS RELEASED ON THAT DATE

  message(paste0("As of ", guess_as_of,", ", acs_yr_range(likely_already_published_yr, parens = FALSE),
                 " ACS data is likely to have been incorporated into EJAM/EJSCREEN."))
  return(likely_already_published_yr)
}
##################### #

acs_clean_date = function(x) {

  # convert to a date the input that can be Date class or text of a date in 2 possible formats or just the year

  if (length(x) > 1) {stop("x must be a single date")}
  if ("Date" %in% class(x)) {
    tried <- x
  } else {
    if (is.character(x) || is.numeric(x)) {
      # try to interpret just text date or just year
      suppressWarnings({
        tried = lubridate::ymd(x)
      })
      if (is.na(tried)) {
        suppressWarnings({
          tried = lubridate::mdy(x)
        })
      }
      if (is.na(tried)) {
        if (nchar(x) == 4 && grepl("^[0-9]+$", x)) {
          tried <- as.Date(paste0(x, "-01-01"))
          if (as.numeric(x) < 2000 || as.numeric(x) > 2050) {
            # will warn later about date outside range so skip this warning here
          } else {
            warning("Only the year was specified, so assuming that means ", as.character(tried))
          }
        }
      }
      if (is.na(tried)) {
        # try as.Date() just in case that works
        tried <- try({as.Date(x)}, silent = TRUE)
        if (inherits(tried, "try-error")) {
          tried <- NA
        }
      }
    } else {
      tried <- NA
    }
  }
  if (is.na(tried)) {
    warning('x parameter was not a valid date so it was ignored -- using today')
    x <- Sys.Date()
  } else {
    if (lubridate::year(tried) < 2000 || lubridate::year(tried) > 2050) {
      warning("Date is outside range of years allowed -- using today")
      tried <- Sys.Date()
    }
    x <- tried
  }
  return(x)
}
##################### #

#' check which ACS 5-year survey is available from Census Bureau or in EJAM/EJSCREEN
#'
#' @param guess_as_of optional alternative date to use if guessing what is available
#'  as of this date, e.g., "2025-01-01" -- Date class like Sys.Date()
#' @param guess_always optional, set TRUE to ignore metadata and just guess at year.
#'  But guess_always=F is ignored if guess_census_has_published=T
#'
#' @param guess_census_has_published optional, set to TRUE to guess what is the latest
#'  end year of 5yr ACS data that Census Bureau has published on their summary file site,
#'  rather than guessing what the EJAM package has already incorporated from there.
#'  Setting this TRUE will return an earlier year than if FALSE, usually, given the lag
#'  from Census Bureau publishing to EJAM incorporating.
#'  If this is set TRUE, then the guess_always parameter is ignored.
#'
#' @param lag_yrs_endyr_to_census_publishes years to assume lag between end of endyear and when Census Bureau releases ACS dataset for 5yr summary file
#' @param lag_yrs_endyr_to_ejscreen years to assume lag between end of endyear and when ejscreen gets updated with ACS data
#' @details
#'  This function can report what the package metadata says is the version of ACS data in the package,
#'  or it can guess what version is published by Census Bureau or is incorporated into EJAM/EJSCREEN,
#'  based on actual recent release dates or typical lags from survey to release by Census or in EJSCREEN.
#'
#'  Census Bureau provides yearly release schedules for ACS data:
#'
#'  - The [2020-2024 ACS data](https://www.census.gov/programs-surveys/acs/news/data-releases/2024/release-schedule.html) normally would be released by Census Bureau 12/11/2025, but release was delayed until January 29, 2026.
#'
#'  - The [2019-2023 ACS data](https://www.census.gov/programs-surveys/acs/news/data-releases/2023/release-schedule.html) were published by Census Bureau 12/12/2024.
#'
#'  - The [2018-2022 ACS data](https://www.census.gov/programs-surveys/acs/news/data-releases/2022/release-schedule.html) were published by Census Bureau 12/7/2023.
#'
#'
#'  EJSCREEN has incorporated ACS data in new releases of EJSCREEN on a more complicated schedule since 2024.
#'  See [ejanalysis.com/status](https://ejanalysis.com/status)
#'
#'  - The 2020-2024 ACS data may be in non-EPA versions of EJAM / EJSCREEN starting around mid 2026.
#'
#'  - The 2019-2023 ACS data were never used in EJSCREEN / EJAM, because in 2025 EPA stopped updating the tool and data.
#'
#'  - The 2018-2022 ACS data were used in EJSCREEN / EJAM starting in mid/late 2024.
#'
#' @return a single year like "2022", meaning ACS5 survey data covering 2018-2022,
#'   released by Census Bureau 12/2023, updated in EJSCREEN in mid/late 2024.
#'
#' @export
#'
acs_endyear <- function(guess_as_of = Sys.Date(), guess_always = FALSE, guess_census_has_published = FALSE,
                        lag_yrs_endyr_to_census_publishes = 0.95,
                        lag_yrs_endyr_to_ejscreen = 1.6
) {

  if (guess_census_has_published) {
    if (!guess_always) {
      guess_always <- TRUE
      message("guess_census_has_published=TRUE and guess_always=FALSE, so guess_always=FALSE is being ignored")
    }
  }

  # lag_yrs_endyr_to_census_publishes
  # 0.945 yrs was typical lag for ACS, 0.945 = 1- 20/365 was lag in yrs, ie had been 365 days minus about 20 days, ie December 11 or so.
  # 1.08 yrs was lag for 2020-2024 ACS, though. Based on actual release of 2020-2024 data in 1/29/2026, lag was more like 365+29=394 days or 1.08 yrs

  # lag_yrs_endyr_to_ejscreen
  # 1.6 yrs was typical lag for EJSCREEN. Lag to census publishing was around 1 yr, and EJSCREEN was using that by June-August after that, lag was roughly 1.6 to 1.7 yrs

  if (!guess_always) {

    # if !guess_always, try metadata approach first, and then only if metadata approach fails, try to use guess_as_of
    #  try use year that was in metadata that should record/report the years of the ACS data currently being used.
    ejscreen_says_it_uses_yr <- as.vector(gsub("^....-", "", get_metadata_mapping()$acs_version)) # unexported func in EJAM
    if (length(ejscreen_says_it_uses_yr) == 0 || is.null(ejscreen_says_it_uses_yr)) {
      warning("Cannot find metadata that reports the year being used, so trying to guess at what years might be available in the package vs from Census Bureau ACS 5-year survey data.")
    }
  }

  if (!(guess_always || length(ejscreen_says_it_uses_yr) == 0 || is.null(ejscreen_says_it_uses_yr))) {

    return(ejscreen_says_it_uses_yr)

  } else {

    # if guess_always, do not try metadata approach at all, just try to use guess_as_of
    guess_as_of <- acs_clean_date(guess_as_of)

    likely_already_published_yr <- acs_endyr_latest_published_by_census(
      guess_as_of, lag_yrs_endyr_to_available = lag_yrs_endyr_to_census_publishes
    )
    if (guess_census_has_published) {
      # use guess of what Census Bureau has published (rather than what EJSCREEN has incorporated which might be different)
      return(likely_already_published_yr)
    } else {
      # use guess of what EJSCREEN had incorporated
      ejscreen_uses_yr <- acs_endyr_latest_published_by_ejscreen(guess_as_of = guess_as_of, lag_yrs_endyr_to_available = lag_yrs_endyr_to_ejscreen)
      return(ejscreen_uses_yr)
    }
  }
}
