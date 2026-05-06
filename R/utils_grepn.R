
#' utility - how many times within each element of x vector is the pattern matched ?
#'
#' @param pattern passed to `gregexec()`
#' @param x a vector of character strings
#' @return vector of numbers
#' @seealso [find_in_files()]
#' @keywords internal
#' @export
#'
grepn = function(pattern, x, ignore.case = TRUE) {

  # Also see EJAM:::find_in_files()
  #
  # Related: EJAM:::found_in_files()
  # Undocumented related functions:
  # EJAM:::found_in_N_files_T_times()
  # EJAM:::grab_hits()
  # EJAM:::grepn()

  info = gregexec(pattern = pattern, text = x, ignore.case = ignore.case)
  sapply(info, function(z) ifelse(z[1] == -1, 0, length(z)))
}
########################################################################### #

# how many matches of each pattern, within each element of x vector,
# or can also report how many of x have at least one match?

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

# which of patterns are in any of the x? or also can report which x have each pattern

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


########################################################################### #

# # examples / tests
#
#   grepls(c("hi", "other", 'x'), c("said hi ther hi hi hi e", 'hi', 'another', 'none'),
#          rowperx = T)
#   grepls(c("hi", "other", 'x'), c("said hi ther hi hi hi e", 'hi', 'another', 'none'),
#          rowperx = F)
#
#
#   grepns(c("hi", "other", 'x'), c("said hi ther hi hi hi e", 'hi', 'another', 'none'),
#          rowperx = T, count1perx=T)
#   grepns(c("hi", "other", 'x'), c("said hi ther hi hi hi e", 'hi', 'another', 'none'),
#          rowperx = F, count1perx=T)
#   grepns(c("hi", "other", 'x'), c("said hi ther hi hi hi e", 'hi', 'another', 'none'),
#          rowperx = T, count1perx=F)
#   grepns(c("hi", "other", 'x'), c("said hi ther hi hi hi e", 'hi', 'another', 'none'),
#          rowperx = F, count1perx=F)
