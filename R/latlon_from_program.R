
#' Get lat lon, Registry ID, and NAICS, for given FRS Program System CATEGORY
#'
#' Find all FRS sites in a program like RCRAINFO, TRIS, or others
#'
#' @details  For info on FRS program codes in general, see <https://www.epa.gov/frs/frs-program-crosswalks>
#'
#'   Also see information at <https://echo.epa.gov/tools/data-downloads/frs-download-summary>
#'    about the file FRS_PROGRAM_LINKS.csv
#'
#'   For info on program codes ECHO uses, see <https://echo.epa.gov/resources/echo-data/about-the-data>
#'
#'   including <https://www.epa.gov/frs/frs-environmental-interest-types>
#'
#'   For a list of program acronyms, <https://www.epa.gov/frs/frs-rest-services#appendixa>
#'
#'   The acronym is the abbreviated name that represents the name of an
#'   information management system for an environmental program.
#'   The Federal ones with at least 100k facilities each are
#'
#'   RCRAINFO (over 500k sites), NPDES, ICIS, AIR, FIS, EIS, and AIRS/AFS.
#'
#' @param query like "RMP", "RCRAINFO", "TRIS", "RMP", or others.
#'
#' @return table in [data.table](https://r-datatable.com) format with lat  lon  REGISTRY_ID  program -- but not pgm_sys_id
#'   since there could be duplicates where same REGISTRY_ID has 2 different pgm_sys_id values
#'   in the same program, so results were sometimes longer than if using [frs_from_program()]
#' @examples \dontrun{
#'  x = latlon_from_program("CAMDBS")
#'   mapfast(x)
#'  program <- c("EIS", "UST")
#'  x = latlon_from_program(program)
#'  # to get the facility name as well:
#'  x = frs[grepl("RCRAINFO", PGM_SYS_ACRNMS), ] # fast
#'  ## x = latlon_from_regid(latlon_from_program(program)[,REGISTRY_ID])  # slower!
#'  mapfast(x[sample(1:nrow(x), 1000), ])
#' }
#'
#' @export
#'
latlon_from_program <- function(query) {

  if (missing(query)) {return(NULL)} else if (all(is.na(query)) || is.null(query)) {return(NULL)}

  if (!exists("frs_by_programid_arrow")) {
    dataload_dynamic("frs_by_programid", return_data_table = FALSE)
  }

  if (!exists("frs_arrow")) {
    dataload_dynamic("frs", return_data_table = FALSE)
  }


  # NOW USE THIS VERSION THAT MAKES IT IDENTICAL TO frs_from_program() :
  regid <- frs_by_programid_arrow %>%
    filter(.data$program %in% !!query) %>%
    select(REGISTRY_ID) %>%
    collect() %>%
    pull(REGISTRY_ID)

  res <- frs_arrow %>%
    filter(.data$REGISTRY_ID %in% regid) %>%
    collect() %>%
    data.table::as.data.table()

  return(res)

}
