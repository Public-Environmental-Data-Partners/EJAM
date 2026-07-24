
#' Get URL, or just owner/reponame, for the package code, datasets, or documentation website
#' as specified in the DESCRIPTION file or by redirects or aliases
#'
#' @details
#' This function reads `Config/EJAM/url_*` fields from the DESCRIPTION file.
#' Below is a snapshot of those fields at the time of writing (7/2026):
#'
#' ```
#' Config/EJAM/url_api: https://api.ejanalysis.com
#' Config/EJAM/url_api_alias: https://ejamapi.ejanalysis.com
#' Config/EJAM/url_api_redirect: https://ejanalysis.com/api
#' Config/EJAM/url_api_direct: https://ejamapi-84652557241.us-central1.run.app
#'
#' Config/EJAM/url_apirepo: https://github.com/Public-Environmental-Data-Partners/EJAM-API
#' Config/EJAM/url_apirepo_alias: https://apirepo.ejanalysis.com
#' Config/EJAM/url_apirepo_redirect: https://ejanalysis.com/apirepo
#'
#' Config/EJAM/url_apidocs: https://public-environmental-data-partners.github.io/EJAM/articles/dev-api.html
#' Config/EJAM/url_apidocs_alias: https://apidocs.ejanalysis.com
#' Config/EJAM/url_apidocs_redirect: https://ejanalysis.com/apidocs
#'
#' Config/EJAM/url_apidocker: https://hub.docker.com/r/ericnost/ejamapi
#'
#' Config/EJAM/url_ejamapp: https://ejam.publicenvirodata.org
#' Config/EJAM/url_ejamapp_alias: https://ejam.ejanalysis.com
#' Config/EJAM/url_ejamapp_redirect: https://ejanalysis.com/ejamapp
#'
#' Config/EJAM/url_ejamapp_dev: http://ejam-dev-alb-971929002.us-east-1.elb.amazonaws.com
#' Config/EJAM/url_ejamapp_dev_alias: https://ejamdev.ejanalysis.com
#' Config/EJAM/url_ejamapp_dev_redirect: https://ejanalysis.com/ejamdev
#'
#' Config/EJAM/url_ejamrepo: https://github.com/Public-Environmental-Data-Partners/EJAM
#' Config/EJAM/url_ejamrepo_alias: https://ejamrepo.ejanalysis.com
#' Config/EJAM/url_ejamrepo_redirect: https://ejanalysis.com/ejamrepo
#'
#' Config/EJAM/url_ejamdocs: https://public-environmental-data-partners.github.io/EJAM
#' Config/EJAM/url_ejamdocs_alias: https://ejamdocs.ejanalysis.com
#' Config/EJAM/url_ejamdocs_redirect: https://ejanalysis.com/ejamdocs
#'
#' Config/EJAM/url_ejscreenapp: https://pedp-ejscreen.azurewebsites.net/index.html
#' Config/EJAM/url_ejscreenapp_alias: https://ejscreen.ejanalysis.com
#' Config/EJAM/url_ejscreenapp_redirect: https://ejanalysis.com/ejscreenapp
#'
#' Config/EJAM/url_ejscreenrepo: https://github.com/Public-Environmental-Data-Partners/EJScreen
#' Config/EJAM/url_ejscreenrepo_alias: https://ejscreenrepo.ejanalysis.com
#' Config/EJAM/url_ejscreenrepo_redirect: https://ejanalysis.com/ejscreenrepo
#'
#' Config/EJAM/url_ejscreendocs: https://public-environmental-data-partners.github.io/EJAM/articles/ejscreen.html
#' Config/EJAM/url_ejscreendocs_alias: https://ejscreendocs.ejanalysis.com
#' Config/EJAM/url_ejscreendocs_redirect: https://ejanalysis.com/ejscreendocs
#'
#' Config/EJAM/url_ejscreendocs_old: https://github.com/Public-Environmental-Data-Partners/EJScreen#ejscreen
#'
#' Config/EJAM/url_ejamdata: https://github.com/Public-Environmental-Data-Partners/ejamdata
#' Config/EJAM/url_ejamdata_alias: https://ejamdata.ejanalysis.com
#' Config/EJAM/url_ejamdata_redirect: https://ejanalysis.com/ejamdata
#' ```
#'
#' (`Config/EJAM/url_api_direct`, `Config/EJAM/url_apidocker`, and
#' `Config/EJAM/url_ejscreendocs_old` are informational only -- they are stored
#' in DESCRIPTION but are not `type` values this function accepts.)
#'
#' @param type Which type of URL is needed, such as
#'   "docs", "app", "api", "code", or "data",
#'   but more specifically, "ejamapp", "ejscreenapp", "ejamrepo", etc.
#'
#'   The basic type "xyz" is stored in the DESCRIPTION field
#'   `Config/EJAM/url_xyz`, as listed below, but a URL also can be an alias or
#'   simple 301 redirect, stored in a field that has
#'   "_alias" or "_redirect" as a suffix,
#'   such as `Config/EJAM/url_ejamdocs_alias` providing the URL for
#'   `type = "ejamdocs"` and `desc_or_alias = "alias"`.
#'
#' DOCUMENTATION SITES:
#'
#'   - "ejamdocs" or "docs" (`Config/EJAM/url_ejamdocs`, also recorded in part
#'     in the standard `URL` field) is for the EJAM (and EJScreen to some extent)
#'     documentation website.
#'
#'   - "ejscreendocs" (`Config/EJAM/url_ejscreendocs`) is for the EJScreen
#'     documentation website.
#'
#'   - "apidocs" (`Config/EJAM/url_apidocs`) is for the EJAM API documentation website.
#'
#' APP OR API SERVERS:
#'
#'   - "ejam" or "ejamapp" or "app" (`Config/EJAM/url_ejamapp`) is for the EJAM Shiny app.
#'
#'   - "ejamdev" or "ejamappdev" (`Config/EJAM/url_ejamapp_dev`) is for the EJAM Shiny app development server.
#'
#'   - "ejscreen" or "ejscreenapp" (`Config/EJAM/url_ejscreenapp`) is for the live EJScreen app.
#'
#'   - "api" (`Config/EJAM/url_api`) is for the EJAM REST API base URL.
#'     Always a full URL. All functions that call or build EJAM API URLs read it from here, so the
#'     endpoint can be changed in one place (by editing `Config/EJAM/url_api`).
#'     It is the branded Cloudflare edge proxy `https://api.ejanalysis.com`
#'     (equivalently `https://ejamapi.ejanalysis.com`, stored in
#'     `Config/EJAM/url_api_alias`), which fronts the direct Cloud Run origin
#'     recorded informationally in `Config/EJAM/url_api_direct`.
#'
#' CODE OR DATA REPOSITORIES:
#'
#'   - "ejamrepo" or "code" (`Config/EJAM/url_ejamrepo`, also recorded in part
#'     in the standard `URL` field) is for the github.com repository of EJAM R package code.
#'
#'   - "ejscreenrepo" (`Config/EJAM/url_ejscreenrepo`) is for the EJScreen code repository.
#'
#'   - "apirepo" (`Config/EJAM/url_apirepo`) is for the API source-code
#'     repository on github.com and is informational only -- it is not the API endpoint.
#'
#'   - "datarepo" or "data" (`Config/EJAM/url_ejamdata`, with owner/repository
#'     shorthand also stored in `ejam_data_repo`) is for the github.com
#'     repository of datasets.
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

  # Map each accepted type (and its synonyms) to its key within the
  # Config/EJAM/ namespace in DESCRIPTION.
  url_config_prefix <- "Config/EJAM/"
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

  url_desc <- function(field) {
    config_field <- paste0(url_config_prefix, field)
    as.vector(
      desc::desc(file = system.file("DESCRIPTION", package = "EJAM"))$get(config_field)
    )
  }
  is_missing_value <- function(x) {
    length(x) == 0 || is.na(x[1]) || !nzchar(trimws(x[1]))
  }

  suffix <- switch(desc_or_alias, desc = "", alias = "_alias", redirect = "_redirect")
  one_url <- url_desc(paste0(field_by_type[[type]], suffix))
  if (is_missing_value(one_url)) {
    # Fall back to the basic Config/EJAM/url_xyz field if its "_alias" or
    # "_redirect" field is missing, and for the API fall back further to the
    # built-in production API base.
    one_url <- url_desc(field_by_type[[type]])
    if (is_missing_value(one_url)) {
      if (type == "api") {
        one_url <- "https://api.ejanalysis.com"
      } else {
        stop("DESCRIPTION file of the EJAM package is missing the field '",
             url_config_prefix, field_by_type[[type]],
             "' needed for url_package(type='", type, "')")
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
