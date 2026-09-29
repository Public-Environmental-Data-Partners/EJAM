#' Main function that updates several FRS datasets for use in EJAM
#'
#' @details
#' This function is used by someone maintaining the EJAM package,
#' to obtain updated Facility Registry Service (FRS) data such as
#' the locations, IDs, etc. for hundreds of thousands of EPA-regulated sites.
#'
#'  This function is only for a package maintainer/updater
#'  (or an analyst who wants to get the latest information).
#'
#'  These datasets are obtained from EPA servers, reformatted for this package,
#'  and written as local Arrow IPC files for validation before they are uploaded
#'  to an `ejamdata` release - see
#'  [updating data for package](https://public-environmental-data-partners.github.io/EJAM/articles/dev-update-datasets.html).
#'  The `save_as_data_*` parameters are obsolete and kept only to make old
#'  maintainer scripts fail clearly. FRS tables are no longer saved as
#'  lazy-loaded `.rda` package data in `EJAM/data/`.
#'
#'  The five FRS Arrow files are `frs`, `frs_by_programid`, `frs_by_naics`,
#'  `frs_by_sic`, and `frs_by_mact`. The function also writes `mact_table.arrow`
#'  and `mact_table.rda` to the output folder; `mact_table` is package data,
#'  not one of the 11 dynamic Arrow release assets. The Arrow files later get
#'  downloaded for local use by EJAM.
#'
#' @param folder optional folder for where to download to; uses temp folder by default
#' @param folder_save_as_arrow optional folder where to save any .arrow files
#' @param downloaded_and_unzipped_already optional, set to TRUE if already downloaded latest
#'   and folder will be specified or can be assumed to be current working directory
#' @param csvname optional, passed to frs_get()
#' @param date Retrieval/snapshot date passed to [frs_get()]. Set it to the
#'   original retrieval date when reusing a previously downloaded source CSV.
#'
#' @param save_as_arrow_frs Whether to save `frs.arrow` in `folder_save_as_arrow`.
#' @param save_as_arrow_frs_by_programid Whether to save `frs_by_programid.arrow` there.
#' @param save_as_arrow_frs_by_naics Whether to save `frs_by_naics.arrow` there.
#' @param save_as_arrow_frs_by_sic Whether to save `frs_by_sic.arrow` there.
#' @param save_as_arrow_frs_by_mact Whether to save `frs_by_mact.arrow` there.
#'
#' @param save_as_data_frs,save_as_data_frs_by_programid,save_as_data_frs_by_naics,save_as_data_frs_by_sic,save_as_data_frs_by_mact
#'   Obsolete. FRS tables are no longer saved as `.rda` files in `./data/`.
#'   Leave these as `FALSE` and publish the `.arrow` files instead.
#'
#' @return Writes the requested Arrow IPC files locally, using [frs_get()]
#'   and [frs_inactive_ids()] and other functions, and invisibly returns the
#'   newly built `frs` table. The caller must validate and publish the files.
#'   `download_date` and `released` describe this FRS retrieval/snapshot;
#'   the version and release-date attributes come from EJAM's DESCRIPTION.
#'
#' @seealso [frs_get()] [frs_inactive_ids()] [frs_drop_inactive()]
#'    [frs_make_programid_lookup()] [frs_make_naics_lookup()] [frs_make_sic_lookup()] [frs_make_mact_lookup()]
#'
frs_update_datasets <- function(folder = NULL,
                                folder_save_as_arrow = '.',
                                downloaded_and_unzipped_already = FALSE,
                                csvname = "NATIONAL_SINGLE.CSV",

                                save_as_arrow_frs              = TRUE,
                                save_as_arrow_frs_by_programid = TRUE,
                                save_as_arrow_frs_by_naics     = TRUE,
                                save_as_arrow_frs_by_sic       = TRUE,
                                save_as_arrow_frs_by_mact      = TRUE,

                                save_as_data_frs               = FALSE,
                                save_as_data_frs_by_programid  = FALSE,
                                save_as_data_frs_by_naics      = FALSE,
                                save_as_data_frs_by_sic        = FALSE,
                                save_as_data_frs_by_mact       = FALSE,
                                date = Sys.Date()) {


  commas <- function(x) {
    prettyNum(x, big.mark = ",")
  }
  if (!dir.exists(folder_save_as_arrow)) {
    dir.create(folder_save_as_arrow, recursive = TRUE)
  }
  save_as_data_flags <- c(
    save_as_data_frs,
    save_as_data_frs_by_programid,
    save_as_data_frs_by_naics,
    save_as_data_frs_by_sic,
    save_as_data_frs_by_mact
  )
  if (any(save_as_data_flags)) {
    stop(
      "The save_as_data_* arguments are obsolete. ",
      "FRS tables should be saved/published as .arrow files, not as .rda ",
      "objects in EJAM/data/.",
      call. = FALSE
    )
  }
  if (is.null(folder))
    folder <- tempdir()
  ###################################################### #
  cat("\nTrying to get frs datasets\n")
  cat("This takes a *LONG* time to download, unzip, and read the large files! Please wait!\n")
  frs <- frs_get(folder = folder, csvname = csvname,
                 downloaded_and_unzipped_already = downloaded_and_unzipped_already,
                 date = date)
  # Capture source dates before table filtering or lookup builders can discard
  # custom attributes.
  frs_download_date <- attr(frs, "download_date")
  frs_released <- attr(frs, "released")
  closedidlist <- frs_inactive_ids()
  cat("frs rows total: ", commas(NROW(frs)), '\n')
  cat("frs clearly inactive IDs: ", commas(length(closedidlist)), "\n")
  frs <- frs_drop_inactive(frs = frs, closedid = closedidlist)
  cat("frs rows actives: ", commas(NROW(frs)), "\n")

  # Lookup builders may drop table attributes. Stamp every derived table from
  # the same FRS snapshot and the package's current metadata mapping.
  frs_metadata <- c(
    get_metadata_mapping("default"),
    list(
      download_date = frs_download_date,
      released = frs_released
    )
  )

  # validate lat lon values
  cat('checking latlon values are valid \n')
  bad <- sum(!latlon_is.valid(frs$lat, frs$lon))
  if (bad > 0) {warning(bad, " LAT LON VALUES APPEAR TO BE INVALID (e.g., in US Island Areas, where demographic data may be lacking")}

  # validate regid
  cat('checking REGISTRY_ID is never NA \n')
  bad <- sum(is.na(frs$REGISTRY_ID))
  if (bad > 0) {warning(bad, "REGISTRY_ID values appear to be NA")}

  frs <- metadata_add(frs, metadata = frs_metadata)
  cat("Saving .arrow file \n")
  if (save_as_arrow_frs) {
    arrow::write_ipc_file(frs, sink = file.path(folder_save_as_arrow,
                                                "frs.arrow"))
  }
  ###################################################### #
  cat("\nTrying to create frs_by_programid\n")
  frs_by_programid <- frs_make_programid_lookup(x = frs)
  # dropped invalid ones, in that function.
  frs_by_programid <- metadata_add(frs_by_programid, metadata = frs_metadata)
  if (save_as_arrow_frs_by_programid) {
    cat("Saving .arrow file \n")
    arrow::write_ipc_file(frs_by_programid, sink = file.path(folder_save_as_arrow,
                                                             "frs_by_programid.arrow"))
  }
  ###################################################### #
  cat("\nTrying to create frs_by_naics\n")
  frs_by_naics <- frs_make_naics_lookup(x = frs)
  cat("frs_by_programid rows: ", commas(NROW(frs_by_programid)),
      "\n")
  cat("frs_by_naics rows: ", commas(NROW(frs_by_naics)), "\n")
  frs_by_naics <- metadata_add(frs_by_naics, metadata = frs_metadata)
  if (save_as_arrow_frs_by_naics) {
    cat("Saving .arrow file \n")
    arrow::write_ipc_file(frs_by_naics, sink = file.path(folder_save_as_arrow,
                                                         "frs_by_naics.arrow"))
  }
  ###################################################### #

  cat("\nTrying to create frs_by_sic\n")
  frs_by_sic <- frs_clean_sic(frs)
  frs_by_sic <- frs_make_sic_lookup(frs_by_sic)
  frs_by_sic <- metadata_add(frs_by_sic, metadata = frs_metadata)
  if (save_as_arrow_frs_by_sic) {
    arrow::write_ipc_file(frs_by_sic, sink = file.path(folder_save_as_arrow,
                                                       "frs_by_sic.arrow"))
  }
  ###################################################### #
  cat("Trying to create frs_by_mact\n")
  x <- frs_make_mact_lookup(frs_by_programid, folder = folder)
  frs_by_mact <- x$frs_by_mact
  frs_by_mact <- metadata_add(frs_by_mact, metadata = frs_metadata)
  if (save_as_arrow_frs_by_mact) {
    arrow::write_ipc_file(frs_by_mact, sink = file.path(folder_save_as_arrow,
                                                        "frs_by_mact.arrow"))
  }
  ###################################################### #
  cat("Trying to create mact_table\n")
  mact_table <- x$mact_table
  rm(x)
  mact_table <- metadata_add(mact_table, metadata = frs_metadata)
  arrow::write_ipc_file(mact_table, sink = file.path(folder_save_as_arrow,
                                                     "mact_table.arrow"))
  save(mact_table, file = file.path(folder_save_as_arrow,
                                    "mact_table.rda"))
  cat("mact_table.rda was written to the output folder; the maintainer script saves it as package data.\n")
  ###################################################### #

  cat("FRS .arrow files were written. Publish those files through the data repository release process; do not save FRS tables as package .rda data.\n")
  ############################################################# #

  print(Sys.time())
  invisible(frs)
}
############################################################# #
############################################################# #
############################################################# #

# what this looks like in console:

# devtools::load_all()
# > frs_update_datasets()

# This takes a *LONG* time to download, unzip, and read the large files! Please wait!
#   [1] "2023-12-11 10:33:36 EST"
# Downloading... Trying to download from  https://ordsext.epa.gov/FLA/www3/state_files//national_single.zip
#   to save as    \AppData\Local\Temp\RtmpQHgVhc/national_single.zip
# trying URL 'https://ordsext.epa.gov/FLA/www3/state_files//national_single.zip'
# Content type 'application/zip' length 312820183 bytes (298.3 MB)
# downloaded 298.3 MB
#
# Finished download to  AppData\Local\Temp\RtmpQHgVhc/national_single.zip
# [1] "2023-12-11 10:34:05 EST"
# Unzipping...done unzipping
# [1] "2023-12-11 10:34:25 EST"
# Reading... This takes something like 30 seconds. please wait.
# |--------------------------------------------------|
#   |==================================================|
#   Finished reading file.
# [1] "2023-12-11 10:34:55 EST"
# Cleaning...  Finished cleaning file.
# Total rows:  4809978
# Rows with lat/lon:  3490113
# [1] "2023-12-11 10:35:00 EST"
#
# Obsolete: FRS tables are not saved with usethis::use_data() anymore.
# Publish frs.arrow and related .arrow files via the data repository release.
# Also see frs_make_naics_lookup() and frs_make_programid_lookup()
# Downloading national dataset to temp folder... Takes a couple of minutes!
#   Trying to download from  https://ordsext.epa.gov/FLA/www3/state_files/national_combined.zip
# to save as  AppData\Local\Temp\RtmpQHgVhc/national_combined.zip
# trying URL 'https://ordsext.epa.gov/FLA/www3/state_files/national_combined.zip'
# Content type 'application/zip' length 1320371459 bytes (1259.2 MB)
# downloaded 1259.2 MB
#
# Finished download to   AppData\Local\Temp\RtmpQHgVhc/national_combined.zip
# Reading unzipped file...
# |--------------------------------------------------|
#   |==================================================|
#   Complete list of unique ids is 4775797 out of 7,558,760 rows of data.
# Count of    all REGISTRY_ID rows:   7,558,760
# Count of unique REGISTRY_ID values: 4,775,797
# Clearly inactive unique IDs:      1,511,111
# Assumed   active unique IDs:      3,264,686
#
# Codes assumed to mean site is closed:
#   CLOSED
# PERMANENTLY CLOSED
# PERMANENTLY SHUTDOWN
# INACTIVE
# TERMINATED
# N
# RETIRED
# OUT OF SERVICE – WILL NOT BE RETURNED
# CANCELED, POSTPONED, OR NO LONGER PLANNED
#
# frs rows total:  3,490,113
# frs clearly inactive IDs:  1,511,111
# frs rows actives:  2,576,588
# Obsolete: frs_by_naics is published as frs_by_naics.arrow, not as package .rda data.
# frs_by_programid rows:  3,438,163
# frs_by_naics rows:  697,444
# Error in `[.data.table`(frs, , ..usefulcolumns) :
#   column(s) not found: LATITUDE83, LONGITUDE83, SIC_CODES
# In addition: Warning messages:
#   1: Expected 2 pieces. Missing pieces filled with `NA` in 1160 rows [31360, 31362, 31395, 31396, 31426, 31428, 31461,
#                                                                       31548, 31567, 31569, 31685, 31711, 31732, 31841, 31896, 31897, 31899, 31918, 31919, 31929, ...].
# 2: In frs_make_naics_lookup(x = frs) : NAs introduced by coercion
# Called from: `[.data.table`(frs, , ..usefulcolumns)
#
