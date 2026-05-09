#' @name map_headernames
#' @docType data
#' @title map_headernames provides metadata about all indicators in EJSCREEN / EJAM
#'
#' @details
#'   This is an IMPORTANT TABLE that provides information about each variable (indicator), such as the following:
#'   - names as used in geodatabase files (original data source)
#'   - names as used in the old EJSCREEN API (`ejscreen_apinames_old`,
#'     copied from the historical `apiname` column)
#'   - names as used in the current EJAM API (`ejam_apinames`, copied from
#'     `rname`)
#'   - names as used in old EJSCREEN staff CSV/FTP-style downloads
#'     (`ejscreen_ftp_names`, copied from `csvname`)
#'   - names as used in current EJSCREEN download, geodatabase, and map-service
#'     fields (`ejscreen_indicator`)
#'   - names as used in the R code
#'   - names as used in short labels of graphics
#'   - names as used in table headers (long versions to provide full descriptions of the variables)
#'   - category of variable, for purposes of grouping similar ones like those in names_d or names_d_pctile
#'   - info about rounding decimal places, significant digits, percentage format, etc.
#'   - method for aggregating the value across blockgroups (sum, weighted mean, what is the weight, etc.)
#'   - etc.
#'
#'   It was created from a spreadsheet of the same name in the `data-raw`
#'   folder. Several helper functions are used to query it, such as
#'   [fixcolnames()], and many functions rely on it. You can see examples of
#'   what it contains below.
#'
#'   `data.frame(t(map_headernames[1:2, ]))`
#' @seealso [varinfo()] [fixcolnames()] [varin_map_headernames()] [varlist2names()]
#' @examples
#'   #   See how many variables are on each list, for example:
#'   \donttest{
#'   data.table::setDT(copy(map_headernames))[, .(
#'     variables = .N,
#'     has_apiname = sum(apiname != ""),
#'     has_csvname = sum(csvname != ""),
#'     has_ejscreen_indicator = sum(ejscreen_indicator != ""),
#'     has_ejscreen_apinames_old = sum(ejscreen_apinames_old != ""),
#'     has_ejam_apinames = sum(ejam_apinames != ""),
#'     has_acsname = sum(acsname != "")
#'     ),
#'  keyby = c("raw_pctile_avg", "DEJ", "ratio.to", "pctile.", "avg.",  "varlist" )]
#'
#'  # Which sources provide which key variables or indicators?
#'
#'  some <- unique(map_headernames$rname[map_headernames$varlist != ""
#'    & map_headernames$varlist != "x_anyother"])
#'
#'  info <- cbind(
#'    varinfo(some, info = c('api', 'csv', 'acs', 'varlist')),
#'    usastats = some %in% names(usastats),
#'    statestats = some %in% names(statestats))
#'  info <- info[nchar(paste0(info$api, info$csv, info$acs)) > 0, ]
#'  info
#'
#'  # any others
#'
#'  some <- unique(map_headernames$rname[map_headernames$varlist != ""
#'    & map_headernames$varlist == "x_anyother"])
#'
#'  info <- cbind(
#'    varinfo(some, info = c('api', 'csv', 'acs', 'varlist')),
#'    usastats = some %in% names(usastats),
#'    statestats = some %in% names(statestats))
#'  info <- info[nchar(paste0(info$api, info$csv, info$acs)) > 0, ]
#'  info
#'   }
#'
'map_headernames'
