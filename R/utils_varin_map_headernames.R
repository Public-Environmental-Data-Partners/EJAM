
#  utility to search for a variable name in map_headernames & see all variants of the name
# or see that info for all variables in a specified varlist
## examples  varin_map_headernames_all("lan_")


varin_map_headernames_all <- function(query, varlist = NULL, simple=FALSE) {

  kinds = c('rname',
            'oldname',
            'apiname',
            'api_synonym',
            'acsname',
            'csvname',
            'longname')

  if (!is.null(varlist)) {
    # warning("varlist parameter not quite working yet - it provides duplicative info in extra row")
    if (!missing(query)) {stop("specify query or varlist not both")}
    if (!all(varlist %in% map_headernames$varlist)) {stop("some varlist items not found in map_headernames$varlist -- Note the varlist param should be quoted such as 'names_d' ")}
    # query <- "*"

    x <- data.table::data.table(

      varlist = varlist,
      map_headernames[map_headernames$varlist %in% varlist, kinds]
    )

  } else {
    q = query
    if (length(q) > 1) {
      x1q = list()
      for (qi in 1:length(q)) {
        x1q[[qi]] <- varin_map_headernames_all(query = q[qi], simple = simple)
      }
      x1q <- data.table::rbindlist(x1q)
      x1q = unique(x1q)
      x1q = x1q[order(x1q$varlist, x1q$rname), ]
      return(x1q)

    }  else {

  # view all versions and renamed versions of all matches to query term
  q = query
  # if (length(q) > 1) {stop("designed for query length 1")}
  hits = list()
  for (i in 1:length(kinds)) {
    hits[[i]] <-  grep(q, map_headernames[, kinds[i]], ignore.case = T, value = T)
  }
  x = list()
  for (i in 1:length(kinds)) {
    hits_thistype = hits[[i]]
    junk = capture.output({varlist_of_this <- varinfo(fixcolnames(hits_thistype, oldtype = kinds[i], newtype = 'rname'))$varlist})
    if (simple) {
      x[[i]] = data.table::data.table(
        # type_with_match = kinds[i],
        query = paste0('"', q, '"'),
        varlist = varlist_of_this,
        # matched_term = hits_thistype, # redundant with later column info
        rname       = fixcolnames(hits_thistype, oldtype = kinds[i], newtype = 'rname'),
        oldname     = fixcolnames(hits_thistype, oldtype = kinds[i], newtype = 'oldname'),
        apiname     = fixcolnames(hits_thistype, oldtype = kinds[i], newtype = 'apiname'),
        api_synonym = fixcolnames(hits_thistype, oldtype = kinds[i], newtype = 'api_synonym'),
        acsname     = fixcolnames(hits_thistype, oldtype = kinds[i], newtype = 'acsname'),
        csvname     = fixcolnames(hits_thistype, oldtype = kinds[i], newtype = 'csvname'),
        longname    = fixcolnames(hits_thistype, oldtype = kinds[i], newtype = 'longname')
        )
    } else {
      x[[i]] = data.table::data.table(
        query = paste0('"', q, '"'),
        varlist = varlist_of_this,
        rname       = map_headernames[match(hits_thistype, map_headernames[, kinds[i]]), 'rname'],
        oldname     = map_headernames[match(hits_thistype, map_headernames[, kinds[i]]), 'oldname'],
        apiname     = map_headernames[match(hits_thistype, map_headernames[, kinds[i]]), 'apiname'],
        api_synonym = map_headernames[match(hits_thistype, map_headernames[, kinds[i]]), 'api_synonym'],
        acsname     = map_headernames[match(hits_thistype, map_headernames[, kinds[i]]), 'acsname'],
        csvname     = map_headernames[match(hits_thistype, map_headernames[, kinds[i]]), 'csvname'],
        longname    = map_headernames[match(hits_thistype, map_headernames[, kinds[i]]), 'longname']
      )
    }
  }
  x <- data.table::rbindlist(x)
  }
  x = unique(x)
  x = x[order(x$varlist, x$rname), ]
  kinds_not_r = kinds[kinds != "rname"]
  x$consistency <- apply(x[, ..kinds_not_r], 1, function(rowhits) {
    rowhits = rowhits[rowhits != ""]
    ifelse(length(unique(rowhits)) == 1, "", "has synonyms")
  })
  # if (!is.null(varlist)) {
  #   data.table::setDF(x)
  #   x = x[x$varlist %in% varlist, ]
  #   data.table::setDT(x)
  # }
  return(x)
  }
}
#################################### #



#' utility to check if a variable or term is in map_headernames and where
#'
#' @param query variable name or fragment (or regular expression) to look for in map_headernames
#'   columns, looking within just column names listed in cols_with_names.
#'   Or a vector of query terms in which case this returns one column per query term.
#' @param ignore.case optional, like in grepl()
#' @param cols_with_names optional, colnames of map_headernames to check in
#' @param exact set to TRUE for only exact matches
#' @return data.frame of info about where query was found and how many hits.
#' @examples
#' EJAM:::varin_map_headernames("spanish")
#' EJAM:::varin_map_headernames("lowinc")
#' EJAM:::varin_map_headernames("pop")
#' EJAM:::varin_map_headernames("POV", ignore.case = T)
#' EJAM:::varin_map_headernames("POV", ignore.case = F)
#'
#' EJAM:::varin_map_headernames( "traffic.score", exact = T)
#'
#' EJAM:::varin_map_headernames( "traffic" )
#'
#' t(EJAM:::varinfo("traffic.score",
#'   info = c("oldname","apiname", "acsname" ,"csvname",
#'   "basevarname", 'shortlabel', 'longname', 'varlist')))
#'
#' @seealso [varinfo()]
#'
#' @export
#' @keywords internal
#'
varin_map_headernames <- function(query = "lowinc", ignore.case = TRUE, exact = FALSE,
                                  cols_with_names = c("oldname",
                                                      "apiname",
                                                      "api_synonym",
                                                      "acsname" ,
                                                      "csvname",
                                                      "ejscreen_csv",
                                                      "rname",
                                                      "topic_root_term",
                                                      "basevarname",
                                                      "denominator",
                                                      "shortlabel",

                                                      "longname",
                                                      #"description", # obsolete
                                                      #"csvlongname", # obsolete
                                                      "api_description",
                                                      "acs_description",
                                                      "varlist"
                                  )) {

  cols_with_names <- cols_with_names[cols_with_names %in% names(map_headernames)]
  mh <- map_headernames[, cols_with_names]

  if (exact) {query <- paste0("^", query, "$")}

  out <- list()

  for (i in seq_along(query)) {

    if (ignore.case) {
      exactmatch = sapply(mh, function(x) {
        tolower(query[i]) %in%
          tolower(x)
      })
    } else {
      exactmatch = sapply(mh, function(x) {
        query[i] %in% x
      })
    }

    out[[i]] <- data.frame(
      exactmatch = exactmatch,

      # grepmatch.anycase = sapply(mh, function(x) {
      # any(grepl(query, as.vector(x), ignore.case = ignore.case))
      # }),
      # grepmatch.anycase.hitlist = sapply(mh, function(x) {
      #   paste0(grep(query, as.vector(x), ignore.case = ignore.case, value = T), collapse = ",")
      # }),

      grepmatch.hitcount = sapply(mh, function(x) {
        sum(grepl(query[i], as.vector(x), ignore.case = ignore.case))
      }),

      example = sapply(mh, function(x) {
        (grep(query[i], as.vector(x), ignore.case = ignore.case, value = TRUE)[1])
      })
    )

    if (length(query) > 1) {
      out[[i]] <- out[[i]][, "grepmatch.hitcount", drop = FALSE] # drop exactmatch and example columns if multiple terms in query
    }
  }
  if (length(query) > 1) {
    out  <- do.call(cbind, out)
    if (exact) {
      # get rid of the ^ and $ that had been added at start and end of each query term to get back to the parameter as provided
      query <-  gsub( ".{1}(.*).{1}", "\\1", query)
    }
    colnames(out) <- query
    return( out)
  } else {
    return(out[[1]])
  }
}
