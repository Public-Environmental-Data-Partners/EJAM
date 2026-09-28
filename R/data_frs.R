#' @name frs
#' @title frs (DATA) EPA Facility Registry Service table of regulated sites
#' @description This is a table in [data.table](https://r-datatable.com) format,
#'   a snapshot version of the EPA FRS.
#'   You can look up sites by REGISTRY_ID in [frs], and get their location, etc.
#' @seealso [epa_programs] [epa_programs_defined] [frs_by_programid]  [frs_by_naics] [frs_by_sic]
#' @details
#'  This dataset can be updated by a package maintainer by using
#'     frs_update_datasets() (which is not an exported function).
#'  FRS tables are dynamic `.arrow` files loaded by [dataload_dynamic()],
#'  not `.rda` files installed in `EJAM/data/`.
#'
#'   The definitions of active/inactive here are not quite the
#'   same as used in ECHO. See attributes(frs) to see date created, etc.
#'
#'   Also, [EJSCREEN](https://ejanalysis.com/ejscreenapp) has maps of EPA-regulated [facilities](`r paste0(EJAM::url_package("docs"), "/articles/ejscreen-map-descriptions.html#epa-regulated-facilities")`) of a few program types
#'   and for a table of acronym definitions
#'   see https://www.epa.gov/sites/default/files/2021-05/frs_program_abbreviations_and_names.xlsx
#'   and [epa_programs_defined]
#'
#'  Counts change with each EPA FRS snapshot. After calling [dataload_dynamic()],
#'  use `nrow(frs)` and `data.table::uniqueN(frs$REGISTRY_ID)` for the
#'  currently installed release; use the corresponding lookup tables to count
#'  sites with program, NAICS, or SIC information.
#'
#'   Classes `data.table` and `data.frame`
#'
#'   colnames
#'
#'   - \[1,\] "lat"
#'   - \[2,\] "lon"
#'   - \[3,\] "REGISTRY_ID" like 110000343003
#'   - \[4,\] "PRIMARY_NAME"
#'   - \[5,\] "NAICS" csv group of codes per site
#'   - \[6,\] "SIC"
#'   - \[7,\] "PGM_SYS_ACRNMS" like RCRAINFO:XJW000200113
NULL
