
#' Get URL, or just owner/reponame, for the package code, datasets, or documentation website
#' as specified in the DESCRIPTION file or by redirects or aliases
#'
#' @details
#' This function reads from the DESCRIPTION file, but below is a
#' snapshot of URLs that were in the DESCRIPTION file at the time of writing (7/2026):
#'
#' ```
#' url_api: https://api.ejanalysis.com
#' url_api_alias: https://ejamapi.ejanalysis.com
#' url_api_redirect: https://ejanalysis.com/api
#' url_api_direct: https://ejamapi-84652557241.us-central1.run.app
#'
#' url_apirepo: https://github.com/Public-Environmental-Data-Partners/EJAM-API
#' url_apirepo_alias: https://apirepo.ejanalysis.com
#' url_apirepo_redirect: https://ejanalysis.com/apirepo
#'
#' url_apidocs: https://public-environmental-data-partners.github.io/EJAM/articles/dev-api.html
#' url_apidocs_alias: https://apidocs.ejanalysis.com
#' url_apidocs_redirect: https://ejanalysis.com/apidocs
#'
#' url_apidocker: https://hub.docker.com/r/ericnost/ejamapi
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
#' url_ejamdata: https://github.com/Public-Environmental-Data-Partners/ejamdata
#' url_ejamdata_alias: https://ejamdata.ejanalysis.com
#' url_ejamdata_redirect: https://ejanalysis.com/ejamdata
#' ```
#'
#' (`url_api_direct`, `url_apidocker`, and `url_ejscreendocs_old` are informational
#' only -- they are stored in DESCRIPTION but are not `type` values this function accepts.)
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
#'     It is the branded Cloudflare edge proxy `https://api.ejanalysis.com`
#'     (equivalently `https://ejamapi.ejanalysis.com`, stored in `url_api_alias`),
#'     which fronts the direct Cloud Run origin recorded informationally in `url_api_direct`.
#'
#'     For development/testing, the API base can be overridden without editing
#'     DESCRIPTION: `options(ejam.api.baseurl = ...)` takes highest precedence,
#'     then the environment variable `EJAM_API_BASEURL`, then DESCRIPTION as usual.
#'     Setting either (e.g. to `http://127.0.0.1:3035`, where `EJAM:::ejamapi_local()`
#'     serves the API locally) makes every API URL the package builds -- report links
#'     in the app's tables and map popups, [url_ejamapi()], [ejamapi()] -- point at
#'     that base instead of the production API. The override applies only to the
#'     canonical lookup (`desc_or_alias = "desc"`); explicit "alias"/"redirect"
#'     lookups are unaffected. See the "Testing against a local or draft API"
#'     section of the deployment article (`vignette("dev-deployment")`).
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
#'   Only meaningful for the github repository types ("code", "ejamrepo", "ejscreenrepo",
#'   "apirepo", "data", "datarepo"); for all other types (and whenever
#'   desc_or_alias is "alias" or "redirect") a full URL is always returned.
#'
#' @param desc_or_alias must be "desc" or "alias" or "redirect" to use info from DESCRIPTION file
#'   or the URL based on a cloudflare alias or a simple 301 redirect such as
#'
#'   - https://api.ejanalysis.com (if "desc", use the basic URL from the "url_xyz" field)
#'   - https://ejamapi.ejanalysis.com (if "alias", use the cloudflare alias from the "url_xyz_alias" field, which can handle subpaths and query strings passed through to the final URL)
#'   - https://ejanalysis.com/api (if "redirect", use the simple 301 redirect from the "url_xyz_redirect" field, which cannot handle subpaths or query strings)
#'
#'   If the "_alias" or "_redirect" field is missing from DESCRIPTION, the basic
#'   "url_xyz" field is used as a fallback.
#'
#' @param docs_version optional, only used when type = "docs" or "ejamdocs". A docs subpath such as
#'   "dev", "v3.2024.0", or "v3.2022.2" to append to the canonical root
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
#'  url_package("ejamapp")
#'  url_package("ejamapp", desc_or_alias = "alias")
#'  url_package("ejscreenapp")
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
    desc_or_alias = c("desc", "alias", "redirect")[1],
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

  # map each accepted type (and its synonyms) to the DESCRIPTION field that stores its URL
  field_by_type <- c(
    code = "url_ejamrepo", ejamrepo = "url_ejamrepo",
    ejscreenrepo = "url_ejscreenrepo",
    apirepo = "url_apirepo",
    data = "url_ejamdata", datarepo = "url_ejamdata",
    docs = "url_ejamdocs", ejamdocs = "url_ejamdocs",
    ejscreendocs = "url_ejscreendocs",
    apidocs = "url_apidocs",
    app = "url_ejamapp", ejam = "url_ejamapp", ejamapp = "url_ejamapp",
    ejamdev = "url_ejamapp_dev", ejamappdev = "url_ejamapp_dev",
    ejscreen = "url_ejscreenapp", ejscreenapp = "url_ejscreenapp",
    api = "url_api"
  )
  # github repositories are the only types where the owner/repo shorthand
  # (get_full_url = FALSE) makes sense
  repo_types <- c("code", "ejamrepo", "ejscreenrepo", "apirepo", "data", "datarepo")

  stopifnot(length(type) == 1, type %in% names(field_by_type))
  stopifnot(length(desc_or_alias) == 1, desc_or_alias %in% c("desc", "alias", "redirect"))

  if (desc_or_alias %in% c("alias", "redirect") && get_full_url == FALSE) {
    if (!missing(get_full_url)) {
      warning("cannot use desc_or_alias='", desc_or_alias,
              "' if get_full_url=FALSE, so just using get_full_url=TRUE ")
    }
    get_full_url <- TRUE
  }
  if (!(type %in% repo_types) && get_full_url == FALSE) {
    if (!missing(get_full_url)) {
      warning("ignoring get_full_url=FALSE since that would not make sense -- ",
              "the owner/repo shorthand only applies to github repositories, ",
              "so returning a full URL for type = '", type, "'")
    }
    get_full_url <- TRUE
  }

  # Developer/test override of the API base URL: lets a locally-run API
  # (EJAM:::ejamapi_local(), e.g. http://127.0.0.1:3035) or a staging URL stand
  # in for the production API everywhere the package builds API URLs -- report
  # links in app tables and map popups, url_ejamapi(), ejamapi(), etc.
  # Precedence: option(ejam.api.baseurl) > env var EJAM_API_BASEURL >
  # DESCRIPTION as usual. Applies only to the canonical lookup (desc_or_alias =
  # "desc"); explicit alias/redirect lookups are left alone. See the
  # "Testing against a local or draft API" section of vignette("dev-deployment").
  if (type == "api" && desc_or_alias == "desc") {
    override <- getOption("ejam.api.baseurl", default = Sys.getenv("EJAM_API_BASEURL"))
    if (length(override) == 1 && !is.na(override) && nzchar(trimws(override))) {
      return(sub("/+$", "", trimws(override)))
    }
  }

  url_desc <- function(field) {
    as.vector(desc::desc(file = system.file("DESCRIPTION", package = "EJAM"))$get(field))
  }
  is_missing_value <- function(x) {
    length(x) == 0 || is.na(x[1]) || !nzchar(trimws(x[1]))
  }

  suffix <- switch(desc_or_alias, desc = "", alias = "_alias", redirect = "_redirect")
  one_url <- url_desc(paste0(field_by_type[[type]], suffix))
  if (is_missing_value(one_url)) {
    # fall back to the basic "url_xyz" field if the "_alias"/"_redirect" field is missing,
    # and for the API fall back further to the built-in production API base
    one_url <- url_desc(field_by_type[[type]])
    if (is_missing_value(one_url)) {
      if (type == "api") {
        one_url <- "https://api.ejanalysis.com"
      } else {
        stop("DESCRIPTION file of the EJAM package is missing the field '",
             field_by_type[[type]], "' needed for url_package(type='", type, "')")
      }
    }
  }
  one_url <- sub("/+$", "", trimws(one_url[1]))

  # Versioned docs support (EJAM docs types, desc path only). Within a pkgdown CI build,
  # EJAM_DOCS_BASE_URL overrides the docs base so rendered Rd/Rmd links stay inside the
  # version being built. Otherwise docs_version (e.g. "dev", "v3.2024.0") appends a
  # subpath to the canonical root docs URL. Alias shortcuts always point to root only.
  if (type %in% c("docs", "ejamdocs") && desc_or_alias == "desc") {
    env_base <- Sys.getenv("EJAM_DOCS_BASE_URL")
    if (nzchar(env_base)) {
      return(sub("/+$", "", env_base))
    }
    if (!is.null(docs_version) && nzchar(docs_version)) {
      one_url <- paste0(one_url, "/", sub("^/+|/+$", "", docs_version))
    }
    return(one_url)
  }

  if (get_full_url) {
    return(one_url)
  } else {
    # owner/repo shorthand for github repositories,
    # e.g. "Public-Environmental-Data-Partners/EJAM"
    return(sub("^https?://github\\.com/", "", one_url))
  }
}
############################################################################# #


# comma <- function(x) format(x, digits = 2, big.mark = ",")

############################################################################# #
