

#' ejam2means - quick look at averages, via ejamit() results
#'
#' @param ejamitout as from ejamit()
#' @param vars all or some of colnames in ejamitout$results_overall
#'
#' @return means in a useful format
#' @examples
#' out <- testoutput_ejamit_100pts_1miles
#' ejam2means(out, vars = names_e_ratio_to_state_avg)
#'
#' #' # these should tell you the same thing:
#' out$results_summarized$keystats[
#'   rownames(out$results_summarized$keystats) %in% names_e_ratio_to_state_avg,
#' ]
#' ejam2means(out, vars = names_e_ratio_to_state_avg)
#'
#' @export
#'
ejam2means <- function(ejamitout, vars = names_these) {

  # The CORRECT weighted means (avg person, generally) are already in ejamitout$results_overall[ , ..vars]

  y <- ejamitout$results_overall[ , ..vars]

  y <- table_signif_round_x100(y)

  junk <- capture.output({printable <- cbind(wtdmean = lapply(as.list(y), print))  })
  rownames(printable) <- fixcolnames(rownames(printable), 'r', 'long')
  print(printable)
  cat('\n\n')

  invisible(y)
}
######################################## #
