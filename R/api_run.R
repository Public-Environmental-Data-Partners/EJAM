############################# #
# api_run() will run the API in the background as a separate R process

# https://callr.r-lib.org
# Security considerations
# callr makes a copy of the user's .Renviron file and potentially of the local or user .Rprofile, in the session temporary directory. Avoid storing sensitive information such as passwords, in your environment file or your profile, otherwise this information will get scattered in various files, at least temporarily, until the subprocess finishes. You can use the keyring package to avoid passwords in plain files.
############################# #

#' Run API in background to test/develop it
#'
#' @param fname file with API definition using plumber package
#' @param host optional, localhost IP
#' @param port optional, a port number
#' @param quiet optional, set to TRUE To reduce info printed to console
#'
#' @examples
#' # launch and try it in R console
#'  api_run()
#'
#'  urlx <- "http://127.0.0.1:3035/getblocksnearby?lat=33&lon=-99&radius=2"
#'  reqx <- httr2::request(urlx)
#'  httr2::req_dry_run(reqx)
#'  outx <- httr2::req_perform(reqx)
#'  s2b <- data.table::rbindlist(httr2::resp_body_json(outx))
#'  s2b
#'
#'
#' @return NA
#'
#' @export
#'
api_run <- function(

                    fname = system.file("plumber/plumber.R", package = "EJAM"), # the installed version unless load_all() was done
                    host = "127.0.0.1",
                    port = 3035,
                    quiet = FALSE
) {
  ############################# #
  # api_run_here() will run API in current process:

  api_run_here <- function(
                           fname = system.file("plumber/plumber.R", package = "EJAM"), # the installed version unless load_all() was done
                           host = "127.0.0.1",
                           port = 3035,
                           quiet = FALSE
  ) {

    library(plumber) # was not in DESCRIPTION of EJAM package as of 10/2025

    ## this would be slow to redo - is it really needed?
    ## now the plumber.R file says library(EJAM)
    # library(EJAM)  # must do this before load_all() for it to correctly create  cbind(global_defaults_package), e.g., global_defaults_package$report_logo
    # devtools::load_all(".")

    beepr::beep() # alerts when finished with package loading and ready
    cat("Try  http://127.0.0.1:3035/__docs__/ \n")

    fname <- fname
    ## or    # fname <- "./inst/plumber/plumber.R"
    plumber::plumb(fname) %>%
      # plumber::pr(fname) %>%

      plumber::pr_hook("exit", function() {
        # can specify any other cleanup here
        print("plumber API process is terminating")
      }) %>%

      plumber::pr_run(
        host = host,
        port = port,
        quiet = quiet
      )

  }
  ############################# #

  # run the API in the background using callr package

  library(callr)
  x <- callr::r_bg(
    api_run_here,
    args = list(
      fname = fname, # system.file("plumber/plumber.R", package = "EJAM"), # the installed version unless load_all() was done
      host = host, # "127.0.0.1",
      port = port, # 3035,
      quiet = quiet # FALSE
    )
    # , stderr = "/tmp/err"
  )

  pause(8) # check how long it takes
  browseURL("http://127.0.0.1:3035/__docs__/")

  # browseURL(paste0(host, ":", port))

  # readLines("/tmp/err")
  #
  # return(x)
}
############################# #
