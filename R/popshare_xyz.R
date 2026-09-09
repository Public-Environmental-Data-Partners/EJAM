# Shared cumulative population curve, with the origin included for small samples.
popshare_curve <- function(pop) {
  if (!is.numeric(pop) || !is.null(dim(pop))) {
    stop("pop must be a numeric vector")
  }
  if (anyNA(pop)) {
    warning("some pop were NA, likely due to very small area being analyzed, so those will be treated as zero population for reporting on share of population vs share of sites")
    pop[is.na(pop)] <- 0
  }
  if (any(!is.finite(pop) | pop < 0)) {
    stop("pop must contain finite, nonnegative populations")
  }
  pop <- sort(pop, decreasing = TRUE)
  cumulative <- cumsum(pop)
  total <- if (length(pop) > 0) tail(cumulative, 1) else 0
  if (!is.finite(total)) stop("total population must be finite")
  list(n = length(pop), fraction = if (total > 0) c(0, cumulative / total) else NULL)
}

popshare_check_fraction <- function(x) {
  if (!is.numeric(x) || any(!is.finite(x) | x < 0 | x > 1)) {
    stop("shares must be finite numbers between 0 and 1")
  }
}

##################################################################### #

#' top X percent of sites account for what percent of residents?
#'
#' What fraction of total population is accounted for by the top X percent of places?
#' Linear interpolation between whole-site cumulative totals includes the origin:
#' zero percent of sites accounts for zero percent of population.
#' @param pop vector of population totals across places,
#'   like out$results_bysite$pop where out is the output of ejamit()
#' @param x a fraction of 1, the share of all places (or a vector of values)
#' @param astext if TRUE, return text of description of results
#' @param dig rounding digits for text output
#' @details Missing populations are treated as zero with a warning. Empty or all-zero
#' populations return NA shares because the population fraction is undefined.
#' @return A fraction of 1 (or a vector of results) or text
#' @seealso [popshare_at_top_x_pct()] [popshare_at_top_n()] [popshare_p_lives_at_what_n()] [popshare_p_lives_at_what_pct()]
#' @inherit popshare_at_top_n examples
#'
#' @export
#'
popshare_at_top_x_pct = function(pop, x = 0.20, astext = FALSE, dig = 0) {

  curve <- popshare_curve(pop)
  popshare_check_fraction(x)
  share <- if (is.null(curve$fraction)) {
    rep(NA_real_, length(x))
  } else {
    stats::approx(x = (0:curve$n) / curve$n, y = curve$fraction, xout = x)$y
  }

  sharetext <- paste0( paste0(round(100 * share, dig), "%"), collapse = ", ")
  xtext <- paste0( paste0(round(100 * x, dig), "%"), collapse = ", ")
  msg <- paste0(xtext, " of places account for ", sharetext, " of the total population")

  if (astext) {
    return(msg)
  } else {
    if (interactive() && !shiny::isRunning()) {
    cat(msg)
    cat("\n\n")
    }
    return(share)
  }
}
##################################################################### #


#' top N sites account for what percent of residents?
#'
#' What fraction of total population is accounted for by the top N places?
#' @param pop vector of population totals across places,
#'   like out$results_bysite$pop where out is the output of ejamit()
#' @param n nonnegative whole number of places to consider, capped at the number of sites
#' @param astext if TRUE, return text of description of results
#' @param dig rounding digits for text output
#' @details Missing populations are treated as zero with a warning. Empty or all-zero
#' populations return NA shares because the population fraction is undefined.
#' @return A fraction of 1
#' @seealso [popshare_at_top_x_pct()] [popshare_at_top_n()] [popshare_p_lives_at_what_n()] [popshare_p_lives_at_what_pct()]
#' @examples
#'  x <- testoutput_ejamit_100pts_1miles$results_bysite
#'  popshare_p_lives_at_what_pct(x$pop, p = 0.50, astext=TRUE)
#'  popshare_p_lives_at_what_n(  x$pop, p = c(0.50, 0.67, 0.80, 0.95))
#'  popshare_at_top_x_pct(       x$pop, x = c(0.25, 0.50, .90))
#'  popshare_at_top_n(           x$pop, n = c(1, 5, 10))
#'
#' @export
#'
popshare_at_top_n = function(pop, n=10, astext=FALSE, dig=0) {

  curve <- popshare_curve(pop)
  if (!is.numeric(n) || any(!is.finite(n) | n < 0 | n != floor(n))) {
    stop("n must contain nonnegative whole numbers")
  }
  n <- pmin(n, curve$n)
  share <- if (is.null(curve$fraction)) rep(NA_real_, length(n)) else curve$fraction[n + 1]

  sharetext <- paste0( paste0(round(100 * share, dig), "%"), collapse = ", ")
  ntext <- paste0( n,  collapse = ", ")
  msg <- paste0(ntext, " places account for ", sharetext, " of the total population")

  if (astext) {
    return(msg)
  } else {
    if (interactive() && !shiny::isRunning()) {
    cat(msg)
    cat("\n\n")
    }
    return(share)
  }
}
##################################################################### #
##################################################################### #


#' how many sites account for P percent of residents?
#'
#' @param pop vector of population totals across places,
#'   like out$results_bysite$pop where out is the output of ejamit()
#' @param p share of population (0-1, fraction), vector of one or more
#' @param astext if TRUE, return text of description of results
#' @param dig rounding digits for text output
#' @return vector of numbers of sites, or text about that
#' @seealso [popshare_at_top_x_pct()] [popshare_at_top_n()] [popshare_p_lives_at_what_n()] [popshare_p_lives_at_what_pct()]
#' @inherit popshare_p_lives_at_what_pct examples
#'
#' @export
#'
popshare_p_lives_at_what_n <- function(pop, p, astext = FALSE, dig = 0) {

  popshare_p_lives_at_what_pct(pop = pop, p = p, astext = astext, dig = dig, whatn = TRUE)

}
##################################################################### #


#' what percent of sites is enough to account for (at least) P percent of residents?
#' minimum share of sites that can account for at least P% of population
#' @param pop vector of population totals across places,
#'   like out$results_bysite$pop where out is the output of ejamit()
#' @param p share of population (0-1, fraction), vector of one or more
#' @param astext if TRUE, return text of description of results
#' @param dig rounding digits for text output
#' @param atleast_not_exact if atleast_not_exact = TRUE and astext = TRUE, answer is like
#'   "10% of places account for at least 50% of the total population"
#'   and if atleast_not_exact = FALSE, answer is like
#' @param whatn if TRUE, returns count of sites not fraction
#' @details Missing populations are treated as zero with a warning. Empty or all-zero
#' populations return NA. A zero target needs zero sites when total population is positive.
#' @return vector of fractions 0-1 of all sites (or whole-site counts if whatn is TRUE), or text
#' @seealso [popshare_at_top_x_pct()] [popshare_at_top_n()] [popshare_p_lives_at_what_n()] [popshare_p_lives_at_what_pct()]
#' @examples
#'  x <- testoutput_ejamit_10pts_1miles$results_bysite[4:9, ]
#'  # x <- testoutput_ejamit_1000pts_1miles$results_bysite
#'  x <- x[!is.na(x$pop), ]
#'  # set pop to zero or remove sites where pop was NA
#'  cbind(pctofsites = round((1:length(x$pop)) / length(x$pop), 2),
#'    pctofpop = round(cumsum(sort(x$pop, decreasing = TRUE)) / sum(x$pop, na.rm=TRUE), 2))
#'
#'  popshare_p_lives_at_what_pct(x$pop, p = 0.50, astext=TRUE)
#'  popshare_p_lives_at_what_pct(x$pop, p = 0.50, astext=TRUE, atleast_not_exact=FALSE)
#'  popshare_p_lives_at_what_pct(x$pop, p = 0.50, astext=FALSE)
#'  popshare_p_lives_at_what_pct(x$pop, p = 0.50, astext=FALSE, atleast_not_exact=FALSE)
#'
#'  ## for more than one p
#'  popshare_p_lives_at_what_pct(x$pop, p = c(0.50, 0.67, 0.80, 0.95) )
#'
#'  popshare_p_lives_at_what_n(  x$pop, p = c(0.50, 0.67, 0.80, 0.95))
#'  popshare_at_top_x_pct(       x$pop, x = c(0.25, 0.50, .90))
#'  popshare_at_top_n(           x$pop, n = c(1, 5, 10))
#'
#' @export
#'
popshare_p_lives_at_what_pct <- function(pop, p, astext = FALSE, dig = 0, atleast_not_exact = TRUE, whatn = FALSE) {

  curve <- popshare_curve(pop)
  popshare_check_fraction(p)
  sitecountcan <- rep(NA_real_, length(p))
  pct_of_pop_for_siteshare <- rep(NA_real_, length(p))
  if (!is.null(curve$fraction)) {
    for (i in seq_along(p)) {
      # First cumulative crossing is the minimum number of whole sites needed.
      # Counting all later crossings instead gives the wrong end of the series.
      sitecountcan[i] <- which(curve$fraction >= p[i])[1] - 1L
      pct_of_pop_for_siteshare[i] <- curve$fraction[sitecountcan[i] + 1L]
    }
  }
  siteshare <- if (curve$n > 0) sitecountcan / curve$n else rep(NA_real_, length(p))

  sharetext       <- paste0( paste0(round(100 * p, dig), "%"), collapse = ", ")

  if (whatn) {
    sitesharetext <- paste0(sitecountcan, collapse = ", ")
  } else {
    sitesharetext <- paste0(round(100 * siteshare, dig), "%",  collapse = ", ")
  }
  pct_of_pop_for_siteshare_text <- paste0(round(100 * pct_of_pop_for_siteshare, dig), "%",  collapse = ", ")

  msg        <- paste0("The most-populated ", sitesharetext, " of the ", length(pop)," places can account for at least ",
                       sharetext,
                       " of the total population of all sites as a whole.")
  msg_exact  <- paste0("The most-populated ", sitesharetext, " of the ", length(pop)," places can account for exactly ",
                       pct_of_pop_for_siteshare_text,
                       " of the total population of all sites as a whole.")
  if (interactive() && !shiny::isRunning()) {
    cat(paste0( msg, "\n", msg_exact), "\n\n")
    }
  if (astext) {
    if (atleast_not_exact) {
      return(msg)
    } else {
      return(msg_exact)
    }
  } else {

    return(if (whatn) sitecountcan else siteshare)
  }
}
##################################################################### #
