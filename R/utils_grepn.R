
#' Count regex matches within each element of a character vector
#'
#' @param pattern pattern to search for, passed to `gregexec()`
#' @param x a vector of character strings to search within
#' @param ignore.case passed to `gregexec()`
#'
#' @returns vector of numbers, same length as x
#'
#' @seealso [grepns()] [grepls()] [find_in_files()] [found_in_files()]
#'   [found_in_N_files_T_times()] [grep_lines()]
#'
#' @details
#' - `grepn()` counts matches for one pattern across a character vector.
#' - `grepns()` handles multiple patterns and can return either a matrix of
#'   counts per string or a vector summarizing hits per pattern.
#' - `grepls()` handles multiple patterns and returns logical presence/absence
#'   results rather than counts.
#'
#' @examples
#'  grepn("x", c("0 abc", "1 uppercase X", "1 xyz", "2 xx", "3 x x x"))
#'  grepn("x", c("0 abc", "1 uppercase X", "1 xyz", "2 xx", "3 x x x"), ignore.case = FALSE)
#'
#'  grepns(c("x", "y"), c("yes", "yx", "this 1 has some x x xxxxx"))
#'  grepns(c("hi", "other", 'x'), c("said hi ther hi hi hi e", 'hi', 'another', 'none'),
#'          rowperx = TRUE, count1perx = TRUE)
#'  grepns(c("hi", "other", 'x'), c("said hi ther hi hi hi e", 'hi', 'another', 'none'),
#'          rowperx = FALSE, count1perx = TRUE)
#'  grepns(c("hi", "other", 'x'), c("said hi ther hi hi hi e", 'hi', 'another', 'none'),
#'          rowperx = TRUE, count1perx = FALSE)
#'  grepns(c("hi", "other", 'x'), c("said hi ther hi hi hi e", 'hi', 'another', 'none'),
#'          rowperx = FALSE, count1perx = FALSE)
#'
#'  grepls(c("hi", "other", 'x'), c("said hi ther hi hi hi e", 'hi', 'another', 'none'),
#'    rowperx = TRUE)
#'  grepls(c("hi", "other", 'x'), c("said hi ther hi hi hi e", 'hi', 'another', 'none'),
#'    rowperx = FALSE)
#'
#'
#' @export
#' @keywords internal
#'
grepn = function(pattern, x, ignore.case = TRUE) {

  info = gregexec(pattern = pattern, text = x, ignore.case = ignore.case)
  sapply(info, function(z) ifelse(z[1] == -1, 0, length(z)))
}
########################################################################### #

#' Count matches for multiple patterns across a character vector
#'
#' @param patterns vector of 1+ patterns to search for, passed one at a time to [gregexec()]
#' @param x a vector of character strings to search within
#' @param ignore.case passed to [gregexec()]
#'
#' @param rowperx whether to return a matrix with one row per element of `x`
#'   and one column per pattern, or instead return a vector with one element
#'   per pattern summarizing across all of `x`
#' @param count1perx whether to count only 1 match per pattern per element of x,
#'   or to count all matches (i.e., if there are 3 matches for a pattern in one element of x, count as 1 or 3)
#'
#' @returns If `rowperx = TRUE`, a matrix with one row per element of `x` and
#'   one column per pattern. If `rowperx = FALSE`, a vector with one element
#'   per pattern summarizing across all of `x`.
#'
#' @inherit grepn seealso
#' @inherit grepn examples
#'
#' @export
#' @keywords internal
#'
grepns = function(patterns, x, ignore.case = TRUE, rowperx = FALSE, count1perx = TRUE) {

  if (count1perx) {
    z = sapply(patterns, function(pattern) {
      ifelse(grepl(pattern = pattern, x = x, ignore.case = ignore.case), 1, 0)
    })
  } else {
    z = sapply(patterns, function(pattern) {
      grepn(pattern = pattern, x = x, ignore.case = ignore.case)
    })
  }

  if (rowperx) {
    return(z)
  } else {
    return(colSums(z))
  }
}
########################################################################### #
########################################################################### #

#' Detect whether multiple patterns occur in a character vector
#'
#' @inherit grepn examples
#' @inherit grepn seealso
#' @inheritParams grepns
#' @returns If `rowperx = TRUE`, a logical matrix with one row per element of
#'   `x` and one column per pattern. If `rowperx = FALSE`, a logical vector
#'   with one element per pattern.
#'
#' @export
#' @keywords internal
#'
grepls = function(patterns, x, ignore.case = TRUE, rowperx = FALSE) {

  z = sapply(patterns, function(pattern) {
    grepl(pattern = pattern, x = x, ignore.case = ignore.case)
  })

  if (rowperx) {
    return(z)
  } else {
    return(colSums(z) > 0)
  }
}
########################################################################### #
