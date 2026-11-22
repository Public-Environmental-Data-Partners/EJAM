#' JavaScript that wakes the EJAM API, for the app's Start button (internal)
#'
#' @description The one-site report links in the app (table of sites, map popups)
#'   open reports from the EJAM API. After a quiet period the API has no running
#'   container, and the first report then waits about a minute while one starts.
#'   When a user clicks Start, the app sends this JavaScript to the browser, which
#'   asks the API's `/warmup` address to answer and does not wait for the answer.
#'   The API then starts while the app runs the analysis, so a report link clicked
#'   afterwards opens at normal speed. See EJAM#720 and EJAM#772.
#'
#'   The request is made by the browser, not by R, so it can never delay or stop
#'   the analysis. Any error (API down, no network, blocked request) is ignored.
#'
#' @param baseurl API base address. Default is the one the report links use,
#'   `url_package("api")`.
#' @param reports list like `global_or_param("default_reports")`. If none of
#'   these report links uses [url_ejamapi()], there is nothing to wake and the
#'   result is NULL.
#' @param is_down like `global_or_param("ejamapi_is_down")`. If TRUE, the report
#'   links do not use the API, so the result is NULL.
#'
#' @return one line of JavaScript for `shinyjs::runjs()`, or NULL when no
#'   wake-up should be sent.
#' @keywords internal
#' @noRd
#'
ejamapi_wake_js <- function(baseurl = NULL,
                            reports = global_or_param("default_reports"),
                            is_down = global_or_param("ejamapi_is_down")) {

  if (isTRUE(is_down)) {return(NULL)}
  uses_api <- any(vapply(reports, function(r) {
    is.list(r) && identical(r$FUN, url_ejamapi)
  }, logical(1)))
  if (!uses_api) {return(NULL)}

  if (is.null(baseurl)) {
    baseurl <- tryCatch(url_package("api"), error = function(e) NULL)
  }
  if (length(baseurl) != 1 || is.na(baseurl) || !grepl("^https?://[^/]", baseurl)) {
    return(NULL)
  }
  wakeurl <- paste0(sub("/+$", "", trimws(baseurl)), "/warmup")

  # 'no-cors' keeps the browser from needing CORS approval; the answer is not read.
  paste0(
    "try { fetch(", jsonlite::toJSON(wakeurl, auto_unbox = TRUE),
    ", {mode: 'no-cors', cache: 'no-store', credentials: 'omit'}).catch(function () {}); } catch (e) {}"
  )
}
