#' @name frs
#' @title frs (DATA) EPA Facility Registry Service table of regulated sites
#' @description This is a table in [data.table](https://r-datatable.com) format,
#'   a snapshot version of the EPA FRS.
#'   You can look up sites by REGISTRY_ID in [frs], and get their location, etc.
#' @seealso [epa_programs] [epa_programs_defined] [frs_by_programid]  [frs_by_naics] [frs_by_sic]
#' @details
#'  FRS-related datasets are large dynamic `.arrow` files loaded by [dataload_dynamic()],
#'  not `.rda` files installed in `EJAM/data/`, so they are not lazy-loaded by R.
#'
#'  FRS-related datasets are loaded by the package functions that need them,
#'  or a developer can load them via
#'  `dataload_dynamic(c('frs','frs_by_programid','frs_by_naics','frs_by_sic'))`
#'
#'  This dataset can be updated by a package maintainer as explained in the
#'  `r paste0('[article on data updates](', url_package('docs'), '/articles/dev-update-datasets.html)')`.
#'
#'   The definitions of active/inactive here are not quite the
#'   same as used in ECHO. See attributes(frs) to see date created, etc.
#'
#'   Also, [EJSCREEN](https://ejanalysis.com/ejscreenapp) has maps of EPA-regulated
#'   [facilities](`r paste0(EJAM::url_package("docs"), "/articles/ejscreen-map-descriptions.html#epa-regulated-facilities")`)
#'   of a few program types
#'   and for a table of acronym definitions
#'   see https://www.epa.gov/sites/default/files/2021-05/frs_program_abbreviations_and_names.xlsx
#'   and [epa_programs_defined]
#'
#'  - Count of    all REGISTRY_ID rows:   Approx 7 million in 2025 data
#'  - Count of unique REGISTRY_ID values: Approx 4-5 million in 2025 data
#'  - Clearly inactive unique IDs:        Approx 1-2 million in 2025 data
#'  - Assumed   active unique IDs:        Approx 3 million in 2025 data
#'  - frs rows total:            Approx 3 million rows (approx 3 million unique ids) in late 2026 data.
#'  - frs_by_programid rows:     Approx 4 million rows (approx 3 million unique ids) in late 2026 data.
#'
#'  - frs_by_naics rows:         Over 800k (approx 700k unique regid, approx 2k unique NAICS) in late 2026.
#'  - frs_by_sic rows:           Over 800k (approx 700k unique regid, approx 2k unique SIC) in late 2026.
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
