
#' utility for server/ui to check value of a global default setting or user-defined setting
#'
#' @details
#' This and [get_golem_options()] are very similar tools, useful in server and ui.
#' See help for [get_global_defaults_or_user_options()]
#'
#' [global_or_param()] is used a lot in server and also ui (while sometimes
#' [golem::get_golem_options()] had been used instead but now is not, for the same purpose).
#' It is used generally in ui to set default values for params that
#' are set in the global_defaults_ files and often can be
#' modified in the advanced tab. To provide alternative values as
#' params passed to [ejamapp()] you would have to understand the options
#' by seeing what they are defaulted to in the files and how they are used
#' as parameters in ui or server. See [ejamapp()]
#'
#' This is much like [golem::get_golem_options()]
#' but [global_or_param()] is more flexible/robust since it will,
#'  if vname is not already defined as found
#' by [golem::get_golem_options()]
#'
#' then as second best, see if it was defined in global_defaults_package
#' and just not yet stored as golem options because the shiny app has not yet launched.
#' That lets any function or vignette find the values defined in global_defaults_package.R
#' even if a shiny app has not yet launched.
#'
#' Then as a last resort, check if the param called vname is
#' defined in the search path such as in the
#' calling or global envt already somehow,
#' and return that value if it exists.
#' But if it is not in golem options and not found in search path,
#' this returns NULL
#'
#' @param vname a global default or user param - do a global find in files
#'   of source code for this function to see how / where it is used.
#'
#' @returns value of the param, or NULL if not found
#'
#' @keywords internal
#'
global_or_param = function(vname) {

  ################################ #
  ## 1st check if param was defined upon shiny app launch
  ## either via being passed to ejamapp() or  stored as golem global options upon app launch after having been defined by global_default_*.R file

  param_passed_to_run_app_or_global_defaults <- golem::get_golem_options(vname)

  if (!is.null(param_passed_to_run_app_or_global_defaults)) {
    return(param_passed_to_run_app_or_global_defaults)
  } else {

    ################################ #
    ## 2d, in case no shiny app launch has happened,
    ## check if set by global_defaults_package.R file and stored in list called "global_defaults_package"

    if (exists("global_defaults_package")) {
      if (vname %in% names(global_defaults_package)) {
        return(global_defaults_package[[vname]])
      }
    }
    ################################ #
    ## 3d, as last resort, check global env for the variable/option/param name

    x <- try(get(vname), silent = TRUE)

    if (inherits(x, "try-error")) {
      return(NULL)
    } else {
      get(vname) # from the global envt
    }
  }
}
