
#' Get lat lon, Registry ID, and NAICS, for given FRS Program System ID
#'
#' @details The ID is the identification number, such as the permit number,
#'  assigned by an information management system that represents a
#'  facility site, waste site, operable unit, or other feature tracked by that
#'  Environmental Information System.
#'
#'  see [epa_programs] for a list of programs and their acronyms and a count
#'  of FRS facilities under each.
#'  Also see a simple list of names like this:
#'  as.vector(epa_programs)
#'  or
#'  sort(unique(frs_by_programid$program))
#'
#'  There are roughly 3.5 million records in [frs_by_programid] but only
#'  about 2.7 million unique pgm_sys_id values because the same number
#'  may be used under different program types, like RCRAINFO AND EGRID.
#'
#'  The program name is needed because an ID can occur in more than one
#'  program. Use the current `testinput_program_sys_id` fixture for examples.
#'
#'  Also note the FRS API:
#'   <https://www.epa.gov/frs/facility-registry-service-frs-api>
#'   <https://www.epa.gov/frs/frs-rest-services>
#'
#' @param programname name of EPA program that the programid is from:
#'   "RCRAINFO" is the programname and "XJW000000174" is the programid
#'   if the full record was  RCRAINFO:XJW000000174
#' @param programid like "XJW000000174"
#'   "RCRAINFO" is the programname and "XJW000000174" is the programid
#'   if the full record was  RCRAINFO:XJW000000174
#'
#' @return table in [data.table](https://r-datatable.com) format with lat  lon  REGISTRY_ID  program   pgm_sys_id
#' @examples
#'  latlon_from_programid(
#'    testinput_program_sys_id$program[1],
#'    testinput_program_sys_id$pgm_sys_id[1]
#'  )
#'
#' @export
#'
latlon_from_programid <- function(programname, programid) {

  if (missing(programid) || missing(programname)) {
    warning('Please provide both programname and programid.')
    return(NULL)
  }
  if (!exists("frs_by_programid")) dataload_dynamic("frs_by_programid")

  frs_by_programid[match(paste0(programname,':',programid), PGM_SYS_ACRNMS), ] # slower but retains order
  #frs_by_programid[match(programid, frs_by_programid$pgm_sys_id), ] # slower but retains order
  #  frs_by_programid[pgm_sys_id %in% programid, ] # faster but lose sort order of input

}
