

#' Get indicator names within a varlist like names_d
#' @aliases varlist2names
#' @details
#'   varlist2names() aka namesbyvarlist() is a way to just get a vector of variable names even if the varlist is not stored as a separate data object
#'   and is only found in the map_headernames$varlist column:
#'
#'   varlist2names(c('names_d', 'names_d_subgroups'))
#'
#'    c(names_d, names_d_subgroups)
#'
#' @param varlist one character string like "names_d", or a vector of them
#' @param nametype vector of 1 or more names of columns in map_headernames, or a shortcut type that can be
#'   api, csv, r, original, long, shortlabel
#' @param mapping data.frame with at least `varlist` and requested `nametype`
#'   columns. Defaults to [map_headernames].
#' @param include optional vector of names to keep.
#' @param exclude optional vector of names to drop.
#' @param available_vars optional vector of names available in a target dataset.
#'   Rows whose `rname` is not available are dropped.
#'
#' @return  a data.frame one row per indicator, one col per nametype and a column identifying the varlist
#'
#' @examples
#'  unique(map_headernames$varlist)
#'
#'  namesbyvarlist('names_e_avg', 'rname')
#'  namesbyvarlist('names_d')
#'  namesbyvarlist('names_d', 'r')
#'  namesbyvarlist('names_d', 'long')
#'  namesbyvarlist('names_d', 'shortlabel')
#'
#'  namesbyvarlist( 'names_e_pctile', c('r', 'longname'))
#'  namesbyvarlist(c('names_e_pctile', 'names_e_state_pctile'),
#'    c('varlist', 'rname', 'ejscreen_apinames_old', 'csvname', 'shortlabel', 'longname'))
#' @seealso [varlist2names()] [varin_map_headernames()] [varinfo()] [names_whichlist_multi_key()]
#'
#' @keywords internal
#' @export
#'
namesbyvarlist <- function(varlist,
                           nametype = c('rname','longname','ejscreen_apinames_old')[1],
                           mapping = map_headernames,
                           include = NULL,
                           exclude = NULL,
                           available_vars = NULL) {

  for (i in 1:length(nametype)) {
    nametype[i] <- switch(nametype[i],
                           api = 'ejscreen_apinames_old',
                           csv = 'csvname',
                           r =   'rname',
                          acs = 'acsname',
                           original = 'oldname',   # which might be an older name or rname
                          shortlabel = 'shortlabel',
                          long = 'longname',
                           nametype[i]) # if no match above, use as-is
  }
  if (!"varlist" %in% names(mapping)) {
    stop("mapping must have a varlist column")
  }
  if (!(any(varlist %in% unique(mapping$varlist)))) {stop('specified varlist is not found among mapping$varlist')}
  if (any(!(nametype %in% names(mapping)))) {stop('specified nametype not a known type and not found among colnames(mapping)')}
  if (!"rname" %in% names(mapping) && (!is.null(include) || !is.null(exclude) || !is.null(available_vars))) {
    stop("mapping must have an rname column when include, exclude, or available_vars is used")
  }

  out <- mapping[mapping$varlist %in% varlist, c('varlist', nametype), drop = FALSE]
  if ("rname" %in% names(out)) {
    out <- out[!is.na(out$rname) & nzchar(out$rname), , drop = FALSE]
    if (!is.null(include)) {
      out <- out[out$rname %in% include, , drop = FALSE]
    }
    if (!is.null(exclude)) {
      out <- out[!out$rname %in% exclude, , drop = FALSE]
    }
    if (!is.null(available_vars)) {
      out <- out[out$rname %in% available_vars, , drop = FALSE]
    }
  }
  rownames(out) <- NULL
  out
}
########################################## #
#' @keywords internal
names_from_varlist <- function(vlist) {
  namesbyvarlist(vlist)$rname
}
########################################## #
#' @keywords internal
#' @export
#'
varlist2names <- function(varlist, ...) {
  namesbyvarlist(varlist, nametype = "rname", ...)$rname
}
########################################## #
