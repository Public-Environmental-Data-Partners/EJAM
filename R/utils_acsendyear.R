
######################
acs_yr_range <- function(end.year, parens = FALSE) {
  txt <- paste0(as.character(as.numeric(end.year) - 4), "-", end.year)
  if (parens) {
    txt <- paste0("(", txt, ")")
  }
  return(txt)
}
######################


#' check which ACS 5-year survey is available, per EJAM metadata or guessed via published or typical schedules
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
#' - The 2020-2024 data should be released by Census Bureau 12/11/2025.
#'
#' - The 2019-2023 data were published by Census Bureau 12/12/2024, but were not yet in EJSCREEN as of late 2025.
#'
#' - The 2018-2022 data were published by Census Bureau 12/7/2023, in EJSCREEN mid/late 2024.
#'
#'  See schedules such as <https://www.census.gov/programs-surveys/acs/news/data-releases/2024/release-schedule.html>
#'
#' @returns a single year like "2022", meaning ACS5 survey data covering 2018-2022,
#'   released by Census Bureau 12/2023, updated in EJSCREEN in mid/late 2024.
#'
#' @keywords internal
#'
acsendyear <- function(guess_as_of = Sys.Date(), guess_always = FALSE, guess_census_has_published = FALSE,
                       lag_yrs_endyr_to_census_publishes = 0.9452055, # 1- 20/365
                       lag_yrs_endyr_to_ejscreen = 1.6
                       ) {

if (guess_census_has_published) {
  if (!guess_always) {
    guess_always <- TRUE
    warning("guess_census_has_published=TRUE and guess_always=FALSE, so guess_always is being ignored")
  }
}

  # lag_yrs_endyr_to_census_publishes = 1
  ## end year (December) + 1 year (December) has been date ACS published by Census.
  # so  rounded year now minus 1 should be the endyear that is already published by Census Bureau, typically.

  # https://www.census.gov/programs-surveys/acs/news/data-releases/2024/release-schedule.html

  # lag_yrs_endyr_to_ejscreen = 1.6
  ## publication date of acs + about 6-8 months was date EJSCREEN updated to use it.
  # e.g., 2018-2022 ACS was still used until at least mid-2025 and actually it was not updating EJSCREEN after that.

  ## tests
  # acsendyear()
  # acsendyear(guess_always = TRUE)
  # acsendyear(Sys.Date(), guess_always = TRUE)
  #
  # acsendyear(as.Date("2021-01-01"))
  # acsendyear(as.Date("2021-01-01"), guess_always = TRUE)
  #
  # acsendyear("2021-01-01")
  # acsendyear("2021-01-01", guess_always = TRUE)
  #
  # acsendyear("2021")
  # acsendyear("2021", guess_always = TRUE)
  #
  # acsendyear(as.Date("2025-11-30"), guess_always = TRUE)
  # acsendyear(as.Date("2025-12-31"), guess_always = TRUE)
  #
  # acsendyear(as.Date("2026-01-01"), guess_always = TRUE)
  # acsendyear(as.Date("2026-02-01"), guess_always = TRUE)
  # acsendyear(as.Date("2026-03-01"), guess_always = TRUE)
  # acsendyear(as.Date("2026-04-01"), guess_always = TRUE)
  # acsendyear(as.Date("2026-05-01"), guess_always = TRUE)
  # acsendyear(as.Date("2026-06-01"), guess_always = TRUE)
  # acsendyear(as.Date("2026-07-01"), guess_always = TRUE)
  # acsendyear(as.Date("2026-08-01"), guess_always = TRUE)
  # acsendyear(as.Date("2026-09-01"), guess_always = TRUE)
  # acsendyear(as.Date("2026-10-01"), guess_always = TRUE)
  # acsendyear(as.Date("2026-11-01"), guess_always = TRUE)
  # acsendyear(as.Date("2026-12-01"), guess_always = TRUE)
  # acsendyear(as.Date("2026-12-31"), guess_always = TRUE)
  # acsendyear(as.Date("2027-01-01"), guess_always = TRUE)
  #
  #
  # acsendyear(as.Date("2099-01-01"), guess_always = TRUE)

  if (!guess_always) {
    # if !guess_always, try metadata approach first, and then only if metadata approach fails,
    #     try to use guess_as_of
    #
    #  try use year that was in metadata that should record/report the years of the ACS data currently being used.
    yr <- as.vector(gsub("^....-", "", get_metadata_mapping()$acs_version)) # unexported func in EJAM
    if (length(yr) == 0 || is.null(yr)) {
      warning("Cannot find metadata that reports the year being used, so trying to guess at what years might be available in the package vs from Census Bureau ACS 5-year survey data.")
    }
  }

  if (guess_always || length(yr) == 0 || is.null(yr)) {

    # if guess_always, do not try metadata approach at all, just
    #     try to use guess_as_of

    ## try to use guess_as_of

    if (is.character(guess_as_of)) {
      # try to interpret just text date or just year
      guess_as_of <- try({as.Date(guess_as_of)}, silent = TRUE)
      if (inherits(guess_as_of, "try-error")) {
        if (length(guess_as_of) && nchar(guess_as_of)[1] == 4 && guess_as_of[1] > 2019 && guess_as_of[1] < 2041) {
          guess_as_of <- as.Date(paste0(guess_as_of, "-01-01"))
          warning("Only the year was specified, so assuming that means ", as.character(guess_as_of))
        } else {
          warning('Invalid guess_as_of parameter ignored')
          guess_as_of <- Sys.Date()
        }
      }
    }
    message("Guessing based on what may be the case as of ", as.character(guess_as_of), "\n")

    likely_already_published_yr <- substr(  guess_as_of - 365 * lag_yrs_endyr_to_census_publishes, 1, 4)
    # based on published schedules and actual release at end of 2024, we know the 2019-2023 data are the ACS data available during almost all of 2025:
    if (guess_as_of <= "2025-12-11" && guess_as_of >= "2024-12-13") {likely_already_published_yr <- "2023"}
    if (guess_as_of <= "2026-12-12" && guess_as_of >= "2025-12-12") {likely_already_published_yr <- "2024"}
    # we could even validate that guess by checking the website. see ACSdownload:::validate.end.year(2023) ***
    message(paste0("As of ", guess_as_of,", it is likely that ACS data was already released (in December ", as.numeric(likely_already_published_yr) + 1,") for the 5-year survey period whose last year is ",
            likely_already_published_yr, " ", acs_yr_range(likely_already_published_yr, parens = TRUE), " but not later periods"))

    if (guess_census_has_published) {
      return(likely_already_published_yr)
    }

    yr <- substr( guess_as_of - 365 * lag_yrs_endyr_to_ejscreen, 1, 4)
    # regardless of typical lags, all of 2025 will have used the 2022 acs since no update to 2023 was done in mid or even late 2025, at least as of November 2025.
    if (guess_as_of >= "2025-01-01" && guess_as_of  < "2025-12-31") {yr <- "2022"}
    if (                               guess_as_of == "2025-12-31") {yr <- "2023"} # just for 1 day / not really used but ACS made available
    if (guess_as_of >= "2026-01-01" && guess_as_of <= "2027-12-31") {yr <- "2024"}
    # we could even validate that yr by checking the website. see ACSdownload:::validate.end.year(2023) ***
    message(paste0("It is a guess that ACS data may already be incorporated into this package for the 5-year survey period of ",
                   yr, " ", acs_yr_range(yr, parens = TRUE), " but not later periods"))
  }

  return(yr)
}
