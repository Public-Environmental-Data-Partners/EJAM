
#' utility to check if internet connection is not available
#'
#' @details A single DNS lookup can fail for a moment even when the machine is
#'   online (seen on the macOS GitHub Actions runners, where it made random
#'   boundary-download tests fail with "No internet connection seems to be
#'   available"). So this only reports offline when **every** host in
#'   `c(url, fallback_hosts)` fails to resolve on **every** one of `tries`
#'   rounds, waiting `wait`, then `2 * wait`, ... seconds between rounds.
#'   The answer is remembered for `cache_seconds`, so repeated calls (for
#'   example `skip_if(offline())` in a test and then the same check inside the
#'   function being tested) agree, and a machine that really is offline pays the
#'   retry delay only once.
#'
#' @return logical (TRUE or FALSE), TRUE if offline, FALSE if any of the hosts
#'   can be resolved
#' @param url optional host checked first, using [curl::nslookup()]
#' @param fallback_hosts other hosts to try if `url` does not resolve
#' @param tries how many rounds of lookups before deciding it is offline
#' @param wait seconds to wait before the second round (doubling after that)
#' @param cache_seconds how long to reuse the last answer for the same hosts;
#'   0 means always check again
#' @seealso offline_warning() and offline_cat() utilities unexported undocumented,
#'   either returns the same as offline() does, 
#'   while also providing, if offline, warning() or cat() info to console
#' @keywords internal
#'
offline = function(url = "r-project.org",
                   fallback_hosts = c("github.com", "census.gov"),
                   tries = 3, wait = 1, cache_seconds = 30) {

  hosts <- unique(c(url, fallback_hosts))
  key <- paste(hosts, collapse = " ")
  if (cache_seconds > 0) {
    cached <- offline_cache[[key]]
    if (!is.null(cached) &&
        difftime(Sys.time(), cached$time, units = "secs") < cache_seconds) {
      return(cached$offline)
    }
  }
  hasinternet <- FALSE
  for (i in seq_len(max(1, tries))) {
    if (i > 1 && wait > 0) {Sys.sleep(wait * 2^(i - 2))}
    for (host in hosts) {
      if (offline_host_resolves(host)) {
        hasinternet <- TRUE
        break
      }
    }
    if (hasinternet) {break}
  }
  if (cache_seconds > 0) {
    offline_cache[[key]] <- list(offline = !hasinternet, time = Sys.time())
  }
  return(!hasinternet)
}
################ # 

offline_cache <- new.env(parent = emptyenv())

offline_host_resolves = function(host) {
  isTRUE(tryCatch(!is.null(curl::nslookup(host, error = FALSE)),
                  error = function(e) FALSE))
}
################ #

offline_warning = function(text = 'NO INTERNET CONNECTION AVAILABLE') {
  off <- offline()
  if (off) {warning(text)}
  return(off)
}
################ # 

offline_cat = function(text = 'NO INTERNET CONNECTION AVAILABLE\n') {
  off <- offline()
  if (off) {cat(text)}
  return(off)
}
################ # 
