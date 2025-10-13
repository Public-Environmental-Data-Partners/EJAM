################################################### #################################################### #

# This file has generic url-related functions/helpers/utilities
#
# LIST OF FUNCTIONS HERE ####
#
#   see outline via ctrl-shift-O
#
#   also see URL_*.R and url_*.R

################################################### #################################################### #

#' utility - check if URL available, such as if an API is online or offline
#' @param url the URL to check
#' @returns TRUE or FALSE (but NA if no internet connection seems to be available at all)
#' @details
#' Also see EJAM:::global_or_param("ejamapi_is_down") and EJAM:::global_or_param("ejscreenapi_is_down")
#'    as set in global_defaults_package.R
#'
#' @keywords internal
#'
url_online <- function(url = "ejscreen.epa.gov") {

  if (missing(url)) {stop("must specify a URL")}
  if (length(url) > 1) {stop("can only check one URL at a time using url_online()")}
  if (offline()) {
    warning("Cannot check URL when offline -- internet connection does not seem to be available")
    return(NA)
  }

  ############## #
  ## simpler would be:
  # url_200 <- function(urlx) {200 %in% (httr::HEAD(urlx))$status_code}
  # url_200(url)
  ############## #
  ## more careful
  x <- httr2::request(url)
  junk <- capture.output({x <- try(httr2::req_perform(x), silent = TRUE)})
  if (inherits(x, "try-error")) {
    return(FALSE)
  }
  if (!("status_code" %in% names(x))) {
    return(FALSE)
  }
  if (x$status_code != 200) {
    return(FALSE)
  } else {
    return(TRUE)
  }
  ############## #
}
################################################### #################################################### #

#' utility to make html link from URL
#'
#' Convert URL to HTML link that opens in new tab
#'
#' @param url string that is URL
#' @param text string that is label
#' @param newtab unless set to FALSE, link opens in a new browser tab
#' @param encode unless set to FALSE, it uses [utils::URLencode()] first
#' @param reserved if encode=T, this parameter is passed to [utils::URLencode()]
#' @return url_linkify('epa.gov','EPA') returns `"<a href=\"epa.gov\", target=\"_blank\">EPA</a>"`
#' @seealso [enurl()]
#' @details
#'   Consider also the golem utility enurl() as modified in this pkg,
#'   except that enurl()
#'
#'   1. does not make a link that would open in new tab,
#'
#'   2. skips [utils::URLencode()] and
#'
#'   3. returns "shiny.tag" class
#'
#'   4. now sets text=url, while url_linkify() uses a shorter text
#'
#'   `enurl("https://google.com", "click here")`
#'   `url_linkify("https://google.com")`
#'
#'   `enurl("https://google.com")`
#'
#'   `url_linkify("https://google.com", "click here")`
#'
#' @keywords internal
#'
url_linkify <- function(url, text, newtab = TRUE, encode = TRUE, reserved = FALSE) {

  if (missing(text)) {text = gsub(pattern = "http[s]?://","",url)}

  if (encode) {
    url <- URLencode(url, reserved = reserved)
  } else {
    url <- url
  }
  if (newtab) {
    paste0('<a href=\"', url, '\"',
           ', target=\"_blank\"',
           '>', text, '</a>')
  } else {
    paste0('<a href=\"', url, '\"',
           '>', text, '</a>')
  }
}
################################################### #################################################### #

# convert EJAM html versions of weblinks back to simple URLs
# in the output tables from ejamit or doaggregate

unlinkify = function(x) {

  unlinkify_column <- function(z) {gsub('.*https', 'https', gsub('=report.*', '=report', gsub('., target.*', '', as.vector(unlist(z))))) }
  if (NCOL(x) > 1) {
    fixed = lapply(x, unlinkify_column)
  } else {
    fixed = unlinkify_column(x)
  }
  if (is.data.table(x)) {return(as.data.table(fixed))}
  if (is.data.frame(x)) {return(data.frame(fixed))}
  return(fixed)
}
# test_vec = testoutput_ejamit_10pts_1miles$results_bysite$`Report`
# test_df1 = as.data.frame(testoutput_ejamit_10pts_1miles$results_bysite[ , 1])
# test_df2 = as.data.frame(testoutput_ejamit_10pts_1miles$results_bysite[ , 1:2])
# test_dt1 = testoutput_ejamit_10pts_1miles$results_bysite[ , 1]
# test_dt2 = testoutput_ejamit_10pts_1miles$results_bysite[ , 1:2]
#
# unlinkify(test_df1[1,1])
# unlinkify(test_vec); class(unlinkify(test_vec))
# unlinkify(test_df1); class(unlinkify(test_df1))
# unlinkify(test_dt1); class(unlinkify(test_dt1))
# unlinkify(test_df2); class(unlinkify(test_df2))
# unlinkify(test_dt2); class(unlinkify(test_dt2))
################################################### #################################################### #

#' utility to prep URLs for being written to Excel
#'
#' @param urls vector of urls such as from [url_ejamapi()]
#' @param urltext The text to appear in Excel cells instead of just the URL showing
#'
#' @details
#'   See table_xls_format()
#'
#'   Works best if using [openxlsx::writeData()] not [openxlsx::write.xlsx()]
#'
#'   To write this column of urls to a worksheet:
#'   ```
#'   lat <- c(30.977402, 32.515813); lon = c(-83.368997, -86.377325)
#'   radius <- 1
#'   urls <- url_ejscreenmap(lat=lat, lon=lon, radius=radius)
#'
#'   urlx <- EJAM:::url_xl_style(urls, urltext = paste0("Report ", 1:2))
#'
#'   wb <- openxlsx::createWorkbook()
#'   openxlsx::addWorksheet(wb, sheetName = 'tab1')
#'   openxlsx::writeData(wb, sheet = 1, x = urlx, startCol = 1, startRow = 2)
#'   openxlsx::saveWorkbook(wb, file = '~/test1.xlsx', overwrite = TRUE)
#'
#'   # using just [openxlsx::write.xlsx()] is simpler but ignores the urltext param:
#'   openxlsx::write.xlsx(data.frame(lat = lat, lon = lon, urlx), file = 'test2.xlsx')
#'   ```
#'
#' @keywords internal
#'
url_xl_style <- function(urls, urltext = urls) {

  x <- urls
  x <- unlinkify(x) # if it was an HTML tag, convert back to just the URL
  if (length(urltext) == 1) {urltext <- rep(urltext, length(urls))}
  names(x) <- urltext
  class(x) <- 'hyperlink'
  return(x)
}
################## #  ################## #  ################## #  ################## #

########################################################### #
# helpers to construct URL(s) based on parameters in a key list of query terms
# ## for a more full featured approach, see  ?httr2::url_modify_query()
########################################################### #

# url_and_other_query_terms <- function(..., baseurl = "https://ejamapi-84652557241.us-central1.run.app/report?") {
#
#   # etc will look something like "&x=1,a=hello,y=3"
#
#   etc <- unlist(rlang::list2(...))
#   qterms <- names(etc)
#   qvalues <- as.vector(etc)
#   if (length(etc) == 0) {
#     etc <- ""
#   } else {
#     etc <- URLencode(
#       paste0("&",
#              paste0(
#                paste0(qterms, "=", qvalues),
#                collapse = "&"
#              )
#       )
#     )
#   }
#   return(paste0(baseurl, etc))
# }
########################################################### #

# ... lets you pass params like a=1:2, b=101:102, c="word"
# keylist lets you pass params like list(a=1:2, b=101:102, c="word")
# this also drops any keys whose value is NA, NULL, or ""

url_from_keylist <- function(..., keylist = NULL,
                             baseurl = "https://ejamapi-84652557241.us-central1.run.app/report?",
                             ifna = "https://ejamapi-84652557241.us-central1.run.app",
                             encode = TRUE
) {
  # klist <- rlang::list2(...) # error if empty key like  (a=1, , b=2)  - so use .ignore_empty = "all" (but still errors on  b=,c=3)
  klist <- rlang::dots_list(..., .ignore_empty = "all", .homonyms = "error")
  if (length(klist) == 0) {klist <- NULL}

  # if ("keylist" %in% names(klist)) {
  # }

  if (!is.null(keylist)) {
    # but note # unlist(list(a=2,b=3:4)) # turns b into b1, b2
    stopifnot(is.list(keylist), !is.data.frame(keylist))
    #etc checks
  }

  klist <- c(klist, keylist) # but how to do .ignore_empty = "all"

  klist <- drop_empty_keys_from_list(klist)
  klist <- collapse_each_vector_keyval(klist)
  klist_string <- collapse_keylist(klist, encode = encode)
  if (is.null(klist_string)) {
    baseurl <- ifna
  }
  urlx <- paste0(baseurl, klist_string)
  return(urlx)
}
# ########################################################### #

# ... lets you pass params like a=1:2, b=101:102, c="word"
# keylist lets you pass params like list(a=1:2, b=101:102, c="word")
# this also drops any keys whose value is NA, NULL, or ""

# vector length 1 applies to every site
# vectors length N are vectorized over N sites and should all be N long!!
# the ... param lets you provide vectors over sites and single values that apply to all sites
# without putting those all in keylist_bysite = list(...)
# keylist_4all is not really needed - could just use parameters of length 1 for those


urls_from_keylists <- function(..., keylist_bysite=NULL, keylist_4all=NULL,
                               baseurl = "https://example.com/q?", encode = TRUE,
                               pass_null_as = "" # or null ?
                               ) {

  if (is.null(keylist_4all) || length(keylist_4all) == 0 || !is.list(keylist_4all)) {
    keylist_4all <- NULL
  }
  if (is.null(keylist_bysite) || length(keylist_bysite) == 0 || !is.list(keylist_bysite)) {
    keylist_bysite <- NULL
  }
  # ...
  klist <- rlang::dots_list(..., .ignore_empty = "all", .homonyms = "error")
  if (length(klist) == 0) {klist <- NULL}
  keylist_bysite <- c(keylist_bysite, klist)

  if (is.null(keylist_bysite)) {
    keylist_bysite <- ""
  } else {
    # assemble these so each url has one of each parameter

    # NULL will cause error in as.data.frame
    ## so how pass a parameter value of NULL ??
    keylist_bysite[sapply(keylist_bysite, is.null)] <- pass_null_as # actually it will turn into "" and then get dropped entirely by url_from_keylist() now

    keylist_bysite <- paste0(
      # "&",
      apply(as.data.frame(keylist_bysite) , 1,
            # function(z) {paste0(names(z) , "=", z, collapse = "&")}
            function(z) {
              url_from_keylist(keylist = as.list(z), baseurl = "", encode = encode) # should drop empties
            }
      ))
  }

  forallpart <- url_from_keylist(keylist = keylist_4all, baseurl = "", encode = encode, ifna = "") # should drop empties
  if (length(forallpart) > 0 &&  !(all(forallpart %in% "")) &&
      length(keylist_bysite) > 0 && !(all(keylist_bysite %in% ""))) {
    forallpart <- paste0("&", forallpart)
  }

  urlx <- paste0(baseurl,
                 keylist_bysite,
                 forallpart
  )
  return(urlx)
}
########################################################### #
if (FALSE ) {

  # examples or tests

  # url_from_keylist(lat = 35, lon = -100, radius = 3.2)
  # url_from_keylist(lat = c(35,36), lon = c(-100,-99), radius = 3.14)
  #
  # lat = c(35,36)
  # lon = c(-100,-99)
  # radius = 3.14
  # url_from_keylist(lat = lat, lon = lon, radius = radius)
  #
  # keys = list(lat = c(35,36), lon = c(-100,-99), radius = 3.14)
  # url_from_keylist(keylist = keys)
  #
  #
  #
  # # might want NULL to be encoded as empty parameter but that gets removed anyway
  # url_from_keylist(lat = c(35,36), lon = c(-100,-99), radius = 3.14, xyz = NULL, abc = NULL)
  #
  # url_from_keylist(sitepoints=testpoints_10)
  #
  #
  # # bad:
  #
  # url_from_keylist(keylist = list(a = 1, ))
  # url_from_keylist(a=, b=1)
  # url_from_keylist(keylist = list(a=, b=1 ))

}
# ########################################################### #
# simplify by removing unused / empty parameters, but only if it is empty for all in the vector of values for that key
#
# drops ""
# drops NA
# drops NULL
#
drop_empty_keys_from_list <- function(klist) {

  # if a key is empty like "" in the 1 URL or all of the URLs if vector of values for that key
  emptykeys <- sapply(klist, function(v) {all(nchar(v)  %in% 0 )})
  klist <- klist[!emptykeys]

  # if a key is NULL (it would always be NULL in all URLs)
  emptykeys <- sapply(klist, is.null)
  klist <- klist[!emptykeys]

  # if a key is NA in the 1 URL or all of the URLs if vector of values for that key
  emptykeys <- sapply(klist, function(v) {all(is.na(v))})
  klist <- klist[!emptykeys]

  return(klist)
}
#################################################### #
# drops if ""
# does NOT do anything about NA or "NA"
# does NOT check for NULL or null

drop_empty_keys_from_url = function(quer) {

  # simplify by removing unused / empty parameters
  quer =  gsub("[^=&]*=&", "", x = quer) # drop any empty one except first or last param
  quer = gsub("?[^&=]*=&", "?", x = quer) # drop any empty one at start
  quer = gsub("&[^&=]*=$", "", x = quer) # drop any empty one at end
  return(quer)
}
# ########################################################### #
collapse_each_vector_keyval <- function(klist) {
  # like the .multi="comma" parameter in ?httr2::url_modify_query()
  klist <- lapply(klist, function(z) {
    if (is.vector(z)) {
      paste0(z, collapse = ",")
    } else {
      z
    }
  })
  if (length(klist) == 0) {klist <- NULL}
  return(klist)
}
# ########################################################### #
collapse_keylist <- function(klist, encode=TRUE) {
  if (is.null(klist)) {return(NULL)}
  if (any(sapply(klist, length) > 1)) {stop("any vector value must be already collapsed")}
  knames <- names(klist)
  kvals <- as.vector(klist)
  if (encode) {
    if (!is.null(kvals)) {
      kvals <- URLencode(kvals)
    }
  }
  return(
    paste0( paste0(knames, "=", kvals), collapse = "&")
  )
}
# ########################################################### #

# notes on vector of urls vs 1 url with query values that are vectors ####
#
# Question:
## some url_xyz() functions try to create a vector of URLs, 1 per key value, like   "d.com?q=1", "d.com?q=2"
## but in other cases you want to pass a vector within 1 URL, like    "d.com?q=1,2"
## question is how to best distinguish those?
# how to vectorize so a parameter that is a vector creates a query string that is a CSV list:   d.com?q=1,2
# versus
# how to vectorize so a parameter that is a vector creates multiple URLs:  d.com?q=1, d.com?q=2
# or both of those options.

# keylist that is list of vectors works in url_from_keylist()

# list of vectors that are all same length or length 1 would work for making vector of urls.
#  but what if some keys should be vectors within each url?
#    then a list of lists makes sense?
#  pick an approp data structure.
#  and write a function
## or just use loop over url_from_keylist()
## where keylist[[i]] <- list(lat = lats[i, lon = lon[i], radius = 3.1, xyz=7:8])

########################################################### #

#   has flexible input, so input can be
## 1) a list of settings defined earlier:
##   keys = list(key=value, key=value)  ## but not list(a=1:2,b=0)
##  url_from_arglist(keylist=keys)
## or
## 2) explicit:
##   url_from_keylist(key=value, key=value)

## other tools
# klist <- c(klist,
#            .url = baseurl,
#            .multi = "comma") # breaks vector key value into csv key value like d.com?q=1,2
# ## see  ?httr2::url_modify_query()
# rlang::exec("url_modify_query", !!!klist)  # note the url_modify_query function here cannot be prefixed with, say, httr2::
# ########################################################## #

##   linktext could also} be numbered:
# linktext = paste0("EJSCREEN Map ", 1:NROW(sitepoints))

########################################################### #

# flexible in what is the named vector of query values,
# BUT only returns 1 URL... non vectorized, via loop
#  cannot flexibly create one parameter based on other  parameters

# url1 = function(
    #     keyvector = c(
#       baseurl="https://example.com",
#       areatype = "county",
#       areaid = "10001",
#       # v=1 # v = 1:2 # not possible as vector
#       namestr = "here",
#
#       geometry = paste0('{"spatialReference":{"wkid":', 0, '},','"x":', -100, ',"y":', 34, '}'),
#       ## cannot flexibly create one parameter based on other  parameters:
#       # paste0('{"spatialReference":{"wkid":',wkid, '},','"x":', lon, ',"y":', lat, '}'),
#
#       radius = 3.1,
#       unit = "",
#       f = "report"
#     )
# ) {
#   url1 <- baseurl
#   for (i in seq_along(keyvector)) {
#     url1 <- urltools::param_set(urls = url1, key = names(keyvector)[ i], value = keyvector[i])  # ????
#   }
#   url1
# }
########################################################### #
#
# ### how ejscreenRESTbroker.R  used to do it
# areatype <- ''
# fips     <- ''
# geometry <- paste0('{"spatialReference":{"wkid":',wkid, '},','"x":', lon, ',"y":', lat, '}')
# geotext <- paste0(
#   '&geometry=', geometry,
#   '&distance=', radius
# )
# this_request <-  paste0(url,
#                         '&areatype=', areatype,
#                         '&areaid=',   fips,
#                         '&namestr=',  namestr,
#                         geotext,
#                         '&unit=', unit,
#                         '&f=', f
# )
