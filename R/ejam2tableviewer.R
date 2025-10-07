#' See ejamit()$results_bysite in interactive table in RStudio viewer pane
#'
#' @param out output of ejamit(), or one table like \code{ejamit()$results_overall},
#'   or subset like \code{ejamit()$results_bysite[7,]}
#' @param filename optional. path and name of the html file to save the table to,
#'   or it uses tempdir() if not specified. Set it to NULL to prevent saving a file.
#' @param maxrows only load/ try to show this many rows max.
#' @param launch_browser set TRUE to have it launch browser and show report.
#'   Ignored if not interactive() or if filename is set to NULL.
#' @param ... passed to [DT::datatable()]
#'
#' @return a datatable object using [DT::datatable()]
#'   that can be printed to the console or shown in the RStudio viewer pane
#' @examples ejam2tableviewer(testoutput_ejamit_10pts_1miles)
#'
#' @export
#'
ejam2tableviewer = function(out, filename = 'automatic', maxrows = 1000, launch_browser = TRUE, ...) {

  if (!interactive()) {launch_browser <- FALSE} # but that means other functions cannot override this while not interactive.

  if ("results_bysite" %in% names(out)) {
    x <- out$results_bysite
  } else {
    x <- out
  }
  if ("sitetype" %in% names(out)) {sitetype <- out$sitetype} else {
    sitetype <- sitetype_from_dt(x)
  }
  if (!is.data.frame(x)) { # data.table is ok too
    stop("Input must be a data frame")
  }

  # cap on # of rows! ####
  x <- x[1:min(nrow(x), maxrows), ]

  # round/sigfig (again?) ####
  x <- table_signif_round_x100(x)

  x$pop <- prettyNum(round(x$pop), big.mark = ',')

  # freeze "Site ID" in column 1 ####

  n_cols_freeze <- 1
  x <- dplyr::relocate(x, ejam_uniq_id) # 1st column
  names(x) <- gsub("ejam_uniq_id", "Site ID", names(x))

  # DT::datatable() options ####

  dt <-    DT::datatable(x,

                         ## fixcolnames ####
                         colnames = fixcolnames(names(x), 'r', 'long'),
                         rownames = FALSE,

                         ## column filters ####
                         filter = 'top',

                         ## selecting rows
                         ## to allow selection of one row at a time (remove to allow multiple)
                         ###selection = 'single',
                         selection = 'none',

                         ## SCROLL RIGHT/LEFT ##############

                         extensions = c('FixedColumns'),

                         options = list(
                           fixedColumns = list(leftColumns = n_cols_freeze),
                           scrollX = TRUE,

                           ## column width ####
                           autoWidth = TRUE,

                           ## SCROLL UP/DOWN  ##############

                           ## freeze header row when scrolling down
                           fixedHeader = TRUE,
                           pageLength = 100,
                           ## set scroll height up and down
                           scrollY = '500px',

                           ## remove global search box ####
                           dom = 'lrtip'
                         ),
                         ## table height ####
                         height = 1500,

                         ## > *** not escape HTML??? for links ####
                         escape = FALSE,  # *** escape = FALSE may add security issue but makes links clickable in table

                         ...) %>%
    DT::formatStyle(names(x), 'white-space' = 'nowrap')

  ################################# #
  # . ####
  # save file if not in shiny web app ####
  #
  # if filename was missing, then create a name and save it in temp dir.
  # if filename was set to some path by user, then save it there not in temp dir
  # if filename was set to NULL by user, then do not save, and cannot see in browser
  #
  # For now at least, do not try to save file if in shiny app!
  if (!shiny::isRunning()) {

    # save/try save unless NULL was specified as a way to suppress save
    if (!is.null(filename)) {trysave <- TRUE} else {trysave <- FALSE}

    if (trysave)  {
    # (NULL would mean do not save and do not browse)

    # Validate folder and or file

    validfoldernotfile = dir.exists # function(x) {x = file.info(x)$isdir; x[is.na(x)] <- FALSE; return(x)}
      # BAD folder or missing param
      if (!validfoldernotfile(dirname(filename))) {
        if (!missing(filename)) {
          warning("ignoring filename because specified path was invalid")
        } # else default automatic needs no warning

        filename <- create_filename(ext = ".html", file_desc = "results_bysite", buffer_dist = x$radius.miles[1],
                                    site_method = sitetype, with_datetime = TRUE)
        filename <- file.path(tempdir(), filename)
      } else {
        # good folder NOT WITH a filename, define a filename in that folder
        if (validfoldernotfile(filename)) {
          mydir = filename
          filename <- create_filename(ext = ".html", file_desc = "results_bysite", buffer_dist = x$radius.miles[1],
                                      site_method = sitetype, with_datetime = TRUE)
          filename = file.path(mydir, filename)
        } else {
          # good folder, WITH a filename w good extension, that may not yet exist?
          if (validfoldernotfile(dirname(filename)) && tools::file_ext(filename) == "html") {
            # all set
          } else {
            # good folder, WITH BAD extension
            if (validfoldernotfile(dirname(filename)) && !tools::file_ext(filename) == "html") {
              warning("wrong extension, so adding .html")
              filename = paste0(filename, ".html")
            }
          }
        }
      }
      # save file:
      htmlwidgets::saveWidget(dt, filename)
      filename <- normalizePath(filename) # makes it work on Mac, e.g.
      cat("\n")
      cat("Interactive table of sites is saved here: ", filename, '\n')
      cat(paste0("To open that folder: browseURL('", dirname(filename), "')\n"))
      cat(paste0("To view that report in a browser: browseURL('", filename, "')\n"))

      # maybe launch external browser to view table:
      if (!shiny::isRunning() && launch_browser) {
        browseURL(filename)
      }
    }
  }

  ## shows table in the RStudio viewer pane by returning it
  # (even if running shiny app locally - should work on server too)
  return(dt)
}
################################################# #
