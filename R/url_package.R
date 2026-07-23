
#' Get URL, or just owner/reponame, for the package code, datasets, or documentation website
#' as specified in the DESCRIPTION file or by redirects or aliases
#'
#' @details
#' This function reads from the DESCRIPTION file, but below is a
#' snapshot of URLs that were in DESCRIPTION file at the time of writing (7/2026):
#'
#' url_api: https://ejamapi-84652557241.us-central1.run.app
#' url_api_alias: https://api.ejanalysis.com
#' url_api_redirect: https://ejanalysis.com/api
#'
#' url_apirepo: https://github.com/Public-Environmental-Data-Partners/EJAM-API
#' url_apirepo_alias: https://apirepo.ejanalysis.com
#' url_apirepo_redirect: https://ejanalysis.com/apirepo
#'
#' url_apidocs: https://public-environmental-data-partners.github.io/EJAM/articles/dev-api.html
#' url_apidocs_alias: https://public-environmental-data-partners.github.io/EJAM/articles/dev-api.html # not https://apidocs.ejanalysis.com  ???
#' url_apidocs_redirect: https://public-environmental-data-partners.github.io/EJAM/articles/dev-api.html # not https://ejanalysis.com/apidocs  ???
#'
#' url_apidocker: https://hub.docker.com/r/ericnost/ejamapi
#'
#'
#' url_ejamapp: https://ejam.publicenvirodata.org
#' url_ejamapp_alias: https://ejam.ejanalysis.com
#' url_ejamapp_redirect: https://ejanalysis.com/ejamapp
#'
#' url_ejamapp_dev: http://ejam-dev-alb-971929002.us-east-1.elb.amazonaws.com
#' url_ejamapp_dev_alias: https://ejamdev.ejanalysis.com
#' url_ejamapp_dev_redirect: https://ejanalysis.com/ejamdev
#'
#' url_ejamrepo: https://github.com/Public-Environmental-Data-Partners/EJAM
#' url_ejamrepo_alias: https://ejamrepo.ejanalysis.com
#' url_ejamrepo_redirect: https://ejanalysis.com/ejamrepo
#'
#' url_ejamdocs: https://public-environmental-data-partners.github.io/EJAM
#' url_ejamdocs_alias: https://ejamdocs.ejanalysis.com
#' url_ejamdocs_redirect: https://ejanalysis.com/ejamdocs
#'
#'
#' url_ejscreenapp: https://pedp-ejscreen.azurewebsites.net/index.html
#' url_ejscreenapp_alias: https://ejscreen.ejanalysis.com
#' url_ejscreenapp_redirect: https://ejanalysis.com/ejscreenapp
#'
#' url_ejscreenrepo: https://github.com/Public-Environmental-Data-Partners/EJScreen
#' url_ejscreenrepo_alias: https://ejscreenrepo.ejanalysis.com
#' url_ejscreenrepo_redirect: https://ejanalysis.com/ejscreenrepo
#'
#' url_ejscreendocs: https://public-environmental-data-partners.github.io/EJAM/articles/ejscreen.html
#' url_ejscreendocs_alias: https://ejscreendocs.ejanalysis.com
#' url_ejscreendocs_redirect: https://ejanalysis.com/ejscreendocs
#'
#' url_ejscreendocs_old: https://github.com/Public-Environmental-Data-Partners/EJScreen#ejscreen
#'
#'
#' url_ejamdata: https://github.com/Public-Environmental-Data-Partners/ejamdata
#' url_ejamdata_alias: https://ejamdata.ejanalysis.com
#' url_ejamdata_redirect: https://ejanalysis.com/ejamdata
#'
#' @param type Which type of URL is needed, such as
#'   "docs", "app", "api", "code", or "data",
#'   but more specifically, "ejamapp", "ejscreenapp", "ejamrepo", etc.
#'
#'   The basic type "xyz" is stored in the DESCRIPTION file field "url_xyz",
#'   as listed below, but a URL also can be an alias or simple 301 redirect,
#'   stored in the DESCRIPTION file field that has
#'   "_alias" or "_redirect" as a suffix,
#'   such as the "url_ejamdocs_alias" field in DESCRIPTION providing the URL for
#'   type = "ejamdocs" and desc_or_alias = "alias".
#'
#' DOCUMENTATION SITES:
#'
#'   - "ejamdocs" or "docs" (`url_ejamdocs` field in the DESCRIPTION file contains this, and `URL` field has it in part) is for the EJAM (and EJScreen to some extent) documentation website.
#'
#'   - "ejscreendocs" (`url_ejscreendocs` field in the DESCRIPTION file) is for the EJScreen documentation website.
#'
#'   - "apidocs" (`url_apidocs` field in the DESCRIPTION file) is for the EJAM API documentation website.
#'
#' APP OR API SERVERS:
#'
#'   - "ejam" or "ejamapp" or "app" (`url_ejamapp` field in the DESCRIPTION file) is for the EJAM Shiny app.
#'
#'   - "ejamdev" or "ejamappdev" (`url_ejamapp_dev` field in the DESCRIPTION file) is for the EJAM Shiny app development server.
#'
#'   - "ejscreen" or "ejscreenapp" (`url_ejscreenapp` field in the DESCRIPTION file) is for the live EJScreen app.
#'
#'   - "api" (`url_api` field in the DESCRIPTION file) is for the EJAM REST API base URL.
#'     Always a full URL. All functions that call or build EJAM API URLs read it from here, so the
#'     endpoint can be changed in one place (by editing `url_api` in DESCRIPTION).
#'     A friendlier branded alias (in `url_api_alias`) proxies the same API via Cloudflare and
#'     may be used as a substitute.
#'
#' CODE OR DATA REPOSITORIES:
#'
#'   - "ejamrepo" or "code" (`url_ejamrepo` field in the DESCRIPTION file contains this, and `URL` field has it in part) is for the github.com repository of EJAM R package code.
#'
#'   - "ejscreenrepo" (`url_ejscreenrepo` field in the DESCRIPTION file) is for the EJScreen code repository.
#'
#'   - "apirepo" (`url_apirepo` field in the DESCRIPTION file) is for the API source-code
#'     repository on github.com and is informational only -- it is not the API endpoint.
#'
#'   - "datarepo" or "data" (`url_ejamdata` and `ejam_data_repo` field in the DESCRIPTION file) is for the github.com repository of datasets.
#'
#' @param get_full_url logical, whether to return full URL or just the owner/reponame info.
#'   Ignored if type is an app, docs, or API URL, where a full URL is always returned.
#'
#' @param desc_or_alias must be "desc" or "alias" or "redirect" to use info from DESCRIPTION file
#'   or the URL based on a cloudflare alias or a simple 301 redirect such as
#'
#'   - https://ejamapi-84652557241.us-central1.run.app # if "desc", use the basic URL
#'   - https://api.ejanalysis.com # if "alias" use the cloudflare alias that can handle subpaths and query strings passed through to the final URL
#'   - https://ejanalysis.com/api # if "redirect" use the simple 301 redirect that cannot handle subpaths or query strings
#'
#' @param docs_version optional, only used when type = "docs". A docs subpath such as
#'   "dev" or "v3.2022.1" to append to the canonical root
#'   docs URL (e.g. returns ".../EJAM/v3.2024.0"). If the environment variable
#'   `EJAM_DOCS_BASE_URL` is set (as the pkgdown CI workflow does while building a
#'   given version), that value overrides everything so rendered Rd/Rmd links stay
#'   within the version being built. `desc_or_alias = "alias"` shortcuts always point
#'   to the root docs site only.
#' @param domain obsolete parameter - do not use
#' @seealso [url_ejamapi()] [ejamapi()] [url_ejamapp()] -- the functions that build/call EJAM API
#'   and app URLs; `url_package("api")` is their single source for the API base URL.
#'
#' @examples
#'  owner_repo <- url_package()
#'  reponame <- gsub(".*/", "", owner_repo)
#'  reponame
#'
#'  url_package("docs")
#'
#'  url_package("code")
#'  url_package("code", get_full_url = TRUE)
#'
#'  url_package("data")
#'  url_package("data", get_full_url = TRUE)
#'
#'  url_package("api")
#'
#'  url_package("docs", desc_or_alias="alias")
#'  url_package("docs", desc_or_alias="redirect")
#'  url_package("code", desc_or_alias="alias")
#'  url_package("data", desc_or_alias="alias")
#'
#' @return a single URL or owner/repo as a character string
#'
#' @export
#' @keywords internal
#'
url_package <- function(
    type = c(

      'code', 'ejamrepo', 'ejscreenrepo', 'apirepo',
      'data', 'datarepo',

      'docs', 'ejamdocs', 'ejscreendocs', 'apidocs',

      'app',
      'ejam',    'ejamapp',
      'ejamdev', 'ejamappdev',
      'ejscreen', 'ejscreenapp',

      'api' # , 'apidocker'
    )[1],

    get_full_url = FALSE,
    desc_or_alias = c("desc", "alias")[1],
    docs_version = NULL,
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

  stopifnot(length(type) == 1,
            type %in% c(

              'code', 'ejamrepo', 'ejscreenrepo', 'apirepo',
              'data', 'datarepo',

              'docs', 'ejamdocs', 'ejscreendocs', 'apidocs',

              'app',
              'ejam',    'ejamapp',
              'ejamdev', 'ejamappdev',
              'ejscreen', 'ejscreenapp',

              'api' # , 'apidocker'
            )
  )
  stopifnot(length(desc_or_alias) == 1, desc_or_alias %in% c("desc", "alias", "redirect"))

  # "api": full EJAM REST API base URL from DESCRIPTION. Returned
  # as-is (a full URL, like "docs"), so it bypasses the github owner/repo handling
  # below. If the field is somehow missing, fall back to the built-in production API
  # base -- NOT url_apirepo, which names the API source-code repo (a github URL),
  # not an API endpoint.


  if (type == "api") {
    one_url <- as.vector(desc::desc(file = system.file("DESCRIPTION", package = "EJAM"))$get("url_api"))
    if (length(one_url) == 0 || is.na(one_url) || !nzchar(one_url)) {
      one_url <- "https://api.ejanalysis.com"
    }
    return(sub("/+$", "", one_url[1]))
  }

  if (desc_or_alias == "alias" && get_full_url == FALSE) {
    if (!missing(get_full_url)) {
      warning("cannot use desc_or_alias='alias' if get_full_url=FALSE, so just using get_full_url=TRUE ")
    }
    get_full_url <- TRUE
  }

  full_url_only_types <- c(
    "docs", "ejamdocs", "ejscreendocs", "apidocs",
    "app", "ejam", "ejamapp", "ejamdev", "ejamappdev",
    "ejscreen", "ejscreenapp"
  )

  if (type %in% full_url_only_types && get_full_url == FALSE) {
    if (!missing(get_full_url)) {
      warning("ignoring get_full_url=FALSE since this type is not a github repository and can only return a full URL")
    }
    get_full_url <- TRUE
  }

  url_desc <- function(field) {
    as.vector(desc::desc(file = system.file("DESCRIPTION", package = "EJAM"))$get(field))
  }

  if (desc_or_alias %in% c("alias", "redirect")) {

    # use redirects (or cloudflare aliases) URL from instead of basic URL
    get_full_url <- TRUE # already handled but just in case
}

    # 'code', 'ejamrepo', 'ejscreenrepo', 'apirepo',
    # 'data', 'datarepo',
    #
    # 'docs', 'ejamdocs', 'ejscreendocs', 'apidocs',
    #
    # 'app',
    # 'ejam',    'ejamapp',
    # 'ejamdev', 'ejamappdev',
    # 'ejscreen', 'ejscreenapp',
    #
    # 'api' # , 'apidocker'

    ## interpret synonyms for the same type, and get the corresponding   URL from DESCRIPTION file

    if (desc_or_alias == "alias") {
      suffix <- "_alias"
    }
    if (desc_or_alias == "redirect") {
      suffix <- "_redirect"
    }
    if (desc_or_alias == "desc") {
      suffix <- ""
    }

    if (type %in% c("code", "ejamrepo")) {
      one_url <-  url_desc(paste0("url_ejamrepo", suffix))
      domain <- "github.com"
    }
    if (type == c("ejscreenrepo")) {
      one_url <- url_desc(paste0("url_ejscreenrepo", suffix))
      domain <- "github.com"
    }
    if (type == c("apirepo")) {
      one_url <- url_desc(paste0("url_apirepo", suffix))
      domain <- "github.com"
    }
    if (type %in% c("data", "datarepo")) {
      one_url <-  url_desc(paste0("url_ejamdata", suffix))
      domain <- "github.com"
    }
    if (type %in% c("docs", "ejamdocs")) {
      one_url <-  url_desc(paste0("url_ejamdocs", suffix))
    }
    if (type %in% c("ejscreendocs")) {
      one_url <-  url_desc(paste0("url_ejscreendocs", suffix))
    }
    if (type %in% c("apidocs")) {
      one_url <-  url_desc(paste0("url_apidocs", suffix))
    }
    if (type %in% c("ejam", "ejamapp", "app")) {
      one_url <- url_desc(paste0("url_ejamapp", suffix))
    }
    if (type %in% c("ejamdev", "ejamappdev")) {
      one_url <- url_desc(paste0("url_ejamapp_dev", suffix))
    }
    if (type %in% c("ejscreen", "ejscreenapp")) {
      one_url <- url_desc(paste0("url_ejscreenapp", suffix))
    }
    if (type %in% c("api")) {
      one_url <- url_desc(paste0("url_api", suffix))
    }
    # , 'apidocker'

## this should be obsolete now that all types of URLs are in DESCRIPTION file
  ## but needs to be confirmed ok
  #
  # if (desc_or_alias == "desc") {
  #   # desc_or_alias == "desc" (default) and get_full_url = TRUE or FALSE
  #   # look at DESCRIPTION file
  #
  #   ## can rewrite this chunk below, to use the full URLs now available in DESCRIPTION file...
  #   ## TO BE CONTINUED .. WORK IN PROGRESS
  #
  #   if (type == "data") {
  #     one_url <- url_desc("ejam_data_repo")
  #     one_url <- paste0("https://github.com/", one_url)
  #     domain <- "github.com"
  #   }
  #   if (type == "code") {
  #     domain <- "github.com"
  #   }
  #   if (type == "docs") {
  #     domain <- "github.io"
  #   }
  #   if (type %in% c("code", "docs")) {
  #     # split out each URL from that data field that stored more than one URL
  #     both_urls <- desc::desc(file = system.file("DESCRIPTION", package = "EJAM"))$get("URL")
  #     both_urls <- as.vector(unlist(strsplit(gsub(" |\n", "", both_urls), ",")))
  #     one_url <- grep(domain, both_urls, value = T)
  #   }
  #
  #   if (type == "app") {
  #     one_url <- url_desc("url_ejamapp")
  #   }
  #
  # }

  # Versioned docs support (type = "docs", desc path only). Within a pkgdown CI build,
  # EJAM_DOCS_BASE_URL overrides the docs base so rendered Rd/Rmd links stay inside the
  # version being built. Otherwise docs_version (e.g. "dev", "v3.2024.0") appends a
  # subpath to the canonical root docs URL. Alias shortcuts always point to root only.
  if (type == "docs" && desc_or_alias == "desc") {
    env_base <- Sys.getenv("EJAM_DOCS_BASE_URL")
    if (nzchar(env_base)) {
      return(sub("/+$", "", env_base))
    }
    base <- sub("/+$", "", one_url[1])
    if (!is.null(docs_version) && nzchar(docs_version)) {
      base <- paste0(base, "/", sub("^/+|/+$", "", docs_version))
    }
    return(base)
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
