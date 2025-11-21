
#' UTILITY - see what is in y not x
#'
#' utility just like setdiff except for y,x instead of x,y
#' @examples
#'   setdiff(   1:4, 3:8)
#'   EJAM:::setdiff_yx(1:4, 3:8) # makes it easy to check both without
#'
#' @keywords internal
#'
setdiff_yx = function(x,y) setdiff(y,x)
##################################################################### #

#' UTILITY - see what is only in x or y but not both - just like setdiff except for y,x and also x,y
#'
#' setdiff2 aka unshared just shows which elements are in one and only one of the sets x and y
#' @examples EJAM:::setdiff2(1:4, 3:8)
#'
#' @keywords internal
#'
setdiff2 <- function(x,y) {setdiff(union(x,y), intersect(x,y))}
##################################################################### #

#' UTILITY - see what is only in x or y but not both - just like setdiff except for y,x and also x,y
#'
#' setdiff2 aka unshared just shows which elements are in one and only one of the sets x and y
#' @examples EJAM:::unshared(1:4, 3:8)
#'
#' @keywords internal
#'
unshared <- function(x,y) {setdiff(union(x,y), intersect(x,y))}
##################################################################### #
