#' @name frs_by_programid
#' @title frs_by_programid (DATA) data.table of Program System ID code(s) for each EPA-regulated site in
#'   the Facility Registry Service
#' @seealso [frs] [frs_by_naics]
#' @details Table in [data.table](https://r-datatable.com) format.
#'   This file is not stored in the package, but is obtained via [dataload_dynamic()].
#'
#'  Created by frs_make_programid_lookup()
#'
#'    This is the format with one row per site-programid pair,
#'    so multiple rows for one site if it is in multiple programs.
#'
#'  Counts and example IDs change with each FRS snapshot. After loading the
#'  current Arrow table, inspect `dim(frs_by_programid)` and a site's rows with
#'  `frs_by_programid[REGISTRY_ID == testinput_registry_id[1]]`.
#'
NULL
