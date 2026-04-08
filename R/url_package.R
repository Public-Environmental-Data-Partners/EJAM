

#' Get URL, or just owner/reponame, for the package code, datasets, or documentation website
#' as specified in the DESCRIPTION file or by redirects from aliases
#'
#' @param type Which type of URL is needed? Can be "data", "code", or "docs".
#'
#'   - "code" is for the github.com repository of R package code
#'   - "data" is for the github.com repository of datasets
#'   - "docs" is for the documentation website
#'
#' @param get_full_url logical, whether to return full URL or just the owner/reponame info.
#'   Ignored if type = "docs", where full URL is always returned.
#'
#' @param desc_or_alias must be "desc" or "alias" to use info from DESCRIPTION file
#'   or the URL based on a redirect from the aliases at
#'
#'   - https://ejanalysis.org/code
#'   - https://ejanalysis.org/data
#'   - https://ejanalysis.org/docs
#'
#' @param domain obsolete parameter - do not use
#' @details
#' See https://ejanalysis.com/ejam-code   for a list of URLs
#'
#' @examples
#'  owner_repo <- url_package()
#'  reponame <- gsub(".*/", "", owner_repo)
#'  reponame
#'
#'  url_package("docs")
#'
#'  url_package("code")
#'  url_package("code", get_full_url=T)
#'
#'  url_package("data")
#'  url_package("data", get_full_url=T)
#'
#'  url_package("docs", desc_or_alias="alias")
#'  url_package("code", desc_or_alias="alias")
#'  url_package("data", desc_or_alias="alias")
#'
#' @return a single URL or owner/repo as a character string
#'
#' @export
#' @keywords internal
#'
url_package <- function(
    type = c('code', 'data', 'docs')[1],
    get_full_url = FALSE,
    desc_or_alias = c("desc", "alias")[1],
    domain = NULL
) {

  if (all(type %in% c("github.com", "github.io"))) {
    # warning("this function no longer uses the 'domain' parameter. Use 'type' instead.")
    domain <- type[1]
  }
  if (!is.null(domain)) {
    warning("this function no longer uses the 'domain' parameter. Use 'type' instead.")
    if (all(domain == "github.com")) {type <- "code"} else {
      if (all(domain == "github.io")) {type <- "docs"} else {
        stop("the obsolete 'domain' parameter must be either 'github.com' or 'github.io'")
      }
    }
  }
  stopifnot(length(type) == 1, type %in% c('code', 'data', 'docs'))
  stopifnot(length(desc_or_alias) == 1, desc_or_alias %in% c("desc", "alias"))
  if (desc_or_alias == "alias" && get_full_url == FALSE) {
    if (!missing(get_full_url)) {
      warning("cannot use desc_or_alias='alias' if get_full_url=FALSE, so just using get_full_url=TRUE ")
    }
    get_full_url <- TRUE
  }
  if (type == "docs" && get_full_url == FALSE) {
    if (!missing(get_full_url)) {
      warning("ignoring get_full_url=FALSE since that would not make sense -- we can only return a full URL for the documentation website since it is not a github repository")
    }
    get_full_url <- TRUE
  }

  if (desc_or_alias == "alias") {

    # use redirects

    get_full_url <- TRUE # already handled but just in case
    if (type == "data") {
      one_url <- "https://ejanalysis.org/data"
    }
    if (type == "code") {
      one_url <- "https://ejanalysis.org/code"
    }
    if (type == "docs") {
      one_url <- "https://ejanalysis.org/docs"
    }

  } else {

    # look at DESCRIPTION file

    if (type == "data") {
      one_url <- as.vector(desc::desc(file = system.file("DESCRIPTION", package = "EJAM"))$get("ejam_data_repo"))
      one_url <- paste0("https://github.com/", one_url)
      domain <- "github.com"
    }
    if (type == "code") {
      domain <- "github.com"
    }
    if (type == "docs") {
      domain <- "github.io"
    }
    if (type %in% c("code", "docs")) {
      # split out each URL from that data field that stored more than one URL
      both_urls <- desc::desc(file = system.file("DESCRIPTION", package = "EJAM"))$get("URL")
      both_urls <- as.vector(unlist(strsplit(gsub(" |\n", "", both_urls), ",")))
      one_url <- grep(domain, both_urls, value = T)
    }
  }

  if (get_full_url) {
    return(one_url)
  } else {
    owner_slash_repo_or_just_docs_repo <- gsub(
      paste0("(.*", domain, "/)(.*)"), "\\2", one_url)
    return(owner_slash_repo_or_just_docs_repo)
  }
}
############################################################################# #


# comma <- function(x) format(x, digits = 2, big.mark = ",")

############################################################################# #
