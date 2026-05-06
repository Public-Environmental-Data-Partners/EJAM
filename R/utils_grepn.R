
#' utility - how many times within each element of x vector is the pattern matched ?
#'
#' @param pattern passed to `gregexec()`
#' @param x a vector of character strings
#' @return vector of numbers
#' @seealso [EJAM:::find_in_files()]
#' @keywords internal
#' @export
#'
grepn <- function(pattern, x) {

  # Also see EJAM:::find_in_files()
  #
  # Related: EJAM:::found_in_files()
  # Undocumented related functions:
  # EJAM:::found_in_N_files_T_times()
  # EJAM:::grab_hits()
  # EJAM:::grepn()

  info = gregexec(pattern = pattern, text = x)
  sapply(info, function(z) ifelse(z[1] == -1, 0, length(z)))
}
