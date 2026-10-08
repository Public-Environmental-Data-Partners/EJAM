#' Find the memory limit of the container this R process runs in, if any
#'
#' @details Reads the Linux "control group" (cgroup) memory limit that container platforms
#'   such as AWS ECS/Fargate and Docker set for a container. Returns NA when there is no
#'   limit, as on a laptop or on a server without a container memory limit.
#'
#' @param files cgroup files to check, in order: cgroup v2 first, then cgroup v1.
#'
#' @return the limit in bytes, or NA if no limit was found
#'
#' @seealso [memory_cap_for_app()]
#'
#' @keywords internal
#'
memory_container_limit_bytes <- function(files = c("/sys/fs/cgroup/memory.max",
                                                   "/sys/fs/cgroup/memory/memory.limit_in_bytes")) {
  for (f in files) {
    if (!file.exists(f)) next
    x <- suppressWarnings(try(trimws(readLines(f, n = 1, warn = FALSE)), silent = TRUE))
    if (inherits(x, "try-error") || length(x) == 0) next
    if (identical(x, "max")) return(NA_real_) # cgroup v2: no limit
    bytes <- suppressWarnings(as.numeric(x))
    if (is.na(bytes) || bytes <= 0) next
    if (bytes >= 2^60) return(NA_real_) # cgroup v1 reports about 9.2e18 when there is no limit
    return(bytes)
  }
  NA_real_
}
############################################################################### #

#' Cap R's memory in the hosted app, so a too-large analysis stops with an error instead of crashing the app
#'
#' @details In a container with a memory limit, if the app's R process uses more memory than
#'   the limit, the operating system stops the whole container, which ends every user's session
#'   in it (see EJAM issues 504 and 57 on GitHub). Capping R's own memory (its "vector heap",
#'   see [base::mem.maxVSize()]) below that limit instead makes R stop just the one analysis
#'   that needs too much memory, with an error the app can catch and explain to that user,
#'   while the app stays up for everyone else. Near the cap, R also cleans up unused memory
#'   more thoroughly before giving up, so an analysis fails only if the data it really needs
#'   do not fit.
#'
#'   The cap applies only to R's own memory. The rest of the container's memory is used by
#'   things outside it: the index of Census blocks, data read with arrow, loaded packages, and
#'   helper programs such as pandoc and Chrome used for reports. `reserve_gb` is how much of
#'   the container limit to leave for those (about 2-2.5 GB when the app is idle, more after
#'   some datasets are loaded on first use).
#'
#'   Does nothing if the environment variable R_MAX_VSIZE is set (R then already enforces
#'   that cap), or if cap_gb is not given and no container limit is found (e.g., on a laptop).
#'
#' @param cap_gb Optional cap in GB. If NULL or NA (the default), the cap is the
#'   container memory limit minus `reserve_gb`.
#' @param reserve_gb GB of the container memory limit to leave for memory used outside R's own memory.
#' @param limit_bytes the container memory limit in bytes, found by [memory_container_limit_bytes()] by default
#' @param quiet set to TRUE to avoid a message saying what was done
#'
#' @return invisibly, the cap in GB that was set, or NA if none was set
#'
#' @keywords internal
#'
memory_cap_for_app <- function(cap_gb = NULL, reserve_gb = 3, limit_bytes = memory_container_limit_bytes(), quiet = FALSE) {

  say <- function(...) {if (!quiet) message("EJAM memory cap: ", ...)}
  if (nzchar(Sys.getenv("R_MAX_VSIZE"))) {
    say("R_MAX_VSIZE is set to ", Sys.getenv("R_MAX_VSIZE"), ", so that cap is left as is.")
    return(invisible(NA_real_))
  }
  limit_gb <- limit_bytes / 1024^3
  if (is.null(cap_gb) || length(cap_gb) != 1 || is.na(cap_gb)) {
    if (is.na(limit_gb)) {
      say("none set, since no container memory limit was found.")
      return(invisible(NA_real_))
    }
    cap_gb <- limit_gb - reserve_gb
  }
  if (!is.numeric(cap_gb) || !is.finite(cap_gb)) {
    say("none set, since the cap requested was not a number.")
    return(invisible(NA_real_))
  }
  # never set a cap so low that the data already loaded leave no room for even a small analysis
  inuse_gb <- sum(gc()[, 2]) / 1024
  if (cap_gb < inuse_gb + 1) {
    say("none set, since ", round(cap_gb, 2), " GB would leave less than 1 GB beyond the ",
        round(inuse_gb, 2), " GB R already uses (container limit ",
        if (is.na(limit_gb)) "unknown" else paste(round(limit_gb, 2), "GB"), ", reserve ", reserve_gb, " GB).")
    return(invisible(NA_real_))
  }
  mem.maxVSize(vsize = cap_gb * 1024) # in Mb
  say(round(cap_gb, 2), " GB for R's own memory (container limit ",
      if (is.na(limit_gb)) "unknown" else paste(round(limit_gb, 2), "GB"),
      ", reserve ", reserve_gb, " GB; R uses ", round(inuse_gb, 2), " GB now).")
  invisible(cap_gb)
}
############################################################################### #

#' Plain-language message for an error that stopped an analysis in the web app
#'
#' @param e an error condition
#'
#' @return a message to show the user
#'
#' @keywords internal
#'
analysis_error_message <- function(e) {
  msg <- conditionMessage(e)
  if (grepl("vector memory limit|cannot allocate vector|memory exhausted", msg, ignore.case = TRUE)) {
    paste0("This analysis needs more memory than this server allows, so it was stopped. ",
           "Please try fewer places or a smaller radius, or split the places into a few smaller analyses.")
  } else {
    paste0("The analysis stopped because of an error: ", msg)
  }
}
############################################################################### #

#' Run one step of an analysis in the web app, catching an error such as reaching the memory cap
#'
#' @details The Start Analysis observer in the web app runs each step that can need a lot of
#'   memory, such as buffering polygons or [ejamit()], through this function. An error in that
#'   step, such as reaching the cap set by [memory_cap_for_app()] in a very large analysis, then
#'   stops just this analysis with a message for this user, instead of ending the user's session.
#'   `validate()` and `req()` inside the step keep their usual effect.
#'
#' @param expr the code to run, such as a call to [ejamit()]
#' @param step short name of the step, used in the log message
#'
#' @return the value of `expr`, or if it stopped with an error, a list with element `message`
#'   (from [analysis_error_message()]) and class `"analysis_failed"`
#'
#' @keywords internal
#'
analysis_step_in_app <- function(expr, step = "ejamit()") {
  tryCatch(expr, error = function(e) {
    if (inherits(e, "shiny.silent.error")) {stop(e)} # from validate() or req()
    message(step, " stopped with an error in the web app: ", conditionMessage(e))
    structure(list(message = analysis_error_message(e)), class = "analysis_failed")
  })
}
