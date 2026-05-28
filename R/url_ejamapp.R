

#' get URL for live EJAM app
#'
#' @param browse set to TRUE to open the URL in a browser (if interactive)
#' @returns URL
#' @seealso [url_ejscreenmap()] [url_ejamapi()] [url_package()]
#'
#' @export
#'
url_ejamapp <- function(browse = FALSE) {

  urlx = "https://ejanalysis.com/ejamapp"
  if (browse & interactive()) {
    browseURL(urlx)
  }
  return(urlx)
}


