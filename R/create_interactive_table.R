
#' creates interactive html version of site by site table in app
#' @description Builds site by site table after an analysis in EJAM app. Pulls in uploaded and analyzed data to create table
#'
#' @seealso [ejam2tableviewer()]
#'
#' @param out list of tables like data_processed in app_server, similar to output of ejamit()
#' @param reports ignored for now - info about which URLs/links/reports columns to include among those already in out
#' @param columns_used if specified in server based on defaults or inputs, these are a subset of
#'   colnames from ejamit()$results_bysite  to show in site-by-site interactive table
#' @param sitereport_download_buttons_colname header for column to create with buttons to download 1-site reports in shiny app
#' @param sitereport_download_buttons_show if TRUE, add column near first with buttons to allow download of 1-site html summary report
#'
#' @keywords internal
#'
create_interactive_table <- function(out,
                                     reports = EJAM:::global_or_param("default_reports"),
                                     sitereport_download_buttons_colname = "Download EJAM Report",
                                     sitereport_download_buttons_show = TRUE,
                                     # can limit columns to just some important subset:
                                     columns_used = NULL
) {

  ################################################################################################### #
  ################################################################################################### #
  ################################################################################################### #
  # NEW WAY ####
  #   SIMPLIFIED SHINY APP BY-SITE TABLE VIEW -   APPENDS A COLUMN OF SHINY BUTTONS FOR DOWNLOADS
  #   merging/ harmonizing
  #   create_interactive_table() for shiny app
  #   and ejam2tableviewer() for interactive use.

  if ("results_bysite" %in% names(out)) {
    x <- out$results_bysite
  } else {
    x <- out
  }
  ########### #
  ## > data.frame ####
  if (data.table::is.data.table(x)) {
    # avoid mutating upstream objects by reference
    x <- data.table::copy(x)
    data.table::setDF(x)
  }
  ########### #
  ## > subset of columns ####
  if (!is.null(columns_used) && length(columns_used) > 0) {
    x <- x[, columns_used[columns_used %in% names(x)]]
  }
  ########### #
  ## > add summary columns ####
  if ("results_summarized" %in% names(out)) {
    batch.sum.cols <- out$results_summarized$cols
    batch.sum.cols[is.na(batch.sum.cols$pop), ] <- NA
  } else {
    batch.sum.cols <- NULL
  }
  x <- x %>%
    dplyr::bind_cols(batch.sum.cols)
  ################################################################################################### #

  ## BUTTONS for 1-site reports ####

  if (sitereport_download_buttons_show) {
  # function to create shiny UI buttons, one per row (site), to download 1-site report for given site
  shinyInputmaker <- function(FUN, len, id, ...) {
    inputs <- character(len)
    for (i in seq_len(len)) {
      inputs[i] <- as.character(FUN(id[i], ...))
    }
    inputs
  }
  index <- 1:NROW(x)
  buttoncolumn <- shinyInputmaker(
    FUN = shiny::actionButton,
    len = length(index),
    id = paste0('button_', index),
    label = "Download",
    onclick = paste0('Shiny.onInputChange(\"single_site_report_button', index,'\", this.id)' )
  )
  x$buttoncolumn <- buttoncolumn
  x <- dplyr::relocate(x, buttoncolumn)  # will be second column
  names(x) <- gsub("buttoncolumn", sitereport_download_buttons_colname, names(x))
  # x <- dplyr::relocate(x, ejam_uniq_id) # done in ejam2tableviewer()
}
  ################################################################################################### #

  ## MAKE DATATABLE, DT::datatable object ####
  ### ejam2tableviewer() ####

  x <- ejam2tableviewer(x, launch_browser = FALSE)

  return(x)

  ################################################################################################### #
  ################################################################################################### #
  ################################################################################################### #

  # . ####
  # OLD WAY --------------------------- XXX ####
  {
    #
#   # It provided more ways to adjust the columns shown and their order and could add some columns for the web app,
#   # but was overly complicated and duplicated a lot of ejam2tableviewer()
#
#   # --------------------------------------------------- #
#   # . ####
#
#   if (!is.null(reports)) {
#     hyperlink_header <- sapply(reports, function(x) x$header)
#     hyperlink_text <- sapply(reports, function(x) x$text)
#   } else {
#     hyperlink_header <- NULL
#     hyperlink_text <- NULL
#   }
#
#   # COLUMN NAMES ####
#
#   ## colnames ####
#
#   cols_to_select <- c('ejam_uniq_id', 'invalid_msg',
#                       'pop',
#                       'sitereport_download_buttons_colname_placeholder', # #################### #
#                       hyperlink_header, # vector of colnames of reports
#                       names_d, names_d_subgroups,
#                       names_e #,
#                       # no names here corresponding to number above x threshold, state, region ??
#   )
#   tableheadnames <- c('Site ID',
#                       'Est. Population',
#                       # # or  Barplot/Community Report   here
#                       sitereport_download_buttons_colname,
#                       hyperlink_header, # vector of colnames of reports
#                       fixcolnames(c(names_d, names_d_subgroups, names_e), 'r', 'shortlabel'))
#
#   ## ej index columns ####
#
#   ejcols          <- c(names_ej_pctile, names_ej_state_pctile, names_ej_supp_pctile, names_ej_supp_state_pctile)
#   ejcols_short <- fixcolnames(ejcols, 'r', 'shortlabel')
#   which_ejcols_here <- which(ejcols %in% names(out$results_bysite))
#   cols_to_select <- c(cols_to_select, ejcols[which_ejcols_here])
#   tableheadnames <- c(tableheadnames, ejcols_short[which_ejcols_here])
#
#   ## out$results_summarized State, region ####
#
#   tableheadnames <- c(tableheadnames,
#                       names(out$results_summarized$cols),
#                       # 'Max of selected indicators',  ###
#                       # '# of indicators above threshold',
#                       'State', 'EPA Region')
#   # --------------------------------------------------- #
#   # . ####
#
#   # MAKE DATA FRAME ####
#
#   ## out$results_bysite ####
#
#   dt <- out$results_bysite
#
#   ## do not round again ####
#   #
#   # dt <- table_signif_round_x100(dt)
#
#   dt <- as.data.frame(dt)
#
#   # dplyr::mutate(dplyr::across(dplyr::where(is.numeric), .fns = function(x) {round(x, digits = 2)})
#   #               # *** This should not be hard coded to 2 digits - instead should follow rounding rules
#   #               # provided via table_round() and table_rounding_info() that use map_headernames$decimals  !
#   # ) %>%
#   ############################## #
#   ## BUTTONS for 1-site reports ####
#
#   dt <- dt %>%
#
#     dplyr::mutate(index = row_number()) %>%
#     dplyr::rowwise() %>%
#     dplyr::mutate(
#       pop = ifelse(valid == TRUE, pop, NA),
#       # sitereport_download_buttons_colname =
#       # `Download EJAM Report`
#       sitereport_download_buttons_colname_placeholder = ifelse(
#         valid == TRUE,
    #
#         shinyInputmaker(
#           FUN = actionButton, len = 1,
#           id = paste0('button_', index),
#           label = "Download",
#           onclick = paste0('Shiny.onInputChange(\"single_site_report_button', index,'\", this.id)' )
#         ),
    #
#         '')
#     ) %>%
#     dplyr::ungroup() %>%
#     dplyr::select(dplyr::all_of(cols_to_select), ST)
#
#   names(dt) <- gsub("sitereport_download_buttons_colname_placeholder", sitereport_download_buttons_colname, names(dt))
#
#
#   ############################## #
#   ## out$results_summarized  from batch.summarize() ####
#
#   batch.sum.cols <- out$results_summarized$cols
#   batch.sum.cols[is.na(batch.sum.cols$pop), ] <- NA
#
#   dt_final <- dt %>%
#     dplyr::bind_cols(batch.sum.cols) %>%
#
#     ## not include count above threshold ? ####
#   #
#   # dplyr::mutate(
#   #   Number.of.variables.at.above.threshold.of.90 = ifelse(
#   #   is.na(pop), NA,
#   #   Number.of.variables.at.above.threshold.of.90)) %>%
#
#   ## was pop already rounded ? ####
#   dplyr::mutate(pop = ifelse(is.na(pop), NA, pop)) %>% # prettyNum(round(pop), big.mark = ','))) %>%
#
#     ## was State info already there ? ####
#   ### should already have added ST, statename, REGION ?
#   dplyr::left_join(stateinfo %>% dplyr::select(ST, statename, REGION), by = 'ST') %>%
#     dplyr::mutate(
#       REGION = factor(REGION, levels = 1:10),
#       statename = factor(statename)
#     ) %>%
#     dplyr::select(-ST ) # , -Max.of.variables)    # should be made more flexible so column need not be Max.of.variables
#
#   ## finalize colnames  ####
#   colnames(dt_final) <- tableheadnames # not a very robust way to do this!
#
#   ## URLs linkify was already done by ejamit()  ####
#   # if (!is.null(hyperlink_header)) {
#   #   dt_final[ , hyperlink_header] <- sapply(dt_final[ , hyperlink_header], function(x) url_linkify(x, hyperlink_text))
#   # }
#
#   ## reorder columns more!? ####
#
#   dt_final <- dt_final %>%
#     dplyr::relocate(dplyr::all_of(c('Invalid Reason', 'State', 'EPA Region')),
#                     # , '# of indicators above threshold'),
#                     .before = 2)
#
#   ## set # of indicators above threshold to NA if population = 0
#   # dt_final <- dt_final %>%
#   #   dplyr::mutate(`# of indicators above threshold` = ifelse(`Est. Population` == 0, 'N/A',
#   #                                                                `# of indicators above threshold`))
#   ############################## #
#   # . ####
#   # MAKE DATATABLE via DT::datatable() ####
#
#   n_cols_freeze <- 1
#
#   ## format data table of site by site table
#   # see also  EJAM/inst/notes_MISC/DT_datatable_tips_options.R
#
#   out_dt <- DT::datatable(dt_final,
#                           rownames = FALSE,
#                           ## add column filters (confirm that does work)
#                           filter = 'top',
#                           ## allow selection of one row at a time (remove to allow multiple)
#                           #selection = 'single',
#                           selection = 'none',
#                           ## add-in for freezing columns
#                           extensions = c('FixedColumns'),
#                           options = list(
#                             ## column width
#                             autoWidth = TRUE,
#                             ## remove global search box
#                             dom = 'lrtip',
#                             ## freeze header row when scrolling down
#                             fixedHeader = TRUE,
#                             fixedColumns = list(leftColumns = n_cols_freeze),
#                             pageLength = 100,
#                             ## allow scroll left-to-right
#                             scrollX = TRUE,
#                             ## set scroll height up and down
#                             scrollY = '500px'
#                           ),
#                           ## set overall table height
#                           height = 1500,
#                           escape = FALSE  # *** escape = FALSE may add security issue but makes links clickable in table
#   ) %>%
#     DT::formatStyle(names(dt_final), 'white-space' = 'nowrap') %>%
#
#     ## format population again? ####
#   DT::formatRound('Est. Population', digits = 0, interval = 3, mark = ',')
#
#   return(out_dt)
  } # old way
  }
################################################################################################### #
