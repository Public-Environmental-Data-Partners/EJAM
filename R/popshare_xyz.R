##################################################################### #

#' top X percent of sites account for what percent of residents?
#'
#' What fraction of total population is accounted for by the top X percent of places?
#' @param pop vector of population totals across places,
#'   like out$results_bysite$pop where out is the output of ejamit()
#' @param x a fraction of 1, the share of all places (or a vector of values)
#' @param astext if TRUE, return text of description of results
#' @param dig rounding digits for text output
#' @return A fraction of 1 (or a vector of results) or text
#' @examples
#'  x <- testoutput_ejamit_100pts_1miles$results_bysite
#'  popshare_p_lives_at_what_pct(x$pop, p = 0.50, astext=TRUE)
#'  popshare_p_lives_at_what_n(  x$pop, p = c(0.50, 0.67, 0.80, 0.95))
#'  popshare_at_top_x_pct(       x$pop, x = c(0.25, 0.50, .90))
#'  popshare_at_top_n(           x$pop, n = c(1, 5, 10))
#'
#' @export
#'
popshare_at_top_x_pct = function(pop, x = 0.20, astext = FALSE, dig = 0) {

  if (!is.vector(pop)) {
    warning('pop must be a vector')
    return(NULL)
  }

  pop = sort(pop,decreasing = T)
  frac = cumsum(pop) / sum(pop)
  share = quantile(frac, probs = x)

  sharetext <- paste0( paste0(round(100 * share, 0), "%"), collapse = ", ")
  xtext <- paste0( paste0(round(100 * x, dig), "%"), collapse = ", ")
  msg <- paste0(xtext, " of places account for ", sharetext, " of the total population")

  if (astext) {
    return(msg)
  } else {
    cat(msg)
    cat("\n\n")
    return(share)
  }
}
##################################################################### #


#' top N sites account for what percent of residents?
#'
#' What fraction of total population is accounted for by the top N places?
#' @param pop vector of population totals across places,
#'   like out$results_bysite$pop where out is the output of ejamit()
#' @param n the number of places to consider
#' @param astext if TRUE, return text of description of results
#' @param dig rounding digits for text output
#' @return A fraction of 1
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

  if (!is.vector(pop)) {
    warning('pop must be a vector')
    return(NULL)
  }
  pop = sort(pop, decreasing = T)
  frac = cumsum(pop) / sum(pop)
  share = frac[n]

  sharetext <- paste0( paste0(round(100 * share, dig), "%"), collapse = ", ")
  ntext <- paste0( n,  collapse = ", ")
  msg <- paste0(ntext, " places account for ", sharetext, " of the total population")

  if (astext) {
    return(msg)
  } else {
    cat(msg)
    cat("\n\n")
    return(share)
  }
}
##################################################################### #


#' how many sites account for P percent of residents?
#'
#' @param pop vector of population totals across places,
#'   like out$results_bysite$pop where out is the output of ejamit()
#' @param p share of population (0-1, fraction), vector of one or more
#' @param astext if TRUE, return text of description of results
#' @param dig rounding digits for text output
#'
#' @return vector of numbers of sites, or text about that
#' @examples
#'  x <- testoutput_ejamit_100pts_1miles$results_bysite
#'  popshare_p_lives_at_what_pct(x$pop, p = 0.50, astext=TRUE)
#'  popshare_p_lives_at_what_n(  x$pop, p = c(0.50, 0.67, 0.80, 0.95))
#'  popshare_at_top_x_pct(       x$pop, x = c(0.25, 0.50, .90))
#'  popshare_at_top_n(           x$pop, n = c(1, 5, 10))
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
#' @param atleast_not_exact if atleast_not_exact=TRUE and astext=T, answer is like
#'   "10% of places account for at least 50% of the total population"
#'   and if atleast_not_exact=F, answer is like
#' @param whatn if TRUE, returns count of sites not fraction
#'
#' @return vector of fractions 0-1 of all sites, or text about that
#' @examples
#'  x <- testoutput_ejamit_10pts_1miles$results_bysite[4:9,]
#'  cbind(pctofsites= round((1:length(x$pop))/length(x$pop),2),
#'    pctofpop = round(cumsum(sort(x$pop, decreasing = T))/sum(x$pop) ,2))
#'  popshare_p_lives_at_what_pct(x$pop, p = 0.50, astext=TRUE)
#'  popshare_p_lives_at_what_pct(x$pop, p = 0.50, astext=TRUE, atleast_not_exact=FALSE)
#'  popshare_p_lives_at_what_pct(x$pop, p = 0.50, astext=F)
#'  popshare_p_lives_at_what_pct(x$pop, p = 0.50, astext=F, atleast_not_exact=FALSE)
#'  ## for more than one p
#' popshare_p_lives_at_what_pct(x$pop, p = c(0.50, 0.67, 0.80, 0.95) )
#'
#'  popshare_p_lives_at_what_n(  x$pop, p = c(0.50, 0.67, 0.80, 0.95))
#'  popshare_at_top_x_pct(       x$pop, x = c(0.25, 0.50, .90))
#'  popshare_at_top_n(           x$pop, n = c(1, 5, 10))
#'
#' @export
#'
popshare_p_lives_at_what_pct <- function(pop, p, astext = FALSE, dig = 0, atleast_not_exact = TRUE, whatn = FALSE) {

  if (!is.vector(pop)) {
    warning('pop must be a vector')
    return(NULL)
  }
  if (any(is.na(pop))) {
    warning("some pop were NA, likely due to very small area being analyzed, so those will be treated as zero population for reporting on share of population vs share of sites")
    pop[is.na(pop)] <- 0
    }

  pop <- sort(pop, decreasing = T)

  siteshare                <- vector(length = length(p))
  sitecountcan             <- vector(length = length(p))
  pct_of_pop_for_siteshare <- vector(length = length(p))

  for (i in 1:length(p)) {

    pct_of_pop   <-    cumsum(pop)  /    sum(pop)
    pct_of_sites <- (1:length(pop)) / length(pop)

    accounts_for_at_least_p  <- pct_of_pop >= p[i]
    sitecountcan[i]             <- sum(             accounts_for_at_least_p)
    siteshare[i]                <- min(pct_of_sites[accounts_for_at_least_p])
    pct_of_pop_for_siteshare[i] <- min(pct_of_pop[  accounts_for_at_least_p])
  }

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

  cat(paste0( msg, "\n", msg_exact), "\n\n")

  if (astext) {
    if (atleast_not_exact) {
      return(msg)
    } else {
      return(msg_exact)
    }
  } else {

    if (atleast_not_exact) {
      return(siteshare)
    } else {
      return(siteshare)
    }
  }
}
##################################################################### #
