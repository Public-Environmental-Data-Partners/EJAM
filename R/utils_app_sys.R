#' Access files from app code
#'
#' Utility from golem pkg to help code refer to files, in correct folder
#' 
#' @details 
#'   [system.file()] refers to the installed or 
#'   loaded version of the package.
#'   R will during installation move all source/EJAM/inst/xyz to
#'   installed/EJAM/xyz
#'   We use golem helper app_sys() to ensure we point to 
#'   the right folder, which in source pkg is 
#'   EJAM/inst/app/www/ejam_styling.css but in
#'   installed pkg is EJAM/app/www/ejam_styling.css
#'   
#' NOTE: If you manually change your package name in the DESCRIPTION,
#' don't forget to change it here too, and in the config file.
#' For a safer name change mechanism, use `[golem::set_golem_name()]`
#'
#' @param ... character vectors, specifying subdirectory and file(s)
#' within your package. The default, none, returns the root of the app.
#'
#' @noRd
#' 
app_sys <- function(...) {
 
  system.file(..., package = "EJAM")
}
###################################################################### #


