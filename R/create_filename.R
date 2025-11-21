
##################### #
# lubridate:: could do this, but this works ok
# format date and time to use as part of a file name to save results in
Sys.time_txt = function(time = Sys.time()) {
  format(time, '%Y-%m-%d %H.%M')
}
##################### #
# lubridate:: could do this, but this works ok
time_plus_x_seconds = function(seconds = 60, start_time = Sys.time()) {
  gsub("\\.", ":",  gsub("^[^ ]* ", "", Sys.time_txt( start_time + seconds)))
}
##################### #


#' create_filename - construct custom filename for downloads in EJAM app
#' @description Builds filename from file description, analysis title, buffer distance, and site selection method. Values are pulled from Shiny app if used there.
#' @param file_desc file description, such as "short report", "long report", "results_table"
#' @param title analysis title (capped at 100 characters)
#' @param buffer_dist buffer distance, to follow "Miles from"
#' @param site_method site selection method, such as SHP, latlon, FIPS, NAICS, FRS, EPA_PROGRAM, SIC, MACT, or anything to follow "places by"
#' @param filename_base optional word to start the file name
#' @param with_datetime boolean to include date and time
#' @param ext optional file extension, like ".html" etc. Will check for '.' and add if not provided.
#' @param replace_spaces_with substitutes this in place of each space in file_desc, title, "places by", "Miles from",
#'  and used to separate from text for buffer_dist and site_method
#'  @param maxchar optional max characters for each component of the name
#'  @param maxchar_total optional max for the entire filename, truncated at end if necessary
#' @return Returns string of file name (with extension but no path) with specified components
#'
#' @examples
#' # specify title only
#' EJAM:::create_filename(title = 'Summary of Analysis', ext=".txt")
#'
#' # test / see how it works for various combinations of input parameters
#' parameters_table = expand.grid(
#'   file_desc=c("", "FILE DESCRIPTION"),
#'   title = c("", "My Title"),
#'   buffer_dist = c(0, 3.2),
#'   site_method = c("", "latlon"),
#'   ext = c(NULL, ".html"),
#'   stringsAsFactors = F
#' )
#' cbind(output_filename =
#'   cbind(
#'     purrr::pmap(parameters_table, EJAM:::create_filename)
#'   ),
#'   parameters_table
#' )
#'
#' @keywords internal
#'
create_filename <- function(file_desc = '',
                            filename_base = 'EJAM',
                            with_datetime = TRUE,
                            ext = NULL,
                            title = '',
                            buffer_dist = 0,
                            site_method = '',

                            replace_spaces_with = " ",
                            maxchar = 50,
                            maxchar_total = 150) {
if (FALSE) {
  # # test / see how it works for various combinations of input parameters

  parameters_table = expand.grid(
    file_desc=c("", "FILE DESCRIPTION"),
    title = c("", "My Title"),
    buffer_dist = c(0, 3.2),
    site_method = c("", "latlon"),
    ext = c(NULL, ".html"),
    stringsAsFactors = F)

  cbind(output_filename =
          cbind(purrr::pmap(parameters_table, create_filename)),
        parameters_table)

 }
  # 1                                                                  EJAM 2025-09-22 14.24.html                                   0.0             .html
  # 2                                                 EJAM FILE DESCRIPTION 2025-09-22 14.24.html FILE DESCRIPTION                  0.0             .html
  # 3                                                         EJAM My Title 2025-09-22 14.24.html                  My Title         0.0             .html
  # 4                                        EJAM FILE DESCRIPTION My Title 2025-09-22 14.24.html FILE DESCRIPTION My Title         0.0             .html
  # 5                                                 EJAM within 3.2 Miles 2025-09-22 14.24.html                                   3.2             .html
  # 6                                EJAM FILE DESCRIPTION within 3.2 Miles 2025-09-22 14.24.html FILE DESCRIPTION                  3.2             .html
  # 7                                        EJAM My Title within 3.2 Miles 2025-09-22 14.24.html                  My Title         3.2             .html
  # 8                       EJAM FILE DESCRIPTION My Title within 3.2 Miles 2025-09-22 14.24.html FILE DESCRIPTION My Title         3.2             .html
  # 9                                             EJAM for places by latlon 2025-09-22 14.24.html                                   0.0      latlon .html
  # 10                           EJAM FILE DESCRIPTION for places by latlon 2025-09-22 14.24.html FILE DESCRIPTION                  0.0      latlon .html
  # 11                                   EJAM My Title for places by latlon 2025-09-22 14.24.html                  My Title         0.0      latlon .html
  # 12                  EJAM FILE DESCRIPTION My Title for places by latlon 2025-09-22 14.24.html FILE DESCRIPTION My Title         0.0      latlon .html
  # 13                           EJAM within 3.2 Miles for places by latlon 2025-09-22 14.24.html                                   3.2      latlon .html
  # 14          EJAM FILE DESCRIPTION within 3.2 Miles for places by latlon 2025-09-22 14.24.html FILE DESCRIPTION                  3.2      latlon .html
  # 15                  EJAM My Title within 3.2 Miles for places by latlon 2025-09-22 14.24.html                  My Title         3.2      latlon .html
  # 16 EJAM FILE DESCRIPTION My Title within 3.2 Miles for places by latlon 2025-09-22 14.24.html FILE DESCRIPTION My Title         3.2      latlon .html

  sep <- replace_spaces_with

  fname <- filename_base

  append_cleaned = function(filename, text2append = "") {
    # replace spaces with sep character, shorten if needed, append with sep character
    txt <- text2append
    txt <- gsub(' ', sep, txt)
    txt <- substr(txt, 1, maxchar)
    filename <- paste0(filename, sep, txt)
    return(filename)
  }

  ## add file description
  if (!is.null(file_desc) && nchar(file_desc) > 0) {
    txt <- file_desc
    fname <- append_cleaned(fname, txt)
  }
  ## add analysis title
  if (!is.null(title) && nchar(title) > 0) {

    txt <- title
    fname <- append_cleaned(fname, txt)
  }
  ## add buffer distance, if applicable
  if (!is.null(buffer_dist) && !is.na(buffer_dist) && buffer_dist > 0  && !isTRUE(getOption("shiny.testmode"))) {

    txt = paste0("within", sep, buffer_dist, sep, "Miles")
    fname <- append_cleaned(fname, txt)
  }
  ## add site selection method
  if (!is.null(site_method) && nchar(site_method) > 0) {

    txt = paste0("for places by", sep, site_method)
    fname <- append_cleaned(fname, txt)
  }

  ## add date and time of download
  if (with_datetime && !isTRUE(getOption("shiny.testmode"))) {

    txt = Sys.time_txt()
    fname <- append_cleaned(fname, txt)
  }

  ## add file extension
  if (!is.null(ext) && nchar(ext) > 0) {
    ## check for missing . at beginning
    if (!grepl('\\.', ext)) {
      fname <- paste0(fname, '.', ext)
    } else {
      fname <- paste0(fname, ext)
    }
  }
  # shorten overall if necessary
  fname <- trimws(fname)
  extnow <- tools::file_ext(fname)
  dotnow <- ifelse(nchar(extnow) == 0, "", ".") # in case no extension is wanted
  fname_no_ext <- tools::file_path_sans_ext(fname)
  fname_no_ext <- substr(fname_no_ext, 1, maxchar_total - nchar(extnow) - nchar(dotnow))
  fname <- paste0(fname_no_ext, dotnow, extnow)

  return(fname)
}

